process CHANGE_DOT_FOR_UNDERSCORE {
	tag "$sample"
	label 'process_single'

	input:
	tuple val(sample), path(files), val(empty_bins)	

	output:
	tuple val(sample), path(files), stdout

	script:
	"""
	change_dot_for_underscore.sh ${files}
	echo "Changed dot for underscore"
	"""
}
