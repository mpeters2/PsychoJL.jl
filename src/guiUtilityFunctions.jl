export InputBox

#-==========================================================================================================
mutable struct SDLGlobals

    SDLwindow
	renderer
	inputTextTexture
	promptTextTexture
end

#-==========================================================================================================
# more global shit from here: https:# pastebin.com/HvWxcZKv
 
mutable struct LTexture

    # Initialize
    mTexture 
    mWidth
    mHeight
end
#-==================================
function NTupleToString(NTuple)
	theString::String = ""
	i = 1
	done = false
	while !done
		theChar = NTuple[i]
		if theChar == 0							# 0 terminated Cstring
			done = true
		else
			theChar = Char(theChar)				# convert ascii interger to char
			theString = theString * theChar
			i += 1
		end
	end
	return theString
end

#-==================================
mutable struct InputBox
	win::Window
	valueText::String
	leftTop::Vector{Int64}
	size::Vector{Int64}
	focus::Bool
	textTexture::LTexture
	rightBottom::Vector{Int64}
	pos::Vector{Int64}
	textRect::SDL_Rect					#Ref{SDL_Rect}			# for drawing the text
	state::String
	key::String								# dictionary key

	function InputBox( win::Window, valueText::String, leftTop::Vector{Int64}, size::Vector{Int64}, key::String = "no-key-given")
		# should probably check to see if theses are valid, or flip their order if needed
	
		if valueText == ""
			valueText = " "
		end
		textTexture = loadFromRenderedText(win, valueText, SDL_Color(0,0,0,255))
		rightBottom = [ leftTop[1] + size[1],leftTop[2] + size[2] ]
		pos = [(leftTop[1] + rightBottom[1])÷2,(leftTop[2] + rightBottom[2])÷2]

		textRect = SDL_Rect( leftTop[1] *2 , leftTop[2] *2 ,  size[1] *2 , size[2] *2  )

		new(win, valueText, leftTop, size, false, textTexture, rightBottom, pos, textRect, "unused", key )
	end
end
#-==================================
mutable struct InputBoxMap
	parent::InputBox
	state::String					# clicked or not
	leftTop::Vector{Int64}
	rightBottom::Vector{Int64}


	function InputBoxMap( inBox::InputBox)
		state = "unclicked"
		leftTop = [inBox.pos[1] - inBox.size[1]÷ 2, inBox.pos[2] - inBox.size[2]÷ 2]
		#leftTop[1] ÷= 2
		#leftTop[2] ÷= 2
		rightBottom = [inBox.pos[1] + inBox.size[1]÷ 2, inBox.pos[2] + inBox.size[2]÷ 2]
		#rightBottom[1] ÷= 2
		#rightBottom[2] ÷= 2

		#left = inBox.leftTop[1]# + (in.size[1] ÷2)
		#top = inBox.leftTop[2]# + (in.size[2] ÷2)



		new(inBox, state, leftTop, rightBottom )
	end
end

#-==================================
function draw(in::InputBox)		# drawInputBox

#	left = in.leftTop[1]# + (in.size[1] ÷2)
#	top = in.leftTop[2]# + (in.size[2] ÷2)
#	myRect = SDL_Rect( left *2 , top *2 ,  in.size[1] *2 , in.size[2] *2  )
	drawInputBox(in, in.textRect, in.focus)
end
#--
function drawInputBox(in::InputBox, R::SDL_Rect, focus::Bool)			#drawInputBox
	# first draw filled Rect
	SDL_SetRenderDrawColor(in.win.renderer, 
							255, 
							255, 
							255, 
							255)

	SDL_RenderFillRect( in.win.renderer, Ref{SDL_Rect}(R))
	# then draw outline
	if focus == false
		SDL_SetRenderDrawColor(in.win.renderer, 
								0, 
								0, 
								0, 
								255)
	else
		SDL_SetRenderDrawColor(in.win.renderer, 
								0, 
								0, 
								255, 
								255)
	end	
	SDL_RenderDrawRect( in.win.renderer, Ref{SDL_Rect}(R))
	#-----------------------------------------------
	in.textTexture = loadFromRenderedText(in.win, in.valueText, SDL_Color(0,0,0,255))

	render(in.win.renderer, 
		in.textTexture,  
		#DoubleWidth - 70 - (Globals.inputTextTexture.mWidth + 10),
		#floor(Int64,(Globals.promptTextTexture.mHeight)) + 40,
		#R.x, R.y,
		convert(Int32, R.x + R.w -6 - in.textTexture.mWidth), 	# -22
		convert(Int32, R.y +8),
		#Globals.inputTextTexture.mWidth, 
		#Globals.inputTextTexture.mHeight 
		in.textTexture.mWidth, 
		in.textTexture.mHeight 
		#R.w, R.h
		)

end



#-==========================================================================================================
# from https:# gist.github.com/TomMinor/855879407c5acca83225
# same person, but on github 13 years earlier

#function loadFromRenderedText(Globals::SDLGlobals,  textureText::String,  textColor::SDL_Color, gFont::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font} )
function loadFromRenderedText(win::Window,  textureText::String,  textColor::SDL_Color )

    # Render text surface
    #textSurface = TTF_RenderText_Blended( gFont, textureText, textColor );			# should anti-alias compared to solid?
    textSurface = TTF_RenderText_Blended( win.font, textureText, textColor );			# should anti-alias compared to solid?

	
    if( textSurface == C_NULL )
        println( "Unable to render text surface! SDL_ttf Error: %s\n", SDL_GetError() ) #TTF_GetError() );
        return false;
    end

    # Create texture from surface pixels
   # font_texture = SDL_CreateTextureFromSurface( Globals.renderer, textSurface );
    font_texture = SDL_CreateTextureFromSurface( win.renderer, textSurface );
    if( font_texture  == C_NULL )
        println( "Unable to create texture from rendered text! SDL Error: %s\n", SDL_GetError() );
        return false;
    end

    # Get image dimensions
 	w = Ref{Cint}()
	h = Ref{Cint}()
	#TTF_SizeText(gFont, textureText, w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
	TTF_SizeText(win.font, textureText, w::Ref{Cint}, h::Ref{Cint})		# Ref is used if Julia controls the memory
	
	mWidth = w[]
	mHeight = h[]

    #Get rid of old surface
    SDL_FreeSurface( textSurface );

    # Return success
 	tempTextTexture = LTexture(font_texture, mWidth ,mHeight)
	return tempTextTexture
end
#-==========================================================================================================
function render(renderer::Ptr{SDL_Renderer}, ltexture::LTexture, x::Int32, y::Int32,  mWidth::Int32, mHeight::Int32)
	render(renderer, ltexture, convert(Int64, x), convert(Int64, y), mWidth, mHeight)
end
#-----------------
function render(renderer::Ptr{SDL_Renderer}, ltexture::LTexture, x::Int64, y::Int64,  mWidth::Int32, mHeight::Int32)

	renderQuad = SDL_Rect( x, y, mWidth, mHeight )
 
	SDL_RenderCopyEx( renderer, ltexture.mTexture, C_NULL,  Ref{SDL_Rect}(renderQuad), 0.0, C_NULL, SDL_FLIP_NONE );

end