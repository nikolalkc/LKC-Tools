--reaopen init setup
--v1.1 --Exe path logic added
--v1.0 --initial commit

function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

separator = [[/]]

info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]




function get_reaopen_id() 	
	local reaopen_id = nil
	resource_path =  reaper.GetResourcePath()
	kb_ini_path = resource_path..separator.."reaper-kb.ini"
	-- reaper.ShowConsoleMsg(kb_ini_path.."\n")
	local f = io.open(kb_ini_path,"r")

	if f ~= nil then
		for line in f:lines() do
			reaopen_id = string.match(line,"SCR %d %d (.-) \"Custom: ReaOpen.lua")
			if reaopen_id ~= nil then
				reaopen_id = "S&M_PROJACTION _"..reaopen_id
				-- reaper.ShowConsoleMsg(tostring(reaopen_id).."\n\n")
				break
			end
		end
		--error
		if reaopen_id == nil then
			reaper.ShowMessageBox("ReaOpen.lua not found in the list of actions!\nMake sure that you installed the package properly.","ReaOpen Setup",0)
		end
	--error	
	else 
		reaper.ShowMessageBox("Reading reaper-kb.ini error!","ReaOpen Setup",0)
	end
	
	f:close()
	return reaopen_id
end


function save_exe_path()
    -- print("High score: "..tostring(score))
    local file,err = io.open(script_path.."reaper_exe_path.txt",'w')
    if file then
        file:write(tostring(reaper.GetExePath()))
        file:close()
    else
        -- print("error:", err) -- not so hard?
        Msg("Error saving exe path!")
    end
end


function Main()
    save_exe_path()
	--load
	local template_project = script_path.."ReaOpen.rpp"
	local new_id = get_reaopen_id()
	local file = io.open(template_project,"r")
	local text = file:read("*all")
	file:close()

	
	go = string.match(text,"S&M_PROJACTION _%w*")
	
	if go then
		--change
		new_state = string.gsub(text,"S&M_PROJACTION _%w*", new_id)
		
		--save
		local f = io.open(template_project, "w")
		f:write(new_state)
		f:close()		
		
		reaper.ShowMessageBox("ReaOpen setup successful!\nHave fun!","LKC Tools",0)
	else
		reaper.ShowMessageBox("Something went wrong!\nOriginal ReaOpen.rpp file is corrupted.\nPlease reinstall the package or solve the problem manually.","ReaOpen Setup",0)
	end
end


Main()