# Overview of the task

In the Spatial Stroop[^Virzi] task, the goal is response as quickly as possible, with a left or right keypress, to the identity of the word on the screen. The stimulus words are "Left" and "Right". The words appear to the left or right of central fixation, and on response congruent trials, the side of the word matches the meaning of the word (e.g. "Left' appears to the left of fixation), whereas in the response *incongruent* trials, they mismach ("Left" appears to the right of fixation).
Mean reaction times for incongruent trials are slower than for congruent trials, and also show less accuracy.

## First Step

Below is the outline of the program we are going to build. We will take a look at these sections piece-by-piece.

```julia
using PsychExpAPIs
using Random
using Printf

#------------
# Experiment design/control variables
mutable struct ExperimentDesign           # We'll pass this around instead of globals
	numTrials::Int64                      # Total number of trials
	trialSide::Vector{String}             # Determines which side the stimulus will appear.
	trialCongruency::Vector{Int64}        # Is the word is congruent with the side it appears?
	randomOrder::Vector{Int64}            # The order in which the trials will be presented.
end

function main()
end
#-===============================================================
function makeExperimentalDesign(sides::Vector{String}, congru::Int64, Reps::Int64)
end
#-===============================================================
function showInstructions(win::Window)
end
#-===============================================================
function shutDown(win::Window, subjFile::IOStream)
end
#-===============================================================
function getSubjectInfo()	
end
#-===============================================================
function openDataFile(subjID::String)
end
#-===============================================================
function doATrial(win::Window, trialNum::Int64, trialInfo::ExperimentDesign, subjFile::IOStream, realOrPractice::Bool = true)
end
#-===============================================================
function fixCross(win::Window)
end
#-===============================================================
main()				# Call main() to get things started
```
---

The keyword `using` is similar to the keyword *import* in Python.

PsychExpAPIs: provides our functions for presenting stimuli and gathering responses.
Random: provides our randomization functions.
Printf: allows to have C-style formatted printing and file writing.

```julia
using PsychExpAPIs
using Random
using Printf
```
---
### Control Variables

Control variables are variables that control your experiment.  They may or may not be part of your experimental design.  For example, in a 
spatial-Stroop task, from an analysis standpoint, we don't care if the word was "Left" or "Right" or if the word appeared on the left or 
right side of the screen, but we do need to control those things, which is why those would be considered *control variables*. On the
other hand, *congruency* can be considered both a control variable and an independent variable.


#### Control Variably strategy

Will use vectors (arrays) to hold all posibble combinations of control variables.  Each index in a vector will represent a single
combination of control variables.\
In the example below, a struct *type* called `ExperimentDesign` holds the four variables that are used to help control the experiment. The code below only
defines the variable *type* -- an instance of that type will be made in the function `makeExperimentalDesign()`.



```julia
#------------
# Experiment design/control variables
mutable struct ExperimentDesign           # We'll pass this around instead of globals
	numTrials::Int64                      # Total number of trials
	trialSide::Vector{String}             # Determines which side the stimulus will appear.
	trialCongruency::Vector{Int64}        # Is the word is congruent with the side it appears?
	randomOrder::Vector{Int64}            # The order in which the trials will be presented.
end
```
!!! note "Resist the urge to use global variables."
    In Python or C, it might natural to make our control variables global variables.  In Julia, it is 
	better to pass the control variabls around in a struct (see [Global Variables](@ref globals) under
	the Performance Tips section).
---
### Overview of functions

`function main()`
* *main()* will hold our main loop for intializing variables, making the main Window, and running practice and experimental trials.
`function makeExperimentalDesign(sides, congru, Reps)`
* Makes the experimental design, filling in the control variables, and make an instance of the `makeExperimentalDesign` struct.
`function showInstructions(win::Window)`
 * Shows the instructions to the participants.  Because global variables are frowned-upon, we pass it the reference to our window as one of its parameters.
`function shutDown(win::Window, subjFile::IOStream)`
* *shutDown()* is called when the experiment is over.  It closes the window, saves the data file, and lets the participant know that the experiment is over.
`function getSubjectInfo()`
* *getSubjectInfo()* opens a dialog and asks for the subject's ID. Also checks to see if the file allready exsits, and if it does, it asks for a new ID.
`function openDataFile(subjID::String)`
* *openDataFile()* opens a text file for writing based on the ID returned by *getSubjectInfo()*.  Also writes the column heading in the data file.
`function doATrial(win::Window, trialNum::Int64, trialInfo::ExperimentDesign, ... realOrPractice::Bool = true)`
* Runs a single practice trial.  `trialInfo` is a struct of type *ExperimentalDesign* and holds our 'global' variables. The variable `realOrPractice` controls whether it is a practice trial (do not save data) or experimental trial (save the data).
`function fixCross(win::Window)`
* Draws the fixation cross to memory.
`main()`
* This is our entry point to the program.  This is a function call to the *main()* function defined above.

---
```julia
using PsychExpAPIs
using Random
using Printf

#------------
# Experiment design variables

mutable struct ExperimentDesign	 				# we'll pass this around instead of globals
	numTrials::Int64
	trialSide::Vector{String}		  			# Determines which side the stimulus will appear on each trial 
	trialCongruency::Vector{Int64}
	randomOrder::Vector{Int64}					# the order in which the trials will be presented
end

#-----
function main()

	exp = makeExperimentalDesign(screenSides, congruencies, repetitions)		# returns an ExperimentDesign struct

	InitPsychoJL()								# Do this before calling any PsychoJL functions
	subjID = getSubjectInfo()					# put up a dialog asking for subject's information
	subjFile = openDataFile(subjID)				# open the subject's data file


	win = Window( [2560,1440], false, coordinateSpace = "PsychoPy")			# 5120 × 2880, or 2560 x 1440	[1000,1000]
	mouseVisible(false)							# hide mouse cursor

	showInstructions(win)						# pass 'win' to showInstructions.  We do this since global variables are verboten.
	#practice
	for t in 1:3
		doATrial(win, t, exp, subjFile, false )
	end

	for t in 1:10
		doATrial(win, t, exp, subjFile, true )
	end	
	shutDown(win, subjFile)
	#exit()
end
```
---

[^Virzi]:
    Virzi, R. A., & Egeth, H. E. (1985). Toward a translational model of Stroop interference. Memory & cognition, 13, 304-319.