Genetic Algorithm-Based Configurational Sampling
------------------------------------------------

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
   :caption: /home/username/gly-h2o/GA/h2o.xyz

   3
   
   O          0.00000        0.00000        0.11536
   H         -0.00000        0.76308       -0.46145
   H         -0.00000       -0.76308       -0.46145

Copy and paste the following into a file called ``gly.xyz``:

.. code-block:: none
   :caption: /home/username/gly-h2o/GA/gly.xyz
   
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
be found in the `OGOLEM manual <https://www.ogolem.org/manual/>`_. For this tutorial, we will
use a pool size of 100 configurations and run the genetic algorithm for 20,000 iterations.

Copy and paste the following into a file called ``gly-h2o.ogo``:

.. code-block:: none
   :caption: :caption: /home/username/gly-h2o/GA/gly-h2o.ogo

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
   PoolSize=100
   MaxIterLocOpt=100
   NumberOfGlobIterations=20000
   BlowBondDetect=1.4
   BlowInitialBonds=1.4
   BlowFacDissoc=2.5
   InitialFillAlgo=2
   GrowCell=true
   DiversityCheck=fitnessbased:0.00001

Finally, a submit script is required to run the calculation. This file describes the
requested resources and contains shell commands to run the configurational sampling calculation.
Since Marcy and Skylight operate different queueing systems (PBS on Marcy and SLURM on Skylight),
instructions for both clusters are provided below.

On Marcy, create a file called ``ogolem.pbs`` with the following contents:

.. code-block:: bash
   :caption: /home/username/gly-h2o/ogolem.pbs

   #!/bin/tcsh
   #PBS -q mercury
   #PBS -l nodes=1:ppn=16
   #PBS -l mem=30gb
   #PBS -l walltime=48:00:00
   #PBS -j oe
   #PBS -V
   
   setenv FILE gly-h2o          # assign the OGOLEM input file name to $FILE
   
   source ~/.login              # load default user environment
   set echo                     # toggle printing
   
   run-ogolem.csh $FILE.ogo 16  # run the OGOLEM calculation

On Skylight, create a file called ``ogolem.slurm`` with the following contents:

.. code-block:: bash
   :caption: /home/username/gly-h2o/ogolem.slurm

   #!/bin/tcsh
   #SBATCH -p stdmem
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=20
   #SBATCH --mem=48G
   #SBATCH -t 48:00:00
   #SBATCH --export=ALL
   
   setenv FILE gly-h2o          # assign OGOLEM input file name to $FILE
   
   source ~/.login              # load default user environment
   set echo                     # toggle printing
   
   run-ogolem.csh $FILE.ogo 20  # run the OGOLEM calculation

The submit scripts have been written to use the optimal resources for each cluster, so the
number of processors and memory requests are different between the ``.pbs`` and ``.slurm``
files. We finally have all the required files.

.. code-block:: bash

   $ ls
   gly-h2o.ogo  gly.xyz  h2o.xyz  ogolem.slurm

Submit the calculation to the queue and wait for its completion.

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

Change directory to the output folder and call the ``getRotConsts-GA.csh`` script.

.. code-block:: bash

   $ cd gly-h2o
   $ getRotConsts-GA.csh 13 0 99

This generates an output file called ``rotConstsData_C`` containing a list of the rotational
constants of each configuration sorted according to their energies. Finally, generate a
list of unique configurations.

.. code-block:: bash

   $ similarityAnalysis.py pm7 rotConstsData_C

This generates an output file called ``uniqueStructures-pm7.data`` containing the unique
configurations found at the PM7 semiempirical level of theory.

.. toctree::

