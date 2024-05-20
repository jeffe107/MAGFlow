process EMPTY_BINS {
	tag "$sample"
	label 'process_single'
	
	input:
	tuple val(sample), path(files), val(decompressed)

	output:
	tuple val(sample), path(files), stdout

	script:
	def outdir = params.outdir

	"""
	empty_bins.sh ${files} $outdir $sample
	echo "Empty bins are removed"
	"""
}