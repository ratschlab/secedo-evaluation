# Data
## Breast cancer dataset
Download the BAM and BAI files for each of the 5 tumor slices using the following script: 

```
for slice in A B C D E; do wget https://s3-us-west-2.amazonaws.com/10x.files/samples/cell-dna/1.1.0/breast_tissue_${slice}_2k/breast_tissue_${slice}_2k_possorted_bam.bam; wget https://cf.10xgenomics.com/samples/cell-dna/1.1.0/breast_tissue_${slice}_2k/breast_tissue_${slice}_2k_possorted_bam.bam.bai; done
```
MD5 sums:
| Slice | BAM | BAI |
| ------- | -------- | ------- |
| [A](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-a-2000-cells-1-standard-1-1-0) | 6af2da98db8907d2fc8193ceb96afb01 | 440d7aaf854d37a36edd0557be1f047b |
| [B](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-b-2000-cells-1-standard-1-1-0) | 6ece8a436600503616ac5db8b5700e2b | 76977649d257484951d8b65e0f7061f3 |
| [C](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-c-2000-cells-1-standard-1-1-0) | ea44baa851801efa745246e7ed79a278 | 93d19f8d123f01a7f2ad86d9ff2f3eab |
| [D](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-d-2000-cells-1-standard-1-1-0) | a27de1b702b8b8c776daa33640a41117 | 606b3c7867382cc3a0e596aed7137ed6 |
| [E](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-e-2000-cells-1-standard-1-1-0) | 0a5bc98adf1f4401151f49f75ebcd58c | 540cdff1f5d209b8ca1750c7392ec8dd |

## Chisel "ground truth" data
```
for section in all sectionA sectionB sectionC sectionD sectionE; do wget https://github.com/raphael-group/chisel-data/blob/a9df050179fe9b303d4a9546bb51ffdb29a17bf9/patientS0/clones/${section}/mapping.tsv.gz -O mapping_${section}.tsv.gz; done
```
Alternatively, download the data using your browser from the [Chisel github repository](https://github.com/raphael-group/chisel-data/blob/a9df050179fe9b303d4a9546bb51ffdb29a17bf9/patientS0/clones).

# Preprocessing
First, execute [1_run_filtering.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/preprocessing/1_run_filtering.sh) 
on the original BAM file:
```console
./preprocessing/1_run_filtering.sh <BAM_FILE>
```
This will generated a file named `<BAM_FILE_pos_sorted.BAM>` that keeps alignments with the following properties:
  - reads mapped in proper pair
  - primary alignment
  - not PCR or optical duplicate

Second, execute [2_run_filteringCB.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/preprocessing/2_run_filteringCB.sh) 
on the filtered BAM in order to filter out all reads that do not contain the CB (cell barcode?) tag. Explanation for what CB means is [here]
(https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/output/bam).
```console
./preprocessing/2_run_filtering.sh <BAM_FILE_pos_sorted.BAM>
```
This step will produce a BAM file called <BAM_FILE_pos_sorted_CB.BAM>

Third, execute [3_run_splittingByCB.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/preprocessing/3_run_splittingByCB.sh) 
to separate out the reads for each cell. You should now have \~2000 BAM files, one for each sequenced cell in a directory called 
`cell_bams`:
```console
./preprocessing/2_run_filtering.sh <BAM_FILE_pos_sorted_CB.BAM>
```
Here we attempt to sort the BAM files on a larger cluster using LSF. If you prefer to work locally, simply copy the 
`samtools sort` command from the log file, and run it locally, e.g.
```console
samtools sort -t CB -m 10G -@ 10 -T /scratch/slice /Users/dd/work/secedo/tests/data/test1_pos_sorted_CB.bam > /Users/dd/work/secedo/tests/data/test1_pos_sorted_CB_sorted.bam
```


# Pileup generation and variant calling

Edit [clustering.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/clustering.sh) and set the 
`base_dir` variable to the location of the cell BAM files. Set the `slices` to the slices you would like to process 
(e.g. "A C E"). The script assumes a cluster run via LSF, but it's trivial to adapt to other cluster virtualization software.
