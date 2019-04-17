--[[
  ReaScript Name: Declutter
  Author: LKC
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
  About:
    #Close all midi editor and floating windows with one keystroke
]]

--[[
 * Changelog:
 * v1.0 (2018-06-13)
	+ First Version
]]


--CLOSE MIDI
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SN_FOCUS_MIDI_EDITOR"),0) --SWS/SN: Focus MIDI editor
hwnd = reaper.MIDIEditor_GetActive()
reaper.MIDIEditor_OnCommand(hwnd,2) --close midi editor

--close others
reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNMAIN_HIDE_OTHERS"),0) --SWS/S&M: Focus main window (close others)