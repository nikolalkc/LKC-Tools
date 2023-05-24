--[[
	Noindex: true
]]	

function OpenURL(url)
  local OS = reaper.GetOS()
  if OS == "OSX32" or OS == "OSX64" or OS == "macOS-arm64" then
    os.execute('open "" "' .. url .. '"')
  else
    os.execute('start "" "' .. url .. '"')
  end
end

local info = debug.getinfo(1,'S');
script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
OpenURL(script_path)

