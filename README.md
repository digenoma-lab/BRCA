# BRCA
A Nextflow pipeline for processing target NGS BRCA data


## Dry run

```
nextflow run main.nf --csv test.csv --debug true --outdir results 
```


## Input files

Los siguientes archivos son relativos al cluster UOH.

1. reads : /mnt/beegfs/home/adigenova/DiGenomaLab/HRR/gene_focus_analisis/reads
2. reference genome : /mnt/beegfs/labs/DiGenomaLab/databases/references/human/hs38DH.fa 
3. BRCA1/2 positions :  /mnt/beegfs/labs/DiGenomaLab/HRR/gene_focus_analisis/brca.bed.gz
4. Annovar database : /mnt/beegfs/home/adigenova/DiGenomaLab/databases/annovar/hg38
5. Annovar code : /mnt/beegfs/labs/DiGenomaLab/databases/annovar/annovar/table_annovar.pl  



## Current pipeline

1. run the ***genome.mk*** makefile script which perform genome alignment, quality control, and post processing. 
The batch script  ***run-genome-pipeline.sh*** under script directory is currently used to submit the job to the cluster.

2. call variants using the following command 
```
# configuration
STRELKA_INSTALL_PATH=/home/adigenova/DiGenomaLab/projects/HRR/gene_focus_analisis/strelka-2.9.10.centos6_x86_64
${STRELKA_INSTALL_PATH}/bin/configureStrelkaGermlineWorkflow.py \
    --bam AL_S9.md.bam \
    --bam DC_S14.md.bam \
    --bam JC_S13.md.bam \
    --bam JM_S12.md.bam \
    --bam KV_S3.md.bam \
    --bam LV_S2.md.bam \
    --bam MC_S16.md.bam \
    --bam ML_S10.md.bam \
    --bam NS_S5.md.bam \
    --bam PM_S15.md.bam \
    --bam PP_S7.md.bam \
    --bam PV_S1.md.bam \
    --bam PZ_S8.md.bam \
    --bam RQ_S6.md.bam \
    --bam VM_S4.md.bam \
    --bam YA_S11.md.bam \
    --referenceFasta /home/adigenova/DiGenomaLab/databases/references/human/hs38DH.fa \
    --exome \
    --callRegions brca.bed.gz \
    --runDir pool_germline
# execution on a single local machine with 20 parallel jobs
pool_germline/runWorkflow.py -m local -j 5
```
3. Annotate the resulting variants using annovar with the following command:

```
table_annovar.pl pool_germline/results/variants/variants.pass.vcf.gz 
		<path>/databases/annovar/hg38 -out annovar_annot 
		-nastring . -vcfinput --buildver hg38  
		-protocol abraom,avsnp150,clinvar_20220320,dbnsfp42c,ensGene,esp6500siv2_all,exac03,gene4denovo201907,gnomad30_genome,hrcr1,icgc28,intervar_20180118,kaviar_20150923,ljb26_all,mcap,regsnpintron,revel 
		--codingarg -includesnp -operation f,f,f,f,g,f,f,f,f,f,f,f,f,f,f,f,f   --remove --onetranscript
```

## Nextflow pipeline
The idea is to build a nextflow pipeline to automatize all the above steps.




