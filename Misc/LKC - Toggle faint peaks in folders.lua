--[[
  ReaScript Name: Toggle faint peaks in folders
  Author: LKC
  REAPER: 5+
  Version: 1.0
  About:
    # Show or hides ghost waveforms in folder tracks.
]]

--[[
 * Changelog:
 * v1.0 (2018-08-24)
  + Initial Release
]]

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

local showpeaks =  reaper.SNM_GetIntConfigVar( "showpeaks", -1)
if showpeaks == 2067 then
      reaper.SNM_SetIntConfigVar("showpeaks",2051)  -- show faint peaks in folders
else
  if showpeaks == 2051 then
      reaper.SNM_SetIntConfigVar("showpeaks",2067) --hide faint peaks in folders
  end
end

--Msg(showpeaks)
reaper.UpdateArrange()