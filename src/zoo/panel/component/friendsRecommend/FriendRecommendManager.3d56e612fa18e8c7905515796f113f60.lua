require "zoo.panel.component.friendsRecommend.FriendRecommendPanel"

FriendRecommendManager = class()
local instance = nil
local kLastRecommendTime = "last_recommend_friend_time_"
local kLastReceiveFreeGiftTime = "last_get_energy_bottle_time_"
local timeInterval = 3 * 24 * 60 * 60 * 1000

function FriendRecommendManager.getInstance()
	if not instance then
		instance = FriendRecommendManager.new()
		instance:init()
	end
	return instance
end

function FriendRecommendManager:friendsButtonOutSide()
	if PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then return false end 
	-- if PlatformConfig:isQQPlatform() and 
	-- 	MaintenanceManager:getInstance():isEnabled("QQForumAvailable", true) and
	-- 	_G.sns_token and _G.sns_token.authorType == PlatformAuthEnum.kQQ then 
	-- 	return false 
	-- end
	return true
end

function FriendRecommendManager:init()
	local uidKey = tonumber(UserManager:getInstance().uid) or 0 
	self.uidKey = uidKey % 100
	self.userDefault = CCUserDefault:sharedUserDefault()
	self.lastRecommendTime = tonumber(self.userDefault:getStringForKey(kLastRecommendTime .. self.uidKey))
	self.lastGetBottleTime = tonumber(self.userDefault:getStringForKey(kLastReceiveFreeGiftTime .. self.uidKey))
end

function FriendRecommendManager:shouldAskRecommendInfo()
	if not MaintenanceManager:getInstance():isAvailbleForUid("FriendsRecommend2", UserManager:getInstance().uid) then
		-- CommonTip:showTip(localize("好友优化2期：开关未开启"),"negative")
		return false
	end

	local nowTime = Localhost:time()
	-- 玩家好友数≤20；
	local friendCount = FriendManager:getInstance():getFriendCount()
	if friendCount >= 200 then 
		-- CommonTip:showTip(localize("好友优化2期：好友超过200人"),"negative")
		return false 
	end
	-- 20<玩家好友数<200，且近三天内未收到好友赠送精力瓶。
	if friendCount > 20 and self.lastGetBottleTime and nowTime - self.lastGetBottleTime < timeInterval then 
		-- local str = string.format("好友优化2期：上次领取精力时间：%s", os.date("%Y-%m-%d %H:%M:%S", self.lastGetBottleTime / 1000))
		-- CommonTip:showTip(localize(str),"negative", nil, 5)
		return false
	end
	-- 每隔三天
	if self.lastRecommendTime and type(self.lastRecommendTime) == "number" and nowTime - self.lastRecommendTime < timeInterval then 
		-- local str = string.format("好友优化2期：上次推荐的时间：%s  %s  %s  %s", os.date("%Y-%m-%d %H:%M:%S", self.lastRecommendTime / 1000), nowTime, self.lastRecommendTime, timeInterval)
		-- CommonTip:showTip(localize(str),"negative", nil, 5)
		return false
	end
	return true
end

local function getFriendsInfo(users, profiles)
	local friendsInfo = {}
	local profilesKV = {}
	if profiles then 
		for i,v in ipairs(profiles) do
			profilesKV[v.uid] = v
		end
	end
	for i,v in ipairs(users) do
		local info = {}
		info.uid = v.uid
		info.topLevelId = v.topLevelId

		local profile = profilesKV[v.uid]
		if profile then 
			info.name = profile.name or "消消乐玩家"
			info.headUrl = profile.headUrl or i
			info.sex = profile.gender or 0
			info.profile = profile
		else
			info.name = "消消乐玩家"
			info.headUrl = i
			info.sex = 0
		end
		table.insert(friendsInfo, info)
	end

	return friendsInfo
end

function FriendRecommendManager:getRecommendInfo(successCB, failCB)
	-- -----------test------------
	-- local info = {}
	-- info.success = true
	-- info.lastRecommendTime = Localhost:timeInSec() - timeInterval - 10
	-- info.lastReceiveFreeGiftTime = Localhost:timeInSec() - timeInterval - 10
	-- info.users = {}
	-- for i=1,10 do
	-- 	local user = {}
	-- 	user.uid = 12345 + i
	-- 	user.topLevelId = 100 * i
	-- 	table.insert(info.users, user)
	-- end
	-- info.profiles = {}
	-- for i=1,10 do
	-- 	local profile = {}
	-- 	profile.name = "aaaa"..i
	-- 	profile.uid = 12345 + i
	-- 	profile.headUrl = i
	-- 	profile.gender = i%3
	-- 	table.insert(info.profiles, profile)
	-- end
	-- if info.success then 
	-- 	if info.users and #info.users > 0 then 
	-- 		local friendsInfo = getFriendsInfo(info.users, info.profiles)
	-- 		if successCB then successCB(friendsInfo) end
	-- 	else
	-- 		if failCB then failCB() end
	-- 	end
	-- else
	-- 	if failCB then failCB() end
	-- end
	-- -----------test------------

	local function onSuccess(evt)
		local info = evt.data or {}
		if info.lastRecommendTime then 
			self:setLastRecommendTime(info.lastRecommendTime)
			
		end
		if info.lastReceiveFreeGiftTime then 
			self:setReceiveFreeGiftTime(info.lastReceiveFreeGiftTime)
		end
		if info.success then 
			if info.users and #info.users > 0 then 
				local friendsInfo = getFriendsInfo(info.users, info.profiles)
				if successCB then successCB(friendsInfo) end
			else
				if failCB then failCB() end
			end
		else
			if failCB then failCB() end
		end
	end
	local function onFail(evt)
		local errcode = evt and evt.data or nil
		if failCB then failCB(errcode) end
	end
	local http = GetRecommendFriendInfo.new()
	http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
	http:load()
end

function FriendRecommendManager:setLastRecommendTime(time)
	self.lastRecommendTime = tonumber(time)
	self.userDefault:setStringForKey(kLastRecommendTime .. self.uidKey, time)
	self.userDefault:flush()
end

function FriendRecommendManager:setReceiveFreeGiftTime(time)
	self.lastReceiveFreeGiftTime = tonumber(time)
	self.userDefault:setStringForKey(kLastReceiveFreeGiftTime .. self.uidKey, time)
	self.userDefault:flush()
end

function FriendRecommendManager:sendAccept(uids, successCB, failCB)
	-- print("FriendRecommendManager:sendAccept=====uids", table.tostring(uids))
	local function addRewards(rewards)
		if rewards then
			UserManager:getInstance():addRewards(rewards)
    		UserService:getInstance():addRewards(rewards)
    		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kFriend, rewards, DcSourceType.kRecommendFriendAccept)
    	end
	end
	local function onSuccess(evt)
		if evt.data and evt.data.rewards and type(evt.data.rewards) == "table" then
			addRewards(evt.data.rewards)
		end
		if successCB then successCB() end
	end
	local function onFail(evt)
		if evt and evt.data then 
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		end
		if failCB then failCB() end
	end
	local http = AcceptRecommendFriendAndReward.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
	http:syncLoad(uids)
end
