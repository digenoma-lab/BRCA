process B2C{
     tag "$sampleId-b2c"
    //label 'process_medium'

    publishDir "$params.outdir/CRAM", mode: "copy"


    conda "bioconda::samtools=1.17"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
                'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
                'biocontainers/samtools:1.17--h00cdaf9_0' }"


    input:
    tuple val(sampleId), file(bam), file(bai)

    output:
    tuple val("${sampleId}"), file("${sampleId}.out.cram"), file("${sampleId}.out.cram.crai"), emit: crams
    path("${sampleId}.out.flagstat"), emit: flags

    script:
    if(params.debug == true){
    	"""
    	echo samtools view -C -T ${params.ref} $bam -o ${sampleId}.out.cram
    	echo samtools index ${sampleId}.out.cram
    	echo samtools flagstats  ${sampleId}.out.cram > ${sampleId}.out.flagstat
    	touch ${sampleId}.out.cram
    	touch ${sampleId}.out.cram.crai
    	touch ${sampleId}.out.flagstat
    	"""
    }else{
    	"""
    	samtools view -C -T ${params.ref} $bam -o ${sampleId}.out.cram -@ $task.cpus
    	samtools index ${sampleId}.out.cram
    	samtools flagstats  ${sampleId}.out.cram > ${sampleId}.out.flagstat
    	"""
    }
}
