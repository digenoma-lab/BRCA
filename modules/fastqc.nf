process FASTQC {
    tag "$sampleId-mem"
    cpus 8
    memory '10 GB'

    //label 'process_medium'
    // -t $task.cpus
    container "docker://quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0"

    publishDir "$params.outdir/QC/FASTQC", mode: "copy"

    input:
    tuple val(sampleId), val(part), file(read1), file(read2)

    output:
    path("${sampleId}-${part}.fastqc"), emit: fqc 
	
    script:
    	if(params.debug == true){
    		"""
    		echo fastqc --noextract -o ${sampleId}-${part}.fastqc $read1 $read2
    		mkdir -p ${sampleId}-${part}.fastqc
    		touch ${sampleId}-${part}.fastqc/report.fastqc
    
    		"""
    }   else{
    		"""
    		mkdir -p ${sampleId}-${part}.fastqc
    		fastqc --noextract -o ${sampleId}-${part}.fastqc $read1 $read2
    		"""
    }
}
