--[[
  Noindex:true
  ReaScript Name: PRO ZOOM - Out
  Author: LKC
  REAPER: 5+
  Version: 1.1
    
]]

--[[
 * Changelog:
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
	reaper.Main_OnCommand(1011,0) --zoom out horizontal
	reaper.Main_OnCommand(1011,0) --zoom out horizontal
	reaper.Main_OnCommand(1011,0) --zoom out horizontal
    -- reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_HSCROLL10"),0) --SWS: Horizontal scroll to put edit cursor at 10%
	reaper.PreventUIRefresh( -1 )
end
--RUN
Main()
