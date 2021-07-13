--[[
  ReaScript Name: 1 frame fade to all selected items
  Author: LKC
  Version: 1.0
  Provides:
   [Main] LKC - 1 frame fadeout to all selected items.lua
  About:
   Contains two actions:
   1 framein fade to all selected items
   1 frame fadeout to all selected items
]]

--[[
 * Changelog:
 * v1.0 (2021-07-13)
	+ First Version
]]


count = reaper.CountSelectedMediaItems(0)
for i = 0, count -1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", 1 / reaper.TimeMap_curFrameRate(0), 0, 0 )
end

reaper.UpdateArrange()