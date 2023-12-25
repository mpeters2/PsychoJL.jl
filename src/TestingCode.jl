# code for testing the PsychoJL module during development
# working prototype should be abale to draw square, circle, text, pictures and get keyboard input
println("------------------------------------ starting new run --------------------------------------")
using PsychoJL
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using SDL2_gfx_jll

# look at thick lines
# overload int and float versions
#-----------------
#=
const Sint16 = Int16
const Uint8 = UInt8

#println(libsdl2)
libsdl2 ="/Library/Frameworks/SDL.framework/Versions/A/SDL"

function aalineRGBA(renderer, x1, y1, x2, y2, r, g, b, a)
    ccall((:aalineRGBA, libsdl2), Cint, (Ptr{SDL_Renderer}, Sint16, Sint16, Sint16, Sint16, Uint8, Uint8, Uint8, Uint8), renderer, x1, y1, x2, y2, r, g, b, a)
end
#/Users/MattPetersonsAccount/Documents/Development/Julia/PaddleBattle.jl-master/libs/libSDL2-2.0.0.dylib
=#
#-----------------

function DemoWindow()
	InitPsychoJL()
	myWin = window( [1000,1000], false)

	SDL_SetWindowResizable(myWin.win, SDL_TRUE)						# sets it as a resiable window.  Scales contents when resized
	
#	renderer = SDL_CreateRenderer(myWin.win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)


	mRect = SDL_Rect(250, 150, 200, 200)					# wacky Julia struct constructor; x,y, widht, height


	psychoRect = rect(myWin, 100, 100, [400,400], lineColor = [255,0,0], fillColor = [255,128,128] )


	SDL_SetRenderDrawColor(myWin.renderer, 255, 255, 255, 255);	
	#SDL_RenderDrawRect(renderer, mRect)
	SDL_RenderDrawRect(myWin.renderer, Ref{SDL_Rect}(mRect))		# that addition mess lets me send the rect as a pointer to the rect
	SDL_SetRenderDrawColor(myWin.renderer, 255, 255, 0, 255);		# <<< this becomes the next background color, during flip()
	#SDL_RenderPresent(renderer);
	flip(myWin)
	SDL_SetRenderDrawColor(myWin.renderer, 255, 0, 0, 255);	
	mRect = SDL_Rect(300, 300, 200, 200)					# wacky Julia struct constructor; x,y, widht, height
	SDL_RenderDrawRect(myWin.renderer, Ref{SDL_Rect}(mRect))		# that addition mess lets me send the rect as a pointer to the rect
#	SDL_RenderPresent(myWin.renderer)									# equivalent to win.Flip()
#	SDL_PumpEvents()											# Must do this after every SDL_RenderPresent
	println("start")
	SDL_Delay(250)
	flip(myWin)
	println("\n")

	SDL_Delay(250)
	draw(psychoRect)

	newRect = rect(myWin, 100, 100, [200,200], lineColor = [255,0,0], fillColor = [255,128,128] )
	draw(newRect) 

	hollowRect = rect(myWin, 500, 500, [750,750], lineColor = [128,128,128, 255], fillColor = [0,0,0,0] )
	draw(hollowRect) 
	hollowRect2 = rect(myWin, 500, 500, [250,250], lineColor = [128,128,128, 255], fillColor = [0,0,0,0] )
	draw(hollowRect2) 
#	sdl_ellipse(myWin, 500, 500, 75, 75)
#	filledCircleRGBA(myWin.renderer, 550, 600, 50, 255,128, 128, 255)
	#drawText(myWin, "does this work?")
	myColor = [255, 255, 255, 255]
	#myLine = line(myWin, [50, 150], [150, 1500], width = 1, lineColor = myColor )
	myLine = line(myWin, [500, 875], [1000, 625], width = 1, lineColor = myColor )
	draw(myLine)


	myColor2 = [0, 255, 0, 255]
	myLine2 = line(myWin, [500, 750], [1000, 750], width = 2, lineColor = myColor2 )	# ::Vector{Int8}
	draw(myLine2)


	myColor3 = [0, 0, 255, 255]
	myLine3 = line(myWin, [500, 500], [1000, 1000], width = 3, lineColor = myColor3 )	
	draw(myLine3)

	myColor4 = [255, 255, 0, 255]
	myLine4 = line(myWin, [750, 500], [750, 1000], width = 4, lineColor = myColor4 )	
	draw(myLine4)

	myColor5 = [255, 0, 255, 255]
	myLine5 = line(myWin, [500, 625], [1000, 875], width = 5, lineColor = myColor5 )	
	draw(myLine5)

	myText = textStim(myWin,  "Using a textStim", [300, 100], color = [255, 255, 128])
	draw(myText)

	myLine6 = line(myWin, [1300, 200], [1305, 1500], width = 1, lineColor = myColor )
	draw(myLine6)

	myLine7 = line(myWin, [1320, 200], [1325, 1500], width = 5, lineColor = myColor5 )	
	draw(myLine7)

	myLine8 = line(myWin, [500, 675], [1000, 925], width = 1, lineColor = myColor5 )	
	draw(myLine8)

	myLine9 = line(myWin, [500, 725], [1000, 975], width = 2, lineColor = myColor5 )	
	draw(myLine9)

	horizLine = line(myWin, [500, 1100], [1000, 1100], width = 4, lineColor = [255, 0, 0, 255] )
	draw(horizLine)

	vertLine = line(myWin, [1100, 500], [1100, 1000], width = 4, lineColor = [255, 0, 0, 255] )
	draw(vertLine)
#=	Sans = TTF_OpenFont("Sans.ttf", 24);
	White = SDL_Color(255, 255, 255, 255)

	render_text(myWin.renderer, 
					"Does this work?", 
					Sans, 
					White, 
					50, 
					50)
=#
#	aaellipseRGBA(myWin.renderer, 650, 600, 50,50, 128,255, 128, 255)
	myellipse1 = ellipse(myWin, [500, 1200], 120, 80, lineColor = [128, 255, 128, 255], fill = false)
	myellipse2 = ellipse(myWin, [700, 600], 50,50, lineColor = [128, 128, 255, 255], fillColor = [255, 128, 128, 255], fill =true)

	draw(myellipse1)
	draw(myellipse2)

	#myColor = MakeInt8Color(255, 0, 255, 255)
	#------------------------------------------------------
	# This sections is for checking anti-aliasing and subpixels rendering bult-in to SDL2
	# SDL_RenderDrawLine, aaline, SDL_RenderDrawLineF
	SDL_SetRenderDrawColor(myWin.renderer, 255,255,255,255)	
	SDL_RenderDrawLine(myWin.renderer, 1500, 10, 1510, 1500 )		# shallow
	SDL_RenderDrawLine(myWin.renderer, 1600, 10, 1900, 310 )		# 45°
	#----
#=
	aalineRGBA(myWin.renderer, 
				convert(Int16, 1510), 
				convert(Int16, 10), 
				convert(Int16, 1520), 
				convert(Int16, 1500),
				convert(UInt8, 255),
				convert(UInt8, 255),
				convert(UInt8, 255),
				convert(UInt8, 255)
				)
	aalineRGBA(myWin.renderer, 1610, 10, 1910, 1500, 255,255,255,255)
=#
	#----
	SDL_SetRenderDrawColor(myWin.renderer, 255,255,255,255)	
	SDL_RenderDrawLineF(myWin.renderer, 1520.5, 10, 1530.5, 1500 )		# shallow
	SDL_RenderDrawLineF(myWin.renderer, 1530, 10, 1540, 1500 )		# shallow
	SDL_RenderDrawLineF(myWin.renderer, 1620.5, 10, 1920.5, 310 )		# 45°
	SDL_RenderDrawLineF(myWin.renderer, 1630, 10, 1930, 310 )		# 45°
	#------------------------------------------------------
	flip(myWin)
end

#@report_opt DemoWindow()
#font = FC_CreateFont();  
#FC_LoadFont(font, renderer, "fonts/FreeSans.ttf", 20, FC_MakeColor(0,0,0,255), TTF_STYLE_NORMAL);  

DemoWindow()



SDL_Delay(2000)


exit()

