// Run deepVariant for a single sample
process DEEPVARIANT_ONESAMPLE{    
	
	cpus 8
	memory '20 GB'
	clusterOptions = '--nodelist=SRV04'

	tag "$sampleId-deepVariant"
	publishDir "$params.outdir/deepvariant_persample", mode: "copy"

    container "docker://google/deepvariant:1.6.1"
	containerOptions "-B /mnt/beegfs:/mnt/beegfs"
	
	input:
	//Input: bam files merged by mergedb process and preprocessed by elprep process
        tuple val(sampleId), file(preprocessed_bam), file(bai)
        
	output:
   	tuple val(sampleId), file("${sampleId}.variants.vcf")  , emit: vcf
	tuple val(sampleId), file("${sampleId}.variants.g.vcf") , emit: gvcf

	script:
	output=""

	if (params.debug == true){
        	"""
        echo run_deepvariant --model_type=WES \\
  	--ref=${params.ref} \\
  	--reads=$preprocessed_bam \\
  	--output_vcf=${sampleId}.variants.vcf \\
  	--output_gvcf=${sampleId}.variants.g.vcf \\
  	--regions="chr13:32315086-32400268 chr17:43044295-43125483" \\
	--num_shards=4
	"""
	}
	else {
    	"""
	run_deepvariant --model_type=WES \
        --ref=${params.ref} \
        --reads=$preprocessed_bam \
        --output_vcf=${sampleId}.variants.vcf \
        --output_gvcf=${sampleId}.variants.g.vcf \
	--regions="chr13:32315086-32400268 chr17:43044295-43125483" \
        --num_shards=4 \
   	"""
	}
}
