
export PopUpMenu, PopUpMap




mutable struct PopUpMenu
	win::Window
	pos::Vector{Int64}
	size::Vector{Int64}
	options::Array								# list of strings that can be selected
	selectionIndex::Int64							# index option that is selected
	valueText::String							# text of option that is selected
	#TextStim::TextStim						
	#type::String								# default, other, custom.  default can be clicked with enter key
	outlineColor::Vector{Int64}					# these will need to change to floats to handle Psychopy colors
	fillColor::Vector{Int64}					# these will need to change to floats to handle Psychopy colors

	selectionColor::Vector{Int64}		
	textColor::Vector{Int64}	
	selectionTextColor::Vector{Int64}
	selectionHeight::Int64				
	state::String
	leftTop::Vector{Int64}						# these change when the state changes, reflecting that the menu has grown
	rightBottom::Vector{Int64}
	fullLT::Vector{Int64}						# this is the full size it expands to when clicked.
	fullRB::Vector{Int64}
	menuTexts::Vector{TextStim}
	smallLT::Vector{Int64}
	smallRB::Vector{Int64}
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	focus::Bool
	key::String								# dictionary key

	function PopUpMenu( win::Window, pos::Vector{Int64}, size::Vector{Int64}, options::Array, key = "no-key-given"; horizAlignment = -1, vertAlignment = -1)
		
		if vertAlignment == -1											# top anchored
			pos[2] += size[2]÷2
		elseif vertAlignment == 0											# center anchored
			pos[2] = pos[2]
		elseif vertAlignment == +1										# bottom anchored
			pos[2] -= size[2]÷2
		else
			error("invalid popUp vertical popUp alignment parameter")
		end
		#---------

		if horizAlignment == -1											# left anchored
			pos[1] += size[1]÷2
		elseif horizAlignment == 0											# center justification
			pos[1] = pos[1]
		elseif horizAlignment == +1										# right anchored
			pos[1] -= size[1]÷2
		else
			error("invalid popUp horizontal popUp alignment parameter")
		end


		state = "unclicked"
		leftTop = [ 2*(pos[1] - size[1]÷ 2), pos[2] - size[2]÷ 2]
		rightBottom = [leftTop[1] + size[1], leftTop[2] + size[2]]
		#rightBottom = [pos[1] + size[1]÷ 2, pos[2] + size[2]÷ 2]
		#----- calculate full expanded size
		w = Ref{Cint}()
		h = Ref{Cint}()

		count = length(options)
		halfCount = count/2
		maxWidth = 0
		for opt in options
			TTF_SizeText(win.font, opt, w::Ref{Cint}, h::Ref{Cint})
			if w[] > maxWidth
				maxWidth = w[]
			end
		end
		maxWidth += 10
		if maxWidth < size[1]			# size is user defined size of the unclicked box	
			maxWidth = size[1]
		end
		height = h[] #* length(options[1]) + 10
		#=
		fullLT = [pos[1] - maxWidth ÷ 2, 
				pos[2] - height ÷ 2]
		fullRB = [pos[1] + maxWidth ÷ 2, 
				pos[2] + height ÷ 2]
		=#	
		fullLT = [leftTop[1], pos[2] - round(Int64, (height * halfCount)) - 4]		# pos[1] - maxWidth ÷ 2, 
		fullRB = [rightBottom[1], pos[2] + round(Int64, (height * halfCount)) + 4 ]	#pos[1] + maxWidth ÷ 2, 
						
		#-----
		txtColor = [0,0,0,255]
		selectTextColor = [255,255,255,255]
		selectColor = [64, 135, 247, 255]
		background = [250, 250, 250, 255]
		selectHeight = height + 4					
		#-----
		menuTexts::Vector{TextStim} = []
		for i in eachindex(options)								# make text stimuli for each entry
			popUpText = TextStim(win, options[i],	[0, 0]; color = txtColor)
			#popUpText.pos = [leftTop[1] + 4 , pos[2] ]
			#popUpText.pos = [leftTop[1] + 10 , rightBottom[2]-4 ]
			setPos(popUpText, [leftTop[1] + 10 , rightBottom[2]-4 ] )
			#popUpText.color = txtColor
			popUpText.fontSize = 24
			popUpText.horizAlignment = -1
			popUpText.vertAlignment = +1
			#popUpText.style = "bold"
			push!(menuTexts, popUpText)
		end
		#-----
		smallLT = leftTop
		smallRB = rightBottom
		#-----
		new(win, pos, size, options, 1, options[1],
				[200,200,200,255],
				background,
				selectColor,
				txtColor,
				selectTextColor,
				selectHeight,
				"unclicked",
				leftTop, rightBottom,
				fullLT, fullRB,
				menuTexts,
				smallLT, smallRB,
				horizAlignment,vertAlignment,							#	horizAlignment,  vertAlignment
				false,
				key
			)

	end
end
#----------------------------
function drawPopUpArrows(popUp::PopUpMenu)
	verts = [ [-8, -8], [+8, -8], [0, +8]]

	verts1 = [ [-8, 2], [0, +10], [+8, 2]]
	verts2 = [ [-8, -2], [0, -10], [+8, -2]]
	cX = popUp.rightBottom[1] - 19
	cY = popUp.pos[2]
	for i in 1:(length(verts1)-1)
		draw( Line(popUp.win, [cX + verts1[i][1], cY + verts1[i][2]], [cX + verts1[i+1][1], cY + verts1[i+1][2]], width = 4, lineColor = [255,255,255,255] ) )
	end
	#draw( line(popUp.win, [cX + verts1[3][1], cY + verts1[3][2]], [cX + verts1[1][1], cY + verts1[1][2]], width = 4, lineColor = [255,255,255,255] ) )	# [160,160,255,255]

	for i in 1:(length(verts2)-1)
		draw( Line(popUp.win, [cX + verts2[i][1], cY + verts2[i][2]], [cX + verts2[i+1][1], cY + verts2[i+1][2]], width = 4, lineColor = [255,255,255,255] ) )
	end
	#draw( line(popUp.win, [cX + verts2[3][1], cY + verts2[3][2]], [cX + verts2[1][1], cY + verts2[1][2]], width = 4, lineColor = [255,255,255,255] ) )	# [160,160,255,255]

end
#----------------------------
function draw(popUp::PopUpMenu, mousePos::Vector{Int64} = [-99,-99])			# Int32 because that is what SDL returns for coordinates

	draw(popUp, [ convert(Int32, mousePos[1]), convert(Int32, mousePos[2]) ] )
end
#--------
# unicode triangle pointing down is \u25BC:

function draw(popUp::PopUpMenu, mousePos::Vector{Int32} )			# Int32 because that is what SDL returns for coordinates

	fC = popUp.fillColor	
	oC = popUp.outlineColor	

	if popUp.state == "unclicked"
		# draw fill
		#SDL_SetRenderDrawColor(popUp.win.renderer, fC[1], fC[2], fC[3], fC[4])
		#mRect = SDL_Rect(popUp.leftTop[1], popUp.leftTop[2], popUp.size[1], popUp.size[2])					# wacky Julia struct constructor; x,y, widht, height
		#SDL_RenderFillRect(popUp.win.renderer, Ref{SDL_Rect}(mRect))		# that addition mess lets me send the rect as a pointer to the rect
		aaFilledRoundRectRGBA(popUp.win.renderer,
						popUp.leftTop[1] , popUp.leftTop[2], popUp.rightBottom[1], popUp.rightBottom[2],
						8, 
						fC[1], fC[2], fC[3], fC[4])		
		#---------
		# draw outline
		if popUp.focus == false
			aaRoundRectRGBA(popUp.win.renderer, 			#roundedRectangleRGBA
							popUp.leftTop[1], popUp.leftTop[2], popUp.rightBottom[1], popUp.rightBottom[2],
							8, 
							oC[1], oC[2], oC[3], oC[4])
		else
			aaRoundRectRGBA(popUp.win.renderer, 			#roundedRectangleRGBA
							popUp.leftTop[1]-1, popUp.leftTop[2]-1, popUp.rightBottom[1]+1, popUp.rightBottom[2]+1,
							8, 
							0, 0, 255, 255)
		end
		#---------
		# draw text			...maybe move this inside the constructor
		popUpText = popUp.menuTexts[popUp.selectionIndex] #				TextStim(popUp.win, popUp.options[selection],	[0, 0])
		#popUpText.pos = [popUp.leftTop[1] + 10 , popUp.rightBottom[2]-4 ]
		setPos(popUpText, [popUp.leftTop[1] + 10 , popUp.rightBottom[2]-4 ] )
		draw(popUpText)
		# ********************
		#popUpSymbol = TextStim(popUp.win, "▼",	[0, 0])
		aaFilledRoundRectRGBA(popUp.win.renderer,
						popUp.rightBottom[1] - 36, popUp.leftTop[2]+4, popUp.rightBottom[1]-4, popUp.rightBottom[2]-4,
						8, 
						64, 134, 237, 255)	
		drawPopUpArrows(popUp)
		# ********************
	elseif popUp.state == "clicked"														# this enters the pop-up button selection loop
#		println("I was clicked ", mousePos)
		mousePos[1] *= 2									# Hi Res stuff
		mousePos[2] *= 2									# Hi Res stuff
		#-----------
		# find which item is selected
		selectedItem = -99									# we don't use popUp.selectionIndex in case coords are out-of-bounds 
		for i in eachindex(popUp.options)
			yCoordTop = popUp.fullLT[2] + (popUp.selectionHeight * (i-1))
			yCoordBottom = yCoordTop + popUp.selectionHeight
			#[popUp.leftTop[1] + 4 , yCoord ]
			if (popUp.rightBottom[1] > mousePos[1] > popUp.leftTop[1]) && (yCoordBottom > mousePos[2] > yCoordTop)
				selectedItem = i
				popUp.selectionIndex = i
				popUp.valueText = popUp.menuTexts[i].textMessage
			end
		end
		#-------------------------
		# draw expanded menu
		aaFilledRoundRectRGBA(popUp.win.renderer,
						popUp.fullLT[1], popUp.fullLT[2], popUp.fullRB[1], popUp.fullRB[2],
						8, 
						fC[1], fC[2], fC[3], fC[4])		
		#------
		# draw outline
		if popUp.focus == false
			aaRoundRectRGBA(popUp.win.renderer, 			#roundedRectangleRGBA
							popUp.fullLT[1], popUp.fullLT[2], popUp.fullRB[1], popUp.fullRB[2],
							8, 
							oC[1], oC[2], oC[3], oC[4])
		else
			aaRoundRectRGBA(popUp.win.renderer, 			#roundedRectangleRGBA
							popUp.fullLT[1]-1, popUp.fullLT[2]-1, popUp.fullRB[1]+2, popUp.fullRB[2]+7,
							8, 
							0, 0, 128, 255)
						aaRoundRectRGBA(popUp.win.renderer, 			#roundedRectangleRGBA
							popUp.fullLT[1], popUp.fullLT[2], popUp.fullRB[1]+1, popUp.fullRB[2]+6,
							8, 
							127, 127, 255, 255)
			aaRoundRectRGBA(popUp.win.renderer, 			#roundedRectangleRGBA
							popUp.fullLT[1]-1, popUp.fullLT[2]-1, popUp.fullRB[1]+1, popUp.fullRB[2]+6,
							8, 
							0, 0, 255, 255)
		end
		#------
		for i in eachindex(popUp.options)
			#options[i]
			xCoord = popUp.fullLT[1]
			yCoord = popUp.fullLT[2] + (popUp.selectionHeight * (i-1))
			#popUp.menuTexts[i].pos[2] = yCoord + (popUp.selectionHeight÷1)
			setPos(popUp.menuTexts[i], [xCoord , yCoord + (popUp.selectionHeight÷1) ] )
			draw(popUp.menuTexts[i])
			#println("Ycoord = ", yCoord,", top = ", popUp.fullLT[2],", bottom = ", popUp.fullRB[2])
			# set coords of each then draw
			if i == selectedItem							# highlight selected item
				SDL_SetRenderDrawColor(popUp.win.renderer, 0, 0, 255, 64)
				mRect = SDL_Rect(popUp.leftTop[1], yCoord, popUp.size[1], popUp.selectionHeight) #popUp.size[2])					# wacky Julia struct constructor; x,y, widht, height
				SDL_RenderFillRect(popUp.win.renderer, Ref{SDL_Rect}(mRect))		# that addition mess lets me send the rect as a pointer to the rect
			end
		end
		#-------------------------
		# do event loop

		#-------------------------
		# draw screen

#			SDL_RenderPresent( popUp.win.renderer )


	else
		errString = "invalid popUp menu state. Got: " * popUp.state
		error(errString)
	end
end
#---------------------------------------------
# popup maps are part of a larger list of buttons that is looped through to
# draw and handle events.
mutable struct PopUpMap
	parent::PopUpMenu
	state::String					# clicked or not
	leftTop::Vector{Int64}
	rightBottom::Vector{Int64}

	function PopUpMap( parent::PopUpMenu)
		state = "unclicked"
		leftTop = [parent.pos[1] - parent.size[1]÷ 2, parent.pos[2] - parent.size[2]÷ 2]
		leftTop[1] ÷= 2
		leftTop[2] ÷= 2
		rightBottom = [parent.pos[1] + parent.size[1]÷ 2, parent.pos[2] + parent.size[2]÷ 2]
		rightBottom[1] ÷= 2
		rightBottom[2] ÷= 2
		new(parent, state, leftTop, rightBottom )
	end
end
#----------------------------
function stateChange(popMap::PopUpMap)
	if popMap.state == "clicked"
		popMap.state = "unclicked"
		popMap.parent.state = "unclicked"
		popMap.leftTop = deepcopy(popMap.parent.smallLT)				# change size based on state
		popMap.leftTop[1] ÷= 2
		popMap.leftTop[2] ÷= 2
		popMap.rightBottom = deepcopy(popMap.parent.smallRB)
		popMap.rightBottom[1] ÷= 2
		popMap.rightBottom[2] ÷= 2
	else
		popMap.state = "clicked"
		popMap.parent.state = "clicked"
		popMap.leftTop = deepcopy(popMap.parent.fullLT)				# change size based on state
		popMap.rightBottom = deepcopy(popMap.parent.fullRB)
		popMap.leftTop[1] ÷= 2
		popMap.leftTop[2] ÷= 2
		popMap.rightBottom[1] ÷= 2
		popMap.rightBottom[2] ÷= 2
	end
	println("changed popMap state to ", popMap.state)
end