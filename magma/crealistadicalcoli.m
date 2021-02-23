/*Script per creare il csv da dare in pasto a hliðskjàlf
scrive su outFile
takes parameters minG, maxG,minR [default 3],maxR .
for each g, consider r<=2g+2, r<=maxR.
*/

load "magma/segnaturenc.m";

if not assigned maxG then error "define maxG (and possibly minG, defaulting to 2) before invoking this program"; end if;
if not assigned minG then minG:="2"; end if;
if not assigned maxR then maxR:="-1"; end if;
if not assigned minR then minR:="3"; end if;
if not assigned outFile then error "define outFile before invoking this program"; end if;
if assigned onlyNonCyclic then print "skipping signatures that correspond to cyclic groups"; end if;

minG:=StringToInteger(minG);
maxG:=StringToInteger(maxG);
maxR:=StringToInteger(maxR);
minR:=StringToInteger(minR);

if maxR lt 0 then print "r >= ",minR, ", ",minG,"<= g <=",maxG;
else print minR,"<= r <=",maxR,", ",minG,"<= g <=",maxG;
end if;

if assigned onlyNonCyclic then 
WriteLine:=procedure(d,n,M,file)
	if d in M then return; end if;
	riga:=Sprint(d) cat ";" cat Sprint(n) cat ";" cat Sprint(M);
	Puts(file,riga);
end procedure;
else
WriteLine:=procedure(d,n,M,file)
	riga:=Sprint(d) cat ";" cat Sprint(n) cat ";" cat Sprint(M);
	Puts(file,riga);
end procedure;
end if;

WriteComputations:=procedure(g,file)
	boundR:=2*g+2;
	if maxR gt 0 then boundR:=Min(boundR,maxR); end if;
	for r in [minR..boundR] do
	for M in Segnature_g_r(g,r) do
		d:=M`OrdG;
		WriteLine(d,NumberOfSmallGroups(d),M`Rami,file);
	end for;
	end for;
end procedure;

file:=Open(outFile,"w");

for g in [minG..maxG] do		
		WriteComputations(g,file);
end for;

delete file;

quit;
