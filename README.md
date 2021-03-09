# centone
A [Magma](http://magma.maths.usyd.edu.au/magma/) program to test the Coleman-Oort conjecture on spherical systems of generators

The algorithm is explained in
[CGP] D. Conti, A. Ghigi, R. Pignatelli. Some evidence for the Coleman-Oort conjecture. [arXiv:2102.12349](http://arxiv.org/abs/2102.12349)

This paper is referred to as [CGP] in the code.

If you use this code in your research, please quote our paper!

### Magma code
The program consists of four Magma scripts:

### computesignatures.m
Computes the admissible signatures and stores them on disk, in the directory signatures

### createlistocomputations.m
Creates a list of computations to be passed to the main script

### runcomputation.m
Main script that iterates through signatures, looking for counterexamples. The output is a CSV file where each line takes the following form:

	d;n;M;time;memory;algorithm;generators

* _d_ group order
* _n_ group number
* _M_ signature
* _time_ computation time in seconds
* _memory_ maximum memory usage in MB
* _algorithm_ string identifying the algorithm version
* _generators_ One of the following:
    * {I:reason} if computation was skipped; the string _reason_ then identifies the criterion used to exclude it;
    * {} if no counterexample was found
    * otherwise, a list of counterexamples, one in each Aut(G)-orbit of refined passports

### printcounterexamples.m
Print all counterexamples that have been computed

## Bash scripts
The sh directory contains some bash scrips that invoke the Magma scripts with example parameters. These scripts employ awk and GNU parallel, and they have been tested on CentOS Linux 7. They should be run in the order in which they appear here:

###	computesignatures.sh
Computes signatures up to d=2000, using GNU parallel to parallelize the computation

### createlistofcomputations.sh
Creates two lists of computations, corresponding to noncyclic signatures with g<=100, r>=4 and g<=7, r>=3.

### runcomputations.sh
Runs the main script through a list of computations using a single process

For example, run 

	sh/runcomputations.sh 2-7.comp 
	
to recover the known examples with 2<=g<=7.

### runcomputationsinparallel.sh

Like runcomputations.sh, but using [hliðskjálf](https://github.com/diego-conti/hlidskjalf) to parallelize the computation.

For example, run 

	sh/runcomputationsinparallel.sh 2-100.comp 50 100

to recover the known examples with 2<=g<=100 using 50 parallel processes and up to 100GB of memory

### printcounterexamples.sh
Print all counterexamples that have been computed
