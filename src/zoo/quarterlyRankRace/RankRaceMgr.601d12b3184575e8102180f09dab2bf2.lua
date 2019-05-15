require 'zoo.quarterlyRankRace.RankRaceHttp'


local function getWeekIndex( timeInSec )
	return math.floor((timeInSec - 4 * 24 * 3600 + 8 * 3600) / (7 *24 * 3600)) + 1
end

local function getWeekStartTS( weekIndex )
	return (weekIndex - 1) * (7 *24 * 3600) - 8 * 3600 + 4 * 24 * 3600
end


RankRaceMgr = class()

RankRaceOBKey = table.const{
	kPassDay = 	"kPassDay", 
	kRewardInfoChange = 'kRewardInfoChange',
	kTargetCountChange0 = 'kTargetCountChange0',
	kTargetCountChange1 = 'kTargetCountChange1',  
	kUnlock = 'kUnlock',
	kOpenMainPanel = 'kOpenMainPanel',
	kGiftInfo = 'kGiftInfo',
	kRefreshCanLotteryShow = 'kRefreshCanLotteryShow', 
}

local RankType = {
	kGroup = 1,
	kFriend = 2,
}

local RankRequestCD = {
	kGroup = 1,
	kFriend = 1, 
}

local WeekBoxesNum = 7 		--宝石领奖里上面那一排的宝箱数量

local function parseTime( str,default )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str,pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

--这个时间所在的那一周，是新周赛开始的第一周，上现前写死
local MAIN_BEGIN_TIME = os.time2(parseTime'2018-06-11 00:00:00')
local MAIN_BEGIN_WEEK = getWeekIndex(MAIN_BEGIN_TIME) 
local LEVEL_CHANGE_WEEK = 2536

local RaceSeasonConfig = {
	{beginWeekIndex = MAIN_BEGIN_WEEK, seasonIndex = 1},
	{beginWeekIndex = getWeekIndex(os.time2(parseTime'2018-09-03 00:00:00')), seasonIndex = 2, startTime = os.time2(parseTime'2018-09-03 10:00:00'), endTimeStr = '12月2日24时'},
	{beginWeekIndex = getWeekIndex(os.time2(parseTime'2018-12-03 00:00:00')), seasonIndex = 3, startTime = os.time2(parseTime'2018-12-03 10:00:00'), endTimeStr = '3月3日24时'},
	{beginWeekIndex = getWeekIndex(os.time2(parseTime'2019-03-04 00:00:00')), seasonIndex = 4, startTime = os.time2(parseTime'2019-03-04 10:00:00'), endTimeStr = '6月2日24时'},
}


local instance = nil
function RankRaceMgr.getInstance()
	if not instance then
        instance = RankRaceMgr.new()
    end
    return instance
end

function RankRaceMgr.getExistedInstance( ... )
	return instance
end

function RankRaceMgr:ctor()
	self.rankListFriend = nil
	self.rankListGroup = nil
	self.rankIndexFriend = nil
	self.rankIndexGroup = nil
	self.rankCDFriend = nil
	self.rankCDGroup = nil
	self.rankUserInfo = nil
	self.rankCardGroup = nil
	self.rankCardFriend = nil

	self.observers = {}
	self.data = require('zoo.quarterlyRankRace.RankRaceData').new()
	self.data:read()
	self:checkAutoUnlock()
	self.meta = require('zoo.quarterlyRankRace.RankRaceMeta').new(self.data)

    self.ShowGetGoldTip = false
    self.ShowGetGoldNum = 0
    self.LaseWeekAfterDan = 1
    self.LaseWeekBeforeDan = 1

    local newestSeasonConfig = RaceSeasonConfig[#RaceSeasonConfig]
    self.newestSaijiStartTime = newestSeasonConfig.startTime
    self.newestSeasonIndex = newestSeasonConfig.seasonIndex

	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, function (evt) 

		local passWeek = false 
		if self.data:checkOverWeek(true) then
			passWeek = true
			--确实跨周
			--至于清不清数据 有待考虑
		end
		self:onPassDay(passWeek)


		HomeScene:sharedInstance():tryRemoveSummerWeeklyButton()
	end)
end	

function RankRaceMgr:writeLowLevelTag( ... )
    local uid = UserManager.getInstance().user.uid
    local key = 'RankRaceMgr:writeLevelTag.' .. uid
    local toplevel = UserManager.getInstance().user:getTopLevelId()
    if toplevel <= 30 then
		CCUserDefault:sharedUserDefault():setBoolForKey(key, true)	
	end
end

function RankRaceMgr:hadLowLevelTag( ... )
	local uid = UserManager.getInstance().user.uid
    local key = 'RankRaceMgr:writeLevelTag.' .. uid
	return CCUserDefault:sharedUserDefault():getBoolForKey(key, false)
end

function RankRaceMgr:addObserver(observer)
	table.insert(self.observers, observer)
end

function RankRaceMgr:removeObserver(observer)
	table.removeValue(self.observers, observer)
end

function RankRaceMgr:notify(obKey, ... )
	for _, observer in ipairs(self.observers) do
		if type(observer) =='table' then
			if type(observer.onNotify) == 'function' then
				observer:onNotify(obKey, ...)
			end
		end
	end
end

function RankRaceMgr:getMeta( ... )
	return self.meta
end

function RankRaceMgr:resetTempData()
	self.rankListFriend = nil
	self.rankListGroup = nil
	self.rankIndexFriend = nil
	self.rankIndexGroup = nil
	self.rankCDFriend = nil
	self.rankCDGroup = nil
	self.rankUserInfo = nil
	self.rankCardGroup = nil
	self.rankCardFriend = nil
end

function RankRaceMgr:setRequestRankCD(rankType)
	if rankType == RankType.kFriend then 
		self.rankCDFriend = os.time()
	elseif rankType == RankType.kGroup then 
		self.rankCDGroup = os.time()
	end
end

function RankRaceMgr:isRequestRankCD(rankType)
	if rankType == RankType.kFriend then 
		if self.rankCDFriend and (os.time() - self.rankCDFriend <= RankRequestCD.kFriend) then
			return true
		end
	elseif rankType == RankType.kGroup then 
		if self.rankCDGroup and (os.time() - self.rankCDGroup <= RankRequestCD.kGroup) then
			return true
		end
	end
	return false 
end

function RankRaceMgr:requestRankList(subRankType, startIndex, endIndex, successCallback, failCallback, cancelCallback)
	local http = GetCommonRankListHttp.new(true)
	local function onSuccess(evt)
		self:setRequestRankCD(subRankType)
		local data = evt and evt.data or {}
		if successCallback then successCallback(data) end
	end

	local function onFail(evt)
		local errcode = evt and evt.data or nil
		if failCallback then failCallback(errcode) end
	end

	local function onCancel(evt)
		if cancelCallback then cancelCallback() end
	end

	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onCancel)

	http:syncLoad(36, subRankType, 0, startIndex, endIndex)
end

function RankRaceMgr:getRankListFriend(considerCD, successCallback, failCallback, cancelCallback)
	local function updateServer()
		local function onSuccess(rankData) 
			self:onGetRankListFriendSuccess(rankData, successCallback) 
		end
		local function onFail(errorCode) 
			if failCallback then failCallback(errorCode) end 
		end
		local function onCancel() 
			if cancelCallback then cancelCallback() end 
		end
		self:requestRankList(RankType.kFriend, 0, 0, onSuccess, onFail, onCancel)
	end

	local function updateLocal()
		self:onGetRankListFriendSuccess({rankList = self.rankListFriend}, successCallback)
	end

	if self.rankListFriend == nil then 
		updateServer()
	elseif considerCD then 
		if self:isRequestRankCD(RankType.kFriend) then 
			if failCallback then failCallback(-1012) end
		else
			updateServer()
		end
	else
		updateLocal()
	end
end

function RankRaceMgr:onGetRankListFriendSuccess(rankData, successCallback)
	local rankList = rankData and rankData.rankList or {}
	local friendsIds = {}

	local userSelfData
	for i,v in ipairs(rankList) do
		if  tostring(v.uid) == tostring(UserManager.getInstance().uid) then 
			userSelfData = v
		else
			v.extra = tonumber(v.extra) or 1
		end
	end
	
	local targetCount = self.data:getTC0()

	if userSelfData == nil then
		table.insert(rankList, {
			uid = UserManager.getInstance().uid, 
			score = targetCount, 
			rank = 0,
			extra = RankRaceMgr.getInstance():getData():getSafeDan()}
		)
	else
		userSelfData.score = targetCount
		userSelfData.extra = RankRaceMgr.getInstance():getData():getSafeDan()
	end
	self.rankListFriend = self:sortRankList(rankList, friendsIds)

	if self.rankListFriend ~= nil then
		for i=1, #self.rankListFriend do
			local friendRankData = self.rankListFriend[i]
			if friendRankData ~= nil and friendRankData.uid ~= nil then
				friendRankData.name = FriendManager.getInstance():getFriendName(friendRankData.uid)
				friendRankData.headUrl = FriendManager.getInstance():getFriendHeadUrl(friendRankData.uid)
			end
		end
	end
	
	local myRank = 0
	-- if targetCount > 0 then
		myRank = table.indexOf(self.rankListFriend, table.find(self.rankListFriend, function(_rankData)
			return tostring(_rankData.uid) == tostring(UserManager.getInstance().uid)
		end))
	-- end
	self.rankIndexFriend = myRank or 0

	if successCallback then successCallback(self.rankListFriend, self.rankIndexFriend) end
end

function RankRaceMgr:getRankListGroup(considerCD, successCallback, failCallback, cancelCallback)
	local function updateServer()
		local function onSuccess(rankData) 
			self:onGetRankListGroupSuccess(rankData, successCallback)
		end
		local function onFail(errorCode) 
			if failCallback then failCallback(errorCode) end 
		end
		local function onCancel() 
			if cancelCallback then cancelCallback() end 
		end
		self:requestRankList(RankType.kGroup, 1, 100, onSuccess, onFail, onCancel)
	end

	local function updateLocal()
		self:onGetRankListGroupSuccess({rankList = self.rankListGroup,
										profiles = self.rankListGroup}, successCallback)
	end

	if self.rankListGroup == nil then 
		updateServer()
	elseif considerCD then 
		if self:isRequestRankCD(RankType.kGroup) then 
			if failCallback then failCallback(-1012) end
		else
			updateServer()
		end
	else
		updateLocal()
	end
end

function RankRaceMgr:onGetRankListGroupSuccess(rankData, successCallback)
	local targetCount = self.data:getTC0()
	local rankList = rankData and rankData.rankList or {}
	local profiles = rankData and rankData.profiles or {}

	local function finish(idx, rankList)
		self.rankIndexGroup = idx
		self.rankListGroup = rankList
		for i,v in ipairs(self.rankListGroup) do
			if not v.name or not v.headUrl then 
				local profile = table.find(profiles, function(pf)
					return tostring(pf.uid) == tostring(v.uid)
				end) or {}
				v.name = profile.name
				v.headUrl = profile.headUrl
				v.headFrame = profile.headFrame
			end
		end
		if successCallback then successCallback(self.rankListGroup, self.rankIndexGroup) end
	end

	local oldIndex = table.indexOf(rankList, table.find(rankList, function(_rankData)
			return tostring(_rankData.uid) == tostring(UserManager.getInstance().uid)
		end)) or 0
	if oldIndex > 0 then 
		local data = rankList[oldIndex]
		if data and data.score and data.score ~= targetCount then 
			table.remove(rankList, oldIndex)
		else
			finish(oldIndex, rankList)
			return 
		end
	end

	local newIndex = -1
	for i,v in ipairs(rankList) do
		if v.score < targetCount then 
			newIndex = i
			break;
		end
	end
	local userSelfData = {
		uid = UserManager.getInstance().uid, 
		score = targetCount, 
		rank = 0
	}
	if newIndex > 0 then 
		table.insert(rankList, newIndex, userSelfData)
	else
		table.insert(rankList, userSelfData)
		newIndex = #rankList
	end
	finish(newIndex, rankList)
end

--根据传入收集物的数量获取排名和晋升信息
function RankRaceMgr:getFakeGroupRankIndex(targetCount)
	if self.rankListGroup then 
		local oldIndex = -1
		local oldRenderState = 3 
		if self.rankIndexGroup then 
			oldIndex = self.rankIndexGroup
			oldRenderState = self:getRankRenderState(RankType.kGroup, self.rankIndexGroup) 
		end
		local rankList = table.clone(self.rankListGroup)

		local oldIndex = table.indexOf(rankList, table.find(rankList, function(_rankData)
				return tostring(_rankData.uid) == tostring(UserManager.getInstance().uid)
			end)) or 0
		if oldIndex > 0 then 
			local data = rankList[oldIndex]
			if data and data.score then 
				table.remove(rankList, oldIndex)
			end
		end

		local newIndex = -1
		for i,v in ipairs(rankList) do
			if v.score < targetCount then 
				newIndex = i
				break
			end
		end
		if newIndex <= 0 then 
			newIndex = #rankList + 1
		end

		return self:getRankRenderState(RankType.kGroup, newIndex), oldRenderState, newIndex, oldIndex, rankList[newIndex]
	end

	return 3
end

function RankRaceMgr:sortRankList(rankList, friendUids)
	rankList = rankList or {}

	if type(friendUids) == "table" and #friendUids > 0 then
		for _,friendID in pairs(friendUids) do
			local friendRankData = table.find(rankList, function(rank)
				return tostring(rank.uid) == tostring(friendID)
			end)
			if friendRankData == nil then table.insert(rankList, {uid=tostring(friendID), score=0, rank=0}) end
		end
	end

	local myUid = tostring(UserManager.getInstance().uid)
	table.sort(rankList, function(a, b)
							if a.extra == b.extra then 
							 	 if a.score == b.score then
							 	 	if tostring(a.uid) == tostring(b.uid) then
							 	 		return false
							 	 	end
							 	 	if tostring(a.uid) == myUid then
							 	 		return true
							 	 	end
							 	 	if tostring(b.uid) == myUid then
							 	 		return false
							 	 	end

							 	 	return tonumber(a.uid) < tonumber(b.uid)
							 	 else
							 	 	return a.score > b.score
							 	 end
						 	else
						 		return a.extra > b.extra
						 	end
						 end)
	return rankList
end

--1 晋2级    2 晋1级    3 不晋级或者无数据    4 10段无晋级
function RankRaceMgr:getRankRenderState(subRankType, rankIdx)
	if subRankType and subRankType == RankType.kGroup then 
		local promotionCfg = self:getMeta():getPromotionRate()
		local dan = self.data:getSafeDan()
		if dan < 10 then 
			local pro2Num, pro1Num = self:getProNum()
			if pro2Num and pro1Num then 
				if rankIdx > 0 and rankIdx <= pro2Num then
					if dan == 9 then 
						return 2
					else
						return 1
					end
				elseif rankIdx > pro2Num and rankIdx <= pro1Num then
					return 2
				else
					return 3
				end
			else
				return 3
			end
		else
			return 4
		end
	else
		return 3
	end
end

function RankRaceMgr:getProNum()
	local pro1Num
	local pro2Num 
	local promotionCfg = self:getMeta():getPromotionRate()
	local dan = self.data:getSafeDan()
	if dan < 10 then 
		pro2Num = promotionCfg[dan][1]
		local rate = promotionCfg[dan][2]
		rate = tonumber(string.sub(rate, 1, string.len(rate) - 1))
		if rate and self.rankListGroup then 
			local listNum = #self.rankListGroup
			pro1Num = math.ceil2(listNum * rate / 100)
		end
	end

	local hasScoreNum = 0
	if self.rankListGroup then 
		for i,v in ipairs(self.rankListGroup) do
			if v.score > 0 then 
				hasScoreNum = hasScoreNum + 1
			end
		end
	end

	if pro2Num and pro2Num > 0 then 
		pro2Num = math.min(pro2Num, hasScoreNum)
	end
	if pro1Num and pro1Num > 0 then 
		pro1Num = math.min(pro1Num, hasScoreNum)
	end

	return pro2Num, pro1Num
end

function RankRaceMgr:getShareExtraNum()
	return 10
end

RankRaceMgr.LevelNodeState = {
	kLock = 0,
	kOpen = 1,	
}

function RankRaceMgr:getLevelNodeSate(levelNodeId)
	if levelNodeId <= self:getData().unlockIndex then 
		return RankRaceMgr.LevelNodeState.kOpen
	else
		return RankRaceMgr.LevelNodeState.kLock
	end
end

function RankRaceMgr:getPromotionReward(promotionRange)
	local function insertReward(rewards, reward)
		local find = false 
		for i,v in ipairs(rewards) do
			if v.itemId == reward.itemId then 
				find = true
				v.num = v.num + reward.num
			end
		end
		if not find then 
			table.insert(rewards, reward)
		end
	end

	local rewardsConfig = {}
	local dan = self.data:getSafeDan()
	if dan and dan < 10 then 
		local danRewards = self.meta:getDanRewardConfig()
		for i=1, promotionRange do
			local danReward = danRewards[dan + i - 1]
			for i,v in ipairs(danReward) do
				insertReward(rewardsConfig, v)
			end
		end
	end

	return rewardsConfig
end

function RankRaceMgr:isNeedShowTimeWarnPanel()
	return self:isTimeNotEnough()
end

local hasReminded = false
function RankRaceMgr:isTimeNotEnough()
	local now = Localhost:timeInSec()
	local weekIndex = getWeekIndex(now)
	local nextWeekStartTS = getWeekStartTS(weekIndex + 1)
	local deltaInSec = nextWeekStartTS - now
	if not hasReminded and deltaInSec > 0 and deltaInSec <= 30 * 60 then 
		hasReminded = true
		return true
	end
	return false
end

function RankRaceMgr:getCurWeekStartTS()
	local now = Localhost:timeInSec()
	local weekIndex = getWeekIndex(now)
	return getWeekStartTS(weekIndex)
end

function RankRaceMgr:getNextWeekStartTS()
	local now = Localhost:timeInSec()
	local weekIndex = getWeekIndex(now)
	return getWeekStartTS(weekIndex+1)
end

function RankRaceMgr:getDanGroup()
	local dan = self.data:getSafeDan()
	local danGroup = 0
	if dan then 
		if dan <= 3 then 
			danGroup = 1
		elseif dan <= 6 then 
			danGroup = 2
		elseif dan <= 9 then 
			danGroup = 3
		elseif dan == 10 then 
			danGroup = 4
		end
	end
	return danGroup
end

function RankRaceMgr:getRankTatalNum(subRankType)
	local totalNum = 0
	if subRankType == RankType.kGroup and self.rankListGroup then
		totalNum = #self.rankListGroup
	elseif subRankType == RankType.kFriend and self.rankListFriend then 
		totalNum = #self.rankListFriend
	end

	return totalNum
end

function RankRaceMgr:addRankUserInfo(uid, info)
	if not self.rankUserInfo then self.rankUserInfo = {} end
	self.rankUserInfo[uid] = info
end

function RankRaceMgr:getRankUserInfo(uid)
	if self.rankUserInfo then 
		return self.rankUserInfo[uid]
	end
end

function RankRaceMgr:queryRankUserInfo(uid, onSuccess, onFail, onCancel)
	local function _onSuccess(evt)
		local data = evt.data
		local userInfo = data and data.user or {}
		local info = {}
		info.topLevelId = userInfo.topLevelId or 0
		info.star = userInfo.star or 0
		info.achiScore = data and data.achievementPoint or 0
		self:addRankUserInfo(uid, info)
		if onSuccess then onSuccess() end
	end
	RankRaceHttp:getUserInfo(uid, _onSuccess, onFail, onCancel)
end

function RankRaceMgr:addRankCardInfo(_type, uid, info)
	if _type == RankType.kGroup then 
		if not self.rankCardGroup then self.rankCardGroup = {} end
		self.rankCardGroup[uid] = info
	elseif _type == RankType.kFriend then
		if not self.rankCardFriend then self.rankCardFriend = {} end
		self.rankCardFriend[uid] = info
	end
end

function RankRaceMgr:getRankCardInfo(_type, uid)
	if _type == RankType.kGroup then 
		if self.rankCardGroup then 
			return self.rankCardGroup[uid]
		end
	elseif _type == RankType.kFriend then
		if self.rankCardFriend then 
			return self.rankCardFriend[uid]
		end
	end
end

function RankRaceMgr:onThumbSuccess(_type, uid, num)
	if _type == RankType.kGroup then 
		if self.rankCardGroup and self.rankCardGroup[uid] then 
			self.rankCardGroup[uid].thumbsUpCount = num
			self.rankCardGroup[uid].canThumbsUp = false
		end
	elseif _type == RankType.kFriend then
		if self.rankCardFriend and self.rankCardFriend[uid] then 
			self.rankCardFriend[uid].thumbsUpCount = num
			self.rankCardFriend[uid].canThumbsUp = false
		end
	end
end

function RankRaceMgr:queryRankCardInfo(_type, uid, onSuccess, onFail, onCancel)
	local function _onSuccess(evt)
		local data = evt.data
		if data and data.profile then 
			local cardInfo = {}
			cardInfo.uid = uid
			cardInfo.rankType = _type

			if tostring(uid) == tostring(UserManager.getInstance().uid) then 
		    	cardInfo.profile = UserManager:getInstance().profile
		    	cardInfo.isSelf = true
		    else
		    	cardInfo.profile = data.profile
		    	cardInfo.isSelf = false
		    end
		    
		    cardInfo.level = data.level or 0
		    cardInfo.star = data.star or 0
		    cardInfo.weekHighest = data.weekHighest or 0
		    cardInfo.singleHighest = data.singleHighest or 0
		    cardInfo.danHighest = data.danHighest or 1
		    cardInfo.canThumbsUp = data.canThumbsUp
		    cardInfo.thumbsUpCount = tonumber(data.thumbsUpCount) or 0
		    cardInfo.rank = data.rank or 100
		    cardInfo.rankGroup = data.rankGroup or 100

			self:addRankCardInfo(_type, uid, cardInfo)
			if onSuccess then onSuccess() end
		else
			if onFail then onFail() end
		end
	end
	RankRaceHttp:getCardInfo(uid, _onSuccess, onFail, onCancel)
end
---------------------------------------------------------------
-- ######                       ######                       --
-- #     #   ##   #    # #    # #     #   ##    ####  ###### -- 
-- #     #  #  #  ##   # #   #  #     #  #  #  #    # #      --
-- ######  #    # # #  # ####   ######  #    # #      #####  --
-- #   #   ###### #  # # #  #   #   #   ###### #      #      --
-- #    #  #    # #   ## #   #  #    #  #    # #    # #      --
-- #     # #    # #    # #    # #     # #    #  ####  ###### --
---------------------------------------------------------------
function RankRaceMgr:addRewards(rewardItems, source)
	for _,reward in pairs(rewardItems or {}) do
		if reward.itemId == ItemType.RACE_TARGET_0 then
			self:incTC0(reward.num)
		elseif reward.itemId == ItemType.RACE_TARGET_1 then
			self:incTC1(reward.num, true)
		elseif ItemType:isHeadFrame(reward.itemId) then
			local delta
			if reward.num == 0 then
				delta = nil --永久
			else
				delta = reward.num * 60 * 1000 * 24 * 60 --num是个天数 
			end
			HeadFrameType:setProfileContext(nil):addHeadFrame(ItemType:convertToHeadFrameId(reward.itemId), delta)
		else
			UserManager:getInstance():addReward(reward, true)
			UserService:getInstance():addReward(reward)
		    GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kRankRace, reward.itemId, reward.num, source)
		end
	end
	Localhost:getInstance():flushCurrentUserData()
end

function RankRaceMgr:receiveLastWeekRewards(onSuccess, onFail, onCancel )

	local function __success( evt )
		self.data:clearLastWeekBoxes()
		self.data:clearLastWeekLotteryRewards()

		local rewards = evt.data.rewards or {}
		self:addRewards(rewards, DcSourceType.kRankRaceLastWeek)
		if onSuccess then
			onSuccess(rewards)
		end
		self:notify(RankRaceOBKey.kRewardInfoChange)
	end


	RankRaceHttp:getLastWeekReward(__success, onFail, onCancel)
end



function RankRaceMgr:receiveLotteryRewards( onSuccess, onFail, onCancel )

	local function __success( evt )

		local rewards = evt.data.rewards or {}

		self:addRewards(rewards, DcSourceType.kRankRaceLottery)

		local rewardItem = rewards[1]
		if rewardItem then
			self.data:insertLotteryLog(rewardItem.itemId, rewardItem.num)
		end

		self:incTC1(-self.meta:getLotteryCost())

		if onSuccess then
			onSuccess(rewards)
		end

		self:notify(RankRaceOBKey.kRewardInfoChange)

		if rewardItem then

			DcUtil:UserTrack({
		        category='weeklyrace2018', 
		        sub_category='weeklyrace2018_click_turntable',
		        t1 = rewardItem.itemId,
		        t2 = rewardItem.num
		    })
		end
	end


	RankRaceHttp:getLotteryReward(__success, onFail, onCancel)
end


function RankRaceMgr:receiveBoxRewards( boxIndex, onSuccess, onFail, onCancel )

	local function __success( evt )

		self.data:insertRewardedBoxes(boxIndex)

		local rewards = evt.data.rewards or {}

		self:addRewards(rewards, DcSourceType.kRankRaceBox)

		if onSuccess then
			onSuccess(rewards)
		end

		self:notify(RankRaceOBKey.kRewardInfoChange)
	end


	RankRaceHttp:getBoxReward(boxIndex, __success, onFail, onCancel)
end

RankRaceMgr.BoxState = {
	kUnavaliable = 1,
	kAvaliable = 2,
	kRewarded = 3,
}

function RankRaceMgr:getBoxRewardState(boxIndex)
	local rewardedBoxes = self.data:getRewardedBoxes()
	if table.exist(rewardedBoxes, boxIndex) then
		return RankRaceMgr.BoxState.kRewarded
	end
	local curTarget = self.data:getTC0()
	local thisBoxConfig = self.meta:getBoxRewardConfig()[boxIndex]
	if thisBoxConfig then
		if curTarget >= tonumber(thisBoxConfig.conditions) then
			return RankRaceMgr.BoxState.kAvaliable
		end
	end
	return RankRaceMgr.BoxState.kUnavaliable
end

function RankRaceMgr:getBoxesRespectiveInfos( ... )
	local infos = {}
	local targetCount = self.data:getTC0()

	for i, v in ipairs(self.meta:getBoxRewardConfig()) do
		local curNum = math.min(targetCount, tonumber(v.conditions))
		local requiredNum = tonumber(v.conditions)
		table.insert(infos, {curNum, requiredNum})
	end

	return infos
end

function RankRaceMgr:getFirstUnavaliableBoxIndex( ... )
	local targetCount = self.data:getTC0()

	for i, v in ipairs(self.meta:getBoxRewardConfig()) do
		local requiredNum = tonumber(v.conditions)
		if targetCount < requiredNum then
			return i
		end
	end
end

function RankRaceMgr:canDrawLottery( ... )
	local cost = self.meta:getLotteryCost()
	local money = self.data:getTC1()
	return money >= cost
end

function RankRaceMgr:getData( ... )
	return self.data
end

function RankRaceMgr:incTC0( delta )
	self.data:setTC0(self.data:getTC0() + delta)
	self.data:setTodayTC0(self.data:getTodayTC0() + delta)
	self:notify(RankRaceOBKey.kTargetCountChange0)

    DcUtil:UserTrack({
        category='weeklyrace2018', 
        sub_category='weeklyrace2018_satisfy_reward',
        t1 = table.reduce(table.filter({1,2,3,4,5,6}, function ( boxIndex )
            return self:getBoxRewardState(boxIndex) == RankRaceMgr.BoxState.kAvaliable
        end), math.max)
    })

end

function RankRaceMgr:incTC1(delta, fromRewards)
	self.data:setTC1(self.data:getTC1() + delta)
	self:notify(RankRaceOBKey.kTargetCountChange1, fromRewards)


	if self:canDrawLottery() then
		DcUtil:UserTrack({
	        category='weeklyrace2018', 
	        sub_category='weeklyrace2018_satisfy_turntable',
	    })
	end
end

function RankRaceMgr:onPassDay(passWeek)
	self.data:onPassDay()
	self:notify(RankRaceOBKey.kPassDay, passWeek)
	if not passWeek then 
		self:checkAutoUnlock()
	end


	local btn = HomeScene.sharedInstance().rankRaceButton
    if btn then
        btn:update()
    end
end

function RankRaceMgr:checkAutoUnlock( ... )
	if self.data:canAutoUnlock() then
		RankRaceHttp:unlock(function ( ... )
			self.data:autoUnlock()
			self:notify(RankRaceOBKey.kUnlock, 2)
		end)
	end
end

function RankRaceMgr:getDanHistory( ... )
	-- body
end


function RankRaceMgr:canRecvMoreGifts( ... )
	return self.data:getReceiveGiftCount() < self.meta:getReceiveGiftLimit()
end



function RankRaceMgr:receiveInGameGift( friUids, onSuccess, onFail, onCancel, friendNum )

	if not self:canRecvMoreGifts() then
		if onFail then
			onFail({data = 731812})
		end
		return
	end

    local num = friendNum or 5

	RankRaceHttp:recvGift(friUids, function ( ... )

		self:incTC1(#friUids * num)
		self.data:addReceiveGiftCount(1)

		self:notify(RankRaceOBKey.kGiftInfo)

		if onSuccess then
			onSuccess(...)
		end

	end, onFail, onCancel)

end

function RankRaceMgr:sendInGameGift( friUids, onSuccess, onFail, onCancel )
	RankRaceHttp:sendGift( friUids, function ( ... )
		self.data:extendSendedUids(friUids)
		if onSuccess then
			onSuccess(...)
		end
	end, onFail, onCancel )
end

function RankRaceMgr:isEnabled( ... )

	if PrepackageUtil:isPreNoNetWork() then
		return false
	end

	if not self:isLevelReached() then
		return false
	end

	if getWeekIndex(Localhost:timeInSec()) < MAIN_BEGIN_WEEK then
		return false
	end

	return true
end

function RankRaceMgr:isPreHeat( ... )

	if PrepackageUtil:isPreNoNetWork() then
		return false
	end
	
	if not self:isLevelReached() then
		return false
	end

	if getWeekIndex(Localhost:timeInSec()) >= MAIN_BEGIN_WEEK then
		return false
	end

	return true
end

function RankRaceMgr:isLevelReached( ... )
	local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0
	if topLevelId <= 30 then
		return false
	end
	return true
end

function RankRaceMgr:getPreheatCountdownStr()
	local now = Localhost:timeInSec()
	local deltaInSec = MAIN_BEGIN_TIME - now

	local d = math.floor(deltaInSec / (3600 * 24))
	local h = math.floor(deltaInSec % (3600 * 24) / 3600)
	local m = math.floor(deltaInSec % (3600 * 24) % 3600 / 60)
	local s = math.floor(deltaInSec % (3600 * 24) % 3600 % 60)
	local isOver = deltaInSec <= 0 

	h = d * 24 + h
	if h < 10 then h = "0"..h end
	if m < 10 then m = "0"..m end
	if s < 10 then s = "0"..s end
	local time = string.format("%s:%s:%s", h, m, s)
	return time, isOver
end

function RankRaceMgr:hasAvailableGifts( ... )
	if not self:canRecvMoreGifts() then
		return false
	end
	return self.data:getHasGifts()
end

function RankRaceMgr:setHasGifts( v )
	self.data:setHasGifts(v)
	self:notify(RankRaceOBKey.kGiftInfo)
end

function RankRaceMgr:hasAvailableRewards( ... )
	local ret = self:hasAvailableBoxRewards() or self:canDrawLottery()


	return ret
end

function RankRaceMgr:hasAvailableBoxRewards( ... )
	local ret = false
	for i = 1, WeekBoxesNum do
		ret = ret or (self:getBoxRewardState(i) == RankRaceMgr.BoxState.kAvaliable)
	end
	return ret
end

-------根据当前拥有数量 与传入的预增加数量判断能否领宝箱  add by zhigang.niu
function RankRaceMgr:HasBoxCanRewards( addnum )
	local ret = false
    local boxIndex = 0

	for i = 1, WeekBoxesNum do
        if self:getBoxRewardStateByAddNum(i,addnum) == RankRaceMgr.BoxState.kAvaliable then
		    ret = true
            boxIndex = i
        end
	end

	return ret, boxIndex
end

function RankRaceMgr:getBoxRewardStateByAddNum( boxIndex, addnum )
    
    local rewardedBoxes = self.data:getRewardedBoxes()
	if table.exist(rewardedBoxes, boxIndex) then
		return RankRaceMgr.BoxState.kRewarded
	end

	local curTarget = self.data:getTC0() + addnum
	local thisBoxConfig = self.meta:getBoxRewardConfig()[boxIndex]
	if thisBoxConfig then
		if curTarget >= tonumber(thisBoxConfig.conditions) then
			return RankRaceMgr.BoxState.kAvaliable
		end
	end
	return RankRaceMgr.BoxState.kUnavaliable
end
--------

function RankRaceMgr:handleShareData( shareKey, close_cb )
	self:receiveLinkReward(shareKey, function ( rewards )
		self:popoutLinkRawardPanel(rewards, close_cb)
	end, function ( evt )
		local errCode = evt.data
		if errCode then
			AutoPopout:showNotifyPanel(localize('error.tip.' .. errCode), close_cb)
		else
			if close_cb then close_cb() end
		end
	end)
end

function RankRaceMgr:popoutLinkRawardPanel( rewards, close_cb )
	local RankRaceSingleRewardPanel = require 'zoo.quarterlyRankRace.view.RankRaceSingleRewardPanel'
	RankRaceSingleRewardPanel:create(rewards, close_cb):popout()
end


function RankRaceMgr:tryShowGetGoldTip( )
    if self.ShowGetGoldTip then
        self.ShowGetGoldTip = false

        local text = "成功过关，获得黄金地鼠"..self.ShowGetGoldNum.."个！"
        CommonTipWithBtn:showTip({tip = text, yes = "知道了"}, "positive", nil, nil, nil, true)
--        CommonTip:showTip("成功过关，获得黄金地鼠"..self.ShowGetGoldNum.."个！")
        self.ShowGetGoldNum = 0
    end
end

function RankRaceMgr:tryPopoutLastWeekRewardsPanel( done )
	local lastWeekLotteryRewards = self.data:getLastWeekLotteryRewards()
    local lastWeekBoxes = self.data:getLastWeekBoxes()

    if #lastWeekBoxes + #lastWeekLotteryRewards > 0 then
    	local RankRaceLastWeekRewardPanel = require 'zoo.quarterlyRankRace.view.RankRaceLastWeekRewardPanel'
		local panel = RankRaceLastWeekRewardPanel:create()
		panel:popout()
		panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
			if done then done() end
		end)
    else
    	if done then done() end
    end
end

function RankRaceMgr:tryPopoutDanSharePanel( done )

	local rewardedDan = self.data:getRewardedDan()
	local curDan = self.data:getSafeDan()

    local bCanReward, saijiIndex = self:hasDanRewards()
	if bCanReward then

        local ReciveDanRewardFunc
        local curSaiJi = self:getCurSaijiIndex()
        if curSaiJi == 1 then
            ReciveDanRewardFunc = self.receiveDanRewards
        else
            ReciveDanRewardFunc = self.receiveDanRewards2
        end

		ReciveDanRewardFunc( self, tonumber(saijiIndex), function ( rewards )
			self.data:setIsShowSkillGuide( true )
    		local RankRaceDanSharePanel = require 'zoo.quarterlyRankRace.view.RankRaceDanSharePanel'
    		local panel = RankRaceDanSharePanel:create(rewards or {}, {rewardedDan, curDan})
    		panel:popout()
    		panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
				if done then done() end
			end)


			DcUtil:UserTrack({
		        category='weeklyrace2018', 
		        sub_category='weeklyrace2018_rank_advance',
		        t1 = curDan,
		    })

		end, done, done)
	else
    	if done then done() end
	end
end

function RankRaceMgr:tryPopoutSkillDescPanel( done )
    if done then done() end
end

function RankRaceMgr:tryPopoutHeadFramePanel( done )

    local kingHeadFrame  = self:getData().kingHeadFrame 
    if kingHeadFrame then
        -- body
	    local panel = require('zoo.quarterlyRankRace.view.RankRaceHeadFrameGetPanel'):create()
	    panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
		    if done then done() end
	    end)
	    panel:popout()

        self:getData().kingHeadFrame = true
    else
    	if done then done() end
    end

end

function RankRaceMgr:tryPopoutOldRewardsPanel( done )
	if self.data:hasOldRewards() then
		self:receiveOldReward(function ( rewards )
			if #rewards <= 0 then
    			if done then done() end
    			return
    		end
    		local RankRaceOldRewardsPanel = require 'zoo.quarterlyRankRace.view.RankRaceOldRewardsPanel'
    		local panel = RankRaceOldRewardsPanel:create(rewards or {})
    		panel:popout()
    		panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
				if done then done() end
			end)

		end, done, done)
	else
    	if done then done() end
	end
end

function RankRaceMgr:receiveLinkReward( shareKey, onSuccess, onFail, onCancel )
	-- body
	RankRaceHttp:getShareReward(shareKey, function ( evt )
		local rewards = evt.data.rewards
		self:addRewards(rewards or {}, DcSourceType.kRankRaceLink)
		self:notify(RankRaceOBKey.kRewardInfoChange)
		if onSuccess then
			onSuccess(rewards)
		end
	end, onFail, onCancel)
end

function RankRaceMgr:receiveDanRewards( saijiIndex, onSuccess, onFail, onCancel )

	RankRaceHttp:getDanReward( function ( evt )
		self.data:setRewardedDan(self.data:getSafeDan())	
		self:addRewards(evt.data.rewards or {}, DcSourceType.kRankRaceDan)

		if onSuccess then
			onSuccess(evt.data.rewards or {})
		end

		self:notify(RankRaceOBKey.kRewardInfoChange)

	end, onFail, onCancel)
end

function RankRaceMgr:receiveDanRewards2( saijiIndex, onSuccess, onFail, onCancel )

	RankRaceHttp:getDanReward2( saijiIndex, function ( evt )
		self.data:setRewardedDan(self.data:getSafeDan())	
        self.LaseWeekAfterDan = evt.data.afterDan
        self.LaseWeekBeforeDan = evt.data.beforeDan

		self:addRewards(evt.data.rewards or {}, DcSourceType.kRankRaceDan)

		if onSuccess then
			onSuccess(evt.data.rewards or {})
		end

		self:notify(RankRaceOBKey.kRewardInfoChange)

	end, onFail, onCancel)
end

function RankRaceMgr:hasDanRewards( ... )

    --之前算法废弃。需要考虑跨赛季的问题了。
    local CurSaiJiIndex = self:getCurSaijiIndex()

    if CurSaiJiIndex== 1 then
	    -- body
    	return self.data:getSafeDan() > self.data:getRewardedDan()
    else
        local SeasonRewards = self.data:getSeasonRewards()

        local bCanDanReward = false
        local RewardIndex = 0
        if SeasonRewards and (type(SeasonRewards)=="table") then
            for i,v in pairs(SeasonRewards) do
                if v[1] > v[2] then
                    bCanDanReward = true
                    RewardIndex = i
                    break
                end
            end
        end
        return bCanDanReward, RewardIndex
    end

    return false
end

function RankRaceMgr:hasLastWeekRewards( ... )
	local lastWeekLotteryRewards = self.data:getLastWeekLotteryRewards()
	local lastWeekBoxes = self.data:getLastWeekBoxes()

	local hasLottery = #lastWeekLotteryRewards > 0
	local hasBoxes = #lastWeekBoxes > 0

	return hasLottery or hasBoxes, hasLottery, hasBoxes
end

function RankRaceMgr:isTaskFinished( ... )
	return self.data:getTodayTC0() >= self.meta:getTaskTarget()
end


function RankRaceMgr:receiveOldReward( onSuccess, onFail, onCancel )
	RankRaceHttp:getOldReward(function ( evt )
		self.data:clearOldRewards()	
		self:addRewards(evt.data.rewards or {}, DcSourceType.kRankRaceOld)
		if onSuccess then
			onSuccess(evt.data.rewards or {})
		end
	end, onFail, onCancel)
end

function RankRaceMgr:getLevelIDRange()
	local ret = {}
	local now = self.data:getWeekIndex()
	if now >= LEVEL_CHANGE_WEEK then
		local newLvCfg = self.meta:getNewLevelIdCfg() 
		for _, levelId in ipairs(newLvCfg) do
			table.insert(ret, levelId)
		end
	else
		local bweek, blevel, step = self.meta:getLevelIdCfg()
		local beginLevel = (now - bweek) * step + blevel
		local endLevel = beginLevel + step - 1
		for levelId = beginLevel, endLevel do
			table.insert(ret, levelId)
		end
	end
	return ret
end

--失败过关不要调用它
function RankRaceMgr:onPassLevel(levelId, star, deltaTC0, deltaTC1)

	if (deltaTC0 and deltaTC0 > 0) or (deltaTC1 and deltaTC1 > 0) then
		if star > 1 then
			if self:getLevelIndex() == self.data:getUnlockIndex() and self.data:getUnlockIndex() < 6 then
				local GetGoldTip, GetGoldNum = self.data:passLevelUnlock()

                local SaijiIndex = self:getCurSaijiIndex()
                if SaijiIndex == 1 then
                else
                    self.ShowGetGoldTip = GetGoldTip
                    self.ShowGetGoldNum = GetGoldNum
                end

				self:notify(RankRaceOBKey.kUnlock, 1)
			end
		end
		if deltaTC0 then
			self:incTC0(deltaTC0)
		end
		if deltaTC1 then
			self:incTC1(deltaTC1)
		end
	end
end

function RankRaceMgr:onPaySuccess( ... )
	self.data:addFreePlay(1)
end

function RankRaceMgr:getLevelIndex( ... )
	return self.__curLevelIndex or 1
end

function RankRaceMgr:setLevelIndex( v )
	self.__curLevelIndex = v
end

function RankRaceMgr:willEnterGamePlay( )
	self.data:addFreePlay(-1)
	self.data:updateLastPlayTimestamp()
end

--只针对1-5关
function RankRaceMgr:getUnlockTarget(_levelIndex)
	local levelIndex = _levelIndex or self:getLevelIndex()
	local danBuffCfg = self.meta:getUnlockBuffConfig()
	local dan = self.data:getSafeDan()
	local extra = tonumber(danBuffCfg[dan][levelIndex] or 0) or 0
	return extra
end

function RankRaceMgr:needShowTargetInfoInGamePlay( _levelIndex )
	local levelIndex = _levelIndex or self:getLevelIndex()
	if levelIndex >= 6 then
		return false
	end

	return not (self.data:getUnlockIndex() >= levelIndex + 1)
end

function RankRaceMgr:getCountDownStr( bShowUpdateVersion, ... )

    if bShowUpdateVersion == nil then bShowUpdateVersion = true end

	local now = Localhost:timeInSec()
	local weekIndex = getWeekIndex(now)
	local nextWeekStartTS = getWeekStartTS(weekIndex + 1)
	local deltaInSec = nextWeekStartTS - now
	local d = math.floor(deltaInSec / (3600 * 24))
	local h = math.floor(deltaInSec % (3600 * 24) / 3600)
	local m = math.floor(deltaInSec % (3600 * 24) % 3600 / 60)
	local s = math.floor(deltaInSec % (3600 * 24) % 3600 % 60)
	local time = string.format("%02d:%02d:%02d", h, m, s)

    local numVersion = tonumber(_G.bundleVersion:split(".")[2])
    if numVersion < 64 and bShowUpdateVersion then 					--这一条 不动更到老版本 那就不会生效
        --64 版本以下通知下新包
        return localize('rank.race.main.20', {n='\n'}), -10
    else
        local curSeasonIndex = self:getCurSaijiIndex()
        if curSeasonIndex < self.newestSeasonIndex then
            --旧赛季显示赛季结束倒计时
	        if d > 0 then
	        	local endTimeStr = RaceSeasonConfig[curSeasonIndex].endTimeStr
		        return localize('rank.race.main.19', {n = endTimeStr})
	        else
		        return localize('rank.race.main.18', {n = time})
	        end
        else
            --新赛季正常显示
            if d > 0 then
		        return localize('rank.race.time.default.desc')
	        else
		        return localize('rank.race.main.6', {n = time})
	        end
        end
    end

end

function RankRaceMgr:getFinalTarget( targetNum )
	local cfg = self.meta:getTargetBuffConfig()
	local extra = tonumber(cfg[self:getLevelIndex() or 1] or 0) or 0
	local ret = math.ceil2(targetNum * (1 + extra / 100))

	--特权结算加成
	local isEffective, addNum = PrivilegeMgr.getInstance():isPrivilegeEffctive(PrivilegeType.kRankRace)
	if isEffective then 
		addNum = addNum or 0
		ret = ret + addNum 
		self:setPrivilegeAddNum(addNum)
	else
		self:setPrivilegeAddNum(0)
	end
	return ret
end

function RankRaceMgr:setPrivilegeAddNum(addNum)
	self.privilegeAddNum = addNum
end

function RankRaceMgr:getPrivilegeAddNum()
	return self.privilegeAddNum
end

function RankRaceMgr:getTargetBuff( levelIndex )
	local cfg = self.meta:getTargetBuffConfig()
	local extra = tonumber(cfg[levelIndex] or 0) or 0
	return extra
end

function RankRaceMgr:setBaseTarget_0( targetNum )
	self.base_target_0 = targetNum
end

function RankRaceMgr:getBaseTarget_0( ... )
	return self.base_target_0
end

function RankRaceMgr:checkLevelExists( callback )

	local levelIds = self:getLevelIDRange()
	

	local function isLevelExists( ... )
		return #(table.filter(levelIds, function ( levelId )
			return not LevelMapManager.getInstance():getMeta(levelId)
		end)) <= 0
	end

	if isLevelExists() then
		if callback then callback(true) end
	else

		local levelConfigUpdateProcessor = require("zoo.loader.LevelConfigUpdateProcessor").new()
		levelConfigUpdateProcessor:ad(Events.kComplete, function ( ... )
			LevelMapManager.getInstance():invalidLevelUpdate()
			if callback then callback(isLevelExists()) end
		end)
    	levelConfigUpdateProcessor:ad(Events.kError, function ( ... )
			if callback then callback(false) end
    	end)

    	levelConfigUpdateProcessor:start()
	end

end

function RankRaceMgr:checkLevelsIsCurWeekLevel()
    local CurWeekIndex = self:getCurWeekIndex()
    local LevelWeek = self.data.LevelWeekIndex

    if LevelWeek == CurWeekIndex then
        return true
    end

    return false
end

function RankRaceMgr:openMainPanel(isClick, onSuccess, onFail, close_cb)
	--最好是 周赛icon一点，就调用这个方法
	-- 有一些其他地方，会主动打开周赛，就让他们调这个
	-- 实现 拉数据 开面板

	if PrepackageUtil:isPreNoNetWork() then
		if (__ANDROID) then
            if isClick then PrepackageUtil:showSettingNetWorkDialog() end
        end
        if onFail then onFail() end
		return
	end


	if self:isPreHeat() then 
		local PanelClazz = require "zoo.quarterlyRankRace.view.RankRacePrePanel"
		local panel = PanelClazz:create()
		panel:popout( close_cb )
	elseif self:isEnabled() then
		local function __popout( syncSuccess )

            if syncSuccess and type(syncSuccess)=='table' and syncSuccess.name and syncSuccess.name == 'error' then 
                local ErrorCode = tonumber( syncSuccess.data )
                CommonTip:showTip( localize("error.tip."..ErrorCode ),"negative")
                return
            end 

			local t1 = 2
			if self.data:isValid() and (self.data:getRawDan() > 0 or (not self.data:isNormalStatus())) then
				if not isClick then
					self.data:setLastPopWeekIndex(self.data:getWeekIndex())
				end
				self.data:write()
				local PanelClazz = require "zoo.quarterlyRankRace.view.RankRaceMainPanel"
				local panel = PanelClazz:create()
				panel:popout( close_cb )
				self:notify(RankRaceOBKey.kOpenMainPanel)

				if syncSuccess then
					t1 = 1
				end
			else
				if isClick then CommonTip:showNetworkAlert() end
			end
			if not syncSuccess then
				if onFail then onFail() end 
			end
			DcUtil:UserTrack({category='weeklyrace2018', sub_category='weeklyrace2018_click_icon', t1 = t1, t2 = self.data:getDan()})
		end

		local function onUserLogin( ... )
			RankRaceHttp:getFullInfo(function ( evt )
				self.data:decode(evt.data or {})
				__popout(true)
			end, __popout, __popout)
		end

		RequireNetworkAlert:callFuncWithLogged(onUserLogin, function ( ... )
			if self.data:isValid() then
				__popout()
			else
				if isClick then CommonTip:showNetworkAlert() end
				if onFail then onFail() end 
			end
		end)
	end
end

function RankRaceMgr:loadServerDataInBackground(callback)
	if self:isEnabled() then
		local function onUserLogin( ... )
			RankRaceHttp:getMiniInfo(function ( evt )
				self.data:miniDecode(evt.data or {})
				if self.data:isValid() then
					self.data:write()
				end
				if callback then callback() end
			end, callback, callback)
		end
		RequireNetworkAlert:callFuncWithLogged(onUserLogin, function ( ... )  
			if callback then callback() end
		end)
	else
		if callback then callback() end
	end
end

function RankRaceMgr:getLeftFreePlay( ... )
	return self.data.leftFreePlay or 0
end

function RankRaceMgr:isValid()
	return self.data:isValid()
end

function RankRaceMgr:isTomorrowSameWeek( ... )
	local curWeekIndex = self.data:getWeekIndex()
	local now = Localhost:timeInSec()
	local tomorrow = now + 24 * 3600
	local tomorrowWeekIndex = getWeekIndex(tomorrow)
	return tomorrowWeekIndex == curWeekIndex
end

function RankRaceMgr:canForcePop()
	do return false end

	local nowWeekIndex = getWeekIndex(Localhost:timeInSec())
	local lastPopWeekIndex = self:getData():getLastPopWeekIndex() or 0
	local calStatus = tonumber(self:getData():getStatus())
	if not calStatus or (calStatus ~= 2 and calStatus ~= 3) then
		if nowWeekIndex > lastPopWeekIndex then 
			return true
		end
	end
	return false
end

function RankRaceMgr:tryForcePopout(onSuccess, onFail, close_cb)
	if self:canForcePop() then
		self:openMainPanel(false, onSuccess, onFail, close_cb)
	end
end

--获取当前赛季
function RankRaceMgr:getCurSaijiIndex()
	local curWeekIndex = self:getCurWeekIndex()
	local curSeasonIndex = 3 					--1.65版本开始 最低第3赛季
	for i,v in ipairs(RaceSeasonConfig) do
		if curWeekIndex >= v.beginWeekIndex then 
			curSeasonIndex = v.seasonIndex
		end
	end

	return curSeasonIndex
end

function RankRaceMgr:getSaijiIndex(weekIndex)
	local curSeasonIndex = 3 					
	for i,v in ipairs(RaceSeasonConfig) do
		if weekIndex >= v.beginWeekIndex then 
			curSeasonIndex = v.seasonIndex
		end
	end

	return curSeasonIndex
end

function RankRaceMgr:getCurWeekIndex()
    local now = Localhost:timeInSec()
    return getWeekIndex(now)
end

function RankRaceMgr:isOldUISeason()
	local curWeekIndex = self:getCurWeekIndex()
	local season2Week = RaceSeasonConfig[2].beginWeekIndex
    if curWeekIndex < season2Week then
    	return true
    end
    return false
end

function RankRaceMgr:lastWeekIsOldUISeason()
    local getCurSaijiIndex = self:getCurSaijiIndex()
	local curWeekIndex = self:getCurWeekIndex()
	local seasonWeek = RaceSeasonConfig[getCurSaijiIndex].beginWeekIndex
    if curWeekIndex-1 < seasonWeek then
    	return true
    end
    return false
end

function RankRaceMgr:isNewestSeaonWeekIndex()
    local curWeekIndex = self:getCurWeekIndex()
    local seasonMaxNum = #RaceSeasonConfig
    local newestBeginWeekIndex = RaceSeasonConfig[seasonMaxNum].beginWeekIndex
    return curWeekIndex == newestBeginWeekIndex
end

function RankRaceMgr:isNewestSeasonComming()
	local curWeekIndex = self:getCurWeekIndex()
    local seasonMaxNum = #RaceSeasonConfig
    local newestBeginWeekIndex = RaceSeasonConfig[seasonMaxNum].beginWeekIndex
    return curWeekIndex < newestBeginWeekIndex
end

function RankRaceMgr:getCurBigDan()
    local Dan = RankRaceMgr.getInstance():getData():getSafeDan()
    local bigDan = self:getBigDanByDan( Dan )
    return bigDan
end

function RankRaceMgr:getBigDanByDan( Dan )
    local bigDan = math.ceil(Dan/3)
    return bigDan
end

function RankRaceMgr:getSaiJiName(seasonIndex)
	local year = "地鼠周赛"
    local season = ""

    local _seasonIndex = seasonIndex + 2	--前人和后端订的索引从-1开始 这里纠正过来
    for i,v in ipairs(RaceSeasonConfig) do
    	if v.seasonIndex == _seasonIndex then
    		season = "第" .. _seasonIndex .. "赛季"
    	end
    end
    return year, season
end

function RankRaceMgr:getNewestPreShow()
	if self.newestPreShow == nil then
		local uid = UserManager.getInstance().user.uid
	    local key = 'RankRace:NewestPre.' .. self.newestSeasonIndex .. '.' .. uid
		self.newestPreShow = CCUserDefault:sharedUserDefault():getBoolForKey(key, false)	 
	end
	return self.newestPreShow
end

function RankRaceMgr:setNewestPreShow()
	self.newestPreShow = true

	local uid = UserManager.getInstance().user.uid
    local key = 'RankRace:NewestPre.' .. self.newestSeasonIndex .. '.' .. uid
	CCUserDefault:sharedUserDefault():setBoolForKey(key, true)	
	CCUserDefault:sharedUserDefault():flush()
end