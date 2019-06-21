--[[
  Noindex: true
]]


function Msg(param)
	reaper.ShowConsoleMsg(tostring(param).."\n")
end
--take item info
number_of_takes_in_first_item= nil
selected_count = reaper.CountSelectedMediaItems(0)
selection_valid = nil
selected_items = {}
idx = 0

function RenderItemsAndSetFXOffline()
	for i = 0, selected_count -1 do 
		selected_items[idx] = reaper.GetSelectedMediaItem(0,i)
		idx = idx + 1
	end
	
	--DEPRECATED
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SAVETIME5"),0) --save time selection slot 5
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS4"),0) --SWS/S&M: Close all FX chain windows
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS3"),0) --SWS/S&M: Close all floating FX windows
	
	selectionStart, selectionEnd =  reaper.GetSet_LoopTimeRange(0,0,0,0,0)
	selectionLength = selectionEnd - selectionStart
	res_path =  reaper.GetResourcePath()	
	for i = 0, idx - 1 do
		reaper.Main_OnCommand(40289,0) --unselect all items
		
		--DEPRECATED
		-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_RESTTIME5"),0) --restore time selection slot 5
		
		local item = selected_items[i]
		local take = reaper.GetMediaItemTake(item, 0)
		local track = reaper.GetMediaItem_Track( item )
		local track_idx =  reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER")
		local pos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
		local length = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
		local fadein = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
		local fadeout = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" )
		local item_volume = reaper.GetMediaItemInfo_Value(item, "D_VOL")
		
		--write parameters to notes
		reaper.BR_SetMediaItemImageResource( item, res_path.."\\Data\\track_icons\\constructed.png", 3 )
		local note = length..[[-]]..fadein..[[-]]..fadeout..[[-]]..item_volume
		reaper.ULT_SetMediaItemNote( item, note)
		--retval, offsOut, lenOut, revOut reaper.PCM_Source_GetSectionInfo( src )
		
		
		reaper.SetMediaItemSelected( item, true )
		reaper.Main_OnCommand(41173,0) --move cursor to start of items
		
		--DEPRECATED
		-- reaper.Main_OnCommand(40222,0) --set start loop point to selected item start
		
		local item_end = pos + length + selectionLength
		reaper.GetSet_LoopTimeRange(1,1,pos,item_end,0)
		
		--NEW AND SEXY (ONLY ONE GLUE)================================================================
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) --SWS/S&M: Set all take FX offline for selected items
		reaper.Main_OnCommand(40698,0) --copy items
		
		
		--create temp track -- NEW, SEXY
		reaper.Main_OnCommand(40297,0) --unselect all tracks
		-- reaper.ShowMessageBox("All tracks unselected","DEBUG",0)
		local track = reaper.GetMediaItem_Track( item )
		reaper.SetTrackSelected( track, true )
		reaper.Main_OnCommand(40914,0) --set first track in selection as last touched
		reaper.Main_OnCommand(40001,0)-- insert new track
		temp_track =  reaper.GetSelectedTrack( 0, 0 )
		-- reaper.ShowMessageBox("Track Inserted","DEBUG",0)
		reaper.Main_OnCommand(40698,0) --copy items
		reaper.Main_OnCommand(40058,0) --paste items
		temp_item = reaper.GetSelectedMediaItem(0,0)
		
		-- reaper.ShowMessageBox("Item copied","DEBUG",0)
		autoincrease_channel_count = true -- FORCE THIS FOR THIS SCRIPT VERSION
		if autoincrease_channel_count ~= nil then
			local original_position =  reaper.GetMediaItemInfo_Value( temp_item, "D_POSITION" )
			local temp_item_length =  reaper.GetMediaItemInfo_Value( temp_item, "D_LENGTH" )
			reaper.SetMediaItemInfo_Value( temp_item, "D_POSITION", 0 ) --move item to start of project
			temp_time_selection = temp_item_length + selectionLength
			reaper.GetSet_LoopTimeRange(1,1,0,temp_time_selection,0)
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN2"),0) --SWS/S&M: cut fx chain from selected items
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN10"),0) --SWS/S&M: paste fx chain to selected tracks	
			reaper.Main_OnCommand(40536,0) --fx online for selected tracks 	
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWRENDERSTEREOSMART"),0) -- render STEREO in time selection
			reaper.Main_OnCommand(40421,0) -- select all items in track
			rendered_item = reaper.GetSelectedMediaItem(0,0)
			reaper.SetMediaItemInfo_Value( rendered_item, "D_POSITION", original_position ) --move item to original position
			reaper.DeleteTrack( temp_track )
			reaper.SetMediaItemSelected( item, true )
			reaper.Main_OnCommand(40438,0) --Take: Implode items across tracks into takes
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELECTLASTTAKEOFITEMS"),0)--select last take in item
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_RESETITEMLENMEDOFFS"),0) --reset item length
			reaper.Main_OnCommand(40005,0) --remove stem track
			reaper.Main_OnCommand(41193,0) --remove fades
			
		else --unused for this version of script
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_ONLINE"),0) --fx online
			reaper.Main_OnCommand(40606,0) --Item: Glue items, including leading fade-in and trailing fade-out
		end
		
		
		
		

		--=============================================================================
		local new_length = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
		reaper.Main_OnCommand(41923,0) -- reset item volume to 0db
		
		
		
		
		
		
		
		
	end
	
	
	reaper.Main_OnCommand(40635,0) --remove time selection
end

function RestoreItemsAndSetFXOnline()
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		note =  reaper.ULT_GetMediaItemNote( item )
		reaper.BR_SetMediaItemImageResource( item, "", 3 )
		reaper.ULT_SetMediaItemNote( item, note)
		--retval, offsOut, lenOut, revOut reaper.PCM_Source_GetSectionInfo( src )
		
		local length, fadein, fadeout, volume = note:match("([^,]+)-([^,]+)-([^,]+)-([^,]+)")
		-- Msg(length)
		-- Msg(fadein)
		-- Msg(fadeout)
		-- Msg(volume)
		
		reaper.SetMediaItemInfo_Value( item, "D_LENGTH", length)
		reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", fadein)
		reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", fadeout)
		reaper.SetMediaItemInfo_Value( item, "D_VOL", volume)
		reaper.ULT_SetMediaItemNote( item, "")
	end
	
	--NO UNDO
	-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_DELTAKEANDFILE4"),0) --SWS/S&M: Delete active take and source file in selected items (no undo)
	
	--UNDO, BUT CLEAN PROJECT MANUALLY
	reaper.Main_OnCommand(40129,0) --Take: Delete active take from items
	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_ONLINE"),0) --all take fx online
	--reaper.Main_OnCommand(40638,0) --show item fx
end


if selected_count > 1 then
	selection_valid = true
	for i = 0, selected_count - 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		if number_of_takes_in_first_item == nil then
			number_of_takes_in_first_item = reaper.CountTakes( item )
		else
			local cur_take_number = reaper.CountTakes(item)
			if number_of_takes_in_first_item ~= cur_take_number then
				Msg("ERROR: THIS IS NOT GOING TO WORK, ITEMS DIFFER IN TAKE NUMBERS")
				selection_valid = false
				break
			else 
				if number_of_takes_in_first_item > 2 then 
					Msg("ERROR: THIS SCRIPT WORKS JUST WITH ITEMS THAT HAVE ONE(1) OR TWO(2) TAKES!")
					selection_valid = false
					break
				end
			end
		end
	end
else
	if selected_count == 1 then 
		local item = reaper.GetSelectedMediaItem(0,0)
		number_of_takes_in_first_item = reaper.CountTakes(item)
		if number_of_takes_in_first_item ~= nil then
			if number_of_takes_in_first_item < 3 then
				selection_valid = true
			else 
				Msg("ERROR: THIS SCRIPT WORKS JUST WITH ITEMS THAT HAVE ONE(1) OR TWO(2) TAKES!")
				selection_valid = false
			end
		end
		-- Msg("only one item selected, check what to do")
	else
		Msg("ERROR: SELECT AT LEAST ONE ITEM")
	end
	
end




--MAIN
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
-- Msg(number_of_takes_in_first_item)
if selection_valid then
	if number_of_takes_in_first_item == 1 then
		-- Msg("render items and put sfx offline")
		RenderItemsAndSetFXOffline()
	else
		if number_of_takes_in_first_item == 2 then
			-- Msg("restore previous state and put sfx online")
			RestoreItemsAndSetFXOnline()
		end
	end
else 
	Msg("SELECTION NOT VALID")
end
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("LKC - CONSTRUCT ITEMS - Toggle", -1)



