--[[
  NoIndex: true
]]

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
string2 =[[")
reaper.SetToggleCommandState(0, command, hover_editing)]]

--OS INFO
platform = reaper.GetOS()
separator = [[/]]


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
 
--used to get GUID of "Toggle Hovering" action
function get_script_guid(input) 	
	local script_id = nil
	resource_path =  reaper.GetResourcePath()
	kb_ini_path = resource_path..separator.."reaper-kb.ini"
	-- reaper.ShowConsoleMsg(kb_ini_path.."\n")
	local f = io.open(kb_ini_path,"r")

	if f ~= nil then
        for line in f:lines() do
            script_id = string.match(line,input  )
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

function Main()
    resource_path = reaper.GetResourcePath()
	startup_file = resource_path..separator..[[Scripts]]..separator..[[__startup.lua]]
	script_to_find = "SCR %d %d (.-) \"Custom: LKC (-) HOVER EDIT (-) Toggle hovering.lua"  -- (-) is a way of escaping - character
    script_id = get_script_guid(script_to_find)
    
    if exists(startup_file) then  --check and modify existing startup file if needed
        file = io.open(startup_file)
        content = file:read("*all")    
        -- Msg(content)

		--create pattern to be used to find hover editing code block inside startup lua file
		--  \n is used for newlines
		--  %( is used to escape (
		-- %) is used to escape )
		-- \" is used to escape "
		-- s1 == string1, but with escapes
		-- s2 == string2, but with escapes
		local s1 = "--HOVER EDITING\nhover_editing = tonumber%(reaper.GetExtState%(\"LKC_TOOLS\",\"hover_editing_state\"%)%)\nif hover_editing == nil then hover_editing = 1 end\ncommand = reaper.NamedCommandLookup%(\"_"
		local s2 = "\"%)\nreaper.SetToggleCommandState%(0, command, hover_editing%)"
		local pattern = s1..script_id..s2 --this should be final pattern

		--check if already installed
        local section = string.match(content, s1.."(%w+)"..s2)
		if section ~= nil then -- if code block found
			if section == script_id then -- if code block is ok
				reaper.ShowMessageBox("Script already installed.","LKC - Hover editing",0)
			else --if code block is incorrect
				local new_content = string.gsub(content,section,script_id)
				file:close()
				local f = io.open(startup_file,"w")
				f:write(new_content)
				reaper.ShowMessageBox("Script ID updated.\nPlease restart REAPER.","LKC - Hover editing",0)
			end
            
        else--if code block not found then append existing file
            file:close()
            local f = io.open(startup_file,"a")
            f:write(string1..script_id..string2)
            reaper.ShowMessageBox("Script Installed.\nStartup file appended.\nPlease restart REAPER.","LKC - Hover editing",0)
        end
    else --create file if it doesn't exist
        local file = io.open(startup_file, "w")
        file:write(string1..script_id..string2)
        reaper.ShowMessageBox("Hover editing toggle script installed.\nPlease restart REAPER.","LKC - Hover editing",0)
    end
end

Main()
