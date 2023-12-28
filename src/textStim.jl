export textStim, draw, TextStim

#-================================================================================================================
# TextStim

# Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}

mutable struct TextStim	#{T}
	win::Window
	textMessage::String							# this will need to change to floats for Psychopy height coordiantes
	pos::Vector{Int64}	
	color::Vector{Int64}					# these will need to change to floats to handle Psychopy colors
	fontName::String						
	fontSize::Int64
	orientation::Int64
	justification::String
	scale::Float64
	font::Ptr{TTF_Font}
end

#----------
function textStim(win::Window,				
				textMessage::String =  "future text",
				pos::Vector{Int64} = [SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED];
				color::Vector{Int64} = fill(128, (3)),			# these will need to change to floats to handle Psychopy colors
				fontName::String = "",
				fontSize::Int64 = 12,
				orientation::Int64 = 0,
				justification = "left",							# left, center, or right
				scale = 1,										# magnifies the bitmap, but does not change font size
				font::Any = nothing											# font is for internal use and is a pointer to a TTF	
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
				orientation,
				justification,
				scale,
				font,				# these will need to change to floats to handle Psychopy colors
				)
	return textStruct
end
#----------
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

	surfaceMessage = TTF_RenderUTF8_Blended(text.win.font, text.textMessage, color)

	# now you can convert it into a texture
	Message = SDL_CreateTextureFromSurface(text.win.renderer, surfaceMessage);

#@engineerX you can get dimensions of rendered text with TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h)

	w = Ref{Cint}()
	h = Ref{Cint}()
	TTF_SizeText(text.font, text.textMessage, w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
	#println("w: ", w,", value = ", w[] )
#	Message_rect = SDL_Rect(50, 50, w[], h[])
	Message_rect = SDL_Rect(text.pos[1], text.pos[2], w[], h[])
	if text.scale != 1								# scale the text.  Not the same as changing the font size.
		Message_rect = SDL_Rect(text.pos[1], text.pos[2], sTruncInt( w[] * text.scale),sTruncInt( h[] * text.scale))	
	end
	if text.justification == "center"
		center = SDL_Point(w[]÷2, h[]÷2)											# ÷ is integer divide
	elseif text.justification == "left"
		center = SDL_Point(0, h[]÷2)											# ÷ is integer divide
	elseif text.justification == "right"
		center = SDL_Point(w[], h[]÷2)											# ÷ is integer divide
	else		# default is left justified at the bottom
		center = SDL_Point(0, h[])											# ÷ is integer divide
	end

	if text.orientation == 0 
		SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) );		# &Message_rect)
	else
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