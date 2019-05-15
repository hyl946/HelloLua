require "hecore.class"
require "zoo.data.DataRef"

local debugFriendData = false

local instance = nil
FriendManager = {
	friends = {},
	invitedFriends = {},
	appFriends = {}, -- app好友
	noneAppFriends = {}, -- 非app好友
	snsFriendIds = {},
}

function FriendManager.getInstance()
	if not instance then instance = FriendManager end
	return instance
end

local function debugMessage( msg )
	if debugFriendData then if _G.isLocalDevelopMode then printx(0, "[FriendManager]", ""..msg) end end
end 

function FriendManager:encode()
	local dst = {}
	for uid,v in pairs(self.friends) do
		dst[uid] = v:encode()
	end
	return dst
end

function FriendManager:decode(src)
	self:initFromLua(src)
end

function FriendManager:getNewAddedSnsFriendIds()
	local resultSnsFriendIds = {}

	local newAddedIds = self.newAddedSnsFriendIds or {}
	for __,v in pairs(newAddedIds) do
		if self.friends[tostring(v)] then
			table.insert(resultSnsFriendIds, v)
		end
	end

	return resultSnsFriendIds
end

--检查是否有完整好友信息。需要请求过friendHttp 或者 有缓存
function FriendManager:checkFullInfo(callback,failCallback)
	if self.lastLoginInfoMap then
		callback()
		return
	end
    local friendIds = UserManager:getInstance().friendIds
    local data = Localhost:readFriendsData()
    if data and #data==#friendIds then
	    callback()
		return
	end

	local http = FriendHttp.new( true )
    http:addEventListener(Events.kComplete, callback)
    http:addEventListener(Events.kError, failCallback)
    http:addEventListener(Events.kCancel, failCallback)
    http:load(true, friendIds)
end

function FriendManager:syncFromLua( src, profiles, snsFriendIds, achievementList, friendSource, friendLastLoginDays,lastLoginInfoMap)
	self.newAddedSnsFriendIds = {}
	local newSnsFriendIds = {}
	self.friends = {}

	self.lastLoginInfoMap = lastLoginInfoMap
	
	if snsFriendIds then
		for _,v in pairs(snsFriendIds) do
			if not self.snsFriendIds or not self.snsFriendIds[tostring(v)] then
				table.insert(self.newAddedSnsFriendIds, v)
			end
			newSnsFriendIds[tostring(v)] = true
		end
	end

	self.snsFriendIds = newSnsFriendIds

	local list = {}
	if profiles ~= nil then
		for i, v in ipairs(profiles) do
			if v then list[v.uid] = ProfileRef.new(v) end
		end
	end

	local uid2AchievementMap = {}
	if achievementList then
		for _,v in pairs(achievementList) do
			uid2AchievementMap[v.uid] = v
		end
	end

	----------------------------------------------------------------------------
	local newFriendSource = {}
	if friendSource then
		for _,v in pairs(friendSource) do
			newFriendSource[v.first] = v.second
		end
	end

	----------------------------------------------------------------------------
	local allLastLoginDays = {}
	-- printx(11, "friendLastLoginDays:", table.tostring(friendLastLoginDays))
	if friendLastLoginDays then
		for _,v in pairs(friendLastLoginDays) do
			allLastLoginDays[v.first] = v.second
		end
	end

	------------------------------------------------------------------------------

	for i,v in ipairs(src) do
		local f = UserRef.new()
		f:fromLua(v)
		local profile = list[f.uid]
		if profile then 

			ProfileRef:checkProfileAgeConstellation(profile)

			-- f.name = nameDecode(profile.name or "")   --仅显示时转义，否则可能多次转义造成ascii码显示异常
			f.name = profile.name or ""
			f.headUrl = profile.headUrl
			f.snsId = profile.snsId
			f.age = profile.age
			f.gender = profile.gender
			f.constellation = profile.constellation
			f.secret = profile.secret
			f.fileId = profile.fileId
			f.customProfile = profile.customProfile
			f.headFrame = profile.headFrame
			f.headFrameExpire = profile.headFrameExpire
			f.birthDate = profile.birthDate
			f.location = profile.location
			f.headFrames = profile.headFrames
			f.communityUser = profile.communityUser

			-- if _G.isLocalDevelopMode then printx(0, "FriendManager syncFromLua:"..tostring(f.name)..","..tostring(f.headUrl)..","..tostring(f.snsId)) end
		end

		local achievement = uid2AchievementMap[f.uid]
		if achievement then
			f.achievement = achievement
		end

		-- 来源标记
		local fs = newFriendSource[f.uid]
		if fs then
			f.friendSource = fs
		end

		--用户上次登录，自1970以来经过的天数
		local loginDay = allLastLoginDays[f.uid]
		if loginDay then
			f.friendLastLoginDays = loginDay
		end

		--上次登录信息
		local data = lastLoginInfoMap and lastLoginInfoMap[f.uid]
		f.lastLoginTime = data and tonumber(data.lastLoginTime) or 0
		f.lastSnsPlatform = data and data.lastSnsPlatform or ""
		f.lastPlatform = data and data.lastPlatform or ""

		self.friends[tostring(f.uid)] = f
	end
	-- if _G.isLocalDevelopMode then printx(0, "user friendIds = "..table.tostring(friendIds)) end
	if __IOS_FB then -- facebook以平台好友为准
		local friendIds = {}
		for k,_ in pairs(self.friends) do
			table.insert(friendIds, k)
		end
		UserManager:getInstance().friendIds = friendIds
	end
	self.friendListUpdateTime = os.time()

	local homescene = HomeScene:sharedInstance()
	if homescene and homescene.worldScene and homescene.worldScene.worldSceneUnlockInfoPanel then
		homescene.worldScene.worldSceneUnlockInfoPanel:updateFriendItem()
	end
end

function FriendManager:isQQFriendsSynced()
	return self.qqFriendsSynced
end

function FriendManager:setQQFriendsSynced()
	self.qqFriendsSynced = true
end

function FriendManager:isSnsFriend( friendUid )
	return self.snsFriendIds[tostring(friendUid)] == true
end

function FriendManager:syncFromLuaForInvitedFriends(src, profiles)
	local list = {}
	if not self.invitedFriends then
		self.invitedFriends = {}
	end
	if profiles ~= nil then
		for i, v in ipairs(profiles) do
			if v then list[v.uid] = ProfileRef.new(v) end
		end
	end

	for i,v in ipairs(src) do
		local f = UserRef.new()
		f:fromLua(v)
		local profile = list[f.uid]
		if profile then 
			f.name = nameDecode(profile.name or "")
			f.headUrl = profile.headUrl
			f.snsId = profile.snsId
			f.fileId = profile.fileId
			f.customProfile = profile.customProfile
			f.headFrame = profile.headFrame
			f.headFrameExpire = profile.headFrameExpire
			--if _G.isLocalDevelopMode then printx(0, "FriendManager syncFromLua", f.name, f.headUrl) end
		end
		self.invitedFriends[f.uid] = f

	end	
	-- if _G.isLocalDevelopMode then printx(0, 'FriendManager:syncFromLuaForInvitedFriends', table.tostring(self.invitedFriends)) end
end

function FriendManager:getFriendInfo( uid )
	return self.friends[tostring(uid)]
end

function FriendManager:getFriendName( uid )
	local friendRef = nil
	if uid ~= nil then
		if tostring(UserManager:getInstance().uid) == tostring(uid) then 
			friendRef = UserManager.getInstance().profile
		else
			friendRef = self.friends[tostring(uid)]
		end
		if friendRef and friendRef.name and string.len(friendRef.name) > 0 then 
			return nameDecode(friendRef.name)
		else
			return "ID:"..tostring(uid)
		end
	end

	return "ID:nil"
end

function FriendManager:getFriendHeadUrl( uid )
	local friendRef = nil
	if uid ~= nil then
		if tostring(UserManager:getInstance().uid) == tostring(uid) then 
			friendRef = UserManager.getInstance().profile
		else
			friendRef = self.friends[tostring(uid)]
		end
		if friendRef then 
			return friendRef.headUrl
		end
	end
	
	return "ID:nil"
end

-- uid is a string!
function FriendManager:removeFriend(friendUid)
	friendUid = tostring(friendUid)
	if self.friends[friendUid] ~= nil then
		self.friends[friendUid] = nil
		
		for k, v in pairs(UserManager:getInstance().friendIds) do 
			if tostring(friendUid) == tostring(v) then
				table.remove(UserManager:getInstance().friendIds, k)
			end
		end
		self.friendListUpdateTime = os.time()
	end
end

function FriendManager:addFriend(friend)
	if friend.uid then 
		self.friends[tostring(friend.uid)] = friend
		self.friendListUpdateTime = os.time()
	end
end

function FriendManager:getFriendsSnsIdByUid(friendUids)
	local openIds = {}
	if not friendUids or not self.friends then return openIds end

	for i, v in ipairs(friendUids) do 
		local friend = self.friends[tostring(v)]
		if friend and friend.snsId then
			table.insert(openIds, friend.snsId)
		end
	end

	-- if _G.isLocalDevelopMode then printx(0, "gameIds:"..table.tostring(friendUids)) end
	-- if _G.isLocalDevelopMode then printx(0, "openIds:"..table.tostring(openIds)) end
	return openIds
end

function FriendManager:getAppFriendSnsIds(limit)
	local snsIds = {}
	if not self.friends then return snsIds end

	-- if _G.isLocalDevelopMode then printx(0, "self.friends="..table.tostring(self.friends)) end
	local counter = 1
	for uid,v in pairs(self.friends) do
		if limit and counter > limit then
			return snsIds
		elseif v.snsId then
			counter = counter + 1
			table.insert(snsIds, v.snsId)
		end
	end
	return snsIds
end

function FriendManager:getNoneAppFriendSnsIds(limit)
	local snsIds = {}
	for i,v in ipairs(self.noneAppFriends) do
		if limit and i > limit then
			return snsIds
		else
			table.insert(snsIds, v.id)
		end
	end
	return snsIds
end

function FriendManager:getFriendCount()
	local count = 0
	for k, v in pairs(self.friends) do count = count + 1 end
	return count
end

function FriendManager:getMaxFriendCount()
	return 300
end

function FriendManager:isFriendCountReachedMax()
	return self:getFriendCount() >= self:getMaxFriendCount()
end

function FriendManager:getAppFriendsCount()
	local count = 0
	for k, v in pairs(self.snsFriendIds) do count = count + 1 end
	return count
end

function FriendManager:canDelete()
	if self:getFriendCount() <=0 then return false end
	if WXJPPackageUtil.getInstance():isWXJPPackage() then return false end
	if PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) then return false end
	if PlatformConfig:isPlatform("kWechat") then return false end

	return true
end
