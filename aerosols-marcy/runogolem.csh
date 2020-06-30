#!/bin/tcsh
# Syntax: runogolem.csh <name of input file> <number of processes> <scratch_dir>
# Eg:	 runogolem.csh input.ogo 16 input_scr
#		where your input file name is 'input.ogo' and the name of processes is 16

if ( $#argv != 4 ) then
   echo "Error in the number of arguments passed.\n"
   echo "Usage: runogolem.csh <input file name> <number of processes>  <name of scratch dir> version"
   echo "  Eg.: runogolem.csh input.ogo 16 scrspace 03-24-14"
   exit
endif

source /usr/local/Modules/3.2.10/init/tcsh
module load jre/1.8.0
module load mpi/openmpi-1.6.4_gnu-4.4.7_ib
setenv OGO_ORCACMD /usr/local/Dist/orca_3_0_3/orca
setenv MOPAC_LICENSE /usr/local/Dist/mopac/2018
setenv OGO_MOPACCMD /usr/local/Dist/mopac/2019/MOPAC2016.exe

#Keep MOPAC from multithreading 
if(`grep -c mopac $1` > 0) then
   setenv OMP_NUM_THREADS 1
endif

setenv SCRATCH /scratch/$GROUP/$USER
if(! -d $SCRATCH/$3) then
   mkdir $SCRATCH/$3
   setenv MYSCR $SCRATCH/$3
  else
   mkdir $SCRATCH/$3-new
   setenv MYSCR $SCRATCH/$3-new
endif

unalias cp 
unalias rm 
foreach FILE (`grep -i -e "MoleculePath" -e "BondMatrix" $1 |awk -F"=" '{print $2}'`) 
   cp -f ./$FILE $MYSCR/
end
#   cp -f *.xyz $MYSCR/
   cp -f *.aux $MYSCR/
if(`grep -c -i amber $1` > 0) then
  cp -f *prmtop $MYSCR/
  #cp -f *inpcrd $MYSCR/
endif
cp -f $1 $MYSCR/

#Setting working directory
if($?PBS_O_WORKDIR) then
   setenv WORK $PBS_O_WORKDIR
   else
   setenv WORK `pwd`
endif

set BASE = ( `basename $1 .ogo`)
mkdir $BASE

cd $MYSCR

#Copy SKF files DFTB
if(`grep -c -i dftb $1` > 0) then
  module load dftb+/1.2.2-mpi
    foreach ATOM1 (H C N O S)
    foreach ATOM2 (H C N O S)
    ln -s /usr/local/Dist/dftb+/params/3ob-3-1/$ATOM1-$ATOM2.skf
    end
  end
  #cp -f $WORK/*.skf .
endif

#Copy basis sets and potentials for CP2k
if(`grep -c -i cp2k $1` > 0) then
 module load cp2k
 ln -s /usr/local/Dist/cp2k/2.5/tests/QS/BASIS_SET
 ln -s /usr/local/Dist/cp2k/2.5/tests/QS/POTENTIAL
endif

#Copy pseudopotentials for CPMD
if(`grep -c -i cpmd $1` > 0) then
  module load cpmd
  setenv FUNCTIONAL `grep -m 1 cpmd $1 | awk -F":" '{print toupper($2)}'`
  foreach ATOM (H C O N S)
     ln -s /usr/local/Dist/cpmd/vdb/$ATOM\_VDB_$FUNCTIONAL.psp
  end
endif

setenv OSTART_TIME `date`
setenv OGOLEM_VERSION $4
echo "Running Ogolem ($OGOLEM_VERSION) on " `hostname`
echo "Starting $OSTART_TIME "

onchange.sh rsync -avt $BASE/ master:$WORK/$BASE &
java -jar /home/btemelso/src/Ogolem/ogolem-snapshot-$4.jar --shmem $1 $2
setenv OEND_TIME `date`

#Print version, start and end time
echo "Ran Ogolem ($OGOLEM_VERSION) from" >> $BASE/$BASE.out
echo "$OSTART_TIME to" >> $BASE/$BASE.out
echo "$OEND_TIME" >> $BASE/$BASE.out

rsync -aru $BASE/ $WORK/$BASE

pkill onchange.sh
pkill inotifywait

#cp -r *.bin $WORK/
#cp -r j*[0-9] $WORK/
#rm -rf $WORK/$BASE-link

cd $WORK
rm -rf $MYSCR
