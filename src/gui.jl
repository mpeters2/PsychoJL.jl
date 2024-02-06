# Might want to make a larger Window for instructions, with buttons for OK and Back (incase they went too fast)

#using .Gtk: draw as GTKdraw
#import Gtk			# this prevents namespace collisions between Gtk's draw() and PsychoJL's draw() functions
include("guiUtilityFunctions.jl")
using Dates

export displayMessage, askQuestionDialog, fileOpenDlg,  inputDialog, textInputDialog, DlgFromDict
export infoMessage, happyMessage, warningMessage, errorMessage

# make fileOpenDlg actually work
# mask ask dialog look nice

const SDLK_BACKSPACE = 8
const SDLK_RETURN = 13
const SDLK_c = 99
const SDLK_v = 118
const KMOD_CTRL = 192
const SDLK_KP_ENTER = 1073741912
const SDLK_LEFT = 1073741904
const SDLK_RIGHT = 1073741903

#-==========================================================================================================
function fileOpenDlg()
	file = Gtk.open_dialog_native("My first file dialog")
	filehandle = Gtk.open("$file");
	Netlist_lines = Gtk.readlines(filehandle);
	Gtk.close(filehandle); 
	Netlist_lines[1][begin:3]
end
#-=============================================
#!["picture of a displayMessage dialog"](displayMessage.png)
"""
	displayMessage( message::String)

Displays a message along with an "OK" button.  Use before opening the main window
or after closing the main window.  Useful for displaying errors or experiment completion messages.

**Inputs:** PsychoJL Window, String\n
**Outputs:** Nothing\n
!["picture of a displayMessage dialog"](displayMessageSmall.png)
"""
function displayMessage( message::String)

	SDL_ShowSimpleMessageBox( SDL_MESSAGEBOX_INFORMATION, "Alert", message, C_NULL)
	# debounces by waiting for an SDL_KEYUP event
	SDLevent = Ref{SDL_Event}()
	done = false
	while done == false
		while Bool(SDL_PollEvent(SDLevent))
			event_ref = SDLevent
			evt = event_ref[]
			evt_ty = evt.type
			if( evt_ty == SDL_KEYUP )
				done = true
			end
		end
	end

end
#-=============================================
"""
	infoMessage( message::String)

Displays a message along with an "OK" button.  Use before opening the main window
or after closing the main window.  Useful for displaying general information.

**Inputs:** String\n
**Outputs:** Nothing\n
!["picture of a infoMessage dialog"](infoMessage.png)
"""
function infoMessage( message::String)
	genericMessage(message, "information.png")
end
#-----------------
"""
	happyMessage( message::String)

Displays a message along with an "OK" button.  Use before opening the main window
or after closing the main window.  Useful for experiment completion messages.

**Inputs:** String\n
**Outputs:** Nothing\n
!["picture of a happyMessage dialog"](happyMessage.png)
"""
function happyMessage( message::String)
	genericMessage(message, "HappyFace.png")
end
#-----------------
"""
	warningMessage( message::String)

Displays a message along with an "OK" button.  Use before opening the main window
or after closing the main window.  Useful for displaying non-critical warnings.

**Inputs:** String\n
**Outputs:** Nothing\n
!["picture of a warningMessage dialog"](warningMessage.png)
"""
function warningMessage( message::String)
	genericMessage(message, "warning.png")
end
#-----------------
"""
	errorMessage( message::String)

Displays a message along with an "OK" button.  Use before opening the main window
or after closing the main window.  Useful for displaying critical errors.

**Inputs:** String\n
**Outputs:** Nothing\n
!["picture of a errorMessage dialog"](errorMessage.png)
"""
function errorMessage( message::String)
	genericMessage(message, "error.png")
end

#does SDL do text wrap?
#Even so, I want to use \n to add new lines
#-=============================================
function genericMessage( message::String, imageName::String)

	SCREEN_WIDTH = 360
	SCREEN_HEIGHT = 125
	CENTERX = SCREEN_WIDTH ÷ 2
	CENTERY = SCREEN_HEIGHT ÷ 2

	buttonClicked = "NoButton"
	quit::Bool = false;

	mX = Ref{Cint}()					# pointers that will receive mouse coordinates
	mY = Ref{Cint}()

	SDLevent = Ref{SDL_Event}()									#Event handler
	
	textColor =  SDL_Color(0, 0, 0, 0xFF)						#Set text color as black

	dialogWin = Window([SCREEN_WIDTH, SCREEN_HEIGHT], false, title = "")

	renderer = dialogWin.renderer
	
	gFont = dialogWin.font

	if gFont == C_NULL
		println("*** Error: gFont is NULL")
	end
	SDL_PumpEvents()									# this erases whatever random stuff was in the backbuffer
	SDL_SetRenderDrawColor(dialogWin.renderer, 250, 250, 250, 255)
	SDL_RenderClear(dialogWin.renderer)		

	w = Ref{Cint}()
	h = Ref{Cint}()
	TTF_SizeText(gFont, message, w::Ref{Cint}, h::Ref{Cint})
	label = TextStim(dialogWin, message, [CENTERX + 40, 10 + (1*(h[] + 10)) ],		# the centerX * 1.5 seem weird, that's because of retina = 0.75 of width
#	label = TextStim(dialogWin, message, [round(Int64, SCREEN_WIDTH *0.8), 10 + (1*(h[] + 10)) ],		# the centerX * 1.5 seem weird, that's because of retina = 0.75 of width
	#label = TextStim(dialogWin, message, [round(Int64,CENTERX * 1.5), 10 + (1*(h[] + 10)) ],		# the centerX * 1.5 seem weird, that's because of retina = 0.75 of width
						color = [0, 0, 0], 
						fontSize = 24, 
						horizAlignment = -1, 
						vertAlignment = 1 )
	draw(label, wrapLength = round(Int64,SCREEN_WIDTH*1.5)-50 )			# SCREEN_WIDTH seems weird, but retina doubles/halves everything
	#---------
	# draw alert
	parentDir = pwd()
	filePath = joinpath(parentDir, "artifacts")
	filePath = joinpath(filePath, imageName)
	#symbol = ImageStim(	dialogWin, filePath,  [round(Int64, SCREEN_WIDTH *0.2), CENTERY] )
	symbol = ImageStim(	dialogWin, filePath,  [CENTERX ÷ 1.5, SCREEN_HEIGHT] )			# This might break with retina
	draw(symbol, magnification = 0.4)

	#---------
	# draw OK button
	OKtext = TextStim(dialogWin, "OK",	[0, 0])
	OKbutton = ButtonStim(dialogWin,
				#[ 20 + (widestKey),  10 + ((length(labels)+1) * (h[] +10)) ],		# was 0.75, buthigh dpi shenanigans
				#[ widestKey, h[] + 10],
				[ round(Int64, SCREEN_WIDTH *0.8), SCREEN_HEIGHT - (h[] ÷ 2)],
				[ (SCREEN_WIDTH ÷ 5) , h[] + 10],
				OKtext,					
				"default")
	_, ytemp = OKbutton.pos
	ytemp ÷= 2
	#OKbutton.pos[2] = ytemp
	buttonDraw(OKbutton)
	OKmap = ButtonMap(OKbutton, "OK-clicked")
	#---------
	# Play alert sound
	parentDir = pwd()
	filePath = joinpath(parentDir, "artifacts")
	filePath = joinpath(filePath, "qbeep.wav")
	mySound = SoundStim(filePath)
	play(mySound)
	#---------


	while( !quit )
			while Bool(SDL_PollEvent(SDLevent))			# Handle events on queue
			event_ref = SDLevent
			evt = event_ref[]
			evt_ty = evt.type
			evt_key = evt.key
			evt_text = evt.text
			evt_mouseClick = evt.button
 	
			# We only want to update the input text texture when we need to so we have a flag that keeps track of whether we need to update the texture.
			if( evt_ty == SDL_KEYDOWN )							#Special key input

				#Handle backspace
				if evt_key.keysym.sym == SDLK_RETURN || evt_key.keysym.sym == SDLK_KP_ENTER

					SDL_StopTextInput();										#Disable text input
					hideWindow(dialogWin)
					SDL_RenderPresent( renderer );
					closeWinOnly(dialogWin)

					return "OK"
				end

			elseif( evt_ty == SDL_MOUSEBUTTONDOWN )				# new version makes a list of clicked items, and the item with the focus is the winner
				x = evt_mouseClick.x
				y = evt_mouseClick.y

				if (OKmap.rightBottom[1] > x > OKmap.leftTop[1]) && (OKmap.rightBottom[2] > y > OKmap.leftTop[2])
					OKmap.state = "clicked"
					SDL_StopTextInput();										#Disable text input
					hideWindow(dialogWin)
					SDL_RenderPresent( renderer );
					closeWinOnly(dialogWin)

					return "OK"
				end

			end
		end
		SDL_SetRenderDrawColor(renderer, 250, 250, 250, 255)
		SDL_RenderClear( renderer );
		#--------------------------------------------
		# Update widgets and such
		draw(label,  wrapLength = round(Int64,SCREEN_WIDTH*1.5)-50 )
		draw(symbol, magnification = 0.4)

		#-------------------
		#Update screen
		if OKmap.state == "unclicked"
			buttonDraw(OKmap.button)
		elseif OKmap.state == "clicked"
			buttonDrawClicked(OKmap.button)
			OKmap.state = "unclicked"
			quit = true
			buttonClicked = OKmap.button.TextStim.textMessage
		end

		SDL_RenderPresent( renderer );
		# check for enter or cancel
	end
	#--------------   Show stuff
	SDL_StopTextInput();										#Disable text input

	hideWindow(dialogWin)
	SDL_RenderPresent( renderer );
	#SDL_DestroyWindow(SDL_Window * Window)
	closeWinOnly(dialogWin)


	return "OK"

end

#-=============================================
function askQuestionDialog(message::String)
	println("askQuestionDialog not implemented yet")
end
#-=============================================
function showMessageBullshitExample(message::String)
    buttons::SDL_MessageBoxButtonData = [						# .flags, .buttonid, .text
        [ #= .flags, .buttonid, .text =#        0, 0, "no" ],
        [ SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT, 1, "yes" ],
        [ SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT, 2, "cancel" ],
    ]
    colorScheme::SDL_MessageBoxColorScheme = [					# .colors (.r, .g, .b)		all this stuff was in a second set of []
         #= .colors (.r, .g, .b) =#         
					[ 255,   0,   0 ],							# [SDL_MESSAGEBOX_COLOR_BACKGROUND]     
					[  0,  255,   0 ],							# [SDL_MESSAGEBOX_COLOR_TEXT]         
					[ 255, 255,   0 ],							# [SDL_MESSAGEBOX_COLOR_BUTTON_BORDER]         
					[   0,   0, 255 ],							# [SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND]         
					[ 255,   0, 255 ]							# [SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED] 
    ]
    
    messageboxdata::SDL_MessageBoxData = [
					SDL_MESSAGEBOX_INFORMATION, 				# .flags 
					C_NULL, 									# .Window 
					"example message box",						# .title 
					"select a button",							# .message 
					SDL_arraysize(buttons), 					# .numbuttons 
					buttons, 									# .buttons 
					colorScheme 								# .colorScheme 
    ]
    #int buttonid;
    if (SDL_ShowMessageBox(messageboxdata, buttonid) < 0) 
        SDL_Log("error displaying message box");
		println("error displaying message box")
        return 1;
    end
    if (buttonid == -1) 
        SDL_Log("no selection");
		println("no selection")
 
    else
        SDL_Log("selection was %s", buttons[buttonid].text);
    end
    return 0;
end
#-=============================================
function textInputDialog( promptString::String, defaultText::String)
	SCREEN_WIDTH = 350
	SCREEN_HEIGHT = 150
	DoubleWidth = SCREEN_WIDTH * 2									# I don't know if this is a workaround for Retina or SDL_WINDOW_ALLOW_HIGHDPI, but a 400 pixel width yields 800 pixels 

	firstRun = true
	buttonClicked = "NoButton"
	quit::Bool = false;

	mX = Ref{Cint}()					# pointers that will receive mouse coordinates
	mY = Ref{Cint}()

	cursorLocation = 0											# after the last character.  This is in charachter units, not pixels
																# this cycles during each refresh from true to false
	onTime = 0												# for timing of cursor blinns
	# these are used later to get the size of the text when moving the cursor
	w = Ref{Cint}()
	h = Ref{Cint}()

	SDLevent = Ref{SDL_Event}()									#Event handler
	
	textColor =  SDL_Color(0, 0, 0, 0xFF)						#Set text color as black

	InitPsychoJL()

	dialogWin = Window(title = "", [SCREEN_WIDTH, SCREEN_HEIGHT], false)

	SDLwindow = dialogWin.win
	renderer = dialogWin.renderer

	#Globals = SDLGlobals(SDLwindow, renderer, LTexture(C_NULL, 0 ,0), LTexture(C_NULL, 0 ,0) )
	
	gFont = dialogWin.font

	if gFont == C_NULL
		println("*** Error: gFont is NULL")
	end
	SDL_PumpEvents()					# this erases whatever random stuff was in the backbuffer
	SDL_RenderClear(renderer)			#

	TTF_SizeText(gFont, "Abcxyz", w, h)
	#-===== Their code:
	#The current input text.
	#inputText::String = "Some Text";

	inputText = defaultText
	#TTF_SetFontStyle(gFont, TTF_STYLE_ITALIC)
	#Globals.promptTextTexture = loadFromRenderedText(Globals, promptString, textColor,  dialogWin.italicFont);		# inputText.c_str(), textColor );
	#leftX = (SCREEN_WIDTH - Globals.promptTextTexture.mWidth)÷2					
	promptText = TextStim(dialogWin, promptString, [SCREEN_WIDTH, 20 ],		# you would think it would be SCREEN_WIDTH÷2, but hi-res messes it centers at SCREEN_WIDTH÷4.
							color = [0, 0, 0], 
							fontSize = 24, 
							horizAlignment = 0, 
							vertAlignment = -1,
							style = "italic" )
	#TTF_SetFontStyle(gFont, TTF_STYLE_NORMAL )

	#Globals.inputTextTexture = loadFromRenderedText(Globals, inputText, textColor,  gFont);		# inputText.c_str(), textColor );

	myInputBox = InputBox(dialogWin, 
							defaultText, 
							[35,	h[]÷2 + 17],
							[ (DoubleWidth - 140)÷2, h[]÷2 + 5], 
							""
							)
	#--------- Make buttons
	buttonList = []
	
	OKtext = TextStim(dialogWin, "OK",	[0, 0])
	OKbutton = ButtonStim(dialogWin,
				[ round(Int64, SCREEN_WIDTH * 0.75), round(Int64, SCREEN_HEIGHT * 0.75)],		# was 0.75, buthigh dpi shenanigans
				[ round(Int64, SCREEN_WIDTH * 0.25), 68],
				OKtext,					
				"default")
	push!(buttonList, ButtonMap(OKbutton, "OK-clicked") )

	CancelText = TextStim(dialogWin, "Cancel",	[0, 0])
	CancelButton = ButtonStim(dialogWin,
				[ round(Int64, SCREEN_WIDTH * 0.25), round(Int64, SCREEN_HEIGHT * 0.75)],		# was 0.75, buthigh dpi shenanigans
				[ round(Int64, SCREEN_WIDTH * 0.25), 68],
				CancelText,					
				"other")
	push!(buttonList, ButtonMap(CancelButton, "Cancel-clicked") )


	#---------- end buttons
	#---------- Make PopUp
	popList = []
	myPop = PopUpMenu(dialogWin, [70,100], [100, h[] + 10], ["Cat", "Dog", "Bird"] )


	push!(popList, PopUpMap(myPop ) )
	#---------- end buttons
	#Enable text input
	SDL_StartTextInput();

	#=
	Before we go into the main loop we declare a string to hold our text and render it to a texture. We then call 
	SDL_StartTextInput so the SDL text input functionality is enabled.
	=#

	#While application is running

	while( !quit )

		renderText::Bool = false;					# The rerender text flag

		while Bool(SDL_PollEvent(SDLevent))			# Handle events on queue
			event_ref = SDLevent
			evt = event_ref[]
			evt_ty = evt.type
			evt_key = evt.key
			evt_text = evt.text
			evt_mouseClick = evt.button
 	
			# We only want to update the input text texture when we need to so we have a flag that keeps track of whether we need to update the texture.
		
			if( evt_ty == SDL_KEYDOWN )							#Special key input

				#Handle backspace
				if( evt_key.keysym.sym == SDLK_BACKSPACE && length(inputText) > 0 )
					if (length(inputText) - cursorLocation - 1) >= 0
						newString = first(inputText, length(inputText) - cursorLocation - 1)
					else
						newString = ""
					end
					println(cursorLocation," ",newString)
					inputText = newString * last(inputText, cursorLocation)
					#inputText = String(chop(inputText, tail = 1))				# remove last item; chop return a substring, so we have to cast it as String
					renderText = true;
					cursorLocation += 1											# move cursor as text expands
				elseif evt_key.keysym.sym == SDLK_RETURN || evt_key.keysym.sym == SDLK_KP_ENTER
					return ["OK", inputText]
				elseif evt_key.keysym.sym == SDLK_LEFT 
					cursorLocation += 1			
				elseif evt_key.keysym.sym == SDLK_RIGHT 
					cursorLocation -= 1
					if cursorLocation <= 0
						cursorLocation = 0
					end	
				end

				# SDLK_LEFT, SDLK_RIGHT
				# SDLK_LEFT = 1073741904
				# SDLK_RIGHT = 1073741903
			#=
			There are a couple special key presses we want to handle. When the user presses backspace we want to remove the last character 
			from the string. When the user is holding control and presses c, we want to copy the current text to the clip board using 
			SDL_SetClipboardText. You can check if the ctrl key is being held using SDL_GetModState.

			When the user does ctrl + v, we want to get the text from the clip board using SDL_GetClipboardText. This function returns a 
			newly allocated string, so we should get this string, copy it to our input text, then free it once we're done with it.

			Also notice that whenever we alter the contents of the string we set the text update flag.
			=#
			#Special text input event
			elseif( evt_ty == SDL_TEXTINPUT )
				textTemp = NTupleToString(evt_text.text)
				if (length(inputText) - cursorLocation ) >= 0
						leftString = first(inputText, length(inputText) - cursorLocation )
				else
					leftString = ""
				end
				inputText = leftString * textTemp * last(inputText, cursorLocation)
				#inputText = inputText * textTemp				# * is Julila concatenate
				renderText = true;
				
			elseif( evt_ty == SDL_MOUSEBUTTONDOWN )
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				for butMap in buttonList
					println(butMap.leftTop,", ",butMap.rightBottom)
					if (butMap.rightBottom[1] > x > butMap.leftTop[1]) && (butMap.rightBottom[2] > y > butMap.leftTop[2])
						butMap.state = "clicked"
					end
				end
				for popMap in popList
					if (popMap.rightBottom[1] > x > popMap.leftTop[1]) && (popMap.rightBottom[2] > y > popMap.leftTop[2])
						#popMap.popUp.state = "clicked"
						println("pre-state change ", popMap.leftTop,", ",popMap.rightBottom)
						stateChange(popMap)
						draw(popMap.popUp, [x,y])					# enter pop-up button drawing and selection loop
					end
				end
			
			#=elseif( evt_ty == SDL_MOUSEBUTTONUP )
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				for popMap in popList
					if (popMap.rightBottom[1] > x > popMap.leftTop[1]) && (popMap.rightBottom[2] > y > popMap.leftTop[2])
						#popMap.popUp.state = "unclicked"
						draw(popMap.popUp, [x,y])					# enter pop-up button drawing and selection loop
					end
				end
			=#
			end
		end
		#=
		With text input enabled, your key presses will also generate SDL_TextInputEvents which simplifies things like shift key and caps lock. 
		Here we first want to check that we're not getting a ctrl and c/v event because we want to ignore those since they are already handled 
		as keydown events. If it isn't a copy or paste event, we append the character to our input string.
		=#
	
		if( renderText )						# Rerender text if needed
			if( inputText != "" )				# Text is not empty
				#Render new text
				#Globals.inputTextTexture = loadFromRenderedText(Globals,  inputText, textColor,  gFont);	# inputText.c_str(), textColor );
				draw(myInputBox)
			else								#Text is empty
				#Render space texture
				InputBox.valueText = " "
				#Globals.inputTextTexture = loadFromRenderedText(Globals, " ", textColor, gFont );
			end
		end
		#=
		If the text render update flag has been set, we rerender the texture. One little hack we have here is if we have an empty string, 
		we render a space because SDL_ttf will not render an empty string.
		=#

		SDL_SetRenderDrawColor(renderer, 250, 250, 250, 255)
		SDL_RenderClear( renderer );

		#Render text textures


		draw(promptText)
		
#		myInputBox = InputBox( [35,	Globals.promptTextTexture.mHeight÷2 + 17],
#								 [ (DoubleWidth - 140)÷2, Globals.inputTextTexture.mHeight÷2 + 5
#								 ] )
#		drawInputBox(renderer, myInputBox)
		
		#=
					SDL_Rect( 70,
							floor(Int64,(Globals.promptTextTexture.mHeight)) + 35,
							DoubleWidth - 140, 
							Globals.inputTextTexture.mHeight + 10
							)
						=#
#=
		render(Globals.renderer, 
				Globals.inputTextTexture,  
				#40, #floor(Int64,( SCREEN_WIDTH - Globals.inputTextTexture.mWidth ) / 2 ), 
				#DoubleWidth - (Globals.inputTextTexture.mWidth + 20),
				DoubleWidth - 70 - (Globals.inputTextTexture.mWidth + 10),
				floor(Int64,(Globals.promptTextTexture.mHeight)) + 40,
				Globals.inputTextTexture.mWidth, 
				Globals.inputTextTexture.mHeight );
=#
		#-------------------
		# need to get size of text for cursor using cursorLocation
		TTF_SizeText(gFont, last(inputText, cursorLocation), w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
		cursorScootch = w[]
		#-------------------
		if (time() - onTime) < 1
			thickLineRGBA(renderer,
							DoubleWidth - 70 - 10 - cursorScootch, 
							floor(Int64, h[]) + 45, 
							DoubleWidth - 70 - 10 - cursorScootch, 
							floor(Int64, h[]) + 75, 
							3, 
							0, 0, 0, 255)

			cursorBlink = false

		elseif   1 < (time() - onTime) < 2				# show during this time
			#vlineRGBA(Globals.renderer, DoubleWidth - 70, floor(Int64,(Globals.promptTextTexture.mHeight)), floor(Int64,(Globals.promptTextTexture.mHeight)) + 40, 0, 250, 0, 255);
			thickLineRGBA(renderer,
							DoubleWidth - 70 - 10 - cursorScootch, 
							 floor(Int64, h[]) + 45, 
							DoubleWidth - 70 - 10 - cursorScootch, 
							floor(Int64, h[] ) + 75, 
							3, 
							255, 250, 255, 255)
			cursorBlink = true

		else				# reset after 1 cycle
			onTime = time()
			#println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> else ", time() - offTime,", ", time() - onTime)
		end

		#Update screen
		for butMap in buttonList									# button maps help with managing clicks
			if butMap.state == "unclicked"
				buttonDraw(butMap.button)
			elseif butMap.state == "clicked"
				buttonDrawClicked(butMap.button)
				butMap.state = "unclicked"
				quit = true
				buttonClicked = butMap.button.TextStim.textMessage
			end
		end

		#if firstRun == true
			SDL_GetMouseState(mX, mY)
			draw(myPop, [ mX[], mY[] ] )
			firstRun = false
			#println("drew popup")
		#end
		SDL_RenderPresent( renderer );
		# check for enter or cancel
	end
	#	At the end of the main loop we render the prompt text and the input text.

	
	SDL_StopTextInput();										#Disable text input

	hideWindow(dialogWin)
	SDL_RenderPresent( renderer );
	#SDL_DestroyWindow(SDL_Window * Window)
	closeWinOnly(dialogWin)

	return [buttonClicked, inputText]



end
#-=============================================
function textInputDialog(dlgTitle::String, promptString::String, defaultText::String)
	SCREEN_WIDTH = 350
	SCREEN_HEIGHT = 150

	firstRun = true
	buttonClicked = "NoButton"
	quit::Bool = false;

	mX = Ref{Cint}()					# pointers that will receive mouse coordinates
	mY = Ref{Cint}()

	cursorLocation = 0											# after the last character.  This is in charachter units, not pixels
	cursorPixels = 0											# negative (leftward) pixels from end of string
																# this cycles during each refresh from true to false
	onTime = 0												# for timing of cursor blinns
	offTime = 0
 	# these are used later to get the size of the text when moving the cursor
	w = Ref{Cint}()
	h = Ref{Cint}()

	SDLevent = Ref{SDL_Event}()									#Event handler
	
	textColor =  SDL_Color(0, 0, 0, 0xFF)						#Set text color as black

	InitPsychoJL()

	dialogWin = Window(title = dlgTitle, [SCREEN_WIDTH, SCREEN_HEIGHT], false)

	SDLwindow = dialogWin.win
	renderer = dialogWin.renderer

	Globals = SDLGlobals(SDLwindow, renderer, LTexture(C_NULL, 0 ,0), LTexture(C_NULL, 0 ,0) )
	
	gFont = dialogWin.font
	#gFont = TTF_OpenFont("/Users/MattPetersonsAccount/Documents/Development/Julia/PsychoJL/sans.ttf", 36);		# global font
	if gFont == C_NULL
		println("*** Error: gFont is NULL")
	end
	SDL_PumpEvents()					# this erases whatever random stuff was in the backbuffer
	SDL_RenderClear(Globals.renderer)			#
	#-===== Their code:
	#The current input text.
	#inputText::String = "Some Text";

	inputText = defaultText
	#TTF_SetFontStyle(gFont, TTF_STYLE_ITALIC)
	Globals.promptTextTexture = loadFromRenderedText(Globals, promptString, textColor,  dialogWin.italicFont);		# inputText.c_str(), textColor );
	leftX = (SCREEN_WIDTH - Globals.promptTextTexture.mWidth)÷2					
	promptText = TextStim(dialogWin, promptString, [SCREEN_WIDTH, 20 ],		# you would think it would be SCREEN_WIDTH÷2, but hi-res messes it centers at SCREEN_WIDTH÷4.
							color = [0, 0, 0], 
							fontSize = 24, 
							horizAlignment = 0, 
							vertAlignment = -1,
							style = "italic" )
	#TTF_SetFontStyle(gFont, TTF_STYLE_NORMAL )

	Globals.inputTextTexture = loadFromRenderedText(Globals, inputText, textColor,  gFont);		# inputText.c_str(), textColor );
	#--------- Make buttons
	buttonList = []
	
	OKtext = TextStim(dialogWin, "OK",	[0, 0])
	OKbutton = ButtonStim(dialogWin,
				[ round(Int64, SCREEN_WIDTH * 0.75), round(Int64, SCREEN_HEIGHT * 0.75)],		# was 0.75, buthigh dpi shenanigans
				[ round(Int64, SCREEN_WIDTH * 0.25), 68],
				OKtext,					
				"default")
	push!(buttonList, ButtonMap(OKbutton, "OK-clicked") )

	CancelText = TextStim(dialogWin, "Cancel",	[0, 0])
	CancelButton = ButtonStim(dialogWin,
				[ round(Int64, SCREEN_WIDTH * 0.25), round(Int64, SCREEN_HEIGHT * 0.75)],		# was 0.75, buthigh dpi shenanigans
				[ round(Int64, SCREEN_WIDTH * 0.25), 68],
				CancelText,					
				"other")
	push!(buttonList, ButtonMap(CancelButton, "Cancel-clicked") )


	#---------- end buttons
	#---------- Make PopUp
	popList = []
	myPop = PopUpMenu(dialogWin, [70,100], [100, Globals.inputTextTexture.mHeight + 10], ["Cat", "Dog", "Bird"] )
	# mouse clicks say 14,41 and 57,58
	# popUp		20, 75		120, 125		size = 100, 51
	# popUpMap	20, 75		120, 125
	# new scaled Popmap	10,37 60,62
	push!(popList, PopUpMap(myPop ) )
	#---------- end buttons
	#Enable text input
	SDL_StartTextInput();

	#=
	Before we go into the main loop we declare a string to hold our text and render it to a texture. We then call 
	SDL_StartTextInput so the SDL text input functionality is enabled.
	=#

	#While application is running

	while( !quit )

		renderText::Bool = false;					# The rerender text flag

		while Bool(SDL_PollEvent(SDLevent))			# Handle events on queue
			event_ref = SDLevent
			evt = event_ref[]
			evt_ty = evt.type
			evt_key = evt.key
			evt_text = evt.text
			evt_mouseClick = evt.button
 	
			# We only want to update the input text texture when we need to so we have a flag that keeps track of whether we need to update the texture.
		
			if( evt_ty == SDL_KEYDOWN )							#Special key input

				#Handle backspace
				if( evt_key.keysym.sym == SDLK_BACKSPACE && length(inputText) > 0 )
					if (length(inputText) - cursorLocation - 1) >= 0
						newString = first(inputText, length(inputText) - cursorLocation - 1)
					else
						newString = ""
					end
					println(cursorLocation," ",newString)
					inputText = newString * last(inputText, cursorLocation)
					#inputText = String(chop(inputText, tail = 1))				# remove last item; chop return a substring, so we have to cast it as String
					renderText = true;
					cursorLocation += 1											# move cursor as text expands
				elseif evt_key.keysym.sym == SDLK_RETURN || evt_key.keysym.sym == SDLK_KP_ENTER
					return ["OK", inputText]
				elseif evt_key.keysym.sym == SDLK_LEFT 
					cursorLocation += 1			
				elseif evt_key.keysym.sym == SDLK_RIGHT 
					cursorLocation -= 1
					if cursorLocation <= 0
						cursorLocation = 0
					end	
				end

				# SDLK_LEFT, SDLK_RIGHT
				# SDLK_LEFT = 1073741904
				# SDLK_RIGHT = 1073741903
			#=
			There are a couple special key presses we want to handle. When the user presses backspace we want to remove the last character 
			from the string. When the user is holding control and presses c, we want to copy the current text to the clip board using 
			SDL_SetClipboardText. You can check if the ctrl key is being held using SDL_GetModState.

			When the user does ctrl + v, we want to get the text from the clip board using SDL_GetClipboardText. This function returns a 
			newly allocated string, so we should get this string, copy it to our input text, then free it once we're done with it.

			Also notice that whenever we alter the contents of the string we set the text update flag.
			=#
			#Special text input event
			elseif( evt_ty == SDL_TEXTINPUT )
				textTemp = NTupleToString(evt_text.text)
				if (length(inputText) - cursorLocation ) >= 0
						leftString = first(inputText, length(inputText) - cursorLocation )
				else
					leftString = ""
				end
				inputText = leftString * textTemp * last(inputText, cursorLocation)
				#inputText = inputText * textTemp				# * is Julila concatenate
				renderText = true;
				
			elseif( evt_ty == SDL_MOUSEBUTTONDOWN )
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				for butMap in buttonList
					println(butMap.leftTop,", ",butMap.rightBottom)
					if (butMap.rightBottom[1] > x > butMap.leftTop[1]) && (butMap.rightBottom[2] > y > butMap.leftTop[2])
						butMap.state = "clicked"
					end
				end
				for popMap in popList
					if (popMap.rightBottom[1] > x > popMap.leftTop[1]) && (popMap.rightBottom[2] > y > popMap.leftTop[2])
						#popMap.popUp.state = "clicked"
						println("pre-state change ", popMap.leftTop,", ",popMap.rightBottom)
						stateChange(popMap)
						draw(popMap.popUp, [x,y])					# enter pop-up button drawing and selection loop
					end
				end
			
			#=elseif( evt_ty == SDL_MOUSEBUTTONUP )
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				for popMap in popList
					if (popMap.rightBottom[1] > x > popMap.leftTop[1]) && (popMap.rightBottom[2] > y > popMap.leftTop[2])
						#popMap.popUp.state = "unclicked"
						draw(popMap.popUp, [x,y])					# enter pop-up button drawing and selection loop
					end
				end
			=#
			end
		end
		#=
		With text input enabled, your key presses will also generate SDL_TextInputEvents which simplifies things like shift key and caps lock. 
		Here we first want to check that we're not getting a ctrl and c/v event because we want to ignore those since they are already handled 
		as keydown events. If it isn't a copy or paste event, we append the character to our input string.
		=#
	
		if( renderText )						# Rerender text if needed
			if( inputText != "" )				# Text is not empty
				#Render new text
				Globals.inputTextTexture = loadFromRenderedText(Globals,  inputText, textColor,  gFont);	# inputText.c_str(), textColor );
			
			else								#Text is empty
				#Render space texture
				Globals.inputTextTexture = loadFromRenderedText(Globals, " ", textColor, gFont );
			end
		end
		#=
		If the text render update flag has been set, we rerender the texture. One little hack we have here is if we have an empty string, 
		we render a space because SDL_ttf will not render an empty string.
		=#

		SDL_SetRenderDrawColor(renderer, 250, 250, 250, 255)
		SDL_RenderClear( renderer );

		#Render text textures

		DoubleWidth = SCREEN_WIDTH * 2									# I don't know if this is a workaround for Retina or SDL_WINDOW_ALLOW_HIGHDPI, but a 400 pixel width yields 800 pixels 
		#=
		render(Globals.renderer, 
				Globals.promptTextTexture,  
				#	floor(Int64,DoubleWidth -( DoubleWidth - Globals.promptTextTexture.mWidth ) / 2), 	#SCREEN_WIDTH -
				floor( Int64, SCREEN_WIDTH - (Globals.promptTextTexture.mWidth/2) ),
				20, 
				Globals.promptTextTexture.mWidth, 
				Globals.promptTextTexture.mHeight );
		=#
		draw(promptText)
		
		myInputBox = InputBox( [35,	Globals.promptTextTexture.mHeight÷2 + 17],
								 [ (DoubleWidth - 140)÷2, Globals.inputTextTexture.mHeight÷2 + 5
								 ] )
		drawInputBox(renderer, myInputBox)
		
		#=
					SDL_Rect( 70,
							floor(Int64,(Globals.promptTextTexture.mHeight)) + 35,
							DoubleWidth - 140, 
							Globals.inputTextTexture.mHeight + 10
							)
						=#

		render(Globals.renderer, 
				Globals.inputTextTexture,  
				#40, #floor(Int64,( SCREEN_WIDTH - Globals.inputTextTexture.mWidth ) / 2 ), 
				#DoubleWidth - (Globals.inputTextTexture.mWidth + 20),
				DoubleWidth - 70 - (Globals.inputTextTexture.mWidth + 10),
				floor(Int64,(Globals.promptTextTexture.mHeight)) + 40,
				Globals.inputTextTexture.mWidth, 
				Globals.inputTextTexture.mHeight );
		#-------------------
		# need to get size of text for curso using cursorLocation
		TTF_SizeText(gFont, last(inputText, cursorLocation), w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
		cursorScootch = w[]
		#-------------------
		if (time() - onTime) < 1
			thickLineRGBA(Globals.renderer,
							DoubleWidth - 70 - 10 - cursorScootch, 
							floor(Int64,(Globals.promptTextTexture.mHeight)) + 45, 
							DoubleWidth - 70 - 10 - cursorScootch, 
							floor(Int64,(Globals.promptTextTexture.mHeight)) + 75, 
							3, 
							0, 0, 0, 255)

			cursorBlink = false

		elseif   1 < (time() - onTime) < 2				# show during this time
			#vlineRGBA(Globals.renderer, DoubleWidth - 70, floor(Int64,(Globals.promptTextTexture.mHeight)), floor(Int64,(Globals.promptTextTexture.mHeight)) + 40, 0, 250, 0, 255);
			thickLineRGBA(Globals.renderer,
							DoubleWidth - 70 - 10 - cursorScootch, 
							 floor(Int64,(Globals.promptTextTexture.mHeight)) + 45, 
							DoubleWidth - 70 - 10 - cursorScootch, 
							floor(Int64,(Globals.promptTextTexture.mHeight)) + 75, 
							3, 
							255, 250, 255, 255)
			cursorBlink = true

		else				# reset after 1 cycle
			onTime = time()
			#println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> else ", time() - offTime,", ", time() - onTime)
		end

		#Update screen
		for butMap in buttonList									# button maps help with managing clicks
			if butMap.state == "unclicked"
				buttonDraw(butMap.button)
			elseif butMap.state == "clicked"
				buttonDrawClicked(butMap.button)
				butMap.state = "unclicked"
				quit = true
				buttonClicked = butMap.button.TextStim.textMessage
			end
		end

		#if firstRun == true
			SDL_GetMouseState(mX, mY)
			draw(myPop, [ mX[], mY[] ] )
			firstRun = false
			#println("drew popup")
		#end
		SDL_RenderPresent( renderer );
		# check for enter or cancel
	end
	#	At the end of the main loop we render the prompt text and the input text.

	
	SDL_StopTextInput();										#Disable text input

	hideWindow(dialogWin)
	SDL_RenderPresent( renderer );
	#SDL_DestroyWindow(SDL_Window * Window)
	closeWinOnly(dialogWin)

	return [buttonClicked, inputText]



end
#-==================================================================================================================
#-==================================================================================================================
#-==================================================================================================================
#= 
	if key has a dict, its a pull-down menu, else its a text box's default values

	- find widest key
	- widest key + padding determines width of left column (there needs to be some minimum
	- both buttons are as wide as the left column (some minimum width)
	- right column is the rest of the screen minus padding
	- need to implement ways to change input widget focus
	- would love a way to pick TTF from various operating systems

=#
"""
	DlgFromDict(dlgDict::Dict)

Displays a dialog box constructed from a dictionary.

**Inputs:** Dictionary defining the input fields (keys) and pre-filled values (values) for the user dialog\n
If the value is a string, that indicates a text input box with a default value.
If the value is a tuple, it indicates that the widget should be pop-up menu populated by the choices listed in the tuple\n
**Outputs:** Dictionary of responses.  Keys are from the input dictionary.

Example:
```julia
	exp_info = Dict("subject_nr"=>0, "age"=>0, "handedness"=>("right","left","ambi"), 
            "gender"=>("male","female","other","prefer not to say"))


	new_info = DlgFromDict(exp_info)
```
![alternative text](dlgDictSmall.png)
"""
function DlgFromDict(dlgDict::Dict)
	DEBUG = true
	
	SCREEN_WIDTH = 350
	SCREEN_HEIGHT = 150

	firstRun = true
	buttonClicked = "NoButton"
	quit::Bool = false;

	focusedInput = 1		# -99

	mX = Ref{Cint}()					# pointers that will receive mouse coordinates
	mY = Ref{Cint}()

	cursorLocation = 0											# after the last character.  This is in charachter units, not pixels
	cursorPixels = 0											# negative (leftward) pixels from end of string
																# this cycles during each refresh from true to false
	onTime = 0												# for timing of cursor blinns
	offTime = 0
 	# these are used later to get the size of the text when moving the cursor
	w = Ref{Cint}()
	h = Ref{Cint}()

	SDLevent = Ref{SDL_Event}()									#Event handler
	
	textColor =  SDL_Color(0, 0, 0, 0xFF)						#Set text color as black

#	InitPsychoJL()												# Is it bad form to call this here?

	dialogWin = Window([SCREEN_WIDTH, SCREEN_HEIGHT], false, title = "")

	SDLwindow = dialogWin.win
	renderer = dialogWin.renderer

	#Globals = SDLGlobals(SDLwindow, renderer, LTexture(C_NULL, 0 ,0), LTexture(C_NULL, 0 ,0) )
	
	gFont = dialogWin.font

	if gFont == C_NULL
		println("*** Error: gFont is NULL")
	end
	SDL_PumpEvents()									# this erases whatever random stuff was in the backbuffer
	SDL_SetRenderDrawColor(dialogWin.renderer, 250, 250, 250, 255)
	SDL_RenderClear(dialogWin.renderer)		
	#--- DictDlg really starts here ------------------------
	# 	- find widest key and draw the key labels
	widestKey = 20										# arbitrary minimum size
	labels = []
	i = 1

	outDictionary = deepcopy(dlgDict)					# we really just want the keys...we'll replace the values later
	for (key, value) in dlgDict 
		TTF_SizeText(gFont, key, w::Ref{Cint}, h::Ref{Cint})
		if w[] > widestKey
			widestKey = w[]
		end
		println(key,", ", w[])
		label = TextStim(dialogWin, key, [20, 10 + (i*(h[] + 10)) ],
							color = [0, 0, 0], 
							fontSize = 24, 
							horizAlignment = -1, 
							vertAlignment = 1 )
		push!(labels, label)
		i += 1
	end
	widestKey ÷= 2																# Damn hi-res stuff!
	#---------
	# draw labels along left side
	for label in labels
		draw(label)
	end
	#---------
	# draw OK button
	buttonList = []
	OKtext = TextStim(dialogWin, "OK",	[0, 0])
	OKbutton = ButtonStim(dialogWin,
				#[ 20 + (widestKey),  10 + ((length(labels)+1) * (h[] +10)) ],		# was 0.75, buthigh dpi shenanigans
				#[ widestKey, h[] + 10],
				[ round(Int64, SCREEN_WIDTH *0.8), SCREEN_HEIGHT - (h[] ÷ 2)],
				[ (SCREEN_WIDTH ÷ 5) , h[] + 10],
				OKtext,					
				"default")
	_, ytemp = OKbutton.pos
	ytemp ÷= 2
	#OKbutton.pos[2] = ytemp
	push!(buttonList, ButtonMap(OKbutton, "OK-clicked") )
	buttonDraw(OKbutton)
	#---------
	# draw Cancel button
	Canceltext = TextStim(dialogWin, "Cancel",	[0, 0])
	CancelButton = ButtonStim(dialogWin,
				[ round(Int64, SCREEN_WIDTH *0.5), SCREEN_HEIGHT - (h[] ÷ 2)],
				[ (SCREEN_WIDTH ÷ 5) , h[] + 10],
				Canceltext,					
				"other")
	_, ytemp = CancelButton.pos
	ytemp ÷= 2
	#CancelButton.pos[2] = ytemp
	push!(buttonList, ButtonMap(CancelButton, "Cancel-clicked") )
	buttonDraw(CancelButton)
	#-------------
	# draw input widgets
	inputWidgets = []
	inputMapList = []
	popUpList = []
	i = 0
	for (key, value) in dlgDict 
		leftSide = 40 + widestKey
		topSide = 17 + (i*(h[] + 10))
		if value isa String || value isa Number									# input text box
			if value isa Number
				value = string(value)											# convert numbers to strings
			end
			if value == ""
				value = " "														#requires at least one charcters
			end
			myInputBox = InputBox(dialogWin, value, [leftSide,	topSide÷2 ],		#-8
							[SCREEN_WIDTH - (widestKey + 60), h[]÷2 + 2	], 
							key
							)
			push!(inputWidgets, myInputBox)
			push!(inputMapList, InputBoxMap(myInputBox))
			draw(myInputBox)
			i += 1
		elseif value isa Tuple
			#leftSide2 = leftSide + ((SCREEN_WIDTH - leftSide)÷2)							# input box is top left, this is center
			leftSide2 = leftSide + ((SCREEN_WIDTH - (widestKey + 60))÷2)							# input box is top left, this is center
			leftSide2 *= 2
			topSide2 = topSide + h[]÷2
			myPop = PopUpMenu(dialogWin, 
								#[80 + widestKey*2,	 20 + (i*(h[] + 10))*2 ], 			# center pos
								#[leftSide2 , topSide2],
								[leftSide,	topSide ],
								[ (SCREEN_WIDTH - (widestKey + 60))*2, (h[]÷2 + 2)*2	], 
								collect(value), 		# collect turns tuple into an array
								key )
			push!(inputWidgets, myPop)
			push!(inputMapList, PopUpMap(myPop ))
			push!(popUpList, PopUpMap(myPop ))
			draw(myPop, [ -99, -99 ] )
			i += 1
		end
	end
	#	drawInputBox(renderer, myInputBox)
	bend = 0

	# wait for KeyUp first so that we can debounce
	# but I don't think it will work for this, as dialogWin is not the main window!
	# therefore, it contains a different .firstKey!
	#=
	done = false
	while done == false || dialogWin.firstKey == false
		while Bool(SDL_PollEvent(SDLevent))
			event_ref = SDLevent
			evt = event_ref[]
			evt_ty = evt.type
			if( evt_ty == SDL_KEYUP )
				done = true
			end
		end
	end
	=#
#	win.firstKey = true							# couldn't find a way to inject a Key_UP event in the queue, so did this instead
	SDL_StartTextInput()

	while( !quit )
		renderText::Bool = false;					# The rerender text flag
		while Bool(SDL_PollEvent(SDLevent))			# Handle events on queue
			event_ref = SDLevent
			evt = event_ref[]
			evt_ty = evt.type
			evt_key = evt.key
			evt_text = evt.text
			evt_mouseClick = evt.button
 	
			# We only want to update the input text texture when we need to so we have a flag that keeps track of whether we need to update the texture.
			if( evt_ty == SDL_KEYDOWN )							#Special key input

				#Handle backspace
				if typeof(inputWidgets[focusedInput]) == InputBox
					if( evt_key.keysym.sym == SDLK_BACKSPACE && length(inputWidgets[focusedInput].valueText) > 0 ) 
						#if (length(inputText) - cursorLocation - 1) >= 0
						#	newString = first(inputText, length(inputText) - cursorLocation - 1)
						if (length(inputWidgets[focusedInput].valueText) - cursorLocation - 1) >= 0
							newString = first(inputWidgets[focusedInput].valueText, length(inputWidgets[focusedInput].valueText) - cursorLocation - 1)
						
						else
							newString = ""
						end
						println("\n.........",cursorLocation," ",newString) 
						inputWidgets[focusedInput].valueText = newString * last(inputWidgets[focusedInput].valueText, cursorLocation)
						#inputText = String(chop(inputText, tail = 1))				# remove last item; chop return a substring, so we have to cast it as String
						renderText = true;
						cursorLocation += 1											# move cursor as text expands

					elseif evt_key.keysym.sym == SDLK_LEFT 
						cursorLocation += 1			
					elseif evt_key.keysym.sym == SDLK_RIGHT 
						cursorLocation -= 1
						if cursorLocation <= 0
							cursorLocation = 0
						end	
					end
				end
				if evt_key.keysym.sym == SDLK_RETURN || evt_key.keysym.sym == SDLK_KP_ENTER
					for inWidgit in inputWidgets
						outDictionary[inWidgit.key] = inWidgit.valueText
					end
					SDL_StopTextInput();										#Disable text input
					hideWindow(dialogWin)
					SDL_RenderPresent( renderer );
					closeWinOnly(dialogWin)

					return ["OK", outDictionary]
				end
			elseif( evt_ty == SDL_TEXTINPUT && typeof(inputWidgets[focusedInput]) == InputBox)												#Special text input event
				textTemp = NTupleToString(evt_text.text)
				if (length(inputWidgets[focusedInput].valueText) - cursorLocation ) >= 0
						leftString = first(inputWidgets[focusedInput].valueText, length(inputWidgets[focusedInput].valueText) - cursorLocation )
				else
					leftString = ""
				end
				inputWidgets[focusedInput].valueText = leftString * textTemp * last(inputWidgets[focusedInput].valueText, cursorLocation)
				#inputText = inputText * textTemp				# * is Julila concatenate
				renderText = true;
				if DEBUG; println("...",inputWidgets[focusedInput].valueText); end
			#---------------------------------------------------------------------------------------
			#=	make list of clicks
				determine who gets the click
					if clicks > 1
						if focus is one of them
							focus gets click
						else
							give error stating that too many widgets got a click
					else
						widget gets click
				act on the click
			=#
			elseif( evt_ty == SDL_MOUSEBUTTONDOWN )				# new version makes a list of clicked items, and the item with the focus is the winner
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				println("evt_mouseClick.x/y = ",x,", ", y )
				for butMap in buttonList
					println(butMap.leftTop,", ",butMap.rightBottom)
					if (butMap.rightBottom[1] > x > butMap.leftTop[1]) && (butMap.rightBottom[2] > y > butMap.leftTop[2])
						butMap.state = "clicked"
					end
				end


				clickedItemIndexes = []
				#----------------------
				# make list of clicks
				for i in eachindex(inputMapList)
					inMap = inputMapList[i]
					if (inMap.rightBottom[1] > x > inMap.leftTop[1]) && (inMap.rightBottom[2] > y > inMap.leftTop[2])
						println("ooooo in a inMap")
						println("  ooooo state ", inMap.parent.state )
						println("    ooooo typeof ", typeof(inMap.parent))
						push!(clickedItemIndexes, i)
					end
				end
				#----------------------
				# determine who gets the click
				focusClicked = false
				focusIndex = -99
				for ci in clickedItemIndexes
					if inputMapList[ci].parent.focus == true
						focusClicked = true
						focusIndex = ci
					end
				end
				#----------------------
				# if more than one item clicked, use focus as a tie-break (the focused item is expanded and covering another widget).
				if length(clickedItemIndexes) > 1		
														# for now, we assume focus was clicked...but might need to check

					if typeof(inputMapList[focusIndex]) == ButtonMap
						inputMapList[focusIndex].state = "clicked"
					elseif typeof(inputMapList[focusIndex]) == PopUpMap
						stateChange(inputMapList[focusIndex])
						draw(inputMapList[focusIndex].parent, [x,y])
					end

				elseif length(clickedItemIndexes) == 1
					index = clickedItemIndexes[1]

					if typeof(inputMapList[index]) == ButtonMap
						inputMapList[i].state = "clicked"
					elseif typeof(inputMapList[index]) == PopUpMap
						stateChange(inputMapList[index])
						draw(inputMapList[index].parent, [x,y])
					end
					focusedInput = index

					for i in eachindex(inputMapList)
						if i == focusedInput
							inputMapList[i].parent.focus = true
						else
							inputMapList[i].parent.focus = false
						end
					end

				else
					println(".......", evt_ty," ,",typeof(inputWidgets[focusedInput]))

				end

			end
#=			
			elseif( evt_ty == SDL_MOUSEBUTTONDOWN )
				# new version makes a list of clicked items, and the item with the focus is the winner
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				println("evt_mouseClick.x/y = ",x,", ", y )
				clickedItemIndexes = []
				for i in eachindex(inputMapList)
					inMap = inputMapList[i]
					if (inMap.rightBottom[1] > x > inMap.leftTop[1]) && (inMap.rightBottom[2] > y > inMap.leftTop[2])
						println("ooooo in a inMap")
						println("  ooooo state ", inMap.parent.state )
						println("    ooooo typeof ", typeof(inMap.parent))
						push!(clickedItemIndexes, i)
					end
				end
				focusFound = false
				for i in clickedItemIndexes
					if inputMapList[i].parent.focus == true					# we found a winner!
						focusFound = true
						if typeof(inputMapList[i]) == ButtonMap
							inputMapList[i].state = "clicked"
						elseif typeof(inputMapList[i]) == PopUpMap
							stateChange(inputMapList[i])
							draw(inputMapList[i].parent, [x,y])
						end
					elseif focusFound == false						# we never found the focus, so go with the only one on the list.  If list is>0, send error
						if length(clickedItemIndexes) == 1
							inMap = inputMapList[i]
							# set focus flags
							if (inMap.rightBottom[1] > x > inMap.leftTop[1]) && (inMap.rightBottom[2] > y > inMap.leftTop[2])
								focusedInput = i
								inMap.parent.focus = true
								println("focus = ", inMap.leftTop, inMap.rightBottom)
							else
								inMap.parent.focus = false


			we are in a subset of clicked items. Need all so that we can unfocus the others.
							end
							# do widget specific stuff
							if typeof(inputMapList[i]) == ButtonMap
								inputMapList[i].state = "clicked"
							elseif typeof(inputMapList[i]) == PopUpMap
								stateChange(inputMapList[i])
								draw(inputMapList[i].parent, [x,y])
							end
							focusedInput = i
						else
							#buf = 
							error("\n*** You have a problem, as two or more widgets received a click \n", clickedItemIndexes,"\n")
						end
					end
				end
			end
=#

			
#-----------------------------------------------------------------------------------------------------
#			what about the lines setting and unsetting focus?	
			# old version below
			#=
			elseif( evt_ty == SDL_MOUSEBUTTONDOWN )
				x = evt_mouseClick.x
				y = evt_mouseClick.y
				println("evt_mouseClick.x/y = ",x,", ", y )
				clickOverlap = false
				# skip next part of mouse click overlaps with a popup whose state is "clicked"
				for i in eachindex(inputMapList)
					inMap = inputMapList[i]
					if (inMap.rightBottom[1] > x > inMap.leftTop[1]) && (inMap.rightBottom[2] > y > inMap.leftTop[2])
						println("ooooo in a inMap")
						println("  ooooo state ", inMap.parent.state )
						println("    ooooo typeof ", typeof(inMap.parent))
						if inMap.parent.state == "clicked" && typeof(inMap.parent) == PopUpMenu
							clickOverlap = true
							println(">>>> clickOverlap = true")
							stateChange(inMap)
							draw(inMap.parent, [x,y])			# 	CALLED		# enter pop-up button drawing and selection loop
						end
					end
				end
				if clickOverlap == false			# skip these if the mouse click was in an open pop-up
					for i in eachindex(inputMapList)
						inMap = inputMapList[i]
						if (inMap.rightBottom[1] > x > inMap.leftTop[1]) && (inMap.rightBottom[2] > y > inMap.leftTop[2])
							focusedInput = i
							inMap.parent.focus = true
							println("focus = ", inMap.leftTop, inMap.rightBottom)
						else
							inMap.parent.focus = false
						end
					end
					for butMap in buttonList
						if (butMap.rightBottom[1] > x > butMap.leftTop[1]) && (butMap.rightBottom[2] > y > butMap.leftTop[2])
							butMap.state = "clicked"
						end
					end
					for popMap in  popUpList
						if (popMap.rightBottom[1] > x > popMap.leftTop[1]) && (popMap.rightBottom[2] > y > popMap.leftTop[2])
							#popMap.popUp.state = "clicked"
							println("pre-state change ", popMap.leftTop,", ",popMap.rightBottom)
							stateChange(popMap)
							println("post-state change ", popMap.leftTop,", ",popMap.rightBottom)
							
							draw(popMap.parent, [x,y])			# 	CALLED		# enter pop-up button drawing and selection loop
						end

					end
				end
				println(">>>>>>>>>> button end ", bend)
				bend+=1
			end  # evt_ty == SDL_MOUSEBUTTONDOWN 
			=#
		end
		#=
		With text input enabled, your key presses will also generate SDL_TextInputEvents which simplifies things like shift key and caps lock. 
		Here we first want to check that we're not getting a ctrl and c/v event because we want to ignore those since they are already handled 
		as keydown events. If it isn't a copy or paste event, we append the character to our input string.
		=#
		if( renderText )						# Rerender text if needed
			if typeof(inputWidgets[focusedInput]) == InputBox

				if( inputWidgets[focusedInput].valueText != "" )				# Text is not empty
					#Render new text
					#Globals.inputTextTexture = loadFromRenderedText(Globals,  inputText, textColor,  gFont);	# inputText.c_str(), textColor );
					draw(inputWidgets[focusedInput])	
				else								#Text is empty
					#Render space texture
					inputWidgets[focusedInput].valueText = " "
					println("- draw 654: ", focusedInput)
				end
			end
		end
		SDL_SetRenderDrawColor(renderer, 250, 250, 250, 255)
		SDL_RenderClear( renderer );
		#--------------------------------------------
		# Update widgets and such
		for label in labels
			draw(label)
		end

		for i in eachindex(inputWidgets)
			if i != focusedInput					# draw the non-focus widgets first
				draw(inputWidgets[i])				# 	CALLED
			end
		end
		if focusedInput != -99						# we do this to make sure any exanded widgets are on top and not drawn over
			draw(inputWidgets[focusedInput])		# 	CALLED
		end
		#Render text textures
		DoubleWidth = SCREEN_WIDTH * 2									# I don't know if this is a workaround for Retina or SDL_WINDOW_ALLOW_HIGHDPI, but a 400 pixel width yields 800 pixels 
		#=
		myInputBox = InputBox( [35,	Globals.promptTextTexture.mHeight÷2 + 17],
								 [ (DoubleWidth - 140)÷2, Globals.inputTextTexture.mHeight÷2 + 5
								 ] )
		drawInputBox(renderer, myInputBox)
		

		render(Globals.renderer, 
				Globals.inputTextTexture,  
				#40, #floor(Int64,( SCREEN_WIDTH - Globals.inputTextTexture.mWidth ) / 2 ), 
				#DoubleWidth - (Globals.inputTextTexture.mWidth + 20),
				DoubleWidth - 70 - (Globals.inputTextTexture.mWidth + 10),
				floor(Int64,(Globals.promptTextTexture.mHeight)) + 40,
				Globals.inputTextTexture.mWidth, 
				Globals.inputTextTexture.mHeight );
		=#
		#-------------------
		if focusedInput > 0	&& typeof(inputWidgets[focusedInput]) == InputBox			# only blink cursor in a textbox that is the focus
			in = inputWidgets[focusedInput]
			# need to get size of text for curso using cursorLocation
			TTF_SizeText(dialogWin.font, 
							last(in.valueText, cursorLocation), 
							w::Ref{Cint}, 
							h::Ref{Cint})		# Ref is used if Julia controls the memory
			cursorScootch = w[]
			#-------------------
			if (time() - onTime) < 1
				thickLineRGBA(dialogWin.renderer,
								in.textRect.x + in.textRect.w -6 - cursorScootch, 
								in.textRect.y +10,
								in.textRect.x + in.textRect.w -6 - cursorScootch, 
								in.textRect.y +10 + h[]-10, 
								3, 
								255, 0, 0, 255)

				cursorBlink = false

			elseif   1 < (time() - onTime) < 2				# show during this time
				#vlineRGBA(Globals.renderer, DoubleWidth - 70, floor(Int64,(Globals.promptTextTexture.mHeight)), floor(Int64,(Globals.promptTextTexture.mHeight)) + 40, 0, 250, 0, 255);
				thickLineRGBA(dialogWin.renderer,
								in.textRect.x + in.textRect.w -6 - cursorScootch, 
								in.textRect.y +10,
								in.textRect.x + in.textRect.w -6 - cursorScootch, 
								in.textRect.y +10 + h[]-10, 
								3, 
								255, 250, 255, 255)
				cursorBlink = true

			else				# reset after 1 cycle
				onTime = time()
				#println(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> else ", time() - offTime,", ", time() - onTime)
			end
		end
		#Update screen
		for butMap in buttonList									# button maps help with managing clicks
			if butMap.state == "unclicked"
				buttonDraw(butMap.button)
			elseif butMap.state == "clicked"
				buttonDrawClicked(butMap.button)
				butMap.state = "unclicked"
				quit = true
				buttonClicked = butMap.button.TextStim.textMessage
			end
		end

		#if firstRun == true
			SDL_GetMouseState(mX, mY)
			for myPop in popUpList
				if myPop.parent.focus == true
					draw(myPop.parent, [ mX[], mY[] ] )
				end
			end
			firstRun = false
			#println("drew popup")
		#end
		SDL_RenderPresent( renderer );
		# check for enter or cancel
	end
	#--------------   Show stuff
	SDL_StopTextInput();										#Disable text input

	hideWindow(dialogWin)
	SDL_RenderPresent( renderer );
	#SDL_DestroyWindow(SDL_Window * Window)
	closeWinOnly(dialogWin)

	for inWidgit in inputWidgets
		outDictionary[inWidgit.key] = inWidgit.valueText
	end
	return [buttonClicked, outDictionary]
end

#-=====================================================================================
# Utility functions
#-=====================================================================================



#-  GTK versions (unused) =============================================================
#=
function askQuestionDialog(message::String)
	Gtk.ask_dialog("Do you like chocolate ice cream?", "Not at all", "I like it") && println("That's my favorite too.")

end

#-===================================================
function inputDialog(message::AbstractString, entry_default::AbstractString)
	# input_dialog(message::AbstractString, entry_default::AbstractString, buttons = (("Cancel", 0), ("Accept", 1)), parent = GtkNullContainer())
	resp, entry_text = Gtk.input_dialog(message, entry_default) #buttons = (("Cancel", 0), ("Accept", 1)))
	return resp, entry_text
end
=#
