/***************************************************************************
	Copyright (C) 2021 by Diego Conti, Alessandro Ghigi and Roberto Pignatelli.

	This file is part of centone.
	Centone is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
***************************************************************************
	This script takes a path as a parameter, e.g.
	magma path:=co magma/processcounterexamples.m
	prints all the counterexamples that have been written in co.
*/
load "magma/include/processcounterexamples.m";
load "magma/include/genus.m";

if not assigned path then error "variable outputPath should point to a directory containing the output of runcomputation.m"; end if; 

IterateThroughDirectory:=procedure(directory,f)
	pipe:=POpen("ls " cat directory cat " -1","r");
	while true do
		line:=Gets(pipe);
		if IsEof(line) then break; end if;
		f(directory cat "/" cat line);
	end while;
	delete pipe;
end procedure;

PrintCounterexamples:=procedure(csvfile)
	for counterexample in CounterexamplesInFile(csvfile) do
		print "Group: ",counterexample`d,",",counterexample`n;
		for x in counterexample`X do 
			print "Generators: ",x; 
		end for;
		M:=[Order(g): g in Rep(counterexample`X)];
		print "signature:",M;
		print "g:",Genus(M,counterexample`d);
	end for;
end procedure;

IterateThroughDirectory(path,PrintCounterexamples);
quit;
