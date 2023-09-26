
function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

-- year = tonumber(os.date("%Y"))
-- month = tonumber(os.date("%m"))
-- day = tonumber(os.date("%d"))

-- final_month = 6
-- final_year = 2020

-- if month <= final_month and year == final_year then
--     first_beta_run = reaper.HasExtState( "LKC_VARIATOR", "first_beta_run")
--     if first_beta_run == false then
--         reaper.ShowMessageBox("You are using closed beta trial version of LKC Variator which is valid until June 30, 2020.\n\nHave fun.", "VARIATOR INFO", 0)
--         reaper.SetExtState("LKC_VARIATOR", "first_beta_run", "1", true)
--     end
-- else
--     reaper.ShowMessageBox("Your beta version of LKC Variator has expired. You can still run mutate and formula actions but you cannot use the GUI.\n\nVisit www.lkctools.com for news and updates.", "VARIATOR INFO", 0)
--     TRIAL_EXPIRED = true
-- end



--Two ways of changing z layer
-- GUI.elms.properties.z = 100
-- GUI["elms"]["properties"].z = 300

-- Hiding layer 100
-- GUI.elms_hide[100] = true

local bin="x64"
if platform == "Win32" or platform == "OSX32" then bin="x86" end

loadfile(script_path .. "Data" .. separator .. "variator_mutations.lua")() --UCITAVANJE MUTA table-a


--[[
DYNAMICS - Volume,Fades,FadeShape
STEREO - Pan
TIMING - Position,Length
PITCH - Pitch,Tape/Stretch,Rate
SOURCE - Content,File
]]
----------------------------------------------------------------------------------------------
layout = tonumber(reaper.GetExtState("LKC_VARIATOR","layout"))
if layout == nil then layout = 1 end



if layout == 1 then
    loadfile(script_path .. "Data" .. separator .. "layout_vertical1.lua")() --UCITAVANJE MUTA table-a
elseif layout == 2 then
    loadfile(script_path .. "Data" .. separator .. "layout_vertical2.lua")() --UCITAVANJE MUTA table-a 
elseif layout == 3 then
    loadfile(script_path .. "Data" .. separator .. "layout_horizontal1.lua")() --UCITAVANJE MUTA table-a 
elseif layout == 4 then
    loadfile(script_path .. "Data" .. separator .. "layout_horizontal2.lua")() --UCITAVANJE MUTA table-a 
end


--SETTINGS/OPTIONS
function ApplySettings()
    local layout = GUI.Val("layout")
    local chernobyl_affects_file = tostring(GUI.Val("options")[1])
    local snap_to_grid = tostring(GUI.Val("options")[2])
    -- Msg(docked)
    reaper.SetExtState("LKC_VARIATOR","layout",layout,true)
    reaper.SetExtState("LKC_VARIATOR","chernobyl_affects_file",chernobyl_affects_file,true)
    reaper.SetExtState("LKC_VARIATOR","snap_to_grid",snap_to_grid,true)
    reaper.ShowMessageBox("Settings are saved. Please restart the script to see layout changes.", "LKC VARIATOR", 0)
end

function CheckLayout()
    chernobyl_affects_file = reaper.GetExtState("LKC_VARIATOR", "chernobyl_affects_file")
    if chernobyl_affects_file == 'true' then
        chernobyl_affects_file = true
    else
        chernobyl_affects_file = false
    end
    
    snap_to_grid = reaper.GetExtState("LKC_VARIATOR", "snap_to_grid")
    if snap_to_grid == 'true' then
        snap_to_grid = true
    else
        snap_to_grid = false
    end

    local options = {}
    options[1] = chernobyl_affects_file
    options[2] = snap_to_grid
    GUI.Val("options",options)


    if layout then
        GUI.Val("layout",layout)
    end


    loaded_dock_id = tonumber(reaper.GetExtState("LKC_VARIATOR", "dock_id"))
    is_docked = tonumber(reaper.GetExtState("LKC_VARIATOR", "docked"))
    -- Msg(tostring(loaded_dock_id))
    if loaded_dock_id == nil or loaded_dock_id == "" then
        loaded_dock_id = 0
    end
    if is_docked == 1 then
        GUI.dock = loaded_dock_id
    else
        GUI.dock = 0
    end


end

function SaveDockState()
    dockid  = gfx.dock(-1) 
    if dockid > 0 then
        reaper.SetExtState( "LKC_VARIATOR", "dock_id", dockid, true )
        reaper.SetExtState( "LKC_VARIATOR", "docked", 1, true )
    else
        reaper.SetExtState( "LKC_VARIATOR", "docked", 0, true )
    end
end

function ToggleDocking()
    if gfx.dock(-1) > 0 then
        gfx.dock(0) -- UNDOCK
        GUI.dock = 0
    else
        -- Msg(GUI.dock)
        if GUI.dock == 0 then GUI.dock = 1 end
        -- Msg(GUI.dock)
        -- Msg("--")
        gfx.dock(GUI.dock)
    end
    SaveDockState()
end

function Exit()
    SaveDockState()
    GUI.quit = true
end




--DO FUNCTIONS--------------------------------------------------------------------------------------------------------------------------------------------
function GetGUISliders()
	local sliders = {}
	for i = 1 , #MUTA.PROPERTIES do
		local factor_name = MUTA.PROPERTIES[i] .. " Factor"
		sliders[factor_name] = GUI.Val(factor_name)
	end
	
	return sliders
end

function GetGUIChecklistValues()
	local array = GUI.Val("properties")
	return MUTA.ConvertChecklistArrayToDict(array)
end



function DoMutate()

	
	
	reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    MUTA.Mutate(GetGUIChecklistValues(),GetGUISliders())
    SaveProfile()
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_FOCUS_ARRANGE_WND"), 0) -- focus arrange
    
    reaper.Undo_EndBlock("LKC - Variator Mutate", -1) -- End of the undo block. Leave it at the bottom of your main function.
    reaper.UpdateArrange()
    reaper.PreventUIRefresh(-1)
end

function DoResetFormula()
	all_false = {}
    for i = 1 , #MUTA.PROPERTIES do
        local val
        if layout > 2 then
            val = 100
        else
            val = 0
        end
		GUI.Val(MUTA.PROPERTIES[i] .. " Factor", val)
		all_false[i] = false
	end
	
    GUI.Val("properties", all_false)
    SaveProfile()
end

function DoDecontaminate()
    reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    MUTA.Decontaminate()
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_FOCUS_ARRANGE_WND"), 0) -- focus arrange
    
    reaper.Undo_EndBlock("LKC - Variator - Decontaminate", -1) -- End of the undo block. Leave it at the bottom of your main function.
    reaper.UpdateArrange()
    reaper.PreventUIRefresh(-1)
        
end



-- function DisableFileFactor()
--     -- --MAKE SURE THAT FILE DOES NOT GET CHANGED
--     file_to_false = {[#MUTA.PROPERTIES] = false}
--     GUI.Val("File Factor",0)
--     GUI.Val("properties", file_to_false)
-- end

function DoChernobyl()
    reaper.PreventUIRefresh(1)
    reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.
    
    if chernobyl_affects_file then
        MUTA.Chernobyl()
    else
        MUTA.Chernobyl("disable_file_factor")
    end

    reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_FOCUS_ARRANGE_WND"), 0) -- focus arrange
    
    reaper.Undo_EndBlock("LKC - Variator - Chernobyl", -1) -- End of the undo block. Leave it at the bottom of your main function.
    reaper.UpdateArrange()
    reaper.PreventUIRefresh(-1)
end

function DoRandomizeGUI()
	checklist_values,slider_values = MUTA.Randomize()
	
	--set values to sliders
    for i = 1, #MUTA.PROPERTIES do
        local val
        if layout > 2 then
            val = 100 - slider_values[i]
        else
            val = slider_values[i]
        end
		GUI.Val(MUTA.PROPERTIES[i] .. " Factor",val)
	end
	
	--Set Values to checkboxes
    GUI.Val("properties", checklist_values)
    SaveProfile()
end





function SaveProfile(formula)
    if formula == nil then formula= '' end
    dna_state = GUI.Val("properties")
    for i = 1 , #MUTA.PROPERTIES do
        local val = GUI.Val(MUTA.PROPERTIES[i] .. " Factor")
        reaper.SetExtState("LKC_VARIATOR",MUTA.PROPERTIES[i]..formula,val,true)
        reaper.SetExtState("LKC_VARIATOR",MUTA.PROPERTIES[i].."_checkbox"..formula,tostring(dna_state[i]),true)
    end
end

function LoadProfile(formula)

    if formula == nil then formula= '' end
    states = {}
    for i = 1 , #MUTA.PROPERTIES do
        local value

        local hasval = reaper.HasExtState("LKC_VARIATOR", MUTA.PROPERTIES[i]..formula)
        if hasval then 
            value = tonumber(reaper.GetExtState("LKC_VARIATOR",MUTA.PROPERTIES[i]..formula))
        else
            value = 0
        end


        if layout > 2 then
            value = 100 - value
        end
        GUI.Val(MUTA.PROPERTIES[i] .. " Factor",value)
        
        local state = reaper.GetExtState("LKC_VARIATOR",MUTA.PROPERTIES[i].."_checkbox"..formula)
        -- Msg(PROPERTIES[i] .. ":" .. state)
        if state == 'true' then state = true
        else state = false end
        states[i] = state

    end   

    GUI.Val("properties",states)
    SaveProfile()
end


function Save1()
    SaveProfile(1)
    reaper.ShowMessageBox("Formula is now saved in slot 1", "LKC VARIATOR", 0)
end
function Save2()
    SaveProfile(2)
    reaper.ShowMessageBox("Formula is now saved in slot 2", "LKC VARIATOR", 0)
end
function Save3()
    SaveProfile(3)
    reaper.ShowMessageBox("Formula is now saved in slot 3", "LKC VARIATOR", 0)
end
function Save4()
    SaveProfile(4)
    reaper.ShowMessageBox("Formula is now saved in slot 4", "LKC VARIATOR", 0)
end
function Save5()
    SaveProfile(5)
    reaper.ShowMessageBox("Formula is now saved in slot 5", "LKC VARIATOR", 0)
end

function Load1()
    LoadProfile(1)
end
function Load2()
    LoadProfile(2)
end
function Load3()
    LoadProfile(3)
end
function Load4()
    LoadProfile(4)
end
function Load5()
    LoadProfile(5)
end

save_functions = {Save1,Save2,Save3,Save4,Save5}
load_functions = {Load1,Load2,Load3,Load4,Load5}

--GUI-----------------------------------------------------------------------------------------------------------------------------------------------------

-- local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
-- if not lib_path or lib_path == "" then
--     reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
--     return
-- end
-- loadfile(lib_path .. "Core.lua")()


-- GUI.req("Classes/Class - Slider.lua")()
-- GUI.req("Classes/Class - Label.lua")()
-- GUI.req("Classes/Class - Options.lua")()
-- GUI.req("Classes/Class - Frame.lua")()
-- GUI.req("Classes/Class - Button.lua")()
-- GUI.req("Classes/Class - Tabs.lua")()
-- -- If any of the requested libraries weren't found, abort the script.
-- if missing_lib then return 0 end



loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Core.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Button.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Label.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Window.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Slider.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Frame.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Tabs.dat]])()
loadfile(script_path.."Data"..separator..[[Lokasenna_GUI]]..separator..[[Class - Options.dat]])()





GUI.name = "LKC Variator"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, WIDTH, HEIGHT
GUI.anchor, GUI.corner = "screen", "C"
GUI.freq = 1
GUI.onresize = force_size

local function force_size()


    --Da može do mile volje da se resize-uje
    -- GUI.elms.Listbox1:wnd_recalc()
    for k,v in pairs(GUI.buffers) do
        GUI.FreeBuffer(k)
    end

	-- GUI.elms.Listbox1:wnd_recalc()
end

GUI.New("TitleLabel", "Label", {
    z = 9,
    x = TITLE_X + 5,
    y = TITLE_Y,
    caption = "Variator",
    font = 1,
    color = "txt",
    bg = "wnd_bg",
    shadow = false
})

-- GUI.New("authorLabel", "Label", {
    -- z = 11,
    -- x = 275.0,
    -- y = 35.0,
    -- caption = "by LKC",
    -- font = 3,
    -- color = "txt",
    -- bg = "wnd_bg",
    -- shadow = false
-- })

--GENERATE SLIDERS

for i = 1 , #MUTA.PROPERTIES do
    GUI.New(MUTA.PROPERTIES[i] .. " Factor", "Slider", {
        z = 11,
        x = SLIDER_ANCHOR_X + SLIDER_PAD_X * i,
        y = SLIDER_ANCHOR_Y + SLIDER_PAD_Y * i,
        w = SLIDER_WIDTH,
        caption = "",
        min = 0,
        max = 100,
        defaults = {0},
        inc = 1,
        dir = SLIDER_DIRECTION,
        font_a = 3,
        font_b = 4,
        col_txt = "txt",
        col_fill = "elm_fill",
        bg = "wnd_bg",
        show_handles = true,
        show_values = true,
        cap_x = 0,
        cap_y = 0
    })
end



if layout < 3 then
    GUI.New("RadiationLabel", "Label", {
        z = 11,
        x = RADIATION_ANCHOR_X + 53,
        y = RADIATION_ANCHOR_Y - 10,
        caption = "Radiation",
        font = 2,
        color = "txt",
        bg = "wnd_bg",
        shadow = false
    })

        --RADIATION FRAME
    GUI.New("RadiationFrame", "Frame", {
        z = 13.0,
        x = RADIATION_ANCHOR_X,
        y = RADIATION_ANCHOR_Y,
        w = 168,
        h = CHECKLIST_HEIGHT,
        shadow = false,
        fill = false,
        color = "elm_frame",
        bg = "wnd_bg",
        round = 0,
        text = "",
        txt_indent = 0,
        txt_pad = 0,
        pad = 4,
        font = 4,
        col_txt = "txt"
    })
end


GUI.New("properties", "Checklist", {
    z = 11,
    x = CHECKLIST_X,
    y = CHECKLIST_Y,
    w = CHECKLIST_WIDTH,
    h = CHECKLIST_HEIGHT,
    caption = CHECKLIST_CAPTION,
    optarray = MUTA.PROPERTIES,
    dir = CHECKLIST_DIRECTION,
    pad = CHECKLIST_PADDING,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = true,
    shadow = true,
    swap = nil,
    opt_size = 20,
    lkc_layout = layout
})



--PRESETS FRAME
GUI.New("FormulasFrame", "Frame", {
    z = 12.0,
    x = FORMULAS_ANCHOR_X,
    y = FORMULAS_ANCHOR_Y,
    w = SECTION_WIDTH,
    h = FORMULAS_HEIGHT,
    shadow = false,
    fill = false,
    color = "elm_frame",
    bg = "wnd_bg",
    round = 0,
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 4,
    font = 4,
    col_txt = "txt"
})



GUI.New("PresetsLabel", "Label", {
    z = 11,
    x = FORMULAS_ANCHOR_X + 53,
    y = FORMULAS_ANCHOR_Y - 10,
    caption = "Formulas",
    font = 2,
    color = "txt",
    bg = "wnd_bg",
    shadow = false
})

--CREATE LOAD AND SAVE BUTTONS
for i = 1, 5 do
	local load_string = "Load " .. i
		GUI.New(load_string, "Button", {
		z = 11,
		x = FORMULAS_ANCHOR_X + 18,
		y = FORMULAS_ANCHOR_Y - 15 + 32*i,
		w = 75,
		h = 24,
		caption = load_string,
		font = 3,
		col_txt = "txt",
        col_fill = "elm_frame",
        func = load_functions[i]
	})
	
	local save_string = "Save " .. i
	GUI.New(save_string, "Button", {
		z = 11,
		x = FORMULAS_ANCHOR_X + 98,
		y = FORMULAS_ANCHOR_Y - 15 + 32*i,
		w = 48,
		h = 24,
		caption = save_string,
		font = 3,
		col_txt = "txt",
        col_fill = "elm_frame",
        func = save_functions[i]
	})
end




-- GUI.New("EnvironmentRadio", "Radio", {
--     z = 11,
--     x = 384.0,
--     y = 72.0,
--     w = 200,
--     h = 70,
--     caption = "Environment",
--     optarray = {"Time Selection", "Region"},
--     dir = "v",
--     font_a = 2,
--     font_b = 3,
--     col_txt = "txt",
--     col_fill = "elm_fill",
--     bg = "wnd_bg",
--     frame = true,
--     shadow = true,
--     swap = nil,
--     opt_size = 20
-- })








GUI.New("random_params", "Button", {
    z = 11,
    x = RESEARCH_ANCHOR_X + 10,
    y = RESEARCH_ANCHOR_Y + 17,
    w = 70,
    h = 24,
    caption = "Randomize",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
	func = DoRandomizeGUI
})

GUI.New("reset", "Button", {
    z = 11,
    x = RESEARCH_ANCHOR_X + 87,
    y = RESEARCH_ANCHOR_Y + 17,
    w = 72,
    h = 24,
    caption = "Reset",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
	func = DoResetFormula
})

GUI.New("heal", "Button", {
    z = 11,
    x = RESEARCH_ANCHOR_X + 10,
    y = RESEARCH_ANCHOR_Y + 50,
    w = 150,
    h = 24,
    caption = "Decontaminate",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = DoDecontaminate
})

GUI.New("mutate", "Button", {
    z = 11,
    x = RESEARCH_ANCHOR_X + 10,
    y = RESEARCH_ANCHOR_Y + 85,
    w = 150,
    h = 50,
    caption = "Mutate",
    font = 1,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = DoMutate
})

GUI.New("chernobyl", "Button", {
    z = 11,
    x = RESEARCH_ANCHOR_X + 10,
    y = RESEARCH_ANCHOR_Y + 145,
    w = 150,
    h = 24,
    caption = "Chernobyl",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = DoChernobyl
})







GUI.New("ResearchLabel", "Label", {
    z = 11.0,
    x = RESEARCH_ANCHOR_X + 54,
    y = RESEARCH_ANCHOR_Y - 10,
    caption = "Research",
    font = 2,
    color = "txt",
    bg = "wnd_bg",
    shadow = false
})


GUI.New("ResearchFrame", "Frame", {
    z = 14.0,
    x = RESEARCH_ANCHOR_X,
    y = RESEARCH_ANCHOR_Y,
    w = SECTION_WIDTH,
    h = RESEARCH_FRAME_HEIGHT,
    shadow = false,
    fill = false,
    color = "elm_frame",
    bg = "wnd_bg",
    round = 0,
    text = "",
    txt_indent = 0,
    txt_pad = 0,
    pad = 4,
    font = 4,
    col_txt = "txt"
})





--OFFICE TAB----------------------------------------------------------------------------------------

GUI.New("options", "Checklist", {
    z = 2,
    x = TL_X,
    y = 220,
    w = SECTION_WIDTH,
    h = 70,
    caption = "Options",
    optarray = {
                "Chernobyl affects 'File'",
                "Snap mutations to grid"
                -- "Decontaminate fades",

                },
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = true,
    shadow = true,
    swap = nil,
    opt_size = 20
})

GUI.New("layout", "Radio", {
    z = 2,
    x = TL_X,
    y = TL_Y,
    w = SECTION_WIDTH,
    h = 120,
    caption = "Layout",
    optarray = {
                "Vertical 1",
                "Vertical 2",
                "Horizontal 1",
                "Horizontal 2",
                -- "Decontaminate fades",
                -- "Chernobyl affects files"
                },
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = true,
    shadow = true,
    swap = nil,
    opt_size = 20
})

GUI.New("apply", "Button", {
    z = 2,
    x = TR_X,
    y = TR_Y,
    w = 150,
    h = 50,
    caption = "Apply",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = ApplySettings
})
GUI.New("toggle_docking", "Button", {
    z = 2,
    x = TR_X,
    y = TR_Y + 60,
    w = 150,
    h = 40,
    caption = "(Un)dock",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = ToggleDocking
})
GUI.New("feedback", "Button", {
    z = 2,
    x = TR_X,
    y = TR_Y + 115,
    w = 150,
    h = 40,
    caption = "Submit Feedback",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = MUTA.SubmitFeedback
})

GUI.New("exit", "Button", {
    z = 2,
    x = TR_X,
    y = TR_Y + 165,
    w = 150,
    h = 40,
    caption = "Exit",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = Exit
})




---------------------------------------------------------------------


--TABS
GUI.New("Tabs1", "Tabs", {
    z = 30.0,
    x = 0.0,
    y = 0.0,
    w = 960.0,
    caption = "Tabs1",
    optarray = {"Lab", "Office"},
    tab_w = 48,
    tab_h = 20,
    pad = 8,
    font_a = 3,
    font_b = 4,
    col_txt = "txt",
    col_tab_a = "wnd_bg",
    col_tab_b = "tab_bg",
    bg = "elm_bg",
    fullwidth = true
})

tabs = 	{
	[1] = {14, 11,13,12 }, 
	[2] = {2, 5, 6} 
	-- [3] = {2, 7, 8},
}
GUI.elms.Tabs1:update_sets(tabs)



CheckLayout()
LoadProfile()
GUI.Init()
GUI.Main()

function onexit()
    -- gfx.init(1) - ne znam čemu ovo služi za izlaz, radi i bez ovoga
    dockid  = gfx.dock(-1)
    SaveDockState()
    -- Msg("KRAJ")
end
reaper.atexit(onexit)

if TRIAL_EXPIRED then
    GUI.elms_hide[30] = true
    GUI.elms_hide[11] = true
    GUI.elms_hide[12] = true
    GUI.elms_hide[13] = true
    GUI.elms_hide[14] = true
end
