# code for testing the PsychoJL module during development
# working prototype should be abale to draw square, circle, text, pictures and get keyboard input
println("------------------------------------ starting new run --------------------------------------")
using PsychoJL
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using SDL2_gfx_jll
using Revise
using JET

#=
	√	missing textbox
	√	need down arrows for pop-ups
	√	button is missing text
	√	need to center OK button at 75%
	√	add Cancel button at 25%
	√	fix pop-up text and highlighting
	√	add event loop
	√	change draw functions to just "draw" so I can loop through them
	√	add mouse-driven focus

	need to return struct full of values
	change the spacing of the labels and widgets so that they are closer to eachother
	have Window size be based on number of widgets
	make pop-ups and text entries prettier
=#


# look at thick lines
# overload int and float versions
#-----------------

const Sint16 = Int16
const Uint8 = UInt8

#println(libsdl2)
libsdl2 ="/Library/Frameworks/SDL.framework/Versions/A/SDL"

function aalineRGBA(renderer, x1, y1, x2, y2, r, g, b, a)
    ccall((:aalineRGBA, libsdl2), Cint, (Ptr{SDL_Renderer}, Sint16, Sint16, Sint16, Sint16, Uint8, Uint8, Uint8, Uint8), renderer, x1, y1, x2, y2, r, g, b, a)
end
#/Users/MattPetersonsAccount/Documents/Development/Julia/PaddleBattle.jl-master/libs/libSDL2-2.0.0.dylib

#-----------------

function DemoWindow()
 

#	resp, entry_text = inputDialog("Subject ID: ", "000")
#println(resp, entry_text)
#	displayMessage(" a message")
#	displayError(" an error")
#	displayWarning(" a warning")
	InitPsychoJL()

	#------------------------------------------
	exp_info = Dict("subject_nr"=>0, "age"=>0, "handedness"=>("right","left","ambi"), 
            "gender"=>("male","female","other","prefer not to say"))


	new_info = DlgFromDict(exp_info)

	println("\n New experiment info from dialog: \n\t", new_info)

	displayMessage( "Something happened")
	#------------------------------------------
	#IDnumber = textInputDialog( "Enter the subject ID number", "000")
	#println("Id number received is", IDnumber)

	myWin = Window( [1000,1000], false)

	SDL_SetWindowResizable(myWin.win, SDL_TRUE)						# sets it as a resiable Window.  Scales contents when resized
	
#	renderer = SDL_CreateRenderer(myWin.win, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC)


	mRect = SDL_Rect(250, 150, 200, 200)					# wacky Julia struct constructor; x,y, widht, height






	wuAACircle(myWin.renderer, 
				150.0, 
				600.0, 
				50.0, 
				0.0, 
				90.0, 
				255, 255, 255, 255)

	aaRoundRectRGBA(myWin.renderer, 			#roundedRectangleRGBA
							100, 
							700, 
							200, 
							750, 
							20, 
							255, 128, 0, 255)
	aaRoundRectRGBA(myWin.renderer, 			#roundedRectangleRGBA
							102, 
							702, 
							198, 
							748, 
							18, 
							255, 128, 0, 255)

	aaRoundRectRGBA(myWin.renderer, 			#roundedRectangleRGBA
							100, 
							800, 
							200, 
							850, 
							10, 
							255, 128, 0, 255)
	aaRoundRectRGBAThick(myWin.renderer, 			#roundedRectangleRGBA
							100, 
							900, 
							200, 
							950, 
							20, 
							4,
							255, 255, 0, 255)

	aaRoundRectRGBAThick(myWin.renderer, 			#roundedRectangleRGBA
							100, 
							600, 
							300, 
							675, 
							30, 
							7,
							255, 255, 0, 255)


	aaFilledRoundRectRGBA(myWin.renderer, 			#roundedRectangleRGBA

							500,
							700,
							968,
							768,
							17,
							131, 149, 247, 255)				
#454, 54
	aaFilledRoundRectRGBA(myWin.renderer, 			#roundedRectangleRGBA

							507,
							707,
							961,
							761,
							13,
							64, 135, 247, 255)				
	aaRoundRectRGBA(myWin.renderer, 			#roundedRectangleRGBA
							507,
							707,
							961,
							761,
							13,
							45, 97, 228, 255)	
	buttonText = TextStim(myWin,  
							"OK", 
							[734, 734], 
							color = [255, 255, 255], 
							fontSize = 24, 
							horizAlignment = 0, 
							vertAlignment = 0,
							style = "bold")
	draw(buttonText)		
#=
TextBox( t::String,  font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}, color::SDL_Color, renderer::Ptr{SDL_Renderer}, wrapWidth::Int64)

	myfont = myWin.font
    #char CharArray[2000]; // Create a char array
   #strcpy_s(CharArray, t.c_str()); // Convert the string into a char array for the surface function.

    Surface = TTF_RenderText_Blended_Wrapped(font, t, color, wrapWidth);	# Make into a surface.
    Texture = SDL_CreateTextureFromSurface(renderer, Surface); 				# Turn the surface into a texture.
    TTF_SizeText(font, CharArray, &w, &h);									# Size the texture so it renders the text correctly.
end
=#



	psychoRect = Rect(myWin, 100, 100, [400,400], lineColor = [255,0,0], fillColor = [255,128,128] )


	SDL_SetRenderDrawColor(myWin.renderer, 255, 255, 255, 255);	
	#SDL_RenderDrawRect(renderer, mRect)
	SDL_RenderDrawRect(myWin.renderer, Ref{SDL_Rect}(mRect))		# that addition mess lets me send the Rect as a pointer to the Rect
	SDL_SetRenderDrawColor(myWin.renderer, 255, 255, 0, 255);		# <<< this becomes the next background color, during flip()
	#SDL_RenderPresent(renderer);
	flip(myWin)
	SDL_SetRenderDrawColor(myWin.renderer, 255, 0, 0, 255);	
	mRect = SDL_Rect(300, 300, 200, 200)					# wacky Julia struct constructor; x,y, widht, height
	SDL_RenderDrawRect(myWin.renderer, Ref{SDL_Rect}(mRect))		# that addition mess lets me send the Rect as a pointer to the Rect
#	SDL_RenderPresent(myWin.renderer)									# equivalent to win.Flip()
#	SDL_PumpEvents()											# Must do this after every SDL_RenderPresent
	println("start")
	SDL_Delay(250)
	flip(myWin)
	println("\n")

	SDL_Delay(250)
	draw(psychoRect)

	newRect = Rect(myWin, 100, 100, [200,200], lineColor = [255,0,0], fillColor = [255,128,128] )
	draw(newRect) 

	hollowRect = Rect(myWin, 500, 500, [750,750], lineColor = [128,128,128, 255], fillColor = [0,0,0,0] )
	draw(hollowRect) 
	hollowRect2 = Rect(myWin, 500, 500, [250,250], lineColor = [128,128,128, 255], fillColor = [0,0,0,0] )
	draw(hollowRect2) 
#	sdl_ellipse(myWin, 500, 500, 75, 75)
#	filledCircleRGBA(myWin.renderer, 550, 600, 50, 255,128, 128, 255)
	#drawText(myWin, "does this work?")
	myColor = [255, 255, 255, 255]
	#myLine = Line(myWin, [50, 150], [150, 1500], width = 1, lineColor = myColor )
	myLine = Line(myWin, [500, 875], [1000, 625], width = 1, lineColor = myColor )
	draw(myLine)


	myColor2 = [0, 255, 0, 255]
	myLine2 = Line(myWin, [500, 750], [1000, 750], width = 2, lineColor = myColor2 )	# ::Vector{Int8}
	draw(myLine2)


	myColor3 = [0, 0, 255, 255]
	myLine3 = Line(myWin, [500, 500], [1000, 1000], width = 3, lineColor = myColor3 )	
	draw(myLine3)

	myColor4 = [255, 255, 0, 255]
	myLine4 = Line(myWin, [750, 500], [750, 1000], width = 4, lineColor = myColor4 )	
	draw(myLine4)

	myColor5 = [255, 0, 255, 255]
	myLine5 = Line(myWin, [500, 625], [1000, 875], width = 5, lineColor = myColor5 )	
	draw(myLine5)

	myText = TextStim(myWin,  "Using a TextStim", [300, 100], color = [255, 255, 128])
	draw(myText)

	myLine6 = Line(myWin, [1300, 200], [1305, 1500], width = 1, lineColor = myColor )
	draw(myLine6)

	myLine7 = Line(myWin, [1320, 200], [1325, 1500], width = 5, lineColor = myColor5 )	
	draw(myLine7)

	myLine8 = Line(myWin, [500, 675], [1000, 925], width = 1, lineColor = myColor5 )	
	draw(myLine8)

	myLine9 = Line(myWin, [500, 725], [1000, 975], width = 2, lineColor = myColor5 )	
	draw(myLine9)

	horizLine = Line(myWin, [500, 1100], [1000, 1100], width = 4, lineColor = [255, 0, 0, 255] )
	draw(horizLine)

	vertLine = Line(myWin, [1100, 500], [1100, 1000], width = 4, lineColor = [255, 0, 0, 255] )
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
	myellipse1 = Ellipse(myWin, [500, 1200], 120, 80, lineColor = [128, 255, 128, 255], fill = false)
	myellipse2 = Ellipse(myWin, [700, 600], 50,50, lineColor = [128, 128, 255, 255], fillColor = [255, 128, 128, 255], fill =true)

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
	imagePath = joinpath(dirname(pathof(SimpleDirectMediaLayer)), "..", "assets", "cat.png")
	myImage = ImageStim(myWin, imagePath)
	draw(myImage, magnification = 10.0)

	flip(myWin)

	startTimer(myWin)
	#theKey = getKey(myWin)
	theKey = waitKeys(myWin, 5000)
	timeTaken = stopTimer(myWin)
	println("the key ", theKey," was pressed. It took ", timeTaken," milliseconds")
	
	for i in 1:10
		println(getKey(myWin) )
	end
	closeAndQuitPsychoJL(myWin)
end

#@report_opt DemoWindow()
#font = FC_CreateFont();  
#FC_LoadFont(font, renderer, "fonts/FreeSans.ttf", 20, FC_MakeColor(0,0,0,255), TTF_STYLE_NORMAL);  

#@report_opt DemoWindow()
#@report_call DemoWindow()
DemoWindow()



SDL_Delay(2000)


#exit()



#=

i should make it unclicked and slection mode
need state to change state with each click

=#