--[[
  ReaScript Name: Lawrence randomizer
  Author: LKC
  Version: 1.1
  About:
    This script randomizes selected items' positions inside the time selection or region.

]]

--[[
 * Changelog:
 * v1.1 (2020-05-11)
	+ Disabled offset randomization
 * v1.0 (2020-05-11)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----


function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

function main()
    
    
    sel_count = reaper.CountSelectedMediaItems(0)
    
    if sel_count > 0 then
        
        for i = 0 , sel_count -1 do
            local start_time, end_time = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
            local length = end_time - start_time

            local item = reaper.GetSelectedMediaItem(0, i)
            local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

            if length == 0 or length == nil then
                -- Msg("LENGTH:"..length)
                local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                local markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0, pos)
                local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color = reaper.EnumProjectMarkers3( 0, regionidx )
                if isrgn then
                    start_time = pos
                    end_time = rgnend
                    length = end_time - start_time
                else
                    break
                end
            end



            local potential_item_position_range = 0
            potential_item_position_range = length - item_len
            
            if item_len > length then
                reaper.SetMediaItemInfo_Value(item,"D_LENGTH",length)
                item_len = length
                reaper.SetMediaItemInfo_Value( item, "D_POSITION", start_time )
            end


            local random_pos = math.random()*potential_item_position_range
            reaper.SetMediaItemInfo_Value( item, "D_POSITION", start_time + random_pos )


            local take = reaper.GetActiveTake(item)
            local source = reaper.GetMediaItemTake_Source( take )
            local audio_duration, lengthIsQN = reaper.GetMediaSourceLength( source )

            -- random_offset = math.random() * (audio_duration  - item_len)
            -- reaper.SetMediaItemTakeInfo_Value( take, "D_STARTOFFS", random_offset )

            
        end


    end

end


reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock() 

main()

reaper.Undo_EndBlock("LKC - Lawrence Randomizer", -1) 

reaper.UpdateArrange()

reaper.PreventUIRefresh(-1)