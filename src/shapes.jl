#=

Psychopy defines and uses shapes like this:

myRectPy = visual.Rect(win, size = (0.1, 0.1), pos = (x,y), lineColor = (1,1,-1), fillColor =  None)
myRectPy.draw()

In Psychopy, shapes are objects.
In PsychoJL, shapes are structs.

myRectJL = rect(myWin, 100, 100, [400,400] )			# width, height, position array, myRectJL is a Rect structure
draw(myRectJL)

=#

export Rect, Ellipse, draw
export Line, Circle, ShapeStim, Polygon
export setColor, setLineColor, setFillColor, setPos

#=
new functions needed:

SetColor
SetPos

also for images

=#

#-==================================================================
"""
	Line()

Constructor for a Line object

**Constructor inputs:**
  * win::Window\n
  * startPoint::Vector{Int64}\n
  * endPoint::Vector{Int64}\n
  * width::Int64				
  * lineColor::PsychoColor\n
**Outputs:** None

**Methods:** 
* draw()
"""
mutable struct Line	
	win::Window
	startPoint::Vector{Int64}
	endPoint::Vector{Int64}
	width::Int64							# this will need to change to floats for Psychopy height coordiantes
	lineColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	_lineColor::Vector{Int64}

	#----------
	function Line(	win::Window,
					startPoint::Vector{Int64} = [0,0],
					endPoint::Vector{Int64} = [10,10];
					width::Int64 = 1,
					lineColor::PsychoColor = fill(128, (3)),				# these will need to change to floats to handle Psychopy colors
		#			opacity::Int64 = 255							# these will need to change to floats to handle Psychopy colors
			)
	# might want to add length and orientation
	#	Int8Color = 
		if length(endPoint) != 2
			message = "endPoint needs two coordinates, got " * String(length(endPoint)) * " instead."
			error(message)
		end
		if length(startPoint) != 2
			message = "startPoint needs two coordinates, got " * String(length(startPoint)) * " instead."
			error(message)
		end		

		_lineColor = colorToSDL(win, lineColor)
		new(win, 
			startPoint,
			endPoint,
			width,
			lineColor,
			_lineColor
			)

	end
end
#----------
function draw(L::Line)

	if L.width == 1							# draw a single anti-aliased line
		WULinesAlpha(L.win, 
						convert(Float64, L.startPoint[1]), 
						convert(Float64, L.startPoint[2]), 
						convert(Float64, L.endPoint[1]), 
						convert(Float64, L.endPoint[2]),
						convert(UInt8, L.lineColor[1]),
						convert(UInt8, L.lineColor[2]),
						convert(UInt8, L.lineColor[3]),
						convert(UInt8, L.lineColor[4])
					)

	else											
		# If we were really cool, we would center even lines by somehow antialiasing the sides
		# in order to make the lines look centered at the start point instead of offset.
		WULinesAlphaWidth(L.win, 
						convert(Float64, L.startPoint[1]), 
						convert(Float64, L.startPoint[2]), 
						convert(Float64, L.endPoint[1]), 
						convert(Float64, L.endPoint[2]),
						convert(UInt8, L.lineColor[1]),
						convert(UInt8, L.lineColor[2]),
						convert(UInt8, L.lineColor[3]),
						convert(UInt8, L.lineColor[4]),
						L.width
					)

	end

#	drawStartPoint(L.win.renderer,L.startPoint[1] ,L.startPoint[2] )
end
#-==========================
"""
	setColor(::Line, ::Union{String, Vector{Int64}, Vector{Int64})

Used to update the color of a Line object.
"""
function setColor(line::Line, color::PsychoColor)
	line._lineColor = colorToSDL(line.win, color)
end
#-==========================

#--------
function drawStartPoint(renderer::Ptr{SDL_Renderer}, x::Int64, y::Int64)
	# 4 points are drawning like the 5 on dice.  the missing center one is x, y
	SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
	SDL_RenderDrawPoint(renderer, x-1, y-1)
	SDL_RenderDrawPoint(renderer, x-1, y+1)
	SDL_RenderDrawPoint(renderer, x+1, y-1)
	SDL_RenderDrawPoint(renderer, x+1, y+1)
end
#-==========================
function getLineLength(L::Line)
	return sqrt( ((L.startPoint[1] - L.endPoint[1]) ^2)  + ((L.startPoint[2] - L.endPoint[2])^2) )
end
#-=====================================================================================================
#=
#- Line2 experiments with using multiple dispatch for coordinate systems
mutable struct Line2	
	win::Window
	startPoint::Vector{Real}
	endPoint::Vector{Real}
	width::Int64							# this will need to change to floats for Psychopy height coordiantes
	lineColor::Vector{Int64}			# these will need to change to floats to handle Psychopy colors
	_startPoint::Vector{Int64}
	_endPoint::Vector{Int64}
	#----------
	function Line2(	win::Window,
					startPoint::Vector{Int64} = [0,0],
					endPoint::Vector{Int64} = [10,10];
					width::Int64 = 1,
					lineColor::Vector{Int64} = fill(128, (4)),				# these will need to change to floats to handle Psychopy colors
					_startPoint::Vector{Int64} = [0,0],
					_endPoint::Vector{Int64} = [10,10]
			)

		if length(endPoint) != 2
			message = "endPoint needs two coordinates, got " * String(length(endPoint)) * " instead."
			error(message)
		end
		if length(startPoint) != 2
			message = "startPoint needs two coordinates, got " * String(length(startPoint)) * " instead."
			error(message)
		end		

		lineColor = colorToSDL(win, lineColor)
		new(win, 
			startPoint,
			endPoint,
			width,
			convert(Vector{Int64},lineColor),
			startPoint,
			endPoint
			)

	end
	#----------
	function Line2(	win::Window,
					startPoint::Vector{Float64} = [0.1,0.1],
					endPoint::Vector{Float64} = [0.2,0.2];
					width::Int64 = 1,
					lineColor::Vector{Int64} = fill(128, (4)),				# these will need to change to floats to handle Psychopy colors
					_startPoint::Vector{Int64} = [0,0],
					_endPoint::Vector{Int64} = [10,10]
				)

		if length(endPoint) != 2
			message = "endPoint needs two coordinates, got " * String(length(endPoint)) * " instead."
			error(message)
		end
		if length(startPoint) != 2
			message = "startPoint needs two coordinates, got " * String(length(startPoint)) * " instead."
			error(message)
		end		
		_, displayHeight = getSize(win)

		if win.coordinateSpace == "PsychoPy"											
			_startPoint[1] = round(Int64, (startPoint[1]+0.5) * displayHeight)		# convert PsychoPy to Percent coordinates first then percentage to pixels
			_startPoint[2] = round(Int64, (-startPoint[2]+0.5) * displayHeight)
			_endPoint[1] = round(Int64, (endPoint[1]+0.5) * displayHeight)
			_endPoint[2] = round(Int64, (-endPoint[2]+0.5) * displayHeight)
		else
			_startPoint[1] = round(Int64, startPoint[1] * displayHeight)		# convert percentage to pixels
			_startPoint[2] = round(Int64, startPoint[2] * displayHeight)
			_endPoint[1] = round(Int64, endPoint[1] * displayHeight)
			_endPoint[2] = round(Int64, endPoint[2] * displayHeight)
		end
		new(win, 
			startPoint,
			endPoint,
			width,
			convert(Vector{Int64},lineColor),
			_startPoint,
			_endPoint
			)

	end

end
#----------

#----------
function draw(L::Line2)

	if L.width == 1							# draw a single anti-aliased line
		WULinesAlpha(L.win, 
						convert(Float64, L._startPoint[1]), 
						convert(Float64, L._startPoint[2]), 
						convert(Float64, L._endPoint[1]), 
						convert(Float64, L._endPoint[2]),
						convert(UInt8, L.lineColor[1]),
						convert(UInt8, L.lineColor[2]),
						convert(UInt8, L.lineColor[3]),
						convert(UInt8, L.lineColor[4])
					)

	else											
		# If we were really cool, we would center even lines by somehow antialiasing the sides
		# in order to make the lines look centered at the start point instead of offset.
		WULinesAlphaWidth(L.win, 
						convert(Float64, L._startPoint[1]), 
						convert(Float64, L._startPoint[2]), 
						convert(Float64, L._endPoint[1]), 
						convert(Float64, L._endPoint[2]),
						convert(UInt8, L.lineColor[1]),
						convert(UInt8, L.lineColor[2]),
						convert(UInt8, L.lineColor[3]),
						convert(UInt8, L.lineColor[4]),
						L.width
					)

	end

 
end
=#
#-=====================================================================================================
# Floating point version shelved for now, as you can not do multiple dispatch with optional arguments.
"""
	Rect()

Constructor for a Rect object

**Constructor inputs:**  
* win::Window,
* width::Int64 
* height::Int64 
* pos::Vector{Int64}	**position**

**Optional constructor inputs:**
* units::String......*(default is "pixel"*
* lineWidth::Int64......*(default is 1)*
* lineColor::PsychoColor......*default is (128, 128, 128)*
* fillColor::PsychoColor......*default is (128, 128, 128)*
* ori::Float64 = 0.0......*(orientation in degrees)*		
* opacity::Float......*(default is 1.0, indepenent of alpha)*

**Full list of fields**
* win::Window
* width::Int64							
* height::Int64
* pos::Vector{Int64}
* units::String
* lineWidth::Int64					
* lineColor::PsychoColor		
* fillColor::PsychoColor			
* ori::Float64							
* opacity::Int64							
* SDLRect::SDL_Rect

**Methods:** 
* draw()
* setLineColor()
* setFillColor()
* setPos()
"""
mutable struct Rect	#{T}
	win::Window
	width::Int64							# this will need to change to floats for Psychopy height coordiantes
	height::Int64
	pos::PsychoCoords
	units::String
	lineWidth::Int64						# this will need to change to floats for Psychopy height coordiantes
	lineColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	fillColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	ori::Float64							# The orientation of the stimulus (in degrees).
	opacity::Float64							# these will need to change to floats to handle Psychopy colors
	SDLRect::SDL_Rect
	_lineColor::Vector{Int64}
	_fillColor::Vector{Int64}
	_pos::Vector{Int64}

	#----------
	function Rect(	win::Window,
					width::Int64 = 1,
					height::Int64 = 1,
					pos::PsychoCoords = [10,10];		# position
					units::String = "pixel",
					lineWidth::Int64 = 1,
					lineColor::PsychoColor = fill(128, (3)),				# these will need to change to floats to handle Psychopy colors
					fillColor::PsychoColor = fill(128, (3)),				# these will be Psychopy colors
					ori::Float64 = 0.0,						
					opacity::Float64 = 1.0							# these will need to change to floats to handle Psychopy colors
			)
		# NOTE: SDL uses the upper left corner.  I'm converting the to the center of the rect like Psychopy
		centerX::Int64 = round(pos[1] - (width/2))
		centerY::Int64 = round(pos[2] - (height/2))
		_pos = [ centerX, centerY]
		SDLRect = SDL_Rect(_pos[1], _pos[2], width, height)
		_lineColor = colorToSDL(win, lineColor)
		_fillColor = colorToSDL(win, fillColor)
		#=
		if length(lineColor) == 3									# will need to be changed later when other formats can be used
			push!(lineColor, 255)
		end
		if length(fillColor) == 3									# will need to be changed later when other formats can be used
			push!(fillColor, 255)
		end		
		=#
		new(win, 
			width ,
			height,
			pos,
			units,
			lineWidth,
			lineColor,				# these will need to change to floats to handle Psychopy colors
			fillColor,				# these will be Psychopy colors
			ori,						
			opacity,							# these will need to change to floats to handle Psychopy colors
			SDLRect,					# SDL rectangle object
			_lineColor,
			_fillColor,
			_pos
			)

	end
end
#----------
"""
	draw(various shape types)

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
function draw(R::Rect)
	# first draw filled Rect
	SDL_SetRenderDrawColor(R.win.renderer, 
							R._fillColor[1], 
							R._fillColor[2], 
							R._fillColor[3], 
							round(Int64, R._fillColor[4] * R.opacity ) )

 	SDL_RenderFillRect( R.win.renderer, Ref{SDL_Rect}(R.SDLRect))
#println("resulting alpha = ", round(Int64, R._fillColor[4] * R.opacity )," ,", R._fillColor[4]," ,", R.opacity)
#println(R._fillColor)
	# then draw outline
	SDL_SetRenderDrawColor(R.win.renderer, 
							R._lineColor[1], 
							R._lineColor[2], 
							R._lineColor[3], 
							round(Int64, R._lineColor[4] * R.opacity) )

	SDL_RenderDrawRect( R.win.renderer, Ref{SDL_Rect}(R.SDLRect))

end

#-=====================================================================================================
"""
	Ellipse()

Constructor for an Ellipse object

**Inputs:**
* win::Window 
* pos::Vector{Int64}   
* rx::Int64 ......*horizontal radius*  
* ry::Int64 ......*vertical radius*
* lineWidth::Int64				
* lineColor::PsychoColor
* fillColor::PsychoColor
* fill::Bool ......*fill or not*
**Outputs:** None
**Methods:** 
* draw
* setLineColor()
* setFillColor()
* setPos()
"""
mutable struct Ellipse
	win::Window
	pos::PsychoCoords
	rx::Union{Int64, Float64}							# Horizontal radius in pixels of the aa-ellipse
	ry::Union{Int64, Float64}							# vertical radius in pixels of the aa-ellipse
	lineWidth::Int64
	lineColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	fillColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	fill::Bool							# these will need to change to floats to handle Psychopy colors
	_lineColor::Vector{Int64}
	_fillColor::Vector{Int64}
	_pos::Vector{Int64}
	_rx::Int64
	_ry::Int64


	#aaellipseRGBA
	#----------
#MethodError: no method matching Ellipse(::Window, ::Vector{Int64}, ::Int64, ::Int64, ::Int64, ::Vector{Int64}, ::Vector{Int64}, ::Bool)
#								 Ellipse(::Window, ::Vector{Int64}, ::Int64, ::Int64; lineWidth, lineColor, fillColor, fill)
	function Ellipse(win::Window,
					pos::PsychoCoords = [10,10],		# position
					rx::Union{Int64, Float64} = 20,						# Horizontal radius in pixels of the aa-ellipse
					ry::Union{Int64, Float64} = 10;						# vertical radius in pixels of the aa-ellipse
					lineWidth::Int64 = 1,
					lineColor::PsychoColor = fill(128, (4)),				# these will need to change to floats to handle Psychopy colors
					fillColor::PsychoColor = fill(128, (4)),				# these will be Psychopy colors
					fill::Bool = false
			)
		_lineColor = colorToSDL(win, lineColor)
		_fillColor = colorToSDL(win, fillColor)

		if win.coordinateSpace != "LT_Pix"
			_, displayHeight = getSize(win)								# get true height of window
			_rx = round(Int64, rx * displayHeight)								# convert percent to pixels
			_ry = round(Int64, ry * displayHeight)								# convert percent to pixels
			_pos = SDLcoords(win, pos)
		else
			_rx = rx
			_ry = ry
			_pos = pos
		end

		new(win, 
			pos,
			rx,
			ry,
			lineWidth,
			lineColor,				# these will need to change to floats to handle Psychopy colors
			fillColor,				# these will be Psychopy colors
			fill,
			_lineColor,
			_fillColor,
			_pos,
			_rx,
			_ry
			)
	end
end
#----------
#MethodError: Cannot `convert` an object of type Int64 to an object of type Vector{Int64}
#Ellipse(win::Window, pos::Vector{Float64}, rx::Int64, ry::Int64; lineWidth::Int64, lineColor::String, fillColor::Vector{Float64}, fill::Bool)

function draw(El::Ellipse)

	if El.fill == true
		aaFilledEllipseRGBA(El.win.renderer, 
							El._pos[1], 
							El._pos[2],  
							El._rx, 
							El._ry, 
							El._fillColor[1], 
							El._fillColor[2], 
							El._fillColor[3], 
							El._fillColor[4])
	# I need to check if linecolor exists or has an alpha>0, and then draw the outline
		_aaellipseRGBA(El.win.renderer,El._pos[1], El._pos[2], El._rx, El._ry, El._lineColor, El.fill)
	end
	if El.lineWidth > 1
		# we need to anti-alias the outside.  When thickness is >1, radius increases by thickness / 2	
		# outside antialias first
		newrX = El._rx + (El.lineWidth ÷ 2) #-1
		newrY = El._ry + (El.lineWidth ÷ 2) -1
		_aaellipseRGBA(El.win.renderer,El._pos[1]-1, El._pos[2], newrX, newrY, El.lineColor, El.fill)
		thickEllipseRGBA(El.win.renderer,
							El._pos[1], 
							El._pos[2],  
							El._rx, 
							El._ry, 
							El._lineColor[1], 
							El._lineColor[2], 
							El._lineColor[3], 
							El._lineColor[4],
							El.lineWidth)
		# inside antialias first
		newrX = El._rx - (El.lineWidth ÷ 2) #+1
		newrY = El._ry - (El.lineWidth ÷ 2) 
		_aaellipseRGBA(El.win.renderer,El._pos[1]-1, El._pos[2], newrX, newrY, El._lineColor, El.fill)

	else
		_aaellipseRGBA(El.win.renderer,El._pos[1], El._pos[2], El._rx, El._ry, El._lineColor, El.fill)
	end
	# below is my lame way of drawing a filled ellipse inside an anti-aliased ellipse
	# in reality, I show modify aaelipse fill
#=
	if El.fill == true			# filled
		filledEllipseRGBA(El.win.renderer,El.pos[1], El.pos[2], El.rx, El.ry,  
							convert(UInt8, El.lineColor[1]), 
							convert(UInt8, El.lineColor[2]),
							convert(UInt8, El.lineColor[3]),
							convert(UInt8, El.lineColor[4])
							)
	end
=#
end
#-=====================================================================================================
"""
	Circle()

Constructor for an Circle object

**Inputs:**
* win::Window 
* pos::Vector{Int64}   
* rad::Int64 ......*radius* 
* lineWidth::Int64				
* lineColor::PsychoColor
* fillColor::PsychoColor
* fill::Bool ......*fill or not*
**Outputs:** None
**Methods:** 
* draw()
* setLineColor()
* setFillColor()
* setPos()


"""
mutable struct Circle
	win::Window
	pos::PsychoCoords	
	rad::Union{Int64, Float64}							# radius in pixels of the aa-ellipse
	lineWidth::Int64
	lineColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	fillColor::PsychoColor			# these will need to change to floats to handle Psychopy colors
	fill::Bool							# these will need to change to floats to handle Psychopy colors
	circlesEllipse::Ellipse
	_lineColor::Vector{Int64}
	_fillColor::Vector{Int64}
	_pos::Vector{Int64}
	_rad::Int64

	function Circle(win::Window,
					pos::PsychoCoords = [10,10],		# position
					rad::Union{Int64, Float64} = 20;						# Horizontal radius in pixels of the aa-ellipse
					lineWidth::Int64 = 1,
					lineColor::PsychoColor = fill(128, (4)),				# these will need to change to floats to handle Psychopy colors
					fillColor::PsychoColor = fill(128, (4)),				# these will be Psychopy colors
					fill::Bool = false
			)

		_lineColor = colorToSDL(win, lineColor)
		_fillColor = colorToSDL(win, fillColor)
		if win.coordinateSpace != "LT_Pix"
			_, displayHeight = getSize(win)								# get true height of window
			_rad = round(Int64, rad * displayHeight)								# convert percent to pixels
			_pos = SDLcoords(win, pos)
		else
			_rad = rad
			_pos = pos
		end
		circlesEllipse = Ellipse(win, pos, rad, rad, lineWidth=lineWidth,lineColor=lineColor,fillColor=fillColor, fill=fill)

		new(win, 
			pos,
			rad,
			lineWidth,
			lineColor,				# these will need to change to floats to handle Psychopy colors
			fillColor,				# these will be Psychopy colors
			fill,
			circlesEllipse,
			_lineColor,
			_fillColor,
			_pos,
			_rad
			)
	end
end
#----------


function draw(Circ::Circle)
	draw(Circ.circlesEllipse)
end
#-=====================================================================================================
# Floating point version shelved for now, as you can not do multiple dispatch with optional arguments.
"""
	ShapeStim()

Constructor for a ShapeStim object, which is a polygon defined by vertices.

**Constructor inputs:**  
* win::Window,
* vertices::Vector{Vector{Int64}} 


**Optional constructor inputs:**
* units::String......*(default is "pixel"*
* lineWidth::Int64......*(default is 1)*
* lineColor::PsychoColor......*default is (128, 128, 128)*

**Full list of fields**
* win::Window
* vertices::Vector{Vector{Int64}} 
Example:
*[ [300, 10], [400, 5], [410,150], [320, 100] ,[290, 20] ]*
* units::String
* lineWidth::Int64					
* lineColor::PsychoColor		

**Methods:** 
* draw()
"""
mutable struct ShapeStim	#{T}
	win::Window
	vertices::Vector{Vector{Int64}}			#Vector{Int64}
	units::String
	lineWidth::Int64						# this will need to change to floats for Psychopy height coordiantes
	lineColor::PsychoColor			# these will need to change to floats to handle Psychopy colors


	#----------
	function ShapeStim(	win::Window,
						vertices::Vector{Vector{Int64}} = [[10,10]];		# a single vertex placeholder
						units::String = "pixel",
						lineWidth::Int64 = 1,
						lineColor::PsychoColor = fill(128, (4)),				# these will need to change to floats to handle Psychopy colors
			)

		lineColor = colorToSDL(win, lineColor)		
		new(win, 
			vertices,
			units,
			lineWidth,
			lineColor,				# these will need to change to floats to handle Psychopy colors
			)

	end
end
#----------
function draw(S::ShapeStim)

	numCoords = length(S.vertices)
	if S.lineWidth == 1							# draw a single anti-aliased line
		for i in 2:numCoords
			WULinesAlpha(S.win, 
							convert(Float64, S.vertices[i-1][1]), 
							convert(Float64, S.vertices[i-1][2]), 
							convert(Float64, S.vertices[i][1]), 
							convert(Float64, S.vertices[i][2]),
							convert(UInt8, S.lineColor[1]),
							convert(UInt8, S.lineColor[2]),
							convert(UInt8, S.lineColor[3]),
							convert(UInt8, S.lineColor[4])
						)
		end
		# close the shape
		WULinesAlpha(S.win, 
					convert(Float64, S.vertices[1][1]), 
					convert(Float64, S.vertices[1][2]), 
					convert(Float64, S.vertices[numCoords][1]), 
					convert(Float64, S.vertices[numCoords][2]),
					convert(UInt8, S.lineColor[1]),
					convert(UInt8, S.lineColor[2]),
					convert(UInt8, S.lineColor[3]),
					convert(UInt8, S.lineColor[4])
				)

	else											
		# If we were really cool, we would center even lines by somehow antialiasing the sides
		# in order to make the lines look centered at the start point instead of offset.
		for i in 2:numCoords
			WULinesAlphaWidth(S.win, 
							convert(Float64, S.vertices[i-1][1]), 
							convert(Float64, S.vertices[i-1][2]), 
							convert(Float64, S.vertices[i][1]), 
							convert(Float64, S.vertices[i][2]),
							convert(UInt8, S.lineColor[1]),
							convert(UInt8, S.lineColor[2]),
							convert(UInt8, S.lineColor[3]),
							convert(UInt8, S.lineColor[4]),
							S.lineWidth
						)
		# close the shape
		WULinesAlphaWidth(S.win, 
						convert(Float64, S.vertices[1][1]), 
						convert(Float64, S.vertices[1][2]), 
						convert(Float64, S.vertices[numCoords][1]), 
						convert(Float64, S.vertices[numCoords][2]),
						convert(UInt8, S.lineColor[1]),
						convert(UInt8, S.lineColor[2]),
						convert(UInt8, S.lineColor[3]),
						convert(UInt8, S.lineColor[4]),
						S.lineWidth
					)
		end
	end	


end

#-=====================================================================================================
# Floating point version shelved for now, as you can not do multiple dispatch with optional arguments.
"""
	Polygon()

Constructor for a regular Polygon object, such as a pentagon or hexagon.

**Constructor inputs:**  
* win::Window,
* pos::Vector{Int64}......*[x,y] coordinates of center*
* rad::Int64......*radius*
* sides::Int64

**Optional constructor inputs:**
* units::String......*(default is "pixel"*
* lineWidth::Int64......*(default is 1)*
* lineColor::PsychoColor......*default is (128, 128, 128)*

**Full list of fields**
* win::Window,
* pos::Vector{Int64}
* rad::Int64......*radius*
* sides::Int64
* units::String
* lineWidth::Int64					
* lineColor::PsychoColor		

**Methods:** 
* draw()
"""
mutable struct Polygon	#{T}
	win::Window
	pos::Vector{Int64}
	rad::Int64
	sides::Int64
	units::String
	lineWidth::Int64						# this will need to change to floats for Psychopy height coordiantes
	lineColor::PsychoColor			# these will need to change to floats to handle Psychopy colors


	#----------
	function Polygon(	win::Window,
						pos::Vector{Int64} = [10,10],		# a single vertex placeholder
						rad::Int64 = 10,
						sides::Int64 = 5;
						units::String = "pixel",
						lineWidth::Int64 = 1,
						lineColor::PsychoColor = fill(128, (4))				# these will need to change to floats to handle Psychopy colors
			)

		lineColor = colorToSDL(win, lineColor)
		new(win, 
			pos,
			rad,
			sides,
			units,
			lineWidth,
			lineColor,				# these will need to change to floats to handle Psychopy colors
			)

	end
end
#----------
function draw(P::Polygon)
	# it would be more efficient to initially fill this with pairs of zeros (pre-allocate)
	vertices = []

	for i in 1:P.sides
		x = P.pos[1] + P.rad * sin(2 * pi * i/P.sides)				# this is technically wrong, but I swap sine and cos
		y = P.pos[2] + P.rad * cos(2 * pi * i/P.sides)				# so that their bases will be on the bottom
		push!(vertices, [round(Int64, x),round(Int64, y)])
	end

	if P.lineWidth == 1							# draw a single anti-aliased line
		for i in 2:P.sides
			WULinesAlpha(P.win, 
							convert(Float64, vertices[i-1][1]), 
							convert(Float64, vertices[i-1][2]), 
							convert(Float64, vertices[i][1]), 
							convert(Float64, vertices[i][2]),
							convert(UInt8, P.lineColor[1]),
							convert(UInt8, P.lineColor[2]),
							convert(UInt8, P.lineColor[3]),
							convert(UInt8, P.lineColor[4])
						)
		end
		# close the shape
		WULinesAlpha(P.win, 
					convert(Float64, vertices[1][1]), 
					convert(Float64, vertices[1][2]), 
					convert(Float64, vertices[P.sides][1]), 
					convert(Float64, vertices[P.sides][2]),
					convert(UInt8, P.lineColor[1]),
					convert(UInt8, P.lineColor[2]),
					convert(UInt8, P.lineColor[3]),
					convert(UInt8, P.lineColor[4])
				)

	else											
		# If we were really cool, we would center even lines by somehow antialiasing the sides
		# in order to make the lines look centered at the start point instead of offset.
		for i in 2:P.sides
			WULinesAlphaWidth(P.win, 
							convert(Float64, vertices[i-1][1]), 
							convert(Float64, vertices[i-1][2]), 
							convert(Float64, vertices[i][1]), 
							convert(Float64, vertices[i][2]),
							convert(UInt8, P.lineColor[1]),
							convert(UInt8, P.lineColor[2]),
							convert(UInt8, P.lineColor[3]),
							convert(UInt8, P.lineColor[4]),
							P.lineWidth
						)
		# close the shape
		WULinesAlphaWidth(P.win, 
						convert(Float64, vertices[1][1]), 
						convert(Float64, vertices[1][2]), 
						convert(Float64, vertices[P.sides][1]), 
						convert(Float64, vertices[P.sides][2]),
						convert(UInt8, P.lineColor[1]),
						convert(UInt8, P.lineColor[2]),
						convert(UInt8, P.lineColor[3]),
						convert(UInt8, P.lineColor[4]),
						P.lineWidth
					)
		end
	end	

end
#-==========================
"""
	setLineColor(various shape types, color)

Sets the outline color for various solid shapes (Rect, Ellipse, Circle, etc.).

NEED link to colors
```
"""
function setLineColor(solidShape::Union{Rect, Ellipse, Circle}, color::PsychoColor)
	solidShape._lineColor = colorToSDL(rect.win, color)
end
#-==========
"""
	setFillColor(various shape types, color)

Sets the fill color for various solid shapes (Rect, Ellipse, Circle, etc.) 

NEED link to colors
```
"""
function setFillColor(solidShape::Union{Rect, Ellipse, Circle}, color::PsychoColor)
	solidShape._fillColor = colorToSDL(rect.win, color)
end

#-=====================================================================================================
"""
	setPos(solidShape::Union{Rect, Ellipse, Circle, Polygon}, coordinates)

Set the position of the object, usually the center unless specified otherwise. 

See "Setter Functions" in side tab for more information.
"""
function setPos(solidShape::Union{Rect, Ellipse, Circle, Polygon}, coords::PsychoCoords)
	solidShape._pos = SDLcoords(solidShape.win, coords)
	solidShape.pos = coords
	if typeof(solidShape) == Circle
		solidShape.circlesEllipse._pos = solidShape._pos			# update the ellipse owned by the circle
		solidShape.circlesEllipse.pos = solidShape.pos			# update the ellipse owned by the circle
	end
end
#-======================================================================================================================

#-======================================================================================================================
#=
#----------# from https://stackoverflow.com/questions/38334081/how-to-draw-circles-arcs-and-vector-graphics-in-sdl

#draw one quadrant arc, and mirror the other 4 quadrants
function sdl_ellipse(win::Window, x0::Int64,  y0::Int64,  radiusX::Int64,  radiusY::Int64)

   # const pi::Float64  = 3.14159265358979323846264338327950288419716939937510
	piHalf::Float64 = π / 2.0; 		# half of pi

	#drew  28 lines with   4x4  circle with precision of 150 0ms
	#drew 132 lines with  25x14 circle with precision of 150 0ms
	#drew 152 lines with 100x50 circle with precision of 150 3ms
	precision::Int64 = 27 		# precision value; value of 1 will draw a diamond, 27 makes pretty smooth circles.
	theta::Float64 = 0;	 		# angle that will be increased each loop

	#starting point
	x::Int64  = int(radiusX * cos(theta))	#(Float64)radiusX * cos(theta)		# start point
	y::Int64  = int(radiusY * sin(theta))	#(float)radiusY * sin(theta)		# start point
	x1::Int64 = x
	y1::Int64 = y

	#repeat until theta >= 90;
	step::Float64  = piHalf/precision					#pih/(float)prec; 	# amount to add to theta each time (degrees)


	#for(theta=step;  theta <= pih;  theta+=step)//step through only a 90 arc (1 quadrant)
	for theta in step:step:piHalf							# step through only a 90 arc (1 quadrant)

		# get new point location
		x1 = int(radiusX * cos(theta) + 0.5)	# (float)radiusX * cosf(theta) + 0.5; # new point (+.5 is a quick rounding method)
		y1 = int(radiusY * sin(theta) + 0.5)	 # new point (+.5 is a quick rounding method)

		# draw line from previous point to new point, ONLY if point incremented
		if( (x != x1) || (y != y1) )			#only draw if coordinate changed
		
			SDL_RenderDrawLine(win.renderer, x0 + x, y0 - y,	x0 + x1, y0 - y1 );		# quadrant TR
			SDL_RenderDrawLine(win.renderer, x0 - x, y0 - y,	x0 - x1, y0 - y1 );		# quadrant TL
			SDL_RenderDrawLine(win.renderer, x0 - x, y0 + y,	x0 - x1, y0 + y1 );		# quadrant BL
			SDL_RenderDrawLine(win.renderer, x0 + x, y0 + y,	x0 + x1, y0 + y1 );		# quadrant BR
		end
		# save previous points
		x = x1		#;	//save new previous point
		y = y1		#;//save new previous point
	end
	#	arc did not finish because of rounding, so finish the arc
	if(x!=0)
	
		x=0;
		SDL_RenderDrawLine(win.renderer, x0 + x, y0 - y,	x0 + x1, y0 - y1 );		# quadrant TR
		SDL_RenderDrawLine(win.renderer, x0 - x, y0 - y,	x0 - x1, y0 - y1 );		# quadrant TL
		SDL_RenderDrawLine(win.renderer, x0 - x, y0 + y,	x0 - x1, y0 + y1 );		# quadrant BL
		SDL_RenderDrawLine(win.renderer, x0 + x, y0 + y,	x0 + x1, y0 + y1 );		# quadrant BR
	end
end


#-====================================================================

function draw(L::Line)
	#=
	SDL_SetRenderDrawColor(L.win.renderer, 
							L.lineColor[1], 
							L.lineColor[2], 
							L.lineColor[3], 
							L.opacity)
	SDL_RenderDrawLine( L.win.renderer, L.startPoint[1], L.startPoint[2], L.endPoint[1], L.endPoint[2])
	=#
#=
	thickLineRGBA( L.win.renderer, 
					L.startPoint[1], 
					L.startPoint[2], 
					L.endPoint[1], 
					L.endPoint[2],
					L.width, 
					L.lineColor[1],
					L.lineColor[2],
					L.lineColor[3],
					L.lineColor[4],
				)
=#
#=
	_aalineRGBA(L.win.renderer, 
					L.startPoint[1], 
					L.startPoint[2], 
					L.endPoint[1], 
					L.endPoint[2],
					L.lineColor[1],
					L.lineColor[2],
					L.lineColor[3],
					L.lineColor[4],
					true
				)
=#
#=
	DrawWuLine(L.win.renderer, 
					L.startPoint[1], 
					L.startPoint[2], 
					L.endPoint[1], 
					L.endPoint[2],
					L.lineColor[1],
					L.lineColor[2],
					L.lineColor[3],
					L.lineColor[4]
				)
=#
	if L.width == 1							# draw a single anti-aliased line
		WULinesAlpha(L.win, 
						convert(Float64, L.startPoint[1]), 
						convert(Float64, L.startPoint[2]), 
						convert(Float64, L.endPoint[1]), 
						convert(Float64, L.endPoint[2]),
						convert(UInt8, L.lineColor[1]),
						convert(UInt8, L.lineColor[2]),
						convert(UInt8, L.lineColor[3]),
						convert(UInt8, L.lineColor[4])
					)
#=		elseif L.width%2 == 0				# even number line width
			println("I haven't implemenet even number widths yet, so I'm giving you a line width of 1")
			WULinesAlpha(L.win, 
						convert(Float64, L.startPoint[1]), 
						convert(Float64, L.startPoint[2]), 
						convert(Float64, L.endPoint[1]), 
						convert(Float64, L.endPoint[2]),
						≈,
						convert(UInt8, L.lineColor[2]),
						convert(UInt8, L.lineColor[3]),
						convert(UInt8, L.lineColor[4])
					)	=#
		else										# odd nubmer will draw width-2 jaggy lines in the middle flanked by anti-aliased versions		
			println("I'm trying to draw a wide line ", L.width)
			deltaY = L.endPoint[2] - L.startPoint[2]
			deltaX = L.endPoint[1] - L.startPoint[1]

			radians = atan( deltaY / deltaX ) 
			angleDegrees = rad2deg(radians)-90		# yep, that's the pi-symbol for π.  Aint Julia cool!

			GeometricLength = round(getLineLength(L))
			centerX::Int64 =  round( (L.startPoint[1] + L.endPoint[1])/2)		# average, not local center round(L.width/2)
			centerY::Int64 = round( (L.startPoint[2] + L.endPoint[2])/2)		# average, not local center	round(GeometricLength/2)#
# 120, 825 for average
# 2, 677 for width and height /2
#centerX = convert(Int64, round( L.startPoint[2]/100))
#centerY = L.startPoint[2]
#centerX = 1000
#centerX = L.startPoint[1]
#centerY = L.startPoint[2]
#centerX = L.endPoint[1]
#centerX = L.endPoint[1]
centerX = L.startPoint[1]
centerY = L.startPoint[2]
println("center = ", centerX, ", ", centerY)
println("startPoint = ", L.startPoint[1], ", ", L.startPoint[2])
println("startPoint = ", L.endPoint[1], ", ", L.endPoint[2])
			#center = SDL_Point(Cint(centerX),  Cint(centerY))
			center = SDL_Point(Cint(0),  Cint(0))

			#center::SDL_Point = [centerX, centerY]
			SDL_SetRenderDrawColor(L.win.renderer, 
									L.lineColor[1], 
									L.lineColor[2], 
									L.lineColor[3], 
									L.lineColor[4])			
			if L.width > 1							# only one jaggy
				#SDL_RenderDrawLine( L.win.renderer, L.startPoint[1], L.startPoint[2], L.endPoint[1], L.endPoint[2])
				# 	(1) create surface the size of the line
				lineSurface = SDL_CreateRGBSurface(0, L.width, round(GeometricLength), 32,0,0,0,0)
println("GeometricLength = ", GeometricLength)
				SDL_SetSurfaceBlendMode(lineSurface, SDL_BLENDMODE_BLEND)
				# 	(2) Fill the surface with a rect
				#destinationRect = SDL_Rect(centerX, centerY, L.width, convert(UInt32, round(GeometricLength)) )	
				destinationRect = SDL_Rect(L.startPoint[1], L.startPoint[2], L.width, convert(UInt32, round(GeometricLength)) )	

				tempColor = MakeInt8Color(L.lineColor[1], L.lineColor[2], L.lineColor[3], L.lineColor[4])

#				SDL_FillRect(lineSurface::Ptr{SDL_Surface}, Ref{SDL_Rect}(lineRect), convert(UInt32, tempColor) )
				SDL_FillRect(lineSurface::Ptr{SDL_Surface}, C_NULL, convert(UInt32, tempColor) )			# C_NULL = fill entire surface
# this next part puts a notch at the Start end
	notchColor = MakeInt8Color(0, 0, 0,255)
	notchRect = SDL_Rect(0, 10, L.width,20)	
				SDL_FillRect(lineSurface::Ptr{SDL_Surface},  Ref{SDL_Rect}(notchRect), convert(UInt32, notchColor) )			# C_NULL = fill entire surface

	tempSurface = IMG_Load( "sec_hand.png" );
	if tempSurface == C_NULL
		println("*** error loading texture: sec_hand.png")
			println("current directory is ", pwd())
	end
	tagRect = SDL_Rect(0,0, 100, 4)			# used to color code the hands
	SDL_FillRect(tempSurface::Ptr{SDL_Surface}, Ref{SDL_Rect}(tagRect), convert(UInt32, tempColor) )
	tempSDLTexture = SDL_CreateTextureFromSurface( L.win.renderer, tempSurface );
	w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)					# These create C integer pointers: https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/
	SDL_QueryTexture(tempSDLTexture, C_NULL, C_NULL, w_ref, h_ref)			# get the attributes of a texture, such as width and height
	width = w_ref[]
	height = h_ref[]
	tempRect = SDL_Rect(L.startPoint[1], L.startPoint[2], width, height)		# 160, 160
#	tempRect = SDL_Rect(centerX, centerY, width, height)
#	tempPoint = SDL_Point(centerX, centerY)
#	tempPoint = SDL_Point(10, 10)
	tempPoint = SDL_Point(10, 10)
	angleDegrees2 = angleDegrees + 90		# positve 90 is down
println("angle of line: ", angleDegrees)
println("angle of arrow: ", angleDegrees2, "\n")
	SDL_RenderCopyEx( L.win.renderer, tempSDLTexture, C_NULL, Ref{SDL_Rect}(tempRect),  angleDegrees2, Ref{SDL_Point}(tempPoint), SDL_FLIP_NONE );

	SDL_FreeSurface( tempSurface );
#==#



#If think there is disagreement between the center of lineRect for SDLFillRect and SDL_RenderCopyEx
#function SDL_FillRect(dst, rect, color)
 #   ccall((:SDL_FillRect, libsdl2), Cint, (Ptr{SDL_Surface}, Ptr{SDL_Rect}, Uint32), dst, rect, color)

				# 	(3) copy it to a texture
				lineTexture = SDL_CreateTextureFromSurface(L.win.renderer, lineSurface)
				SDL_FreeSurface(lineSurface)									# Delete the surface, as we no longer need it.
				# 	(4) rotate it and copy to the window
#				SDL_RenderCopyEx(L.win.renderer, lineTexture, C_NULL, C_NULL, angleDegrees, Ref{SDL_Point}(center), SDL_FLIP_NONE)
#				SDL_RenderCopyEx(L.win.renderer, lineTexture,  Ref{SDL_Rect}(lineRect),  Ref{SDL_Rect}(lineRect), angleDegrees, Ref{SDL_Point}(center), SDL_FLIP_NONE)
				SDL_RenderCopyEx(L.win.renderer, lineTexture,  C_NULL,  Ref{SDL_Rect}(destinationRect), angleDegrees, Ref{SDL_Point}(center), SDL_FLIP_NONE)

	#			SDL_RenderCopyEx( renderer, timeTexture.texture, C_NULL, Ref{SDL_Rect}(timeTexture.rect),  timeTexture.angle, Ref{SDL_Point}(timeTexture.center), SDL_FLIP_NONE );

#				SDL_RenderCopyEx(L.win.renderer, lineTexture,  C_NULL,  Ref{SDL_Rect}(destinationRect), angleDegrees, C_NULL, SDL_FLIP_NONE)
				# 	(5) destroy it and clean up
				SDL_DestroyTexture(lineTexture)									# no longer need the texture, so delete it
			end
#=
			for inner in 1:L.width -2
should probably countdown from top, middle, bottom...

	SDL_RenderDrawLine( L.win.renderer, L.startPoint[1], L.startPoint[2], L.endPoint[1], L.endPoint[2])
			end
=#
		end
#prinln(startPoint, endPoint)
#	thickLineRGBA(renderer, x1, y1, x2, y2, width, r, g, b, a)
end
=#