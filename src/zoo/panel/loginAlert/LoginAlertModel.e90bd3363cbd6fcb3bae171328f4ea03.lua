require "zoo.net.OtherConnectLogic"

LoginAlertModel = class(EventDispatcher)

LoginAlertModel.EVENT_TYPE = {
	kContinue = "continue",
	kBackToLogin = "backToLogin",
	kToAccountBindLogin = "toAccountBindLogin"
}

LoginAlertModel.CONFIG = {
	kMinLoginCount = 2,
	kMinTopLevel = 10,
}

function LoginAlertModel:create()
	local model = LoginAlertModel:new()
	model:init()
	return model
end

local function debugInfo(...)
	RemoteDebug:uploadLogWithTag(...)
end
-----------------------------------------------------------------------------------------------
---------------------------以下测试代码   testFlag = true时 测试数据生效-----------------------
-----------------------------------------------------------------------------------------------
local testFlag = false

--推荐账号选登录次数比较多的那个账号
function LoginAlertModel:getCurTestData()
	return {
			{
uid = "490464111",
platformShopUrl = "http://app.so.com/detail/index?pname=com.happyelements.AndroidAnimal&id=1625930",
platform = "360",
packageName = "com.happyelements.AndroidAnimal",
updateTime = "1488954896340",
topLevelId = 930,
cash = 13,
loginCount = 1,
headUrl = "http://animal-10001882.image.myqcloud.com/9b0ad3cc-a49c-4c43-8479-64989a2aa06d",
apkDownloadUrl = "http://shouji.360tpcdn.com/170223/cd8f38c87f8243bcf019cfc0d0cd40c0/com.happyelements.AndroidAnimal_42.apk",
loginType = 5},
{
uid = "615366445",
platformShopUrl = "",
platform = "wechat_android",
packageName = "com.tencent.tmgp.AndroidAnimal",
updateTime = "1488955070054",
topLevelId = 151,
cash = 0,
loginCount = 1,
headUrl = "9",
apkDownloadUrl = "",
loginType = 8},
{
uid = "61106942",
platformShopUrl = "",
platform = "he",
packageName = "",
updateTime = "1488963453586",
topLevelId = 510,
cash = 0,
loginCount = 1,
headUrl = "http://tp1.sinaimg.cn/5216302964/50/0/1",
apkDownloadUrl = "",
loginType = 1},
{
uid = "1541740490",
platformShopUrl = "",
platform = "he",
packageName = "",
updateTime = "1489025798685",
topLevelId = 501,
cash = 3,
loginCount = 1,
headUrl = "http://q.qlogo.cn/qqapp/100718846/D9DB576F83FED83AB87A26E7A27621CA/40",
apkDownloadUrl = "",
loginType = 2}
	}
end

function LoginAlertModel:getAnotherServerTestData()
	return {apkDownloadUrl = "http://imtt.dd.qq.com/16891/5D17222AB739018A355F247853B1489E.apk?fsname=com.happyelements.AndroidAnimal.qq_1.42_42.apk&csr=4d5s",
cash = 28,
headUrl = "http://q.qlogo.cn/qqapp/100718846/D9DB576F83FED83AB87A26E7A27621CA/40",
loginCount = 12,
loginType = 2,
packageName = "com.happyelements.AndroidAnimal.qq",
platform = "yingyongbao",
platformShopUrl = "http://a.app.qq.com/o/simple.jsp?pkgname=com.happyelements.AndroidAnimal.qq",
topLevelId = 1030,
uid = 218325514,
updateTime = 1488963656987}
end
-----------------------------------------------------------------------------------------------
---------------------------以上测试代码   testFlag = true时 测试数据生效-----------------------
-----------------------------------------------------------------------------------------------

local _instance

LoginAlertModel.ALERT_TYPE = {
	DIFFERENT_SERVER_PKG_AVAILABLE = 1,--不同服务器，PKG可下载
	DIFFERENT_SERVER_PKG_UNAVAILABLE = 2,--不同服务器，PKG不可下载
	SAME_SERVER_SAME_PKG_SAME_BIND_TYPE = 3,--相同服务器，相同PKG，相同账户绑定
	SAME_SERVER_SAME_PKG_DIFFERENT_BIND_TYPE = 4,--相同服务器，相同PKG，不同账户绑定
	SAME_SERVER_DIFFERENT_PKG_AVAILABLE = 5,--相同服务器，不同PKG
	SAME_SERVER_DIFFERENT_PKG_UNAVAILABLE = 6,--相同服务器，不同PKG，且不能下载
	NEED_OVERLOAD_INSTALL = 7, --需要覆盖安装
	AUTH_REMOVED_WITHOUT_OTHER_SNS = 8  --建议的登录方式被删除 去看客服页面
}

function LoginAlertModel:cannotDownload()
	if self.adviceLoginInfo.apkDownloadUrl == nil or #self.adviceLoginInfo.apkDownloadUrl == 0 then
		if self.adviceLoginInfo.platformShopUrl == nil or #self.adviceLoginInfo.platformShopUrl == 0 then
			return true
		else
			return false
		end
	end

	return false
end

function LoginAlertModel:canDownloadAPK()
	return self.adviceLoginInfo.apkDownloadUrl ~= nil and #self.adviceLoginInfo.apkDownloadUrl > 0
end

function LoginAlertModel:getAlertType()
	if self.adviceLoginInfo ~= nil then
		if __IOS then
			if self.adviceLoginInfo.loginType ~= nil and PlatformConfig:hasLoginAuthConfig(self.adviceLoginInfo.loginType) then
			   	if self.currentLoginInfo.loginType == self.adviceLoginInfo.loginType then
					return LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_SAME_BIND_TYPE
				else
					return LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_DIFFERENT_BIND_TYPE
				end
			end
			return nil
		end

		local adviceLoginType = self.adviceLoginInfo.loginType
		-- if false then

		if PlatformConfig.name ~= PlatformNameEnum.kMiPad and PlatformConfig:isRemovedAuthConfigs(adviceLoginType) then

			local otherSnsPlatforms = self.adviceLoginInfo.otherSnsPlatforms or {}

			local validSnsPlatforms = table.filter(otherSnsPlatforms, function ( snsName )
				local authConfig = PlatformConfig:getPlatformAuthByName(snsName)
				return not PlatformConfig:isRemovedAuthConfigs(authConfig)
			end) or {}

			local snsSupportedByAdvicePkg = PlatformConfig:getOtherPlatformAuthConfig(self.adviceLoginInfo.platform)
		
			local priority = {
				[PlatformAuthEnum.kPhone] = 1,
				[PlatformAuthEnum.kQQ] = 2,
				[PlatformAuthEnum.k360] = 3,
				[PlatformAuthEnum.kMI] = 4,
				[PlatformAuthEnum.kWeibo] = 5,
				[PlatformAuthEnum.kWechat] = 6,
			}

			table.sort(validSnsPlatforms, function ( a, b )
				local Priority_A = priority[a]
				local Priority_B = priority[b]

				if Priority_A and Priority_B then
					return Priority_A < Priority_B
				else
					return (tostring(a) or '') < (tostring(b) or '')
				end
			end)

			local function hasSnsSupportedByAdvicePkg( ... )
				for _, snsName in ipairs(validSnsPlatforms) do
					local authConfig = PlatformConfig:getPlatformAuthByName(snsName)
					if table.exist(snsSupportedByAdvicePkg, authConfig) then
						return true, authConfig
					else
						return false
					end
				end
			end

			if #validSnsPlatforms > 0 then
				if self.adviceLoginInfo.anotherServer then

					local supported, authConfig = hasSnsSupportedByAdvicePkg()
					
					if supported then

						self.adviceLoginInfo.loginType = authConfig

						if self:cannotDownload() then
							return LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_UNAVAILABLE
						else
							return LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_AVAILABLE
						end

					else
						return LoginAlertModel.ALERT_TYPE.AUTH_REMOVED_WITHOUT_OTHER_SNS
					end
				else
					local supportAuthConfig = nil
					for _, snsName in ipairs(validSnsPlatforms) do
						local authConfig = PlatformConfig:getPlatformAuthByName(snsName)
						if PlatformConfig:hasLoginAuthConfig(authConfig) then
							supportAuthConfig = authConfig
							break
						end
					end

					if supportAuthConfig then
						self.adviceLoginInfo.loginType = supportAuthConfig
					else

						local supported, authConfig = hasSnsSupportedByAdvicePkg()
						if supported then
							self.adviceLoginInfo.loginType = authConfig
							if self:cannotDownload() then
								return LoginAlertModel.ALERT_TYPE.SAME_SERVER_DIFFERENT_PKG_UNAVAILABLE
							else
								return LoginAlertModel.ALERT_TYPE.SAME_SERVER_DIFFERENT_PKG_AVAILABLE
							end
						else
							return LoginAlertModel.ALERT_TYPE.AUTH_REMOVED_WITHOUT_OTHER_SNS
						end
					end
				end
			else
				return LoginAlertModel.ALERT_TYPE.AUTH_REMOVED_WITHOUT_OTHER_SNS
			end
		end

		if self.adviceLoginInfo.anotherServer then
			if self:cannotDownload() then
				return LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_UNAVAILABLE
			else
				return LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_AVAILABLE
			end
		else
			if self.adviceLoginInfo.loginType == PlatformAuthEnum.kGuest then
				self:correctAdviceLoginType()
			end

			if self.adviceLoginInfo.loginType ~= nil and PlatformConfig:hasLoginAuthConfig(self.adviceLoginInfo.loginType) then
			   	if self.currentLoginInfo.loginType == self.adviceLoginInfo.loginType then
					return LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_SAME_BIND_TYPE
				else
					return LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_DIFFERENT_BIND_TYPE
				end
			else
				--相同包名情况处理
				if self.adviceLoginInfo.packageName == nil or 
				   #self.adviceLoginInfo.packageName == 0 or 
				   self.adviceLoginInfo.packageName == _G.packageName then
						return LoginAlertModel.ALERT_TYPE.NEED_OVERLOAD_INSTALL
				--不同包名情况处理
				else
					if self:cannotDownload() then
						return LoginAlertModel.ALERT_TYPE.SAME_SERVER_DIFFERENT_PKG_UNAVAILABLE
					else
						return LoginAlertModel.ALERT_TYPE.SAME_SERVER_DIFFERENT_PKG_AVAILABLE
					end
				end
			end
		end
	end

	return nil
end

---------------------------------------------------------------------------------------------------------------------------------------------------------
--   历史原因，loginType字段可能为0，这是一个错误的值。洗包只会有（左游客，右账号）（左账号，右账号）两种情况出现，尝试修复loginType字段
----------------------------------------------------------------------------------------------------------------------------------------------------------
function LoginAlertModel:correctAdviceLoginType()
	local pfs = self.adviceLoginInfo.otherSnsPlatforms
	if pfs ~= nil and #pfs > 0 then
		local curPkgEnableAuthAry = {}
		local curPkgDisableAuthAry = {}
		for i=1, #pfs do
			local authType = PlatformConfig:getPlatformAuthByName(pfs[i])
			if authType ~= nil then
				local adviceInfo = {loginType = authType, platform = pfs[i]}
				if PlatformConfig:hasLoginAuthConfig(authType) then
					curPkgEnableAuthAry[#curPkgEnableAuthAry + 1] = adviceInfo
				else
					curPkgDisableAuthAry[#curPkgDisableAuthAry + 1] = adviceInfo
				end
			end
		end

		if #curPkgEnableAuthAry > 0 then
			self.adviceLoginInfo.loginType = curPkgEnableAuthAry[1].loginType
			self.adviceLoginInfo.platform = "common"
		elseif #curPkgDisableAuthAry > 0 then
			self.adviceLoginInfo.loginType = curPkgDisableAuthAry[1].loginType
			self.adviceLoginInfo.platform =  "adviceCommon"
		end
	end
end

function LoginAlertModel:getInstance()
	if _instance == nil then
		_instance = LoginAlertModel:create()
	end

	return _instance
end

function LoginAlertModel:closeAlertPanel()
	setTimeOut(function()
		self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
	end, 0.1)
end

function LoginAlertModel:backToLogin()
	PlatformConfig:snsLogout(function ()
		self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kBackToLogin, nil, self))
	end)
end

function LoginAlertModel:toAccountBindLogin()
	PlatformConfig:snsLogout(function ()
		self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kToAccountBindLogin, nil, self))
	end)
end

function LoginAlertModel:bindAccount(onSuccess, onError)
	local openId = _G.sns_token.openId
	local accessToken = _G.sns_token.accessToken
	local authorType = _G.sns_token.authorType
	local snsName = SnsProxy.profile and SnsProxy.profile.nick or nil
    if authorType == PlatformAuthEnum.kPhone then
        snsName = Localhost:getLastLoginPhoneNumber()
    end
    local otherUid = self.adviceLoginInfo.uid

	local logic = OtherConnectLogic.new(otherUid, authorType, openId, accessToken, snsName)
	logic:execute(onSuccess, onError)
end

function LoginAlertModel:init()
	self.currentLoginInfo = nil
	self.adviceLoginInfo = nil
	self.sameServerAdviceInfo = nil
	self.anotherServerAdviceInfo = nil
end

function LoginAlertModel:checkAlert()
	if testFlag then
		self:getLoginInfos() --------------------------------------------------------------to test lhl
		if true then return end
	end

	if PrepackageUtil:isPreNoNetWork() then
		self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
		return
	end

  --   if not __ANDROID then
		-- self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
		-- return
  --   end

    if __ANDROID then
	    if WXJPPackageUtil.getInstance():isWXJPPackage() then 
	    	self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
			return
	    end

	    if require('zoo.panel.WDJAlertPanel'):shouldSkipXiBaoCheck() then
	    	self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
	    	return
	    end
	end
    
    local uid = UserManager:getInstance().uid
    local loginNum = self:getCurUserLoginNum()
	-- CommonTipWithBtn:showTip({tip = "read: " .. loginNum, yes = "好"}, "negative", nil, nil, nil, true)
	if _G._UploadDebugLog then debugInfo("checkAlertStart", uid, loginNum, kDeviceID) end
    if not uid or kDeviceID == uid or loginNum > 1 then
		self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
		return
	else
		self:getLoginInfos()
    end
end

function LoginAlertModel:writeLoginInfo(num)
	local uid = UserManager:getInstance().uid or "12345"
	local loginNum
	if num ~= nil then
		loginNum = num
	else
		loginNum = self:getCurUserLoginNum()
		loginNum = loginNum + 1
	end
	CCUserDefault:sharedUserDefault():setIntegerForKey("loginInfo" .. uid, loginNum)
end

function LoginAlertModel:getCurUserLoginNum()
	local uid = UserManager:getInstance().uid or "12345"
	local loginNum = CCUserDefault:sharedUserDefault():getIntegerForKey("loginInfo" .. uid) or 0
    return loginNum
end

function LoginAlertModel:getLoginInfos()
	self.infoStep = 0
	local uid = UserManager:getInstance().uid or "12345"
	self.currentLoginInfo = { uid = uid, 
							  topLevelId = UserManager:getInstance().user:getTopLevelId(),
							  platform = PlatformConfig.name,
							  loginType = _G.kLoginType,
							  loginCount = 1, --当前登录用户目前用不到这个字段
							  cash = UserManager:getInstance().user:getCash(),
							  updateTime = UserManager:getInstance().lastLoginTime,
							  headUrl = UserManager:getInstance().profile.headUrl,
							}
	if self.currentLoginInfo.updateTime == nil then
		self.currentLoginInfo.updateTime = 0
	end
	if _G._UploadDebugLog then debugInfo("canAccountBeMerged_currentLoginInfo", table.tostring(self.currentLoginInfo)) end

	if self.currentLoginInfo.loginType == nil or 
	   self.currentLoginInfo.platform == nil or
	   self.currentLoginInfo.topLevelId == nil or
	   self.currentLoginInfo.cash == nil or
	   self.currentLoginInfo.headUrl == nil
	then
		self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
		return
	end

	self:getCurrentPlatformLoginInfos()
	self:getAnotherServerLoginInfos() --获取另一台服务器的登录信息  应用宝非应用宝相对
end

--------拉取当前服务器上用户登录信息历史记录
function LoginAlertModel:getCurrentPlatformLoginInfos( ... )
	local function onSucess(evt)
		self.infoStep = self.infoStep + 1
		if evt ~= nil and evt.data ~= nil then
			local loginInfos = evt.data.loginInfos
			if loginInfos ~= nil and type(loginInfos) == 'table' and #loginInfos > 0 then
				self:trimLoginInfos(loginInfos)
				self:countToAlert()
			else
				self:countToAlert()

			end
		else
			self:countToAlert()
		end
	end

	local function onError()
		self.infoStep = self.infoStep + 1
		self:countToAlert()
	end

	------------------------------------------------------------------------------- test lhl 测试代码
	if testFlag then
	 	onSucess({data = self:getCurTestData()})
	else
		--正式情况下打开
		local http = GetLoginInfosHttp.new()
		http:addEventListener(Events.kComplete, onSucess)
		http:addEventListener(Events.kError, onError)
		http:load()
	end
	
end

--------找出当前服务器上推荐用户
function LoginAlertModel:trimLoginInfos(loginInfos)
	local uid = UserManager:getInstance().uid or 0
	uid = tonumber(uid) or 0

	local maxLoginCount = loginInfos[1].loginCount
	for i, v in ipairs(loginInfos) do
		local vUid = v.uid or 0
		if v.uid ~= nil then 
			vUid = tonumber(v.uid) or 0
		end

		if vUid ~= uid and v.loginCount > maxLoginCount then
			maxLoginCount = v.loginCount
		end

		if vUid == uid then
			self.currentLoginInfo.loginCount = v.loginCount
		end
	end

	local maxLoginCountGroup = {}
	for i, v in ipairs(loginInfos) do
		local vUid = v.uid or 0
		if v.uid ~= nil then 
			vUid = tonumber(v.uid) or 0
		end

		if v.loginCount == maxLoginCount and vUid ~= uid and (v.platform ~= nil and #v.platform > 0) then
			table.insert(maxLoginCountGroup, v)
		end
	end

	local maxTopLevelLoginInfo = maxLoginCountGroup[1]
	if #maxLoginCountGroup > 0 then
		maxTopLevelLoginInfo = maxLoginCountGroup[1]
		for i, v in ipairs(maxLoginCountGroup) do
			if v.topLevelId > maxTopLevelLoginInfo.topLevelId then
				maxTopLevelLoginInfo = v
			end
		end
	end

	local finalLoginInfo = maxTopLevelLoginInfo
	if finalLoginInfo and 
	   finalLoginInfo.loginCount > LoginAlertModel.CONFIG.kMinLoginCount and 
	   finalLoginInfo.topLevelId > LoginAlertModel.CONFIG.kMinTopLevel then
		self.sameServerAdviceInfo = finalLoginInfo
	end
end

--------拉取相对服务器（应用宝，非应用宝相对）上用户登录信息历史记录
function LoginAlertModel:getAnotherServerLoginInfos( ... )
	if __IOS then
		self.anotherServerAdviceInfo = nil
		self.infoStep = self.infoStep + 1
		self:countToAlert()
		return
	end

	if testFlag then
		self.anotherServerAdviceInfo = self:getAnotherServerTestData()
		self.infoStep = self.infoStep + 1
		self:countToAlert()
		if self.anotherServerAdviceInfo ~= nil then
			self.anotherServerAdviceInfo.anotherServer = true
		end
		return
	end

	local uid = UserManager:getInstance().uid
	local qqServerURL = "http://mobile.app100718846.twsapp.com/" 
	local otherServerURL = "http://animalmobile.happyelements.cn/"
	local isYYB = PlatformConfig:isQQPlatform()
	local url = isYYB and otherServerURL or qqServerURL 
	local function  callback(success, data)
		if success then
			DeviceLoginInfos:setAnotherServerLoginInfos(data)

			self.anotherServerAdviceInfo = data
			if self.anotherServerAdviceInfo ~= nil then
				self.anotherServerAdviceInfo.anotherServer = true
    		end
		end
		self.infoStep = self.infoStep + 1
		self:countToAlert()
	end
	DeviceLoginInfos:requestDeviceLoginInfo(url, callback)
end

------根据两台服务器上的登录数据，查看是否需要弹登录提醒的面板
function LoginAlertModel:countToAlert()
	if self.infoStep >= 2 then --已经拉取到两个服务器的登录数据
		if self.sameServerAdviceInfo and self.anotherServerAdviceInfo then
			if self.sameServerAdviceInfo.loginCount >= self.anotherServerAdviceInfo.loginCount then
				self.adviceLoginInfo = self.sameServerAdviceInfo
			else
				self.adviceLoginInfo = self.anotherServerAdviceInfo
			end
		else
			self.adviceLoginInfo = self.sameServerAdviceInfo or self.anotherServerAdviceInfo
		end
		if _G._UploadDebugLog then debugInfo("countToAlert", self.adviceLoginInfo ~= nil) end
		if self.adviceLoginInfo ~= nil then
			local alertType = self:getAlertType()
			local function callback(data)
				if data and data.ok then
					if _G._UploadDebugLog then debugInfo("popoutBindAlertPanel1") end
					self:popoutBindAlertPanel()
				else
					if _G._UploadDebugLog then debugInfo("popoutBindAlertPanel2", self.currentLoginInfo.loginCount, self.adviceLoginInfo.loginCount) end
					if self.currentLoginInfo.loginCount >= self.adviceLoginInfo.loginCount then
						self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
						return
					end
					if __IOS then
						self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
						return
					end

					local function onSucess(installFlag)
						self.isAdviceAppInstalled = installFlag
						self:popoutAlertPanel()
					end
					local function onError(errCode)
						self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
					end
					if __WIN32 then
						onSucess(true)
					else
						PackageUtil.isPackageInstalled(self.adviceLoginInfo.packageName, onSucess, onError)
					end
				end
			end
			self:checkAccountBind(alertType, callback)
		else		
			self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
		end
	end
end

function LoginAlertModel:popoutBindAlertPanel()
	local LoginAlertPanelCls = require "zoo.panel.loginAlert.LoginBindAlertPanel"
	LoginAlertPanelCls:create():popout()
end

function LoginAlertModel:popoutAlertPanel()
	-- self:dispatchEvent(Event.new(LoginAlertModel.EVENT_TYPE.kContinue, nil, self))
	-- if true then return end
	if self.currentLoginInfo.platform == nil or #self.currentLoginInfo.platform < 1 then
		self.currentLoginInfo.platform = "common"
	end
	if self.adviceLoginInfo.platform == nil or #self.adviceLoginInfo.platform < 1 then
		self.adviceLoginInfo.platform = "adviceCommon"
	end
	
	local LoginAlertPanelCls = require "zoo.panel.loginAlert.LoginAlertPanel"
	LoginAlertPanelCls:create():popout()

	-- local a = require "zoo.panel.loginAlert.DownloadTargetApkPanel" --测试代码
	-- a:create():popout()
end

function LoginAlertModel:checkAccountBind(alertType, callback)
	if self:canAccountBeMerged(alertType) then
		local sns_token = _G.sns_token
		if _G._UploadDebugLog then debugInfo("checkAccountBind", table.tostring(sns_token)) end
		if sns_token and sns_token.openId and sns_token.accessToken and sns_token.authorType then
			local function onFinish(data)
				callback(data)
			end
			local function onError( ... )
				callback(nil)
			end
			local otherUid = tonumber(self.adviceLoginInfo.uid)
			local logic = OtherConnectPreLogic.new(otherUid, sns_token.authorType)
			logic:execute(onFinish, onError)
		else
			callback(nil)
		end
	else
		callback(nil)
	end
end

function LoginAlertModel:canAccountBeMerged(alertType)
	local alertType = alertType or self:getAlertType()
	if _G._UploadDebugLog then debugInfo("canAccountBeMerged_adviceLoginInfo", table.tostring(_G.sns_token), table.tostring(self.adviceLoginInfo)) end
	if  alertType == LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_DIFFERENT_BIND_TYPE then
		if not (_G.sns_token and _G.sns_token.openId and _G.sns_token.accessToken and _G.sns_token.authorType) then
			return false
		end
		local topLevelId = UserManager.getInstance().user:getTopLevelId()
		if _G._UploadDebugLog then debugInfo("canAccountBeMerged_topLevelId", topLevelId) end
		if topLevelId > 30 then return false end

		local lastPayTime = tonumber(UserManager.getInstance().userExtend:getLastPayTime()) or 0
		if _G._UploadDebugLog then debugInfo("canAccountBeMerged_lastPayTime", lastPayTime) end
		if lastPayTime > 0 then return false end

		local snsMap = UserManager.getInstance().profile.snsMap
		if _G._UploadDebugLog then debugInfo("canAccountBeMerged_snsMap", table.tostring(snsMap)) end
		if snsMap and table.size(snsMap) > 1 then return false end

		local otherSnsPlatforms = self.adviceLoginInfo.otherSnsPlatforms or {}
		local authorType = _G.sns_token.authorType
		local snsPlatform = PlatformConfig:getPlatformAuthName(authorType)
		if _G._UploadDebugLog then debugInfo("canAccountBeMerged_otherSnsPlatforms", table.tostring(otherSnsPlatforms)) end
		if table.includes(otherSnsPlatforms, snsPlatform) then return false end

		return true
	else
		if _G._UploadDebugLog then debugInfo("canAccountBeMerged_AlertType", alertType) end
	end
	return false
end

function LoginAlertModel:getAdviceApkPath()
	local apkName = self:getAdviceApkName()
	if apkName ~= nil then
		local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local apkPath = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext()) .. 	"/" .. apkName
		-- CommonTipWithBtn:showTip({tip = apkPath, yes = "好"}, "negative", nil, nil, nil, true)
		return apkPath
	end
	return nil
end

function LoginAlertModel:getAdviceApkName()
	--"http://downloadapk.manimal.happyelements.cn/apk/aaaa.apk?md5=1111"
	local apkUrl = self.adviceLoginInfo.apkDownloadUrl
	if apkUrl == nil or #apkUrl < 1 then return nil end
	local apkUrlAry = apkUrl:split("/")
	apkUrl = apkUrlAry[#apkUrlAry]
	apkUrlAry = apkUrl:split("?")
	return apkUrlAry[1]
end

function LoginAlertModel:getApkMd5()
	--"http://downloadapk.manimal.happyelements.cn/apk/aaaa.apk?md5=1111"
	local apkUrl = self.adviceLoginInfo.apkDownloadUrl
	local apkUrlAry = apkUrl:split("/")
	apkUrl = apkUrlAry[#apkUrlAry]
	apkUrlAry = apkUrl:split("?")
	if apkUrlAry and #apkUrlAry >= 2 then
		return apkUrlAry[2]
	end

	return nil
end

function LoginAlertModel:adviceApkExist()
	if not __ANDROID then
		return false
	end

	local apkPath = self:getAdviceApkPath()
	if apkPath ~= nil then
		local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")
		return FileUtils:isExist(apkPath)
	end

	return false
end

function LoginAlertModel:adviceAppInstalled()
	return self.isAdviceAppInstalled
end

function LoginAlertModel:isSupportAdviceLoginTypes()
	local snsPlatform = self.adviceLoginInfo and self.adviceLoginInfo.otherSnsPlatforms or {}
	for _, v in pairs(snsPlatform) do
		local authType = PlatformConfig:getPlatformAuthByName(snsName)
		if authType and PlatformConfig:hasLoginAuthConfig(authType) then
			return true
		end
	end
	return false
end

function LoginAlertModel:log(t5)
	local dcData = {}
	dcData.category = "UI"
	if self.dcSubCategory == nil then self.dcSubCategory = self:getDCSubCategory() end
	dcData.sub_category = self.dcSubCategory
	dcData.t1 = self.adviceLoginInfo.loginType
	dcData.t2 = self.currentLoginInfo.loginType
	dcData.t3 = self.adviceLoginInfo.platform
	dcData.t4 = self.currentLoginInfo.platform
	dcData.t5 = t5
    DcUtil:log(AcType.kUserTrack, dcData)
end

function LoginAlertModel:getDCSubCategory()
	local alertType = self:getAlertType()
	if alertType == LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_AVAILABLE or 
	   alertType == LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_UNAVAILABLE then
	   return "xibaoyyb"
	else
		if self.currentLoginInfo.loginType == self.adviceLoginInfo.loginType then return "xibaosns"
		elseif self.currentLoginInfo.loginType == PlatformAuthEnum.kGuest or
		       self.adviceLoginInfo.loginType == PlatformAuthEnum.kGuest then return "xibaoyk"
		else return "xibaobsns" end
	end
end