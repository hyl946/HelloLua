-------------------------------------------------------------------------
--  Class include: SnsProxy_Android, SnsProxy_iOS, SnsProxy
-------------------------------------------------------------------------
SyncSnsFriendEvents = {
	kSyncSuccess = "syncSuccess",
	kSyncFailed = "syncFailed",
}

if __IOS_FB then
    require "hecore.sns.SnsProxyIOS"
elseif __IOS_WEIBO then
    require "hecore.sns.SnsProxyIOS_Weibo"
elseif __IOS_QQ then
	require "hecore.sns.SnsProxyIOS_Tencent"
elseif __ANDROID then
    require "hecore.sns.SnsProxyAndroid"
elseif __WP8 then
	require "hecore.sns.SnsProxyWP8"
end

if __WIN32 then 
	SnsProxy = {}

	-- SnsProxy.profile = {}

	function SnsProxy:isLogin( ... )
		return false
	end

	function SnsProxy:getAuthorizeType( ... )
		return PlatformAuthEnum.kPhone
	end

	function SnsProxy:setAuthorizeType( ... )
		-- body
	end

	function SnsProxy:logout( callback )
		callback.onSuccess()
	end

	-- function SnsProxy:getUserProfile( successCallback )
	-- 	successCallback({})
	-- end
end


if not SnsProxy then
	return
end
if not SnsProxy.profile then
	SnsProxy.profile = {}
end
function SnsProxy:isPhoneLogin()
	if not PlatformConfig:hasLoginAuthConfig(PlatformAuthEnum.kPhone) then
		return false
	end

	local lastLoginUser = Localhost.getInstance():getLastLoginUserConfig()
	if not lastLoginUser then 
		return false
	end

    local userData = Localhost.getInstance():readUserDataByUserID(lastLoginUser.uid)
    --if _G.isLocalDevelopMode then printx(0, "userData:"..table.tostring(userData)) end
    if userData and userData.openId then

        --if _G.isLocalDevelopMode then printx(0, "userData.snsType:"..table.tostring(userData.authorType)) end
        if not userData.authorType then return false end
        self:setAuthorizeType(userData.authorType) -- 使用上次登陆的平台进行判断

        if userData.authorType ~= PlatformAuthEnum.kPhone then
        	return false
        end

        return true
		-- return Localhost:time() - Localhost:getLastLoginUserConfig().time < 365 * 24 * 60 * 60 * 1000
    end

    return false
end

function SnsProxy:isPhoneLoginExpire( ... )
	return Localhost:time() - Localhost:getLastLoginUserConfig().time > 365 * 24 * 60 * 60 * 1000 	
	-- return os.time() * 1000 - Localhost:getLastLoginUserConfig().time > 30 * 24 * 60 * 60 * 1000 
end

function SnsProxy:isQQLogin()
	if not PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ) then
		return false
	end

	local lastLoginUser = Localhost.getInstance():getLastLoginUserConfig()
	if not lastLoginUser then 
		return false
	end

    local userData = Localhost.getInstance():readUserDataByUserID(lastLoginUser.uid)
    --if _G.isLocalDevelopMode then printx(0, "userData:"..table.tostring(userData)) end
    if userData and userData.openId then

        --if _G.isLocalDevelopMode then printx(0, "userData.snsType:"..table.tostring(userData.authorType)) end
        if not userData.authorType then return false end
        self:setAuthorizeType(userData.authorType) -- 使用上次登陆的平台进行判断

        if userData.authorType ~= PlatformAuthEnum.kQQ then
        	return false
        end

        return true
		-- return Localhost:time() - Localhost:getLastLoginUserConfig().time < 365 * 24 * 60 * 60 * 1000
    end

    return false
end

-- since ver1.54
function SnsProxy:isWXAppInstalled()
	if __IOS then
		return WechatOpenApiManager:getInstance():isWXAppInstalled()
	elseif __ANDROID then
		return luajava.bindClass("com.happyelements.android.utils.PackageUtils"):isPackageInstalled("com.tencent.mm")
	else
		return false
	end
end

-- since ver1.54
function SnsProxy:isOSSupportWXLogin()
	if __IOS then
		return AppController:getSystemVersion() >= 8.0
	else
		return true
	end
end

-- since ver1.54
function SnsProxy:setWechatLoginTimeOut(timeout)
	if __IOS then
		return WechatOpenApiManager:getInstance():setLoginTimeout(timeout)
	elseif __ANDROID then
		return luajava.bindClass("com.happyelements.android.wechat.WechatAuthProxy"):get():setLoginTimeout(timeout)
	end
end

-- since ver1.54
function SnsProxy:setWechatUserInfoTimeOut(timeout)
	if __IOS then
		return WechatOpenApiManager:getInstance():setGetInfoTimeout(timeout)
	elseif __ANDROID then
		return luajava.bindClass("com.happyelements.android.wechat.WechatAuthProxy"):get():setUserInfoTimeout(timeout)
	end
end
--
-- SnsProxy_Android ---------------------------------------------------------
--
-- initialize



--
-- SnsProxy_iOS ---------------------------------------------------------
--
-- initialize


--
-- SnsProxy ---------------------------------------------------------
--
--[[
function SnsProxy:isLogin()
	return false
end
-- login
function SnsProxy:login(callback) 
end

function SnsProxy:changeAccount( callback )
end

-- called
function SnsProxy:inviteFriends(callback)
end

function SnsProxy:getAllFriends(callback)
end

-- logout    
function SnsProxy:logout(callback)
end

-- called
function SnsProxy:submitScore( leaderBoardId, level )
end

function SnsProxy:showPlatformLeaderbord( )
end
-- called
function SnsProxy:purchaseItem(goodsType, itemId, itemAmount, realAmount, callback)
end
-- called
function SnsProxy:syncSnsFriend()
end
-- called
function SnsProxy:getUserProfile(successCallback,errorCallback,cancelCallback)
end
]]--