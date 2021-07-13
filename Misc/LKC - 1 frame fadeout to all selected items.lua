--[[
  NoIndex: true
]]


count = reaper.CountSelectedMediaItems(0)
for i = 0, count -1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", 1 / reaper.TimeMap_curFrameRate(0), 0, 0 )
end

reaper.UpdateArrange()