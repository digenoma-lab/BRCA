
//BCFtools filter pass
process BCFTOOLS_FILTER {
    tag "$meta"
    publishDir "$params.outdir/BCFTOOLS", mode: "copy"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path("*.${extension}"), path("*.${extension}.tbi"), emit: vcf_tbi
    path  "versions.yml"                   , emit: versions

    script:
    def args = task.ext.args ?: '-f PASS --output-type z'
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
        
    bcftools index --tbi ${prefix}.${extension}


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bcftools: \$(bcftools --version 2>&1 | head -n1 | sed 's/^.*bcftools //; s/ .*\$//')
    END_VERSIONS
    """
    }
}

process TABIX {
    tag "$meta"
    publishDir "$params.outdir/TABIX", mode: "copy"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/tabix:1.11--hdfd78af_0':
        'biocontainers/tabix:1.11--hdfd78af_0' }"

    input:
    tuple val(meta), path(vcf)

    output:
    tuple val(meta), path(vcf), path("*.tbi"), emit: vcf_tbi

    script:
    """
    tabix -p vcf ${vcf}
    """
}