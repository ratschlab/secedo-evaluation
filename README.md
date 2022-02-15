This repository contains scripts for evaluating SECEDO, available at:
[https://github.com/ratschlab/secedo](https://github.com/ratschlab/secedo)

This repository also contains all the information needed to reproduce the experimental results in the associated [SECEDO](https://www.biorxiv.org/content/10.1101/2021.11.08.467510v3) paper.

Please follow the installation instructions in the SECEDO repository before running the experiments. All scripts are written in basic bash and are using LSF to launch jobs. The scripts are readable and well-documented, and should be trivial to adapt for your needs.


### Breast Cancer Dataset
  This dataset, provided by 10xGenomics, contains single-cell data from 5 different tumor slices of a breast cancer patient.

  Download instructions and scripts for preprocessing the Breast Cancer 10xGenomics data, for creating pileup files and 
    for running SECEDO on it are [here](https://github.com/danieldanciu/secedo-experiments/tree/main/breast_cancer).

### Synthetic Dataset
  We also evaluated SECEDO on an extensive set of simulated data. Instructions on how to use the scripts that generate the simulated data starting from an altered GRCh38 human genome are [here](https://github.com/danieldanciu/secedo-experiments/tree/main/varsim)


