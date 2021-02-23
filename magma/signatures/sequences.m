/* This function allows iterating through nondecreasing sequences 1\leq i_1\leq ... \leq i_h\leq x 
	It takes a nondecreasing sequence [i_1,...,i_h], which is modified into the next sequence if it exists, or the empty sequence [].
  The parameter max is the upper bound x for elements of the sequence.
 */
NextSequence:=procedure(~sequence, max); //SeqEnum, int
		i:=#sequence;
		while (i gt 0) and (sequence[i] eq max)  do
			i-:=1;
		end while;
		if i eq 0 then
			sequence:=[]; 
			return;
		end if;
		sequence[i]+:=1;
		while i lt #sequence do
			sequence[i+1]:=sequence[i];
			i+:=1;
		end while;
end procedure;


