#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
//check some variables before execution

//loading scripts from modules
include {FASTQC} from './modules/fastqc'
include {BWAMEM} from './modules/bwamem'
include {MERGEB} from './modules/mergeb'
include {ELPREP} from './modules/elprep'
include {QUALIMAP} from './modules/qualimap'
include {B2C} from './modules/b2c'
include {STRELKA_ONESAMPLE} from './modules/strelka'
//include {STRELKA_ONESAMPLE} from './modules/strelka'
include {ANNOVAR} from './modules/annovar'

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
    echo "Strelka: 2.9.10" >> versions.txt
    echo "Annovar: zzz" >> versions.txt
    """
}

workflow {
    // TODO do a parameter check
    PRINT_VERSIONS()
    //we read pairs from regex
    if(params.csv != null){
    //we reads pairs from csv
    read_pairs_ch=Channel.fromPath(params.csv) \
        | splitCsv(header:true) \
        | map { row-> tuple(row.sampleId, row.part,  file(row.read1), file(row.read2))}\
    }else{
        println "Error: reads regex or path"
    }


    //read_pairs_ch.view()
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
    //if(params.onesample){
    STRELKA_ONESAMPLE(ELPREP.out.bams)
    //}else{
      //pool sample
    //ELPREP.out.bams.view()
    pool=ELPREP.out.bams.collect()
    pool.view()
      //STRELKA_POOL(pool)
    //}
    //STRELKA(ELPREP.out.bams)
    // Annovar to annotate variatns
    //ANNOVAR(STRELKA.out.variants)
    //MULTIQC(all_files)
}
