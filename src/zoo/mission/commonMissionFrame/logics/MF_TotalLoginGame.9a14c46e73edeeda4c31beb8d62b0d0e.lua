MF_TotalLoginGame = class()

--[[
	--自接受任务起，累计在线登录value天
]]
function MF_TotalLoginGame:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context 
		and context:getPlace() == TriggerContextPlace.ANY_WHERE then

		local conditionId = condition:getId()
		local targetValue = condition:getTargetValue()
		local parameters = condition:getParameters()

		local missionDailyData = MissionModel:getInstance():getMissionDailyData()

		if missionDailyData and missionDailyData.todayIsOnlineLogin and not missionDailyData.todayChecked then
			local currValue = condition:getCurrentValue()
			if currValue < targetValue then
				condition:setCurrentValue( currValue + 1 )
			end
			missionDailyData.todayChecked = true
			MissionModel:getInstance():flushMissionDailyData()
		end

		if condition:getCurrentValue() >= targetValue then
			result = true
		end
	end
	
	return result
end

return MF_TotalLoginGame