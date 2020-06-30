#!/bin/tcsh
# The script uses Serguei Patchkovskii's symmetry analyzer to find the symmetry elements of a molecule
#
# *  Brute force symmetry analyzer.
# *  This is actually C++ program, masquerading as a C one!
# *
# *  (C) 1996, 2003 S. Patchkovskii, Serguei.Patchkovskii@sympatico.ca
#
# The code named 'symmetry.c' is included. You can compile it with a GNU gcc compiler
#  'gcc -o symmetry symmetry.c'
#
#     You may see a lot of warnings, especially if you are using more recent versions of gcc.
#
# Given Cartesian coordinates for a molecule, it calculates its symmetry elements and the Abelian
# symmetry group it belongs in
#
# Usage: ./symmetry XYZfile.xyz
#    Eg: ./symmetry test.xyz
#

setenv SCRIPTS_HOME /usr/local/sbin/aerosols

head -1 $1 > /tmp/$USER-symm.xyz
obabel -ixyz $1 -ozin | grep -v "[a-zA-Z]" | grep "[.]" | awk '{if(NF==4) {printf "%4d  %10f  %10f  %10f\n", $4, $1, $2, $3} }' >> /tmp/$USER-symm.xyz
$SCRIPTS_HOME/symmetry /tmp/$USER-symm.xyz
rm -f /tmp/$USER-symm.xyz
