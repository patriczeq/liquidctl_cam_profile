#-------------------------
# liquidctl Profile loader
#  patrikeder.cz 2020
#
#-------------------------

global liquidctl
global liquidctl_v
global RingEffectProfile
global LogoEffectProfile
global PumpProfile
global FanProfile
global current_path

set liquidctl to "/usr/local/bin/liquidctl "
set liquidctl_v to false

set RingEffectProfile to "tai-chi 8800ff 00ff00"
set LogoEffectProfile to "fixed 8800ff"
set PumpProfile to "30 30 32 40 34 50 40 80 45 100"
set FanProfile to "30 20 32 30 34 40 40 50 50 100"

set progress description to "Preparing..."
set progress total steps to 3

set progress additional description to "Checking liquidctl"

try
	set liquidctl_v to do shell script liquidctl & " --version"
on error
	set liquidctl_v to false
end try

if liquidctl_v is false then
	display alert "Package liquidctl was not found" as critical
	error number -128
	
end if

tell application "Finder"
	set current_path to container of (path to me) as text
end tell

set profile_path to (current_path as text) & "cam_profile:"
set progress total steps to 4
set progress completed steps to 0
set progress description to "Loading profile"
set progress additional description to "Ring color effect"
try
	set profile_ring_file to open for access (profile_path as text) & "ring" & ".txt"
	set RingEffectProfile to (read profile_ring_file)
	close access profile_ring_file
on error
	display alert "Create your profile as first!" as critical
	error number -128
end try

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




