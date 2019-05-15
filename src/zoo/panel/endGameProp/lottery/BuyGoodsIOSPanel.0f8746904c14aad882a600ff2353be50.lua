local SuperClass = require('zoo.panel.endGameProp.lottery.BuyGoodsBasePanel')
local UIHelper = require 'zoo.panel.UIHelper'

local BuyGoodsIOSPanel = class(SuperClass)

function BuyGoodsIOSPanel:create()
    local panel = BuyGoodsIOSPanel.new()
    return panel
end

function BuyGoodsIOSPanel:init(onReady)
    local ui = UIHelper:createUI('ui/lottery.json', 'add.step.lottery/buy')
	SuperClass.init(self, ui)
   
	local function createDCInfo( goodsId )
		local goodsPrice = self:getCashPrice(goodsId)
		self['dcInfo_' .. goodsId] = DCWindmillObject:create()
		self['dcInfo_' .. goodsId]:setGoodsId(goodsId)
		self['dcInfo_' .. goodsId]:setWindMillPrice(goodsPrice)
		self['dcInfo_' .. goodsId]:setGoodsNum(1)
	end
   	
   	createDCInfo(self.goodsIds[1])	
   	createDCInfo(self.goodsIds[2])	

   	if onReady then
   		onReady()
   	end
end


function BuyGoodsIOSPanel:onEnterHandler(event)
	SuperClass.onEnterHandler(self, event)

	if event == "enter" then
		if self.autoBuy and self.autoBuy.goodsMeta then 
			self:runAction(CCCallFunc:create(
				function ( ... )
					if self.isDisposed then return end
					self:onTapBuyBtn(self.autoBuy.goodsMeta)
					self.autoBuy = nil

				end
			))
		end
	elseif event == "exit" then
	end
end

function BuyGoodsIOSPanel:onTapBuyBtn( goodsMeta )
    local logic = BuyLogic:create(goodsMeta.id, MoneyType.kGold, DcFeatureType.kAddFiveSteps, DcSourceType.kFSBuyDiamonds)
    local price = logic:getPrice()

	logic:setCancelCallback(function ( ... )
		CommonTip:showTip('购买取消')
	end)

	local goldMarketPanel = nil
	local function buyGoldSuccess()
		require('zoo.panel.endGameProp.lottery.CashObserver'):update()
		if not goldMarketPanel or self.isDisposed then return end 
		local userCash = UserManager:getInstance().user:getCash()
		if userCash >= price then 
			self.autoBuy = {
				goodsMeta = goodsMeta
			}
			if not goldMarketPanel.isDisposed then
				goldMarketPanel:onCloseBtnTapped()
			end
			goldMarketPanel = nil
		end
	end

	local function onCreateGoldPanel()
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			goldMarketPanel = createMarketPanel(index)
			goldMarketPanel:setBuyGoldSuccessFunc(buyGoldSuccess)
			goldMarketPanel:popout()
			-- goldMarketPanel:addEventListener(kPanelEvents.kClose, function ()
			-- 	--btn resume 
			-- end)
		end
    end

	logic:start(1, function ( ... )

		require('zoo.panel.endGameProp.lottery.CashObserver'):update()

		
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

function BuyGoodsIOSPanel:refreshBuyBtn( btn, goodsMeta )
	if self.isDisposed then return end
	-- btn.icon:setVisible(true)
	btn:setIconByFrameName("common_icon/item/icon_coin_small0000")
	btn:setNumber( self:getCashPrice(goodsMeta.id) )
	btn:setString(string.format('购买') )
	btn:setColorMode(kGroupButtonColorMode.blue)
end

function BuyGoodsIOSPanel:onCloseBtnTapped( ... )
    SuperClass.onCloseBtnTapped(self, ...)

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

	handldCloseDC(self.goodsIds[1])
	handldCloseDC(self.goodsIds[2])
end


return BuyGoodsIOSPanel

