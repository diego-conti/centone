cd `dirname $0`/..
magma -b maxG:=100 minR:=4 outFile:=2-100.csv onlyNonCyclic:=true magma/createlistofcomputations.m
magma -b maxG:=7 minR:=3 outFile:=2-7.csv onlyNonCyclic:=true magma/createlistofcomputations.m
