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
