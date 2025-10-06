--[[
  ReaScript Name: LKC Perforce P4 Scripts
  Author: LKC
  REAPER: 7+
  Version: 1.02
  Provides:
   [Main] LKC - Perforce P4 - Checkout current project folder.lua
   [Main] LKC - Perforce P4 - Reconcile current project folder.lua
   [Main] LKC - Perforce P4 - Revert unchanged files in current project folder.lua
  About:
    # Simple perforce scripts to handle your REAPER projects
]]

--[[
 * Changelog:
 * v1.02 (2025-10-06)
  + Add support to set user,client and server
 * v1.01 (2025-10-02)
  + Fixed incorrect metadata
 * v1.0 (2025-10-02)
  + Initial Release
]]

-- Set P4 Configuration
-- Prompts the user for P4 settings and saves them permanently in REAPER extstate

local EXT_SECTION = "LKC_TOOLS"

-- Read existing values
local p4_port = reaper.GetExtState(EXT_SECTION, "P4PORT")
local p4_user = reaper.GetExtState(EXT_SECTION, "P4USER")
local p4_client = reaper.GetExtState(EXT_SECTION, "P4CLIENT")

-- Prefill with defaults if empty
if p4_port == "" then p4_port = "localhost:1666" end
if p4_user == "" then p4_user = "YOUR_USERNAME" end
if p4_client == "" then p4_client = "YOUR_CLIENT_NAME" end

-- Ask user for all settings
local retval, inputs = reaper.GetUserInputs(
  "P4 Configuration", 
  3, 
  "P4PORT (server:port):,P4USER (username):,P4CLIENT (workspace):,extrawidth=200",
  p4_port .. "," .. p4_user .. "," .. p4_client
)

if not retval then
  return  -- User cancelled
end

-- Parse inputs
p4_port, p4_user, p4_client = inputs:match("([^,]+),([^,]+),([^,]+)")

-- Validate
if p4_port == "" or p4_user == "" or p4_client == "" then
  reaper.ShowMessageBox("All fields are required.", "Error", 0)
  return
end

-- Save settings
reaper.SetExtState(EXT_SECTION, "P4PORT", p4_port, true)
reaper.SetExtState(EXT_SECTION, "P4USER", p4_user, true)
reaper.SetExtState(EXT_SECTION, "P4CLIENT", p4_client, true)

reaper.ShowMessageBox(
  string.format("Saved P4 settings:\nServer: %s\nUser: %s\nClient: %s", p4_port, p4_user, p4_client),
  "Configuration Saved",
  0
)