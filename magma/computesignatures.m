/* This script is meant to be invoked from the command line, e.g:
magma d:=10 maxG:=100 magma/signatures/computesignatures.m
It computes and stores on disk signatures up to a given maximum genus for fixed group order.
Useful in order to parallelize the computation
*/

load "magma/signatures/signatures.m";

if not assigned d then error "variable d should be assigned an integer representing group order"; end if;
if not assigned maxG then maxG:="128"; end if;

print "computing signatures for d=",d,", g\\leq ",maxG;

groupOrder:=StringToInteger(d);
maxG:=StringToInteger(maxG);

ComputeAndSaveSignatures(groupOrder,maxG);

quit;
