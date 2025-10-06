--[[
  NoIndex: true
]]

-- P4 Revert Unchanged Files (Recursive)
-- Reverts all unchanged files in the project folder and subfolders in Perforce

local EXT_SECTION = "LKC_TOOLS"

-- Read P4 settings from ExtState
local p4_port = reaper.GetExtState(EXT_SECTION, "P4PORT")
local p4_user = reaper.GetExtState(EXT_SECTION, "P4USER")
local p4_client = reaper.GetExtState(EXT_SECTION, "P4CLIENT")

-- Check if settings are configured
if p4_port == "" or p4_user == "" or p4_client == "" then
  reaper.ShowMessageBox("P4 settings not configured. Run the 'P4 Set Workspace name' script first.", "Error", 0)
  return
end

-- Get the current project path
local retval, project_path = reaper.EnumProjects(-1, "")

if retval == nil or project_path == "" then
  reaper.ShowMessageBox("No project is currently open.", "Error", 0)
  return
end

-- Extract the directory from the project path
local project_dir = project_path:match("(.+)\\[^\\]+$")

if not project_dir then
  reaper.ShowMessageBox("Could not determine project directory.", "Error", 0)
  return
end

-- Show confirmation dialog
local user_response = reaper.ShowMessageBox(
  string.format("Run p4 revert -a on:\n%s\n\nServer: %s\nUser: %s\nClient: %s\n\nThis will:\n- Revert ALL unchanged files in this folder recursively\n\nContinue?", 
    project_dir, p4_port, p4_user, p4_client),
  "Confirm P4 Revert Unchanged",
  4  -- Yes/No buttons
)

if user_response == 7 then  -- No button
  return
end

-- Create a temporary file to capture output
local temp_file = os.getenv("TEMP") .. "\\p4_output.txt"

-- Construct the p4 revert command with all settings
local p4_command = string.format(
  'cd /d "%s" & p4 -p %s -u %s -c %s revert -a "..." > "%s" 2>&1',
  project_dir, p4_port, p4_user, p4_client, temp_file
)

-- Execute the command
reaper.ShowConsoleMsg(string.format(
  "Running: cd /d \"%s\" & p4 -p %s -u %s -c %s revert -a \"...\"\n\n",
  project_dir, p4_port, p4_user, p4_client
))
os.execute(p4_command)

-- Read the output file
local file = io.open(temp_file, "r")
if file then
  local output = file:read("*all")
  file:close()
  
  -- Print output to console
  reaper.ShowConsoleMsg("=== P4 Output ===\n")
  reaper.ShowConsoleMsg(output)
  reaper.ShowConsoleMsg("\n=================\n")
  
  -- Clean up temp file
  os.remove(temp_file)
else
  reaper.ShowMessageBox("Could not read command output.", "Error", 0)
end