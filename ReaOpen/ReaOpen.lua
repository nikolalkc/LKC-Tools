--[[
 ReaScript Name:ReaOpen
 Author: LKC,JerContact
 REAPER: 5+
 Extensions: SWS
 Version: 1.83
 Provides:
  ReaOpen.exe
  ReaOpen MAC.zip
  ReaOpen.rpp
  install_wwise_command_for_pc.bat
  [Main] ReaOpen - Init Setup.lua
  [Main] ReaOpen - Open script directory.lua
 About:
  ReaOpen is a free lightweight program that allows you to select an audio file and open its original REAPER project with ease.
  It works both on Windows and Mac and can be integrated into Wise, Explorer/Finder and REAPER itself.
  It is a mod of another script called Open project from clipboard by JerContact.
]]
--[[
 * Changelog:
  * v1.83 (2023-05-25)
	+ Fixed 'Open script directory' action on M1 Macs
  * v1.82 (2023-05-25)
	+ Fixed Mac M1 path issues, used universal, cross-platform slash symbol
  * v1.81 (2022-08-15)
	+ ReaOpen will now look for items/blocks within hidden project tracks
  * v1.80 (2021-02-21)
	+ PC: Added logic for reaper_exe_path - improves portability
  * v1.75 (2019-04-15)
	+ Fixed issue with regular (appdata) REAPER installation on PC
  * v1.74 (2019-03-07)
	+ Fixed error with region name parsing
  * v1.73 (2019-03-02)
	+ Fixed error with init setup
  * v1.72 (2019-02-27)
	+ Updated ReaOpen.rpp file
  * v1.71 (2019-02-27)
	+ Added bat file for installing command on PC
	+ Removed Assets folder from ReaOpen.rpp project settings
 * v1.70 (2018-12-05)
	+ Deleted bat for installing command in wwise, for simplicity
	+ Added open script directiory action
 * v1.60 (2018-10-13)
	+ wGroups metadata support
	+ Fixed reading binary wavs with sub character
 * v1.55 (2018-10-13)
	+ ReaOpen - Init Setup.lua to action list
 * v1.54 (2018-10-13)
	+ ReaOpen Init Setup v1.0 script added
 * v1.53 (2018-10-08)
	+ Script to install ReaOpen command in Wwise 2018.1.2
 * v1.52 (2018-10-07)
	+ Fix Mac select tab problem
 * v1.51 (2018-10-07)
	+ New mac build
 * Changelog:
 * v1.50 (2018-10-07)
	+ Changed the name of package to ReaOpen
 * v1.44 (2018-10-07)
	+ file:read fix for case when binary is not in just one line
 * v1.43 (2018-09-10)
	+ Metadata parse character changed to semicolon (;) instead of colon(,)
	+ Reawwiser.exe icon
 * v1.42 (2018-09-10)
	+ PC version of ReaWwiser opens normal instead of template project
 * v1.41 (2018-09-08)
	+ New ReaWwiser MAC.zip file
* v1.40 (2018-09-08)
	+ Regions support
	+ Template moved to app folder
 * v1.33 (2018-09-07)
	+ Mac icon
 * v1.32 (2018-09-07)
	+ Added zip with MAC app
 * v1.31 (2018-09-07)
	+ Changelog and indexing fix
 * v1.30 (2018-09-07)
	+ ReaWwiser OSX support
 * v1.20 (2018-09-06)
	+ Fixed selecting tabs when multiple projects are opened
	+ Replaced whitespaces with tabs
	+ Reindented the file
	+ Added support for metadata items in reaper (everything after comma in item name will be ignored)
 * v1.17 (2018-07-13)
	+ Loading improved, no ui refresh
 * v1.16 (2018-06-24)
	+ Rename package files and name
 * v1.15 (2018-06-22)
	+ Script and all files renamed
 * v1.10 (2018-06-22)
	+ FIX: Gets Active Item Take, not first take
 * v1.0 (2018-06-22)
	+ Initial Commit
]]


--NIKOLALKC INTRO
--METAPARSE CHAR = ;
function Msg(param)
	reaper.ShowConsoleMsg(tostring(param).."\n")
end
--ENUM PROJECT
TempProject, projfn = reaper.EnumProjects( -1, "" )
function open_or_select_tab()
	open=1
	proj=0
	subproj=0
	
	while subproj do
		subproj, projname = reaper.EnumProjects(proj, "NULL")
		if projname==n1 then
			project=subproj
			open=0
			break
		end
		
		proj=proj+1
	end
	if open==1 then
		-- Msg("Open Project: "..tostring(n1))
		reaper.Main_OnCommand(40859, 0) --new project tab
		reaper.Main_openProject(n1)
	else
		-- Msg("Select Project: "..tostring(project))
		reaper.SelectProjectInstance(project)
	end
end

--CHECK IF REGION - NIKOLALKC
function isRegion(position,file_name)
	result = false
	retval, num_markers, num_regions = reaper.CountProjectMarkers( 0 )
	all_markers_count = num_markers + num_regions
	
	potential_match_regions = {}
	match_count = 0
	--go thru all regsion
	-- Msg("QUERY:"..file_name)
	for i = 0, all_markers_count-1 do
		local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers( i )
		
		if isRegion then
			local delta_pos = pos - position
			if delta_pos < 0 then  delta_pos = delta_pos * (-1) end
			--odvoj svaku regiju koja ima isto ime
			
			--izbaci space iz imena regije, da bi moglo da se uporedi sa file_name-om koji nema space-ove
			name = string.gsub (name, "\n", "") --remove newlines
			name = string.gsub (name, "\r", "") --remove newlines
			name = string.gsub(name, "% ", "") -- remove spaces
			-- Msg(name)
			if file_name == name then
				potential_match_regions[name] = pos
				match_count = match_count + 1
			end
		end
	end
	
	--FIND CLOSEST REGION
	if match_count > 0 then 
		smallest_delta = nil
		final_region_name = nil
		for k,v  in pairs(potential_match_regions) do
			if smallest_delta == nil then   --calculate init delta 
				smallest_delta = v - position
				if smallest_delta < 0 then smallest_delta = smallest_delta * (-1) end  --take absolute value
				final_region_name = k
			else
				local delta = v - position
				if delta < 0 then delta = delta * (-1) end --take absolute value
				if delta < smallest_delta then
					smallest_delta = delta
					final_region_name = k
				end
			end
		end
		
	end
	
	--determine results
	if final_region_name ~= nil then
		return potential_match_regions[final_region_name]
	else
		return false
	end
end


--CSV PARSER
function ParseCSVLine (line,sep) 
	local res = {}
	local pos = 1
	sep = sep or ','
	while true do 
		local c = string.sub(line,pos,pos)
		if (c == "") then break end
		if (c == '"') then
			-- quoted value (ignore separator within)
			local txt = ""
			repeat
				local startp,endp = string.find(line,'^%b""',pos)
				txt = txt..string.sub(line,startp+1,endp-1)
				pos = endp + 1
				c = string.sub(line,pos,pos) 
				if (c == '"') then txt = txt..'"' end 
				-- check first char AFTER quoted string, if it is another
				-- quoted string without separator, then append it
				-- this is the way to "escape" the quote char in a quote. example:
				--	 value1,"blub""blip""boing",value3	will result in blub"blip"boing	for the middle
			until (c ~= '"')
			table.insert(res,txt)
			assert(c == sep or c == "")
			pos = pos + 1
			else	
			-- no quotes used, just look for the first separator
			local startp,endp = string.find(line,sep,pos)
			if (startp) then 
				table.insert(res,string.sub(line,pos,startp-1))
				pos = endp + 1
				else
				-- no separator found -> use rest of string and terminate
				table.insert(res,string.sub(line,pos))
				break
			end 
		end
	end
	return res
end

--ORIGINAL SCRIPT STARTS HERE--------------------------------------------------------------------------------------------------------------------
--description Open project based on file in clipboard
--version 1.3
--author JerContact
--about
-- # open-project-based-on-file-in-clipboard
-- If you copy the full pathname of the file, this script will open the corresponding reaper project associated with that file based
-- on the bwf metadata inside the .wav file (to get to this to work you'll need to render out .wav files from reaper and have
-- the "Include project filename in BWF data" checked.	This script first figures out the timecode location of that file imbedded
-- inside the .wav file, and tries to find the item around that location.	If the file is in the project but has moved timecode there
-- will be a warning message box telling you so.	If the project is opened but the item is not longer in the project, you'll get
-- and error saying the item is no longer there.	If there is no metadata in you .wav file, no project will be loaded.
--changelog
-- + 1.3 - adding a little feature to make this work with files named with .wav at the end inside reaper.

reaper.PreventUIRefresh(1)
weallgood=0
filetxt = reaper.CF_GetClipboard("")
m, n = string.find(filetxt, ".wav")
if m~= nil then
	test = string.find(filetxt, '"')
	if test==1 then
		testlength = string.len(filetxt)
		test = string.sub(filetxt, testlength)
		test = string.find(filetxt, '"')
		if test==1 then
			filetxt = string.sub(filetxt, 2, testlength-1)
		end
	end
	--reaper.ShowMessageBox(filetxt, "", 1)
	filetxt = string.sub(filetxt, 1, (m+3))
	filetxt = tostring(filetxt)
	wavfile = filetxt
	-- f = io.input(filetxt)--old and buggy - escapes SUB character
	local f = assert(io.open(filetxt, "rb"))--new and even more sexy LKC edit
	a=f:read("*all") --new and sexy lkc edit
	-- Msg("PRINT FILE:")
	-- Msg(a)
	-- Msg("PRINT LINE:")
    -- local count = 1
    -- while true do
		-- local line = io.read()
      -- if line == nil then break end
      -- Msg(tostring(count).." "..line)
      -- count = count + 1
    -- end	
	n1 = a
	m, n = string.find(n1, "RPP:")
	f:close()
	if m~=nil then
		n1 = string.sub(n1, (m+4))
		m, n = string.find(n1, ".RPP")
		n1 = string.sub(n1, 1, n)
		filenametemp=n1
		
		m=0
		m, n = string.find(filenametemp, ".rpp")
		
		if m~=nil then
			filenametemp = string.sub(filenametemp, 1, n)
		end
		
		n1=filenametemp
		-- Msg(n1)
		
		open_or_select_tab()
		
		m=0
		if reaper.GetOS() == "Win32" or reaper.GetOS() == "Win64" then
			separator = "\\"
			else
			separator = "/"
		end
		
		while (m~=nil) do
			m, n = string.find(filetxt, separator)
			if m==nil then
				break
			end
			filetxt = string.sub(filetxt, m+1)
		end
		
		m, n = string.find(filetxt, ".wav")
		filetxt = string.sub(filetxt, 1, m-1)
		-- Msg(filetxt)
		--function get_path_bwf_data(var_path)
		--retval, var_path = reaper.GetUserFileNameForRead("", "Select SRT file", "wav")
		var_path = wavfile
		pcm_source = reaper.PCM_Source_CreateFromFile(var_path)
		pcm = reaper.GetMediaSourceSampleRate(pcm_source)
		local fo=0, opchn
		opchn = io.open(var_path, "rb") -- open take's source file to read binary
		bext_found =false
		if opchn ~= false then
			riff_header = opchn:read(4) -- file header
			file_size_buf = opchn:read(4) -- file_size as string
			file_size = string.unpack ("<I4", file_size_buf) -- unpack file_size as unsigned integer, LE
			fo=fo+8
			wave_header = opchn:read(4)
			fo=fo+4
			while not bext_found and fo< file_size do
				chunk_header = opchn:read(4) 
				chunk_size_buf = opchn:read(4)
				chunk_size = string.unpack ("<I4", chunk_size_buf) -- unpack chunk_size as unsigned integer, LE
				fo=fo+8
				if chunk_header ~="bext" then 
					opchn:seek ("cur", chunk_size) -- seek beyond chunk
					else
					-- gfx.printf("chunk header:<%s> chunk size:<%s>", chunk_header, chunk_size)
					-- gfx.x=10 gfx.y=gfx.y+gfx.texth
					bext_found =true -- *set to flat var, calling functions set to tables*
					chunk_data_buf = opchn:read(chunk_size) -- import chunk data as string
					-- process chunk_data_buf
					bext_Description = string.sub(chunk_data_buf, 1, 256)
					bext_Originator = string.sub(chunk_data_buf, 256+1, 256+32)
					bext_OriginatorReference = string.sub(chunk_data_buf, 256+32+1, 256+32+32)
					bext_OriginationDate = string.sub(chunk_data_buf, 256+32+32+1, 256+32+32+10)
					bext_OriginationTime = string.sub(chunk_data_buf, 256+32+32+10+1, 256+32+32+10+8) -- left these "open" to show the obvious structure
					bext_TimeRefLow_buf = string.sub(chunk_data_buf, 256+32+32+10+8+1, 256+32+32+10+8+4) -- SMPTE codes and LUFS data follow these
					bext_TimeRefHigh_buf = string.sub(chunk_data_buf, 256+32+32+10+8+4+1, 256+32+32+10+8+4+4) -- see EBU Tech 3285 v2 etc for more details.
					bext_VersionNum_buf = string.sub(chunk_data_buf, 256+32+32+10+8+4+4+1, 256+32+32+10+8+4+4+2) --
					--gfx.printf("LCDbuf:%d LD:%s OD:%s OT:%s LTRLbuf:%d LTRHbuf:%d", #chunk_data_buf, #bext_Description, bext_OriginationDate, bext_OriginationTime, #bext_TimeRefLow_buf, #bext_TimeRefHigh_buf)
					--gfx.x=10 gfx.y=gfx.y+gfx.texth
					-- I stopped here, but the full set of bext metadata can be retrieved -PM me for further details/help -planetnin
					bext_TimeRefLow = string.unpack ("<I4", bext_TimeRefLow_buf) -- unpack chunk_size as unsigned integer (4-bytes)
					bext_TimeRefHigh = string.unpack ("<I4", bext_TimeRefHigh_buf) -- unpack chunk_size as unsigned integer (4-bytes)
					bext_VersionNum = string.unpack ("<i2", bext_VersionNum_buf) -- unpack chunk_size as signed integer (2-bytes)
					-- combine high & low bytes & sample rate, save offset to table for this bwf_take
					ret_bso = ((bext_TimeRefHigh*4294967295) + bext_TimeRefLow)/pcm--/reaper.GetMediaSourceSampleRate(reaper.GetMediaItemTake_Source(var_path)) --==> for offset in seconds
					--ret_bso = reaper.format_timestr_pos(ret_bso, chunk_data_buf, 4)
					-- *inner function returns to flat variables, "take" and "render" function add to table*
				end
				fo=fo+chunk_size
			end
			opchn:close() -- close file
			else
			bext_found = false
			ret_bso = 0
		end
		reaper.PCM_Source_Destroy(pcm_source)
		ret_bso = reaper.parse_timestr_pos(ret_bso, 5)
		reaper.SetEditCurPos(ret_bso, true, true)
		
        reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWSTL_SHOWALL"), 0)-- SHOW ALL PROJECT TRACKS (LKC CONTENT NAVIGATOR SUPPORT)

		commandID = reaper.NamedCommandLookup("_SWS_AWSELTOEND")
		reaper.Main_OnCommand(commandID, 0) --time selection to end of project
		reaper.Main_OnCommand(40717, 0) --select all items in time selection
		x = reaper.CountSelectedMediaItems(0)
		i=0
		while (i<x) do
			item = reaper.GetSelectedMediaItem(0, i)
			-- take = reaper.GetMediaItemTake(item, 0) --DEPRECATED
			take = reaper.GetActiveTake( item ) --NEW AND SEXY
			--nikolalkc edit
			local its_audio_or_empty_item = 0
			if take ~= nil then 
				its_audio_or_empty_item = 1
				retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
				stringNeedBig = string.gsub (stringNeedBig, "\n", "") --remove newlines
				stringNeedBig = string.gsub (stringNeedBig, "\r", "") --remove newlines
				stringNeedBig = string.gsub(stringNeedBig, "% ", "") -- remove spaces
			else
				local empty_item_note = reaper.ULT_GetMediaItemNote(item)
				-- empty_item_note = string.gsub(empty_item_note, "-", [[:]]) --replace (-) with (:)			--DEPRECATED - no more :
				empty_item_note = string.gsub (empty_item_note, "\n", "")
				empty_item_note = string.gsub (empty_item_note, "\r", "")
				empty_item_note = string.gsub(empty_item_note, "% ", "") -- remove spaces
				if empty_item_note ~= "" or empty_item_note ~= nil then -- ????
					its_audio_or_empty_item = 2
					stringNeedBig = empty_item_note
					-- Msg(stringNeedBig)
				end
			end
			if its_audio_or_empty_item > 0 then
				wavstr = "WAV"
				teststr = string.sub(stringNeedBig, -3)
				teststr = string.upper(teststr)
				if wavstr == teststr then
					stringNeedBig = string.sub(stringNeedBig, 1, -5)
				end
				--nikolalkc edit
				filetxt = string.gsub(filetxt, "% ", "") -- remove spaces
				filetext_with_monkey = [[@]]..filetxt
				
				--remove metadata from wGroup name
				XXX = ParseCSVLine(stringNeedBig,";") --METAPARSE CHARACTER ;
				if XXX[1] then
					XXX[1] =  string.gsub(XXX[1], '^%s*(.-)%s*$', '%1') --start (& end)
					XXX[1] = string.gsub(XXX[1], '[ \t]+%f[\r\n%z]', '')--end
					XXX[1] = string.gsub(XXX[1], "% ", "") -- remove spaces
				end
				--XXX[1] is name of the item before first semicolon (;) sign
				--[[example:
					filename = some_sound.wav
					
					item_name = some_sound					stringNeedBig == filetxt
					item_name = @some_sound					stringNeedBig == filetext_with_monkey
					item_name = some_sound,some metadata	XXX[1] == filetxt
					item_name = @some_sound,some_metadata	XXX[1] = filetext_with_monkey
					
					]]
					-- Msg("QUERY:"..tostring(filetxt))
					-- Msg("@QUERY:"..tostring(filetext_with_monkey))
					-- Msg("stringNeedBig:"..stringNeedBig)
					-- Msg("XXX[1]:"..tostring(XXX[1]))
					-- Msg("")
					if stringNeedBig == filetxt or stringNeedBig == filetext_with_monkey or XXX[1] == filetxt or XXX[1] == filetext_with_monkey then
					-- Msg("FOUND")
					pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
					reaper.GetSet_LoopTimeRange(true, false, ret_bso, ret_bso, false)
					reaper.Main_OnCommand(40289, 0) --unselect all items
					reaper.SetMediaItemSelected(item, true)
					reaper.SetEditCurPos(pos, true, true)
					reaper.adjustZoom(1000, 1, true, -1)
					track = reaper.GetMediaItem_Track(item)
					reaper.Main_OnCommand(40286, 0) --go to previous track
					temptrack = reaper.GetSelectedTrack(0, 0)
					command=40286
					while temptrack~=track do
						reaper.Main_OnCommand(command, 0) --go to previous track
						temptrack2 = reaper.GetSelectedTrack(0, 0)
						if temptrack2==temptrack then
							command=40285
						end
						temptrack=temptrack2
					end
					commandID = reaper.NamedCommandLookup("_WOL_SETVZOOMC_LASTSELTRACK")
					reaper.Main_OnCommand(40913, 0) --zoom vertically
					weallgood=1
					break
				end
			end
			i=i+1
		end
		if weallgood==0 then
			reaper.SelectAllMediaItems(0, true)
			x = reaper.CountSelectedMediaItems(0)
			i=0
			while (i<x) do
				item = reaper.GetSelectedMediaItem(0, i)
				-- take = reaper.GetMediaItemTake(item, 0)--DEPRECATED
				take = reaper.GetActiveTake( item ) --NEW AND SEXY
				--nikolalkc edit
				local its_audio_or_empty_item = 0
				if take ~= nil then 
					its_audio_or_empty_item = 1
					retval, stringNeedBig = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)					
					stringNeedBig = string.gsub (stringNeedBig, "\n", "") --remove newlines
					stringNeedBig = string.gsub (stringNeedBig, "\r", "") --remove newlines
					stringNeedBig = string.gsub(stringNeedBig, "% ", "") -- remove spaces
				else
					local empty_item_note = reaper.ULT_GetMediaItemNote(item)
					-- empty_item_note = string.gsub(empty_item_note, "-", [[:]]) --replace (-) with (:)			- DEPRECATED - no more :
					empty_item_note = string.gsub (empty_item_note, "\n", "")
					empty_item_note = string.gsub (empty_item_note, "\r", "")
					empty_item_note = string.gsub(empty_item_note, "% ", "") -- remove spaces
					if empty_item_note ~= "" or empty_item_note ~= nil then -- ????
						its_audio_or_empty_item = 2
						stringNeedBig = empty_item_note
					end
				end
				if its_audio_or_empty_item > 0 then
					--nikolalkc edit
					filetxt = string.gsub(filetxt, "% ", "") -- remove spaces
					filetext_with_monkey = [[@]]..filetxt
					
					--remove metadata from wGroup name
					XXX = ParseCSVLine(stringNeedBig,";") --METAPARSE CHARACTER ;
					--remove unwanted spaces at start end end
					if XXX[1] then
						XXX[1] =  string.gsub(XXX[1], '^%s*(.-)%s*$', '%1') --start (& end)
						XXX[1] = string.gsub(XXX[1], '[ \t]+%f[\r\n%z]', '')--end
						XXX[1] = string.gsub(XXX[1], "% ", "") -- remove spaces	
					end
					
					
					--XXX[1] is name of the item before first semicolon (;) sign
					--[[example:
						filename = some_sound.wav
						
						item_name = some_sound					stringNeedBig == filetxt
						item_name = @some_sound					stringNeedBig == filetext_with_monkey
						item_name = some_sound,some metadata	XXX[1] == filetxt
						item_name = @some_sound,some_metadata	XXX[1] = filetext_with_monkey
						
						]]
					-- Msg("QUERY:"..tostring(filetxt))
					-- Msg("@QUERY:"..tostring(filetext_with_monkey))
					-- Msg("stringNeedBig:"..stringNeedBig)
					-- Msg("XXX[1]:"..tostring(XXX[1]))
					-- Msg("")
					if stringNeedBig == filetxt or stringNeedBig == filetext_with_monkey or XXX[1] == filetxt or XXX[1] == filetext_with_monkey then
						-- Msg("FOUND SIMILAR")
						pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
						reaper.Main_OnCommand(40289, 0) --unselect all items
						reaper.SetMediaItemSelected(item, true)
						reaper.SetEditCurPos(pos, true, true)
						reaper.adjustZoom(1000, 1, false, -1)
						--commandID = reaper.NamedCommandLookup("_WOL_SETVZOOMC_LASTSELTRACK")
						reaper.Main_OnCommand(40913, 0) --zoom vertically
						reaper.GetSet_LoopTimeRange(true, false, ret_bso, ret_bso, false)
						weallgood=1
						reaper.ShowMessageBox("Timecode Offset doesn't match the file selected, but a clip in this session has the same filename, so perhaps this is the correct one...","Possible Error",0)
						break
					end
				end
				i=i+1
			end
		end
		-- Msg([[WeeAllGood:]]..weallgood)
		if weallgood==0 then
			reaper.Main_OnCommand(40289, 0) --unselect all items
			reaper.GetSet_LoopTimeRange(true, false, ret_bso, ret_bso, false)
			reaper.adjustZoom(1000, 1, false, -1)
			reaper.Main_OnCommand(40913, 0) --zoom vertically
			local BBB = isRegion(ret_bso,filetxt)
			if  BBB == false then
				reaper.ShowMessageBox("Couldn't Find That Filename in the Session...Sorry...","ERROR!!!!!!!",0) 
			else
				edit_pos =  reaper.GetCursorPosition()
				delta_edit_pos = BBB - edit_pos
				
				reaper.MoveEditCursor( delta_edit_pos, false )
				reaper.adjustZoom(1000, 1, false, -1)
				reaper.Main_OnCommand(40913, 0) --zoom vertically
				-- Msg("REGION FOUND:"..BBB)
			end
		end
	end
end
--ORIGINAL SCRIPT ENDS HERE--------------------------------------------------------------------------------------------------------------------

--NIKOLALKC OUTRO
-- focus temp and close
reaper.SelectProjectInstance( TempProject )
reaper.Main_OnCommand(40860,0)	 --close current project tab
reaper.SelectProjectInstance(project)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_HSCROLL10"),0)	 --edit cursor 10%
reaper.Main_OnCommand(40034,0)	 --select all items in group
reaper.PreventUIRefresh(-1)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_SCROLL_ITEM"), 0)-- SWS/S&M: Scroll to selected item (no undo)
reaper.Main_OnCommand(40340,0) -- unsolo all tracks
reaper.UpdateArrange()													