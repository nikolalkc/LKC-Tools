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





function LoadExState(formula)
    if formula == nil then formula= '' end
    states = {}
    values = {}
    for i = 1 , #MUTA.PROPERTIES do
        local value = tonumber(reaper.GetExtState("LKC_VARIATOR",MUTA.PROPERTIES[i]..formula))
        values[i] = value


        local state = reaper.GetExtState("LKC_VARIATOR",MUTA.PROPERTIES[i].."_checkbox"..formula)
        -- Msg(PROPERTIES[i] .. ":" .. state)
        if state == 'true' then state = true
        else state = false end
        states[i] = state

    end   

    return states,values
end



function DoMutate()
	reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    local states,values = LoadExState(1)
    MUTA.Mutate(MUTA.ConvertChecklistArrayToDict(states),MUTA.ConvertSlidersArrayToDict(values))
    
    reaper.Undo_EndBlock("LKC - Variator - Mutate using formula 1", -1) -- End of the undo block. Leave it at the bottom of your main function.
    reaper.UpdateArrange()
    reaper.PreventUIRefresh(-1)
end



--main
DoMutate()