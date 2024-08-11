--[[
  ReaScript Name: ElevenLabs TTS Helper
  Author: LKC
  REAPER: 7
  Version: 0.1
  Extensions: ReaImgui
  About:
    Small helper script to generate TTS through API faster.
]]

--[[
 * Changelog:
 * v0.1 (2024-08-11)
	+ First Version
]]

reaper.ClearConsole()

local reaper_imgui = reaper.ImGui_CreateContext("ElevenLabs Text-to-Speech")
local settings_file = reaper.GetResourcePath() .. '/elevenlabs_settings.txt'

local api_key = ""
local voice_id = ""
local stability = "0.5"
local similarity_boost = "0.5"

local input_text = ""

-- Function to load settings from file
function load_settings()
    local file = io.open(settings_file, "r")
    if file then
        api_key = file:read("*line") or api_key
        voice_id = file:read("*line") or voice_id
        stability = file:read("*line") or stability
        similarity_boost = file:read("*line") or similarity_boost
        file:close()
    end
end

-- Function to save settings to file
function save_settings()
    local file = io.open(settings_file, "w")
    if file then
        file:write(api_key .. "\n")
        file:write(voice_id .. "\n")
        file:write(stability .. "\n")
        file:write(similarity_boost .. "\n")
        file:close()
    end
end

-- Enhanced Function to escape special characters in text for JSON
function escape_json_text(text)
    local result = text:gsub('\\', '\\\\')
                      :gsub('"', '\\"')
                      :gsub("\n", "\\n")
                      :gsub("\r", "\\r")
                      :gsub("[%z\1-\31]", function(c) 
                          return string.format("\\u%04x", string.byte(c)) 
                      end)
    return result
end

-- Function to create a unique file name based on timestamp and text abbreviation
function generate_unique_filename(text)
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local words = {}
    for word in text:gmatch("%w+") do
        table.insert(words, word)
        if #words >= 3 then break end -- Take the first 3 words
    end
    local abbreviation = table.concat(words, "_")
    return timestamp .. "_" .. abbreviation .. ".mp3"
end

-- Function to set item note
function set_item_note_to_text(item, note)
    reaper.ULT_SetMediaItemNote(item, note)
end

-- Function to get the note text from the selected item
function get_note_text_from_selected_item()
    local item = reaper.GetSelectedMediaItem(0, 0)
    if item then
        local note = reaper.ULT_GetMediaItemNote(item)
        return note
    else
        reaper.ShowMessageBox("No item selected. Please select an item with a note.", "Error", 0)
        return nil
    end
end

-- Function to validate UTF-8 encoding
function is_valid_utf8(text)
    local pos = 1
    local length = #text
    while pos <= length do
        local byte = text:byte(pos)
        if byte >= 0x80 then
            if byte >= 0xC0 and byte <= 0xDF then
                pos = pos + 1
            elseif byte >= 0xE0 and byte <= 0xEF then
                pos = pos + 2
            elseif byte >= 0xF0 and byte <= 0xF7 then
                pos = pos + 3
            else
                return false
            end
        end
        pos = pos + 1
    end
    return true
end

-- Function to set item name with suffix
function set_item_name_with_suffix(item, base_name, suffix)
    local new_name = base_name .. suffix
    reaper.GetSetMediaItemTakeInfo_String(reaper.GetActiveTake(item), "P_NAME", new_name, true)
end

-- Function to send the text to ElevenLabs API and generate the audio file
function generate_audio(text)
    if not is_valid_utf8(text) then
        reaper.ShowMessageBox("Invalid UTF-8 encoding detected in the text. Please correct it and try again.", "Error", 0)
        return
    end

    -- Escape text for JSON
    text = escape_json_text(text)

    -- Get the REAPER project directory
    local project_path = reaper.GetProjectPath("") -- Get the project directory path

    -- Generate unique file name
    local unique_filename = generate_unique_filename(text)
    local output_file_path = project_path .. "\\" .. unique_filename

    -- Prepare the HTTP request using PowerShell Invoke-WebRequest
    local ps_command = string.format([[powershell -Command "Invoke-WebRequest -Uri 'https://api.elevenlabs.io/v1/text-to-speech/%s' -Method POST -Headers @{'xi-api-key'='%s'; 'accept'='audio/mpeg'; 'Content-Type'='application/json'} -Body '{\"text\": \"%s\", \"voice_settings\": {\"stability\": %s, \"similarity_boost\": %s}}' -OutFile '%s'"]],
        voice_id, api_key, text, stability, similarity_boost, output_file_path)

    -- Execute the PowerShell command
    reaper.ShowConsoleMsg(ps_command)
    local result = os.execute(ps_command)

    -- Import the generated file into REAPER
    if reaper.file_exists(output_file_path) then
        local track = reaper.GetSelectedTrack(0, 0)
        if track then
            local position = reaper.GetCursorPosition()
            reaper.InsertMedia(output_file_path, 0)

            -- Set the item note with the input text
            local item = reaper.GetMediaItem(0, reaper.CountMediaItems(0) - 1)
            if item then
                set_item_note_to_text(item, text)
                local suffix = string.format(" [Model: %s, Stability: %s, Similarity: %s]", voice_id, stability, similarity_boost)
                set_item_name_with_suffix(item, unique_filename, suffix)
            end
        else
            reaper.ShowMessageBox("No track selected. Please select a track to insert the audio.", "Error", 0)
        end
    else
        reaper.ShowMessageBox("Failed to generate audio. Please check your settings and try again.", "Error", 0)
    end
end

-- Function to generate audio from selected item's note
function generate_audio_from_selected_item_note()
    local note = get_note_text_from_selected_item()
    if note then
        generate_audio(note)
    end
end

-- GUI Main Loop
function loop()
    reaper.ImGui_SetNextWindowSize(reaper_imgui, 600, 400, reaper.ImGui_Cond_FirstUseEver())
    if reaper.ImGui_Begin(reaper_imgui, "ElevenLabs Text-to-Speech") then

        -- Input text box
        local changed, new_text = reaper.ImGui_InputTextMultiline(reaper_imgui, "##input_text", input_text, 500, 200)
        if changed then input_text = new_text end

        -- Generate button
        if reaper.ImGui_Button(reaper_imgui, "Generate") then
            generate_audio(input_text)
        end

        -- Generate from Item Note button
        if reaper.ImGui_Button(reaper_imgui, "Generate from Item Note") then
            generate_audio_from_selected_item_note()
        end

        -- Settings button
        if reaper.ImGui_Button(reaper_imgui, "Settings") then
            reaper.ImGui_OpenPopup(reaper_imgui, "Settings")
        end

        -- Settings Modal
        if reaper.ImGui_BeginPopupModal(reaper_imgui, "Settings", nil, reaper.ImGui_WindowFlags_AlwaysAutoResize()) then
            local api_key_changed, new_api_key = reaper.ImGui_InputText(reaper_imgui, "API Key", api_key)
            if api_key_changed then api_key = new_api_key end

            local voice_id_changed, new_voice_id = reaper.ImGui_InputText(reaper_imgui, "Voice ID", voice_id)
            if voice_id_changed then voice_id = new_voice_id end

            local stability_changed, new_stability = reaper.ImGui_InputText(reaper_imgui, "Stability", stability)
            if stability_changed then stability = new_stability end

            local similarity_boost_changed, new_similarity_boost = reaper.ImGui_InputText(reaper_imgui, "Similarity Boost", similarity_boost)
            if similarity_boost_changed then similarity_boost = new_similarity_boost end

            if reaper.ImGui_Button(reaper_imgui, "Save & Close") then
                save_settings()
                reaper.ImGui_CloseCurrentPopup(reaper_imgui)
            end

            reaper.ImGui_EndPopup(reaper_imgui)
        end

        reaper.ImGui_End(reaper_imgui)
    end

    -- Re-run the loop
    reaper.defer(loop)
end

-- Initialize settings and run the script
load_settings()
loop()
