if [ "$#" -ne 1 ]; then
            echo "Usage:"
            echo "         1_run_filtering.sh <bam_file>"
            exit 1
fi

if [ ! -f $1 ]; then
    echo "File not found: $1"
    exit 1
fi

DIR="$(dirname "$1")"
OLD_BAM="${DIR}/$(basename -- $1)"
NEW_BAM="${OLD_BAM%.bam}_pos_sorted.bam"
LOG=$DIR/"run_filtering.log"

echo "Filtering ${OLD_BAM} into ${NEW_BAM}"
echo "Writing logs to: $LOG"
echo > $LOG
date >> $LOG
echo "Number of reads in the original BAM:" >> $LOG
samtools view -c $OLD_BAM >> $LOG
echo >> $LOG

#### filtering
# -h: include the header in the output
# -b: output in BAM
# filter: -f 0x2 ... read mapped in proper pair
#	-F 0x100 ... not not primary alignment (= primary alignment)
#	-F 0x400 ... not PCR or optical duplicate
echo "Filtering" >> $LOG
echo "samtools view -h -b -f 0x2 -F 0x500 $OLD_BAM > $NEW_BAM" >> $LOG
samtools view -h -b -f 0x2 -F 0x500 $OLD_BAM > $NEW_BAM
echo "Number of reads after filtering:" >> $LOG
samtools view -c $NEW_BAM  >> $LOG
date >> LOG
echo >> $LOG
