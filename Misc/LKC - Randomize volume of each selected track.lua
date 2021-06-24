--[[
  ReaScript Name: Randomize volume of each selected track
  Author: LKC
  Version: 1.0
  About:
	Mixing inspiration!
]]

--[[
 * Changelog:
 * v1.0 (2021-06-24)
	+ Initial Release
]]

sel_tracks =  reaper.CountSelectedTracks( 0 )
for i = 0, sel_tracks - 1 do
    local track = reaper.GetSelectedTrack( 0,i )
    reaper.SetMediaTrackInfo_Value( track, "D_VOL", math.random() )
end

reaper.UpdateArrange()