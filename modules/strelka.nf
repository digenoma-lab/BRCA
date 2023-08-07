

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
/*
process STRELKA_POOL{
	tag "$sampleId-strelkaPool"
	publishDir "$params.outdir/strelkaPool", mode : "copy"


	conda "bioconda::strelka=2.9.10"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/strelka:2.9.10--h9ee0642_1' :
        'biocontainers/strelka:2.9.10--h9ee0642_1' }"


	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
	 tuple val(group), [ val(sampleId), file(preprocessed_bam), file(bai)]
	output:
   tuple val("${sampleId}"), path("*variants.vcf.gz")    , emit: vcf
   tuple val("${sampleId}"), path("*variants.vcf.gz.tbi"), emit: vcf_tbi
   tuple val("${sampleId}"), path("*genome.vcf.gz")      , emit: genome_vcf
   tuple val("${sampleId}"), path("*genome.vcf.gz.tbi")  , emit: genome_vcf_tbi




	script:
	def prefix = "${sampleId}"
	def samplesgroup=""
	for(s in range) {
   statement #1
   statement #2
   }

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


		# configuration
STRELKA_INSTALL_PATH=/home/adigenova/DiGenomaLab/projects/HRR/gene_focus_analisis/strelka-2.9.10.centos6_x86_64
${STRELKA_INSTALL_PATH}/bin/configureStrelkaGermlineWorkflow.py \
    --bam AL_S9.md.bam \
    --bam DC_S14.md.bam \
    --bam JC_S13.md.bam \
    --bam JM_S12.md.bam \
    --bam KV_S3.md.bam \
    --bam LV_S2.md.bam \
    --bam MC_S16.md.bam \
    --bam ML_S10.md.bam \
    --bam NS_S5.md.bam \
    --bam PM_S15.md.bam \
    --bam PP_S7.md.bam \
    --bam PV_S1.md.bam \
    --bam PZ_S8.md.bam \
    --bam RQ_S6.md.bam \
    --bam VM_S4.md.bam \
    --bam YA_S11.md.bam \
    --referenceFasta /home/adigenova/DiGenomaLab/databases/references/human/hs38DH.fa \
    --exome \
    --callRegions brca.bed.gz \
    --runDir pool_germline
# execution on a single local machine with 20 parallel jobs
pool_germline/runWorkflow.py -m local -j 5



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
*/
