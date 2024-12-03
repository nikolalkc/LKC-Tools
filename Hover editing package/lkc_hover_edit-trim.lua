--[[
  NoIndex: true
]]
reaper.PreventUIRefresh( 1 )

function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--save item selection
count = reaper.CountSelectedMediaItems( 0 )
items = {}
for i = 0, count-1 do
	items[i] =  reaper.GetSelectedMediaItem( 0, i )
end

--for flying cursor (no need for clicking)
hover_editing = tonumber(reaper.GetExtState("LKC_TOOLS","hover_editing_state"))
if hover_editing == nil then hover_editing = 1 end

function Main()
	if hover_editing == 1 then
		--for flying cursor (no need for clicking)
		--reaper.Main_OnCommand(40514,0) --View: Move edit cursor to mouse cursor (no snapping)
		reaper.Main_OnCommand(40513,0) --View: Move edit cursor to mouse cursor (snapping)
		
		reaper.Main_OnCommand(40528,0) --Item: Select item under mouse cursor
	end

	
	--compare new selection with original
	selected_item = reaper.GetSelectedMediaItem(0,0)
	if selected_item ~= nil then
		for i = 0, #items do
			if items[i] == selected_item then
				-- Msg("already in selection")
				already_in_selection = true
				break
			end
		end
		-- Msg("comparing done")
	end
	--select other items if needed
	if already_in_selection then
		for i = 0, #items do
			reaper.SetMediaItemSelected( items[i], true )
		end
	end
	
	--recreate selection array
	count = reaper.CountSelectedMediaItems( 0 )
	items = {}
	for i = 0, count-1 do
		items[i] =  reaper.GetSelectedMediaItem( 0, i )
	end
    
    trim_content_state = reaper.GetToggleCommandState( 41117 )
    -- Msg(trim_content_state)
    if trim_content_state == 1 then
        reaper.Main_OnCommand(41117,0) -- trim content off
        turn_back_on_trim_content = 1
    end
    --do the edits for complete array
	for i = 0 , #items do
		reaper.Main_OnCommand(40289,0) --unselect all items
		local selected_item = items[i]
		if selected_item ~= nil then
			reaper.SetMediaItemSelected( items[i], true )

			--get stuff
			local item_pos = reaper.GetMediaItemInfo_Value(selected_item,"D_POSITION")
			local fadein_len = reaper.GetMediaItemInfo_Value(selected_item,"D_FADEINLEN")
			local fadeout_len = reaper.GetMediaItemInfo_Value(selected_item,"D_FADEOUTLEN")
			local item_len = reaper.GetMediaItemInfo_Value(selected_item,"D_LENGTH")
			local cursor_pos =  reaper.GetCursorPosition()

			--calculate stuff
			local item_end = item_pos + item_len
			
			
			
			if cursor_pos > item_pos and cursor_pos < item_end then
				--Msg("edit")
				local cursor_delta = cursor_pos - item_pos
				local cursor_end_delta = item_end - cursor_pos


				--S SCRIPT================================================================================
				if OPERATION == "right_trim" then
					--do stuff
					--if mouse is at fadeout part of item
					-- Msg("Fadeout:"..fadeout_len.."   Cursor Delta:".. cursor_end_delta)
					if fadeout_len > cursor_end_delta then
						-- Msg("fadeout")
						local new_fadeout_time = fadeout_len - cursor_end_delta
						reaper.SetMediaItemInfo_Value(selected_item,"D_FADEOUTLEN",new_fadeout_time)
						reaper.Main_OnCommand(41311, 0) --Trim right edge of item to edit cursor
					else
						--if mouse is at fadein part of item
						if fadein_len > cursor_delta then
							-- Msg("fadein")
							reaper.Main_OnCommand(40509, 0) --fadein item to cursor
						else --if at middle of item
							-- Msg("trim")
							reaper.SetMediaItemInfo_Value(selected_item,"D_FADEOUTLEN",0)
							reaper.Main_OnCommand(41311, 0) --Trim right edge of item to edit cursor
						end
					end
				--A SCRIPT==============================================================================
				elseif OPERATION == "left_trim" then
					if fadein_len > cursor_delta then
						--Msg("fadein")
						new_fadein_time = fadein_len - cursor_delta
						reaper.SetMediaItemInfo_Value(selected_item,"D_FADEINLEN",new_fadein_time)
						reaper.Main_OnCommand(41305, 0) --Trim left edge of item to edit cursor
					else
						--mouse cursor at fadeout partzzz
						if fadeout_len > cursor_end_delta then
							--Msg("fadeout")
							reaper.Main_OnCommand(40510, 0) --Item: Fade items out from cursor
	
						else --mouse cursor at middle of item
							--Msg("trim")
							reaper.SetMediaItemInfo_Value(selected_item,"D_FADEINLEN",0)
							reaper.Main_OnCommand(41305, 0) --Trim left edge of item to edit cursor
						end
					end
                end
			end
		end
    end

    if turn_back_on_trim_content == 1 then
        reaper.Main_OnCommand(41117,0)  --trim content on
    end

	--select all items again
	for i = 0 , #items do
		if items[i] ~= nil then
			reaper.SetMediaItemSelected( items[i], true )
		end
	end
end
Main()
reaper.PreventUIRefresh( -1 )
reaper.UpdateArrange()
