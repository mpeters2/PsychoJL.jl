println("\n----------------------------- NEW RUN ------------------------------\n")
using PsychoJL
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
	global subjInfo
	global subjID
	

	InitPsychoJL()
	subjInfo, subjID = getSubjectInfo()
	myWin = window( [1000,1000], false)
	
	exp = makeExperimentalDesign(setSizes, targetPresences, repetitions)		# returns an ExperimentDesign struct

	#practice
	for t in 1:10
		doATrial(myWin, t, exp, false)
	end
	println("done!")
	SDL_Delay(2000)
	exit()
end
#-============================================================================
# We'll make the target an O among Q's
function doATrial(win::Window, trialNum::Int64, trialInfo::ExperimentDesign, realOrPractice::Bool = true)

	theTrial = trialInfo.randomOrder[trialNum]		# get our randomized trial number

	# (2) need to fill an array full of stimuli to display, depending on set size, target presence, etc.
	# 	make a list of distractors as orientatons 0-4 (90 degree).  Target will be coded as -1
	stimList = zeros(trialInfo.trialSS[theTrial])

	ori = 0												# distractor orientation
	for i in eachindex(stimList)
		stimList[i] = ori
		ori += 1
		if ori >= 4
			ori = 0
		end
	end

	if trialInfo.trialTP[theTrial] == 1					# if the target is present
		stimList[1] = -1								# replace the first item in stimList with the target  (-1)
	end
	# (3) need to randomly pick the locations
	locations = collect(0:99)							# these are in a 10 x 10 grid
	shuffle!(locations)


	# (4) Premake the stimuli
	stimDrawList::Vector{TextStim} = []
	#stimDrawList = Vector{TextStim}()
	#stimDrawList() = stimDrawList(textStim[],[])
	for i in eachindex(stimList)
		x = 50+((locations[i]%10)*100)						# 1000 x 1000, steps of 100
		y = 50+(floor(Int64, locations[i]/10)*100)						# 1000 x 1000, steps of 100
		if stimList[i] == -1							# target
			ori = rand(1:2)
			if ori == 1
				ori  = -90
			else
				ori = +990
			end
			tempStim = textStim(win,  "T", [x, y], color = [255,255,0], fontSize = 24, orientation = ori)
			push!(stimDrawList, tempStim)				# append it to stimDrawList
			println("target present",  theTrial)
		else											# else it is a distractor
			tempStim = textStim(win,  "L", [x, y], color = [255,255,255], fontSize = 24, orientation = floor(Int, stimList[i] * 90) )
			push!(stimDrawList, tempStim)				# append it to stimDrawList
		end
	end
	
	#=
	myTextStim = textStim(win,  DEFAULT_TEXT[trialNum], [750, 750], color = [rand(128:255), rand(128:255), rand(128:255)], fontSize = 24, orientation = trialNum*10)
	myTextStim.justification = "left"
	myTextStim.scale = 1 + trialNum/4
	draw(myTextStim)
	=#
	for s in stimDrawList
		draw(s)
	end
	flip(win)
	SDL_Delay(2285)
	flip(win)
	SDL_Delay(15)	

	print("boo")
end
#-============================================================================
# Algorithmically make the control variables for the experiment
function makeExperimentalDesign(SS, TP, Reps)
 
	numTrials = length(SS) * TP * Reps
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
#-===============================================================
function getSubjectInfo()

	
	#subjInfo = {"Particpant":""}
	subjInfo= Dict("Particpant" => "")
	dictDlg = DlgFromDict(subjInfo)
	if dictDlg[1] == "OK"
		println(subjInfo)
	else
		println("User Cancelled")
		displayMessage("User Cancelled")
		core.wait(3)
	end
	#subjID =  subjInfo.get("Particpant","none")
	subjID =  dictDlg[2]["Particpant"]
	println("subject name = ", subjID,"\n")

	return subjInfo, subjID
end
#-============================================================================
main()