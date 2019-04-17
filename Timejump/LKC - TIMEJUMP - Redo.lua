--[[
  ReaScript Name: TIMEJUMP - Redo
  Author: LKC
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
  NoIndex: true
  About:
    #Redo is faster
]]

--[[
 * Changelog:
 * v1.0 (2018-06-13)
	+ First Version
]]

reaper.PreventUIRefresh( 1 )
reaper.Main_OnCommand(40030,0) --REDO
reaper.PreventUIRefresh( -1 )