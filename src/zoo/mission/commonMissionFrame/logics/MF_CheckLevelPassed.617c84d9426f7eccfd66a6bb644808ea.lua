MF_CheckLevelPassed = class()

--[[
	--检查玩家第value关的是否为过关状态
	--和MF_PassLevel不同，MF_CheckLevelPassed不要求一定要在接到任务后打过这一关。
	--参数：
	--parameters[1]要求的最低星星数，默认是1
	--parameters[2]比较方式【1】大于等于（默认）【2】小于等于【3】等于 
]]
function MF_CheckLevelPassed:check(condition , context)

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

		if context:getPlace() == TriggerContextPlace.ANY_WHERE then
			local conditionId = condition:getId()
			local parameters = condition:getParameters()
			

			if not parameters or #parameters == 0 then
				parameters = {}
				parameters[1] = 1
				parameters[2] = 1
			end

			local score = UserManager:getInstance():getUserScore(tonumber(targetValue))
			if not score then
				score = ScoreRef.new()
			end

			local hasJumpedLevel = false
			if JumpLevelManager then
				hasJumpedLevel = JumpLevelManager:getInstance():hasJumpedLevel(targetValue)
			end

			local function checkStar(star)
				if tonumber(parameters[2]) == 1 then --大于等于（默认）value
					if ( hasJumpedLevel and parameters[1] == 1 ) or star >= parameters[1] then
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

			

			if score and score.star and checkStar(tonumber(score.star)) then
				result = true
				condition:setCurrentValue( tonumber(-2) )
				HomeScene:sharedInstance().worldScene:clearMissionBubble(targetValue)
				MissionManager:getInstance():removeLevelMissionMap( targetValue , condition:getMissionId() )
			end
		end
		
	end
	
	return result
end

return MF_CheckLevelPassed