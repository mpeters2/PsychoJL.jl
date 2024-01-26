export startTimer, stopTimer


"""
	startTimer(win::Window)

Starts a timer.  Only one timer can run at a time. If you need more than tha one timer, use Julia's time() function.

**Inputs:**
 * win::Window
 * waitTime::Float64  *default is milliseconds*
**Outputs:** nothing
"""
function startTimer(win::Window)
	win.startTime = time()
end
"""
	stopTimer(win::Window)

Stops the global timer and returns the time taken. If you need more than one timer, use Julia's time() function.

**Inputs:**
 * win::Window
 
**Outputs:** 
	The time in [default] milliseconds.
"""
function stopTimer(win::Window)
	stopTime = time()
	if win.timeScale == "milliseconds"
		return (stopTime - win.startTime)*1000.0
	else
		return (stopTime - win.startTime)
	end
end