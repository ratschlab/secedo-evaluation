# Data
Download the BAM and BAI files for each of the 5 tumor slices (denoted with letters A to E) from the following location:

Slice A: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-a-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-a-2000-cells-1-standard-1-1-0)

Slice B: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-b-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-b-2000-cells-1-standard-1-1-0)

Slice C: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-c-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-c-2000-cells-1-standard-1-1-0)

Slice D: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-d-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-d-2000-cells-1-standard-1-1-0)

Slice E: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-e-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-e-2000-cells-1-standard-1-1-0)

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

Edit [variant_call.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/variant_call.sh) and set the `base_dir` variable to the location of the cell BAM files. Set the `slices` to the slices you would like to process (e.g. "A C E"). The script assumes a cluster run via LSF, but it's trivial to adapt to other cluster virtualization software.
