iterateThroughDirectory:=procedure(directory,f)
	pipe:=POpen("ls " cat directory cat " -1","r");
	while true do
		line:=Gets(pipe);
		if IsEof(line) then break; end if;
		f(directory cat "/" cat line);
	end while;
	delete pipe;
end procedure;

removeSurroundingBrackets:=function(bracketedString,opening,closing,separator)
	matches,pattern,insideBrackets:=Regexp(opening cat "(.*)" cat closing,bracketedString);
	if not matches then error bracketedString," not a bracket-enclosed list"; end if;
	if IsEmpty(insideBrackets) then return []; end if;
	if #insideBrackets ne 1 then error bracketedString," not a bracket-enclosed list"; end if;
	return Split(insideBrackets[1],separator);
end function;

groupElementFromString:=function(G,g) 
	if Type (G) eq GrpPerm then return eval("G ! " cat g);
	else return elt<G|eval(g)>;
	end if;
end function;

replaceOuterCommasWithColons:=function(string) 
	modifiedString:="";
	modified:=false;
	level:=0;
	for i in [1..#string] do
		if string[i] eq "," and level eq 0 then
			modifiedString cat:=":";
			modified:=true;
		else
			modifiedString cat:=string[i];
		end if;
		if string[i] eq ")" then 
			level-:=1;
		elif string[i] eq "(" then 
			level+:=1;
		end if;
	end for;
	return modified,modifiedString;
end function;
		
groupElements:=function(vettore)
	modified,modifiedString:=replaceOuterCommasWithColons(vettore);
	if modified then
		return removeSurroundingBrackets(modifiedString,"\\[","\\]",":");
	else
		return removeSurroundingBrackets(modifiedString,"\\[","\\]",",");
	end if;	
end function;	

gruppoEGeneratori:=function(d,n,csvlist) 
	G:=SmallGroup(StringToInteger(d),StringToInteger(n));	
	vettori:=removeSurroundingBrackets(csvlist,"{","}",":");
	if IsEmpty(vettori) or vettori[1] eq "IGNORED" then return G,{}; end if;
	return G,{[groupElementFromString(G,g) : g in groupElements(vettore)] : vettore in vettori};
end function;

getLineWithBalancedBraces:=function(file)
	line:=Gets(file);
	if IsEof(line) or "{" notin line then return line; end if;
	while "}" notin line do
		additional_line:=Gets(file);
		if IsEof(additional_line) then return line; end if;
		line cat:=additional_line;
	end while;
	return line;
end function;

parseFile:=procedure(csvfile) 
	file:=Open(csvfile,"r");
	while true do
		line:=getLineWithBalancedBraces(file);
		if IsEof(line) then break; end if;
		valuesInLine:=Split(line,";");
		G,X:=gruppoEGeneratori(valuesInLine[1],valuesInLine[2],valuesInLine[7]);
		print "d=" cat valuesInLine[1] cat ";n=" cat valuesInLine[2] cat ";M=" cat valuesInLine[3] cat ";#X=" cat Sprint(#X);
	end while;
	delete file;
end procedure;


