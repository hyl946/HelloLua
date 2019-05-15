require "zoo.data.FriendManager"

InvitedAndRewardLogic = class()

-- TODO: change interface with server
-- TODO: decide poping CommongTip or not (in this file)

-- isShowLoad: play loading animation or not
function InvitedAndRewardLogic:create(isShowLoad)
	local logic = InvitedAndRewardLogic.new()
	if logic:_init(isShowLoad) then return logic
	else logic = nil end
	return nil
end

-- this will always success for not having bad network state
-- function successCallback(data, withFlag, context)
-- CAUTION: success callback should check for withFlag para to decide playing reward animation or not
function InvitedAndRewardLogic:start(inviteCode, uid, pid, ext, successCallback, failCallback, context)
	local function onSuccess(evt)
		-- get reward for invited for first time
		if self.withFlag and UserManager:getInstance().user:getTopLevelId() < 31 then self:_getReward() end
		-- add friend
		if evt.data and evt.data.user then
			local ref = UserRef.new()
			if evt.data.profile then
				ref.userHead = evt.data.profile.userHead
				ref.name = evt.data.profile.name
			end
			ref:fromLua(evt.data.user)
			FriendManager:getInstance():addFriend(ref)
		end
		if successCallback then successCallback(evt.data, self.withFlag, context) end
	end
	local function onFail(evt)
		-- disable flag
		if self.withFlag then UserManager:getInstance().userExtend:setFlagBit(1, false) end
		if failCallback then failCallback(evt.data, context) end
	end
	-- check for level condition
	if UserManager:getInstance().user:getTopLevelId() < 31 then
		-- enable flag for not request (first time reward) twice
		if not UserManager:getInstance().userExtend:isFlagBitSet(1) then
			UserManager:getInstance().userExtend:setFlagBit(1, true)
			self.withFlag = true
		else -- fail while target is already my friend and invite code used before
			local ref = FriendManager:getInstance():getFriendInfo(uid)
			if ref then
				if failCallback then failCallback(731013, context) end -- error: repeat invite code
				return
			end
		end
	else
		local ref = FriendManager:getInstance():getFriendInfo(uid)
		if ref then
			if failCallback then failCallback(731011, context) end -- error: already be friends
			return
		end
	end

	if self:checkCanBeAdded(pid, ext) then 
		self.http:addEventListener(Events.kComplete, onSuccess)
		self.http:addEventListener(Events.kError, onFail)
		self.http:load(tonumber(inviteCode), ADD_FRIEND_INVITE_SOURCE.WX_P2P)
	else
		if not WXJPPackageUtil.getInstance():isWXJPPackage() then 
			CommonTip:showTip(Localization:getInstance():getText("error.tip.add.friends"), "negative", nil, 3 )
			if self.withFlag then UserManager:getInstance().userExtend:setFlagBit(1, false) end
		end
	end
end

function InvitedAndRewardLogic:checkCanBeAdded(linkPf, linkExt)
	local canBeAdded = false
	local curPf = StartupConfig:getInstance():getPlatformName()
	if PlatformConfig:isQQPlatform(linkPf) then 
		if PlatformConfig:isQQPlatform(curPf) then 
			canBeAdded = true
		end
	elseif linkPf == PlatformNameEnum.kWechatAndroid then 
		canBeAdded = false
	else
		if not PlatformConfig:isQQPlatform(curPf) and curPf ~= PlatformNameEnum.kWechatAndroid then 
			canBeAdded = true
		end
	end
	return canBeAdded
end

function InvitedAndRewardLogic:_init(isShowLoad)
	if isShowLoad == nil then isShowLoad = true end
	self.http = ConfirmInvite.new(isShowLoad)
	return true
end

function InvitedAndRewardLogic:_getReward()
	local meta = MetaManager:getInstance():getEnterInviteCodeReward()
	for i = 1, 2 do
		UserManager:getInstance():addReward(meta[i])
		GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kFriend, meta[i].itemId, meta[i].num, DcSourceType.kInviteReward)
	end
end