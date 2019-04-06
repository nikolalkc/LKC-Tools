--[[
	NoIndex: true
]]

local state = tonumber(reaper.GetExtState("LKC_TOOLS","hover_editing_state"))
if state == nil then state = 1 end

if state == 0 then
	state = 1
elseif state == 1 then
	state = 0
end

reaper.SetExtState("LKC_TOOLS","hover_editing_state",state,true)
local self = ({reaper.get_action_context()})[4]
reaper.SetToggleCommandState(0, self, state)