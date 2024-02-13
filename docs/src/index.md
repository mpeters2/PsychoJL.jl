
 
# Introduction to PsychoJL

PsychoJL is a module for writing psychology and psychophysics experiments.  The general framework 
and style is inspired by PsychoPy, but there has been no collaboration with the authors of PsychoPy.

Matt Peterson, 2023-2024

## Manual Outline
```@contents
```
## Overview

PsychoJL is a module for writing psychology experiments.  Typically, before a trial begins, 
stimuli are drawn offscreen into the video buffer.  When it is time to present the stimuli,
the flip() function is called and the offscreen image is displayed.

## Differences between PsychoPy and PsychoJL

The main difference between the two involves how objects are called in Julia.  For example, to 
make and draw a TextStim, you would write something like this in PsychoPy:

```python
stim = visual.TextStim(win, 
                    	'Hello World!',
                    	pos=(0.0, 0.0),		# center of the screen
                    	color=(1, 0, 0), 
                    	colorSpace='rgb')
TextStim.draw()
```
In Julia, it would look like this:

```julia
stim = TextStim(win, 
                "Hello World!",
                [300, 100], 		# position
                color=(255, 0, 0))
draw(stim)
```
Notice that Julia does not use the Object.method() syntax of Python.  Instead, the stimulus is passed
to the draw() function.

In addition, Julia objects are really structures (data) with a constructor function of the same name. 
For example, I can make a new `TextStim` using the `TextStim()` constructor function, and latter change
one of its properties using dot notation.

```julia
stim = TextStim(win, 
                "Hello World!",
                [300, 100], 		# position
                color=(255, 0, 0))
stim.textMessage = "Goodbye, world!"
```
## Performance Tips
Julia can be many orders of magnitude faster than Python. My biggest performance tip is, despite their similarities,
do not write Julia programs like you would write a Python program.

##### Global Variables
For example, although Julia can use global variables, the use of global variables (global constants are OK)
[prevents the optimizing compiler from optimizing](https://docs.julialang.org/en/v1/manual/performance-tips/).
Instead, pass around structs containing what would have been written as global variables in a Python program.
The VisualSearchMain.jl example experiment shows this in action. It uses a struct called ExperimentalDesign.
Although the struct definition is in the global scope, an instance of this structure is created in the 
function `makeExperimentalDesign()` and passed around from function-to-function.

```julia
mutable struct ExperimentDesign	 	# we'll pass this around instead of globals
	numTrials::Int64
	trialSS::Vector{Int64}		  	# this holds the combination of SetSize control 
	trialTP::Vector{Int64}		  	# Target Presence
	randomOrder::Vector{Int64}	  	# this will hold the random order in which the trials will be displayed.
end
```
PsychoJL also makes use of this through the Window instance you create.  You may have noticed that most PsychoJL functions
require a window to be passed as one of their parameters.  For example, `startTimer()` and `stopTimer()` require a Window to be 
passed as one of their arguments.
What in the world does timing have to do with a graphical window?  Nothing. However, PsychoJL uses it as a struct that can
hold what would have otherwise been a global variable in another language.  Calling `startTimer()` causes it to store the 
starting time in the Window you passsed to it.  Likewise, `stopTimer()` uses the information stored in the Window structure
to calculate the elapsed time.

##### Variable Typing

Like Python, Julia can infer variables' types. However, Julia can be faster when it does not need to infer types.  For example,
the parameter for this function is perfectly legal (from a syntactic point of view):

```julia
function fancyMath(myArray)
	answer = doSomeStuff(myArray)
	return answer
end
```
But, this is even better, because it explicitely states the parameter's type:

```julia
function fancyMath(myArray::Vector{Float64})
	answer = doSomeStuff(myArray)
	return answer
end
```

As you might have noticed by the documentation, PsychoJL is strongly typed.  Future versions, through
multiple-dispatch (i.e. overloading) will be less strict with their types. For example, for the `startPoint`
and `endPoint`, `Line()` requires a vector of two integers.  In the future, it will allow vectors of floats. [edit: the future is here!]

##### Integer Division

When dividing variables that should remain integers, Julia's integer division operand `÷` (not `/`!) is 
extremely useful. Dividing integers using the standard division operand `\` can return a float. For example:

```julia
julia> x = 255 ÷ 2
127
```
vs
```julia
julia> x = 255 / 2
127.5
```
Integer division truncates.  In other situations `round(Int64, x)` might make more sense.



## Usage Rules

1. The function `InitPsychoJL()` just be called before any PsychoJL functions are called.
2. The `Window()` constructor for the main window should be called before using any PsychoJL functions, other than GUI calls.
3. GUI dialog windows should be called before the main `Window` has been made.
4. GUI dialog windows can be callled after the main `Window has` been closed.
5. Do not taunt Happy Fun Ball.

## Example

The function 

```julia
using PsychExpAPIs

function DemoWindow()
	InitPsychoJL()
	myWin = Window( [1000,1000], false)	# dimensions, fullscreen = false

	newRect = Rect(myWin, 
			100,			# width
			100, 			# height
			[200,200],		# position
			lineColor = [255,0,0], 
			fillColor = [255,128,128] 
			)
	draw(newRect) 		# in PsychoPy this would have been newRect.draw()

	myText = TextStim(myWin,  		# window
			"Using a textStim", 	# text
			[300, 100], 		# position
			color = [255, 255, 128]
			)
	draw(myText) 		# in PsychoPy this would have been myText.draw()
	flip(myWin)
	wait(2000)		# core.wait in Psychopy.  Default timeScale (see Window) is in milliseconds.
end
#------
DemoWindow()
```
## Missing Functionality
mouse events\n
timers (timing can be done by using Julia's time() function)\n
pie-wedges\n


## Known issues

### Manual
The manual is a work in progress, and needs reorganization.

### Timescales
The default timescale is `milliseconds`, but `seconds` is also an option.
The timescale used for your experiment is set by passing `milliseconds` or `seconds` as one of the optional 
parameters when creating a main window.

### Monitors
There are some issues that need to be worked out when using high-resolution displays suchs Retina displays.  Currently, fullscreen mode draws correctly, but when fullscreen = false, 
the image is smaller than expected.
## Technology

All graphics and input are handled by SDL.jl.  I translated parts of SDL2_gfxPrimitives from
C to Julia, with some code replaced with more efficient algorithms (and sometimes I couldn't figure out the orignal C code!).

