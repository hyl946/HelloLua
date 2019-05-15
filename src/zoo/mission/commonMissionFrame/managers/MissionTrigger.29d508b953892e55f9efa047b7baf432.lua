-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	Reast.Li
-- Email:	reast.li@happyelements.com
---------------------------------------------------
--[[
					MissionTrigger

	
	MissionTrigger为检测所有任务的进度和完成状态的入口类

	游戏的某些关键操作会调用 MissionTrigger:checkAll() 的方法，以此触发对所有任务的检测操作。
	关键操作是指诸如【登录】【关卡开始】【关卡结束】【摘果子】【签到】等可能对任务进度有影响的操作。
	在关键操作之后调用MissionTrigger:checkAll()方法，任务框架会自动检测任务的进度和完成情况，
	而不需要将判断逻辑代码嵌入原有的业务逻辑中。

	调用MissionTrigger:checkAll()之后，MissionTrigger会通过MissionModel获取到每个正在进行中的任务的MissionData，
	遍历每个 MissionData 的completeConditions，获得当前Mission的某一个 MissionCondition ，
	然后通过 MissionCondition 的id , 映射出一个MissionLogic的实例来检测该条件是否达成。
	如果一个 MissionData的completeConditions中的所有条件都达成，则该任务完成。

	MissionCondition 的 id 到 MissionLogic的映射配置在MissionFrameConfig中。
	所有的MissionLogic都在zoo.mission.commonMissionFrame.logics包下。

]]
---------------------------------------------------

require "zoo.mission.commonMissionFrame.data.TriggerContext"

MissionTrigger = class(EventDispatcher)

local trigger = nil

function MissionTrigger:getInstance( ... )
	if trigger == nil then
		trigger = MissionTrigger.new()
	end
	return trigger
end


local idToLogicMap = MissionFrameConfig.conditionsMap

function MissionTrigger:checkCondition( missionId , condition , context) 

	--遍历配置，看看该condition的id是否存在已定义的MissionLogic
	for k,v in pairs( idToLogicMap or {}) do
		
		--如果找到了该id的logic定义
		if k == tostring("k" .. condition:getId()) then 
			
			local clazz = nil
			local logic = nil
			local result = false

			local function requireLuaClass() 
				--根据配置映射出一个MissionLogic实例
				clazz = require( "zoo/mission/commonMissionFrame/logics/" .. idToLogicMap[k] )

				if clazz then
					logic = clazz.new()
				end

				--任何一个MissionLogic实例都应该实现一个 function MissionLogic:check(condition , context) 的方法
				if logic and logic.check and type(logic.check) == "function" then

					local oldValue = condition:getCurrentValue()
					local oldProgress = condition:getProgress()  --先保存下check之前的进度值

					local logicCheckResult = logic:check(condition , context) --执行条件检测，返回检测结果

					result = logicCheckResult

					--执行check操作之后，如果进度发生了改变，则抛出进度改变的事件
					if condition:getCurrentValue() ~= oldValue then
						--Progress Changed !!
						if _G.isLocalDevelopMode then printx(0, "MF   MissionTrigger:checkCondition  Progress Changed !!  " , condition:getCurrentValue() , oldValue) end
						MissionManager:getInstance():onMissionProgressChanged(condition , oldValue , oldProgress)
					end
				end
			end
			pcall(requireLuaClass)

			if(isLocalDevelopMode) then
				print("MF   MissionTrigger:checkCondition  find logic by conditionId " 
					.. tostring(condition:getId()) .. "    " , tostring(idToLogicMap[k]) .. "    on contextPlace " .. tostring(context:getPlace()) )
			end
			if _G.isLocalDevelopMode then printx(0, "MF   check result " .. tostring(result) ) end

			--返回该条件的检测结果
			return result
		end

	end

	return false
end

function MissionTrigger:checkConditionList( missionId , conditionList , context) 
	local returnResult = true
	if not conditionList then
		return false
	end

	if type(conditionList) ~= "table" then
		return false
	end

	if #conditionList == 0 then
		return true  -- 这是一个约定。#list数量为0表示不需要检测
	end

	--遍历conditionList，一个任务可能包含多个条件，必须所有条件都达成，任务才算完成
	for k,v in pairs( conditionList or {}) do
		if not self:checkCondition( missionId , v , context) then
			returnResult = false  --为什么不直接返回false，因为虽然任意条件未完成，任务就肯定未完成。但剩余的条件有可能会发生进度变更，所以还是要检测
		end
	end

	return returnResult
end


function MissionTrigger:checkOneMissionAccepted(context , id)
	local missionData = MissionModel:getInstance():getMission(id)
	local oldState = missionData:getMissionState()

	if oldState == MissionDataState.UNACCEPTED then

		if self:checkConditionList( id , missionData:getAcceptConditions() , context ) then

			missionData:setMissionState(MissionDataState.STARTED)
			--EventDispatcher
			MissionManager:getInstance():onMissionStateChanged(missionData , oldState)

			return true
		end
		return false
	end
	
	return true
end

function MissionTrigger:checkOneMissionCompleted(context , id)
	local missionData = MissionModel:getInstance():getMission(id)
	local oldState = missionData:getMissionState()
	
	if oldState == MissionDataState.STARTED or oldState == MissionDataState.IN_PROGRESS then

		if self:checkConditionList( id , missionData:getCompleteConditions() , context ) then

			missionData:setMissionState(MissionDataState.COMPLETED)
			--EventDispatcher
			MissionManager:getInstance():onMissionStateChanged(missionData , oldState)

			return true
		end
		return false

	elseif oldState == MissionDataState.UNACCEPTED then
		return false
	end

	return true
end


function MissionTrigger:checkAllUnacceptableMissions(context)
	
	local unacceptableMissions = MissionModel:getInstance():getUnacceptableMissions()

	local missionData = nil

	for k,v in pairs( unacceptableMissions or {}) do

		missionData = v
		
		self:checkOneMissionAccepted( context , missionData:getId() )
	end

end

function MissionTrigger:checkAllRunningMissions(context)

	local runningMissions = MissionModel:getInstance():getRunningMissions()
	
	local missionData = nil

	for k,v in pairs( runningMissions or {}) do

		missionData = v
		
		self:checkOneMissionCompleted( context , missionData:getId() )
	end

end


function MissionTrigger:checkAll(context)

	printx( 1 , "  ============================MissionTrigger:checkAllUnacceptableMissions=================================")
	self:checkAllUnacceptableMissions(context)
	printx( 1 , "  ============================MissionTrigger:checkAllRunningMissions=================================")

	MissionManager:getInstance():clearLevelMissionMap()
	if HomeScene:sharedInstance() then
		HomeScene:sharedInstance().worldScene:clearAllMissionBubble()
	end

	self:checkAllRunningMissions(context)

end

