--[[
	Noindex: true
]] MUTA = {}

-- local function Msg(param)
-- reaper.ShowConsoleMsg(tostring(param).."\n")
-- end

-- CONFIG--------------------------------------------------------------------------------------
-- VOLREF: RANGE = 2:     -6db <-> 0db
-- VOLREF: RANGE = 4:     -12db <-> 0db
-- VOLREF: RANGE = 8:     -18db <-> 0db
-- VOLREF: RANGE = 10:    -20db <-> 0db
-- VOLREF: RANGE = 16:    -24db <-> 0db
MUTA.VOLUME_RANGE = 8 -- VOLREF --pogledati dole
MUTA.PITCH_RANGE = 48 --  +24 i  -24
MUTA.MAX_RATE = 8 -- 4 times faster or 4 times slower
----------------------------------------------------------------------------------------------

-- KEY is INDEX
-- VALUE is STRING
MUTA.PROPERTIES = {
    "Volume", "Pan", "Pitch", "Tape/Stretch", "Rate", "Position", "Content", "Length", "Fades",
    "Fade Shape", "File"
}

-- KEY is STRING
-- VALUE is INDEX
MUTA.props = {}
for i = 1, #MUTA.PROPERTIES do MUTA.props[MUTA.PROPERTIES[i]] = i end

MUTA.blend = function(a, b, percent) return a + percent / 100 * (b - a) end


MUTA.ConvertChecklistArrayToDict = function(array)
    local dict = {}
    for i = 1, #MUTA.PROPERTIES do dict[MUTA.PROPERTIES[i]] = array[i] end
    return dict
end


MUTA.ConvertSlidersArrayToDict = function(array)
    local dict = {}
    for i = 1, #MUTA.PROPERTIES do
        local factor_name = MUTA.PROPERTIES[i] .. " Factor"
        dict[factor_name] = array[i]
    end

    return dict
end


MUTA.Mutate = function(checklist_values, sliders)

    sel_count = reaper.CountSelectedMediaItems(0)
    NO_USER_TIME_SELECTION = false
    if sel_count > 0 then

        local start_time, end_time = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
        local environment_length = end_time - start_time

        if environment_length == 0 or environment_length == nil then
            NO_USER_TIME_SELECTION = true
            reaper.Main_OnCommand(40290, 0) -- set time selection to items
            start_time, end_time = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
            environment_length = end_time - start_time
            reaper.Main_OnCommand(40635, 0) -- remove time selection
        end

        for i = 0, sel_count - 1 do

            local item = reaper.GetSelectedMediaItem(0, i)
            local take = reaper.GetActiveTake(item)
            if take == nil then goto skip_item end
            local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

            -- FILE RANDOMIZATION
            if checklist_values["File"] then

                local random_chance = math.random() * 100

                if random_chance >= sliders["File Factor"] then
                    -- nothing
                else

                    reaper.Main_OnCommand(41229, 0) -- Save selection set #1
                    reaper.Main_OnCommand(40289, 0) -- unselect all items
                    reaper.SetMediaItemSelected(item, true)
                    reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SISFTRANDIF"), 0)
                    reaper.Main_OnCommand(41239, 0) -- Load Selection Set #1
                end
            end

            -- SET LENGTH TO REGION IF NO TIME SELECTION
            if NO_USER_TIME_SELECTION then
                local markeridx, regionidx = reaper.GetLastMarkerAndCurRegion(0, pos)
                local retval, isrgn, pos, rgnend, name, markrgnindexnumber, color =
                    reaper.EnumProjectMarkers3(0, regionidx)
                if isrgn then
                    start_time = pos
                    end_time = rgnend
                    environment_length = end_time - start_time
                end
            end

            -- POSITION RANDOMIZATION
            if checklist_values["Position"] then
                local potential_item_position_range = environment_length - item_len

                local random_pos = math.random() * potential_item_position_range + start_time

                local final_position = MUTA.blend(pos, random_pos, sliders["Position Factor"])

                reaper.SetMediaItemInfo_Value(item, "D_POSITION", final_position)
            end

            -- LENGTH RANDOMIZATION
            if checklist_values["Length"] then
                local max_len = end_time - reaper.GetMediaItemInfo_Value(item, "D_POSITION")

                local random_len = math.random() * max_len
                local final_length = MUTA.blend(item_len, random_len, sliders["Length Factor"])
                reaper.SetMediaItemInfo_Value(item, "D_LENGTH", final_length)
            end

            -- CONTENT RANDOMIZATION
            if checklist_values["Content"] then
                local source = reaper.GetMediaItemTake_Source(take)
                if source ~= nil then
                    local audio_duration, lengthIsQN = reaper.GetMediaSourceLength(source)

                    local original_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
                    local random_offset = math.random() * (audio_duration - item_len)
                    local final_offset = MUTA.blend(original_offset, random_offset,
                                                    sliders["Content Factor"])
                    -- Msg(final_offset)
                    reaper.SetMediaItemTakeInfo_Value(take, "D_STARTOFFS", final_offset)
                end
            end

            -- PITCH RANDOMIZATION
            if checklist_values["Pitch"] then
                local cur_pitch = reaper.GetMediaItemTakeInfo_Value(take, "D_PITCH")

                local random_pitch = math.random() * MUTA.PITCH_RANGE - MUTA.PITCH_RANGE / 2 -- da bi islo od -12 do +12 ako je 24 pitch range

                final_pitch = MUTA.blend(cur_pitch, random_pitch, sliders["Pitch Factor"])
                reaper.SetMediaItemTakeInfo_Value(take, "D_PITCH", final_pitch)
            end

            -- RATE RANDOMIZATION
            if checklist_values["Rate"] then
                local cur_rate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")

                -- nadji broj između -4 i 4 ako je max_rate 8
                local random_factor_a = math.random() * 100
                local random_factor_b = MUTA.blend(-MUTA.MAX_RATE / 2, MUTA.MAX_RATE / 2,
                                                   random_factor_a)

                -- prebaci dobijenu vrednost u rate
                local random_rate = 1
                if random_factor_b < 0 then
                    random_rate = 1 / random_factor_b * (-1)
                else
                    random_rate = random_factor_b
                end

                local final_rate = MUTA.blend(cur_rate, random_rate, sliders["Rate Factor"])
                reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", final_rate)
            end

            -- PRESERVE PITCH RANDOMIZATION
            if checklist_values["Tape/Stretch"] then

                local random_chance = math.random() * 100

                local ret
                if random_chance >= sliders["Tape/Stretch Factor"] then
                    ret = reaper.SetMediaItemTakeInfo_Value(take, "B_PPITCH", 0)
                else
                    ret = reaper.SetMediaItemTakeInfo_Value(take, "B_PPITCH", 1)
                end
            end

            -- VOLUME RANDOMIZATION
            if checklist_values["Volume"] then

                -----------------------------------------------------------------------------------------------------------------------
                -- -- od -4 do +4 ako je range 8
                -- --RANGE = 8   -- 1/4(-12dB)   <-->  1*4 (+12dB)    -- 0.5 = -6db  , 2.0 = +6db
                -- local random_vol_factor = math.random()*MUTA.VOLUME_RANGE - MUTA.VOLUME_RANGE/2 
                -- local random_vol 
                -- if random_vol_factor < 0 then
                --     random_vol = 1 / random_vol_factor * (-1)
                -- else
                --     random_vol = random_vol_factor
                -- end

                -- local cur_volume = reaper.GetMediaItemInfo_Value(item, "D_VOL")

                -- local final_vol = MUTA.blend(cur_volume,random_vol,sliders["Volume Factor"])
                -- reaper.SetMediaItemInfo_Value(item, "D_VOL",final_vol)

                -----------------------------------------------------------------------------------------------------------------------
                local random_vol_factor = math.random() * 100

                local min_vol = 1 / MUTA.VOLUME_RANGE
                local max_vol = 1

                local random_vol = MUTA.blend(min_vol, max_vol, random_vol_factor) -- 0.125 do 1 ako je volume range 8 (-18db do 0db )

                local cur_volume = reaper.GetMediaItemInfo_Value(item, "D_VOL")
                local final_vol = MUTA.blend(cur_volume, random_vol, sliders["Volume Factor"])
                -- Msg(final_vol)
                reaper.SetMediaItemInfo_Value(item, "D_VOL", final_vol)

            end

            -- PAN RANDOMIZATION
            if checklist_values["Pan"] then
                local cur_pan = reaper.GetMediaItemTakeInfo_Value(take, "D_PAN")

                local random_pan = math.random() * 2 - 1 -- od -1 do +1

                local final_pan = MUTA.blend(cur_pan, random_pan, sliders["Pan Factor"])
                reaper.SetMediaItemTakeInfo_Value(take, "D_PAN", final_pan)
            end

            -- FADES RANDOMIZATION
            if checklist_values["Fades"] then
                local cur_fdin = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
                local cur_fdout = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN")

                -- --DO POLA NAJVISE
                -- local max_fade_len = item_len/2
                -- local max_fdin_len = max_fade_len
                -- local max_fdout_len = max_fade_len

                -- RANDOM TACKA U KLIPU, ALI BEZ PREKLAPANJA
                local max_fdin_len = math.random() * item_len
                local max_fdout_len = item_len - max_fdin_len

                local random_fdin = math.random() * max_fdin_len
                local random_fdout = math.random() * max_fdout_len

                local final_fdin = MUTA.blend(cur_fdin, random_fdin, sliders["Fades Factor"])
                local final_fdout = MUTA.blend(cur_fdout, random_fdout, sliders["Fades Factor"])

                reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", final_fdin)
                reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", final_fdout)
            end

            -- FADE SHAPE RANDOMIZATION
            if checklist_values["Fade Shape"] then
                local cur_fdin_shape =
                    tonumber(reaper.GetMediaItemInfo_Value(item, "C_FADEINSHAPE"))
                local cur_fdout_shape = tonumber(reaper.GetMediaItemInfo_Value(item,
                                                                               "C_FADEOUTSHAPE"))

                local random_fdin_shape = math.floor(math.random() * 6)
                local random_fdout_shape = math.floor(math.random() * 6)

                local final_fdin_shape = math.floor(
                                             MUTA.blend(cur_fdin_shape, random_fdin_shape,
                                                        sliders["Fade Shape Factor"]))
                local final_fdout_shape = math.floor(
                                              MUTA.blend(cur_fdout_shape, random_fdout_shape,
                                                         sliders["Fade Shape Factor"]))

                reaper.SetMediaItemInfo_Value(item, "C_FADEINSHAPE", final_fdin_shape)
                reaper.SetMediaItemInfo_Value(item, "C_FADEOUTSHAPE", final_fdout_shape)
            end

            ::skip_item::
        end

        -- SNAP TO GRID
        snap_to_grid = reaper.GetExtState("LKC_VARIATOR", "snap_to_grid")
        if snap_to_grid == 'true' then
            local grid = reaper.GetToggleCommandState(40145) -- toggle grid
            if grid == 1 then
                reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_QUANTITESTART2"), 0) -- quantize to grid
            end
        end

        if NO_USER_TIME_SELECTION then
            reaper.Main_OnCommand(40290, 0) -- set time selection to items
            reaper.Main_OnCommand(40635, 0) -- remove time selection
        end

    end

end


MUTA.Decontaminate = function()
    local sel_count = reaper.CountSelectedMediaItems(0)
    if sel_count > 0 then
        for i = 0, sel_count - 1 do
            local item = reaper.GetSelectedMediaItem(0, i)
            local take = reaper.GetActiveTake(item)

            reaper.SetMediaItemInfo_Value(item, "D_VOL", 1)
            reaper.SetMediaItemTakeInfo_Value(take, "D_PITCH", 0)
            reaper.SetMediaItemTakeInfo_Value(take, "D_PLAYRATE", 1)
            reaper.SetMediaItemTakeInfo_Value(take, "B_PPITCH", 1)
            reaper.SetMediaItemTakeInfo_Value(take, "D_PAN", 0)

            -- reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", 0)
            -- reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", 0)
        end
    end

    reaper.UpdateArrange()
end


MUTA.Randomize = function(min_value)
    if min_value == nil then min_value = 0 end
    local checklist_values = {}
    local slider_values = {}
    for i = 1, #MUTA.PROPERTIES do
        -- set slider
        local value = math.floor(math.random() * (100 - min_value) + min_value)

        -- set checklist
        local chance = math.random()
        if chance > 0.5 then
            slider_values[i] = value
            checklist_values[i] = true
        else
            checklist_values[i] = false
            slider_values[i] = 0
        end
    end
    return checklist_values, slider_values
end


MUTA.RandomSliceSelection = function()
    local sel_count = reaper.CountSelectedMediaItems(0)
    if sel_count > 0 then

        local item_selection = {}
        for i = 0, sel_count - 1 do item_selection[i] = reaper.GetSelectedMediaItem(0, i) end

        local max_splits = math.floor(math.random() * 3) + 2 -- od 3 do 5
        for i = 1, max_splits do
            sel_count = reaper.CountSelectedMediaItems(0)
            for j = 0, sel_count - 1 do
                local item = item_selection[j]
                if item ~= nil then
                    local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
                    local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                    local random_split = math.random() * item_len
                    local new_item = reaper.SplitMediaItem(item, pos + random_split)
                    if new_item then
                        reaper.SetMediaItemSelected(item, true)
                        reaper.SetMediaItemSelected(new_item, true)
                    end
                end
            end
        end
    end
end


MUTA.Chernobyl = function(disable_file)
    MUTA.RandomSliceSelection()

    -- local checklist_array,slider_values = MUTA.Randomize()
    local checklist_array, slider_values = MUTA.Randomize(50)

    local checklist_dict = MUTA.ConvertChecklistArrayToDict(checklist_array)
    local sliders_dict = MUTA.ConvertSlidersArrayToDict(slider_values)

    -- DISABLE FILE FACTOR
    if disable_file then checklist_dict["File"] = false end

    -- DEBUG
    -- for k,v in pairs(checklist_dict) do
    -- 	Msg(k..":"..tostring(v))
    -- end

    MUTA.Mutate(checklist_dict, sliders_dict)
end


MUTA.SubmitFeedback = function()
    local url = [[https://forms.gle/NbGuox17ypNhCB396]] -- open beta feedback
    if platform == "OSX32" or platform == "OSX64" or platform == "OSX" then
        os.execute('open "' .. url .. '"')
    else
        if platform == "Other" then -- linux
            os.execute('xdg-open "' .. url .. '"')
        else
            os.execute("start " .. url) -- windows
        end
    end
end


