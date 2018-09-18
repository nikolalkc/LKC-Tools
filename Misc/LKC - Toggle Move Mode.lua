--[[ ReaScript Name:Toggle move mode
 Author: LKC
 REAPER: 5+
 Extensions: SWS
 Version: 1.10
 About:
  Locks item edges, fades, stretch markers, envelopes and time selection and shows visible large red GUI while locking is activated. 
  This enables you to move items like you have real hand tool.
]]

--[[
 * Changelog:
 * v1.10 (2018-06-22)
	+ Cleaned junk, rename, new meta info
 * v1.03 (2018-05-21)
	+ GUI removed, rectified peaks indicate lock state
 * v1.02 (2018-03-22)
	+ New script name
 * v1.0     (2018-03-22)
	+ Initial Commit
]]

--meat starts here

local locked = reaper.GetToggleCommandState(1135) -- check lock

if locked == 1 then
	--close GUI and disable locking
	GUI_ACTIVE = false
	reaper.Main_OnCommand(40570,0) -- disable locking
	reaper.Main_OnCommand(42307,0) --rectify peaks
else
	reaper.Main_OnCommand(40595,0) -- set item edges lock
	reaper.Main_OnCommand(40598,0) --set item fades lock
	reaper.Main_OnCommand(41852,0) --set item stretch markers lock
	reaper.Main_OnCommand(41849,0) --set item envelope
	reaper.Main_OnCommand(40571,0) --set time selection lock
	reaper.Main_OnCommand(40569,0) --enable locking
	reaper.Main_OnCommand(42307,0) --rectify peaks
	
	reaper.Main_OnCommand(40578,0) --Locking: Clear left/right item locking mode
	reaper.Main_OnCommand(40581,0) --Locking: Clear up/down item locking mode
end

