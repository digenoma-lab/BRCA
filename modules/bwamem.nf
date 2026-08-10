//we do run bwa-mem2 or bwa-mem
process BWAMEM {

    tag "$sampleId-mem"
    //label 'process_high'
    publishDir "$params.outdir/BWA", mode: "copy", pattern: '*.log.*'
    publishDir "$params.outdir/BWA/HLA", mode: "copy", pattern: '*.hla.all'

    input:
    tuple val(sampleId), val(part), file(read1), file(read2)

    output:
    tuple val("${sampleId}"), val("${part}"), file("${sampleId}-${part}.aln.bam"), emit: bams
    path("${sampleId}-${part}.log.bwamem")
    path("${sampleId}-${part}.hla.all") , optional: true
    path("${sampleId}-${part}.log.hla") , optional: true

   script:
    def aln="bwa-mem2"
    //we define the aln tool
    if(params.aligner=="bwa"){
	aln="bwa"
    }
    if(params.debug == true){
    	"""
    	echo "seqtk mergepe $read1 $read2 | ${aln} mem -p -t $task.cpus -R'@RG\\tID:${sampleId}-${part}\\tSM:${sampleId}\\tPL:ill' ${params.ref} - 2> ${sampleId}-${part}.log.bwamem | k8 ${params.alt_js} -p ${sampleId}-${part}.hla ${params.ref}.alt | samtools view -1 - > ${sampleId}-${part}.aln.bam"
    	echo "run-HLA ${sampleId}-${part}.hla > ${sampleId}-${part}.hla.top 2> ${sampleId}-${part}.log.hla;"
    	echo "touch ${sampleId}-${part}.hla.HLA-dummy.gt; cat ${sampleId}-${part}.hla.HLA*.gt | grep ^GT | cut -f2- > ${sampleId}-${part}.hla.all"
    	echo "rm -f ${sampleId}-${part}.hla.HLA*;"
    	touch ${sampleId}-${part}.aln.bam
    	touch ${sampleId}-${part}.log.bwamem
    	touch ${sampleId}-${part}.hla.all
    	"""
    }else{
    	if(params.hla == true){
    	"""
		seqtk mergepe $read1 $read2 \\
        	| ${aln} mem -p -t $task.cpus -R'@RG\\tID:${sampleId}-${part}\\tSM:${sampleId}\\tPL:ill' ${params.ref} - 2> ${sampleId}-${part}.log.bwamem \\
        	| k8 ${params.alt_js} -p ${sampleId}-${part}.hla ${params.ref}.alt | samtools view -1 - > ${sampleId}-${part}.aln.bam
		run-HLA ${sampleId}-${part}.hla > ${sampleId}-${part}.hla.top 2> ${sampleId}-${part}.log.hla;
		touch ${sampleId}-${part}.hla.HLA-dummy.gt; cat ${sampleId}-${part}.hla.HLA*.gt | grep ^GT | cut -f2- > ${sampleId}-${part}.hla.all;
		rm -f ${sampleId}-${part}.hla.HLA*;
    	"""
    }
    	else if (params.alt == true){
     		"""
		seqtk mergepe $read1 $read2  \\
  		| ${aln} mem -p -t $task.cpus  -R'@RG\\tID:${sampleId}-${part}\\tSM:${sampleId}\\tPL:ill' ${params.ref} - 2> ${sampleId}-${part}.log.bwamem \\
  		| k8 ${params.alt_js} -p ${sampleId}-${part}.hla hs38DH.fa.alt \\
  		| samtools view -1 - > ${sampleId}-${part}.aln.bam
     	"""
    }else{
	//normal mapping mode
     	"""
	seqtk mergepe $read1 $read2 \\
  	| ${aln} mem -p -t $task.cpus  -R'@RG\\tID:${sampleId}-${part}\\tSM:${sampleId}\\tPL:ill' ${params.ref} - 2> ${sampleId}-${part}.log.bwamem \\
        | samtools view -1 - > ${sampleId}-${part}.aln.bam
     	"""
    }
  }

}
