Rough Quantum Mechanical Geometry Refinement
--------------------------------------------
The goal of this step is to refine the geometries of the configurations identified by
the configurational sampling method. This is necessary because the configurational
sampling step uses energies calculated at the semiempirical level and generates a 
large number of configurations. So, we will
further optimize the geometries of the configurations at the M08-HX/6-31+G* level of
theory. This is a density functional theory (DFT) method is more accurate than the
semiempirical method but is computationally more demanding. The 6-31+G* basis set,
refered to simply as 'small-basis' in our group, is a relatively small basis set and
ensures a reasonable balance between accuracy and computational cost.

At this point, you should be in the output folder inside the "genetic algorithm"
directory ``/home/username/gly-h2o/GA/gly-h2o``. Copy the 
``uniqueStructures-pm7.data`` file to the small-basis calculation directory and change
directory to the small-basis folder.

.. code-block:: bash
   
   $ cp uniqueStructures-pm7.data /home/username/gly-h2o/QM/m08hx-sb/.
   $ cd ../../QM/m08hx-sb

Now, use small-basis run script ``run-m08hx-sb.csh`` to submit the geometry optimization
jobs. This script automatically reads the ``uniqueStructures-pm7.data`` file and
generates a Gaussian 16 input file for each structure and submits the calculations to
the queue in batches.

On Marcy, submit the small-basis geometry optimizations to the mercury queue in batches of
10.

.. code-block:: bash

   $ run-m08hx-sb.csh uniqueStructures-pm7.data sb mercury 10

On Skylight, submit the small-basis geometry optimizations to the stdmem queue in batches
of 10.

.. code-block:: bash

   $ run-m08hx-sb.csh uniqueStructures-pm7.data sb stdmem 10

This will generate Gaussian 16 input files named ``gly-h2o-#-#-m08hx-sb.com``, which will
subsequently generate their associated output files named ``gly-h2o-#-#-m08hx-sb.log``. A set
of submit scripts are generated as ``run-#.pbs`` on Marcy and ``run-#.slurm`` on Skylight.

Once all jobs are completed, generate a list of rotational constants.

.. code-block:: bash

   $ getRotConsts-dft-sb.csh m08hx 13

This script takes the density functional (``m08hx``) and number of atoms (``13``) as input
and generates a file called ``rotConstsData_C``, which contains the rotational constants of
the clusters sorted according to their energies.

Now, screen for unique structures.

.. code-block:: bash

   $ similarityAnalysis.py sb rotConstsData_C

This script generates a file called ``uniqueStructures-sb.data`` which contains a list
of the unique structures and their rotational constants.

.. toctree::

