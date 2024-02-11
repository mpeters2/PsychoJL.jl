# From: https://github.com/GPUWorks/SDL_GUI/blob/e9f7eca21fad733ad4444aede354162dbd175ac1/Source/SDL_TTF_utf8wrapsize.cpp#L16
# Translated to Julia by Matt Peterson, February 2024
using SDL2_ttf_jll

const lineSpace = 2;

function character_is_delimiter(c::Char, delimiters::String)
    for d in delimiters
        if c == d
            return true
        end
    end
    return false
end



#--------------------
function ttf_size_utf8_wrappedAI(font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}, text::String, wrap_length::Int64)
    if isempty(text) || wrap_length == 0
        error("Text has zero width or invalid wrap length")
    end

	wrap_length *= 2			# retina
    # Assuming TTF_SizeUTF8 is a function that returns the width and height of the text
    # This function needs to be defined or replaced with an equivalent in Julia
    #width, height = TTF_SizeUTF8(font, text)
	width = Ref{Cint}()
	height = Ref{Cint}()
	TTF_SizeUTF8(font, text, width, height)
    
    line_space = 2
    num_lines = 1
    wrap_delims = [' ', '\t', '\r', '\n']	#" \t\r\n"
    str_lines = []
    str_len = length(text)
    str = text
    tok = 1
    end_pos = str_len

    while tok <= end_pos
        line_end = findfirst(isequal('\n'), str[tok:end])
        if line_end === nothing				# === means "is"
            line_end = end_pos
        else
            line_end += tok - 1
        end

        # Wrap the line if necessary
        if wrap_length > 0 && (line_end - tok + 1) > wrap_length
            # Find the last delimiter before the wrap length
            wrap_spot = tok + wrap_length - 1
            while wrap_spot > tok && !character_is_delimiter(str[wrap_spot], wrap_delims)
                wrap_spot -= 1
            end
            if wrap_spot == tok
                wrap_spot = tok + wrap_length - 1
            end
            push!(str_lines, str[tok:wrap_spot])
            tok = wrap_spot + 1
        else
            push!(str_lines, str[tok:line_end])
            tok = line_end + 1
        end
        num_lines += 1
    end

    # Calculate the final width and height
    if num_lines > 1
		final_width = wrap_length
	else
		final_width = width[]
	end
	final_height = height[] + (num_lines - 1) * (height[] + line_space)

    return final_width, final_height
end

#	*w = (numLines > 1) ? wrapLength : width;
#	*h = height * numLines + (lineSpace * (numLines - 1));

#=
#-********************************* AI version above
function TTF_SizeUTF8_Wrapped(TTF_Font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}, 
							text::String, 
							w::Ptr{Int64},			# *w, 
							h::Ptr{Int64},			#int *h, 
							wrapLength::Int64)

	status = 0;
	#int width, height;
	width = Ref{Cint}()
	height = Ref{Cint}()
	#int numLines;
	#char *str, **strLines;

	# Get the dimensions of the text surface */
    if isempty(text) || wrap_length == 0
        error("Text has zero width or invalid wrap length")
    end

	numLines = 1;
	str = C_NULL;
	strLines = C_NULL;
	if (wrapLength > 0 && length(text) >0 ) 
		wrapDelims = " \t\r\n";
		#int w, h;
		int line = 0;
		#char *spot, *tok, *next_tok, *endText;
		#char delim;
		#str_len = SDL_strlen(text);
		str_len = length(text);

		numLines = 0;

		str = SDL_stack_alloc(char, str_len + 1);
		if (str == NULL) 
			TTF_SetError("Out of memory");
			return -1;
		end

		SDL_strlcpy(str, text, str_len + 1);
		tok = str;
		endText = str + str_len;
		do 
			strLines = (char **)SDL_realloc(strLines, (numLines + 1) * sizeof(*strLines));
			if (!strLines) 
				TTF_SetError("Out of memory");
				return -1;
			end
			strLines[numLines++] = tok;

			# Look for the end of the line */
			if ((spot = SDL_strchr(tok, '\r')) != NULL ||
				(spot = SDL_strchr(tok, '\n')) != NULL) 
				if (*spot == '\r') 
					++spot;
				end
				if (*spot == '\n') 
					++spot;
				end
			else
				spot = endText;
			end
			next_tok = spot;

			# Get the longest string that will fit in the desired space */
			for (; ; ) 
				# Strip trailing whitespace */
				while (spot > tok && CharacterIsDelimiter(spot[-1], wrapDelims)) 
					--spot;
				end
				if (spot == tok) 
					if (CharacterIsDelimiter(*spot, wrapDelims)) 
						*spot = '\0';
					end
					break;
				end
				delim = *spot;
				*spot = '\0';

				TTF_SizeUTF8(font, tok, &w, &h);
				if ((Uint32)w <= wrapLength) 
					break;
				else 
					# Back up and try again... */
					*spot = delim;
				end

				while (spot > tok &&
					!CharacterIsDelimiter(spot[-1], wrapDelims)) 
					--spot;
				end
				if (spot > tok) 
					next_tok = spot;
				end
			end
			tok = next_tok;
		end while (tok < endText);
	end
    if numLines > 1
		w[] = wrap_length
	else
		w[] = width[]
	end
	#*w = (numLines > 1) ? wrapLength : width;
	h[] = height * numLines + (lineSpace * (numLines - 1));

	return status;
end
=#
#-===============================================================================
# From: https://github.com/davidsiaw/SDL2_ttf/commit/5f5e8d09095f6ba03f1b92ce1349509d54165d53
# Translated to Julia by Matt Peterson, February 2024

#=
function SDL_bool GetDimensionsOfWrappedTextSurface(width_p::Int64,
                                                  height_p::Int64,
                                                  text::String,
                                                  TTF_Font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font},
                                                  numLines_p::Int64,
                                                  strLines_p::String,
                                                  str::String,
                                                  size_t str_len::Int64,
												  wrapLength::Uint32)


	w = Ref{Cint}()
	h = Ref{Cint}()

    #  Get the dimensions of the text surface  
    #if ( (TTF_SizeUTF8(font, text, &(*width_p), &(*height_p)) < 0) || !(*width_p) ) 
    if ( (TTF_SizeUTF8(font, text, w, h) < 0) || width_p <= 0 ) 
        TTF_SetError("Text has zero width");
        return(SDL_FALSE);
    end

    width_p = 0;   #  set this to zero. we will find out what the longest line is  

    numLines_p = 1;
    strLines_p = C_NULL;
    if ( wrapLength > 0 && length(text) > 0 ) 
        const char *wrapDelims = " \t\r\n";
        int w, h;
        int line = 0;
        char *spot, *tok, *next_tok, *end;
        char delim;
        *numLines_p = 0;

        if ( str == NULL ) 
            TTF_SetError("Out of memory");
            return(SDL_FALSE);
        end

        SDL_strlcpy(str, text, str_len+1);
        tok = str;
        end = str + str_len;
        do 
            size_t size = (*numLines_p+1)*sizeof(*(*strLines_p));
            *strLines_p = (char **)SDL_realloc(*strLines_p, size);
            if (!(*strLines_p)) 
                TTF_SetError("Out of memory");
                return(SDL_FALSE);
            end
            (*strLines_p)[(*numLines_p)++] = tok;

            #  Look for the end of the line  
            if ((spot = SDL_strchr(tok, '\r')) != NULL || (spot = SDL_strchr(tok, '\n')) != NULL) 
                if (*spot == '\r') 
                    ++spot;
                end
                if (*spot == '\n') 
                    ++spot;
                end
            else
                spot = end;
            end
            next_tok = spot;

            #  Get the longest string that will fit in the desired space  
            for ( ; ; ) 
                #  Strip trailing whitespace  
                while ( spot > tok && CharacterIsDelimiter(spot[-1], wrapDelims) ) 
                    --spot;
                end
                if ( spot == tok ) 
                    if (CharacterIsDelimiter(*spot, wrapDelims)) 
                        *spot = '\0';
                    end
                    break;
                end
                delim = *spot;
                *spot = '\0';

                TTF_SizeUTF8(font, tok, &w, &h);
                if ((Uint32)w <= wrapLength) 
                    if (w > *width_p) 
                        *width_p = w;
                    end

                    break;
                else
                    #  Back up and try again...  
                    *spot = delim;
                end

                while ( spot > tok &&
                       !CharacterIsDelimiter(spot[-1], wrapDelims) ) 
                    --spot;
                end
                if ( spot > tok ) 
                    next_tok = spot;
                end
            end
            tok = next_tok;
        end while (tok < end);
    end

    return SDL_TRUE;
end
#-=====================================================================================================
function TTF_SizeUTF8_Wrapped(TTF_Font::Ptr{SimpleDirectMediaLayer.LibSDL2._TTF_Font}, 
								text::String, 
								wrapLength::Int64,
								w::Ptr{Int64},			# *w, 
								h::Ptr{Int64},			#int *h, 
								lineCount::Ptr{Int64}		#int *lineCount)
							)


    TTF_CHECKPOINTER(text, NULL);

    str = C_NULL;
    if (wrapLength > 0 && text)
    
        str_len = SDL_strlen(text);
        str = SDL_stack_alloc(char, str_len+1);
    end
    get_dimension_result = GetDimensionsOfWrappedTextSurface(w,
                                                             h,
                                                             text,
                                                             font,
                                                             lineCount,
                                                             &strLines,
                                                             str,
                                                             str_len,
                                                             wrapLength);
    if (!get_dimension_result) 
        return(-1);
    end

    *h *= *lineCount;

    return 0;
end

=#