--[[
  Noindex: true
  Instructions:Select takes and run the script, you should get original sounds
  Author: LKC
  REAPER: 5+
  Extensions: SWS
  Version: 1.0
]]

--[[
 * Changelog:
 * v1.0 (2018-05-10)
	+ Initial Release
--]]

local selitems = reaper.CountSelectedMediaItems(0)
if selitems > 0 then
	for i = 0, selitems - 1 do
		local item = reaper.GetSelectedMediaItem( 0, i)
		local take = reaper.GetActiveTake( item )
		
		
		--pitch
		reaper.SetMediaItemTakeInfo_Value( take, "D_PITCH", 0)
		
		--rate
		reaper.SetMediaItemTakeInfo_Value( take, "D_PLAYRATE", 1)
		
	end
end

reaper.UpdateArrange()