# BRCA

Nextflow pipeline for clinical profiling of **BRCA1 and BRCA2** variants from targeted sequencing data.

## Run pipeline

```bash
nextflow run main.nf \
    -profile kutral \
    --csv example_input.csv \
    -params-file params-brca.yml \
    -c nextflow.config \
    -resume
```

## Input files

Samples are provided through a CSV file using the `--csv` parameter.

```bash
head example_input.csv
sampleId,part,read1,read2
17,0,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/17_S1.R1.fastq.gz,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/17_S1.R2.fastq.gz
18,0,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/18_S2.R1.fastq.gz,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/18_S2.R2.fastq.gz
20,0,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/20_S3.R1.fastq.gz,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/20_S3.R2.fastq.gz
21,0,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/21_S4.R1.fastq.gz,/mnt/beegfs/labs/DiGenomaLab/HRR/reads/21_S4.R2.fastq.gz
```
Pipeline parameters and reference files are defined in `params-brca.yml`.

Example:

```yaml
dbsnp: /mnt/beegfs/labs/DiGenomaLab/databases/references/human/GATK_Bundle/Homo_sapiens_assembly38.dbsnp138.elsites
dbindel: /mnt/beegfs/labs/DiGenomaLab/databases/references/human/GATK_Bundle/Mills_and_1000G_gold_standard.indels.hg38.elsites
ref: /mnt/beegfs/labs/DiGenomaLab/databases/references/human/bwa2/hs38DH.fa
elpre_ref: /mnt/beegfs/labs/DiGenomaLab/databases/references/human/hs38DH.fa.elfasta
bqsr: true

alt_js: /mnt/beegfs/home/efeliu/micromamba/envs/brca12/bin/bwa-postalt.js
brca_reg: /mnt/beegfs/labs/DiGenomaLab/HRR/nextflow/brca.bed.gz
brca_amp: /mnt/beegfs/home/efeliu/work2024/080524_nextflow_BRCA/AmpliSeq_BRCA_hg38_new.bed

ANNOVAR_CODE: /mnt/beegfs/labs/DiGenomaLab/databases/annovar/annovar/table_annovar.pl
ANNOVAR_DB: /mnt/beegfs/labs/DiGenomaLab/databases/annovar/hg38

panel_id: custom
#panel_id: 10 Familial breast cancer
custom_list: assets/brca_panel.tsv
custom_list_name: BRCA1_BRCA2
genome_assembly: grch38
```

## Pipeline

The workflow includes:

1. Read alignment with **BWA-MEM**
2. Quality control with **Qualimap**
3. Germline variant calling with **DeepVariant** and **Strelka**
4. Joint genotyping with **GLnexus**
5. Variant preprocessing with **BCFtools**
6. Variant annotation with **ANNOVAR**
7. Clinical interpretation with **CPSR**

## Citation

González E, Moreno Salinas R, Muñoz M, et al.  
**A workflow for clinical profiling of BRCA genes in Chilean breast cancer patients via targeted sequencing.**  
medRxiv (2024).

https://doi.org/10.1101/2024.09.25.24314295