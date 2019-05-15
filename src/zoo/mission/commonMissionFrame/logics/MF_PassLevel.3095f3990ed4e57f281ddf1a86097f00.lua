MF_PassLevel = class()

--[[
	--自接受任务起，通过第 value 关。
	--参数：
	--parameters[1]星星数要求
	--parameters[2]星星数的比较方式【1】大于等于（默认）【2】小于等于【3】等于
	--parameters[3]剩余步数要求
	--parameters[4]剩余步数的比较方式【1】大于等于（默认）【2】小于等于【3】等于
]]
function MF_PassLevel:check(condition , context)
	
	local result = false

	if not condition then
		return result
	end

	if context then
		local targetValue = condition:getTargetValue()
		local toplv = UserManager:getInstance():getUserRef():getTopLevelId()
		local position = math.floor( condition:getMissionId() / 100000 )
		
		if targetValue and targetValue <= toplv then

			if position == 4 then
				local expireTime = MissionLogic:getInstance():getExpireTime(position)
				if expireTime and expireTime > 9999999999 then
					expireTime = math.floor( expireTime / 1000 )
				end
				if expireTime and expireTime > Localhost:timeInSec() then
					HomeScene:sharedInstance().worldScene:buildMissionBubble(targetValue)
					MissionManager:getInstance():addLevelMissionMap( targetValue , condition:getMissionId() )
				end
			else
				HomeScene:sharedInstance().worldScene:buildMissionBubble(targetValue)
				MissionManager:getInstance():addLevelMissionMap( targetValue , condition:getMissionId() )
			end
		end

		if ( context:getPlace() == TriggerContextPlace.OFFLINE and context:getValue(kHttpEndPoints.passLevel) )
			or ( context:getPlace() == TriggerContextPlace.ONLINE_SETTER and context:getValue(kHttpEndPoints.jumpLevel) )
			then

			local conditionId = condition:getId()
			local parameters = condition:getParameters()
			local data = context:getValue(kHttpEndPoints.passLevel)

			if context:getPlace() == TriggerContextPlace.OFFLINE then
				data = context:getValue(kHttpEndPoints.passLevel)
			else
				data = context:getValue(kHttpEndPoints.jumpLevel)
			end

			if not parameters or #parameters == 0 then
				parameters = {}
			end

			if not parameters[1] then--parameters[1]星星数要求
				parameters[1] = 1
			end
			if not parameters[2] then--parameters[2]星星数的比较方式【1】大于等于（默认）【2】小于等于【3】等于
				parameters[2] = 1
			end
			if not parameters[3] then--parameters[3]剩余步数要求。-1为不要求
				parameters[3] = -1
			end
			if not parameters[4] then--parameters[4]剩余步数的比较方式【1】大于等于（默认）【2】小于等于【3】等于
				parameters[4] = 1
			end


			local function checkStar(star)
				if tonumber(parameters[2]) == 1 then --大于等于（默认）value
					if (star == 0 and parameters[1] == 1) or star >= parameters[1] then
						return true
					end
				elseif tonumber(parameters[2]) == 2 then --小于等于value
					if star <= parameters[1] then
						return true
					end
				elseif tonumber(parameters[2]) == 3 then  --等于value
					if star == parameters[1] then
						return true
					end
				end
				return false
			end


			local function checkStep(step)
				if tonumber(parameters[4]) == 1 then --大于等于（默认）value
					if step >= tonumber(parameters[3]) then
						return true
					end
				elseif tonumber(parameters[4]) == 2 then --小于等于value
					if step <= tonumber(parameters[3]) then
						return true
					end
				elseif tonumber(parameters[4]) == 3 then  --等于value
					if step == tonumber(parameters[3]) then
						return true
					end
				end
				return false
			end

			if data and data.levelId and tonumber(data.levelId) == tonumber(targetValue) then

				local starCheckResult = checkStar(data.star)
				local stepCheckResult = true

				if parameters[3] ~= -1 then

					local leftMoveToWin = MissionModel:getInstance():getLastPlayGameCache().leftMoveToWin
					if not leftMoveToWin then
						leftMoveToWin = 0
					end
					stepCheckResult = checkStep(tonumber(leftMoveToWin))
				end

				if starCheckResult and stepCheckResult then
					result = true
					condition:setCurrentValue( tonumber(-2) )
					HomeScene:sharedInstance().worldScene:clearMissionBubble(targetValue)
					MissionManager:getInstance():removeLevelMissionMap( targetValue , condition:getMissionId() )
				end
			end

		end
	end
	
	return result
end

return MF_PassLevel