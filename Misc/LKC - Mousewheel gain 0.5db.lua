--[[
  ReaScript Name: Mousewheel gain 0.5 db
  Author: LKC
  REAPER: 5.52
  Version: 1.0
  About:
    Changes gain of selected items with scroll of mouse
    Instructions: First you must have at least on item selected. Then assign this script to some relative command (mousewheel/osc).
    The use your scroll or whatever to change gain of selected items. If none is selected, gain change will be applied only to item
    under mouse cursor.
]]

--[[
 * Changelog:
 * v1.0 (2020-08-05)
	+ Initial Release
]]

--[[ ----- DEBUGGING ===>

]]-- <=== DEBUGGING -----



--UTILITIES
function Msg(param) 
    reaper.ShowConsoleMsg(tostring(param).."\n")
end


------------------------------------------------------------
-- Mod from SPK77
-- http://forum.cockos.com/showpost.php?p=1608719&postcount=6
--Trak_Vol_dB = 20*math.log(val, 10) end
--Trak Vol val = 10^(dB_val/20) end
------------------------------------------------------------


-------------------------------------------------------------
-- item Vol conversion    https://forum.cockos.com/showthread.php?p=2200278#post2200278

-----------------------------------------------------------
local LN10_OVER_TWENTY = 0.11512925464970228420089957273422
function DB2VAL(x) return math.exp(x*LN10_OVER_TWENTY) end

function VAL2DB(x)
  if x < 0.0000000298023223876953125 then
    return -150
  else
    return math.max(-150, math.log(x)* 8.6858896380650365530225783783321); 
  end
end
-----------------------------------------------------------



function run()
	is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
	selected_count = reaper.CountSelectedMediaItems(0)
	if selected_count <= 1 then
		--reaper.Main_OnCommand(40529,0) --select item under mouse leaving other items selected
		reaper.Main_OnCommand(40528,0) --select item under mouse
	end

	if selected_count > 0 then
		for i = 0, selected_count - 1 do
			if is_new then
				--reaper.ShowConsoleMsg(name .. "\nrel: " .. rel .. "\nres: " .. res .. "\nval = " .. val .. "\n")
				local item = reaper.GetSelectedMediaItem( 0,i )

				if item ~= nil then
					vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
					--reaper.ShowConsoleMsg(vol.."\n")
					if val > 0 then --if positive value
						local new_vol = vol*DB2VAL(0.5)
						reaper.SetMediaItemInfo_Value(item, "D_VOL", new_vol )
					else --if it's negative value
						local new_vol = vol/DB2VAL(0.5)
						reaper.SetMediaItemInfo_Value( item, "D_VOL", new_vol )
					end
				end
			end
		end
	end

	--reaper.Main_OnCommand(40441,0) --rebuild peaks
end



reaper.Undo_BeginBlock()
reaper.PreventUIRefresh( 1 )
run() -- run script
reaper.PreventUIRefresh( -1 )
reaper.Undo_EndBlock("LKC - Mousewheel Gain 0.5 db", -1)
reaper.UpdateArrange()
