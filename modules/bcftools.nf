
//BCFtools filter pass
process BCFTOOLS_FILTER {
    tag "$meta"
    publishDir "$params.outdir/BCFTOOLS", mode: "copy"

    conda "bioconda::bcftools=1.17"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bcftools:1.17--haef29d1_0':
        'biocontainers/bcftools:1.17--haef29d1_0' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*.${extension}"), emit: vcf
    path  "versions.yml"                   , emit: versions

    script:
    def args = task.ext.args ?: '-f PASS'
    def prefix = task.ext.prefix ?: "${meta}.pass"

    extension = args.contains("--output-type b") || args.contains("-Ob") ? "bcf.gz" :
                    args.contains("--output-type u") || args.contains("-Ou") ? "bcf" :
                    args.contains("--output-type z") || args.contains("-Oz") ? "vcf.gz" :
                    args.contains("--output-type v") || args.contains("-Ov") ? "vcf" :
                    "vcf"

    if ("$vcf" == "${prefix}.${extension}") error "Input and output names are the same, set prefix in module configuration to disambiguate!"
    if(params.debug){
      """
      echo bcftools view \\
          --output-file ${prefix}.${extension} \\
          --threads ${task.cpus} \\
          $args \\
          $vcf
      touch ${prefix}.${extension}
      touch versions.yml
      """
    }else{
    """
    bcftools view \\
        --output-file ${prefix}.${extension} \\
        --threads ${task.cpus} \\
        $args \\
        $vcf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*\$//')
    END_VERSIONS
    """
    }
}
