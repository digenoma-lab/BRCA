#!/usr/bin/env nextflow

nextflow.enable.dsl = 2


//check some variables before execution
process PRINT_VERSIONS {
    publishDir "$params.outdir/software", mode: "copy"

    output:
    path("versions.txt")
    """
    echo "bwa-mem2: 2.2.1" > versions.txt
    echo "samtools: 1.16.1" >> versions.txt
    echo "elprep: 5.1.3" >> versions.txt
    echo "fastqc: v0.12.1" >> versions.txt
    echo "qualimap: v.2.2.2-dev" >> versions.txt
    echo "Strelka: xxx" >> versions.txt
    echo "Annovar: zzz" >> versions.txt
    """
}



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
    } else{
    """
    mkdir -p ${sampleId}-${part}.fastqc
    fastqc -t $task.cpus -o ${sampleId}-${part}.fastqc $read1 $read2
    """
    }
    
}

//we do run bwa-mem2 or bwa mem
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


//we do preproces the bam file
process ELPREP {

    tag "$sampleId-elprep"
    //label 'process_high'
    //we save some stats from elprep
    publishDir "$params.outdir/ELPREP", mode: "copy", pattern: '*.output.*'

    input:
     tuple val(sampleId), file(bam)
    output:
    tuple val("${sampleId}"), file("${sampleId}.out.bam"), file("${sampleId}.out.bam.bai"), emit: bams
    //path("${sampleId}.out.bam.bai") , emit : bindex
    path("${sampleId}.output.metrics"), emit : metrics
    path("${sampleId}.output.recal"), optional: true

    script:
    
    if(params.debug == true){
    """
    echo elprep sfm ${bam} ${sampleId}.out.bam --mark-duplicates --mark-optical-duplicates ${sampleId}.output.metrics \\
        --sorting-order coordinate \\
        --bqsr  ${sampleId}.output.recal --known-sites ${params.dbsnp},${params.dbindel} \\
        --reference ${params.elpre_ref}  --nr-of-threads $task.cpus
    echo samtools index ${sampleId}.out.bam
    #output files
    touch ${sampleId}.out.bam
    touch ${sampleId}.out.bam.bai
    touch ${sampleId}.output.metrics
    touch ${sampleId}.output.recal
    """
    }else{
    if(params.bqsr == true){
    """
    elprep sfm ${bam} ${sampleId}.out.bam --mark-duplicates --mark-optical-duplicates ${sampleId}.output.metrics \\
        --sorting-order coordinate \\
        --bqsr  ${sampleId}.output.recal --known-sites ${params.dbsnp},${params.dbindel} \\
        --reference ${params.elpre_ref}  --nr-of-threads $task.cpus
    samtools index ${sampleId}.out.bam
    """
   }
   else{
    """
    elprep sfm ${bam} ${sampleId}.out.bam --mark-duplicates --mark-optical-duplicates ${sampleId}.output.metrics \\
        --sorting-order coordinate \\
        --reference ${params.elpre_ref}  --nr-of-threads $task.cpus
    #we index the resulting bam file
    samtools index ${sampleId}.out.bam
    """
    }
   }
}


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

process B2C{
     tag "$sampleId-b2c"
    //label 'process_medium'
    
    publishDir "$params.outdir/CRAM", mode: "copy"

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





//we declare the workflow for index

workflow {
    // TODO do a parameter check
    PRINT_VERSIONS()
    //we read pairs from regex 
    if(params.reads != null){
    // --reads "./reads/B087*.merge.{1,2}.fq.gz"
    read_pairs_ch = channel.fromFilePairs(params.reads)
    }else if(params.csv != null){
    //we reads pairs from csv
    read_pairs_ch=Channel.fromPath(params.csv) \
        | splitCsv(header:true) \
        | map { row-> tuple(row.sampleId, row.part,  file(row.read1), file(row.read2)) }
    }else{
        println "Error: reads regex or path"
    }

    read_pairs_ch.view()
    //ref = path(params.ref)
    //fastqc read quality
    FASTQC(read_pairs_ch)
    //read aligment alt/hla
    BWAMEM(read_pairs_ch)
    //we do merge the bams by sample ID
    groups=BWAMEM.out.bams.groupTuple(by: 0)
    //groups.view()
    MERGEB(groups)
    //MERGEB.out.mbams.view()
    //bam procesisng sort/duplciates/bqrs
    ELPREP(MERGEB.out.mbams)
    //Quality of alignments
    QUALIMAP(ELPREP.out.bams)
    //BAM->CRAM conversion
    B2C(ELPREP.out.bams)
    // Strelka to call variants
    STRELKA(ELPREP.out.bams)
    // Annovar to annotate variatns
    ANNOVAR(STRELKA.vcf)
    // Automatic report with multiqc 
    MULTIQC(all_files)
}
