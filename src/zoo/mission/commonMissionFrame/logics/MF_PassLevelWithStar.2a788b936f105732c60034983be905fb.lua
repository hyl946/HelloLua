MF_PassLevelWithStar = class()

--[[
	自接受任务起，通过第任意一关，且星星数 >= value。
	
	参数：
	parameters[1]比较方式
						【1】大于等于（默认）value
						【2】小于等于value
						【3】等于value
]]
function MF_PassLevelWithStar:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context 
		and context:getPlace() == TriggerContextPlace.OFFLINE
		and context:getValue(kHttpEndPoints.passLevel) then

		local conditionId = condition:getId()
		local targetValue = condition:getTargetValue()
		local parameters = condition:getParameters()
		local data = context:getValue(kHttpEndPoints.passLevel)

		if not parameters or #parameters == 0 then
			parameters = {}
			parameters[1] = 1
		end

		local function checkStar(star)
			if tonumber(parameters[1]) == 1 then --大于等于（默认）value
				if star >= targetValue then
					return true
				end
			elseif tonumber(parameters[1]) == 2 then --小于等于value
				if star <= targetValue then
					return true
				end
			elseif tonumber(parameters[1]) == 3 then  --等于value
				if star == targetValue then
					return true
				end
			end
			return false
		end
		

		if data and data.star and checkStar(tonumber(data.star)) then
			result = true
			condition:setCurrentValue( tonumber(-2) )
		end
	end
	
	return result
end

return MF_PassLevelWithStar