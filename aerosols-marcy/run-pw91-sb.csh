#!/bin/tcsh

if ( $#argv == 4 ) then
   setenv CUTOFF 30 
   else if ( $#argv == 5 ) then
   setenv CUTOFF $5 
 else
   echo "Number of args is $#argv. It should br 4 or 5 "
   echo "Error in the number of arguments passed."
   echo "Usage: run.csh <uniq-str-file> <system name> <queue name> <number of jobs/batch>"
   echo "  Eg.: run.csh uniqueStructures-pm7.data s1a1w3  medium 25"
   echo "  Eg.: run.csh uniqueStructures-pw91.data dftb s1a1w3  mercury 40 5"
   echo "This starts jobs with names s1a1w2-JOBNUMBER in the mercury or medium queues"
   exit
endif

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

setenv TAG $1
setenv JOBNAME $2
setenv QUEUE `echo $3| tr '[:upper:]' '[:lower:]'`
setenv NJOBS $4
setenv RERUN 0
unalias cp
touch list-done
@ count = 1
@ jobnumber = 1
foreach OLDNAME (`cat $TAG | awk 'BEGIN{ c = '$CUTOFF'}{if($7 < c) {print $1} else {}}'`)
  setenv DIR `echo $OLDNAME | awk -F"/" '{print $1}'`
  setenv FILE `echo $OLDNAME | awk -F"/" '{print $2}'`
  
	setenv NEWNAME `echo $OLDNAME | sed -e "s/\//-/g" -e "s/rank//g" -e "s/globopt//g" -e "s/geometry/-/g" -e "s/individual/-/g" -e "s/.xyz//g"` 
	echo $NEWNAME
	if(`grep -ci "^$NEWNAME" list-done`) then
   	echo "PASS"
 	else
		if(-e $NEWNAME-pw91.log) then
			obabel -ig09 $NEWNAME-pw91.log -oxyz > $NEWNAME.xyz
			setenv RERUN 1
		else
         cp -f ../../GA/$DIR/$FILE $NEWNAME.xyz
   	endif

		if( $RERUN ) then
			echo "%nproc=8" > $NEWNAME-pw91.com
			echo "%mem=15gb" >> $NEWNAME-pw91.com
			echo "%chk=j$NEWNAME.chk" >> $NEWNAME-pw91.com
			echo "#T PW91PW91/6-31+g*" >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
			echo "$NEWNAME" >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
			echo "0 1" >> $NEWNAME-pw91.com
			grep "^[NCHOSPFP] " $NEWNAME.xyz  >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
			echo "--link1--" >> $NEWNAME-pw91.com
			echo "%nproc=8" >> $NEWNAME-pw91.com
			echo "%mem=15gb" >> $NEWNAME-pw91.com
			echo "%chk=j$NEWNAME.chk" >> $NEWNAME-pw91.com
			echo "#T PW91PW91/6-31+g* geom(checkpoint,newdefinition) opt(maxcycles=500)" >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
			echo "$NEWNAME" >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
			echo "0 1" >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
			setenv RERUN 0
		else
			sed "s/__NAME__/$NEWNAME/g" $SCRIPTS_HOME//templates/template-pw91.com > $NEWNAME-pw91.com
			grep "^[NCHOSPFP] " $NEWNAME.xyz  >> $NEWNAME-pw91.com
			echo " " >> $NEWNAME-pw91.com
		endif

		@ res = $count % $NJOBS
		if($res == 1) then
			sed -e "s/__JN__/$JOBNAME/g" -e "s/__NAME__/$NEWNAME/g" -e "s/__QUEUE__/$QUEUE/g" $SCRIPTS_HOME//templates/template-marcy.pbs > run-$jobnumber.pbs
			echo "g09 $NEWNAME-pw91.com" >> run-$jobnumber.pbs
		  else
			echo "g09 $NEWNAME-pw91.com" >> run-$jobnumber.pbs
		endif

		if($res == 0) then
			if ($QUEUE == "test") then 
		  		echo "Skipping submission $jobnumber"
			else
		  		echo "Submitting $jobnumber"
      		qsub run-$jobnumber.pbs
			endif
			@ jobnumber++
		endif

		@ count++
		echo "$count  - Done with $NEWNAME"
	endif
	endif
end

if($res != 0) then
		if ($QUEUE == "test") then 
		  	echo "Skipping submission $jobnumber"
		 else
      	echo "Submitting $jobnumber"
      	qsub run-$jobnumber.pbs
		endif

      @ jobnumber++
endif

