local UIHelper = require 'zoo.panel.UIHelper'

local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'

local RewardItemView = require 'zoo.panel.store.views.RewardItemView'


local GiftView = class(Layer)

function GiftView:create( itemData )
	-- body
	local v = GiftView.new()
	v:initLayer()
	v:initWithData(itemData)

	return v
end



function GiftView:initWithData( itemData )
	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/gift')
	self.ui = ui
	self:addChild(ui)

	self.itemData = itemData

	self:initView()
end

function GiftView:initView( ... )
	if self.isDisposed then return end
	local titleLabel = self.ui:getChildByPath('name')

	local goodsId = self.itemData.goodsId


	CommonViewLogic:setTitle(titleLabel, goodsId)

	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	local goldItem = table.find(goodsMeta.items or {}, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local goldNumLabel = self.ui:getChildByPath('goldNumLabel')
	UIHelper:setLeftText(goldNumLabel, tostring(goldItem.num), 'fnt/libao3.fnt')

	goldNumLabel:setAnchorPointWhileStayOriginalPosition(ccp(0, 0.5))
	goldNumLabel:setScale(goldNumLabel:getScaleX() * 1.1)

	local holder = self.ui:getChildByPath('holder')
	local holderBounds = holder:getGroupBounds()

	local itemsLayout = GridLayout:create()
	itemsLayout:setWidth(holderBounds.size.width)
	itemsLayout:setColumn(2)
	itemsLayout:setItemSize(CCSizeMake(holderBounds.size.width/2, holderBounds.size.height/3))
	itemsLayout:setColumnMargin(0)
	itemsLayout:setRowMargin(0)

	for _, v in ipairs(goodsMeta.items) do
		if v.itemId ~= ItemType.GOLD then
			local view = RewardItemView:create(v, CCSizeMake(holderBounds.size.width/2, holderBounds.size.height/3))
			local layoutItem = ItemInLayout:create()
			layoutItem:setContent(view)
			itemsLayout:addItem(layoutItem)
		end
	end

	local posX, posY = holder:getPositionX(), holder:getPositionY()
	itemsLayout:setPositionXY(posX, posY)
	self.ui:addChild(itemsLayout)

	holder:removeFromParentAndCleanup(true)

	self.ui:getChildByPath('flag'):setVisible(false)

	-- some ugly config

	if goodsId == 636 then
		self.ui:getChildByPath('flag'):setVisible(true)
		self.ui:getChildByPath('flag/t2'):setVisible(false)

	end

	if goodsId == 639 then
		self.ui:getChildByPath('flag'):setVisible(true)
		self.ui:getChildByPath('flag/t1'):setVisible(false)
	end

	


	for _, v in ipairs(self.ui:getChildByPath('icons'):getChildrenList()) do
		v:setVisible(v.name == tostring(goodsId - _G.StoreConfig.GiftGoodsIds[1] + 1))
	end

	self.button = GroupButtonBase:create(self.ui:getChildByPath('button'))
	self.button:setString('')

	if self.itemData.iapConfig then
		self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol(self.itemData.iapConfig.priceLocale), self.itemData.iapConfig.iapPrice))
	else
		if goodsMeta.discountRmb and goodsMeta.discountRmb > 0 then
			self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol('CNY'), goodsMeta.discountRmb/100))
		else
			self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol('CNY'), goodsMeta.rmb/100))
		end
	end

	self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.isDisposed then return end
		BuyGoodsLogic:getInstance():buy(goodsId, GoodsType.kItem, self.itemData.iapConfig, function ( ... )
			if self.isDisposed then return end
			self:dp(Event.new('AfterBuySuccess', GoodsIdInfoObject:create(self.itemData.goodsId, GoodsType.kItem), self))
		end, function ( ... )
			-- body
		end, function ( ... )
			-- body
		end)
	end))

	local discountUI = self.ui:getChildByPath('discountUI')
	CommonViewLogic:setDiscountRmbAndRmb(discountUI, goodsMeta.discountRmb, goodsMeta.rmb)
	
	self.button:setColorMode(kGroupButtonColorMode.blue)
	
end


function GiftView:setEnabled( bEnabled )
	if self.isDisposed then return end
	self.button:setEnabled(bEnabled)
end

return GiftView

