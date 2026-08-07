# BRCA
A Nextflow pipeline for processing target NGS BRCA data

#
## Dry run
```
cd BRCA
nextflow run main.nf -profile kutral --csv ../readsHRR_1-4.csv -params-file ../params-brca.yml -c nexflow.config
```

## Input files

Los siguientes archivos son relativos al cluster UOH.

```
## Example params-brca.yml
dbsnp: /databases/references/human/GATK_Bundle/Homo_sapiens_assembly38.dbsnp138.elsites
dbindel: /databases/references/human/GATK_Bundle/Mills_and_1000G_gold_standard.indels.hg38.elsites
ref: /references/human/bwa2/hs38DH.fa
brca_reg: brca.bed.gz
brca_amp: AmpliSeq_BRCA_hg38_new.bed

ANNOVAR_CODE: annovar/table_annovar.pl
ANNOVAR_DB: databases/annovar/hg38
```

## Current pipeline

1. run the ***genome.mk*** makefile script which perform genome alignment, quality control, and post processing. 
The batch script  ***run-genome-pipeline.sh*** under script directory is currently used to submit the job to the cluster.

2. call variants using the following command 
```
```
3. Annotate the resulting variants using annovar with the following command:


## Nextflow pipeline
The idea is to build a nextflow pipeline to automatize all the above steps.




