//we do preproces the bam file
process ELPREP {

    tag "$sampleId-elprep"
    //label 'process_high'
    //we save some stats from elprep
    publishDir "$params.outdir/ELPREP", mode: "copy", pattern: '*.output.*'

    input:
     tuple val(sampleId), file(bam)
    output:
    tuple val("${sampleId}"), file("${sampleId}.out.bam"), file("${sampleId}.out.bam.bai"), emit: bams
    path("${sampleId}.out.bam.bai") , emit : bindex
    path("${sampleId}.output.metrics"), emit : metrics
    path("${sampleId}.output.recal"), optional: true

    script:
    
    if(params.debug == true){
    	"""
    	echo elprep sfm ${bam} ${sampleId}.out.bam --mark-duplicates --mark-optical-duplicates ${sampleId}.output.metrics \\
        	--sorting-order coordinate \\
        	--bqsr ${sampleId}.output.recal --known-sites ${params.dbsnp},${params.dbindel} \\
        	--reference ${params.elpre_ref}  --nr-of-threads $task.cpus
    	echo samtools index ${sampleId}.out.bam
    	#output files
    	touch ${sampleId}.out.bam
    	touch ${sampleId}.out.bam.bai
    	touch ${sampleId}.output.metrics
    	touch ${sampleId}.output.recal
    	"""
    }else{
    	if(params.bqsr == true){
    		"""
    		elprep sfm ${bam} ${sampleId}.out.bam --mark-duplicates --mark-optical-duplicates ${sampleId}.output.metrics \\
        		--sorting-order coordinate \\
        		--bqsr  ${sampleId}.output.recal --known-sites ${params.dbsnp},${params.dbindel} \\
        		--reference ${params.elpre_ref}  --nr-of-threads $task.cpus
    			samtools index ${sampleId}.out.bam
    		"""
   	}
   	else{
    		"""
    		elprep sfm ${bam} ${sampleId}.out.bam --mark-duplicates --mark-optical-duplicates ${sampleId}.output.metrics \\
        		--sorting-order coordinate \\
        		--reference ${params.elpre_ref}  --nr-of-threads $task.cpus
    		#we index the resulting bam file
    		samtools index ${sampleId}.out.bam
    		"""
    	}
   }
}
