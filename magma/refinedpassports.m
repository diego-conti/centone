	load "magma/definizionicomuni.m";
	load "magma/log.m";
	load "magma/sottoinsiemegenera.m";
	load "magma/scott.m";
	load "magma/ChevalleyWeil.magma";
	load "magma/sequences.m";
	
	//////////////////////////////////////////////////////////////////////
	// mosse di Hurwitz
	//////////////////////////////////////////////////////////////////////

	//(g_1,...,g_n)->(g_1,....,g_{i+1}, g_{i+1}^{-1} g_i g_{i+1}, ...,g_n)
	HurwitzMove:=function(seq,i)
		temp:=seq[i];
		seq[i]:=seq[i+1];
		seq[i+1]:=temp^seq[i+1];
		return seq;
	end function;

	//(h_1,...,h_n)->(h_1,....,h_i h_{i+1} h_i^{-1}, h_i, ...,h_n)
	InverseHurwitzMove:=function(seq,i)
		temp:=seq[i+1];
		seq[i+1]:=seq[i];
		seq[i]:=temp^(seq[i]^-1);
		return seq;
	end function;

	TrecciaPura:=function(seq, i,j)
		for k := j-1 to i+1 by -1 do
			seq:=InverseHurwitzMove(seq,k);
		end for;
		seq:=HurwitzMove(seq,i);
		seq:=HurwitzMove(seq,i);
		for k := i+1 to j-1 do
			seq:=HurwitzMove(seq,k);
		end for;
		return seq;
	end function;


	//////////////////////////////////////////////////////////////////////
	//caso non abeliano: i vettori generatori sono rappresentati da sequenze
	formatoDatiCalcoloGeneratori:=recformat<group,classMap,classSizes,datiGModuli,characterTable,lastOrder,signatureElementsWithLastOrder,chevalleyWeilData>;
		
	//ritorna un array associativo il cui elemento con chiave m è l'insieme delle classi di coniugio in G di elementi di ordine m
	ConjugacyClassesByOrder:=function(G)
		result:=AssociativeArray();
		for class in [1..Nclasses(G)] do
			order:=Order(ClassRepresentative(G,class));
			if not IsDefined(result,order) then result[order]:={}; end if;
			Include(~result[order],class);
		end for;
		return result;
	end function;



	//data una sequenza di insiemi X_1,...,X_r, ritorna l'insieme delle sequenze x_1,...,x_r con x_i in X_i.
	VettoriDiElementiIn:=function(insiemiDiElementi)
		result:={};			//TODO verificare se una sequenza è più veloce di un set
		insiemeDiElementi:=insiemiDiElementi[#insiemiDiElementi];
		if #insiemiDiElementi eq 1 then
				return {[x]: x in insiemeDiElementi};
		end if;
		senzaUltimo:=$$(Prune(insiemiDiElementi));
		result join:={Append(vettore,ultimo): ultimo in insiemeDiElementi, vettore in senzaUltimo};
		return result;
	end function;

	//data una sequenza di insiemi X_1,...,X_r e una funzione, esegui procedure(x_1,..,x_r) per ogni sequenza x_1,...,x_r con x_i in X_i.	
	IteraSuSequenzeCompletateConElementiIn:=procedure(sequenza,insiemiDiElementi,~procedura,argA,~arg1,~arg2,~arg3)
		if IsEmpty(insiemiDiElementi) then
			procedura(sequenza,argA,~arg1,~arg2,~arg3);
		else 
			insiemeDiElementi:=insiemiDiElementi[1];
			senzaPrimo:=Remove(insiemiDiElementi,1);
			for v in insiemeDiElementi do
				$$(Append(sequenza,v),senzaPrimo,~procedura,argA,~arg1,~arg2,~arg3);
			end for;
		end if;
	end procedure;

	//data una sequenza di insiemi X_1,...,X_r e una funzione, esegui procedure(x_1,..,x_r,arg1,arg2,arg3) per ogni sequenza x_1,...,x_r con x_i in X_i.	
	IteraSuSequenzeDiElementiIn:=procedure(insiemiDiElementi,~procedura,argA,~arg1,~arg2,~arg3)
		IteraSuSequenzeCompletateConElementiIn([],insiemiDiElementi,~procedura,argA,~arg1,~arg2,~arg3);
	end procedure;

	//data una sequenza di insiemi insiemiDiElementi=[X_1,...,X_r], aggiungi a generatori le sequenze g_1,..,g_r di generatori sferici con g_i in X_i
	AggiungiVettoriGeneratoriDiElementiIn:=procedure(datiCalcoloGeneratori,insiemiDiElementi,~aggiungiSeGenera, ~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~generatori)
		ultimoInsieme:=insiemiDiElementi[#insiemiDiElementi];
		IteraSuSequenzeDiElementiIn(Prune(insiemiDiElementi),~aggiungiSeGenera,ultimoInsieme,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~generatori);
	end procedure;

	//dato un gruppo G e un multiset di classi di coniugio, ritorna il sottogruppo di Aut(G) che fissa il multiset
	StabilizzatoreClassiDiConiugio:=function(G, classiDiConiugio)
		AutG:=AutomorphismGroup(G);
		r,A:=PermutationRepresentation(AutG);
		CM:=ClassMap(G);
		X:={1..Nclasses(G)};
		f:=map<CartesianProduct(X,A) -> X | xAndA :-> CM((r^-1)(xAndA[2])(ClassRepresentative(G,xAndA[1])))>;
		Y:= Orbit(A,GSet(A,X,f),classiDiConiugio);
		stabilizzatore:=Stabilizer(A,Y,classiDiConiugio);
		return sub<AutG | [(r^-1)(g): g in Generators(stabilizzatore)]>;
	end function;

	//given two sequences [x_1,..,x_r], [y_1,..,y_r] with the same underlying multiset, give a permutation sigma such that x_sigma_i=y_i
	PermutationMapping:=function(sequence1, sequence2)	
		if #sequence1 ne #sequence2 then error sequence1, sequence2, "do not have the ame number of elements"; end if;
		sigma:=[];
		for x in sequence1 do
			i:=Index(sequence2,x);
			while i in sigma do	
				i:=Index(sequence2,x,i+1); 
			end while;
			if i eq 0 then error sequence1, "is not a permutation of ", sequence2; end if;
			Append(~sigma,i);
		end for;
		return SymmetricGroup(#sequence1) ! sigma;
	end function;

	AzioneAutomorfismoSuClasseDiConiugio:=function(datiCalcoloGeneratori,automorfismo,classe)
		rappresentante:=ClassRepresentative(datiCalcoloGeneratori`group, classe);		
		return datiCalcoloGeneratori`classMap(automorfismo(rappresentante));
	end function;

	//dato un automorfismo f di G, ritorna una parola h nel gruppo libero tale che facendo agire il gruppo libero come trecce '(g,h) fissi la classe di coniugio.
	AzioneDiAutomorfismoComeTreccia:=function(datiCalcoloGeneratori,classiDiConiugio, f)
		immagineClassiDiConiugio:=[AzioneAutomorfismoSuClasseDiConiugio(datiCalcoloGeneratori,f,C): C in classiDiConiugio];
		sigma:=PermutationMapping(immagineClassiDiConiugio,classiDiConiugio);
		r:=#classiDiConiugio;
		gruppoLibero:=FreeGroup(r-1);
		azionetrecce:=hom<gruppoLibero->SymmetricGroup(r) | [SymmetricGroup(r) ! (i,i+1) : i in [1..r-1]]>;
		return sigma @@ azionetrecce;
	end function;	
	
	//ritorna l'azione di una parola h nel gruppo libero su r-1 generatori su una sequenza di vettori generatori x=(g_1,..,g_r)
	AzioneTreccia:=function(x,h) 
		image:=x;
		for generator in Eltseq(h) do
			if generator ge 1 then
				image:=HurwitzMove(image,generator);
			else 
				image:=InverseHurwitzMove(image,-generator);
			end if;
		end for;
		return image;
	end function;	

	//dato il gruppo G e l'insieme X dei generatori sferici (g_1,...,g_r) con classi di coniugio assegnate, restituisce i generatori corrispondenti del gruppo delle permutazioni di X
	GeneratoriDaAutG:=function(datiCalcoloGeneratori,X,classiDiConiugio)
		generatori:=[];
		stabilizzatoreInAutG:=StabilizzatoreClassiDiConiugio(datiCalcoloGeneratori`group, {* C: C in classiDiConiugio *});		
		for g in Generators(stabilizzatoreInAutG) do 
			h:=AzioneDiAutomorfismoComeTreccia(datiCalcoloGeneratori,classiDiConiugio,g);
			Include(~generatori,SymmetricGroup(X) ! [AzioneTreccia(x	@g,h) : x in X]);
		end for;
		return generatori;
	end function;

	//dato l'insieme X dei generatori sferici (g_1,...,g_r) con classi di coniugio assegnate, il gruppo G e l'intero r, 
	//determina il sottogruppo del prodotto di Aut(G) per il gruppo delle trecce che preserva X, e lo restituisce come sottogruppo delle permutazioni di X
	SottogruppoDiPermutazioni:=function(datiCalcoloGeneratori,X,classiDiConiugio)
		r:=#classiDiConiugio;
		azioniDeiGeneratoriDiAutG:=GeneratoriDaAutG(datiCalcoloGeneratori,X,classiDiConiugio);
		trecceChePreservanoClassi:={i : i in [1..r-1] | classiDiConiugio[i] eq classiDiConiugio[i+1]};
		generatoriTrecceImpure:=[SymmetricGroup(X) ! [HurwitzMove(x,i) : x in X] : i in trecceChePreservanoClassi];
		generatoriTreccePure:=[SymmetricGroup(X) ! [TrecciaPura(x,i,j) : x in X] : i in [1..r-1], j in [2..r] | i lt j and classiDiConiugio[i] ne classiDiConiugio[j]];
		return PermutationGroup< X | azioniDeiGeneratoriDiAutG cat generatoriTrecceImpure cat generatoriTreccePure>;
	end function;

	ClassiDiConiugioComeInsiemi:=function(datiCalcoloGeneratori,classiDiConiugio)
		G:=datiCalcoloGeneratori`group;
		return [Class(G,ClassRepresentative(G,i)) : i in classiDiConiugio];
	end function;

	
	_AggiungiGeneratoriSfericiInClassiDiConiugio:=procedure(datiCalcoloGeneratori,classiDiConiugio,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~rappresentanti) 
		local sottogruppoDiPermutazioni;
		X:={};
		classiDiConiugioComeInsiemi:=ClassiDiConiugioComeInsiemi(datiCalcoloGeneratori,classiDiConiugio);
		
		AggiungiSequenzaCortaSeGenera:=procedure(v,ultimoInsieme,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~generatori)
			local subsetGenerates;
			ultimoElemento:=(&*v)^-1;		
			if ultimoElemento in ultimoInsieme then 
				DeterminaSeIlSottoinsiemeGenera({g : g in v},datiCalcoloGeneratori`group,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~subsetGenerates);
				if subsetGenerates then	
					Include(~generatori, Append(v,ultimoElemento));
				end if;
			end if;
		end procedure;
		
		AggiungiVettoriGeneratoriDiElementiIn(datiCalcoloGeneratori,classiDiConiugioComeInsiemi,~AggiungiSequenzaCortaSeGenera,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~X);
		if IsEmpty(X) then return; end if;
		sottogruppoDiPermutazioni:=SottogruppoDiPermutazioni(datiCalcoloGeneratori,X,classiDiConiugio);
		rappresentanti join:={orbitSizeAndRepresentative[2] : orbitSizeAndRepresentative in OrbitRepresentatives(sottogruppoDiPermutazioni)};
	end procedure;

	SommaDiFrobenius:=function(TavolaDeiCaratteri,ClassiDiConiugio);
		somma:=0;
		for Carattere in TavolaDeiCaratteri do prodotto:=(1/Carattere[1])^(#ClassiDiConiugio-2);
		   for Classe in ClassiDiConiugio do prodotto*:=Carattere[Classe];
		   end for; 
		  somma+:=prodotto;
		end for;
	return somma;
	end function; 

	ClassiDiConiugioOrdinate:=function(datiCalcoloGeneratori,classiDiConiugio) 
		k:=0;
		classi:=[];		
		for class in MultisetToSet(classiDiConiugio) do
			size:=datiCalcoloGeneratori`classSizes[class];	
			if size gt k then 
				biggest:=class;
				k:=size;
			end if;
		end for;				
		return [classe : classe in classiDiConiugio | classe ne biggest ] cat [biggest : i in [1..Multiplicity(classiDiConiugio,biggest)]];
	end function;

	AggiungiGeneratoriSfericiInClassiDiConiugio:=procedure(classiDiConiugio,datiCalcoloGeneratori,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~rappresentanti)
	 if SommaDiFrobenius(datiCalcoloGeneratori`characterTable,classiDiConiugio) ne 0 and ScottTest(classiDiConiugio,datiCalcoloGeneratori`datiGModuli) then
			classiDiConiugioOrdinate:=ClassiDiConiugioOrdinate(datiCalcoloGeneratori,classiDiConiugio);
			_AggiungiGeneratoriSfericiInClassiDiConiugio (datiCalcoloGeneratori, classiDiConiugioOrdinate, ~sottoinsiemiTrovatiCheGenerano, ~sottoinsiemiTrovatiCheNonGenerano, ~rappresentanti);
		end if;
	end procedure;

	FlushKnownGeneratingSets:=procedure(datiCalcoloGeneratori,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~rappresentanti)
		if not IsEmpty(sottoinsiemiTrovatiCheNonGenerano) then
			print "flushing", #sottoinsiemiTrovatiCheGenerano, #sottoinsiemiTrovatiCheNonGenerano;
		end if;
		sottoinsiemiTrovatiCheGenerano:={};
		sottoinsiemiTrovatiCheNonGenerano:={};	
	end procedure;

//return a group that acts on the given set of conjugacy classes as Aut(G)
	AutGOnConjugacyClasses:=function(datiCalcoloGeneratori,classes)
 		G:=datiCalcoloGeneratori`group;
		AutG:=AutomorphismGroup(G);
		generators:=[
		  	[AzioneAutomorfismoSuClasseDiConiugio(datiCalcoloGeneratori,aut,class) : class in classes]
	  	 : aut in Generators(AutG)
		  ];
		return PermutationGroup<classes|generators>;
	end function;


	FindAllComponentsNonabelian:=function(G,M)
		rappresentanti:={};
		sottoinsiemiTrovatiCheGenerano:={};
		sottoinsiemiTrovatiCheNonGenerano:={};
		datiCalcoloGeneratori:=rec<formatoDatiCalcoloGeneratori | group:=G,classMap:=ClassMap(G),
			classSizes:=[#Conjugates(G,ClassRepresentative(G,i)) : i in [1..Nclasses(G)]],
			datiGModuli:=DatiGModuli(G),characterTable:=CharacterTable(G)
		>;
	allConjugacyClassesByOrder:=ConjugacyClassesByOrder(G);
	conjugacyClasses:=&join [allConjugacyClassesByOrder[x] : x in {m: m in M}];
	setsAndMultiplicities:=SetsAndMultiplicities(M,allConjugacyClassesByOrder);
	IterateOverMultisetsWithCommonUnderlyingSet(setsAndMultiplicities, [], AutGOnConjugacyClasses(datiCalcoloGeneratori,conjugacyClasses), AggiungiGeneratoriSfericiInClassiDiConiugio, FlushKnownGeneratingSets, datiCalcoloGeneratori,  ~sottoinsiemiTrovatiCheGenerano, ~sottoinsiemiTrovatiCheNonGenerano, ~rappresentanti);
		return rappresentanti;
	end function;	



