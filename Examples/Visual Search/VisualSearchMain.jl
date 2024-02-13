#=
	THINGS TO ADD/FIX

	Save subject data
	have the screen scaling change whether it is full screen or not (done in Win?)


=#

println("\n----------------------------- NEW RUN ------------------------------\n")
using PsychExpAPIs
using Random
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using SDL2_gfx_jll
using Printf

const setSizes = [8, 16, 24] 				# global constants are kosher in Julia,  but not global variables.
const targetPresences = 2
const repetitions = 30

mutable struct ExperimentDesign	 	# we'll pass this around instead of globals
	numTrials::Int64
	trialSS::Vector{Int64}		  	# this holds the combination of SetSize control 
	trialTP::Vector{Int64}		  	# Target Presence
	randomOrder::Vector{Int64}	  	# this will hold the random order in which the trials will be displayed.
end


#-----
function main()
	global subjInfo
	global subjID

	InitPsychoJL()
	subjID = getSubjectInfo()
	subjFile = openDataFile(subjID)


	myWin = Window( [2560,1440], true)			# 5120 × 2880, or 2560 x 1440	[1000,1000]
	mouseVisible(false)
	exp = makeExperimentalDesign(setSizes, targetPresences, repetitions)		# returns an ExperimentDesign struct

	showInstructions(myWin)
	#practice
	for t in 1:3
		doATrial(myWin, t, exp, subjFile, false )
	end

	for t in 1:10
		doATrial(myWin, t, exp, subjFile, true )
	end	
	shutDown(myWin, subjFile)
	#exit()
end
#-============================================================================
function showInstructions(win::Window, )
	
	x2 = win.pos[1]
	y2 = win.pos[1]
	x,y = getPos(win)
	posMes = @sprintf("(%d, %d) (%d, %d)", x,y,x2,y2)
	posText = TextStim(win, posMes, [100, 100 ])
	posText.horizAlignment = -1
	draw(posText)

	w2 = Ref{Cint}()
	h2 = Ref{Cint}()
	SDL_GetWindowSize(win.win, w2, h2)
	posText.textMessage = @sprintf("SDL_GetWindowSize (%d, %d)", w2[],h2[])
	posText.pos = [100, 150 ]
	draw(posText)

	w3 = Ref{Cint}()
	h3 = Ref{Cint}()
	SDL_GL_GetDrawableSize(win.win, w3, h3)
	posText.textMessage = @sprintf("SDL_GL_GetDrawableSize (%d, %d)", w3[],h3[])
	posText.pos = [100, 200 ]
	draw(posText)

	line1 = Line(win, [x, 0], [x, y*2], width = 1, lineColor = [255,0,0,255] )
	line2 = Line(win, [0, y], [x* 2, y], width = 1, lineColor = [0,0,255,255] )
	draw(line1)
	draw(line2)

	#x = win.pos[1] ÷ 2						# divide by two for retina scaling issue
	#y = win.pos[2]	÷ 2
	print("x and y = ", x,", ",y)

	message1 = "Press the '/' key if a T is present."
	TextStim1 = TextStim(win, message1, [x, y - 50 ])
	TextStim1.color = [255, 255, 255]
	TextStim1.scale = 1.5
	TextStim1.horizAlignment = 0					# center aligned
	draw(TextStim1)

	message2 = "Press the 'z' key if the target T is absent."
	TextStim2 = TextStim(win, message2, [x, y + 50 ])
	TextStim2.color = [255, 255, 255]
	TextStim2.scale = 1.5
	TextStim2.horizAlignment = 0					# center aligned
	draw(TextStim2)

	message3 = "Press the space bar when you are ready to continue."
	TextStim3 = TextStim(win, message3, [x, y + 250 ])
	TextStim3.color = [255, 255, 0]
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
function openDataFile(subjID::String)
	fileName = "subj" * subjID * ".txt"
	println(pwd())
	println(fileName)
	while isfile(fileName) == true && subjID != "999"
		message = fileName * " already exists!"
		displayMessage( message)
		subjID = getSubjectInfo()
		fileName = "subj" * subjID * ".txt"
	end
	f = open(fileName, "a")						# append, so that we can stream the data
	write(f,"TrialNum\tOrder\tTargetPresent\tSetSize\tRT\tCorrect\tkeypressed\n")
	return f
end
#-============================================================================
# We'll make the target a left or right rotated T among rotated Ls
function doATrial(win::Window, trialNum::Int64, trialInfo::ExperimentDesign, subjFile::IOStream, realOrPractice::Bool = true)

	#---------
	# make an ErrSound object
	errSound = ErrSound()							
	# NOTE: Ideally you would not do this here, because it 
	#	(1) creates a sound object and loads a sound file
	#	(2) destroys the sound object after each trial
	# however, it probably does not have an effect on performance.


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
	_, gridSize = getSize(win)							# square display area, so grabbing window's height
	gridSize *= 0.9										# we'll use 90% of the area
	gridSize *= 0.1										# and divide it into 10
	xScootch, _ = win.pos								# find the middle of the window...
	xScootch = round(Int64, xScootch /2)				# ... and take half that.  We'll scootch the stimuli over so that they are centered.
	for i in eachindex(stimList)
		#x = 50+((locations[i]%10)*100)						# 1000 x 1000, steps of 100
		#y = 50+(floor(Int64, locations[i]/10)*100)						# 1000 x 1000, steps of 100
		x = (gridSize÷2)+((locations[i]%10)*gridSize)						# 1000 x 1000, steps of 100
		y = (gridSize÷2)+(floor(Int64, locations[i]/10)*gridSize)						# 1000 x 1000, steps of 100
		x += xScootch
		x = round(Int64, x)
		y = round(Int64, y)
		if stimList[i] == -1							# target
			ori = rand(1:2)
			if ori == 1
				ori  = -90
			else
				ori = +90
			end
			tempStim = TextStim(win,  "T", [x, y], color = [255,255,0], fontSize = 24, orientation = ori)
			push!(stimDrawList, tempStim)				# append it to stimDrawList
		else											# else it is a distractor
			tempStim = TextStim(win,  "L", [x, y], color = [255,255,255], fontSize = 24, orientation = floor(Int, stimList[i] * 90) )
			push!(stimDrawList, tempStim)				# append it to stimDrawList
		end
	end
	if stimList[1] == -1
		println("target present\n",  theTrial)
	else
		println("target absent\n",  theTrial)
	end
	for s in stimDrawList
		draw(s)
	end
	flip(win)
	startTimer(win)

	keypressed = getKey(win)
	RT = stopTimer(win)

	# Grade Keypress
	accuracy = 0
	if keypressed == "z" && trialInfo.trialTP[theTrial] == 0
		accuracy = 1
	elseif keypressed == "/" && trialInfo.trialTP[theTrial] == 1
		accuracy = 1
	elseif keypressed == "7"								# secret abort key
		shutDown(win, subjFile)
	else
		play(errSound)
	end
	#------
	if realOrPractice == true					# do not save practice data
		buf = @sprintf("%d\t%d\t%d\t", trialNum,  theTrial, trialInfo.trialTP[theTrial])
		buf = buf * @sprintf("%d\t%4.1f\t%d\t%s\n", trialInfo.trialSS[theTrial], RT, accuracy, keypressed)

		write(subjFile, buf)
	end
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
function OldgetSubjectInfo()

	
	#subjInfo = {"Particpant":""}
	subjInfo= Dict("Particpant" => "")
	dictDlg = DlgFromDict(subjInfo)
	if dictDlg[1] == "OK"
		println(subjInfo)
	else
		println("User Cancelled")
		displayMessage("User Cancelled")
		waitTimeMsec(3000)
		exit()
	end
	subjID =  dictDlg[2]["Particpant"]
	subjID = String(strip(subjID, ' '))						# sometimes returns an extra space
	println("subject name = ", subjID,"\n")

	return subjID
end
#-============================================================================
function getSubjectInfo()	
	
	done = false
	subjID = ""									# ensures that subjID is not local to the while loop
	
	while done == false
		subjInfo= Dict("Particpant" => "")
		dictDlg = DlgFromDict(subjInfo)
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
			displayMessage( message)
			#subjID = getSubjectInfo()
			#fileName = "subj" * subjID * ".txt"
		else
			done = true
		end
	end
	return subjID
end
main()