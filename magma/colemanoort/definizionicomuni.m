//non definire le cose due volte se il file è già stato caricato
if not assigned DEFINIZIONI_COMUNI_M_CARICATO then 
DEFINIZIONI_COMUNI_M_CARICATO:=true;

DegreeOfCanonicalBundle:=function(M,d)
	deg:=d*(-2+#M-&+[1/M[i]: i in [1..#M]]);
	return deg;
end function;

//ritorna la soluzione in g di degK=2g-2
Genus := function(M,d)
	return DegreeOfCanonicalBundle(M,d)/2+1;
end function;


//un record che contiene la terna (d,n,SmallGroup(d,n))
FormatoGruppo:=recformat< d: Integers(), progressivoGruppo: Integers(), gruppo>;

GroupToString:=function(smallgroupAsRecord)
	return "Smallgroup(" cat Sprint(smallgroupAsRecord`d) cat "," cat Sprint(smallgroupAsRecord`progressivoGruppo) cat ")";
end function;

/* crea un nome file valido a partire da una sequenza di interi */	
NomeFileDaParametri:=function(parameters) 
	return &cat [IntegerToString(i) cat "." : i in parameters];
end function;

FrapponiSeparatore:=function(contenitoreDiPrintable, separatore) 
	result:="";
	if IsEmpty(contenitoreDiPrintable) then return result; end if;
	result:=Sprint(contenitoreDiPrintable[1]);	
	for i in [2..#contenitoreDiPrintable] do
		result cat:=separatore;
		result cat:=Sprint(contenitoreDiPrintable[i]);
	end for;
	return result;
end function;

end if;
//chiude l'if per non definire le cose due volte se il file è già stato caricato

