/* This script implements Algorithm 4 in [CGP]
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

	//data una sequenza di insiemi insiemiDiElementi=[X_1,...,X_r] e un gruppo G, ritorna [] oppure la prima sequenza [g_1,...,g_r] con g_i in X_i tali che g_1,...,g_r generano il gruppo G e g_1...g_r=1
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


