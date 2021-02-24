//script to compute the character of the representation phi from a spherical system of generators
//based on a script by Gleissner [citation here]

/* Let X  be a character of the group G and g be a group element. The script "pol" determines the 
characteristic polynomial of "rho(g)", where "rho" is a representation affording the character X. 
The coefficients of the characteristic polynomial are determined from the power sums of the eigenvalues 
X(g^i) by the MAGMA function "PowerSumToCoefficients" (cf. Lemma 1.3.6).*/
 
pol:=function(X,g)
	L:=[X(g^i) : i in [1..Degree(X)]];
	return Polynomial(PowerSumToCoefficients(L)); 
end function;

/* Recall that the roots of pol(X,g) are of the form exp(a*2*pi*i/n), where 0 <= a <= n-1 and n is the 
order of g. Return \sum_a a*Na where exp(a*2*pi*i/n) is a root of pol(X,g) with multiplicity Na and 1 <= a <= n-1.
Gleissner's original script also included the case a=0, but we skip it since a*Na is then zero
*/

SumOfRootLogs:=function(polynomial,n)
	F:=CyclotomicField(n);
	z:=F.1;            // z is equal to exp(2*pi*i/n)
	sum_of_root_logs:=0;
	pol:=polynomial;
	a:=1;
	z_a:=z;
	while not IsUnit(pol) and a lt n do
		x_minus_za:=Polynomial([-z_a,1]);
		q,r:=Quotrem(pol,x_minus_za);
		if r eq 0 then 
			sum_of_root_logs+:=a;
			pol:=q;
		else
			a+:=1;
			z_a*:=z;
		end if;
	end while;
	return sum_of_root_logs;
end function;

//return \sum a N_a /n or zero for trivial character
ChevalleyWeilDataForGroupAndX:=function(X, g,n)
	if IsOne(X) then return 0; 
	else return SumOfRootLogs(pol(X,g),n)/n;
	end if;
end function;

ChevalleyWeilData:=function(G, characterTable, orders)
	data:=AssociativeArray();	
	for g in G do
		n:=Order(g);
		if n in orders then 
			data[g]:=[ChevalleyWeilDataForGroupAndX(X,g,n) : X in characterTable];
		end if;
	end for;
	return data;
end function;

CharacterFromGroupAndGenerators:=function(G,characterTable, chevalleyWeilData, generators)
	character:=0;
	for i in [2..#characterTable] do
		X:= characterTable[i];
		mult:=-Degree(X)+&+([chevalleyWeilData[g][i] : g in generators]);
		character+:=mult*X;
	end for;
	return character;
end function;
	
