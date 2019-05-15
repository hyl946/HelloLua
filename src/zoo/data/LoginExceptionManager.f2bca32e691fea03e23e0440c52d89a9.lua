require "zoo.common.FAQ"

LoginExceptionManager = class()

local instance = nil

local ExceptionCode = table.const{
	kItemOverdue = 730308,
	kItemNotExist = 730311,
	kPassThrough = 730603,
	kEnergyNotEnough = 730326,
	kEnergyNotEnoughTwo = 730331,
	kPayError = 730211,
	kPayErrorTwo = 730402,
	kUserBaned = 109,
}

ExceptionErrorCodeIgnore = table.const{
	kServerUniformErrorCode = 203,
	--rpc.lua  line470 
	kServerUniformErrorCode_Two = -6
}

function LoginExceptionManager:getInstance()
	if not instance then
		instance = LoginExceptionManager.new()
		instance:init()
	end
	return instance
end

function LoginExceptionManager:ctor()
	
end

function LoginExceptionManager:init()
	self.shouldShowFunsClub = false
	self.showFunsClubWithoutUserLogin = false
	self.userDefault = CCUserDefault:sharedUserDefault()
	self.errorHistory = self.userDefault:getStringForKey("login.exception.error.history")
	self.tipLabel = ""
	self.errorCodeCache = ExceptionErrorCodeIgnore.kServerUniformErrorCode_Two
end

function LoginExceptionManager:updateErrorHistory(errorCode)
	if not errorCode then return end
	
	local historyTable = string.split(self.errorHistory, "|")
	local num = #historyTable
	if num == 5 then 
		table.remove(historyTable, 1)
	end
	local errorItem = errorCode..":"..os.date()
	table.insert(historyTable, errorItem)

	local tempErrorHistroy = ""
	for i,v in ipairs(historyTable) do
		local item = v
		if i ~= 1 then
			item = "|"..item
		end
		tempErrorHistroy = tempErrorHistroy .. item
	end
	self.errorHistory = tempErrorHistroy
	self.userDefault:setStringForKey("login.exception.error.history", self.errorHistory)
	self.userDefault:flush()
end

function LoginExceptionManager:setShouldShowFunsClub(shouldShow)
	self.shouldShowFunsClub = shouldShow
end

function LoginExceptionManager:getShouldShowFunsClub()
	return self.shouldShowFunsClub
end

function LoginExceptionManager:setShowFunsClubWithoutUserLogin(shouldShow)
	self.showFunsClubWithoutUserLogin = shouldShow
end

function LoginExceptionManager:getShowFunsClubWithoutUserLogin()
	return self.showFunsClubWithoutUserLogin
end

function LoginExceptionManager:getLoginErrorTip(errCode, showReportBtn)
	self.tipLabel = Localization:getInstance():getText("error.tips.6")
	local tipLabel = Localization:getInstance():getText("error.tip.6")
	if errCode then
		if errCode == ExceptionCode.kItemOverdue then 
			self.tipLabel = Localization:getInstance():getText("error.tips.1")
			tipLabel = Localization:getInstance():getText("error.tip.1")
		elseif errCode == ExceptionCode.kItemNotExist then 
			self.tipLabel = Localization:getInstance():getText("error.tips.2")
			tipLabel = Localization:getInstance():getText("error.tip.2")
		elseif errCode == ExceptionCode.kPassThrough then
			self.tipLabel = Localization:getInstance():getText("error.tips.3")
			tipLabel = Localization:getInstance():getText("error.tip.3")
		elseif errCode == ExceptionCode.kEnergyNotEnough or errCode == ExceptionCode.kEnergyNotEnoughTwo then
			self.tipLabel = Localization:getInstance():getText("error.tips.4")
			tipLabel = Localization:getInstance():getText("error.tip.4")
		elseif errCode == ExceptionCode.kPayError or errCode == ExceptionCode.kPayErrorTwo then
			self.tipLabel = Localization:getInstance():getText("error.tips.5")
			tipLabel = Localization:getInstance():getText("error.tip.5")
		elseif errCode == ExceptionCode.kUserBaned then
			self.tipLabel = Localization:getInstance():getText("error.tips.7", {replace = UserManager.getInstance().uid})
			tipLabel = Localization:getInstance():getText("error.tip.7", {n = '\n', replace = UserManager.getInstance().uid})
		end
		if showReportBtn then 
			tipLabel = tipLabel .. Localization:getInstance():getText("error.tip.desc1")
		end
	end
	return tipLabel
end

function LoginExceptionManager:getShouldShowReportBtn()
	if MaintenanceManager:getInstance():isEnabled("ReportButtonShow") ~= true then
		return false
	end

	local num = MaintenanceManager:getInstance():getValue("ReportButtonShow")
	if num == nil then num = 10000 end
	num = tonumber(num)
	local uid = UserManager.getInstance().user.uid
	uid = tonumber(uid)
	if uid ~= nil then
		return (uid % 10000) < num
	end
	return false	
end


local function encodeUri(str)
    local ret = HeDisplayUtil:urlEncode(str)
    return ret
end

local function getAutoSendParams()
	local deviceOS = "android"
	local appId = "1022"
	local secret = "andridxxl!sx0fy13d2"
	
	if __IOS then
		deviceOS = "ios"
		appId = "1021"
		secret = "iosxxl!23rj8945fc2d3"
	end
	
	local parameters = {}

	local metaInfo = MetaInfo:getInstance()
	parameters["app"] = appId
	parameters["os"] = deviceOS
	parameters["mac"] = metaInfo:getMacAddress()
	parameters["model"] = metaInfo:getDeviceModel()
	parameters["osver"] = metaInfo:getOsVersion()
	parameters["udid"] = metaInfo:getUdid()
	local network = "UNKNOWN"
	if __ANDROID then
		network = luajava.bindClass("com.happyelements.android.MetaInfo"):getNetworkTypeName()
	elseif __IOS then 
		network = Reachability:getNetWorkTypeName()
	end
	parameters["network"] = network

	parameters["vip"] = 0
	parameters["src"] = "client"
	parameters["lang"] = "zh-Hans"

	parameters["pf"] = StartupConfig:getInstance():getPlatformName() or ""
	parameters["uuid"] = _G.kDeviceID or ""

	local user = UserManager:getInstance().user
	local profile = UserManager.getInstance().profile
	parameters["level"] = user:getTopLevelId()
	local markData = UserManager:getInstance().mark
	local createTime = markData and markData.createTime or 0
	parameters["ct"] = tonumber(createTime) / 1000
	parameters["lt"] = PlatformConfig:getLoginTypeName()
	if __IOS then
		parameters["pt"] = "apple"
	elseif __ANDROID then 
		local pt = AndroidPayment.getInstance():getDefaultSmsPayment()
		local ptName = "NOSIM"
		if pt then 
			local payment = PaymentBase:getPayment(pt)
            ptName = payment.name
		end
		parameters["pt"] = tostring(ptName)
	end
	parameters["gold"] = user:getCash()
	parameters["silver"] = user:getCoin()
	parameters["uver"] = ResourceLoader.getCurVersion()
	parameters["uid"] = user.uid
	local name = ""
	if profile and profile:haveName() then
		name = profile:getDisplayName()
	end
	parameters["name"] = name
	parameters["ver"] = _G.bundleVersion
	parameters["ts"] = os.time()
	parameters["ext"] = LoginExceptionManager:getInstance().errorHistory
	parameters["msg"] = LoginExceptionManager:getInstance().tipLabel
	return parameters
end

local function getAutoSendUrl()
	local parameters = params or getAutoSendParams()
	local faqUrl = "http://fansclub.happyelements.com/kefu/api/send_question.php"
	local isFirstParam = true
	for k, v in pairs(parameters) do
		local join = "&"
		if isFirstParam then 
			join = "?"
			isFirstParam = false
		end
		faqUrl = faqUrl .. join .. k .. "=" .. encodeUri(tostring(v))
	end
	return faqUrl
end

function LoginExceptionManager:showFunsClub()
	local function onCallback(response)
    	if response.httpCode ~= 200 then 
    		--未能正确发送客服提问 什么也不做
    	else
    		--成功反馈打点
    		DcUtil:loginException("Success_repairs")
		   	FAQ:openFAQClient("http://fansclub.happyelements.com/kefu/api/view_question.php", FAQTabTags.kSheQu, true)
    	end
    end

	local request = HttpRequest:createGet(getAutoSendUrl())
    local timeout = 3
  	local connection_timeout = 2
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(timeout * 1000)
    HttpClient:getInstance():sendRequest(onCallback, request)
end

--这里手动记录报错的类型 否则ExceptionPanel传入的错误码都是203 
function LoginExceptionManager:setErrorCodeCache(errCode)
	self.errorCodeCache = errCode
end

function LoginExceptionManager:getErrorCodeCache()
	return self.errorCodeCache
end