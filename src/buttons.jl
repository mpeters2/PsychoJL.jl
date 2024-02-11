

export ButtonStim, ButtonMap, buttonDraw, buttonDrawClicked, buttonStim
# SDL-based buttons for dialog boxes.

"""
	Structs
		ButtonStim: threee types: default (enter key triggers), other (non-triggered), and custom
		ButtonMap: internally used as part of a list of butttons. Used for 
					detecting button presses, dispatching, etc.

"""

mutable struct ButtonStim
	win::Window
	pos::Vector{Int64}
	size::Vector{Int64}
	TextStim::TextStim						
	type::String								# default, other, custom.  default can be clicked with enter key
	outlineColor::Vector{Int64}					# these will need to change to floats to handle Psychopy colors
	fillColor::Vector{Int64}					# these will need to change to floats to handle Psychopy colors
												# other are the non-default buttons.
												# custom uses the colors provided.

	#----------

	function ButtonStim(win::Window,
					pos::Vector{Int64} = [10,10],
					size::Vector{Int64} = [10,10],
					TextStim::TextStim = nothing,					
					type::String = "other";
					outlineColor::Vector{Int64} = fill(128, (4)),			# these will need to change to floats to handle Psychopy colors
					fillColor::Vector{Int64} = fill(128, (4))			# these will need to change to floats to handle Psychopy colors
					)
		if TextStim == nothing
			error("Buttons require a TextStim.")
		end

		TextStim.pos[1] = pos[1] * 2		# high dpi	
		TextStim.pos[2] = pos[2] * 2		# high dpi
		outlineColor = colorToSDL(win, outlineColor)
		fillColor = colorToSDL(win, fillColor)

		new(win, 
			pos,
			size,
			TextStim,
			type,
			outlineColor,
			fillColor,						# these will need to change to floats to handle Psychopy colors
			)

	end
end

#----------

function buttonDraw(but::ButtonStim)
	# don't need to divide by 2, because high dpi causes everything to be half as large
	x1 = (but.pos[1]*2) - but.size[1] #÷ 2			# left;  ÷ is integer divide in Julia.  // in Python is integer divide, but in Julia it is fractions (rational number)
	x2 = (but.pos[1]*2) + but.size[1] #÷ 2			# right
	y1 = (but.pos[2]*2) - but.size[2] ÷ 2			# top
	y2 = (but.pos[2]*2) + but.size[2] ÷ 2			# bottom

	cx = (x1+x2) ÷ 2
	cy = (y1+y2) ÷ 2

	fillR = but.fillColor[1]
	fillG = but.fillColor[2]
	fillB = but.fillColor[3]
	fillA = but.fillColor[4]

	outR = but.outlineColor[1]
	outG = but.outlineColor[2]
	outB = but.outlineColor[3]
	outA = but.outlineColor[4]

	if but.type == "other"													# white button with black text
				aaFilledRoundRectRGBA(but.win.renderer, x1-2, y1-2, x2+3, y2+4, 19,	# lightshadow first
										238, 238, 238, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1-1, y1-1, x2+2, y2+3, 18,	# lightshadow first
										230, 230, 230, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2+1, y2+2, 17,	# shadow first
										203, 203, 203, 255)				
				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2, y2, 16,
										255, 255, 255, 255)				

				#aaRoundRectRGBA(but.win.renderer,x1, y1, x2, y2, 17,
				#						0, 0, 0, 255)	

				but.TextStim.color = [0, 0, 0]
				but.TextStim.fontSize = 24
				but.TextStim.horizAlignment = 0
				but.TextStim.vertAlignment = 0
				#but.TextStim.style = "bold"
				draw(but.TextStim)
	elseif but.type == "default"												# blue highlighted button with white text
				aaFilledRoundRectRGBA(but.win.renderer, x1-2, y1-2, x2+4, y2+4, 19,	# lightshadow first
										238, 238, 238, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1-1, y1-1, x2+3, y2+3, 18,	# lightshadow first
										230, 230, 230, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2+2, y2+2, 17,	# shadow first
										203, 203, 203, 255)		
				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2, y2, 16,
										131, 149, 247, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1 + 7, y1 +7, x2-7, y2-7, 12,
										64, 135, 247, 255)				
				aaRoundRectRGBA(but.win.renderer,x1 + 7, y1 +7, x2-7, y2-7, 12,
										45, 97, 228, 255)	
				but.TextStim.color = [255, 255, 255]
				but.TextStim.fontSize = 24
				but.TextStim.horizAlignment = 0
				but.TextStim.vertAlignment = 0
				#but.TextStim.style = "bold"
				draw(but.TextStim)
	elseif but.type == "custom"
				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2, y2, 16,
										fillR, fillG, fillB, fillA)				
			
				aaRoundRectRGBA(but.win.renderer,x1, y1, x2, y2, 16,
										outR, outG, outB, outA)	
				draw(but.TextStim)
	else
		error("Invalid button type. Options are 'default', 'other', or 'custom'.")
	end
end
#-================================
function buttonDrawClicked(but::ButtonStim)
	# don't need to divide by 2, because high dpi causes everything to be half as large
	x1 = (but.pos[1]*2) - but.size[1] #÷ 2			# left;  ÷ is integer divide in Julia.  // in Python is integer divide, but in Julia it is fractions (rational number)
	x2 = (but.pos[1]*2) + but.size[1] #÷ 2			# right
	y1 = (but.pos[2]*2) - but.size[2] ÷ 2			# top
	y2 = (but.pos[2]*2) + but.size[2] ÷ 2			# bottom

	cx = (x1+x2) ÷ 2
	cy = (y1+y2) ÷ 2

	fillR = but.fillColor[1]
	fillG = but.fillColor[2]
	fillB = but.fillColor[3]
	fillA = but.fillColor[4]

	outR = but.outlineColor[1]
	outG = but.outlineColor[2]
	outB = but.outlineColor[3]
	outA = but.outlineColor[4]

	if but.type == "other"													# white button with black text
				aaFilledRoundRectRGBA(but.win.renderer, x1-2, y1-2, x2+3, y2+4, 20,	# lightshadow first
										238, 238, 238, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1-1, y1-1, x2+2, y2+3, 19,	# lightshadow first
										230, 230, 230, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2+1, y2+2, 18,	# shadow first
										203, 203, 203, 255)				
				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2, y2, 17,
										239, 239, 239, 255)				

				#aaRoundRectRGBA(but.win.renderer,x1, y1, x2, y2, 17,
				#						0, 0, 0, 255)	

				but.TextStim.color = [0, 0, 0]
				but.TextStim.fontSize = 24
				but.TextStim.horizAlignment = 0
				but.TextStim.vertAlignment = 0
				but.TextStim.style = "bold"
				draw(but.TextStim)
	elseif but.type == "default"												# blue highlighted button with white text
				aaFilledRoundRectRGBA(but.win.renderer, x1-2, y1-2, x2+4, y2+4, 20,	# lightshadow first
										238, 238, 238, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1-1, y1-1, x2+3, y2+3, 19,	# lightshadow first
										230, 230, 230, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2+2, y2+2, 18,	# shadow first
										203, 203, 203, 255)		
				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2, y2, 17,
										131, 149, 247, 255)				

				aaFilledRoundRectRGBA(but.win.renderer, x1 + 7, y1 +7, x2-7, y2-7, 13,
										48, 113, 247, 227)				
				aaRoundRectRGBA(but.win.renderer,x1 + 7, y1 +7, x2-7, y2-7, 13,
										45, 97, 228, 255)	
				but.TextStim.color = [255, 255, 255]
				but.TextStim.fontSize = 24
				but.TextStim.horizAlignment = 0
				but.TextStim.vertAlignment = 0
				but.TextStim.style = "bold"
				draw(but.TextStim)
	elseif but.type == "custom"
				aaFilledRoundRectRGBA(but.win.renderer, x1, y1, x2, y2, 17,
										fillR, fillG, fillB, fillA)				
			
				aaRoundRectRGBA(but.win.renderer,x1, y1, x2, y2, 17,
										outR, outG, outB, outA)	
				draw(but.TextStim)
	else
		error("Invalid button type. Options are 'default', 'other', or 'custom'.")
	end
end
#---------------------------------------------
# button maps are part of a larger list of buttons that is looped through to
# draw and handle events.
mutable struct ButtonMap
	button::ButtonStim
	message::String					# used for dealing with logic of mouse click
	state::String					# clicked or not
	leftTop::Vector{Int64}
	rightBottom::Vector{Int64}

	function ButtonMap( button::ButtonStim, message::String)
		state = "unclicked"
		leftTop = [button.pos[1] - button.size[1]÷ 2, button.pos[2] - button.size[2]÷ 2]
		rightBottom = [button.pos[1] + button.size[1]÷ 2, button.pos[2] + button.size[2]÷ 2]
		new(button, message, state, leftTop, rightBottom )
	end
end


