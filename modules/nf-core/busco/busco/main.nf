process BUSCO {
        tag "$sample"
        label 'process_medium'

        conda "bioconda::busco=5.7.0"
        container "${ params.use_singularity ?
            'https://depot.galaxyproject.org/singularity/busco:5.7.0--pyhdfd78af_1' :
            'biocontainers/busco:5.7.0--pyhdfd78af_1' }"

        input:
        tuple val(sample), path(files), val(change_dot_for_underscore)
        val "gtdbtk2_db"

        output:
        path "busco", emit: busco
        path "versions.yml", emit: versions

        script:
        def lineage = params.lineage == 'auto_lineage' ? "--auto-lineage" : "-l ${params.lineage}"
        def args = task.ext.args ?: ''
        """
        busco -i $files \
        -o busco \
        -m genome -c $task.cpus --force \
        $lineage $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
                busco: \$( busco --version 2>&1 | sed 's/^BUSCO //' )
        END_VERSIONS
        """
}
