#!/bin/tcsh  

if ( $#argv == 2 ) then
  setenv XCF $1
else
  echo "Number of args is $#argv. It should be 4 or 5 "
  echo "Error in the number of arguments passed."
  echo "Usage: run-thermo.csh <theory> <unique-str-file>"
  echo "   Eg: run-thermo.csh m08hx uniqueStructures-uf.data"
  exit
endif

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

alias thermo 'perl $SCRIPTS_HOME/thermo.pl \!^ 1 | grep "^[1-9]" | awk '\''{printf "%3.3f\t%3.3f\t%3.3f\t", $5, $9, $10} END {printf "\n" }'\'' '
alias ZPVE 'perl $SCRIPTS_HOME/thermo.pl \!^ 1 | grep zero | awk '\''{printf "%3.3f \t", $10}'\'' '

foreach FILE (`cat $2 | awk -F"-${XCF}" '{print $1}'`)
  if ( -e o$FILE.xyz ) then
  else
    obabel -ig09 $FILE-${XCF}.log -oxyz > o$FILE-${XCF}.xyz
  endif
  @ sym = `$SCRIPTS_HOME/calcSymmetry.csh o$FILE-${XCF}.xyz | grep "It seems to be" |sed "s/[a-zA-Z]//g" | awk '{if(NF==0){print 1} else {print $1}}'`
  $SCRIPTS_HOME/make-thermo-gaussian.csh o$FILE-${XCF}.xyz $FILE-${XCF}.log $FILE-thermo.inp $sym
end

foreach FILE (`cat $2 | awk -F"-${XCF}" '{print $1}'`)
  setenv E `gaussianE.csh m08hx last $FILE-${XCF}.log | awk '{print $2}' | bc `
  printf "%s\t" "$FILE "
  printf "%4.10f\t" $E
  printf "%4.4f\t" `ZPVE $FILE-thermo.inp`
  thermo $FILE-thermo.inp
end
