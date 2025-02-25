function Msg(string) reaper.ShowConsoleMsg(string .. "\n") end


-- CSV PARSER
function ParseCSVLine(line, sep)
    local res = {}
    local pos = 1
    sep = sep or ','
    while true do
        local c = string.sub(line, pos, pos)
        if (c == "") then break end
        if (c == '"') then
            -- quoted value (ignore separator within)
            local txt = ""
            repeat
                local startp, endp = string.find(line, '^%b""', pos)
                txt = txt .. string.sub(line, startp + 1, endp - 1)
                pos = endp + 1
                c = string.sub(line, pos, pos)
                if (c == '"') then txt = txt .. '"' end
                -- check first char AFTER quoted string, if it is another
                -- quoted string without separator, then append it
                -- this is the way to "escape" the quote char in a quote. example:
                --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
            until (c ~= '"')
            table.insert(res, txt)
            assert(c == sep or c == "")
            pos = pos + 1
        else
            -- no quotes used, just look for the first separator
            local startp, endp = string.find(line, sep, pos)
            if (startp) then
                table.insert(res, string.sub(line, pos, startp - 1))
                pos = endp + 1
            else
                -- no separator found -> use rest of string and terminate
                table.insert(res, string.sub(line, pos))
                break
            end
        end
    end
    return res
end




extstate_relpaths = reaper.GetExtState("ReaOpen", "relative_paths")
active_root = reaper.GetExtState("ReaOpen","chosen_root")

retval, retvals_csv = reaper.GetUserInputs("ReaOpen - Relative Path Setup", 6, "Relative path substring::extrawidth=300,Root 1:,Root 2:,Root 3:,Root 4:,Active Root:", extstate_relpaths.. "," .. active_root)

if retval then
    if retvals_csv == ",,,," then retvals_csv = "" end
    reaper.SetExtState("ReaOpen", "relative_paths", retvals_csv, true)
    
    relative_substring = ""
    parsed = ParseCSVLine(retvals_csv,",")
    for k,v in pairs(parsed) do
        if v ~= "" then
            -- Msg(k .. " : ".. v)
            if k == 6 then
                reaper.SetExtState("ReaOpen", "chosen_root", v, false)
            end
        end
    end
    -- result = string.match([[D:\P4\main_workspace_milan\AudioSource\Reaper\Characters\SoldierMovement\SoldierMovement.rpp]],relative_substring)
    -- Msg("rezultat:" .. result)
    -- Msg("final:" .. root .. result)

end



