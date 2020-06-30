#!/bin/tcsh

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

umask 0027
unalias cp
unalias mv 
unalias rm 

rm -f /tmp/temp
touch /tmp/temp

setenv NAME $1

if ( $#argv < 2 ) then
   echo "Error in the number of arguments passed.\n"
   echo "Usage: run.csh <name> <list of directories to look through>"
   echo "   Eg: run.csh pw91 pw91-pm7 pw91-pm7-S pw91-pm7-D"
   exit 
endif   

if($#argv > 1) then
   foreach DIR ($argv[2-])
      awk -v D=$DIR '{print D"/"$0}' $DIR/rotConstsData_C  |grep -v Rot  >> /tmp/temp
      @ argnum ++
   end
else
   foreach DIR (`find -type d | grep "[a-zA-Z]" | sed "s/\.\///g"`)
      awk -v D=$DIR '{print D"/"$0}' $DIR/rotConstsData_C  |grep -v Rot  >>/tmp/temp
   end
endif

sort -n -k 3 /tmp/temp | awk 'BEGIN {print "Rot_const : -50000" } {if(NR==1) {min=$3; print $0, "0.00"} else {printf "%s\t%s\t%-4.6f\t%-2.4f\t%-2.4f\t%-2.4f\t%-1.2f\n", $1, $2, $3, $4, $5, $6, ($3-min)*627.51}}' | column -t > rotConstsData_C-$1 
	
$SCRIPTS_HOME/similarityAnalysis.py $1 rotConstsData_C-$1 #0 2000
	
rm -f /tmp/temp
