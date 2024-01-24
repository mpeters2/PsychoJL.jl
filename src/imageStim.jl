export imageStim



#-==================================================================
mutable struct ImageStim	#{T}
	win::Window
	imageName::String
	pos::Vector{Int64}
	image::Ptr{SDL_Texture}
	width::Int64							# this will need to change to floats for Psychopy height coordiantes
	height::Int64

#	opacity::Int64							# these will need to change to floats to handle Psychopy colors

	#----------
	function ImageStim(	win::Window,
					imageName::String,
					pos = [20,20];						# just far enough to be visible
					width = 0,							# this will need to change to floats for Psychopy height coordiantes
					height = 0
		#			opacity::Int64 = 255							# these will need to change to floats to handle Psychopy colors
			)
		surface = IMG_Load(imageName)		# loads a picture from a file into a surface buffer. Surfaces are usually transfered to something else
		image = SDL_CreateTextureFromSurface(win.renderer, surface)		# Now we create a texture from our intial surface
		if image == C_NULL
			error("Could not open image file")
		end
		SDL_FreeSurface(surface)									# Delete the surface, as we no longer need it.

		w_ref, h_ref = Ref{Cint}(0), Ref{Cint}(0)					# These create C integer pointers: https://docs.julialang.org/en/v1/manual/calling-c-and-fortran-code/
		SDL_QueryTexture(image, C_NULL, C_NULL, w_ref, h_ref)			# get the attributes of a texture, such as width and height
		w, h = w_ref[], h_ref[]	
#println(w_ref[],", ",h_ref[])
		#-------
#println(typeof(win))
#println(typeof(w_ref))
#println(typeof(h_ref))
		SDL_GetWindowSize(win.win, w_ref, h_ref)
		winW, winH = w_ref[], h_ref[]
		#-------
		new(win, 
			imageName,
			[ convert(Int64, winW/2), convert(Int64, winH/2)],
			image,
			w,							# this will need to change to floats for Psychopy height coordiantes
			h
			)
	end
end
#----------
function draw(theImageStim::ImageStim; magnification::Float64)

	if magnification == 0
		dest_ref = Ref(SDL_Rect(theImageStim.pos[1], theImageStim.pos[2], theImageStim.width, theImageStim.height))
	else
		dest_ref = Ref(SDL_Rect(theImageStim.pos[1], 
								theImageStim.pos[2], 
								theImageStim.width * magnification, 
								theImageStim.height * magnification
								)
						)
	end
#	dest_ref[] = SDL_Rect(theImageStim.pos[1], theImageStim.pos[2], theImageStim.width, theImageStim.height)
#println(theImageStim.pos[1],", ",theImageStim.pos[2],", ",theImageStim.width,", ",theImageStim.height)
	SDL_RenderCopy(theImageStim.win.renderer, theImageStim.image, C_NULL, dest_ref)	
end
