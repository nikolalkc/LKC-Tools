--[[
  NoIndex: true
  About:
    Cuts right part of item where mouse cursor is positioned and shortens lenth of fadeout, like Pro Tools
    Instructions: Hover your mouse over item and run the script
]]
reaper.Undo_BeginBlock()

OPERATION = "right_trim"
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "lkc_hover_edit-trim.lua")

reaper.Undo_EndBlock("LKC - HOVER EDIT - Trim from right", -1)