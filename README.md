# centone
A Magma program to test the Coleman-Oort conjecture on spherical systems of generators

The algorithm is explained in
[CGP] D. Conti, A. Ghigi, R. Pignatelli. Some evidence for the Coleman-Oort conjecture
This paper is referred to as [CGP] in the code.

If you use this code in your research, please quote our paper!

The program consists of three Magma scripts:
###computesignatures.m
Computes the admissible signatures and stores them on disk, in the directory signatures

###createlistocomputations.m
Creates a list of computations to be passed to the main script

### runcomputation.m
Main script that iterates through signatures, looking for counterexamples.


The sh directory contains some bash scrips that invoke the Magma scripts with example parameters. These scripts employ parallel awk and grep, and they have been tested on CentOS Linux 7.

###	computesignatures.sh
Computes signatures up to d=2000

### createlistofcomputations.sh
Creates two lists of computations, corresponding to noncylic signatures with g<=100, r>=4 and g<=7, r>=3.

### runcomputations.sh
Runs the main script through a list of computations, using GNU parallel to parallelize the computations. No attempt is made to handle out-of-memory errors.
For example, run sh/runcomputations.sh 2-7.csv to recover the known examples with 2<=g<=7.
*Disclaimer*: the script runcomputations.sh is included for demonstration purposes. A more sophisticated script was needed in order to parallelize effectively the computation for g<=100.

