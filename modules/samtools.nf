process SAMTOOLS {

    tag "$sampleId-SamTools"
    //label 'process_high'
    //we save some stats from elprep
    //publishDir "$params.outdir/Samtools", mode: "copy"

    conda "bioconda::samtools=1.17"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
                'https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0' :
                'biocontainers/samtools:1.17--h00cdaf9_0' }"

    input:
     tuple val(sampleId), file(bam)
    output:
    tuple val("${sampleId}"), file("${sampleId}.md.bam"), file("${sampleId}.md.bam.bai"), emit: bams
    path("${sampleId}.md.bam.bai") , emit : bindex

    script:
    if(params.debug == true){
    	"""
      echo samtools view -Sb ${bam}  samtools fixmate -m  - ${sampleId}.fixmate.bam
      echo samtools view -Sb ${sampleId}.fixmate.bam  samtools sort -o ${sampleId}.sort.bam -
      echo samtools markdup ${sampleId}.sort.bam ${sampleId}.md.bam
      echo samtools index ${sampleId}.md.bam
    	#output files
    	touch ${sampleId}.md.bam
    	touch ${sampleId}.md.bam.bai
      """
    }else{
    	"""
        samtools view -Sb ${bam} | samtools fixmate -m  - ${sampleId}.fixmate.bam
        samtools view -Sb ${sampleId}.fixmate.bam | samtools sort -o ${sampleId}.sort.bam -
        samtools markdup ${sampleId}.sort.bam ${sampleId}.md.bam
        samtools index ${sampleId}.md.bam
        rm -f ${sampleId}.fixmate.bam ${sampleId}.sort.bam
    	"""
    }
}
