```@docs
Line
Rect
Ellipse
```

#### draw(various shape types) - Method

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
"""