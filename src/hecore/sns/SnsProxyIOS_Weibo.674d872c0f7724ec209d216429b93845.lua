require "hecore.sns.SnsCallbackEvent"

SnsProxy = {profile = {}}

local proxy
if __IOS_WEIBO then proxy = WeiboManager:getInstance() end

function SnsProxy:isLogin()
	if not __IOS_WEIBO then return false end
	
    local lastLoginUser = Localhost.getInstance():getLastLoginUserConfig()
    if not lastLoginUser then
        return false
    end

    local userData = Localhost.getInstance():readUserDataByUserID(lastLoginUser.uid)
    if userData and userData.openId then
        return proxy:isLogin()
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

function SnsProxy:changeAccount( callback )
	SnsProxy:login(callback)
end
function SnsProxy:login(callback)
	if __IOS_WEIBO then
		waxClass{"WeiboCallback",NSObject,protocols={"WeiboDelegate"}}
		function WeiboCallback:onSuccess(result)
			if _G.isLocalDevelopMode then printx(0, "WeiboCallback:onSuccess") end
			SnsProxy.profile = {id=result.userID, name=result.nickName, nick=result.nickName, headurl=result.headURL}
			local token = {openId = result.userID,accessToken = result.accessToken}
			callback(SnsCallbackEvent.onSuccess,token)
		end
		function WeiboCallback:onFailed(result)
			if _G.isLocalDevelopMode then printx(0, "WeiboCallback:onFailed") end
			callback(SnsCallbackEvent.onError,result)
		end

		proxy:login(WeiboCallback:init())
	end
end

function SnsProxy:logout(callback)
	if __IOS_WEIBO then
		waxClass{"WeiboCallback",NSObject,protocols={"WeiboDelegate"}}
		function WeiboCallback:onSuccess(result)
			if _G.isLocalDevelopMode then printx(0, "logout WeiboCallback:onSuccess") end
			callback.onSuccess(result)
		end
		function WeiboCallback:onFailed(result)
			if _G.isLocalDevelopMode then printx(0, "logout WeiboCallback:onFailed") end
			callback.onFailed(result)
		end
		proxy:logout(WeiboCallback:init())
	end		
end

function SnsProxy:getUserProfile(successCallback,errorCallback,cancelCallback)
	local profile = SnsProxy.profile
	if profile.nick and profile.headUrl then
   		UserManager.getInstance().profile.nick = profile.nick
		UserManager.getInstance().profile.headUrl = profile.headUrl
		successCallback(result)
   else
       cancelCallback()
   end
end