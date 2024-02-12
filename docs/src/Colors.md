### Color spaces in PsychoJL

The colorspace for your experiment is specified when you make your window.
For example:
```julia
	myWin = Window( [2560, 1440], false, colorSpace = "rgba255")
```

#### Colorspaces

`rgb255`	red, green, and blue values from 0 to 255. Alpha (opacity) is assumed to be 255 (100%)
  * black = [0,0,0]
  * 50% gray = [127, 127, 127]
  * white = [255, 255, 255]
`rgba255`	red, green, blue, and alpha values from 0 to 255.
  * black = [0, 0, 0, 255]
  * 50% gray = [127, 127, 127, 255]
  * white = [255, 255, 255, 255]
`decimal`	red, green, blue, and alpha values from 0.0 to 1.0. 0.0 is black and 1.0 is 100%
  * black = [0.0, 0.0, 0.0, 1.0]
  * 50% gray = [0.5, 0.5, 0.5, 1.0]
  * white = [1.0, 1.0, 1.0, 1.0]
`PsychoPy`	red, green, blue, and alpha values from -1.0 to 1.0. A value of 0.0 is gray, and +1.0 is 100%
  * black = [-1.0, -1.0, -1.0, +1.0]
  * 50% gray = [0.0, 0.0, 0.0, +1.0]
  * white = [+1.0, +1.0, +1.0, +1.0]
\
Internally, all of these colors will be translated to rgba255 so that they work with SDL (the cross-platform graphics engine that PsychoJL uses).

##### Color fields
Because of the color conversions, you should not access color fields directly.  Internally, the color you set is translated to
an SDL color and saved in another variable, which is the variable used for drawing.

In order to translate (and update!) the color, colors should be set either when making the stimulus or using the `setColor()` function.\
For example, while making a new Textstim:
```julia 
myText = TextStim(myWin,  "Using a TextStim", [100, 100], color = [255, 255, 128])
```
Example using `setColor()`
```julia 
setColor(myText, "red")
```
see [Color setting functions](@ref)

#### Colors in PsychoJL
Shapes and TextStim use PsychoColor as their color Type.

`PsychoColor = Union{String, Vector{Int64}, Vector{Float64}}`

What does that gobbledy-gook mean?  It means that the constructors and functions accept strings,
Vectors of Int64 (from 0-255) and Vectors of Float 64 (either -1.0...+1.0, or 0.0...+1.0) as inputs.

You can pass a string, an integer vector, or a floating point vector as a color.  Keep in mind that the values you pass must
be legal in the color space.  For example, if you set the color space to `rgba255` and try to set the color using a floating
point vector, it will throw an error.\
\
Strings are legal in all cases.

##### When the color space is rgb255 or rgba255...
String inputs will be accepted (see [Colors.jl](https://github.com/JuliaGraphics/Colors.jl/blob/master/src/names_data.jl) for a list of color names).\
\
Integer Vectors with a length of 3 (RGB) or a length of 4 (RGBA) will also be accepted.  If the length is 3, alpha (opacity) is assumed to be 255 (100%).

Example:
```julia
	newRect = Rect(myWin, 
			100,			# width
			100, 			# height
			[200,200],		# position
			lineColor = "dodgerblue", 			# strings are kosher
			fillColor = [255,128,128] 			# this works if the window's color space is rgb255 or rgba255
			)
	draw(newRect) 		# in PsychoPy this would have been newRect.draw()
```

##### When the color space is decimal or PsychoPy...
String inputs will be accepted (see [Colors.jl](https://github.com/JuliaGraphics/Colors.jl/blob/master/src/names_data.jl) for a list of color names).\
\
Float Vectors need a length of 4 (RGBA). How they are interpreted depends on the color space.

If the color space is `decimal`, a value of 0.0 is considered 'black' (in that color channel), and 0.5 is considered gray (50% in that channel).
On the other hand, if the color space is `PsychoPy`, -1.0 s considered 'black' (in that color channel), 0.0 is considered gray (50% in that channel),
and +1.0 is considered white (100% in that channel).

see [Colorspaces](@ref) for example values.

Example:
```julia
	newRect = Rect(myWin, 
			100,			# width
			100, 			# height
			[200,200],		# position
			lineColor = "beige", 			# strings are kosher
			fillColor = [1.0, 0.5, 0.5] 			# this works if the window's color space is decimal or PsychoPy, 
			)
	draw(newRect) 		# in PsychoPy this would have been newRect.draw()
```
"""