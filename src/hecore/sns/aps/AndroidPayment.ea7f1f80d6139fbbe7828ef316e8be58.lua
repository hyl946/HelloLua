AndroidPayment = class()

local decisionStoragePath = "/smspaydecision.ds"

CMOptimalType = {
	kDefault = 0,
	kThirdPart_CMMM = 1,
	kThirdPart_CMGame = 2,
	kCMMM = 3,
	kCMGame = 4,
}

local instance
function AndroidPayment.getInstance()
	if not instance then
		instance = AndroidPayment.new()
		instance:init()
	end
	return instance
end

function AndroidPayment:init()
	self.thirdPartyPayment = {}
	self.chinaMobilePayment = Payments.UNSUPPORT
	self.chinaUnicomPayment = Payments.UNSUPPORT
	self.chinaTelecomPayment = Payments.UNSUPPORT

	self.cmOptimalType = nil

	self.enabledNetOperators = {}
	self.enabledNetOperators[TelecomOperators.CHINA_MOBILE] = true
	self.enabledNetOperators[TelecomOperators.CHINA_UNICOM] = true
	self.enabledNetOperators[TelecomOperators.CHINA_TELECOM] = true

	local defaultDecisionFunc, defaultMd5 = require("zoo.payment.AndroidSMSPaymentDecision")
	self.defaultDecisionFunc = defaultDecisionFunc
	self:updateSMSPaymentDecisionFunction(defaultDecisionFunc, defaultMd5)
end

--同包名的包 是否强制走he的微信支付参数
function AndroidPayment:forceHeWechatPayment()
	if PlatformConfig:isPlatform(PlatformNameEnum.kJinli) then
		return true
	end
	return false
end

function AndroidPayment:getAPSMgr()
	return luajava.bindClass("com.happyelements.hellolua.aps.APSManager")
end

function AndroidPayment:setCMOptimalType(oType)
	self.cmOptimalType = oType
end

function AndroidPayment:isCMThirdPartOptimal()
	if self:getOperator() == TelecomOperators.CHINA_MOBILE then
		return self.cmOptimalType == CMOptimalType.kThirdPart_CMMM or self.cmOptimalType == CMOptimalType.kThirdPart_CMGame
	end
	return false
end

function AndroidPayment:getActiveOperators()
	local activeOps = {}
	local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
	if metaInfo then
		local opList = metaInfo:getActiveNetOperatorTypes()
		local opTable = luaJavaConvert.list2Table(opList)
		for _, v in ipairs(opTable) do
			table.insert(activeOps, v:getValue())
		end
	end
	return activeOps
end

function AndroidPayment:isNetOperatorAvaiable(optype)
	if self.enabledNetOperators and self.enabledNetOperators[optype] == false then -- 明确知道运营商不可用时
		return false
	end
	return true
end

function AndroidPayment:checkOperatorActive(optype, activeOperators)
	activeOperators = activeOperators or self:getActiveOperators()
	for _, v in ipairs(activeOperators) do
		if v == optype then return true end
	end
	return false
end

function AndroidPayment:hasNetOperators()
	return table.size(self:getActiveOperators()) > 0
end

-- 当前设备的电信运营商
function AndroidPayment:getOperator() 
	-- do return TelecomOperators.CHINA_MOBILE end
	local meta = MaintenanceManager:getInstance():getMaintenanceByKey("AndroidMutiOperator")
	if not meta or meta.enable then -- 多卡处理
		local extra = meta and meta.extra or "ct,cm,cu"
		local opPriority = string.split(extra, ",")
		local activeOperators = AndroidPayment:getActiveOperators()
		-- 初始化卡的类型
		local operator = activeOperators and activeOperators[1] or -1

		local sortOperators = {}
		for _,op in ipairs(opPriority) do
			if op == "cm" then table.insert(sortOperators, TelecomOperators.CHINA_MOBILE)
			elseif op == "cu" then table.insert(sortOperators, TelecomOperators.CHINA_UNICOM)
			elseif op == "ct" then table.insert(sortOperators, TelecomOperators.CHINA_TELECOM)
			end
		end
		for _, op in ipairs(sortOperators) do
			-- 运营商可用且支持计费,这里判断isNetOperatorAvaiable是为了当卡1被禁用可以返回卡2的类型
			if self:isNetOperatorAvaiable(op) and self:checkOperatorActive(op, activeOperators) then
				operator = op
				break
			end
		end
		return operator
	else
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		if metaInfo then
			local optype = metaInfo:getNetOperatorType()
			if optype then 
				return optype:getValue()
			end
		end
		return -1 -- present no sim
	end
end

local function testSDK()
    if PlatformConfig:isPlatform(PlatformNameEnum.kHE_CLOUDTEST) then

    	local i = 1
    	local sdks = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME, Payments.CHINA_UNICOM, Payments.CHINA_TELECOM }
    	local sdkHandle = nil

		local onTimer = function(...)
			if i > #(sdks) then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(sdkHandle)
				sdkHandle = nil
				return
			end

			local payType = sdks[i]
			local payment = PaymentBase:getPayment(payType)
			payment:registerDelegate()
			i = i + 1

		end
		sdkHandle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimer, 3, false)

		-- for k, payType in ipairs({ Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME, Payments.CHINA_UNICOM, Payments.CHINA_TELECOM }) do
		-- 	local payment = PaymentBase:getPayment(payType)
		-- 	payment:registerDelegate()
		-- end
	end
end

--线上金立包动态改wxpaymentId
function AndroidPayment:handleWechatPayment()
	-- if self:forceHeWechatPayment() then 
	-- 	local success, ret = pcall(function()
	-- 		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
	-- 		MainActivityHolder:setWXPaymentAppId("wxa9d9b3bd072257e0")
	-- 	end)
	-- 	if not success then 
	-- 		PlatformConfig.paymentConfig.thirdPartyPayment = {Payments.ALIPAY}
	-- 	end
	-- end
	if PlatformConfig:isPlatform(PlatformNameEnum.kJinliPre) then
		local success, ret = pcall(function()
			local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
			self.wxPaymentId = MainActivityHolder:getWXPaymentAppId()
		end)
	end
end

-- 支付初始化
function AndroidPayment:initPaymentConfig(paymentCfg)
	testSDK()

	if not paymentCfg or type(paymentCfg) ~= "table" then 
		return 
	end

	self:handleWechatPayment()

	-- 1.36-1.42 leshop 关停微信支付
	local gameVersion = string.split(_G.bundleVersion, '.')
	local verNo = tonumber(gameVersion[2])
	local osVer = getOSVersionNumber() or 99
	local deviceType = MetaInfo:getInstance():getMachineType()
	-- v1.49 mz 7.1及以上系统mm兼容问题，关闭mm支付, 其他关闭8.0以上MM支付
	local deviceBrand = ""
	local success, ret = pcall(function()
		deviceBrand = luajava.bindClass("android.os.Build").BRAND
		deviceBrand = string.lower(deviceBrand)
	end)
	local javaLatestModify = 0
	pcall(function()
		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
		javaLatestModify = MainActivityHolder.ACTIVITY:getLatestModify()
	end)
	local useNewMMSDK = false
	-- 1.52 mz,he,tf_ct升级mmsdk了，未升级的平台8.0系统兼容有问题，升级后的5.0以下低端机型有首次启动未响应的问题
	local supportAndroid9 = false
	local mmSdkVer = 0
	pcall(function()
		local fullSdkVer = luajava.bindClass("com.happyelements.android.operatorpayment.iap.IAPPayment"):getSdkVersion()
		local sdkVerCodes = string.split(fullSdkVer, '.')
		for i, v in ipairs(sdkVerCodes) do
			local num = tonumber(v) or 0
			mmSdkVer = mmSdkVer * 100 + num
		end
	end)
	if mmSdkVer >= 4000000 then
		useNewMMSDK = true 
	end

	if mmSdkVer >= 4000300 then
		if osVer < 5.0 then
			table.removeValue(paymentCfg.chinaMobilePayment, Payments.CHINA_MOBILE)
		end
		-- 4.0.3 测试
	elseif (not useNewMMSDK and osVer >= 8.0) or 
		(useNewMMSDK and osVer < 5.0) or 
		osVer >= 9.0 or 
		(deviceBrand == "meitu") or -- 美图关闭mmsdk
		-- (useNewMMSDK and deviceBrand == "xiaomi") or -- 小米权限问题导致启动和支付时多次弹出短信提示
		(not useNewMMSDK and deviceBrand == "meizu" and osVer >= 7.0) or 
		PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei) then
		table.removeValue(paymentCfg.chinaMobilePayment, Payments.CHINA_MOBILE)
	end

	self.thirdPartyPayment = paymentCfg.thirdPartyPayment or {}

	if _G.isLocalDevelopMode then printx(0, table.tostring(self.thirdPartyPayment)) end

	for i,payType in ipairs(self.thirdPartyPayment) do
		if payType ~= Payments.UNSUPPORT then
			local payment = PaymentBase:getPayment(payType)
			payment:setEnabled(true)
			--小米支付仅启动sdk，并不使用
			if payType == Payments.MI then
				payment:setEnabled(false)
			end
		end
	end
	--189Store包非电信运营商，不能使用sdk支付
	if PlatformConfig:isPlatform(PlatformNameEnum.k189Store) and self:getOperator() ~= TelecomOperators.CHINA_TELECOM then
		local payment = PaymentBase:getPayment(Payments.TELECOM3PAY)
		if payment then payment:setEnabled(false) end
	end

	-- local operator = self:getOperator()
	local extraData = self:getSmsPaymentsExtraData()
	-- 确定可用的支付方式
	self.chinaMobilePayment = paymentCfg.chinaMobilePayment or Payments.UNSUPPORT
	local cmPayType, isUmpayInit = self:filterCMPayment(true)
	if cmPayType == Payments.UNSUPPORT and not isUmpayInit then
		self.enabledNetOperators[TelecomOperators.CHINA_MOBILE] = false
	end
	self.chinaUnicomPayment = paymentCfg.chinaUnicomPayment or Payments.UNSUPPORT
	local cuPayType = self:filterCUPayment()
	if cuPayType == Payments.UNSUPPORT then
		self.enabledNetOperators[TelecomOperators.CHINA_UNICOM] = false
	end
	self.chinaTelecomPayment = paymentCfg.chinaTelecomPayment or Payments.UNSUPPORT
	local ctPayType = self:filterCTPayment()
	if ctPayType == Payments.UNSUPPORT then
		self.enabledNetOperators[TelecomOperators.CHINA_TELECOM] = false
	end
	-- 初始化可用的支付方式
	if cmPayType ~= Payments.UNSUPPORT then
		local payment = PaymentBase:getPayment(cmPayType)
		payment:setEnabled(true)
	end
	if isUmpayInit then
		local payment = PaymentBase:getPayment(Payments.UMPAY)
		payment:setEnabled(true)
	end
	if cmPayType ~= Payments.UNSUPPORT and self:checkOperatorActive(TelecomOperators.CHINA_MOBILE) then
		if cmPayType == Payments.CHINA_MOBILE and extraData.mmAppidRule then -- CMMM
			AndroidPayment:setMMAppidRule(extraData.mmAppidRule)
		end
	end
	if cuPayType ~= Payments.UNSUPPORT then
		local payment = PaymentBase:getPayment(cuPayType)
		payment:setEnabled(true)
	end
	if ctPayType ~= Payments.UNSUPPORT then
		local payment = PaymentBase:getPayment(ctPayType)
		payment:setEnabled(true)
	end
	if _G.isLocalDevelopMode or MaintenanceManager:getInstance():isEnabled("UploadDebugLog") then
		local function findUkeyByValue(t, v)
			for k, _v in pairs(t) do 
				if _v == v then return k end
			end
			return ""
		end
		local msg = {}
		local supportPay = {
			["移动"]=findUkeyByValue(Payments, cmPayType),
			["电信"]=findUkeyByValue(Payments, ctPayType),
			["联通"]=findUkeyByValue(Payments, cuPayType),
			["友盟"]=isUmpayInit,
		}
		local enabledOps = {}
		for k, _ in ipairs(self.enabledNetOperators or {}) do
			table.insert(enabledOps, findUkeyByValue(TelecomOperators, tonumber(k)))
		end
		local activeOps = {}
		for _, v in ipairs(self:getActiveOperators() or {}) do
			table.insert(activeOps, findUkeyByValue(TelecomOperators, v))
		end
		msg["计费方式"] = supportPay
		msg["支持运营商"] = enabledOps
		msg["手机运营商"] = activeOps
		local meta = MaintenanceManager:getInstance():getMaintenanceByKey("AndroidMutiOperator")
		msg["多卡优先级"] = {enable =  meta and meta.enable or false, extra = meta and meta.extra or ""}
		msg["默认运营商"] = findUkeyByValue(TelecomOperators, self:getOperator())
		RemoteDebug:uploadLogWithTag("sms_payment", table.tostring(msg))
	end

	self:startVivo()
end

function AndroidPayment:startVivo()
	if PlatformConfig:isPlatform(PlatformNameEnum.kBBK) then
		require "zoo.platform.VivoPlatform"
		VivoPlatform:onStart()
	end
end

function AndroidPayment:getNormalThirdPartPayment()
	local payments = PaymentBase:getPayments()
	for payType,payment in pairs(payments) do
		if payment.type ~= Payments.WECHAT and payment.type ~= Payments.ALIPAY then 
			return payment.type
		end
	end
	return Payments.UNSUPPORT
end

function AndroidPayment:getSmsPaymentsExtraData()
    local status, _, result = pcall(self.decisionFunc)
	if _G.isLocalDevelopMode then printx(0, status) end
	if _G.isLocalDevelopMode then printx(0, table.tostring(result)) end
	if not status or type(result) ~= "table" then
		result = {}
	end
	return result
end

function AndroidPayment:getSmsBanList()
    local status, result, banlist = pcall(self.decisionFunc)
    if not status or not result or type(result) ~= "table" then
	    status, result, banlist = pcall(self.defaultDecisionFunc)
	end

	return banlist
end

function AndroidPayment:getSmsPayments()
    local status, result = pcall(self.decisionFunc)
	if _G.isLocalDevelopMode then printx(0, status) end
	if _G.isLocalDevelopMode then printx(0, table.tostring(result)) end
	if not status or not result or type(result) ~= "table" then
	    local status, result = pcall(self.defaultDecisionFunc)
		if not status or not result or type(result) ~= "table" then
			result = { Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME, Payments.CHINA_UNICOM, Payments.CHINA_TELECOM }
	    end
	end
	-- local function checkArtInUse()
	-- 	return AndroidPayment:getAPSMgr():isArtInUse()
	-- end

	-- local success, ret = pcall(checkArtInUse)
	-- if success and ret then
	-- 	if _G.isLocalDevelopMode then printx(0, "isArtInUse") end
		-- table.removeValue(result, Payments.CHINA_MOBILE_GAME)
		-- table.removeValue(result, Payments.CHINA_UNICOM)
	-- end
	return result
end

function AndroidPayment:isNetworkEnabled()
	local help = luajava.bindClass("com.happyelements.android.ApplicationHelper")
	return help:isDataAvailable()
end

function AndroidPayment:checkStartChinaGame()
	local osVersion = getOSVersionNumber() or 1
	if osVersion < 4.0 then 
		return false
	end
	
	return true
end

function AndroidPayment:filterCMPayment(isInit)
	if _G.__CMGAME_TISHEN then
		return Payments.CHINA_MOBILE_GAME
	end
	
	local cmPayments = self.chinaMobilePayment
    local cmPayType = nil
	local isUmpayInit = false

    if _G.isLocalDevelopMode then printx(0, "filterCMPayment...") end

	if type(cmPayments) == "table" then
		if _G.kDefaultCmPayment and table.includes(cmPayments, _G.kDefaultCmPayment) then
			if _G.isLocalDevelopMode then printx(0, "kDefaultCmPayment cmcc") end
			cmPayType = _G.kDefaultCmPayment
		end
		
		local result = self:getSmsPayments()

		local cmgameIndex = table.indexOf(result, Payments.CHINA_MOBILE_GAME)

		if cmgameIndex and not self:checkStartChinaGame() then
			table.remove(result, cmgameIndex)
		end

		for i, v in ipairs(result) do
			if table.includes(cmPayments, v) then
				if v ~= Payments.UMPAY or (not isInit and self:isNetworkEnabled()) then
					cmPayType = v
					break
				end
			end
		end

		--调低联动优势的优先级
		if cmPayType == Payments.UMPAY and not isInit then
			for i=2,#result do
				local payType = result[i]
				if table.includes(cmPayments, payType) then
					cmPayType = payType
					break
				end
			end
		end

		isUmpayInit = isInit and table.includes(result, Payments.UMPAY) and table.includes(cmPayments, Payments.UMPAY)
	end
	return cmPayType or Payments.UNSUPPORT, isUmpayInit
end

function AndroidPayment:filterCUPayment()
	local cuPayment = self.chinaUnicomPayment
	local result = self:getSmsPayments()

	local cuPayType = nil

	if _G.isLocalDevelopMode then printx(0, "filterCUPayment...") end

	if table.includes(result, cuPayment) then
		cuPayType = cuPayment
	end

	return cuPayType or Payments.UNSUPPORT
end

function AndroidPayment:filterCTPayment()
	local ctPayment = self.chinaTelecomPayment
	local result = self:getSmsPayments()

	if _G.isLocalDevelopMode then printx(0, "filterCTPayment...") end

	local ctPayType = nil

	if table.includes(result, ctPayment) then
		ctPayType = ctPayment
	end

	return ctPayType or Payments.UNSUPPORT
end

function AndroidPayment:getDefaultSmsPayment()
	local operator = self:getOperator()
	if _G.isLocalDevelopMode then printx(0, "getOperator:", operator) end
	if operator == TelecomOperators.CHINA_MOBILE then
		return self:filterCMPayment()
	elseif operator == TelecomOperators.CHINA_UNICOM then
		return self:filterCUPayment()
	elseif operator == TelecomOperators.CHINA_TELECOM then
		return self:filterCTPayment()
	else
		return nil
	end
end


function AndroidPayment:getChinaMobileChannelId()
	local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE)
	return payment.delegate:getChannelId()
end

function AndroidPayment:getPaymentDelegate(paymentType)
	local payment = PaymentBase:getPayment(paymentType)
	return payment.delegate
end

function AndroidPayment:isPaymentTypeSupported(paymentType)
	local payment = PaymentBase:getPayment(paymentType)
	return payment:isEnabled()
end

function AndroidPayment:isSmsPaymentSupported()
	return self:filterCUPayment() ~= Payments.UNSUPPORT
		or self:filterCTPayment() ~= Payments.UNSUPPORT
		or self:filterCMPayment() ~= Payments.UNSUPPORT
end

function AndroidPayment:initCMPaymentDecisionScript()
	local storageSrc = Localhost:readFromStorage(decisionStoragePath)
	if _G.isLocalDevelopMode then printx(0, "initCMPaymentDecisionScript") end
	if storageSrc then
		if type(storageSrc) ~= "string" then
			assert(false, type(storageSrc) == "table" and table.tostring(storageSrc) or tostring(storageSrc))
			return
		end	
		local func, err = loadstring(storageSrc)
		if not func then
	    	he_log_error("initCMPaymentDecisionScript loadfunction error:"..tostring(err))
	    	return
	    end
		local status, result = pcall(func)
		if status then
			if _G.isLocalDevelopMode then printx(0, "decode success") end
			if _G.isLocalDevelopMode then printx(0, storageSrc) end
			self:updateSMSPaymentDecisionFunction(func, HeMathUtils:md5(storageSrc))
			return
		else
			he_log_error("initCMPaymentDecisionScript error:"..tostring(result))
		end
	end
end

function AndroidPayment:changeSMSPaymentDecisionScript(src)
	if src and src ~= "" then
	    local func, err = loadstring(src)
	    if not func then
	    	he_log_error("changeSMSPaymentDecisionScript loadfunction error:"..tostring(err))
	    	return
	    end
	    local status, result = pcall(func)
	    if _G.isLocalDevelopMode then printx(0, "changeCMPaymentDecisionScript") end
	    if _G.isLocalDevelopMode then printx(0, src) end
	    if status then
	    	if _G.isLocalDevelopMode then printx(0, "change src") end
		    local encodeSrc = amf3.encode(src)
	        local path = HeResPathUtils:getUserDataPath() .. decisionStoragePath
	        Localhost:safeWriteStringToFile(encodeSrc, path)
	        
	        -- self:updateSMSPaymentDecisionFunction(func, HeMathUtils:md5(src))
		else
			he_log_error("changeSMSPaymentDecisionScript error:"..tostring(result))
	    end
	end
end

function AndroidPayment:updateSMSPaymentDecisionFunction(func, scriptMd5)
	if type(func) ~= "function" then return end
	
    self.decisionFunc = func
	self.scriptMd5 = scriptMd5
end

function AndroidPayment:getDecisionScriptMd5()
	return self.scriptMd5
end

function AndroidPayment:setMMAppidRule(appidRule)
	-- if _G.isLocalDevelopMode then printx(0, "AndroidPayment:setMMAppidRule:", table.tostring(appidRule)) end
	local function setMMAppidRule()
		local rule = {}
		if type(appidRule) == "table" then
			for _,v in ipairs(appidRule) do
				if v.from and v.to then
					rule[tostring(v.from)] = tostring(v.to)
				end
			end
			luajava.bindClass("com.happyelements.android.operatorpayment.iap.IAPPayment"):setAppidReplaceRule(luaJavaConvert.table2Map(rule))
		end
	end
	local success, ret = pcall(setMMAppidRule)
	if not success then
		he_log_error("setMMAppidRule failed. err:"..tostring(ret))
	end
end