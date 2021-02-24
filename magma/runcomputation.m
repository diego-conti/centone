/* 
This script runs the code that tests the Coleman-Oort conjecture on spherical systems of generators corresponding to a given set of signatures and groups, e.g:
magma processID:=1 dataFile:=data.csv outputPath:=co memory:=1 magma/runcomputation.m
invokes the test on the signatures contained in the file data.csv, using a maximum memory of 1 GB and writing the output to co/1.csv.
The script performs one computation at a time; if memory runs out during a computation, the script terminates. The offending data can be recovered by comparing the dataFile to the output.

It takes the following parameters:
processID a unique string identifying the process. Useful for parallelization; it determines the name of the file to be used for output
dataFile a file containing the computations to be performed, each line having the form d;n;[m_1,...,m_r], corresponding to SmallGroup(d,n) and signature [m_1,...,m_r]
outputPath a directory where output should be stored
memory the memory limit in GB
*/

load "magma/colemanoort/colemanoort.m"

if not assigned processId then error "variable processId should be assigned to unique string"; end if;
if not assigned dataFile then error "variable dataFile should point to a valid data file"; end if;
if not assigned outputPath then error "variable outputPath should point to a directory to contain the output"; end if;
if not assigned memory then error "variable memory should indicate how many GB to use"; end if;

AbelianizationInvariants:=function(G)
	group:=G;
	if Type(group) eq GrpPerm then group:=FPGroup(group); end if;
	return AbelianQuotientInvariants(group);
end function;


//exclude the case where the abelianization cannot be generated by r-1 elements and the case where the lcm of r-1 elements in M is not a multiple of some abelian invariant.
CannotGenerateAbelianization:=function(M,invariants)
	if #invariants ge #M then return true; end if;
	if IsEmpty(invariants) then return false; end if;	//skip the test for perfect groups
	last:=invariants[#invariants];
	M_as_set:={x: x in M};
	if not IsDivisibleBy(Lcm(M_as_set),last) then return true; end if;
	for x in M_as_set do		
		if Multiplicity(M,x) eq 1 and not IsDivisibleBy(Lcm(Exclude(M_as_set,x)),last) then return true; end if;
	end for;
	return false;
end function;

/* function Admissible in Algorithm 3 of [CGP]. It returns false,reason if the computation should be skipped, where reason is a string describing the criterion used to exclude the computation.
It returns true if none of the criteria apply */
Admissible:=function(G, M)
	if (#M ge 5) and IsCyclic(G) then return false,"cyclic"; end if;
	if  ( #M eq 4) and IsAbelian(G) then return false,"abelian"; end if;
	orders:={Order(g): g in G};
	if exists {m : m in M | m notin orders} then return false,"order"; end if;
  g:=Integers() ! Genere(M,Order(G));
	if g gt 2 and exists {o: o in orders | o gt 4*(g-1)} then return false,"KW"; end if;
	invariants:=AbelianizationInvariants(G); 
	if # [x: x in invariants | IsEven(x)] ge 4  then return false,"(Z_2)^4"; end if;
	if CannotGenerateAbelianization(M,invariants) then return false,"abelianization"; end if;
 	return true;
end function;

ParametersFormat:=recformat< d: Integers(), n: Integers(), M : SeqEnum>;

ReadParameters:=function(line)
	result:=rec<ParametersFormat|>;
	components:=Split(line,";");
	if #components ne 3 then error "Each line in datafile should have the form d;n;[m_1,...,m_r]", components; end if;
	result`d:=StringToInteger(components[1]);
	result`n:=StringToInteger(components[2]);
	result`M:=eval(components[3]);
	if ExtendedType(result`M) ne SeqEnum[RngIntElt] then error "Each line in datafile should have the form d;n;[m_1,...,m_r], with the m_i integers", result`M; end if;
	return result;
end function;

EXCLUDED_STRING:="I";

WriteToOutputFile:=procedure(line,outputPath)
	Write(outputPath cat "/" cat Sprint(processId) cat ".csv",line);
end procedure;

WriteLineToOutputFile:=procedure(parameters, runningTime, data,outputPath)
	firstPart:=[* parameters`d, parameters`n, parameters`M,MBUsedAndTimeSinceLastReset(runningTime),VERSION *];
	line:= FrapponiSeparatore(firstPart,";") cat ";{" cat FrapponiSeparatore(data,":") cat "}";
	WriteToOutputFile(line,outputPath);
end procedure;

FindCounterExamplesFromParameters:=procedure(parameters,outputPath)
	local runningTime;
	ResetTimeAndMemoryUsage(~runningTime);	
  G:=SmallGroup(parameters`d,parameters`n);
  admissible,reasonToExclude:=Admissible(G,parameters`M);
	if admissible then
		counterexamples:=SetToSequence(FindCounterexamplesToColemanOort(G,parameters`M));
		WriteLineToOutputFile(parameters,runningTime,counterexamples,outputPath);
	else 
		WriteLineToOutputFile(parameters,runningTime,[EXCLUDED_STRING, reasonToExclude],outputPath);
	end if;
end procedure;

FindCounterExamplesFromFile:=procedure(fileName,outputPath)
	file:=Open(fileName,"r");
	line:=Gets(file);
	while not IsEof(line) do
		FindCounterExamplesFromParameters(ReadParameters(line),outputPath);
		line:=Gets(file);
	end while;
end procedure;


SetMemoryLimit(StringToInteger(memory)*1024*1024*1024);
SetQuitOnError(true);
SetColumns(1024);

FindCounterExamplesFromFile(dataFile,outputPath);

quit;
