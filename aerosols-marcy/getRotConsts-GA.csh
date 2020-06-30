#!/bin/tcsh
umask 0027
if ( $#argv < 3 || $#argv > 4) then
	echo "USAGE: ./getRotConsts_C.csh [#atoms in each xyz file] [min rank] [max rank] "
	exit
endif

if(`ls rank*xyz | grep -ci "geom"`) then
   setenv EXTRACTED 1
   alias seq 'seq -w'
else
   setenv EXTRACTED 0
endif

echo "Rotational_Constants : -50000" > rotConstsData_C
foreach i (`seq $2 $3`)
   if ( $EXTRACTED ) then 
       set file = (rank$i\geometry*.xyz)
     else
       set file = (rank$i\individual*.xyz)
   endif

   echo -n "$file : " >> rotConstsData_C
   echo -n `grep Energy $file | awk '{printf "%4.6f", $2/4.184/627.51}'` >> rotConstsData_C
   echo -n " " >> rotConstsData_C
   echo `~btemelso/bin/getrotconsts $file $1` >> rotConstsData_C
end

setenv DIR `basename $PWD`

#sort -n -k 3 rotConstsData_C | awk -v dir=$DIR '{if(NR==1) {print $0} else if(NR==2) {min=$3; print $0, "0.00"} else {printf "%s/%s\t%s\t%-4.6f\t%-2.4f\t%-2.4f\t%-2.4f\t%-1.2f\n", dir, $1, $2, $3, $4, $5, $6, ($3-min)*627.51}}' | column -t > temp

sort -n -k 3 rotConstsData_C | awk -v dir=$DIR '{if(NR==1) {print $0} else if(NR==2) {min=$3; printf "%s/%s\t%s\t%-4.6f\t%-2.4f\t%-2.4f\t%-2.4f\t%-1.2f\n", dir, $1, $2, $3, $4, $5, $6, ($3-min)*627.51} else {printf "%s/%s\t%s\t%-4.6f\t%-2.4f\t%-2.4f\t%-2.4f\t%-1.2f\n", dir, $1, $2, $3, $4, $5, $6, ($3-min)*627.51}}' | column -t > temp

mv temp rotConstsData_C
