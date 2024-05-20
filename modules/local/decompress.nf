process DECOMPRESS {
        tag "$sample"
        label 'process_single'

        input:
        tuple val(sample), path(files)

        output:
        tuple val(sample), path(files), stdout

        script:
        """
        decompress.sh ${files}
        echo "Files are decompressed"
        """
}
