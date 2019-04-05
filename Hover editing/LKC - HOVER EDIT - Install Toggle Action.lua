--UTILITIES
function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

--function lines to be used for startup file
string1 = [[
--HOVER EDITING
hover_editing = tonumber(reaper.GetExtState("LKC_TOOLS","hover_editing_state"))
if hover_editing == nil then hover_editing = 1 end
command = reaper.NamedCommandLookup("_]]
string2 = [[")
reaper.SetToggleCommandState(0, command, hover_editing)
]]


--OS INFO
platform = reaper.GetOS()
if platform == "OSX64" or platform == "OSX32" or platform == "OSX" or platform == "Other" then
	separator = [[/]]
else
	separator = [[\]]	--win
end

--check if file or directory exists
function exists(file)
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          -- Permission denied, but it exists
          return true
       end
    end
    return ok, err
 end
 

--used to get GUID of action toggle action call
function get_hover_toogle_id() 	
	local script_id = nil
	resource_path =  reaper.GetResourcePath()
	kb_ini_path = resource_path..separator.."reaper-kb.ini"
	-- reaper.ShowConsoleMsg(kb_ini_path.."\n")
	local f = io.open(kb_ini_path,"r")

	if f ~= nil then
        for line in f:lines() do
            -- script_id = string.match(line,"SCR %d %d (.-) \"Custom: LKC - HOVER EDIT"  )
            script_id = string.match(line,"SCR %d %d (.-) \"Custom: LKC (-) HOVER EDIT (-) TOGGLE HOVER MODE.lua"  ) -- (-) is a way of escaping - character
            if script_id ~= nil then
				-- reaper.ShowConsoleMsg(tostring(script_id).."\n\n")
				break
			end
		end
		--error
		if script_id == nil then
			reaper.ShowMessageBox("Not found.","Setup",0)
		end
	--error	
	else 
		reaper.ShowMessageBox("Reading reaper-kb.ini error!","Setup",0)
	end
	
	f:close()
	return script_id
end

--OS INFO
platform = reaper.GetOS()
if platform == "OSX64" or platform == "OSX32" or platform == "OSX" or platform == "Other" then
	separator = [[/]]
else
	separator = [[\]]	--win
end





function Main()
    resource_path = reaper.GetResourcePath()
    startup_file = resource_path..separator..[[Scripts]]..separator..[[__startup.lua]]
    script_id = get_hover_toogle_id()
    
    if exists(startup_file) then  --append existing file
        -- reaper.ShowMessageBox("File already exists","LKC - Hover editing",0)
        file = io.open(startup_file)
        content = file:read("*all")    
        -- Msg(content)
        --check if already installed
        local section = string.match(content, "--HOVER EDITING\nhover_editing ="  ) 
        if section ~= nil then
            reaper.ShowMessageBox("Script already installed.","LKC - Hover editing",0)
        else--append existing file
            file:close()
            local f = io.open(startup_file,"a")
            f:write("\n"..string1..script_id..string2)
            reaper.ShowMessageBox("Script Installed.\nStartup file appended.\nPlease restart REAPER.","LKC - Hover editing",0)
        end
    else --create file
        local file = io.open(startup_file, "w")
        file:write(string1..script_id..string2)
        reaper.ShowMessageBox("Hover editing toggle script installed.\nPlease restart REAPER.","LKC - Hover editing",0)
    end
end




Main()


