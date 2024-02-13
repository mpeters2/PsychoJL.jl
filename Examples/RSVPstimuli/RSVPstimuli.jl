println("\n----------------------------- NEW RUN ------------------------------\n")
using PsychExpAPIs
using Random
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using SDL2_gfx_jll

const setSizes = [8, 16, 24]
const targetPresences = 2
const repetitions = 30

mutable struct ExperimentDesign	 # we'll pass this around instead of globals
	numTrials::Int64
	trialSS::Vector{Int64}		  # this holds the combination of SetSize control 
	trialTP::Vector{Int64}		  # 
	randomOrder::Vector{Int64}	  # this will hold the random order in which the trials will be displayed.
end
#-----
function main()
#	global setSizes 				# global constants are kosher in Julia,  but not gloval variables.
#	global targetPresences
#	global repetitions

	InitPsychoJL()
	myWin = Window( [1000,1000], false)
	
	exp = makeExperimentalDesign(setSizes, targetPresences, repetitions)		# returns an ExperimentDesign struct

	spinningDemo(myWin, 10)
	#practice
	for t in 1:10
		doATrial(myWin, t, false)
	end
	println("done!")
	SDL_Delay(2000)
	exit()
end
#-============================================================================
# I did this to demonstrate reusing TextStim objects.  Ideally you should
# not be making, and releasing, objects all of the time. Might not matter
# in the big picture, but reuse == speed.
function spinningDemo(win::Window, trials::Int64)

	DEFAULT_TEXT =	["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog", "house"]

	myTextStim = TextStim(win,  DEFAULT_TEXT[1], [750, 750], color = [rand(128:255), rand(128:255), rand(128:255)])
	#myTextStim = TextStim(win,  DEFAULT_TEXT[trialNum], [750, 750], color = [rand(128:255), 0, 0])

	for trialNum in 1:trials

		myTextStim.textMessage = DEFAULT_TEXT[trialNum]

		myTextStim.fontSize = 24
		myTextStim.orientation = (trialNum*10) - 45

		myTextStim.horizAlignment = 0	
		myTextStim.scale = 1 + trialNum/4
		#myTextStim.fontSize = 1 + round(Int64,trialNum/4)
		draw(myTextStim)

		flip(win)
		SDL_Delay(15)	
		#SDL_Delay(285)
		flip(win)
		#SDL_Delay(15)		
		print("boo")
	end
end#-============================================================================
# We'll make the target an O among Q's
function doATrial(win::Window, trialNum::Int64, realOrPractice::Bool = true)

	DEFAULT_TEXT =	["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog", "house"]

	myTextStim = TextStim(win,  DEFAULT_TEXT[trialNum], [750, 750], color = [rand(128:255), rand(128:255), rand(128:255)])
	#myTextStim = TextStim(win,  DEFAULT_TEXT[trialNum], [750, 750], color = [rand(128:255), 0, 0])


	myTextStim.fontSize = 24
	myTextStim.orientation = trialNum*10

	myTextStim.horizAlignment = -1	
	myTextStim.scale = 1 + trialNum/4
	#myTextStim.fontSize = 1 + round(Int64,trialNum/4)
	draw(myTextStim)

	flip(win)
	SDL_Delay(285)
	flip(win)
	SDL_Delay(15)		
	print("boo")
end
#-============================================================================
# Algorithmically make the control variables for the experiment
function makeExperimentalDesign(SS, TP, Reps)
 
	numTrials = sizeof(SS) * TP * Reps
	trialSetSize = zeros(Int64, numTrials)			 # this will holder the set size control variable that we will fill below
	trialTP = zeros(Int64, numTrials)	  # this will holder the target presence control variable that we will fill below

	trial = 1
	for r in 1:repetitions						# we do this outer because it makes block randomization easier
		for ss in SS							# array of set setSizes
			for pres in 1:TP					# target presence
				trialSetSize[trial] = ss
				trialTP[trial] = pres-1			# 0 = absent, 1 = present
				trial += 1
			end
		end
	end
	# next, create the random order for the trials.  This is not fancy block randomization.
	order = collect(1:numTrials)
	shuffleOrder = shuffle(order)
	# below we fill the struct with info about the experimental design and return it.
	designInfo = ExperimentDesign(numTrials, trialSetSize, trialTP, shuffleOrder)
	return designInfo
end
#-============================================================================
main()