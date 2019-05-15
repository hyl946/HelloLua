local SuperClass = require('zoo.panel.endGameProp.lottery.BuyGoodsBasePanel')
local UIHelper = require 'zoo.panel.UIHelper'

local BuyGoodsAndroidPanel = class(SuperClass)

function BuyGoodsAndroidPanel:create()
    local panel = BuyGoodsAndroidPanel.new()
    return panel
end

function BuyGoodsAndroidPanel:init(onReady)
    local ui = UIHelper:createUI('ui/lottery.json', 'add.step.lottery/buy')
	
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.goodsIds = {479, 480}

    self.btns = {}



    local counter = #(self.goodsIds)

    local function handlePaymentDecision(goodsId, decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable )
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
    			onReady()
    		end
    	end
    end

    PaymentManager.getInstance():getBuyItemDecision(function ( ... )
    	handlePaymentDecision(self.goodsIds[1], ...)
    end, self.goodsIds[1])

    PaymentManager.getInstance():getBuyItemDecision(function ( ... )
    	handlePaymentDecision(self.goodsIds[2], ...)
    end, self.goodsIds[2])

end

function BuyGoodsAndroidPanel:buildUI( ... )
	if self.isDisposed then return end

	self.dcAndroidInfo = DCWindmillObject:create()
	self.dcAndroidInfo:setGoodsId(self.goodsId)
	self.dcAndroidInfo:setWindMillPrice(goodsPrice)
	self.dcAndroidInfo:setGoodsNum(1)

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
   	
   	createDCInfo(self.goodsIds[1])	
   	createDCInfo(self.goodsIds[2])	


	self:setGoodsItem(self.ui:getChildByName('item_1'), self.ui:getChildByName('btn_1'), self.goodsIds[1])
	self:setGoodsItem(self.ui:getChildByName('item_2'), self.ui:getChildByName('btn_2'), self.goodsIds[2])

	self:refreshAllBuyBtn()

end


function BuyGoodsAndroidPanel:onEnterHandler(event)
	SuperClass.onEnterHandler(self, event)

	if event == "enter" then
		if self.autoBuy and self.autoBuy.goodsMeta then 
			self:onTapBuyBtn(self.autoBuy.goodsMeta)
		end
	elseif event == "exit" then
	end
	self.autoBuy = nil
end

function BuyGoodsAndroidPanel:onTapBuyBtn( goodsMeta )

	local decision = self['decision_' .. goodsMeta.id]


	local function onBuySuccess( ... )
		-- body

		CommonTip:showTip(localize('five.steps.lottery.buy.diamond'))

		local bounds = self:getGroupBounds()

		local function copyItems( tbl )
			local ret = {}
			for index, v in ipairs(tbl) do
				ret[index] = {itemId = v.itemId, num = v.num}

				if ret[index].itemId == ItemType.DIAMONDS then
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
		-- body

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
		local logic = BuyLogic:create(goodsMeta.id, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuyDiamonds)
		logic:getPrice()
		logic:setCancelCallback(onBuyCancel)
		logic:start(1, function ( ... )

			require('zoo.panel.endGameProp.lottery.CashObserver'):update()

			-- body
			self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kSuccess)
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])

			if onBuySuccess then
				onBuySuccess(...)
			end

		end, function ( errorCode )
			-- body
			if errorCode and errorCode == 730330 then -- not enough gold
				self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kNoWindmill)
			else
				self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kFail, errorCode)
			end
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcAndroidInfo)

			if onBuyFail then
				onBuyFail(errorCode)
			end
		end)
	else

		PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self['dcInfo_' .. goodsMeta.id])
		local logic = IngamePaymentLogic:createWithGoodsInfo(self['goodsIdInfo_' .. goodsMeta.id], self['dcInfo_' .. goodsMeta.id], DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuyDiamonds)
		-- logic:setBuyConfirmPanel(self)
		logic:endGameBuy(decision.decision, decision.paymentType, onBuySuccess, onBuyFail, onBuyCancel, nil, decision.repayChooseTable)
	end
end

local function famatPriceShow(price)
	price = tonumber( price )
	return string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
end


function BuyGoodsAndroidPanel:refreshBuyBtn( btn, goodsMeta )
	local decision = self['decision_' .. goodsMeta.id]
	
	if decision.decision == IngamePaymentDecisionType.kPayWithWindMill then
		btn:setIconByFrameName("common_icon/item/icon_coin_small0000")
		btn.icon:setVisible(true)
		btn:setNumber( self:getCashPrice(goodsMeta.id) )
		btn:setString(string.format('购买') )
		
	else
		local normalPrice = goodsMeta.rmb / 100
		local discountPrice = goodsMeta.discountRmb / 100
		local finalPrice = 0
		finalPrice = normalPrice
		-- btn.icon:setVisible(false)
		btn:setIcon(nil)
		btn:setNumber( famatPriceShow(finalPrice) )
		btn:setString("购买")
		--todo 
		--隐藏风车币icon
	end

	btn:setColorMode( kGroupButtonColorMode.blue )
end

function BuyGoodsAndroidPanel:onCloseBtnTapped( ... )

	if PaymentManager.getInstance():getIsCheckingPayResult() then return end 

	local function handldCloseDC( goodsId )
		-- body
		local decision = self['decision_' .. goodsId]

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

			if payResult and payResult == AndroidRmbPayResult.kNoNet then  
				self['dcInfo_'..goodsId]:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
			elseif payResult and payResult == AndroidRmbPayResult.kNoPaymentAvailable then 
				self['dcInfo_'..goodsId]:setResult(AndroidRmbPayResult.kCloseAfterNoPaymentAvailable)
			elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
	    		self['dcInfo_'..goodsId]:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
			else
				self['dcInfo_'..goodsId]:setResult(AndroidRmbPayResult.kCloseDirectly)
			end
			PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self['dcInfo_'..goodsId])
		end

	end

	handldCloseDC(self.goodsIds[1])
	handldCloseDC(self.goodsIds[2])

    SuperClass.onCloseBtnTapped(self, ...)
end


return BuyGoodsAndroidPanel

