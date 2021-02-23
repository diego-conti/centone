MultisetDiClassiDiConiugio:=function(datiCalcoloGeneratori,M)
	conjugacyClassesByOrder:=ConjugacyClassesByOrder(datiCalcoloGeneratori`group);
	result:={* *};
	M_as_multiset:={* x: x in M *};
	for m in MultisetToSet(M_as_multiset) do
		if not IsDefined(conjugacyClassesByOrder,m) then  error datiCalcoloGeneratori`group, "non ha elementi di ordine ",m; end if;
		Include(~result, conjugacyClassesByOrder[m]^^Multiplicity(M_as_multiset,m));
	end for;
	return result;
end function;

CompletaSequenzaDiGeneratoriIn:=procedure(sequenza,insiemiDiElementi, ultimoInsieme, G,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
	local test;
	if IsEmpty(insiemiDiElementi) then
			ultimoElemento:=(&*sequenza)^-1;
			if ultimoElemento in ultimoInsieme then
				DeterminaSeIlSottoinsiemeGenera(sequenza,G,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~test);
				if test then 
					result:=Append(sequenza,ultimoElemento); 
					return;
				end if;
			end if;
	else
			insiemeDiElementi:=insiemiDiElementi[1];
			senzaPrimo:=Remove(insiemiDiElementi,1);
			for v in insiemeDiElementi do
				$$(Append(sequenza,v),senzaPrimo,ultimoInsieme,G,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result);
				if not IsEmpty(result) then 
					return; 
				end if;				
			end for;
	end if;
	result:=[];
	end procedure;

	//data una sequenza di insiemi insiemiDiElementi=[X_1,...,X_r] e un gruppo G, ritorna [] oppure la prima sequenza [g_1,...,g_r] con g_i in X_i tali che g_1,...,g_r generano il gruppo G e g_1...g_r=1
	PrimaSequenzaDiGeneratoriSfericiIn:=procedure(insiemiDiElementi, G,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
		ultimoInsieme:=insiemiDiElementi[#insiemiDiElementi];
		senzaUltimo:=Prune(insiemiDiElementi);
		CompletaSequenzaDiGeneratoriIn([],senzaUltimo,ultimoInsieme,G,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result);
	end procedure;

	ColemanOort:=function(datiCalcoloGeneratori,generatori)
		G:=datiCalcoloGeneratori`group;			
		chi_phi:=CharacterFromGroupAndGenerators(G,datiCalcoloGeneratori`characterTable, datiCalcoloGeneratori`chevalleyWeilData,generatori);
	  N:=1/(2*Order(G))*(&+[chi_phi(g^2)+chi_phi(g)^2: g in G]);
		return (N eq #generatori-3);
	end function;

if assigned onlyTestColemanOort and onlyTestColemanOort eq "testVersion" then 
	ColemanOort:=function(datiCalcoloGeneratori,generatori)
		return true;
	end function;
end if;

AggiungiControesempioInClassiDiConiugio:=procedure(classiDiConiugio,datiCalcoloGeneratori,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
	local v;
	G:=datiCalcoloGeneratori`group;
	if SommaDiFrobenius(datiCalcoloGeneratori`characterTable,classiDiConiugio) eq 0 then return; end if;
	g:=[ClassRepresentative(G,i) : i in classiDiConiugio];
	if ColemanOort(datiCalcoloGeneratori,g) then
		classiDiConiugioComeInsiemi:=[Class(G,x): x in g];
		PrimaSequenzaDiGeneratoriSfericiIn(classiDiConiugioComeInsiemi,datiCalcoloGeneratori`group,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~v);
 		if not IsEmpty(v) then Include(~result, v); end if;	
	end if;
end procedure;

//ritorna la sequenza lunga se effettivamente la sequenza corta di classi di coniugio corrisponde a una sequenza di elementi degli ordini giusti
SequenzaCortaEdElemento:=function(classiDiConiugio,datiCalcoloGeneratori)
	G:=datiCalcoloGeneratori`group;	
	sequenzaClassiDiConiugio:=[C: C in classiDiConiugio];
	sequenzaCorta:=[ClassRepresentative(G,i) : i in sequenzaClassiDiConiugio];
	prodotto:=&*sequenzaCorta ;
	if Order(prodotto) ne datiCalcoloGeneratori`lastOrder then return [],0; end if;
	elemento:=prodotto^-1;
	return sequenzaCorta,elemento;
end function;


AggiungiSeControesempioInGruppoAbeliano:=procedure(classiDiConiugio,datiCalcoloGeneratori,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
	local test;
	G:=datiCalcoloGeneratori`group;	
	sequenzaCorta,elemento:=SequenzaCortaEdElemento(classiDiConiugio,datiCalcoloGeneratori);
	if not IsEmpty(sequenzaCorta) then
		sequenzaLunga:=Append(sequenzaCorta, elemento);
		if ColemanOort(datiCalcoloGeneratori,sequenzaLunga) then
			DeterminaSeIlSottoinsiemeGenera(sequenzaCorta,G,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~test);
			if test then 
				classi:=Include(classiDiConiugio,datiCalcoloGeneratori`classMap(elemento));
				Include(~result, [ClassRepresentative(G,C): C in classi]);	//la conversione da multiset a set implicitamente produce una sequenza ordinata canonicamente; questo elimina elementi duplicati, ma non quelli coniugati dall'azione di Aut(G)
			end if;
		end if;
	end if;
end procedure;

//version of the script that includes all multisets of conjugacy classes with N=r-3 and Frobenius, even if they do not generate
if assigned onlyTestColemanOort and onlyTestColemanOort eq "notGenerating" then 
AggiungiControesempioInClassiDiConiugio:=procedure(classiDiConiugio,datiCalcoloGeneratori,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
	local v;
	G:=datiCalcoloGeneratori`group;
	if SommaDiFrobenius(datiCalcoloGeneratori`characterTable,classiDiConiugio) eq 0 then return; end if;
	g:=[ClassRepresentative(G,i) : i in classiDiConiugio];
	if ColemanOort(datiCalcoloGeneratori,g) then
		Include(~result, classiDiConiugio); 
	end if;
end procedure;

AggiungiSeControesempioInGruppoAbeliano:=procedure(classiDiConiugio,datiCalcoloGeneratori,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
	G:=datiCalcoloGeneratori`group;	
	sequenzaCorta,elemento:=SequenzaCortaEdElemento(classiDiConiugio,datiCalcoloGeneratori);
	if not IsEmpty(sequenzaCorta) then
		sequenzaLunga:=Append(sequenzaCorta, elemento);
		if ColemanOort(datiCalcoloGeneratori,sequenzaLunga) then
				classi:=Include(classiDiConiugio,datiCalcoloGeneratori`classMap(elemento));
				Include(~result, [ClassRepresentative(G,C): C in classi]);
		end if;
	end if;
end procedure;
end if;

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




/*
AutomorphismGroupAsPermutations:=function(G)
		G:=datiCalcoloGeneratori`group;
		AutG:=AutomorphismGroup(G);
		N:=Nclasses(G);
		generators:=		  [
		  	[AzioneAutomorfismoSuClasseDiConiugio(datiCalcoloGeneratori,aut,class) : class in [1..N]]
	  	 : aut in Generators(AutG)
		  ];
		return sub	<SymmetricGroup
*/

//TODO: considerare se usare gli elementi direttamente invece delle classi di coniugio.

//nota: la versione abeliana può ritornare più di un rappresentante per orbita di Hurwitz. Il punto però è capire se ci sono controesempi o no.
FindCounterexamplesToColemanOortAbelian:=function(G,M)
		rappresentanti:={};
		sottoinsiemiTrovatiCheGenerano:={};
		sottoinsiemiTrovatiCheNonGenerano:={};
		table:=CharacterTable(G);
		datiCalcoloGeneratori:=rec<formatoDatiCalcoloGeneratori | group:=G, classMap:=ClassMap(G),
				characterTable:=table,chevalleyWeilData:=ChevalleyWeilData(G,table,{m: m in M})
		>;
		allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
		reducedM,datiCalcoloGeneratori`lastOrder:=SignatureWithoutOrderAndOrder(allConjugacyClassesByOrder,M);
		conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in reducedM}];
		setsAndMultiplicities:=SetsAndMultiplicities(reducedM,allConjugacyClassesByOrder);
		IterateOverMultisets(setsAndMultiplicities, {* *},AutGOnConjugacyClasses(datiCalcoloGeneratori,conjugacyClasses), AggiungiSeControesempioInGruppoAbeliano, datiCalcoloGeneratori,  ~sottoinsiemiTrovatiCheGenerano, ~sottoinsiemiTrovatiCheNonGenerano, ~rappresentanti);
		return rappresentanti;
end function;


FindCounterexamplesToColemanOort:=function(G,M)
		if IsAbelian(G) then return FindCounterexamplesToColemanOortAbelian(G,M); end if;
		rappresentanti:={};
		sottoinsiemiTrovatiCheGenerano:={};
		sottoinsiemiTrovatiCheNonGenerano:={};
		table:=CharacterTable(G);
		datiCalcoloGeneratori:=rec<formatoDatiCalcoloGeneratori | group:=G, classMap:=ClassMap(G),
			classSizes:=[#Conjugates(G,ClassRepresentative(G,i)) : i in [1..Nclasses(G)]],characterTable:=table,chevalleyWeilData:=ChevalleyWeilData(G,table,{m: m in M})
		>;
	allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
	conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in M}];
	setsAndMultiplicities:=SetsAndMultiplicities(M,allConjugacyClassesByOrder);
	IterateOverMultisets(setsAndMultiplicities,{* *}, AutGOnConjugacyClasses(datiCalcoloGeneratori,conjugacyClasses), AggiungiControesempioInClassiDiConiugio, datiCalcoloGeneratori,  ~sottoinsiemiTrovatiCheGenerano, ~sottoinsiemiTrovatiCheNonGenerano, ~rappresentanti);
		return rappresentanti;
end function;

//esempio da studiare: time FindCounterexamplesToColemanOort(SmallGroup(104,8),[2,2,13,26,26]);


