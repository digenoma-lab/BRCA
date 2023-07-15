process STRELKA{
	tag "$sampleId-strelka"
	publishDir "$params.outdir/strelka", mode : "copy"
	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
	tuple val(sampleId), file(preprocessed_bam), file(bai)
	output:
	//Germnline analysis 
      	tuple val("${sampleId}"), file("genome.${sampleId}.vcf.gz"), file("genome.${sampleId}.vcf.gz.tbi"), emit: genom
	tuple file("variants.vcf.gz"), file("variants.vcf.gz.tbi"), emit: variants
	script:
	if (params.debug == true){
		"""
		echo
		${params.STRELKA_INSTALL_PATH}/bin/configureStrelkaGermlineWorkflow.py\
		--bam $preprocessed_bam \
		--referenceFasta ${params.REFERENCE_FASTA}\
		--exome \
		--callRegions ${params.BRCA_POSITION} \
		--runDir ./pool_germine 
		pool_germline/runWorkflow.py -m local -j 5
		"""
	}
	else{
		"""
		${params.STRELKA_INSTALL_PATH}/bin/configureStrelkaGermlineWorkflow.py\
                --bam $preprocessed_bam \
                --referenceFasta ${params.REFERENCE_FASTA}\
                --exome \
                --callRegions ${params.BRCA_POSITION} \
                --runDir ./pool_germine
                pool_germline/runWorkflow.py -m local -j 5
                """

	}
	
}
