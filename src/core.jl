# Translation of psycopy window file to Julia

export InitPsychoJL, MakeInt8Color, waitTime, waitTimeMsec, colorToSDL, SDLcoords, SDLsize
export PsychoColor, PsychoCoords, ConvertPixelSizeToFloats, openLogFile, logOut
using Colors
using Dates

#using SimpleDirectMediaLayer
#using SimpleDirectMediaLayer.LibSDL2


PsychoColor = Union{String, Vector{Int64}, Vector{Float64}}
PsychoCoords = Union{Vector{Int64}, Vector{Int32}, Vector{Float64}}


#----------
"""
	InitPsychoJL()

Initializes PsychoJL module.

**Inputs:** None\n
**Outputs:** None
"""
function InitPsychoJL()

	@assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
	@assert TTF_Init() == 0 "error initializing TTF_Init: $(unsafe_string(SDL_GetError()))"
	#---------
	flags = IMG_INIT_JPG | IMG_INIT_PNG
	initted = IMG_Init(flags);
	if ((initted & flags) != flags)
		println("IMG_Init: Failed to init required jpg and png support!\n")
		error("IMG_Init: %s\n", IMG_GetError())
	end

	#---------
	SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)			# the number of multisample anti-aliasing buffers.
	SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)			# the number of samples used around the current pixel used for multisample anti-aliasing
	if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 1, 1024) < 0)
		println("SDL_mixer could not initialize!", Mix_GetError())
	end
end
#-=================================================
function openLogFile()
	return open("logFile.txt","a")
end
#-=================================================
function logOut(logFile, message)
	dt = now()
	dtString = Dates.format(dt, "yyyy-mm-dd HH:MM:SS")
	message = dtString * ": " * message * "\n"
	write(logFile,message)
	flush(logFile)
	println(message)
end
#-=================================================
#=
"""
	MakeInt8Color(r,g,b,a)

Packs 8-bit red, green, blue, alpha values into a 32-bit Int.

inputs: Four integers of any type
outputs: UInt32

"""
=#
function MakeInt8Color(r,g,b,a)

	#color::Vector{UInt8} = [mod(r, UInt8), mod(g, UInt8), mod(b, UInt8), mod(a, UInt8)]
	color::UInt32 = mod(a, UInt8)
	color += mod(b, UInt8) * 256
	color += mod(g, UInt8) * 65536
	color += mod(r, UInt8) * 16777216
#	16777216	65536	256	1


#------
println("r, g, b, a = ", r,", ",g,", ",b,", ",a)
	colorString = dec2hex255(a)			#string(mod(r, UInt8) , base=16)
	colorString = colorString * dec2hex255(r)			#string(mod(g, UInt8), base=16)
	colorString = colorString * dec2hex255(g)			#string(mod(b, UInt8), base=16)
	colorString = colorString * dec2hex255(b)			#string(mod(a, UInt8), base=16)
	color = parse(UInt32, colorString, base= 16)
println("color = ", color) #, "\n")
#------
	return color
end
#-=================================================
"""
	waitTime(win::Window, time::Float64)

Pauses for a set amount of time. Time scale (second or milliseconds) is set
when making the Window.

**Inputs:** PsychoJL Window, 64-bit float\n
**Outputs:** Nothing
"""
function waitTime(win::Window, time::Float64)
	if win.timeScale == "milliseconds"
		SDL_Delay( round(UInt32, time)	)	
	elseif win.timeScale == "seconds"
		SDL_Delay(  round(UInt32, time * 1000)	)
	else
		error("Invalid timescale: ", win.timeScale)
	end
end
#-=================================================
"""
	waitTimeMsec(time::Union{Float64, Int64})

Pauses for a set amount of time. Time scale is in milliseconds, and does not 
require a window to be passed to it..

**Inputs:** 64-bit float\n
**Outputs:** Nothing
"""
function waitTimeMsec(time::Union{Float64, Int64})
	SDL_Delay(time)		
end
#-=================================================

#-=========

function dec2hex255(number)
	if number <= 255 && number >=0
		if number < 16				# if we don't do this, string() will return a single char without left 0 padding.
			hex = "0"
			hex = hex * string(mod(number, UInt8) , base=16) 
		else
			hex = string(mod(number, UInt8) , base=16)
		end
	else
		println("*** Error: number should be from 0-255, got this instead: ", number)
	end
	return hex
end
#-=====================================================================================================
# Changes various types of colors to standard SDL RGB color with an alpha channel

# RGB.  Adds alpha channel if length < 4
function colorToSDL(win::Window, inColor::Vector{Int64})

	if win.colorSpace != "rgba255" && win.colorSpace != "rgb255"
		error("Mismatch between colorspace.  Given integer vector, but colorspace is ", win.colorSpace)
	end
	
	if length(inColor) == 4
		return inColor
	elseif length(inColor) == 3
		outColor = zeros(Int64, 4)
		for i in eachindex(inColor)
			outColor[i] = inColor[i]
		end
		outColor[4] = 255
		return outColor
	else
		error("color is too short.  Only ", length(inColor)," values given")
	end
end

#-------------------------
# below tranlates decimal (0.0-1.0) and PsychoPy (-1.0 - +1.0) to rgba255
function colorToSDL(win::Window, inColor::Vector{Float64})

	if win.colorSpace != "decimal" && win.colorSpace != "PsychoPy"
		error("Mismatch between colorspace.  Given float vector, but colorspace is ", win.colorSpace)
	end
	#-----
	if win.colorSpace == "decimal"
		outColor = zeros(Int64, 4)
		for i in eachindex(inColor)
			outColor[i] = round(Int64, inColor[i] * 255)
		end
		if length(inColor) == 3
			outColor[4] = 255			# default is alpha of 255
		elseif length(inColor) < 3
			error("color is too short.  Only ", length(inColor)," values given")
		end
	elseif win.colorSpace == "PsychoPy"
		outColor = zeros(Int64, 4)
		for i in eachindex(inColor)
			outColor[i] = round(Int64, 127.5 + (inColor[i] * 127.5) )
		end
		if length(inColor) == 3
			outColor[4] = 255			# default is alpha of 255
		elseif length(inColor) < 3
			error("color is too short.  Only ", length(inColor)," values given")
		end
	else
		error(win.colorSpace," is an invalid color space")
	end
	return outColor
end
#-------------------------
# below tranlates strings to rgba255.  Ignores color space, and translates 
function colorToSDL(win::Window, inColor::String)

	if haskey(Colors.color_names, inColor)
		theColor = Colors.color_names[inColor]				# color is an rgba255
		outColor = zeros(Int64, 4)
		for i in eachindex(theColor)						# have to convert tuple to vector
			outColor[i] = theColor[i]
		end
		if length(theColor) == 3							# add alpha if necessary
			outColor[4] = 255
		end
		return outColor
	else
		error("Color name ", inColor," could not be found in Colors.jl")
	end

end
#-------------------------
# These versions are only used by a Window
function colorToSDL(colorSpace::String, inColor::Vector{Int64})

	if colorSpace != "rgba255" && colorSpace != "rgb255"
		error("Mismatch between colorspace.  Given integer vector, but colorspace is ", colorSpace)
	end
	
	if length(inColor) == 4
		return inColor
	elseif length(inColor) == 3
		outColor = zeros(Int64, 4)
		for i in eachindex(inColor)
			outColor[i] = inColor[i]
		end
		outColor[4] = 255
		return outColor
	else
		error("color is too short.  Only ", length(inColor)," values given")
	end
end
#----------
function colorToSDL(colorSpace::String, inColor::String)

	if haskey(Colors.color_names, inColor)
		theColor = Colors.color_names[inColor]				# color is an rgba255
		outColor = zeros(Int64, 4)
		for i in eachindex(theColor)						# have to convert tuple to vector
			outColor[i] = theColor[i]
		end
		if length(theColor) == 3							# add alpha if necessary
			outColor[4] = 255
		end
		return outColor
	else
		error("Color name ", inColor," could not be found in Colors.jl")
	end

end
#-=============================================================================
# convert image width and height to SDL
function SDLsize(win::Window, size::Union{Vector{Int64}, Vector{Int32}, Vector{Float64}})
	if win.coordinateSpace == "LT_Pix"
		return size
	elseif win.coordinateSpace == "LT_Percent"			# origin is left top, width is percent of height
		return ConvertPixelSizeToFloats(win, size)
	elseif win.coordinateSpace == "LB_Percent"			# origin is left bott0m, width is percent of height
		return ConvertPixelSizeToFloats(win, size)
	elseif win.coordinateSpace == "PsychoPy"			# origin is left bott0m, width is percent of height
		return ConvertPixelSizeToFloats(win, size)
	else
		error("Invalid coordinate space given: ", win.coordinateSpace)
	end
end
#----------
function ConvertPixelSizeToFloats(win::Window, size::PsychoCoords)
	_, displayHeight = getNativeSize(win)
	x = size[1] / displayHeight
	y = size[2] / displayHeight

	return [x,y]
end
#----------
function ConvertFloatToPixelSize(win::Window, size::PsychoCoords)
	_, displayHeight = getNativeSize(win)
	x = size[1] * displayHeight
	y = size[2] * displayHeight

	return [x,y]
end
#-=============================================================================
# converts coords to local coordinate system (?)
function SDLcoords(win::Window, coords::Union{Vector{Int64}, Vector{Float64}})

	if win.coordinateSpace == "LT_Pix"
		return coords
	elseif win.coordinateSpace == "LT_Percent"			# origin is left top, width is percent of height
		return ConvertFloatCoordsToPixels(win, coords)
	elseif win.coordinateSpace == "LB_Percent"			# origin is left bott0m, width is percent of height
		x = coords[1]
		y = 1 - coords[2]
		return ConvertFloatCoordsToPixels(win, [x,y])
	elseif win.coordinateSpace == "PsychoPy"			# origin is left bott0m, width is percent of height
		return ConvertPsychoPyToPixels(win, coords)
	else
		error("Invalid coordinate space given: ", win.coordinateSpace)
	end
end
#----------
function ConvertPsychoPyToFloatCoords(win::Window, coord::Vector{Float64})
	#x = coord[1] + 0.5

	# =($D5/2)-F9
	#(ratio/2) - x
	displayWidth, displayHeight = getNativeSize(win)
	ratio = displayWidth/displayHeight
	x = (ratio/2) - coord[1]

	y = -coord[2] + 0.5

	return [x,y]
end
#----------
function ConvertFloatCoordsToPixels(win::Window, coord::PsychoCoords)
	_, displayHeight = getNativeSize(win)
	x = round(Int64, coord[1] * displayHeight)
	y = round(Int64, coord[2] * displayHeight)

	return [x,y]
end
#----------
function ConvertPsychoPyToPixels(win::Window, coord::Vector{Float64})
	coord = ConvertPsychoPyToFloatCoords(win, coord)
	return ConvertFloatCoordsToPixels(win, coord)
end
#----------
# This (the name) makes no sense!  Do not write code late at night!
function convertFloatCoordToInt255(coords::Vector{Float64})
	out = ones(Int64, 2)
	out[1] = round(Int64, coords[1] * 255)
	out[2] = round(Int64, coords[2] * 255)
	return out
end


