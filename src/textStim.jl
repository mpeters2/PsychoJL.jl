export draw, TextStim, TextStimExp, setColor


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
  * color::PsychoColor.........*default = (128, 128, 128)*
  * fontName::String = "",
  * fontSize::Int64 = 12,.........*default = 12*
  * scale::Float64 = 1.0,.........*not the same as font size*
  * font::Any.........*default is taken from Window*
  * horizAlignment::Int64.........*default = -1, 0 = center, +1 = right*
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
	color::PsychoColor					# Union of strings, and float and int vectors
	fontName::String						
	fontSize::Int64
	scale::Float64
	font::Ptr{TTF_Font}
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	style::String							# bold, italic, etc.
	orientation::Int64
	_color::Vector{Int64}

	#----------
	function TextStim(win::Window,				
					textMessage::String =  "future text",
					pos::Vector{Int64} = [10,10];
					color::PsychoColor = "white",			# these will need to change to floats to handle Psychopy colors
					fontName::String = "",
					fontSize::Int64 = 12,
					scale::Float64 = 1.0,
					font::Any = nothing,											# font is for internal use and is a pointer to a TTF
					horizAlignment::Int64 = -1,
					vertAlignment::Int64 = +1,
					style::String = "normal",
					orientation::Int64 = 0,
					_color::Vector{Int64} = fill(128, (4))							# internal SDL color 
					)
		if fontName == ""
			font = win.font
		else
			println("*** Notice: have not implemented loading from system fonts yet")
		end
		_color = colorToSDL(win, color)

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
			orientation,
			_color
			)

	end
end

#----------
#----------
"""
	draw(text::TextStim; wrapLength::Int64)

Draws an TextStim to the back buffer.

**Inputs:**
 * text::TextStim

**Optional Inputs:**
 *  wrapLength::Int64......*in pixels (for now)*
"""
function draw(text::TextStim; wrapLength::Int64 = -1)	
	if length(text._color) == 4
		_color = SDL_Color(text._color[1], text._color[2] , text._color[3], text._color[4])
	elseif length(text._color) == 3
		_color = SDL_Color(text._color[1], text._color[2] , text._color[3], 255)
	else
		println("Error in draw(textStim): colors too short, should have length of 3 or 4")
		println("Length = ", length(text._color))
		println("Values = ", text._color)
	end
	#-------------------
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
	if wrapLength == -1
		surfaceMessage = TTF_RenderUTF8_Blended(text.font, text.textMessage, _color)		# text.win.font
		Message = SDL_CreateTextureFromSurface(text.win.renderer, surfaceMessage);
	#else
	#	surfaceMessage = TTF_RenderUTF8_Blended_Wrapped(text.font, text.textMessage, color, wrapLength)
	end

	# now you can convert it into a texture


#@engineerX you can get dimensions of rendered text with TTF_SizeText(TTF_Font *font, const char *text, int *w, int *h)

	w = Ref{Cint}()
	h = Ref{Cint}()
	if wrapLength == -1
		TTF_SizeText(text.font, text.textMessage, w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
		singleHeight = h[]
	else
		TTF_SizeText(text.font, text.textMessage, w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
		singleHeight = h[]
		#println("conventional width and height are: ", w[],", ",h[]," for the text: ",text.textMessage)
		#w[], h[] = ttf_size_utf8_wrappedAI(text.font, text.textMessage, wrapLength)
		strings, widths, h[] = wrapText(text.font, text.textMessage, wrapLength)
		#println("wrap width and height are: ", w[],", ",h[]," for the text: ",text.textMessage)
	end

	
	if text.vertAlignment == -1											# top anchored
		y = text.pos[2]
		cy  = 0
	elseif text.vertAlignment == 0											# center anchored
		y = text.pos[2] - round(Int64, h[]/2)
		cy = h[]÷2
	elseif text.vertAlignment == +1										# bottom anchored
		y = text.pos[2] - h[]
		if y < singleHeight + 5													# enforce a minimum height so it doesn't go off the top.
			y = 5
		end
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
		if wrapLength == -1
			Message_rect = SDL_Rect(x, y, w[], h[])
		else
			Message_rect = SDL_Rect(x, y + h[]÷2, w[], h[])
		end
	end
	#SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) );		# &Message_rect)
	if text.orientation == 0 
		if wrapLength == -1
			SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) );		# &Message_rect)
		else
			for s in 1:length(strings)			# loop through the sub-strings of wrapped text.
				surfaceMessage = TTF_RenderUTF8_Blended(text.font, strings[s], _color)		# text.win.font
				Message = SDL_CreateTextureFromSurface(text.win.renderer, surfaceMessage)

			
				Message_rect = SDL_Rect(x, y + (s-1)*singleHeight, round(Int64, widths[s] * text.scale), round(Int64, singleHeight * text.scale) )
				SDL_RenderCopy(text.win.renderer, Message, C_NULL, Ref{SDL_Rect}(Message_rect) )
			end
		end
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
"""
	setColor(text::TextStim; color::Union{String, Vector{Int64}, Vector{Float64}})

Update the textStim's color

**Inputs:**
 * text::TextStim
 * color is a string, Vector of integers, or vector of floats.
 NEED A LINK TO THE COLORS PAGE

"""
function setColor(text::TextStim, color::PsychoColor)
	text._color = colorToSDL(text.win, color)
end

#----------
function setSize(text::TextStim, fontSize::Int64)
	println("setSize(::TextStim, fontsize) is a future placeholder for loading a font of the specific size")
end
#----------
function setFont(text::TextStim, fontName::String)
	println("setFont(::TextStim, fontName) is a future placeholder for loading a font of the specified name")
end
#-------------------------------
const lineSpace = 2;
#-=============================================================================
function character_is_delimiter(c::Char, delimiters)
    for d in delimiters
        if c == d
            return true
        end
    end
    return false
end
#-=============================================================================
# returns a list of strings for plotting, as well as the resulting width and height
function wrapText(font, original::String, wrapWidth)

	if wrapWidth <= 0
		error("wrapWidth must be > 0")
	end

	line_space = 2
	strings = []

	w = Ref{Cint}()
	h = Ref{Cint}()
	TTF_SizeText(font, original, w, h)		# Ref is used if Julia controls the memory
	#-------------------
	# return if string does not need to be wrapped
	if w[] < wrapWidth
		push!(strings, original)
		return strings, w[], h[]
	end
	#-------------------

	wrap_delims = [' ', '\t', '\r', '\n']
	lineBreak_delims = ['\r', '\n']

	currentStr = original
	startSpot = 1
	endSpot = length(original)
	done = false
	c = 1
	lastFound = 1

	while done == false
		currentChar = currentStr[c]
		if character_is_delimiter(currentChar, wrap_delims) == true
			TTF_SizeText(font, currentStr[startSpot:c], w, h)
			if character_is_delimiter(currentChar, lineBreak_delims) == true		# line break
				if lastFound == 1
					push!(strings, currentStr[startSpot:c-1])
					currentStr = currentStr[c+1:endSpot]
				else
					push!(strings, currentStr[startSpot:c-1] )	#lastFound-1])
					currentStr = currentStr[c+1:endSpot]		#lastFound+1:endSpot]
				end
				endSpot = length(currentStr)
				lastFound = 1
				c = 0
				TTF_SizeText(font, currentStr[1:endSpot], w, h)				# check to see if the next string is short enough
				if 	w[] < wrapWidth
					done = true
					push!(strings, currentStr)
					c = endSpot 
				end
			elseif w[] <= wrapWidth
				lastFound = c
			elseif w[] > wrapWidth
				push!(strings, currentStr[startSpot:lastFound-1])
				currentStr = currentStr[lastFound+1:endSpot]
				endSpot = length(currentStr)
				lastFound = 1
				c = 0
				TTF_SizeText(font, currentStr[1:endSpot], w, h)				# check to see if the next string is short enough
				if 	w[] < wrapWidth
					done = true
					push!(strings, currentStr)
					c = endSpot 
				end
			end
		end
		c += 1

		if c >= endSpot
			done = true
			TTF_SizeText(font, currentStr[startSpot:c-1], w, h)
			if w[] > wrapWidth
				push!(strings, currentStr[startSpot:lastFound-1])
				currentStr = currentStr[lastFound+1:endSpot]
				push!(strings, currentStr)
			end
		end
	end
	
	returnWidth = 0
	widths = []
	# this is written to return max width, but instead we are returning widths of each string
	for s in strings
		TTF_SizeText(font, s, w, h)
		push!(widths, w[])
		if w[] > returnWidth
			returnWidth = w[]
		end
	end

	returnHeight = h[] + (length(strings) - 1) * (h[] + line_space)
	return strings, widths, returnHeight
end
#=
function wrapTextBackwards(font, original::String, wrapWidth)

	if wrapWidth <= 0
		error("wrapWidth must be > 0")
	end

	strings = []

	w = Ref{Cint}()
	h = Ref{Cint}()
	TTF_SizeText(font, original, w, h)		# Ref is used if Julia controls the memory
	#-------------------
	# return if string does not need to be wrapped
	if w[] < wrapWidth
		push!(strings, original)
		return strings, w[], h[]
	end
	#-------------------

	wrap_delims = [' ', '\t', '\r', '\n']
	lineBreak_delims = ['\r', '\n']

	currentStr = original
	startSpot = 1
	endSpot = length(original)
	done = false
	c = endSpot
	while done == false
		#for c in endSpot:-1:startSpot							# work backwards, find a delimiter, and if <, add to strings[]
			currentChar = currentStr[c]
			if character_is_delimiter(currentChar, wrap_delims) == true
				TTF_SizeText(font, currentStr[startSpot:c], w, h)
				if character_is_delimiter(currentChar, lineBreak_delims) == true		# line break
					push!(strings, currentStr[startSpot:c-1])
					currentStr = currentStr[c+1:endSpot]
					endSpot = length(currentStr)
					c = endSpot+1	
					TTF_SizeText(font, currentStr[startSpot:c-1], w, h)				# check to see if the next string is short enough
					if 	w[] < wrapWidth
						done = true
						push!(strings, currentStr)
						c = 0 
					end
				elseif w[] < wrapWidth
					push!(strings, currentStr[startSpot:c-1])
					currentStr = currentStr[c+1:endSpot]
					endSpot = length(currentStr)
					c = endSpot+1
					TTF_SizeText(font, currentStr[startSpot:c-1], w, h)				# check to see if the next string is short enough
					if 	w[] < wrapWidth
						done = true
						push!(strings, currentStr)
						c = 0 
					end
				end
			end
		c -= 1
		#end
		if c== 0
			done = true
			push!(strings, currentStr)
		end
	end
	
	return strings, w[], h[]


end
=#
#=
find delimiter. break on delimiter < length. make new string for next line.  return strings.

rules: break on a delimeter
must break on \r or \n

1) scan for delims
2)if no delim is found, find length of string.  
	If too big:
	a) chop at the 2nd-last char
	b) add a hyphen
	c) add left side to Strings
	d) make ride side the next thing to scan
3) if delim is < width, scan until you find the next that is not or find the end.


wrap_delims = [' ', '\t', '\r', '\n']
break_delims = ['\r', '\n']
findfirst(isequal('\n'), str[tok:end])


	Strings = []
	done = false
	while done = false

	end

	return strings, width, height
=#
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



mutable struct TextStimExp
	win::Window
	textMessage::String							# this will need to change to floats for Psychopy height coordiantes
	pos::Vector{Int64}	
	color::PsychoColor					# these will need to change to floats to handle Psychopy colors
	fontName::String						
	fontSize::Int64
	scale::Float64
	font::Ptr{TTF_Font}
	horizAlignment::Int64					# -1 for left, 0 for center, +1 for right
	vertAlignment::Int64					# -1 aligns at top, 0 for center, +1 aligns at bottom
	style::String							# bold, italic, etc.
	orientation::Int64

	#----------
	function TextStimExp(win::Window,				
					textMessage::String =  "future text",
					pos::Vector{Int64} = [10,10];
					color::PsychoColor = fill(128, (3)),			# these will need to change to floats to handle Psychopy colors
					fontName::String = "",
					fontSize::Int64 = 12,
					scale::Float64 = 1.0,
					font::Any = nothing,											# font is for internal use and is a pointer to a TTF
					horizAlignment::Int64 = -1,
					vertAlignment::Int64 = +1,
					style::String = "normal",
					orientation::Int64 = 0
					)
		if fontName == ""
			font = win.font
		else
			println("*** Notice: have not implemented loading from system fonts yet")
		end
		color = colorToSDL(win, color)

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
