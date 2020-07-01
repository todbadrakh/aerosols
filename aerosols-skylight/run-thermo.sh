#!/bin/bash 

SCRIPTS_HOME=/usr/local/sbin/aerosols

awk '{print $1}' $1 > tmp

while read line; do
  FILE=`basename -s .xyz $line`
  perl $SCRIPTS_HOME/nist-thermo.pl $FILE.log
done < tmp
rm -rf tmp
