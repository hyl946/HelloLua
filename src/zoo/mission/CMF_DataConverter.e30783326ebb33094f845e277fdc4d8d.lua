CMF_DataConverter = {}

--[[

metaData = {
	id = 0,
	type = 2,
	state = 1(MissionState.kStart),
	rewards = {{itemId = 2, num = 100}},
	extraRewards = {{itemId = 2, num = 100}},
	createTime = Localhost:time(),
	finishTime = 0,
	condition = {{4, 2}, {1, 2},}
	progress = {{current = 1, total = 3},{current = 1, total = 3}}
}


souceData = {
	id = 108 ,
	state = 2 ,
	acceptConditions = {} ,
	completeConditions = {
		[1] = { conditionId = 10001 , 
				targetValue = 15 ,  
				currentValue = 0 , 
				parameters = {
								[1] = 3 ,
							} ,
				extendInfo = 1,
				} ,
	} ,
	doAction = {} ,
	resultActions = {} ,
}


]]

function CMF_DataConverter:getCMFSourceData(metaData , isSpecialMission)
	local sourceData = {}

	if not metaData then
		return nil
	end

	local function isSpecialMissionExpired(datas)

		if not isSpecialMission then
			return false
		end

		local specialMissionDuration = math.floor( MissionLogic:getInstance():getSpecialMissionDuration() / 1000 )
		local specialMissionCreateTime = datas.createTime
		if specialMissionCreateTime and specialMissionCreateTime > 0 then
			if specialMissionCreateTime > 9999999999 then
				specialMissionCreateTime = math.floor( specialMissionCreateTime / 1000 )
			end

			if specialMissionCreateTime + specialMissionDuration < Localhost:timeInSec() then
				return true
			end
		end

		return false
	end
	sourceData.id = metaData.id
	if metaData.state == 1 or metaData.state == 2 then
		
		if isSpecialMissionExpired(metaData) then
			sourceData.state = MissionDataState.COMPLETED
		else
			sourceData.state = MissionDataState.STARTED
		end
	else
		sourceData.state = MissionDataState.COMPLETED
	end
	
	sourceData.acceptConditions = {}
	sourceData.completeConditions = {}
	sourceData.doActions = {}
	sourceData.resultActions = {}

	local condition = nil
	local toplv = UserManager:getInstance():getUserRef():getTopLevelId()
	local score = UserManager:getInstance():getUserScore(toplv)
	if not score then
		score = ScoreRef.new()
	end

	local doAction = nil

	if metaData.type == 1 then
		--通过toplevel
		local totalValue = nil
		if metaData.progress and metaData.progress[1] then
			totalValue = metaData.progress[1].total
		end

		if not totalValue then
			if score.star == 0 then
				totalValue = toplv
			else
				totalValue = toplv + 1
			end
		end
		
		condition = {
			conditionId = 10002 ,
			targetValue = tonumber(totalValue) ,
			currentValue = -1 ,
			parameters = {} ,
			extendInfo = 1,
		}

		condition.parameters[1] = 1
		condition.parameters[2] = 1
		table.insert( sourceData.completeConditions , condition )

		doAction = {
			atctionId = 30002 ,
			parameters = {[1]=totalValue} ,
		}	
		table.insert( sourceData.doActions , doAction )


	elseif metaData.type == 2 or metaData.type == 3 then
		--几星过关
		local arr = nil
		if metaData and metaData.condition and metaData.condition[1] then
			arr = metaData.condition[1]
		end

		if arr then
			condition = {
				conditionId = 10002 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = -1 ,
				parameters = {} ,
				extendInfo = 1,
			}

			condition.parameters[1] = tonumber(arr[2])
			condition.parameters[2] = 1
			table.insert( sourceData.completeConditions , condition )

			doAction = {
				atctionId = 30002 ,
				parameters = {[1]=tonumber(arr[1])} ,
			}	
			table.insert( sourceData.doActions , doAction )
		else
			return nil
		end
	
	elseif metaData.type == 4 then
		--过关剩余步数大于n  --id 752
		local arr = nil
		if metaData and metaData.condition and metaData.condition[1] then
			arr = metaData.condition[1]
		end

		if arr then
			condition = {
				conditionId = 10001 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = -1 ,
				parameters = {} ,
				extendInfo = 1,
			}

			condition.parameters[1] = 1
			condition.parameters[2] = 1
			condition.parameters[3] = tonumber(arr[2]) 
			condition.parameters[4] = 1
			table.insert( sourceData.completeConditions , condition )

			doAction = {
				atctionId = 30002 ,
				parameters = {[1]=tonumber(arr[1])} ,
			}	
			table.insert( sourceData.doActions , doAction )
		else
			return nil
		end
	elseif metaData.type == 5 then
		--进入周赛关卡  testId 768

		condition = {
			conditionId = 10005 ,
			targetValue = GameLevelType.kSummerWeekly ,
			currentValue = -1 ,
			parameters = {} ,
			extendInfo = 1,
		}
		table.insert( sourceData.completeConditions , condition )

		doAction = {
			atctionId = 30003 ,
			parameters = {} ,
		}	
		table.insert( sourceData.doActions , doAction )

	elseif metaData.type == 6 then
		--采摘金银果实
		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			end
		end

		local arr = nil
		if metaData and metaData.condition and metaData.condition[1] then
			arr = metaData.condition[1]
		end

		if arr then
			condition = {
				conditionId = 10041 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			condition.parameters[1] = 0
			table.insert( sourceData.completeConditions , condition )

			doAction = {
				atctionId = 30004 ,
				parameters = {} ,
			}	
			table.insert( sourceData.doActions , doAction )
		else
			return nil
		end

	elseif metaData.type == 7 then
		--获得12个星星
		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			else
				currValue = 0
			end
		end

		if arr and currValue then
			condition = {
				conditionId = 10009 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			table.insert( sourceData.completeConditions , condition )

			doAction = {
				atctionId = 30001 ,
				parameters = {} ,
			}	
			table.insert( sourceData.doActions , doAction )
		else
			return nil
		end
	elseif metaData.type == 8 then

		--自接受任务起，连续登录value天

		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			end
		end

		if arr and currValue then
			condition = {
				conditionId = 10021 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			table.insert( sourceData.completeConditions , condition )

			--[[
			doAction = {
				atctionId = 30001 ,
				parameters = {} ,
			}

			table.insert( sourceData.doActions , doAction )
			]]
		else
			return nil
		end

	elseif metaData.type == 9 then
		--自接受任务起，搜集value个西瓜

		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			end
		end

		if arr then
			condition = {
				conditionId = 10031 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			condition.parameters[1] = ItemType.KWATER_MELON
			table.insert( sourceData.completeConditions , condition )

			doAction = {
				atctionId = 30001 ,
				parameters = {} ,
			}	
			table.insert( sourceData.doActions , doAction )
		else
			return nil
		end
	elseif metaData.type == 10 then
		--自接受任务起，连续签到value天

		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			end
		end

		if arr and currValue then
			condition = {
				conditionId = 10025 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			table.insert( sourceData.completeConditions , condition )

		else
			return nil
		end

	elseif metaData.type == 11 then
		--自接受任务起，累计联网登录value天

		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			end
		end

		if arr and currValue then
			condition = {
				conditionId = 10023 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			table.insert( sourceData.completeConditions , condition )

		else
			return nil
		end

	elseif metaData.type == 12 then
		--自接受任务起，累计签到value天

		local arr = nil
		local currValue = 0
		if metaData then
			if metaData.condition and metaData.condition[1] then
				arr = metaData.condition[1]
			end

			if metaData.progress and metaData.progress[1] then
				currValue = metaData.progress[1].current
			end
		end

		if arr and currValue then
			condition = {
				conditionId = 10026 ,
				targetValue = tonumber(arr[1]) ,
				currentValue = tonumber(currValue) ,
				parameters = {} ,
				extendInfo = 1,
			}

			table.insert( sourceData.completeConditions , condition )

		else
			return nil
		end

	else
		return nil
	end

	return sourceData
end