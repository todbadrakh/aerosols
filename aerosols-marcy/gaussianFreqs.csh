#!/bin/tcsh
#
# Reads vibrational frequencies from Gaussian output files
#
# Usage: gaussianFreq.csh output-file [anharm]"
#    Eg: gaussianFreq.csh test.log"
#    Eg: gaussianFreq.csh test-anharm.log anharm\n"

if ( ($#argv == 1) || ($#argv == 2) ) then
else
  echo "Error in the number of arguments passed ($#argv). It needs to be 1 or 2"
  echo "Usage: gaussianFreq.csh output-file [anharm]"
  echo "   Eg: gaussianFreq.csh test.log"
  echo "   Eg: gaussianFreq.csh test-anharm.log anharm\n"
  exit()
endif

setenv SCRIPTS_HOME /usr/local/sbin/aerosols
setenv GAU_VERSION `grep "Gaussian 16:" $1  | awk -F"L-" '{print $2}' | awk '{print $1}'` 

if ( $2 == "anharm" ) then
  if ( $GAU_VERSION == "G09RevD.01  ") then 
    grep -A 100 " Fundamental Bands (DE w.r.t. Ground State)" $1|grep -v "Fundamental" | awk '{if($1=="Overtones") exit; else {printf "%4.2f ",$4}}' | sort -n
  else
    grep -A 100 " Fundamental Bands (DE w.r.t. Ground State)" $1|grep -v "Fundamental" | awk '{if($1=="Overtones") exit; else {printf "%4.2f ",$3}}' | sort -n
  endif
else
  awk '{a[NR]=$0}END{for(i=NR;i>=1;i--) {if(a[i] ~ '/^\ Harmonic/') exit; else print a[i]}}' $1 | grep Frequencies | awk '{{print $3, "\n",$4,"\n", $5}}' | sort -n | awk '{printf "%4.2f ", $1}' | sort -n
endif

echo " "
