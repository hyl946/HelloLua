require "zoo.payment.PaymentManager"
require "zoo.payment.GoodsIdInfoObject"
require "zoo.payment.paymentDC.PaymentDCUtil"
require "zoo.payment.paymentDC.DCAndroidRmbObject"
require "zoo.payment.PaymentEventDispatcher"
require "zoo.payment.PayPanelCoin"
require "zoo.payment.PayPanelWindMill"
require "zoo.payment.ingameBuyPropPanels.PayPanelWindMill_VerB"
require "zoo.payment.PayPanelSingleSms"
require "zoo.payment.ingameBuyPropPanels.PayPanelSingleSms_VerB"
require "zoo.payment.PayPanelOneYuanSingle"
require "zoo.payment.PayPanelOneYuanMulti"
require "zoo.payment.PayPanelSingleThird"
require "zoo.payment.ingameBuyPropPanels.PayPanelSingleThird_VerB"
require "zoo.payment.PayPanelMultiThird"
require "zoo.payment.PayPanelSingleThirdOff"
require "zoo.payment.ingameBuyPropPanels.PayPanelSingleThirdOff_VerB"
require "zoo.payment.PayPanelMultiThirdOff"
require "zoo.payment.PayPanelRePay"
require "zoo.payment.ManualOnlinePayCheck"

require 'zoo.panel.ChoosePaymentPanel'
require 'hecore.sns.aps.AndroidPayment'
require "zoo.panelBusLogic.PaymentLimitLogic"
require 'zoo.gameGuide.ThirdPayGuideLogic'
-- require 'zoo.payment.AndroidSDKPayLogic'
require 'zoo.payment.WechatQuickPayLogic'
require 'zoo.panelBusLogic.AliQuickPayPromoLogic'

require 'zoo.panel.WechatFriendPanel'
require "zoo.panel.broadcast.BroadcastManager"

require "zoo.payment.paycheck.PaymentCheckManager"

local RePayABTestMgr = require 'zoo.payment.repay.RePayABTestMgr'
local PayPanelRePay_VerB = require 'zoo.payment.repay.PayPanelRePay_VerB'


IngamePaymentLogic = class()

function IngamePaymentLogic:create(goodsId, goodsType, feature, source, dcAndroidInfo)
	local logic = IngamePaymentLogic.new()
	logic.goodsIdInfo = GoodsIdInfoObject:create(goodsId, goodsType)
	logic.feature = feature
	logic.source = source
	logic:init(dcAndroidInfo)
	return logic
end

function IngamePaymentLogic:createWithGoodsInfo(goodsIdInfo, dcAndroidInfo, feature, source)
	local logic = IngamePaymentLogic.new()
	logic.goodsIdInfo = goodsIdInfo
	logic.feature = feature
	logic.source = source
	logic:setOriGoodsIdType(goodsIdInfo:getCurrentChangeType())
	logic:init(dcAndroidInfo)
	return logic
end

function IngamePaymentLogic:ctor()
	--与本次支付相关的确认面板 外部面板如加五步需要调用 setBuyConfirmPanel 设置
	self.buyConfirmPanel = nil
	--失败后可能弹出的重新购买面板
	self.repayPanel = nil
	--默认有重新购买
	self.noRePay = false
	--默认checkOnlinePay时 没有loading框
	self.needLoadingMask = false	
	--原始的goodsId转换的状态 只在最初改变的时候记录
	self.oriGoodsIdType = GoodsIdChangeType.kNormal
	--是否使用新的分组优化逻辑  wiki http://wiki.happyelements.net/pages/viewpage.action?pageId=22495586
	self.useNewOptimizationLogic = true
end

-- goodsType: 1: 要买的是普通道具
--            2: 要买的是风车币
function IngamePaymentLogic:init(dcAndroidInfo)
	self.reBuyGoldCount = 1
	self.amount = 1
	if dcAndroidInfo then 
		self.dcAndroidInfo = dcAndroidInfo
	else
		self.dcAndroidInfo = DCAndroidRmbObject:create()
	end

	self.dcAndroidInfo:setGoodsId(self.goodsIdInfo:getGoodsId())
	self.dcAndroidInfo:setGoodsType(self.goodsIdInfo:getGoodsType())
	self.dcAndroidInfo:setGoodsNum(self.amount)
end

--for niuniu 
function IngamePaymentLogic:setReBuyCount(reBuyGoldCount)
	self.reBuyGoldCount = reBuyGoldCount
end

--for reast.li
function IngamePaymentLogic:setSourceFlag(sourceFlag)
	self.sourceFlag = sourceFlag
end

function IngamePaymentLogic:setActivityId(activityId)
	self.activityId = activityId
end

function IngamePaymentLogic:rmbBuyFailed(errCode, errMsg)
	--不弹重买，不弹支付教程，直接返回失败，本次支付流程完全结束
	local function __directError(__errCode, __errMsg)
		if self.failCallback then
			self.failCallback(__errCode or errCode, __errMsg or errMsg) 
		end
	end

	--避免出现sourcePanel处自己的tip
	local function __directCancel(ignoreTip)
		if self.cancelCallback then self.cancelCallback(ignoreTip) end

		if (self.buyConfirmPanel) and (not self.buyConfirmPanel.isDisposed) and self.buyConfirmPanel.setBuyBtnEnabled then 
			self.buyConfirmPanel:setBuyBtnEnabled(true)
		end
	end

	--微信精品包特殊错误码下的特殊处理
	if WXJPPackageUtil.getInstance():isWXJPPackage() then 
		if errCode == WXJPPackageUtil.getInstance().errorCode2 then 
			__directCancel(true)
			CommonTip:showTip(localize("wxjp.loading.tips.success.pay"), "positive")
			return
		elseif errCode == WXJPPackageUtil.getInstance().errorCode3 then 
			__directCancel(true)
			CommonTip:showTip(localize("wxjp.loading.tips.fail.pay"), "negative")
			return
		elseif errCode == WXJPPackageUtil.getInstance().errorCode4 then
			CommonTip:showTip(localize("wxjp.loading.tips.fail"), "negative", function ()
				WXJPPackageUtil.getInstance():restartWithDataClean()
			end, 1)	
			return
		end
	end
	--实名制失败导致的支付失败要特殊处理, 不进入重买逻辑
	if errCode == RealNameManager.errCode then
		__directError()

		if (self.buyConfirmPanel) and (not self.buyConfirmPanel.isDisposed) and self.buyConfirmPanel.setBuyBtnEnabled then 
			self.buyConfirmPanel:setBuyBtnEnabled(true)
		end

		if (self.repayPanel) and (not self.repayPanel.isDisposed) and self.repayPanel.setBuyBtnEnabled then 
			self.repayPanel:setBuyBtnEnabled(true)
		end
		
		return
	end

	if MaintenanceManager:getInstance():isEnabled("RepayPanelFeature") and not self.noRePay and self.repayChooseTable then 
		if RePayABTestMgr:isOld() then
			self:closeBuyConfirmPanel()                            --关闭可能已弹出的二次确认面板
			self:closeSourcePanel()
			self.goodsIdInfo:setGoodsIdChange(self.oriGoodsIdType) --goodsId设为最开始的值 
			self.dcAndroidInfo:increaseTimes() 		   
			if not self.repayPanel then 
				if self.repayPanelPopFunc then self.repayPanelPopFunc() end
				local peDispatcher = self:getPaymentEventDispatcher(true)
				self.repayPanel = PayPanelRePay:create(peDispatcher, self.goodsIdInfo, self.paymentType, self.repayChooseTable, errCode)
				self.repayPanel:popout()
			else
				if not self.repayPanel.isDisposed then 
					self.repayPanel:setBuyBtnEnabled(true)
				end
			end
			CommonTip:showTip(Localization:getInstance():getText("payment.failure.tip.repay"), "negative")
		else
			RePayABTestMgr:process(self.paymentType, self.repayChooseTable, function ( resultType, tip, isConnected )
				if resultType == 1 then
					self:closeBuyConfirmPanel()                            --关闭可能已弹出的二次确认面板
					self:closeSourcePanel()
					self.goodsIdInfo:setGoodsIdChange(self.oriGoodsIdType) --goodsId设为最开始的值 
					self.dcAndroidInfo:increaseTimes() 
					if not self.repayPanel then 
						if self.repayPanelPopFunc then self.repayPanelPopFunc() end
						local peDispatcher = self:getPaymentEventDispatcher(true)
						local notChangeBtnColor = RePayABTestMgr:isNewB()
						self.repayPanel = PayPanelRePay_VerB:create(peDispatcher, self.goodsIdInfo, self.repayChooseTable, isConnected, tip, notChangeBtnColor)
						self.repayPanel:popout()
					end
					local Common = require('zoo.payment.repay.Common')
					local lastPayType = Common:getOriPayment(self.paymentType)
					local isThirdParty = lastPayType and Common:isThirdParty(lastPayType) or false
					if (isThirdParty or errCode == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec) and not isConnected then
						CommonTip:showTip(Localization:getInstance():getText("payment_repay_txt4"), "negative")
					else
						CommonTip:showTip(Localization:getInstance():getText("payment.failure.tip.repay"), "negative")
					end
				else
					CommonTip:showTip(tip)
					__directCancel(true)
					return
				end
			end)
		end
	else
		if self.goodsIdInfo:getGoodsType() == GoodsType.kCurrency and PaymentManager:isNeedThirdPayGuide(self.paymentType) then 
			ThirdPayGuideLogic:onPayFailure(self.paymentType, function ()
				if self.failCallback then self.failCallback(errCode, errMsg) end
			end)
		else
			__directError()
		end
	end
end

function IngamePaymentLogic:rmbBuyCancel()
	local function __directCancel(ignoreTip)
		if self.cancelCallback then self.cancelCallback(ignoreTip) end
	end

	if MaintenanceManager:getInstance():isEnabled("RepayPanelFeature") and not self.noRePay and self.repayChooseTable then 

		if RePayABTestMgr:isOld() then
			self:closeBuyConfirmPanel()  						    --关闭可能已弹出的二次确认面板
			self:closeSourcePanel()
			self.goodsIdInfo:setGoodsIdChange(self.oriGoodsIdType) 	--goodsId设为最开始的值
			self.dcAndroidInfo:increaseTimes() 	
			if not self.repayPanel then 
				if self.repayPanelPopFunc then self.repayPanelPopFunc() end
				local peDispatcher = self:getPaymentEventDispatcher(true)
				self.repayPanel = PayPanelRePay:create(peDispatcher, self.goodsIdInfo, self.paymentType, self.repayChooseTable)
				self.repayPanel:popout()
			else
				if not self.repayPanel.isDisposed then 
					self.repayPanel:setBuyBtnEnabled(true)
				end
			end
			CommonTip:showTip(Localization:getInstance():getText("payment.cancel.tip.repay"), "negative")
		else
			RePayABTestMgr:process(self.paymentType, self.repayChooseTable, function ( resultType, tip, isConnected )
				if resultType == 1 then
					self:closeBuyConfirmPanel()                            --关闭可能已弹出的二次确认面板
					self:closeSourcePanel()
					self.goodsIdInfo:setGoodsIdChange(self.oriGoodsIdType) --goodsId设为最开始的值 
					self.dcAndroidInfo:increaseTimes() 
					if not self.repayPanel then 
						if self.repayPanelPopFunc then self.repayPanelPopFunc() end
						local peDispatcher = self:getPaymentEventDispatcher(true)
						local notChangeBtnColor = RePayABTestMgr:isNewB()
						self.repayPanel = PayPanelRePay_VerB:create(peDispatcher, self.goodsIdInfo, self.repayChooseTable, isConnected, tip, notChangeBtnColor)
						self.repayPanel:popout()
					end
					CommonTip:showTip(Localization:getInstance():getText("payment.failure.tip.repay"), "negative")
				else
					CommonTip:showTip(tip)
					__directCancel(true)

					if (self.buyConfirmPanel) and (not self.buyConfirmPanel.isDisposed) and self.buyConfirmPanel.setBuyBtnEnabled then 
						self.buyConfirmPanel:setBuyBtnEnabled(true)
					end
					return
				end
			end)
		end
	else
		if self.goodsIdInfo:getGoodsType() == GoodsType.kCurrency and PaymentManager:isNeedThirdPayGuide(self.paymentType) then 
			ThirdPayGuideLogic:onPayFailure(self.paymentType, function ()
				if self.cancelCallback then self.cancelCallback() end
			end)
		else
			__directCancel()
		end
	end
end

function IngamePaymentLogic:getPaymentEventDispatcher(isRepayPanel)
	local peDispatcher = PaymentEventDispatcher.new()
	peDispatcher:addEventListener(PaymentEvents.kBuyConfirmPanelPay, function (evt)
		if isRepayPanel then 
			self:repayPanelPay(evt)
		else
			self:confirmPanelPay(evt)
		end
	end)
	peDispatcher:addEventListener(PaymentEvents.kBuyConfirmPanelClose, function ()
		if isRepayPanel then 
			self:repayPanelClose()
		else
			self:confirmPanelClose()
		end
	end)

	peDispatcher:addEventListener(PaymentEvents.kCloseAllAndReBuy, function ()
		if isRepayPanel then 
			self:repayPanelClose()
		else
			self:confirmPanelClose()
		end

		self:buy(self.successCallback,
					self.failCallback,
					self.cancelCallback,
					self.noRePay,
					self.noSign)
	end)
	return peDispatcher
end

function IngamePaymentLogic:repayPanelPay(event)
	if RePayABTestMgr:isNew() then
		self:closeRepayPanel()
	end

	local paymentType = event.data.defaultPaymentType
	self:buyWithPaymentType(paymentType, true)
end

function IngamePaymentLogic:repayPanelClose()
	self.repayPanel = nil
	self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseRepayPanel)
	PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
	--执行后续操作 这里加五步要特殊处理 直接结束游戏
	if self.gameOverCallback then 
		self.gameOverCallback()
	else
		if self.cancelCallback then self.cancelCallback() end
	end

	--关闭一些在repaypanel显示期间隐藏的面板
	self:closeSourcePanel(true)
end

function IngamePaymentLogic:confirmPanelPay(event)
	local paymentType = event.data.defaultPaymentType
	self:buyWithPaymentType(paymentType)
end

function IngamePaymentLogic:confirmPanelClose()
	self.buyConfirmPanel = nil
	local payResult = self.dcAndroidInfo:getResult()
	if payResult and payResult == AndroidRmbPayResult.kNoNet then 
		self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
	elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
        self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
	else
		self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseDirectly)
	end
	PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
	--执行后续操作
	if self.cancelCallback then self.cancelCallback() end
end

function IngamePaymentLogic:setBuyConfirmPanel(buyConfirmPanel)
	self.buyConfirmPanel = buyConfirmPanel
end

function IngamePaymentLogic:setOriGoodsIdType(oriGoodsIdType)
	self.oriGoodsIdType = oriGoodsIdType
end

function IngamePaymentLogic:getPanelIconPos()
	if self.buyConfirmPanel and not self.buyConfirmPanel.isDisposed and self.buyConfirmPanel.getIconPos then 
		return self.buyConfirmPanel:getIconPos()
	elseif self.repayPanel and not self.repayPanel.isDisposed and self.repayPanel.getIconPos then
		return self.repayPanel:getIconPos()
	end
end

function IngamePaymentLogic:closeBuyConfirmPanel()
	if self.buyConfirmPanel and not self.buyConfirmPanel.isDisposed and self.buyConfirmPanel.removePopout then 
		self.buyConfirmPanel:removePopout()
		self.buyConfirmPanel = nil
	end
end

function IngamePaymentLogic:closeRepayPanel()
	if self.repayPanel and not self.repayPanel.isDisposed and self.repayPanel.removePopout then 
		self.repayPanel:removePopout()
		self.repayPanel = nil
	end
end

function IngamePaymentLogic:closeSourcePanel(realClose)
	if self.sourcePanel and not self.sourcePanel.isDisposed then 
		if realClose then 
			if self.sourcePanel.removePopout then 
				self.sourcePanel:removePopout()
				self.sourcePanel = nil
			end
		else
			self.sourcePanel:setVisible(false)
		end
	end
end

function IngamePaymentLogic:hasPanelPopOutOnScene()
	if (self.buyConfirmPanel and not self.buyConfirmPanel.isDisposed and self.buyConfirmPanel:getParent()) or
		(self.repayPanel and not self.repayPanel.isDisposed and self.repayPanel:getParent()) then  
		return true
	end	
	return false
end

function IngamePaymentLogic:setRepayPanelPopFunc(repayPanelPopFunc)
	self.repayPanelPopFunc = repayPanelPopFunc
end

--noRePay 为true 不会弹出重买面板
--noSign 为true 不会引导免密签约
function IngamePaymentLogic:buy(successCallback, failCallback, cancelCallback, noRePay, noSign,isFreeVideo)
	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showInGameDialog(cancelCallback)
		return 
	end

	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	
	self.isFreeVideo = isFreeVideo
	self.goodsIdInfo.isFreeVideo = isFreeVideo
	self.goodsIdInfo.videoCallback = successCallback
	
	self.noRePay = noRePay
	self.noSign = noSign
	if self.noSign then 
		_G.use_ali_quick_pay = false
		_G.use_wechat_quick_pay = false
	end
	
	local function handlePayment(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable, typeDisplay)
		printx( 3 , ' decision ', decision, 'paymentType ', paymentType)
		local cantSetRepay = false

		if StarBank then
			local payment = PaymentBase:getPayment(paymentType)
			local gid = self.goodsIdInfo:getOriginalGoodsId()
			local is485 = 485 == gid or 510 == gid or 614 == gid or 615 == gid

			if is485 and (payment.mode == PaymentMode.kSms or 
							payment.type == Payments.TELECOM3PAY or 
							payment.type == Payments.WO3PAY) 
			then
				if failCallback then failCallback() end
				CommonTip:showTip('购买失败')
				return
			elseif is485 and repayChooseTable then
				local repayCT = {}
				for _,pt in ipairs(repayChooseTable) do
					local pay = PaymentBase:getPayment(pt)
					if pay.mode ~= PaymentMode.kSms
						and pay.type ~= Payments.TELECOM3PAY
						and	pay.type ~= Payments.WO3PAY
					then
						table.insert(repayCT, pt)
					end
				end
				repayChooseTable = repayCT
				self.repayChooseTable = repayCT
				cantSetRepay = true
			end
		end

		if decision ~= IngamePaymentDecisionType.kPayWithWindMill then 		--风车币购买单独打点
			PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcAndroidInfo)
		end

		if not cantSetRepay then
			self:setRepayChooseTable(repayChooseTable, decision == IngamePaymentDecisionType.kThirdPayOnly)
		end

		self.dcAndroidInfo:setTypeStatus(dcAndroidStatus)
		--type_display：支持QQ钱包的实验用户的6种展示弹窗
		self.dcAndroidInfo:setTypeDisplay(typeDisplay)
		if self.repayChooseTable then 
			self.dcAndroidInfo:setRepayTypeList(self.repayChooseTable)
		end
		self:handlePaymentDecision(decision, paymentType, otherPaymentTable)
	end

	PaymentManager.getInstance():getAndroidPaymentDecision(self.goodsIdInfo:getGoodsId(), self.goodsIdInfo:getGoodsType(), handlePayment)
end

--目前用于加五步面板 
--目前也用于在加五步那购买钻石
--没有走统一的buy方法是因为加五步面板的特殊性 需要提前调用PaymentManager.getInstance():getBuyItemDecision
function IngamePaymentLogic:endGameBuy(decision, paymentType, successCallback, failCallback, cancelCallback, gameOverCallback, repayChooseTable)
	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showInGameDialog(cancelCallback)
		return 
	end

	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	self.gameOverCallback = gameOverCallback
	self:setRepayChooseTable(repayChooseTable)
	self.needLoadingMask = true

	if decision == IngamePaymentDecisionType.kPayFailed then 	
		--加五步面板断网导致支付失败要特殊处理 因为此时面板已经弹出
		if paymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
			paymentType = PaymentManager.getInstance():getDefaultThirdPartPayment()
		else
			self:handlePayFailed(paymentType)
			return 
		end
	end

	if self.repayChooseTable then 
		self.dcAndroidInfo:setRepayTypeList(self.repayChooseTable)
	end
	self:buyWithPaymentType(paymentType)
end

--目前用于签到 解锁 周赛买次数等面板
--这类面板弹出时并未生成订单 在点下购买的时候才生成订单
function IngamePaymentLogic:specialBuy(decision, paymentType, successCallback, failCallback, cancelCallback, repayChooseTable, sourcePanel, onlyThirdparty)
	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showInGameDialog(cancelCallback)
		return 
	end
	--pay_start点
	PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcAndroidInfo)

	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	self:setRepayChooseTable(repayChooseTable, onlyThirdparty)
	self.needLoadingMask = true
	self.sourcePanel = sourcePanel
	
	if self.repayChooseTable then 
		self.dcAndroidInfo:setRepayTypeList(self.repayChooseTable)
	end
	if decision == IngamePaymentDecisionType.kPayFailed then 	
		--断网导致支付失败要特殊处理 因为此时面板已经弹出
		if paymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
			paymentType = PaymentManager.getInstance():getDefaultThirdPartPayment()
		else
			self:handlePayFailed(paymentType)
			return 
		end
	elseif decision == IngamePaymentDecisionType.kThirdPayOnly then 
		local peDispatcher = self:getPaymentEventDispatcher()
		peDispatcher:addEventListener(PaymentEvents.kBuyConfirmPanelClose, function ()
			if sourcePanel and not sourcePanel.isDisposed then sourcePanel:setVisible(true) end
		end)
		
		local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
		local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"
		if paymentType == Payments.ALIPAY and 
		   (UserManager.getInstance():isAliSigned() or 
		   		(UserManager.getInstance():isAliNeverSigned() and AliQuickPayGuide.isGuideTime() and PaymentManager.getInstance():shouldShowAliQuickPay())) 
		   	then

		    if sourcePanel and not sourcePanel.isDisposed then sourcePanel:setVisible(false) end
			self.dcAndroidInfo:setInitialTypeList(Payments.ALI_QUICK_PAY)
			if not UserManager.getInstance():isAliSigned() then 
				peDispatcher = self:pocessSignPayPeDispathcher(peDispatcher)
			end			
			self.buyConfirmPanel = PayPanelSingleThird:create(peDispatcher, self.goodsIdInfo, paymentType)
			self.buyConfirmPanel:popout()
			AliQuickPayGuide.updateGuideTimeAndPopCount()
			return
		elseif paymentType == Payments.WECHAT and
			   (UserManager.getInstance():isWechatSigned() or 
			   UserManager.getInstance():isWechatNeverSigned() and 
			   WechatQuickPayGuide.isGuideTime()) and 
			   _G.wxmmGlobalEnabled and 
			   WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then

			if sourcePanel and not sourcePanel.isDisposed then sourcePanel:setVisible(false) end
			self.dcAndroidInfo:setInitialTypeList(Payments.WECHAT_QUICK_PAY)
			if not UserManager.getInstance():isWechatSigned() then 
				peDispatcher = self:pocessSignPayPeDispathcher(peDispatcher)
			end
			self.buyConfirmPanel = PayPanelSingleThird:create(peDispatcher, self.goodsIdInfo, paymentType)
			self.buyConfirmPanel:popout()
			WechatQuickPayGuide.updateGuideTimeAndPopCount()
			return 
		end
	end

	self.dcAndroidInfo:setInitialTypeList(paymentType)
	self:buyWithPaymentType(paymentType)
end

--目前用于安卓破冰促销购买
function IngamePaymentLogic:salesBuy(paymentType, successCallback, failCallback, cancelCallback, repayChooseTable)
	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showInGameDialog(cancelCallback)
		return 
	end

	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	self:setRepayChooseTable(repayChooseTable, true)
	self.needLoadingMask = true

	if self.repayChooseTable then 
		self.dcAndroidInfo:setRepayTypeList(self.repayChooseTable)
	end
	self:buyWithPaymentType(paymentType)
end

--新商店购买 2019/03/26 1.66动更

function IngamePaymentLogic:storeBuy(paymentType, successCallback, failCallback, cancelCallback)
	if PrepackageUtil:isPreNoNetWork() then
		PrepackageUtil:showInGameDialog(cancelCallback)
		return 
	end
	self.successCallback = successCallback
	self.failCallback = failCallback
	self.cancelCallback = cancelCallback
	self.needLoadingMask = true
	self.noRePay = true
	self.notChangeDefaultPaymentType = true
	-- self.dcAndroidInfo:setInitialTypeList(paymentType)

	
	
	self:buyWithPaymentType(paymentType)
end

function IngamePaymentLogic:buyWithPaymentType(paymentType, isFromRepayPanel)
	self.paymentType = paymentType
	local goodsId = self.goodsIdInfo:getGoodsId()
	if _G.isLocalDevelopMode then printx(0, "wenkan zhijian==IngamePaymentLogic:buyWithPaymentType======",paymentType, goodsId) end
	local goodsType = self.goodsIdInfo:getGoodsType()
	local finalPrice = PaymentManager.getInstance():getPriceByPaymentType(goodsId, goodsType, paymentType)

	self.dcAndroidInfo:setTypeChoose(paymentType, isFromRepayPanel)
	self.dcAndroidInfo:setGoodsId(goodsId)
	self.dcAndroidInfo:setRmbPrice(finalPrice)
	self.isFromRepayPanel = isFromRepayPanel

	local function payCallback( result )
		PaymentCheckManager.getInstance():setNeedPaymentCheck(false)

		self:onPayCallback(result)
	end

	local onButton1Click = function()

		local goodsInfo = {
						goodsType = goodsType,
						goodsIdInfo = self.goodsIdInfo,
						amount = self.amount,
						totalFee = finalPrice,
						}

		PaymentBase:buyWithType(paymentType, goodsInfo, payCallback)	
	end

	local onButton2Click = function()
		self.dcAndroidInfo:setResult(AndroidRmbPayResult.kSmsPermission)
		PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
		self:rmbBuyCancel()
	end


	if PaymentManager:checkPaymentTypeIsSms(paymentType) then
	    PermissionManager.getInstance():requestEach(PermissionsConfig.SEND_SMS, onButton1Click, onButton2Click)
	    
		-- CommonAlertUtil:showPrePkgAlertPanel(onButton1Click, NotRemindFlag.SMS_ALLOW, Localization:getInstance():getText("pre.tips.sms"),
		-- 									 nil, nil, onButton2Click,nil,nil,RequestConst.SMS_ALLOW)
	else
		onButton1Click()
	end
end

function IngamePaymentLogic:onPayCallback( result )
	local choosenType = result.subPayType or result.payType
	if choosenType then 
		if self.isFromRepayPanel then 
			self.dcAndroidInfo:setTypeChoose(choosenType, true)
		else
			self.dcAndroidInfo:setTypeChoose(choosenType)
		end	
	end
	self.dcAndroidInfo:setTradeId(result.tradeId)
	
	if result.resultType == PayResultType.kSuccess then
		self:onPaySuccess(result)
	elseif result.resultType == PayResultType.kError then
		self:onPayFailed(result)
	elseif result.resultType == PayResultType.kCancel then
		self:onPayCancel(result)
	end

	if self.goodsIdInfo:getGoodsType() == GoodsType.kCurrency then -- 买风车币的打点
		PaymentDCUtil.getInstance():sendAndroidBuyGold(
			self.dcAndroidInfo, 
			self.reBuyGoldCount, 
			result.orderId, 
			choosenType
		)
	end
end

function IngamePaymentLogic:onPaySuccess( result )
	self.dcAndroidInfo:setResult(AndroidRmbPayResult.kSuccess)
	self.dcAndroidInfo:setChannelId(result.channelId)

	PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)

	local goodsId = self.goodsIdInfo:getGoodsId()
	local goodsType = self.goodsIdInfo:getGoodsType()
	printx( 1 , "   IngamePaymentLogic:onPaySuccess     " , goodsId, goodsType)
	local payment = PaymentBase:getPayment(self.paymentType)

	if not PaymentManager.getInstance():isSmsPayLike(payment) then
		Localhost.getInstance():ingame(goodsId, result.orderId, result.channelId, goodsType)
	end

	if self.paymentType == Payments.CHINA_MOBILE_GAME then
		local networkState, lastCheckTime = PaymentNetworkCheck.getInstance():getNetworkState()
		if lastCheckTime and not networkState then
			UserLocalLogic:incrCMGameOfflinePayCount()
		end
	end
	StageInfoLocalLogic:addPaymentOrderId( UserManager:getInstance().uid, result.orderId)

	EndGamePropABCTest.getInstance():setBecomePayUser(true)
	UserManager:getInstance():getUserExtendRef().payUser = true
	UserService:getInstance():getUserExtendRef().payUser = true
	UserManager:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())
	UserService:getInstance():getUserExtendRef():setLastPayTime(Localhost:time())

	local payUtils = require 'zoo.payment.repay.Common'
	if payUtils:isThirdParty(self.paymentType) then
		UserManager:getInstance():getUserExtendRef():setLastThirdPayTime(Localhost:time())
		UserService:getInstance():getUserExtendRef():setLastThirdPayTime(Localhost:time())
	end

	self:deliverItems(goodsId, goodsType)
	if NetworkConfig.writeLocalDataStorage then 
		Localhost:getInstance():flushCurrentUserData()
	else 
		printx( 1 , " Did not write user data to the device.") 
	end
	SyncManager:getInstance():sync(nil, nil, false)

	if self.paymentType == Payments.ALIPAY or result.subPayType == Payments.ALI_QUICK_PAY or result.subPayType == Payments.ALI_SIGN_PAY then
		AliQuickPayPromoLogic:removeHomeSceneButton()
	end

	local iconPos = self:getPanelIconPos()
	if self.paymentType ~= Payments.QQ then
		local finalPrice = PaymentManager:getPriceByPaymentType(goodsId, goodsType, self.paymentType)
		local goodsName = Localization:getInstance():getText("goods.name.text"..tostring(self.goodsIdInfo:getGoodsNameId()))
		GlobalEventDispatcher:getInstance():dispatchEvent(
			Event.new(kGlobalEvents.kConsumeComplete, { 
				price = finalPrice, 
				props = goodsName,
				goodsId = goodsId,
				goodsType = goodsType
			}))
	end
	if self.successCallback then self.successCallback(self.amount, iconPos) end
	
	self:closeBuyConfirmPanel()				--关掉可能出现的购买确认面板
	self:closeRepayPanel()					--关掉可能出现的重新购买面板

	if not self.notChangeDefaultPaymentType then
		PaymentManager.getInstance():tryChangeDefaultPaymentType(self.paymentType)
	end

	if __ANDROID then
        local platformName = StartupConfig:getInstance():getPlatformName()
        if platformName == "he_ad_tt" then
            pcall(function ( ... )
                local disp = luajava.bindClass("com.happyelements.hellolua.MainActivity_he_ad_tt")
                m = disp:post2tt_pay(result.goodsInfo.totalFee)
            end)
        end
	end
end

function IngamePaymentLogic:onPayFailed(result)
	local errCode = result.code
	local errMsg = result.msg
	local tradeId = result.tradeId

	if result.noRePay then
		self.noRePay = result.noRePay
	end

	local function _dc(resultType, errorCode)
		self.dcAndroidInfo:setResult(resultType, errorCode or errCode, errMsg)
		PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
	end

	if result.stage == PayStage.kSdkNotRegister then
		_dc(AndroidRmbPayResult.kSdkInitFail)
		self:rmbBuyFailed(errCode, errMsg)
	elseif result.stage == PayStage.kPreOrder then
		if errCode == -6 then 
			_dc(AndroidRmbPayResult.kNoNet)
			if self.repayPanel and not self.repayPanel.isDisposed and self.repayPanel.setBuyBtnEnabled then 
				CommonTip:showTip(Localization:getInstance():getText("ali.quick.pay.error"))
				self.repayPanel:setBuyBtnEnabled(true)
			else
				self:rmbBuyFailed(errCode, errMsg)
			end
		else
			_dc(AndroidRmbPayResult.kDoOrderFail)
			self:rmbBuyFailed(errCode, errMsg)
		end
	elseif result.stage == PayStage.kSdkPay or result.stage == PayStage.kOutServerCheck then
		_dc(AndroidRmbPayResult.kSdkFail, errCode)
		if result.reTryPay == true then
			self:buyWithPaymentType(result.payType)
		else
			self:rmbBuyFailed(errCode, errMsg)
		end
	elseif result.stage == PayStage.kServerCheck then
		_dc(AndroidRmbPayResult.kSdkFail, errCode)
		self:rmbBuyFailed(errCode, errMsg)
	elseif result.stage == PayStage.kRealNameCheck then
		_dc(AndroidRmbPayResult.kNoRealNameAuthed, errCode)
		self:rmbBuyFailed(errCode, errMsg)
	end
end

function IngamePaymentLogic:onPayCancel(result)
	if result.stage == PayStage.kConfirm then
		self.dcAndroidInfo:setResult(AndroidRmbPayResult.kAndroidPayConfirmCancel)
	elseif result.stage == PayStage.kSdkPay then
		self.dcAndroidInfo:setResult(AndroidRmbPayResult.kSdkCancel)
	end

	PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)

	self:rmbBuyCancel()
end

function IngamePaymentLogic:checkNeedSecondConfirm(paymentType)
	if self.goodsIdInfo then
		local goodsId = self.goodsIdInfo:getOriginalGoodsId()
		if StarBank:hasGoodsId( goodsId ) or goodsId == 496 then
			return false
		end

		if PaymentManager:needSpecialNoHappyCoinBuyPanel(goodsId) then
			return true
		end
	end
	if not self._ignoreSecondConfirm and
		(paymentType == Payments.CHINA_MOBILE or paymentType == Payments.DUOKU and not MaintenanceManager:getInstance():isEnabled("SecPayPanel")) or 	
		(paymentType == Payments.CHINA_UNICOM  or paymentType == Payments.WO3PAY and not MaintenanceManager:getInstance():isEnabled("SecPayPanel_Uni")) or 
		(paymentType == Payments.CHINA_TELECOM or paymentType == Payments.TELECOM3PAY and not MaintenanceManager:getInstance():isEnabled("SecPayPanel_189")) or 
		(paymentType == Payments.CHINA_MOBILE_GAME and not MaintenanceManager:getInstance():isEnabled("SecPayPanel_Cmgame")) then 
		return true
	end
	return false
end

function IngamePaymentLogic:handlePaymentDecision(decision, paymentType, otherPaymentTable)
	if _G.isLocalDevelopMode then printx(0, "wenkan pay_process handlePaymentDecision: "..tostring(decision)) end
	--RemoteDebug:uploadLog("IngamePaymentLogic:handlePaymentDecision " , decision , "_" , paymentType)
	-- printx(11, "+ + + + + + IngamePaymentLogic:handlePaymentDecision + + + + decision:", decision)

	local useDarkSkin = false
	if self.sourceFlag == "buyPrePropsByInfoPanel" then
		useDarkSkin = true
	end

	if decision == IngamePaymentDecisionType.kPayFailed then 				    --支付失败
		self:handlePayFailed(paymentType)
	elseif decision == IngamePaymentDecisionType.kPayWithType then 				--正常选定支付(购买风车币)
		self:handlePayWithType(paymentType)
	elseif decision == IngamePaymentDecisionType.kSmsPayOnly then               --仅短代支付 
		self:handleSmsPayOnly(paymentType, useDarkSkin)
	elseif decision == IngamePaymentDecisionType.kThirdPayOnly then             --仅三方支付
		self:handleThirdPayOnly(paymentType, otherPaymentTable, useDarkSkin)
	elseif decision == IngamePaymentDecisionType.kSmsWithOneYuanPay then        --短代带三方一元特价
		self:pocessOneYuanCommon()
		if self.useNewOptimizationLogic then
			self:handleThirdOneYuanPay(paymentType, otherPaymentTable, useDarkSkin)             --屏蔽短代强推三方
		else
			self:handleSmsWithOneYuanPay(paymentType, otherPaymentTable)
		end
	elseif decision == IngamePaymentDecisionType.kThirdOneYuanPay then 	        --仅三方一元特价
		self:pocessOneYuanCommon()
		self:handleThirdOneYuanPay(paymentType, otherPaymentTable, useDarkSkin)
	elseif decision == IngamePaymentDecisionType.kGoldOneYuanPay then 			--一元购买风车币活动
		self:handleGoldOneYuanPay()
	elseif decision == IngamePaymentDecisionType.kPayWithWindMill then		    --风车币支付
		local buyLimitPerOnce = 0
		if self.sourceFlag == "buyPrePropsByInfoPanel" then
			buyLimitPerOnce = 1	-- 前置道具，一次只许买一个
		end
		self:handlePayWithWindMill(useDarkSkin, buyLimitPerOnce)
	else
		assert("Unexcepted payment decision " .. decision .. ", " .. paymentType)
	end 
end

--触发一元特价时 所有统一的处理
function IngamePaymentLogic:pocessOneYuanCommon()
	self:pocessOneYuanEnergyBottle()
	PaymentManager.getInstance():refreshOneYuanShowTime()
	self:setOriGoodsIdType(GoodsIdChangeType.kOneYuanChange)
	self.goodsIdInfo:setGoodsIdChange(GoodsIdChangeType.kOneYuanChange)
end

--高级精力瓶要有特殊处理 同一个精力面板下 只要没买 可以一直触发一元特价
function IngamePaymentLogic:pocessOneYuanEnergyBottle()
	local goodsId = self.goodsIdInfo:getOriginalGoodsId()
	if goodsId == 18 then 
		local curEnergyPanel = PaymentManager.getInstance():getCurrentEnergyPanel()
		PaymentManager.getInstance():setOneYuanEnergyPanel(curEnergyPanel)
	end
end

function IngamePaymentLogic:handlePayFailed(resultCode)
	if not resultCode then resultCode = AndroidRmbPayResult.kNoPaymentAvailable end
	if resultCode == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
		local defaultThirdPartPayment = PaymentManager.getInstance():getDefaultThirdPartPayment()
		self.dcAndroidInfo:setInitialTypeList(defaultThirdPartPayment)
		self.dcAndroidInfo:setTypeChoose(defaultThirdPartPayment)
		if RePayABTestMgr:isNewB() then			
			self.dcAndroidInfo:setResult(resultCode)
			PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
			self:rmbBuyFailed(resultCode, nil)
			return
		else
			CommonTip:showTip(Localization:getInstance():getText("payment_repay_txt4"), "negative")
		end
	elseif RePayABTestMgr:isNew() then
		--细化 无可用支付方式的原因
		local smsEnabled, smsReason = PaymentManager:getInstance():checkSmsPayEnabled()
		local smsLimitType = PaymentManager:getInstance():getSmsPaymentLimitType()

		if not smsEnabled then
			if smsReason == SmsDisableReason.kSmsClose then
				CommonTip:showTip(localize('payment_repay_txt7'))
			elseif smsReason == SmsDisableReason.kSmsLimit then
				if smsLimitType == SmsLimitType.kDailyLimit then
					CommonTip:showTip(localize('payment_repay_txt5'))
				else
					CommonTip:showTip(localize('payment_repay_txt6'))
				end
			else
				CommonTip:showTip(localize('payment_repay_txt8'))
			end
		else
			CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
		end
	else
		CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
	end

	self.dcAndroidInfo:setResult(resultCode)
	PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
	if self.cancelCallback then self.cancelCallback() end
end

function IngamePaymentLogic:handlePayWithType(paymentType)
	printx( 3 , ' handlePayWithType ', paymentType)
    self.dcAndroidInfo:setInitialTypeList(paymentType)
	self:buyWithPaymentType(paymentType)
end

function IngamePaymentLogic:handleSmsPayOnly(paymentType, useDarkSkin)
	self.dcAndroidInfo:setInitialTypeList(paymentType)
	if self:checkNeedSecondConfirm(paymentType) then 
		local peDispatcher = self:getPaymentEventDispatcher()

		if self.useNewOptimizationLogic then
			self.buyConfirmPanel = PayPanelSingleSms_VerB:create(peDispatcher, self.goodsIdInfo, paymentType, nil, useDarkSkin)
		else
			self.buyConfirmPanel = PayPanelSingleSms:create(peDispatcher, self.goodsIdInfo, paymentType)
		end
		self.buyConfirmPanel:popout()
	else
		self:buyWithPaymentType(paymentType)
	end
end

function IngamePaymentLogic:handleThirdPayOnly(paymentType, otherPaymentTable, useDarkSkin)
	self.dcAndroidInfo:setInitialTypeList(otherPaymentTable, paymentType)
	local peDispatcher = self:getPaymentEventDispatcher()

	--RemoteDebug:uploadLog("IngamePaymentLogic:handleThirdPayOnly  useNewOptimizationLogic = " ,self.useNewOptimizationLogic , paymentType)
	local function paySingleThird(paymentType, useDarkSkin)
		local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
		local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"

		if paymentType == Payments.ALIPAY 
			and ( UserManager:getInstance():getAliKfDailyLimit() > 0 
					and UserManager:getInstance():getAliKfMonthlyLimit() > 0
				) 
			and ( UserManager.getInstance():isAliSigned() 
					or (UserManager.getInstance():isAliNeverSigned() 
						and AliQuickPayGuide.isGuideTime() 
						and PaymentManager.getInstance():shouldShowAliQuickPay() 
						and not self.noSign
						)
				) then
				--RemoteDebug:uploadLog("IngamePaymentLogic:handleThirdPayOnly  1")
		   	
				self.dcAndroidInfo:adjustTypeList(Payments.ALI_QUICK_PAY)
				if not UserManager.getInstance():isAliSigned() then 
					peDispatcher = self:pocessSignPayPeDispathcher(peDispatcher)
				end		

				if self.useNewOptimizationLogic then
					self.buyConfirmPanel = PayPanelSingleThird_VerB:create(peDispatcher, self.goodsIdInfo, paymentType, useDarkSkin)
				else
					self.buyConfirmPanel = PayPanelSingleThird:create(peDispatcher, self.goodsIdInfo, paymentType)
				end
				
				self.buyConfirmPanel:popout()
				AliQuickPayGuide.updateGuideTimeAndPopCount()
		elseif paymentType == Payments.WECHAT 
				and ( UserManager.getInstance():isWechatSigned()
						or UserManager.getInstance():isWechatNeverSigned() 
							and WechatQuickPayGuide.isGuideTime() 
							and not self.noSign
					) 
				and _G.wxmmGlobalEnabled 
				and WechatQuickPayLogic:getInstance():isMaintenanceEnabled()  then
				--RemoteDebug:uploadLog("IngamePaymentLogic:handleThirdPayOnly  2")

				self.dcAndroidInfo:adjustTypeList(Payments.WECHAT_QUICK_PAY)
				if not UserManager.getInstance():isWechatSigned() then 
					peDispatcher = self:pocessSignPayPeDispathcher(peDispatcher)
				end		

				if self.useNewOptimizationLogic then
					self.buyConfirmPanel = PayPanelSingleThird_VerB:create(peDispatcher, self.goodsIdInfo, paymentType, useDarkSkin)
				else
					self.buyConfirmPanel = PayPanelSingleThird:create(peDispatcher, self.goodsIdInfo, paymentType)
				end
				
				self.buyConfirmPanel:popout()
				WechatQuickPayGuide.updateGuideTimeAndPopCount()

		elseif self:checkNeedSecondConfirm(paymentType) then 
			--RemoteDebug:uploadLog("IngamePaymentLogic:handleThirdPayOnly  3")

			if self.useNewOptimizationLogic then
				self.buyConfirmPanel = PayPanelSingleThird_VerB:create(peDispatcher, self.goodsIdInfo, paymentType, useDarkSkin)
			else
				self.buyConfirmPanel = PayPanelSingleThird:create(peDispatcher, self.goodsIdInfo, paymentType)
			end
			
			self.buyConfirmPanel:popout()
		else
			--RemoteDebug:uploadLog("IngamePaymentLogic:handleThirdPayOnly  4")
			self:buyWithPaymentType(paymentType)
		end
	end

	if otherPaymentTable and #otherPaymentTable>0 then 
		--创建两个按钮的三方支付面板
		if self.useNewOptimizationLogic then
			local paymentTypes = {} 
			table.insert( paymentTypes , paymentType )
			table.insert( paymentTypes , otherPaymentTable[1] )
			local uid = UserManager:getInstance().uid
			--优先微信分组
			local checkReslut , selectedPaymentType = PaymentManager:checkHasWechatLikeInTable(paymentTypes)
			if not checkReslut then
				checkReslut , selectedPaymentType = PaymentManager:checkHasAlipayLikeInTable(paymentTypes)
			end
			if selectedPaymentType then
				paySingleThird( selectedPaymentType, useDarkSkin)
			end
		-- else
		-- 	self.buyConfirmPanel = PayPanelMultiThird:create(peDispatcher, self.goodsIdInfo, paymentType, otherPaymentTable)
		-- 	self.buyConfirmPanel:popout()
		end
	else
		paySingleThird(paymentType, useDarkSkin)
	end
end

--微信支付宝免密签约 打点参数构建
function IngamePaymentLogic:pocessSignPayPeDispathcher(peDispatcher)
	peDispatcher:addEventListener(PaymentEvents.kBeforePanelPay, function (evt)
		local signChoose = evt.data.signChoose
		if signChoose then 
			self.dcAndroidInfo:setSignChooseType(SignPayChooseType.kNikeBuy)
		else
			self.dcAndroidInfo:setSignChooseType(SignPayChooseType.kNoNikeBuy)
		end
	end)
	peDispatcher:addEventListener(PaymentEvents.kBeforePanelClose, function (evt)
		local signChoose = evt.data.signChoose
		local defaultPaytype = evt.data.defaultPaymentType
		if signChoose then 
			self.dcAndroidInfo:setSignChooseType(SignPayChooseType.kNikeClose)
		else
			self.dcAndroidInfo:adjustTypeList(defaultPaytype)
			self.dcAndroidInfo:setSignChooseType(SignPayChooseType.kNoNikeClose)
		end
	end)

	return peDispatcher
end

function IngamePaymentLogic:handleSmsWithOneYuanPay(paymentType, otherPaymentTable)
	self.dcAndroidInfo:setInitialTypeList(otherPaymentTable, paymentType)
	local peDispatcher = self:getPaymentEventDispatcher()
	self.buyConfirmPanel = PayPanelSingleSms:create(peDispatcher, self.goodsIdInfo, paymentType, otherPaymentTable)
	self.buyConfirmPanel:popout()
end

function IngamePaymentLogic:handleThirdOneYuanPay(paymentType, otherPaymentTable, useDarkSkin)
	self.dcAndroidInfo:setInitialTypeList(otherPaymentTable, paymentType)
	local peDispatcher = self:getPaymentEventDispatcher()

	--RemoteDebug:uploadLog( "handleThirdOneYuanPay  1" )
	if otherPaymentTable and #otherPaymentTable>0 then 
		
		--RemoteDebug:uploadLog( "handleThirdOneYuanPay  2 " , paymentType .. "_" ..  tostring(otherPaymentTable[1]) .. tostring(otherPaymentTable[2]) )
		if self.useNewOptimizationLogic then
			--创建一个按钮的三方一元支付面板(自动选择)
			--RemoteDebug:uploadLog( "handleThirdOneYuanPay  3" )
			local uid = UserManager:getInstance().uid

			local patmentTypes = {}
			table.insert( patmentTypes , paymentType )
			if otherPaymentTable[1] then table.insert( patmentTypes , otherPaymentTable[1] ) end
			if otherPaymentTable[2] then table.insert( patmentTypes , otherPaymentTable[2] ) end
			--优先微信分组
			local checkReslut , selectedPaymentType = PaymentManager:checkHasWechatLikeInTable(patmentTypes)
			--RemoteDebug:uploadLog( "handleThirdOneYuanPay  5" )
			if not checkReslut then
				checkReslut , selectedPaymentType = PaymentManager:checkHasAlipayLikeInTable(patmentTypes)
				--RemoteDebug:uploadLog( "handleThirdOneYuanPay  6" )
			end
			if selectedPaymentType then
				--RemoteDebug:uploadLog( "handleThirdOneYuanPay  7" )
				self.buyConfirmPanel = PayPanelSingleThirdOff_VerB:create(peDispatcher, self.goodsIdInfo, selectedPaymentType, useDarkSkin)
			end
		else
			--RemoteDebug:uploadLog( "handleThirdOneYuanPay  13" )
			--创建两个按钮的三方一元支付面板
			self.buyConfirmPanel = PayPanelMultiThirdOff:create(peDispatcher, self.goodsIdInfo, paymentType, otherPaymentTable)
		end
		--RemoteDebug:uploadLog( "handleThirdOneYuanPay  14" )
		self.buyConfirmPanel:popout()
	else
		--RemoteDebug:uploadLog( "handleThirdOneYuanPay  15" )
		--创建一个按钮的三方一元支付面板
		self.buyConfirmPanel = PayPanelSingleThirdOff:create(peDispatcher, self.goodsIdInfo, paymentType)
		self.buyConfirmPanel:popout()
	end
end

function IngamePaymentLogic:handleGoldOneYuanPay()
	local thirdPaymentConfig = AndroidPayment.getInstance().thirdPartyPayment
	local thirdPartyPaymentNum = #thirdPaymentConfig
	local cancelCallback = function ()
		self:rmbBuyCancel()
	end 
	local withConfirmPanel = true
	if thirdPartyPaymentNum > 0 then 
		self.dcAndroidInfo:setInitialTypeList(thirdPaymentConfig)
		if thirdPartyPaymentNum == 1 then 
            if thirdPaymentConfig[1] == Payments.WECHAT then setTimeOut(cancelCallback, 3) end -- 3秒调取消，解决微信未登录就没有回调的问题
			self:buyWithPaymentType(thirdPaymentConfig[1])
		else
			--50%的用户引导开通支付宝快捷支付
			local uid = tonumber(UserManager.getInstance().uid) or 0
			if uid%2 == 0 or not table.includes(thirdPaymentConfig, Payments.ALIPAY) or MaintenanceManager:getInstance():isEnabled("AliSignInGame2") then
				local supportedPayments = {}
				for i,v in ipairs(thirdPaymentConfig) do supportedPayments[v] = true end
				local panel = ChoosePaymentPanel:create(supportedPayments,"选择您希望的支付方式:", true)
				local function onChoosen(choosenType)
					if choosenType then            
	                    if choosenType == Payments.WECHAT then setTimeOut(cancelCallback, 3) end -- 3秒调取消，解决微信未登录就没有回调的问题
						self:buyWithPaymentType(choosenType)
					else
						cancelCallback() 
					end
				end
				if panel then panel:popout(onChoosen) end
			else
				local function onChoosen(choosenType)
					if choosenType then
						if choosenType == Payments.ALI_QUICK_PAY then
							local function onSignSuccess()
								self:buyWithPaymentType(Payments.ALIPAY)
							end

							-- local AliPaymentSignAccountPanel = require "zoo.panel.alipay.AliPaymentSignAccountPanel"
							-- local panel = AliPaymentSignAccountPanel:create(AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL)
							-- if AliQuickPayPromoLogic:isEntryEnabled() then
				   --              panel:setReduceShowOption(AliPaymentSignAccountPanel.showNormalReduce)
				   --          end
							-- panel:popout(onSignSuccess) --!!!错的吧，第一个callback是cancel
				            local function onSignCallback(ret, data)
				                if ret == AlipaySignRet.Success then
				                    onSignSuccess()
				                elseif ret == AlipaySignRet.Cancel then
				                elseif ret == AlipaySignRet.Fail then
				                end
				            end
				            AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL, onSignCallback)
						else
							-- 3秒调取消，解决微信未登录就没有回调的问题
		                    if choosenType == Payments.WECHAT then setTimeOut(cancelCallback, 3) end
							self:buyWithPaymentType(choosenType)
						end
					else
						cancelCallback()
					end
				end

				local NewChoosePaymentPanel = require "zoo.panel.alipay.NewChoosePaymentPanel"
				local panel = NewChoosePaymentPanel:create()
				panel:popout(onChoosen)
			end
		end
	else
		assert(false, "IngamePaymentLogic:handleGoldOneYuanPay---impossible")
	end
end

function IngamePaymentLogic:handlePayWithWindMill(useDarkSkin, buyLimitPerOnce)
	local buyConfirmPanel = nil
	if self.useNewOptimizationLogic then
		buyConfirmPanel = PayPanelWindMill_VerB:create(self.goodsIdInfo:getGoodsId(), self.successCallback, 
			self.cancelCallback, nil, useDarkSkin, buyLimitPerOnce,self.isFreeVideo)
	else
		buyConfirmPanel = PayPanelWindMill:create(self.goodsIdInfo:getGoodsId(), self.successCallback, self.cancelCallback)
	end
	buyConfirmPanel:setFeatureAndSource(self.feature, self.source)
	buyConfirmPanel:popout()
end

function IngamePaymentLogic:getLevelId()
	local user = UserManager:getInstance().user
	local stageInfo = StageInfoLocalLogic:getStageInfo(user.uid)
	if stageInfo then 
		return stageInfo.levelId 
	else
		return -1
	end
end

function IngamePaymentLogic:deliverItems(goodsId, goodsType)
	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	local price = PaymentManager:getPriceByPaymentType(goodsId, goodsType, self.paymentType)
	local levelId = self:getLevelId()
	if goodsType == GoodsType.kItem then 
		self:updatePropCount(goodsInfoMeta, levelId, price)
		GainAndConsumeMgr.getInstance():consumeCurrency(self.feature, DcDataCurrencyType.kRmb, price * 100, 
											goodsId, 1, levelId, self.activityId, self.source)
	elseif goodsType == GoodsType.kCurrency then
		GainAndConsumeMgr.getInstance():consumeCurrency(self.feature, DcDataCurrencyType.kRmb, price * 100, 
											goodsId + 10000, 1, levelId, self.activityId, self.source)
	end
	-- 更新本日购买列表
	if _G.isLocalDevelopMode then printx(0, "Update buyed list") end
	if goodsInfoMeta and goodsInfoMeta.limit > 0 then
		UserManager:getInstance():addBuyedGoods(goodsId, 1)
		UserService.getInstance():addBuyedGoods(goodsId, 1)
	end
end

function IngamePaymentLogic:updatePropCount(goodsInfoMeta, levelId, price)
	local manager = UserManager:getInstance()
	local items = {}
	for __, v in ipairs(goodsInfoMeta.items) do 
		table.insert(items, {itemId = v.itemId, num = v.num}) 
	end

	local valueCalculator = GainAndConsumeMgr.getInstance():getPayValueCalculator(items, price * 100, DcPayType.kRmb)
	-- 加东西
	for __, v in ipairs(items) do
		UserManager:getInstance():addReward(v)
		local value = valueCalculator:getItemSellPrice(v.itemId)
		GainAndConsumeMgr.getInstance():gainItem(self.feature, v.itemId, v.num, self.source, levelId, self.activityId, DcPayType.kRmb, value, goodsInfoMeta.id)
	end
end

function IngamePaymentLogic:ignoreSecondConfirm(value)
	self._ignoreSecondConfirm = value
end

function IngamePaymentLogic:setRepayChooseTable( repayChooseTable, onlyThirdparty)
	self.repayChooseTable = RePayABTestMgr:getRepayChooseTable(repayChooseTable, onlyThirdparty)
end