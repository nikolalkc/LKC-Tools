--[[
  ReaScript Name: Select Next Track For Importing
  Author: LKC
  REAPER: 5.0 pre 40
  Version: 1.3
  Provides: [main=mediaexplorer] LKC - Select next track for importing.lua
  About:
    Assign this script to a key in MediaExporer Section of ActionList. After running this script. Edit cursor goes back to start of selected item.
    After that next track is selected. This allows you to double click on item in media exploerer and it will be imported one track under last selected item,
    rather than selected item's track.
    NOTE: Depends on Script: nikolalkc - Move Edit Cursor To Item Start.lua, change your ID if it doesn't work.
]]

--[[
 * Changelog:
	* v1.3 (2020-11-27)
		+ Removed dependancy script
	* v1.2 (2018-06-22)
		+ Rename and new meta
	* v1.1 (2017-06-13)
		+ Support for horizontal zoom center to edit cursor
	* v1.0 (2017-05-31)
		+ Initial Release
]]

selected_item = reaper.GetSelectedMediaItem(0,0)
-- reaper.ShowConsoleMsg("test")
if selected_item == nil then
	-- Msg("nothing selected")
else
	item_pos = reaper.GetMediaItemInfo_Value(selected_item,"D_POSITION")
	reaper.SetEditCurPos( item_pos, true, false)
end
reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"),0) --SWS: Select only track(s) with selected item(s)
reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELNEXTTRACK"),0) --Xenakios/SWS: Select next tracks
reaper.Main_OnCommand(40289,0) --Track: Unselect all items
reaper.UpdateArrange()
