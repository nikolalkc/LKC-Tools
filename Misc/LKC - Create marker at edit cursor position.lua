--[[
  ReaScript Name: Create marker at edit cursor position
  Author: LKC
  REAPER: 5+
  Version: 1.0
  About:
    # Works better than default action. It can create markers even if project iz zoomed out
]]

--[[
 * Changelog:
 * v1.0 (2019-05-17)
 ]]
--create marker
local cursor_pos = reaper.GetCursorPosition()
reaper.AddProjectMarker( 0, false, cursor_pos, 0, "", -1 )