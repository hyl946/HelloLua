local BaseBuyVoucherPanel = require('zoo.panel.endGameProp.lottery.BaseBuyVoucherPanel')

local UIHelper = require 'zoo.panel.UIHelper'

local BuyVoucherPanelIOS = class(BaseBuyVoucherPanel)

function BuyVoucherPanelIOS:create(onReady)
    local panel = BuyVoucherPanelIOS.new()
    panel:init(onReady)
    return panel
end

function BuyVoucherPanelIOS:init(onReady)
	BaseBuyVoucherPanel.init(self)

	local function createDCInfo( goodsId )
		local goodsPrice = self:getCashPrice(goodsId)
		self['dcInfo_' .. goodsId] = DCWindmillObject:create()
		self['dcInfo_' .. goodsId]:setGoodsId(goodsId)
		self['dcInfo_' .. goodsId]:setWindMillPrice(goodsPrice)
		self['dcInfo_' .. goodsId]:setGoodsNum(1)
	end

   	createDCInfo(self:getGoodsId())	

	self.buy_button = ButtonIconNumberBase:create(self.ui:getChildByPath('content/buy_button'))
	self.buy_button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		self:onTapBuyBtn()
	end))

   	self:refreshBuyBtn()


   	if onReady then onReady(self) end
end

function BuyVoucherPanelIOS:onBuyCountChange( ... )
	if self.isDisposed then return end
	local goodsId = self:getGoodsId()
	local singlePrice = self:getCashPrice(goodsId)
	self['dcInfo_' .. goodsId]:setGoodsNum(self.buyCount)
	self['dcInfo_' .. goodsId]:setWindMillPrice(self.buyCount * singlePrice)
	self:refreshBuyBtn()
end

function BuyVoucherPanelIOS:refreshBuyBtn( ... )
	if self.isDisposed then return end
	self.buy_button:setIconByFrameName("common_icon/item/icon_coin_small0000")
	self.buy_button:setNumber( self:getCashPrice(self:getGoodsId()) * self.buyCount )
	self.buy_button:setString(string.format('购买') )
	self.buy_button:setColorMode(kGroupButtonColorMode.blue)
end


function BuyVoucherPanelIOS:onEnterHandler(event)
	BaseBuyVoucherPanel.onEnterHandler(self, event)

	if event == "enter" then
		if self.autoBuy then 
			self:runAction(CCCallFunc:create(
				function ( ... )
					if self.isDisposed then return end
					self:onTapBuyBtn()
					self.autoBuy = nil

				end
			))
		end

		self:runAction(CCCallFunc:create(
			function ( ... )
				if self.isDisposed then return end
				self:refreshGoldCash()				
			end
		))

	elseif event == "exit" then
	end
end

function BuyVoucherPanelIOS:onTapBuyBtn( ... )
	if self.isDisposed then return end
	local goodsMeta = self.goodsMeta
	local logic = BuyLogic:create(goodsMeta.id, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSNewLottery)
    local price = logic:getPrice()

	logic:setCancelCallback(function ( ... )
		CommonTip:showTip('购买取消')
	end)

	local goldMarketPanel = nil
	local function buyGoldSuccess()
		if self.isDisposed then return end
		require('zoo.panel.endGameProp.lottery.CashObserver'):update()
		if not goldMarketPanel or self.isDisposed then return end 
		local userCash = UserManager:getInstance().user:getCash()
		if userCash >= price then 
			if not goldMarketPanel.isDisposed then
				goldMarketPanel:onCloseBtnTapped()
			end
			goldMarketPanel = nil
		end

		self:refreshGoldCash()
	end

	local function onCreateGoldPanel()
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			goldMarketPanel = createMarketPanel(index)
			goldMarketPanel:setBuyGoldSuccessFunc(buyGoldSuccess)
			goldMarketPanel:popout()
		end
    end

	logic:start(self.buyCount, function ( ... )

		require('zoo.panel.endGameProp.lottery.CashObserver'):update()
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

		self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kSuccess)
		PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])

	end, function ( errCode )
		if errCode then
			if errCode and (tonumber(errCode) or -1) == 730330 then

				self['dcInfo_' .. goodsMeta.id]:setResult(DCWindmillPayResult.kNoWindmill)
				PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])
				GoldlNotEnoughPanel:createWithTipOnly(onCreateGoldPanel)
			else

				self['dcInfo_' .. goodsMeta.id]:setResult(self['dcInfo_' .. goodsMeta.id], errCode)
				PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])

				if errCode then
					CommonTip:showTip(localize('error.tip.'..errCode))
				else
					CommonTip:showTip(localize('buy.gold.panel.err.undefined'))
				end
			end
		else
			self['dcInfo_' .. goodsMeta.id]:setResult(self['dcInfo_' .. goodsMeta.id], errCode)
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self['dcInfo_' .. goodsMeta.id])

			if errCode then
				CommonTip:showTip(localize('error.tip.'..errCode))
			else
				CommonTip:showTip(localize('buy.gold.panel.err.undefined'))
			end
		end
	end)
end

function BuyVoucherPanelIOS:onCloseBtnTapped( ... )
    BaseBuyVoucherPanel.onCloseBtnTapped(self, ...)

	local function handldCloseDC( goodsId )
		-- body
		local payResult = self['dcInfo_' .. goodsId]:getResult()

		if payResult and payResult == DCWindmillPayResult.kSuccess then
			return
		end

		if payResult and payResult == DCWindmillPayResult.kNoWindmill then 
			self['dcInfo_' .. goodsId]:setResult(DCWindmillPayResult.kCloseAfterNoWindmill)
		elseif payResult and payResult == DCWindmillPayResult.kFail then 
			self['dcInfo_' .. goodsId]:setResult(DCWindmillPayResult.kCloseAfterFail)
		elseif payResult and payResult == DCWindmillPayResult.kNoRealNameAuthed then 
			self['dcInfo_' .. goodsId]:setResult(DCWindmillPayResult.kCloseAfterNoRealNameAuthed)
		else
			self['dcInfo_' .. goodsId]:setResult(DCWindmillPayResult.kCloseDirectly)
		end
		PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self['dcInfo_' .. goodsId])
	end
	handldCloseDC(self:getGoodsId())
end

return BuyVoucherPanelIOS
