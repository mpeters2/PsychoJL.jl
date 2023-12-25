# Translation of psycopy window file to Julia

export InitPsychoJL, MakeInt8Color

# Part of the PsychoPy library
# Copyright (C) 2002-2018 Jonathan Peirce (C) 2019-2022 Open Science Tools Ltd.
# Distributed under the terms of the GNU General Public License (GPL).
#using SimpleDirectMediaLayer
#using SimpleDirectMediaLayer.LibSDL2




#----------
function InitPsychoJL()

	@assert SDL_Init(SDL_INIT_EVERYTHING) == 0 "error initializing SDL: $(unsafe_string(SDL_GetError()))"
	@assert TTF_Init() == 0 "error initializing TTF_Init: $(unsafe_string(SDL_GetError()))"
	SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 16)			# the number of multisample anti-aliasing buffers.
	SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 16)			# the number of samples used around the current pixel used for multisample anti-aliasing

end
#----------
#Int8Color::Vector{Int8}{T}

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