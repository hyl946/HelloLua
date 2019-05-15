
local function formatNum( num )
	if num < 10000 then
		return tostring(num)
	else
		return math.floor(num/10000) .. '万'
	end
end

local BuyGoodsBasePanel = class(BasePanel)

function BuyGoodsBasePanel:init(ui)
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.goodsIds = {479, 480}

    self.btns = {}

    self:setGoodsItem(self.ui:getChildByName('item_1'), self.ui:getChildByName('btn_1'), self.goodsIds[1])
    self:setGoodsItem(self.ui:getChildByName('item_2'), self.ui:getChildByName('btn_2'), self.goodsIds[2])

	self:refreshAllBuyBtn()

end

function BuyGoodsBasePanel:setGoodsItem(itemUI, btnUI, goodsId )
	-- body
	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	-- local coinItem = table.find(goodsMeta, function ( item )
	-- 	return item.itemId == ItemType.COIN
	-- end)
	-- local diamondsItem = table.find(goodsMeta, function ( item )
	-- 	return item.itemId == ItemType.DIAMONDS
	-- end)

	-- local coin_label = itemUI:getChildByName('coin_label')
	-- coin_label:setText(formatNum(coinItem.num))

	-- local diamonds_label = itemUI:getChildByName('diamonds_label')
	-- diamonds_label:setText(formatNum(diamondsItem.num))
	local btn = 	ButtonIconNumberBase:create(btnUI)
	btn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onTapBuyBtn(goodsMeta)
	end)
	self:refreshAllBuyBtn()
	self.btns[goodsId] = btn
end

function BuyGoodsBasePanel:onTapBuyBtn( goodsMeta )
	CommonTip:showTip('子类实现')
end

-- function BuyGoodsBasePanel:removePopout()	
-- 	if self.isDisposed then return end
-- 	local container = self:getParent() and self:getParent():getParent()
-- 	if container then
-- 		container:setVisible(false)
-- 	else
-- 		self.ui:setVisible(false)
-- 	end
-- end

function BuyGoodsBasePanel:refreshAllBuyBtn( )
	-- body
	for goodsId, btn in pairs(self.btns) do
		local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
		self:refreshBuyBtn(btn, goodsMeta)
	end
end

function BuyGoodsBasePanel:refreshBuyBtn( btn, goodsMeta )
	CommonTip:showTip('子类实现')
end

function BuyGoodsBasePanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function BuyGoodsBasePanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function BuyGoodsBasePanel:onCloseBtnTapped( ... )
    self:_close()
end

function BuyGoodsBasePanel:onBuySuccess( ... )
	-- CommonTip:showTip('购买成功 刷新转盘')
	if self.onBuySuccessCallback then
		self.onBuySuccessCallback()
	end

	require('zoo.panel.endGameProp.lottery.BuyDiamondObserver'):update()
end

function BuyGoodsBasePanel:setBuyCallback( callback )
	self.onBuySuccessCallback = callback
end

function BuyGoodsBasePanel:getCashPrice( goodsId )
	-- body
	local goodsData = MarketManager:getGoodsById(goodsId)
	if goodsData and goodsData.currentPrice then
		return goodsData.currentPrice
	else
		return 0
	end
end

return BuyGoodsBasePanel
