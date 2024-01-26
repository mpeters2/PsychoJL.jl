# Translation of psycopy window file to Julia

export Window, closeAndQuitPsychoJL, flip, closeWinOnly, hideWindow, dogcow
#


int(x) = floor(Int, x)				# for typecasting floats to ints when indexing




"""
	Window()

Constructor for a Window object


**Constructor inputs:**
  * size::MVector{2, Int64}
  * fullScreen::Bool
**Optional constructor inputs:**
  * color::MVector{3, Int64}
  * colorSpace::String  .......*Future.  Not implemented yet*
  * pos::MVector{2, Float64}	......*position*
  * timeScale::String	.......*default = "milliseconds"*
  * title::String	......*default = "Window"*

**Full list of fields**
  * win::Ptr{SDL_Window}
  * size::MVector{2, Int64}		
  * pos::MVector{2, Float64}	......*position*
  * color::MVector{3, Int64}			
  * colorSpace::String				
  * renderer::Ptr{SDL_Renderer}
  * font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * boldFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * italicFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * event::Base.RefValue{SDL_Event} 		
  * fullScreen::Bool
  * timeScale::String .......*defaults is milliseconds.  Other option is seconds*
  * title::String
  *  startTime::Float64 .......*global proximy for startTime() and stopTime()*

**Methods:**
  * close()
  * closeWinOnly()
  * flip()
  * hideWindow()
"""
mutable struct Window	#{T}
	win::Ptr{SDL_Window}
	size::MVector{2, Int64}		# window size; static array (stay away from tuples)
	pos::MVector{2, Float64}		# position
	color::MVector{3, Int64}			# these will be Psychopy colors
	colorSpace::String				# might need to revist for colors.jl
	renderer::Ptr{SDL_Renderer}
	font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	boldFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	italicFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	event::Base.RefValue{SDL_Event} 		#SDL_Event
	fullScreen::Bool
	timeScale::String
	title::String
	startTime::Float64

	#----------
	function Window(size,			# window size; static array (stay away from tuples)
					fullScreen = false;
					color = fill(0, (3)),					# these will be Psychopy colors
					colorSpace = "rgb",						# might need to revist for colors.jl
					pos = [SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED],		# position
					timeScale = "milliseconds",
					title = "Window"
				)
		winPtr = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, size[1], size[2], SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI )#| SDL_WINDOW_INPUT_GRABBED)

		if timeScale != "seconds" || timeScale != "milliseconds"
			println("* timeScale can only be 'seconds' or 'milliseconds'.")
			println("** ", timeScale, " was given as the value for timeScale.")
			println("* default to milliseconds for timing.")
			timeScale = "milliseconds"
		end


		SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "2");
		renderer = SDL_CreateRenderer(winPtr, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
	#	SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)

		baseFilePath = pwd()
		baseFilePath =joinpath(baseFilePath,"fonts") 
		baseFilePath =joinpath(baseFilePath,"Roboto") 
		fontFilePath =joinpath(baseFilePath,"Roboto-Regular.ttf") 

	#	baseFilePath =joinpath(baseFilePath,"Noto_Serif")
	#	fontFilePath =joinpath(baseFilePath,"NotoSerif-VariableFont_wdth,wght.ttf")
		#	font = 	TTF_OpenFont("/Users/MattPetersonsAccount/Documents/Development/Julia/PsychoJL/sans.ttf", 24);

		font = 	TTF_OpenFont(fontFilePath, 30);

		if font == C_NULL
			if isfile(fontFilePath) == false
				error("Could not open file path: " * fontFilePath)
			end
			error("*** Error: font is NULL")
		end
		#----------------
		# canned BOLD versions look better than asking SDL to bold the font
		fontFilePath =joinpath(baseFilePath,"Roboto-Bold.ttf")

		boldFont = 	TTF_OpenFont(fontFilePath, 30);

		if boldFont == C_NULL
			if isfile(fontFilePath) == false
				error("Could not open file path: " * fontFilePath)
			end
			error("*** Error: font is NULL")
		end
		#-----------
		# canned italic versions look better than asking SDL to bold the font
		fontFilePath =joinpath(baseFilePath,"Roboto-Italic.ttf")

		italicFont = 	TTF_OpenFont(fontFilePath, 30);

		if italicFont == C_NULL
			if isfile(fontFilePath) == false
				error("Could not open file path: " * fontFilePath)
			end
			error("*** Error: font is NULL")
		end
		#----------------
		event = Ref{SDL_Event}()

		if fullScreen == true
			SDL_SetWindowFullscreen(winPtr, SDL_WINDOW_FULLSCREEN)
		end
		SDL_PumpEvents()					# this erases whatever random stuff was in the backbuffer
		SDL_RenderClear(renderer)			# <<< Had to do this to clear out the noise.
		
		new(winPtr, 
			size, 
			pos, 
			color, 
			colorSpace, 
			renderer,
			font,
			boldFont,
			italicFont,
			event,
			fullScreen,
			timeScale,
			title
			)


	end
end
#----------
"""
	closeAndQuitPsychoJL(win::Window)

Attempts to close a PsychoJL Window and quit SDL.
"""
function closeAndQuitPsychoJL(win::Window)
   # SDL_DestroyTexture(tex)			# this nees to get more complicated, where it loops through a list of textures
    SDL_DestroyRenderer(myWin.renderer)		# this nees to get more complicated, where it loops through a list of renderers
	SDL_DestroyWindow(myWin.win)
	println("pre SDL_Quit")
	SDL_Quit()
end
#----------
"""
	flip(win::Window)

Flips the offscreen buffer on screen.  In other words, all of the visual objects that you have drawn offscreen
prior to the flip will now become visible.
"""
function flip(win::Window)
	SDL_RenderPresent(win.renderer)
	SDL_PumpEvents()
	SDL_SetRenderDrawColor(win.renderer, win.color[1], win.color[2], win.color[3], 255)
	SDL_RenderClear(win.renderer)			# <<< Had to do this to clear out the noise.
end
#----------
"""
	closeWinOnly(win::Window)

Attempts to close a PsychoJL Window without quiting SDL.
"""
function closeWinOnly(win::Window)
	SDL_DestroyRenderer(win.renderer)		# this nees to get more complicated, where it loops through a list of renderers

	SDL_DestroyWindow(win.win)
end
#----------
"""
	hideWindow(win::Window)

Attempts to hide a PsychoJL Window.
"""
function hideWindow(win::Window)
	SDL_HideWindow(win.win)
end


#-===============================================
# /System/Library/Fonts


#=
mutable struct Window	#{T}
	win::Ptr{SDL_Window}
	size::MVector{2, Int64}		# window size; static array (stay away from tuples)
	pos::MVector{2, Float64}		# position
	color::MVector{3, Int64}			# these will be Psychopy colors
	colorSpace::String				# might need to revist for colors.jl
	renderer::Ptr{SDL_Renderer}
	font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	boldFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	italicFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	event::Base.RefValue{SDL_Event} 		#SDL_Event
	fullScreen::Bool
	timeScale::String
	title::String
end
#----------
function window(	size,			# window size; static array (stay away from tuples)
				fullScreen = false;
				color = fill(0, (3)),					# these will be Psychopy colors
				colorSpace = "rgb",						# might need to revist for colors.jl
				pos = [SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED],		# position
				timeScale = "milliseconds",
				title = "Window"
			)
	winPtr = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, size[1], size[2], SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI )#| SDL_WINDOW_INPUT_GRABBED)

	if timeScale != "seconds" || timeScale != "milliseconds"
		println("**** timeScale can only be 'seconds' or 'milliseconds'.")
		println("****", timeScale, " was given as the value for timeScale.")
		println("**** default to milliseconds for timing.")
		timeScale = "milliseconds"
	end


	SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "2");
	renderer = SDL_CreateRenderer(winPtr, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
#	SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)

	baseFilePath = pwd()
	baseFilePath =joinpath(baseFilePath,"fonts") 
	baseFilePath =joinpath(baseFilePath,"Roboto") 
	fontFilePath =joinpath(baseFilePath,"Roboto-Regular.ttf") 

#	baseFilePath =joinpath(baseFilePath,"Noto_Serif")
#	fontFilePath =joinpath(baseFilePath,"NotoSerif-VariableFont_wdth,wght.ttf")
	#	font = 	TTF_OpenFont("/Users/MattPetersonsAccount/Documents/Development/Julia/PsychoJL/sans.ttf", 24);

	font = 	TTF_OpenFont(fontFilePath, 30);

	if font == C_NULL
		if isfile(fontFilePath) == false
			error("Could not open file path: " * fontFilePath)
		end
		error("*** Error: font is NULL")
	end
	#----------------
	# canned BOLD versions look better than asking SDL to bold the font
	fontFilePath =joinpath(baseFilePath,"Roboto-Bold.ttf")

	boldFont = 	TTF_OpenFont(fontFilePath, 30);

	if boldFont == C_NULL
		if isfile(fontFilePath) == false
			error("Could not open file path: " * fontFilePath)
		end
		error("*** Error: font is NULL")
	end
	#-----------
	# canned italic versions look better than asking SDL to bold the font
	fontFilePath =joinpath(baseFilePath,"Roboto-Italic.ttf")

	italicFont = 	TTF_OpenFont(fontFilePath, 30);

	if italicFont == C_NULL
		if isfile(fontFilePath) == false
			error("Could not open file path: " * fontFilePath)
		end
		error("*** Error: font is NULL")
	end
	#----------------
	event = Ref{SDL_Event}()

	winStruct = Window(winPtr, 
					size, 
					pos, 
					color, 
					colorSpace, 
					renderer,
					font,
					boldFont,
					italicFont,
					event,
					fullScreen,
					timeScale,
					title)
	if fullScreen == true
		SDL_SetWindowFullscreen(winStruct.win, SDL_WINDOW_FULLSCREEN)
	end
	SDL_PumpEvents()					# this erases whatever random stuff was in the backbuffer
	SDL_RenderClear(renderer)			# <<< Had to do this to clear out the noise.
	return winStruct
end
=#


#=

"""
	Window()

Constructor for a Window object

constructor inputs: 
  * size::MVector{2, Int64}
  * fullScreen::Bool
optional constructor inputs:
  * color::MVector{3, Int64}
  * colorSpace::String					# Future.  Not implemented yet
  * pos::MVector{2, Float64}		# position
  * timeScale::String		# default = "milliseconds",
  * title::String		# default = "Window"

parameters:
  * win::Ptr{SDL_Window}
  * size::MVector{2, Int64}		
  * pos::MVector{2, Float64}		# position
  * color::MVector{3, Int64}			# these will be Psychopy colors
  * colorSpace::String				# might need to revist for colors.jl
  * renderer::Ptr{SDL_Renderer}
  * font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * boldFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * italicFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * event::Base.RefValue{SDL_Event} 		#SDL_Event
  * fullScreen::Bool
  * timeScale::String
  * title::String

"""


=#