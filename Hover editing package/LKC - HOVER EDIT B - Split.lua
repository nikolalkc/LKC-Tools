--[[
  NoIndex: true
  About:
    Use this script to split items on mouse cursor position.
]]
OPERATION = "split"

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "lkc_hover_edit-fade_split.lua")
