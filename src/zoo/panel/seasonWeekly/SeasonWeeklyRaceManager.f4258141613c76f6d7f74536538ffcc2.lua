require "zoo.panel.seasonWeekly.model.SeasonWeeklyRaceData"
require "zoo.panel.seasonWeekly.model.SeasonWeeklyMatchRankData"
require "zoo.panel.seasonWeekly.model.SeasonWeeklyShowOffData"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceConfig"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceHttpUtil"
require "zoo.PersonalCenter.AchievementManager"
require "zoo.panel.endGameProp.weekrace.WeekRaceLottery"

SummerWeeklyMatchEvents = {
	kDataChangeEvent = "weekly.summer.dataChange",
	kNpcSkinChange = 'weekly.npc.skin.change',
	kPiecesNumChange = 'weekly.pieces.num.change'
}

SeasonWeeklyRaceManager = class()

local startDate = {year = 2015, month=6, day=2, hour=0, min=0, sec=0}
local DAY_SEC	= 3600 * 24
local WEEK_SEC	= DAY_SEC * 7

local _instance = nil

function SeasonWeeklyRaceManager:ctor()
	self.matchData = nil

	self.onceRankData = nil	 --单次成绩
	self.allRankData = nil --累积成绩

	self.uid = nil
	self.levelId = nil
	self.wday = nil
	self.firstMondayTime = SeasonWeeklyRaceManager:getMondayTime(os.time(startDate))

	self.eventDispatcher = EventDispatcher.new()

end

function SeasonWeeklyRaceManager:getEventDispatcher( ... )
	return self.eventDispatcher
end

function SeasonWeeklyRaceManager:getInstance()
	if not _instance then
		_instance = SeasonWeeklyRaceManager.new()
		_instance:init()
	end
	return _instance
end

function SeasonWeeklyRaceManager:init()
	--RemoteDebug:uploadLog( "SeasonWeeklyRaceManager:init	" , UserManager.getInstance().uid )
	self.uid = UserManager.getInstance().uid

	local time = Localhost:timeInSec()
	-- self.week = self:getWeek(time)
	self.wday = self:getWDay(time)
	self.levelId = self:calcLevelId()
	self.extraTargetConfig = self:getExtraTargetConfig() or {}
	self.passLevelListener = function(evt)
		assert(evt, "evt cannot be nil")
		self:tryToShareOnPassLevel(evt.data)
	end
	GamePlayEvents.addPassLevelEvent(self.passLevelListener)
end

function SeasonWeeklyRaceManager:getExtraTargetConfig()
	local numConfigStr = MaintenanceManager:getInstance():getExtra("WeeklyTargetConfig") or "60_110_160_230"
	local numConfigT = numConfigStr:split("_")
	local targetNum = #numConfigT
	local config
	if targetNum > 0 then 
		config = {}
		for i=1,targetNum do
			local info = {}
			info.itemNum = tonumber(numConfigT[i])
			info.level = i
			table.insert(config, info)
		end
	end
	return config
end

function SeasonWeeklyRaceManager:getWeeklyRewards()
	return SeasonWeeklyRaceConfig:getInstance():getWeeklyRewards()
end

function SeasonWeeklyRaceManager:getWeek(time)
	time = time or Localhost:timeInSec()
	local diffTime = math.abs(time - self.firstMondayTime)
	local week = math.ceil((diffTime + 1) / WEEK_SEC)
	-- if week == 0 then week = 1 end
	return week
end

function SeasonWeeklyRaceManager:getWDay(time)
	time = time or Localhost:timeInSec()
	local wday = tonumber(os.date('%w', time))
	if wday == 0 then wday = 7 end
	return wday
end

function SeasonWeeklyRaceManager:onDataChanged( needUpdateParts)

	if not needUpdateParts then
		needUpdateParts = { top = true , button = true , rewards = true , ranking = true }
	end

	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SummerWeeklyMatchEvents.kDataChangeEvent, {needUpdateParts = needUpdateParts}))
end

function SeasonWeeklyRaceManager:checkTopLevelUserGetAllPlayCount( ... )
	
	if UserManager.getInstance():getTopPassedLevel() >= kMaxLevels then

		-- 满级玩家自动补满次数
		-- 假装他打了最大次数的主线关

		local needUpdate = false

		while self:canGetFreePlay() do

			self.matchData:addDailyLevelPlayCount(1)

			local leftMainLevelCountToAddWeeklyPlayCount = 
					self.matchData.dailyLevelPlay % SeasonWeeklyRaceConfig:getInstance().addWeeklyPlayCountPerMainLevelPlay

			if leftMainLevelCountToAddWeeklyPlayCount == 0 then
				self.matchData:incrLeftPlay(SeasonWeeklyRaceConfig:getInstance().freePlayByMainLevel)
			end

			needUpdate = true
		end

		if needUpdate then
			local http = OpNotifyOffline.new()
			http:load(OpNotifyOfflineType.kTopLevelUserGetAllPlayCount, '')

			self:flushToStorage()
			self:onDataChanged( {button = true} )

		end
	end
	
end

function SeasonWeeklyRaceManager:getAndUpdateMatchData()
	if not self.matchData then
		self.matchData = self:getMatchDataFromLocal()
		
	end
	if self:hasWeekChanged(self.matchData) then
		local time = Localhost:timeInSec()
		-- self.week = self:getWeek(time)
		self.wday = self:getWDay(time)
		self.levelId = self:calcLevelId()

		self.matchData:resetWeeklyData()
		self.matchData.updateTime = time
		self:flushToStorage()
	else
		if self:hasDayChanged(self.matchData) then
			local time = Localhost:timeInSec()
			self.wday = self:getWDay(time)
			self.levelId = self:calcLevelId()

			self.matchData:resetDailyData()

			self.matchData.updateTime = time

			self:flushToStorage()
		end
	end

	self:checkTopLevelUserGetAllPlayCount()
	-- if _G.isLocalDevelopMode then printx(0, "getAndUpdateMatchData:", table.tostring(self.matchData)) end
	return self.matchData
end

function SeasonWeeklyRaceManager:getMondayTime(time)
	time = time or Localhost:timeInSec()
	local dateT = os.date("*t", time)
	dateT.hour = 0
	dateT.min = 0
	dateT.sec = 0
	local wday = dateT.wday - 1 -- 周日wday=1
	if wday == 0 then wday = 7 end -- 周日
	local mondayTime = os.time(dateT) - (wday - 1) * DAY_SEC
	return mondayTime
end

function SeasonWeeklyRaceManager:getLeftTime( ... )
	local nextMondyTime = self:getMondayTime() + WEEK_SEC
	local leftTime = nextMondyTime - Localhost:timeInSec()

	local leftDay = math.floor(leftTime/DAY_SEC)
	local leftHour = math.floor((leftTime - leftDay * DAY_SEC)/3600)
	local leftMinute = math.floor((leftTime - leftDay * DAY_SEC - leftHour * 3600)/60)

	return {
		leftDay = leftDay,
		leftHour = leftHour,
		leftMinute = leftMinute,
	}
end

function SeasonWeeklyRaceManager:calcLevelId()
	local config = SeasonWeeklyRaceConfig:getInstance()
	local levelIds = config.levelIds
	if not levelIds or #levelIds < 1 then
		return nil
	end
	
	if not self.matchData then
		self.matchData = self:getMatchDataFromLocal()
		self:checkTopLevelUserGetAllPlayCount()
	end

	-- if true then
	--	return GuideLevel.kSeasonWeekly
	-- end

	local randomed = self.matchData.randomedIndices or {}
	for k,v in pairs(randomed) do
		if not table.includes(levelIds, v) then 
			self.matchData.randomedIndices = {}
			randomed = {}
			break
		end
	end
	local lastFinished = self.matchData.lastIndexFinished
	local haveGuide = GameGuide:sharedInstance():checkHaveGuide(GuideLevel.kSeasonWeekly)
	-- 如果没有玩过引导关 则强制进入引导关
	if haveGuide then
		if lastFinished then
			table.remove(self.matchData.randomedIndices)
		end
		table.removeValue(self.matchData.randomedIndices, GuideLevel.kSeasonWeekly)
		table.insert(self.matchData.randomedIndices, GuideLevel.kSeasonWeekly)
		self.matchData.lastIndexFinished = false
		self:flushToStorage()
		return GuideLevel.kSeasonWeekly
	end

	if #randomed == 0 or lastFinished then
		local lastLevelId = randomed[#randomed]
		if #randomed >= #levelIds then
			randomed = {}
			self.matchData.randomedIndices = {}
		end
		while true do
			local index = math.random(#levelIds)
			if not table.indexOf(randomed, levelIds[index]) and levelIds[index] ~= lastLevelId then
				table.insert(self.matchData.randomedIndices, levelIds[index])
				self.matchData.lastIndexFinished = false
				self:flushToStorage()
				return levelIds[index]
			end
		end
	else
		return randomed[#randomed]
	end

	-- 下方是理论上更稳定和高效的方式
	-- 但由于其中出现了哈希操作以及集合很小因此实际时间比上方纯随机并比对 的速度要慢很多
	-- 因此先使用上方的随机方式 如果集合变大可以再进行效率评估并确认是否采用下方的算法
	-- TIP：这个版本没有以上版本中的每轮最后和第一个两个的去重 我的懒癌又犯了……

 --	   if #randomed == 0 or lastFinished then
 --		if #randomed == #levelIds then
 --			randomed = {}
 --			self.matchData.randomedIndices = {}
 --		end
 --		local tmp = {}
	--	for i, v in ipairs(randomed) do
	--		tmp[v] = true
	--	end
 --		levelIds = table.filter(levelIds, function(v)
 --				return not tmp[v]
 --			end)
 --		local index = math.random(#levelIds)
	--	table.insert(self.matchData.randomedIndices, levelIds[index])
	--	self.matchData.lastIndexFinished = false
	--	self:flushToStorage()
	--	return levelIds[index]
 --	   else
 --		return randomed[#randomed]
 --	   end
end

function SeasonWeeklyRaceManager:getLevelId()
	return self.levelId
end

function SeasonWeeklyRaceManager:isLevelReached(topLevelId)
	topLevelId = topLevelId or UserManager:getInstance().user:getTopLevelId()
	local minLevel = SeasonWeeklyRaceConfig:getInstance().minLevel or 31
	return topLevelId >= minLevel
end

function SeasonWeeklyRaceManager:loadData(onFinish, withAnim)
	local function onSuccess()
		if onFinish then onFinish() end
	end

	local function onFail( ... )
		self:getAndUpdateMatchData()
		if onFinish then onFinish() end
	end
	self:getMatchDataFromServer(onSuccess, onFail, not withAnim)
end

function SeasonWeeklyRaceManager:getMatchDataFromServer( onSuccess, onFail, inBackground )

	local function onRequestSuccess(evt)
		--local matchData = Localhost.getInstance():readWeeklyMatchData()
		local localData = Localhost.getInstance():readWeeklyMatchData()
		self.matchData = SeasonWeeklyRaceData:fromRespData(evt.data, localData)
		self:checkTopLevelUserGetAllPlayCount()

		
		if localData then
			self.matchData:getLevelRandomDataFromLocal(localData)
		end
		self:flushToStorage()
		-- if _G.isLocalDevelopMode then printx(0, "self.matchData", table.tostring(self.matchData)) end

		local time = Localhost:timeInSec()
		-- self.week = self:getWeek(time)
		self.wday = self:getWDay(time)
		self.levelId = self:calcLevelId()

		if onSuccess then onSuccess(evt) end
	end

	local function onRequestFail(evt)
		if onFail then onFail(evt) end
	end

	local http = SeasonWeeklyRaceHttpUtil.newGetInfoHttp(inBackground, onRequestSuccess, onRequestFail, onRequestFail)

	http:syncLoad(self.levelId)
end

function SeasonWeeklyRaceManager:hasReward()
	local lastWeekRewards = self:getLastWeekRewards()
	if #lastWeekRewards > 0 then return true , 1 end
	local lastWeekRankRewards = self:getLastWeekRankRewards()
	if #lastWeekRankRewards > 0 then return true , 2 end

	--local dailyReward = self:getNextDailyReward()
	--if dailyReward and dailyReward.needMore == 0 and not dailyReward.nextDayReward then return true end

	local weeklyRewards = self:getNextWeeklyReward()
	for _, v in pairs(weeklyRewards) do
		if v.needMore == 0 and not v.hasReceived then return true , 3 end
	end
	return false
end

function SeasonWeeklyRaceManager:hasWeeklyRewards()
	local weeklyRewards = self:getNextWeeklyReward()
	for _, v in pairs(weeklyRewards) do
		if v.needMore == 0 and not v.hasReceived then return true end
	end
	return false
end

function SeasonWeeklyRaceManager:hasLastWeekRewards()
	local lastWeekRewards = self:getLastWeekRewards()
	if #lastWeekRewards > 0 then return true end
	local lastWeekRankRewards = self:getLastWeekRankRewards()
	if #lastWeekRankRewards > 0 then return true end
	local lastWeekTotalRankRewards = self:getLastWeekTotalRankRewards()
	if #lastWeekTotalRankRewards > 0 then return true end
	return false
end

function SeasonWeeklyRaceManager:hasLastWeekRankRewards()
	local lastWeekRankRewards = self:getLastWeekRankRewards()
	if #lastWeekRankRewards > 0 then return true end
	return false
end

function SeasonWeeklyRaceManager:hasLastWeekTotalRankRewards( ... )
	local lastWeekTotalRankRewards = self:getLastWeekTotalRankRewards()
	if #lastWeekTotalRankRewards > 0 then return true end
	return false
end

function SeasonWeeklyRaceManager:getMatchDataFromLocal()
	local matchData = self:readFromStorage()
	if not matchData then
		matchData = SeasonWeeklyRaceData.new()
	end
	return matchData
end

function SeasonWeeklyRaceManager:hasWeekChanged(oldData)
	return self:getWeek(Localhost:timeInSec()) > self:getWeek(oldData.updateTime)
end

function SeasonWeeklyRaceManager:hasDayChanged(oldData)
	local diffDay = compareDate(os.date("*t", Localhost:timeInSec()), os.date("*t", oldData.updateTime))
	return diffDay > 0
end

function SeasonWeeklyRaceManager:receiveDailyReward( rewardId, onSuccess, onFail )
	local function onReceiveSuccess(evt)
		if evt and evt.data then
			-- 注释掉因为暂时不用了 再启用请加打点
			assert(false, "look at here!")
			-- UserManager:getInstance():addRewards(evt.data.rewards)
			-- UserService:getInstance():addRewards(evt.data.rewards)
		end
		table.insert(self.matchData.receivedDailyRewards, rewardId)
		self:flushToStorage()
		DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_winter_2016_get_dailyreward', reward_id=rewardId, day=self.wday}, true)
		if onSuccess then onSuccess(evt) end
	end

	local function onReceiveFail(event)
		local function localFail()
			onFail(event)
		end
		if event and event.data then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..event.data), "negative", localFail)
		end
		if onFail then onFail(event) end
	end

	local function onRequestCancel( event )
		if onFail then onFail(event) end
	end
	self:receiveReward(self.levelId, GetWeeklyRaceRewardsType.kDailyReward, rewardId, onReceiveSuccess, onReceiveFail, onRequestCancel)
end

function SeasonWeeklyRaceManager:receiveWeeklyReward( rewardId, onSuccess, onFail )
	local function onReceiveSuccess(evt)
		if evt and evt.data then
			-- 注释掉因为暂时不用了 再启用请加打点
			assert(false, "look at here!")
			-- UserManager:getInstance():addRewards(evt.data.rewards)
			-- UserService:getInstance():addRewards(evt.data.rewards)
		end
		table.insert(self.matchData.receivedWeeklyRewards, rewardId)
		self:flushToStorage()
		if not self:hasWeeklyRewards() then
			LocalNotificationManager.getInstance():cancelWeeklyRaceRewardNotification()
		end
		self:onReceiveRewardSuccess(rewardId)
		DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_get_weeklyreward', reward_id=rewardId}, true)
		if onSuccess then onSuccess(evt) end

	end

	local function onReceiveFail(event)
		local function localFail()
			onFail(event)
		end
		if event and event.data then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..event.data), "negative", localFail)
		end
		if onFail then onFail(event) end
	end

	local function onRequestCancel( event )
		if onFail then onFail(event) end
	end
	self:receiveReward(self.levelId, GetWeeklyRaceRewardsType.kWeeklyReward, rewardId, onReceiveSuccess, onReceiveFail, onRequestCancel)
end

function SeasonWeeklyRaceManager:receiveLastWeekRewards(levelId, onSuccess, onFail )
	local function onReceiveSuccess(evt)
		if evt and evt.data then
			-- 注释掉因为暂时不用了 再启用请加打点
			assert(false, "look at here!")
			-- UserManager:getInstance():addRewards(evt.data.rewards)
			-- UserService:getInstance():addRewards(evt.data.rewards)
		end
		for _, rewardId in pairs(self.matchData.lastWeekRewards) do
			DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_get_last_weeklyreward', reward_id=rewardId}, true)
			self:onReceiveRewardSuccess(rewardId)
		end
		self.matchData.lastWeekRewards = {}
		if self:hasLastWeekRankRewards() then
			DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_get_last_weeklyreward', reward_id=7}, true)
			self.matchData.lastWeekRankRewards = {}
		end
		if onSuccess then onSuccess(evt) end
	end

	local function onReceiveFail(event)
		self.matchData.lastWeekRewards = {}
		self.matchData.lastWeekRankRewards = {}
		if event and event.data then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..event.data), "negative", onFail)
		end
		if onFail then onFail(event) end
	end
	local function onRequestCancel( event )
		self.matchData.lastWeekRewards = {}
		self.matchData.lastWeekRankRewards = {}
		if onFail then onFail(event) end
	end
	self:receiveReward(levelId, GetWeeklyRaceRewardsType.kLastWeekRewards, 0, onReceiveSuccess, onReceiveFail, onRequestCancel)
end

--同时领取单次、累计排行榜奖励
function SeasonWeeklyRaceManager:receiveLastWeekRankRewards(levelId, onSuccess, onFail )
	local function onReceiveSuccess(evt)
		local hasExtRewards = false
		local goldNum = 0
		if evt and evt.data and evt.data.rewards then
			if #evt.data.rewards > 1 then
				hasExtRewards = true
			end
			for _, v in pairs(evt.data.rewards) do
				if v.itemId == 2 then
					goldNum = goldNum + v.num
				end
			end
			-- 注释掉因为暂时不用了 再启用请加打点
			assert(false, "look at here!")
			-- UserManager:getInstance():addRewards(evt.data.rewards)
			-- UserService:getInstance():addRewards(evt.data.rewards)
		end

		-- local rewardId = 0
		-- if hasExtRewards and self.matchData then
		--	rewardId = self.matchData.lastWeekRank or 0
		-- end

		local t2 = 0

		local totalRewards = SeasonWeeklyRaceConfig:getInstance():getTotalSurpassRewards() or {}
		totalRewards = totalRewards[1] or {}
		totalRewards = totalRewards.items or {}
		local totalRewardItem = totalRewards[1] or {}

		local onceRewards = SeasonWeeklyRaceConfig:getInstance():getSurpassRewards() or {}
		onceRewards = onceRewards[1] or {}
		onceRewards = onceRewards.items or {}
		local onceRewardItem = onceRewards[1] or {}

		local rewards = {}
		if evt and evt.data and evt.data.rewards then
			rewards = evt.data.rewards
		end

		if table.find(rewards, function(item) return item.itemId == onceRewardItem.itemId end) then
			t2 = t2 + 1
		end
		if table.find(rewards, function(item) return item.itemId == totalRewardItem.itemId end) then
			t2 = t2 + 2
		end

		if t2 == 0 then
			t2 = nil
		end

		DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_get_rankreward', num=1, t2 = t2}, true)

		self.matchData.lastWeekRankRewards = {}
		self.matchData.lastWeekTotalRankRewards = {}
		if onSuccess then onSuccess(evt) end
	end

	local function onReceiveFail(event)
		self.matchData.lastWeekRankRewards = {}
		self.matchData.lastWeekTotalRankRewards = {}
		local forceToSuccess = false
		if event and event.data then
			if tonumber(event.data) == 730770 then
				forceToSuccess = true
			else
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..event.data), "negative", onFail)
			end
		end

		if forceToSuccess then
			if onSuccess then onSuccess(evt) end
		else
			if onFail then onFail(event) end
		end
	end

	local function onRequestCancel( event )
		self.matchData.lastWeekRankRewards = {}
		self.matchData.lastWeekTotalRankRewards = {}
		if onFail then onFail(event) end
	end
	self:receiveReward(levelId, GetWeeklyRaceRewardsType.kLastWeekTotalRankRewards, 0, onReceiveSuccess, onReceiveFail, onRequestCancel)
end

function SeasonWeeklyRaceManager:getLastWeekRewards()
	local rewards = {}
	local weeklyRewards = self:getWeeklyRewards()
	if self.matchData and self.matchData.lastWeekRewards and #self.matchData.lastWeekRewards > 0 then
		if weeklyRewards and #weeklyRewards > 0 then
			for _, v in pairs(weeklyRewards) do
				if table.exist(self.matchData.lastWeekRewards, v.id) then
					table.insert(rewards, v)
				end
			end
		end
	end
	return rewards, 0
end






--skin --- begin ----

function SeasonWeeklyRaceManager:getPieceNum( ... )

	-- if __WIN32 then
		-- return 100
	-- end

	if self.matchData and self.matchData.pieceNum then
		return self.matchData.pieceNum
	end

	return 0
end

function SeasonWeeklyRaceManager:getTotalPieceNum( ... )

	if self.matchData and self.matchData.totalPieceNum then
		return self.matchData.totalPieceNum
	end

	return 0
end

function SeasonWeeklyRaceManager:addPieceNum( delta )
	if self.matchData then
		self.matchData.pieceNum = (self.matchData.pieceNum or 0) + delta

		--totalPieceNum 只能增加 不能减少, 获得碎片时增加 使用碎片时不减少
		self.matchData.totalPieceNum = (self.matchData.totalPieceNum or 0) + math.max(delta, 0)

		self:flushToStorage()

		self.eventDispatcher:dispatchEvent(Event.new(SummerWeeklyMatchEvents.kPiecesNumChange))

	end
end

function SeasonWeeklyRaceManager:getSkins( ... )
	if self.matchData and self.matchData.skins then
		return self.matchData.skins
	end
	return {}
end

function SeasonWeeklyRaceManager:getCurSkin( ... )
	if self.matchData and self.matchData.curSkin then
		return self.matchData.curSkin
	end
	return {}
end

function SeasonWeeklyRaceManager:setSkins( skins )
	if self.matchData then
		self.matchData.skins = table.clone(skins, true)
		self:flushToStorage()
	end
end

function SeasonWeeklyRaceManager:setCurSkin( curSkin )
	if self.matchData then
		self.matchData.curSkin = table.clone(curSkin, true)
		self:flushToStorage()
	end
end

function SeasonWeeklyRaceManager:isSkinGroupPositionSetted(skinType, group, position)
	local skins = self:getSkins()
	local skinGrp = skins[skinType] or  {}
	local skinData = skinGrp[group] or  {}
	return table.exist(skinData, position)
end

function SeasonWeeklyRaceManager:getSkinGroupPositionNum(skinType, group)
	local skins = self:getSkins()
	local skinGrp = skins[skinType] or {}
	local skinData = skinGrp[group] or {}
	return #skinData
end

function SeasonWeeklyRaceManager:setSkinGroupPosition(skinType, group, position)
	local skins = table.clone(self:getSkins(), true)
	skins[skinType] = skins[skinType]  or {}
	local skinGrp = skins[skinType]
	skinGrp[group] = skinGrp[group] or {}
	local skinData = skinGrp[group]
	table.insertIfNotExist(skinData, position)
	self:setSkins(skins)
end

function SeasonWeeklyRaceManager:changeSkin(skinType, group)
	local curSkin = table.clone(self:getCurSkin(), true)
	curSkin[skinType] = group
	self:setCurSkin(curSkin)
end

function SeasonWeeklyRaceManager:isCompleteAll( ... )
	local NpcTigger = require 'zoo.panel.seasonWeekly.mainPanel.NpcTigger'
	return NpcTigger:isCompleteAll()
end

function SeasonWeeklyRaceManager:isPiecesEnoughToCompleteAll( ... )
	local NpcTigger = require 'zoo.panel.seasonWeekly.mainPanel.NpcTigger'
	return NpcTigger:isPiecesEnoughToCompleteAll()
end

function SeasonWeeklyRaceManager:usePiece( skinType, group, position, onSuccess, onFail, onCancel)

	

	if self:isSkinGroupPositionSetted(skinType, group, position) then
		if onCancel then onCancel() end
		return
	end

	if self:getPieceNum() <= 0 then
		if onFail then onFail() end
		return
	end


	local http = SeasonWeeklyRaceHttpUtil.newUsePieceHttp(function ( ... )
			
		self:addPieceNum(-1)
		self:setSkinGroupPosition(skinType, group, position)

		if onSuccess then
			onSuccess()
		end

	end, onFail, onCancel)

	http:load(skinType, group, position)

end

--2017 冬季周赛，上来每人就给一个奖励
function SeasonWeeklyRaceManager:getInitRewards( onSuccess, onFail)

	local rewardId = 16
	local http = GetRewardsHttp.new(false)
	http:ad(Events.kComplete, function ( evt )

		if type(evt.data) ~= "table" or type(evt.data.rewardItems) ~= "table" then 
			return 
		end
		-- 注释掉因为暂时不用了 再启用请加打点
		assert(false, "look at here!")
		-- UserManager:getInstance():addRewards(evt.data.rewardItems)

		UserManager:getInstance():setUserRewardBit(rewardId, true)
		UserService:getInstance():setUserRewardBit(rewardId, true)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		end

		if onSuccess then
			self.isGotFreeProp = true
			onSuccess(evt)
		end
	end)

	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onFail)

	if false and __WIN32 then
		if onSuccess then
			onSuccess({data = {rewardItems = {{itemId = 14, num = 2}}}})
		end
	else
		http:load(rewardId)
	end

end

function SeasonWeeklyRaceManager:hadGotInitRewards( ... )
	-- body
	return UserManager:getInstance():isUserRewardBitSet(16)
end

function SeasonWeeklyRaceManager:setSkin( skinType, group, onSuccess, onFail, onCancel)


	local NpcTigger = require 'zoo.panel.seasonWeekly.mainPanel.NpcTigger'

	if group ~= -1 and (not NpcTigger:isComplete(skinType, group)) then
		if onFail then onFail() end
		return
	end

	local http = SeasonWeeklyRaceHttpUtil.newSetSkinHttp(function ( ... )
		
		self:changeSkin(skinType, group)

		self.eventDispatcher:dispatchEvent(Event.new(SummerWeeklyMatchEvents.kNpcSkinChange))

		if onSuccess then
			onSuccess()
		end

	end, onFail, onCancel)

	http:load(skinType, group)

end

--skin----end ----





function SeasonWeeklyRaceManager:getCurWeekRewards()
	local rewards = {}
	local weeklyRewards = self:getWeeklyRewards()

	if weeklyRewards and #weeklyRewards > 0 then
		for i, reward in ipairs(weeklyRewards) do
			local rewardDetail = {}
			rewardDetail.id = reward.id
			rewardDetail.condition = reward.condition
			rewardDetail.needMore = 0
			if self.matchData.weeklyScore < reward.condition then
				rewardDetail.needMore = reward.condition - self.matchData.weeklyScore
			end
			rewardDetail.items = reward.items
			if table.exist(self.matchData.receivedWeeklyRewards, i) then
				rewardDetail.hasReceived = true
			else
				rewardDetail.hasReceived = false
			end

			local isLast = self.matchData and self.matchData.lastWeekRewards and #self.matchData.lastWeekRewards > 0 and table.exist(self.matchData.lastWeekRewards, reward.id)

			if not isLast then
				table.insert(rewards, rewardDetail)
			end
		end
	end

	return rewards
end

function SeasonWeeklyRaceManager:getLastWeekRewardsForRewardsPanel()
	local weeklyRewards = self:getNextWeeklyReward()
	local rewards = self:getLastWeekRewards()
	local randRewards = self:getLastWeekRankRewards()
	local totalRankRewards = self:getLastWeekTotalRankRewards()

	local allRankRewards = table.union(randRewards, totalRankRewards)

	local realRankRewards = {}
	local realTotalRankRewards = {}

	for k, v in pairs(allRankRewards) do
		if SeasonWeeklyRaceConfig:getInstance():isSurpassReward(v) then
			table.insert(realRankRewards, v)
		elseif SeasonWeeklyRaceConfig:getInstance():isTotalSurpassReward(v) then
			table.insert(realTotalRankRewards, v)
		end
	end

	if #realRankRewards > 0 then
		table.insert(rewards, {items = realRankRewards, id = 7})
	end

	if #realTotalRankRewards > 0 then
		table.insert(rewards, {items = realTotalRankRewards, id = 8})
	end

	return rewards, 0
end

function SeasonWeeklyRaceManager:getLastWeekRankRewards()
	local levelId = self.levelId
	if self.matchData and self.matchData.lastWeekRankRewards and #self.matchData.lastWeekRankRewards > 0 then
		return self.matchData.lastWeekRankRewards, levelId, self.matchData.lastWeekRank, self.matchData.lastWeekSurpass
	end
	return {}, levelId, 0, 0
end

function SeasonWeeklyRaceManager:getLastWeekTotalRankRewards()
	local levelId = self.levelId
	if self.matchData and self.matchData.lastWeekTotalRankRewards and #self.matchData.lastWeekTotalRankRewards >= 0 then
		return self.matchData.lastWeekTotalRankRewards or {}, levelId, self.matchData.lastWeekTotalRank or 0, self.matchData.lastWeekTotalSurpass or 0
	end
	return {}, levelId, 0, 0
end

-- 获取上周排行奖励
function SeasonWeeklyRaceManager:getLastWeekRankRewardsForRewardsPanel()
	local rewards, levelId, num1, num2 = self:getLastWeekRankRewards()
	local totoalRewards, levelId, totalNum1, totalNum2 = self:getLastWeekTotalRankRewards()

	local thisWeek = self:getWeek(Localhost:timeInSec())
	local lastWeek = self:getWeek(tonumber(CCUserDefault:sharedUserDefault():getStringForKey("game.weekly.summer.lask.rank")) or 0)
	if thisWeek == lastWeek then
		return {}, levelId, 0, 0
	end

	local lastRankPos
	local lastPassFriendNum	
	if totalNum1 <= 0 then
		lastRankPos = num1
		lastPassFriendNum = num2
	elseif num1 < totalNum1 and num1 > 0 then
		lastRankPos = num1
		lastPassFriendNum = num2
	else
		lastRankPos = totalNum1
		lastPassFriendNum = totalNum2
	end

	return table.union(rewards, totoalRewards), levelId, lastRankPos, lastPassFriendNum
end

function SeasonWeeklyRaceManager:setLastWeekRankRewardsCancelFlag()
	CCUserDefault:sharedUserDefault():setStringForKey("game.weekly.summer.lask.rank", tostring(Localhost:timeInSec()))
	CCUserDefault:sharedUserDefault():flush()
end

function SeasonWeeklyRaceManager:receiveReward(levelId, rewardType, rewardId, onSuccess, onFail, onCancel)
	local function onRequestSuccess(evt)
		if onSuccess then onSuccess(evt) end
	end
	local function onRequestFail(evt)
		if onFail then onFail(evt) end
	end
	local function onRequestCancel(evt)
		if onCancel then onCancel(evt) end
	end

	local http = SeasonWeeklyRaceHttpUtil.newGetRewardsHttp(onRequestSuccess, onRequestFail, onRequestCancel)
	
	local function afterLogin()
		http:syncLoad(levelId, rewardType, rewardId, self.wday)
	end
	RequireNetworkAlert:callFuncWithLogged(afterLogin, afterLogin, kRequireNetworkAlertAnimation.kSync)
end

function SeasonWeeklyRaceManager:onPlayMainLevel()

	printx( 1 , "	SeasonWeeklyRaceManager:onPlayMainLevel	  --------------------------")
	self:getAndUpdateMatchData():addDailyLevelPlayCount(1)

	if self.matchData.dailyLevelPlay > SeasonWeeklyRaceConfig:getInstance().dailyMainLevelPlay then
		return
	end

	local leftMainLevelCountToAddWeeklyPlayCount = 
			self.matchData.dailyLevelPlay % SeasonWeeklyRaceConfig:getInstance().addWeeklyPlayCountPerMainLevelPlay

	printx( 1 , "	leftMainLevelCountToAddWeeklyPlayCount = " , leftMainLevelCountToAddWeeklyPlayCount)
	if leftMainLevelCountToAddWeeklyPlayCount == 0 then
		self.matchData:incrLeftPlay(SeasonWeeklyRaceConfig:getInstance().freePlayByMainLevel)
	end

	self:flushToStorage()
	self:onDataChanged( {button = true} )
end

function SeasonWeeklyRaceManager:getShareCount()
	return self.matchData.dailyShare or 0
end

function SeasonWeeklyRaceManager:getLevelMaxScore()
	return self.matchData.levelMax
end

function SeasonWeeklyRaceManager:getWeeklyScore()
	return self.matchData.weeklyScore
end

function SeasonWeeklyRaceManager:onShareSuccess( onSuccess, onFail, onCancel )
	local function sendNotify()
		local function onNotifySuccess( evt )
			-- printx( 3 , ' ', table.tostring(evt))
			if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
				self:getAndUpdateMatchData():addShareCount(1)
				local isAddCount = false
				if self.matchData.dailyShare == SeasonWeeklyRaceConfig:getInstance().dailyShare then
					--self.matchData:incrLeftPlay(SeasonWeeklyRaceConfig:getInstance().freePlayByShare)
					isAddCount = true
				end
				self:flushToStorage()
				self:onDataChanged({top=true,button=true})
				if onSuccess then onSuccess(isAddCount) end
			else
				-- printx( 3 , ' not mitalk')
				if type(evt.data) == "table" and type(tonumber(evt.data.extra)) == "number" then
					--self.matchData:incrLeftPlay(tonumber(evt.data.extra))
					self:getAndUpdateMatchData():addShareCount((tonumber(evt.data.extra) > 0) and 1 or 0)
				end
				self:flushToStorage()
				self:onDataChanged({top=true,button=true})
				if onSuccess then onSuccess(tonumber(evt.data.extra)) end
			end
		end

		local function onNotifyFail(evt)
			if onFail then onFail(evt) end
		end

		local function onNotifyCancel(evt)
			if onCancel then onCancel() end
		end

		local http = SeasonWeeklyRaceHttpUtil.newOpNotifyHttp(onNotifySuccess, onNotifyFail, onNotifyCancel)
		-- if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		--	http:syncLoad(OpNotifyType.kAutumnWeekMatchShare, {})
		-- else
			http:syncLoad(OpNotifyType.kRdefSpringWeekMatchShare, {})
		-- end
	end

	local function onLoginFailed()
		if onFail then onFail() end
	end
	RequireNetworkAlert:callFuncWithLogged(sendNotify, onLoginFailed, kRequireNetworkAlertAnimation.kSync)
end

function SeasonWeeklyRaceManager:isDailyFirstShare()
	-- 需求 去掉分享面板上分享得次数功能
	return false
	-- return self.matchData.dailyShare < SeasonWeeklyRaceConfig:getInstance().dailyShare
end

function SeasonWeeklyRaceManager:onPaySuccess()
	self.matchData:incrLeftPlay(1)
	self:flushToStorage()
	self:onDataChanged( {button = true} )
end

-- TODO Localhost:timeInSec()与打开面板的时间差
function SeasonWeeklyRaceManager:getNextDayDailyRewards()
	local nextDayTime = Localhost:timeInSec() + DAY_SEC
	local wday = self:getWDay(nextDayTime)
	return self:getDailyRewardsByDay(wday)
end

function SeasonWeeklyRaceManager:getDailyRewardsByDay(wday)
	return SeasonWeeklyRaceConfig:getInstance():getDailyRewardsByDay(wday)
end

function SeasonWeeklyRaceManager:getNextDailyReward()
	local ret = nil

	local reward = nil
	local isAllReceived = false
	local wday = self:getWDay(Localhost:timeInSec())
	local todayRewards = self:getDailyRewardsByDay(wday)
	if todayRewards and #todayRewards > 0 then
		if #self.matchData.receivedDailyRewards < #todayRewards then
			for i = 1, #todayRewards do
				if not table.exist(self.matchData.receivedDailyRewards, i) then
					reward = todayRewards[i]
					break
				end
			end
		else
			isAllReceived = true
			local nextdayRewards = self:getNextDayDailyRewards()
			if nextdayRewards and #nextdayRewards > 0 then 
				reward = nextdayRewards[1]
			end
		end
	end

	if reward then
		ret = {}
		ret.id = reward.id
		ret.condition = reward.condition
		ret.needMore = 0
		if self.matchData.levelMax < reward.condition then
			ret.needMore = reward.condition - self.matchData.levelMax
		end
		ret.nextDayReward = isAllReceived
		ret.items = reward.items
	end

	-- if _G.isLocalDevelopMode then printx(0, "getNextDailyReward:", table.tostring(ret)) end
	return ret
end

function SeasonWeeklyRaceManager:getCurDailyRewards()
	local rewards = {}

	local wday = self:getWDay(Localhost:timeInSec())
	local todayRewards = self:getDailyRewardsByDay(wday)
	if todayRewards and #todayRewards > 0 then
		if #self.matchData.receivedDailyRewards < #todayRewards then
			for i = 1, #todayRewards do
				if not table.exist(self.matchData.receivedDailyRewards, i) then
					local r = todayRewards[i]
					local reward = {}
					reward.id = r.id
					reward.condition = r.condition
					reward.needMore = 0
					if self.matchData.levelMax < reward.condition then
						reward.needMore = reward.condition - self.matchData.levelMax
					end

					reward.items = r.items
					table.insert(rewards, reward)
				end
			end
		end
	end
	return rewards
end

--------------------------------------------------
-- 获得今天所有未领取的奖励，不论是否处于可领奖状态
--------------------------------------------------
function SeasonWeeklyRaceManager:getRewardsTodayNotGain()
	local rewardInfo = self:getCurDailyRewards()
	local rRewardList = {}
	for i=1, #rewardInfo do
		if rewardInfo[i] ~= nil and rewardInfo[i].items ~= nil and #rewardInfo[i].items > 0 then
			for j=1, #rewardInfo[i].items do
				rRewardList[#rRewardList+1] = rewardInfo[i].items[j]
			end
		end
	end

	return rRewardList
end

--------------------------------------------------
-- 获得今天所有可以领取但是状态为未领取的奖励
--------------------------------------------------
function SeasonWeeklyRaceManager:getRewardsTodayCanGain()
	local rewardInfo = self:getCurDailyRewards()
	local rRewardList = {}
	for i=1, #rewardInfo do
		if rewardInfo[i] ~= nil and rewardInfo[i].needMore < 1 and	rewardInfo[i].items ~= nil and #rewardInfo[i].items > 0 then
			for j=1, #rewardInfo[i].items do
				rRewardList[#rRewardList+1] = rewardInfo[i].items[j]
			end
		end
	end

	return rRewardList
end

function SeasonWeeklyRaceManager:getNextWeeklyReward()
	local ret = {}

	local weeklyRewards = self:getWeeklyRewards()
	if weeklyRewards and #weeklyRewards > 0 then
		for i, reward in ipairs(weeklyRewards) do
			local rewardDetail = {}
			rewardDetail.id = reward.id
			rewardDetail.condition = reward.condition
			rewardDetail.needMore = 0
			if self.matchData.weeklyScore < reward.condition then
				rewardDetail.needMore = reward.condition - self.matchData.weeklyScore
			end
			rewardDetail.items = reward.items
			if table.exist(self.matchData.receivedWeeklyRewards, i) then
				rewardDetail.hasReceived = true
			else
				rewardDetail.hasReceived = false
			end
			table.insert(ret, rewardDetail)
		end
	end
	return ret
end

function SeasonWeeklyRaceManager:getLeftPlay()
	return self.matchData.leftPlay
end

function SeasonWeeklyRaceManager:getExtraNum()
	return self.matchData.accumulateWeekShareRewardCount or 0
end

function SeasonWeeklyRaceManager:getExtraPiecesNum()
	return self.matchData.linkPieceNum or 0
end

function SeasonWeeklyRaceManager:canGetFreePlay()
	--return not self:hasDailyShareCompleted() or not self:hasDailyLevelPlayCompleted()
	return not self:hasDailyLevelPlayCompleted()
end

function SeasonWeeklyRaceManager:hasDailyShareCompleted()
	return self.matchData.dailyShare >= SeasonWeeklyRaceConfig:getInstance().dailyShare
end

function SeasonWeeklyRaceManager:hasDailyLevelPlayCompleted()
	return self.matchData.dailyLevelPlay >= SeasonWeeklyRaceConfig:getInstance().dailyMainLevelPlay
end

function SeasonWeeklyRaceManager:getLeftMainLevelCountToAddWeeklyPlayCount()
	return self.matchData.dailyLevelPlay % SeasonWeeklyRaceConfig:getInstance().addWeeklyPlayCountPerMainLevelPlay
end		

function SeasonWeeklyRaceManager:getDailyLevelPlayCount()
	return self.matchData.dailyLevelPlay
end

function SeasonWeeklyRaceManager:getRankMinScore()
	return SeasonWeeklyRaceConfig:getInstance():getRankMinScore()
end

function SeasonWeeklyRaceManager:getTotalRankMinScore( ... )
	return SeasonWeeklyRaceConfig:getInstance():getTotalRankMinScore()
end

function SeasonWeeklyRaceManager:canShareChamp()
	if not self.onceRankData or self.onceRankData:getRankNum() < 5 then return false end
	local newRank = self.onceRankData and self.onceRankData:getMyRank() or 0
	if newRank > 0 then
		local data = self:getShowOffData()
		if newRank == 1 and data.dailyChampShared < 1 then
			return true
		end
	end
	return false
end

function SeasonWeeklyRaceManager:canShareSurpass()
	if not self.onceRankData or self.onceRankData:getRankNum() < 5 then return false end
	local surpassFriends = SeasonWeeklyRaceManager:getInstance():getSurpassFriends() or {}
	if #surpassFriends <= 0 then return false end
	local hasFriend = FriendManager:getInstance():getFriendCount() > 0
	local bindedQQ = (UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kQQ) ~= nil)

	if hasFriend or bindedQQ then
		local newRank = self.onceRankData and self.onceRankData:getMyRank() or 0
		if self.oldRank and newRank > 0 then
			local data = self:getShowOffData()
			if self.oldRank == 0 or newRank < self.oldRank then -- 之前没有进入排行榜
				return self.onceRankData:getSurpassCount() > 0 and data.dailySurpassShared < 1
			end
		end
	end
	return false
end

function SeasonWeeklyRaceManager:canShareSurpassNation()

	local hasFriend = FriendManager:getInstance():getFriendCount() > 0
	local supportQQ = PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true)
	local bindedQQ = (UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kQQ) ~= nil)
	local levelOk = UserManager.getInstance().user:getTopLevelId() >= 46
	local data = self:getShowOffData()

	if data.dailySurpassShared < 1 and levelOk and not hasFriend and supportQQ and not bindedQQ then
		local myScore = self:getWeeklyScore()
		local wday = self:getWDay(Localhost:timeInSec())
		if myScore > 360 * wday then
			return 4 -- 99%
		elseif myScore > 300 * wday then
			return 3 -- 90%
		elseif myScore > 240 * wday then
			return 2 -- 80%
		elseif myScore > 180 * wday then
			return 1 -- 50%
		else
			return false
		end
	end
	return false
end

function SeasonWeeklyRaceManager:onShareSurpassNationSuccess(suprassNationType)
	-- todo
	local data = self:getShowOffData()
	data:incrSurpassShared()
	local extraData = Localhost:getInstance():readLocalExtraData() or {}
	extraData.summerWeeklyShowOff = data
	Localhost:getInstance():flushLocalExtraData(extraData)
	-- AchievementManager:onShareSuccess(AchievementManager.shareId.WEEKLY_GEM_OVER_NATION, data)
end

function SeasonWeeklyRaceManager:getSurpassFriends()
	if not self.onceRankData then return {} end
	return self.onceRankData:getSurpassFriends()
end

function SeasonWeeklyRaceManager:getTotalSurpassFriends()
	if not self.allRankData then return {} end
	return self.allRankData:getSurpassFriends()
end

function SeasonWeeklyRaceManager:getShowOffData()
	if not self.showOffData then
		local extraData = Localhost:getInstance():readLocalExtraData()
		if extraData and extraData.summerWeeklyShowOff then 
			self.showOffData = SeasonWeeklyShowOffData:fromLua(extraData.summerWeeklyShowOff)
		end
	end
	if not self.showOffData or self.showOffData:hasExpired() then
		self.showOffData = SeasonWeeklyShowOffData:create()
	end
	return self.showOffData
end

function SeasonWeeklyRaceManager:onShareChampSuccess()
	local data = self:getShowOffData()
	data:incrChampShared()
	local extraData = Localhost:getInstance():readLocalExtraData() or {}
	extraData.summerWeeklyShowOff = data
	Localhost:getInstance():flushLocalExtraData(extraData)
	-- AchievementManager:onShareSuccess(AchievementManager.shareId.WEEKLY_FIRST_FRI_RANK, data)
end

function SeasonWeeklyRaceManager:onShareSurpassSuccess()
	local data = self:getShowOffData()
	data:incrSurpassShared()
	local extraData = Localhost:getInstance():readLocalExtraData() or {}
	extraData.summerWeeklyShowOff = data
	Localhost:getInstance():flushLocalExtraData(extraData)
	-- AchievementManager:onShareSuccess(AchievementManager.shareId.WEEKLY_GEM_OVER_FRIEND, data)
end

function SeasonWeeklyRaceManager:getTipShowTimes(tipType)
	local data = self:getShowOffData()
	return data:getTipShowCount(tipType)
end

function SeasonWeeklyRaceManager:onShowTip(tipType)
	local data = self:getShowOffData()
	data:onShowTip(tipType)
	-- save data
	local extraData = Localhost:getInstance():readLocalExtraData() or {}
	extraData.summerWeeklyShowOff = data
	Localhost:getInstance():flushLocalExtraData(extraData)
end

function SeasonWeeklyRaceManager:isShowDailyFirstTip()
	local data = self:getShowOffData()
	return data.showPlayTip
end

function SeasonWeeklyRaceManager:onShowDailyFirstTip()
	local data = self:getShowOffData()
	data.showPlayTip = false
	local extraData = Localhost:getInstance():readLocalExtraData() or {}
	extraData.summerWeeklyShowOff = data
	Localhost:getInstance():flushLocalExtraData(extraData)
end

function SeasonWeeklyRaceManager:filterOnceRankData(onceRankData)
	local res = {}
	if onceRankData then
		for i,v in ipairs(onceRankData) do
			local friendRef = FriendManager.getInstance().friends[tostring(v.uid)]
			if friendRef then 
				table.insert(res, v)
			end
		end
	end
	return res
end

function SeasonWeeklyRaceManager:getRankData( onSuccess, onFail )
	local levelId = self.levelId

	local successCounter = 0
	local failCounter = 0

	local function callback( ... )
		if failCounter + successCounter >= 2 then
			if failCounter >= 1 then
				if onFail then
					onFail()
				end
			else
				if onSuccess then
					onSuccess()
				end
			end
		end
	end

	local function __success( ... )
		successCounter = successCounter + 1
		callback()
	end

	local function __fail( ... )
		failCounter = failCounter + 1
		callback()
	end


	local function onOnceRankSuccess( data )
		local rankList = data.rankList
		local myRank = data.rank
		local myScore = data.value
		--这里会传不在自己好友中 却在全国排行榜里的玩家的profile
		local globalProfile = data.profiles

		self.onceRankData = SeasonWeeklyMatchRankData.new(self:getRankMinScore())
		local activeFriends = {}
		if self.matchData and not self:hasWeekChanged(self.matchData) then
			activeFriends = self.matchData.activeFriends
		end

		self.uid = UserManager.getInstance().uid
		self.onceRankData:initWithData(self.uid , self:filterOnceRankData(rankList) , activeFriends)
		self.onceRankData:updateMyScore(myScore , myRank)
		self.onceRankData:initPassFriendInfo(rankList, globalProfile)
		
		if __success then __success() end
	end

	local function onOnceRankFail(err)
		self.onceRankData = nil
		if __fail then __fail(err) end
	end


	local function onAllRankSuccess( data )
		local rankList = data.rankList
		local myRank = data.rank
		local myScore = data.value
		self.allRankData = SeasonWeeklyMatchRankData.new(self:getTotalRankMinScore())
		local activeFriends = {}
		if self.matchData and not self:hasWeekChanged(self.matchData) then
			activeFriends = self.matchData.activeFriends
		end

		self.uid = UserManager.getInstance().uid
		self.allRankData:initWithData(self.uid , rankList , activeFriends)
		self.allRankData:updateMyScore(myScore , myRank)
		
		if __success then __success() end
	end

	local function onAllRankFail(err)
		self.allRankData = nil
		if __fail then __fail(err) end
	end

	SyncManager.getInstance():addAfterSyncHttp( 
		kHttpEndPoints.getCommonRankList , 
		{rankType = CommonRankType.kSpringWeekMatck, subType = 1, levelId = levelId} , 
		function (result, data)
		 	if result then 
		 		onOnceRankSuccess(data)
		 	else
		 		onOnceRankFail(data)
		 	end
		 end , {allowMergers = false} )

	SyncManager.getInstance():addAfterSyncHttp( 
		kHttpEndPoints.getCommonRankList , 
		{rankType = CommonRankType.kSpringWeekMatck, subType = 2, levelId = levelId} , 
		function (result, data)
		 	if result then 
		 		onAllRankSuccess(data)
		 	else
		 		onAllRankFail(data)
		 	end
		 end , {allowMergers = false} )

	if _G.kUserLogin then
		SyncManager.getInstance():sync(nil, nil, kRequireNetworkAlertAnimation.kNoAnimation)
	end
	-- onOnceRankSuccess({data = {
	--	rank = 10, 
	--	value = 0,
	--	rankList = {
	--		{uid = 12345, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12346, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12347, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12348, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12349, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--	}
	-- }})
	-- onAllRankSuccess({data = {
	--	rank = 120, 
	--	value = 44444,
	--	rankList = {
	--		{uid = 12345, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12346, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12347, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12348, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--		{uid = 12349, score = 12345, levelId = 6, rank = 100, globalRank = 100,},
	--	}
	-- }})

end


function SeasonWeeklyRaceManager:flushToStorage()
	if self.matchData then
		Localhost.getInstance():writeWeeklyMatchData(self.matchData:encode())
	end
end

function SeasonWeeklyRaceManager:readFromStorage()
	local data = Localhost.getInstance():readWeeklyMatchData()



	if data then
		return SeasonWeeklyRaceData:fromLua(data)
	end
	return nil
end

function SeasonWeeklyRaceManager:onStartLevel()
	self:onShowTip(2)
	self:setQuestionMarkToAddMoveNum(0)
	self.matchData:setLastPlayedTime()
	self:flushToStorage()
end

function SeasonWeeklyRaceManager:canPlayIconAnimation()
	local mru = self.matchData:getLastPlayedTime()/1000
	if compareDate(os.date("*t", Localhost:timeInSec()), os.date("*t", mru)) ~= 0 then
        return true
    end
	return false
end

function SeasonWeeklyRaceManager:onPassLevel(levelId, targetCount)
	if self.onceRankData then
		self.oldRank = self.onceRankData:getMyRank()
	end
	if type(targetCount) == "number" and targetCount > 0 then
		self:getAndUpdateMatchData()
		self.matchData:addScore(targetCount)
		-- self:flushToStorage()
		-- self:onDataChanged(true)

		if self:hasWeeklyRewards() then
			LocalNotificationManager.getInstance():setWeeklyRaceRewardNotification()
		end

		local num2 = 0
		for _, v in pairs(self.lottery.boxRewards) do
			if v.id == 18 then 
				num2 = num2 + v.num
			end
		end
		DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_gem_num', level_id=levelId, num=targetCount, num2=num2}, true)
		self.lottery:addRewards()

		self.matchData:addScore(num2)

	end

	self.matchData:decrLeftPlay()
	self.matchData.totalPlayed = self.matchData.totalPlayed + 1
	self.matchData.lastIndexFinished = true
	self:flushToStorage()

	self:onDataChanged( {top = true , rewards = true , button = true , ranking = true, type = "passlevel"})
end

function SeasonWeeklyRaceManager:dcCanReceiveRewards( ... )
	local dRewards = SeasonWeeklyRaceManager:getInstance():getCurDailyRewards()
	
	if dRewards then
		for _,reward in ipairs(dRewards) do
			if reward and reward.needMore == 0 then
				DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_winter_2016_satisfy_dailyreward', reward_id=reward.id}, true)
			end
		end
	end
	
	local wRewards = SeasonWeeklyRaceManager:getInstance():getCurWeekRewards()
	if wRewards then
		for _,reward in ipairs(wRewards) do
			if reward.needMore == 0 and not reward.hasReceived then
				DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_satisfy_weeklyreward', reward_id=reward.id}, true)
			end
		end
	end
end

function SeasonWeeklyRaceManager:tryToShareOnPassLevel(gameResult)
	if gameResult and gameResult.levelType == GameLevelType.kSummerWeekly then
		-- 国庆获得骰子
		local function onShareFinished()
			local QixiManager = require 'zoo.eggs.QixiManager'
			QixiManager:getInstance():onSeasonWeeklyEnd()
		end

		if not self.isDisposed then
			--self:refreshAll()
		end

		self:dcCanReceiveRewards()

		local explorerShare = false
		if gameResult.scrollRowNum and gameResult.scrollRowNum >= 50 then -- 滚屏超过50行触发
		end

		SeasonWeeklyRaceManager:getInstance():getRankData(function()
			if explorerShare then return end

			local scene = Director:sharedDirector():getRunningSceneLua()
			if not self.isDisposed and scene and scene:is(HomeScene) then
				--self:onDataChanged(false)
				if (not ShareManager:isTrigger(130)) 
					and SeasonWeeklyRaceManager:getInstance():canShareSurpass() then
					local surpassFriends = SeasonWeeklyRaceManager:getInstance():getSurpassFriends()
					local panel = SeasonWeeklyRacePassPanel:create(surpassFriends)
					panel:popout(onShareFinished)
					SeasonWeeklyRaceManager:getInstance():onShareSurpassSuccess()
				else
					local surpassNationType = SeasonWeeklyRaceManager:getInstance():canShareSurpassNation()
					if (not ShareManager:isTrigger(140)) 
						and surpassNationType ~= false then
						local panel = SeasonWeeklyRacePassPanel:create(nil, surpassNationType)
						panel:popout(onShareFinished)
						SeasonWeeklyRaceManager:getInstance():onShareSurpassNationSuccess(surpassNationType)
					else
						onShareFinished()
					end
				end
			end
		end,function( ... )

			onShareFinished()
		end)
	end 
end

function SeasonWeeklyRaceManager:canGetSurpassReward()
	return self:needNumToGetSurpassReward() <= 0
end

function SeasonWeeklyRaceManager:canGetTotalSurpassReward()
	return self:needNumToGetTotalSurpassReward() <= 0
end

function SeasonWeeklyRaceManager:needNumToGetSurpassReward()
	if not self.onceRankData then return SeasonWeeklyRaceConfig:getInstance().rankRewardWeight end

	local surpassCount = self.onceRankData:getSurpassCount()
	local needMore = SeasonWeeklyRaceConfig:getInstance().rankRewardWeight - surpassCount

	if needMore < 0 then needMore = 0 end

	return needMore
end

function SeasonWeeklyRaceManager:needNumToGetTotalSurpassReward( ... )
	if not self.allRankData then return SeasonWeeklyRaceConfig:getInstance().totalRankRewardWeight end

	local surpassCount = self.allRankData:getSurpassCount()
	local needMore = SeasonWeeklyRaceConfig:getInstance().totalRankRewardWeight - surpassCount

	if needMore < 0 then needMore = 0 end

	return needMore
end

function SeasonWeeklyRaceManager:getSurpassGoldReward()
	local surpass = self.onceRankData:getSurpassCount()
	local goldReward = 0
	local surpassLimit = SeasonWeeklyRaceConfig:getInstance():getSurpassLimit()
	local surpassRewards = SeasonWeeklyRaceConfig:getInstance():getSurpassRewards()

	if surpass > surpassLimit then surpass = surpassLimit end
	if surpassRewards then
		for _, v in pairs(surpassRewards) do
			if v.itemId == 2 then
				goldReward = goldReward + v.num * surpass
			end
		end
	end
	return goldReward, surpass
end

function SeasonWeeklyRaceManager:getTotalSurpassGoldReward( ... )
	local surpass = self.allRankData:getSurpassCount()
	local goldReward = 0
	local surpassLimit = SeasonWeeklyRaceConfig:getInstance():getSurpassLimit()
	local surpassRewards = SeasonWeeklyRaceConfig:getInstance():getTotalSurpassRewards()

	if surpass > surpassLimit then surpass = surpassLimit end
	if surpassRewards then
		for _, v in pairs(surpassRewards) do
			if v.itemId == 2 then
				goldReward = goldReward + v.num * surpass
			end
		end
	end
	return goldReward, surpass
end

function SeasonWeeklyRaceManager:getLeftBuyCount()
	local goodId = self:getBuyGoodId()
	local num = UserManager:getInstance():getDailyBoughtGoodsNumById(goodId)
	local meta = MetaManager:getInstance():getGoodMeta(goodId)
	return meta.limit - num
end

function SeasonWeeklyRaceManager:getMaxBuyCount()
	local goodId = self:getBuyGoodId()
	return MetaManager:getInstance():getGoodMeta(goodId).limit
end

function SeasonWeeklyRaceManager:getBuyRmb( ... )
	local goodId = self:getBuyGoodId()
	local meta = MetaManager:getInstance():getGoodMeta(goodId)
	return meta.rmb / 100
end

function SeasonWeeklyRaceManager:getBuyQCash( ... )
	local goodId = self:getBuyGoodId()
	local meta = MetaManager:getInstance():getGoodMeta(goodId)
	return meta.qCash
end

function SeasonWeeklyRaceManager:getBuyGoodId( ... )
	return SeasonWeeklyRaceConfig:getInstance().playCardGoodId
end

function SeasonWeeklyRaceManager:getDazhaoGoodId()
	return SeasonWeeklyRaceConfig:getInstance().dazhaoGoodId
end

function SeasonWeeklyRaceManager:applyForNewShareQrCode(count, ts, weeklyType, successCallback, failCallback, cancelCallback)
	local function onSuccess(evt)
		if type(evt.data.targetCount) == "number" then
			count = evt.data.targetCount
		else
			count = math.ceil(count / 5) * 5
		end
		if successCallback then successCallback(count, evt.data.qrCodeId) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end
	local http = SendQrCodeHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:syncLoad(weeklyType, ts, count)
end

function SeasonWeeklyRaceManager:snsShare(imagePath, title, text, successCallback, failCallback, cancelCallback)
	local shareCallback = {
		onSuccess = function(result)
			if successCallback then successCallback(false) end
		end,
		onError = function(errCode, errMsg)
			if failCallback then failCallback() end
		end,
		onCancel = function()
			if cancelCallback then cancelCallback() end
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
		return
	end
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendImageMessage(shareType, title, text, thumb,
	imagePath, shareCallback)
end

function SeasonWeeklyRaceManager:snsShareForResultPanelAndMitalk(imagePath, title, text, successCallback, failCallback, cancelCallback)
	local shareCallback = {
		onSuccess = function(result)
			if successCallback then successCallback(false) end
		end,
		onError = function(errCode, errMsg)
			if failCallback then failCallback() end
		end,
		onCancel = function()
			if cancelCallback then cancelCallback() end
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
		return
	end
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		SnsUtil.sendImageLinkMessage(PlatformShareEnum.kMiTalk, title, text, thumb, imagePath, shareCallback, gShareSource.WEEKLY_MATCH)
	end
end

--这个是发送点对点分享的
function SeasonWeeklyRaceManager:snsShareForFeed(title, text, linkUrl,thumbAddress,successCallback, failCallback, cancelCallback)
	local shareCallback = {
		onSuccess = function(result)
			if successCallback then successCallback(false) end
		end,
		onError = function(errCode, errMsg)
			if failCallback then failCallback() end
		end,
		onCancel = function()
			if cancelCallback then cancelCallback() end
		end,
	}

	if __WIN32 then
		shareCallback.onSuccess()
		return
	end
	if not thumbAddress then 
		thumbAddress = "materials/wechat_icon.png"
	end
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename(thumbAddress)
	local shareType, delayResume = SnsUtil.getShareType()

	if shareType == PlatformShareEnum.kJPWX or shareType == PlatformShareEnum.kWechat then
		if not OpenUrlUtil:canOpenUrl("weixin://") then
			if failCallback then failCallback(nil, nil, true) end
			return
		end
	end

	SnsUtil.sendLinkMessage(shareType, title, text, thumb, linkUrl, false, shareCallback, gShareSource.WEEKLY_MATCH)
end

function SeasonWeeklyRaceManager:showWeeklyTimeTutor()
	if self:hasDailyLevelPlayCompleted() then
		return
	end

	-- local userDefault = CCUserDefault:sharedUserDefault()
	-- local curTime = os.time()
	-- local lastTutorTime = userDefault:getStringForKey("summer.mainlevel.tutor.time")
	-- if lastTutorTime then 
	--	   local oneDaySec = 24 * 3600
	--	   lastTutorTime = tonumber(lastTutorTime)
	--	   if type(lastTutorTime) == "number" then 
	--		   if curTime - lastTutorTime < oneDaySec then 
	--			   return 
	--		   end
	--	   end
	-- end
	-- userDefault:setStringForKey("summer.mainlevel.tutor.time", tostring(curTime))
	-- userDefault:flush()

	local scene = HomeScene:sharedInstance()
	local layer = scene.guideLayer
	local levelId = UserManager:getInstance().user:getTopLevelId()
	
	local topLevelNode = scene.worldScene.levelToNode[levelId]
	if topLevelNode then 
		local pos = topLevelNode:getPosition()
		local worldPos = topLevelNode:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
		local trueMask = GameGuideUI:mask(180, 1, ccp(worldPos.x, worldPos.y-70), 1.2, false, false, false, false, true)
		trueMask.setFadeIn(0.3, 0.3)

		--关卡花代理
		local touchLayer = LayerColor:create()
		touchLayer:setColor(ccc3(255,0,0))
		touchLayer:setOpacity(0)
		touchLayer:setAnchorPoint(ccp(0.5, 0.5))
		touchLayer:ignoreAnchorPointForPosition(false)
		touchLayer:setPosition(ccp(worldPos.x, worldPos.y-70))
		touchLayer:changeWidthAndHeight(100, 100)
		touchLayer:setTouchEnabled(true, 0, true)

		local function onTrueMaskTap()
			--点击关闭引导
			if layer:contains(trueMask) then 
				layer:removeChild(trueMask)
			end
		end

		local function onTouchLayerTap()
			--关了自己
			onTrueMaskTap()
			--打最高关卡
			if not PopoutManager:sharedInstance():haveWindowOnScreen()
					and not HomeScene:sharedInstance().ladyBugOnScreen then
				local levelType = LevelType:getLevelTypeByLevelId(levelId)
				local startGamePanel = StartGamePanel:create(levelId, levelType)
				startGamePanel:popout(false)
			end
		end
		touchLayer:addEventListener(DisplayEvents.kTouchTap, onTouchLayerTap)
		trueMask:addChild(touchLayer)

		trueMask:addEventListener(DisplayEvents.kTouchTap, onTrueMaskTap)

		local panel = nil
		local action = 
		{	
			-- panAlign = "viewY", panPosY = pos.y - 50,
			panelName = 'guide_dialogue_WeeklyTimeTutor',
		}
		panel = GameGuideUI:panelS(nil, action, false)
		local text = localize('guide_dialogue_WeeklyTimeTutor.keepname_guide_dialogue_text_dynamic_35', {n = tostring(SeasonWeeklyRaceConfig:getInstance().dailyMainLevelPlay - self.matchData.dailyLevelPlay)})
		panel.ui:getChildByName('keepname_guide_dialogue_text_dynamic_35'):setString(text)

		panel:setPosition(ccp(worldPos.x-250, worldPos.y+50))
		local function addTipPanel()
			trueMask:addChild(panel)
		end
		trueMask:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(addTipPanel)))

		local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
		hand:setAnchorPoint(ccp(0, 1))
		hand:setPosition(ccp(worldPos.x , worldPos.y - 70))
		trueMask:addChild(hand)

		if layer then
			layer:addChild(trueMask)
		end
	end
end

function SeasonWeeklyRaceManager:isNeedShowTimeWarnPanel()
	return not self:isTimeWarningDisabled() and self:isTimeNotEnough()
end

-- 时间晚于当日23:30时，首先弹出提示面板
function SeasonWeeklyRaceManager:isTimeNotEnough()
	local currentTime = math.ceil(Localhost:time()/1000)
	local currentDate = os.date("*t", currentTime)
	if currentDate.hour >= 23 and currentDate.min >= 30 then
		return true
	end
	return false
end

function SeasonWeeklyRaceManager:isTimeWarningDisabled()
	return CCUserDefault:sharedUserDefault():getBoolForKey("game.weekly.summer.timewarning")
end

function SeasonWeeklyRaceManager:setTimeWarningDisabled(isEnable)
	if isEnable ~= true then isEnable = false end
	CCUserDefault:sharedUserDefault():setBoolForKey("game.weekly.summer.timewarning", isEnable)
	CCUserDefault:sharedUserDefault():flush()
end

function SeasonWeeklyRaceManager:isFlagSet(key)
	return CCUserDefault:sharedUserDefault():getBoolForKey("2017.weekly.summer." ..tostring(key))
end

function SeasonWeeklyRaceManager:setFlag(key, isEnable)
	if isEnable ~= true then isEnable = false end
	CCUserDefault:sharedUserDefault():setBoolForKey("2017.weekly.summer." ..tostring(key), isEnable)
	CCUserDefault:sharedUserDefault():flush()
end

function SeasonWeeklyRaceManager:setKey(type, key, value, ignoreUid)
    if not ignoreUid then
        key = key .. '.' .. (UserManager:getInstance().user.uid or '12345')
    end
    if type == 'int' then
        CCUserDefault:sharedUserDefault():setIntegerForKey(key, value)
    elseif type == 'bool' then
        CCUserDefault:sharedUserDefault():setBoolForKey(key, value)
    elseif type == 'string' then
        CCUserDefault:sharedUserDefault():setStringForKey(key, value)
    end
end

function SeasonWeeklyRaceManager:getKey(type, key, defaultValue, ignoreUid)
    if not ignoreUid then
        key = key .. '.' .. (UserManager:getInstance().user.uid or '12345')
    end
    if type == 'int' then
        return CCUserDefault:sharedUserDefault():getIntegerForKey(key, defaultValue) or defaultValue
    elseif type == 'bool' then
        return CCUserDefault:sharedUserDefault():getBoolForKey(key, defaultValue) or defaultValue
    elseif type == 'string' then
        return CCUserDefault:sharedUserDefault():getStringForKey(key, defaultValue) or defaultValue
    end
end

function SeasonWeeklyRaceManager:sendPassNotify(friendIds, successCallback, failCallback, cancelCallback)
	local function onSuccess()
		if successCallback then successCallback(false) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	local http = SeasonWeeklyRaceHttpUtil.newPushNotifyHttp(onSuccess, onFail, onCancel)
	local profileName = nameDecode(UserManager.getInstance().profile.name or "")
	http:load(friendIds, Localization:getInstance():getText("weekly.race.summer.rank.share", {name = profileName}),
		LocalNotificationType.kSpringShowOffPassFriend, Localhost:time())
end
function SeasonWeeklyRaceManager:sendPassNationNotify(friendIds, successCallback, failCallback, cancelCallback)
	local function onSuccess()
		if successCallback then successCallback(false) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt) end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	local http = SeasonWeeklyRaceHttpUtil.newPushNotifyHttp(onSuccess, onFail, onCancel)
	local profileName = nameDecode(UserManager.getInstance().profile.name or "")
	http:load(friendIds, Localization:getInstance():getText("show_off_season_weekly_over_nation", {friend = profileName}),
		LocalNotificationType.kWeeklyShowOffPassNation, Localhost:time())
end

function SeasonWeeklyRaceManager:getSpecialPercent()
	local specialPercent = nil
	if self.matchData.dropPropCount >= SeasonWeeklyRaceConfig:getInstance().weeklyDropProp or
	   self.matchData.dailyDropPropCount>= SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount then
		specialPercent = 0
	else
		specialPercent = SeasonWeeklyRaceConfig:getInstance():getSpecialPercent(self.matchData.totalPlayed)
	end
	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~~~getSpecialPercent:", self.matchData.dropPropCount, self.matchData.totalPlayed, specialPercent) end
	return specialPercent
end

function SeasonWeeklyRaceManager:onDropPropInGame()
	if self.matchData then
		self.matchData.dropPropCount = self.matchData.dropPropCount + 1
		self:flushToStorage()
	end
end

function SeasonWeeklyRaceManager:getUpdateTime()
	return (self.matchData or {}).lastPlayedTime
end

function SeasonWeeklyRaceManager:getIsShowHelpRecord()
	return self.matchData:getIsShowHelpTip()
end

function SeasonWeeklyRaceManager:ShowedHelpTip()
	self.matchData:ShowedHelpTip()
end

function SeasonWeeklyRaceManager:getHelpNum()
	return self.matchData:getHelpNum()
end

SeasonWeeklyDecisionType = table.const{
	kCanPlay = "can_play",
	kMainLevelTutorOut = "main_level_tutor_out",
	kMainLevelTutorIn = "main_level_tutor_in",
	kShareTutor = "share_tutor",
	kCanBuy = "can_buy",
	kCanNotPlay = "can_not_play",

	kShowWithFreePanel = "show_with_free_panel",
}

SeasonWeeklyLocalKey = table.const{
	kTodayFirstClick = "today_first_click",
	kTodayFirstLevel = "today_first_level_weekly",
	kTodayFirstShare = "today_first_share_weekly",
}

function SeasonWeeklyRaceManager:pocessSeasonWeeklyDecision(fromMessageCenter , forceOpen)

	if (RankRaceMgr:getInstance():isPreHeat() and RankRaceMgr:getInstance():hadLowLevelTag()) or RankRaceMgr:getInstance():isEnabled() then
		RankRaceMgr:getInstance():openMainPanel()
		return
	end

	local function handleDecisionFunc(seasonWeeklyDecisionType)

		local sunmmFunWillPop = false

		if _G.isLocalDevelopMode then printx(0, "======================================>>>>", seasonWeeklyDecisionType) end
		if seasonWeeklyDecisionType == SeasonWeeklyDecisionType.kMainLevelTutorOut then 
			HomeScene:sharedInstance().worldScene:moveTopLevelNodeToCenter(function ()
				SeasonWeeklyRaceManager:getInstance():showWeeklyTimeTutor()
			end)
		else
			if fromMessageCenter and seasonWeeklyDecisionType == SeasonWeeklyDecisionType.kCanNotPlay then 
				--弹消息中心的tip 今日次数已用完 请明天再来挑战吧
				CommonTip:showTip(Localization:getInstance():getText("今日次数已用完，明日再来挑战吧~"), "positive")
				return
			end

			local homeScene = HomeScene:sharedInstance()
			if homeScene.summerWeeklyButton and not homeScene.summerWeeklyButton.isDisposed then
				homeScene.summerWeeklyButton:update()
			end
			if forceOpen or (not PopoutManager:sharedInstance():haveWindowOnScreen() and not homeScene.ladyBugOnScreen) then
				local panel = SeasonWeeklyBaseMainPanel:create(
					"ui/panel_spring_weekly.json" , 
					"2017SummerWeekly/interface/mainpanel" , 
					"weeklyPanelBg",
					seasonWeeklyDecisionType)
				sunmmFunWillPop = true
				panel:popup()
				--PopoutQueue:sharedInstance():push(panel)
			end
		end

		if sunmmFunWillPop == false then 
			-- PopoutQueue:sharedInstance():popAgain()
		end

	end

	local function onMatchDataLoaded()


		if SeasonWeeklyRaceManager:getInstance():getLeftPlay() > 0 then 
			--有次数剩余
			handleDecisionFunc(SeasonWeeklyDecisionType.kCanPlay)
		else
			local isTodayFirstClick = self:checkKeyDailyRefresh(SeasonWeeklyLocalKey.kTodayFirstClick, self:hasReward())
			if false and isTodayFirstClick and not self:hasReward() then --已废弃
				--当天首次点击
				handleDecisionFunc(SeasonWeeklyDecisionType.kMainLevelTutorOut)
			else
				local currentMainLevelCount = self:getDailyLevelPlayCount()
				local mainLevelCountLimit = SeasonWeeklyRaceConfig:getInstance().dailyMainLevelPlay

				if currentMainLevelCount < mainLevelCountLimit then
					--没获得过主线次数
					local isFirstFreeLevelTutor = self:checkKeyDailyRefresh(SeasonWeeklyLocalKey.kTodayFirstLevel)
					if isFirstFreeLevelTutor then 
						--有引导
						handleDecisionFunc(SeasonWeeklyDecisionType.kMainLevelTutorIn)
					else
						handleDecisionFunc(SeasonWeeklyDecisionType.kShowWithFreePanel)
					end
				else
					local currentShareCount = self:getShareCount()
					local shareCountLimit = SeasonWeeklyRaceConfig:getInstance().dailyShare
					if not shareCountLimit then shareCountLimit = 0 end

					if currentShareCount < shareCountLimit then 
						--没分享过
						local isFirstFreeShareTutor = self:checkKeyDailyRefresh(SeasonWeeklyLocalKey.kTodayFirstShare)
						if isFirstFreeShareTutor then 
							--有引导
							handleDecisionFunc(SeasonWeeklyDecisionType.kShareTutor)
						else
							handleDecisionFunc(SeasonWeeklyDecisionType.kShowWithFreePanel)
						end
					else
						if SeasonWeeklyRaceManager:getInstance():getLeftBuyCount() > 0 then
							handleDecisionFunc(SeasonWeeklyDecisionType.kCanBuy)
						else
							handleDecisionFunc(SeasonWeeklyDecisionType.kCanNotPlay)
						end
					end
				end
			end
		end




	end

	self:loadData(onMatchDataLoaded, true)
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

function SeasonWeeklyRaceManager:checkKeyDailyRefresh(localKey, skipWriteKey)
	local userDefault = CCUserDefault:sharedUserDefault()
	local lastDayStartTime = userDefault:getStringForKey(localKey)
	local todayStartTime = getDayStartTimeByTS(now())

	local function writeTodayStartTime()
		if not skipWriteKey then
			userDefault:setStringForKey(localKey, tostring(todayStartTime))
			userDefault:flush()
		end
	end

	if lastDayStartTime then 
		lastDayStartTime = tonumber(lastDayStartTime)
		if type(lastDayStartTime) == "number" then 
			if todayStartTime > lastDayStartTime then 
				writeTodayStartTime()
				return true
			else
				return false
			end
		else
			writeTodayStartTime()
			return true
		end
	else
		writeTodayStartTime()
		return true
	end
end

function SeasonWeeklyRaceManager:onGameInit()
	-- 初始化单关最高成绩
	self.maxScoreInGame = self.matchData.levelMax or 0
	-- 当关获得的钥匙数目 初始化时清0
	self.gotExtraTargetNum = 0
	self.useExtraTargetNum = 0
	self.extraTargetLottery = nil
	self.lottery = WeekRaceLottery:create()
end

function SeasonWeeklyRaceManager:updateGotExtraTargetNum()
	local targetNum = GameBoardLogic:getCurrentLogic().digJewelCount:getValue()
	local configNum = #self.extraTargetConfig
	if configNum > 0 then 
		for i=1,configNum do
			local config = self.extraTargetConfig[i]
			if config then 
				if targetNum >= config.itemNum then 
					self.gotExtraTargetNum = config.level
				end
			end
		end
	end	
end

function SeasonWeeklyRaceManager:getGotExtraTargetNum()
	return self.gotExtraTargetNum
end

function SeasonWeeklyRaceManager:getUseExtraTargetNum()
	return self.useExtraTargetNum
end

function SeasonWeeklyRaceManager:setUseExtraTargetNum(num)
	if num then 
		self.useExtraTargetNum = self.useExtraTargetNum + num
	end
end

function SeasonWeeklyRaceManager:getLeftExtraTargetNum()
	return self.gotExtraTargetNum - self.useExtraTargetNum
end

function SeasonWeeklyRaceManager:getNewPassedFriendsInGame(curScore)
	local ret = {}
	local rankMinScore = self:getRankMinScore() or 0
	if curScore >= rankMinScore and self.onceRankData and #self.onceRankData.rankList > 0 then
		-- 超越的最高成绩的好友
		self.uid = UserManager.getInstance().uid
		local passedMaxScore = self.maxScoreInGame
		for _, rank in ipairs(self.onceRankData.rankList) do
			if curScore > rank.score and rank.score >= passedMaxScore
					and tostring(rank.uid) ~= tostring(self.uid) then
				if rank.score > passedMaxScore then
					ret = {}
					passedMaxScore = rank.score
				end
				table.insert(ret, tonumber(rank.uid))
			end
		end
	end
	-- 更新单关最高成绩
	if curScore > self.maxScoreInGame then
		self.maxScoreInGame = curScore
	end
	return ret
end

function SeasonWeeklyRaceManager:onReceiveRewardSuccess(rewardId)
	-- the final reward
	if rewardId and rewardId == 6 then
		local medals = self.matchData.medals or 0
		self.matchData.medals = medals + 1
		self:flushToStorage()

		-- AchievementManager:onDataUpdate(AchievementManager.COLLECTED_WEEKLY_MEDAL, 1)
	end
end

-- local PassFriendInfo = {}
-- for i=1,10 do
-- 	local friendInfo = {
-- 		uid = 123,
-- 		headUrl = "",
-- 		name = "abc"..i,
-- 		itemNum = 2+(i-1)*4,
-- 		level = i,
-- 	 -- globalRank = 123 --全国排名 可能为空
-- 	 -- isGlobal = true --来源于全国排行榜
-- 	}
-- 	table.insert(PassFriendInfo, friendInfo)
-- end
-- PassFriendInfo[4].itemNum = 11

function SeasonWeeklyRaceManager:getNextPassFriendInfo(itemNum, level)
	if self.onceRankData then 
		if itemNum and type(itemNum) == "number" then 
			local num = self.maxScoreInGame > itemNum and self.maxScoreInGame or itemNum
			local passInfo = self.onceRankData:getPassFriendInfo()
			-- local num = itemNum	--test
			-- local passInfo = PassFriendInfo --test
			for i,v in ipairs(passInfo) do
				if level then 
					if v.level == level then 
						if v.itemNum > num then 
							return v
						end
					end
				else
					if v.itemNum > num then 
						return v
					end
				end
			end
		end
	end
end

function SeasonWeeklyRaceManager:getNextExtraTargetInfo(itemNum)
	if itemNum and type(itemNum) == "number" then 
		for i,v in ipairs(self.extraTargetConfig) do
			if v.itemNum > itemNum then 
				return v
			end
		end
	end
end

function SeasonWeeklyRaceManager:getReplayPassFriendInfo(itemNum)
	if self.onceRankData then 
		if itemNum and type(itemNum) == "number" then 
			local num = self.maxScoreInGame > itemNum and self.maxScoreInGame or itemNum
			local passInfo = self.onceRankData:getPassFriendInfo()
			local passNum = #passInfo
			local nextFriend = nil
			local nnextFriend = nil
			local nextIndex = nil
			local findNext = false
			if passNum > 0 then 
				for i=1, passNum do
					local friendInfo = passInfo[i]
					if friendInfo.itemNum > num and not findNext then 
						findNext = true
						nextFriend = friendInfo
						nextIndex = i
					elseif findNext then 
						if i > nextIndex and i < nextIndex + 5 then 
							nnextFriend = friendInfo
						else
							break
						end
					end
				end
			end
			return nextFriend, nnextFriend
		end
	end
end

function SeasonWeeklyRaceManager:setQuestionMarkToAddMoveNum(num)
	self.qmToamNum = num
end

function SeasonWeeklyRaceManager:getQuestionMarkToAddMoveNum()
	return self.qmToamNum or 0
end

function SeasonWeeklyRaceManager:dcForEndGameProp(subCategory, levelId, levelType, actSource)
	if not levelType or levelType ~= GameLevelType.kSummerWeekly then return end
	
	local cloudNum = 0
	local gemCloudNum = 0
	local dazhaoRate = nil
	local targetNum = nil

	local mainLogic = GameBoardLogic:getCurrentLogic()
	if not mainLogic then return end
	targetNum = mainLogic:getTargetCount()

    local gameItemMap = mainLogic.gameItemMap
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
        	local item = gameItemMap[r][c]
            if item then
            	if item.ItemType == GameItemType.kDigGround then
               		cloudNum = cloudNum + 1
                end
                if item.ItemType == GameItemType.kDigJewel then
               		gemCloudNum = gemCloudNum + 1
                end
            end
        end
    end

	if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList then 
		local rightPropList = mainLogic.PlayUIDelegate.propList.rightPropList
		if rightPropList then 
			local springItem = rightPropList.springItem
			if springItem then 
				local percentage = springItem.percent or 0
				local intPercent = math.floor(percentage * 10)
				dazhaoRate = intPercent * 10
			end
		end
	end

	local buyState = nil
	if actSource then 
		if __ANDROID then 
			if actSource == EndGameButtonTypeAndroid.kPropEnough then 
				buyState = 1
			elseif actSource == EndGameButtonTypeAndroid.kDiscountWindMill then
				buyState = 2
			elseif actSource == EndGameButtonTypeAndroid.kNormalWindMill then
				buyState = 3
			elseif actSource == EndGameButtonTypeAndroid.kDiscountRmb then
				buyState = 4
			elseif actSource == EndGameButtonTypeAndroid.kNormalRmb then
				buyState = 5
			else
				buyState = 0
			end
		else
			if actSource == EndGameButtonTypeIos.kPropEnough then 
				buyState = 1
			elseif actSource == EndGameButtonTypeIos.kDiscountWindMill then
				buyState = 2
			elseif actSource == EndGameButtonTypeIos.kNormalWindMill then
				buyState = 3
			else
				buyState = 0
			end
		end
	end
	DcUtil:dcForWeekly(subCategory, levelId, cloudNum, gemCloudNum, dazhaoRate, targetNum, buyState)
end