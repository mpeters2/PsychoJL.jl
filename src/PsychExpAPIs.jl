" Module for writing Psychology Experiments inspired by Psychopy"
module PsychExpAPIs

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
using Colors
#using Documenter
using JET


#println("---------------------------- NEW RUN -----------------------------")
#print("\ncurrent directory: ", pwd(),"\n\n")
#cd("src")
#print("\ncurrent directory: ", pwd(),"\n\n")
include( "window.jl")
include( "core.jl" )
include( "shapes.jl" )
include( "textStim.jl" )
include( "events.jl" )
include( "imageStim.jl" )
include( "buttons.jl" )
include( "SDL2_gfxPrimitives.jl" )
#include( "SDL2_ttf_wrapping.jl" )
include( "gui.jl" )
include( "popUpMenu.jl" )
include( "timings.jl" )
include( "soundStim.jl" )

export InitPsychoJL,  MakeInt8Color, waitTime, waitTimeMsec, colorToSDL, SDLcoords
export PsychoColor, PsychoCoords
export Window, closeAndQuitPsychoJL, flip, closeWinOnly, hideWindow
export getPos, getSize, setFullScreen, getNativeSize, getCenter
export mouseVisible
export Rect, Ellipse, Line, Circle, ShapeStim, Polygon,  Line2
export setColor, setLineColor, setFillColor, setPos
export TextStim, TextStimExp, setColor
export waitKeys, getKey
export ImageStim
export infoMessage, inputDialog, askQuestionDialog, fileOpenDlg, textInputDialog, DlgFromDict
export alertMessage, happyMessage
export roundedRectangleRGBA, aaRoundRectRGBA, wuAACircle, aaRoundRectRGBAThick, aaFilledRoundRectRGBA
export ButtonStim, ButtonMap, buttonDraw, buttonDrawClicked, buttonStim
export PopUpMenu, PopUpMap
export startTimer, stopTimer
export ErrSound, SoundStim, play

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
