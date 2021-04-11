cd `dirname $0`/..
computations=100	#number of computations to be performed by each magma process
nthreads=$2
mkdir -p co
hliðskjálf --computations $1 --valhalla bad.csv --script magma/runcomputation.m --workload $computations --schema schema.info --nthreads $nthreads --total-memory $3 --workoutput co

