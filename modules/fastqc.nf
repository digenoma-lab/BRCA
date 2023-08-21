process FASTQC {
    tag "$sampleId-mem"
    //label 'process_medium'
    publishDir "$params.outdir/QC/FASTQC", mode: "copy"

    input:
    tuple val(sampleId), val(part), file(read1), file(read2)

    output:
    path("${sampleId}-${part}.fastqc"), emit: fqc 
	
    script:
    	if(params.debug == true){
    		"""
    		echo fastqc -o ${sampleId}-${part}.fastqc $read1 $read2
    		mkdir -p ${sampleId}-${part}.fastqc
    		touch ${sampleId}-${part}.fastqc/report.fastqc
    
    		"""
    }   else{
    		"""
    		mkdir -p ${sampleId}-${part}.fastqc
    		fastqc -t $task.cpus -o ${sampleId}-${part}.fastqc $read1 $read2
    		"""
    }
}
