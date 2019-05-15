require "zoo.panel.endGameProp.EndGamePropBasePanel_VerC"
require "zoo.panel.endGameProp.EndGamePropABCTest"

EndGamePropAndroidPanel_VerB = class(EndGamePropBasePanel_VerC)

function EndGamePropAndroidPanel_VerB:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward, onUpdatePropBarDisplay, isClone)
	local pGoodsId = nil
	local pShowType = nil 
	local animalCreator = nil

	pGoodsId, pShowType = EndGamePropManager.getInstance():getAndroidBuyGoodsId(propId, levelId)

	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		local C1 = GiftPack:isEnabledInGroupMustNewer('C1')
		if levelType == GameLevelType.kSpring2017 or C1 then
			decision = IngamePaymentDecisionType.kPayWithWindMill
		end
		
		local panel = EndGamePropAndroidPanel_VerB.new()

		--用于重新创建一个加五步面板
		panel.ctor_params = {
			levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward, onUpdatePropBarDisplay
		}
		panel.pGoodsId = pGoodsId
		panel.pShowType = pShowType

		panel.isClone = isClone
		panel.levelId = levelId
		panel.propId = propId
		panel.levelType = levelType
		panel.onUseTappedCallback = onUseCallback
		panel.onCancelTappedCallback = onCancelCallback
		panel.onPanelWillPopout = onPanelWillPopout

		panel.hasPreBuff = GameInitBuffLogic:hasInitBuffFromPreBuffAct()
		panel.hasScoreBuff = CollectStarsManager.getInstance():willShowAddStep(levelId  ) and false
		
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
		panel.onUpdatePropBarDisplay = onUpdatePropBarDisplay

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

function EndGamePropAndroidPanel_VerB:clone()
	table.insert(self.ctor_params, true)
	return EndGamePropAndroidPanel_VerB:create(unpack(self.ctor_params))
end

function EndGamePropAndroidPanel_VerB:init()
	AddFiveStepABCTestLogic:setNeedShowCountdownByPrice(false)

	self.inDiscountState = false --礼包显示用
	if self.showType == EndGamePropShowType.kDiscount then 
		self.inDiscountState = true
	end
	
	if not EndGamePropBasePanel_VerC.init(self) then 
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

function EndGamePropAndroidPanel_VerB:initForWindMillPay()
	self.buyExtraParam = nil
	--右下角提示信息显示
	local uid = UserManager:getInstance().uid

	self.moneyBar:setVisible(true)
	local goldText = self.moneyBar:getChildByName("goldText")
	goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))
	self.goldNum = self.moneyBar:getChildByName("gold")

	self:getAliQuickLabel():setVisible(false)

	self:updateGoldNum()

	self.buyButton:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")

	--printx( 1 , "   EndGamePropAndroidPanel_VerB:initForWindMillPay   self.goodsId = " , self.goodsId)
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

function EndGamePropAndroidPanel_VerB:updateButtonShowForWM(goodsPrice, discountNum)
    self.goodsPrice = goodsPrice

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

function EndGamePropAndroidPanel_VerB:initForRmbPay()
	--右下角提示信息显示
	if self.adPaymentType == Payments.ALIPAY and UserManager.getInstance():isAliSigned() and (UserManager:getInstance():getAliKfDailyLimit() > 0 and UserManager:getInstance():getAliKfMonthlyLimit() > 0) then
		-- 支付宝快付
		self:getAliQuickLabel():setString(localize("alipay.pay.kf.confirm"))
	elseif self.adPaymentType == Payments.WECHAT and UserManager.getInstance():isWechatSigned() and _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
		-- 通过微信快付
		self:getAliQuickLabel():setString(localize("wechat.kf.enter2"))
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

function EndGamePropAndroidPanel_VerB:updateButtonShowForRmb(goodsPrice, discountNum, oriGoodsPrice)

	if _G.isLocalDevelopMode then printx(101, "EndGamePropAndroidPanel_VerB updateButtonShowForRmb oriGoodsPrice  ===" , oriGoodsPrice ) end 	

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

	-- local groupBoundsSize = self.buyButton.groupNode:getGroupBounds().size
	-- local propIcon = self.buyButton.groupNode:getChildByPath('propIcon')
	-- if propIcon then
	-- 	propIcon:setPositionX( -groupBoundsSize.width/2 -100)
	-- end

end

-- function EndGamePropAndroidPanel_VerB:updateLabelShow()
	-- if EndGamePropManager.getInstance():isAddMoveProp(self.propId) then 
	-- 	if EndGamePropABCTest.getInstance():getFuuuShow(self.lastGameIsFUUU) and
	-- 		-- MaintenanceManager:getInstance():isEnabled("IosFuuuAdd5Step") and 
	-- 	    self.lastGameIsFUUU then 
	-- 		self.msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.txt.fuuu'))
	-- 	end
	-- end
-- end

function EndGamePropAndroidPanel_VerB:updateGoldNum()
	if self.goldNum then 
		local money = UserManager:getInstance().user:getCash()
		self.goldNum:setString(money)
	end
	self:updateMoneyBarPos()
end

function EndGamePropAndroidPanel_VerB:isOneYuanDecision()
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

function EndGamePropAndroidPanel_VerB:sendServerInfo()
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

function EndGamePropAndroidPanel_VerB:onEnterHandler(event)
	BasePanel.onEnterHandler(self, event)
	self:_onEnterHandler()
end



function EndGamePropAndroidPanel_VerB:_onEnterHandler( event )
	if event == "enter" then
		if self.autoBuy == true then 
			self:onBuyBtnTapped()
		end
	elseif event == "exit" then
	end
	self.autoBuy = false
end

function EndGamePropAndroidPanel_VerB:onBuyBtnTapped()
	EndGamePropBasePanel_VerC.onBuyBtnTapped(self)

	self.allowBackKeyTap = false
	
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
		---- paymentLogic中，设置为buyConfirmPanel的实现中，这里只用到了在支付成功/失败的时候removePopout的特性
		---- 这里的removePopout不是关闭面板，只是隐藏显示，因为如果关闭面板会触发游戏失败，无法兼容需要选择二次支付的情况（详见VerC）
		logic:setBuyConfirmPanel(self)
		logic:endGameBuy(self.adDecision, self.adPaymentType, onBuySuccess, onBuyFail, onBuyCancel, self.onCancelTappedCallback, self.adRepayChooseTable)
		self.buyLogic = logic
		self.onEnterForeGroundCallback = onBuyCancel
	end

	self:dcBuyBtnTap()
end

function EndGamePropAndroidPanel_VerB:onBuyFail(errorCode, errorMsg)
	if self.isDisposed then return end
	self.onEnterForeGroundCallback = nil
	self:stopAllActions()

    local goldMarketPanel = nil
	local function buyGoldSuccess()

		if not goldMarketPanel or self.isDisposed or not self.goodsPrice then return end 
		local userCash = UserManager:getInstance().user:getCash()
		if userCash >= self.goodsPrice then 
			self.autoBuy = true
			goldMarketPanel:onCloseBtnTapped()

			if goldMarketPanel.panelName == 'StorePanel' then
				if self.isDisposed then return end
				self:_onEnterHandler('enter')
			end
		
			goldMarketPanel = nil
		end


	end

	local function resumeTimer()
		if self.isDisposed then return end
		self:resumeTimer()
	end
	local function onCreateGoldPanel()
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			PaymentDCUtil.getInstance():setSrcPayId(self.dcAndroidInfo and self.dcAndroidInfo.payId)

            goldMarketPanel = createMarketPanel(index)

            if self.goodsId == 280 then
            	if goldMarketPanel.addEnterFlag then
            		goldMarketPanel:addEnterFlag(_G.StoreManager.EnterFlag.kEndGamePanelDiscount5Step)
            	end
            end

            goldMarketPanel:setBuyGoldSuccessFunc(buyGoldSuccess)
            goldMarketPanel:popout()
            goldMarketPanel:addEventListener(kPanelEvents.kClose, function ()
            	PaymentDCUtil.getInstance():setSrcPayId(nil)
            	resumeTimer()
            end)
		else 
			resumeTimer() 
		end
	end
	if errorCode and errorCode == 730330 then -- not enough gold
		GoldlNotEnoughPanel:createWithTipOnly(onCreateGoldPanel)
	end
end

function EndGamePropAndroidPanel_VerB:buyWithWindMill(onBuySuccess, onBuyFail, onBuyCancel)
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

function EndGamePropAndroidPanel_VerB:onCloseBtnTapped()
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
						-- he_log_error("zhijiancheck----22")
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
	
	EndGamePropBasePanel_VerC.onCloseBtnTapped(self)
end

function EndGamePropAndroidPanel_VerB:popout()
	if _G.isLocalDevelopMode then printx(0, 'EndGamePropAndroidPanel_VerB:popout()') end
	if self:isOneYuanDecision() then 
		PaymentManager.getInstance():refreshOneYuanShowTime()
	end

	EndGamePropBasePanel_VerC.popout(self)
	-- self:setBgDark(false)

	if not self:handleActivity() then
		-- self:setBgDark(true)
	end
end

function EndGamePropAndroidPanel_VerB:setBgDark(isDark)
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

function EndGamePropAndroidPanel_VerB:updateToPropEnough(isBuyAddFive)
	print("EndGamePropAndroidPanel_VerB:updateToPropEnough()================called")
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


		if self.moneyBar then 
			self.moneyBar:setVisible(false)
		end
	end
end

function EndGamePropAndroidPanel_VerB:handleActivity()
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


function EndGamePropAndroidPanel_VerB:onCashNumChange( ... )
	
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

	if self.packDiscountPlate then
		self:updatePackDiscountPlate()
	end
end

function EndGamePropAndroidPanel_VerB:updateAddStepMode( ... )
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

function EndGamePropAndroidPanel_VerB:deInit( ... )
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

function EndGamePropAndroidPanel_VerB:reInit( ... )
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

-------------------------------- pack discount ----------------------------
function EndGamePropAndroidPanel_VerB:checkCreatePackDiscountPlate()
	EndGamePropBasePanel_VerC.checkCreatePackDiscountPlate(self)
	self:updatePackDiscountPlate()
end

function EndGamePropAndroidPanel_VerB:updatePackDiscountPlate()
	if self.isDisposed then return end
	-- printx(11, " = = = EndGamePropAndroidPanel_VerB:updatePackDiscountPlate = = = ")

	local function onCheckPaymentBack(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		-- printx(11, "onCheckPaymentBack", decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		self.packDiscountPayParam = {}
		self.packDiscountPayParam.adDecision = decision
		self.packDiscountPayParam.adPaymentType = paymentType
		self.packDiscountPayParam.dcAndroidStatus = dcAndroidStatus
		self.packDiscountPayParam.adRepayChooseTable = repayChooseTable

		if decision == IngamePaymentDecisionType.kPayWithWindMill then
			self.packDiscountUseHPCoin = true
		else
			self.packDiscountUseHPCoin = false
		end

		if self.packDiscountPlate then
			self:refreshPackDiscountPlate()
		else
			self:createPackDiscountPlate()
		end
	end

	if self.goodsPackID and self.goodsPackID > 0 then
		-- 判断中，若玩家风车币足够，必然返回风车币购买
		-- 风车币不足时，显示人民币购买
		-- 但是，因没有短代方式，故不支持三方时，仍显示风车币购买
		PaymentManager.getInstance():getBuyItemDecision(onCheckPaymentBack, self.goodsPackID)
	end
end

function EndGamePropAndroidPanel_VerB:onPackDiscountBuyBtnTapped()
	if self.isDisposed then return end
	if not self.packDiscountPayParam then return end

	EndGamePropBasePanel_VerC.onPackDiscountBuyBtnTapped(self)

	-- if self.packDiscountPayParam.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
	if self.packDiscountUseHPCoin then
		self:onBuyPackDiscountByHappyCoin()
	else
		self:onBuyPackDiscountByCash()
	end
end

function EndGamePropAndroidPanel_VerB:onBuyPackDiscountByCash()
	if self.isDisposed then return end

	local function onBuySuccess()
		-- self:dcBuySuccess()	--不用打产品没要求打的点
		
		if self.isDisposed then return end 
		self:onBuyPackDiscountSucceed()

		-- self.dcIosInfo:setResult(DCWindmillPayResult.kSuccess)
		-- PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
	end

	local function onBuyFail(errorCode, errorMsg)
		self:onBuyPackDiscountFailed(errorCode, errorMsg)
	end

	local function onBuyCancel()
		self:onBuyCancel()
	end

	local goodsId = self.goodsPackID
	local goodsIdInfo = GoodsIdInfoObject:create(goodsId)
	local payParams = self.packDiscountPayParam

	local dcAndroidInfoForGoodsPack = DCAndroidRmbObject:create()
	dcAndroidInfoForGoodsPack:setGoodsId(goodsId)
	dcAndroidInfoForGoodsPack:setGoodsType(goodsIdInfo:getGoodsType())
	dcAndroidInfoForGoodsPack:setGoodsNum(1)
	dcAndroidInfoForGoodsPack:setTypeStatus(payParams.dcAndroidStatus)
	if payParams.adDecision == IngamePaymentDecisionType.kPayFailed then 	
		--加五步面板断网导致支付失败要特殊处理 因为此时面板已经弹出
		if payParams.adPaymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
			dcAndroidInfoForGoodsPack:setInitialTypeList(PaymentManager.getInstance():getDefaultThirdPartPayment())
		end
	else
		dcAndroidInfoForGoodsPack:setInitialTypeList(payParams.adPaymentType)
	end
	
	-- PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcAndroidInfo)	--不用打产品没要求打的点
	local logic = IngamePaymentLogic:createWithGoodsInfo(goodsIdInfo, dcAndroidInfoForGoodsPack, DcFeatureType.kPaymentPack, DcSourceType.kPaymentPackID..goodsId)
	---- paymentLogic中，外部buyConfirmPanel有几种用途在支付成功/失败的时候被remove，这里不需要这种特性，放弃设置为buyConfirmPanel
	-- logic:setBuyConfirmPanel(self)
	logic:endGameBuy(payParams.adDecision, payParams.adPaymentType, onBuySuccess, onBuyFail, onBuyCancel, self.onCancelTappedCallback, payParams.adRepayChooseTable)
	self.buyLogic = logic
	self.onEnterForeGroundCallback = onBuyCancel

	-- self:dcBuyBtnTap()
end

function EndGamePropAndroidPanel_VerB:onBuyPackDiscountFailed(errorCode, errorMsg)
	if self.isDisposed then return end

	if errorCode and errorCode == 730330 then 
		-- VerC 中会统一处理
	else
		if errorCode and errorCode == 730241 or errorCode == 730247 or errorCode == SelfDefinePayError.kPaySucCheckFail then
			CommonTip:showTip(errorMsg, "negative")
		else
			CommonTip:showTip(Localization:getInstance():getText("add.step.panel.buy.fail.android"), "negative")
		end
	end

	EndGamePropBasePanel_VerC.onBuyPackDiscountFailed(self, errorCode, errorMsg)
end
