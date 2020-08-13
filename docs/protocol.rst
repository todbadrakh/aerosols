========
Protocol
========

The best way to describe the protocol in detail is to work through an example case. Therefore,
we will use singly-hydrated glycine as our working example and determine the concentrations and
geometries of the most common singly-hydrated glycine clusters in the atmosphere.

0. Set Up
---------
Open a terminal on your local computer and connect to Skylight using your username.

.. code-block:: bash
   
   $ ssh username@skylight.furman.edu

Set up a working directory called ``gly-h2o``, change directory to ``gly-h2o``, and create the
required working directories.

.. code-block:: bash

   $ mkdir gly-h2o
   $ cd gly-h2o
   $ mkdir -p GA QM QM/m08hx-sb QM/m08hx-mg3s QM/m08hx-mg3s/ultrafine
   $ tree .
   .
   ├── GA
   └── QM
       ├── m08hx-mg3s
       │   └── ultrafine
       └── m08hx-sb
   
   5 directories, 0 files
   $

1. Genetic Algorithm-Based Configurational Sampling
---------------------------------------------------
The goal here is to obtain a list of configurations, and their associated ``.xyz`` files. To
do this, we must first obtain the optimized geometries of the water molecule and the glycine
molecule.

Change directory to the genetic algorithm directory.

.. code-block:: bash

   $ pwd
   /home/username/gly-h2o
   $ cd GA
   $ pwd
   /home/username/gly-h2o/GA

This calculation requires the geometry of each molecular species (monomer) in ``.xyz`` format.
Generally, one would optimize each monomer geometry in a separate preparatory step; however,
we will provide optimized geometries for this tutorial.

Copy and paste the following into a file called ``h2o.xyz``:

.. code-block:: none

   3
   
   O          0.00000        0.00000        0.11536
   H         -0.00000        0.76308       -0.46145
   H         -0.00000       -0.76308       -0.46145

Copy and paste the following into a file called ``gly.xyz``:

.. code-block:: none
   
   10
   
   O          1.64695       -0.64686       -0.00003
   O          0.56490        1.30640       -0.00001
   N         -1.95271        0.01325       -0.00003
   C         -0.72105       -0.73514        0.00002
   C          0.53881        0.10923        0.00009
   H         -0.67599       -1.39711       -0.87200
   H         -0.67606       -1.39712        0.87203
   H         -1.99594        0.62049       -0.80956
   H         -1.99601        0.62047        0.80951
   H          2.41159       -0.06038       -0.00008

This calculation also requires an input file for OGOLEM in ``.ogo`` format. This file describes
the parameters of the configurational sampling run. Detailed descriptions of the input file can
be found in the `OGOLEM manual <https://www.ogolem.org/manual/>`_. 

Copy and paste the following into a file called ``gly-h2o.ogo``:

.. code-block:: none

   ###OGOLEM###
   <GEOMETRY>
   NumberOfParticles=2
   <MOLECULE>
   MoleculePath=gly.xyz
   MoleculeRepetitions=1
   </MOLECULE>
   <MOLECULE>
   MoleculePath=h2o.xyz
   MoleculeRepetitions=1
   </MOLECULE>
   <CHARGES>
   0;0;0
   1;0;0
   </CHARGES>
   </GEOMETRY>
   LocOptAlgo=mopac:pm7
   PoolSize=10
   MaxIterLocOpt=100
   NumberOfGlobIterations=20000
   BlowBondDetect=1.4
   BlowInitialBonds=1.4
   BlowFacDissoc=2.5
   InitialFillAlgo=2
   GrowCell=true
   DiversityCheck=fitnessbased:0.00001

Finally, a SLURM submit script is required to run the calculation. This file describes the
requested resources and contains shell commands to run the configurational sampling calculation.

Copy and paste the following into a file called ``ogolem.slurm``:

.. code-block:: none

   #SBATCH -p stdmem
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=20
   #SBATCH --mem=48G
   #SBATCH --export=ALL
   #SBATCH -t 24:00:00
   
   setenv FILE gly-h2o
   
   source ~/.login
   set echo
   
   run-ogolem.csh $FILE.ogo 20

We now have all the required files.

.. code-block:: bash

   $ ls
   gly-h2o.ogo  gly.xyz  h2o.xyz  ogolem.slurm

Finally, submit the calculation to the queue and wait for its completion.

.. code-block:: bash

   $ sbatch ogolem.slurm
   Submitted batch job ###

Once the job finishes, one will find a new directory containing ``.xyz`` files and two OGOLEM
output files and a SLURM output file. The lowest energy configurations of the cluster have
been identified at the semiempirical level of theory and their geometries have been saved in the
named ``rankXindividualY.xyz`` where ``X`` and ``Y`` are numbers. The lowest energy cluster has
``X = 0``. Now, our task is to consolidate these results into a form which can be used in the
next steps. To this end we will check for duplicate structures and generate a list of unique
structures based on their rotational constants.

Change direction to the output folder and call the ``getRotConsts-GA.csh`` script.

.. code-block:: bash

   $ cd gly-h2o
   $ getRotConsts-GA.csh 13 0 9

This generates an output file called ``rotConstsData_C`` containing a list of the rotational
constants of each configuration sorted according to their energies. Finally, generate a
list of unique configurations.

.. code-block:: bash

   $ similarityAnalysis.py pm7 rotConstsData_C

This generates an output file called ``uniqueStructures-pm7.data`` containing the unique
configurations found at the PM7 semiempirical level of theory.

2. Rough Quantum Mechanical Geometry Refinement
-----------------------------------------------

3. Detailed Quantum Mechanical Geometry Refinement
--------------------------------------------------

4. Calculation of Thermodynamic Quantities
------------------------------------------
