#!/bin/tcsh

#SBATCH -p __QUEUE__
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
#SBATCH --mem=26g
#SBATCH --export=all
#SBATCH -t 48:00:00
#SBATCH -J __NAME__
#SBATCH -o __NAME__.o%j

source ~/.login
set echo

module load gaussian/g16-B01
setenv GAUSS_SCRDIR /scratch/${GROUP}/${USER}

