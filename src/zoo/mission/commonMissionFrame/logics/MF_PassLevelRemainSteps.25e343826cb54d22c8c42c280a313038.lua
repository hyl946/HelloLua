require "zoo.util.FUUUManager"
MF_PassLevelRemainSteps = class()

--[[
	自接受任务起，通过第任意一关，且剩余步数 >= value。
	
	参数：
	parameters[1]比较方式
						【1】大于等于（默认）value
						【2】小于等于value
						【3】等于value
]]
function MF_PassLevelRemainSteps:check(condition , context)
	
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

		local function checkStep(step)
			if tonumber(parameters[1]) == 1 then --大于等于（默认）value
				if step >= targetValue then
					return true
				end
			elseif tonumber(parameters[1]) == 2 then --小于等于value
				if step <= targetValue then
					return true
				end
			elseif tonumber(parameters[1]) == 3 then  --等于value
				if step == targetValue then
					return true
				end
			end
			return false
		end
		
		local leftMoveToWin = MissionModel:getInstance():getLastPlayGameCache().leftMoveToWin
		if not leftMoveToWin then
			leftMoveToWin = 0
		end
		if checkStep(tonumber(leftMoveToWin)) then
			result = true
			condition:setCurrentValue( tonumber(-2) )
		end
	end
	
	return result
end

return MF_PassLevelRemainSteps