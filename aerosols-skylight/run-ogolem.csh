#!/bin/tcsh

if ( $#argv != 2 ) then
   echo "Error in the number of arguments passed.\n"
   echo "Usage: run-ogolem.csh <input file> <number of processes>"
   echo "  Eg.: run-ogolem.csh input.ogo 16"
   exit
endif

source /usr/local/Modules/init/tcsh

module load openjdk/14.0.1 openmpi/3.1.4 orca/4.2.1 mopac/2016

setenv OGO_ORCACMD    /usr/local/Dist/orca/orca_4_2_1_linux_x86-64_shared_openmpi314
setenv OGO_MOPACCMD   /usr/local/Dist/mopac/2016/MOPAC2016.exe
setenv SCRATCH        /scratch/$GROUP/$USER/$SLURM_JOB_ID
setenv WORKDIR        `pwd`
setenv BASE           `basename $1 .ogo`

# create scratch directory
mkdir -p $SCRATCH

# move to scratch directory
cp *.ogo $SCRATCH/.
cp *.xyz $SCRATCH/.
cd $SCRATCH

# run ogolem
setenv OSTART_TIME `date`
setenv OGOLEM_VERSION $4
echo "Running Ogolem ($OGOLEM_VERSION) on " `hostname`
echo "Starting $OSTART_TIME "

java -jar /usr/local/Dist/ogolem/ogolem.jar --shmem $1 $2

setenv OEND_TIME `date`
echo "Ran Ogolem ($OGOLEM_VERSION) from" >> $BASE/$BASE.out
echo "$OSTART_TIME to" >> $BASE/$BASE.out
echo "$OEND_TIME" >> $BASE/$BASE.out

# move to work directory
rm -rf mopac*
cp -rf $SCRATCH/* $WORKDIR/.
rm -rf $SCRATCH
