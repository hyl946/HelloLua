require "hecore.sns.SnsCallbackEvent"

SnsProxy = {profile = {}}

local proxy = TencentOpenApiManager:getInstance()

function SnsProxy:isLogin()
	if not __IOS_QQ then return false end

	if _G.isLocalDevelopMode then printx(0, "SnsProxy:isLogin") end
    local lastLoginUser = Localhost.getInstance():getLastLoginUserConfig()
    if not lastLoginUser then
        return false
    end

    local userData = Localhost.getInstance():readUserDataByUserID(lastLoginUser.uid)
    if userData and userData.openId then

        if _G.isLocalDevelopMode then printx(0, "userData.snsType:"..table.tostring(userData.authorType)) end
        if not userData.authorType then return false end
        self:setAuthorizeType(userData.authorType) -- 使用上次登陆的平台进行判断

        if userData.authorType ~= PlatformAuthEnum.kQQ and userData.authorType ~= PlatformAuthEnum.kWechat then
        	return false
        end

        return proxy:isLogin()
    end
    return false
end

function SnsProxy:changeAccount( callback )
	SnsProxy:login(callback)
end

function SnsProxy:setAuthorizeType(authorType)
	self.authorType = authorType
	if authorType == PlatformAuthEnum.kWechat then
		proxy = WechatOpenApiManager:getInstance()
		proxy:setLoginTimeout(10)
	elseif authorType == PlatformAuthEnum.kQQ then
		proxy = TencentOpenApiManager:getInstance()
	end
end

function SnsProxy:getAuthorizeType()
	if self.authorType then
		return self.authorType
	else
		return PlatformAuthEnum.kQQ --PlatformConfig.authConfig
	end
end

function SnsProxy:login(callback)
    if self:getAuthorizeType() == PlatformAuthEnum.kWechat then
    	-- 微信登录检查是否安装微信和系统版本
    	if not SnsProxy:isWXAppInstalled() then
	        if callback then callback(SnsCallbackEvent.onCancel) end
	    	CommonTip:showTip(localize("error.no.wechat1"),"negative")
	        return
	    elseif not SnsProxy:isOSSupportWXLogin() then
	    	if callback then callback(SnsCallbackEvent.onCancel) end
	    	CommonTip:showTip(localize("error.no.wechat2"),"negative")
	        return
	    end
    end

	waxClass{"LoginCallback",NSObject,protocols={"SimpleCallbackDelegate"}}
	
	function LoginCallback:onSuccess(result)
		if _G.isLocalDevelopMode then printx(0, "LoginCallback:onSuccess:"..table.tostring(result)) end
		local token = {openId = result.openId, accessToken = result.accessToken}
		if self.callback then self.callback(SnsCallbackEvent.onSuccess,token) end
	end
	function LoginCallback:onFailed(result)
		if _G.isLocalDevelopMode then printx(0, "LoginCallback:onFailed") end
		if self.callback then self.callback(SnsCallbackEvent.onError,result) end
	end
	function LoginCallback:onCancel()
		if _G.isLocalDevelopMode then printx(0, "LoginCallback:onCancel") end
		if self.callback then self.callback(SnsCallbackEvent.onCancel) end
	end

	local loginCallback = LoginCallback:init()
	loginCallback.callback = callback

	proxy:login(loginCallback)
end

function SnsProxy:logout(callback)
	waxClass{"LogoutCallback",NSObject,protocols={"SimpleCallbackDelegate"}}
	function LogoutCallback:onSuccess(result)
		if _G.isLocalDevelopMode then printx(0, "LogoutCallback:onSuccess") end
		if self.callback then callback.onSuccess(result) end
	end
	function LogoutCallback:onFailed(result)
		if _G.isLocalDevelopMode then printx(0, "LogoutCallback:onFailed") end
		if self.callback then callback.onFailed(result) end
	end
	function LogoutCallback:onCancel()
		if _G.isLocalDevelopMode then printx(0, "LogoutCallback:onCancel") end
		if self.callback then callback.onCancel() end
	end

	local logoutCallback = LogoutCallback:init()
	logoutCallback.callback = callback

	proxy:logout(logoutCallback)
end

function SnsProxy:getUserProfile(successCallback,errorCallback,cancelCallback)
	if proxy:isLogin() then
		waxClass{"GetUserProfileCallback",NSObject,protocols={"SimpleCallbackDelegate"}}
		function GetUserProfileCallback:onSuccess(result)
			if _G.isLocalDevelopMode then printx(0, "GetUserProfileCallback:onSuccess:"..table.tostring(result)) end
			
			if SnsProxy.authorType == PlatformAuthEnum.kQQ then
				SnsProxy.profile = {nick=result.nickname , name=result.nickname , headUrl=result.figureurl_qq_1}
			elseif SnsProxy.authorType == PlatformAuthEnum.kWechat then
				SnsProxy.profile = {nick=result.nickname , name=result.nickname , headUrl=result.headimgurl}
			end
			if self.successCallback then self.successCallback(result) end
		end
		function GetUserProfileCallback:onFailed(result)
			if _G.isLocalDevelopMode then printx(0, "GetUserProfileCallback:onFailed") end
			if self.errorCallback then self.errorCallback(result) end
		end
		function GetUserProfileCallback:onCancel()
			if _G.isLocalDevelopMode then printx(0, "GetUserProfileCallback:onCancel") end
			if self.cancelCallback then self.cancelCallback() end
		end

		local mCallback = GetUserProfileCallback:init()
		mCallback.successCallback = successCallback
		mCallback.errorCallback = errorCallback
		mCallback.cancelCallback = cancelCallback

		proxy:getUserProfile(mCallback)
	else
		if cancelCallback then cancelCallback() end
	end
end

function waxCallback(callback)
	waxClass{"SimpleCallbackDelegate",NSObject,protocols={"SimpleCallbackDelegate"}}
	function SimpleCallbackDelegate:onSuccess(result)
		if _G.isLocalDevelopMode then printx(0, "callback:onSuccess:"..table.tostring(result)) end
		if self.successCallback then self.successCallback(result) end
	end
	function SimpleCallbackDelegate:onFailed(result)
		if _G.isLocalDevelopMode then printx(0, "callback:onFailed") end
		if self.errorCallback then self.errorCallback(result) end
	end
	function SimpleCallbackDelegate:onCancel()
		if _G.isLocalDevelopMode then printx(0, "callback:onCancel") end
		if self.cancelCallback then self.cancelCallback() end
	end
	local mCallback = SimpleCallbackDelegate:init()
	mCallback.callback = callback;
	return mCallback
end

function SnsProxy:inviteFriends(callback)
end

function SnsProxy:syncSnsFriend()
	if not proxy:isLogin() then
		return
	end
	local accInfo = proxy:getUserAccountInfo()
	if not accInfo or not accInfo.openId or not accInfo.accessToken then
		return
	end

	local function onRequestError(evt)
		if _G.isLocalDevelopMode then printx(0, "syncSnsFriend onPreQzoneError callback") end
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncFailed))
	end

	local function onRequestFinish(evt)
		if _G.isLocalDevelopMode then printx(0, "syncSnsFriend onRequestFinish callback") end
		FriendManager.getInstance().lastSyncTime = os.time()
		FriendManager.getInstance():setQQFriendsSynced()
		if HomeScene:hasInited() then
            HomeScene:sharedInstance().worldScene:buildFriendPicture()
        else
            HomeScene.needBuildFriendPicture = true
        end
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncSuccess))
	end

	local http = SyncSnsFriendHttp.new()
    http:addEventListener(Events.kComplete, onRequestFinish)
    http:addEventListener(Events.kError, onRequestError)
    http:load(nil, accInfo.openId, accInfo.accessToken)
end

function SnsProxy:shareImageToQQ( title, text, linkUrl, thumbUrl, callback )
    proxy:shareWithImage_thumb_title_text_callback(linkUrl, thumbUrl, title, text, waxCallback(callback))
end

-- 系统分享
function SnsProxy:shareImage( shareType, title, text, imageUrl, thumbUrl, callback, toTimeline )
	if (shareType == PlatformShareEnum.kWeibo) then
		WeiboShareUtilBridge:shareImage_text_callback(imageUrl, text, callback)
	else
	    SystemShareUtil:shareImage_subject_thumb_callback(imageUrl, text, thumbUrl, nil)
	end
end

function SnsProxy:shareText( shareType, title, text, callback, toTimeline )
	if (shareType == PlatformShareEnum.kWeibo) then
		WeiboShareUtilBridge:shareText_callback(text, callback)
	else
	    he_log_error('SnsProxy:shareText IOS not implemented')
	end
end

-- 系统分享
function SnsProxy:shareLink( shareType, title, text, linkUrl, thumbUrl, callback, toTimeline )
	if (shareType == PlatformShareEnum.kWeibo) then
		WeiboShareUtilBridge:shareLink_text_title_image_callback(linkUrl, text, title, thumbUrl, callback)
	else
	    SystemShareUtil:shareLink_subject_thumb_callback(linkUrl, title, thumbUrl, nil)
	end
end


