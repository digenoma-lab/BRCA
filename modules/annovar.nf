process ANNOVAR{
	tag "$sampleId-annovar"
  	publishDir "$params.outdir/annovar", mode: "copy"

  input:
	tuple val(sampleId), file(variants)
  val(TOOL)
  
  output:
	tuple val ("${sampleId}"), file("*multianno.vcf"), file ("*multianno.txt"), emit: annovar

  script:
    if (params.debug == true){
    """
    echo
    perl ${params.ANNOVAR_CODE} ${variants} \
    ${params.ANNOVAR_DB} -out ${sampleId}.${TOOL}.annovar_annot \
    -nastring . -vcfinput --buildver hg38 \
    -protocol refGenee,avsnp150,clinvar_20240917,gnomad40_genome,icgc28,intervar_20180118,dbnsfp42c,revel \
    --codingarg -includesnp -operation g,f,f,f,f,f,f,f --remove
    touch multianno.vcf multianno.txt
    """
	}
	else{
		"""
    perl ${params.ANNOVAR_CODE} ${variants} \
    ${params.ANNOVAR_DB} -out ${sampleId}.${TOOL}.annovar_annot \
    -nastring . -vcfinput --buildver hg38 \
    -protocol refGene,avsnp150,clinvar_20240917,gnomad40_genome,icgc28,intervar_20180118,dbnsfp42c,revel \
    --codingarg -includesnp -operation g,f,f,f,f,f,f,f --remove
    """
	}

}
