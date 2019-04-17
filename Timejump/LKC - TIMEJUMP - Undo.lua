--[[
  ReaScript Name: TIMEJUMP - Undo/Redo
  Author: LKC
  REAPER: 5+
  Extensions: SWS
  Version: 1.30
  Provides: [main] LKC - TIMEJUMP - Redo.lua
  About:
    #Undo is faster
]]

--[[
 * Changelog:
 * v1.30 (2018-06-28)
	+ Package Created
 * v1.21 (2018-06-13)
	+ Redo does redo
 * v1.2 (2018-06-13)
	+ Fixed title and redo added to action list
 * v1.1 (2018-06-13)
	+ Redo added to package
 * v1.0 (2018-06-13)
	+ First Version
]]

reaper.PreventUIRefresh( 1 )
reaper.Main_OnCommand(40029,0) --UNDO
reaper.PreventUIRefresh( -1 )
