process GUNC_DB {
	label 'process_single'

	conda "bioconda::gunc=1.0.6"
	container "${ params.use_singularity ?
            'https://depot.galaxyproject.org/singularity/gunc:1.0.6--pyhdfd78af_0' :
            'biocontainers/gunc:1.0.6--pyhdfd78af_0' }"
	containerOptions "${ params.directory_to_bind == null ? '' : "--bind ${params.directory_to_bind}" }"

	output:
	stdout

	script:
	def outdir = params.outdir
	def path_db = "${outdir}/databases/GUNC_db/gunc_db_progenomes2.1.dmnd"
	"""
	[ -f $path_db ] || gunc_download_db.sh $outdir
	echo "GUNC database is ready"
	"""
}
