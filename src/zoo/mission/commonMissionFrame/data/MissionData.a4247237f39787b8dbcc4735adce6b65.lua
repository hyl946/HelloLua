-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	Reast.Li
-- Email:	reast.li@happyelements.com
---------------------------------------------------
--[[
					MissionData

	
	MissionData为任务系统框架层的基础数据结构。


	任务系统分为三层：
		视图层 - 位于zoo.mission.panels包下，纯视图逻辑，包括UI和动画，
				 入口类为【MissionPanelLogic】
		业务层 - 位于zoo.mission.missionCreator包下，负责封装后端接口，维护本地持久化数据，并根据后端配置执行创建任务的逻辑，
				 入口类为【MissionLogic】
		框架层 - 位于zoo.mission.commonMissionFrame包下，负责将一个业务层的“任务”解析为一组通用的“条件”队列，
				 并在恰当的游戏操作后检测该“条件”的进度是否变更，是否达成。
				 框架层只负责检测任务的进度变更和状态变更（未完成-->已完成）
				 入口类为【MissionManager】

	任务一个业务层的任务都会被CMF_DataConverter转化为一个sourceData，而sourceData最后会被创建为一个MissionData实例。

	一个MissionData主要由以下几部分构成：
		id                      一个任务的唯一标识
		acceptConditions        接受条件列表，类型为 MissionCondition 实例
		completeConditions      完成条件列表，类型为 MissionCondition 实例
		doActions               点击“做任务”按钮操作，类型为 MissionAction 实例
		resultActions           任务完成默认执行的操作，类型为 MissionAction 实例
		missionState           	任务状态，枚举类为 MissionDataState 
		checkState              任务的检测状态，枚举类为 MissionDataCheckState 

]]
---------------------------------------------------

require "zoo.mission.commonMissionFrame.data.MissionCondition"
require "zoo.mission.commonMissionFrame.data.MissionAction"


MissionData = class()

MissionDataState = {
	UNACCEPTED = 1,
	STARTED = 2,
	IN_PROGRESS = 3,
	COMPLETED = 4,
	REWARDED = 5,
	EXPIRED = 6,
}

MissionDataCheckState = {
	ACTIVED = 1,
	INACTIVED = 2,
	ON_PENDING = 3,
}

function MissionData:create(sourceData) 
	local data = MissionData.new()
	data:init()
	data:buildBySourceData(sourceData)
	return data
end

function MissionData:init() 
	
	self.id = 0
	self.acceptConditions = {}
	self.completeConditions = {}
	self.doActions = {}
	self.resultActions = {}
	self.missionState = MissionDataState.UNACCEPTED
	self.checkState = MissionDataCheckState.ACTIVED

end

function MissionData:buildBySourceData(sourceData) 
	if not sourceData then
		return
	end

	self.id = sourceData.id

	for k,v in pairs(sourceData.acceptConditions or {}) do
		self:addAcceptCondition(
			self:createAcceptCondition(v.conditionId , v.targetValue , v.currentValue  , v.parameters , v.extendInfo)
			) 
	end

	for k,v in pairs(sourceData.completeConditions or {}) do
		self:addCompleteCondition(
			self:createCompleteCondition(v.conditionId , v.targetValue , v.currentValue  , v.parameters , v.extendInfo)
			) 
	end

	for k,v in pairs(sourceData.doActions or {}) do
		self:addDoAction(
			self:createDoAction(v.atctionId , v.parameters)
			) 
	end

	for k,v in pairs(sourceData.resultActions or {}) do
		self:addResultAction(
			self:createResultAction(v.atctionId , v.parameters)
			) 
	end

	self.missionState = sourceData.state
end

function MissionData:getId()
	return self.id
end

function MissionData:getAcceptConditions() 
	return self.acceptConditions
end

function MissionData:getCompleteConditions() 
	return self.completeConditions
end

function MissionData:getCompleteConditionProgress() 
	local list = self:getCompleteConditions()
	local missionCondition = nil
	local returnList = {}
	if list and type(list) == "table" then

		for k,v in pairs(list) do
			missionCondition = v
			table.insert( returnList , missionCondition:getProgress() )
		end

		return returnList
	end
end

function MissionData:getResultActions() 
	return self.resultActions
end

function MissionData:getDoActions() 
	return self.doActions
end
-------------------------------------------------------------------------------

function MissionData:addAcceptCondition(condition)
	if condition and type(condition) == "table" then
		table.insert( self.acceptConditions , condition )
		condition:setIndex( #self.acceptConditions )
		condition:setMissionId( self:getId() )
	end
end

function MissionData:createAcceptCondition(conditionId , targetValue , currentValue  , parameters , extendInfo)
	local condition = MissionCondition:create(conditionId , targetValue , currentValue  , parameters , extendInfo)
	return condition
end

function MissionData:addCompleteCondition(condition)
	if condition and type(condition) == "table" then
		table.insert( self.completeConditions , condition )
		condition:setIndex( #self.completeConditions )
		condition:setMissionId( self:getId() )
	end
end

function MissionData:createCompleteCondition(conditionId , targetValue , currentValue  , parameters , extendInfo)
	--printx( 1 , "   @@@@@@@@@@@@@@@@@@@@@@   " , conditionId , targetValue , currentValue)
	local condition = MissionCondition:create(conditionId , targetValue , currentValue  , parameters , extendInfo)
	return condition
end

function MissionData:addDoAction(atction)
	if atction and type(atction) == "table" then
		table.insert( self.doActions , atction )
	end
end

function MissionData:createDoAction(atctionId  , parameters)
	local atction = MissionAction:create(atctionId  , parameters)
	return atction
end

function MissionData:addResultAction(atction)
	if atction and type(atction) == "table" then
		table.insert( self.resultActions , atction )
	end
end

function MissionData:createResultAction(atctionId  , parameters)
	local atction = MissionAction:create(atctionId  , parameters)
	return atction
end


--------------------------------------------------------------------------


function MissionData:getCompleteConditionValueData()
	local list = self:getCompleteConditions()
	local missionCondition = nil
	local returnList = {}
	local valueData = nil
	if list and type(list) == "table" then

		for k,v in pairs(list) do
			missionCondition = v
			valueData = {
				conditionId = missionCondition:getId(),
				missionId = missionCondition:getMissionId(),
				conditionIndex = missionCondition:getIndex(),
				extendInfo = missionCondition:getExtendInfo(),
				current = missionCondition:getCurrentValue(),
				total = missionCondition:getTargetValue(),
				parameters = missionCondition:getParameters(),
			}
			table.insert( returnList , valueData )
		end

		return returnList
	end

	return nil
end

function MissionData:setCompleteConditionCurrentValueByIndex( index , value ) 
	local list = self:getCompleteConditions()
	local missionCondition = nil
	local returnList = {}
	if list and type(list) == "table" then

		missionCondition = list[index]
		
		if missionCondition then
			missionCondition:setCurrentValue(value)
			return {newValue=missionCondition:getCurrentValue() , newProgress=missionCondition:getProgress()}
		end
	end
end

function MissionData:setMissionState(state)
	self.missionState = state
end

function MissionData:getMissionState(state)
	return self.missionState
end