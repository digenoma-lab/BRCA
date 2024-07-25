// Run GLnexus to merge deepvariants g.vcfs
process GLNEXUS_DEEPVARIANT{

	cpus 8
	memory '40 GB'
	clusterOptions = '--nodelist=SRV04'

	tag "$sampleId-deepVariant"
	publishDir "$params.outdir/deepvariant_pool", mode: "copy"

    container "docker://quay.io/biocontainers/glnexus:1.4.1--h5c1b0a6_3"
	containerOptions "-B /mnt/beegfs:/mnt/beegfs"

	input:
	//Input: gvcfs files - deepvariant outputs
    val(sampleId)
	file(inputgVCFs)

	output:
   	//file("cohorte.bcf"), emit: bcf
	tuple val("${sampleId}"), path("DeepVariant.pool.bcf")    , emit: bcf

	script:
	def files = inputgVCFs.join(' ')
    """
	echo "Archivos VCF: ${files}" 
    glnexus_cli --config DeepVariant_unfiltered ${files} > DeepVariant.pool.bcf
    """
}
