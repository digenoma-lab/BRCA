.DELETE_ON_ERROR:
CPU=1
VPATH = ${PWD}/reads fastqc cov
REF=/home/adigenova/DiGenomaLab/databases/references/human/hs38DH.fa

files_aln:=$(patsubst %.R1.fastq.gz,%.bam,$(notdir $(wildcard reads/*.R1.fastq.gz)))

%.bam:%.R1.fastq.gz
	bwa mem -t ${CPU} ${REF} $< $(subst .R1.,.R2.,$<) | samtools view -Sb - | samtools fixmate -m namecollate.bam | samtools sort -o $(subst .R1.fastq.gz,,$(notdir $<)).bam -
	samtools index $(subst .R1.fastq.gz,,$(notdir $<)).bam

aln:$(files_aln)

files_qc:=$(patsubst %.bam,%.qc,$(files_aln))
%.qc:%.bam
	samtools coverage $< > $@.cov	
	samtools flagstats $< > $@	

qc:$(files_qc)

#fastqc

files_fastqc:=$(patsubst %.R1.fastq.gz,%.R1_fastqc.zip,$(notdir $(wildcard reads/*.R1.fastq.gz)))
%.R1_fastqc.zip:%.R1.fastq.gz
	fastqc $< -o fastqc
	fastqc $(subst .R1.,.R2.,$<) -o fastqc

fastqc:$(files_fastqc)

# coverage
files_cov:=$(patsubst %.bam,%.brca1.cov,$(files_aln))
%.brca1.cov:%.bam
	samtools coverage -q 20 -Q 20 -r chr17:43044295-43125483 -o cov/$@ $<
	samtools coverage -q 20 -Q 20 -A -r chr17:43044295-43125483 -o cov/$@.hist $<
	samtools coverage -q 20 -Q 20 -r chr13:32315086-324002683 -o cov/$(subst brca1,brca2,$@) $<
	samtools coverage -q 20 -Q 20 -A -r chr13:32315086-324002683 -o cov/$(subst brca1,brca2,$@).hist $<
cov:$(files_cov)


#	ls *.bam | xargs -P 5 -n 1 -i samtools coverage -q 20 -Q 20 -r chr17:43044295-43125483 -o {}.brca1.cov.out {}
files_md:=$(patsubst %.R1.fastq.gz,%.md.bam,$(notdir $(wildcard reads/*.R1.fastq.gz)))
%.md.bam:%.R1.fastq.gz
	bwa mem -R "@RG\tID:$(subst .md.bam,,$@)\tSM:$(subst .md.bam,,$@)" -t ${CPU} ${REF} $< $(subst .R1.,.R2.,$<) | samtools view -Sb - | samtools fixmate -m  - $(subst .R1.fastq.gz,,$(notdir $<)).fixmate.bam
	samtools view -Sb $(subst .R1.fastq.gz,,$(notdir $<)).fixmate.bam | samtools sort -o $(subst .R1.fastq.gz,,$(notdir $<)).sort.bam -
	samtools markdup $(subst .R1.fastq.gz,,$(notdir $<)).sort.bam $(subst .R1.fastq.gz,,$(notdir $<)).md.bam
	samtools index $(subst .R1.fastq.gz,,$(notdir $<)).md.bam
	-rm -f $(subst .R1.fastq.gz,,$(notdir $<)).fixmate.bam $(subst .R1.fastq.gz,,$(notdir $<)).sort.bam
	
md:$(files_md)

all : aln qc fastqc cov md

clean: 
	-rm -f *.bam *.bai


#micormamba activate hrr_env
