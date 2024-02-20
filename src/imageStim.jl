export imageStim, scaleToWidth



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
	width::Int64							# this will need to change to floats for Psychopy height coordiantes
	height::Int64
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	_pos::Vector{Int64}	
#	opacity::Int64							# these will need to change to floats to handle Psychopy colors

	#----------
	function ImageStim(	win::Window,
					imageName::String,
					pos::PsychoCoords = [20,20];						# just far enough to be visible
					width = 0,							# this will need to change to floats for Psychopy height coordiantes
					height = 0,
					horizAlignment::Int64 = 0,
					vertAlignment::Int64 = 0,		
					#			opacity::Int64 = 255							# these will need to change to floats to handle Psychopy colors
			)
		surface = IMG_Load(imageName)		# loads a picture from a file into a surface buffer. Surfaces are usually transfered to something else
		image = SDL_CreateTextureFromSurface(win.renderer, surface)		# Now we create a texture from our intial surface
		if image == C_NULL
			error("Could not open image file: ", imageName)
		end
		SDL_FreeSurface(surface)									# Delete the surface, as we no longer need it.

		w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)					# These create C integer pointers: https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/
		SDL_QueryTexture(image, C_NULL, C_NULL, w_ref, h_ref)			# get the attributes of a texture, such as width and height
		w, h = w_ref[], h_ref[]	
		_pos = SDLcoords(win, pos)
		#-------
		# change the position so that it draws at the center of the image and not the top-left
		#pos[1] -= w÷2
		#pos[2] -= h÷2

		#-------
		new(win, 
			imageName,
			pos,	#			[ round(Int64, winW/2), round(Int64, winH/2)],	
			image,
			w,							# this will need to change to floats for Psychopy height coordiantes
			h,
			horizAlignment,
			vertAlignment,
			_pos
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

	if magnification == 0
		centX = theImageStim._pos[1] - theImageStim.width÷2
		centY = theImageStim._pos[2] - theImageStim.height÷2
		dest_ref = Ref(SDL_Rect(centX, centY, theImageStim.width, theImageStim.height))
	else
		centX = theImageStim._pos[1] - (theImageStim.width * magnification)÷2
		centY = theImageStim._pos[2] - (theImageStim.height * magnification)÷2
		dest_ref = Ref(SDL_Rect(centX, 
								centY, 
								theImageStim.width * magnification, 
								theImageStim.height * magnification
								)
						)
	end

#~~~~~~~~~~~~~~~~~~

	if theImageStim.vertAlignment == -1											# top anchored
		y = theImageStim._pos[2]
		cy  = 0
	elseif theImageStim.vertAlignment == 0											# center anchored
		y = theImageStim._pos[2] - round(Int64,(theImageStim.height * magnification)/2)	#
		cy = (theImageStim.height * magnification)÷2
	elseif theImageStim.vertAlignment == +1										# bottom anchored
		y = theImageStim._pos[2] - (theImageStim.height * magnification)
		if y < singleHeight + 5													# enforce a minimum height so it doesn't go off the top.
			y = 5
		end
		cy = (theImageStim.height * magnification)
	else
		error("invalid text vertical text alignment parameter")
	end
	#---------
	if theImageStim.horizAlignment == -1											# left anchored
		x = theImageStim._pos[1]
		cx = 0
	elseif theImageStim.horizAlignment == 0											# center justification
		x = theImageStim._pos[1] - round(Int64, (theImageStim.width * magnification)/2)
		cx = (theImageStim.width * magnification) ÷2
	elseif theImageStim.horizAlignment == +1										# right anchored
		x = theImageStim._pos[1] - (theImageStim.width * magnification)
		cx = (theImageStim.width * magnification)
	else
		error("invalid text horizontal text alignment parameter")
	end

#~~~~~~~~~~~~~~~~~~
	if orientation == 0.0
		SDL_RenderCopy(theImageStim.win.renderer, theImageStim.image, C_NULL, dest_ref)
	else
		#center = SDL_Point(Cint(centX),  Cint(centY))
		center = SDL_Point(cx, cy)
		SDL_RenderCopyEx(theImageStim.win.renderer, theImageStim.image,  C_NULL,  dest_ref, orientation, Ref{SDL_Point}(center), SDL_FLIP_NONE)
	end
	println("center = ", centX, ", ", centY)
	println("dimensions = ", theImageStim.width, ", ", theImageStim.height)
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
end
#-================================================================================

# Need: crop, rotate, set size

function draw_original(theImageStim::ImageStim; magnification::Float64 = 1.0, orientation::Float64 =0.0)

	if magnification == 0
		centX = theImageStim._pos[1] - theImageStim.width÷2
		centY = theImageStim._pos[2] - theImageStim.height÷2
		dest_ref = Ref(SDL_Rect(centX, centY, theImageStim.width, theImageStim.height))
	else
		centX = theImageStim._pos[1] - (theImageStim.width * magnification)÷2
		centY = theImageStim._pos[2] - (theImageStim.height * magnification)÷2
		dest_ref = Ref(SDL_Rect(centX, 
								centY, 
								theImageStim.width * magnification, 
								theImageStim.height * magnification
								)
						)
	end
#	dest_ref[] = SDL_Rect(theImageStim.pos[1], theImageStim.pos[2], theImageStim.width, theImageStim.height)
#println(theImageStim.pos[1],", ",theImageStim.pos[2],", ",theImageStim.width,", ",theImageStim.height)
	if orientation == 0.0
		SDL_RenderCopy(theImageStim.win.renderer, theImageStim.image, C_NULL, dest_ref)
	else
		center = SDL_Point(Cint(centX),  Cint(centY))
		SDL_RenderCopyEx(theImageStim.win.renderer, theImageStim.image,  C_NULL,  dest_ref, orientation, Ref{SDL_Point}(center), SDL_FLIP_NONE)
	end
end