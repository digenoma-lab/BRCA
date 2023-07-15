process QUALIMAP{
    tag "$sampleId-qualimap"
    //label 'process_medium'
    
    publishDir "$params.outdir/QC/QUALIMAP", mode: "copy"

    input:
    tuple val(sampleId), file(bam), file(bai)
    

    output:
    path("${sampleId}.qualimap") , emit : qc
    
    script:
    if(params.debug == true){
    	"""
    	echo qualimap  bamqc  -bam $bam  -outdir ${sampleId}.qualimap --java-mem-size=30G -nt $task.cpus
    	mkdir ${sampleId}.qualimap
    	touch ${sampleId}.qualimap/summaryQualimap.txt
    	"""
    }else{
    	"""
    	qualimap  bamqc  -bam $bam  -outdir ${sampleId}.qualimap --java-mem-size=30G -nt $task.cpus
    	"""
    }
    
}
