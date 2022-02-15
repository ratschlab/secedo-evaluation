# Data
Download the BAM and BAI files for each of the 5 tumor slices (denoted with letters A to E) from the following location:

Slice A: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-a-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-a-2000-cells-1-standard-1-1-0)

Slice B: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-b-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-b-2000-cells-1-standard-1-1-0)

Slice C: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-c-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-c-2000-cells-1-standard-1-1-0)

Slice D: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-d-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-d-2000-cells-1-standard-1-1-0)

Slice E: [https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-e-2000-cells-1-standard-1-1-0](https://www.10xgenomics.com/resources/datasets/breast-tissue-nuclei-section-e-2000-cells-1-standard-1-1-0)

# Preprocessing
First, execute [1_run_filtering.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/preprocessing/1_run_filtering.sh) on the original BAM file. This will keep alignments with the following properties:
  - reads mapped in proper pair
  - primary alignment
  - not PCR or optical duplicate

Second, execute [2_run_filteringCB.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/preprocessing/2_run_filteringCB.sh) to filter out all reads that do not contain the CB tag. Explanation for what CB means is [here](https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/output/bam).

Third, execute [3_run_splittingByCB.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/breast_cancer/preprocessing/3_run_splittingByCB.sh) to separate out the reads.