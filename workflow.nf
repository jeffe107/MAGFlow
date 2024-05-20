/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { BUSCO				}	from './modules/nf-core/busco/busco/main.nf'
include { CHECKM2			}	from './modules/nf-core/checkm2/predict/main.nf'
include { CHECKM2_DB			}	from './modules/nf-core/checkm2/databasedownload/main.nf'
include { GTDBTK2                       }	from './modules/nf-core/gtdbtk/classifywf/main.nf'
include { GUNC				}	from './modules/nf-core/gunc/run/main.nf'
include { GUNC_DB			}	from './modules/nf-core/gunc/downloaddb/main.nf'
include { QUAST				}	from './modules/nf-core/quast/main.nf'
include { softwareVersionsToYAML	}	from './subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Local to the pipeline
//

include { CHANGE_DOT_FOR_UNDERSCORE	}	from './modules/local/changedotforunderscore.nf'
include { CONCAT_DFS			}	from './modules/local/concatdfs.nf'
include { DECOMPRESS			}	from './modules/local/decompress.nf'
include { EMPTY_BINS			}	from './modules/local/emptybins.nf'
include { FINAL_DF			}	from './modules/local/finaldf.nf'
include { GTDBTK2_DB			}	from './modules/local/gtdbtk2db.nf'
include { REMOVE_TMP			}	from './modules/local/removetmp.nf'

/*
 * workflow
 */

workflow MAGFlow {
		// Input channels
                
		if(params.files){
		    files_ch = Channel.fromPath( params.files, type: 'dir').map {tuple(it.baseName,it )}
		} else {
		    files_ch = Channel.fromPath( params.csv_file )
				   .splitCsv(header:true)
				   .map { row-> tuple(row.sampleId, file(row.files)) }
		}

		// Workflow including different tools
		
		ch_versions = Channel.empty()

		decompress_ch = DECOMPRESS(files_ch)
		
		empty_bins_ch = EMPTY_BINS(decompress_ch)

		change_dot_for_underscore_ch = CHANGE_DOT_FOR_UNDERSCORE(empty_bins_ch)

		if(params.run_gtdbtk2){
		    gtdbtk2_db_ch = GTDBTK2_DB()
                } else {
                    gtdbtk2_db_ch = []
                }
		
		busco_ch = Channel.empty()
		BUSCO(change_dot_for_underscore_ch, gtdbtk2_db_ch)
		busco_ch = busco_ch.mix(BUSCO.out.busco.collect { it } )
		busco_ch = busco_ch.first()                
		ch_versions = ch_versions.mix(BUSCO.out.versions.first())


                if(!params.checkm2_db){
		    checkm2_db_ch = CHECKM2_DB()
                } else {
                    checkm2_db_ch = []
                }

		checkm2_ch = Channel.empty()
		CHECKM2(change_dot_for_underscore_ch, checkm2_db_ch, gtdbtk2_db_ch)
		checkm2_ch = checkm2_ch.mix(CHECKM2.out.checkm2.collect { it } )
		checkm2_ch = checkm2_ch.first()
		ch_versions = ch_versions.mix(CHECKM2.out.versions.first())

                if(params.gtdbtk2_db || params.run_gtdbtk2){
		    gtdbtk2_ch = Channel.empty()
                    GTDBTK2(change_dot_for_underscore_ch, gtdbtk2_db_ch)
		    gtdbtk2_ch = gtdbtk2_ch.mix(GTDBTK2.out.gtdbtk2.collect { it } )
		    gtdbtk2_ch = gtdbtk2_ch.first()
		    ch_versions = ch_versions.mix(GTDBTK2.out.versions.first())
                } else {
                    gtdbtk2_ch = []
                }
                           
                if(!params.gunc_db){
		    gunc_db_ch = GUNC_DB()
                } else {
                    gunc_db_ch = []
                }

		gunc_ch = Channel.empty()
		GUNC(change_dot_for_underscore_ch, gunc_db_ch, gtdbtk2_db_ch)
		gunc_ch = gunc_ch.mix(GUNC.out.gunc.collect { it } )
		gunc_ch = gunc_ch.first()
		ch_versions = ch_versions.mix(GUNC.out.versions.first())

		quast_ch = Channel.empty()
                QUAST(change_dot_for_underscore_ch, gtdbtk2_db_ch)
		quast_ch = quast_ch.mix(QUAST.out.quast.collect { it } )
		quast_ch = quast_ch.first()
		ch_versions = ch_versions.mix(QUAST.out.versions.first())		

		// Final processing of the outputs
                concat_dfs_ch = CONCAT_DFS(change_dot_for_underscore_ch, checkm2_ch, busco_ch, gunc_ch, quast_ch, gtdbtk2_ch).collect()
		final_df_ch = FINAL_DF(concat_dfs_ch)

                REMOVE_TMP(change_dot_for_underscore_ch, final_df_ch)
		
		// Collate and save software versions

		softwareVersionsToYAML(ch_versions)
			.collectFile(
				storeDir: "${params.outdir}/pipeline_info",
				name: 'software_versions.yml',
				sort: true,
				newLine: true
			).set { ch_collated_versions }
}
