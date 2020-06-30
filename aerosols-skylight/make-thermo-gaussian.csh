#!/bin/tcsh
# prepares a file with information necessary to calculate thermodynamic qualtities using Karl
# Irikura's thermo.pl script 
# https://www.nist.gov/mml/csd/chemical-informatics-research-group/products-and-services/program-computing-ideal-gas
#
# Usage: make-thermo.csh <file with opt coord> <file with freq calc> <name of file to write to>e
#	Eg: make-thermo.csh orimp2-isomer1.xyz isomer1-rimp2-opt.out isomer1-thermo.inp

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

if ( ($#argv < 3) || ($#argv > 4) ) then
  echo "Error in the number of arguments passed.\n"
  echo "Usage: make-thermo.csh <file with opt coord> <file with freq calc> <name of file to write to> [symm_no]"
  echo "   Eg: make-thermo.csh orimp2-isomer1.xyz isomer1-rimp2-opt.out isomer1-thermo.inp 2"
  exit
endif

echo "[molecule]" > /tmp/temp-$USER
echo "file = $1" >> /tmp/temp-$USER
echo "symm = 1" >> /tmp/temp-$USER

$SCRIPTS_HOME/calcRotConsts.py -m $1 > $3 

echo -n "VIB    " >> $3 
echo `$SCRIPTS_HOME/gaussianFreqs.csh $2` >> $3 
if ( $#argv == 4 ) then
  echo "SYMNO  $4" >> $3 
else
  echo "SYMNO   1" >> $3 
endif
echo "ELEC   1  0.0" >> $3 

rm -f /tmp/temp-$USER
