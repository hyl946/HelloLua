require "zoo.panel.endGameProp.EndGamePropBasePanel_VerB"
require "zoo.panel.endGameProp.EndGamePropABCTest"
require "zoo.payment.paymentDC.PaymentIosDCUtil"

EndGamePropIosPanel_VerB_old = class(EndGamePropBasePanel_VerB)


function EndGamePropIosPanel_VerB_old:create(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward)
	local panel = EndGamePropIosPanel_VerB_old.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_add_step)
	panel:initData(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward)
end

function EndGamePropIosPanel_VerB_old:initData(levelId, levelType, propId, onUseCallback, onCancelCallback, useTipText, onPanelWillPopout, onGetLotteryReward)
	self.levelId = levelId
	self.propId = propId
	self.levelType = levelType
	self.onUseTappedCallback = onUseCallback
	self.onCancelTappedCallback = onCancelCallback
	self.onPanelWillPopout = onPanelWillPopout
	self.onGetLotteryReward = onGetLotteryReward

	self.hasPreBuff = GameInitBuffLogic:hasInitBuffFromPreBuffAct()

	local isFUUU , fuuuId , fuuuData = FUUUManager:lastGameIsFUUU(true)
	if levelType == GameLevelType.kFourYears or levelType == GameLevelType.kSummerFish then
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

function EndGamePropIosPanel_VerB_old:updateGoldNum()
	if self.goldNum then 
		local money = UserManager:getInstance().user:getCash()
		self.goldNum:setString(money)
	end
end

function EndGamePropIosPanel_VerB_old:init()
	if not EndGamePropBasePanel_VerB.init(self) then 
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

	if EndGamePropManager.getInstance():checkNormalDiscountGoodsBuyed(self.propId) then
		AddFiveStepABCTestLogic:setPropNeedBuy(false)
		goodsPrice = normalPrice
		self.actSource = EndGameButtonTypeIos.kNormalWindMill
		self.goodsId = goodsId
		self:updateButtonShow(normalPrice, 10)
	else
		goodsPrice = discountPrice
		self.actSource = EndGameButtonTypeIos.kDiscountWindMill
		self.goodsId = discountGoodsId
		self:updateButtonShow(discountPrice, math.ceil(discountPrice / normalPrice * 10))
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

function EndGamePropIosPanel_VerB_old:initWithWindMill()
	self.buyButton:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
	
	local uid = UserManager:getInstance().uid
	if self.moneyBar then
		self.moneyBar:setVisible(true)
		local goldText = self.moneyBar:getChildByName("goldText")
		goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))
		self.goldNum = self.moneyBar:getChildByName("gold")
	end

	--特殊文案显示
	--self:updateLabelShow()
end

function EndGamePropIosPanel_VerB_old:updateLabelShow()
	if EndGamePropManager.getInstance():isAddMoveProp(self.propId) then 
		if EndGamePropABCTest.getInstance():getFuuuShow(self.lastGameIsFUUU) and 
		   -- MaintenanceManager:getInstance():isEnabled("IosFuuuAdd5Step") and 
		   self.lastGameIsFUUU then 
			self.msgLabel:setString(Localization:getInstance():getText('add.step.panel.msg.txt.fuuu'))
		end
	end
end

function EndGamePropIosPanel_VerB_old:updateButtonShow(goodsPrice, discountNum)
	self.goodsPrice = goodsPrice

	if discountNum <= 0 or discountNum == 10 then
		self.buyButton:setDiscount(discountNum)
	else
		self.buyButton:setDiscount(discountNum, Localization:getInstance():getText("buy.gold.panel.discount"))
	end
	self.buyButton:setNumber(goodsPrice) 
end

function EndGamePropIosPanel_VerB_old:onBuyBtnTapped()
	EndGamePropBasePanel_VerB.onBuyBtnTapped(self)

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

function EndGamePropIosPanel_VerB_old:onBuyFail(errorCode, errorMsg)
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
			goldMarketPanel = nil
		end
	end

	local function onCreateGoldPanel()
        local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
        if index ~= 0 then
            goldMarketPanel = createMarketPanel(index)
            goldMarketPanel:setBuyGoldSuccessFunc(buyGoldSuccess)
            goldMarketPanel:popout()
            goldMarketPanel:addEventListener(kPanelEvents.kClose, resumeTimer)
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

function EndGamePropIosPanel_VerB_old:onEnterHandler(event)
	BasePanel.onEnterHandler(self, event)

	if event == "enter" then
		if self.autoBuy == true then 
			self:onBuyBtnTapped()
		end
	elseif event == "exit" then
	end
	self.autoBuy = false
end

function EndGamePropIosPanel_VerB_old:onCloseBtnTapped()
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

	EndGamePropBasePanel_VerB.onCloseBtnTapped(self)
end

-- 风车币变了
function EndGamePropIosPanel_VerB_old:onCashNumChange( ... )
	if self.isDisposed then return end
	self:updateGoldNum()
end