Welcome to aerosols's documentation!
====================================

This page describes the computational methodology used in the Shields Lab to compute 
the thermodynamic properties of atmospheric prenucleation clusters, which are the 
precursors to atmospheric aerosols. A recent review on the topic can be found in 
Leonardi, A. IJQC 2020. A detailed description of the process of identifying candidate 
prenucleation clusters can be found in Odbadrakh, T. T. JoVE 2020. Here, we present a 
step-by-step application of our methodology as implemented on the MERCURY Consortium's
HPC clusters.

Methodology
-----------
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

Software Requirements
---------------------
This protocol is built around a collection of Linux shell scripts which handle the 
setup and submission of the necessary computations. The protocol also requires a 
particular directory structure to ensure that the shell scripts find the files they 
need. The shell scripts call on OGOLEM to carry out the configurational sampling 
step. The resulting set of cluster geometries are then refined using Gaussian 16. 
Finally, an in-house version of the THERMO script from NIST is used to compute and 
print the final thermodynamic data.


