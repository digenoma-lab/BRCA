process CPSR {
    tag "$sample_id"
    label 'cpsr'

    containerOptions "--bind ${params.vep_dir}:${params.vep_dir},${params.refdata_dir}:${params.refdata_dir}" +
        (params.panel_id == 'custom' ? ",${file(params.custom_list).parent}:${file(params.custom_list).parent}" : "")

    publishDir "${params.outdir}/cpsr/${sample_id}", mode: 'copy'

    input:
    tuple val(sample_id), path(input_vcf), path(input_vcf_index)

    output:
    path "${sample_id}.cpsr.${params.genome_assembly}*"

    script:
    def clinvar_report_noncancer_arg = params.clinvar_report_noncancer ? '--clinvar_report_noncancer' : ''
    def secondary_findings_arg = params.secondary_findings ? '--secondary_findings' : ''
    def pgx_findings_arg = params.pgx_findings ? '--pgx_findings' : ''
    def gwas_findings_arg = params.gwas_findings ? '--gwas_findings' : ''
    def classify_all_arg = params.classify_all ? '--classify_all' : ''
    def force_overwrite_arg = params.force_overwrite ? '--force_overwrite' : ''
    def panel_arg = params.panel_id == 'custom' ?
        "--custom_list \"${params.custom_list}\" --custom_list_name \"${params.custom_list_name}\"" :
        "--panel_id \"${params.panel_id}\""
    """

    set -euo pipefail

    export HOME="\$PWD"
    export XDG_CACHE_HOME="\$PWD/.cache"
    export DENO_DIR="\$PWD/.cache/deno"
    export QUARTO_CACHE_DIR="\$PWD/.cache/quarto"
    mkdir -p "\$XDG_CACHE_HOME" "\$DENO_DIR" "\$QUARTO_CACHE_DIR"

    cpsr \\
        --input_vcf "${input_vcf}" \\
        --vep_dir "${params.vep_dir}" \\
        --refdata_dir "${params.refdata_dir}" \\
        --output_dir "." \\
        --genome_assembly "${params.genome_assembly}" \\
        ${panel_arg} \\
        --sample_id "${sample_id}" \\
        ${clinvar_report_noncancer_arg} \\
        ${secondary_findings_arg} \\
        ${pgx_findings_arg} \\
        ${gwas_findings_arg} \\
        ${classify_all_arg} \\
        --pop_gnomad "${params.pop_gnomad}" \\
        --maf_upper_threshold "${params.maf_upper_threshold}" \\
        ${force_overwrite_arg}
    """

    stub:
    """
    set -euo pipefail

    touch "${sample_id}.cpsr.${params.genome_assembly}.vcf.gz"
    touch "${sample_id}.cpsr.${params.genome_assembly}.vcf.gz.tbi"
    touch "${sample_id}.cpsr.${params.genome_assembly}.pass.vcf.gz"
    touch "${sample_id}.cpsr.${params.genome_assembly}.pass.vcf.gz.tbi"
    touch "${sample_id}.cpsr.${params.genome_assembly}.conf.yaml"
    touch "${sample_id}.cpsr.${params.genome_assembly}.pass.tsv.gz"
    touch "${sample_id}.cpsr.${params.genome_assembly}.xlsx"
    touch "${sample_id}.cpsr.${params.genome_assembly}.html"
    touch "${sample_id}.cpsr.${params.genome_assembly}.snvs_indels.classification.tsv.gz"
    """
}