#!/bin/tcsh
# Prints energies from gaussian output file 
# Usage: gaussianE "method" [last] "output-file"

if($#argv < 2) then
		echo "Usage: gaussianE method [last] output-file[s]"
		echo "   Eg: gaussianE mp2 last output-file[s]"
		echo "   Eg: gaussianE mp2 output-file\n"
		exit()
endif	

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

set method = ` echo $1 | tr "[a-z]" "[A-Z]" `

if($argv[2] == "last") then
   @ argnum = 3
   foreach FILE ( $argv[3-] )
      if($method != "MP2") then
         echo -n "$FILE "
		   grep -T -i "E([RU]$method" $argv[$argnum] | sed "s/D+/e/g" | awk -F"=" '{print $2}'|awk '{printf "%4.8f\n", $1}' | tail -1 
	      else
         echo -n "$FILE "
		   grep -T -i "EUMP2 = " $argv[$argnum] | sed "s/D+/e/g" | awk -F"UMP2 = " '{print $2}'|awk '{printf "\t%4.8f\n", $1}' | tail -1 
      endif
      @ argnum ++
   end
   else
   @ argnum = 2
   foreach FILE ( $argv[2-] )
      if($method != "MP2") then
		   grep -H -T -i "E([RU]$method" $argv[$argnum] | sed "s/D+/e/g" | awk -F"=" '{print $2}' | awk '{printf "%4.8f\n", $1}' 
	      else
		   grep -H -T -i "EUMP2 = " $argv[$argnum] | sed "s/D+/e/g" | awk -F"=" '{print $NF}' | awk '{printf "%4.8f\n", $1}'
      endif
      @ argnum ++
   end
endif
