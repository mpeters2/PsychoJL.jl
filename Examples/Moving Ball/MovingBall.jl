using PsychExpAPIs
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
# Moving Ball Exampile



#-=============================
function main()
	InitPsychoJL()
	# make a new floating window using the PsychoPy coordinate space and and color space
	win = Window( [1280, 720], false; colorSpace = "PsychoPy", coordinateSpace = "PsychoPy", timeScale = "seconds")			#	2560, 1440			[1000,1000]

	myCirc = Circle(win,
					[ 0.0, 0.0],					        # screen center
                	0.1,					                # radius is 10% of the screen height
					fillColor = [+1.0,-1.0,-1.0, +1.0],     # r,g,b, alpha
                	lineColor = "yellow",					# has color names
					fill = true)
  
	draw(myCirc)                           # everything draws into memory
	flip(win)                              # copies to screen
	waitTime(win, 0.5)                            # wait one second

	for i in 0:10
		x = -.5 + (i*0.1)
		setPos(myCirc, [x, 0])
		draw(myCirc)                           # everything draws into memory
		#println(x)
		flip(win)                              # copies to screen

		waitTime(win, 0.1)							# 0.10

	end

	closeWinOnly(win)

	#core.quit()
	#sys.exit(0)
	#exit()

end
#-===============================================================


main()

