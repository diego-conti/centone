
	//////////////////////////////////////////////////////////////////////
	//determina se un sottoinsieme di un gruppo è un sottoinsieme di generatori, cacheando i risultati trovati in sottoinsiemiTrovatiCheGenerano o sottoinsiemiTrovatiCheNonGenerano
	//restituisce il risultato dentro la variabile result perchè magma è stronzo e per passare le variabili per riferimento obbliga a usare le procedure 
	DeterminaSeIlSottoinsiemeGenera:=procedure(sottoinsieme,group,~sottoinsiemiTrovatiCheGenerano,~sottoinsiemiTrovatiCheNonGenerano,~result)
			if sottoinsieme in sottoinsiemiTrovatiCheGenerano then 
				result:= true;
			elif sottoinsieme in sottoinsiemiTrovatiCheNonGenerano then
				result:= false;
			elif sub<group|sottoinsieme> eq group then
				Include(~sottoinsiemiTrovatiCheGenerano,sottoinsieme);
				result:= true;
			else
				Include(~sottoinsiemiTrovatiCheNonGenerano,sottoinsieme);
				result:= false;
			end if;
	end procedure;

