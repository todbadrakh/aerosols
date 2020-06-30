#!/usr/bin/env python2.7

import sys
import math
import sets

def parseDataFile(file):
  f = open(file).readlines()
  data = []
  for i in f[1:]:
    line = i.split()
    data.append([line[0], line[2], line[3], line[4], line[5], line[6]])
  return data

def getData(rotConstsArray):
  data = []
  for i in rotConstsArray:
    data.append([float(i[1]), float(i[2]), float(i[3]), float(i[4]), float(i[5])])
  return data

def isSimilar(constsA, constsB, energyCutoff, rotCutoff):
  return abs(constsA[0] - constsB[0]) < energyCutoff and \
         abs((constsA[1] - constsB[1])/max(constsA[1], constsB[1])) < rotCutoff and \
         abs((constsA[2] - constsB[2])/max(constsA[2], constsB[2])) < rotCutoff and \
         abs((constsA[3] - constsB[3])/max(constsA[3], constsB[3])) < rotCutoff

def createSimilarityDict(dataArray, energyCutoff, rotCutoff):
  simDict = {}
  for i in range(len(dataArray)):
    simDict[i] = []
  for i in range(len(dataArray)):
    for j in range(i):
      if isSimilar(dataArray[i], dataArray[j], energyCutoff, rotCutoff):
        simDict[i] += [j]
        simDict[j] += [i]
  return simDict

def getUnique(simDict):
  uniqueList = []
  nonUniqueSet = sets.Set([])
  for i in range(len(simDict)):
    if i not in nonUniqueSet:
      uniqueList += [i]
      for j in simDict[i]:
        nonUniqueSet.add(j)
  return uniqueList

def writeSimDict(simDict):
  f = open('similarityChart', 'w')
  s = int(math.sqrt(len(simDict)))
  for i in range(len(simDict)):
    if i % s == 5:
      f.write('\n')
    f.write(str(i) + ': ' + str(simDict[i]) + '\t\t')
  f.write('\n')
  f.close()

def writeUniqueList(uniqueList, output):
  name = 'uniquelist' + '-' + output
  f = open(name, 'w')
  for i in range(len(uniqueList)):
    if i % 10 == 0:
      f.write('\n')
    f.write('%s' % (uniqueList[i][4:9]))
    f.write(' ')
  f.write('\n')
  f.close()

def writeUniqueStructures(uniqueList, fileArray, start, stop, output):
  name = 'uniqueStructures-' + output
  data = 'uniqueStructures-' + output + '.data'
  f = open(name, 'w')
  d = open(data, 'w')
  unique = len(uniqueList)
  '''
  if start < 0 or stop > unique or start > stop:
    print 'Index must be between 0 and ', unique
  else:
    for i in range(start, stop):
      f.write(str(fileArray[uniqueList[i]][0]))
      f.write('\n')
  f.close()
  '''
  print 'The number of unique structures is ', unique
  for i in range(start, unique):
    f.write(str(fileArray[uniqueList[i]][0]))
    f.write('\n')
  f.close()
  for i in range(start, unique):
    d.write(str(fileArray[uniqueList[i]][0]))
    d.write('\t')
    d.write(' : ')
    d.write('\t')
    d.write(str(fileArray[uniqueList[i]][1]))
    d.write('\t')
    d.write(str(fileArray[uniqueList[i]][2]))
    d.write('\t')
    d.write(str(fileArray[uniqueList[i]][3]))
    d.write('\t')
    d.write(str(fileArray[uniqueList[i]][4]))
    d.write('\t')
    d.write(str(fileArray[uniqueList[i]][5]))
    d.write('\n')
  d.close()

def main():
  largv = len(sys.argv)
  #print largv 
  if not (largv == 3 or largv == 5):
     print("Usage: similarityAnalysis3.py <TAG> <Rotational_Constants_File> [OPTIONS <energyCutoff> <rotCutoff>]")
     print("       where [OPTIONS] are ")
     print("                           energyCutoff (default=0.00015 a.u ~ 0.1 kcal/mol)")
     print("                           rotCutoff (default=0.010 or 1% )")
     print("   Eg: similarityAnalysis3.py pm7 rotConsts_C")
     print("   Eg: similarityAnalysis3.py pm7 rotConsts_C 0.0003 0.015 ")
     exit()

  output = sys.argv[1]
  rotConstsFile = sys.argv[2]
  try:
    energyCutoff = float(sys.argv[3])	#in a.u.
    rotCutoff = float(sys.argv[4])
  except:
    energyCutoff = 0.00015	#a.u or  0.10  kcal/mol
    rotCutoff = 0.010
  fileArray = parseDataFile(rotConstsFile)
  dataArray = getData(fileArray)
  simDict = createSimilarityDict(dataArray, energyCutoff, rotCutoff)
  #writeSimDict(simDict)
  uniqueList = getUnique(simDict)
  #writeUniqueList(uniqueList)
  try:
    a = int(sys.argv[5])
    b = int(sys.argv[6])
  except:
    a = 0
    b = len(uniqueList)
  writeUniqueStructures(uniqueList, fileArray, a, b, output)

if __name__ == '__main__':
  main()
