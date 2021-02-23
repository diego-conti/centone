/* This script is meant to be invoked from the command line, e.g:
magma d:=10 maxG:=100 computesignatures.m
It computes and stores on disk signatures up to a given maximum genus for fixed group order.
It is useful for parallelizing the computation, e.g. using GNU parallel:
seq 1 2000 | parallel magma -b d:={} magma/computesignatures.m >/dev/null
*/

load "magma/signatures/signatures.m";

if not assigned d then error "variable d should be assigned an integer representing group order"; end if;
if not assigned maxG then maxG:="128"; end if;

print "computing signatures for d=",d,"g\leq ",maxG;

groupOrder:=StringToInteger(d);
maxG:=StringToInteger(maxG);

ComputeAndSaveSignatures(groupOrder,maxG);

quit;
