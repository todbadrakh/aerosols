#!/usr/bin/env python2.7

"""
Orignally named as 'moi.py' by (c) 2008 James Stroud (c) 2008

2010-2019 - Adapted for our purposes 

(c) 2008, James Stroud
This module is released under the GNU Public License 3.0.
See <http://www.gnu.org/licenses/gpl.html>.

A module to calculate rotational constants of a molecule 
given its Cartesian coordinates.
""" 

import sys
import math
import argparse
from textwrap import dedent
from ConfigParser import ConfigParser
from operator import mul
from numpy import linalg
from numpy import dot

PLANCK = 6.626068e-34
PLANCK_SQR = PLANCK**2
C = 2.99792458e8 
BOLTZ = 1.3806503e-23
NA = 6.022e23
SQRT_PI = math.sqrt(math.pi)
PI_SQR = math.pi**2

# please add other elements and their atomic weights here as necessary
elements = {
             'H': 1.00782503207,
             'D': 2.0141017778,
             'T': 3.0160492777,
             'C': 12.000000000,
             'C13': 13.0033548378,
             'N': 14.0067,
             'N15': 15.0001088989,
             'O': 15.9994,
             'O18': 17.9991596128,
             'F': 18.998403163, 
             'NE': 20.1797,
             'P': 30.9738,
             'S': 32.0650,
             'CL': 35.453,
           }

class Atom(object):
  def __init__(self, x, y, z, mass):
    self.x = float(x)
    self.y = float(y)
    self.z = float(z)
    self.mass = float(mass)
  def __str__(self):
    return "%s @ (%s, %s, %s)" % (self.x, self.y, self.z, self.mass)

class Point(object):
  def __init__(self, x, y, z):
    self.x = x
    self.y = y
    self.z = z
  def __str__(self):
    return "(%s, %s, %s)" % (self.x, self.y, self.z)

def read_xyz(filename):
  s = open(filename).readlines()
  atoms = []
  for aline in s[2:]:
    e, x, y, z = aline.upper().split()
    mass = elements[e.upper()]
    x = float(x)
    y = float(y)
    z = float(z)
    atom = Atom(x, y, z, mass)
    atoms.append(atom) 
  return atoms 

def readXYZLabels(filename):
  s = open(filename).readlines()
  return [k.split()[0].upper() for k in s[2:]]

def molecular_mass(sel):
  """
  Calculates the molecular mass 
  """
  mol_mass= sum(atom.mass for atom in sel)
  return mol_mass 

def com(sel):
  """
  Calculates the center of mass of a list of atoms.
  """
  m = sum(atom.mass for atom in sel)
  c = []
  for i in 'xyz':
    mr = []
    for atom in sel:
      mr.append(atom.mass * getattr(atom, i))
    c.append(sum(mr)/m)
  return Point(*c)

def dist(atom, ref=None):
  """
  Calculates distance between an Atom (or Point) and a ref.
  If ref is not given, then the origin is assumed.
  """
  if ref is None:
    d = math.sqrt(atom.x**2 + atom.y**2 + atom.z**2)
  else:
    x = atom.x - ref.x
    y = atom.y - ref.y
    z = atom.z - ref.z
    d = math.sqrt(x**2 + y**2 + z**2)
  return d

def kd(i, j):
  """
  The Kronaker delta.
  """
  return int(i==j)

def moi_element(i, j, sel, ref):
  """
  Generalized moment of inertia element--both diagonal and off
  diagonal. Coordinate axes i and j should be 'x', 'y', or 'z'.
  The sel argument is a list of Atoms.
  The ref arguemnt is a Point.
  """
  delta = kd(i, j)
  refi = getattr(ref, i)
  refj = getattr(ref, j)
  el = []
  for atom in sel:
    r2d = (dist(atom, ref)**2) * delta
    ri = getattr(atom, i) - refi
    rj = getattr(atom, j) - refj
    el.append(atom.mass*(r2d - ri*rj))
  return sum(el)

def tensor_moi(sel, ref=None):
  """
  Calculates the cartesian moment of inertia tensor.
  """
  if ref is None:
    ref = com(sel)
  indices = [(i,j) for i in 'xyz' for j in 'xyz']
  tensor = [moi_element(i, j, sel, ref) for (i,j) in indices]
  return [tensor[0:3], tensor[3:6], tensor[6:9]]

def rot_const(sel, ref=None):
  moi = tensor_moi(sel, ref)
  pmoi = linalg.eigvalsh(moi)*1.6605e-47
  return [PLANCK/(8*PI_SQR*pmoi[i]*1e9) for i in xrange(3)]

def eigenVectors(sel, ref=None):
  moi = tensor_moi(sel, ref)
  eigen_vectors = linalg.eig(moi)[1]
  return eigen_vectors

def main():

  description = """
  Input:
    xyzFile (e.g.  ./rot_consts.py coords.xyz)
  Output: 
    Rotational Constants (A, B, C) in GHz
  Options:
    -m prints only the molecular mass and exits
"""
  parser = argparse.ArgumentParser(
    description=description, formatter_class=argparse.RawDescriptionHelpFormatter, epilog=description)
  parser.add_argument('-m', '--printmass', action='store_true', help='Print the molecular mass.\
    The default is to only print rotational constants')
  parser.add_argument('xyzfile', metavar='coords.xyz', type=str)
  args = parser.parse_args()

  atoms = read_xyz(args.xyzfile)
  orig_coords = [[atoms[k].x, atoms[k].y, atoms[k].z] for k in range(len(atoms))]
  com_atoms = com(atoms)
  com_coords = [[orig_coords[k][0] - com_atoms.x, orig_coords[k][1] - com_atoms.y, orig_coords[k][2] - com_atoms.z] \
                 for k in range(len(orig_coords))]
  eigen_vectors = eigenVectors(atoms)
  new_coords = dot(com_coords, eigen_vectors)
  labels = readXYZLabels(args.xyzfile)
  name = args.xyzfile[:-4]

  B = rot_const(atoms)
  # Print rotational constants (A, B, C) in GHZ unit
  # If -m flag is give, print the mass as well as rotational constants
  if args.printmass:
    print 'MASS    %5.8f' % (molecular_mass(atoms))
    print 'GHZ     %5.8f\t%5.8f\t%5.8f' % (B[0], B[1], B[2])
  else: 
    print '%5.6f\t%5.6f\t%5.6f' % (B[0], B[1], B[2])

if __name__ == "__main__":
  main()
