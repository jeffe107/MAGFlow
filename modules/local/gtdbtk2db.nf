process GTDBTK2_DB {
	label 'process_single'

	conda "bioconda::gtdbtk=2.4.0"
        container "${ params.use_singularity ?
            'https://depot.galaxyproject.org/singularity/gtdbtk:2.4.0--pyhdfd78af_0' :
            'biocontainers/gtdbtk:2.4.0--pyhdfd78af_0' }"
	containerOptions "${ params.directory_to_bind == null ? '' : "--bind ${params.directory_to_bind}" }"        

	output:
	stdout

	script:
	def outdir = params.outdir
	def path_db = "${outdir}/databases/gtdbtk2"
	"""
	[ ! -d $path_db/*/ ] && gtdbtk2_download_db.sh $outdir
	echo "GTDB-Tk2 is ready"
	"""
}
