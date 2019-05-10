autoincrease_channel_count = true


local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
dofile(script_path .. "LKC - CONSTRUCT ITEMS - Toggle.lua")