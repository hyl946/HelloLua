require "hecore.sns.SnsCallbackEvent"

FBOGActionType = {
	PASS = "pass",
	REACH = "reach",
}

FBOGObjectType = {
	LEVEL = "level",
	ACHIEVEMENT = "achievement",
	HELP = "help",
	FREEGIFT = "freegift",
}

FBRequestObject = {
	ULOCK_AREA_HELP = "647263765328588",
	ENERGY = "702670169768368",
}

SnsProxy = {profile = {}}
local proxy;
if __IOS_FB then
	FacebookProxy:getInstance():initSession()
	proxy = FacebookProxy:getInstance()
end

function SnsProxy:isShareLogin()
	return FacebookProxy:getInstance():isShareLogin()
end

function SnsProxy:shareLogin(callback)
	FacebookProxy:getInstance():shareLogin(convertCallback2FBCallback(callback))
end

function SnsProxy:isLogin()
	if __IOS_FB then
		local lastLoginUser = Localhost.getInstance():getLastLoginUserConfig()
		if not lastLoginUser then
			return false
		end

		local currentUser = Localhost.getInstance():readUserDataByUserID(lastLoginUser.uid)
		if currentUser and currentUser.openId then
			return FacebookProxy:getInstance():isLogin()
		elseif FacebookProxy:getInstance():isLogin() then -- 分享登录的账号，需要注销
			FacebookProxy:getInstance():closeSession()
		end
	end

	return false
end

function SnsProxy:setAuthorizeType(authorType)
	self.authorType = authorType
end

function SnsProxy:getAuthorizeType()
	if self.authorType then
		return self.authorType
	else
		return PlatformConfig.authConfig
	end
end

function convertCallback2FBCallback(callback)
	waxClass{"FacebookDelegateImpl",NSObject,protocols={"FacebookDelegate"}}
	function FacebookDelegateImpl:onSuccess(result)
		if self.callback then self.callback.onSuccess(result) end
	end
	function FacebookDelegateImpl:onFailed(result)
		if self.callback then self.callback.onError(result) end
	end
	local fbcb = FacebookDelegateImpl:init()
	fbcb.callback = callback
	return fbcb
end

function SnsProxy:changeAccount( callback )
	SnsProxy:login(callback)
end

function SnsProxy:login(callback)
	if __IOS_FB then
		local isLoging = true
		local fb_token = {openId = "",accessToken = ""}
		waxClass{"FBCallback",NSObject,protocols={"FacebookDelegate"}}
		function FBCallback:onSuccess(result)
			if _G.isLocalDevelopMode then printx(0, "SnsProxy:login-FBCallback:onSuccess") end
			if isLoging then
				fb_token.accessToken = result.accessToken;
				if _G.isLocalDevelopMode then printx(0, "fb_token.accessToken:" .. fb_token.accessToken) end
				local fbcb2 = FBCallback:init()
				FacebookProxy:getInstance():requestUserInfo(fbcb2)
				isLoging = false
			else
				SnsProxy.profile = {id=result.id, nick=result.name, name=result.name, headurl=result.picture.data.url}
				fb_token.openId = result.id
				if _G.isLocalDevelopMode then printx(0, "fb_token.openId:" .. fb_token.openId) end
				callback(SnsCallbackEvent.onSuccess,fb_token)
			end
		end
		function FBCallback:onFailed(result)
			if _G.isLocalDevelopMode then printx(0, "FBCallback:onFailed") end
			callback(SnsCallbackEvent.onError,result)
		end
		local fbcb = FBCallback:init()
		FacebookProxy:getInstance():login(fbcb)

		-- local function requestUserInfo() 
		-- 	local requestUserInfoCallback = {
		-- 		id = "requestUserInfoCallback",
		-- 		onSuccess = function(result) 
		-- 			if _G.isLocalDevelopMode then printx(0, "requestUserInfo result="..table.tostring(result)) end
		-- 			SnsProxy.profile = {id=result.id, nick=result.name, name=result.name, headurl=result.picture.data.url}
		-- 			fb_token.openId = result.id
		-- 			if _G.isLocalDevelopMode then printx(0, "fb_token.openId:" .. fb_token.openId) end

		-- 			callback(SnsCallbackEvent.onSuccess, fb_token)
		-- 		end,
		-- 		onError = function(err)
		-- 			if _G.isLocalDevelopMode then printx(0, "requestUserInfoCallback:onFailed") end
		-- 			callback(SnsCallbackEvent.onError,err)
		-- 		end
		-- 	}
		-- 	FacebookProxy:getInstance():requestUserInfo(convertCallback2FBCallback(requestUserInfoCallback))
		-- end

		-- local loginCallback = {
		-- 	id = "loginCallback",
		-- 	onSuccess = function( result )
		-- 		fb_token.accessToken = result.accessToken
		-- 		if _G.isLocalDevelopMode then printx(0, "fb_token.accessToken:" .. fb_token.accessToken) end
		-- 		requestUserInfo()
		-- 	end,
		-- 	onError = function(err)
		-- 		if _G.isLocalDevelopMode then printx(0, "loginCallback:onFailed") end
		-- 		callback(SnsCallbackEvent.onError,err)
		-- 	end
		-- }
		-- FacebookProxy:getInstance():login(convertCallback2FBCallback(loginCallback))	
	end
end

function SnsProxy:inviteFriends(callback)
	-- self.tabSearch.btnAdd:setEnabled(false)
	if __IOS_FB and not SnsProxy:isLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("error.tip.facebook.login"), "negative",nil, 2)
		return
	end

	if not ReachabilityUtil.getInstance():isNetworkReachable() then
		CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
		if callback then callback.onError("share not available") end
		return
	end

	local inviteCallback = {
		onSuccess = function(result)
			if _G.isLocalDevelopMode then printx(0, "result="..table.tostring(result)) end
			-- self.tabSearch.btnAdd:setEnabled(true)
			if result.snsIds and #result.snsIds > 0 then

				local function onRequestError(evt)
					if _G.isLocalDevelopMode then printx(0, "InviteFriendsHttp onRequestError callback") end
				end

				local function onRequestFinish(evt)
					if _G.isLocalDevelopMode then printx(0, "InviteFriendsHttp onRequestFinish callback") end
				end

				local http = InviteFriendsHttp.new()
                http:addEventListener(Events.kComplete, onRequestFinish)
                http:addEventListener(Events.kError, onRequestError)
                http:load(result.snsIds)
        	end

			if callback and callback.onSuccess then callback.onSuccess(result) end
        	CommonTip:showTip(Localization:getInstance():getText("share.feed.invite.success.tips"), "positive")
			DcUtil:logSendRequest("invitation",result.id,"request_invite_friends")
		end,
		onError = function(err)
			if _G.isLocalDevelopMode then printx(0, "err="..err) end
			if callback and callback.onError then callback.onError(err) end
			-- self.tabSearch.btnAdd:setEnabled(true)
			-- local scene = Director:sharedDirector():getRunningScene()
			-- if scene then
			-- 	local item = RequireNetworkAlert.new(CCNode:create())
			-- 	item:buildUI(Localization:getInstance():getText("share.feed.invite.code.faild.tips"))
			-- 	scene:addChild(item)
			-- end
		end
	}

	local profile = UserManager.getInstance().profile
	local userName = ""
	if profile and profile:haveName() then
		userName = profile:getDisplayName()
	end
	local reqMessage = Localization:getInstance():getText("facebook.request.invite.message")
	local reqTitle = Localization:getInstance():getText("facebook.request.invite.title", {user = userName})
	-- self.tabSearch.btnAdd:setEnabled(false)

	SnsProxy:sendInviteRequest(reqTitle, reqMessage, inviteCallback)
end

function SnsProxy:logout(callback)
	FacebookProxy:getInstance():logout(convertCallback2FBCallback(callback))	
end

function SnsProxy:getOperatorOne()

end

function SnsProxy:getSupportedPayments()

end

function SnsProxy:buildProxy(paymentType)

end

function SnsProxy:submitScore( leaderBoardId, level )

end

function SnsProxy:purchaseItem(goodsType, itemId, itemAmount, realAmount, callback)

end

function SnsProxy:syncSnsFriend()
	if proxy:isLogin() then
		waxClass{"SyncFriendsCallback",NSObject,protocols={"FacebookDelegate"}}
		function SyncFriendsCallback:onSuccess(result)
			if _G.isLocalDevelopMode then printx(0, "syncSnsFriend FBCallback:onSuccess") end
			local friendOpenIds = {}
			local count = 0
			-- local friendInfoList = {}
			-- local friendInfo = {}
			if result and result.data then
				local appFriends = {}
				local noneAppFriends = {}
				for i,v in ipairs(result.data) do
					if v.installed then -- app friend
						table.insert(appFriends, v)
						table.insert(friendOpenIds,v.id)

						-- friendInfo.id = v.id
						-- friendInfo.name = v.name
						-- friendInfo.headurl = v.picture.data.url
						-- table.insert(friendInfoList,friendInfo)
						count = count + 1
					else
						table.insert(noneAppFriends, v)
					end
				end
				FriendManager.getInstance().appFriends = appFriends
				FriendManager.getInstance().noneAppFriends = noneAppFriends
			end

			if count > 0 then
				local function onRequestError(evt)
					if _G.isLocalDevelopMode then printx(0, "syncSnsFriend onPreQzoneError callback") end
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncFailed))
				end

				local function onRequestFinish(evt)
					if _G.isLocalDevelopMode then printx(0, "syncSnsFriend onRequestFinish callback") end
					FriendManager.getInstance().lastSyncTime = os.time()
					HomeScene:sharedInstance().worldScene:buildFriendPicture()
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncSuccess))
				end

				if _G.isLocalDevelopMode then printx(0, "friendOpenIds:"..table.tostring(friendOpenIds)) end
				local http = SyncSnsFriendHttp.new()
                http:addEventListener(Events.kComplete, onRequestFinish)
                http:addEventListener(Events.kError, onRequestError)
                http:load(friendOpenIds)
			end
		end
		function SyncFriendsCallback:onFailed(result)
			if _G.isLocalDevelopMode then printx(0, "syncSnsFriend FBCallback:onFailed") end
			-- 获取好友列表失败，使用本地的数据
			local cachedLocalUserData = Localhost.getInstance():readCurrentUserData()
			if cachedLocalUserData and cachedLocalUserData.friends then
				FriendManager.getInstance().friends = cachedLocalUserData.friends
				if _G.isLocalDevelopMode then printx(0, "read friends from local cache="..table.tostring(FriendManager.getInstance().friends)) end
			end
		end

		local callback = SyncFriendsCallback:init()
		proxy:getFriendList(callback)
	end
end

function SnsProxy:getUserProfile(successCallback,errorCallback,cancelCallback)
	if proxy:isLogin() then
   		waxClass{"FBCallback",NSObject,protocols={"FacebookDelegate"}}
		function FBCallback:onSuccess(result)
			if _G.isLocalDevelopMode then printx(0, "SnsProxy.profile:" .. result.id .. " " .. result.name .. " " .. result.picture.data.url) end
			SnsProxy.profile = {id=result.id,nick=result.name, name=result.name, headurl=result.picture.data.url}
			UserManager.getInstance().profile.nick = result.name
			UserManager.getInstance().profile.headUrl = result.picture.data.url
			successCallback(result)
		end
		function FBCallback:onFailed(err)
			if _G.isLocalDevelopMode then printx(0, "FBCallback:onFailed") end
			errorCallback(err,"")
		end
		local fbcb = FBCallback:init()
		FacebookProxy:getInstance():requestUserInfo(fbcb)
   else
       cancelCallback()
   end
end

function SnsProxy:isShareAvailable()
	if not ReachabilityUtil.getInstance():isNetworkReachable() then
		CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
		return false
	end
	if not self:isShareLogin() then
		self:shareLogin()
		return false
	end
	return true
end

function SnsProxy:sendInviteRequest( title, message, callback )
	local params = nil
	local noneAppFriendSnsIds = FriendManager.getInstance():getNoneAppFriendSnsIds()
	if #noneAppFriendSnsIds > 0 then
		params = params or {}
		params.suggestions = table.concat(noneAppFriendSnsIds, ",")
	end
	-- params.filters = "['app_non_users']"
	FacebookProxy:getInstance():sendRequestToFriends_title_message_parameters_callback(nil, title, message, params, convertCallback2FBCallback(callback))
end

-- friendIds:{"100008167781751"},objectId:"285936521568726"
-- params:{action_type="send|askFor", object_id="OBJECT_ID", filter="", suggestions="uid1,uid2" ...} object_id和action_type必须同时存在
function SnsProxy:sendRequest(friendIds, title, message, isSend, objectId, callback)
	local params = {}
	params.action_type = isSend and "send" or "askFor"
	params.object_id = objectId
	params.data = "notification_" .. params.action_type

	local appFriendSnsIds = FriendManager.getInstance():getAppFriendSnsIds()
	if #appFriendSnsIds > 0 then
		params.suggestions = table.concat(appFriendSnsIds, ",")
	end
	FacebookProxy:getInstance():sendRequestToFriends_title_message_parameters_callback(friendIds, title, message, params, convertCallback2FBCallback(callback))
end

function SnsProxy:sendFeed( title, text, linkUrl, thumbUrl, callback )
    local params = {name=title, text=text, link=linkUrl, picture=thumbUrl} -- caption(subTitle)
    FacebookProxy:getInstance():sendFeedWithLink_callback(params, convertCallback2FBCallback(callback))
end

-- 在后台发送，因此要添加一个loading蒙版并设置超时时间
function SnsProxy:sendNewFeedsWithParams(actionType, objectType, title, description, image, link, callback, data) 
	local scene = Director:sharedDirector():getRunningScene()
	local animation
	local function removeLoading()
		if self.schedule then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
			self.schedule = nil
			animation:removeFromParentAndCleanup(true)
		end
	end
	local function onTimeout()
		if self.schedule then
			removeLoading()
			if timeoutCallback then timeoutCallback() end
		end
	end
	animation = CountDownAnimation:createShareProcessingAnimation(scene)
	scene:addChild(animation)

	self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 10, false)

	local wrapCallback = {
		onSuccess = function(result)
			removeLoading()
			if callback then callback.onSuccess(result) end
		end,
		onError = function(err)
			removeLoading()
			if callback then callback.onError(err) end
		end
	}

	local params = {}
	params.title = title
	params.description = description
	params.image = image
	-- params.url = "https://developers.facebook.com/docs/reference/android/current/interface/OpenGraphObject/"
	-- params.url = "fb607359216019419://cuteanimal/?type=newsfeed"
	FacebookProxy:getInstance():sendNewFeedsWithParameters_data_actionType_objectType_callback(params, data, actionType, objectType, convertCallback2FBCallback(wrapCallback))
end

function SnsProxy:sendFeedWithDialog(actionType, objectType, title, description, image, link, callback, data)
	local params = {}
	params.title = title
	params.description = description
	params.image = image
	-- params.url = "https://developers.facebook.com/docs/reference/android/current/interface/OpenGraphObject/"
	-- params.url = "fb607359216019419://cuteanimal/?type=newsfeed"
	FacebookProxy:getInstance():sendFeedWithDialog_data_actionType_objectType_callback(params, data, actionType, objectType, convertCallback2FBCallback(callback))
end

-- function SnsProxy:sendNewFeedsWithLocalImage(actionType, objectType, title, description, image, link, callback, data)
-- 	local params = {}
-- 	params.title = title
-- 	params.description = description
-- 	params.url = link
-- 	FacebookProxy:getInstance():sendNewFeedsWithLocalImage_parameters_data_actionType_objectType_callback(image, params, data, actionType, objectType, convertCallback2FBCallback(callback))
-- end

function SnsProxy:sendNewFeedsWithObjectId(actionType, objectType, objectId, callback)
	FacebookProxy:getInstance():sendNewFeedsWithObject_actionType_objectType_callback(objectId, actionType, objectType, convertCallback2FBCallback(callback))
end


