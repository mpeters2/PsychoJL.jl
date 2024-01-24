

# Introduction to PsychoJL

PsychoJL is a module for writing psychology and psychophysics experiments.  The general framework 
and style is inspired by PsychoPy, but there is no collaboration with the authors of PsychoPy.

Matt Peterson, 2023-2024

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
## Usage Rules

1. The function `InitPsychoJL()` just be called before any PsychoJL functions are called.
2. The `Window()` constructor for the main window should be called before using any PsychoJL functions, other than GUI calls.
3. GUI dialog windows should be called before the main `Window` has been made.
4. GUI dialog windows can be callled after the main `Window has` been closed.
5. Do not taunt Happy Fun Ball.

## Example

The function 

```julia
using PsychoJL

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

## Known issues

### Color
Currently, color is r,g,b, alpha, with values from 0-255.  Planned color spaces include:

• 0.0 ... 1.0: (Float64)

• -1.0 ... +1.0: (Float64) PsychoPy style color

• Strings: "red", "brown", "gray", etc.

### Coordinate system
Currently, the origin is in the top-left and measurements are in pixels. Planned coordinate systems include:

• Percentage of height: origin is in the top left, and x and y coordinates are a percentage of screen height.
	On a 2560 x 1440, the bottom right coordinate would be ( 1.78, 1.0)

• Psychopy "height": origin is in the center of the screen.  Negative y-values are below the origin, and positive are above the origin.
	On a 2560 x 1440, the top left coordinate would be (-0.89,+0.50), and the bottom right coordinate would be (+0.89,-0.50)

### Coordinate system
The default timescale is `milliseconds`, but `seconds` is also an option.
The timescale used for your experiment is set by passing `milliseconds` or `seconds` as one of the optional 
parameters when creating a main window.

## Technology

All graphics and input are handled by SDL.jl.  I translated parts of SDL2_gfxPrimitives from
C to Julia, with some code replaced with more efficient algorithms.

## Manual Outline
```@contents
```
