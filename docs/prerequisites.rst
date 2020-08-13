=============
Prerequisites
=============

This protocol is built around a collection of Linux shell scripts which handle the 
setup and submission of the necessary computations. The protocol therefore requires a 
particular directory structure to ensure that the shell scripts find the files they 
need. The shell scripts call on OGOLEM to carry out the configurational sampling 
step. The resulting set of cluster geometries are then refined using Gaussian 16. 
Finally, an in-house version of the THERMO script from NIST is used to compute and 
print the final thermodynamic data. For MERCURY HPC users, all prerequisites have
been met on the HPC cluster.

Directory Structure
-------------------
This protocol requires a specific directory structure for the scripts to work
properly. Given a particular working directory ``$DIR``, there should be a main
genetic algorithm directory called ``$DIR/GA`` and a main quantum mechanics directory
called ``$DIR/QM``. The ``$DIR/QM`` directory should contain the directories for small-basis
calculations ``$DIR/QM/m08hx-sb`` and for MG3S basis calculations ``$DIR/QM/m08hx-mg3s``.
Finally, the MG3S directory should contain a final frequency calculation directory called
``$DIR/QM/m08hx-mg3s/ultrafine``. The ``tree`` command can be used to check the directory
structure, which should produce the following output:

.. code-block:: bash

   $ cd $DIR
   $ tree .
   .
   ├── GA
   └── QM
       ├── m08hx-mg3s
       │   └── ultrafine
       └── m08hx-sb
   
   5 directories, 0 files

Programs
--------
`OGOLEM <https://www.ogolem.org>`_
    performs the genetic algorithm-based configurational sampling of gas
    phase molecular clusters and is configured to interface with MOPAC.

`MOPAC <https://openmopac.net>`_
    performs the local geometry optimizations of configurations generated
    by OGOLEM using the PM7 semiempirical method.

`Gaussian 16 <https://gaussian.com>`_
    performs the quantum mechanical geometry optimizations and final
    vibrational frequency calculations of configurations.

Shell Scripts
-------------
``run-ogolem.csh <input file> <number of processors>``
    starts an OGOLEM calculation when given a ``.ogo`` file.

``run-m08hx-sb.csh <input file> <job name> <queue> <number of jobs/batch>``
    starts a set of M08-HX/6-31+G* geometry optimizations when given a ``.data`` file.

``run-m08hx-mg3s.csh <input file> <job name> <queue> <number of jobs/batch>``
    starts a set of M08-HX/MG3S geometry optimizations when given a ``.data`` file.

``run-m08hx-mg3s-ultrafine.csh <input file> <job name> <queue> <number of jobs/batch>``
    starts a set of vibrational frequency calculations when given a ``.data`` file.

``getRotConsts-GA.csh <number of atoms> <min rank> <max rank>``
    generates a sorted list of rotational constants from OGOLEM output.

``getRotConsts-dft-sb.csh <functional> <number of atoms>``
    generates a sorted list of small basis DFT rotational constants from Gaussian 16 output.

``getRotConsts-dft-lb.csh <functional> <number of atoms>``
    generates a sorted list of large basis DFT rotational constants from Gaussian 16 output.

``getRotConsts-dft-lb-ultrafine.csh <functional> <number of atoms>``
    generates a sorted list of final DFT rotational constants from Gaussian 16 output.

``SimilarityAnalysis.py <tag> <input file>``
    generates a sorted list of unique structures from comparing energies and rotational 
    constants when given a ``rotConstsData_C`` file.

``run-thermo.sh <input file>``
    calculates and prints the formation energies of the cluster given a ``.data`` file.
