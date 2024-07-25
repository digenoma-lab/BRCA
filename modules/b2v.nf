// Run deepVariant for a single sample
process B2V{

	cpus 2
	memory '5 GB'

	tag "$sampleId-b2v"
	publishDir "$params.outdir/deepvariant_pool", mode: "copy"

    container "docker://quay.io/biocontainers/bcftools:1.17--haef29d1_0"
	containerOptions "-B /mnt/beegfs:/mnt/beegfs"

	input:
	//Input: bcf - glnexus output
    tuple val(sampleId), file(bcf)

	output:
    // output , file in vcf format
	tuple val("${sampleId}"), path("*.vcf")    , emit: vcf

	script:
    """
	bcftools convert -O v -o DeepVariant.pool.vcf ${bcf}
    """
}