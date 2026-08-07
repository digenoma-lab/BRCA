process QUALIMAP{
    tag "$sampleId-qualimap"
    //label 'process_medium'

    publishDir "$params.outdir/QC/QUALIMAP", mode: "copy"
    
    //container "https://depot.galaxyproject.org/singularity/qualimap:2.2.2a--1"  // Ruta a la imagen Singularity
    //containerOptions "-B /mnt/beegfs:/mnt/beegfs"

    input:
    tuple val(sampleId), file(bam), file(bai)

    output:
    path("${sampleId}.qualimap") , emit : qc

    script:
    if(params.debug == true){
    	"""
    	echo qualimap  bamqc  -gff ${params.brca_amp} -bam $bam  -outdir ${sampleId}.qualimap --java-mem-size=30G -nt $task.cpus
    	mkdir ${sampleId}.qualimap
    	touch ${sampleId}.qualimap/summaryQualimap.txt
    	"""
    }else{
    	"""
    	qualimap  bamqc -gff ${params.brca_amp} -bam $bam -outdir ${sampleId}.qualimap --java-mem-size=30G -nt $task.cpus
    	"""
    }
    
}
