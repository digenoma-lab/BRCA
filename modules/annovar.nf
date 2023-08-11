process ANNOVAR{
	tag "annovar"
        publishDir "$params.outdir/annovar", mode: "copy"
	input:
	file(variants) 
        output:
        tuple file("*multianno.vcf"), file ("*multianno.txt"), emit: multianno
        script:
        if (params.debug == true){
                """
                echo
                ${params.ANNOVAR_CODE}/table_annovar.pl ${variants}
                ${params.ANNOVAR_DB}/hg38 -out annovar_annot
                -nastring . -vcfinput --buildver hg38
                -protocol abraom,avsnp150,clinvar_20220320,dbnsfp42c,ensGene,esp6500siv2_all,exac03,gene4denovo201907,gnomad30_genome,hrcr1,icgc28,intervar_20180118,kaviar_20150923,ljb26_all,mcap,regsnpintron,revel
                --codingarg -includesnp -operation f,f,f,f,g,f,f,f,f,f,f,f,f,f,f,f,f   --remove --onetranscript
                touch multianno.vcf multianno.txt
                """
	}
	else{
		"""
                ${params.ANNOVAR_CODE}/table_annovar.pl ${variants}
                ${params.ANNOVAR_DB}/hg38 -out annovar_annot
                -nastring . -vcfinput --buildver hg38
                -protocol abraom,avsnp150,clinvar_20220320,dbnsfp42c,ensGene,esp6500siv2_all,exac03,gene4denovo201907,gnomad30_genome,hrcr1,icgc28,intervar_20180118,kaviar_20150923,ljb26_all,mcap,regsnpintron,revel
                --codingarg -includesnp -operation f,f,f,f,g,f,f,f,f,f,f,f,f,f,f,f,f   --remove --onetranscript
                """
	}
	
}
