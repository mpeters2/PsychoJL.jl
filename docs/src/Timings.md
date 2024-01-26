```@docs
startTimer(win::Window)
stopTimer(win::Window)
```
#### Alternative approach

An alterntiave to calling these functions is to use Julia's built-in `time()` function, which returns the current time in seconds.

Example:
```julia
	...
	draw(myStim)					# draw stimulus
	flip(win)					# flip the window onto the screen
	startTime = time()				# get the current time
	keypressed = getKey(win)			# wait for a keypress
	stopTime = time()				# get the current time 
	timeTaken = stopTime - startTime
	println("It took ", timeTaken * 1000," milliseconds for a keypress.")
```
"""