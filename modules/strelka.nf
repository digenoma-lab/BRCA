

//Run strelka for a single sample
process STRELKA_ONESAMPLE{
	tag "$sampleId-strelka"
	publishDir "$params.outdir/strelka_persample", mode : "copy"


	conda "bioconda::strelka=2.9.10"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/strelka:2.9.10--h9ee0642_1' :
        'biocontainers/strelka:2.9.10--h9ee0642_1' }"


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
				--referenceFasta ${params.REFERENCE_FASTA} \\
				--callRegions ${params.BRCA_POSITION} \\
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
			 --referenceFasta ${params.REFERENCE_FASTA} \\
			 --callRegions ${params.BRCA_POSITION} \\
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
	tag "$sample-strelkaPool"
	publishDir "$params.outdir/strelkaPool", mode : "copy"


	conda "bioconda::strelka=2.9.10"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/strelka:2.9.10--h9ee0642_1' :
        'biocontainers/strelka:2.9.10--h9ee0642_1' }"


	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
	val(bams)
	val(sample)
	output:
    tuple val("${sampleId}"), path("*variants.vcf.gz")    , emit: vcf
    tuple val("${sampleId}"), path("*variants.vcf.gz.tbi"), emit: vcf_tbi
    tuple val("${sampleId}"), path("*genome.vcf.gz")      , emit: genome_vcf
    tuple val("${sampleId}"), path("*genome.vcf.gz.tbi")  , emit: genome_vcf_tbi
	// path ("variants.pass.vcf.gz"), emit: variants
	

	script:
	def prefix = "${sample}"
	def samplesgroup=""
	
	if (params.debug == true){
		"""
		echo configureStrelkaGermlineWorkflow.py \\
				--bam ${bams} \\
				--referenceFasta ${params.REFERENCE_FASTA} \\
				--callRegions ${params.BRCA_POSITION} \\
				--exome  \\
				--runDir ./strelka_germline

		echo python strelka_germline/runWorkflow.py -m local -j $task.cpus
		touch  ${prefix}.genome.vcf.gz ${prefix}.genome.vcf.gz.tbi ${prefix}.variants.vcf.gz ${prefix}.variants.vcf.gz.tbi 
		"""
	}
	else{
		"""
	 configureStrelkaGermlineWorkflow.py \\
			 --bam ${bams} \\
			 --referenceFasta ${params.REFERENCE_FASTA} \\
			 --callRegions ${params.BRCA_POSITION} \\
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
process STRELKA_POOL_TWO{
	tag "strelkaPooltwo"
	publishDir "$params.outdir/strelkaPooltwo", mode : "copy"


	conda "bioconda::strelka=2.9.10"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/strelka:2.9.10--h9ee0642_1' :
        'biocontainers/strelka:2.9.10--h9ee0642_1' }"


	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
	val(bams)
	output:
	path("*variants.vcf.gz")    , emit: vcf
    path("*variants.vcf.gz.tbi"), emit: vcf_tbi
    path("*genome.vcf.gz")      , emit: genome_vcf
    path("*genome.vcf.gz.tbi")  , emit: genome_vcf_tbi
    path("*variants.pass.vcf.gz")  , emit: variants
   
	// path ("variants.pass.vcf.gz"), emit: variants
	

	script:
	
	def samplesgroup=""
	
	if (params.debug == true){
		"""
		echo configureStrelkaGermlineWorkflow.py \\
				 --bam ${bams}\\
				--referenceFasta ${params.REFERENCE_FASTA} \\
				--callRegions ${params.BRCA_POSITION} \\
				--exome  \\
				--runDir ./strelka_germline

		echo python strelka_germline/runWorkflow.py -m local -j $task.cpus
		touch genome.vcf.gz genome.vcf.gz.tbi variants.vcf.gz variants.vcf.gz.tbi variants.pass.vcf.gz
		"""
		// """
		// echo configureStrelkaGermlineWorkflow.py \\
		// 		for f in ${bams}; do 
		// 		 --bam "${f}" ; done; \\
		// 		--referenceFasta ${params.REFERENCE_FASTA} \\
		// 		--callRegions ${params.BRCA_POSITION} \\
		// 		--exome  \\
		// 		--runDir ./strelka_germline

		// echo python strelka_germline/runWorkflow.py -m local -j $task.cpus
		// touch variants.pass.vfc.gz
		// """
	}
	else{
		"""
	 configureStrelkaGermlineWorkflow.py \\
			 --bam ${bams} \\
			 --referenceFasta ${params.REFERENCE_FASTA} \\
			 --callRegions ${params.BRCA_POSITION} \\
			 --exome  \\
			 --runDir ./strelka_germline
	 python strelka_germline/runWorkflow.py -m local -j $task.cpus

   """

	}

}


