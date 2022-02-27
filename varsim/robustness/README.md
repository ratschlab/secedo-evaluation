# SECEDO clusterings for various values of h, epsilon and theta

This folder contains the SECEDO clusterings and the corresponding log files for various parameter combinations:
  - `h`, the proportion of homozygous loci in the filtered loci
  - `epsilon`, the proportion of mutated loci
  - `theta`, the ratio of sequencing errors in the filtered loci (this is naturally higher than the sequencer's 
    error since loci only pass the Bayesian filtering if they are either truly mutated or if they accumulate enough 
    errors to fool the Bayesian filter)
