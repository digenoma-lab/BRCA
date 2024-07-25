#!/usr/bin/env nextflow

nextflow.enable.dsl = 2
//check some variables before execution

//loading scripts from modules
include {FASTQC} from './modules/fastqc'
include {BWAMEM} from './modules/bwamem'
include {MERGEB} from './modules/mergeb'
include {ELPREP} from './modules/elprep'
include {SAMTOOLS} from './modules/samtools'
include {QUALIMAP} from './modules/qualimap'
include {B2C} from './modules/b2c'
include {STRELKA_ONESAMPLE} from './modules/strelka'
include {STRELKA_POOL} from './modules/strelka'
include {BCFTOOLS_FILTER; BCFTOOLS_FILTER as BF} from './modules/bcftools'
include {ANNOVAR as ANNOVAR_DS} from './modules/annovar'
include {ANNOVAR as ANNOVAR_DP} from './modules/annovar'
include {ANNOVAR as ANNOVAR_SS} from './modules/annovar'
include {ANNOVAR as ANNOVAR_SP} from './modules/annovar'
include {MULTIQC} from './modules/multiqc'
include {DEEPVARIANT_ONESAMPLE} from './modules/deepvariant'
include	{GLNEXUS_DEEPVARIANT} from './modules/glnexus'
include {B2V} from './modules/b2v'

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
    echo "MultiQC: xxx" >> versions.txt
    echo "DeepVariant: 1.6.1" >> versions.txt 
    echo "GLnexus: 1.4.1" >> versions.txt
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

    read_pairs_ch.view()
    //fastqc read quality

    FASTQC(read_pairs_ch)
    //read aligment alt/hla
    BWAMEM(read_pairs_ch)

    //we do merge the bams by sample ID
    groups=BWAMEM.out.bams.groupTuple(by: 0)
    MERGEB(groups)
    MERGEB.out.mbams.view()

    //bam procesisng sort/duplciates/bqrs
    SAMTOOLS(MERGEB.out.mbams)

    //Quality of alignments
    SAMTOOLS.out.bams.view()
    QUALIMAP(SAMTOOLS.out.bams)


    //BAM->CRAM conversion
    B2C(SAMTOOLS.out.bams)

    //Strelka to call variants
    STRELKA_ONESAMPLE(SAMTOOLS.out.bams)


    //we prepare samples for running strelka pool
    bams = SAMTOOLS.out.bams.map {it -> it[1]}.collect()
    bais = SAMTOOLS.out.bams.map {it -> it[2]}.collect()

    STRELKA_POOL("Strelka",bams,bais)
    BCFTOOLS_FILTER(STRELKA_ONESAMPLE.out.vcf)

    //we filter pool variants
    BF(STRELKA_POOL.out.vcf)

    //DeepVariant to call variants - single sample
    DEEPVARIANT_ONESAMPLE(SAMTOOLS.out.bams)


    DEEPVARIANT_ONESAMPLE.out.gvcf.view()
    gvcfs = DEEPVARIANT_ONESAMPLE.out.gvcf.map {it -> it[1]}.collect()
    
    // glnexus to merge variants - pool DeepVariants
    GLNEXUS_DEEPVARIANT("DeepVariant",gvcfs)
    GLNEXUS_DEEPVARIANT.out.bcf.view()

    //bcf to vcf
    B2V(GLNEXUS_DEEPVARIANT.out.bcf)

    //Annotation with ANNOVAR
    ANNOVAR_DP(B2V.out.vcf,"DP")
    ANNOVAR_DS(DEEPVARIANT_ONESAMPLE.out.vcf,"DS")
    ANNOVAR_SP(BF.out.vcf,"SP")
    ANNOVAR_SS(BCFTOOLS_FILTER.out.vcf,"SS")

    //MiltiQC for metrics
    MULTIQC(baseDir)
    
}
