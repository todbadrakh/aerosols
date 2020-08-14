Calculation of Thermodynamic Quantities
---------------------------------------
The goal of this step is to calculate the thermodynamic quantities required for calculating
the Gibbs free energy of formation of the low energy structures. To this end, we will
perform one final set of calculations which involve two steps. First, the geometries of the
structures in ``uniqueStructures-mg3s.data`` are further optimized to a tighter threshold.
This is important because vibrational energy calculations are sensitive to geometry and
require a highly-accurate structure for the results to be valid. The second step is to
calculate the vibrational energies of the clusters, which are used to calculate the
thermodynamic quantities ``dH`` and ``S``. These two steps have been combined into one
script.

At this point, you should be in the large-basis directory
``/home/username/gly-h2o/QM/m08hx-mg3s``. Copy the 
``uniqueStructures-mg3s.data`` file to the ultrafine calculation directory and change
directory to the that folder.

.. code-block:: bash
   
   $ cp uniqueStructures-mg3s.data ultrafine/.
   $ cd ultrafine

Now, use the ultrafine run script ``run-m08hx-mg3s-ultrafine.csh`` to submit the 
jobs. This script automatically reads the ``uniqueStructures-mg3s.data`` file and
generates a Gaussian 16 input file for each structure and submits the calculations to
the queue in batches.

On Marcy, submit the small-basis geometry optimizations to the mercury queue in batches of
10.

.. code-block:: bash

   $ run-m08hx-mg3s-ultrafine.csh uniqueStructures-sb.data uf mercury 10

On Skylight, submit the small-basis geometry optimizations to the stdmem queue in batches
of 10.

.. code-block:: bash

   $ run-m08hx-mg3s-ultrafine.csh uniqueStructures-sb.data uf stdmem 10

This will generate Gaussian 16 input files named ``gly-h2o-#-#-m08hx-uf.com``, which will
subsequently generate their associated output files named ``gly-h2o-#-#-m08hx-uf.log``. A set
of submit scripts are generated as ``run-#.pbs`` on Marcy and ``run-#.slurm`` on Skylight.

Once all jobs are completed, generate a list of rotational constants.

.. code-block:: bash

   $ getRotConsts-dft-lb-ultrafine.csh m08hx 13

This script takes the density functional (``m08hx``) and number of atoms (``13``) as input
and generates a file called ``rotConstsData_C``, which contains the rotational constants of
the clusters sorted according to their energies.

Now, screen for unique structures.

.. code-block:: bash

   $ similarityAnalysis.py uf rotConstsData_C

This script generates a file called ``uniqueStructures-uf.data`` which contains a list
of the unique structures and their rotational constants. This is our final list of the
lowest-energy clusters of hydrated glycine.

Perform the final thermodynamic calculations by using the ``run-thermo.csh`` script.

.. code-block:: bash

   $ run-thermo.csh uniqueStructures-uf.data

This script will print the thermodynamic quantities to the command line, which can be copied
and pasted into spreadsheets. The next step is to calculate the equilibrium concentrations
of the lowest-energy clusters under atmospherically-relevant conditions.

.. toctree::

