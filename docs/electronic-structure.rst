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
command line environment. Generally, one would create a submit script which contains these
commands and submit them to the queue using a ``.pbs`` file on Marcy and a ``.slurm`` file
on Skylight.

The Submit Script
=================
A template submit script can be found in ``/home/software_test/orca`` and can be used
as a starting point for setting up new calculations. On Marcy, the PBS submit script
``orca.pbs`` is

.. code-block:: bash
   :caption: orca.pbs

    #
    # ORCA 4.2.1 PBS Submit Script
    #
    # Usage: edit the following:
    #
    #        _MEMORY_               : RAM. Adequate RAM must be provided.
    #        _NUMBER_OF_PROCESSORS_ : number of processors.
    #        _WALLTIME_             : maximum walltime.
    #        _INPUT_                : the name of the ORCA input file without the '.inp' suffix
    #
    
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

Skylight information under construction.

The ORCA Input File
===================
Template input files for CCSD(T)-F12, DLPNO-CCSD(T)-F12, and RI-MP2-F12 methods can be found in
``/home/software_test/orca``. Regardless of the computational method, all input files have the following
general structure:

.. code-block:: none
   :caption: template.inp
   
   #
   # Example ORCA 4.2.1 input file for _METHOD_/_BASIS_ calculations
   #
   # Usage: edit the following terms:
   #
   #        _X_                    : basis set. Can be D, T, Q, or 5.
   #        _NUMBER_OF_PROCESSORS_ : number of processors. 16 is recommended.
   #        _ATOMIC_COORDINATES_   : xyz coordinates of the system
   
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
   :caption: dlpno-ccsdt-avxz.inp

   ! DLPNO-CCSD(T) aug-cc-pV_X_Z aug-cc-pV_X_Z/C VeryTightSCF

.. code-block:: none
   :caption: dlpno-ccsdt-f12-vxz.inp

   ! DLPNO-CCSD(T)-F12 cc-pV_X_Z-F12 cc-pV_X_Z-F12-CABS cc-pV_X_Z/C VeryTightSCF

.. code-block:: none
   :caption: ri-mp2-f12-vxz.inp

   ! F12-RI-MP2 cc-pV_X_Z-F12 cc-pV_X_Z-F12-CABS cc-pV_X_Z/C VeryTightSCF

where ``_x_`` is defined by the user.
