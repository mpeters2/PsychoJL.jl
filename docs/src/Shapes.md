# Shapes
* Objects
  - [`Circle`](@ref)
  - [`Ellipse`](@ref)
  - [`Line`](@ref)
  - [`Polygon`](@ref)
  - [`Rect`](@ref)
  - [`ShapeStim`](@ref)
* Functions
  - [`draw(various stimuli)`](@ref manualDrawHeader)
  - [`setPos()`](@ref manualSetPosHeader)
see [Setter functions](@ref)
```@docs
Circle
Ellipse
Line
Polygon
Rect
ShapeStim

```
---

## [draw(various shape types)](@id manualDrawHeader)


Draws the shape (Line, Rect, Ellipse, TextStim, etc.) into the back buffer.

Example:
```julia

	newRect = Rect(myWin, 
			100,			# width
			100, 			# height
			[200,200],		# position
			lineColor = [255,0,0], 
			fillColor = [255,128,128] 
			)
	draw(newRect) 		# in PsychoPy this would have been newRect.draw()
```

---
## [setPos()](@id manualSetPosHeader)


Set the position of the object, usually the center unless specified otherwise. 
Example moves an image rightward by 100 pixels per frame, starting at 300 and ending at 500 pixels:
```julia
	for x in 300:100:500
		setPos(myImage, [x, 400])
		draw(myImage)
		waitTime(myWin, 100.0)
		flip(myWin)
	end
```

	See [Setter functions](@ref) for more information.


\
```@index
```