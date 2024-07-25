// Run bcf to vcf
process B2V{

	cpus 2
	memory '5 GB'

	tag "$sampleId-b2v"
	publishDir "$params.outdir/deepvariant_pool", mode: "copy"

    container "docker://quay.io/biocontainers/bcftools:1.17--haef29d1_0"

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