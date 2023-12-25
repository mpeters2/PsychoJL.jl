export textStim, draw

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
	font::Ptr{TTF_Font}
end

#----------
function textStim(win::Window,				
				textMessage::String =  "future text",
				pos::Vector{Int64} = [SDL_WINDOWPOS_CENTERED,SDL_WINDOWPOS_CENTERED];
				color::Vector{Int64} = fill(128, (3)),			# these will need to change to floats to handle Psychopy colors
				fontName::String = "",
				fontSize::Int64 = 12,
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
	Message_rect = SDL_Rect(50, 50, w[], h[])

	SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) );		# &Message_rect)

	# Don't forget to free your surface and texture
	SDL_FreeSurface(surfaceMessage);
	SDL_DestroyTexture(Message);
end