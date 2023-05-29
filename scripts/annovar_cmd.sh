../../../databases/annovar/annovar/table_annovar.pl pool_germline/results/variants/variants.pass.vcf.gz ../../../databases/annovar/hg38 -out annovar_annot -nastring . -vcfinput --buildver hg38  -protocol abraom,avsnp150,clinvar_20220320,dbnsfp42c,ensGene,esp6500siv2_all,exac03,gene4denovo201907,gnomad30_genome,hrcr1,icgc28,intervar_20180118,kaviar_20150923,ljb26_all,mcap,regsnpintron,revel --codingarg -includesnp -operation f,f,f,f,g,f,f,f,f,f,f,f,f,f,f,f,f   --remove --onetranscript

#extract vcf info

bcftools query -f '%CHROM %POS %REF %ALT [ %GT]\n' variants.pass.vcf.gz 

