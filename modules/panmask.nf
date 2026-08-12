process PANMASK_FILTER {
    tag "$sample_id"
    label 'PANMASK'

    publishDir "${params.outdir}/panmask/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(input_vcf), path(input_vcf_index), path(panmask_bed)

    output:
    tuple val(sample_id), path("${sample_id}.panmask.vcf.gz"), path("${sample_id}.panmask.vcf.gz.tbi")

    script:
    """
    set -euo pipefail

    bedtools intersect \\
        -header \\
        -u \\
        -a "${input_vcf}" \\
        -b "${panmask_bed}" \\
        | bcftools view \\
            -Oz \\
            -o "${sample_id}.panmask.vcf.gz"

    bcftools index \\
        --tbi \\
        "${sample_id}.panmask.vcf.gz"
    """

    stub:
    """
    set -euo pipefail

    touch "${sample_id}.panmask.vcf.gz"
    touch "${sample_id}.panmask.vcf.gz.tbi"
    """
}