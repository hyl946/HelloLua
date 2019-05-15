require "zoo.gamePlay.levelStrategy.LevelStrategyLogic"

LevelStrategyManager = class()

local instance = nil

--测试关卡id 测试完可以通过配置读取
local forceGuideLevels = {
	329,753,1137
}

function LevelStrategyManager.getInstance()
	if not instance then
		instance = LevelStrategyManager.new()
		instance:init()
	end
	return instance
end

function LevelStrategyManager:init()
	self.userDefault = CCUserDefault:sharedUserDefault()

	-- self.hasGuideShow = self.userDefault:getBoolForKey("level.strategy.guide.show", false)
	self.hasGuideShow = false 

	self.replayInfoTable = {}

	self.failLimitNum = 10
	self.levelFailTable = {}
	self.levelFailInfo = self.userDefault:getStringForKey("level.strategy.fail.info", "")
	if self.levelFailInfo and self.levelFailInfo ~= "" then 
		local t = string.split(self.levelFailInfo, ":")
		local levelId = t[1]
		local failNum = t[2]
		if levelId then 
			levelId = tonumber(levelId)
			failNum = tonumber(failNum)
			local topLevelId = UserManager:getInstance().user:getTopLevelId()
			if levelId and failNum and levelId == topLevelId then 
				self.levelFailTable[levelId] = failNum
			else
				self.userDefault:setStringForKey("level.strategy.fail.info", "")
				self.userDefault:flush()
			end
		end
	end

	self.hasReplayLevels = {}
end

function LevelStrategyManager:shouldShowStrategy(levelId)
	--单关开关
	local isFirstTime = false  
	if not MetaManager:getInstance():checkLevelTrigger(levelId, "strategy") then return end 
	--时间关和飞碟关不支持
	local levelModeTypeId = MetaModel:sharedInstance():getLevelModeTypeId(levelId)
	if levelModeTypeId == GameModeTypeId.CLASSIC_ID or levelModeTypeId == GameModeTypeId.DIG_TIME_ID then 
		return false
	end
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId, false)
	if levelConfig.hasDropDownUFO then 
		return false
	end
	-- 40%用户
	if not MaintenanceManager:isAvailbleForUid("StrategyShow", UserManager:getInstance().uid, 100) then
		return false 
	end
		
	if table.includes(self.hasReplayLevels, levelId) then 
		return true, isFirstTime
	else
		local topLevelId = UserManager:getInstance().user:getTopLevelId()
		if topLevelId == levelId then 
			local failNum = self.levelFailTable[levelId]
			if failNum then 
				local failLimitNum 
				if self:isForceGuideLevel(levelId) then 
					failLimitNum = 1
				else
					failLimitNum = self.failLimitNum
				end
				if failNum >= failLimitNum then 
					isFirstTime = true
					return true, isFirstTime
				end
			end
		end
	end

	return false
end

function LevelStrategyManager:isForceGuideLevel(levelId)
	return table.includes(forceGuideLevels, levelId)
end

function LevelStrategyManager:shouldAskForReplayData(levelId)
	if not self:isForceGuideLevel(levelId) then return false end
	if not GameGuideCheck:onceOnly(3000000) then return false end
	return true
end

function LevelStrategyManager:shouldShowForceGuide(levelId)
	if not self:shouldAskForReplayData(levelId) then return false end
	if not self:shouldShowStrategy(levelId) then return false end
	if not self.replayInfoTable[levelId] then return false end
	return true
end

function LevelStrategyManager:shouldShowGuide(levelId)
	local shouldShow, isFirstTime = self:shouldShowStrategy(levelId)
	if not shouldShow or not isFirstTime then 
		return false
	end

	local curEnergy = UserManager.getInstance().user:getEnergy() or 0
	if curEnergy < 5 then 
		return false
	end
	return not self.hasGuideShow
end

function LevelStrategyManager:setGuideShow()
	-- self.hasGuideShow = true
	-- self.userDefault:setBoolForKey("level.strategy.guide.show", true)
	-- self.userDefault:flush()
end

function LevelStrategyManager:setLevelFail(levelId)
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	if levelId ~= topLevelId then return end

	if not self.levelFailTable[levelId] then 
		self.levelFailTable[levelId] = 1
	else
		self.levelFailTable[levelId] = self.levelFailTable[levelId] + 1
	end

	local levelFailInfo = levelId..":"..self.levelFailTable[levelId]
	self.userDefault:setStringForKey("level.strategy.fail.info", levelFailInfo)
	self.userDefault:flush()
end

function LevelStrategyManager:getHasReplayDataLevels()
	local function onSuccess(evt)
		local data = evt.data or {}
		self.hasReplayLevels = data.levelIds or {}
	end

	local function onFail(evt)
		--keep silent
		-- CommonTip:showTip(localize("getHasReplayDataLevels::网络出错了~"), "negative")
	end

	local http = StrategyGetLevels.new(false)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:syncLoad()
end

function LevelStrategyManager:getReplayData(levelId, callback, isSilent)
	if self.replayInfoTable[levelId] then 
		if callback then callback(self.replayInfoTable[levelId]) end
	else
		-- local replayInfo = {}				--fromServer
		-- -- ------------test-------------
		-- replayInfo.data = [[{"hasDropBuff":false,"ctx":{"dp1":0,"dc1":0,"dp2":0,"dc2":0,"prop":0},"randomSeed":1507689323,"rct":"20171011103441","context":{"currState":"fallingMatch","priorityLogic":"none"},"replaySteps":
		-- ["5,3:6,3","5,8:6,8","6,1:6,2","6,5:6,6","4,6:5,6",
		-- "p:10001:2:0,0:0,0","p:10010:2:4,1:0,0","6,8:6,9",
		-- "5,8:5,9","2,8:3,8","5,3:5,4","p:10005:2:4,2:0,-1",
		-- "p:10005:2:4,1:0,-1","4,1:4,2","p:10010:2:3,2:0,0",
		-- "5,3:5,4","2,8:3,8","8,1:9,1","8,7:9,7","6,8:6,9",
		-- "p:10010:2:7,8:0,0","5,8:6,8","8,1:8,2","9,5:9,6",
		-- "9,3:9,4","6,1:6,2","8,9:9,9","p:10004:1:0,0:0,0",
		-- "4,1:4,2","7,6:7,7","8,2:9,2","7,3:7,4","9,3:9,4"],"curMd5":"local_dev_version","selectedItemsData":{},"ver":2,"mini":false,"info":"NRCD2050","curConfigMd5":"bff79445d98fd0854d59847388e078f5","currTime":1507689281,"level":1232,"score":174985,"passed":1}]]
		
		-- replayInfo.name = ""
		-- replayInfo.headUrl = ""
		-- self.replayInfoTable[levelId] = replayInfo
		-- if callback then callback(replayInfo) end
		-- do return end
		-- -- -- -----------------------------
		
		local function onSuccess(evt)
			local data = evt.data or {}
			local replayInfo = {}
			replayInfo.data = data.replayData
			if data.replayData and data.replayData ~= "" then 
				replayInfo.name = ""
				replayInfo.headUrl = ""

				self.replayInfoTable[levelId] = replayInfo
				if not table.includes(self.hasReplayLevels, levelId) then 
					table.insert(self.hasReplayLevels, levelId)
				end
				if callback then callback(replayInfo) end
			else
				if not isSilent then CommonTip:showTip(localize("strategy.playback9"), "negative") end
				if callback then callback() end
			end
		end

		local function onFail(evt)
			if not isSilent then CommonTip:showTip(localize("crash.resume.has.no.net"), "negative") end
			if callback then callback() end
		end

		local http = StrategyGetRelay.new(not isSilent)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:syncLoad(levelId)
	end
end

function LevelStrategyManager:checkHasLevelReplayData(levelId)
	return self.replayInfoTable[levelId] ~= nil
end

--回放播放出错 清理本地缓存 以便重新拉取
function LevelStrategyManager:cleanLevelReplayData(levelId)
	self.replayInfoTable[levelId] = nil
end

function LevelStrategyManager:getStrategyInfo(leftMoves, star)
	local uid = UserService.getInstance().user.uid
	local usePre, useTemp, useBag = StageInfoLocalLogic:getPropInLevelUseState(uid)

	local info = {}
	--优先选择使用礼盒道具的replay
	info.p1 = useTemp
	--优先筛选剩余步数小于等于3的
	info.p2 = leftMoves
	--同关卡中，优先选择"使用鸟鸟交换和5+4较少"的replay
	local playInfo = GamePlayContext:getInstance().playInfo
	info.p3 = playInfo.bird_line_swap + playInfo.bird_wrap_swap + playInfo.bird_bird_swap
	--优先选择达成三星分的replay
	info.p4 = star
	--在以上情况都达成的情况下，使用前置道具的优先级等同于不使用任何道具，高于使用付费道具
	info.p5 = useBag

	return info
end

function LevelStrategyManager:dcShowStrategyTab(t1, t2, t3)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "Open_Strategy"
	params.t1 = t1
	params.t2 = t2
	params.t3 = t3
	DcUtil:levelStrategyLog(params)
end

function LevelStrategyManager:dcClickStrategyTab(t1, t2)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "OpenList_Strategy"
	params.t1 = t1
	params.t2 = t2
	DcUtil:levelStrategyLog(params)
end

function LevelStrategyManager:dcClickStrategyPlay(t1, t2)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "Watch_Strategy"
	params.t1 = t1
	params.t2 = t2
	DcUtil:levelStrategyLog(params)
end

function LevelStrategyManager:dcClickStrategyPause(t1)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "Pause_Strategy "
	params.t1 = t1
	DcUtil:levelStrategyLog(params)
end

function LevelStrategyManager:dcCloseStrategyPlay(t1, t2)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "Close_Strategy"
	params.t1 = t1
	params.t2 = t2
	DcUtil:levelStrategyLog(params)
end

function LevelStrategyManager:dcClickStrategyReplay(t1, t2)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "Watch_Again_Strategy"
	params.t1 = t1
	params.t2 = t2
	DcUtil:levelStrategyLog(params)
end

--点了里面的播放按钮
function LevelStrategyManager:dcClickStrategyInnerPlay(t1, t2)
	local params = {}
	params.category = "Strategy"
	params.sub_category = "Play_Strategy"
	params.t1 = t1
	params.t2 = t2
	DcUtil:levelStrategyLog(params)
end