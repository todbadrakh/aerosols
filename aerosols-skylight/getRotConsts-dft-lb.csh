#!/bin/tcsh
# reads final energies and rotational constants from DFT optimizations
#
# Usage: getRotConsts-dft.csh [functional] [#atoms in each xyz file]"
#    Eg: getRotConsts-dft.csh pw91 31"
#    Eg: getRotConsts-dft.csh m062x 10"

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

umask 0027

if( $#argv != 2) then
  echo "Usage: getRotConsts-dft.csh [functional] [#atoms in each xyz file]"
  echo "   Eg: getRotConsts-dft.csh pw91 31"
  echo "   Eg: getRotConsts-dft.csh m062x 10"
  exit()
endif

#determine functional
switch ($1)
  case pw91:
    set functional = pw91-pw91
    breaksw
  default:
    set functional = $1
    breaksw
endsw

echo "Rotational_Constants : -50000 " > rotConstsData_C
foreach i (`ls *log | sed "s/.log//g"`)
  echo -n "$i.xyz : " >> rotConstsData_C
  echo -n `$SCRIPTS_HOME/gaussianE.csh $functional last $i.log | awk '{print $2}'` >> rotConstsData_C
  echo -n " " >> rotConstsData_C
	obabel -ig09 $i.log -oxyz > $i.xyz 
  echo `$SCRIPTS_HOME/calcRotConsts.py $i.xyz` >> rotConstsData_C
end

sort -n -k 3 rotConstsData_C | awk '{if(NR==1) {print $0} else if(NR==2) {min=$3; print $0, "0.00"} else {printf "%s\t%s\t%-4.6f\t%-2.4f\t%-2.4f\t%-2.4f\t%-1.2f\n", $1, $2, $3, $4, $5, $6, ($3-min)*627.51}}' | column -t > /tmp/$USER-temp 
mv /tmp/$USER-temp rotConstsData_C
