export Window, closeAndQuitPsychoJL, flip, closeWinOnly, hideWindow
export getPos, getSize, setFullScreen, getNativeSize, getCenter
export mouseVisible, getScreenShot, flipCache, flip2
#



int(x) = floor(Int, x)				# for typecasting floats to ints when indexing
#=
#..........................................................
using Libdl
#:::::::::::::::
foundThing = find_library("SDL2")
println("find_library results: '", foundThing, "'\n")

#:::::::::::::::


println(pwd())

if !occursin("src", pwd())  			# switches the path if necessary
	cd("src")
	println(pwd())
end

# create library pointer
lib = dlopen("libSDLReadPixels")

# create function pointer
func = dlsym(lib, "SDLreadPixels")			# lib is our library pointer, "SDLreadPixels" is the name of our function

#create wrapper
function SDLreadPixels(renderer::Ptr{SDL_Renderer})
	#ccall(func, Cint, (Cint, Cint), x, y)
	@ccall $func(renderer::Ptr{SDL_Renderer}):: Ptr{SDL_Surface}
end
=#
#..........................................................

#=
Reason: tried: '/Users/MattPetersonsAccount/.julia/juliaup/julia-1.10.0+0.aarch64.apple.darwin14/lib/julia/SDL2.framework/Versions/A/SDL2' (no such file), 
				'/Users/MattPetersonsAccount/.julia/juliaup/julia-1.10.0+0.aarch64.apple.darwin14/lib/julia/../SDL2.framework/Versions/A/SDL2' (no such file), 
				'/Users/MattPetersonsAccount/.julia/juliaup/julia-1.10.0+0.aarch64.apple.darwin14/lib/SDL2.framework/Versions/A/SDL2' (no such file)
=#





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
  * pos::MVector{2, Int64}	......*position*
  * color::PsychoColor			
  * colorSpace::String		
  * coordinateSpace::String	......*placeholder for now*
  * renderer::Ptr{SDL_Renderer}
  * font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * boldFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * italicFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
  * event::Base.RefValue{SDL_Event} 		
  * fullScreen::Bool
  * timeScale::String .......*defaults is milliseconds.  Other option is seconds*
  * title::String
  * startTime::Float64 .......*global proximy for startTime() and stopTime()*

**Methods:**
  * closeAndQuitPsychoJL()
  * closeWinOnly()
  * flip()
  * getCenter
  * getPos()
  * getNativeSize
  * getSize()
  * hideWindow()
  * mouseVisible()
  * setFullScreen()
"""
mutable struct Window	#{T}
	win::Ptr{SDL_Window}
	size::MVector{2, Int64}		# window size; static array (stay away from tuples)
	pos::MVector{2, Int64}		# position
	color::Union{String, Vector{Int64}, Vector{Float64}}			# these will be Psychopy colors
	colorSpace::String				# rgb255, rgba255, decimal, PsychoPy
	coordinateSpace::String		#	LT_Pix, LT_Percent, LB_Percent, PsychoPy
	renderer::Ptr{SDL_Renderer}
	font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	boldFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	italicFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
	event::Base.RefValue{SDL_Event} 		#SDL_Event
	fullScreen::Bool
	timeScale::String
	title::String
	startTime::Float64
	firstKey::Bool					# used for debouncing first keypress
	cachedObjects::Vector{Any}							# used when caching the drawing objects so that they can be redrawn later
	#cachedObjects::Vector{Union{Rect,Circle, Image}}	# used when caching the drawing objects so that they can be redrawn later
	#----------
	function Window(size,			# window size; static array (stay away from tuples)
					fullScreen = false;
					color = fill(0, (4)),					# these will be Psychopy colors
					colorSpace = "rgba255",						# might need to revist for colors.jl
					coordinateSpace = "LT_Pix",
					pos = [SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED],		# position
					timeScale = "milliseconds",
					title = "Window"
				)
		winPtr = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, size[1], size[2], SDL_WINDOW_SHOWN | SDL_WINDOW_ALLOW_HIGHDPI )#| SDL_WINDOW_INPUT_GRABBED)
		#winPtr = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, size[1], size[2], SDL_WINDOW_SHOWN)# | SDL_WINDOW_ALLOW_HIGHDPI )#| SDL_WINDOW_INPUT_GRABBED)
println("widnow pixel format = ", SDL_GetWindowPixelFormat(winPtr) )
println(">>> >>>", unsafe_string(SDL_GetError() ) )
		if timeScale != "seconds" && timeScale != "milliseconds"
			println("* timeScale can only be 'seconds' or 'milliseconds'.")
			println("** ", timeScale, " was given as the value for timeScale.")
			println("* default to milliseconds for timing.")©
			timeScale = "milliseconds"
		end
# for default size, try to use a version of the fullscreen size, taking Retina into account
		displayInfo = Ref{SDL_DisplayMode}()
		SDL_GetCurrentDisplayMode(0, displayInfo)
		screenWidth = displayInfo[].w
		screenHeight = displayInfo[].h
		pos = [screenWidth ÷ 2, screenHeight ÷ 2]
println("screenWidth = ", screenWidth)
println("screenHeight = ", screenHeight)
println("asked for window size = ", size)
		SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "2");
		renderer = SDL_CreateRenderer(winPtr, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)
		SDL_SetRenderDrawBlendMode(renderer, SDL_BLENDMODE_BLEND)

		#baseFilePath = pwd()
		baseFilePath = pathof(PsychExpAPIs)
		# ....julia/packages/PsychExpAPIs/cqE6w/src/PsychExpAPIs.jl
		baseFilePath, _ = splitdir(baseFilePath)				# strip PsychExpAPIs.jl from the path
		baseFilePath, _ = splitdir(baseFilePath)				# strip src from the path
		baseFilePath =joinpath(baseFilePath,"fonts") 
		baseFilePath =joinpath(baseFilePath,"Roboto") 
		fontFilePath =joinpath(baseFilePath,"Roboto-Regular.ttf") 

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
		#---------
		color = colorToSDL(colorSpace, color)
	
		startTime = 0.0
		firstKey = true
		cachedObjects = []
		#---------
		new(winPtr, 
			size, 
			pos, 
			color, 
			colorSpace, 
			coordinateSpace,
			renderer,
			font,
			boldFont,
			italicFont,
			event,
			fullScreen,
			timeScale,
			title,
			startTime,
			firstKey,
			cachedObjects
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
 	println("pre SDL_SetWindowFullscreen")
	exit()
    SDL_SetWindowFullscreen(win.win, SDL_FALSE)
	SDL_DestroyRenderer(win.renderer)		# this nees to get more complicated, where it loops through a list of renderers
	SDL_DestroyWindow(win.win)
	println("pre SDL_Quit")
	#SDL_Quit()
	exit()
end
#-========================================
"""
	flip(win::Window, screenShot::Bool)

Flips the offscreen buffer on screen.  In other words, all of the visual objects that you have drawn offscreen
prior to the flip will now become visible.
If flip() is also passed `true`, a screenshot of the window is taken.  
Taking a screenshot can take quite a bit of additional time.  Use this for non-time-critical applications, such as taking
example screenshots for a publication.
"""
function flip(win::Window; screenShot::Bool = false)		 # saveOrReturnScreenShot::String = " ")
#function flip(win::Window, screenShot::Bool)
	logFile = openLogFile()

	if screenShot == true

		w = Ref{Cint}()
		h = Ref{Cint}()
		SDL_GL_GetDrawableSize(win.win, w, h)
		
		mySurfacePtr = SDL_CreateRGBSurfaceWithFormat(0, w[], h[], 32, SDL_PIXELFORMAT_ARGB8888);			# create empy mySurfacePtr

		dereference(T::DataType, ptr::Ptr) = unsafe_load(Ptr{T}(ptr))		# generic function
		surfaceStruct = dereference(SDL_Surface, mySurfacePtr)					# try to put the C-based SDL_Surface struct into a Julia struct

		result = SDL_RenderReadPixels(win.renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, surfaceStruct.pixels, surfaceStruct.pitch);

		#offset  = fieldoffset(SDL_Surface, 6)

		if result != 0
			error("SDL_RenderReadPixels failed: ", unsafe_string(SDL_GetError()) )
		end

		surfaceStructPtr = Ptr{SDL_Surface}(pointer_from_objref(Ref(surfaceStruct)))
		#----
		# find a usable file name
		fileList = readdir()
		println("\n---------",fileList,"\n---------")
 		newFileName = "screenshot.png"
		for fileName in fileList					# note sure what this will do with multiple filenames that contain  "screenshot"
			if occursin("screenshot", fileName)
				#println( "findfirst('screenshot', fileName) = ", findfirst("screenshot", fileName) )
				head, tail = split(fileName, ".")
				base, numb = split(head, "screenshot")
				if numb == ""
					newFileName = "screenshot" * "1.png"
				else
					#numb = convert(Int64, String(numb) )
 					numb = parse(Int64, String(numb))
					numb +=1
					newFileName = "screenshot" * string(numb) * ".png"
				end
			end
		end

		#----
		logOut(logFile, newFileName)
		logOut(logFile, string(typeof(surfaceStructPtr)) )		
		if surfaceStructPtr == C_NULL
			#logOut(logFile, string(pointer(surfaceStructPtr)) )
			logOut(logFile, "surfaceStructPtr is C_NULL" )
		else
			logOut(logFile, "surfaceStructPtr is NOT C_NULL" )
		end
		r_surfacestruct = Ref(surfaceStruct)
		# 
		GC.@preserve r_surfacestruct begin													# thanks to vchuravy for solving this: https://discourse.julialang.org/t/works-in-debugger-segfaults-when-compiled/111385
			ptr_surfacestruct = Base.unsafe_convert(Ptr{SDL_Surface}, r_surfacestruct)
			result = IMG_SavePNG(ptr_surfacestruct,  "screenshot.png")
		end
		if result != 0
			error("IMG_SavePNG failed: ", unsafe_string(SDL_GetError()) )
		end	
	end
	SDL_RenderPresent(win.renderer)					# Present the backbuffer (memory) to the screen
	SDL_PumpEvents()
	SDL_SetRenderDrawColor(win.renderer, win.color[1], win.color[2], win.color[3], 255)			# sets window background color
	SDL_RenderClear(win.renderer)																# Clears the window in memory, getting it read for the next drawing session.

end
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#-=====================================================================================
"""
	flipCache(win::Window; clearCache::Bool = true)

Draws the graphics objects previously drawn with cacheDraw and then flips the window onto the screen.

This is useful if you want to reproduce a previously drawn screen.  For example, on incorrect trials, you could 
use flipCache() to draw the previously drawn trials, with a circle superimposed showing the correct answer.

If you don't want to clear the cached objects after the flip, pass it clearCache = false
"""
function flipCache(win::Window; clearCache::Bool = true)
	if isempty(win.cachedObjects) == false
		for obj in win.cachedObjects
			draw(obj)
println("\t", obj.pos,", ", obj._orientation)
		end
	end

	flip(win)

	if clearCache == true
		win.cachedObjects = []
	end
end
#-=====================================================================================
function oldFlip(win::Window)
	SDL_RenderPresent(win.renderer)					# Present the backbuffer (memory) to the screen
	SDL_PumpEvents()
	SDL_SetRenderDrawColor(win.renderer, win.color[1], win.color[2], win.color[3], 255)			# sets window background color
	SDL_RenderClear(win.renderer)																# Clears the window in memory, getting it read for the next drawing session.
end
#---------
# two versions of C++ SDL screen shot translated by AI:
#=

function SaveScreenshot()
    const format = SDL_PIXELFORMAT_ARGB8888
    const width = 640
    const height = 400
    renderer = sdl2Core.GetRenderer()
    surface = SDL_CreateRGBSurfaceWithFormat(0, width, height, 32, format)
    SDL_RenderReadPixels(renderer, nothing, format, surface.pixels, surface.pitch)
    SDL_SaveBMP(surface, "screenshot.bmp")
    SDL_FreeSurface(surface)
end
~~~~~~~~~~~~~~~


=#
#---------
function flipDelete(win::Window, screenshot::Bool)
	logFile = openLogFile()

	if screenshot == true

#.........................................	
		surfaceStructPtr = SDLreadPixels(win.renderer)
#.........................................	
		w = Ref{Cint}()
		h = Ref{Cint}()
		SDL_GL_GetDrawableSize(win.win, w, h)
		#=
		mySurfacePtr = SDL_CreateRGBSurfaceWithFormat(0, w[], h[], 32, SDL_PIXELFORMAT_ARGB8888);			# create empy mySurfacePtr

		dereference(T::DataType, ptr::Ptr) = unsafe_load(Ptr{T}(ptr))		# generic function
		surfaceStruct = dereference(SDL_Surface, mySurfacePtr)					# try to put the C-based SDL_Surface struct into a Julia struct

		result = SDL_RenderReadPixels(win.renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, surfaceStruct.pixels, surfaceStruct.pitch);

		#offset  = fieldoffset(SDL_Surface, 6)

		if result != 0
			error("SDL_RenderReadPixels failed: ", unsafe_string(SDL_GetError()) )
		end
		=#
		# try to replace above code with inlined C code, because I'm having a heluva time dereferencing.
#=
		C_code= """
  		int SDLreadPixels()
		{
			const Uint32 format = SDL_PIXELFORMAT_ARGB8888;
			const int width = 640;
			const int height = 400;
			auto renderer = sdl2Core->GetRenderer();
	
			SDL_Surface *surface = SDL_CreateRGBSurfaceWithFormat(0, width, height, 32, format);
			SDL_RenderReadPixels(renderer, NULL, format, surface->pixels, surface->pitch)
			return surface
		}
		"""
=#
		#Clib=tempname()
#		open("gcc -fPIC -O3 -xc -shared -o# \$(Clib * \".\" * Libdl.dlext) -", "w") do f
#=
		open(`gcc -fPIC -O3 -xc -shared -o'#' $'('Clib * "." '*' Libdl.dlext')' -`, "w") do f
			print(f, C_code)
		end
=#
		#result = IMG_SavePNG(mySurfacePtr,  "screenshot.png")
#		surfaceStructPtr = Ptr{SDL_Surface}(pointer_from_objref(Ref(surfaceStruct)))
#		surfaceStructPtr = ccall((:SDLreadPixels,Clib),SDL_Surface,())
		#----
		# find a usable file name
		fileList = readdir()
		println("\n---------",fileList,"\n---------")
 		newFileName = "screenshot.png"
		for fileName in fileList					# note sure what this will do with multiple filenames that contain  "screenshot"
			if occursin("screenshot", fileName)
				#println( "findfirst('screenshot', fileName) = ", findfirst("screenshot", fileName) )
				head, tail = split(fileName, ".")
				base, numb = split(head, "screenshot")
				if numb == ""
					newFileName = "screenshot" * "1.png"
				else
					#numb = convert(Int64, String(numb) )
 					numb = parse(Int64, String(numb))
					numb +=1
					newFileName = "screenshot" * string(numb) * ".png"
				end
			end
		end

		#----
		logOut(logFile, newFileName)
		logOut(logFile, string(typeof(surfaceStructPtr)) )		
		if surfaceStructPtr == C_NULL
			#logOut(logFile, string(pointer(surfaceStructPtr)) )
			logOut(logFile, "surfaceStructPtr is C_NULL" )
		else
			logOut(logFile, "surfaceStructPtr is NOT C_NULL" )
		end
		result = IMG_SavePNG(surfaceStructPtr, newFileName)
		if result != 0
			error("IMG_SavePNG failed: ", unsafe_string(SDL_GetError()) )
		end	
	end
	SDL_RenderPresent(win.renderer)					# Present the backbuffer (memory) to the screen
	SDL_PumpEvents()
	SDL_SetRenderDrawColor(win.renderer, win.color[1], win.color[2], win.color[3], 255)			# sets window background color
	SDL_RenderClear(win.renderer)																# Clears the window in memory, getting it read for the next drawing session.
end
#---------

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
#----------
"""
	getPos(win::Window)

Returns the center of the window. This, as well as the dimensions, can chage when going to full screen
"""
function getPos(win::Window)
#=
	displayInfo = Ref{SDL_DisplayMode}()
	SDL_GetCurrentDisplayMode(0, displayInfo)
	screenWidth = displayInfo[].w
	screenHeight = displayInfo[].h
=#
	w = Ref{Cint}()
	h = Ref{Cint}()
	SDL_GL_GetDrawableSize(win.win, w, h)
	screenWidth = w[]
	screenHeight = h[]
	win.pos = [screenWidth ÷ 2, screenHeight ÷ 2]			# integer division
	return win.pos
end
#----------
"""
	getCenter(win::Window)

Returns the center of the window in the units of the coordinate space.
"""
function getCenter(win::Window)

	coordsTemp = getPos(win)
	coords = zeros(2)
	coords[1] = coordsTemp[1]		# quick and dirty way of translating MVector to Vector
	coords[2] = coordsTemp[2]
	return SDLcoords(win, coords)
end
#----------
"""
	getNativeSize(win::Window)

Returns the width and height of the window in pixels. Dimensions can chage when going to full screen.
"""
function getNativeSize(win::Window)

	w = Ref{Cint}()
	h = Ref{Cint}()
	SDL_GL_GetDrawableSize(win.win, w, h)
	screenWidth = w[]
	screenHeight = h[]
	win.size = [screenWidth, screenHeight ]
	return win.size
end
#----------
"""
	getSize(win::Window)

Returns the width and height of the window depending int the units of the coordinate space. 
"""
function getSize(win::Window)

	w = Ref{Cint}()
	h = Ref{Cint}()
	SDL_GL_GetDrawableSize(win.win, w, h)
	screenWidth = w[]
	screenHeight = h[]
	win.size = [screenWidth, screenHeight ]
	widthRatio = screenWidth/screenHeight
	#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if win.coordinateSpace == "LT_Pix"
		return win.size
	elseif win.coordinateSpace == "LT_Percent" || win.coordinateSpace == "LB_Percent" || win.coordinateSpace == "PsychoPy"
		return [widthRatio , 1.0 ]
	else
		error("Invalid coordinate space given: ", win.coordinateSpace)
	end
end
#----------
"""
	setFullScreen(win::Window, mode::Bool)

Allows you to flip between windowed and full-screen mode.
"""
function setFullScreen(win::Window, mode::Bool)

	if mode == true
		SDL_SetWindowFullscreen(win.win, SDL_WINDOW_FULLSCREEN)
	else
		SDL_SetWindowFullscreen(win.win, SDL_WINDOW_FULLSCREEN_DESKTOP)
	end
end
#----------
"""
	mouseVisible(mode::Bool)

Hides or shows the cursor
"""
function mouseVisible(visibility::Bool)

	if visibility == true
		SDL_ShowCursor(SDL_ENABLE)
	else
		SDL_ShowCursor(SDL_DISABLE)
	end
end
#-===============================================

"""
	getScreenShot(mode::Bool)

Returns a copy of the current visible window as an ImageStim object.
CURRENTLY BROKEN

I wonder if i should add this to flip()?
"""
function getScreenShot(win::Window)
	error("do not use getScreenShot().  In all likelihood it is permanently broken.  Use flip(win, true) instead.")
	w = Ref{Cint}()
	h = Ref{Cint}()
	SDL_GL_GetDrawableSize(win.win, w, h)

	#https://stackoverflow.com/questions/22315980/sdl2-c-taking-a-screenshot/22339011#22339011
	#sshot = SDL_CreateRGBSurface(0, w, h, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000);
	#SDL_RenderReadPixels(renderer, NULL, SDL_PIXELFORMAT_ARGB8888, sshot->pixels, sshot->pitch);	

	# https://gigi.nullneuron.net/gigilabs/saving-screenshots-in-sdl2/
	mySurfacePtr = SDL_CreateRGBSurfaceWithFormat(0, w[], h[], 32, SDL_PIXELFORMAT_ARGB8888);			# create empy mySurfacePtr

	#tempPixels = unsafe_load(mySurfacePtr, 1).pixels							# These work, but I have a struct below
	#tempPitch = unsafe_load(mySurfacePtr, 1).pitch						# These work, but I have a struct below

	dereference(T::DataType, ptr::Ptr) = unsafe_load(Ptr{T}(ptr))		# generic function
	surfaceStruct = dereference(SDL_Surface, mySurfacePtr)					# try to put the C-based SDL_Surface struct into a Julia struct

	result = SDL_RenderReadPixels(win.renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, surfaceStruct.pixels, surfaceStruct.pitch);
	# surfaceStruct.pixels = A pointer to be filled in with the pixel data
	# but, we need to get the pointer to an SDL_Surface
#	surfaceStruct

	#unsafe_store!()  Store a value of type T to the address of the ith element (1-indexed) starting at p. This is equivalent to the C expression p[i-1] = x.
	# unsafe_store!(destination, value, offset)
	for i in 1:6
		println("offset ", i," = ", fieldoffset(SDL_Surface, i) )
	end
	offset  = fieldoffset(SDL_Surface, 6)
	#  Cannot `convert` an object of type Ptr{Nothing} to an object of type SDL_Surface
	#unsafe_store!(mySurfacePtr, surfaceStruct.pixels, offset)
println("typeof(mySurfacePtr) ", mySurfacePtr)
println("typeof( Ptr{SDL_Surface}(pointer_from_objref(Ref(surfaceStruct.pixels)))) ",  Ptr{SDL_Surface}(pointer_from_objref(Ref(surfaceStruct.pixels))))
	# MethodError: Cannot `convert` an object of type Ptr{SDL_Surface} to an object of type SDL_Surface
	#unsafe_store!(mySurfacePtr,   Ptr{SDL_Surface}(pointer_from_objref(Ref(surfaceStruct.pixels)))   , offset)	
	println("Offset of .pixels = ", offset)



	if result != 0
    	error("SDL_RenderReadPixels failed: ", unsafe_string(SDL_GetError()) )
	end


	#result = IMG_SavePNG(mySurfacePtr,  "screenshot.png")
	surfaceStructPtr = Ptr{SDL_Surface}(pointer_from_objref(Ref(surfaceStruct)))
	result = IMG_SavePNG(surfaceStructPtr,  "screenshot.png")
	
	if result != 0
    	error("IMG_SavePNG failed: ", unsafe_string(SDL_GetError()) )
	end
	#=
	#SDL_RenderReadPixels(win.renderer, NULL, SDL_PIXELFORMAT_ARGB8888, mySurfacePtr->pixels, mySurfacePtr->pitch);
	#ccall((:SDL_RenderReadPixels, libsdl2), Cint, (Ptr{SDL_Renderer}, Ptr{SDL_Rect}, Uint32, Ptr{Cvoid}, Cint), renderer, rect, format, pixels, pitch)
	result = SDL_RenderReadPixels(win.renderer, C_NULL, SDL_PIXELFORMAT_ARGB8888, surfaceStruct.pixels, surfaceStruct.pitch);
	# surfaceStruct.pixels = A pointer to be filled in with the pixel data
	if result != 0
    	error("SDL_RenderReadPixels failed: ", unsafe_string(SDL_GetError()) )
	end

	#texture = SDL_CreateTextureFromSurface(win.renderer, mySurfacePtr)		# Now we create a texture from our intial surface
	texture = SDL_CreateTextureFromSurface(win.renderer, surfaceStruct.pixels)		# Now we create a texture from our intial surface
	if texture == C_NULL
		error("Could not take screen snapshot: ")
	end
	#result = SDL_SaveBMP_RW(mySurfacePtr, "screenshot.bmp")
	result = SDL_SaveBMP_RW(mySurfacePtr, SDL_RWFromFile( "screenshot.bmp", "wb"), 1)

	
	if result != 0
    	error("SDL_SaveBMP_RW failed: ", unsafe_string(SDL_GetError()) )
	end
	
	screenShot = ImageStim(win, "", [0.0, 0.0], image = texture)
	SDL_FreeSurface(mySurfacePtr)									# Delete the surface, as we no longer need it.
	return screenShot
	=#
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
	timeScale::String˙
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

