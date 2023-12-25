# Translation of psycopy window file to Julia

export window, close, flip, Window
#


int(x) = floor(Int, x)				# for typecasting floats to ints when indexing



mutable struct Window	#{T}
	win::Ptr{SDL_Window}
	size::MVector{2, Int64}		# window size; static array (stay away from tuples)
	pos::MVector{2, Float64}		# position
	color::MVector{3, Int64}			# these will be Psychopy colors
	colorSpace::String				# might need to revist for colors.jl
	renderer::Ptr{SDL_Renderer}
	font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	event::Base.RefValue{SDL_Event} 		#SDL_Event
	fullScreen::Bool
end
#----------
function window(	size,			# window size; static array (stay away from tuples)
				fullScreen = false;
				color = fill(0, (3)),					# these will be Psychopy colors
				colorSpace = "rgb",						# might need to revist for colors.jl
				pos = [SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED],		# position
				
			)
	winPtr = SDL_CreateWindow("Game", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1000, 1000, SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI)

	SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "2");
	renderer = SDL_CreateRenderer(winPtr, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
#	SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)

	font = 	TTF_OpenFont("/Users/MattPetersonsAccount/Documents/Development/Julia/PsychoJL/sans.ttf", 24);
#	if font 
	if font == C_NULL
		println("*** Error: font is NULL")
	end
	event = Ref{SDL_Event}()

	winStruct = Window(winPtr, 
					size, 
					pos, 
					color, 
					colorSpace, 
					renderer,
					font,
					event,
					fullScreen)
	if fullScreen == true
		SDL_SetWindowFullscreen(winStruct.win, SDL_WINDOW_FULLSCREEN)
	end
	SDL_PumpEvents()					# this erases whatever random stuff was in the backbuffer
	SDL_RenderClear(renderer)			# <<< Had to do this to clear out the noise.
	return winStruct
end
#----------
function close(win::Window)
   # SDL_DestroyTexture(tex)			# this nees to get more complicated, where it loops through a list of textures
   # SDL_DestroyRenderer(renderer)		# this nees to get more complicated, where it loops through a list of renderers
	SDL_DestroyWindow(myWin.win)
	println("pre SDL_Quit")
	SDL_Quit()
end
#----------
function flip(win::Window)
	SDL_RenderPresent(win.renderer)
	SDL_PumpEvents()
	SDL_SetRenderDrawColor(win.renderer, win.color[1], win.color[2], win.color[3], 255)
	SDL_RenderClear(win.renderer)			# <<< Had to do this to clear out the noise.
end
#-===============================================
