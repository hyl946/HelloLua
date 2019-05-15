-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	Reast.Li
-- Email:	reast.li@happyelements.com
---------------------------------------------------
--[[
					MissionManager

	
	MissionManager为【CommonMissionFrame】的入口类。


	任务系统分为三层：
		视图层 - 位于zoo.mission.panels包下，纯视图逻辑，包括UI和动画，
				 入口类为【MissionPanelLogic】
		业务层 - 位于zoo.mission.missionCreator包下，负责封装后端接口，维护本地持久化数据，并根据后端配置执行创建任务的逻辑，
				 入口类为【MissionLogic】
		框架层 - 位于zoo.mission.commonMissionFrame包下，负责将一个业务层的“任务”解析为一组通用的“条件”队列，
				 并在恰当的游戏操作后检测该“条件”的进度是否变更，是否达成。
				 框架层只负责检测任务的进度变更和状态变更（未完成-->已完成）
				 入口类为【MissionManager】

		Wiki地址：http://wiki.happyelements.net/pages/viewpage.action?pageId=20262811

]]
---------------------------------------------------

require "hecore.EventDispatcher"
require "zoo.mission.commonMissionFrame.data.MissionFrameConfig"
require "zoo.mission.commonMissionFrame.managers.MissionTrigger"
require "zoo.mission.commonMissionFrame.managers.MissionActionExecutor"
require "zoo.mission.commonMissionFrame.data.MissionModel"
require "zoo.mission.CMF_DataConverter"


MissionManager = class(EventDispatcher)


local manager = nil 

MissionFrameEvent = {
	kProgressChanged = "missionFrame_progressChanged",
	kStateChanged = "missionFrame_stateChanged",
	kGetReward = "missionFrame_getReward",
}

MissionModelReturnCode = {
	
	kSuccess = 0,
	kSameMissionExist = 1,
	kSourceDataIsUnlegal = 2,
	kCannotFindMissionByID = 3,

}

function MissionManager:getInstance( ... )
	if not manager then
		manager = MissionManager.new()
		manager.levelMissionMap = {}
	end

	return manager
end

local function now( ... )
	return os.time() + (__g_utcDiffSeconds or 0)
end

function MissionManager:init( rootView )
	manager.rootView = rootView
end

--[[
	将一个业务层的【任务数据】转化为一个框架层的【任务数据】
	为什么要有两种任务数据结构？请看以下伪代码：

	【业务层任务数据】
		id:105
		type:通过最高关卡
		condition:无

		|	转化	|
		V 			V

	【框架层任务数据】
		id:100105
		condition_1     : 检测第{target}关的星级
		parameters_1_1  : 1 (代表1颗星)
		parameters_1_2  : 1 (代表检测规则是大于等于)




	【业务层任务数据】
		id:106
		type:三星通过205关
		condition:205,3

		|	转化	|
		V 			V

	【框架层任务数据】
		id:100106
		condition_1     : 检测第{205}关的星级
		parameters_1_1  : 3 (代表1颗星)
		parameters_1_2  : 1 (代表检测规则是大于等于)



	【业务层任务数据】
		id:107
		type:进入一次周赛关卡
		condition:无

		|	转化	|
		V 			V

	【框架层任务数据】
		id:100107
		condition_1     : 进入任意一关LevelTpye为 {target} 的关卡（target = ItemType.KWATER_MELON）
		parameters_1_1  : 无
		parameters_1_2  : 无

]]
function MissionManager:createSouceData( data )

	local missionSouceData = CMF_DataConverter:getCMFSourceData(data)

	return missionSouceDatas
end

--[[========================================================
根据souceData创建一个Mission并添加至检测列表里。
Mission一旦创建，框架会根据其配置信息不断的检测其完成进度。
一旦进度变更，则会抛出 MissionFrameEvent.kProgressChanged 和 MissionFrameEvent.kStateChanged（如果有） 事件
注意：相同的id的任务第二次添加将被忽略

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
--==========================================================]]
function MissionManager:addMission( souceData )
	return MissionModel:getInstance():addMission( souceData.id , souceData )
end

--[[
移除一个任务，被移除的任务将不再检测
]]
function MissionManager:removeMission( id )
	return MissionModel:getInstance():removeMission( id )
end

--[[
获取一个任务的当前数据
]]
function MissionManager:getMission(id)
	return MissionModel:getInstance():getMission(id)
end

--[[
获取一个任务的当前状态，状态枚举在 MissionDataState 里
]]
function MissionManager:getMissionState(id)
	local mission = MissionModel:getInstance():getMission(id)
	if mission then
		return mission:getMissionState()
	end
	return nil
end

--[[
获取一个任务的检测状态，状态枚举在 MissionDataCheckState 里
]]
function MissionManager:getMissionCheckState(id)
	local mission = MissionModel:getInstance():getMission(id)
	if mission then
		return mission.checkState
	end
	return nil
end

--[[
获取所有任务中，包含conditionIds条件的任务
]]
function MissionManager:getMissionsByContainConditions(conditionIds)
	return MissionModel:getInstance():getMissionsByContainConditions(conditionIds)
end

--[[
获取所有不可接受的任务（即接受条件未达成）
]]
function MissionManager:getUnacceptableMissions()
	return MissionModel:getInstance():getUnacceptableMissions()
end

--[[
获取所有进行中的任务
]]
function MissionManager:getRunningMissions()
	return MissionModel:getInstance():getRunningMissions()
end

--[[
获取所有已完成的任务
]]
function MissionManager:getCompletedMissions()
	return MissionModel:getInstance():getCompletedMissions()
end

--[[
获取所有已领奖的任务
]]
function MissionManager:getRewardedMissions()
	return MissionModel:getInstance():getRewardedMissions()
end

-------------------------------------------------------------------------------------
--[[
获取一个任务所有的完成进度
]]
function MissionManager:getMissionCompleteConditionProgress(missionId)
	local mission = self:getMission(missionId)

	if mission then
		return mission:getCompleteConditionProgress()
	end

	return nil
end

--[[
根据index获取某个任务的一个完成进度
]]
function MissionManager:getMissionCompleteConditionProgressByIndex(missionId , index) 
	local progressList = self:getMissionCompleteConditionProgress(missionId)

	if progressList then
		return progressList[index]
	end

	return nil
end

--[[
valueData = {
				conditionId = missionCondition:getId(),
				missionId = missionCondition:getMissionId(),
				conditionIndex = missionCondition:getIndex(),
				extendInfo = missionCondition:getExtendInfo(),
				current = missionCondition:getCurrentValue(),
				total = missionCondition:getTargetValue(),
			}
]]
function MissionManager:getMissionCompleteConditionValueData(missionId)
	local mission = self:getMission(missionId)

	if mission then
		return mission:getCompleteConditionValueData()
	end

	return nil
end

function MissionManager:getMissionCompleteConditionValueDataByIndex(missionId , index) 
	local valueList = self:getMissionCompleteConditionValueData(missionId)

	if valueList then
		return valueList[index]
	end

	return nil
end

function MissionManager:setMissionCompleteConditionCurrentValueByIndex(missionId , index , value) 
	local mission = self:getMission(missionId)

	if mission then
		return mission:setCompleteConditionCurrentValueByIndex(index , value)
	end
end
-------------------------------------------------------------------------------------

--[[
对所有任务执行一次检测，如果有任务的进度发生变化，则会抛出
MissionFrameEvent.kProgressChanged 和 MissionFrameEvent.kStateChanged（如果有） 事件
]]
function MissionManager:checkAll(context)
	if not context then
		context = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
	end
	MissionTrigger:getInstance():checkAll(context)
end

--[[
检测某一个任务是否可以开启
]]
function MissionManager:checkOneMissionAccepted(context , id)
	MissionTrigger:getInstance():checkOneMissionAccepted(context , id)
end

--[[
检测某一个任务是否可以完成
]]
function MissionManager:checkOneMissionCompleted(context , id)
	MissionTrigger:getInstance():checkOneMissionCompleted(context , id)
end

-------------------------------------------------------------------------------------

function MissionManager:onMissionStateChanged(missionData , oldState)
	self:dispatchEvent({
		name = MissionFrameEvent.kStateChanged,
		data = {
				missionId = missionData:getId() , 
				oldState = oldState , 
				newState = missionData:getMissionState()
				},
		target = self
	})
	if _G.isLocalDevelopMode then printx(0, "MF   MissionFrameEvent.kStateChanged  id = " .. tostring(missionData:getId()) ) end
end

function MissionManager:onMissionProgressChanged(condition , oldValue , oldProgress)
	self:dispatchEvent({
		name = MissionFrameEvent.kProgressChanged,
		data = {
				missionId = condition:getMissionId() , 
				conditionId = condition:getId(),
				conditionIndex = condition:getIndex(),
				extendInfo = condition:getExtendInfo(),
				oldProgress = oldProgress , 
				newProgress = condition:getProgress(),
				oldValue = oldValue,
				newValue = condition:getCurrentValue(),
				targetValue = condition:getTargetValue(),
				},
		target = self
	})
	if _G.isLocalDevelopMode then printx(0, "MF   MissionFrameEvent.kProgressChanged  id = " .. tostring(condition:getMissionId()) ) end
end

---------------------------------------------------------------------------------

function MissionManager:addLevelMissionMap(level , missionId )
	printx( 1 , "   MissionManager:addLevelMissionMap    " , level , missionId)
	if not self.levelMissionMap[level] then
		self.levelMissionMap[level] = {}
	end

	local t = self.levelMissionMap[level]
	t[missionId] = true
end

function MissionManager:removeLevelMissionMap(level , missionId)
	printx( 1 , "   MissionManager:removeLevelMissionMap    " , level , missionId)
	if self.levelMissionMap[level] then
		local t = self.levelMissionMap[level]
		t[missionId] = nil
	end
end

function MissionManager:clearLevelMissionMap()
	self.levelMissionMap = {}
end

function MissionManager:getMissionIdOnLevel(level)
	local result = {}
	
	if self.levelMissionMap[level] then
		local t = self.levelMissionMap[level]
		for k,v in pairs(t) do
			--if v and type(v) == "number" and v > 0 then
				table.insert( result , k )
			--end
		end
	end
	
	return result
end