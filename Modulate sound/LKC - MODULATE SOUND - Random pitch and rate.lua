--[[
  ReaScript Name:Modulate Sound
  Instructions:Select takes and run the script, you should get variations
  Author: LKC
  REAPER: 5+
  Extensions: SWS
  Version: 1.1
  Provides:
   [Main] LKC - MODULATE SOUND - Reset pitch and rate.lua
  About:
    # RANDOM PITCH AND RATE
      Use this script to create variations from same sound source quickly. You can run it multiple times.
	# RESET PITCH AND RATE
      Use this script to reset variations of sound source quickly.
]]

--[[
 * Changelog:
 * v1.1 (2018-06-23)
	+ Package created
 * v1.0 (2018-05-10)
	+ Initial Release
--]]
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

pitch_range = 8  --in semitones, larger number larger changes
rate_factor = 2 --large number smaller changes

local selitems = reaper.CountSelectedMediaItems(0)
if selitems > 0 then
	for i = 0, selitems - 1 do
		local item = reaper.GetSelectedMediaItem( 0, i)
		local take = reaper.GetActiveTake( item )
		
		
		--pitch
		cur_pitch = reaper.GetMediaItemTakeInfo_Value( take, "D_PITCH" )
		local offset = math.random()*pitch_range - pitch_range/2
		local new_pitch = cur_pitch + offset
		reaper.SetMediaItemTakeInfo_Value( take, "D_PITCH", new_pitch)
		
		
		
		--rate
		cur_rate = reaper.GetMediaItemTakeInfo_Value( take, "D_PLAYRATE" )
		local offset = math.random()/rate_factor - 1/rate_factor/rate_factor
		local new_rate = cur_rate + offset
		reaper.SetMediaItemTakeInfo_Value( take, "D_PLAYRATE", new_rate)
	end
end

reaper.UpdateArrange()