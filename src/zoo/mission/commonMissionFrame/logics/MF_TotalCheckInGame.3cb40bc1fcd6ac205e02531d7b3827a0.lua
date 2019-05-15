MF_TotalCheckInGame = class()

--[[
	自接受任务起，累计签到value天
]]
function MF_TotalCheckInGame:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context 
		and context:getPlace() == TriggerContextPlace.ONLINE_SETTER
		and context:getValue(kHttpEndPoints.mark) then

		local conditionId = condition:getId()
		local targetValue = condition:getTargetValue()
		local parameters = condition:getParameters()
		local data = context:getValue(kHttpEndPoints.mark)


		if condition:getCurrentValue() + 1 > targetValue then
			condition:setCurrentValue( targetValue )
		else
			condition:setCurrentValue( condition:getCurrentValue() + 1 )
		end
		
		if condition:getCurrentValue() >= targetValue then
			result = true
		end
	end
	
	return result
end

return MF_TotalCheckInGame