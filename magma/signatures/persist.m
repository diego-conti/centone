/* This file implements disk storage and retrieval of magma objects. It exposes two functions:

PersistToFile(path,parameters,object) takes an existing directory, a sequence of integers and a magma object; it creates a file inside the directory, with name determined by the parameters, and stores the magma object in it.
ReadFromFile(path,parameters) takes an existing directory and a sequence of integers; it returns the magma object stored in the file indexed by the parameters

Functions with name starting with _ are considered part of the implementation.
*/

//identifica il formato con cui sono salvati i dati. Da aggiornare se il formato viene cambiato.
_Schema:="Ghighi 1";

/*contenitore per dati da salvare su disco. L'oggetto viene "inscatolato" tra la descrizione dello schema e un SeqEnum che descrive il contenuto,
per minimizzare l'impatto di file corrotti etc.*/

_DatiPersistenti:=recformat< schema: MonStgElt, object, parameters:SeqEnum>;


/* crea un nome file valido a partire da una sequenza di interi */	
NomeFileDaParametri:=function(parameters) 
	return &cat [IntegerToString(i) cat "." : i in parameters] cat "data";
end function;

/* scrive un oggetto su un file
	path: una directory già esistente dove scrivere i dati
	parameters: una sequenza di interi che descrive il contenuto
	object: un oggetto di magma
	
Nota: questa funzione viene usata internamente. Usare PersistiSuFile.
*/
_ScriviSuFile:=procedure(path,parameters,object)
	curdir:=GetCurrentDirectory();
	try 
		ChangeDirectory(path);
		PrintFileMagma(NomeFileDaParametri(parameters),object: Overwrite:=true);
	catch e
		ChangeDirectory(curdir);
		error "error writing to file", e`Object;
	end try;
		ChangeDirectory(curdir);
end procedure;

/* legge un oggetto da un file
	path: la directory che contiene i dati
	parameters: una sequenza di interi che descrive il contenuto

Ritorna un oggetto di magma.

Nota: questa funzione viene usata internamente. Usare LeggiDaFile.
*/

_LeggiDaFile:=function(path,parameters)
	curdir:=GetCurrentDirectory();
	try 
		ChangeDirectory(path);
		object:=Read(NomeFileDaParametri(parameters));
	catch e
		ChangeDirectory(curdir);
		error "error reading from file", e`Object;
	end try;
	ChangeDirectory(curdir);
	return object;
end function;

_VerificaCoerenteConSchema:=procedure(~persistedObject,~parameters) 
	if not Sprint(Format(persistedObject)) cmpeq Sprint(_DatiPersistenti) then
		error "persistedObject is not a rec<_DatiPersistenti>";
	end if;
	if not persistedObject`schema eq _Schema then
		error "wrong schema, " cat _Schema cat " expected";
	end if;
	if not persistedObject`parameters eq parameters then
		error "wrong parameters, " cat Sprint(parameters) cat " expected";
	end if;
end procedure;

/* legge un oggetto da un file
	path: la directory che contiene i dati
	parameters: una sequenza di interi che descrive il contenuto

Ritorna un oggetto di magma
*/

LeggiDaFile:=function(path,parameters)
	if not ExtendedType(parameters) eq SeqEnum[RngIntElt] then
		error "LeggiDaFile: parameters should be a sequence of integers";
	end if;
	persistedObject:=eval(_LeggiDaFile(path,parameters));
	_VerificaCoerenteConSchema(~persistedObject,~parameters);
	return persistedObject`object;
end function;


/* scrive un oggetto su un file
	path: una directory già esistente dove scrivere i dati
	parameters: una sequenza di interi che descrive il contenuto
	object: un oggetto di magma
*/

PersistiSuFile:=procedure(path, parameters, object)
	persistentObject:=rec<_DatiPersistenti|>;
	persistentObject`schema:=_Schema;	
	persistentObject`object:=object;
	persistentObject`parameters:=parameters;
	_ScriviSuFile(path,parameters,persistentObject);
end procedure;

