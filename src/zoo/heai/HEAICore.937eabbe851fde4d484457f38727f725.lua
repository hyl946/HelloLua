---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-05-18 14:13:40
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-02-26 15:03:56
---------------------------------------------------------------------------------------
HEAICore = class()

-- 501-700关 @done
-- 调整去掉回流用户限制 @done
-- 分组走正交分组 @done
-- 用户分组标签ai_flag (0-非法UID或没有读取到开关,1-项目组,2-AI组) @done

local Config = require("zoo.heai.Config")
local RtufBuilder = require("zoo.heai.RealTimeUserFeatureBuilder")
local AISeedRequest = require("zoo.heai.AISeedRequest")
local userGroupId = 0
local kMaintenanceName = "HEAISeeds3"
local kMaintenanceDelay = "HEAIDelayStart"
local kDelayStartTime = 2

function HEAICore:init()
	HEAICore.getInstance():resetData()
end

function HEAICore:ctor()
	-- self:resetData()
	local function resetData(evt)
		self:resetData()
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserDataInit, resetData)
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kMaintenanceChange, resetData)
end

function HEAICore:getUserGroupId(recalc)
	if recalc and (UserManager and UserManager:hadInited()) then
		userGroupId = 0
		for i = 1,2 do
			if MaintenanceManager:getInstance():isEnabledInGroup(kMaintenanceName , "G"..tostring(i) , UserManager:getInstance():getUID()) then
				userGroupId = i
				break
			end
		end
	end
	return userGroupId
end

function HEAICore:resetData()
	self.debugMode = Config.debug_mode
	if not self.debug_mode and (UserManager and UserManager:hadInited()) 
			and MaintenanceManager:getInstance():isEnabled("HEAISeedsDebugMode", false) then
		self.debugMode = true
	end

	self:clearAllSeedDatas()
	self:cancelSeedsRequest()
	self.userInTestGroup = false
	self.delayStartGame = false
	self.levelRangeConfig = self:parseLevelRangeConfig(kMaintenanceName)
	self.delayLevelRangeConfig = self:parseLevelRangeConfig(kMaintenanceDelay)
	if HEAICore:getUserGroupId(true) == 2 then
		self.userInTestGroup = true
	end

	if _G.launchCmds and _G.launchCmds.force_ai_mode then
		self.levelRangeConfig = {{startLevel=1, endLevel = 9999}}
		self.userInTestGroup = true
	end
end

function HEAICore:parseLevelRangeConfig(maintenanceName)
	local levelRangeConfig = {}
	local levelRangeMeta = MaintenanceManager:getInstance():getExtra(maintenanceName)
	if levelRangeMeta then
		local ranges = string.split(levelRangeMeta, ",")
		local values = nil
		local startLevel, endLevel = 0, 0
		for i, range in ipairs(ranges) do
			values = string.split(range, "-")
			if #values >= 2 then
				startLevel = tonumber(values[1]) or 0
				endLevel = tonumber(values[2]) or 0
				if startLevel > endLevel then startLevel, endLevel = endLevel, startLevel end
				table.insert(levelRangeConfig, {startLevel=startLevel, endLevel = endLevel})
			end
		end
	end
	return levelRangeConfig
end

function HEAICore:getInstance()
	if not HEAICore._instance then
		HEAICore._instance = HEAICore.new()
	end
	return HEAICore._instance
end

function HEAICore:getGamePlayCounter()
	local playTimes = UserManager.getInstance().playTimes
	-- assert(playTimes)
	return playTimes or 0
end

-- 自上次种子返回后玩过5次关卡，或是超过1小时，或是种子数据为空，则重新拉取
function HEAICore:checkSeedDataNeedUpdate(levelId)
	local seedTable = self.seedsTable[levelId]
	if seedTable then
		if self:getGamePlayCounter() >= seedTable.gameplayCounter + 5
				or Localhost:timeInSec() > seedTable.timestamp + 3600
				or #seedTable.interveneInfos == 0
				then
			return true
		else
			return false
		end
	end
	return true
end

function HEAICore:isLevelInRangeConfig(levelId)
	if GuideSeeds[levelId] then
		return false
	end

	if not LevelType:isMainLevel(levelId) then
		return false 
	end

	if _G.launchCmds and _G.launchCmds.force_ai_mode then
		return true
	end

	if #self.levelRangeConfig < 1 then
		-- 必须指定
		return false
	end

	for i, range in ipairs(self.levelRangeConfig) do
		if levelId and range.startLevel and range.endLevel and levelId >= range.startLevel and levelId <= range.endLevel then
			return true
		end
	end

	return false
end

function HEAICore:isEnable(levelId)
	if self.userInTestGroup and self:isLevelInRangeConfig(levelId) then
		return true 
	end
	return false
end

function HEAICore:isDiffultyAdjustNeedForbid(levelId)
	if self:isEnable(levelId)
		and self:seedExistForLevel(levelId) then
		return true
	end
	return false
end

function HEAICore:isReturnBackUser()
	if UserTagManager:isReturnBackUser()  then
		return true
	end
	local activityData = LocalBox:getData( LocalBoxKeys.Activity_UserCallBackTest )
	if activityData.flag and Localhost.timeInSec() < activityData.endTime then  
		return true
	end
	return false
end

function HEAICore:isDebugMode()
	return self.debugMode
end

function HEAICore:clearSeedData(levelId)
	self.seedsTable[levelId] = nil
end

function HEAICore:clearAllSeedDatas()
	self.seedsTable = {}
end

function HEAICore:dc(subcategory, data)
	data = data or {}
	data.sub_category = subcategory or "default"
	data.category = "heai"
	DcUtil:log(AcType.kExpire30Days, data)
end

function HEAICore:requestSeeds(levelId)
	local levels = {}
	local levelCount = Config.request_level_count or 5
	local maxMainLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	maxMainLevelId = math.min(maxMainLevelId, levelId + levelCount - 1)
	for level = levelId, maxMainLevelId do
		if self:isLevelInRangeConfig(level) then
			table.insert(levels, level)
			self:clearSeedData(level)
		else
			break
		end
	end

	local params = self:createParams(levels)
	params = table.serialize(params)
	if not params then
		assert(false, "serialize params error")
		return
	end

	self:cancelSeedsRequest()
	self:startNewSeedsRequest(levelId, params)
end

function HEAICore:startNewSeedsRequest(levelId, params)
	local function callbackHanler(responseData)
		self:cancelTimeout()

		self.processingRequest = nil
		if not responseData then return end

		if responseData.result == 200 and responseData.levelInfos then
			for _, v in ipairs(responseData.levelInfos) do
				self:pushSeedData(v)
			end
		end
	end
	local isDebugMode = self:isDebugMode()
	local request = AISeedRequest.new(Config.request_url, isDebugMode)
	self.processingRequest = request
	request:start(levelId, params, callbackHanler)

	if self:isTimeoutEnable(levelId) then
		self:startTimeout()
	end
end

function HEAICore:cancelSeedsRequest()
	self:stopProcessingRequest()
	self:cancelTimeout()
end

function HEAICore:isTimeoutEnable(levelId)
	if not MaintenanceManager:getInstance():isEnabled(kMaintenanceDelay, false) then return false end 
	if #self.delayLevelRangeConfig < 1 then
		-- 必须指定
		return false
	end

	for i, range in ipairs(self.delayLevelRangeConfig) do
		if levelId and range.startLevel and range.endLevel and levelId >= range.startLevel and levelId <= range.endLevel then
			return true
		end
	end

	return false
end

function HEAICore:startTimeout()
	local function onTimeout()
		self.delayStartGame = false
		self.timeoutId = nil
	end

	self.delayStartGame = true
	self.timeoutId = setTimeOut(onTimeout, kDelayStartTime)
end

function HEAICore:cancelTimeout()
	self.delayStartGame = false
	if self.timeoutId then
		cancelTimeOut(self.timeoutId)
		self.timeoutId = nil
	end
end

function HEAICore:shouldDelayStartGame()
	return self.delayStartGame
end

function HEAICore:stopProcessingRequest(isTimeout)
	if self.processingRequest then
		self.processingRequest:cancel(isTimeout)
		self.processingRequest = nil
	end
end

function HEAICore:pushSeedData(dataFromServer)
	if not (dataFromServer and dataFromServer.levelId) then
		return nil
	end
	local seedData = {}
	seedData.levelId = dataFromServer.levelId 		-- int
	seedData.eventId = dataFromServer.eventId 		-- string
	seedData.algorithmId = dataFromServer.algorithmId or "unknown"	-- string
	-- seedData.seeds = dataFromServer.seeds or {} 	-- array
	seedData.interveneInfos = dataFromServer.interveneInfos or {} -- array[{seed,colorProbs}] -- TODO
	seedData.gameplayCounter = self:getGamePlayCounter()
	seedData.timestamp = Localhost:timeInSec()

	self.seedsTable[seedData.levelId] = seedData

	if _G.isLocalDevelopMode then
		printx(0, "pushSeedData:", table.tostring(seedData))
	end
end

function HEAICore:popSeedForLevel(levelId)
	local seedData = self:getSeedDataByLevel(levelId)
	if _G.isLocalDevelopMode then
		printx(0, "popSeedForLevel:", levelId, table.tostring(seedData))
	end

	local interveneInfo = nil
	if seedData then
		interveneInfo = table.remove(seedData.interveneInfos, 1)
	end
	if interveneInfo then
		local colorProbs = nil
		if interveneInfo.colorProbs and #interveneInfo.colorProbs > 0 then
			colorProbs = interveneInfo.colorProbs
		end
		return {seed = tonumber(interveneInfo.seed), colorProbs = colorProbs,
				eventId = seedData.eventId, algorithmId = seedData.algorithmId}
	else
		return nil
	end
end

function HEAICore:seedExistForLevel(levelId)
	local seedData = self:getSeedDataByLevel(levelId)
	if seedData and seedData.interveneInfos then
		return seedData.interveneInfos[1]
	end
	return nil 
end

function HEAICore:getSeedDataByLevel(levelId)
	return self.seedsTable[levelId]
end

function HEAICore:getLevelsData(levelIds)
	local levelSigs = {}
	local levelSteps = {}
	for i, levelId in ipairs(levelIds) do
		local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
		if not levelMeta then assert(false, "levelId=" .. tostring(levelId)) end
		levelSigs[i] = levelMeta and levelMeta.levelSig or ""
		levelSteps[i] = levelMeta and levelMeta:getMoveLimit() or 0
	end
	return levelSigs, levelSteps
end

function HEAICore:createParams(levelIds)
	local params = {}
	params.uid 				= UserManager:getInstance().user.uid
	params.appid			= StartupConfig:getInstance():getDcUniqueKey()
	params.major_version 	= _G.bundleVersion
	params.minor_version 	= ResourceLoader.getCurVersion()

	local levelSigs, levelSteps = self:getLevelsData(levelIds)
	params.levels 			= levelIds
	params.level_steps	 	= levelSteps
	params.level_config_md5 = levelSigs

	params.sdk_version 		= Config.sdk_version
	params.rtuf 			= RtufBuilder:build(levelIds)
	return params
end