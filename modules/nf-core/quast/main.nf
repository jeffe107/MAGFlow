process QUAST {
	tag "$sample"
	label 'process_medium'

	conda "bioconda::quast=5.2.0"
	container "${ params.use_singularity ?
            'https://depot.galaxyproject.org/singularity/quast:5.2.0--py38pl5321h5cf8b27_3' :
            'biocontainers/quast:5.2.0--py38pl5321h5cf8b27_3' }"

	input:
	tuple val(sample), path(files), val(change_dot_for_underscore)
	val "gtdbtk2_db"

	output:
	path "quast", emit: quast
	path "versions.yml", emit: versions

	script:
	def max_reference = "--max-ref-number ${params.max_ref_number}"
	def min_contig = "--min-contig ${params.min_contig}"
	"""
	quast.sh ${files} $max_reference $min_contig $task.cpus
	
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
		quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
	END_VERSIONS
	"""
}
