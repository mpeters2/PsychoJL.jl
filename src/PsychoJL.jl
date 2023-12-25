module PsychoJL
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using StaticArrays

println("---------------------------- NEW RUN -----------------------------")
print("\ncurrent directory: ", pwd(),"\n\n")
#cd("src")
print("\ncurrent directory: ", pwd(),"\n\n")
include( "window.jl")
include( "core.jl" )
include( "shapes.jl" )
include( "textStim.jl" )
include( "events.jl" )
include( "SDL2_gfxPrimitives.jl" )

export InitPsychoJL,  MakeInt8Color
export window, close, flip, Window
export rect, sdl_ellipse, draw, line
export textStim
export waitKeys, getKey

#/Users/MattPetersonsAccount/.julia/dev/PsychoJL/src/testStim.jl
#/Users/MattPetersonsAccount/.julia/dev/PsychoJL/src/textStim.jl
#-==============================================
# scratchpad for future PsychoJL functions, structs, and stuff
#=

ToDo
	√	TextStim STruct
	GEt and show images
	√	waitKeys
	draw for ellipse (not sdl_ellipse() )
	change color methods so that they can handle 255, 1.0, and Psychopy
	√	add line	
	thickLineRGBA looks like shit. How can I anti-alias?
	add fullscreen to windo
	show images
	add documenter
	upload to github
=#

#----------
# needed for converting SDL pointers
#unsafe_convert(::Type{Ptr{Float32}}, q::Quaternions.Quaternion{Float64}) =
 #   convert(Ptr{Float32}, Ptr{Float32}(pointer_from_objref([imag(q), real(q)])))


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end # module PsychoJL
