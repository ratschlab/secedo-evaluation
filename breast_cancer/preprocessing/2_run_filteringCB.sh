if [ "$#" -ne 1 ]; then
            echo "Usage:"
            echo "         2_run_filteringCB.sh <bam_file>"
            exit 1
fi

if [ ! -f $1 ]; then
    echo "File not found: $1"
    exit 1
fi

DIR="$(dirname "$1")"
FILTERED_BAM="${DIR}/$(basename -- $1)"
FILTERED_BAM_CB="${FILTERED_BAM%.bam}_CB.bam"
LOG="${DIR}/run_filteringCB.log"
TMP_FILE="${DIR}/tmp"
HEADER="${DIR}/tmp_header"

echo "Filtering ${FILTERED_BAM} into ${FILTERED_BAM_CB}"
echo "Writing logs to: $LOG"

echo > $LOG
date >> $LOG


#### filtering out reads not containing the CB tag
echo "Filtering reads without CB tag" >> $LOG
# save the header
samtools view -H $FILTERED_BAM > $HEADER
# filter the body
echo "samtools view $FILTERED_BAM | grep CB:Z: > $TMP_FILE" >> $LOG
samtools view $FILTERED_BAM | grep "CB:Z:"  > $TMP_FILE
echo "cat $HEADER $TMP_FILE | samtools view -b > $FILTERED_BAM_CB" >> $LOG
cat $HEADER $TMP_FILE | samtools view -b > $FILTERED_BAM_CB
echo "Number of reads with CB tag:" >> $LOG
samtools view -c $FILTERED_BAM_CB >> $LOG
echo >> $LOG
# remove the temporary files
rm $TMP_FILE $HEADER
# index the file
echo "samtools index $FILTERED_BAM_CB" >> $LOG
samtools index $FILTERED_BAM_CB
date >> $LOG
