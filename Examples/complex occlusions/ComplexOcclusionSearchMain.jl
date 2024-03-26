#=
	THINGS TO ADD/FIX

	Save subject data
	have the screen scaling change whether it is full screen or not (done in Win?)


=#


using Dates
println("\n----------------------------- NEW RUN ------------------------------", Dates.format(now(), "HH:MM") ,"\n")
using PsychExpAPIs
using Random
using SimpleDirectMediaLayer
using SimpleDirectMediaLayer.LibSDL2
using SDL2_ttf_jll
using SDL2_gfx_jll
using Printf

const setSizes = [6, 12] 				# global constants are kosher in Julia,  but not global variables.
const stimLayers = 2
const occluderType = 3
const targetDirections = 2
const repetitions = 12

#=
3 different occluders are always present: white bar, hershey, wii remote.  The target is on/or below
one of the three.

=#

mutable struct imageGroup
	name::String
	image::ImageStim
end

mutable struct ExperimentDesign	 	# we'll pass this around instead of globals
	numTrials::Int64
	trialSS::Vector{Int64}		  	# this holds the combination of SetSize control 
	trialDir::Vector{Int64}		  	# Target direction
	trialLayer::Vector{Int64}		# layer of the stims relative to distractors, -1 = under (occluded), +1 = over
	trialOccluder::Vector{Int64}	# which type of occluder is the target over/under?
	randomOrder::Vector{Int64}	  	# this will hold the random order in which the trials will be displayed.
end

mutable struct Stimuli
	Targets::Vector{imageGroup}					# holds sub-lists, with the first entry being the name (should this be a struct?)
	AnswerTargets::Vector{imageGroup}					# holds sub-lists, with the first entry being the name (should this be a struct?)
	Distractors::Vector{imageGroup}
	Occluders::Vector{imageGroup}
end

struct drawObjects					# used for playback when an error occurs during practice
	im::ImageStim
	ori::Float64
	pos::Vector{Float64}
end

#-----
function main()
	global subjInfo
	global subjID


	InitPsychoJL()
	subjID = getSubjectInfo()
	subjFile = openDataFile(subjID)


	myWin = Window( [2560,1440], false, coordinateSpace = "LT_Percent", color = "gray50")			# 5120 × 2880, or 2560 x 1440	[1000,1000]
	theStims = loadImages(myWin)

	mouseVisible(false)

	exp = makeExperimentalDesign(setSizes, targetDirections, stimLayers, occluderType, repetitions)		# returns an ExperimentDesign struct

	showInstructions(myWin, theStims)

	#practice
	windowMessage(myWin, "Next: Practice Trials")
	for t in 1:10
		doATrial(myWin, t, exp, theStims, subjFile, false )
	end

	windowMessage(myWin, "Practice is over.")
	for t in 1:exp.numTrials
		doATrial(myWin, t, exp, theStims, subjFile, true )
	end	
	shutDown(myWin, subjFile)
	#exit()
end
#-============================================================================
function showInstructions(win::Window, stims::Stimuli)
	
	windowSize = getSize(win)
	cx = windowSize[1] /2

	targImage = stims.Targets[1].image

	message1 = "Press the 'z' key if a left-pointing T is present."
	TextStim1 = TextStim(win, message1, [cx*0.65, 0.40 ])
	TextStim1.color = [255, 255, 255]
	TextStim1.scale = 2.0
	TextStim1.horizAlignment = -1					# left aligned
	draw(TextStim1)
	setPos(targImage,  [cx * 1.17, 0.39])
	draw(targImage)

	message2 = "Press the '/' key if a right-pointing T is present."
	TextStim2 = TextStim(win, message2, [cx*0.65, 0.48 ])
	TextStim2.color = [255, 255, 255]
	TextStim2.scale = 2.0
	TextStim2.horizAlignment = -1					# left aligned
	draw(TextStim2)
	setPos(targImage, [cx * 1.17, 0.47] )
	draw(targImage, orientation = 180.0)

	message3 = "Press the space bar when you are ready to continue."
	TextStim3 = TextStim(win, message3, [cx, 0.6 ], color = "yellow")
	TextStim3.scale = 1.5
	TextStim3.horizAlignment = 0					# center aligned
	draw(TextStim3)
   
	drawKeyInstructions(win, stims)
	flip(win)
	getKey(win)
end
#-============================================================================
# made this a seperate function as I thought about making it visible during practice
function drawKeyInstructions(win::Window, stims::Stimuli)
	windowSize = getSize(win)
	winWidth = windowSize[1]
	cx = winWidth /2

	targImage = stims.Targets[1].image

	message1 = "'z'"
	TextStim1 = TextStim(win, message1, [winWidth * 0.2, 0.85 ])
	TextStim1.color = [255, 255, 255]
	TextStim1.scale = 2.5
	TextStim1.horizAlignment = 0					# left aligned
	draw(TextStim1)
	setPos(targImage,  [winWidth * 0.2, 0.9 ])
	draw(targImage, magnification =0.9)

	message2 = "'/'."
	TextStim2 = TextStim(win, message2, [winWidth * 0.8, 0.85 ])
	TextStim2.color = [255, 255, 255]
	TextStim2.scale = 2.5
	TextStim2.horizAlignment = -1					# left aligned
	draw(TextStim2)
	setPos(targImage, [winWidth * 0.8, 0.9 ] )
	draw(targImage, orientation = 180.0, magnification =0.9)


end
#-============================================================================
function windowMessage(win::Window, message::String)
	
	windowSize = getSize(win)
	cx = windowSize[1] /2

	TextStim1 = TextStim(win, message, [cx, 0.40 ])
	TextStim1.color = [255, 255, 255]
	TextStim1.scale = 2.5
	TextStim1.horizAlignment = 0					# left aligned
	draw(TextStim1)

	message3 = "Press the space bar when you are ready to continue."
	TextStim3 = TextStim(win, message3, [cx, 0.6 ], color = "yellow")
	TextStim3.scale = 1.5
	TextStim3.horizAlignment = 0					# center aligned
	draw(TextStim3)
   
	flip(win)
	getKey(win)
end
#-============================================================================
function fixCross(win::Window)
	
	windowSize = getSize(win)
	cx = windowSize[1] /2

	TextStim1 = TextStim(win, "+", [cx, 0.5 ])
	TextStim1.color = [255, 255, 255]
	TextStim1.scale = 2.5
	TextStim1.horizAlignment = 0					# left aligned
	TextStim1.vertAlignment = 0					# left aligned
	draw(TextStim1)
   
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
	write(f,"TrialNum\tOrder\tTargetDirection\tOccluderName\tOccluderNumber\tStimLayer\tSetSize\tRT\tCorrect\tkeypressed\n")
	return f
end



#-============================================================================
# We'll make the target a left or right rotated T among rotated Ls
function doATrial(win::Window, trialNum::Int64, trialInfo::ExperimentDesign, stims::Stimuli, subjFile::IOStream, realOrPractice::Bool = true)

	#---------
	# make an ErrSound object
	errSound = ErrSound()							
	theTrial = trialInfo.randomOrder[trialNum]		# get our randomized trial number
	
	# (3) need to randomly pick the locations
	locations = collect(0:99)							# these are in a 10 x 10 grid
	shuffle!(locations)
	# 
	fixCross(win)
	flip(win)
	waitTimeMsec(250)
	flip(win)
	waitTimeMsec(250)
	fixCross(win)
	flip(win)
	waitTimeMsec(500)
	# (4) Premake the stimuli
	stimDrawList::Vector{TextStim} = []
	occluderDrawList ::Vector{TextStim} = []
	#_, gridSize = getNativeSize(win)							# square display area, so grabbing window's height
	gridSize = 1.0
	gridSize *= 0.9										# we'll use 90% of the area
	gridSize *= 0.1										# and divide it into 10
	#xScootch, _ = win.pos								# find the middle of the window...
	xScootch, _ = 	getSize(win)
	xScootch /=2				# ... and take half that.  We'll scootch the stimuli over so that they are centered.
	xScootch -= 0.5
	foundTargOcc = false								# falg telling us whether we found the occluder for our target
	targX = 0
	targY = 0
	drawingOrder = []									# will be used for redrawing stims when an error occurs

	for i in 1:trialInfo.trialSS[theTrial]
		x = (gridSize/2)+((locations[i]%10)*gridSize)						# 1000 x 1000, steps of 100
		y = (gridSize/2)+(floor(Int64, locations[i]/10)*gridSize)						# 1000 x 1000, steps of 100
		x += xScootch
		#x = round(Int64, x)
		#y = round(Int64, y)
		whichOccluder = (i % 3)+1
		whichDistractor = (i % 2)+1
		#stims

		if trialInfo.trialLayer[theTrial] == -1								# draw stim first
			if (foundTargOcc == false) && whichOccluder == trialInfo.trialOccluder[theTrial]			# have we drawn the target and found a matching occluder for the target?	
				foundTargOcc = true
				targImage = stims.Targets[1].image
				setPos(targImage, [x, y])
				targX = x					# save it for later in case we need to draw target answer
				targY = y		
				if trialInfo.trialDir[theTrial] == -1					# left facing T stem (default)
					#drawCache(targImage, orientation = 0.0)
					draw(targImage, orientation = 0.0)
					obj = drawObjects(targImage, 0.0, [x,y])
					push!(drawingOrder, obj)
				else
					#drawCache(targImage, orientation = 180.0)
					draw(targImage, orientation = 180.0)
					obj = drawObjects(targImage, 180.0, [x,y])
					push!(drawingOrder, obj)
				end
			else
				distImage = stims.Distractors[whichDistractor].image
				setPos(distImage, [x, y])	
				distOri = rand(1:2)
				if distOri == 1
					#drawCache(distImage, orientation = 0.0) 
					draw(distImage, orientation = 0.0) 
					obj = drawObjects(distImage, 0.0, [x,y])
					push!(drawingOrder, obj)
				else
					#drawCache(distImage, orientation = 180.0)
					draw(distImage, orientation = 180.0)
					obj = drawObjects(distImage, 180.0, [x,y])
					push!(drawingOrder, obj)
				end	
			end
			if i % 2 == 0
				ori = 45.0								# orientation of occluder
			else
				ori = 135.0
			end
			occImage = stims.Occluders[whichOccluder].image
			setPos(occImage, [x, y])		
			drawCache(occImage, orientation = ori)
			obj = drawObjects(occImage, ori, [x,y])
			push!(drawingOrder, obj)			
		else											# draw occluder first
			if i % 2 == 0
				ori = 45.0								# orientation of occluder
			else
				ori = 135.0
			end
			occImage = stims.Occluders[whichOccluder].image
			setPos(occImage, [x, y])		
			#drawCache(occImage, orientation = ori)
			draw(occImage, orientation = ori)
			obj = drawObjects(occImage, ori, [x,y])
			push!(drawingOrder, obj)

			if (foundTargOcc == false) && whichOccluder == trialInfo.trialOccluder[theTrial]			# have we drawn the target and found a matching occluder for the target?	
				foundTargOcc = true
				targImage = stims.Targets[1].image
				setPos(targImage, [x, y])
				targX = x					# save it for later in case we need to draw target answer
				targY = y		
				if trialInfo.trialDir[theTrial] == -1					# left facing T stem (default)
					#drawCache(targImage, orientation = 0.0)
					draw(targImage, orientation = 0.0)
					obj = drawObjects(targImage, 0.0, [x,y])
					push!(drawingOrder, obj)
				else
					#drawCache(targImage, orientation = 180.0)
					draw(targImage, orientation = 180.0)
					obj = drawObjects(targImage, 180.0, [x,y])
					push!(drawingOrder, obj)
				end
			else
				distImage = stims.Distractors[whichDistractor].image
				setPos(distImage, [x, y])	
				distOri = rand(1:2)
				if distOri == 1										#	0 degrees
					#drawCache(distImage, orientation = 0.0) 
					draw(distImage, orientation = 0.0) 
					obj = drawObjects(distImage, 0.0, [x,y])
					push!(drawingOrder, obj)
				else												#	180 degrees
					#drawCache(distImage, orientation = 180.0)
					draw(distImage, orientation = 180.0)
					obj = drawObjects(distImage, 180.0, [x,y])
					push!(drawingOrder, obj)
				end	
			end
		end
	end

	#for s in stimDrawList
	#	draw(s)
	#end
	start = time()
	#flip(win)
	#flip2(win, true)#,"save")
	#flip(win, saveOrReturnScreenShot = "save")
	#........................
	#flip(win, screenShot =  true)
	flip(win)#, screenShot =  true)



	#........................
	stop = time()
	println("flip took ", stop-start)
	startTimer(win)

	keypressed = getKey(win)
	RT = stopTimer(win)

	# Grade Keypress
	accuracy = 0
	if keypressed == "z" && trialInfo.trialDir[theTrial] == -1
		accuracy = 1
	elseif keypressed == "slash" && trialInfo.trialDir[theTrial] == 1
		accuracy = 1
	elseif keypressed == "7"								# secret abort key
		shutDown(win, subjFile)
	else
		play(errSound)
	end

	if accuracy == 0
#i = 1
		for obj in drawingOrder
			setPos(obj.im, obj.pos)							# set the screen position
			draw(obj.im, orientation = obj.ori)
#println(i,") ", obj.pos,", ", obj.ori,", ",obj.im.pos,", ",obj.im._orientation)
#i+=1
		end

#		flipCache(win)	
		answerImage = stims.AnswerTargets[1].image
		setPos(answerImage, [targX, targY])
		if trialInfo.trialDir[theTrial] == -1					# left facing T stem (default)
			draw(answerImage)
		else
			draw(answerImage, orientation = 180.0)
		end
		flip(win)
		waitTimeMsec(1000)
	end
	#------
	if realOrPractice == true					# do not save practice data
		occluderType = trialInfo.trialOccluder[theTrial]
		buf = @sprintf("%d\t%d\t%d\t%s\t", trialNum,  theTrial, trialInfo.trialDir[theTrial], stims.Occluders[occluderType].name )
		buf = buf * @sprintf("%d\t%d\t", trialInfo.trialOccluder[theTrial], trialInfo.trialLayer[theTrial])
		buf = buf * @sprintf("%d\t%4.1f\t%d\t%s\n", trialInfo.trialSS[theTrial], RT, accuracy, keypressed)

		write(subjFile, buf)
	end
	flip(win)							# erase screen
	waitTimeMsec(500)
println("..........End of trial.............")
end
# √	Save Data
# X Try making drawing stimuli a function	<too unwieldy>
# Fix instructions
# add message for practice and trials
#-============================================================================

#-============================================================================
# Algorithmically make the control variables for the experiment
function makeExperimentalDesign(SS, Dir, Lay, OccType, Reps)
 
	numTrials = length(SS) * Dir * Lay * OccType * Reps
	println("NUMTRIALS = ", numTrials)

	trialSetSize = zeros(Int64, numTrials)			 # this will holder the set size control variable that we will fill below
	trialDir = zeros(Int64, numTrials)	  # this will holder the target presence control variable that we will fill below
	trialLayer = zeros(Int64, numTrials)	  # this will holder the stimulus' layer control variable that we will fill below
	trialOccluder = zeros(Int64, numTrials)	  # this will holder the target occluder type variable that we will fill below

	trial = 1
	for r in 1:repetitions						# we do this outer because it makes block randomization easier
		for ss in SS							# array of set setSizes
			for d in 1:Dir					# target presence
				for L in 1:Lay
					for occ in 1:OccType
						trialSetSize[trial] = ss
						trialDir[trial] = (d * 2)-3			# -1 = left (don't change), +1 = rotate 180°
						trialLayer[trial] = (L * 2)-3			# -1 = left (don't change), +1 = rotate 180°
						trialOccluder[trial] = occ
						trial += 1
					end
				end
			end 
		end
	end

		
	# next, create the random order for the trials.  This is not fancy block randomization.
	order = collect(1:numTrials)
	shuffleOrder = shuffle(order)
	# below we fill the struct with info about the experimental design and return it.
	designInfo = ExperimentDesign(numTrials, trialSetSize, trialDir, trialLayer, trialOccluder,shuffleOrder)
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
#-============================================================================
function loadImages(win)
	# 1) load text file with list of images
	
	println(pwd())
	baseFilePath = pwd()
	println("	", baseFilePath)
	#/Users/MattPetersonsAccount/.julia/dev/PsychoJL/Examples/complex occlusions
	baseFilePath =joinpath(baseFilePath, "Examples/complex occlusions/stimuli")
	println("		", baseFilePath)
	occluderFilePath =joinpath(baseFilePath,"occluders.txt")
	println("			", occluderFilePath)
	occludersFile = open(occluderFilePath,"r")
	occluderNames = readlines(occludersFile)
	# 2) loop and load each images and put it at the head of its list, scaled to the same width
	println(occluderNames)
	occluderList = []
	for occName in occluderNames
		#push!(entryList, occName)
		tempName = joinpath(baseFilePath,occName)
		anImage = ImageStim(win, tempName)
		setPos(anImage, [ 0.1, 0.5])
		scaleToWidth2(anImage, 0.05)
		#push!(entryList, anImage)
		entry = imageGroup(occName, anImage)
		draw(anImage)
		setPos(anImage, [ 0.2, 0.5])		
		draw(anImage, orientation = 45.0)
		flip(win)
		waitTimeMsec(100)
		push!(	occluderList, entry)
	end
	# 3) NO >>>>> rotate images
	#------------- Distractors
	distractorsFilePath =joinpath(baseFilePath,"distractors.txt")
	println("			", distractorsFilePath)
	distractorsFile = open(distractorsFilePath,"r")
	distractorNames = readlines(distractorsFile)
	# 2) loop and load each images and put it at the head of its list, scaled to the same width
	println(distractorNames)
	distractorList = []
	for distName in distractorNames
		tempName = joinpath(baseFilePath,distName)
		anImage = ImageStim(win, tempName)
		setPos(anImage, [ 0.1, 0.5])
		scaleToWidth2(anImage, 0.05)
		entry = imageGroup(distName, anImage)
		draw(anImage)
		setPos(anImage, [ 0.2, 0.5])		
		draw(anImage, orientation = 45.0)
		flip(win)
		waitTimeMsec(100)
		push!(distractorList, entry)
	end

	#------------- Target
	targetFilePath =joinpath(baseFilePath,"targets.txt")
	println("			", targetFilePath)
	targetsFile = open(targetFilePath,"r")
	targetNames = readlines(targetsFile)
	# 2) loop and load each images and put it at the head of its list, scaled to the same width
	println(targetNames)
	targetList = []
	for targetName in targetNames
		tempName = joinpath(baseFilePath,targetName)
		anImage = ImageStim(win, tempName)
		setPos(anImage, [ 0.1, 0.5])
		scaleToWidth2(anImage, 0.05)
		entry = imageGroup(targetName, anImage)
		draw(anImage)
		setPos(anImage, [ 0.2, 0.5])		
		draw(anImage, orientation = 45.0)

		setPos(anImage, [ 0.3, 0.5])		
		draw(anImage, orientation = 90.0)

		setPos(anImage, [ 0.4, 0.5])		
		draw(anImage, orientation = 180.0)
		flip(win)
		waitTimeMsec(100)
		push!(targetList, entry)
	end
	#------------- Answer Target
	targetFilePath =joinpath(baseFilePath,"answerTargets.txt")
	println("			", targetFilePath)
	targetsFile = open(targetFilePath,"r")
	targetNames = readlines(targetsFile)
	# 2) loop and load each images and put it at the head of its list, scaled to the same width
	println(targetNames)
	answerList = []
	for targetName in targetNames
		tempName = joinpath(baseFilePath,targetName)
		anImage = ImageStim(win, tempName)
		setPos(anImage, [ 0.1, 0.5])
		scaleToWidth2(anImage, 0.05)
		entry = imageGroup(targetName, anImage)
		draw(anImage)
		setPos(anImage, [ 0.2, 0.5])		
		draw(anImage, orientation = 45.0)

		setPos(anImage, [ 0.3, 0.5])		
		draw(anImage, orientation = 90.0)

		setPos(anImage, [ 0.4, 0.5])		
		draw(anImage, orientation = 180.0)
		flip(win)
		waitTimeMsec(100)
		push!(answerList, entry)
	end

	# 4) put them all in a struct and return
	theStims = Stimuli(targetList, answerList, distractorList, occluderList )
	return theStims
end
main()