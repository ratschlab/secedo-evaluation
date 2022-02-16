This directory contains the scripts to generate synthetic data using varsim and cluster that data.
## Data
We used the GRCH38.p13 human genome as the base genome: [https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.39](https://www.ncbi.nlm.nih.gov/assembly/GCF_000001405.39)

We applied common mutations from dbsnp 20180418:
```console
    wget ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606/VCF/common_all_20180418.vcf.gz
```

Coding/noncoding mutations were randomly selected from Cosmic v94, available [here](https://cancer.sanger.ac.uk/cosmic/download) 
(scroll to "VCF FILES", and download `VCF/CosmicCodingMuts.vcf.gz` and `VCF/CosmicNonCodingVariants.vcf.gz`).

After downloading the 2 cosmic VCFs, run the following command to concatenate them into a single file. 
```console
        cat <(gzip -dc CosmicCodingMuts.vcf.gz) <(gzip -dc CosmicNonCodingVariants.vcf.gz) | gzip -c > cosmic.vcf.gz
```        
Although this is not a valid VCF file, Varsim is ok with it.

## Software environment
Install varsim 0.8.4 from [here](https://github.com/bioinform/varsim/releases/tag/v0.8.4) using these [installation 
instructions](https://github.com/bioinform/varsim)

### Conda environment
Varsim requires python 2 and Oracle JDK. The following conda packages are needed for the simulation:
  - art
  - pyvcf
  - numpy
  - pysam
  - pybedtools
  - oraclejdk
```
conda create -c gtcg -c conda-forge -c bioconda --name secedo python=2.7 art=2016.06.05 pyvcf=0.6.8 numpy=1.15.4 pysam=0.16.0.1 pybedtools=0.8.2 oraclejdk
conda activate secedo
```

## Creating genomes
Tweak the [create_genomes.sh](https://github.com/ratschlab/secedo-evaluation/blob/main/varsim/create_genomes.sh) script to your needs. 
This script uses the GRCH38 reference genome, common variations from dbSNP and cancer mutations from the Cosmic 
database to create the healthy and tumor cells. 


## Generate reads, align reads, create pileups and clustering
The `clustering.sh` script does all of the steps above. Edit it and tweak it to your needs. Usage:
```console
    clustering.sh <step>
```
Where step is a number from 1 to 4, corresponding to the 4 stages to be executed: 
1. Generate reads
This uses `art` to generate reads for all the given genomes (healthy and tumor) at the specified coverage (we used 0.
   05x in our experiments).
2. Align reads
This uses `bowtie2` to align the generated reads back against the genome
3. Create pileups
This uses SECEDO's `pileup` (since `samtools pileup` is extremely slow) to create pileup files for the aligned reads
4. Clustering
Calls `secedo` on the resulting pileup files to generate the `clustering` file (assigning each cell to a cluster). 
   Other useful output files are:
  - `secedo.log` contains information about timing, cluster sizes, AIC/BIC/GMM scores, stopping conditions, etc.
  - `significant_positions*` contains the loci that were deemed informative at each step.
  - `sim_mat_eigenvectors_norm*` contains the first 3 eigenvectors of the similarity matrix (used for visualization 
    and for "manual" stopping criterion on difficult datasets).

## Other scripts
 - The `generate_reads.py` script is called by `clustering.sh` to generate reads using `art` based on fasta templates
for cancer and healthy cells
 - `split.sh` - simple script that splits a BAM by chromosome for distributed processing
 - `cov_vs_snp.sh` - used to test the lowest SNP count/coverage at which SECEDO is able to cluster 1000 cells (Used 
   to create Figure 5 in the paper).
