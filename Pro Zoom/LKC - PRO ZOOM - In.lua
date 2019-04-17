--[[
  ReaScript Name: ProZoom
  Author: LKC
  REAPER: 5+
  Version: 1.6
  Provides:
   [Main] LKC - PRO ZOOM - Out.lua
  About:
    # Pro Tools like zoom in & out
    Zooms more like *Protools* when *T* & *R* key pressed.
]]

--[[
 * Changelog:
 * v1.6 (2018-06-24)
  + Version and info fix
 * v1.5 (2018-06-24)
  + Package Created
 * v1.4 (2017-12-29)
  + INFO ADDED
 * v1.3 (2017-12-28)
  + Link added
 * v1.2 (2017-12-28)
  + About section added
 * v1.1 (2017-06-13)
  + Support for horizontal zoom center to edit cursor
 * v1.0 (2017-05-31)
  + Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

--MEAT

--MAIN FUNCTION
function Main()
	reaper.PreventUIRefresh( 1 )

	reaper.Main_OnCommand(reaper.NamedCommandLookup("_WOL_SETHZOOMC_EDITCUR"),0) --SWS/wol: Options - Set "Horizontal zoom center" to "Edit cursor"
	reaper.Main_OnCommand(1012,0) --zoom in horizontal
	reaper.Main_OnCommand(1012,0) --zoom in horizontal
	reaper.Main_OnCommand(1012,0) --zoom in horizontal
	--reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_HSCROLL10"),0) --SWS: Horizontal scroll to put edit cursor at 10%
	reaper.PreventUIRefresh( -1 )
end
--RUN
Main()
