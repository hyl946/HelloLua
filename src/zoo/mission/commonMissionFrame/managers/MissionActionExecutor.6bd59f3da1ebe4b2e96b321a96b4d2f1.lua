MissionActionExecutor = class()

local idToActionMap = MissionFrameConfig.actionsMap

function MissionActionExecutor:getInstance( ... )
	if executor == nil then
		executor = MissionActionExecutor.new()
	end
	return executor
end

function MissionActionExecutor:doAction(missionAction , context)

	for k,v in pairs( idToActionMap or {}) do

		if k == tostring("k" .. missionAction:getId()) then 
			
			local clazz = nil
			local action = nil
			local result = false

			local function requireLuaClass() 
				clazz = require( "zoo/mission/commonMissionFrame/actions/" .. idToActionMap[k] )
				if clazz then
					action = clazz.new()
				end

				if action and action.doAction and type(action.doAction) == "function" then

					action:doAction(missionAction , context)

				end
			end
			pcall(requireLuaClass)

			return
		end
	end

end


function MissionActionExecutor:doActionByList(actions , context)

	local returnResult = true
	if not actions then
		return false
	end

	if type(actions) ~= "table" then
		return false
	end

	if #actions == 0 then
		return
	end

	for k,v in pairs( actions or {}) do
		self:doAction(v , context)
	end

end