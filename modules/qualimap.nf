process QUALIMAP{
    tag "$sampleId-qualimap"
    //label 'process_medium'

    publishDir "$params.outdir/QC/QUALIMAP", mode: "copy"

    input:
    tuple val(sampleId), file(bam), file(bai)


    output:
    path("${sampleId}.qualimap") , emit : qc

   container "/mnt/beegfs/home/efeliu/work2024/080524_nextflow_BRCA/BRCA/images/qualimap_2.2.1.sif"  // Ruta a la imagen Singularity
   containerOptions "-B /mnt/beegfs:/mnt/beegfs"

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
