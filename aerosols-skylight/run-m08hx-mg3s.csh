#!/bin/tcsh

if ( $#argv == 4 ) then
  setenv CUTOFF 30
  else if ( $#argv == 5 ) then
  setenv CUTOFF $5
else
  echo "Number of args is $#argv. It should be 4 or 5 "
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
setenv QUEUE $3
setenv NJOBS $4
setenv RERUN 0
unalias cp
touch list-done
@ count = 1
@ jobnumber = 1
foreach OLDNAME (`cat $TAG | awk 'BEGIN{ c = '$CUTOFF'}{if($7 < c) {print $1} else {}}'`)
  setenv DIR m08hx-sb #`echo $OLDNAME | awk -F"/" '{print $1}'`
  setenv FILE `echo $OLDNAME | awk -F"/" '{print $1}'| sed "s/.xyz//g"`
  
	setenv NEWNAME $FILE 
	echo $NEWNAME
	if(`grep -ci "^$NEWNAME" list-done`) then
    echo "PASS"
 	else
	  if(-e $NEWNAME.log) then
		  obabel -ig09 $NEWNAME.log -oxyz > $NEWNAME.xyz
		  setenv RERUN 1
	  else
      cp -f ../$DIR/$FILE.xyz $NEWNAME.xyz
    endif

	  if( $RERUN ) then
		  echo "%nproc=10" > $NEWNAME.com
		  echo "%mem=12gb" >> $NEWNAME.com
		  echo "%chk=$NEWNAME.chk" >> $NEWNAME.com
		  echo "# m08hx/gen" >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
		  echo "$NEWNAME" >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
		  echo "0 1" >> $NEWNAME.com
		  grep "^[NCHOSPF] " $NEWNAME.xyz  >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
      # add basis definition
      setenv H `grep H $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv C `grep C $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv N `grep N $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv O `grep O $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv F `grep F $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv P `grep P $NEWNAME.com | tail -n 1 | awk '{pring $1}'`
      setenv S `grep S $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      if($H == 'H') then 
        cat $SCRIPTS_HOME/basis/mg3s-H.basis >> $NEWNAME.com 
      endif
      if($C == 'C') then 
        cat $SCRIPTS_HOME/basis/mg3s-C.basis >> $NEWNAME.com
      endif
      if($N == 'N') then 
        cat $SCRIPTS_HOME/basis/mg3s-N.basis >> $NEWNAME.com
      endif
      if($O == 'O') then 
        cat $SCRIPTS_HOME/basis/mg3s-O.basis >> $NEWNAME.com
      endif
      if($F == 'F') then
        cat $SCRIPTS_HOME/basis/mg3s-F.basis >> $NEWNAME.com
      endif      
      if($P == 'P') then
        cat $SCRIPTS_HOME/basis/mg3s-P.basis >> $NEWNAME.com
      endif
      if($S == 'S') then
        cat $SCRIPTS_HOME/basis/mg3s-S.basis >> $NEWNAME.com
      endif
      echo " " >> $NEWNAME.com
		  echo "--link1--" >> $NEWNAME.com
		  echo "%nproc=10" >> $NEWNAME.com
		  echo "%mem=12gb" >> $NEWNAME.com
		  echo "%chk=$NEWNAME.chk" >> $NEWNAME.com
		  echo "# m08hx/gen geom(checkpoint,newdefinition) opt(maxcycles=500)" >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
		  echo "$NEWNAME" >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
		  echo "0 1" >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
      if($H == 'H') then
        cat $SCRIPTS_HOME/basis/mg3s-H.basis >> $NEWNAME.com
      endif
      if($C == 'C') then
        cat $SCRIPTS_HOME/basis/mg3s-C.basis >> $NEWNAME.com
      endif
      if($N == 'N') then
        cat $SCRIPTS_HOME/basis/mg3s-N.basis >> $NEWNAME.com
      endif
      if($O == 'O') then
        cat $SCRIPTS_HOME/basis/mg3s-O.basis >> $NEWNAME.com
      endif
      if($F == 'F') then
        cat $SCRIPTS_HOME/basis/mg3s-F.basis >> $NEWNAME.com
      endif      
      if($P == 'P') then
        cat $SCRIPTS_HOME/basis/mg3s-P.basis >> $NEWNAME.com
      endif
      if($S == 'S') then
        cat $SCRIPTS_HOME/basis/mg3s-S.basis >> $NEWNAME.com
      endif
      echo " " >> $NEWNAME.com
		  setenv RERUN 0
	  else
		  sed -e "s/tight,//g" -e "s/freq//g" -e "s/__NAME__/$NEWNAME/g" $SCRIPTS_HOME/templates/template-m08hx-gen.com > $NEWNAME.com
		  grep "^[NCHOSPF] " $NEWNAME.xyz  >> $NEWNAME.com
		  echo " " >> $NEWNAME.com
      setenv H `grep H $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv C `grep C $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv N `grep N $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv O `grep O $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv F `grep F $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      setenv P `grep P $NEWNAME.com | tail -n 1 | awk '{pring $1}'`
      setenv S `grep S $NEWNAME.com | tail -n 1 | awk '{print $1}'`
      if($H == 'H') then 
        cat $SCRIPTS_HOME/basis/mg3s-H.basis >> $NEWNAME.com 
      endif
      if($C == 'C') then 
        cat $SCRIPTS_HOME/basis/mg3s-C.basis >> $NEWNAME.com
      endif
      if($N == 'N') then 
        cat $SCRIPTS_HOME/basis/mg3s-N.basis >> $NEWNAME.com
      endif
      if($O == 'O') then 
        cat $SCRIPTS_HOME/basis/mg3s-O.basis >> $NEWNAME.com
      endif
      if($F == 'F') then
        cat $SCRIPTS_HOME/basis/mg3s-F.basis >> $NEWNAME.com
      endif      
      if($P == 'P') then
        cat $SCRIPTS_HOME/basis/mg3s-P.basis >> $NEWNAME.com
      endif
      if($S == 'S') then
        cat $SCRIPTS_HOME/basis/mg3s-S.basis >> $NEWNAME.com
      endif
      echo " " >> $NEWNAME.com
	  endif

	  @ res = $count % $NJOBS
	  if($res == 1) then
		  sed -e "s/__JN__/$JOBNAME/g" -e "s/__NAME__/$NEWNAME/g" -e "s/__QUEUE__/$QUEUE/g" $SCRIPTS_HOME/templates/template-skylight.slurm > run-$jobnumber.slurm
		  echo "g16 < $NEWNAME.com > $NEWNAME.log" >> run-$jobnumber.slurm
	  else
		  echo "g16 < $NEWNAME.com > $NEWNAME.log" >> run-$jobnumber.slurm
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
   	qsub run-$jobnumber.slurm
	endif
@ jobnumber++
endif
