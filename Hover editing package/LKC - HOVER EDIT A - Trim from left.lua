--[[
  NoIndex: true
]]

--Trim item from left side and preserve fadein
reaper.Undo_BeginBlock()

OPERATION = "left_trim"
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "lkc_hover_edit-trim.lua")

reaper.Undo_EndBlock("LKC - HOVER EDIT - Trim from left", -1)