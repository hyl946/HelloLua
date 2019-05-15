local BaseBuyVoucherPanel = require('zoo.panel.endGameProp.lottery.BaseBuyVoucherPanel')

local UIHelper = require 'zoo.panel.UIHelper'

local BuyVoucherPanelAndroid = class(BaseBuyVoucherPanel)

function BuyVoucherPanelAndroid:create(onReady)
    local panel = BuyVoucherPanelAndroid.new()
    panel:init(onReady)
    return panel
end

function BuyVoucherPanelAndroid:init(onReady)
	BaseBuyVoucherPanel.init(self)

	self.rmbIndex = 1

	local counter = #(self:getGoodsIdList())
   	local function handlePaymentDecision(goodsId, decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable )
		if self.isDisposed then return end
    	-- body
    	self['decision_' .. goodsId] = {
    		decision = decision,
    		paymentType = paymentType,
    		dcAndroidStatus = dcAndroidStatus,
    		otherPaymentTable = otherPaymentTable,
    		repayChooseTable = repayChooseTable,
    	}


		counter = counter - 1
    	if counter <= 0 then
    		if self.isDisposed then return end
    		self:buildUI()
    		if onReady then
    			onReady(self)
    		end
    	end

    end

    for _, goodsId in ipairs(self:getGoodsIdList()) do
	    PaymentManager.getInstance():getBuyItemDecision(function ( ... )
	    	handlePaymentDecision(goodsId, ...)
	    end, goodsId)
	end
end

function BuyVoucherPanelAndroid:getGoodsIdList( ... )
	return {600, 601}
end

function BuyVoucherPanelAndroid:getRMBGoodsId( ... )
	return self:getGoodsIdList()[self.rmbIndex]
end

function BuyVoucherPanelAndroid:buildUI( ... )

	local function createDCInfo( goodsId )

		local decision = self['decision_' .. goodsId]
		if decision == IngamePaymentDecisionType.kPayWithWindMill then
			local goodsPrice = self:getCashPrice(goodsId)
			self['dcInfo_' .. goodsId] = DCWindmillObject:create()
			self['dcInfo_' .. goodsId]:setGoodsId(goodsId)
			self['dcInfo_' .. goodsId]:setWindMillPrice(goodsPrice)
			self['dcInfo_' .. goodsId]:setGoodsNum(1)
		else
			local goodsIdInfo = GoodsIdInfoObject:create(goodsId)
			self['goodsIdInfo_' .. goodsId] = goodsIdInfo
			self['dcInfo_' .. goodsId] = DCAndroidRmbObject:create()
			self['dcInfo_' .. goodsId]:setGoodsId(goodsIdInfo:getGoodsId())
			self['dcInfo_' .. goodsId]:setGoodsType(goodsIdInfo:getGoodsType())
			self['dcInfo_' .. goodsId]:setGoodsNum(1)
			self['dcInfo_' .. goodsId]:setTypeStatus(decision.dcAndroidStatus)
			if decision.dcAndroidStatus == IngamePaymentDecisionType.kPayFailed then 	
				if decision.paymentType == AndroidRmbPayResult.kCloseAfterNoNetWithoutSec then 
					self['dcInfo_' .. goodsId]:setInitialTypeList(PaymentManager.getInstance():getDefaultThirdPartPayment())
				end
			else
				self['dcInfo_' .. goodsId]:setInitialTypeList(decision.paymentType)
			end
		end
	end
   	


   	for _, goodsId in ipairs(self:getGoodsIdList()) do
	   	createDCInfo(goodsId)	
	end


   	self.buy_button = ButtonIconNumberBase:create(self.ui:getChildByPath('content/buy_button'))
	self.buy_button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		self:onTapBuyBtn()
	end))

	self:refreshBuyBtn()
end


function BuyVoucherPanelAndroid:onBuyCountChange( ... )
	if self.isDisposed then return end
	self.rmbIndex = self.buyCount

	local goodsId = self:getGoodsId()
	local singlePrice = self:getCashPrice(goodsId)

	local decision = self['decision_' .. goodsId]
	if decision == IngamePaymentDecisionType.kPayWithWindMill then
		self['dcInfo_' .. goodsId]:setWindMillPrice(singlePrice * self.buyCount)
		self['dcInfo_' .. goodsId]:setGoodsNum(self.buyCount)
	end

	self:refreshBuyBtn()
end


local function famatPriceShow(price)
	price = tonumber( price )
	return string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
end


function BuyVoucherPanelAndroid:refreshBuyBtn( )
	if self.isDisposed then return end

	local goodsMeta = self.goodsMeta

	local decision = self['decision_' .. self:getRMBGoodsId()]
	if decision.decision == IngamePaymentDecisionType.kPayWithWindMill then
		self.buy_button:setIconByFrameName("common_icon/item/icon_coin_small0000")
		self.buy_button.icon:setVisible(true)
		self.buy_button:setNumber( self:getCashPrice(goodsMeta.id) * self.buyCount )
		self.buy_button:setString(string.format('购买'))
		self.money_bar:setVisible(true)
	else
		local normalPrice = goodsMeta.rmb / 100
		local finalPrice = 0
		finalPrice = normalPrice
		self.buy_button:setIcon(nil)
		self.buy_button:setNumber( famatPriceShow(finalPrice * self.buyCount) )
		self.buy_button:setString("购买")
		self.money_bar:setVisible(false)
	end

	self.buy_button:setColorMode( kGroupButtonColorMode.blue )
end


function BuyVoucherPanelAndroid:onEnterHandler(event)
	BaseBuyVoucherPanel.onEnterHandler(self, event)

	if event == "enter" then
	elseif event == "exit" then
	end
end



function BuyVoucherPanelAndroid:onTapBuyBtn( ... )
	local goodsMeta = self.goodsMeta

	local decision = self['decision_' .. self:getRMBGoodsId()]

	local function onBuySuccess( ... )
		CommonTip:showTip(localize('five.steps.lottery.buy.voucher'))
		local bounds = self:getGroupBounds()
		local function copyItems( tbl )
			local ret = {}
			for index, v in ipairs(tbl) do
				ret[index] = {itemId = v.itemId, num = v.num}
				if ret[index].itemId == ItemType.VOUCHER then
					ret[index].num = 1 
				end
			end
			return ret
		end
		local items = copyItems(goodsMeta.items)
		local anim = FlyItemsAnimation:create(items)
		anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
		anim:play()
		self:onCloseBtnTapped()
		self:onBuySuccess()
	end

	local function onBuyFail( errCode )
		if errCode and (tonumber(errCode) or -1) == 730330 then
		else
		end
		if errCode then
			CommonTip:showTip(localize('error.tip.'..errCode))
		else
			CommonTip:showTip(localize('buy.gold.panel.err.undefined'))
		end
	end

	local function onBuyCancel( ... )
		-- body
	end

	if decision.decision == IngamePaymentDecisionType.kPayWithWindMill then
		local logic = BuyLogic:create(goodsMeta.id, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSNewLottery)
		logic:getPrice()
		logic:setCancelCallback(onBuyCancel)
		logic:start(self.buyCount, function ( ... )
			require('zoo.panel.endGameProp.lottery.CashObserver'):update()
			self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kSuccess)
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])
			if onBuySuccess then
				onBuySuccess(...)
			end
		end, function ( errorCode )
			if errorCode and errorCode == 730330 then -- not enough gold
				self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kNoWindmill)
			else
				self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kFail, errorCode)
			end
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])
			if onBuyFail then
				onBuyFail(errorCode)
			end
		end)
	else
		local rmbGoodsId = self:getRMBGoodsId()
		PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self['dcInfo_' .. rmbGoodsId])
		local logic = IngamePaymentLogic:createWithGoodsInfo(self['goodsIdInfo_' .. rmbGoodsId], self['dcInfo_' .. rmbGoodsId], DcFeatureType.kAddFiveSteps, DcSourceType.kFSNewLottery)
		logic:endGameBuy(decision.decision, decision.paymentType, onBuySuccess, onBuyFail, onBuyCancel, nil, decision.repayChooseTable)
	end
end

function BuyVoucherPanelAndroid:onCloseBtnTapped( ... )
    if PaymentManager.getInstance():getIsCheckingPayResult() then return end 
	local function handldCloseDC( goodsId )
		local decision = self['decision_' .. self:getRMBGoodsId()]
		local payResult = self['dcInfo_'..goodsId]:getResult()
		if decision == IngamePaymentDecisionType.kPayWithWindMill then
			if payResult and payResult == DCWindmillPayResult.kSuccess then
				return
			end
			if payResult and payResult == DCWindmillPayResult.kNoWindmill then 
				self['dcInfo_'..goodsId]:setResult(DCWindmillPayResult.kCloseAfterNoWindmill)
			elseif payResult and payResult == DCWindmillPayResult.kFail then 
				self['dcInfo_'..goodsId]:setResult(DCWindmillPayResult.kCloseAfterFail)
			elseif payResult and payResult == DCWindmillPayResult.kNoRealNameAuthed then 
				self['dcInfo_'..goodsId]:setResult(DCWindmillPayResult.kCloseAfterNoRealNameAuthed)
			else
				self['dcInfo_'..goodsId]:setResult(DCWindmillPayResult.kCloseDirectly)
			end
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self['dcInfo_'..goodsId])
		else
			if payResult and payResult == AndroidRmbPayResult.kSuccess then
				return
			end

			local rmbGoodsId = self:getRMBGoodsId()

			if payResult and payResult == AndroidRmbPayResult.kNoNet then  
				self['dcInfo_'..rmbGoodsId]:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
			elseif payResult and payResult == AndroidRmbPayResult.kNoPaymentAvailable then 
				self['dcInfo_'..rmbGoodsId]:setResult(AndroidRmbPayResult.kCloseAfterNoPaymentAvailable)
			elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
	    		self['dcInfo_'..rmbGoodsId]:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
			else
				self['dcInfo_'..rmbGoodsId]:setResult(AndroidRmbPayResult.kCloseDirectly)
			end
			PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self['dcInfo_'..rmbGoodsId])
		end
	end
	handldCloseDC(self:getGoodsId())
    BaseBuyVoucherPanel.onCloseBtnTapped(self, ...)
end

return BuyVoucherPanelAndroid