MF_ContinuousLoginGame = class()

--[[
	--自接受任务起，连续在线登录value天
]]
function MF_ContinuousLoginGame:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context 
		and context:getPlace() == TriggerContextPlace.ANY_WHERE  then

		local conditionId = condition:getId()
		local targetValue = condition:getTargetValue()
		local parameters = condition:getParameters()

		local missionDailyData = MissionModel:getInstance():getMissionDailyData()

		if condition:getCurrentValue() ~= missionDailyData.continuousLoginDays then
			condition:setCurrentValue( missionDailyData.continuousLoginDays )
		end
		
		if condition:getCurrentValue() >= targetValue then
			result = true
		end
	end
	
	return result
end

return MF_ContinuousLoginGame