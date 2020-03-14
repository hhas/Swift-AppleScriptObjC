

script iTunesBridge
	
	property parent : class "NSObject"
	
	
	to isRunning() -- () -> NSNumber (Bool)
		-- AppleScript will automatically launch apps before sending Apple events;
		-- if that is undesirable, check the app object's `running` property first
		return running of application id "com.apple.Music"
	end isRunning
	
	
	to playerState() -- () -> NSNumber (PlayerState)
		tell application id "com.apple.Music"
			if running then
				set currentState to player state
				-- ASOC does not bridge AppleScript's 'type class' and 'constant' values
				set i to 1
				repeat with stateEnumRef in {stopped, playing, paused, fast forwarding, rewinding}
					if currentState is equal to contents of stateEnumRef then return i
					set i to i + 1
				end repeat
			end if
			return 0 -- 'unknown'
		end tell
	end playerState
	
	
	to trackInfo() -- () -> ["trackName":NSString, "trackArtist":NSString, "trackAlbum":NSString]?
		tell application id "com.apple.Music"
			try
				return {trackName:name, trackArtist:artist, trackAlbum:album} of current track
			on error number -1728 -- current track is not available
				return missing value -- nil
			end try
		end tell
	end trackInfo
	
	to trackDuration() -- () -> NSNumber (Double, >=0)
		tell application id "com.apple.Music"
			return duration of current track
		end tell
	end trackDuration
	
	
	to soundVolume() -- () -> NSNumber (Int, 0...100)
		tell application id "com.apple.Music"
			return sound volume -- ASOC will convert returned integer to NSNumber
		end tell
	end soundVolume
	
	to setSoundVolume:newVolume -- (NSNumber) -> ()
		-- ASOC does not convert NSObject parameters to AS types automatically…
		tell application id "com.apple.Music"
			-- …so be sure to coerce NSNumber to native integer before using it in Apple event
			set sound volume to newVolume as integer
		end tell
	end setSoundVolume:
	
	
	to playPause()
		tell application id "com.apple.Music" to playpause
	end playPause
	
	to gotoNextTrack()
		tell application id "com.apple.Music" to next track
	end gotoNextTrack
	
	to gotoPreviousTrack()
		tell application id "com.apple.Music" to previous track
	end gotoPreviousTrack
	
end script
