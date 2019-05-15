require "zoo.util.SensorManager"
require "zoo.util.LocationManager"

AddFriendPanelLogic = class()

ADD_FRIEND_SOURCE = {
	PHONE = 1,
	QR_CODE = 2,
	XXL_CODE = 3,
	NEAR_PLAYER = 4,
	ACTIVITY = 5,
	WEEKLY_RACE = 6,
	ASKFORHELP = 7,
	RECOMMEND = 8,
	UNKNOW = 9,
	AUTOADDFRIEND = 10,
}

ADD_FRIEND_INVITE_SOURCE = {
	WX_P2P = 1,
	INVITE_REWARD_AUTO = 2
}

function AddFriendPanelLogic:create()
	local logic = AddFriendPanelLogic.new()
	logic:init()
	return logic
end

function AddFriendPanelLogic:init()
	LocationManager_All:getInstance():initLocationManager()
end

function AddFriendPanelLogic:startUpdateLocation()
	LocationManager_All:getInstance():startUpdatingLocation(true)
end

function AddFriendPanelLogic:dispose()
	LocationManager_All:getInstance():stopUpdatingLocation()
	SensorManager_All:getInstance():stopListenerShake()
end

function AddFriendPanelLogic:randomList(data, isShowNext)
	if not data or #data == 0 then return {} end
	if #data <= 10 then return data end
	local value, res = {}, {}
	local length = 9
	local function getCount(tab)
		local count = 0
		for k, v in pairs(tab) do count = count + 1 end
		return count
	end
	while getCount(res) < length do
		local index = math.floor(math.random(length))
		if not value[index] then
			table.insert(res, data[index])
			value[index] = true
		end
	end
	return res
end

-- get list of profile
function AddFriendPanelLogic:getRecommendFriend(successCallback, failCallback, context)
	local function onSuccess(evt)
		if self.http ~= evt.target then return end
		local data = {}
		if evt.data.profiles and evt.data.users then
			local function getUser(uid)
				for k, v in ipairs(evt.data.users) do
					if v.uid == uid then return v end
				end
			end
			for k, v in ipairs(evt.data.profiles) do
				local user = getUser(v.uid)
				local ref = FriendManager:getInstance():getFriendInfo(v.uid)
				local player = UserManager:getInstance().user
				if user and not ref and user.uid ~= player.uid then
					table.insert(data, {userLevel = user.topLevelId, userName = v.name, uid = user.uid, headUrl = v.headUrl or user.image})
				end
			end
		end
		self.contentRecommend = data
		if successCallback then successCallback({data = self:randomList(data), num = #data}, context) end
	end
	local function onFail(evt)
		if self.http ~= evt.target then return end
		self.longitude, self.latitude = nil, nil
		if failCallback then failCallback(evt.data, context) end
	end

	local retry = 5
	local function sendPosition()
		local longitude = LocationManager_All:getInstance():getLongitude()
		local latitude = LocationManager_All:getInstance():getLatitude()
		if longitude == 0 or latitude == 0 then
			if retry == 0 then
				if self.positionSchedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.positionSchedule) end
				if failCallback then failCallback(1016, context) end
			end
			retry = retry - 1
		else
			if self.positionSchedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.positionSchedule) end
			if (self.longitude and self.latitude and self:inRequestedRange(longitude, latitude)) and (self.contentRecommend and (#self.contentRecommend > 0 or self:lastResRemainAvl())) then
				if successCallback then successCallback({data = self:randomList(self.contentRecommend), num = #self.contentRecommend}, context) end
			else
				local http = GetNearbyHttp.new(false)
				self.http = http
				http:addEventListener(Events.kComplete, onSuccess)
				http:addEventListener(Events.kError, onFail)
				http:load(longitude, latitude)
				self.longitude, self.latitude = longitude, latitude
			end
		end
	end
	if self.positionSchedule then Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.positionSchedule) end
	retry = 5
	self.positionSchedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(sendPosition, 2, false)
end

function AddFriendPanelLogic:inRequestedRange(longitude, latitude)
	if _G.isLocalDevelopMode then printx(0, "AddFriendPanelLogic:inRequestedRange") end
	if not self.longitude or not self.latitude or not longitude or not latitude then return false end
	local part1 = math.pow(math.sin((self.latitude - latitude) * math.pi / 180 / 2), 2)
	local part2 = math.cos(self.latitude * math.pi / 180) * math.cos(latitude * math.pi / 180)
	local part3 = math.pow(math.sin((self.longitude - longitude) * math.pi / 180 / 2), 2)
	return 6378.137 * 2 * math.asin(math.sqrt(part1 + part2 * part3)) <= 1
end

function AddFriendPanelLogic:lastResRemainAvl()
	if not self.recommendLastUpdate then
		self.recommendLastUpdate = os.time()
		return false
	elseif os.time() - self.recommendLastUpdate <= 30 then
		self.recommendLastUpdate = os.time()
		return true
	else return false end
end

function AddFriendPanelLogic:sendRecommendFriendMessage(uid, successCallback, failCallback, context)
	if not uid then -- request fail
		if failCallback then failCallback(206, context) end
	end

	local function onSuccess(evt)
		for k, v in ipairs(self.contentRecommend) do
			if v.uid == uid then
				table.remove(self.contentRecommend, k)
				break
			end
		end
		if successCallback then successCallback(evt.data, context) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data, context) end
	end

	require("zoo.panel.component.friendsPanel.func.FriendsFullPanel")
	if FriendsFullPanel:checkFullZombieShow() then
		if failCallback then failCallback(nil, context) end
		return
	end
	if FriendManager:getInstance():isFriendCountReachedMax() then
		if failCallback then
			failCallback(731014, context) -- too many friends
			return
		end
	end
	local http = RequestFriendHttp.new(false)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load(nil, uid, ADD_FRIEND_SOURCE.NEAR_PLAYER)
end

-- search for user with code
-- CAUTION: record the code after search succeed
-- successCallback({user = UserRef, profile = ProfileRef}, context)
-- failCallback(err, context)
function AddFriendPanelLogic:searchUser(code, successCallback, failCallback, cancelCallback, context)
	if not code then -- request fail
		if failCallback then failCallback(206, context) end
	end

	local function onSuccess(evt)
		if self.http ~= evt.target then return end
		self.code = code
		local data = {}
		if evt.data.profile and evt.data.user then
			table.insert(data, 
                {   
                    userLevel = evt.data.user.topLevelId, 
                    userName = evt.data.profile.name, 
                    star = evt.data.user.star,
                    hideStar = evt.data.user.hideStar,
                    uid = evt.data.user.uid, 
                    headUrl = evt.data.profile.headUrl or evt.data.user.image, 
                    profile = evt.data.profile
                }
            )
		end
		if successCallback then successCallback(data, context) end
	end
	local function onFail(evt)
		if self.http ~= evt.target then return end
		if failCallback then failCallback(evt.data, context) end
	end
	local function onCancel(evt)
		if self.http ~= evt.target then return end
		if cancelCallback then cancelCallback(context) end
	end

	local http = QueryUserHttp.new(true)
	self.http = http
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(code)
end

-- send add friend message with code
-- CAUTION: if code is nil, use the recoded code
-- CAUTION: if do add with code, the recorded code will not be changed
-- successCallback(data, context)
-- failCallback(err, context)
function AddFriendPanelLogic:sendAddMessage(code, successCallback, failCallback, cancelCallback, context, srcType)
	if not code then code = self.code end
	if not code then -- request fail
		if failCallback then failCallback(206, context) end
		return
	end

	local function onSuccess(evt)
		if self.http ~= evt.target then return end
		if successCallback then successCallback(evt.data, context) end
	end
	local function onFail(evt)
		if self.http ~= evt.target then return end
		if failCallback then failCallback(evt.data, context) end
	end
	local function onCancel(evt)
		if self.http ~= evt.target then return end
		if cancelCallback then cancelCallback(evt.data, context) end
	end

	self.http = nil
	if code == UserManager:getInstance().inviteCode then
		onFail({data = 731010})
		return
	end
	local ref = FriendManager:getInstance():getFriendInfo(uid)
	if ref then
		onFail({data = 731011}) -- error: already be friends
		return
	end
	local http = RequestFriendHttp.new(true)
	self.http = http
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(code, nil, srcType)
end

function AddFriendPanelLogic:sendAddPhoneMessage(uid, successCallback, failCallback, cancelCallback, context)
	local function onSuccess(evt)
		if self.http ~= evt.target then return end
		if successCallback then successCallback(evt.data, context) end
	end

	local function onFail(evt)
		if self.http ~= evt.target then return end
		if failCallback then failCallback(evt.data, context) end
	end

	local function onCancel(evt)
		if self.http ~= evt.target then return end
		if cancelCallback then cancelCallback(evt.data, context) end
	end

	local http = RequestFriendHttp.new(true)
	self.http = http
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(nil, uid, ADD_FRIEND_SOURCE.PHONE)
end

local shakeStatus = false
function AddFriendPanelLogic:waitForShake(callback, context)
	local function onCallback(data)
		if shakeStatus == false then return end
		shakeStatus = false
		SensorManager_All:getInstance():stopListenerShake()
		if callback then callback(data, context) end
	end
	shakeStatus = true
	SensorManager_All:getInstance():startListenerShake(onCallback)
end

function AddFriendPanelLogic:stopWaitForShake()
	SensorManager_All:getInstance():stopListenerShake()
end

function AddFriendPanelLogic:sendPositionMessage(successCallback, failCallback, context)
	local function onSuccess(evt)
		if self.http ~= evt.target then return end
		local function getResult() self:getSearchResult(successCallback, failCallback, context) end
		setTimeOut(getResult, 5)
	end
	local function onFail(evt)
		if self.http ~= evt.target then return end
		if failCallback then failCallback(evt.data, context) end
	end
	local longitude = LocationManager_All:getInstance():getLongitude()
	local latitude = LocationManager_All:getInstance():getLatitude()
	if longitude == 0 or latitude == 0 then
		if failCallback then failCallback(1016, context) end
	else
		local http = SendLocationHttp.new(false)
		self.http = http
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:load(longitude, latitude)
	end
end

function AddFriendPanelLogic:getSearchResult(successCallback, failCallback, context)
	local function onSuccess(evt)
		if self.http ~= evt.target then return end
		local data = {}
		self.shakeUsers = self.shakeUsers or {}
		if evt.data.profiles and evt.data.users then
			local function getUser(uid)
				for k, v in ipairs(evt.data.users) do
					if v.uid == uid then return v end
				end
			end
			for k, v in ipairs(evt.data.profiles) do
				local user = getUser(v.uid)
				if user then
					local isFriend = FriendManager:getInstance():getFriendInfo(v.uid)
					table.insert(data, {userLevel = user.topLevelId, userName = v.name, uid = user.uid, headUrl = v.headUrl or user.image, isFriend = isFriend ~= nil})
					user.name, user.headUrl = v.name, v.headUrl
					table.insert(self.shakeUsers, user)
				end

			end
		end
		if successCallback then successCallback(data, context) end
	end
	local function onFail(evt)
		if self.http ~= evt.target then return end
		if failCallback then failCallback(evt.data, context) end
	end
	local http = GetMatchsHttp.new(false)
	self.http = http
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load()
end

function AddFriendPanelLogic:resetWaitingState()
	self.rcList = self.rcList or {}
	self.shakeUsers = self.shakeUsers or {}
	for i = 1, #self.rcList do table.remove(self.rcList, 1) end
	for i = 1, #self.shakeUsers do table.remove(self.shakeUsers, 1) end
	if self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
	end
	self.rcCount = -1
end

function AddFriendPanelLogic:isWaitingState()
	self.rcList = self.rcList or {}
	if (not self.rcList or #self.rcList == 0) and self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
		self.schedule = nil
	end
	return self.schedule ~= nil
end

function AddFriendPanelLogic:sendShakeAddMessage(uid, successCallback, failCallback, context)
	local function onSuccess(evt)
		if successCallback then successCallback(evt.data, context) end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data, context) end
	end
	require("zoo.panel.component.friendsPanel.func.FriendsFullPanel")
	if FriendsFullPanel:checkFullZombieShow() then
		if failCallback then failCallback(nil, context) end
		return
	end
	if FriendManager:getInstance():isFriendCountReachedMax() then
		if failCallback then
			failCallback(731014, context) -- too many friends
			return
		end
	end
	local http = ConfirmMatchHttp.new(false)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:load(uid)
end

function AddFriendPanelLogic:askForShakeAddResult(uid, successCallback, timeoutCallback, context)
	local function onSuccess(evt)
		if evt.data.friendUids and #evt.data.friendUids > 0 then
			for k1, v1 in ipairs(evt.data.friendUids) do
				self.rcList = self.rcList or {}
				for k2 = #self.rcList, 1, -1 do
					v2 = self.rcList[k2]
					if v1 == v2.uid then
						for k, v in ipairs(self.shakeUsers) do
							local ref = UserRef.new()
							ref:fromLua(v)
							if v.uid == v1 then FriendManager:getInstance():addFriend(ref) end
						end
						if successCallback then successCallback(v1, v2.context) end
						table.remove(self.rcList, k2)
						break
					end
				end
			end
		end
		if not self.rcList or #self.rcList == 0 or evt.data.result == 0 then
			self:resetWaitingState()
		end
	end
	local function sendMessage()
		self.rcCount = self.rcCount - 1
		if rcCount == -1 then
			self:resetWaitingState()
			if timeoutCallback then timeoutCallback(context) end
		end
		local http = AckMatchHttp.new(false)
		http:addEventListener(Events.kComplete, onSuccess)
		-- ignore fail messages 'cause there is only success, timeout & still waiting.
		http:load()
	end
	self.rcList = self.rcList or {}
	for k, v in ipairs(self.rcList) do
		if uid == v then return end
	end
	table.insert(self.rcList, {uid = uid, context = context})
	if not self.schedule then
		if self.rcCount == -1 then self.rcCount = 10 end
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(sendMessage, 3, false)
	end
end

AddFriendPanelModel = class()
function AddFriendPanelModel:getUserInviteCode()
	return UserManager:getInstance().inviteCode
end