

//Run strelka for a single sample
process STRELKA_ONESAMPLE{
	tag "$sampleId-strelka"
	publishDir "$params.outdir/strelka_persample", mode : "copy"

     conda "bioconda::strelka=2.9.10"
    //container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/strelka:2.9.10--h9ee0642_1' :
    //    'biocontainers/strelka:2.9.10--h9ee0642_1' }"
    container "/mnt/beegfs/home/efeliu/work2024/080524_nextflow_BRCA/BRCA/images/strelka:2.9.10--h9ee0642_1"

    containerOptions "-B /mnt/beegfs:/mnt/beegfs"

	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
	 tuple val(sampleId), file(preprocessed_bam), file(bai)
	output:
   tuple val("${sampleId}"), path("*variants.vcf.gz")    , emit: vcf
   tuple val("${sampleId}"), path("*variants.vcf.gz.tbi"), emit: vcf_tbi
   tuple val("${sampleId}"), path("*genome.vcf.gz")      , emit: genome_vcf
   tuple val("${sampleId}"), path("*genome.vcf.gz.tbi")  , emit: genome_vcf_tbi
	script:
	def prefix = "${sampleId}"

	if (params.debug == true){
		"""
		echo configureStrelkaGermlineWorkflow.py \\
				--bam $preprocessed_bam \\
				--referenceFasta ${params.ref} \\
				--callRegions ${params.brca_reg} \\
				--exome  \\
				--runDir ./strelka_germline

		echo python strelka_germline/runWorkflow.py -m local -j $task.cpus
		touch  ${prefix}.genome.vcf.gz ${prefix}.genome.vcf.gz.tbi ${prefix}.variants.vcf.gz ${prefix}.variants.vcf.gz.tbi
		"""
	}
	else{
		"""
	 configureStrelkaGermlineWorkflow.py \\
			 --bam $preprocessed_bam \\
			 --referenceFasta ${params.ref} \\
			 --callRegions ${params.brca_reg} \\
			 --exome  \\
			 --runDir ./strelka_germline

	 python strelka_germline/runWorkflow.py -m local -j $task.cpus
	 mv strelka_germline/results/variants/genome.*.vcf.gz     ${prefix}.genome.vcf.gz
	 mv strelka_germline/results/variants/genome.*.vcf.gz.tbi ${prefix}.genome.vcf.gz.tbi
	 mv strelka_germline/results/variants/variants.vcf.gz     ${prefix}.variants.vcf.gz
	 mv strelka_germline/results/variants/variants.vcf.gz.tbi ${prefix}.variants.vcf.gz.tbi
   """

	}

}




//Run strelka for a multiples samples using a pool!!!!

process STRELKA_POOL{
	tag "$sampleId-strelkaPool"
	publishDir "$params.outdir/strelka_pool", mode : "copy"


	conda "bioconda::strelka=2.9.10"
    //container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //    'https://depot.galaxyproject.org/singularity/strelka:2.9.10--h9ee0642_1' :
    //    'biocontainers/strelka:2.9.10--h9ee0642_1' }"
	
    container "/mnt/beegfs/home/efeliu/work2024/080524_nextflow_BRCA/BRCA/images/strelka:2.9.10--h9ee0642_1"

    containerOptions "-B /mnt/beegfs:/mnt/beegfs"
	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
	 val(sampleId)
	 file(bams)
	 file(bais)
	//val(bams)
	output:
    tuple val("${sampleId}"), path("*variants.vcf.gz")    , emit: vcf
    tuple val("${sampleId}"), path("*variants.vcf.gz.tbi"), emit: vcf_tbi
    tuple val("${sampleId}"), path("genome.*.vcf.gz")      , emit: genome_vcf
    tuple val("${sampleId}"), path("genome.*.vcf.gz.tbi")  , emit: genome_vcf_tbi
	// path ("variants.pass.vcf.gz"), emit: variants


	script:
	def prefix = "${sampleId}"
	def samplesgroup=""
  	def bamg=""
	for (b in bams){
		bamg=bamg+" --bam $b"
	}

	if (params.debug == true){
		"""
		echo configureStrelkaGermlineWorkflow.py \\
				${bamg} \\
				--referenceFasta ${params.ref} \\
				--callRegions ${params.brca_reg} \\
				--exome  \\
				--runDir ./strelka_germline

		echo python strelka_germline/runWorkflow.py -m local -j $task.cpus
		touch  genome.${prefix}.vcf.gz genome.${prefix}.vcf.gz.tbi ${prefix}.variants.vcf.gz ${prefix}.variants.vcf.gz.tbi
		"""
	}
	else{
		"""
	 configureStrelkaGermlineWorkflow.py \\
			${bamg} \\
			 --referenceFasta ${params.ref} \\
			 --callRegions ${params.brca_reg} \\
			 --exome  \\
			 --runDir ./strelka_germline
	 python strelka_germline/runWorkflow.py -m local -j $task.cpus
	 mv strelka_germline/results/variants/genome.*.vcf.gz     .
	 mv strelka_germline/results/variants/genome.*.vcf.gz.tbi .
	 mv strelka_germline/results/variants/variants.vcf.gz     ${prefix}.variants.vcf.gz
	 mv strelka_germline/results/variants/variants.vcf.gz.tbi ${prefix}.variants.vcf.gz.tbi
   """
	}
}
