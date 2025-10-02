--[[
  NoIndex: true
  About:
    Toggles faint peaks in folder tracks.
]]

--[[
 * Changelog:
 * v1.1 (2025-10-02)
  + Updated faint peaks script to work on REAPER 7
 * v1.0 (2018-08-24)
  + Initial Release
]]

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

local showpeaks =  reaper.SNM_GetIntConfigVar( "showpeaks", -1)
if showpeaks == 32787 then
      reaper.SNM_SetIntConfigVar("showpeaks",32771)  -- show faint peaks in folders
else
  if showpeaks == 32771 then
      reaper.SNM_SetIntConfigVar("showpeaks",32787) --hide faint peaks in folders
  end
end

--Msg(showpeaks)
reaper.UpdateArrange()
