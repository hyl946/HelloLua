MF_EnterLevelTpye = class()

--[[
	自接受任务起，进入任意一关LevelTpye为 value 的关卡。
]]
function MF_EnterLevelTpye:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context then

		if context:getPlace() == TriggerContextPlace.START_LEVEL_AND_CREATE_GAME_PLAY_SCENE
			and context:getValue("data") then

			local conditionId = condition:getId()
			local targetValue = condition:getTargetValue()
			local parameters = condition:getParameters()
			local data = context:getValue("data")

			if data and data.levelType and tonumber(data.levelType) == tonumber(targetValue) then
				result = true
			end
		end
	end
	
	return result
end

return MF_EnterLevelTpye