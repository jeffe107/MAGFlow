process FINAL_DF {
	tag "final_df"
	label 'process_single'

        conda "conda-forge::pandas=2.2.1"
	container "${ params.use_singularity ?
            'https://depot.galaxyproject.org/singularity/pandas:1.5.2' :
            'biocontainers/bioframe:0.6.2--pyhdfd78af_0' }"

	input:
	val "concat_dfs"

	output:
	stdout

	script:
	def outdir = params.outdir
	"""
	final_df.py "${outdir}/paths.txt" $outdir
	[ -f "${outdir}/paths.txt" ] && rm -r "${outdir}/paths.txt"
	echo "Final dataframe is ready"
	"""
}
