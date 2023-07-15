//merge bams by sample
process MERGEB{

  tag "$sampleId-merge"

  input:
  tuple val(sampleId), val(parts), file(bamFiles)

  output:
  tuple val(sampleId), file("${sampleId}.merged.bam") ,emit: mbams

  script:
 
  if(params.debug == true){
  	"""
    	echo samtools merge -@ $task.cpus -f ${sampleId}.merged.bam ${bamFiles}
    	touch ${sampleId}.merged.bam
  	"""
  }else{
  	"""
  	samtools merge -@ $task.cpus -f ${sampleId}.merged.bam ${bamFiles}
  	"""
  }
}

