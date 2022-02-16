This repository also contains all the information needed to reproduce the experimental results in the [SECEDO](https://www.biorxiv.org/content/10.1101/2021.11.08.467510v3) paper.
# Installing SECEDO
We used SECEDO v1.0.3 in the experiments. You can install this version using:
````console
conda install -c conda-forge -c bioconda secedo=1.0.3
````
To install from source download the v.1.0.3 release from [https://doi.org/10.5281](https://doi.org/10.5281/zenodo.
6088890) and follow the installation instructions at
[https://github.com/ratschlab/secedo](https://github.com/ratschlab/secedo).


All scripts are written in basic bash and are using LSF to launch jobs. The scripts are readable and well-documented,
and should be easily adaptable for your needs.


### Breast Cancer Dataset
  This dataset, provided by 10xGenomics, contains single-cell data from 5 different tumor slices of a breast cancer patient.

  Download instructions, scripts for preprocessing the Breast Cancer 10xGenomics data, scripts for creating pileup 
  files and for running SECEDO are [here](https://github.com/danieldanciu/secedo-experiments/tree/main/breast_cancer).

### Synthetic Dataset
  We also evaluated SECEDO on an extensive set of simulated data. Instructions on how to use the scripts that generate the simulated data starting from an altered GRCh38 human genome are [here](https://github.com/danieldanciu/secedo-experiments/tree/main/varsim)


