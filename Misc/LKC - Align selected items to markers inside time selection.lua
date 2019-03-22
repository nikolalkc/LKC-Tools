--[[
  ReaScript Name: Align selected items to markers inside time selection
  Author: LKC
  Version: 1.0
  About:
    Create time selection which includes some markers.
    Select some items.
    Run the action.
]]

--[[
 * Changelog:
 * v1.0 (2019-03-22)
	+ Initial Release
]]


function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end


--init
idx = 0 
marker_positions = {}
items = {}


--create items array
count  =  reaper.CountSelectedMediaItems(0)
for i = 0, count-1 do
  items[i] =  reaper.GetSelectedMediaItem( 0, i )
end

--check time selection
startTime, endTime = reaper.GetSet_LoopTimeRange( false, false, 0, 0, false )

--check number of markers
retval, num_markers, num_regions = reaper.CountProjectMarkers( 0 )
all_markers = num_markers + num_regions


if endTime - startTime > 0 and #items > 0 then
  for i = 0, all_markers - 1 do

    local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers( i )
    
    if isrgn == false then 
      
      if pos >= startTime then
        if pos <= endTime then
            -- Msg(pos)
            marker_positions[idx] = pos
            idx = idx + 1
        end
      end
    end
  end

  if #marker_positions > 0 then
    for i = 0, #marker_positions do
      local item = items[i]
      if item ~= nil then
        local snap_offset = reaper.GetMediaItemInfo_Value( item, "D_SNAPOFFSET")
        reaper.SetMediaItemInfo_Value( item, "D_POSITION", marker_positions[i]- snap_offset)
      end
    end
  end

reaper.UpdateArrange()
end