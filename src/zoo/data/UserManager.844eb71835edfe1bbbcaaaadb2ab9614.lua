require "hecore.class"
require "zoo.data.DataRef"
require "zoo.data.CDKeyManager"
require "zoo.dc.GameItemDcUtil"
require "zoo.dc.GameCurrencyDcUtil"
require "zoo.model.GainAndConsumeMgr"
require "zoo.quest.QuestManager"

kMaxLevels = -1
kMaxHiddenLevel = 0

local debugUserData = false

local instance = nil
UserManager = class()

kBAFlagsIdx = {
	kHiddenBranchIntroduction = 1,
	kRealNameAuthPopout = 2,--实名制通知
	kASKFirstHelpedSuccess = 3,

	kWifiAutoDownloadSwitch_1 = 4, --wifi自动下载 用户是否可见该功能
	kWifiAutoDownloadSwitch_2 = 5, --wifi自动下载 用户手动设置的开关状态
	kHasNewAskForHelpMsg = 6,
	kInviteFriendRewardRemovePopout = 7,--是否还可以弹出删除邀请好友有礼提示
	kAreaTaskAnimation = 8,

	kRankRaceSkillGuideFlag = 9,

	--隐私策略相关 10 -14 
	kLocationDCFlag = 10,
	kEditHead = 11,
	kAlertPhone = 12,
	kAlertLocation = 13 ,
	kAlertFriends = 14 ,
    kSVIPGetPhoneReward = 131,

    kRankRaceNewSkillGuideFlag = 15, --第二赛季引导
    kRankRaceNewSkillGuideFlag2 = 16, --第三赛季引导
}

kHeadFrameEnum = {
	ACT1 = 1,
	ACT2 = 2,
	ACT3 = 3,
	ACT4 = 4,
	ASF = 14,
}

--需要后端返回的额外字段
_G.USER_NEED_KEYS = {
	--区域任务
	'areaTaskInfo',
	--满星排行榜数据
	'fullStarRecords',
	'lastRoundFullLevel',
	'curRoundFullStar',
	--4~6天召回推送奖励
	'recallNotificationRewards',
	--30天内活跃天数
	'active30Days',
	--视频广告
	'videoSDKInfo',
	--个人社区最新消息的版本
	'communityMessage',
	--开屏广告
	'splashAd',
	--前置buff
	'preBuff',
	--任务
	'questSystemInfo',
}

function UserManager:ctor()
	self:reset()
end

function UserManager:hadInited( ... )
	return instance ~= nil
end

function UserManager:reset()
	self.kMaxHeadImages = 10
	self.platform = kDefaultSocialPlatform
	self.uid = nil --set by debug, by sns connect, etc. 
	self.sessionKey = nil
	self.openId = nil
	self.appName = ""
	self.friendIds = {}
	self.user = UserRef.new()
	self.profile = ProfileRef.new()
	self.userExtend = UserExtendRef.new()
	self.bag = BagRef.new()
	self.mark = MarkRef.new()
	self.dailyData = DailyDataRef.new()
	self.props = {} 
	self.funcs = {} 
	self.decos = {}
	self.scores = {}

	self.jumpedLevelInfos = {}
	self.subsSuccessLevelIds = {}
	self.successRecords = {}
	self.subsTotalBeHelpedCount = 0
	self.oldScores = {}

	self.achis = {}
	self.requestInfos = {} 
	self.requestNum = 0
	self.unLockFriendInfos = {}
	self.countdownAreaId = -1
	self.countdownUnlockTime = -1
	self.ladyBugInfos = {}

	self.levelAreaOpenedId = false	-- Used To Record Which Level Area Opened Recently

	-- Index: locked area id
	-- value: a table { userid1, userid2, userid3, ...}

	-- Used To Invited Friend Info
	self.inviteFriendsInfo	= false

	-- Used In Friend Rank 
	self.selfNumberInFriendRank	= {}	-- Key: number(LevelId), Value: number(rank)
	self.selfOldNumberInFriendRank	= {}

	self.selfNumberInServerRank	= {}
	self.selfOldNumberInServerRank	= {}	

	self.exchangeCode = ""


	-- Used For Invited Friend Reward
	self.inviteFriendInfos = false

	-- 
	self.updateInfo = {}
	self.updateReward = {}
	self.updateRewards = {}

	self.smsDayRmb = 0
	self.smsMonthRmb = 0

	self.preRewards = {}
	self.preRewardsFlag = true
	self.timeProps = {}

	self.contact = {}
	self.actualExchangeCodes = {}

	self.achievement = AchievementRef.new()
	self.newLadyBugInfo = NewLadyBugInfoRef.new()

	self.acceptedEnergy = false
	self.global = {}
	
	self.uiHasClickedEasterEggList = {}

	self.npcNumber = 0
	self.areaId = 0

	local currentTime = Localhost:timeInSec()
	-- 积分墙Quota[时间戳，日领取，日限额，月领取，月限额]
	self.yybAdWallLimit = {currentTime, 0, 100, 0, 300}
	self.realNameAuthSwitchStatus = true
	self.realNameAuthed = true
	self.realNameIdCardAuthed = true
	self.realNameStatus = 0 --0，NONE 1，成功 2，失败

	-- ExceptionPanel 已经弹出面板就不再弹出
	self.isExceptionPanelPop = false

	self.baFlags = {}
	self.guideFlags = {}

	self.activationTag = 0
	self.activationTagTopLevelId = 0
	self.activationTagEndTime = 0

	self.notificationReminder = {}

	self.add5LotteryInfo = '{}'
	self.startTimeUserCallback = 0
	self.onlineStartAreaIds = {}

	self.playTimes = 0

	self.areaTaskInfo = AreaTaskRef.new()
	self.questSystemInfo = QuestRecordRef.new()

    self.endTimeOfBindPhoneIcon  = 0

    self.currentLoginTime = 0

    self.fullStarRecords = {}
    self.curRoundFullStar = 0x7FFFFFFF
    self.lastRoundFullLevel = false

    self.maxLevel = 0
    self.fullLevelGifts = "{}"
    self.active30Days = 0
    self.videoSDKInfo = nil

    self.userCallbackActInfo = nil

    self.scoreVersion = 0
	--个人社区最新消息的版本
    self.communityMessageVersion = 0

    self.splashAd = nil

    self.preBuff = nil

    self.groupInfo = {}
    self.giftPackInfos = {}
    self.giftPackNewUser = false

    self.markV2Active = false
    self.markV2TodayIsMark = false
end

function UserManager:getCurrLoginPlatformAuthType()	
	--PlatformAuthEnum
	return _G.sns_token.authorType 
end

function UserManager:checkDateChange()	

	local currentTime = math.ceil(Localhost:time()/1000)
	local currentDate = os.date("*t", currentTime)
	local flushData = false
	if not self.lastCheckTime then -- not initialized 
		if _G.isLocalDevelopMode then printx(0, 'not initialized ') end
		self.lastCheckTime = currentTime
		UserService:getInstance().lastCheckTime = currentTime

        UserManager:getInstance():updateContinuousLogonData(currentTime)
        UserService:getInstance():updateContinuousLogonData(currentTime)

        flushData = true
	end

	local lastTime = self.lastCheckTime
	local lastDate = os.date("*t", lastTime)

	local compareResult = compareDate(lastDate, currentDate)
	
	if 	compareResult == -1
	then
		self.lastCheckTime = currentTime
        UserManager:getInstance():getDailyData():resetAll()
        
		UserService:getInstance().lastCheckTime = currentTime
        UserService:getInstance():getDailyData():resetAll()

        flushData = true

		UserManager:getInstance():setAliKfDailyLimit(200)
		if lastDate.month ~= currentDate.month then
			UserManager:getInstance():setAliKfMonthlyLimit(20000)
		end
	end

    if compareResult ~= 0 then -- not equal
        UserManager:getInstance():updateContinuousLogonData(currentTime)
        UserService:getInstance():updateContinuousLogonData(currentTime)
        flushData = true
        if _G.isLocalDevelopMode then printx(0, ' not equal') end
    end	

    if flushData then
    	Localhost:flushCurrentUserData()
    end
end

function UserManager:getDailyData()
	self:checkDateChange()

	return self.dailyData
end

function UserManager:getInstance()
	if not instance then 
		instance = UserManager.new() 
	end
	return instance
end

function UserManager:isPlayerRegistered()
	return self.uid and self.uid ~= self.sessionKey
end

function UserManager:getMaxLevelInOpenedRegion()
	local curLevelId	= UserManager:getInstance().user.topLevelId
	local nextLevelAreaRef	= MetaManager.getInstance():getNextLevelAreaRefByLevelId(curLevelId)

	local areaMaxLevel = 0
	if nextLevelAreaRef then 
		areaMaxLevel = tonumber(nextLevelAreaRef.minLevel) - 1 
	else
		areaMaxLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	end
	return areaMaxLevel
end

function UserManager:getMinLevelInHighestLevelArea()
	local maxLevelIdWeHave = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	local minLevel = MetaManager.getInstance():getLevelAreaRefByLevelId(maxLevelIdWeHave).minLevel
	return minLevel
end

function UserManager:inHighestLevelArea()
	local minLevel = self:getMinLevelInHighestLevelArea()
	local toplevel = self.user:getTopLevelId()

	if toplevel >= minLevel then
		return true
	end

	return false
end

-- 用于隐藏关，和主线关的TopLevelId意思一样
function UserManager:getTopHiddenLevelId()
	return 0
end

function UserManager:getTopPassedMainLevelId()
    local topPassedLevelId = self.user:getTopLevelId()
    if not self:hasPassedLevelEx(topPassedLevelId) then
    	topPassedLevelId = topPassedLevelId - 1
    end
	return topPassedLevelId
end

function UserManager:getOpenedHiddenLevelStars()
	local branchList = MetaModel:sharedInstance():getHiddenBranchDataList()
	if not branchList then return 0 end
	
	local totalStars = 0
	for branchId, opened in pairs(branchList) do
		if MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then
			totalStars = totalStars + 9
		end
	end
	return totalStars
end

-- 隐藏关是否可玩
-- canPlay 是否可玩
-- isFirstFlowerInHiddenBranch 是否为隐藏关分支的第一关
function UserManager:isHiddenLevelCanPlay(hiddenLevelId)
	local id = hiddenLevelId
	if not LevelType:isHideLevel(id) then return false end

	local hiddenLevelScore = UserManager.getInstance():getUserScore(id)
	local preHiddenLevelScore = UserManager.getInstance():getUserScore(id - 1)

	local hiddenBranchId = MetaModel:sharedInstance():getHiddenBranchIdByHiddenLevelId(id)
	assert(hiddenBranchId)

	local isFirstFlowerInHiddenBranch = false
	local hiddenBranchData = MetaModel:sharedInstance():getHiddenBranchDataByHiddenLevelId(id)
	assert(hiddenBranchData)

	if hiddenBranchData.startHiddenLevel == id then
		isFirstFlowerInHiddenBranch = true
	end

	if not MetaModel:sharedInstance():isHiddenBranchCanShow(hiddenBranchId) then
		return false,isFirstFlowerInHiddenBranch
	end

	if MetaModel:sharedInstance():isHiddenBranchDesign(hiddenBranchId) then
		return false,isFirstFlowerInHiddenBranch
	end

	local canPlay = false
	if MetaModel:sharedInstance():isHiddenBranchCanOpen(hiddenBranchId) then
		if hiddenLevelScore and hiddenLevelScore.star > 0 then
			canPlay = true
		elseif isFirstFlowerInHiddenBranch or (preHiddenLevelScore and preHiddenLevelScore.star > 0) then				
			canPlay = true
		end
	end
	return canPlay,isFirstFlowerInHiddenBranch
end


function UserManager:getFullStarInOpenedRegion(...)
	assert(#{...} == 0)

	local areaMaxLevel = self:getMaxLevelInOpenedRegion()
	local fullStar = areaMaxLevel * 3

	return fullStar
end

-- 包含四星关
function UserManager:getFullStarInOpenedRegionInclude4star(...)
	assert(#{...} == 0)

	local areaMaxLevel = self:getMaxLevelInOpenedRegion()
	-- local fullStar = areaMaxLevel * 3

	return  LevelMapManager.getInstance():getTotalStar(areaMaxLevel)
end


local function debugMessage( msg )
	if debugUserData then if _G.isLocalDevelopMode then printx(0, "[UserManager]", ""..msg) end end
end 

function UserManager:decode(src)
	self:initFromLua(src , true)
end

function UserManager:createNewUser()
	local globalMeta = MetaManager.getInstance().global
	local userCoin = globalMeta.user_init_coin or 30000
	if _G.isLocalDevelopMode then printx(0, "createNewUser:", userCoin) end

	self.platform = kDefaultSocialPlatform
	self.uid = kDeviceID
	self.sessionKey = kDeviceID
	self.openId = nil
	self.user.uid = kDeviceID
	self.user:setEnergy(globalMeta.user_energy_init_count or 30)
	self.user:setCoin(userCoin)
	self.user:setUpdateTime(os.time() * 1000)
	self.user:setTopLevelId(1)

	local kMaxHeadImages = self.kMaxHeadImages + 1
	self.profile.headUrl = math.floor(math.random() * kMaxHeadImages)
end

function UserManager:syncUserFromLua( src )
	if src then
		self.user:fromLua(src)
	end
end

local function cloneMetaTableArray( dst )
	local result = {}
	for i,v in ipairs(dst) do
		result[i] = v
	end
	return result
end 
local function cloneClassTableArray( src, Cls )
	local result = {}
	for i,v in ipairs(src) do
		local p = Cls.new()
		p:fromLua(v)
		result[i] = p
	end
	return result
end 
function UserManager:clone(dst)
	dst.platform = self.platform
	dst.appName = self.appName
	dst.uid = self.uid
	dst.inviteCode = self.inviteCode
	dst.sessionKey = self.sessionKey
	dst.friendIds = cloneMetaTableArray(self.friendIds)
	dst.openId = self.openId
	
	dst.user = UserRef.new()
	dst.user:fromLua(self.user)

	dst.userExtend = UserExtendRef.new()
	dst.userExtend:fromLua(self.userExtend)

	dst.profile = ProfileRef.new()
	dst.profile:fromLua(self.profile)

	dst.bag = BagRef.new()
	dst.bag:fromLua(self.bag)

	dst.mark = MarkRef.new()
	dst.mark:fromLua(self.mark)

	dst.dailyData = DailyDataRef.new()
	dst.dailyData:fromLua(self.dailyData)

	dst.props = cloneClassTableArray(self.props, PropRef)
	dst.funcs = cloneClassTableArray(self.funcs, FuncRef)
	dst.decos = cloneClassTableArray(self.decos, DecoRef)
	dst.scores = cloneClassTableArray(self.scores, ScoreRef)
	dst.jumpedLevelInfos = cloneClassTableArray(self.jumpedLevelInfos, JumpLevelRef)
	dst.subsSuccessLevelIds = cloneMetaTableArray(self.subsSuccessLevelIds)
	dst.notificationReminder = cloneClassTableArray(self.notificationReminder, NotifiItemRef)
	dst.successRecords = cloneClassTableArray(self.successRecords, HelpedInfoRef)
	dst.subsTotalBeHelpedCount = self.subsTotalBeHelpedCount
	dst.achis = cloneClassTableArray(self.achis, AchiRef)
	dst.requestInfos = cloneClassTableArray(self.requestInfos, RequestInfoRef)
	dst.requestNum = self.requestNum
	dst.unLockFriendInfos = cloneClassTableArray(self.unLockFriendInfos, UnLockFriendInfoRef)
	dst.countdownAreaId = self.countdownAreaId
	dst.countdownUnlockTime = self.countdownUnlockTime
	dst.npcNumber = self.npcNumber
	dst.areaId = self.areaId
	dst.ladyBugInfos = cloneClassTableArray(self.ladyBugInfos, LadyBugInfoRef)
	dst.weekMatch = self.weekMatch
	dst.lastCheckTime = self.lastCheckTime
	dst.userReward = self.userReward
	dst.rabbitWeekly = self.rabbitWeekly
	dst.dimePlat = self.dimePlat
	dst.dimeProvince = self.dimeProvince
	dst.timeProps = cloneClassTableArray(self.timeProps, TimePropRef)
	dst.userType = self.userType
	dst.setting = self.setting
	dst.achievement = AchievementRef.new()
	dst.achievement:fromLua(self.achievement)

	dst.newLadyBugInfo = NewLadyBugInfoRef.new()
	dst.newLadyBugInfo:fromLua(self.newLadyBugInfo)
	

	dst.ingameLimit = self.ingameLimit
	dst.acceptedEnergy = self.acceptedEnergy
	dst.global = self.global
	dst.cmgameOfflinePayLimit = self.cmgameOfflinePayLimit

	-- 积分墙Quota
	dst.yybAdWallLimit = cloneMetaTableArray(self.yybAdWallLimit)
	dst.realNameAuthSwitchStatus = self.realNameAuthSwitchStatus
	dst.realNameAuthed = self.realNameAuthed
	dst.realNameIdCardAuthed = self.realNameIdCardAuthed
	dst.realNameStatus = self.realNameStatus
	dst.activationTag = self.activationTag
	dst.activationTagTopLevelId = self.activationTagTopLevelId
	dst.activationTagEndTime = self.activationTagEndTime

	dst.propGuideInfo = PropGuideInfoRef.new()
	dst.propGuideInfo:fromLua(self.propGuideInfo)

	dst.baFlags = {}
	for k, v in pairs(self.baFlags) do
		dst.baFlags[k] = v
	end
	dst.guideFlags = {}
	for k, v in pairs(self.guideFlags) do
		dst.guideFlags[k] = v
	end

	dst.add5LotteryInfo = self.add5LotteryInfo
	dst.startTimeUserCallback = self.startTimeUserCallback or 0
	dst.onlineStartAreaIds = self.onlineStartAreaIds

	dst.areaTaskInfo = AreaTaskRef.new()
	dst.areaTaskInfo:fromLua(self.areaTaskInfo or {})

	dst.questSystemInfo = QuestRecordRef.new()
	dst.questSystemInfo:fromLua(self.questSystemInfo or {})

    dst.endTimeOfBindPhoneIcon  = self.endTimeOfBindPhoneIcon 

	dst.fullStarRecords = cloneClassTableArray(self.fullStarRecords or {}, FullStarRankHistoryRef)
	dst.lastRoundFullLevel = self.lastRoundFullLevel or false
	dst.curRoundFullStar = self.curRoundFullStar or 0x7FFFFFFF
	dst.maxLevel = self.maxLevel or 0
	dst.fullLevelGifts = self.fullLevelGifts or '{}'
	dst.active30Days = self.active30Days or 0

	-- dst.videoSDKInfo = self.videoSDKInfo or {}

	dst.scoreVersion = self.scoreVersion or 0

	--个人社区最新消息的版本
    dst.communityMessageVersion = self.communityMessageVersion or 0

    dst.groupInfo = self.groupInfo or {}
    dst.giftPackInfos = self.giftPackInfos or {}
    dst.giftPackNewUser = self.giftPackNewUser or false

    dst.markV2Active = self.markV2Active or false
    dst.markV2TodayIsMark = self.markV2TodayIsMark or false
end

function UserManager:ladyBugInfos_getLadyBugInfoById(id, ...)
	assert(type(id) == "number")
	assert(#{...} == 0)

	for k,v in pairs(self.ladyBugInfos) do
		if v.id == id then
			return v
		end
	end

	return false
end

function UserManager:initFromLua( src , fromLocalData )
	self.appName = src.appName --ConfigManager中的App名称
	self.friendIds = src.friendIds --用户好友id列表,只在访问自己信息的时候返回

	self.inviteCode	= src.inviteCode or ""
	if _G.isLocalDevelopMode then printx(0, "inviteCode ".. tostring(src.inviteCode)) end

	debugMessage("FriendIds")
	if debugUserData then
		for i,v in ipairs(self.friendIds) do if _G.isLocalDevelopMode then printx(0, "FriendId:",v) end end
	end

	debugMessage(self.appName)
	debugMessage("UserRef")

	self.user = UserRef.new() --用户信息
	self.user:fromLua(src.user)

	self.profile = ProfileRef.new()
	self.profile:fromLua(src.profile)

	debugMessage("UserExtendRef")

	self.userExtend = UserExtendRef.new() --用户扩展信息
	self.userExtend:fromLua(src.userExtend)

	self.qqOpenID = src.qqOpenID

	debugMessage("BagRef")

	self.bag = BagRef.new() --用户背包信息
	self.bag:fromLua(src.bag)

	debugMessage("MarkRef")

	self.mark = MarkRef.new() --用户签到信息
	self.mark:fromLua(src.mark)

	debugMessage("DailyDataRef")

	self.dailyData = DailyDataRef.new() --用户每日数据
	self.dailyData:fromLua(src.dailyData)

	self.exchangeCode = src.exchangeCode

	--用户道具信息,只在访问自己信息的时候返回

	debugMessage("PropRef")

	self.props = {}
	if src.props then
		for i,v in ipairs(src.props) do
			local p = PropRef.new()
			p:fromLua(v)
			self.props[i] = p
		end
	end

	-- 限时道具
	self:timePropsFromServer(src.timeProps)
		
	--用户功能信息,只在访问自己信息的时候返回

	debugMessage("FuncRef")

	self.funcs = {}
	if src.funcs then
		for i,v in ipairs(src.funcs) do
			local p = FuncRef.new()
			p:fromLua(v)
			self.funcs[i] = p
		end
	end
	
	--用户装扮信息,只在访问自己信息的时候返回

	debugMessage("DecoRef")

	self.decos = {}
	if src.decos then
		for i,v in ipairs(src.decos) do
			local p = DecoRef.new()
			p:fromLua(v)
			self.decos[i] = p
		end
	end	

	--用户关卡得分和星级信息

	debugMessage("ScoreRef")

	if fromLocalData then
		self.scores = {}
	end

	if src.scores then
		self.scores = {}
		for i,v in ipairs(src.scores) do
			local p = ScoreRef.new()
			p:fromLua(v)
			self.scores[i] = p
		end
	end

	--用户跳关信息
	debugMessage("jumpedLevelInfos")
	self.jumpedLevelInfos = {}
	if src.jumpedLevelInfos then
		for i,v in ipairs(src.jumpedLevelInfos) do
			local p = JumpLevelRef.new()
			p:fromLua(v)
			self.jumpedLevelInfos[i] = p
		end
	end

	-- 代打信息
	self.subsSuccessLevelIds = {}
	self.subsSuccessLevelIds = cloneMetaTableArray(src.subsSuccessLevelIds or {})
	self.successRecords = {}
	self.successRecords = cloneClassTableArray(src.successRecords or {}, HelpedInfoRef)
	self.subsTotalBeHelpedCount = src.subsTotalBeHelpedCount or 0

	----------- 暂时只针对应用宝平台，重新计算客户端支持的星星数 ----------
	if PlatformConfig:isQQPlatform() then
		local userStars = 0
		local areaMaxLevel = self:getMaxLevelInOpenedRegion()
		for k, v in pairs(self.scores) do 
			if tonumber(v.levelId) <= areaMaxLevel then
				userStars = userStars + tonumber(v.star)
			end
		end
		self.user:setStar(userStars)

		local userHiddenStars = 0
	end
	-------------------- END ----------------------------------------------


	--用户成就相关数据

	debugMessage("AchiRef")

	self.achis = {}
	if src.achis then
		for i,v in ipairs(src.achis) do
			local p = AchiRef.new()
			p:fromLua(v)
			self.achis[i] = p
		end
	end
	
	--请求信息（免费礼物信息除外）

	debugMessage("RequestInfoRef")

	local inviteProfilesMap = {}
	local inviteProfiles = src.inviteProfiles
	if inviteProfiles and #inviteProfiles > 0 then
		for i,v in ipairs(inviteProfiles) do inviteProfilesMap[v.uid] = v end
	end

	self.requestInfos = {}
	if src.requestInfos then
		for i,v in ipairs(src.requestInfos) do
			local p = RequestInfoRef.new()
			p:fromLua(v)
			local profile = inviteProfilesMap[p.senderUid]
			if profile then
				p.name = profile.name or ""
				p.headUrl = profile.headUrl
			end
			self.requestInfos[i] = p
		end
	end

	self.requestNum = src.requestNum or 0
	
	--已同意请求的 关卡好友信息

	debugMessage("UnLockFriendInfoRef")
	self.unLockFriendInfos = {}
	if src.unLockFriendInfos then
		for i,v in ipairs(src.unLockFriendInfos) do
			local p = UnLockFriendInfoRef.new()
			p:fromLua(v)
			self.unLockFriendInfos[i] = p
		end
	end

	self.npcNumber = src.npcNumber or 0
	self.areaId = src.areaId or 0
	self.countdownAreaId = tonumber(src.countdownAreaId) or -1
	self.countdownUnlockTime = tonumber(src.countdownUnlockTime) or -1

	self.usedSnsSource = {}
	if src.usedSnsSource then
		for i,v in ipairs(src.usedSnsSource) do
			self.usedSnsSource[v] = true
		end
	end
	

	--具体的各个子任务信息

	debugMessage("LadyBugInfoRef")

	self.ladyBugInfos = {}
	if src.ladyBugInfos then
		for i,v in ipairs(src.ladyBugInfos) do
			local p = LadyBugInfoRef.new()
			p:fromLua(v)
			self.ladyBugInfos[i] = p
		end
	end
	
	-- 更新信息
	self.updateInfo = src.updateInfo
	self.updateReward = src.updateReward
	self.updateRewards = src.updateRewards
	self.preRewards = src.preRewards
	if (self.updateInfo) then
		self.preRewardsFlag = self.updateInfo.preRewardsFlag
	end
	self.smsDayRmb = src.smsDayRmb
	self.smsMonthRmb = src.smsMonthRmb

	self.sjRewards = src.sjRewards

	self.compens = src.compens
	self.compenText = src.compenText
	self.compenList = src.compenList
	
	-- 
	self.actInfos = src.actInfos

	self.weekMatch = src.weekMatch

	self.payGiftInfo = src.payGiftInfo

	self.lastCheckTime = src.lastCheckTime

	self.userReward = src.userReward
	self.rabbitWeekly = src.rabbitWeekly
	--用户流失类型 RecallRewardType之一
	self.lostType = src.lostType
	-- 用户类型,做白名单判断,普通用户=0
	self.userType = src.userType or 0
	-- 存储在后端的设置 目前用于获取用户支付类型
	self.setting = src.setting or 0
	-- android dime middle energy
	self.dimePlat = src.dimePlat
	if type(self.dimePlat) == "table" then
		for k, v in ipairs(self.dimePlat) do
			self.dimePlat[k] = string.gsub(v, '\"', '')
		end
	else self.dimePlat = {} end
	self.dimeProvince = src.dimeProvince
	if type(self.dimeProvince) == "table" then
		for k, v in ipairs(self.dimeProvince) do
			self.dimeProvince[k] = string.gsub(v, '\"', '')
		end
	else self.dimeProvince = {} end

	self.iosSettingUrl = src.iosSettingUrl

	CDKeyManager:getInstance():initData(
		src.contact, 
		src.actualExchangeCodes,
		src.physicalRewards or {}
	)
	
	self.achievement = AchievementRef.new()
	self.achievement:fromLua(src.achievement)

	self.newLadyBugInfo = NewLadyBugInfoRef.new()
	self.newLadyBugInfo:fromLua(src.newLadyBugInfo)

	-- 
	self.ingameLimit = src.ingameLimit

	self.acceptedEnergy = src.acceptedEnergy

	if src.cmgameOfflinePayLimit then
		self.cmgameOfflinePayLimit = src.cmgameOfflinePayLimit
	end
	if src.global and type(src.global) == "table" then
		self.global = src.global
		if self.global.cmgameOfflinePayLimit then
			self.cmgameOfflinePayLimit = src.global.cmgameOfflinePayLimit
		end
	end
	
	-- 六一彩蛋已经点击id
	self.uiHasClickedEasterEggList = src.uiHasClickedEasterEggList or {}
	--前一次登录时间 ms
	if src.lastLoginTime ~= nil then
		self.lastLoginTime = tonumber(src.lastLoginTime)
	end

	local currentTime = Localhost:timeInSec()
	-- 积分墙Quota[时间戳，日领取，日限额，月领取，月限额]
	self.yybAdWallLimit = src.yybAdWallLimit or {currentTime, 0, 100, 0, 300}
	self.realNameAuthSwitchStatus = src.realNameAuthSwitchStatus--实名制后端开关
	self.realNameAuthed = src.realNameAuthed--是否已经手机号认证
	self.realNameIdCardAuthed = src.realNameIdCardAuthed--是否已经身份证认证
	self.realNameStatus = src.realNameStatus or 0 

	self.continueLoginDays = src.continueLoginDays
	if src.askEnergyReceivedNum ~= nil then
		local giftNum = tonumber(src.askEnergyReceivedNum)
		if giftNum > 0 then
			require "zoo.panel.broadcast.GetShareFreeGiftPanel"
			GetShareFreeGiftPanel:setPreGameGiftNum(giftNum)
		end
	end
	if not fromLocalData then
		UserTagManager:updateTagsByResp( src , UserTagDCSource.kLaunch )
	end

	self.baFlags = {}
	if type(src.flags) == "string" then
		self.baFlags = self:decodeBAFlags(src.flags)
	elseif type(src.baFlags) == "table" then
		for k, v in pairs(src.baFlags) do
			self.baFlags[tonumber(k)] = v
		end
	end

	self.guideFlags = {}
	if type(src.guideFlags) == "string" then
		self.guideFlags = self:decodeBAFlags(src.guideFlags)
	elseif type(src.guideFlags) == "table" then
		for k, v in pairs(src.guideFlags) do
			self.guideFlags[tonumber(k)] = v
		end
	end

	self.propGuideInfo = PropGuideInfoRef.new()
	self.propGuideInfo:fromLua(src.propGuideInfo)


	if _G.__IOS and src.guideReview and src.guideReview ~= "" and src.guideReview ~= "nil" then
		local guideReviewRef = IOSScoreGuideDataRef.new()
		guideReviewRef:fromServer(src.guideReview)
		Localhost.getInstance():writeIOSScoreReviewData(guideReviewRef:encode())
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new("ios.guidereview.update"))
	end

	self.notificationReminder = {}
	self.notificationReminder = cloneClassTableArray(src.notificationReminder or {}, NotifiItemRef)

	self.add5LotteryInfo = src.add5LotteryInfo or '{}'
	self.startTimeUserCallback = src.startTimeUserCallback or 0

	self.onlineStartAreaIds = src.onlineStartAreaIds or {}

	self.playTimes = src.playTimes or 0

	self:setAreaTaskInfo(src.areaTaskInfo or {})

	self.questSystemInfo = QuestRecordRef.new()


	self.questSystemInfo:fromLua(src.questSystemInfo)
	QuestManager:getInstance():readFromUserData()

    self.endTimeOfBindPhoneIcon  = src.endTimeOfBindPhoneIcon  or 0

    if not fromLocalData then
    	self.currentLoginTime=Localhost:time()
    end

    self.fullStarRecords = cloneClassTableArray(src.fullStarRecords or {}, FullStarRankHistoryRef)
    self.lastRoundFullLevel = src.lastRoundFullLevel or false
    self.curRoundFullStar = src.curRoundFullStar or 0x7FFFFFFF
    self.maxLevel = src.maxLevel or 0
    self.fullLevelGifts = src.fullLevelGifts or '{}'
    
    self.recallNotificationRewards = src.recallNotificationRewards

    self.active30Days = src.active30Days or 0

    self.videoSDKInfo = src.videoSDKInfo
    self.userCallbackActInfo = src.userCallbackActInfo or {}

    self.scoreVersion = src.scoreVersion or 0

	--个人社区最新消息的版本
    self.communityMessageVersion = src.communityMessageVersion or 0

    self.splashAd = src.splashAd
    self.preBuff = src.preBuff 
    if fromLocalData then
    	GameLauncherContext:getInstance():onInitUserDataByLocal()
    else
    	GameLauncherContext:getInstance():onInitUserDataByServer()
    end

    self.groupInfo = src.groupInfo or {}
    self.giftPackInfos = src.giftPackInfos or {}
    self.giftPackNewUser = src.giftPackNewUser or false

    self.markV2Active = src.markV2Active or false
    self.markV2TodayIsMark = src.markV2TodayIsMark or false

    GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kUserDataInit))
end

function UserManager:updateCommunityMessageVersion()
	if not self:isNewCommunityMessageVersion() then
		return
	end
	CCUserDefault:sharedUserDefault():setIntegerForKey("lastCommunityMessageVersion", self.communityMessageVersion)
	CCUserDefault:sharedUserDefault():flush()

	local scene = HomeScene:sharedInstance()
	local _ = scene and scene:updateFriendButton()
end

function UserManager:isNewCommunityMessageVersion()
	local version = CCUserDefault:sharedUserDefault():getIntegerForKey("lastCommunityMessageVersion", 0)
	return self.communityMessageVersion>version
end

function UserManager:incrPlayTimes()
	self.playTimes = self.playTimes + 1
end

function UserManager:updateUserLocation(datas, source)
	-- 如果位置来源是ip,那么满足以下条件才更新位置：
	-- 1. 没有旧的位置信息
	-- 2. 原来位置信息来源也是ip
	if source ~= "ip" or (not self.userLocationData) or self.userLocationData.source == "ip" then
		if datas and (datas.country or datas.province or datas.city) then -- 确保传入的是有效的数据
			datas.source = source
			datas.updateTime = Localhost:timeInSec()
			self.userLocationData = datas
		end
	end
end

function UserManager:getUserLocation()
	return self.userLocationData
end

function UserManager:decodeBAFlags(str)
	-- str是一个64位字符串，每一位是一个16进制字符
	-- str平均分成4分，每一份16位16进制数字代表一个64位二进制数字
	-- 所以str一共可以表示256个flag bit
	local flags = {}
	for i = 1, 4 do
		local s = string.sub(str, (i-1)*16+1, i*16)
		for idx = 1, 16 do
			local c = string.sub(s, idx, idx)
			local n = tonumber(c, 16)
			for j = 0, 3 do
				if n < 1 then break end
				if n % 2 == 1 then flags[64 * i - 4 * idx + j] = true end
				n = math.floor(n / 2)
			end
		end
	end
	return flags
end

function UserManager:setRequestInfos( requestInfos )
	if requestInfos then
		self.requestInfos = {}
		for i,v in ipairs(requestInfos) do
			local p = RequestInfoRef.new()
			p:fromLua(v)
			self.requestInfos[i] = p
		end
	end
end

function UserManager:getActivationTag()
	return self.activationTag
end

function UserManager:getActivationTagTopLevelId()
	return self.activationTagTopLevelId
end

function UserManager:getActivationTagEndTime()
	return self.activationTagEndTime
end

--since ver1.47
function UserManager:setBAFlag(flagIndex)
	self.baFlags[flagIndex] = true
end

--since ver1.50
function UserManager:clearBAFlag(flagIndex)
	self.baFlags[flagIndex] = false
end

function UserManager:hasBAFlag(flagIndex)
	return self.baFlags and self.baFlags[flagIndex] or false
end

--since ver1.53
function UserManager:setGuideFlag(flagIndex)
	self.guideFlags[flagIndex] = true
end
function UserManager:clearGuideFlag(flagIndex)
	self.guideFlags[flagIndex] = false
end
function UserManager:hasGuideFlag(flagIndex)
	return self.guideFlags and self.guideFlags[flagIndex] or false
end

function UserManager:getOffLoginDayNum()
	local gapDay = 0
	if self.lastLoginTime ~= nil then
		local gapDayInSec = Localhost:getDayStartTimeByTS(Localhost:timeInSec()) - Localhost:getDayStartTimeByTS(self.lastLoginTime/1000)
		gapDay = math.floor((gapDayInSec + 5000) / 86400) -1
	end
	if gapDay < 0 then gapDay = 0 end
	return gapDay
end

function UserManager:canUnlockAreaByTime(unlockAreaId)
	if tonumber(unlockAreaId) == self.countdownAreaId then
	   if self.countdownUnlockTime <= Localhost:time() then--倒计时可以免费解锁
			return true
	   else
	   		return false, math.ceil((self.countdownUnlockTime - Localhost:time())/1000)
	   end
	end

	if self.countdownAreaId == -1 then --user 失败 读取前端存的数据
		local areaUnlockTime = Localhost:readDataByFileNameAndKey(AreaUnlockPanel.LOCAL_DATA_FILE, "area_" .. unlockAreaId .. "_unlock_time", 0)
		if areaUnlockTime > 0 then
			if areaUnlockTime <= Localhost:timeInSec() then
				return true
			else
				return false, Localhost:timeInSec() - areaUnlockTime
			end
		end
	end
	return false
end

function UserManager:getUnlockFriendUidsWithNPC( areaId )
	local unLockFriendInfos = UserManager:getInstance().unLockFriendInfos
	local friendList = {}
	-- Get Current Area 's Friend Ids

	for k,v in pairs(unLockFriendInfos) do
		if tonumber(v.id) == tonumber(areaId) then

			for i = 1 , #v.friendUids do
				table.insert( friendList , v.friendUids[i] )
			end

			break
		end
	end
	
	if tonumber( UserManager:getInstance().areaId ) == tonumber(areaId) then
		local npcNum = UserManager:getInstance().npcNumber
		if npcNum > 0 then
			for i = 1 , npcNum do
				table.insert( friendList , -1 )
			end
		end
	end

	return friendList
end

function UserManager:getUnlockNPCFriendNumber( areaId )
	if tonumber( UserManager:getInstance().areaId ) == areaId then
		local npcNum = UserManager:getInstance().npcNumber
		if not npcNum then
			npcNum = 0
		end
		return npcNum
	end
	return 0
end


function UserManager:syncUserData( src )
	if src then
		if _G.isLocalDevelopMode then printx(0, "sync user data.", self.user.energy, src.energy) end
		self.user:setCoin(src.coin)
		self.user.point = src.point
		self.user:setStar(src.star)
		self.user:setHideStar(src.hideStar)
		self.user:setEnergy(src.energy)
		self.user:setTopLevelId(src.topLevelId)
		if _G.isLocalDevelopMode then printx(0, "initFromLua sync:"..tostring(self.user:getTopLevelId()).."/"..tostring(#self.scores)) end
	end
end

function UserManager:isNewLevelAreaStart( levelId )
	return MetaManager.getInstance():isMinLevelAreaId(levelId)  
end

function UserManager:updateUserData( src )
	if not src then return end
	for i,v in ipairs(self.props) do v:dispose() end

	self.user:fromLua(src.user)

	self.achievement:fromLua(src.achievement)
	
	if src.achievementValue then
		self.userExtend:updateAchievementValue( src.achievementValue )
	end

	self.scores = {}
	if src.scores then
		for i,v in ipairs(src.scores) do
			local p = ScoreRef.new()
			p:fromLua(v)
			self.scores[i] = p
		end
	end

	self.jumpedLevelInfos = {}
	if src.jumpedLevelInfos then
		for i,v in ipairs(src.jumpedLevelInfos) do 
			local p = JumpLevelRef.new()
			p:fromLua(v)
			self.jumpedLevelInfos[i] = p
		end
	end

	-- 好友代打
	self.subsSuccessLevelIds = {}
	self.subsSuccessLevelIds = cloneMetaTableArray(src.subsSuccessLevelIds or {})
	self.successRecords = {}
	self.successRecords = cloneClassTableArray(src.successRecords or {}, HelpedInfoRef)
	self.subsTotalBeHelpedCount = src.subsTotalBeHelpedCount or 0

	self.props = {}
	if src.props then
		for i,v in ipairs(src.props) do
			local p = PropRef.new()
			p:fromLua(v)
			self.props[i] = p
		end
	end

	if src.requestInfos then
		self.requestInfos = {}
		for i,v in ipairs(src.requestInfos) do
			local p = RequestInfoRef.new()
			p:fromLua(v)
			self.requestInfos[i] = p
		end
	end

	if src.requestNum then
		self.requestNum = src.requestNum
	end

	self.notificationReminder = {}
	self.notificationReminder = cloneClassTableArray(src.notificationReminder or {}, NotifiItemRef)

	Notify:dispatch("StarBankEventSyncData", src.starJarV2)
	Notify:dispatch("AchiEventUserDataUpdate")

	if src.questSystemInfo then
		self.questSystemInfo:fromLua(src.questSystemInfo)
		QuestManager:getInstance():readFromUserData()
	end
end

function UserManager:getUserRef(...)
	assert(#{...} == 0)

	return self.user
end

function UserManager:getUID()
	if self.user ~= nil and self.user.uid ~= nil then return self.user.uid end
	return '12345'
end

function UserManager:getInviteCode()
	return self.inviteCode or '12345'
end

function UserManager:getPropRef(...)
	assert(#{...} == 0)

	return self.props
end

function UserManager:removeRequestInfo( infoId )
	local index = -1
	for i,v in ipairs(self.requestInfos) do
		if v.id == infoId then index = i end
	end
  	if index ~= -1 then table.remove(self.requestInfos, index) end
end

function UserManager:removeRequestInfoByTypes(types)
	for j=1, #types do
		for i=#self.requestInfos, 1, -1 do
			if self.requestInfos[i].type == types[j] then
				table.remove(self.requestInfos, i)
				UserManager.getInstance().requestNum = UserManager.getInstance().requestNum - 1
			end
		end
	end
end

--------------------------------------
-----	Function About User Score
-------------------------------------

function UserManager:getScoreRef(...)
	assert(#{...} == 0)
	return self.scores
end

function UserManager:getUserScore( levelId )
	for i,v in ipairs(self.scores) do
		if v.levelId == levelId then return v end
	end
	return nil
end


function UserManager:addUserScore( userscore )
	if self:getUserScore(userscore.levelId) == nil then
		table.insert(self.scores, userscore)
	else
		assert(false)
	end
end

function UserManager:removeUserScore(levelId, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	for i,v in ipairs(self.scores) do

		if v.levelId == levelId then
			table.remove(self.scores, i)
			return
		end
	end

	assert(false)
end

function UserManager:hasPassedLevel(levelId)
	local score = self:getUserScore(levelId)
	return score and score.star > 0
end

function UserManager:hasPassedByTrick(levelId)
	local ref = self:getUserJumpLevelRef(levelId)
	if ref and ref.pawnNum > 0 then
		return true
	end

	if self:hasAskForHelpInfo(levelId) then
		return true
	end
	return false
end

function UserManager:hasPassedLevelEx(levelId)
	if self:hasPassedLevel(levelId) or
		self:hasPassedByTrick(levelId) then 
		return true
	end
	return false
end

function UserManager:getTopPassedLevel()
	local topPassedLevelId = self.user:getTopLevelId()
	if not UserManager:getInstance():hasPassedLevelEx(topPassedLevelId) then
		topPassedLevelId = topPassedLevelId - 1
	end
	return topPassedLevelId
end

-----------------------------------------------
--jumpedLevelInfos
-----------------------------------------------
function UserManager:getJumpLevelInfo()
	return self.jumpedLevelInfos
end

function UserManager:getUserJumpLevelRef(levelId)
	for i, v in ipairs(self.jumpedLevelInfos) do 
		if v.levelId == levelId then
			return v
		end
	end
	return nil
end

function UserManager:addJumpLevelInfo(jumpLevelRef)
	if self:getUserJumpLevelRef(jumpLevelRef.levelId) == nil then
		table.insert(self.jumpedLevelInfos, jumpLevelRef)
	else
		assert(false)
	end
end

function UserManager:removeJumpLevelRef(levelId)
	for i, v in ipairs(self.jumpedLevelInfos) do 
		if v.levelId == levelId then
			table.remove(self.jumpedLevelInfos, i)
			return 
		end
	end
end

-----------------------------------
--- Function About Ask For Help
------------------------------------
function UserManager:getAskForHelpInfo()
	return self.successRecords
end

function UserManager:addAskForHelpInfo(record)
	for k,v in pairs(self.successRecords) do
		if record.levelId == (v.levelId or 1)  then return end
	end
	
	local v = HelpedInfoRef.new()
	v:fromLua(record)
	table.insert(self.successRecords, v)
end

function UserManager:removeAskForHelpInfo(levelId)
	for k,v in pairs(self.successRecords) do
		if levelId == (v.levelId or 1) then
			self.successRecords[k] = nil
			return 
		end
	end
	return
end

function UserManager:hasAskForHelpInfo(levelId)
	for k,v in pairs(self.successRecords) do
		if levelId == (v.levelId or 1)  then return true end
	end
	return false
end

-----------------------------------
--- Function About Old User Score
------------------------------------

function UserManager:getOldUserScore(levelId, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	for i,v in ipairs(self.oldScores) do

		if v.levelId == levelId then 
			return v
		end
	end

	return nil
end

function UserManager:addOldUserScore(oldUserScore, ...)
	assert(type(oldUserScore) == "table")
	assert(#{...} == 0)

	if self:getOldUserScore(oldUserScore.levelId) == nil then
		table.insert(self.oldScores, oldUserScore)
	else
		assert(false)
	end
end

function UserManager:removeOldUserScore(levelId, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	for i,v in ipairs(self.oldScores) do
		if v.levelId == levelId then
			table.remove(self.oldScores, i)
			return
		end
	end

	--assert(false)
end

function UserManager:addUserProp( prop )
	if self:getUserProp(prop.itemId) == nil then
		table.insert(self.props, prop)
	end
end
function UserManager:getUserProp(itemId, ...)
	assert(type(itemId) == "number")
	assert(#{...} == 0)

	for i,v in ipairs(self.props) do
		if v.itemId == itemId then 
			return v 
		end
	end
	return nil
end

function UserManager:setUserPropNumber(itemId, newNumber, ...)
	assert(type(itemId) == "number")
	assert(type(newNumber) == "number")
	assert(newNumber >= 0)
	assert(#{...} == 0)
	for i,v in ipairs(self.props) do
		if v.itemId == itemId then 
			v:setNum(newNumber)
			return
		end
	end
	--assert(false)

	-- Not Record This Prop Before
	-- Add A New Prop Record
	local newProp = PropRef.new()
	newProp.itemId	= itemId
	newProp:setNum(newNumber)

	self:addUserProp(newProp)
end

-- -- bye bye ! since ver1.62
-- function UserManager:addRewardsWithDc(rewards, dcParams)
-- end

function UserManager:addCoin(addCoinNum, updateButton)
	self.user:setCoin(self.user:getCoin() + addCoinNum)
    if updateButton and HomeScene:sharedInstance().coinButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().coinButton:updateView()
    end
end

function UserManager:addCash(addCashNum, updateButton)
	self.user:setCash(self.user:getCash() + addCashNum)
    if updateButton and HomeScene:sharedInstance().goldButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().goldButton:updateView()
    end
end

function UserManager:addEnergy(addEnergyNum, updateButton)
	local _, _, maxEnergy = self:refreshEnergy()
	local energy = self.user:getEnergy() + addEnergyNum
	if energy > maxEnergy then energy = maxEnergy end
	self.user:setEnergy(energy)
	if updateButton and HomeScene:sharedInstance().energyButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().energyButton:updateView()
    end
end

--since ver1.62
function UserManager:addReward(reward, updateButton)
	if reward.itemId == ItemType.COIN then
		self:addCoin(reward.num, updateButton)
	elseif reward.itemId == ItemType.GOLD then
		self:addCash(reward.num, updateButton)
	elseif reward.itemId == ItemType.ENERGY_LIGHTNING then
		self:addEnergy(reward.num, updateButton)
	elseif ItemType:isItemNeedToBeAdd(reward.itemId) then 
		self:addUserPropNumber(reward.itemId, reward.num)
	end
end

-- since ver1.25
function UserManager:addRewards(rewards, updateButton)
	if type(rewards) == "table" then
		for _, v in pairs(rewards) do
			self:addReward(v, updateButton)
		end
	end
end

function UserManager:getUserPropNumber(itemId, ...)
	assert(type(itemId) == "number")
	assert(#{...} == 0)
	if ItemType:isTimeProp(itemId) then
		return self:getUserTimePropNumber(itemId)
	end
	local userProp = self:getUserProp(itemId)
	if userProp then return userProp:getNum() end
	return 0
end
--根据 RealItemID 得到有用的限时道具的数量
function UserManager:getAllTimePropNumberWithRealItemID( realItemID )
	local timePropIdList = ItemType:getTimePropItemListByRealId( realItemID )
	local timePropNum = 0
	for i=1,#timePropIdList do
		local propIdNode = timePropIdList[i]
		timePropNum = timePropNum + self:getUserTimePropNumber( propIdNode )
	end
	if _G.isLocalDevelopMode then printx(100, 'UserManager getAllTimePropNumberWithRealItemID  timePropNum = ' ,timePropNum ) end
	return timePropNum
	
end

-- 传进来的是 realItemID 或者 propid 都视为 realItemID 过去所有的道具总数
function UserManager:getUserPropNumberWithAllType(itemId, ...)

	local realItemId = ItemType:getRealIdByTimePropId( itemId )
	local timePropNum = self:getAllTimePropNumberWithRealItemID( realItemId )
	local propNum = 0
	local userProp = self:getUserProp(realItemId)
	if userProp then 
		propNum = userProp:getNum() 
	end
	return propNum + timePropNum

end

function UserManager:addUserPropNumber(itemId, deltaNumber, isFromService, ...)
	assert(itemId)
	assert(type(itemId) == "number")
	assert(deltaNumber)
	assert(type(deltaNumber) == "number")
	assert(#{...} == 0)
	if not isFromService then
		if itemId == ItemType.SMALL_ENERGY_BOTTLE then
			Notify:dispatch("AchiEventDataUpdate",AchiDataType.kGetPrimaryEnergyAddCount, deltaNumber)
		end
	end

	if ItemType:isTimeProp(itemId) then
		self:addTimeProp(itemId, deltaNumber)
	else
		local curNumber = self:getUserPropNumber(itemId)
		assert(curNumber)
		local newNumber = curNumber + deltaNumber
		if newNumber < 0 then newNumber = 0 end
		self:setUserPropNumber(itemId, newNumber)
	end
end


-- 启动时，给已经过期的道具打点
function UserManager:sendOfflineExpiredPropDC()
	if self.expirePropDCSent == true then return end
	self.expirePropDCSent = true
	if UserManager:getInstance().uid then
		local cachedLocalUserData = Localhost.getInstance():readCurrentUserData()
		if cachedLocalUserData and cachedLocalUserData.user and cachedLocalUserData.user.timeProps then
			local timeProps = cachedLocalUserData.user.timeProps
			local curTimeInSec = Localhost:timeInSec()
			for k, v in pairs(timeProps) do			
				local expireTime = math.floor(v.expireTime / 1000)
				if expireTime <= curTimeInSec and v.num > 0 then
					DcUtil:UserTrack({category = 'item_overdue', sub_category = 'item_overdue', t1 = v.itemId, t2 = v.num, ts = expireTime}, true)
				end
			end
		end
	end
end

function UserManager:timePropsFromServer(timeProps)
	self:sendOfflineExpiredPropDC()
	self.timeProps = {}

	if not timeProps then  return end

	for i, v in ipairs(timeProps) do
		local p = TimePropRef.new()
		p:fromLua(v)
		local newProp = true
		--wiki 24284019 前置道具优化 不再合并
		-- 合并同一种且过期时间相同的限时道具数量  
		-- for _, prop in pairs(self.timeProps) do
		-- 	if prop.itemId == p.itemId and prop.expireTime == p.expireTime then
		-- 		prop.num = prop.num + p.num
		-- 		newProp = false
		-- 	end
		-- end
		if newProp then
			table.insert(self.timeProps, p)
		end
	end

	self:sortTimeProps()
end

-- 刷新时，过期的道具打点
function UserManager:getAndUpdateTimeProps()
	-- if _G.isLocalDevelopMode then printx(0, "getAndUpdateTimeProps:", table.tostring(self.timeProps)) end
	local timeProps = {}
	if #self.timeProps > 0 then
		local curTimeInSec = Localhost:timeInSec()
		for k,v in pairs(self.timeProps) do
			-- 转为s计算更准确
			local expireTime = math.floor(v.expireTime / 1000)
			if expireTime > curTimeInSec and v.num > 0 then
				table.insert(timeProps, v)
			else
				DcUtil:UserTrack({category = 'item_overdue', sub_category = 'item_overdue', t1 = v.itemId, t2 = v.num, ts = expireTime}, true)
			end
		end
	end
	self.timeProps = timeProps

	self:sortTimeProps()
	return self.timeProps
end

-- 将限时道具按过期时间从小到大排列,方便显示和扣除
function UserManager:sortTimeProps()
	table.sort( self.timeProps, function( a, b )
		return a.expireTime < b.expireTime
	end )
end
--根据 realItemId 得到 道具的实例
function UserManager:getTimePropsByRealItemId(realItemId)
	local ret = {}

	for i,v in ipairs(self.timeProps) do
		if v.num > 0 and ItemType:getRealIdByTimePropId(v.itemId) == realItemId then
			local p = TimePropRef.new()
			p:fromLua(v)
			table.insert(ret, p)
		end
	end
	return ret
end

function UserManager:addTimeProp(itemId, num, expireTime)
	local propMeta = MetaManager:getInstance():getPropMeta(itemId)
	if not propMeta or not propMeta.expireTime then
		return
	end

	local function doAddProp()
		local p = TimePropRef.new()
		p.itemId = itemId
		p.num = 1
		if expireTime then
			p.expireTime = expireTime
		else
			p.expireTime = Localhost:time() + propMeta.expireTime
		end
		table.insert(self.timeProps, p)
	end

	if num>0 then
		for i=1,num do
			doAddProp()
		end
	end
	self:sortTimeProps()
end

function UserManager:getUserTimePropNumber(itemId)
	local num = 0
	for _,v in pairs(self.timeProps) do
		if v.itemId == itemId then
			num = num + v.num
		end
	end
	return num
end

function UserManager:useTimeProp(itemId)
	-- if _G.isLocalDevelopMode then printx(0, "UserManager:useTimeProp:", itemId) end
	if self:getUserTimePropNumber(itemId) < 1 then return false end

	--用最快过期的道具
	local minExpireTimeProp = nil 
	for i,v in ipairs(self.timeProps) do
		if itemId == v.itemId and v.num > 0 then
			if not minExpireTimeProp then 
				minExpireTimeProp = v
			else
				if minExpireTimeProp.expireTime > v.expireTime then 
					minExpireTimeProp = v
				end
			end
		end
	end

	if minExpireTimeProp then 
		minExpireTimeProp.num = minExpireTimeProp.num - 1
		return true, minExpireTimeProp.expireTime
	end

	return false
end

function UserManager:addUserDeco( deco )
	if self:getUserDeco(deco.itemId) == nil then
		table.insert(self.decos, deco)
	end
end
function UserManager:getUserDeco( itemId )
	for i,v in ipairs(self.decos) do
		if v.itemId == itemId then return v end
	end
	return nil
end

function UserManager:addUserFunc( func )
	if self:getUserFunc(func.itemId) == nil then
		table.insert(self.funcs, func)
	end
end
function UserManager:getUserFunc( itemId )
	for i,v in ipairs(self.funcs) do
		if v.itemId == itemId then return v end
	end
	return nil
end

function UserManager:refreshEnergy()
	local user = UserManager.getInstance().user
	local now = Localhost:time()
	local maxEnergy = (MetaManager.getInstance().global.user_energy_max_count or 30) + Achievement:getRightsExtra( "EnergyRecoveryUpperLimit" )
	local userExtend = UserManager.getInstance().userExtend
	local energyPlusEffectTime = userExtend:getEnergyPlusEffectTime()
	local notUsedTime = 0
	local isRefresh = false

	if energyPlusEffectTime > now then
		local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusId)
		if propMeta then
			maxEnergy = maxEnergy + propMeta.confidence
		end
	elseif userExtend.energyPlusPermanentId > 0 then
		local propMeta = MetaManager.getInstance():getPropMeta(userExtend.energyPlusPermanentId)
		if propMeta then
			maxEnergy = maxEnergy + propMeta.confidence
		end
	end
	
	if FcmManager:getTimeScale() > 1 and FcmManager:getLeftTime() <= 0 then
		FcmManager:reset()
	end

	if user:getEnergy() < maxEnergy then
		local timePast = now - user:getUpdateTime()
		local user_energy_recover_time_unit = MetaManager.getInstance().global.user_energy_recover_time_unit or 480000
		user_energy_recover_time_unit = user_energy_recover_time_unit * FcmManager:getTimeScale()
		local energyInc = math.floor(timePast / user_energy_recover_time_unit)

		if energyInc >= 1 then
			if user:getEnergy() + energyInc >= maxEnergy then
				user:setEnergy(maxEnergy)
				user:setUpdateTime(now)
			else
				user:setEnergy(user:getEnergy() + energyInc)
				notUsedTime = timePast % user_energy_recover_time_unit
				user:setUpdateTime(now - notUsedTime)

				notUsedTime = user_energy_recover_time_unit - notUsedTime
			end
			isRefresh = true
		else
			--user:setUpdateTime(now)
			notUsedTime = user_energy_recover_time_unit - timePast
		end
		user.isFull = false
	else
		-- user:getEnergy() >= maxEnergy
		user:setUpdateTime(now)
		user.isFull = true
	end

	local isInfiniteEnergy = false

	if UserEnergyRecoverManager:sharedInstance().energyState then
		if UserEnergyRecoverManager:sharedInstance():getEnergyState() == UserEnergyState.INFINITE then
			isInfiniteEnergy = true
		end
	end
	
	return math.floor(notUsedTime / 1000), isRefresh, maxEnergy , isInfiniteEnergy
end

function UserManager:getCMGameOfflinePayLimit()
	return tonumber(self.cmgameOfflinePayLimit) or 9999
end

function UserManager:isAliNeverSigned()
	return self.userExtend.aliIngameState == 0
end

function UserManager:isAliSigned()
	return self.userExtend.aliIngameState == 1
end

function UserManager:isAliUnSigned()
	return self.userExtend.aliIngameState == 2
end

function UserManager:getAliSignState() 
	return self.userExtend.aliIngameState
end

function UserManager:isWechatNeverSigned()
	return self.userExtend.wxIngameState == 0
end

function UserManager:isWechatSigned()
	return self.userExtend.wxIngameState == 1 
end

function UserManager:isWechatUnSigned()
	return self.userExtend.wxIngameState == 2
end

function UserManager:getAliKfMonthlyLimit()
	self:checkDateChange()
	return self.userExtend.aliMonthRmb or 0
end

function UserManager:setAliKfMonthlyLimit(value)
	self.userExtend.aliMonthRmb = value
end

function UserManager:getAliKfDailyLimit()
	self:checkDateChange()
	return self.userExtend.aliDailyRmb or 0
end

function UserManager:setAliKfDailyLimit(value)
	self.userExtend.aliDailyRmb = value
end

function UserManager:getTestInfo()
	return self.userExtend.testInfo
end

function UserManager:getDailyBoughtGoodsNumById(goodsId)
	return self:getDailyData():getBuyedGoodsById(goodsId)
end

function UserManager:addBuyedGoods(goodsId, num)
	self:getDailyData():addBuyedGoods(goodsId, num)
end

function UserManager:getDailyBuyedGoodsNumByLevel(levelId, goodsId)
	return self:getDailyData():getBuyedGoodsByLevel(levelId, goodsId)
end

function UserManager:setDailyBuyedGoodsByLevel(levelId, goodsId, num)
	self:getDailyData():setBuyedGoodsByLevel(levelId, goodsId, num)
end

function UserManager:addBagBuyCountByOne()
	if self.bag.buyCount < 4 then
		self.bag.buyCount = self.bag.buyCount + 1
	end
end

function UserManager:getBagRef()
	return self.bag
end

function UserManager:getWantIds()
	local res = self:getDailyData():getWantIds()
	if type(res) ~= "table" then res = {} end

	--要去掉首次索要精力时触发的一个功能
	--所以首次索要时，插入一个假uid
	if #res <= 0 then
		table.insert(res, 0)
	end

	return res
end

function UserManager:addWantIds(ids)
	self:getDailyData():addWantIds(ids)
end

function UserManager:sendGiftCount()
	return self:getDailyData():getSendGiftCount()
end

function UserManager:incSendGiftCount()
	self:getDailyData():incSendGiftCount()
end

function UserManager:receiveGiftCount()
	return self:getDailyData():getReceiveGiftCount()
end

function UserManager:incReceiveGiftCount()
	return self:getDailyData():incReceiveGiftCount()
end

function UserManager:decReceiveGiftCount()
	return self:getDailyData():decReceiveGiftCount()
end

function UserManager:getSendIds()
	return self:getDailyData():getSendIds()
end

function UserManager:addSendId(sendId)
	self:getDailyData():addSendId(sendId)
end

function UserManager:removeSendId(sendId)
	self:getDailyData():removeSendId(sendId)
end

function UserManager:getUserExtendRef()
	return self.userExtend
end

function UserManager:isUserRewardBitSet(bitIndex)
	self.userReward = self.userReward or {}
	self.userReward.rewardFlag = self.userReward.rewardFlag or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex) -- e.g.: mask: 0010

	local bit = require("bit")
	return mask == bit.band(self.userReward.rewardFlag, mask) -- e.g.:1111 & 0010 = 0010
end

function UserManager:setUserRewardBit(bitIndex, setToTrue)
	self.userReward = self.userReward or {}
	self.userReward.rewardFlag = self.userReward.rewardFlag or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex) -- e.g.: maks: 0010
	local bit = require("bit")
	if setToTrue == true or setToTrue == 1 then 
		self.userReward.rewardFlag = bit.bor(self.userReward.rewardFlag, mask) -- e.g. 1100 | 0010 = 1110
	else
		if mask == bit.band(self.userReward.rewardFlag, mask) then 
			self.userReward.rewardFlag = self.userReward.rewardFlag - mask -- e.g.: 1110 - 0010 = 1100
		end
	end
	return self.userReward.rewardFlag
end

function UserManager:getDimePlatforms()
	return self.dimePlat
end

function UserManager:getDimeProvinces()
	return self.dimeProvince
end

---------------------------
--判断后端是否在一个平台
---------------------------
function UserManager:isSameInviteCodePlatform( code )
	-- body
	local function isYYBCode(_code)
		local codeNum = tonumber(_code)
		if not codeNum then 
			assert(false, "isYYBCode codeNum error:" .. tostring(_code))
			return false 
		end
		codeNum = math.floor(codeNum/1000000000)
		-- if _G.isLocalDevelopMode then printx(0, codeNum, type(codeNum)) debug.debug() end
		if 1<= codeNum and codeNum <=3 then 
			return true
		end
		return false
	end

	return isYYBCode(code) == isYYBCode(self.inviteCode)
end

function UserManager:isYYBInviteCodePlatform(code)
	code = code or self.inviteCode

	local codeNum = tonumber(code)
	codeNum = math.floor(codeNum/1000000000)
	if 1<= codeNum and codeNum <=3 then 
		return true
	end
	return false
end

function UserManager:isSamePlatform(inviteCodeA, inviteCodeB)
	if self:isYYBInviteCodePlatform(inviteCodeA) then
		return self:isYYBInviteCodePlatform(inviteCodeB)
	else
		return not self:isYYBInviteCodePlatform(inviteCodeB)
	end
end

function UserManager:setIngameBuyGuide(var)
	self.ingameBuyPropsGuide = var
end

function UserManager:getIngameBuyGuide()
	if self.ingameBuyPropsGuide == 1 then
		self.ingameBuyPropsGuide = 0
		return true
	end
	return false
end

-- 是否通过了某关
function UserManager:hasPassed(levelId)
	return (UserManager.getInstance():getUserScore(levelId) ~= nil) or UserManager.getInstance().user:getTopLevelId() >= (levelId+1)
end

function UserManager:updateContinuousLogonData(timeInSec)
	return self.userExtend:updateContinuousLogonData(timeInSec)
end

function UserManager:getContinuousLogonDays(timeInSec)
	if self.userExtend.continuousLogonStartTime > 0 then
		timeInSec = timeInSec or Localhost:timeInSec()
		local diffDays = calcDateDiff(os.date("*t", timeInSec), os.date("*t", self.userExtend.continuousLogonStartTime/1000))
		if diffDays >= 0 then
			return diffDays + 1
		end
	end
	return 1
end

function UserManager:hasNotifyData(eType)
	for k,v in pairs(self.notificationReminder or {}) do
        if v.first == eType then
            return true
        end
	end
	return false
end

function UserManager:updateNotifyData(eType, tm)
	for k,v in pairs(self.notificationReminder or {}) do
		if v.first == eType then
			v.second = tostring(tm)
            return
        end
	end
	
	local item = NotifiItemRef.new()
	item.first = eType
	item.second = tostring(tm)
	table.insert(self.notificationReminder, item)
end

function UserManager:getAreaTaskInfo( ... )
	return self.areaTaskInfo
end

function UserManager:setAreaTaskInfo( areaTaskInfo )
	self.areaTaskInfo = AreaTaskRef.new()
	self.areaTaskInfo:fromLua(areaTaskInfo)
end

function UserManager:getCurRoundFullStar( ... )
	return self.curRoundFullStar or 0x7FFFFFFF
end

function UserManager:getFullStarRecords( ... )
	return self.fullStarRecords or {}
end

function UserManager:addFullStarRecode( historyInfo )
	if not self.fullStarRecords then
		self.fullStarRecords = {}
	end

	local fullStarHistory = FullStarRankHistoryRef.new()
	fullStarHistory:fromLua({
		fullStar = historyInfo.fullStar or 0,
		rank = historyInfo.fullstar_rank or 0,
		time = historyInfo.fullstar_ts or 0,
		rewarded = historyInfo.rewarded or 0,
		rewards = table.clone(historyInfo.rewards or {}) or {},
	})

	table.insert(self.fullStarRecords, fullStarHistory)
end

function UserManager:getServerMaxLevel( ... )
	return self.maxLevel or 0
end

function UserManager:isGlobalFullLevel( ... )
	return self:hasPassedLevelEx(self:getGlobalMaxLevel())
end

function UserManager:getGlobalMaxLevel( ... )
	local localMaxLevel = kMaxLevels
	if NewAreaOpenMgr then
		localMaxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
	end
	local serverMaxLevel = self:getServerMaxLevel()
	local maxLevel = math.max(serverMaxLevel, localMaxLevel)
	return maxLevel
end

function UserManager:getFullLevelGiftData( ... )
	return self.fullLevelGifts
end

function UserManager:setFullLevelGiftData( jsonSZ )
	self.fullLevelGifts = jsonSZ or '{}'
end

function UserManager:getAreaStarInfo()
	local areaStars = {}
	local scores = UserManager:getInstance():getScoreRef()
	local max_unlock_area = math.ceil(UserManager.getInstance().user:getTopLevelId() / 15)
    local maxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()

	for k = 1, maxLevel/15 do 
		areaStars[k] = 0
	end

	for k, v in ipairs(scores) do
		local levelId = tonumber(v.levelId)
		if levelId < 10000 and levelId <= maxLevel then
			local areaId = math.ceil(levelId / 15)
			areaStars[areaId] = areaStars[areaId] + v.star
		end 
	end

	local dataList = {}
    local hideAreaList = {}
    local numFullStar = 0

	local function createAreaData(index,isHiddenBranch,currentStar,totalStar)
		local data = {}
		data.index = index
		data.isHiddenBranch = isHiddenBranch
		data.currentStar = currentStar
		data.totalStar = totalStar
		data.isUnlock = index <= max_unlock_area
		data.isFullStar = currentStar >= totalStar
		numFullStar = numFullStar + (data.isFullStar and 1 or 0)
		--print(#dataList,#hideAreaList,"createAreaData()",index,data.isFullStar,numFullStar,isHiddenBranch,currentStar,totalStar)
		return data
	end

	for k = 1 , maxLevel/15 do 
		local data = createAreaData(k,false,areaStars[k],LevelMapManager.getInstance():getTotalStarNumberByAreaId(k))
		table.insert(dataList,data)
	end

	-- 隐藏关卡星星数
	for k,v in pairs(dataList) do
		v.hideStar_amount = 0
		local endLevelId = k * 15
		local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(endLevelId)
		if branchId and not MetaModel:sharedInstance():isHiddenBranchDesign(branchId) then --已上线隐藏关
			local branchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
			local endTime = NewAreaOpenMgr.getInstance():getHideAreaEndTime(branchId)
		    local _, isOver
		    if endTime then
		    	_, isOver = NewAreaOpenMgr.getInstance():getCountdownStr(endTime)
		    end
		    local isLock = endTime and not isOver
			--print(k,endLevelId,branchId,endTime,_, isOver)
			if branchData and branchData.endNormalLevel == endLevelId and not isLock then
				for levelId=branchData.startHiddenLevel,branchData.endHiddenLevel do
					local score = UserManager:getInstance():getUserScore(levelId)
					if score and score.star > 0 then
						v.hideStar_amount = v.hideStar_amount + score.star
					end 
				end
				v.hideStar_total_amount = 9
				v.isBranchOpen = MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) 

				local data = createAreaData(k,true,v.hideStar_amount,v.hideStar_total_amount)
				data.isBranchOpen = v.isBranchOpen
				table.insert(hideAreaList,data)
			end
		end
		-- v.isAllFullStar = v.star_amount >= v.total_amount and v.hideStar_amount >= v.hideStar_total_amount
		-- print(k,v.star_amount >= v.total_amount,v.hideStar_amount >= v.hideStar_total_amount,v.star_amount , v.total_amount , v.hideStar_amount , v.hideStar_total_amount)
	end

	for i, v in ipairs(hideAreaList) do
    	table.insert(dataList, v)
	end	

	return dataList,numFullStar
end

function UserManager:mockTimeProps(num)
	self.timeProps = {}
	local uniqItemId = {}
	for k, v in pairs(TimePropMap) do
		if not uniqItemId[v] then
			uniqItemId[v] = true
			local p = TimePropRef.new()
			p.itemId = k
			p.expireTime = Localhost.time() + 86400000 * 3
			p.num = num or 10
			table.insert(self.timeProps, p)
		end
	end
end

function UserManager:mockScores(levelId)
	local mapMgr = LevelMapManager.getInstance()
	for lv = 1, levelId do
		local meta = mapMgr:getMeta(lv)
		local score = ScoreRef.new()
		score.levelId	= lv
		score.score	= meta and (meta.score3 + 100) or 200000
		score.star	= 3
		score.uid	= self.uid
		score.updateTime	= Localhost.getInstance():timeInSec()
		self:addUserScore(score)
		self.user:setTopLevelId(levelId)
	end
end

function UserManager:changeRequestNum()
    local hasReward = NewVersionUtil:hasUpdateReward()
--    hasReward = true --test
    if hasReward then
        self.requestNum = self.requestNum + 1
    end
end

function UserManager:setTodayMark()
	self.markV2TodayIsMark = true
end