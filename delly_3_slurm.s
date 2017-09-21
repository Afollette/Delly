#!/bin/bash
#SBATCH --job-name=delly_3_canine
#SBATCH -N 1  #The amount of nodes
#SBATCH -n  # amount of cores
#SBATCH -t 0-14-:00 # time
#SBATCH -o slurm.%N.%j.out # STDOUT
#SBATCH -e slurm.%N.%j.err # STDERR
#SBATCH --email-user=afollette@tgen.org
#SBATCH --mail-type=BEGIN--mail-type=END

##--parametrized scrip####
#SBATCH --export=CALL=<call>,NORMAL=<normalbam>,TUMOR=<tumorbam>,DIR=<dir>,OUTFILE=<PATH/FILENAME> delly_3.s


# -t was changed for every variant type
#include a samples.tsv file - tab delimited with sampleName\tNormalorTumor
cd ${DIR}

/home/ksivaprakasam/tools/delly/src/delly call -t ${CALL} -q 20 -o ${OUTFILE}"_"${CALL}"_delly.bcf" -g /home/tgenref/genomes/dog/canFam3.1/canFam3.1.fa ${NORMAL} ${TUMOR}

/home/ksivaprakasam/tools/delly/src/delly filter -t ${CALL} -f somatic  -o ${OUTFILE}"_"${CALL}"_pre_filter.bcf" -s /home/afollette/samples.tsv ${OUTFILE}"_"${CALL}"_delly.bcf"

/home/ksivaprakasam/tools/delly/src/bcftools/bcftools view ${OUTFILE}"_"${CALL}"_delly.bcf"  > ${OUTFILE}"_"${CALL}"_delly.vcf"

/home/ksivaprakasam/tools/delly/src/bcftools/bcftools view ${OUTFILE}"_"${CALL}"_pre_filter.bcf"  > ${OUTFILE}"_"${CALL}"_pre_filter.vcf"

#concat variant types and then annotate using snpeff
#example
#java -cp /home/tgenref/pecan/bin/GATK3.5.0/GenomeAnalysisTK.jar org.broadinstitute.gatk.tools.CatVariants -R ~/genome/canFam3.1/canFam3.1.fa -V TOCL_0005_DUP_pre_filter.vcf -V TOCL_0005_DEL_pre_filter.vcf -V TOCL_0005_INS_pre_filter.vcf -V TOCL_0005_INV_pre_filter.vcf -V TOCL_0005_TRA_pre_filter.vcf -out TOCL_0005_concatVariants.vcf -assumeSorted