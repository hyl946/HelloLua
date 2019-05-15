
WXJPPackageUtil = class()
local instance = nil

WXJPLoginType = table.const {
	kQQ = "jp_login_qq",
	kWechat = "jp_login_wx",
}

function WXJPPackageUtil.getInstance()
	if not instance then
		instance = WXJPPackageUtil.new()
		instance:init()
	end
	return instance
end

function WXJPPackageUtil:init()
	self.isWXJP = false
	self.isGuset = false
	self.isMarketAdInit = false
	--发起支付时 登录态过期 
	self.errorCode1 = 1012001  --sdk返回(错误码是我自定义)
	self.errorCode2 = 1012002  --过期后登录成功
	self.errorCode3 = 1012003  --过期后登录失败
	self.errorCode4 = 1012004  --过期后选择取消 登出游戏

	if not __ANDROID then
		return 
	end
	local pfName = StartupConfig:getInstance():getPlatformName()
	if pfName and pfName == "wechat_android" then 
		self.JPMsdkProxy = luajava.bindClass("com.tencent.tmgp.AndroidAnimal.msdk.JPMsdkProxy"):getInstance()
		self.JPMidasProxy = luajava.bindClass("com.tencent.tmgp.AndroidAnimal.midas.JPMidasProxy"):getInstance()
		self.JPMarketProxy = luajava.bindClass("com.tencent.tmgp.AndroidAnimal.msdk.market.JPMarketProxy"):getInstance()
		self.wxappid = "wxa11d0f63ab762e43"
		self.isWXJP = true
	end
end

function WXJPPackageUtil:getOSVersion()
	return getOSVersionNumber() or 1
end

function WXJPPackageUtil:isWXJPPackage()
	return self.isWXJP
end

function WXJPPackageUtil:getLastLoginPF()
	if self.isWXJP then
		local isLoginForShare = self.JPMsdkProxy:getLoginForShare() 
		if isLoginForShare then 
			self.JPMsdkProxy:setLoginForShare(false) 
			self.JPMsdkProxy:cleanJPLastLoginPF() 
			return false
		else
			local pfStr = self.JPMsdkProxy:getJPLastLoginPF() 
			if pfStr then 
				if pfStr == WXJPLoginType.kQQ then 
					return PlatformAuthEnum.kJPQQ
				elseif pfStr == WXJPLoginType.kWechat then
					return PlatformAuthEnum.kJPWX
				end
			end
		end
	end
	return false
end

function WXJPPackageUtil:getDiffLoginType()
	if self.isWXJP then
		local loginType = WXJPDiffLoginUtil.getInstance():getLoginType()
		if loginType then 
			if loginType == WXJPLoginType.kQQ then 
				return PlatformAuthEnum.kJPQQ
			elseif loginType == WXJPLoginType.kWechat then
				return PlatformAuthEnum.kJPWX
			end
		end
	end
	return false
end

function WXJPPackageUtil:setGuestLogin()
	if self.isWXJP then 
		self.isGuset = true
		self.JPMsdkProxy:setLoginForShare(true)
	end
end

function WXJPPackageUtil:isGuestLogin()
	return self.isWXJP and self.isGuset
end

function WXJPPackageUtil:refreshWXToken()
	if self.isWXJP then
		return self.JPMidasProxy:refreshWXToken() 
	end
end

function WXJPPackageUtil:getAccessToken()
	local authorType = SnsProxy:getAuthorizeType()
	if authorType == PlatformAuthEnum.kJPQQ then 
		return self.JPMsdkProxy:getQQAccessToken()
	elseif authorType == PlatformAuthEnum.kJPWX then 
		return self.JPMsdkProxy:getWXAccessToken()
	end
end

function WXJPPackageUtil:getPayParam(openId)
	if self.isWXJP then
		return self.JPMidasProxy:getPayParam(openId) 
	end
end

function WXJPPackageUtil:setDefaultPayParam(openId)
	if self.isWXJP then
		return self.JPMidasProxy:setDefaultPayParamLua(openId) 
	end
end

function WXJPPackageUtil:getGameCenterUrl()
	local url = 'https://game.weixin.qq.com/cgi-bin/h5/static/gamecenter/detail.html?appid='..self.wxappid
	return url
end

-- 检测是否是jp包 sdk部分直接切换账号（如异账号）如果是 则不能用本地缓存的账号信息做登录显示
function WXJPPackageUtil:checkIsLoginAutoChange()
	if self.isWXJP then 
	    local loginUserData = Localhost.getInstance():readLastLoginUserData().user
	    local pfName = PlatformConfig:getPlatformAuthName(SnsProxy:getAuthorizeType())
	    if pfName and type(pfName) == "string" then 
		    for k,v in pairs(loginUserData.profile.snsMap) do
		        if v.snsPlatform == pfName then 
		        	return false
		        end
		    end
		end
		return true
	else
		return false
	end
end

--打开游戏中心
function WXJPPackageUtil:openGameHub(webviewCloseCB)
	if self.isWXJP then
		local cb = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = function ()
	        	-- body
	        end,
	        onError = function ()
	        	-- body
	        end,
	        onCancel = function ()
	        	if webviewCloseCB and type(webviewCloseCB) == "function"then webviewCloseCB() end
	        end
	    })
		local url = 'https://game.weixin.qq.com/cgi-bin/h5/static/circle/index.html?jsapi=1&appid='..self.wxappid..'&auth_type=2&ssid=12'
		self.JPMsdkProxy:openUrl(url, cb)
	end
end

--打开兴趣群
function WXJPPackageUtil:openInterestGroup(canCreate, webviewCloseCB)
	if self.isWXJP then 
		local urlPre = 'http://game.weixin.qq.com/cgi-bin/h5/static/chat_group/index.html?'
		local authorize = 'authorize='..tostring(canCreate).."&"
		local appid = 'appid='..self.wxappid..'&'
		local acToken = self:getAccessToken()
		if not acToken then 
			CommonTip:showTip(Localization:getInstance():getText("wxjp.interest.group.loading.tips.fail"), "positive")
			return 
		end
		local accessToken = 'access_token='..acToken

		local cb = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = function ()
	        	-- body
	        end,
	        onError = function ()
	        	-- body
	        end,
	        onCancel = function ()
	        	if webviewCloseCB and type(webviewCloseCB) == "function"then webviewCloseCB() end
	        end
	    })
		local url = urlPre..authorize..appid..accessToken
		self.JPMsdkProxy:openUrl(url, cb)
	end
end

--营销sdk部分 就是那个悬浮窗
function WXJPPackageUtil:tryShowMarketAd()
	local function show()
	    self:initMarketAd()
    	-- setTimeOut(function ()
    	-- 	self:showMarketStartView()
    	-- end, 1)
	end

	local osVersion = self:getOSVersion()
	if self.isWXJP and osVersion < 8.0 then 
		-- if MaintenanceManager:getInstance():isEnabled("WechatAndroidAD") then 
			show()
		-- else
	 --        local proName = RealNameManager:getLocationInfoCached()
	 --        if proName == "广东" then 
	 --   			show()
	 --        end
		-- end
	end
end

function WXJPPackageUtil:initMarketAd()
	if self.isWXJP and not self.isMarketAdInit then 
		local appIdType = "1"
		local authorType = SnsProxy:getAuthorizeType()
		if PlatformAuthEnum.kJPQQ == authorType then
			appIdType = "0"
		end
		local openId = "12345"
		if _G.sns_token and _G.sns_token.openId then 
			openId = _G.sns_token.openId
		end
		self.isMarketAdInit = self.JPMarketProxy:setLoginData(appIdType, openId)
	end
end

function WXJPPackageUtil:showMarketFloatView()
	if self.isWXJP and self.isMarketAdInit then 
		pcall(function ()
			self.JPMarketProxy:showFloatingAdView()
		end)
	end
end

function WXJPPackageUtil:hideMarketFloatView()
	if self.isWXJP and self.isMarketAdInit then 
		pcall(function ()
			self.JPMarketProxy:hideFloatingAdView()
		end)
	end
end


function WXJPPackageUtil:showMarketStartView()
	if self.isWXJP and self.isMarketAdInit then 
		self.JPMarketProxy:showStartAdView()
	end
end

function WXJPPackageUtil:showMarketPauseView()
	if self.isWXJP and self.isMarketAdInit then 
		self.JPMarketProxy:showPauseAdView()
	end
end

--登录过期后发起支付等操作 需提示并根据提示重新登入或者登出
function WXJPPackageUtil:showLoginExpirePanel(loginSucFunc, loginFailFunc, cancelFunc)
	local tipConfig = {tip = localize("wxjp.loading.tips.register.failure"), yes = "确定", no = "取消"}
	CommonTipWithBtn:showTip(tipConfig, "negative", function ()
		local loginType = SnsProxy:getAuthorizeType()
		SnsProxy:logout()
		if loginType or loginType == PlatformAuthEnum.kJPQQ or loginType == PlatformAuthEnum.kJPWX then
			local function onLoginSuccess(evt)
		        if _G.isLocalDevelopMode then printx(0, "showLoginExpirePanel:oauthLoginProcessor " .. "onLoginSuccess") end
		        evt.target:rma()
		      	if loginSucFunc then loginSucFunc() end
		    end

		    local function onLoginFail(evt)
		        if _G.isLocalDevelopMode then printx(0, "showLoginExpirePanel:oauthLoginProcessor " .. "onLoginFail") end
		        -- --1001：qq登录取消      2002：微信登录取消
		        -- if evt.data and evt.data.errorCode and (evt.data.errorCode == 1001 or evt.data.errorCode == 2002) then 
		        --     evt.target:rma()
		        --     if cancelFunc then cancelFunc() end
		        -- else
		        -- 	evt.target:rma()	           
		        --     if loginFailFunc then loginFailFunc() end
		        -- end

	        	evt.target:rma()	           
	            if cancelFunc then cancelFunc() end
		    end

		    local function onLoginCancel(evt)
		        if _G.isLocalDevelopMode then printx(0, "showLoginExpirePanel:oauthLoginProcessor " .. "onLoginCancel") end
		        evt.target:rma()
		        if cancelFunc then cancelFunc() end
		    end

		    local oauthLoginProcessor = require("zoo.loader.OAuthLoginWithRequestProcessor").new()
		    oauthLoginProcessor:addEventListener(Events.kComplete, onLoginSuccess)
		    oauthLoginProcessor:addEventListener(Events.kError, onLoginFail)
		    oauthLoginProcessor:addEventListener(Events.kCancel, onLoginCancel)
		    oauthLoginProcessor:start(self)
		else
			if cancelFunc then cancelFunc() end
		end
	end, function ()
		if cancelFunc then cancelFunc() end
	end)
end

function WXJPPackageUtil:restartWithDataClean()
	WXJPDiffLoginUtil.getInstance():clean()
	SnsProxy:logout()
	Localhost:getInstance():clearLastLoginUserData()
	PrepackageUtil:restart(500)
end

function WXJPPackageUtil:isWXJPLoginWX()
	if WXJPPackageUtil.getInstance():isWXJPPackage() then 
		local authorType = SnsProxy:getAuthorizeType()
		if authorType == PlatformAuthEnum.kJPWX then 
			return true
		end
	end
	return false
end