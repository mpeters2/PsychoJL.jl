```@docs
InitPsychoJL()
wait(win::Window, time::Float64)
MakeInt8Color(r,g,b,a)

```



```
@autodocs
Modules = [PsychoJL, core]
Private = false
Order   = [:function, :type]
```

```
checkdocs=:exports
```



# Introduction to PsychoJL

PsychoJL is a module for writing psychology and psychophysics experiments.  The general framework 
and style is inspired by PsychoPy

Matt Peterson, 2023-2024

## Installation and basic usage

## Basic usage

```julia
using PsychoJL

function DemoWindow()
	InitPsychoJL()
	myWin = window( [1000,1000], false)	# dimensions, fullscreen = false

	newRect = rect(myWin, 
			100,			# width
			100, 			# height
			[200,200],		# position
			lineColor = [255,0,0], 
			fillColor = [255,128,128] 
			)
	draw(newRect) 		# in PsychoPy this would have been newRect.draw()

	myText = textStim(myWin,  		# window
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
