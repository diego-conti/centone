/* Given a subset of a group, determine whether it generates.
For efficiency, this function takes two parameters containing a list of subsets that are already known to generate or not generate the group; these lists are updated by the function.
The result is stored in the variable result, since Magma does not allow simultaneous use of pass-by-reference variables and return values.
*/
DetermineWhetherSubsetGenerates:=procedure(subset,group,~subsetsThatGenerate,~subsetsThatDoNotGenerate,~result)
	if subset in subsetsThatGenerate then 
		result:= true;
	elif subset in subsetsThatDoNotGenerate then
		result:= false;
	elif sub<group|subset> eq group then
		Include(~subsetsThatGenerate,subset);
		result:= true;
	else
		Include(~subsetsThatDoNotGenerate,subset);
		result:= false;
	end if;
end procedure;

