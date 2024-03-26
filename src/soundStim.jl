export ErrSound, SoundStim, play

#When modules are loaded, if they have a function called __init__ it will be called. Does that help? NO
"""
	SoundStim()

Constructor for a SoundStim object

**Constructor inputs:**
  * filePath::string ......**the entire path to the file, including file name and extension**\n

**Outputs:** None

**Methods:** play()
"""
struct SoundStim	
	filePath::String
	soundData::Ptr{Mix_Chunk}

	#----------
	function SoundStim(	filePath::String)
						
	if isfile(filePath)
		soundData = Mix_LoadWAV_RW(SDL_RWFromFile(filePath, "rb"), 1)
	else
		error("$filePath not found")
	end

		new(filePath, 
			soundData
			)

	end
end
#----------
struct ErrSound	
	soundData::Ptr{Mix_Chunk}

	#----------
	function ErrSound()

	#parentDir = pwd()
	parentDir = pathof(PsychExpAPIs)
	parentDir, _ = splitdir(parentDir)				# strip PsychExpAPIs.jl from the path
	parentDir, _ = splitdir(parentDir)				# strip src from the path
	filePath = joinpath(parentDir, "artifacts")
	filePath = joinpath(filePath, "ErrSound-10db.wav")					
	if isfile(filePath)
		soundData = Mix_LoadWAV_RW(SDL_RWFromFile(filePath, "rb"), 1)
	else
		error("ErrSound() $filePath not found")
	end

		new(
			soundData
			)

	end
end
#----------
"""
	play(sound::SoundStim; repeats::Int64)

Plays a SoundStim

**Inputs:** SoundStim\n

**Optional Inputs:** repeats\n

**Outputs:** None
"""
function play(S::Union{SoundStim, ErrSound}; repeats::Int64 = 0)

	Mix_PlayChannel(-1, S.soundData, repeats)
	#no method matching unsafe_convert(::Type{Ptr{Mix_Chunk}}, ::typeof(errSound))
end
#-=======================================================





# play(loops=None,

function testSound()
	#if(Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 1, 1024) < 0)
	#	println("SDL_mixer could not initialize!", Mix_GetError())
	#end

	#Load the music
	aud_files = dirname(@__FILE__)
	#parentDir = pwd()
	parentDir = pathof(PsychExpAPIs)
	parentDir, _ = splitdir(parentDir)				# strip PsychExpAPIs.jl from the path
	parentDir, _ = splitdir(parentDir)				# strip src from the path
	filePath = joinpath(parentDir, "artifacts")
	filePath = joinpath(filePath, "ErrSound.wav")

	if isfile("$aud_files/beat.wav")
		println("FOUND ErrSound.wave AUDIO FILE!!!!!!!!!!!")
	end

	music = Mix_LoadMUS(filePath)

	if (music == C_NULL)
		println(">>> >>>", unsafe_string(SDL_GetError() ) )
		error("$filePath not found.")
	end
	errSound = Mix_LoadWAV_RW(SDL_RWFromFile(filePath, "rb"), 1)

	Mix_PlayChannel(-1, errSound, 0)
end
#=
scratch = Mix_LoadWAV_RW(SDL_RWFromFile("$aud_files/scratch.wav", "rb"), 1)
high = Mix_LoadWAV_RW(SDL_RWFromFile("$aud_files/high.wav", "rb"), 1)
med = Mix_LoadWAV_RW(SDL_RWFromFile("$aud_files/medium.wav", "rb"), 1)
low = Mix_LoadWAV_RW(SDL_RWFromFile("$aud_files/low.wav", "rb"), 1)
Mix_PlayChannelTimed(-1, med, 0, -1)

Mix_PlayMusic(music, -1)
sleep(1)
Mix_PauseMusic()
sleep(1)
Mix_ResumeMusic()
sleep(1)
Mix_HaltMusic()
=#