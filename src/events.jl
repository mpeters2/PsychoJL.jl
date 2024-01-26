
export waitKeys, getKey


function waitKeys(win::Window, waitTime::Int64)
	waitKeys(win, convert(Float64, waitTime))
end
"""
	waitKeys(win::Window, waitTime::Float64)

Waits for a predetermined time for a keypress. Returns immediately when a key is pressed
or the timer runs out.

**Inputs:**
 * win::Window
 * waitTime::Float64  *default is milliseconds*
**Outputs**: returns the character that was pressed

**Limitations**: currently only returns character keys. Arrow keys, tab, return, etc. do not work.

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
			evt_text = evt.text
			if( evt_ty == SDL_TEXTINPUT )
				textTemp = NTupleToString(evt_text.text)
				if textTemp != nothing
					SDL_StopTextInput()
					if textTemp == " "				# space
						return "space"
					elseif	textTemp == "	"		# tab
						return "tab"
					else
						return textTemp
					end
				end
			end
			#= if evt_ty == SDL_KEYDOWN
				println( "Key press detected (", time() - start,")\n" );
			elseif evt_ty == SDL_KEYUP
				println( "Key release detected\n" );
			end =#
		end
	end
	println("exited waitKeys")
end
#------------------------------------
"""
	getKey(win::Window)

Waits until a key is pressed.

**Inputs:**
 * win::Window

**Outputs**: returns the character that was pressed

**Limitations**: currently only returns character keys. Arrow keys, tab, return, etc. do not work.
"""
function getKey(win::Window)
	#Enable text input
	SDL_StartTextInput();

	done = false
	while done == false
		while Bool(SDL_PollEvent(win.event))
			event_ref = win.event
			evt = event_ref[]
			evt_ty = evt.type
			evt_text = evt.text
			if( evt_ty == SDL_TEXTINPUT )
				textTemp = NTupleToString(evt_text.text)
				if textTemp != nothing
					SDL_StopTextInput()
					if textTemp == " "				# space
						return "space"
					elseif	textTemp == "	"		# tab
						return "tab"
					else
						return textTemp
					end
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
	end
	SDL_StopTextInput()
end