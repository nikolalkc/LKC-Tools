--[[
  ReaScript Name: Move items vertically (mousewheel)
  Author: LKC
  Version: 1.1
  About:
	Moves items up and down based on mousewheel
]]

--[[
 * Changelog:
 * v1.1 (2019-07-30)
	+ Fix title
 * v1.0 (2019-07-30)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----

--UTILITIES
function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end

function run()
	is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
	selected_count = reaper.CountSelectedMediaItems(0)
	-- reaper.ShowConsoleMsg(val.."\n")
	if selected_count > 0 then
		--reaper.ShowConsoleMsg(name .. "\nrel: " .. rel .. "\nres: " .. res .. "\nval = " .. val .. "\n")
		if val > 0 then --if positive value
			reaper.Main_OnCommand(40117,0) --move items up
		else --if it's negative value
			reaper.Main_OnCommand(40118,0) --move items down
		end
	end

	--reaper.Main_OnCommand(40441,0) --rebuild peaks
end



reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
run() -- run script
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("LKC - Mousewheel move items vertically", -1)
reaper.UpdateArrange()
