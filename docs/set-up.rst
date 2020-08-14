Set Up
------

Open a terminal on your local computer and connect to Marcy or Skylight using your MERCURY account.

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

.. toctree::

