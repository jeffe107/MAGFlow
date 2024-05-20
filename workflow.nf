/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Local to the pipeline
//
include { BUSCO				}	from './modules/local/busco.nf'
include { CHANGE_DOT_FOR_UNDERSCORE	}	from './modules/local/change_dot_for_underscore.nf'
include { CHECKM2			}	from './modules/local/checkm2.nf'
include { CHECKM2_DB			}	from './modules/local/checkm2_db.nf'
include { CONCAT_DFS			}	from './modules/local/concat_dfs.nf'
include { DECOMPRESS			}	from './modules/local/decompress.nf'
include { EMPTY_BINS			}	from './modules/local/empty_bins.nf'
include { FINAL_DF			}	from './modules/local/final_df.nf'
include { GTDBTK2                       }	from './modules/local/gtdbtk2.nf'
include { GTDBTK2_DB			}	from './modules/local/gtdbtk2_db.nf'
include { GUNC				}	from './modules/local/gunc.nf'
include { GUNC_DB			}	from './modules/local/gunc_db'
include { QUAST				}	from './modules/local/quast.nf'
include { REMOVE_TMP			}	from './modules/local/remove_tmp.nf'
include { softwareVersionsToYAML	}	from './subworkflows/nf-core/utils_nfcore_pipeline'

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
