--[[
  NoIndex: true
  About:
    Use this script to create fadeout to item under mouse cursor. Fadeout is created from mouse position to the end of item.
]]

OPERATION = "fadeout"


local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "lkc_hover_edit-fade_split.lua")