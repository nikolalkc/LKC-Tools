--[[
  NoIndex: true
  About:
    Use this script to create fadein on item under mouse cursor. Fadein is created from start of item to mouse cursor position.
]]
OPERATION = "fadein"


local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "lkc_hover_edit-fade_split.lua")