#=
Overview of spatial stroop (Simon Effect).

	1) The word 'Left' or 'Right' occurs to the left or right of fixation
	2) Respond with a left key for 'Left', right key for 'Right'
	3) If a trial is congruent, then the spatial location matches the word.
		For example, 'Left' to the left of fixation.
	4) If a trial is incongruent, then the spatial locatin mismatches the word.
		For example, 'Right' to the left of fixation.

=#

println("\n----------------------------- NEW RUN ------------------------------\n")
using PsychExpAPIs
using Random
using Printf

#------------
# Experiment design/control variables
const screenSides = ["leftSide", "rightSide"] 				# global constants are kosher in Julia,  but not global variables.
const congruencies = 2
const repetitions = 15
#------
const leftX = -0.05							# x values for left side
const rightX = +0.05							# x values for right side

mutable struct ExperimentDesign	 				# we'll pass this around instead of globals
	numTrials::Int64
	trialSide::Vector{String}		  			# Determines which side the stimulus will appear on each trial 
	trialCongruency::Vector{Int64}
	randomOrder::Vector{Int64}					# the order in which the trials will be presented
end

#-----
function main()

	exp = makeExperimentalDesign(screenSides, congruencies, repetitions)		# returns an ExperimentDesign struct

	InitPsychoJL()								# Do this before calling any PsychoJL functions
	subjID = getSubjectInfo()					# put up a dialog asking for subject's information
	subjFile = openDataFile(subjID)				# open the subject's data file


	win = Window( [2560,1440], false, coordinateSpace = "PsychoPy")			# 5120 × 2880, or 2560 x 1440	[1000,1000]
	mouseVisible(false)							# hide mouse cursor

	showInstructions(win)						# pass 'win' to showInstructions.  We do this since global variables are verboten.
	#practice
	for t in 1:3
		doATrial(win, t, exp, subjFile, false )
	end

	for t in 1:exp.numTrials
		doATrial(win, t, exp, subjFile, true )
	end	
	shutDown(win, subjFile)
	#exit()
end
#-============================================================================
# Algorithmically make the control variables for the experiment
function makeExperimentalDesign(sides::Vector{String}, congru::Int64, Reps::Int64)
 
	numTrials = length(sides) * congru * Reps		# algorithmically calculate the number of trials in our experiment
	trialSides = []									# We'll append strings for leftSide or rightSide to this array
	trialCongru = zeros(Int64, numTrials)	  		# this will holder the target congruencey control variable that we will fill below

	trial = 1
	for r in 1:repetitions							# we do this outer because it makes block randomization easier
		for sides in sides							# stimulus sides
			for c in 1:congru						# response congruency
				push!(trialSides, sides	)			# sides is a string
				trialCongru[trial] = (c*2)-3		# -1 = incongruent, +1 = congruent
				trial += 1
			end 
		end
	end

		
	# Next, create the random order for the trials.  This is not fancy block randomization.
	order = collect(1:numTrials)				# Fill an array with all possible trial numbers
	shuffleOrder = shuffle(order)				# Shuffle the array
	#--------------
	# Below we fill the struct with info about the experimental design and return it.
	# Information is added to fields in the order that the fields are defined in the struct.
	designInfo = ExperimentDesign(numTrials, trialSides, trialCongru, shuffleOrder)
	return designInfo
end
#-============================================================================
function showInstructions(win::Window)
	
	line1 = Line(win, [0.0, -0.5], [0.0, +0.5], width = 1, lineColor = [255,0,0,255] )
	line2 = Line(win, [-0.7, 0.0], [+0.7, 0.0], width = 1, lineColor = [0,0,255,255] )
	draw(line1)
	draw(line2)

	message1 = "Press the '/' key if you see the word 'Left'."
	TextStim1 = TextStim(win, message1, [0.0,  +0.05 ])					# Using PsychoPy coordinates, whihc are floats, so need 0.0 instead of 0.
	setColor(TextStim1, [255, 255, 255])
	TextStim1.scale = 2.0
	TextStim1.horizAlignment = 0					# center aligned
	draw(TextStim1)

	message2 = "Press the 'z' key if you see the word 'Right'."
	TextStim2 = TextStim(win, message2, [0.0, -0.05 ])
	setColor(TextStim2, "white")
	TextStim2.scale = 2.0
	TextStim2.horizAlignment = 0					# center aligned
	draw(TextStim2)

	message3 = "Press the space bar when you are ready to continue."
	TextStim3 = TextStim(win, message3, [0.0, -0.15 ])
	setColor(TextStim3, "yellow")
	TextStim3.scale = 1.5
	TextStim3.horizAlignment = 0					# center aligned
	draw(TextStim3)
   
	flip(win)
	getKey(win)
end

#-============================================================================
function shutDown(win::Window, subjFile::IOStream)
	close(subjFile)
	mouseVisible(true)
	setFullScreen(win, false)
	hideWindow(win)
	happyMessage( "Thank-you for participating")
	closeAndQuitPsychoJL(win)
	println("post closeAndQuitPsychoJL")
end
#-============================================================================
function getSubjectInfo()	
	
	done = false
	subjID = ""									# ensures that subjID is not local to the while loop
	
	while done == false
		subjInfo= Dict("Particpant" => "")
		dictDlg = DlgFromDict(subjInfo)
println(dictDlg)
		if dictDlg[1] == "OK"
			println(subjInfo)
		else
			print("User Cancelled")
			displayMessage("User Cancelled")
			waitTimeMsec(3000)
			exit()
		end
		subjID =  dictDlg[2]["Particpant"]
		subjID = String(strip(subjID, ' '))						# sometimes returns an extra space

		println("subjID = ", subjID,"\n")
	
		# check if the filename is valid (length <= 8 & no special char)
		fileName = "subj" * subjID * ".txt"
		if isfile(fileName) == true && subjID != "999"			# 999 is my demo subject
			message = fileName * " already exists!"
			errorMessage( message)
		else
			done = true
		end
	end
	return subjID
end
#-============================================================================
function openDataFile(subjID::String)
	fileName = "subj" * subjID * ".txt"
	println(pwd())
	println(fileName)

	f = open(fileName, "w")						# open for writing
	write(f,"TrialNum\tOrder\tTargetWord\tWordSide\tCongruency\tRT\tCorrect\tkeypressed\n")
	return f
end
#-============================================================================
function doATrial(win::Window, trialNum::Int64, trialInfo::ExperimentDesign, subjFile::IOStream, realOrPractice::Bool = true)

	#---------
	# make an ErrSound object
	errSound = ErrSound()							
	# NOTE: Ideally you would not do this here, because it 
	#	(1) creates a sound object and loads a sound file
	#	(2) destroys the sound object after each trial
	# however, it probably does not have an effect on performance.

	thisTrial = trialInfo.randomOrder[trialNum]			# get our randomized trial number
	word = ""											# need to define this outside ths scope of the if statements below
	if trialInfo.trialCongruency[thisTrial] == -1					# incongruent
		if trialInfo.trialSide[thisTrial] == "leftSide"			# left side
			word = "Right"
		elseif trialInfo.trialSide[thisTrial] == "rightSide"
			word = "Left"
		else
			error("trialSide is an illegal value:  ", trialSide)
		end
	elseif trialInfo.trialCongruency[thisTrial] == +1				# congruent
		if trialInfo.trialSide[thisTrial] == "leftSide"			# left side
			word = "Left"
		elseif trialInfo.trialSide[thisTrial] == "rightSide"
			word = "Right"
		else
			error("trialSide is an illegal value:  ", trialSide)
		end
	end
	#--------------------
	# Draw fixation cross
	fixCross(win)
	flip(win)
	waitTimeMsec(500)									# wait 500 milliseconds
	# Draw the stimuli in memory
	if trialInfo.trialSide[thisTrial] == "leftSide"
		stimWord = TextStim(win,  word, [leftX, 0.0], color = "white", fontSize = 24, horizAlignment = 0)
	else
		stimWord = TextStim(win,  word, [rightX, 0.0], color = "white", fontSize = 24, horizAlignment = 0)
	end
	stimWord.scale = 2.0
	stimWord.vertAlignment = 0							# make sure it is vertically aligned with fixation cross
	
	draw(stimWord)
	flip(win)
	startTimer(win)

	keypressed = getKey(win)
	RT = stopTimer(win)

	# Grade Keypress
	accuracy = 0
	if keypressed == "z" && word == "Left"
		accuracy = 1
	elseif keypressed == "slash" && word == "Right"
		accuracy = 1
	elseif keypressed == "7"								# secret abort key
		shutDown(win, subjFile)
	else
		play(errSound)
	end
	#------
	if realOrPractice == true					# do not save practice data
		buf = @sprintf("%d\t%d\t%s\t%s\t", trialNum,  thisTrial, word, trialInfo.trialSide[thisTrial])
		buf = buf * @sprintf("%d\t%4.1f\t%d\t%s\n", trialInfo.trialCongruency[thisTrial], RT, accuracy, keypressed)
		#write(f,"TrialNum\tOrder\tTargetWord\tCongruency\tRT\tCorrect\tkeypressed\n")
		write(subjFile, buf)
	end
end
#-============================================================================
function fixCross(win::Window)
	cross = TextStim(win,  "+", [0.0, 0.0], color = "white", fontSize = 24)
	cross.horizAlignment = 0								# make sure it is centered vertically and horizontally
	cross.vertAlignment = 0
	draw(cross)

	println("cross pos: ", cross.pos)
	println("cross native pos: ", cross._pos)
end



#-================================================================
main()				# Call main() to get things started