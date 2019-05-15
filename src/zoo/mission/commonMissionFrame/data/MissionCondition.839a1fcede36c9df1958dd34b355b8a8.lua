-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	Reast.Li
-- Email:	reast.li@happyelements.com
---------------------------------------------------
--[[
					MissionCondition

	
	MissionCondition用来描述一个条件，这个条件可以是任务的完成条件，也可以是任务的接受条件

	任务一个业务层的任务都会被CMF_DataConverter转化为一个sourceData，而sourceData最后会被创建为一个MissionData实例。
	每个MissionData的completeConditions列表里都应该至少包含一个MissionCondition

	一个MissionCondition主要由以下几部分构成：
		id                条件类型，枚举在 MissionFrameConfig.conditionsMap 里
		targetValue       该条件的目标值。具体的意义，也是在 MissionFrameConfig.conditionsMap 里定义的
		currentValue      该条件的当前进度值。
		parameters        该条件的参数列表。
		extendInfo        扩展信息。

]]
---------------------------------------------------

MissionCondition = class()

function MissionCondition:create(id , targetValue , currentValue , parameters , extendInfo)
	local condition = MissionCondition.new()
	condition:init(id , targetValue , currentValue , parameters , extendInfo)
	return condition
end

function MissionCondition:init(id , targetValue , currentValue , parameters , extendInfo)
	self.conditionId = id

	self.targetValue = tonumber(targetValue) or 0
	self.currentValue = 0
	self.parameters = parameters or {}

	self:setCurrentValue(tonumber(currentValue))

	self.index = 1
	self.missionId = 0
	self.extendInfo = extendInfo
end

function MissionCondition:getId()
	return self.conditionId
end

function MissionCondition:getTargetValue()
	return self.targetValue
end

function MissionCondition:getCurrentValue()
	return self.currentValue
end

function MissionCondition:setCurrentValue(value)
	self.currentValue = value or 0
	self.progress = tonumber(self.currentValue / self.targetValue)
	if self.progress > 1 then
		self.progress = 1
	elseif self.progress > 1 then
		self.progress = 0
	end
end

function MissionCondition:getProgress()
	return self.progress
end

function MissionCondition:getParameters()
	return self.parameters
end

function MissionCondition:getIndex()
	return self.index
end

function MissionCondition:setIndex(index)
	self.index = index
end

function MissionCondition:getMissionId()
	return self.missionId
end

function MissionCondition:setMissionId(id)
	self.missionId = id
end

function MissionCondition:getExtendInfo()
	return self.extendInfo
end

function MissionCondition:setExtendInfo(data)
	self.extendInfo = data
end