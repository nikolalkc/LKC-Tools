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

hover_editing = tonumber(reaper.GetExtState("LKC_TOOLS","hover_editing_state"))
if hover_editing == nil then hover_editing = 1 end


reaper.Undo_BeginBlock()

if hover_editing == 1 then
	--reaper.Main_OnCommand(40514,0) --View: Move edit cursor to mouse cursor (no snapping)
	reaper.Main_OnCommand(40513,0) --View: Move edit cursor to mouse cursor (snapping)
	
	reaper.Main_OnCommand(40528,0) --Item: Select item under mouse cursor
	

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
end

if OPERATION == "fadeout" then
	reaper.Main_OnCommand(40510,0)--Item: Fade items out from cursor
	reaper.Undo_EndBlock("LKC - HOVER EDIT - Fadeout", -1)
elseif OPERATION == "fadein" then
	reaper.Main_OnCommand(40509,0)--Item: Fade items in to cursor
	reaper.Undo_EndBlock("LKC - HOVER EDIT - Fadein", -1)
elseif OPERATION == "split" then
	reaper.Main_OnCommand(40012,0) --Item: Split items at edit or play cursor
	reaper.Undo_EndBlock("LKC - HOVER EDIT - Split", -1)
end


reaper.PreventUIRefresh( -1 )
reaper.UpdateArrange()