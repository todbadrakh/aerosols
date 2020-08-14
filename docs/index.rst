.. aerosols documentation master file, created by
   sphinx-quickstart on Wed Aug 12 21:31:24 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

======================
aerosols Documentation
======================

This document describes the computational methodology used in the 
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

.. toctree::
   :numbered:
   :caption: Contents

   prerequisites
   protocol
   electronic-structure
   
