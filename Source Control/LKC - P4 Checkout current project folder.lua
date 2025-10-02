--[[
  NoIndex: true
]]


-- P4 Checkout Current Project Folder (Recursive)
-- Opens all files in the project folder and subfolders for edit in Perforce

-- CONFIGURATION: Set your P4 client name here (optional if P4CLIENT is set)
-- local P4_CLIENT = "YOUR_CLIENT_NAME"  -- Leave empty to use your default client, or set to "YOUR_CLIENT_NAME"

local EXT_SECTION = "LKC_TOOLS"
local EXT_KEY = "P4ClientName"

local P4_CLIENT = reaper.GetExtState(EXT_SECTION, EXT_KEY)


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

-- Build client flag if specified
local client_flag = ""
if P4_CLIENT ~= "" then
client_flag = "-c " .. P4_CLIENT .. " "
end

-- Show confirmation dialog
local client_info = P4_CLIENT ~= "" and ("\nUsing client: " .. P4_CLIENT) or "\nUsing default client"
local user_response = reaper.ShowMessageBox(
string.format("Run p4 edit on:\n%s%s\n\nThis will:\n- Open ALL files in this folder recursively for edit\n\nContinue?", project_dir, client_info),
"Confirm P4 Checkout",
4  -- Yes/No buttons
)

if user_response == 7 then  -- No button
return
end

if P4_CLIENT == "" then
  reaper.ShowMessageBox("No P4 client has been set. Run the 'Set P4 Client Name' script first.", "Error", 0)
else
  reaper.ShowConsoleMsg("Using P4 client: " .. P4_CLIENT .. "\n")
end


-- Create a temporary file to capture output
local temp_file = os.getenv("TEMP") .. "/p4_output.txt"

-- Construct the p4 edit command with output redirection
local p4_command = string.format('cd /d "%s" & p4 %sedit "..." > "%s" 2>&1', project_dir, client_flag, temp_file)

-- Execute the command
reaper.ShowConsoleMsg(p4_command .. "\n\n")
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
