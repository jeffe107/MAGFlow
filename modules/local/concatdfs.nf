process CONCAT_DFS {
	tag "$sample"
	label 'process_single'

	conda "conda-forge::pandas=2.2.1"
	container "${ params.use_singularity ?
            'https://depot.galaxyproject.org/singularity/pandas:1.5.2' :
            'biocontainers/bioframe:0.6.2--pyhdfd78af_0' }"

	input:
	tuple val(sample), path(files), val(change_dot_for_underscore)
	val "checkm2"
	val "busco"
	val "gunc"
	val "quast"
	val "gtdbtk2"

	output:
	stdout

	script:
	def outdir = params.outdir
	"""
	mkdir -p "${outdir}/${sample}/concat_dfs"
	concat_dfs.py "${outdir}/${sample}" ${sample} ${outdir} ${files}
	echo "Concatenated dataframes are ready"
	"""
}