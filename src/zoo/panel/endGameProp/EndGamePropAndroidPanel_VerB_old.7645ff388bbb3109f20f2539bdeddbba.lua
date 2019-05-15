require "zoo.panel.endGameProp.EndGamePropBasePanel_VerB"
require "zoo.panel.endGameProp.EndGamePropABCTest"

EndGamePropAndroidPanel_VerB_old = class(EndGamePropBasePanel_VerB)


function EndGamePropAndroidPanel_VerB_old:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward)
	local pGoodsId = nil
	local pShowType = nil 
	local animalCreator = nil


	pGoodsId, pShowType = EndGamePropManager.getInstance():getAndroidBuyGoodsId(propId, levelId)

	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		if levelType == GameLevelType.kSpring2017 or levelType == GameLevelType.kMidAutumn2018 then
			decision = IngamePaymentDecisionType.kPayWithWindMill
		end
		
		local panel = EndGamePropAndroidPanel_VerB_old.new()

		--用于重新创建一个加五步面板
		panel.ctor_params = {
			levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward
		}
		panel.pGoodsId = pGoodsId
		panel.pShowType = pShowType


		panel.levelId = levelId
		panel.propId = propId
		panel.levelType = levelType
		panel.onUseTappedCallback = onUseCallback
		panel.onCancelTappedCallback = onCancelCallback
		panel.onPanelWillPopout = onPanelWillPopout

		panel.hasPreBuff = GameInitBuffLogic:hasInitBuffFromPreBuffAct()
		
		panel:loadRequiredResource(PanelConfigFiles.panel_add_step)

		panel.adDecision = decision
		panel.adPaymentType = paymentType
		panel.dcAndroidStatus = dcAndroidStatus
		panel.adRepayChooseTable = repayChooseTable

		panel.goodsId = pGoodsId
		panel.showType = pShowType

		local isFUUU , fuuuId , fuuuData = FUUUManager:lastGameIsFUUU(true)
		if levelType == GameLevelType.kFourYears or levelType == GameLevelType.kSummerFish then
			isFUUU = false
		end
		panel.lastGameIsFUUU = isFUUU
		panel.fuuuLogID = fuuuId
		panel.fuuuData = fuuuData

		panel.animalAnimetionCreator = animalCreator

		panel.onGetLotteryReward = onGetLotteryReward

		panel:init() 
		if type(useTipText) == "string" then
			panel:setUseTipText(useTipText)
			panel:setUseTipVisible(true)
		end

		panel:dcPanelShow()

		self.isFUUU = isFUUU
		self.levelId = levelId

		panel:popout() 
	end
 

	PaymentManager.getInstance():getBuyItemDecision(popoutPanel, pGoodsId)

end

function EndGamePropAndroidPanel_VerB_old:init()
	AddFiveStepABCTestLogic:setNeedShowCountdownByPrice(false)
	
	if not EndGamePropBasePanel_VerB.init(self) then 
		self.actSource = EndGameButtonTypeAndroid.kPropEnough
		return 
	end 
	
	self.payStart = true

	--test need remove late
	if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
		self:initForWindMillPay()
	else
		self:initForRmbPay()	
	end

	--特殊文案显示
	--self:updateLabelShow()

	self:updateCountdownShow()
end

function EndGamePropAndroidPanel_VerB_old:initForWindMillPay()
	self.buyExtraParam = nil
	--右下角提示信息显示
	local uid = UserManager:getInstance().uid
	self.moneyBar:setVisible(true)
	local goldText = self.moneyBar:getChildByName("goldText")
	goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))
	self.goldNum = self.moneyBar:getChildByName("gold")
	
	self:updateGoldNum()

	self.buyButton:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")

	--printx( 1 , "   EndGamePropAndroidPanel_VerB_old:initForWindMillPay   self.goodsId = " , self.goodsId)
	local goodsMeta = MetaManager:getInstance():getGoodMeta(self.goodsId)
	local normalPrice = goodsMeta.qCash
	local discountPrice = goodsMeta.discountQCash

	if self.showType == EndGamePropShowType.kDiscount then 
		self.actSource = EndGameButtonTypeAndroid.kDiscountWindMill
		self:updateButtonShowForWM(discountPrice, math.ceil(discountPrice / normalPrice * 10))
	elseif self.showType == EndGamePropShowType.kDiscountNoLimit then
		self.buyExtraParam = self.levelId
		self.actSource = EndGameButtonTypeAndroid.kDiscountNoLimit
		self:updateButtonShowForWM(discountPrice, math.ceil(discountPrice / normalPrice * 10))
	else
		self.actSource = EndGameButtonTypeAndroid.kNormalWindMill
		self:updateButtonShowForWM(normalPrice, 10)
	end
end

function EndGamePropAndroidPanel_VerB_old:updateButtonShowForWM(goodsPrice, discountNum)
	if discountNum <= 0 or discountNum == 10 then
		self.buyButton:setDiscount(discountNum)
	else
		self.buyButton:setDiscount(discountNum, Localization:getInstance():getText("buy.gold.panel.discount"))
	end
	self.buyButton:setNumber(goodsPrice) 

	--支付打点
	self.dcAndroidInfo = DCWindmillObject:create()
	self.dcAndroidInfo:setGoodsId(self.goodsId)
	self.dcAndroidInfo:setWindMillPrice(goodsPrice)
	self.dcAndroidInfo:setGoodsNum(1)
end

local function famatPriceShow(price)
	price = tonumber( price )
	return string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
end

function EndGamePropAndroidPanel_VerB_old:initForRmbPay()
	--右下角提示信息显示
	if self.adPaymentType == Payments.ALIPAY and UserManager.getInstance():isAliSigned() and (UserManager:getInstance():getAliKfDailyLimit() > 0 and UserManager:getInstance():getAliKfMonthlyLimit() > 0) then
		self.ui:getChildByName("labelAliQuickPay"):setString(localize("alipay.pay.kf.confirm"))
	elseif self.adPaymentType == Payments.WECHAT and UserManager.getInstance():isWechatSigned() and _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
		self.ui:getChildByName("labelAliQuickPay"):setString(localize("wechat.kf.enter2"))
	end

	local goodsMeta = MetaManager:getInstance():getGoodMeta(self.goodsId)
	local normalPrice = goodsMeta.rmb / 100
	local discountPrice = goodsMeta.discountRmb / 100
	local finalPrice = 0

	if self.showType == EndGamePropShowType.kDiscount then 
		self.actSource = EndGameButtonTypeAndroid.kDiscountRmb
		self:updateButtonShowForRmb(famatPriceShow(discountPrice), math.ceil(discountPrice / normalPrice * 10), famatPriceShow(normalPrice))
		finalPrice = discountPrice
	elseif self.showType == EndGamePropShowType.kDiscountNoLimit then
		self.actSource = EndGameButtonTypeAndroid.kDiscountRmb
		self:updateButtonShowForRmb(famatPriceShow(discountPrice), math.ceil(discountPrice / normalPrice * 10), famatPriceShow(normalPrice))
		finalPrice = discountPrice
	else
		self.actSource = EndGameButtonTypeAndroid.kNormalRmb
		self:updateButtonShowForRmb(famatPriceShow(normalPrice), 10, famatPriceShow(normalPrice))
		finalPrice = normalPrice
	end

	if finalPrice == 6 then
		AddFiveStepABCTestLogic:setNeedShowCountdownByPrice(true)
	end

	--支付打点
	self.goodsIdInfo = GoodsIdInfoObject:create(self.goodsId)
	if self:isOneYuanDecision() then
		self.actSource = EndGameButtonTypeAndroid.kOneYuan
		self.goodsIdInfo:setGoodsIdChange(GoodsIdChangeType.kOneYuanChange)
	end
	self.dcAndroidInfo = DCAndroidRmbObject:create()
	self.dcAndroidInfo:setGoodsId(self.goodsIdInfo:getGoodsId())
	self.dcAndroidInfo:setGoodsType(self.goodsIdInfo:getGoodsType())
	self.dcAndroidInfo:setGoodsNum(1)
	self.dcAndroidInfo:setTypeStatus(self.dcAndroidStatus)
	if self.adDecision == IngamePaymentDecisionType.kPayFailed then 	
		--加五步面板断网导致支付失败要特殊处理 因为此时面板已经弹出
		if self.adPaymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
			self.dcAndroidInfo:setInitialTypeList(PaymentManager.getInstance():getDefaultThirdPartPayment())
		end
	else
		self.dcAndroidInfo:setInitialTypeList(self.adPaymentType)
	end
end

function EndGamePropAndroidPanel_VerB_old:updateButtonShowForRmb(goodsPrice, discountNum, oriGoodsPrice)
	local needRefreshPos = false 
	if self:isOneYuanDecision() then 
		needRefreshPos = true
		--现价
		local goodsInfo = GoodsIdInfoObject:create(self.goodsId)
		local oneYuanGoodsId = goodsInfo:getOneYuanGoodsId()
		local oneYuanGoodsMeta = MetaManager:getInstance():getGoodMeta(oneYuanGoodsId)
		self.buyButton:setNumber(famatPriceShow(oneYuanGoodsMeta.thirdRmb / 100)) 
		--打折
		goodsInfo:setGoodsIdChange(GoodsIdChangeType.kOneYuanChange)
		self.buyButton:setDiscount(goodsInfo:getDiscountNum(), Localization:getInstance():getText("buy.gold.panel.discount"))
	else
		if discountNum <= 0 or discountNum == 10 then
			self.buyButton:setDiscount(discountNum)
		else
			needRefreshPos = true
			self.buyButton:setDiscount(discountNum, Localization:getInstance():getText("buy.gold.panel.discount"))
		end
		self.buyButton:setNumber(goodsPrice) 
	end
	--调整按钮显示
	-- self.buyButton.label:setPositionX(65)
	-- self.buyButton.numberLabel:setPositionX(-158)
	if needRefreshPos then
		self.buyButton:setOriNumber(oriGoodsPrice) 
		-- if self.buyButton.oriNumber then 
		-- 	self.buyButton.numberLabel:setPositionY(11)
		-- 	self.buyButton.oriNumber:setPosition(ccp(-115, 56))
		-- end
		-- if self.buyButton.redLine then 
		-- 	self.buyButton.redLine:setPosition(ccp(-110, 50))
		-- end
	end
	local groupBoundsSize = self.buyButton.groupNode:getGroupBounds().size
	local propIcon = self.buyButton.groupNode:getChildByPath('propIcon')
	if propIcon then
		propIcon:setPositionX( -groupBoundsSize.width/2 -100)
	end
end

function EndGamePropAndroidPanel_VerB_old:updateLabelShow()
	if EndGamePropManager.getInstance():isAddMoveProp(self.propId) then 
		if EndGamePropABCTest.getInstance():getFuuuShow(self.lastGameIsFUUU) and
			-- MaintenanceManager:getInstance():isEnabled("IosFuuuAdd5Step") and 
		    self.lastGameIsFUUU then 
			self.msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.txt.fuuu'))
		end
	end
end

function EndGamePropAndroidPanel_VerB_old:updateGoldNum()
	if self.goldNum then 
		local money = UserManager:getInstance().user:getCash()
		self.goldNum:setString(money)
	end
end

function EndGamePropAndroidPanel_VerB_old:isOneYuanDecision()
	if self.adDecision and self.adDecision == IngamePaymentDecisionType.kSmsWithOneYuanPay or 
		self.adDecision == IngamePaymentDecisionType.kThirdOneYuanPay then
		return true
	end
	return false
end

local EndGameExtraInfoHttp = class(HttpBase)
function EndGameExtraInfoHttp:load(pLevelId, pGoodsId, pCartNum)
	local context = self
	local loadCallback = function(endpoint, data, err)
		if err then
			he_log_info("EndGameExtraInfoHttp error: " .. err)
			context:onLoadingError(err)
		else
			he_log_info("EndGameExtraInfoHttp success !")
			context:onLoadingComplete(data)
		end
	end

	if NetworkConfig.useLocalServer then 
		UserService.getInstance():cacheHttp("recordLimitGoodsBuyLog", {levelId = pLevelId, goodsId = pGoodsId, cartNum = pCartNum})
		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.2") end 
		end
		context:onLoadingComplete()
	else
		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
		self.transponder:call("recordLimitGoodsBuyLog", {levelId = pLevelId, goodsId = pGoodsId, cartNum = pCartNum}, loadCallback, rpc.SendingPriority.kHigh, false)
	end
end

function EndGamePropAndroidPanel_VerB_old:sendServerInfo()
	local function onSuccess(evt)
		if endCallback then endCallback() end
	end
	local function onFail(evt)
		if endCallback then endCallback() end
	end
	local function onCancel(evt)
		if endCallback then endCallback() end
	end
	local http = EndGameExtraInfoHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(self.levelId, self.goodsId, 1)
end

function EndGamePropAndroidPanel_VerB_old:onBuyBtnTapped()
	EndGamePropBasePanel_VerB.onBuyBtnTapped(self)

	if self.actPanel and not self.actPanel.isDisposed then 
		self.actPanel:onCloseBtnTap()
	end

	local function onBuySuccess()
		self:dcBuySuccess()

		self:onBuySuccess()

		if self.goodsId == EndGamePropManager.getInstance():getDiscountLimitGoodsId(self.propId) then 
			--不限购的特价道具 这里记录下在该关卡买过了
			UserManager:getInstance():addBuyedGoods(self.goodsId, 1)
			UserManager.getInstance():setDailyBuyedGoodsByLevel(self.levelId, self.goodsId, 1)
			--这里通知下后端 
			self:sendServerInfo()
		end
	end

	local function onBuyFail(errorCode, errorMsg)
		self:onBuyFail(errorCode, errorMsg)
		if errorCode and errorCode == 730330 then 
			--do nothing here
		else
			if errorCode and errorCode == 730241 or errorCode == 730247 or errorCode == SelfDefinePayError.kPaySucCheckFail then
				CommonTip:showTip(errorMsg, "negative")
			else
				CommonTip:showTip(Localization:getInstance():getText("add.step.panel.buy.fail.android"), "negative")
			end
			self:resumeTimer()
		end
	end

	local function onBuyCancel()
		self:onBuyCancel()
	end

	if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
		-- PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcAndroidInfo)
		self:buyWithWindMill(onBuySuccess, onBuyFail, onBuyCancel)
	else
		PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcAndroidInfo)
		local logic = IngamePaymentLogic:createWithGoodsInfo(self.goodsIdInfo, self.dcAndroidInfo, DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuy)
		logic:setBuyConfirmPanel(self)
		logic:endGameBuy(self.adDecision, self.adPaymentType, onBuySuccess, onBuyFail, onBuyCancel, self.onCancelTappedCallback, self.adRepayChooseTable)
		self.buyLogic = logic
		self.onEnterForeGroundCallback = onBuyCancel
	end

	self:dcBuyBtnTap()
end

function EndGamePropAndroidPanel_VerB_old:buyWithWindMill(onBuySuccess, onBuyFail, onBuyCancel)
	local function sucFuncWithDC(data)
		self.dcAndroidInfo:setResult(DCWindmillPayResult.kSuccess)
		PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcAndroidInfo)
		if onBuySuccess then onBuySuccess() end
	end

	local function failFuncWithDC(errorCode)
		if errorCode and errorCode == 730330 then -- not enough gold
			self.dcAndroidInfo:setResult(DCWindmillPayResult.kNoWindmill)
		else
			self.dcAndroidInfo:setResult(DCWindmillPayResult.kFail, errorCode)
		end
		PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcAndroidInfo)
		if onBuyFail then onBuyFail(errorCode) end
	end

	local logic = BuyLogic:create(self.goodsId, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuy, self.buyExtraParam)
	logic:getPrice()
	logic:setCancelCallback(onBuyCancel)
	logic:start(1, sucFuncWithDC, failFuncWithDC)
end

function EndGamePropAndroidPanel_VerB_old:onCloseBtnTapped()
	--三方查询订单时 不可关闭加五步面板
	if PaymentManager.getInstance():getIsCheckingPayResult() then return end 

	if self.payStart then  
		local payResult = self.dcAndroidInfo:getResult()
		if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
			if payResult and payResult == DCWindmillPayResult.kNoWindmill then 
				self.dcAndroidInfo:setResult(DCWindmillPayResult.kCloseAfterNoWindmill)
			elseif payResult and payResult == DCWindmillPayResult.kFail then 
				self.dcAndroidInfo:setResult(DCWindmillPayResult.kCloseAfterFail)
			elseif payResult and payResult == DCWindmillPayResult.kNoRealNameAuthed then 
				self.dcAndroidInfo:setResult(DCWindmillPayResult.kCloseAfterNoRealNameAuthed)
			else
				self.dcAndroidInfo:setResult(DCWindmillPayResult.kCloseDirectly)
			end
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcAndroidInfo)
		else
			local noDC = false 
			if payResult and payResult == AndroidRmbPayResult.kNoNet then  
				self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
			elseif payResult and payResult == AndroidRmbPayResult.kNoPaymentAvailable then 
				self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoPaymentAvailable)
			elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
        		self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
			else
				local typeChoose = self.dcAndroidInfo.typeChoose
				if typeChoose then 
					if payResult and payResult == AndroidRmbPayResult.kSuccess then 
						he_log_error("zhijiancheck----11")
						noDC = true
					else
						he_log_error("zhijiancheck----22")
					end
				end
				if not noDC then 
					self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseDirectly)
				end
			end
			if not noDC then 
				PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)
			end
		end
	end

	if self.actPanel and not self.actPanel.isDisposed then 
		self.actPanel:onCloseBtnTap()
	end
	
	EndGamePropBasePanel_VerB.onCloseBtnTapped(self)
end

function EndGamePropAndroidPanel_VerB_old:popout()
	if _G.isLocalDevelopMode then printx(0, 'EndGamePropAndroidPanel_VerB_old:popout()') end
	if self:isOneYuanDecision() then 
		PaymentManager.getInstance():refreshOneYuanShowTime()
	end

	EndGamePropBasePanel_VerB.popout(self)
	self:setBgDark(false)

	if not self:handleActivity() then
		-- self:setBgDark(true)
	end
end

function EndGamePropAndroidPanel_VerB_old:setBgDark(isDark)
	self:runAction(CCCallFunc:create(function ()
		local c = self:getParent() 
		if c then 
			local container = c:getParent()
			if container and container.darkLayer then
				if isDark then 
					container.darkLayer:setOpacity(150)
				else
					container.darkLayer:setOpacity(0)
				end
			end
		end
	end))
end

function EndGamePropAndroidPanel_VerB_old:updateToPropEnough(isBuyAddFive)
	print("EndGamePropAndroidPanel_VerB_old:updateToPropEnough()================called")
	self.isBuyAddFive = isBuyAddFive
	local propNum = EndGamePropManager.getInstance():getItemNum(self.propId)
	if propNum > 0 then -- use
		self.payStart = false
		self.useButtonUI:setVisible(true)
		if not self.useButton then 
			self.useButton = EndGameUseButton:create(self.useButtonUI, self.propId)
			self.useButton:setPositionY(self.useButton:getPositionY() + 45)
			self:saveBtnScaleInfo(self.useButton)
			self.useButton:setString(Localization:getInstance():getText("add.step.panel.use.btn.txt"))
			self.useButton:addEventListener(DisplayEvents.kTouchTap, function (evt)
				self:onUseBtnTapped()
			end)
		end
		self.useButton:setNumber(propNum)
		-- self.useButton:setColorMode(kGroupButtonColorMode.blue)
		self.buyButtonUI:setVisible(false)
		if self.buyButton then 
			self.buyButton.groupNode:stopAllActions()
			self.buyButton:setEnabled(false) 
		end
		-- self.countdownLabel:setPositionX(541)
		self.countdownLabel:setVisible(false)

		local label1 = self.ui:getChildByName("labelAliQuickPay")
		if label1 then 
			label1:setVisible(false)
		end

		local moneyBar = self.ui:getChildByName("moneyBar")		
		if moneyBar then 
			moneyBar:setVisible(false)
		end
	end
end

function EndGamePropAndroidPanel_VerB_old:handleActivity()
	local function buyBtnTapCb()
		self.buyButton:setEnabled(false)
		self:stopCountdown()
	end
	local function successCb()
		if self.isDisposed then return end
		if self.actPanel then 
			self.actPanel:removePopout()
		end
		--刷新显示
		self:updateToPropEnough()
	end

	local function failCb(errCode)
		if self.isDisposed then return end
		--刷新按钮状态
		self:resumeTimer()
		if errCode == 731547 then 
			CommonTip:showTip(localize('不能重复购买哦~'))
			if self.actPanel then 
				self.actPanel:removePopout()
			end
		end
	end

	local function cancelCb()
		if self.isDisposed then return end
		--刷新按钮状态
		self:resumeTimer()
	end

	if _G.__Alipay1708_ACT then 
		if self.goodsId == 280 and 
			(self.adDecision == IngamePaymentDecisionType.kSmsPayOnly or self.adDecision == IngamePaymentDecisionType.kThirdPayOnly) and 
			self.actSource ~= EndGameButtonTypeAndroid.kPropEnough then 
			local manager = require("activity/Alipay1708/src/Manager.lua")
			if manager.getInstance():shouldShowPanel() then 
				self:setBgDark(true)
				local Panel = require("activity/Alipay1708/src/Panel.lua")
				local panel = Panel:create(buyBtnTapCb, successCb, failCb, cancelCb)
				if panel then 
					self.actPanel = panel
					panel:popout()
					return true
				end
			end
		end
	end

	return false
end


function EndGamePropAndroidPanel_VerB_old:onCashNumChange( ... )
	
	if self.isDisposed then
		return
	end
	self:updateGoldNum()

	if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
		local money = UserManager:getInstance().user:getCash()
		local bl = BuyLogic:create(self.goodsId, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuy)
		local price = bl:getPrice()

		if money < price then
			-- 把自己的状态切换到风车币支付

			self:updateAddStepMode()

		end
	end
end

function EndGamePropAndroidPanel_VerB_old:updateAddStepMode( ... )
	if self.isDisposed then
		return
	end
	if not self.lotteryBtn then
		return
	end

	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		self.adDecision = decision
		self.adPaymentType = paymentType
		self.dcAndroidStatus = dcAndroidStatus
		self.adRepayChooseTable = repayChooseTable

		self:deInit()
		self:reInit() 

		if type(useTipText) == "string" then
			self:setUseTipText(useTipText)
			self:setUseTipVisible(true)
		end
	end
	PaymentManager.getInstance():getBuyItemDecision(popoutPanel, self.pGoodsId)
end

function EndGamePropAndroidPanel_VerB_old:deInit( ... )
	-- body
	if self.isDisposed then
		return
	end
	-- self.ui:removeFromParentAndCleanup(true)
	self.buyExtraParam = nil
	local uid = UserManager:getInstance().uid
	self.moneyBar:setVisible(false)
	self:updateGoldNum()
	self.buyButton:setIcon(nil)
end

function EndGamePropAndroidPanel_VerB_old:reInit( ... )
	if self.isDisposed then
		return
	end
	AddFiveStepABCTestLogic:setNeedShowCountdownByPrice(false)
	self.payStart = true
	if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
		self:initForWindMillPay()
	else
		self:initForRmbPay()	
	end
end