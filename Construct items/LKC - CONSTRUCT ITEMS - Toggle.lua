--[[
 ReaScript Name: Construct Items
 Author: LKC
 REAPER: 5+
 Version: 1.55
 Provides:
  [Main] LKC - CONSTRUCT ITEMS - Toggle (channel aware).lua
  [Main] LKC - CONSTRUCT ITEMS - Toggle (automation supported - slow).lua
  [data] constructed.png > toolbar_icons/constructed.png
 About:
  This is a simulation of Nuendo's DIRECT OFFLINE PROCESSING. This script renders selected items to new takes and puts all item fx offline.
  If that operation has already been done then it restores original items length and fades,
  deletes rendered take from project and puts all items fx back online.
  NOTE: It works only with items that have one or two takes.
]]

--[[
 * Changelog:
 * v1.55 (2019-06-21)
  + Added stripes background for constructed items.
 * v1.54 (2019-05-10)
  + Automation aware is separate script
 * v1.53 (2019-05-10)
  + Reverted to previous version (no item envelopes supported, but quicker rendering)
 * v1.52 (2019-03-21)
  + Fixed temp track creation error
 * v1.51 (2018-06-22)
  + New package name
 * v1.50 (2018-06-18)
  + Added autoincrease_channel_count script
 * v1.41 (2018-06-18)
  + Version changelog fix
 * v1.40 (2018-06-18)
  + Optimized rendering, much faster
  + Time selection is determening the length of tail for all items relative
 * v1.32 (2018-04-03)
  + Volume saving and support added
 * v1.31 (2018-04-03)
  + New description
 * v1.3 (2018-04-03)
   + Rendered item have stretch markers as visual indicators
 * v1.2 (2018-04-03)
  + Redefined rendering logic to include fades and time selection
 * v1.1 (2018-04-02)
  + Preserve source type when rendering (added)
  + Delete active take and source file on restore (added)
 * v1.0 (2018-02-26)
  + Initial Commit
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
		
		-- --create temp track -- OLD, DEPRECATED
		-- reaper.Main_OnCommand(40297,0) --unselect all tracks
		-- reaper.SetTrackSelected( track, true )
		-- reaper.Main_OnCommand(40001,0) --insert new track
		-- local temp_track =  reaper.GetSelectedTrack( 0, 0 )
		-- reaper.Main_OnCommand(40058,0) --paste item to new track
		
		--create temp track -- NEW, SEXY
		reaper.Main_OnCommand(40297,0) --unselect all tracks
		reaper.InsertTrackAtIndex( track_idx, false )
		temp_track = reaper.GetTrack( 0, track_idx )
		-- reaper.ShowMessageBox("Track Inserted","DEBUG",0)
		midi_item = reaper.CreateNewMIDIItemInProj( temp_track, pos, pos+0.1, false )
		-- reaper.ShowMessageBox("Midi Inserted","DEBUG",0)
		
		--convert midi item to original item
		reaper.Main_OnCommand(40289,0) --unselect all items
		retval, str = reaper.GetItemStateChunk( item, "", false )
		reaper.SetMediaItemSelected( midi_item, true )
		reaper.SetItemStateChunk( midi_item, str, false )
		
		reaper.Main_OnCommand(40297,0) --unselect all tracks
		reaper.SetTrackSelected( temp_track, true )
		reaper.Main_OnCommand(40421,0) -- Item: Select all items in track
		-- reaper.ShowMessageBox("Item copied","DEBUG",0)
		
		if autoincrease_channel_count ~= nil then
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN2"),0) --SWS/S&M: cut fx chain from selected items
			reaper.Main_OnCommand(40606,0) --Item: Glue items, including leading fade-in and trailing fade-out
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN8"),0) --SWS/S&M: paste fx chain to selected items
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_ONLINE"),0) --fx online
			reaper.Main_OnCommand(42009,0) --Item: Glue items (auto-increase channel count with take FX)
		else
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_ONLINE"),0) --fx online
			reaper.Main_OnCommand(40606,0) --Item: Glue items, including leading fade-in and trailing fade-out
		end
		
		
		
		
		
		--select original item
		reaper.SetMediaItemSelected( item, true )
		
		reaper.Main_OnCommand(40438,0) --Take: Implode items across tracks into takes
		reaper.Main_OnCommand(41193,0) --Item: Remove fade in and fade out
		reaper.Main_OnCommand(40125,0) --Take: Switch items to next take
		
		local new_item  = reaper.GetSelectedMediaItem(0,0)
		
		reaper.DeleteTrack( temp_track )
		--=============================================================================
		
		-- OLD DEPRECATED
		-- reaper.Main_OnCommand(40698,0) --copy items
		-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) --SWS/S&M: Set all take FX offline for selected items
		-- reaper.Main_OnCommand(40297,0) --unselect all tracks
		-- reaper.SetTrackSelected( track, true )
		-- reaper.Main_OnCommand(40001,0) --insert new track
		-- local temp_track =  reaper.GetSelectedTrack( 0, 0 )
		-- reaper.Main_OnCommand(40058,0) --paste item to new track
		-- local fx_count = reaper.TakeFX_GetCount( take )
		-- if fx_count > 0 then 
		-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN2"),0) --SWS/S&M: cut fx chain from selected items
		-- end
		-- reaper.Main_OnCommand(40606,0) --Item: Glue items, including leading fade-in and trailing fade-out
		-- if fx_count > 0 then 
		-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_COPYFXCHAIN8"),0) --SWS/S&M: paste fx chain to selected items
		-- end
		-- reaper.Main_OnCommand(41993,0) --Item: Apply track/take FX to items (multichannel output) -- temp track is empty so it will not have track fx
		-- reaper.Main_OnCommand(40126,0) --Take: Switch items to previous take
		
		-- --NO UNDO
		-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_DELTAKEANDFILE4"),0) --SWS/S&M: Delete active take and source file in selected items (no undo)
		
		-- --UNDO, BUT CLEAN PROJECT MANUALLY
		-- -- reaper.Main_OnCommand(40129,0) --Take: Delete active take from items
		
		-- reaper.SetMediaItemSelected( item, true )
		-- reaper.Main_OnCommand(40438,0) --Take: Implode items across tracks into takes
		-- reaper.Main_OnCommand(40125,0) --Take: Switch items to next take
		-- reaper.Main_OnCommand(41193,0) --Item: Remove fade in and fade out
		-- reaper.DeleteTrack( temp_track )
		
		local start_time, end_time =  reaper.GetSet_LoopTimeRange2( 0, false, false, 0, 0, false)
		local delta_time = end_time - start_time
		if delta_time > 0 then
			reaper.Main_OnCommand(41320,0) --Item: Move items to time selection, trim/loop to fit
		end
		local new_length = reaper.GetMediaItemInfo_Value( new_item, "D_LENGTH" )
		local new_take =  reaper.GetActiveTake( new_item )
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
reaper.UpdateArrange()
reaper.Undo_EndBlock("LKC - CONSTRUCT ITEMS - Toggle", -1)



