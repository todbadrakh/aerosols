==============================
High-Level Electronic Energies
==============================

The electronic energies used in calculating the Gibbs free energies of formation of gas
phase molecular clusters can be computed at much higher levels of theory compared to
density-functional theory. In particular, explicitly-correlated, correlation-corrected
wavefunction-based methods such as
`CCSD(T)-F12 <https://pubs.rsc.org/en/content/articlelanding/2008/CP/b803704n#!divAbstract>`_
can be employed. These methods are computationally very costly and scale poorly with system
size due to the many mathematical operations involved in solving the Schrodinger equation.
Various mathematical tricks have been employed to reduce the computational cost of these
calculation, resulting in methods such as RI-MP2-F12 and DLPNO-CCSD(T)-F12. Detailed
information can be found
`here <https://pubs-rsc-org.libproxy.furman.edu/en/content/articlelanding/2008/CP/b808067b#!divAbstract>`_.
These methods are implemented in ORCA 4.2.1 and are available on Marcy and Skylight.

The ORCA Module
===============
ORCA 4.2.1 is implemented as an `envorinmental module <http://modules.sourceforge.net/>`_
on Marcy and Skylight. In order to use ORCA 4.2.1, load the module with the command::

    module load orca/4.2.1

Now, the program ``orca`` and run script ``run-orca-4.2.1.csh`` are available in your
command line environment. Generally, one would create a submit script in the form of a
``.pbs`` file on Marcy and a ``.slurm`` file on Skylight containing instructions which
use the ``orca`` and ``run-orca-4.2.1.csh`` program and script.

The Submit Script
=================
A template submit script can be found in ``/home/software_test/orca`` and can be used
as a starting point for setting up new calculations. On Marcy, the PBS submit script
``orca.pbs`` is

.. code-block:: bash
   :caption: /home/software_test/orca/orca.pbs

   #!/bin/tcsh   
   #PBS -q mercury
   #PBS -l nodes=1:ppn=_NUMBER_OF_PROCESSORS_
   #PBS -l mem=_MEMORY_
   #PBS -l walltime=_WALLTIME_
   #PBS -j oe
   #PBS -e _INPUT_
   #PBS -N _INPUT_
   #PBS -V
   
   setenv FILE _INPUT_
   
   source ~/.login                     # loading default user environment
   set echo                            # toggle printing
   module purge                        # clear environment modules
   module load orca/4.2.1              # load ORCA 4.2.1
   cd $PBS_O_WORKDIR                   # go to working/submit directory
   
   run-orca-4.2.1.csh $FILE $PBS_JOBID # run ORCA 4.2.1 using the input file $FILE and scratch directory $PBS_JOBID

where ``_MEMORY_``, ``_NUMBER_OF_PROCESSORS_``, ``_WALLTIME_``, and ``_INPUT_`` are defined
by the user. Note that ``_NUMBER_OF_PROCESSORS_`` must match the ``nproc`` parameter in the ORCA input
file.

On Skylight, the SLURM submit script ``orca.slurm`` is

.. code-block:: bash
   :caption: /home/software_test/orca/orca.slurm

   #SBATCH -p stdmem
   #SBATCH --nodes=1
   #SBATCH --ntasks-per-node=_NUMBER_OF_PROCESSORS_
   #SBATCH --mem=_MEMORY_
   #SBATCH -t _WALLTIME_
   #SBATCH --export=ALL
   
   setenv FILE _INPUT_
   
   source ~/.login                     # loading default user environment
   set echo                            # toggle printing
   module purge                        # clear environment modules
   module load orca/4.2.1              # load ORCA 4.2.1
   cd $SLURM_SUBMIT_DIR                # go to working/submit directory
   
   run-orca-4.2.1.csh $FILE $SLURM_JOBID # run ORCA 4.2.1 using the input file $FILE and scratch directory $PBS_JOBID

The ORCA Input File
===================
Template input files for CCSD(T)-F12, DLPNO-CCSD(T)-F12, and RI-MP2-F12 methods can be found in
``/home/software_test/orca``. Regardless of the computational method, all input files have the following
general structure:

.. code-block:: none
   :caption: /home/software_test/orca/template.inp
   
   ! _METHOD_ _BASIS_ VeryTightSCF
      
   %pal
     nproc _NUMBER_OF_PROCESSORS_
   end
   
   * xyz 0 1
   _ATOMIC_COORDINATES_
   *

where ``_METHOD_``, ``_BASIS_``, ``_NUMBER_OF_PROCESSORS_``, and ``_ATOMIC_COORDINATES_`` are defined by
the user. The unique lines of each template input file are as follows:

.. code-block:: none
   :caption: /home/software_test/orca/dlpno-ccsdt-avxz.inp

   ! DLPNO-CCSD(T) aug-cc-pV_X_Z aug-cc-pV_X_Z/C VeryTightSCF

.. code-block:: none
   :caption: /home/software_test/orca/dlpno-ccsdt-f12-vxz.inp

   ! DLPNO-CCSD(T)-F12 cc-pV_X_Z-F12 cc-pV_X_Z-F12-CABS cc-pV_X_Z/C VeryTightSCF

.. code-block:: none
   :caption: /home/software_test/orca/ri-mp2-f12-vxz.inp

   ! F12-RI-MP2 cc-pV_X_Z-F12 cc-pV_X_Z-F12-CABS cc-pV_X_Z/C VeryTightSCF

where ``_x_`` is defined by the user.

An Example Calculation
======================
Let us calculate the energy of water at the DLPNO-CCSD(T)-F12/cc-pVTZ-F12 level of theory as an exercise. First,
log into Marcy, create a working directory called ``orca-example`` and change directory to the new folder.

.. code-block:: bash
   
   $ ssh username@marcy.furman.edu
   Last login: Thu Aug 13 13:05:36 2020 from 10.101.80.1
           +-+-+-+-+-+-+-+-+-+-+-+-+-++-+-+-+-+-+-+-+-+-+-+
           |    |M|A|R|C|Y| @       MERCURY Consortium    |
         	+-+-+-+-+-+-+-++-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
   Ganglia - 	http://marcy.furman.edu/ganglia/
   WebMO - 	http://marcy.furman.edu/webmo.html	(mercuryuser:marcy)
   
   UPDATES:
    
   02/08/15 - NEW queue rules are implemented
     See http://marcy.furman.edu/wiki/doku.php/start?&#running_calculations for details
     If you submit to the 'mercury' queue requesting the necessary resources
     (walltime=x:x:x, nodes=x:ppn=x, mem=xGB), the job will be routed to the best queue.
   
   08/15/14 - Example runs and benchmarks are compiled at ~software_test
   	   or online at http://marcy.furman.edu/~software_test
   
   Send any support requests to support@mercuryconsortium.org
   $ mkdir orca-example
   $ cd orca-example
   $ pwd
   /home/username/orca-example

Now, create an input file for the calculation called ``example.inp`` with the following contents:

.. code-block:: none
   :caption: example.inp

   ! DLPNO-CCSD(T)-F12 cc-pVTZ-F12 cc-pVTZ-F12-CABS cc-pVTZ/C VeryTightSCF PModel
   
   %pal
     nproc 4
   end

   * xyz 0 1
     O  0.000000000  0.000000000  0.369372944
     H  0.783975899  0.000000000 -0.184686472
     H -0.783975899  0.000000000 -0.184686472
   *

This input file requests a DLPNO-CCSD(T)-F12/cc-pVTZ-F12 single point calculation using the
cc-pVTZ-F12-CABS and cc-pVTZ/C auxiliary basis sets and 4 CPUs. Now we need a PBS submit script to
actually run the calculation.

Create a submit script called ``example.pbs`` with the following contents:

.. code-block:: none
   :caption: example.pbs

   #!/bin/tcsh
   #PBS -q mercury
   #PBS -l mem=8gb
   #PBS -l nodes=1:ppn=4
   #PBS -l walltime=2:00:00
   #PBS -j oe
   #PBS -e example
   #PBS -N example
   #PBS -V
   
   setenv FILE example
   
   source ~/.login
   set echo
   module purge
   module load orca/4.2.1
   cd $PBS_O_WORKDIR
   
   run-orca-4.2.1.csh $FILE $PBS_JOBID

This script requests 4 CPUs and 8GB RAM for 2:00:00 hours for a job named ``example``. Now submit
the calculation using the ``qsub`` command.

.. code-block:: bash

   $ qsub example.pbs

This calculation will complete quickly because water is a small molecule and generate an output file
called ``example.out``. The final electronic energy can be extracted with a ``grep`` command:

.. code-block:: bash
   
   $ grep 'FINAL SINGLE POINT ENERGY' example.out
   example.out:FINAL SINGLE POINT ENERGY       -76.367027678417

Thus, the final result tells us that the electronic energy of water is -76.367027678417 Ha at the
DLPNO-CCSD(T)-F12/cc-pVTZ-F12 level of theory.

.. toctree::
   :caption: aerosols Manual

