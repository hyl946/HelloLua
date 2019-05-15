local function getWeekIndex( timeInSec )
	return math.floor((timeInSec - 4 * 24 * 3600 + 8 * 3600) / (7 *24 * 3600)) + 1
end

local function time2day(ts)
	ts = ts or Localhost:timeInSec()
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end

local RankRaceData = class()

function RankRaceData:ctor( ... )

	-- self.freePlay = 0 
	-- info 返回的所有玩意儿都声明一下

	self:reset()
end

function RankRaceData:reset( ... )

	self.timestamp = 0
	-- if __WIN32 then
	-- 	self.timestamp = Localhost:time()
	-- end
	self.status = 3
	self.rewardedOld = true

	self.unlockIndex = 1
	self.lastAutoUnlockDay = time2day()

	self.leftFreePlay = 3

	self.target_count_0 = 0 --领累计宝箱的收集物
	self.target_count_1 = 0 --抽奖用的收集物

	self.today_target_count_0 = 0 

	self.rewardedBoxes = {} -- 领过的宝箱id {1,2,3,4,5,6}

	self.lastWeekBoxes = {} -- 需要另发协议 领取
	self.lastWeekBoxRewards = {}
	self.lastWeekLotteryRewards = {} -- 需要另发协议 领取
	self.lastWeekGold = 0 --last_week_target_1

	self.dan = 0 --段位
	self.rewardedDan = 1
	self.lastRank = 0

	-- self.taskRewarded = false --今日任务是否完成

	self.receiveGiftCount = 0
	self.sendGiftCount = 0
	self.danHistory = {}

	self.lotteryHistory = {}

	self.hasGifts = false

    self.lastWeekDan = 1 --上周段位
    self.lastWeekRank = 0 --上周排名
    self.extraGoldExcludeIndexes = {} --不能获取通关奖励的关卡
    self.seasonRewards = {} --赛季奖励 
    self.seasonHistories = {} --赛季历史  -1为当前赛季 0为第一赛季
    self.kingHeadFrame = false --是否能领取头像框


	-- if __WIN32 then
		-- self.lotteryHistory = {'10086:12:21390'}
	-- end

	--后端传来的配置, 只读字段，通过 RankRaceMeta访问, 不要从这直接引用
	if not self.config then
		self.config = '{}'
	end
	self.levels = {}
    self.LevelWeekIndex = 0 --关卡列表所在的周

	-- self.lotteryCost = 10
	-- self.rawLotteryConfig = "10060:122,10087:1,10058:2,10089:1,10004:3,10007:1,10086:1,10010:1"
	-- self.rawBoxRewardConfig = '[{"conditions": "1","rewards": [{"itemId": "14","num": "1"}]}, {"conditions": "2","rewards": [{"itemId": "14","num": "1"}]}, {"conditions": "3","rewards": [{"itemId": "14","num": "1"}]}, {"conditions": "4","rewards": [{"itemId": "14","num": "1"}]}, {"conditions": "5","rewards": [{"itemId": "14","num": "1"}]}, {"conditions": "6","rewards": [{"itemId": "14","num": "1"}]}]'


	-- 即时拉取 不作缓存的数据 另外存在别地方
	-- 转盘抽奖记录
	-- 收到的红包
	-- 红包领取记录
	-- 坚坚的排行榜
	-- 
	--

	--本地字段
	self.sendedUids = {}
	self.lastPlayTimestamp = 0

	if self.isShowSkillGuide == nil then
		self.isShowSkillGuide = true
	end

	if self.isPlayAdd5Anim == nil then
		self.isPlayAdd5Anim = true
	end


	self.sawBoxAnim = false

	self.lastPopWeekIndex = nil
	-- 生成的字段 不参与序列化
	self:clearDerivationData()
    self:clearRewardsJsonInfo()
    self:clearHistoriesJsonInfo()
    self:clearGoldExcludeIndexesJsonInfo()
end

function RankRaceData:getSawBoxAnim( ... )
	return self.sawBoxAnim
end

function RankRaceData:getLastRank( ... )
	return self.lastRank or 0
end

function RankRaceData:setSawBoxAnim( v )
	if not self:isValid() then return end
	self.sawBoxAnim = v
	self:write()
end

function RankRaceData:clearDerivationData( ... )
	self.jsonMeta = nil
end

function RankRaceData:clearRewardsJsonInfo( ... )
    self.seasonRewardsJsonInfo = nil
end

function RankRaceData:clearHistoriesJsonInfo( ... )
    self.seasonHistoriesJsonInfo = nil
end

function RankRaceData:clearGoldExcludeIndexesJsonInfo( ... )
	self.extraGoldExcludeIndexesJsonInfo = nil
end

function RankRaceData:getIsShowSkillGuide( ... )
	return self.isShowSkillGuide
end

function RankRaceData:setIsShowSkillGuide( bShow )
	if not self:isValid() then return end
	self.isShowSkillGuide = bShow
	self:write()
end

function RankRaceData:getIsPlayAdd5Anim( ... )
	return self.isPlayAdd5Anim
end

function RankRaceData:setIsPlayAdd5Anim( bShow )
	if not self:isValid() then return end
	self.isPlayAdd5Anim = bShow
	self:write()
end


function RankRaceData:getSkillGuideFlag( ... )
	return UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kRankRaceSkillGuideFlag)
end

function RankRaceData:setSkillGuideFlag()
	UserLocalLogic:setBAFlagWrapper(kBAFlagsIdx.kRankRaceSkillGuideFlag, true)
end

function RankRaceData:getNewSkillGuideFlag( ... )
	return UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kRankRaceNewSkillGuideFlag2)
end

function RankRaceData:setNewSkillGuideFlag()
	UserLocalLogic:setBAFlagWrapper(kBAFlagsIdx.kRankRaceNewSkillGuideFlag2, true)
end

function RankRaceData:getMetaValue( keyName )
	if not self.jsonMeta then
		self.jsonMeta = table.deserialize(self.config)
	end

	if self.jsonMeta then
		return self.jsonMeta[keyName]
	end
end

function RankRaceData:getLevels()
	return self.levels
end

function RankRaceData:onPassDay( ... )
	-- body
	if not self:isValid() then return end

	self.timestamp = Localhost:time() + 1
	self.leftFreePlay = 3
	self.today_target_count_0 = 0
	self.taskFinished = 0
	self.receiveGiftCount = 0
	self.sendedUids = {}
	self.hasGifts = false
	self:write()

end

function RankRaceData:getReceiveGiftCount( ... )
	return self.receiveGiftCount or 0
end

function RankRaceData:getHasGifts( ... )
	return self.hasGifts
end

function RankRaceData:setHasGifts( v)
	if not self:isValid() then return end
	self.hasGifts = v
	self:write()
end

function RankRaceData:addReceiveGiftCount( delta )
	if not self:isValid() then return end
	self.receiveGiftCount = (self.receiveGiftCount or 0) + delta
	self:write()
end

function RankRaceData:addFreePlay( delta )
	if not self:isValid() then return end
	self.leftFreePlay = (self.leftFreePlay or 0) + delta
	self.leftFreePlay = math.max(self.leftFreePlay, 0)
	self:write()
end

function RankRaceData:getFreePlay( ... )
	return self.leftFreePlay or 0
end


function RankRaceData:isValid( ... )
	return self:getWeekIndex() == getWeekIndex(Localhost:timeInSec())
end

function RankRaceData:getStatus( ... )
	return self.status
end

function RankRaceData:isNormalStatus( ... )
	return tostring(self.status) == tostring(1)
end

function RankRaceData:getWeekIndex( ... )
	if self.timestamp then
		return getWeekIndex(tonumber(self.timestamp)/1000)
	end
	return 0
end

function RankRaceData:getDayIndex( ... )
	if self.timestamp then
		return time2day(tonumber(self.timestamp)/1000)
	end
	return 0
end

local function getWeekIndex( timeInSec )
	return math.floor((timeInSec - 4 * 24 * 3600 + 8 * 3600) / (7 *24 * 3600)) + 1
end

function RankRaceData:getCurWeekIndex()
    local now = Localhost:timeInSec()
    return getWeekIndex(now)
end

function RankRaceData:decode( src )

	for key, value in pairs(src or {}) do
		if string.starts(key, '_') then

		elseif type(value) == 'number' or type(value) == 'boolean' or type(value) == 'string' then
			self[key] = value
		elseif type(value) == 'table' and value.ctor == nil then
			self[key] = table.clone(value, true)
		end
	end

	self.leftFreePlay = math.clamp(self.leftFreePlay or 0, 0, 999)

	if self.unlockIndex then
		self.unlockIndex = math.clamp(self.unlockIndex, 1, 6)
	end

    local CurSaijiWeek = self:getCurWeekIndex()
    self.LevelWeekIndex = CurSaijiWeek

	self:clearDerivationData()
    self:clearRewardsJsonInfo()
    self:clearHistoriesJsonInfo()
    self:clearGoldExcludeIndexesJsonInfo()

	self:checkOverDay(true)
	self:checkOverWeek(true)
end

function RankRaceData:miniDecode( src )

	self:decode({
		timestamp = src.timestamp,
		status = src.status,
		leftFreePlay = src.leftFreePlay,
		levels = src.levels,
		config = src.config,
		today_target_count_0 = src.today_target_count_0,
		target_count_0 = src.target_count_0,
		target_count_1 = src.target_count_1,
		unlockIndex = src.unlockIndex,
		rewardedBoxes = src.rewardedBoxes or {},
        lastWeekDan = src.lastWeekDan or 1 ,
        lastWeekRank = src.lastWeekRank or 0 ,
        extraGoldExcludeIndexes = src.extraGoldExcludeIndexes or {} ,
        seasonRewards = src.seasonRewards or {} ,
        seasonHistories = src.seasonHistories or {}
	})
end


function RankRaceData:encode( ... )
	self:clearDerivationData()
    self:clearRewardsJsonInfo()
    self:clearHistoriesJsonInfo()
    self:clearGoldExcludeIndexesJsonInfo()

	local data = {}
	for key, value in pairs(self) do
		if string.starts(key, '_') then

		elseif type(value) == 'number' or type(value) == 'boolean' or type(value) == 'string' then
			data[key] = value
		elseif type(value) == 'table' and value.ctor == nil then
			data[key] = table.clone(value, true)
		end
	end

	return data
end

function RankRaceData:__write( ... )
	Localhost.getInstance():writeRankRaceData(self:encode())
end

function RankRaceData:write( ... )
	if not self._writeWorker then
		self._writeWorker = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ( ... )

			self:__write()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._writeWorker)
			self._writeWorker = nil

		end,1/60,false)
	end

	-- self:__write()
end

function RankRaceData:read( ... )
	self:decode(Localhost.getInstance():readRankRaceData() or {})
end

--跨天应该调用
function RankRaceData:checkOverWeek( clearData )
	if tonumber(self:getWeekIndex()) ~= getWeekIndex(Localhost:timeInSec()) then
		if clearData then
			self:reset()
			self:write()
		end
		return true
	end
	return false
end

function RankRaceData:checkOverDay( clearData )
	if tonumber(self:getDayIndex()) ~= time2day(Localhost:timeInSec()) then
		if clearData then
			self:onPassDay()
			self:write()
		end
		return true
	end
	return false
end

function RankRaceData:getTodayTC0( ... )
	return self.today_target_count_0
end

function RankRaceData:setTodayTC0( tc )

	if not self:isValid() then return end

	self.today_target_count_0 = tc
	self:write()
end

function RankRaceData:getTC0( ... )
	return self.target_count_0
end

function RankRaceData:getTC1( ... )
	return self.target_count_1
end

function RankRaceData:getLastWeekTC1( ... )
	return self.lastWeekGold
end

function RankRaceData:setTC0( tc )

	if not self:isValid() then return end

	self.target_count_0 = tc
	self:write()
end

function RankRaceData:setTC1( tc )

	if not self:isValid() then return end

	self.target_count_1 = tc
	self:write()
end

function RankRaceData:getRewardedBoxes( ... )
	
	return self.rewardedBoxes or {}
end

function RankRaceData:insertRewardedBoxes( boxIndex )
	if not self:isValid() then return end
	table.insert(self.rewardedBoxes, boxIndex)
	self:write()
end

function RankRaceData:getSafeDan( ... )
	return math.clamp(self.dan or 1, 1, 10)
end

function RankRaceData:getDan( ... )
	return self:getSafeDan()
end

function RankRaceData:getLastWeekDan( ... )
	return self.lastWeekDan
end

function RankRaceData:getLastWeekRank( ... )
	return self.lastWeekRank
end

function RankRaceData:getSeasonRewards( ... )

    if not self.seasonRewardsJsonInfo then
		self.seasonRewardsJsonInfo = table.deserialize(self.seasonRewards)
	end

	if self.seasonRewardsJsonInfo then
		return self.seasonRewardsJsonInfo
	end
end

function RankRaceData:getSeasonHistories( ... )
    if not self.seasonHistoriesJsonInfo then
		self.seasonHistoriesJsonInfo = table.deserialize(self.seasonHistories)
	end

	if self.seasonHistoriesJsonInfo then
		return self.seasonHistoriesJsonInfo
	end
end

function RankRaceData:getExtraGoldExcludeIndexes( ... )
    if not self.extraGoldExcludeIndexesJsonInfo then
		self.extraGoldExcludeIndexesJsonInfo = table.deserialize(self.extraGoldExcludeIndexes)
	end

	if self.extraGoldExcludeIndexesJsonInfo then
		return self.extraGoldExcludeIndexesJsonInfo
	end
end

function RankRaceData:getRawDan( ... )
	return self.dan or 0
end

function RankRaceData:getRewardedDan( ... )
	return self.rewardedDan
end

function RankRaceData:setRewardedDan( _rewardedDan )
	if not self:isValid() then return end
	self.rewardedDan = _rewardedDan
	self:write()
end

function RankRaceData:clearLastWeekBoxes( ... )
	if not self:isValid() then return end
	self.lastWeekBoxes = {}
	self.lastWeekBoxRewards = {}
	self:write()
end

function RankRaceData:clearLastWeekLotteryRewards( ... )
	if not self:isValid() then return end
	self.lastWeekLotteryRewards = {}
	self.lastWeekGold = 0
	self:write()
end

function RankRaceData:getLastWeekLotteryRewards( ... )
	return self.lastWeekLotteryRewards or {}
end

function RankRaceData:getLastWeekBoxes( ... )
	return self.lastWeekBoxes or {}
end

function RankRaceData:getLastWeekBoxRewards( ... )
	return self.lastWeekBoxRewards
end

function RankRaceData:getSendGiftNum( ... )
	return self.sendGiftCount
end

function RankRaceData:getSendedUids( ... )
	return self.sendedUids
end

function RankRaceData:extendSendedUids( uids )
	if not self:isValid() then return end
	self.sendedUids = table.union(self.sendedUids, uids)
	self:write()
end

function RankRaceData:passLevelUnlock( ... )
	if not self:isValid() then return end
    local GetGoldTip, GetGoldNum = self:addTaskExtraIndexes( self.unlockIndex, false )
	self.unlockIndex = math.clamp(self.unlockIndex + 1, 1, 6)
	self:write()

    return GetGoldTip, GetGoldNum
end

function RankRaceData:autoUnlock( ... )
	if not self:isValid() then return end
    local GetGoldTip, GetGoldNum = self:addTaskExtraIndexes( self.unlockIndex, true )
	self.unlockIndex = math.clamp(self.unlockIndex + 1, 1, 6)
	self.lastAutoUnlockDay = self:getDayIndex()
	self:write()

    return GetGoldTip, GetGoldNum
end

function RankRaceData:addTaskExtraIndexes( taskIndex, bAutoUnlock )

    local bIsAutoUnlock = bAutoUnlock or false
    local ShowGetGoldTip = false
    local ShowGetGoldNum = 0

    local ExtraGoldExcludeIndexes = self:getExtraGoldExcludeIndexes()
    if ExtraGoldExcludeIndexes and type(ExtraGoldExcludeIndexes) == 'table'  then

       local bHave = false
       for i,v in pairs(ExtraGoldExcludeIndexes) do
            if v == taskIndex then
                bHave = true
                break
            end
        end

        if bHave == false then
            ExtraGoldExcludeIndexes[#ExtraGoldExcludeIndexes+1] = taskIndex
            self.extraGoldExcludeIndexes = table.serialize(ExtraGoldExcludeIndexes)

            if bAutoUnlock == false then
                local addNum = self:getMetaValue('first_pass_gold_'..taskIndex) or 0
                self:setTC1(self:getTC1() + addNum)

                ShowGetGoldTip = true
                ShowGetGoldNum = addNum
            end
        end
    end

    return ShowGetGoldTip, ShowGetGoldNum
end

function RankRaceData:updateLastPlayTimestamp( ... )
	self.lastPlayTimestamp = Localhost:time()
	self:write()
end

function RankRaceData:getLastPlayTimestamp( ... )
	return self.lastPlayTimestamp or 0
end

function RankRaceData:getUnlockIndex( ... )
	return self.unlockIndex
end

function RankRaceData:getLastAutoUnlockDay( ... )
	-- body
	return self.lastAutoUnlockDay
end

function RankRaceData:canAutoUnlock( ... )
	if self:isValid() then
		if self:getDayIndex() > self:getLastAutoUnlockDay() and self:getUnlockIndex() < 6 then
			return true
		end
	end
	return false
end

function RankRaceData:insertLotteryLog( itemId, num, timestamp )
	if not self:isValid() then return end
	timestamp = timestamp or Localhost:time()
	table.insert(self.lotteryHistory, string.format('%s,%s,%s', itemId, num, timestamp))
	self:write()
end

function RankRaceData:getLotteryLog( ... )
	return self.lotteryHistory
end

function RankRaceData:hasOldRewards( ... )
	return self.rewardedOld == false
end

function RankRaceData:clearOldRewards( ... )
	self.rewardedOld = true
end

function RankRaceData:getLastPopWeekIndex()
	return self.lastPopWeekIndex
end

function RankRaceData:setLastPopWeekIndex(weekIndex)
	self.lastPopWeekIndex = weekIndex
end

return RankRaceData