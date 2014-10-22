#!/bin/bash

# exit on errr
set -e

#########
# USAGE #
#########

if [[ $# < 3 ]]; then
    echo "Usage:"
    echo "	$0 indir outdir reads"
    echo ""
    echo "	with:"
    echo "		indir: The input directory. The script will expect forward and reverse"
    echo "		       strand files found with a matching pattern."
    echo "		       - forward match pattern: $FORWARD_PATTERN"
    echo "		       - reverse match pattern: $REVERSE_PATTERN"
    echo "		outdir: The output directory. Will be created if it does not exist."
    echo "		       One output file per strand will be created in this directory."
    echo "		       The output file name will be the first file name in the input"
    echo "		       directory matched with above mentioned patterns."
    echo "		reads: The amount of reads to keep."

    exit 1
fi

##################
# MATCH PATTERNS #
##################

# Change the file matching pattern here if needed

FORWARD_PATTERN='*_1.fastq.gz'
REVERSE_PATTERN='*_2.fastq.gz'

##########
# params #
##########

INDIR=$1
OUTDIR=$2
READS=$3

[[ ! -e $OUTDIR ]] && mkdir $OUTDIR

SEQTK_DIR=`pwd`../seqtk/

########
# RUN! #
########

# get first file name - forward
FORWARD_OUTFILE=`ls -1 ${INDIR}/${FORWARD_PATTERN} | head -1`
FORWARD_OUTFILE=`basename $FORWARD_OUTFILE`
echo ${FORWARD_OUTFILE}

# get first file name - reverse
REVERSE_OUTFILE=`ls -1 ${INDIR}/${REVERSE_PATTERN} | head -1`
REVERSE_OUTFILE=`basename $REVERSE_OUTFILE`
echo ${REVERSE_OUTFILE}

# get a random number (range 0-32k)
SEED=$RANDOM

# create forward downsample file -- and put it in the background
COMMAND1="${SEQTK_DIR}/seqtk sample -s $SEED <(zcat ${INDIR}/${FORWARD_PATTERN}) $READS"
COMMAND2="gzip --to-stdout"
echo "$COMMAND1 | $COMMAND2 > ${OUTDIR}/${FORWARD_OUTFILE} &"
$COMMAND1 # | $COMMAND2 > ${OUTDIR}/${FORWARD_OUTFILE} &

# create reverse downsample file
#${SEQTK_DIR}/seqtk sample <(zcat ${INDIR}/$REVERSE_PATTERN}) | gzip --to-stdout -- > ${OUTDIR}/${REVERSE_OUTFILE}
