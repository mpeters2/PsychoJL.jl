export imageStim, scaleToWidth, scaleToWidth2, scaleToHeight, drawCache, draw


#-==================================================================
"""
	ImageStim()

Constructor for an ImageStim object

**Constructor inputs:**
  * win::Window\n
  * imageName::String.......*includes path*\n
  * pos::Vector{Int64}\n

**Optional constructor inputs:**
  * image::Ptr{SDL_Texture}
  * width::Int64
  * height::Int64

**Methods:**
  * draw()

**Notes:**
width and height are automatically calculated during ImageStim construction.
"""
mutable struct ImageStim	#{T}
	win::Window
	imageName::String
	pos::PsychoCoords
	image::Ptr{SDL_Texture}
	width::Union{Float64, Int64, Int32}							# this will need to change to floats for Psychopy height coordiantes
	height::Union{Float64, Int64, Int32}
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	_magnification::Float64					# used with cache
	_orientation::Float64
	_magSet::Bool							# used with cache
	_oriSet::Bool
	_pos::Vector{Int64}
	_width::Int64
	_height::Int64
#	opacity::Int64							# these will need to change to floats to handle Psychopy colors

	#----------
	function ImageStim(	win::Window,
					imageName::String,
					pos::PsychoCoords = [20,20];						# just far enough to be visible
					image = C_NULL,
					width = 0,							# this will need to change to floats for Psychopy height coordiantes
					height = 0,
					horizAlignment::Int64 = 0,
					vertAlignment::Int64 = 0,		
					#			opacity::Int64 = 255							# these will need to change to floats to handle Psychopy colors
			)
		if imageName != ""													# if a file name was given
			surface = IMG_Load(imageName)									# loads a picture from a file into a surface buffer. Surfaces are usually transfered to something else
			image = SDL_CreateTextureFromSurface(win.renderer, surface)		# Now we create a texture from our intial surface
			if image == C_NULL
				error("Could not open image file: ", imageName)
			end
			SDL_FreeSurface(surface)									# Delete the surface, as we no longer need it.
		elseif image != C_NULL
			println("creating an imageStim from texture")
		else
			error("Expected an fileName or an SDL_Texture when creating a new ImageStim")
		end

		w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)					# These create C integer pointers: https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/
		_pos = SDLcoords(win, pos)		
		SDL_QueryTexture(image, C_NULL, C_NULL, w_ref, h_ref)			# get the attributes of a texture, such as width and height
		w, h = w_ref[], h_ref[]	
		coordSpaceSize = SDLsize(win, [w, h])
		# All image sizes are in pixels
		# we need to set _width and _height to pixels
		# and width and height to the coordinate space equivalent
		percentSpaces = [ "LT_Percent", "LB_Percent", "PsychoPy"]

		if win.coordinateSpace == "LT_Pix"
			_w = w
			_h = h
		elseif win.coordinateSpace in percentSpaces
			_w = w
			_h = h
			percentSize =  ConvertPixelSizeToFloats(win, [_w,_h])
			w = percentSize[1]
			h = percentSize[2]
		end

		
		#-------
		# change the position so that it draws at the center of the image and not the top-left
		#pos[1] -= w÷2
		#pos[2] -= h÷2
		#-------
		new(win, 
			imageName,
			pos,	#			[ round(Int64, winW/2), round(Int64, winH/2)],	
			image,
			w, #coordSpaceSize[1],							# this will need to change to floats for Psychopy height coordiantes
			h, #coordSpaceSize[2],
			horizAlignment,
			vertAlignment,
			1.0,
			0.0,
			false,
			false,
			_pos,
			_w,
			_h
			)
	end
end
#----------
"""
	draw(theImageStim::ImageStim; magnification::Float64)

Draws an ImageStim to the back buffer.

**Inputs:**
 * theImageStim::ImageStim

 **Optional Inputs:**
 * magnification::Float64
 * orientation::Float64 (degrees)

"""
function draw(theImageStim::ImageStim; magnification::Float64 = 1.0, orientation::Float64 =0.0)
	#-- Below is for flipCache
	if theImageStim._magSet == true
		magnification = theImageStim._magnification
		#theImageStim._magnification = 1.0				# reset to default magnification
		#theImageStim._magSet = false
	end
	if theImageStim._oriSet == true
		orientation = theImageStim._orientation
		#theImageStim._orientation = 0.0				# reset to default magnification
		#theImageStim._oriSet = false
	end
	#----
	if magnification == 0
		centX = theImageStim._pos[1] - theImageStim.width÷2
		centY = theImageStim._pos[2] - theImageStim._height÷2
		dest_rect = Ref(SDL_Rect(centX, centY, theImageStim._width, theImageStim._height))
	else
		centX = theImageStim._pos[1] - (theImageStim._width * magnification)÷2
		centY = theImageStim._pos[2] - (theImageStim._height * magnification)÷2
		dest_rect = Ref(SDL_Rect(centX, 
								centY, 
								round(Int64, theImageStim._width * magnification), 
								round(Int64, theImageStim._height * magnification)
								)
						)
	end

	#~~~~~~~~~~~~~~~~~~

	if theImageStim.vertAlignment == -1											# top anchored
		y = theImageStim._pos[2]
		cy  = 0
	elseif theImageStim.vertAlignment == 0											# center anchored
		y = theImageStim._pos[2] - round(Int64,(theImageStim._height * magnification)/2)	#
		cy = (theImageStim._height * magnification)÷2
	elseif theImageStim.vertAlignment == +1										# bottom anchored
		y = theImageStim._pos[2] - (theImageStim._height * magnification)
		if y < singleHeight + 5													# enforce a minimum height so it doesn't go off the top.
			y = 5
		end
		cy = (theImageStim._height * magnification)
	else
		error("invalid text vertical text alignment parameter")
	end
	#---------
	if theImageStim.horizAlignment == -1											# left anchored
		x = theImageStim._pos[1]
		cx = 0
	elseif theImageStim.horizAlignment == 0											# center justification
		x = theImageStim._pos[1] - round(Int64, (theImageStim._width * magnification)/2)
		cx = (theImageStim._width * magnification) ÷2
	elseif theImageStim.horizAlignment == +1										# right anchored
		x = theImageStim._pos[1] - (theImageStim._width * magnification)
		cx = (theImageStim._width * magnification)
	else
		error("invalid text horizontal text alignment parameter")
	end

	#~~~~~~~~~~~~~~~~~~
	if orientation == 0.0
		SDL_RenderCopy(theImageStim.win.renderer, theImageStim.image, C_NULL, dest_rect)
	else
		#center = SDL_Point(Cint(centX),  Cint(centY))
		center = SDL_Point(cx, cy)
		SDL_RenderCopyEx(theImageStim.win.renderer, theImageStim.image,  C_NULL,  dest_rect, orientation, Ref{SDL_Point}(center), SDL_FLIP_NONE)
	end
	#println("center = ", centX, ", ", centY)
	#println("dimensions = ", theImageStim._width, ", ", theImageStim._height)
end
#-================================================================================
"""
	drawCache(theImageStim::ImageStim; magnification::Float64)

Draws an ImageStim to the back buffer and places a copy in the window's cache.

**Inputs:**
 * theImageStim::ImageStim

 **Optional Inputs:**
 * magnification::Float64
 * orientation::Float64 (degrees)

"""
function drawCache(theImageStim::ImageStim; magnification::Float64 = 1.0, orientation::Float64 =0.0)
	theImageStim._magnification = magnification
	theImageStim._orientation = orientation
	theImageStim._magSet = true					# this gives a memory for these values when drawFlip is called later
	theImageStim._oriSet = true

	push!(theImageStim.win.cachedObjects, theImageStim) 

	draw(theImageStim; magnification, orientation)
println("\t\t", theImageStim.pos,", ", theImageStim._orientation)
end
#-================================================================================
"""
	 setPos(image::ImageStim, coords::, coordinates)

Set the position of the image, usually the center unless specified otherwise. 

See "Setter Functions" in side tab for more information.
"""
function setPos(image::ImageStim, coords::PsychoCoords)
	image._pos = SDLcoords(image.win, coords)
	image.pos = coords

end
#-================================================================================
"""
	 scaleToWidth(theImageStim::ImageStim, newWidth::Int64)

Scales the image to a specific width in pixels.

"""
function scaleToWidth(theImageStim::ImageStim, newWidth::Int64)

	ratio = newWidth / theImageStim.width
	theImageStim.height = round(Int64, theImageStim.height * ratio)
	theImageStim.width = newWidth

	_size = SDLsize(theImageStimwin, [theImageStim.width, theImageStim.height])
	theImageStim._width = _size[1]
	theImageStim._height = _size[2]
end
#-------------------------
"""
	 scaleToWidth2(theImageStim::ImageStim, newWidth::Int64)

Scales the image to a specific width in various coordinate spaces.

"""
function scaleToWidth2(theImageStim::ImageStim, newWidth::Union{Int64, Float64})
	# convert whatever width to pixels
	percentSpaces = [ "LT_Percent", "LB_Percent", "PsychoPy"]
	#=
	if theImageStim.win.coordinateSpace == "LT_Pix"
		newWidth2 = theImageStim._width
	elseif theImageStim.win.coordinateSpace in percentSpaces
		newWidth2 = theImageStim._width
	end
	=#
	#newWidth2 = theImageStim._width ÷ theImageStim.win.size[2]		# < no, this is wrong, i think...
	#temp = SDLsize(theImageStim.win, [0, newWidth] )
	#newWidth2 = temp[2]
	#ratio = newWidth2 / theImageStim.width							# ratio of old to new ._width is the SDL's pixel coordinate space
	ratio = newWidth / theImageStim.width							# ratio of old to new ._width is the SDL's pixel coordinate space
	heightTemp = theImageStim.height * ratio
	widthTemp = newWidth
	
	#coordSpaceSize = SDLsize(theImageStim.win, [widthTemp, heightTemp])
	theImageStim.height = widthTemp 
	theImageStim.width= heightTemp 

	theImageStim._width = round(Int64, widthTemp * theImageStim.win.size[2]	)	#coordSpaceSize[1]
	theImageStim._height = round(heightTemp * theImageStim.win.size[2] )			#coordSpaceSize[2]
end
#-------------------------
"""
	 scaleToHeight(theImageStim::ImageStim, newWidth::Int64)

Scales the image to a specific height in pixels.

"""
function scaleToHeight(theImageStim::ImageStim, newHeight::Int64)

	ratio = newHeight / theImageStim.height
	theImageStim.width = round(Int64, theImageStim.width * ratio)
	theImageStim.height = newHeight

	_size = SDLsize(win, [theImageStim.width, theImageStim.height])
	theImageStim._width = _size[1]
	theImageStim._height = _size[2]
end
#-================================================================================

# Need: crop, rotate, set size

function draw_original(theImageStim::ImageStim; magnification::Float64 = 1.0, orientation::Float64 =0.0)

	if magnification == 0
		centX = theImageStim._pos[1] - theImageStim.width÷2
		centY = theImageStim._pos[2] - theImageStim.height÷2
		dest_rect = Ref(SDL_Rect(centX, centY, theImageStim.width, theImageStim.height))
	else
		centX = theImageStim._pos[1] - (theImageStim.width * magnification)÷2
		centY = theImageStim._pos[2] - (theImageStim.height * magnification)÷2
		dest_rect = Ref(SDL_Rect(centX, 
								centY, 
								theImageStim.width * magnification, 
								theImageStim.height * magnification
								)
						)
	end
#	dest_rect[] = SDL_Rect(theImageStim.pos[1], theImageStim.pos[2], theImageStim.width, theImageStim.height)
#println(theImageStim.pos[1],", ",theImageStim.pos[2],", ",theImageStim.width,", ",theImageStim.height)
	if orientation == 0.0
		SDL_RenderCopy(theImageStim.win.renderer, theImageStim.image, C_NULL, dest_rect)
	else
		center = SDL_Point(Cint(centX),  Cint(centY))
		SDL_RenderCopyEx(theImageStim.win.renderer, theImageStim.image,  C_NULL,  dest_rect, orientation, Ref{SDL_Point}(center), SDL_FLIP_NONE)
	end
end