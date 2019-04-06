--[[
  NoIndex: true
]]
OPERATION = "right_untrim"


local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "lkc_hover_edit-untrim.lua")