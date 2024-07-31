# BRCA

A Nextflow pipeline for processing target NGS BRCA data

## Nextflow Pipeline for BRCA Variant Calling Using Amplicon Illumina Data

This documentation provides an overview of the Nextflow pipeline for variant calling on BRCA genes using amplicon Illumina data and instructions on how to use it.

## Pipeline Overview

The pipeline performs the following steps:

1. **Quality Control**: Assess the quality of the sequencing reads using FastQC.
2. **Read Alignment**: Align reads to the reference genome using BWA-MEM.
3. **Merge BAM Files**: Merge aligned BAM files by sample ID.
4. **BAM Processing**: Process BAM files (sorting, marking duplicates) using SAMtools and Elprep.
5. **Quality Assessment**: Assess the quality of the alignments using Qualimap.
6. **BAM to CRAM Conversion**: Convert BAM files to CRAM format.
7. **Variant Calling**: Call variants using Strelka and DeepVariant.
8. **Variant Filtering**: Filter variant calls using BCFtools.
9. **Variant Annotation**: Annotate variants using ANNOVAR.
10. **Quality Control Summary**: Generate a summary of QC metrics using MultiQC.

## Instructions for Using the Pipeline

### Prerequisites

- Nextflow installed on your system.
- Required bioinformatics tools installed (e.g., BWA, SAMtools, FastQC, etc.).

## Dry run

```
nextflow run main.nf --csv test.csv --debug true --outdir results 
```

### Input Files

Prepare a CSV file containing the paths to your input sequencing reads. The CSV file should have the following columns:

- `sampleId`: Unique identifier for each sample.
- `part`: Part of the sample (e.g., replicate number).
- `read1`: Path to the first read file.
- `read2`: Path to the second read file.

2. fasta of reference genome : hs38DH.fa 
3. BRCA1/2 positions in bed format : brca.bed.gz
4. Path to Annovar database : <path>/annovar/hg38
5. Annovar code : <path>/annovar/table_annovar.pl  



### Running the Pipeline

1. **Prepare Input Files**: Ensure your input files are in the correct format and paths are specified correctly in the CSV file.

2. **Set Parameters**: Define the output directory and the path to the CSV file.

3. **Execute Pipeline**: Run the pipeline using the following command:

```bash
nextflow run <path_to_pipeline.nf> --csv <path_to_input_csv> --outdir <output_directory>
```

Replace `<path_to_pipeline.nf>`, `<path_to_input_csv>`, and `<output_directory>` with your actual file paths and directory.

### Example Command

```bash
nextflow run brca_variant_calling.nf --csv samples.csv --outdir results
```

This command runs the pipeline with the input samples specified in `samples.csv` and outputs the results to the `results` directory.

### Output

The pipeline generates various output files, including:

- Quality control reports.
- Aligned BAM/CRAM files.
- Variant call files (VCF).
- Filtered and annotated variant call files.
- A summary report of quality metrics.

### Developers




