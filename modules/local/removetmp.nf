process REMOVE_TMP {
	tag "$sample"
	label 'process_single'

	input:
	tuple val(sample), path(files), val(change_dot_for_underscore)
	val "std_output"

	output:
	stdout

	script:
	def outdir = params.outdir
	"""
	delete_files.sh "${outdir}/${sample}"
	[ -f "${outdir}/${sample}/versions.yml" ] && rm -r "${outdir}/${sample}/versions.yml"
	echo "Temporary files deleted. Your BIgMAG is ready"
	"""
}
