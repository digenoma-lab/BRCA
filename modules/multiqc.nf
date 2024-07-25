process MULTIQC {
    label 'process_single'
    publishDir "$params.outdir/MultiQC", mode: "copy"

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/multiqc:1.22.2--pyhdfd78af_0' :
        'biocontainers/multiqc:1.22.2--pyhdfd78af_0' }"

    input:
    file '*'

    output:
    path "*multiqc_report.html", emit: report
    path "*_data"              , emit: data

    script:
    """
    multiqc --force .
    """
}