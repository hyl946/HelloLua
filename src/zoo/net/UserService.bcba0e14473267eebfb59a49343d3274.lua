require "zoo.data.UserManager"
require "zoo.util.MemClass"
require "zoo.util.UserContext"
-------------------------------------------------------------------------
--  Class include: UserService
-------------------------------------------------------------------------

local uuid = require "hecore.uuid"

--
-- UserService ---------------------------------------------------------
--
local instance = nil
UserService = class(UserManager)

function UserService:getInstance()
	if not instance then 
		instance = UserService.new() 

		--local storage
		instance.httpData = HttpDataInfo.new()
		local userData = Localhost:readLastLoginUserData()
		instance.levelDataInfo = LevelDataInfo.new()
		if userData and userData.user and userData.user.levelDataInfo then
			instance.levelDataInfo:fromLua(userData.user.levelDataInfo)
		end
		instance.metals = {}
	end
	return instance
end

local function encodeListDataRef( list )
	local dst = {}
	for i,v in ipairs(list) do dst[i] = v:encode() end
	return dst
end 

function UserService:encode()
	local dst = {}	
	dst.inviteCode = self.inviteCode
	dst.appName = self.appName
	dst.friendIds = self.friendIds
	dst.user = self.user:encode()
	dst.userExtend = self.userExtend:encode()
	dst.profile = self.profile:encode()
	dst.bag = self.bag:encode()
	dst.mark = self.mark:encode()
	dst.dailyData = self.dailyData:encode()

	dst.props = encodeListDataRef(self.props)
	dst.funcs = encodeListDataRef(self.funcs)
	dst.decos = encodeListDataRef(self.decos)
	dst.scores = encodeListDataRef(self.scores)
	dst.jumpedLevelInfos = encodeListDataRef(self.jumpedLevelInfos)

	dst.achis = encodeListDataRef(self.achis)
	--dst.requestInfos = encodeListDataRef(self.requestInfos) DO not save this as it require online
	dst.unLockFriendInfos = encodeListDataRef(self.unLockFriendInfos)
	dst.ladyBugInfos = encodeListDataRef(self.ladyBugInfos)

	dst.httpData = self.httpData:encode()
	dst.levelDataInfo = self.levelDataInfo:encode()
	dst.metals = self.metals
	
	dst.openId = self.openId
	dst.weekMatch = self.weekMatch
	dst.userReward = self.userReward
	dst.rabbitWeekly = self.rabbitWeekly

	dst.lastCheckTime = self.lastCheckTime

	dst.dimePlat = self.dimePlat
	dst.dimeProvince = self.dimeProvince
	dst.timeProps = encodeListDataRef(self.timeProps)

	-- dst.userType = self.userType
	dst.setting = self.setting

	dst.achievement = self.achievement
	dst.newLadyBugInfo = self.newLadyBugInfo

	

	dst.ingameLimit = self.ingameLimit
	dst.smsDayRmb = self.smsDayRmb
	dst.smsMonthRmb = self.smsMonthRmb
	dst.yybAdWallLimit = self.yybAdWallLimit

	dst.realNameAuthSwitchStatus = self.realNameAuthSwitchStatus
	dst.realNameAuthed = self.realNameAuthed
	dst.realNameIdCardAuthed = self.realNameIdCardAuthed

	dst.propGuideInfo = self.propGuideInfo

	dst.cmgameOfflinePayLimit = self.cmgameOfflinePayLimit
	
	dst.baFlags = {}
	for k, v in pairs(self.baFlags) do
		dst.baFlags[k] = v
	end
	dst.guideFlags = {}
	for k, v in pairs(self.guideFlags) do
		dst.guideFlags[k] = v
	end
	dst.add5LotteryInfo = self.add5LotteryInfo
	dst.startTimeUserCallback = self.startTimeUserCallback
	dst.onlineStartAreaIds = self.onlineStartAreaIds
	dst.playTimes = self.playTimes
	dst.areaTaskInfo = self.areaTaskInfo:encode()
	dst.questSystemInfo = self.questSystemInfo:encode()
	dst.lastRoundFullLevel = self.lastRoundFullLevel
	dst.curRoundFullStar = self.curRoundFullStar
	dst.maxLevel = self.maxLevel
	dst.active30Days = self.active30Days
	dst.scoreVersion = self.scoreVersion
	dst.groupInfo = self.groupInfo
	dst.giftPackInfos = self.giftPackInfos
	dst.giftPackNewUser = self.giftPackNewUser

    dst.markV2Active = self.markV2Active
    dst.markV2TodayIsMark = self.markV2TodayIsMark

	return dst
end

function UserService:onLevelUpdate( win, level, totalScore )
	if 1 == win then self.levelDataInfo:onLevelWin(level, totalScore)
	else self.levelDataInfo:onLevelFail(level, totalScore) end

	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
end

function UserService:onQuitLevel(levelId)
	self.levelDataInfo:onQuitLevel(levelId)
	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
end

function UserService:decodeLocalStorageData( userData )
	if userData then
		local httpData = userData.httpData
		self.httpData = HttpDataInfo.new()
		self.httpData:fromLua(httpData)

		local levelDataInfo = userData.levelDataInfo
		self.levelDataInfo = LevelDataInfo.new()
		self.levelDataInfo:fromLua(levelDataInfo)

		local metals = userData.metals
		--if _G.isLocalDevelopMode then printx(0, "metals"..table.tostring(metals)) end
		self.metals = metals or {}
	end
end

function UserService:addCoin(addCoinNum)
	UserManager.addCoin(self, addCoinNum, false)
end

function UserService:addCash(addCashNum)
	UserManager.addCash(self, addCashNum, false)
end

function UserService:addEnergy(addEnergyNum)
	UserManager.addEnergy(self, addEnergyNum, false)
end

function UserService:addUserPropNumber(itemId, deltaNumber, ...)
	UserManager.addUserPropNumber(self, itemId, deltaNumber, true, ...)
end

function UserService:addReward(reward)
	UserManager.addReward(self, reward, false)
end

function UserService:addRewards(rewards)
	UserManager.addRewards(self, rewards)
end

function UserService:clearCachedHttp()
	self.httpData = HttpDataInfo.new()
end
local function indexOfHttpData( indexID, httpDataAlreadySent )
	if httpDataAlreadySent and #httpDataAlreadySent > 0 then
		for i,v in ipairs(httpDataAlreadySent) do
			if v.id == indexID then return true end
		end
	end
	return false
end
function UserService:clearUsedHttpCache(httpDataAlreadySent)
	local list = {}
	local httpData = self.httpData:encode()
	for i,element in ipairs(httpData) do 
		if element and not indexOfHttpData(element.id, httpDataAlreadySent) then
			table.insert(list, element) 
		end
	end
	self.httpData = HttpDataInfo.new()
	self.httpData.list = list
end

function UserService:setCachedHttp(httpData)
	self.httpData = HttpDataInfo.new()
	self.httpData.list = httpData
end

function UserService:getCachedHttpData()
	return self.httpData:encode()
end
function UserService:cacheHttp( endpoint, body )
	-- add info data for AI dc by server
	UserContext:addGamePlayContextDatas(body)

	body.__offlineRequestTime = Localhost:timeInMillis()
    body.__id = uuid:getUUID()
	
	local serialized = table.serialize(body)
	self.httpData:add(endpoint, table.deserialize(serialized)) --deep clone object
end

function UserService:initialize()
	UserManager.getInstance():clone(self)
end

function UserService:computeFullEnergyTime()
	local fullEnergyTime = 0
	local max = UserLocalLogic:getUserEnergyMaxCount()
	local updateTime = self.user:getUpdateTime() or Localhost:time()
	local energy = self.user:getEnergy()
	local deltaEnergy = max - energy
	if deltaEnergy > 3 then
		updateTime = tonumber(updateTime)
		if _G.isLocalDevelopMode then printx(0, string.format("computeFullEnergyTime %f %f", updateTime, Localhost:time())) end
		local user_energy_recover_time_unit = MetaManager.getInstance().global.user_energy_recover_time_unit or 480000
		user_energy_recover_time_unit = user_energy_recover_time_unit * FcmManager:getTimeScale()
		fullEnergyTime = 61 + math.floor(deltaEnergy * user_energy_recover_time_unit + updateTime - Localhost:time()) / 1000
	end
	return fullEnergyTime
end

function UserService:getExactFullEnergyTimeInSec()
	local fullEnergyTime = 0
	local max = UserLocalLogic:getUserEnergyMaxCount()
	local updateTime = self.user:getUpdateTime() or Localhost:time()
	local energy = self.user:getEnergy()
	local deltaEnergy = max - energy
	if deltaEnergy > 0 then
		updateTime = tonumber(updateTime)
		local user_energy_recover_time_unit = MetaManager.getInstance().global.user_energy_recover_time_unit or 480000
		user_energy_recover_time_unit = user_energy_recover_time_unit * FcmManager:getTimeScale()
		fullEnergyTime = math.ceil((deltaEnergy * user_energy_recover_time_unit + updateTime - Localhost:time()) / 1000)
	end
	return fullEnergyTime
end

function UserService:setSyncSerial(syncSerial)
	self.syncSerial = syncSerial
end

function UserService:getSyncSerial()
	return self.syncSerial
end

local isSyncLocalProgress = false
function UserService:isSyncingLocal()
	return isSyncLocalProgress
end

function UserService:syncLocal()
	local requests = {}
	local list = self:getCachedHttpData()
	for k, v in ipairs(list) do table.insert(requests, v) end
	if #requests <= 0 then return end
	local successed = {}
	isSyncLocalProgress = true
	for i, element in ipairs(requests) do
		local success = true
		local body = element.body
		if element.endpoint == "startlevel" then
			success = Localhost:startLevel(body.levelId, body.gameMode, body.itemList, body.energyBuff, body.activityFlag, body.requestTime)
		elseif element.endpoint == "passLevel" then
			success = Localhost:passLevel(body.levelId, body.score, body.star, body.stageTime, body.coin, body.targetCount, body.opLog, body.activityFlag, body.requestTime)
		elseif element.endpoint == "useProps" then
			success = Localhost:useProps(body.type, body.levelId, body.gameMode, body.param, body.itemList, body.requestTime)
		elseif element.endpoint == "openGiftBlocker" then
			success = Localhost:openGiftBlocker(body.levelId, body.itemList)
		elseif element.endpoint == "ingame" then
			success = Localhost:ingame(body.id, body.orderId, body.channel, body.ingameType, body.detail)
		elseif element.endpoint == "getNewUserRewards" then
			success = Localhost:getNewUserRewards()
		elseif element.endpoint == "unLockLevelArea" then
			success = Localhost:unlockLevelArea(body.type, body.friendUids)
		elseif element.endpoint == "buy" then
			success = Localhost:buy(body.goodsId, body.num, body.moneyType, body.targetId)
		end
		if not success then break end
		table.insert(successed, element)
	end
	self:setCachedHttp(successed)
	local user = self.user
	local scores = self.scores
	local props = self.props
	local jumpedLevelInfos = self.jumpedLevelInfos
	UserManager:getInstance():updateUserData({user = user, 
		scores = scores, props = props, jumpedLevelInfos = jumpedLevelInfos})

	isSyncLocalProgress = false
end