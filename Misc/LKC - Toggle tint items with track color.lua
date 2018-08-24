--[[
  NoIndex: true
  About:
    Toggles colors
]]

--[[
 * Changelog:
 * v1.0 (2018-08-24)
  + Initial Release
]]

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

local tinttcp =  reaper.SNM_GetIntConfigVar( "tinttcp", -1)
if tinttcp == 1834 then
      reaper.SNM_SetIntConfigVar("tinttcp",1830)  -- paint with track color
else
  if tinttcp == 1830 then
      reaper.SNM_SetIntConfigVar("tinttcp",1834) --ignore track color
  end
end

--Msg(tinttcp)
reaper.UpdateArrange()