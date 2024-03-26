# main()

main() is the first function called in our experiment.  Let's go over this step-by-step.

```julia
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

	for t in 1:exp.numTrials
		doATrial(win, t, exp, subjFile, true )
	end	
	shutDown(win, subjFile)
end
```
\

`exp = makeExperimentalDesign(screenSides, congruencies, repetitions)]`
* This makes our experimental design, filling (and returning) and instance of `mutable struct ExperimentDesign`.
* We'll take a more detailed look at this later.
`InitPsychoJL()`
 * This must be called before calling any PsychoJL functions. It initializes the graphics, audio devices, and input. I usually call this first.
```	julia
subjID = getSubjectInfo()           # put up a dialog asking for subject's information
subjFile = openDataFile(subjID)     # open the subject's data file`
```
* The first line opens a dialog box, asks for an ID.  If a file using that ID already exists, a message pops up asking for a new ID. The second line takes the `subjID` returned by `getSubjectInfo()` and opens a data (text) file for writing.
* We'll take a look at both of these functions later in the tutorial.
`win = Window( [2560,1440], false, coordinateSpace = "PsychoPy")`
* Creates our graphics window.  The first parameter is a vector describing the width and height of the window, and the second paramter sets *fullScreen* to `false`.  For final deployment, this should be set to `true`.  The last parameter sets the coordinate system ot PsychoPy style coordinates (see [coordinates](@ref PsychoPyCoordinates)).
* Please see [Windows](@ref WindowsPage) for more parameters that Windows can take.
`mouseVisible(false)`
 * Hides the mouse cursor/pointer.
 `showInstructions(win)`
 * Shows the instrucitons to the participant.  Since global variables are discouraged, we pass it `win` as one of its parameters (*win* is local to `main()`)\

```julia
 	for t in 1:3
		doATrial(win, t, exp, subjFile, false )
	end
	
	for t in 1:exp.numTrials
		doATrial(win, t, exp, subjFile, true )
	end	
```
  * The first `for` loop loops through 3 practice trials (I could have made more). The last parameter to doATrial determines whether it is a practice or experimental trial. We'll look at this in more detail later.
  * The second `for` loop loops through the experimental trials, from 1 to `exp.numTrials` (see the second line of `main()`.
  * One thing we overlooked, is that we should have had a function between the practice and experimental trials informing the participant that the experimental trials are beginning.  If you chose to add a function, it should be modelled after the `showInstructions()` function, which uses a full screen window, rather than diaglog (dialogs might not be visible during fullscreen mode).
 

Next: [makeExperimentalDesign()](@ref makeExperimentalDesign())