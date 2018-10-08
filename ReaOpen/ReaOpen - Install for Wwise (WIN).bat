@echo off
setlocal ENABLEDELAYEDEXPANSION

set "variable=%~dp0"
set "variable=%variable:\=\\%"
REM echo "%variable%"


mkdir "%appdata%\Audiokinetic\Wwise\Add-ons\Commands"
(
echo {
echo 	"commands":[
echo 		{
echo 			"id":"ak.reaopen_in_reaper",
echo 			"displayName":"ReaOpen in REAPER",
echo 			"defaultShortcut":"Alt+R",
echo 			"program":"%variable%ReaOpen.exe",
echo 			"args":"${sound:originalWavFilePath}",
echo 			"cwd":"",
echo 			"contextMenu":{
echo 				"visibleFor":"Sound,MusicTrack"
echo 			},
echo 			"mainMenu":{
echo 				"basePath":"Edit/ReaOpen"
echo 			}
echo 		}
echo 	]
echo }) > "%appdata%\Audiokinetic\Wwise\Add-ons\Commands\reaopen_in_reaper_command.json"
echo Script finished! Please restart Wwise.
pause