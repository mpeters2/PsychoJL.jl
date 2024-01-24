" Module for writing Psychology Experiments inspired by Psychopy"
module PsychoJL

# need to make an alignment option for all widgets, like I did with textStim.

# Look at this about scaling and SDL with  SDL_WINDOW_ALLOW_HIGHDPI   https://discourse.libsdl.org/t/high-dpi-mode/34411/7
# Need to add copyright for whatever fotn I am using.

#=

- link to [core.jl](@ref)
- link to [`InitPsychoJL()`](@ref)
- link to [`MakeInt8Color(r,g,b,a)`](@ref)
=#
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using StaticArrays
#using Documenter
using JET


println("---------------------------- NEW RUN -----------------------------")
print("\ncurrent directory: ", pwd(),"\n\n")
#cd("src")
print("\ncurrent directory: ", pwd(),"\n\n")
include( "window.jl")
include( "core.jl" )
include( "shapes.jl" )
include( "textStim.jl" )
include( "events.jl" )
include( "imageStim.jl" )
include( "buttons.jl" )
include( "SDL2_gfxPrimitives.jl" )
include( "gui.jl" )
include( "popUpMenu.jl" )

export InitPsychoJL,  MakeInt8Color, waitTime
export Window, closeAndQuitPsychoJL, flip, closeWinOnly, hideWindow, dogcow
export Rect, Ellipse, sdl_ellipse, Line
export TextStim
export waitKeys, getKey
export ImageStim
export displayMessage, inputDialog, askQuestionDialog, fileOpenDlg, textInputDialog, DlgFromDict
export roundedRectangleRGBA, aaRoundRectRGBA, wuAACircle, aaRoundRectRGBAThick, aaFilledRoundRectRGBA
export ButtonStim, ButtonMap, buttonDraw, buttonDrawClicked, buttonStim
export PopUpMenu, PopUpMap


#/Users/MattPetersonsAccount/.julia/dev/PsychoJL/src/testStim.jl
#/Users/MattPetersonsAccount/.julia/dev/PsychoJL/src/textStim.jl
#-==============================================0
# scratchpad for future PsychoJL functions, structs, and stuff
#=

ToDo
	Fix super hi-res scaling issue
	√	add a gui
	Add multiple coordinate systems
	√	TextStim STruct
	√	GEt and show images
	√	GEt and show images
	√	waitKeys
	√	draw for ellipse (not sdl_ellipse() )
	√	draw for ellipse (not sdl_ellipse() )
	change color methods so that they can handle 255, 1.0, and Psychopy
	√	add line	
	√	thickLineRGBA looks like shit. How can I anti-alias?
	√	add fullscreen to window
	√	show images
	add documenter
	√	upload to github
	√	Need Gui interface for getting information
=#

#----------
# needed for converting SDL pointers
#unsafe_convert(::Type{Ptr{Float32}}, q::Quaternions.Quaternion{Float64}) =
 #   convert(Ptr{Float32}, Ptr{Float32}(pointer_from_objref([imag(q), real(q)])))


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
end # module PsychoJL
