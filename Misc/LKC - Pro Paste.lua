--[[
  ReaScript Name: Pro Paste
  Author: LKC
  REAPER: 5+
  Version: 1.6
  About:
    # Pro Tools like paste
]]

--[[
 * Changelog:
 * v1.0 (2019-04-17)
  + Initial Release
]]

position = reaper.GetCursorPosition()

reaper.Main_OnCommand(40058, 0) --paste items/tracks

reaper.SetEditCurPos(position, true, false)
