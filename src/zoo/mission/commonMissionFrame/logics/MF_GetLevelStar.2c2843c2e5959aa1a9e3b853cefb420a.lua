MF_GetLevelStar = class()

--[[
	自接受任务起，累计再收集value颗星星。
]]
function MF_GetLevelStar:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context then

		if context:getPlace() == TriggerContextPlace.OFFLINE
			and context:getValue(kHttpEndPoints.passLevel) then

			local conditionId = condition:getId()
			local targetValue = condition:getTargetValue()
			local parameters = condition:getParameters()
			local data = context:getValue(kHttpEndPoints.passLevel)

			local toplv = UserManager:getInstance():getUserRef():getTopLevelId()

			if data and data.star and data.levelId < 20000 then --仅计算主线关卡和隐藏关卡

				local score = UserManager:getInstance():getUserScore(data.levelId)
				if not score then
					score = ScoreRef.new()
				end
				

				if data.star > score.star then

					if tonumber(condition:getCurrentValue()) + tonumber(data.star - score.star) > targetValue then
						condition:setCurrentValue( tonumber(targetValue) )
					else
						condition:setCurrentValue( tonumber(condition:getCurrentValue()) + tonumber(data.star - score.star) )
					end
				end

				if condition:getCurrentValue() >= targetValue then
					result = true
				end
			end
		end
	end
	
	return result
end

return MF_GetLevelStar