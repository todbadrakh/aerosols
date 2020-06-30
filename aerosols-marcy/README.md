# Changes

## Scripts

- `g09E`
  - renamed as `gaussianE.csh`
  - updated scripts referring to 'g09E' to the new name
- `g09_freqs`
  - renamed as `gaussianFreqs.csh`
   - updated scripts referring to 'gaussianFreqs.csh' with the proper name
- `getRotConsts2-GA.csh`
  - renamed `getRotConsts-GA.csh`
- `getRotConsts2-dft-sb.csh`
  - renamed `getRotConsts-dft-sb.csh`
- `getRotConsts2-dft-lb.csh`
  - renamed `getRotConsts-dft-lb.csh`
- `similarityAnalysis3.py`
  - renamed `similarityAnalysis.py`  
- `getRotConsts2-dft-lb-ul.csh`
  - renamed `getRotConsts-dft-lb-ul.csh`
- I would suggest using the Python `rot_consts.py` script as opposed to C version (`getrotconsts`) because
  - the current dynamically-linked version won't work on any other computer without re-compilation or providing a path to Intel MKL libraries
  - I've replaced it with a statically-linked version that should presumably work on any Linux system without recompilation, but it is 14MB compared to just 294KB for the dynamically-linked version
  - if users choose to compile the `getrotconsts` C code, we can provide them with a code and Makefile. They would need to update the path to Intel MKL libraries.
  - The Python version should work out of the box for most people. We can give users the option of getting the much faster C version if they
choose to. Or we could put it on GitHub.
  - Python version will be substantially slower, but it will at least work for everyone.
- `moi.py`
  - removed `moi.py` since all its functionality is already in `rot_const.py`
  - references to `moi.py` replaced with `calcRotConsts.py -m`
- `rot_consts.py`
  - cleaned up only its essential parts
  - renamed as `calcRotConsts.py` for clarity
- `symmetry.c`
  - added code for `symmetry.c`
  - it can be complied using `gcc -o symmetry symmetry.c`
  - updated the code for `getsymmetry.csh`
- `getsymmetry.csh`
  - renamed as `calcSymmetry.csh`
- `make-thermo-g09.csh`
  - renamed `make-thermo-gaussian.csh`
  - updated to use 'rot_consts.py' to calculate rotational constants
  - updated to not print dSvib, dHvib
  - updated to print the electronic energy only once
- `runogolem-versioned.csh`
  - renamed `runogolem.csh`
- added `combine-GA.csh`
- added `combine-QM.csh`
- added $SCRIPTS_HOME environmental variable to all tcsh scripts so that users can replace it with the permanent location of the scripts and run it from anywhere

## Tables
- tables
  - tables 1-3 updated
    - 'sheet1' removed and replaced with 'sheet2'
    - Extra energies removed, as well as ∆Svib and ∆Hvib values
  - table-4
    - I updated the ∆H and ∆G numbers, but the hydrate populations don't change
    - please check the table
    - I've added my hydration data in 'sheet2' for comparison

## Figures    
- figures
  - figure-1.eps - converted to ".eps"
  - figure-2 - I don't have a copy (it may note be necessary -- perhaps replace with a schema or something). Someone can generate a hi-res version if they want to include it.
  - figure-3.eps - updated with a new eps figure of minima
  - added figure-4.eps -- showing the hydrate population

## Suggestions
- I would suggest
  - submitting the coordinates of the global minimum structures in a file `global-minimum-coords.xyz`
  - adding a document with clarifications/README ( ***see below*** ) to help users who want to use the protocol for their own project  

## Will do
- update the protocol part of the manuscript with the new scripts
- upload all the new files

## Need
- I need Togo to look at Table 4 and make sure it can provide the right hydrate distribution given ∆G(T). I have included data generated using my Mathematica script in 'sheet2' of Table 4.

## Still remaining
- editorial changes the editor suggested
- incorporating


# Clarifications/README
- The scripts assume all the data they will operate on is located in the same directory. To access them from anywhere,
  - move the whole directory with the scripts to somewhere that is in your $PATH
  - in each tcsh script (`*.csh`), update `setenv SCRIPTS_HOME pwd` to `setenv SCRIPTS_HOME __LOCATION_OF_SCRIPTS__`
- The scripts have been used on the following operating systems
  - CentOS 6/7, although they should work on most GNU Linux systems
  - Mac OS X 10.10+, assuming it has XCode and most Linux utilities
- The scripts assume you will be running them on an HPC system using
  - PBS batch queuing system
  - all the scripts and necessary software are accessible to the compute nodes via a shared filesystem
- The scripts assume users have the following software
   - OpenBabel
      - only version 2.4.x was tested
   - tcsh shell
      - only version 6.18.x was tested
      - if the location of your 'tcsh' is different from `/bin/tcsh`, you would need to update the scripts with the proper path to 'tcsh'
   - Python
      - only versions 2.6 and 2.7 were tested  
   - Gaussian 09 or 16
      - g09rev[B,D] and g16rev[A-B] were tested
   - Ogolem
      - only the "classic" (x - 2016) version is tested
      - requires Java
   - all packages that interface with Ogolem need to be available. For example,
      - MOPAC to run PM7
      - Orca to run hf3c
      - DFTBplus to run scc-dftb
      - paths to the locations of all these packages need to be specified in the `runogolem.csh` script   
- To calculate the symmetry of molecules, one would likely need to compile the attached '`symmetry.c`' file by entering '`gcc -o symmetry symmetry.c`'. Since the code was written in 2003, you may get a lot of warning messages if you compile it using recent versions of GNU gcc.
- Rotational constants are calculated using the '`rot_conts.py`' script.
  - if your molecule has elements aside from the 10 or so first and second row elements included in the script, you would need to add the atom and its atomic mass in the script.
  - this Python script is slow for processing a large number of files. If users want to compile a much faster C version, they can ask the authors for a more efficient C code.
- The scripts write intermediate data to /tmp assuming it exists and that the user has permission to write to files in that directory. If that is not the case, please change '/tmp' to a a location you have write permissions to.  
