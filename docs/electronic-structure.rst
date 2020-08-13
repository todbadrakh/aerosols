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
commands and submit them to the queue: ``.pbs`` file on Marcy and ``.slurm`` file on Skylight.

The Submit Script
=================
A template submit script can be found in ``/home/software_test/orca`` and can be used
as a starting point for setting up new calculations.
