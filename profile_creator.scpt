#-------------------------
#  liquidctl Profile configurator
#  patrikeder.cz 2020
#
#-------------------------
display notification "Script started, wait for menu dialog..." with title "liquidctl Profile configurator"
#globals
global liquidctl
global liquidctl_v
global RingEffectProfile
global LogoEffectProfile
global PumpProfile
global FanProfile
global current_path
global Speeds
global RingEffectsSpeeds
global LogoEffectsSpeeds
#---------------------------------------- Script variables
set myFN to "Reload info"
set DefaultColor to {65535, 65535, 65535}
set liquidctl to "/usr/local/bin/liquidctl "
set liquidctl_v to false
set RingEffectProfile to "tai-chi ffffff 000000"
set LogoEffectProfile to "fixed ffffff"
set PumpProfile to "30 30 32 40 34 50 40 80 45 100"
set FanProfile to "30 20 32 30 34 40 40 50 50 100"

#---------------------------------------- liquidctl LED Effects
#---- ring
set ringEffects to {"off", "fixed", "super-fixed", "fading", "spectrum-wave", "backwards-spectrum-wave", "super-wave", "backwards-super-wave", "marquee-3", "backwards-marquee-3", "covering-marquee", "covering-backwards-marquee", "alternating", "moving-alternating", "backwards-moving-alternating", "breathing", "super-breathing", "pulse", "tai-chi", "water-cooler", "loading", "wings"}
set RingEffectsColorMax to {0, 1, 9, 8, 0, 0, 8, 8, 1, 1, 8, 8, 2, 2, 2, 8, 9, 8, 2, 0, 1, 1}
set RingEffectsColorMin to {0, 1, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 1, 1, 1, 2, 0, 1, 1}
set RingEffectsSpeeds to {false, false, false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, false, true, true}
#---- logo
set logoEffects to {"off", "fixed", "fading", "spectrum-wave", "backwards-spectrum-wave", "breathing", "super-breathing", "pulse"}
set logoEffectsColorMax to {0, 1, 8, 0, 0, 8, 8, 8}
set logoEffectsColorMin to {0, 1, 2, 0, 0, 1, 1, 1}
set LogoEffectsSpeeds to {false, false, true, true, true, true, true, true}
#---- speeds
set Speeds to {"slowest", "slower", "normal", "faster", "fastest"}
#---------------------------------------- EOF liquidctl LED Effects
#================================================================================================================================
#---------------------------------------- Script begin
set fnList to {"├─ Reload status", "├───────────────────", "├─ Fan speed", "├─ Pump speed", "├───────────────────", "├─ Ring color effect", "├─ Logo color effect", "└───────────────────", "       ├─ Load profile", "       └─ Save profile"}

set current_path to false
set firstRun to false

set progress description to "Preparing..."
set progress total steps to 3
set progress additional description to "Checking liquidctl"
#---------------------------------------- Check if liquidctl is installed
try
	set liquidctl_v to do shell script liquidctl & " --version"
on error
	set liquidctl_v to false
end try
if liquidctl_v is false then
	display alert "Package liquidctl was not found" as critical
	error number -128
	
end if
#---------------------------------------- Load device info
set device to (do shell script liquidctl & "status")

set progress completed steps to 1
set progress additional description to "Checking profile files..."

#---------------------------------------- Profile files preparation
tell application "Finder"
	set current_path to container of (path to me) as text
	if (not (exists (current_path as text) & "cam_profile")) then
		set firstRun to true
		set profile_path to make new folder at current_path with properties {name:"cam_profile"}
		tell application "Finder"
			set current_path to container of (path to me) as text
			tell application "Finder"
				set profile_ring_file to make new file at (profile_path) with properties {name:"ring.txt"}
				set profile_logo_file to make new file at (profile_path) with properties {name:"logo.txt"}
				set profile_pump_file to make new file at (profile_path) with properties {name:"pump.txt"}
				set profile_fan_file to make new file at (profile_path) with properties {name:"fan.txt"}
			end tell
		end tell
	end if
end tell


#--------- profile writer

if firstRun then
	write_profile((current_path as text) & "cam_profile:", RingEffectProfile, LogoEffectProfile, PumpProfile, FanProfile)
end if
delay 0.5

#---------------------------------------- Functions
on load_profile(profile_path)
	set progress total steps to 4
	set progress completed steps to 0
	set progress description to "Loading profile"
	set progress additional description to "Ring color effect"
	set profile_ring_file to open for access (profile_path as text) & "ring" & ".txt"
	set RingEffectProfile to (read profile_ring_file)
	close access profile_ring_file
	
	do shell script liquidctl & " set ring color " & RingEffectProfile
	set progress completed steps to 1
	set progress additional description to "Logo color effect"
	
	set profile_logo_file to open for access (profile_path as text) & "logo" & ".txt"
	set LogoEffectProfile to (read profile_logo_file)
	close access profile_logo_file
	
	do shell script liquidctl & " set logo color " & LogoEffectProfile
	set progress completed steps to 2
	set progress additional description to "Pump speed"
	
	set profile_pump_file to open for access (profile_path as text) & "pump" & ".txt"
	set PumpProfile to (read profile_pump_file)
	close access profile_pump_file
	
	do shell script liquidctl & " set pump speed " & PumpProfile
	set progress completed steps to 3
	set progress additional description to "Fan speed"
	
	set profile_fan_file to open for access (profile_path as text) & "fan" & ".txt"
	set FanProfile to (read profile_fan_file)
	close access profile_fan_file
	
	do shell script liquidctl & " set fan speed " & FanProfile
	set progress completed steps to 4
	set progress additional description to "Profile loaded!"
	
	
end load_profile

on write_single_profile_part(profile_path, variable, type)
	set progress total steps to 1
	set progress completed steps to 0
	set progress description to "Saving profile part"
	set progress additional description to type
	set profile_part_file to open for access (profile_path as text) & "type" & ".txt" with write permission
	write ring to profile_part_file
	close access profile_part_file
end write_single_profile_part

on write_profile(profile_path, ring, logo, pump, fan)
	set progress total steps to 4
	set progress completed steps to 0
	set progress description to "Saving profile"
	set progress additional description to "Ring color effect"
	set profile_ring_file to open for access (profile_path as text) & "ring" & ".txt" with write permission
	write "                                                                                                                                                                        " as text to profile_ring_file starting at 0
	write ring as text to profile_ring_file starting at 0
	close access profile_ring_file
	
	set progress completed steps to 1
	set progress additional description to "Logo color effect"
	set profile_logo_file to open for access (profile_path as text) & "logo" & ".txt" with write permission
	write "                                                                                                                                                                        " as text to profile_logo_file starting at 0
	write logo to profile_logo_file starting at 0
	close access profile_logo_file
	
	set progress completed steps to 2
	set progress additional description to "Pump speed"
	set profile_pump_file to open for access (profile_path as text) & "pump" & ".txt" with write permission
	write "                                                                                                                                                                        " as text to profile_pump_file starting at 0
	write pump to profile_pump_file starting at 0
	close access profile_pump_file
	
	set progress completed steps to 3
	set progress additional description to "Fan speed"
	set profile_fan_file to open for access (profile_path as text) & "fan" & ".txt" with write permission
	write "                                                                                                                                                                        " as text to profile_fan_file starting at 0
	write fan to profile_fan_file starting at 0
	close access profile_fan_file
	
	set progress completed steps to 4
	set progress additional description to "Done!"
	
	return true
end write_profile

on RBG_to_HEX(RGB_values)
	set the hex_list to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
	set the the hex_value to ""
	repeat with i from 1 to the count of the RGB_values
		set this_value to (item i of the RGB_values) div 256
		if this_value is 256 then set this_value to 255
		set x to item ((this_value div 16) + 1) of the hex_list
		set y to item (((this_value / 16 mod 1) * 16) + 1) of the hex_list
		set the hex_value to (the hex_value & x & y) as string
	end repeat
	#return ("#" & the hex_value)
	return (the hex_value)
end RBG_to_HEX

on RBG_to_RGB8bit({r, g, b})
	set r to (r ^ 0.5) div 1
	set g to (g ^ 0.5) div 1
	set b to (b ^ 0.5) div 1
	return "{class:8-bit RGB color, red:" & r & ", green:" & g & ", blue:" & b & "}" as string
end RBG_to_RGB8bit

on RBG_to_RGB16bit({r, g, b})
	return "{class:16-bit RGB color, red:" & r & ", green:" & g & ", blue:" & b & "}" as string
end RBG_to_RGB16bit

on list_position(this_item, this_list)
	repeat with i from 1 to the count of this_list
		if item i of this_list is this_item then return i
	end repeat
	return 0
end list_position

#---------------------------------------- Main menu

on ringColorsMerge(theList)
	set AppleScript's text item delimiters to " "
	set theString to theList as string
	set AppleScript's text item delimiters to " "
	return theString
end ringColorsMerge

#------------------------------------------------------------------------------------------------------------------------

#---------------------------------------- MENU Loop

repeat while myFN is not false
	set progress total steps to 0
	set progress completed steps to 0
	set progress description to "Waiting for selection"
	set progress additional description to ""
	set myFN to choose from list fnList with prompt liquidctl_v & "
────────────────────
" & device & "
────────────────────
Configuration:" default items {myFN}
	
	if myFN is {"       ├─ Load profile"} then
		load_profile((current_path as text) & "cam_profile:")
	else if myFN is {"       └─ Save profile"} then
		
		display dialog "Save current settings as profile?
        
Ring: " & RingEffectProfile & "
Logo: " & LogoEffectProfile & "
Pump: " & PumpProfile & "
Fan: " & FanProfile buttons {"Back", "Save"} default button "Save"
		
		if button returned of result = "Save" then
			write_profile((current_path as text) & "cam_profile:", RingEffectProfile, LogoEffectProfile, PumpProfile, FanProfile)
		end if
	else if myFN is {"├─ Fan speed"} then
		set FanProfile to the text returned of (display dialog "Set fan speed. Percent, or in format => TEMP PERC TEMP PERC (30 50 35 100) - on 30°C 50%, on 35°C 100%" default answer FanProfile)
		set doShell to liquidctl & "set fan speed " & FanProfile
		set progress total steps to 1
		set progress completed steps to 0
		set progress description to "Setting fan speed"
		set progress additional description to FanProfile
		delay 0.5
		set res to (do shell script doShell)
		set progress completed steps to 1
		
	else if myFN is {"├─ Pump speed"} then
		set PumpProfile to the text returned of (display dialog "Set pump speed. Percent, or in format => TEMP PERC TEMP PERC (30 50 35 100) - on 30°C 50%, on 35°C 100%" default answer PumpProfile)
		set doShell to liquidctl & "set pump speed " & PumpProfile
		set progress total steps to 1
		set progress completed steps to 0
		set progress description to "Setting pump speed"
		set progress additional description to PumpProfile
		delay 0.5
		set res to (do shell script doShell)
		set progress completed steps to 1
		
	else if myFN is {"├─ Ring color effect"} then
		#------------ PROPMPTS
		set ringEffect to choose from list ringEffects with prompt "Select effect for ring:" default items {"off"}
		set effectIndex to list_position(ringEffect as text, ringEffects)
		set maxColors to item effectIndex of RingEffectsColorMax
		set minColors to item effectIndex of RingEffectsColorMin
		
		
		if ringEffect is not {"off"} then
			set ringColors to {}
			set addingColors to true
			repeat while maxColors > (count of ringColors) and addingColors is true
				if (count of ringColors) < minColors then
					copy RBG_to_HEX((choose color default color DefaultColor)) to the end of the ringColors
				else
					display dialog "Add color ?
Minimum " & minColors & " color/s and maximum " & maxColors & " color/s
Current " & (count of ringColors) & " color/s
(" & ringColorsMerge(ringColors) & ")" buttons {"No", "Yes"} default button "Yes"
					
					if button returned of result = "Yes" then
						copy RBG_to_HEX((choose color default color DefaultColor)) to the end of the ringColors
					else
						set addingColors to false
					end if
				end if
			end repeat
			if (count of ringColors) < minColors then
				display dialog "Minimum is " & minColors & " color(s)"
			else
				set ringSpeed to ""
				if item effectIndex of RingEffectsSpeeds is true then
					
					display dialog "Change effect speed?" buttons {"No", "Yes"} default button "Yes"
					if button returned of result = "Yes" then
						set ringSpeed to choose from list Speeds with prompt "Select effect speed" default items "default"
						set ringSpeed to " --speed " & ringSpeed
					end if
					
				end if
				
				
				set RingSetup to liquidctl & "set ring color " & ringEffect & " " & ringColorsMerge(ringColors) & ringSpeed
				set RingEffectProfile to ringEffect & " " & ringColorsMerge(ringColors) & ringSpeed
				#---------- SH - Ring
				set progress total steps to 1
				set progress completed steps to 0
				set progress description to "Setting Ring color"
				set progress additional description to RingEffectProfile
				delay 0.5
				set res to (do shell script RingSetup)
				set progress completed steps to 1
			end if
			
		else
			set RingSetup to liquidctl & "set ring color off"
			set RingEffectProfile to "off"
			#---------- SH - Ring
			set progress total steps to 1
			set progress completed steps to 0
			set progress description to "Turning off LEDs on ring"
			delay 0.5
			set res to (do shell script RingSetup)
			set progress completed steps to 1
		end if
	else if myFN is {"├─ Logo color effect"} then
		set logoColors to {}
		set addingColors to true
		set logoEffect to choose from list logoEffects with prompt "Select effect for logo:" default items "off"
		set effectIndex to list_position(logoEffect as text, logoEffects)
		set maxColors to item effectIndex of logoEffectsColorMax
		set minColors to item effectIndex of logoEffectsColorMin
		
		repeat while maxColors > (count of logoColors) and addingColors is true
			if (count of logoColors) < minColors then
				copy RBG_to_HEX((choose color default color DefaultColor)) to the end of the logoColors
			else
				display dialog "Add color ?
Minimum " & minColors & " color/s and maximum " & maxColors & " color/s
Current " & (count of logoColors) & " color/s
(" & ringColorsMerge(logoColors) & ")" buttons {"No", "Yes"} default button "Yes"
				
				if button returned of result = "Yes" then
					copy RBG_to_HEX((choose color default color DefaultColor)) to the end of the logoColors
				else
					set addingColors to false
				end if
			end if
		end repeat
		if (count of logoColors) < minColors then
			display dialog "Minimum is " & minColors & " color(s)"
		else
			set LogoSpeed to ""
			if item effectIndex of LogoEffectsSpeeds is true then
				display dialog "Change effect speed?" buttons {"No", "Yes"} default button "Yes"
				if button returned of result = "Yes" then
					set LogoSpeed to choose from list Speeds with prompt "Select speed" default items {"default" as text}
					set LogoSpeed to " --speed " & LogoSpeed
				end if
			end if
			
			set LogoSetup to liquidctl & "set logo color " & logoEffect & " " & ringColorsMerge(logoColors) & LogoSpeed
			set LogoEffectProfile to logoEffect & " " & ringColorsMerge(logoColors) & LogoSpeed
			#---------- SH - logo
			set progress total steps to 1
			set progress completed steps to 0
			set progress description to "Setting Logo color"
			set progress additional description to LogoEffectProfile
			delay 0.5
			set res to (do shell script LogoSetup)
			set progress completed steps to 1
		end if
	else if myFN is not false then
		set progress total steps to 1
		set progress completed steps to 0
		set progress description to "Loading liquidctl status"
		delay 0.5
		
		set device to (do shell script liquidctl & "status")
		set progress completed steps to 1
	end if
	
end repeat

