--[[
  ReaScript Name: LKC Perforce Scripts
  Author: LKC
  REAPER: 7+
  Version: 1.0
  Provides:
   [Main] LKC - P4 Revert unchanged files.lua
   [Main] LKC - P4 Reconcile current project folder.lua
   [Main] LKC - P4 Checkout current project folder.lua
  About:
    # Simple perforce scripts to handle your REAPER projects
]]

--[[
 * Changelog:
 * v1.0 (2025-10-02)
  + Initial Release
]]




-- Set P4 Client Name (saved in extstate, with default shown)
-- Prompts the user for a P4 client name and saves it permanently in REAPER extstate
-- If a value already exists, it is prefilled in the input box

local EXT_SECTION = "LKC_TOOLS"
local EXT_KEY = "P4ClientName"

-- Read existing value if present
local existing_value = reaper.GetExtState(EXT_SECTION, EXT_KEY)
if existing_value == "" then
	existing_value = "YOUR_CLIENT_NAME"  -- nothing set yet
end

-- Ask user for input, prefilled with existing value
local retval, input = reaper.GetUserInputs("Set P4 Client", 1, "Enter Perforce client name:,extrawidth=200", existing_value)

if retval then
	if input ~= "" then
		reaper.SetExtState(EXT_SECTION, EXT_KEY, input, true)  -- save persistently
		reaper.ShowMessageBox("Saved P4 client: " .. input, "Success", 0)
	else
		reaper.ShowMessageBox("Client name cannot be empty.", "Error", 0)
	end
end
