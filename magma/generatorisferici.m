	//////////////////////////////////////////////////////////////////////
	//  
	// Hurwitz Moves, modified version of:
	// http://www.science.unitn.it/~pignatel/papers/Nodal.magma
	// 
	// See there for more information.
	//////////////////////////////////////////////////////////////////////
	load "magma/definizionicomuni.m";
	load "magma/log.m";
	load "magma/refinedpassports.m";
	load "magma/generatorisfericiabeliano.m";
	load "magma/coleman.m";
	
	VERSION:="FastCWColemanOort";
	FindAllComponents:=function(type, smallgroupAsRecord)
		G:=smallgroupAsRecord`gruppo;
		return FindCounterexamplesToColemanOort(G,type);
	end function;	

