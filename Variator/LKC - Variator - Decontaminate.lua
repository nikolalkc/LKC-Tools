--[[
 Noindex: true
]]

function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end


--OS INFO
platform = reaper.GetOS()
if platform == "OSX64" or platform == "OSX32" or platform == "OSX" or platform  == "Other" or platform == "macOS-arm64" then
    separator = [[/]]
else
    separator = [[\]]     --win
end

-- SAVE UTILITIES
local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]

local bin="x64"
if platform == "Win32" or platform == "OSX32" then bin="x86" end

loadfile(script_path .. "Data" .. separator .. "variator_mutations.lua")() --UCITAVANJE MUTA table-a

function Main()
	reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    MUTA.Decontaminate()
    
    reaper.Undo_EndBlock("LKC - Variator - Decontaminate", -1) -- End of the undo block. Leave it at the bottom of your main function.
    reaper.UpdateArrange()
    reaper.PreventUIRefresh(-1)
end



--main
Main()