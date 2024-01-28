export draw, TextStim


#-================================================================================================================
# TextStim

# Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}
"""
	TextStim()

Constructor for a TextStim object


**Constructor inputs:**
  * win::Window
  * textMessage::String.........*default = "future text"*
  * pos::Vector{Int64}........*position: default  = [10,10]*
**Optional constructor inputs:**
  * color::Vector{Int64}.........*default = (128, 128, 128)*
  * fontName::String = "",
  * fontSize::Int64 = 12,.........*default = 12*
  * scale::Float64 = 1.0,.........*not the same as font size*
  * font::Any.........*default is taken from Window*
  * horizAlignment::Int64.........*default = 1, 0 = center, -1 = right*
  * vertAlignment::Int64 = 1.........*default = 1, 0 = center, -1 = bottom*
  * style::String.........*default = "normal", options include "bold" and "italic"*
  * orientation.........*orientation in degrees*


**Methods:**
  * draw()

**Notes:**
Using different font sizes requires loading them as different fonts.  For now it is easier
to load a large version of a font and using *scale* to scale the size of the resulting image.
"""
mutable struct TextStim	#{T}
	win::Window
	textMessage::String							# this will need to change to floats for Psychopy height coordiantes
	pos::Vector{Int64}	
	color::Vector{Int64}					# these will need to change to floats to handle Psychopy colors
	fontName::String						
	fontSize::Int64
	scale::Float64
	font::Ptr{TTF_Font}
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	style::String							# bold, italic, etc.
	orientation::Int64

	#----------
	function TextStim(win::Window,				
					textMessage::String =  "future text",
					pos::Vector{Int64} = [10,10];
					color::Vector{Int64} = fill(128, (3)),			# these will need to change to floats to handle Psychopy colors
					fontName::String = "",
					fontSize::Int64 = 12,
					scale::Float64 = 1.0,
					font::Any = nothing,											# font is for internal use and is a pointer to a TTF
					horizAlignment::Int64 = 1,
					vertAlignment::Int64 = 1,
					style::String = "normal",
					orientation::Int64 = 0
					)
		if fontName == ""
			font = win.font
		else
			println("*** Notice: have not implemented loading from system fonts yet")
		end


		new(win, 
			textMessage ,
			pos,
			color,
			fontName,
			fontSize,
			scale,
			font,				# these will need to change to floats to handle Psychopy colors
			horizAlignment,
			vertAlignment,
			style,
			orientation
			)

	end
end

#----------
#----------
"""
	draw(text::TextStim)

Draws an TextStim to the back buffer.

**Inputs: **
 * text::TextStim

"""
function draw(text::TextStim)
	if length(text.color) == 4
		color = SDL_Color(text.color[1], text.color[2] , text.color[3], text.color[4])
	elseif length(text.color) == 3
		color = SDL_Color(text.color[1], text.color[2] , text.color[3], 255)
	else
		println("Error in draw(textStim): colors too short, should have length of 3 or 4")
		println("Length = ", length(text.color))
		println("Values = ", text.color)
	end
	# as TTF_RenderText_Solid could only be used on
	# SDL_Surface then you have to create the surface first+
	#=
	if text.style == "normal"
		TTF_SetFontStyle(text.font, TTF_STYLE_NORMAL)
	elseif text.style == "italic"
		TTF_SetFontStyle(text.font, TTF_STYLE_ITALIC)
	elseif text.style == "bold"
		TTF_SetFontStyle(text.font, TTF_STYLE_BOLD)
	elseif text.style == "underline"
		TTF_SetFontStyle(text.font, TTF_STYLE_UNDERLINE)
	else
		error("Unrecognized font style. 'normal', 'italic', 'bold', and 'underline' are recognized.")
	end
	=#
	if text.style == "normal"
		text.font = text.win.font
	elseif text.style == "italic"
		text.font = text.win.italicFont
	elseif text.style == "bold"
		text.font = text.win.boldFont
	else
		error("Unrecognized font style. 'normal', 'italic', 'bold', and 'underline' are recognized.")
	end

	
	#---------
	surfaceMessage = TTF_RenderUTF8_Blended(text.font, text.textMessage, color)		# text.win.font
#	surfaceMessage = TTF_RenderText_Blended(text.font, text.textMessage, color)		# text.win.font

	# now you can convert it into a texture
	Message = SDL_CreateTextureFromSurface(text.win.renderer, surfaceMessage);

#@engineerX you can get dimensions of rendered text with TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h)

	w = Ref{Cint}()
	h = Ref{Cint}()
	TTF_SizeText(text.font, text.textMessage, w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
	#println("w: ", w,", value = ", w[] )

	if text.vertAlignment == -1											# top anchored
		y = text.pos[2]
		cy  = 0
	elseif text.vertAlignment == 0											# center anchored
		y = text.pos[2] - round(Int64, h[]/2)
		cy = h[]÷2
	elseif text.vertAlignment == +1										# bottom anchored
		y = text.pos[2] - h[]
		cy = h[]
	else
		error("invalid text vertical text alignment parameter")
	end
	#---------
	if text.horizAlignment == -1											# left anchored
		x = text.pos[1]
		cx = 0
	elseif text.horizAlignment == 0											# center justification
		x = text.pos[1] - round(Int64, w[]/2)
		cx = w[]÷2
	elseif text.horizAlignment == +1										# right anchored
		x = text.pos[1] - w[]
		cx = w[]
	else
		error("invalid text horizontal text alignment parameter")
	end
	#---------


	if text.scale != 1								# scale the text.  Not the same as changing the font size.
		Message_rect = SDL_Rect(x, y, round(Int64, w[] * text.scale), round(Int64, h[] * text.scale) )
	else
		Message_rect = SDL_Rect(x, y, w[], h[])
	end
	#SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) );		# &Message_rect)
	if text.orientation == 0 
		SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) );		# &Message_rect)
	else
		center = SDL_Point(cx, cy)
		SDL_RenderCopyEx(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect), text.orientation, Ref{SDL_Point}(center), SDL_FLIP_NONE)
	#	SDL_RenderCopyExF(  <<< FUTURE WITH FLOATS
	end 

	# Don't forget to free your surface and texture
	SDL_FreeSurface(surfaceMessage);
	SDL_DestroyTexture(Message);
end
#----------
function setSize(text::TextStim, fontSize::Int64)
	println("setSize(::TextStim, fontsize) is a future placeholder for loading a font of the specific size")
end
#----------
function setFont(text::TextStim, fontName::String)
	println("setFont(::TextStim, fontName) is a future placeholder for loading a font of the specified name")
end


#=
mutable struct TextStim	#{T}
	win::Window
	textMessage::String							# this will need to change to floats for Psychopy height coordiantes
	pos::Vector{Int64}	
	color::Vector{Int64}					# these will need to change to floats to handle Psychopy colors
	fontName::String						
	fontSize::Int64
	scale::Float64
	font::Ptr{TTF_Font}
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	style::String							# bold, italic, etc.
	orientation::Int64
end

#----------
function textStim(win::Window,				
				textMessage::String =  "future text",
				pos::Vector{Int64} = [10,10];
				color::Vector{Int64} = fill(128, (3)),			# these will need to change to floats to handle Psychopy colors
				fontName::String = "",
				fontSize::Int64 = 12,
				scale::Float64 = 1.0,
				font::Any = nothing,											# font is for internal use and is a pointer to a TTF
				horizAlignment::Int64 = 1,
				vertAlignment::Int64 = 1,
				style::String = "normal",
				orientation::Int64 = 0
				)
	if fontName == ""
		font = win.font
	else
		println("*** Notice: have not implemented loading from system fonts yet")
	end


	textStruct = TextStim(win, 
				textMessage ,
				pos,
				color,
				fontName,
				fontSize,
				scale,
				font,				# these will need to change to floats to handle Psychopy colors
				horizAlignment,
				vertAlignment,
				style,
				orientation
				)
	return textStruct
end


=#