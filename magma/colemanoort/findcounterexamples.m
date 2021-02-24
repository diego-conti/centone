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
****************************************************************************
This script implements Algorithm 4 in [CGP]
*/

load "magma/colemanoort/findcounterexamplesabelian.m";

VERSION:="FastCW";	//script version; useful to compare the performance of different versions of the script

_CompleteSequenceOfGeneratorsIn:=procedure(sequence,setsOfElements, lastSet, G,~subsetThatGenerate,~subsetThatDoNotGenerate,~result)
	local test;
	if IsEmpty(setsOfElements) then
			lastElement:=(&*sequence)^-1;
			if lastElement in lastSet then
				DetermineWhetherSubsetGenerates(sequence,G,~subsetThatGenerate,~subsetThatDoNotGenerate,~test);
				if test then 
					result:=Append(sequence,lastElement); 
					return;
				end if;
			end if;
	else
			setOfElements:=setsOfElements[1];
			withoutFirst:=Remove(setsOfElements,1);
			for v in setOfElements do
				$$(Append(sequence,v),withoutFirst,lastSet,G,~subsetThatGenerate,~subsetThatDoNotGenerate,~result);
				if not IsEmpty(result) then 
					return; 
				end if;				
			end for;
	end if;
	result:=[];
	end procedure;

/*given a sequence of sets and a group, return a system of spherical generators with one element in each set if it exists, or [] otherwise

setsOfElements: a sequence of subsets of the group G
G: a group
subsetsThatGenerate: a list of sets that are already known to generate G. This list is passed as an argument to DetermineWhetherSubsetGenerates, which updates it.
subsetsThatDoNotGenerate: a list of sets that are already known not to generate G. This list is passed as an argument to DetermineWhetherSubsetGenerates, which updates it.
result: a variable where the system of spherical generators is stored, or [] if it does not exist
*/
_FindSequenceOfSphericalGeneratorsIn:=procedure(setsOfElements, G,~subsetThatGenerate,~subsetThatDoNotGenerate,~result)
	lastSet:=setsOfElements[#setsOfElements];
	withoutLast:=Prune(setsOfElements);
	_CompleteSequenceOfGeneratorsIn([],withoutLast,lastSet,G,~subsetThatGenerate,~subsetThatDoNotGenerate,~result);
end procedure;


AddIfCounterexample:=procedure(refinedPassport,groupData,~subsetThatGenerate,~subsetThatDoNotGenerate,~result)
	local v;
	G:=groupData`group;
	if FrobeniusSum(groupData`characterTable,refinedPassport) eq 0 then return; end if;
	g:=[ClassRepresentative(G,i) : i in refinedPassport];
	if ColemanOort(groupData,g) then
		refinedPassportAsSets:=[Class(G,x): x in g];
		_FindSequenceOfSphericalGeneratorsIn(refinedPassportAsSets,groupData`group,~subsetThatGenerate,~subsetThatDoNotGenerate,~v);
 		if not IsEmpty(v) then Include(~result, v); end if;	
	end if;
end procedure;

/* Return a list of counterexamples for the group G and signature M, one for each Aut(G)-orbit of refined passports.

This code implements Algorithm 4 in [CGP].
*/
FindCounterexamplesToColemanOort:=function(G,M)
	if IsAbelian(G) then return FindCounterexamplesToColemanOortAbelian(G,M); end if;
	counterexamples:={};
	subsetsThatGenerate:={};
	subsetsThatDoNotGenerate:={};
	table:=CharacterTable(G);
	groupData:=rec<groupDataFormat | group:=G, classMap:=ClassMap(G),
		classSizes:=[#Conjugates(G,ClassRepresentative(G,i)) : i in [1..Nclasses(G)]],characterTable:=table,chevalleyWeilData:=ChevalleyWeilData(G,table,{m: m in M})
	>;
	allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
	conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in M}];
	setsAndMultiplicities:=SetsAndMultiplicities(M,allConjugacyClassesByOrder);
	IterateOverMultisets(setsAndMultiplicities,{* *}, AutGOnConjugacyClasses(groupData,conjugacyClasses), AddIfCounterexample, groupData,  ~subsetsThatGenerate, ~subsetsThatDoNotGenerate, ~counterexamples);
	return counterexamples;
end function;


