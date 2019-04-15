--[[
  NoIndex: true
]]
reaper.Undo_BeginBlock()
hover_editing = tonumber(reaper.GetExtState("LKC_TOOLS","hover_editing_state"))
if hover_editing == nil then hover_editing = 1 end

if hover_editing == 1 then
	--reaper.Main_OnCommand(40514,0) --View: Move edit cursor to mouse cursor (no snapping)
	reaper.Main_OnCommand(40513,0) --View: Move edit cursor to mouse cursor (snapping)
end
if OPERATION == "right_untrim" then
	reaper.Main_OnCommand(41311,0) --Item edit: Trim right edge of item to edit cursor
	reaper.Undo_EndBlock("LKC - HOVER EDIT - Untrim right", -1)
elseif OPERATION == "left_untrim" then 
	reaper.Main_OnCommand(41305,0) --Item edit: Trim left edge of item to edit cursor
	reaper.Undo_EndBlock("LKC - HOVER EDIT - Untrim left", -1)
end