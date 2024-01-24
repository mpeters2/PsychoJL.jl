
export waitKeys, getKey

"""
	waitKeys(win::Window, waitTime::Float64)

Waits for a predetermined time for a keypress. Returns immediately when a key is pressed
or the timer runs out.

inputs: 
 * win::Window
 * waitTime::Float64  *default is milliseconds*
outputs: Should return something, but I just realized that I forgot to implement that!
"""
function waitKeys(win::Window, waitTime::Float64)
	
	#println(" win.event: ",  win.event)
	#println(" win.event value: ",  win.event[])
	if win.timeScale == "milliseconds"
		waitTime /= 1000
	end
	println("entered waitKeys")
	start = time()
	while (time() - start) < waitTime
		while Bool(SDL_PollEvent(win.event))
		#while( SDL_PollEvent( win.event ) )
			event_ref = win.event
			evt = event_ref[]
			evt_ty = evt.type
			if evt_ty == SDL_KEYDOWN
				println( "Key press detected (", time() - start,")\n" );
			elseif evt_ty == SDL_KEYUP
				println( "Key release detected\n" );
			end
		end
	end
	println("exited waitKeys")
end
#------------------------------------
"""
	getKey(win::Window)

Waits until a key is pressed.

inputs: 
 * win::Window

outputs: Should return something, but I just realized that I forgot to implement that!
"""
function getKey(win::Window)
	#Enable text input
	SDL_StartTextInput();


	while Bool(SDL_PollEvent(win.event))
		event_ref = win.event
		evt = event_ref[]
		evt_ty = evt.type
		if( evt_ty == SDL_TEXTINPUT )
			textTemp = NTupleToString(evt_text.text)
			if textTemp != nothing
				SDL_StopTextInput()
				return textTemp
			end
		end
		#=
		if evt_ty == SDL_KEYDOWN
			println( "Key press detected (", time() - start,")\n" );
		elseif evt_ty == SDL_KEYUP
			println( "Key release detected\n" );
		end
		=#
	end
	SDL_StopTextInput()
end