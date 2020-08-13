.. aerosols documentation master file, created by
   sphinx-quickstart on Wed Aug 12 21:31:24 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Introduction
============

This page describes the computational methodology used in the 
`Shields <https://www.furman.edu/people/george-c-shields>`_ Lab to compute 
the thermodynamic properties of atmospheric prenucleation clusters, which are the 
precursors to atmospheric aerosols. A recent review on the topic can be found in 
`Leonardi, A. IJQC 2020 <https://onlinelibrary.wiley.com/doi/full/10.1002/qua.26350>`_.
A detailed description of the process of identifying candidate 
prenucleation clusters can be found in
`Odbadrakh, T. T. JoVE 2020
<https://www.jove.com/t/60964/computation-atmospheric-concentrations-molecular-clusters-from-ab>`_.
Here, we present a step-by-step application of our methodology as implemented on the 
`MERCURY Consortium <https://mercuryconsortium.org>`_'s high-performance computing (HPC) clusters.

Our ultimate goal is to compute the Gibbs free energy change associated with the 
formation of gas-phase molecular clusters. This information can be used to calculate 
how much of a particular molecule ends up suspended in the atmosphere as aerosols. 
In order to calculate the energy of a cluster, we need to know its geometry. The 
process of identifying the stable geometries of a cluster is called configurational 
sampling and is the first step of our methodology. We will use a genetic 
algorithm-based configurational sampling (GA) method. The set of cluster geometries 
identified through the GA method will then be refined through a series of screening 
calculations, resulting in a final set of low-energy clusters which represent the 
possible shapes/geometries of the given molecular clusters that we can expect our 
cluster to naturally be in. Finally, the thermodynamic properties of this set of 
possible clusters are calculated at a high level of accuracy to produce meaningful 
data.

Prerequisites
=============

This protocol is built around a collection of Linux shell scripts which handle the 
setup and submission of the necessary computations. The protocol also requires a 
particular directory structure to ensure that the shell scripts find the files they 
need. The shell scripts call on OGOLEM to carry out the configurational sampling 
step. The resulting set of cluster geometries are then refined using Gaussian 16. 
Finally, an in-house version of the THERMO script from NIST is used to compute and 
print the final thermodynamic data.

Directory Structure
-------------------
This protocol requires a specific directory structure for the scripts to work
properly. Given a particular working directory ``$DIR``, there should be a main
genetic algorithm directory called ``$DIR/GA`` and a main quantum mechanics directory
called ``$DIR/QM``. The ``$DIR/QM`` directory should contain the directories for small-basis
calculations ``$DIR/QM/m08hx-sb`` and for MG3S basis calculations ``$DIR/QM/m08hx-mg3s``.
Finally, the MG3S directory should contain a final frequency calculation directory called
``$DIR/QM/m08hx-mg3s/ultrafine``. The ``tree`` command can be used to check the directory
structure, which should produce the following output::

   .
   ├── GA
   └── QM
       ├── m08hx-mg3s
       │   └── ultrafine
       └── m08hx-sb

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

Custom Scripts
--------------
``run-ogolem.csh``
    starts an OGOLEM calculation when given a .ogo file.

``run-m08hx-sb.csh``
    starts a set of M08-HX/6-31+G* geometry optimizations when given a .data file.

``run-m08hx-mg3s.csh``
    starts a set of M08-HX/MG3S geometry optimizations when given a .data file.

``run-m08hx-mg3s-ultrafine.csh``
    starts a set of vibrational frequency calculations when given a .data file.

``getRotConsts-GA.csh``
    generates a sorted list of rotational constants from OGOLEM output.

``getRotConsts-dft.csh``
    generates a sorted list of rotational constants from Gaussian 16 output.

``SimilarityAnalysis.py``
    generates a sorted list of unique structures from comparing energies and rotational 
    constants.

``run-thermo.sh``
    calculates and prints the formation energies of the cluster.

Protocol
========

The best way to describe the protocol in detail is to work through an example case. Therefore,
we will use singly-hydrated glycine as our working example and determine the concentrations and
geometries of the most common singly-hydrated glycine clusters in the atmosphere.

Step 1. Genetic Algorithm-Based Configurational Sampling
--------------------------------------------------------
The goal here is to obtain a list of configurations, and their associated ``.xyz`` files. To
do this, we must first obtain the optimized geometries of the 

Set up the required directories::

    mkdir -p GA QM QM/m08hx-sb QM/m08hx-mg3s QM/m08hx-mg3s/ultrafine

Step 2. Rough Quantum Mechanical Geometry Refinement
----------------------------------------------------

Step 3. Detailed Quantum Mechanical Geometry Refinement
-------------------------------------------------------

Step 4. Calculation of Thermodynamic Quantities
-----------------------------------------------
