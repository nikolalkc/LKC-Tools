-- deffadeshape=0 --linear
-- deffadeshape=1 --parabolic
-- deffadeshape=2 --logarithmic

--[[
  NoIndex: true
  About:
    Toggles faint peaks in folder tracks.
]]

--[[
 * Changelog:
 * v1.0 (2018-10-03)
  + Initial Release
]]
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


--for selected items
item_count =  reaper.CountSelectedMediaItems(0)
if item_count > 0 then
	reaper.Main_OnCommand(41516,0) --fadein shape   LOGARITHMIC
	reaper.Main_OnCommand(41523,0) --fadeout shape  LOGARITHMIC
end

--set default for next imported
reaper.SNM_SetIntConfigVar("deffadeshape",2) -- LOGARITHMIC


--Msg(showpeaks)
reaper.UpdateArrange()

