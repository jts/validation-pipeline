#!/bin/bash -l
module purge 
module unuse /oicr/local/boutroslab/Modules/modulefiles
module use /.mounts/labs/simpsonlab/modules/

module load samtools/1.2
module load bcftools/1.1

DEFREF=/oicr/data/pancanxfer/validation/reference/bwa-0.6.2/genome.fa

if [ $# -eq 0 ] || [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ]
then
    echo "$0 - performs variant calling on two BAMS"
    echo "Usage: $0 NORMAL.BAM TUMOUR.BAM REGIONS.BED TARGETS.BED OUTFILE.VCF [REFERENCE=$DEFREF]"
    exit 
fi

NORMAL=$1
TUMOUR=$2
REGIONS=$3
TARGETS=$4
OUTPUT=$5
REFERENCE=${6-$DEFREF}

mpileupdir=/oicr/data/pancanxfer/validation/mpileups

mkdir -p ${mpileupdir}
mpileupfile=${mpileupdir}/$( basename $OUTPUT .vcf ).mpileup

if [ ! -f ${mpileupfile} ]
then
    samtools mpileup --output-tags DP,DP4,SP -C50 --positions $REGIONS -gf $REFERENCE $NORMAL $TUMOUR > ${mpileupfile}
fi
if [ -f ${mpileupfile} ] && [ ! -f ${OUTPUT} ]
then
    bcftools view --output-type v --targets-file $TARGETS ${mpileupfile} > $OUTPUT
fi
