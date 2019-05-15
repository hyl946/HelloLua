require "zoo.panel.endGameProp.EndGamePropBasePanel_VerC"
require "zoo.panel.endGameProp.EndGamePropABCTest"
require "zoo.payment.paymentDC.PaymentIosDCUtil"

EndGamePropIosPanel_VerB = class(EndGamePropBasePanel_VerC)


function EndGamePropIosPanel_VerB:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward, onUpdatePropBarDisplay, isClone)
	local panel = EndGamePropIosPanel_VerB.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_add_step)
	panel.isClone = isClone
	panel.ctor_params = {levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward, onUpdatePropBarDisplay}
	panel:initData(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward, onUpdatePropBarDisplay)
end

function EndGamePropIosPanel_VerB:clone()
	table.insert(self.ctor_params, true)
	return EndGamePropIosPanel_VerB:create(unpack(self.ctor_params))
end

function EndGamePropIosPanel_VerB:initData(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward, onUpdatePropBarDisplay)
	self.levelId = levelId
	self.propId = propId
	self.levelType = levelType
	self.onUseTappedCallback = onUseCallback
	self.onCancelTappedCallback = onCancelCallback
	self.onPanelWillPopout = onPanelWillPopout
	self.onGetLotteryReward = onGetLotteryReward
	self.onUpdatePropBarDisplay = onUpdatePropBarDisplay

	self.hasPreBuff = GameInitBuffLogic:hasInitBuffFromPreBuffAct()
	self.hasScoreBuff = CollectStarsManager.getInstance():willShowAddStep(levelId  ) and false
	
	local isFUUU , fuuuId , fuuuData = FUUUManager:lastGameIsFUUU(true)
	if levelType == GameLevelType.kFourYears or levelType == GameLevelType.kSummerFish or levelType == GameLevelType.kJamSperadLevel
        or levelType == GameLevelType.kSpring2019 then
		isFUUU = false
	end	
	self.lastGameIsFUUU = isFUUU
	self.fuuuLogID = fuuuId
	self.fuuuData = fuuuData

	--[[if levelType == GameLevelType.kOlympicEndless then
		require("zoo/panel/endGameProp/OlympicEndGamePropBasePanelNormalAnimalAnimetionCreator.lua")
		panel.animalAnimetionCreator = OlympicEndGamePropBasePanelNormalAnimalAnimetionCreator
	end]]

	self:init() 
	if type(useTipText) == "string" then
		self:setUseTipText(useTipText)
		self:setUseTipVisible(true)
	end
	self:popout() 

	self:dcPanelShow()
	self:updateGoldNum()
end

function EndGamePropIosPanel_VerB:updateGoldNum()
	if self.goldNum then 
		local money = UserManager:getInstance().user:getCash()
		self.goldNum:setString(money)
	end
	self:updateMoneyBarPos()
end

function EndGamePropIosPanel_VerB:init()
	self.inDiscountState = false --礼包显示用
	local B1 = GiftPack:isEnabledInGroupMustNewer('B1')
	if not EndGamePropManager.getInstance():checkNormalDiscountGoodsBuyed(self.propId) and (not B1 or self.isWeekly) then
		self.inDiscountState = true
	end

	if not EndGamePropBasePanel_VerC.init(self) then 
		self.actSource = EndGameButtonTypeIos.kPropEnough
		--特殊文案显示
		--self:updateLabelShow()
		return 
	end 
	self.autoBuy = false
	self.iosWindMillPay = true
	self.buyExtraParam = nil 		--用来带一些额外的字段给服务端
	
	local goodsId = EndGamePropManager.getInstance():getGoodsId(self.propId)
	local discountGoodsId = EndGamePropManager.getInstance():getDiscountGoodsId(self.propId)
	local goodsMeta = MetaManager:getInstance():getGoodMeta(discountGoodsId)
	local normalPrice = goodsMeta.qCash
	local discountPrice = goodsMeta.discountQCash
	local goodsPrice = normalPrice

	if self.inDiscountState then
		goodsPrice = discountPrice
		self.actSource = EndGameButtonTypeIos.kDiscountWindMill
		self.goodsId = discountGoodsId
		self:updateButtonShow(discountPrice, math.ceil(discountPrice / normalPrice * 10))
	else
		AddFiveStepABCTestLogic:setPropNeedBuy(false)
		goodsPrice = normalPrice
		self.actSource = EndGameButtonTypeIos.kNormalWindMill
		self.goodsId = goodsId
		self:updateButtonShow(normalPrice, 10)
	end

	if self.moneyBar then
		self.goldNum = self.moneyBar:getChildByName("gold")
	end

	self:initWithWindMill()

	self:updateCountdownShow()

	--支付打点
	self.dcIosInfo = DCWindmillObject:create()
	self.dcIosInfo:setGoodsId(self.goodsId)
	self.dcIosInfo:setWindMillPrice(goodsPrice)
	self.dcIosInfo:setGoodsNum(1)
end

function EndGamePropIosPanel_VerB:initWithWindMill()
	self.buyButton:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
	
	local uid = UserManager:getInstance().uid

	if self.moneyBar then
		self.moneyBar:setVisible(true)
		local goldText = self.moneyBar:getChildByName("goldText")
		goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))
		self.goldNum = self.moneyBar:getChildByName("gold")

		self:getAliQuickLabel():setVisible(false)
		self:updateGoldNum()
	end


	--特殊文案显示
	--self:updateLabelShow()
end

-- function EndGamePropIosPanel_VerB:updateLabelShow()
-- 	if EndGamePropManager.getInstance():isAddMoveProp(self.propId) then 
-- 		if EndGamePropABCTest.getInstance():getFuuuShow(self.lastGameIsFUUU) and 
-- 		   -- MaintenanceManager:getInstance():isEnabled("IosFuuuAdd5Step") and 
-- 		   self.lastGameIsFUUU then 
-- 			self.msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.txt.fuuu'))
-- 		end
-- 	end
-- end

function EndGamePropIosPanel_VerB:updateButtonShow(goodsPrice, discountNum)
	self.goodsPrice = goodsPrice

	if discountNum <= 0 or discountNum == 10 then
		self.buyButton:setDiscount(discountNum)
	else
		self.buyButton:setDiscount(discountNum, Localization:getInstance():getText("buy.gold.panel.discount"))
	end
	self.buyButton:setNumber(goodsPrice) 
end

function EndGamePropIosPanel_VerB:onBuyBtnTapped()
	EndGamePropBasePanel_VerC.onBuyBtnTapped(self)

	local function onBuySuccess()
		self:dcBuySuccess()
		
		if self.isDisposed then return end 
		self:onBuySuccess()

		self.dcIosInfo:setResult(DCWindmillPayResult.kSuccess)
		PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
	end

	local function onBuyFail(errorCode, errorMsg)
		self:onBuyFail(errorCode, errorMsg)
	end

	local function onBuyCancel()
		self:onBuyCancel()
	end

	local logic = BuyLogic:create(self.goodsId, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuy, self.buyExtraParam)
	logic:getPrice()
	logic:setCancelCallback(onBuyCancel)
	logic:start(1, onBuySuccess, onBuyFail)

	self:dcBuyBtnTap()
end

function EndGamePropIosPanel_VerB:onBuyFail(errorCode, errorMsg)
	if self.isDisposed then return end
	self.onEnterForeGroundCallback = nil
	self:stopAllActions()

	local function resumeTimer()
		if self.isDisposed then return end
		self:resumeTimer()
	end

	local function buyGoldEnter()
		CommonTip:showTip(Localization:getInstance():getText("buy.step.no.gold"), "negative")
	end

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

	local function onCreateGoldPanel()
        local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
        if index ~= 0 then
        	PaymentIosDCUtil.getInstance():setSrcPayId(self.dcIosInfo and self.dcIosInfo.payId)

            goldMarketPanel = createMarketPanel(index)
            goldMarketPanel:setBuyGoldSuccessFunc(buyGoldSuccess)

            if self.goodsId == 280 then
            	if goldMarketPanel.addEnterFlag then
            		goldMarketPanel:addEnterFlag(_G.StoreManager.EnterFlag.kEndGamePanelDiscount5Step)
            	end
            end

            goldMarketPanel:popout()
            goldMarketPanel:addEventListener(kPanelEvents.kClose, function ()
            	PaymentIosDCUtil.getInstance():setSrcPayId(nil)
            	resumeTimer()
            end)
        else
        	resumeTimer() 
        end
    end

	if errorCode and errorCode == 730330 then 
		self.dcIosInfo:setResult(DCWindmillPayResult.kNoWindmill)
		PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
		GoldlNotEnoughPanel:createWithTipOnly(onCreateGoldPanel)
	else
		self.dcIosInfo:setResult(DCWindmillPayResult.kFail, errorCode)
		PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
		if errorCode then 
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative", resumeTimer)
		else
			CommonTip:showTip(Localization:getInstance():getText("add.step.panel.buy.fail.android"), "negative")
		end
		self.buyButton:setEnabled(true)
	end
end

function EndGamePropIosPanel_VerB:onEnterHandler(event)
	BasePanel.onEnterHandler(self, event)
	self:_onEnterHandler(event)
end

function EndGamePropIosPanel_VerB:_onEnterHandler( event )
	if event == "enter" then
		if self.autoBuy == true then 
			self:onBuyBtnTapped()
		end
	elseif event == "exit" then
	end
	self.autoBuy = false
end

function EndGamePropIosPanel_VerB:onCloseBtnTapped()
	--三方查询订单时 不可关闭加五步面板
	if self.iosRmbPay then 
		local payResult = self.dcIosInfo:getResult()
		if payResult and payResult == IosRmbPayResult.kSdkFail then 
			self.dcIosInfo:setResult(IosRmbPayResult.kCloseAfterSdkFail)
		elseif payResult and payResult == IosRmbPayResult.kNoRealNameAuthed then
			self.dcIosInfo:setResult(IosRmbPayResult.kCloseAfterNoRealNameAuthed)
		else
			self.dcIosInfo:setResult(IosRmbPayResult.kCloseDirectly)
		end
		PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(self.dcIosInfo)
	elseif self.iosWindMillPay then 
		local payResult = self.dcIosInfo:getResult()
		if payResult and payResult == DCWindmillPayResult.kNoWindmill then 
			self.dcIosInfo:setResult(DCWindmillPayResult.kCloseAfterNoWindmill)
		elseif payResult and payResult == DCWindmillPayResult.kFail then 
			self.dcIosInfo:setResult(DCWindmillPayResult.kCloseAfterFail)
		elseif payResult and payResult == DCWindmillPayResult.kNoRealNameAuthed then 
			self.dcIosInfo:setResult(DCWindmillPayResult.kCloseAfterNoRealNameAuthed)
		else
			self.dcIosInfo:setResult(DCWindmillPayResult.kCloseDirectly)
		end
		PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcIosInfo)
	end

	EndGamePropBasePanel_VerC.onCloseBtnTapped(self)
end

-- 风车币变了
function EndGamePropIosPanel_VerB:onCashNumChange( ... )
	if self.isDisposed then return end
	self:updateGoldNum()

	if self.packDiscountPlate then
		self:refreshPackDiscountPlate()
	end
end

-------------------------------- pack discount ----------------------------
function EndGamePropIosPanel_VerB:checkCreatePackDiscountPlate()
	EndGamePropBasePanel_VerC.checkCreatePackDiscountPlate(self)

	if self.goodsPackID and self.goodsPackID > 0 then
		if self.goodsPackID == 613 then
			-- 特殊需求，613只能用RMB支付
			self.packDiscountUseHPCoin = false
		else
			self.packDiscountUseHPCoin = true
		end
		
		self:createPackDiscountPlate()
	end
end

function EndGamePropIosPanel_VerB:onPackDiscountBuyBtnTapped()
	if self.isDisposed then return end
	EndGamePropBasePanel_VerC.onPackDiscountBuyBtnTapped(self)
	
	if self.packDiscountUseHPCoin then
		self:onBuyPackDiscountByHappyCoin()
	else
		self:onBuyPackDiscountByCash()
	end
end

function EndGamePropIosPanel_VerB:onBuyPackDiscountByCash()
	if self.isDisposed then return end

	local function onBuySuccess()
		if self.isDisposed then return end 
		self:onBuyPackDiscountSucceed()
	end

	local function onBuyFail(errorCode, errorMsg, noTip)
		self:onBuyPackDiscountFailed(errorCode, errorMsg, noTip)
	end

	-- local function onBuyCancel()
	-- 	self:onBuyCancel()
	-- end

	local goodsId = self.goodsPackID
	self.buylogic = IapBuyPropLogic:create(goodsId, 'payment_Pack', 'payment_Pack_'..goodsId)
    if self.buylogic then 
        self.buylogic:buy(onBuySuccess, onBuyFail)
    end
end

function EndGamePropIosPanel_VerB:onBuyPackDiscountFailed(errorCode, errorMsg, noTip)
	if self.isDisposed then return end

	if errorCode and errorCode == 730330 then 
		-- VerC 中会统一处理
	else
		if not noTip then 
			if errorCode then 
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative", resumeTimer)
			else
				CommonTip:showTip(Localization:getInstance():getText("add.step.panel.buy.fail.android"), "negative")
			end
		end
	end

	EndGamePropBasePanel_VerC.onBuyPackDiscountFailed(self, errorCode, errorMsg)
end

