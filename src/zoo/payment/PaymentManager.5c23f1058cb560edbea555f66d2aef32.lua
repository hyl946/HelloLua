require "zoo.payment.WMBBuyItemLogic"
require "zoo.payment.PaymentNetworkCheck"
require "zoo.payment.paymentDC.DCAndroidStatus"
require 'zoo.payment.WechatQuickPayLogic'

--按位表示支付类型 目前支持到24位
PaymentTypeMaxBit = 24

IngamePaymentDecisionType = table.const {
	kPayFailed = 1,
	kPayWithType = 2,
	kSmsPayOnly = 3,
	kThirdPayOnly = 4,
	kSmsWithOneYuanPay = 5,			--短代和三方都可用时 一元限购
	kThirdOneYuanPay = 6,			--仅三方可用时 一元限购
	kGoldOneYuanPay = 7,			--一元购买风车币(这个只处理在默认栏里的,若是微信支付宝等独有的栏，不会走这套逻辑)

	kPayWithWindMill = 101,
}

ThirdPayPromotionConfig = table.const {}

SmsLimitType = table.const {
	kDailyLimit = 1,
	kMonthlyLimit = 2,	
}

SmsDisableReason = table.const{
	kSmsLimit = 1,
	kSmsClose = 2,
	kSimCardError = 3,
	kSdkStartError = 4,
	kPaycodeNotExist = 5,
}

local ThirdPayWithoutNetCheck = {
	Payments.WO3PAY,
	Payments.TELECOM3PAY,
}

SelfDefinePayError = table.const{
	kPaySucCheckFail = 800000,
}

--道具只能使用金币购买 不能用RMB购买的  
--家琪开的先河，居然忘记申请计费点
NoUseRMBPayGoodsList = table.const{
    553, --果酱锤子
    554, --果酱+5步
}

-- 不支持短代的商品
-- 请注意：目前，在不支持三方时强制切换返回风车币支付，若非此需求请注意另行处理
NoSMSPayGoodsList = table.const{
    30, -- 加五步礼包
}

PaymentManager = class()
local instance = nil

function PaymentManager.getInstance()
	if not instance then
		instance = PaymentManager.new()
		instance:init()
	end
	return instance
end

function PaymentManager:init()
	self.userDefault = CCUserDefault:sharedUserDefault()
	--玩家是否已用过三方支付（服务端记个标识 方便进行开卡活动）
	self.hasFirstThirdPay = false
	--短代是否超限额  
	self.smspayPassLimit = false 
	--短代超限额类型
	self.smspayLimitType = SmsLimitType.kDailyLimit

	self.defaultSmsPayment = nil
	--本地记录的默认三方支付类型
	self.defaultThirdPartyPayment = self.userDefault:getIntegerForKey("default.third.payment")
	--初始化默认支付（可能是三方或者短代）
	self.defaultPayment = self:getServerDefaultPaymentType()
	if self.defaultPayment == 0 then 
		self.defaultPayment = self.userDefault:getIntegerForKey("default.setting.payment")
	end
	self.lastDefaultPayment = self.defaultPayment
	--一元特价每日首次提示时间
	self.oneYuanShowTime = self.userDefault:getStringForKey("one.yuan.show.time")
	--今日第一次关卡内触发一元特价时 记录今日时间 
	self.isTodayFirstOneYuanLevel = self.userDefault:getIntegerForKey("one.yuan.today.level")

	--需要向服务端查询订单结果的三方支付  这里记录个查询状态
	self.isCheckingPayResult = false

	--支付宝免密支付上限金额
	self.aliQuickPayLimit = 60

	-- 微信免密支付金额上限
	self.wechatQuickPayLimit = 30

	--风车币默认栏中（包含短代的那个） 是否是一元特价的处理标识
	self.goldOneYuanThirdPay = false 

	--本地记录的连续三次短代支付的次数
	self.continueSmsPayCount = self.userDefault:getIntegerForKey("continue.smspay.count")
end

function PaymentManager:checkIsWechatLike(paymentType)
	--local PaymentConfigs = require "zoo.payment.logic.PaymentConfig"
	--PaymentConfigs[paymentType]
	--WechatLikePayments
	if table.indexOf( WechatLikePayments , paymentType ) then
		return true
	end

	return false
end

function PaymentManager:checkIsAlipayLike(paymentType)
	if table.indexOf( AlipayLikePayments , paymentType ) then
		return true
	end

	return false
end

function PaymentManager:checkHasWechatLikeInTable(paymentTypeTable)
	if paymentTypeTable and type(paymentTypeTable) == "table" then
		for k,v in pairs(paymentTypeTable) do
			if self:checkIsWechatLike(v) then
				return true , v
			end
		end
	end
	return false
end

function PaymentManager:checkHasAlipayLikeInTable(paymentTypeTable)
	if paymentTypeTable and type(paymentTypeTable) == "table" then
		for k,v in pairs(paymentTypeTable) do
			if self:checkIsAlipayLike(v) then
				return true , v
			end
		end
	end
	return false
end

function PaymentManager:getPaymentShowConfig(paymentType, price)
	local function generateConfig(name, smallIcon, bigIcon)
		local showConfig = {}
		showConfig.name = name
		showConfig.smallIcon = smallIcon
		showConfig.bigIcon = bigIcon
		return showConfig
	end

	if PaymentBase:isChinaMobile(paymentType) then
		return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_mobile_small0000", "pay_icon/icon_mobile_big0000")
	elseif PaymentBase:isChinaUnicom( paymentType ) then 
		return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_unicom_small0000", "pay_icon/icon_unicom_big0000")
	elseif PaymentBase:isChinaTelecom( paymentType ) then 
		return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_telecom_small0000", "pay_icon/icon_telecom_big0000")
	elseif paymentType == Payments.WECHAT then
		if UserManager:getInstance():isWechatSigned() and _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then 
			return generateConfig(localize("wechat.kf.button"), "pay_icon/icon_wechat_small0000", "pay_icon/icon_wechat_big0000")
		else
			return generateConfig(localize("panel.choosepayment.wechat"), "pay_icon/icon_wechat_small0000", "pay_icon/icon_wechat_big0000")
		end
	elseif paymentType == Payments.QQ then 
		return generateConfig(localize("panel.choosepayment.payments.jp_msdk"), "pay_icon/icon_qqwallet_small0000", "pay_icon/icon_qqwallet_big0000")
	elseif paymentType == Payments.ALIPAY then 
		if UserManager:getInstance():isAliSigned() and price and self:checkCanAliQuickPay(price) then 
			return generateConfig(localize("accredit.title"), "pay_icon/icon_ali_small0000", "pay_icon/icon_ali_big0000")		--支付宝快付
		else
			return generateConfig(localize("panel.choosepayment.alipay"), "pay_icon/icon_ali_small0000", "pay_icon/icon_ali_big0000")
		end
	elseif paymentType == Payments.WDJ then 
		return generateConfig(localize("market.panel.buy.gold.title.wandoujia"), "pay_icon/icon_wdj_small0000", "pay_icon/icon_wdj_big0000")
	elseif paymentType == Payments.QIHOO then 
		return generateConfig(localize("panel.choosepayment.payment.360"), "pay_icon/icon_qihoo_small0000", "pay_icon/icon_qihoo_big0000")
	elseif paymentType == Payments.QIHOO_WX then 
		return generateConfig(localize("panel.choosepayment.wechat"), "pay_icon/icon_wechat_small0000", "pay_icon/icon_wechat_big0000")
	elseif paymentType == Payments.QIHOO_ALI then 
		return generateConfig(localize("panel.choosepayment.alipay"), "pay_icon/icon_ali_small0000", "pay_icon/icon_ali_big0000")
	elseif paymentType == Payments.MI then 
		return generateConfig(localize("panel.choosepayment.payments.mi"), "pay_icon/icon_mi_small0000", "pay_icon/icon_mi_big0000")
	elseif paymentType == Payments.HUAWEI then 
		return generateConfig(localize("panel.choosepayment.payments.huawei"), "pay_icon/icon_huawei_small0000", "pay_icon/icon_huawei_big0000")
	elseif paymentType == Payments.QQ_WALLET then 
		return generateConfig(localize("panel.choosepayment.payments.qqwallet"), "pay_icon/icon_qqwallet_small0000", "pay_icon/icon_qqwallet_big0000")
	elseif paymentType == Payments.MI_ALIPAY then 
		return generateConfig(localize("panel.choosepayment.alipay"), "pay_icon/icon_ali_small0000", "pay_icon/icon_ali_big0000")
	elseif paymentType == Payments.MI_WXPAY then 
		return generateConfig(localize("panel.choosepayment.wechat"), "pay_icon/icon_wechat_small0000", "pay_icon/icon_wechat_big0000")
	elseif PlatformConfig:isPlatform(PlatformNameEnum.k189Store) then -- 189Store的包特殊处理，因为仅有短代支付方式，因此按照运营商分别显示不同的图标
		local operator = AndroidPayment.getInstance():getOperator()
		if operator == TelecomOperators.CHINA_MOBILE then
			return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_mobile_small0000", "pay_icon/icon_mobile_big0000")
		elseif operator == TelecomOperators.CHINA_UNICOM then
			return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_unicom_small0000", "pay_icon/icon_unicom_big0000")
		elseif operator == TelecomOperators.CHINA_TELECOM then
			return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_telecom_small0000", "pay_icon/icon_telecom_big0000")
		else
			return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_sms_union_small0000", "pay_icon/icon_sms_union_big0000")
		end
	elseif paymentType == Payments.MIDAS then 
		return generateConfig(localize("panel.choosepayment.payments.jp_msdk"), "pay_icon/icon_qqwallet_small0000", "pay_icon/icon_qqwallet_big0000")
	else
		return generateConfig(localize("panel.no.net.pay.botton2"), "pay_icon/icon_sms_union_small0000", "pay_icon/icon_sms_union_big0000")
	end
end

function PaymentManager:isCMGameOfflinePayLimited()
	local networkState, lastCheckTime = PaymentNetworkCheck.getInstance():getNetworkState()
    if _G.isLocalDevelopMode or MaintenanceManager:getInstance():isEnabled("UploadDebugLog") then 
    	RemoteDebug:uploadLogWithTag("cmgame_limit_netstate", networkState, UserLocalLogic:getCMGameOfflinePayCount(), UserManager.getInstance():getCMGameOfflinePayLimit()) 
    end
	if lastCheckTime and not networkState and UserLocalLogic:isCMGameOfflinePayLimited() then -- 无网络
		return true
	else
		return false
	end
end

function PaymentManager:checkSmsPayEnabled(goodsId, goodsType)
	local smsPayEnabled = true
	local smsPayDisableReason = nil
	
	--是否超限额 
	if self:getIsSmsPaymentLimit() then 
		smsPayEnabled = false
		smsPayDisableReason = SmsDisableReason.kSmsLimit
	else
		local operator = AndroidPayment.getInstance():getOperator()
		--是否关停
		if operator == TelecomOperators.CHINA_MOBILE then
			local smsType = AndroidPayment.getInstance():filterCMPayment()
	        if smsType == Payments.UNSUPPORT then 
	            smsPayEnabled = false
	            smsPayDisableReason = SmsDisableReason.kSmsClose
            elseif smsType == Payments.CHINA_MOBILE_GAME then
            	if self:isCMGameOfflinePayLimited() then
					smsPayEnabled = false
					smsPayDisableReason = SmsDisableReason.kSdkStartError

					local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME)
					if payment then payment:setBeLimited(true) end
	            else
	            	local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME)
					if payment then payment:setBeLimited(false) end
	            end
	        end
	    elseif operator == TelecomOperators.CHINA_UNICOM then
	        if AndroidPayment.getInstance():filterCUPayment() == Payments.UNSUPPORT then 
	            smsPayEnabled = false
	            smsPayDisableReason = SmsDisableReason.kSmsClose
	        end
	    elseif operator == TelecomOperators.CHINA_TELECOM then
	        if AndroidPayment.getInstance():filterCTPayment() == Payments.UNSUPPORT then 
	            smsPayEnabled = false
	            smsPayDisableReason = SmsDisableReason.kSmsClose
	        end
	    else
	    	--没卡 或者卡有问题等情况
	    	smsPayEnabled = false
	    	smsPayDisableReason = SmsDisableReason.kSimCardError
	    end
	end

	local paymentType = self:getDefaultSmsPayment()
	local payment = PaymentBase:getPayment(paymentType)

	if smsPayEnabled and not payment:isEnabled() then
		smsPayEnabled = false
		smsPayDisableReason = SmsDisableReason.kSdkStartError
	end
	if smsPayEnabled and not self:checkPayCodeValid(paymentType, goodsId, goodsType) then
		smsPayEnabled = false
		smsPayDisableReason = SmsDisableReason.kPaycodeNotExist
	end

	return smsPayEnabled, smsPayDisableReason
end

function PaymentManager:checkPayCodeValid(paymentType, goodsId, goodsType)
	if not (paymentType and goodsId) then return true end
	if goodsType == 2 then return true end

	local payCodeMeta = MetaManager:getInstance():getGoodPayCodeMeta(goodsId)
	if payCodeMeta then
		if paymentType == Payments.CHINA_MOBILE_GAME then
			if not payCodeMeta.cmGamePayCode or payCodeMeta.cmGamePayCode == "" then 
				return false 
			end
		end
		return true
	end
	return false
end

function PaymentManager:checkThirdPartPaymentEabled(onlyLvOne)
	return PaymentBase:checkThirdPartyPaymentEabled(onlyLvOne)
end

function PaymentManager:getAndroidPaymentDecision(goodsId, goodsType, handlePayment)
	if _G.isLocalDevelopMode then printx(0, "[Payment] getAndroidPaymentDecision goodsId:", goodsId, "goodsType:", goodsType) end
	if goodsType == 2 then 
		self:getBuyGoldDecision(handlePayment, goodsId)
	else
		self:getBuyItemDecision(handlePayment, goodsId)
	end
end

function PaymentManager:getBuyGoldDecision(handlePayment, goodsId)
	local payment = PaymentBase:getPayment(PlatformConfig:getCurrentPayType())
	local decesion, payType
	if PaymentManager.getInstance():getGoldOneYuanThirdPay() then 			--风车币默认栏 可能出现的一元特价
		decesion = IngamePaymentDecisionType.kGoldOneYuanPay
	elseif payment.mode == PaymentMode.kThirdParty 
		or self:isThirdPartPaymentOnly(goodsId, 2) 
		or not self:checkSmsPayEnabled(goodsId, 2) 
	then
		decesion, payType = self:getThirdPartPaymentDecision()
	else
		decesion, payType = self:getSMSPaymentDecision()
	end
	handlePayment(decesion, payType)
end

function PaymentManager:getBuyItemDecision(handlePayment, goodsId)
	assert(handlePayment)
	if self:checkCanWindMillPay(goodsId) then 
		if handlePayment then 
			handlePayment(IngamePaymentDecisionType.kPayWithWindMill)
		end
	else
		self:getRMBBuyItemDecision(handlePayment, goodsId)
	end
end

function PaymentManager:priorityThirdPartyDecision(dcAndroidStatus, handlePayment, goodsId, useHappyCoinIfDisabled)
	dcAndroidStatus:push(DecisionJudgeType.kDefaultPaymentType.NO)
	local repayChooseTable = nil

	if self:checkThirdPartPaymentEabled(true) then 
		dcAndroidStatus:push(DecisionJudgeType.kThirdPayEnable.YES)
		local defaultSmsPayment = self:getDefaultSmsPayment()
		local thirdPartPaymentTable = AndroidPayment.getInstance().thirdPartyPayment
		local defaultThirdPartyPayment = self:getDefaultThirdPartPayment()

		if table.includes(ThirdPayWithoutNetCheck, defaultThirdPartyPayment) and goodsId == 485 then
			defaultThirdPartyPayment = self:getDefaultThirdPartPayment(true)
		end

		if table.includes(ThirdPayWithoutNetCheck, defaultThirdPartyPayment) then 
			--这里的三方 不用联网检测 比如TELECOM3PAY
			dcAndroidStatus:push(DecisionJudgeType.kNetEnable.YES)
			--这里不判断短代是否可用了 不联网三方一般融合短代 不会用我们的短代
			repayChooseTable = self:filterRepayPayment(thirdPartPaymentTable)
			handlePayment(IngamePaymentDecisionType.kPayWithType, defaultThirdPartyPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
		else
			PaymentNetworkCheck.getInstance():check(function ()
				--一种优先三方 若为支付宝引导快付
				dcAndroidStatus:push(DecisionJudgeType.kNetEnable.YES)
				
				local smsEnable, disableReason = self:checkSmsPayEnabled()
				if smsEnable and defaultSmsPayment ~= Payments.UMPAY then 
					repayChooseTable = self:filterRepayPayment(table.union(thirdPartPaymentTable, {defaultSmsPayment}))
				else
					repayChooseTable = self:filterRepayPayment(thirdPartPaymentTable)
				end
				handlePayment(IngamePaymentDecisionType.kPayWithType, defaultThirdPartyPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
			end, function ()
				dcAndroidStatus:push(DecisionJudgeType.kNetEnable.NO)
				local smsEnable, disableReason = self:checkSmsPayEnabled()
				dcAndroidStatus:pushWithSmsEnableCheck(disableReason)
				if smsEnable and defaultSmsPayment ~= Payments.UMPAY then
					--短代原价
					repayChooseTable = self:filterRepayPayment(table.union({defaultSmsPayment}, thirdPartPaymentTable))
					handlePayment(IngamePaymentDecisionType.kPayWithType, defaultSmsPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
				else
					local cuccPayment = PaymentBase:getPayment(Payments.WO3PAY)
					local storePayment = PaymentBase:getPayment(Payments.TELECOM3PAY)
					
					repayChooseTable = self:filterRepayPayment(thirdPartPaymentTable)

					if cuccPayment:isEnabled() then
						handlePayment(IngamePaymentDecisionType.kPayWithType, Payments.WO3PAY, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
					elseif storePayment:isEnabled() then
						handlePayment(IngamePaymentDecisionType.kPayWithType, Payments.TELECOM3PAY, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
					else
						--去联网 errortip
						handlePayment(IngamePaymentDecisionType.kPayFailed, AndroidRmbPayResult.kCloseAfterNoNetWithoutSec, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
					end
				end
			end)
		end
		return true
	else
		if useHappyCoinIfDisabled and handlePayment then
			handlePayment(IngamePaymentDecisionType.kPayWithWindMill)
			return true
		end
	end

	return false
end

function PaymentManager:checkMustPayWithPriorityThirdParty(goodsId)
	if StarBank and StarBank:hasGoodsId(goodsId) then
		return true
	end
	return false
end

-- RMB支付只能用三方，若三方不支持，改回用风车币
function PaymentManager:checkIsSMSPayForbidden(goodsId)
	if table.includes(NoSMSPayGoodsList, goodsId) then
        return true
    end
	return false
end

function PaymentManager:getAvailablePayType( goodsIdInfo )
	local thirdPayments = self:filterRepayPayment(AndroidPayment.getInstance().thirdPartyPayment)
	local smsPayments = {}

	if _G.StoreManager:getInstance():getAndroidGoodsPrice(goodsIdInfo) <= 30 then
		-- local payCodeMeta = MetaManager:getInstance():getGoodPayCodeMeta(goodsIdInfo:getGoodsNameId())
		-- hacker code, 故意穿一个 goodType 1 是为了借用 checkSmsPayEnabled 中校验pay_code的逻辑
		if self:checkSmsPayEnabled(goodsIdInfo:getGoodsNameId(), 1) then
			smsPayments = {self:getDefaultSmsPayment()}
		end
	else
		thirdPayments = table.filter(thirdPayments, function ( payType )
			return payType ~= Payments.WO3PAY and payType ~= Payments.TELECOM3PAY
		end)
	end

	return table.union(thirdPayments, smsPayments)
end

function PaymentManager:setLastSuccessfulPayment( payType )
	self.userDefault:setIntegerForKey('user.last.successful.payment.type', payType)
	self.userDefault:flush()
end

function PaymentManager:getLastSuccessfulPayment( ... )
	return self.userDefault:getIntegerForKey('user.last.successful.payment.type', 0) or 0
end


function PaymentManager:getRMBBuyItemDecision(handlePayment, goodsId)
	local repayChooseTable = {}
	local dcAndroidStatus = DCAndroidStatus:create()

	if self:checkMustPayWithPriorityThirdParty(goodsId) and self:priorityThirdPartyDecision(dcAndroidStatus, handlePayment, goodsId) then
		return
	end

	if self:checkIsSMSPayForbidden(goodsId) and self:priorityThirdPartyDecision(dcAndroidStatus, handlePayment, goodsId, true) then
		return
	end

	if self:checkDefaultPaymentIsSmsPay() then 
		dcAndroidStatus:push(DecisionJudgeType.kDefaultPaymentType.YES) 
		local smsEnable, disableReason = self:checkSmsPayEnabled(goodsId, 1)
		dcAndroidStatus:pushWithSmsEnableCheck(disableReason)

		local defaultSmsPayment = self:getDefaultSmsPayment()
		if smsEnable and defaultSmsPayment == Payments.UMPAY then
			smsEnable = false
		end

		if smsEnable then 
			dcAndroidStatus:push(DecisionJudgeType.kOneYuanEnable.NO)
			if self:checkThirdPartPaymentEabled() then
				PaymentNetworkCheck.getInstance():check(function ()
					--短代原价 重买带三方
					local thirdPartPaymentTable = AndroidPayment.getInstance().thirdPartyPayment
					repayChooseTable = self:filterRepayPayment(table.union(thirdPartPaymentTable, {defaultSmsPayment}))
					handlePayment(IngamePaymentDecisionType.kSmsPayOnly, defaultSmsPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
				end, function ()
					--短代原价 重买不带三方
					table.insert(repayChooseTable, defaultSmsPayment)
					handlePayment(IngamePaymentDecisionType.kSmsPayOnly, defaultSmsPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
				end)
			else
				--短代原价 重买不带三方
				table.insert(repayChooseTable, defaultSmsPayment)
				handlePayment(IngamePaymentDecisionType.kSmsPayOnly, defaultSmsPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
			end
		else
			if self:checkThirdPartPaymentEabled(true) then
				dcAndroidStatus:push(DecisionJudgeType.kThirdPayEnable.YES)

				local defaultThirdPartyPayment = self:getDefaultThirdPartPayment()
				local otherThirdPartyPayment = self:getPaymentTableWithLimit(self:getOtherThirdPartPayment(), 1)
	
				repayChooseTable = self:filterRepayPayment(AndroidPayment.getInstance().thirdPartyPayment)

				--全部三方 原价或首次打折
				dcAndroidStatus:push(DecisionJudgeType.kOneYuanEnable.NO)
				handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment, dcAndroidStatus:getStatus(), otherThirdPartyPayment, repayChooseTable) 
			else
				--支付失败 errortip
				dcAndroidStatus:push(DecisionJudgeType.kThirdPayEnable.NO)
				handlePayment(IngamePaymentDecisionType.kPayFailed, AndroidRmbPayResult.kNoPaymentAvailable, dcAndroidStatus:getStatus()) 
			end
		end
	else
		dcAndroidStatus:push(DecisionJudgeType.kDefaultPaymentType.NO)
		if self:checkThirdPartPaymentEabled(true) then 
			dcAndroidStatus:push(DecisionJudgeType.kThirdPayEnable.YES)
			local defaultSmsPayment = self:getDefaultSmsPayment()
			local thirdPartPaymentTable = AndroidPayment.getInstance().thirdPartyPayment
			local defaultThirdPartyPayment = self:getDefaultThirdPartPayment()
			if table.includes(ThirdPayWithoutNetCheck, defaultThirdPartyPayment) then 
				--这里的三方 不用联网检测 比如TELECOM3PAY
				dcAndroidStatus:push(DecisionJudgeType.kNetEnable.YES)
				--这里不判断短代是否可用了 不联网三方一般融合短代 不会用我们的短代
				repayChooseTable = self:filterRepayPayment(thirdPartPaymentTable)
				handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
			else
				PaymentNetworkCheck.getInstance():check(function ()
					--一种优先三方 若为支付宝引导快付
					dcAndroidStatus:push(DecisionJudgeType.kNetEnable.YES)
					
					local smsEnable, disableReason = self:checkSmsPayEnabled(goodsId, 1)
					if smsEnable and defaultSmsPayment ~= Payments.UMPAY then 
						repayChooseTable = self:filterRepayPayment(table.union(thirdPartPaymentTable, {defaultSmsPayment}))
					else
						repayChooseTable = self:filterRepayPayment(thirdPartPaymentTable)
					end
					handlePayment(IngamePaymentDecisionType.kThirdPayOnly, defaultThirdPartyPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
				end, function ()
					dcAndroidStatus:push(DecisionJudgeType.kNetEnable.NO)
					local smsEnable, disableReason = self:checkSmsPayEnabled(goodsId, 1)
					dcAndroidStatus:pushWithSmsEnableCheck(disableReason)
					if smsEnable and defaultSmsPayment ~= Payments.UMPAY then
						--短代原价
						repayChooseTable = self:filterRepayPayment(table.union({defaultSmsPayment}, thirdPartPaymentTable))
						handlePayment(IngamePaymentDecisionType.kSmsPayOnly, defaultSmsPayment, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
					else
						--去联网 errortip
						repayChooseTable = self:filterRepayPayment(thirdPartPaymentTable)
						handlePayment(IngamePaymentDecisionType.kPayFailed, AndroidRmbPayResult.kCloseAfterNoNetWithoutSec, dcAndroidStatus:getStatus(), nil, repayChooseTable) 
					end
				end)
			end
		else
			--支付失败 errortip
			dcAndroidStatus:push(DecisionJudgeType.kThirdPayEnable.NO)
			handlePayment(IngamePaymentDecisionType.kPayFailed, AndroidRmbPayResult.kNoPaymentAvailable, dcAndroidStatus:getStatus()) 
		end
	end
end

function PaymentManager:filterRepayPayment(repayChooseTable)
	local filterTable = nil
	if repayChooseTable then 
		filterTable = {}
		for i,v in ipairs(repayChooseTable) do
			local payment = PaymentBase:getPayment(v)
			if payment and payment:isEnabled() then 
				table.insert(filterTable, v)
			end
		end
	end
	return filterTable
end

function PaymentManager:getPaymentTableWithLimit(paymentTable, num)
	if not paymentTable or not num then return paymentTable end
	local cPaymentTable = {}
	local insertNum = 0
	for i,v in ipairs(paymentTable) do
		local payment = PaymentBase:getPayment(v)
		if payment and payment:isEnabled() and payment:getPaymentLevel() == PaymentLevel.kLvOne then 
			table.insert(cPaymentTable, v)
			insertNum = insertNum + 1
			if insertNum == num then 
				break
			end
		end
	end
	return cPaymentTable
end

function PaymentManager:getSMSPaymentDecision()
	local defaultSmsPayment = AndroidPayment.getInstance():getDefaultSmsPayment()
	if defaultSmsPayment then -- 有sim卡
		if defaultSmsPayment == Payments.UNSUPPORT then -- 不支持的运营商
			return IngamePaymentDecisionType.kPayFailed
		else
			return IngamePaymentDecisionType.kPayWithType, defaultSmsPayment
		end
	else -- 无卡或者未知种类
		return IngamePaymentDecisionType.kPayFailed
	end
end

function PaymentManager:getThirdPartPaymentDecision()
	local thirdPartPayment = Payments.UNSUPPORT

	local currentPayType = PlatformConfig:getCurrentPayType()
	local payment = PaymentBase:getPayment(currentPayType)
	if payment.mode == PaymentMode.kThirdParty then
		thirdPartPayment = payment.type
	end

	if not thirdPartPayment or thirdPartPayment == Payments.UNSUPPORT then
		return IngamePaymentDecisionType.kPayFailed
	else
		return IngamePaymentDecisionType.kPayWithType, thirdPartPayment
	end
end

function PaymentManager:setGoldOneYuanThirdPay(isOneYuan)
	self.goldOneYuanThirdPay = isOneYuan
end

function PaymentManager:getGoldOneYuanThirdPay()
	return self.goldOneYuanThirdPay
end

function PaymentManager:isThirdPartPaymentOnly(goodsId, goodsType)
	local thirdPayOnly = false
	if self.goodsType == 2 then 
		local goodsData = MetaManager:getInstance():getProductAndroidMeta(goodsId)
		if goodsData.rmb >= 3000 then 
			thirdPayOnly = true
		end
	end
	return thirdPayOnly
end

function PaymentManager:checkCanWindMillPay(goodsId)
	if not goodsId then return false end

    if table.includes( NoUseRMBPayGoodsList, goodsId ) then
        return true
    end
    
	local TradeUtils = require 'zoo.panel.endGameProp.lottery.TradeUtils'
	return TradeUtils:isGoldEnough(goodsId)
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

function PaymentManager:checkNeedOneYuanPay(goodsId)
	return false
end

function PaymentManager:resetOneYuanCheckCondition()
	self.oneYuanGoodsId = nil
	self.oneYuanShowTime = nil
end

--一些三网融合的SDK 我们放在三方的配置中 但该三方会调起对应的短代 这不算纯粹的三方支付 
function PaymentManager:checkHasRealThirdPay()
    local payments = PaymentBase:getPayments()
    for payType,payment in pairs(payments) do
    	if payment.mode == PaymentMode.kThirdParty and payType ~= Payments.WO3PAY and payType ~= Payments.TELECOM3PAY then
    		return true
    	end
    end

    return false
end

function PaymentManager:isFakeThirdPay(payType)
	if payType == Payments.WO3PAY or payType == Payments.TELECOM3PAY then 
		return true
	end
	return false
end

function PaymentManager:checkIsNoThirdPayPromotion(paymentType)
	local payment = PaymentBase:getPayment(paymentType)
	if payment.mode == PaymentMode.kSms or 
		paymentType == Payments.WO3PAY or paymentType == Payments.TELECOM3PAY or 
		payment:getPaymentLevel() ~= PaymentLevel.kLvOne then 
		return true
	end
	return false
end

function PaymentManager:setOneYuanEnergyPanel(oneYuanEnergyPanel)
	self.oneYuanEnergyPanel = oneYuanEnergyPanel
end

function PaymentManager:setCurrentEnergyPanel(currentEnergyPanel)
	self.currentEnergyPanel = currentEnergyPanel
end

function PaymentManager:getCurrentEnergyPanel()
	return self.currentEnergyPanel
end

function PaymentManager:checkSameLevel(nowDay)
	local scene = Director.sharedDirector():getRunningScene()

	if (not scene or scene:is(GamePlaySceneUI)) and self.oneYuanScene == nil then 
		if not self.isTodayFirstOneYuanLevel or self.isTodayFirstOneYuanLevel == 0 or self.isTodayFirstOneYuanLevel < nowDay then 
			self.isTodayFirstOneYuanLevel = nowDay
			self.userDefault:setIntegerForKey("one.yuan.today.level", nowDay)
			self.userDefault:flush()
			self.oneYuanScene = scene
			return true
		end
	end

	if scene == self.oneYuanScene then 
		return true
	else
		return false
	end
end

function PaymentManager:refreshOneYuanShowTime()
	self.oneYuanShowTime = now()
	self.userDefault:setStringForKey("one.yuan.show.time", self.oneYuanShowTime)
	self.userDefault:flush()
end

function PaymentManager:getDefaultSmsPayment()
	if __ANDROID then
		self.defaultSmsPayment = AndroidPayment.getInstance():getDefaultSmsPayment()
	end
	return self.defaultSmsPayment
end

function PaymentManager:checkHaveAliAPP()
	if __ANDROID then
		local function checkAndroidApp( pkgName )
			local help = luajava.bindClass("com.happyelements.android.ApplicationHelper")
			return help:checkApkExist(pkgName)
		end
		
		if self.haveAliApp == true then return self.haveAliApp end

		local ok, haveAliApp = pcall(checkAndroidApp, "com.eg.android.AlipayGphone")

		if ok == true then
			self.haveAliApp = haveAliApp
			return haveAliApp
		else
			return false
		end
	end
end

function PaymentManager:getThirdPartyPaymentPriority()
	local priority = "wechat,alipay,other"
	if PlatformConfig:isPlatform(PlatformNameEnum.kLeshop) then
		priority = "alipay,wechat,other"
	end
	local priorityConfig = MaintenanceManager:getInstance():getMaintenanceByKey("ThirdPartyPaymentPriority")
	if priorityConfig and type(priorityConfig.extra) == "string" and string.len(priorityConfig.extra) > 0 then
		priority = priorityConfig.extra
	end
	return string.split(priority, ",")
end

function PaymentManager:refreshDefaultThirdPartyPayment()
	local payments = PaymentBase:getPayments()
	if not self.defaultThirdPartyPayment or self.defaultThirdPartyPayment == 0 then
		local hasWechat = false
		local hasAli = false
		local hasOther = false
		local otherThirdPaymentType = nil
		self.defaultThirdPartyPayment = Payments.UNSUPPORT

		for payType, payment in pairs(payments) do
			if payment:isEnabled() then
				if payType == Payments.WECHAT then 
					hasWechat = true
				elseif payType == Payments.ALIPAY then 
					hasAli = true
				elseif payType ~= Payments.UNSUPPORT and payment:getPaymentLevel() == PaymentLevel.kLvOne and payment.mode == PaymentMode.kThirdParty then 
					hasOther = true
					otherThirdPaymentType = payType
				end
			end
		end

		local priority = self:getThirdPartyPaymentPriority()
		for i, payType in ipairs(priority) do
			if payType == "wechat" and hasWechat == true then
				self.defaultThirdPartyPayment = Payments.WECHAT
				break
			elseif payType == "alipay" and hasAli == true then
				self.defaultThirdPartyPayment = Payments.ALIPAY
				break
			elseif payType == "other" and hasOther == true then
				self.defaultThirdPartyPayment = otherThirdPaymentType
				break
			end
		end

		self.userDefault:setIntegerForKey("default.third.payment", self.defaultThirdPartyPayment)
		self.userDefault:flush()
	else
		local defaultIsEnable = false
		for payType, payment in pairs(payments) do
			if payType == self.defaultThirdPartyPayment and payment:isEnabled() and payment:getPaymentLevel() == PaymentLevel.kLvOne then 
				defaultIsEnable = true
				break
			end
		end
		if not defaultIsEnable then 
			self.defaultThirdPartyPayment = 0
			self:refreshDefaultThirdPartyPayment()
		end
	end
end

function PaymentManager:getDefaultThirdPartPayment(isRefresh)
	if isRefresh == true then
		self.defaultThirdPartyPayment = 0
		self:refreshDefaultThirdPartyPayment()
	end
	return self.defaultThirdPartyPayment
end

function PaymentManager:setDefaultThirdPartPayment(thirdPartPay)
	if thirdPartPay and type(thirdPartPay) == "number" then
		local payment = PaymentBase:getPayment(thirdPartPay)
		if payment:isEnabled() and payment.mode == PaymentMode.kThirdParty then
			self.defaultThirdPartyPayment = thirdPartPay
			self.userDefault:setIntegerForKey("default.third.payment", thirdPartPay)
			self.userDefault:flush()
			return 
		end
	end
end

function PaymentManager:setThirdPartPaymentAsDefault()
	local defaultThirdPartyPayment = self:getDefaultThirdPartPayment()
	if defaultThirdPartyPayment and defaultThirdPartyPayment ~= 0 then
		self:setDefaultPayment(defaultThirdPartyPayment)
		return true
	end
	return false
end

function PaymentManager:refreshDefaultPayment()
	if not self.defaultPayment or self.defaultPayment == 0 then
		local tempDefaultPayment = nil
		local noThirdPay = false
		local noSmsPay = false
		if self:checkThirdPartPaymentEabled(true) then 
			if self:getHasFirstThirdPay() then
				tempDefaultPayment = self:getDefaultThirdPartPayment()
				if tempDefaultPayment == Payments.UNSUPPORT then 
					noThirdPay = true
				end
			else
				tempDefaultPayment = self:getDefaultSmsPayment()
				if not tempDefaultPayment or tempDefaultPayment == Payments.UNSUPPORT then 
					noSmsPay = true
				end
			end
		else
			tempDefaultPayment = self:getDefaultSmsPayment()
		end
		if noThirdPay then 
			tempDefaultPayment = self:getDefaultSmsPayment()
		elseif noSmsPay then 
			tempDefaultPayment = self:getDefaultThirdPartPayment()
		end

		if tempDefaultPayment == Payments.UMPAY then
			tempDefaultPayment = nil
		end

		if tempDefaultPayment == nil then 
			tempDefaultPayment = Payments.UNSUPPORT
		end

		PaymentDCUtil.getInstance():sendDefaultPaymentChange(nil, self.lastDefaultPayment, tempDefaultPayment, 3)
		self:setDefaultPayment(tempDefaultPayment)
	else
		local noDefaultPayment = false
		if self.defaultPayment == Payments.UNSUPPORT then 
			noDefaultPayment = true
		else
			local defaultIsNotSms = false
			if not self:checkPaymentIsInSmsConfig(self.defaultPayment) then 
				defaultIsNotSms = true
			end

			local defaultIsNotThirdPay = true
			if self.defaultPayment ~= self:getDefaultThirdPartPayment() then 
				local payment = PaymentBase:getPayment(self.defaultPayment)
				if payment:isEnabled() and payment.mode == PaymentMode.kThirdParty and payment:getPaymentLevel() == PaymentLevel.kLvOne then
					self.defaultThirdPartyPayment = self.defaultPayment
					self.userDefault:setIntegerForKey("default.third.payment", thirdPartPay)
					self.userDefault:flush()
					defaultIsNotThirdPay = false
				end
			else
				defaultIsNotThirdPay = false
			end

			if defaultIsNotSms and defaultIsNotThirdPay then 
				noDefaultPayment = true
			end
		end 
		if noDefaultPayment then 
			self.defaultPayment = 0
			self:refreshDefaultPayment()
		end
	end
end

function PaymentManager:checkDefaultPaymentValid()
	local noDefaultPayment = false
	if self.defaultPayment == Payments.UNSUPPORT then 
		noDefaultPayment = true
	else
		local defaultIsNotSms = false
		if not self:checkPaymentIsInSmsConfig(self.defaultPayment) then 
			defaultIsNotSms = true
		end

		local defaultIsNotThirdPay = true
		if self.defaultPayment ~= self:getDefaultThirdPartPayment() then 
			local payment = PaymentBase:getPayment(self.defaultPayment)
			if payment:isEnabled() and payment.mode == PaymentMode.kThirdParty and payment:getPaymentLevel() == PaymentLevel.kLvOne then
				defaultIsNotThirdPay = false
			end
		else
			defaultIsNotThirdPay = false
		end

		if defaultIsNotSms and defaultIsNotThirdPay then 
			noDefaultPayment = true
		end
	end 
	if noDefaultPayment then 
		return false
	end
	return true
end

--设置面板上需求的默认支付方式 
function PaymentManager:getDefaultPayment(isRefresh)
	if isRefresh == true then
		self.defaultPayment = 0
		self:refreshDefaultPayment()
	end
	return self.defaultPayment
end

function PaymentManager:setDefaultPayment(paymentType)
	if paymentType and type(paymentType) == "number" then
		if paymentType == self.defaultPayment then return end
		self.lastDefaultPayment = paymentType
		self.defaultPayment = paymentType
		self.userDefault:setIntegerForKey("default.setting.payment", paymentType)
		self.userDefault:flush()

		--向后端同步当前默认支付方式
		-- local curSettingFlag = self:getSettingFlag(paymentType)
		local curSettingFlag = paymentType
		local http = SettingHttp.new()
		http:load(curSettingFlag)

		self:setDefaultThirdPartPayment(paymentType)
	end
end

-- function PaymentManager:getSettingFlag(paymentType)
-- 	local curSettingFlag = UserManager.getInstance().setting or 0
-- 	local bit = require("bit")
-- 	--低位24位都是用来存储支付类型的 先清空
-- 	local tempFlag = bit.rshift(curSettingFlag, PaymentTypeMaxBit)
-- 	tempFlag = bit.lshift(tempFlag, PaymentTypeMaxBit) 
-- 	if paymentType > 0 then 
-- 		local paymentFlag = bit.lshift(1, paymentType-1) 
-- 		tempFlag = tempFlag + paymentFlag
-- 	end
-- 	return tempFlag
-- end

function PaymentManager:getServerDefaultPaymentType()
	-- local curSettingFlag = UserManager.getInstance().setting or 0
	-- local serverPaymentType = 0
	-- for i=0,PaymentTypeMaxBit-1 do
	-- 	if 1 == bit.band(bit.rshift(curSettingFlag, i), 0x01) then 
	-- 		serverPaymentType = i + 1
	-- 		break 
	-- 	end
	-- end
	-- return serverPaymentType
	return UserManager.getInstance().setting or 0
end

function PaymentManager:initUserDefaultPaymentType()
	--初始化默认支付（可能是三方或者短代）
	self.defaultPayment = self:getServerDefaultPaymentType()
	if self.defaultPayment == 0 then 
		self.defaultPayment = self.userDefault:getIntegerForKey("default.setting.payment")
	end

	if self.defaultPayment == Payments.UMPAY then
		self.defaultPayment = 0
	end

	self.lastDefaultPayment = self.defaultPayment
end

function PaymentManager:resetDefaultPaymentIfDisabled()
	-- if defaultPayment not enable, reset defaultPayment
	if self.defaultPayment and self.defaultPayment ~= 0 then
		local defaultPaymentEnabled = false
		local payments = PaymentBase:getPayments()
		for payType,payment in pairs(payments) do
			if payment:isEnabled() then
				if self.defaultPayment == payType then
					defaultPaymentEnabled = true
					break
				end
			end
		end
		if not defaultPaymentEnabled then
			self.defaultPayment = 0
		end
	end
end

-- 默认支付方式是否是短代
function PaymentManager:checkDefaultPaymentIsSmsPay()
	return self:checkPaymentIsInSmsConfig(self.defaultPayment)
end

function PaymentManager:getOtherThirdPartPayment(onlyLvOne)
	local otherThirdPayTable = {}

	local payments = PaymentBase:getPayments()
	for payType,payment in pairs(payments) do
		if payType ~= self.defaultThirdPartyPayment and payment.mode == PaymentMode.kThirdParty then
			if onlyLvOne then 
				if payment:getPaymentLevel() == PaymentLevel.kLvOne then 
					table.insert(otherThirdPayTable, payType)
				end
			else
				table.insert(otherThirdPayTable, payType)
			end
		end
	end

	return otherThirdPayTable
end

function PaymentManager:setHasFirstThirdPay(firstThirdPay)
	self.hasFirstThirdPay = firstThirdPay
end

function PaymentManager:getHasFirstThirdPay()
	if self.hasFirstThirdPay then 
		return self.hasFirstThirdPay
	else
		return UserManager:getInstance().userExtend:hasFirstThirdPay()
	end
end

--每次支付成功了检测下 
function PaymentManager:checkPaymentLimit(paymentType)
	if not paymentType then return end
	--这个会在user里面由服务端返回 暂时不用
	local serverLimit = false
	if serverLimit then
		self.smspayPassLimit = serverLimit
	else
		if PaymentLimitLogic:isNeedLimit(paymentType) then 
			if PaymentLimitLogic:isExceedMonthlyLimit(paymentType) then
				self.smspayPassLimit = true
				self.smspayLimitType = SmsLimitType.kMonthlyLimit
			elseif PaymentLimitLogic:isExceedDailyLimit(paymentType) then 
				self.smspayPassLimit = true
				self.smspayLimitType = SmsLimitType.kDailyLimit
			end
		end
	end
end

function PaymentManager:getIsSmsPaymentLimit()
	return self.smspayPassLimit
end

function PaymentManager:getSmsPaymentLimitType()
	return self.smspayLimitType
end

function PaymentManager:getPriceByPaymentType(goodsId, goodsType, paymentType)
	if goodsType == 2 then 
		local goodsData = MetaManager:getInstance():getProductAndroidMeta(goodsId)
		return goodsData.rmb / 100
	else
		local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
		local thirdPaymentConfig = AndroidPayment.getInstance().thirdPartyPayment
		for i,v in ipairs(thirdPaymentConfig) do
			if v == paymentType then 
				if v == Payments.QIHOO or v == Payments.QIHOO_WX or v == Payments.QIHOO_ALI then 
					return math.floor(goodsData.thirdRmb / 100)
				else
					return goodsData.thirdRmb / 100
				end
			end
		end
		if goodsData.discountRmb ~= 0 and goodsData.discountRmb ~= "0" then
			return goodsData.discountRmb / 100
		else
			return goodsData.rmb / 100
		end
	end
end

function PaymentManager:getSignForThirdPay(goodsIdInfo)
	local goodsId = goodsIdInfo:getGoodsId()
	local goodsType = goodsIdInfo:getGoodsType()

	local signForThirdPay = nil
	if goodsType ~= 2 then 
		local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
		if goodsData then 
			signForThirdPay = goodsData.sign
		end
	end
	return signForThirdPay
end

function PaymentManager:setIsCheckingPayResult(isChecking)
	self.isCheckingPayResult = isChecking
end

function PaymentManager:getIsCheckingPayResult()
	return self.isCheckingPayResult
end

function PaymentManager:getAliQuickPayLimit()
	return self.aliQuickPayLimit 	
end

function PaymentManager:getWechatQuickPayLimit()
	return self.wechatQuickPayLimit
end

--是否是支付宝免密支付大限度的平台 目前he和tf 支持上限开到60块 其它小于60块
function PaymentManager:isHighLimitPlatform()
	local limitPlatformTable = {
	    PlatformNameEnum.kTF,
	    PlatformNameEnum.kHE,
	}
	local plarformName = StartupConfig:getInstance():getPlatformName()
	if plarformName and table.includes(limitPlatformTable, plarformName) then 
		return true
	end
	return false 
end

function PaymentManager:checkCanAliQuickPay(payPrice, goodsId)

	if goodsId ~= nil then
		if goodsId == 478 then
			return false
		end
	end

	if not payPrice then return false end

	payPrice = tonumber(payPrice) or 0

	local quickPayLimit = self:getAliQuickPayLimit()
	local isHighLimitPF = self:isHighLimitPlatform()
	if (payPrice < quickPayLimit or (isHighLimitPF and payPrice <= quickPayLimit))
	and UserManager:getInstance():getAliKfMonthlyLimit() > 0 and UserManager:getInstance():getAliKfDailyLimit() > 0 then
		return true
	end
	return false
end

function PaymentManager:shouldShowAliQuickPay()
	local isSpecialPF = MaintenanceManager:getInstance():isEnabled("AliSignInGame2")
	if isSpecialPF then 
		if not MaintenanceManager:getInstance():isEnabled('AliSignAndPay') then 
			if _G.isLocalDevelopMode then printx(0, 'PaymentManager:shouldShowAliQuickPay()=======AliSignAndPay========false') end
			return false 
		end

		local isInstalled = false
	    if __ANDROID then
	        local function safeCheck()
	            local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
	            local context = MainActivityHolder.ACTIVITY
	            local packageManager = context:getPackageManager()
	            local info = packageManager:getPackageInfo('com.eg.android.AlipayGphone', 64)

	            if info ~= nil and info.applicationInfo and info.applicationInfo.enabled then
	                isInstalled = true
	            end
	        end
	        local ret = pcall(safeCheck)
	    end
	    if _G.isLocalDevelopMode then printx(0, 'PaymentManager:shouldShowAliQuickPay()=======isInstalled========', isInstalled) end
    	return isInstalled
	else
		if _G.isLocalDevelopMode then printx(0, 'PaymentManager:shouldShowAliQuickPay()=======AliSignInGame2========true') end
		return true
	end
end

function PaymentManager:checkCanWechatQuickPay(payPrice)
	if not _G.wxmmGlobalEnabled or not WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then return false end -- 未开开关，全都不可免密支付

	if not payPrice then return false end

	local quickPayLimit = self:getWechatQuickPayLimit()
	local isHighLimitPF = self:isHighLimitPlatform()
	if payPrice < quickPayLimit or (isHighLimitPF and payPrice <= quickPayLimit) then
		return true
	end
	return false
end

function PaymentManager:checkUseNewWechatPay(pf)
	if not pf then return false end
	local useNewWechatTable = {
		PlatformNameEnum.kAnZhi,
		PlatformNameEnum.kZTEMINIPre,
		PlatformNameEnum.kZTEPre,
		PlatformNameEnum.kAsusPre,
		PlatformNameEnum.kMI,
	}
	if table.includes(useNewWechatTable, pf) then 
		return true
	end
	return false
end

function PaymentManager:checkPaymentTypeIsSms(paymentType)
	local payment = PaymentBase:getPayment(paymentType)
	return payment.mode == PaymentMode.kSms
end

function PaymentManager:setContinueSmsPayCount(count)
	if not count then count = 0 end
	self.continueSmsPayCount = count
	self.userDefault:setIntegerForKey("continue.smspay.count", count)
	self.userDefault:flush()
end

function PaymentManager:tryChangeDefaultPaymentType(paymentType)
	local oriPaymentType = self.defaultPayment
	local isSmsPay = self:checkPaymentTypeIsSms(paymentType)
	if isSmsPay then 
		if paymentType == self.defaultPayment then 
			return
		elseif self:checkPaymentIsInSmsConfig(self.defaultPayment) then 
			--走到这里证明玩家可用的短代和当前记录的默认支付方式（必为短代）不符 这里自动改掉
			--这样的特殊处理是基于产品需求 导致我们获取的默认支付方式不是玩家可用的支付方式 具体参考本次修改记录中的其它代码
			self:setDefaultPayment(paymentType)
			return
		else
			local continueSmsPayCount = self.continueSmsPayCount
			if continueSmsPayCount < 2 then 
				self:setContinueSmsPayCount(continueSmsPayCount + 1)
			else
				PaymentDCUtil.getInstance():sendDefaultPaymentChange(nil, self.defaultPayment, paymentType, 2)
				self:setDefaultPayment(paymentType)
				self:setContinueSmsPayCount(0)
				if not self.paymentAutoChangeFlag then
					self.paymentAutoChangeFlag = true 
					self.paymentBeforeAutoChange = oriPaymentType
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kDefaultPaymentTypeAutoChange))
				end
			end
		end
	else
		if self.continueSmsPayCount and self.continueSmsPayCount ~= 0 then 
			self:setContinueSmsPayCount(0)
		end
		self:setHasFirstThirdPay(true)
	
		if paymentType ~= self.defaultPayment then 
			local payment = PaymentBase:getPayment(paymentType)
			if payment and payment:isEnabled() and payment:getPaymentLevel() == PaymentLevel.kLvOne then 
				PaymentDCUtil.getInstance():sendDefaultPaymentChange(nil, self.defaultPayment, paymentType, 1)
				self:setDefaultPayment(paymentType)
				if not self.paymentAutoChangeFlag then
					self.paymentAutoChangeFlag = true 
					self.paymentBeforeAutoChange = oriPaymentType
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kDefaultPaymentTypeAutoChange))
				end
			end
		end
	end
end

function PaymentManager:setPaymentAutoChangeFlag(paymentAutoChange)
	self.paymentAutoChangeFlag = paymentAutoChange
	
end

function PaymentManager:setPaymentBeforeAutoChange(paymentBeforeAutoChange)
	self.paymentBeforeAutoChange = paymentBeforeAutoChange
end

function PaymentManager:getPaymentBeforeAutoChange()
	return self.paymentBeforeAutoChange
end

--某些道具不参与qq钱包测试的支付排序 
function PaymentManager:isSpecialGoods(oriGoodsId)
	local ignoreIdTable = {
		24,33,46,47,			--最终加五步面板的(1.38弃用)
		278,280,296,279,281,155,472,473, 		--最终加五步面板的
		103,104,105,106,		--签到礼包
		150,					--周赛次数
	}
	local goodsName = Localization:getInstance():getText("goods.name.text"..tostring(oriGoodsId))
	if table.includes(ignoreIdTable, oriGoodsId) or string.find(goodsName, "新区域解锁") then 
		return true
	end
	return false
end

function PaymentManager:needSpecialNoHappyCoinBuyPanel(goodsID)
	if (goodsID == 511 or goodsID == 512 or goodsID == 641) then
		return true
	else
		return false
	end
end

function PaymentManager:isNeedThirdPayGuide(paymentType)
	if PlatformConfig:isBaiduPlatform() then
		return false
	end
	if paymentType and paymentType == Payments.WECHAT or paymentType == Payments.ALIPAY or paymentType == Payments.QQ then 
		return true
	end
	return false
end

function PaymentManager:checkPaymentIsInSmsConfig(paymentType)
	local payment = PaymentBase:getPayment(paymentType)
	return payment.mode == PaymentMode.kSms
end

local IgnorePaymentTypes = {
}
function PaymentManager:isNeedSmsPayOnlineCheck(goodsId, goodsType, exceptType)
	if exceptType then
		if table.includes(IgnorePaymentTypes, exceptType) then 
			return false
		end
	end
	if goodsType == 1 then
		if (StarBank and StarBank:hasGoodsId(goodsId)) then
			return MaintenanceManager:getInstance():isEnabled("SmsPayOnlineCheck", true)
		end
		return MaintenanceManager:getInstance():isEnabled("SmsPayOnlineCheckGoods", true)
	end
	if goodsType == 2 then 
		return MaintenanceManager:getInstance():isEnabled("SmsPayOnlineCheck", true)
	end

	return false
end

function PaymentManager:isSmsPayLike(payment)
	if payment and (payment.mode == PaymentMode.kSms or payment.type == Payments.WO3PAY or payment.type == Payments.TELECOM3PAY) then
		return true
	end
	return false
end