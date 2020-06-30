#!/bin/tcsh

if ( $#argv == 4 ) then
   setenv CUTOFF 3
   else if ( $#argv == 5 ) then
   setenv CUTOFF $5
 else
   echo "Number of args is $#argv. It should br 4 or 5 "
   echo "Error in the number of arguments passed."
   echo "Usage: run.csh <uniq-str-file> <system name> <queue name> <number of jobs/batch>"
   echo "  Eg.: run.csh uniqueStructures-pm7.data s1a1w3  medium 25"
   echo "  Eg.: run.csh uniqueStructures-pw91.data dftb s1a1w3  mercury 40 5"
   echo "This starts jobs with names s1a1w2-JOBNUMBER in the mercury or medium queues"
   echo "The energy cutoff is 3 kcal/mol unless specified other wise."
   exit
endif

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

setenv TAG $1
setenv JOBNAME $2
setenv QUEUE $3
setenv NJOBS $4
setenv RERUN 0
unalias cp
touch list-done
@ count = 1
@ jobnumber = 1
foreach OLDNAME (`cat $TAG | awk 'BEGIN{ c = '$CUTOFF'}{if($7 < c) {print $1} else {}}'`)
   setenv DIR `echo $OLDNAME | awk -F"/" '{print $1}'`
   setenv FILE `echo $OLDNAME | sed "s/.xyz//g"`
   
	setenv NEWNAME $FILE 
	echo $NEWNAME
	if(`grep -ci "^$NEWNAME" list-done`) then
   	echo "PASS"
 	 else
		if(-e $NEWNAME.log) then
			obabel -ig09 $NEWNAME.log -oxyz > $NEWNAME.xyz
			setenv RERUN 1
		else
			obabel -ig09 ../$NEWNAME.log -oxyz > $NEWNAME.xyz
   	endif

		if( $RERUN ) then
			echo "%nproc=10" > $NEWNAME.com
			echo "%mem=12gb" >> $NEWNAME.com
			echo "%chk=j$NEWNAME.chk" >> $NEWNAME.com
			echo "#T PW91PW91/6-31+g*" >> $NEWNAME.com
			echo " " >> $NEWNAME.com
			echo "$NEWNAME" >> $NEWNAME.com
			echo " " >> $NEWNAME.com
			echo "0 1" >> $NEWNAME.com
			grep "^[NCHOSPF] " $NEWNAME.xyz  >> $NEWNAME.com
			echo " " >> $NEWNAME.com
			echo "--link1--" >> $NEWNAME.com
			echo "%nproc=10" >> $NEWNAME.com
			echo "%mem=12gb" >> $NEWNAME.com
			echo "%chk=j$NEWNAME.chk" >> $NEWNAME.com
			echo "#T PW91PW91/6-311++g** int(Acc2E=10,ultrafine) scf(conver=10) geom(checkpoint,newdefinition) opt(tight,maxcycles=500) freq" >> $NEWNAME.com
			echo " " >> $NEWNAME.com
			echo "$NEWNAME" >> $NEWNAME.com
			echo " " >> $NEWNAME.com
			echo "0 1" >> $NEWNAME.com
			echo " " >> $NEWNAME.com
			setenv RERUN 0
		else
			sed -e "s/opt/int(Acc2E=10,ultrafine) scf(conver=10) opt/g" -e "s/__NAME__/$NEWNAME/g" $SCRIPTS_HOME/templates/template-pw91-HL.com > $NEWNAME.com
			grep "^[NCHOSPF] " $NEWNAME.xyz  >> $NEWNAME.com
			echo " " >> $NEWNAME.com
		endif

		@ res = $count % $NJOBS
		if($res == 1) then
			sed -e "s/__JN__/$JOBNAME/g" -e "s/__NAME__/$NEWNAME/g" -e "s/__QUEUE__/$QUEUE/g" $SCRIPTS_HOME/templates/template-skylight.slurm > run-$jobnumber.slurm
			echo "g09 $NEWNAME.com" >> run-$jobnumber.slurm
		  else
			echo "g09 $NEWNAME.com" >> run-$jobnumber.slurm
		endif

		if($res == 0) then
			if ($QUEUE == "test") then 
		  		echo "Skipping submission $jobnumber"
			else
		  		echo "Submitting $jobnumber"
      		qsub run-$jobnumber.slurm
			endif
			@ jobnumber++
		endif

		echo "$count  - Done with $NEWNAME"
		@ count++
	endif
	endif
end

if($res != 0) then
		if ($QUEUE == "test") then 
		  	echo "Skipping submission $jobnumber"
		 else
      	echo "Submitting $jobnumber"
      	qsub run-$jobnumber.slurm
		endif

      @ jobnumber++
endif

