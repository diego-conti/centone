mkdir -p co
rm co/* -f
awk -F";" '
{
	d = $1
	split($2,N,"\.")
	M = $3
    for (n = 1; n <= N[3]; n++)
        print d, ";", n,";", M
}' $1 >allcomputations.csv

magma -b processId:=1 dataFile:=allcomputations.csv outputPath:=co memory:=0 magma/runcomputation.m 
rm allcomputations.csv

