--[[
  ReaScript Name: Count MIDI notes in project
  Author: LKC
  Version: 1.0
  About:
    All midi items must be visible. It counts only active takes.
]]

--[[
 * Changelog:
 * v1.0 (2019-01-09)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----


--UTILITIES
function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end

reaper.Main_OnCommand(40182,0) -- select all items
selected_count = reaper.CountSelectedMediaItems(0)

MIDI_NOTE_COUNT = 0
for i = 0, selected_count - 1 do
    local cur_item = reaper.GetSelectedMediaItem(0,i)
    local cur_take = reaper.GetActiveTake(cur_item) 
    local retval, notecnt, ccevtcnt, textsyxevtcnt = reaper.MIDI_CountEvts( cur_take )
    MIDI_NOTE_COUNT = MIDI_NOTE_COUNT + notecnt
end

Msg("MIDI note count: "..MIDI_NOTE_COUNT)
