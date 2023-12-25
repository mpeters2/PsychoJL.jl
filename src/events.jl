
export waitKeys

function waitKeys(win::Window, waitTime::Float64)
	
	#println(" win.event: ",  win.event)
	#println(" win.event value: ",  win.event[])
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
function getKey(win::Window)
	
	#println(" win.event: ",  win.event)
	#println(" win.event value: ",  win.event[])
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