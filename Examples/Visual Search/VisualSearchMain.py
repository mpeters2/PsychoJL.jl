#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Dec 31 16:33:39 2023

@author: MattPetersonsAccount
"""

print("\n----------------------------- NEW RUN ------------------------------\n")
from psychopy import visual, event, core, gui
import random
import numpy as np
import math
from dataclasses import dataclass
import time
#using SimpleDirectMediaLayer
#using SimpleDirectMediaLayer.LibSDL2
#using SDL2_ttf_jll
#using SDL2_gfx_jll

setSizes = [8, 16, 24]
targetPresences = 2
repetitions = 30


# I normally wouldn't write a Python experiment this way, but I'm trying
# to mimic the Julia version, which uses structs to get around using 
# global variables, which kill Julia's optimization.  We don't have structs
# in Python, so I'm mimicing structs by using an object class without methods
@dataclass
class ExperimentDesign:	 # we'll pass this around instead of globals
	numTrials: int
	trialSS = []		  # this holds the combination of SetSize control 
	trialTP = []		  # 
	randomOrder = []	  # this will hold the random order in which the trials will be displayed.


#-----
def main():
	global setSizes 				# global constants are kosher in Julia,  but not gloval variables.
	global targetPresences
	global repetitions

	getSubjectInfo()
	myWin = visual.Window( [1000,1000], fullscr = False, color=(-1, -1, -1) , units="height") #, blendMode='add')   color=(-1, -1, -1) (0, 0, 0)
	
	exp = makeExperimentalDesign(setSizes, targetPresences, repetitions)		# returns an ExperimentDesign struct

	#practice
	for t in range(50):
		doATrial(myWin, t, exp, False)
	
	print("done!")
	core.wait(2000)
	exit()

#-============================================================================
# We'll make the target an O among Q's
def doATrial(win, trialNum, trialInfo, realOrPractice = True):

	start = time.time()
	theTrial = trialInfo.randomOrder[trialNum]		# get our randomized trial number

	# (2) need to fill an array full of stimuli to display, deping on set size, target presence, etc.
	# 	make a list of distractors as orientatons 0-4 (90 degree).  Target will be coded as -1
	stimList = np.zeros(trialInfo.trialSS[theTrial])

	ori = 0												# distractor orientation
	for i in range(len(stimList)):
		stimList[i] = ori
		ori += 1
		if ori >= 4:
			ori = 0
		
	

	if trialInfo.trialTP[theTrial] == 1	:				# if the target is present
		stimList[1] = -1								# replace the first item in stimList with the target  (-1)
	
	# (3) need to randomly pick the locations
	locations = list(range(0, 100))							# these are in a 10 x 10 grid
	random.shuffle(locations)


	# (4) Premake the stimuli
	stimDrawList = []

	for i in range(len(stimList)):
		x = 50+((locations[i]%10)*100)						# 1000 x 1000, steps of 100
		y = 50+(math.floor(locations[i]/10)*100)						# 1000 x 1000, steps of 100
		x = (x/1000) - 0.5									# convert to Psychopy range of -1 to 1
		y = (y/1000) - 0.5
		if stimList[i] == -1:							# target
			ori = random.randint(1,2)
			if ori == 1:
				ori  = -90
			else:
				ori = +990
			
			tempStim = visual.TextStim(win,  "T", pos = [x, y], color = [1.0, 1.0, -1],  height = 1/24, ori = ori)	#height = 1/24,
			stimDrawList.append( tempStim)				# append it to stimDrawList
			print("target present",  theTrial)
		else:											# else it is a distractor
			tempStim = visual.TextStim(win,  "L", pos = [x, y], color = [1.0, 1.0, 1.0], height = 1/24, ori = math.floor( stimList[i] * 90) )
			stimDrawList.append( tempStim)				# append it to stimDrawList
		
	

	for s in stimDrawList:
		s.draw()
	
#	stop = time.time()
#	print("time taken =  ", stop - start)
	win.flip()
	stop = time.time()
	print("time taken =  ", stop - start)

	start = time.time()
	core.wait(0.285)
	stop = time.time()

	win.flip()

	core.wait(0.015)	


#-============================================================================
# Algorithmically make the control variables for the experiment
def makeExperimentalDesign(SS, TP, Reps):
 
	numTrials = len(SS) * TP * Reps
	trialSetSize = np.zeros(numTrials, dtype = int)			 # this will holder the set size control variable that we will fill below
	trialTP = np.zeros( numTrials, dtype = int)		# this will hold the target presence control variable that we will fill below

	trial = 0
	for r in range(repetitions):					# we do this outer because it makes block randomization easier
		for ss in SS:								# array of set setSizes
			for pres in range(TP):					# target presence
				trialSetSize[trial] = ss
				trialTP[trial] = pres				# 0 = absent, 1 = present
				trial += 1
				print(pres)
			
		
	

		
	# next, create the random order for the trials.  This is not fancy block randomization.
	shuffleOrder = list(range(0, numTrials))	
	random.shuffle(shuffleOrder)
	# below we fill the struct with info about the experimental design and return it.

	designInfo = ExperimentDesign(numTrials = numTrials)
	designInfo.trialSS = trialSetSize
	designInfo.trialTP = trialTP
	designInfo.randomOrder = shuffleOrder
	return designInfo
#-===============================================================
def getSubjectInfo():	
	global subjInfo
	global subjID
	global win
	
	subjInfo = {'Particpant':''}
	dictDlg = gui.DlgFromDict(dictionary=subjInfo,
		title='Visual Search experiment', fixed=['ExpVersion'])
	if dictDlg.OK:
		print(subjInfo)
	else:
		print('User Cancelled')
		popupError("User Cancelled")
		core.wait(3)
		win.close()
		win = None
	subjID =  subjInfo.get('Particpant','none')
	print("subject name = ", subjID,"\n")

#-============================================================================
main()


'''
Python timings:
	time taken =   0.013963937759399414
	core.wait(2.285) =   2.285594940185547
	boo
	time taken =   0.021842002868652344
	core.wait(2.285) =   2.2850961685180664
	boo
	time taken =   0.032482147216796875
	core.wait(2.285) =   2.285022020339966
	boo
	time taken =   0.011793851852416992
	core.wait(2.285) =   2.2851169109344482
	boo
	time taken =   0.011347055435180664
	core.wait(2.285) =   2.285099983215332
	boo
	time taken =   0.021698951721191406
	core.wait(2.285) =   2.2850608825683594
	boo
	time taken =   0.032788991928100586
	core.wait(2.285) =   2.286116123199463
	boo
	time taken =   0.04467892646789551
	core.wait(2.285) =   2.285050868988037
	boo
	time taken =   0.011494874954223633
	core.wait(2.285) =   2.28505277633667
	boo
	time taken =   0.011239767074584961
	core.wait(2.285) =   2.285109758377075
'''
