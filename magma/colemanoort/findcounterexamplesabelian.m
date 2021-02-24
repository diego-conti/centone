load "magma/colemanoort/subsetgenerates.m"
load "magma/colemanoort/refinedpassports.m";

/* given a "short refined passport" on an Abelian group, i.e. a refined passport [{g_1},..,{g_{r-1}] with the last element removed, determine g_r such that \prod g_i=r.
If g_i has order groupData`lastOrder, return the pair [g_1,...,g_{r-1}],g_r, otherwise return [] */

ShortSequenceAndElement:=function(shortRefinedPassport,groupData)
	G:=groupData`group;	
	sequenzaCorta:=[ClassRepresentative(G,C) : C in shortRefinedPassport];
	prodotto:=&*sequenzaCorta ;
	if Order(prodotto) ne groupData`lastOrder then return []; end if;
	elemento:=prodotto^-1;
	return sequenzaCorta,elemento;
end function;


AddIfCounterexampleAbelian:=procedure(shortRefinedPassport,groupData,~subsetThatGenerate,~subsetThatDoNotGenerate,~result)
	local test;
	G:=groupData`group;	
	shortSequence,element:=ShortSequenceAndElement(refinedPassport,groupData);
	if not IsEmpty(shortSequence) then
		sequence:=Append(shortSequence, element);
		if ColemanOort(groupData,sequence) then
			DetermineWhetherSubsetGenerates(shortSequence,G,~subsetThatGenerate,~subsetThatDoNotGenerate,~test);
			if test then 
				refinedPassport:=Include(shortRefinedPassport,groupData`classMap(element));	//add the last conjugacy class to the shortRefinedPassport; this creates a multiset of conjugacy classes
				Include(~result, [ClassRepresentative(G,C): C in refinedPassport]);	//convert the multiset of conjugacy classes into a sequence of elements, which is canonically ordered; this prevents returning two systems of generators that only differ in order
			end if;
		end if;
	end if;
end procedure;


//returns M'=M,m, with M=M'\cup {* m *}, having chosen m in order to maximize the number of conjugacy classes with order m.
SignatureWithoutOrderAndOrder:=function (allConjugacyClassesByOrder,M) 
	k:=0;
	for m in {m: m in M} do
		size:=#allConjugacyClassesByOrder[m];
		if size gt k then 
			biggest:=m;
			k:=size;
		end if;
	end for;				
	return Exclude(M,biggest),biggest;
end function;

/* Return a list of counterexamples for the abelian group G and the signature M. 

This code may return more than one representative in each Hurwitz equivalence class. If counterexamples do arise, some extra work needs to be done to eliminate duplicates.
*/
FindCounterexamplesToColemanOortAbelian:=function(G,M)
		counterexamples:={};
		subsetsThatGenerate:={};
		subsetsThatDoNotGenerate:={};
		table:=CharacterTable(G);
		groupData:=rec<groupDataFormat | group:=G, classMap:=ClassMap(G),
				characterTable:=table,chevalleyWeilData:=ChevalleyWeilData(G,table,{m: m in M})
		>;
		allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
		reducedM,groupData`lastOrder:=SignatureWithoutOrderAndOrder(allConjugacyClassesByOrder,M);
		conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in reducedM}];
		setsAndMultiplicities:=SetsAndMultiplicities(reducedM,allConjugacyClassesByOrder);
		IterateOverMultisets(setsAndMultiplicities, {* *},AutGOnConjugacyClasses(groupData,conjugacyClasses), AddIfCounterexampleAbelian, groupData,  ~subsetsThatGenerate, ~subsetsThatDoNotGenerate, ~counterexamples);
		return counterexamples;
end function;
