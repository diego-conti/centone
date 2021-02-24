cd `dirname $0`/..
computations=100	#number of computations to be performed by each magma process

mkdir -p co
rm co/* -f
awk -F";" '
{
	d = $1
	N = $2
	M = $3
    for (n = 1; n <= N; n++)
        print d, ";", n,";", M
}' $1 | split - data -l $computations

parallel magma -b processId:={} dataFile:={} outputPath:=co memory:=1 magma/runcomputation.m ::: data*
rm data*
echo Counterexamples:
grep -v "{}" co/* | grep -v "{I:"
