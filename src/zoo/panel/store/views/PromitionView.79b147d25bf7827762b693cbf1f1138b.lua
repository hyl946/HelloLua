local UIHelper = require 'zoo.panel.UIHelper'

local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'

local RewardItemView = require 'zoo.panel.store.views.RewardItemView'


--这个需求从第一版 就充满了 好多种 特殊处理，
--新需求就不能想好一个整齐的方案，再排任务开始做吗
--从第一版就加各种特殊逻辑 真是丑陋~~~~~~

local SingleGoldGiftView = class(Layer)


function SingleGoldGiftView:create( itemData )
	-- body
	local v = SingleGoldGiftView.new()
	v:initLayer()
	v:initWithData(itemData)
	return v
end

function SingleGoldGiftView:setEnabled( bEnabled )
	if self.isDisposed then return end
	self.button:setEnabled(bEnabled)
end


function SingleGoldGiftView:initWithData( itemData )
	self.itemData = itemData

	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/fuck-item')
	self.ui = ui
	self:addChild(ui)


	local goodsId = itemData.goodsId
	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)


	local titleLabel = self.ui:getChildByPath('name')
	local goodsId = self.itemData.goodsId
	CommonViewLogic:setTitle(titleLabel, goodsId)

	local discountUI = self.ui:getChildByPath('discountUI')
	CommonViewLogic:setDiscountRmbAndRmb(discountUI, goodsMeta.discountRmb, goodsMeta.rmb)
	discountUI:setVisible(false)

	local goldItem = goodsMeta.items[1] or {}


	local bg = self.ui:getChildByName('bg')

	local cash = goldItem.num or 0


	local coinNumT = self.ui:getChildByName("coinNum")
	local numUI = TextField:createWithUIAdjustment(coinNumT:getChildByName('ph'), coinNumT:getChildByName('num'))
	coinNumT:addChild(numUI)
	numUI:setString(cash)


	local button = GroupButtonBase:create(self.ui:getChildByName('button'))
	button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.isDisposed then return end
		BuyGoodsLogic:getInstance():buy(goodsId, GoodsType.kItem, self.itemData.iapConfig, function ( ... )
			
			if self.isDisposed then 
				if _G.StoreManager:getInstance():getPanelInstance() then
					_G.StoreManager:getInstance():getPanelInstance():refreshGoldLabel()
				end
				return 
			end
			
			self:dp(Event.new('AfterBuySuccess', GoodsIdInfoObject:create(self.itemData.goodsId, GoodsType.kItem), self))
			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_buy_success",
				goods_id = goodsId,
			})
			PromotionManager:getInstance():onBuySuccess()
			self:callAncestors('removeStoreItem', self)
		end, function ( ... )
			-- body
		end, function ( ... )
			-- body
		end)
	end))

	self.button = button


	local price = 0
	local symbol = ''

	if __ANDROID then
		symbol = BuyHappyCoinManager:getCurrencySymbol('CNY')
		price = _G.StoreManager:getInstance():getAndroidGoodsPrice(GoodsIdInfoObject:create(self.itemData.goodsId, GoodsType.kItem))
	end

	if __IOS or __WIN32 then
		local stMgr = StoreManager:getInstance()
		symbol = BuyHappyCoinManager:getCurrencySymbol(self.itemData.iapConfig.priceLocale)
		price = self.itemData.iapConfig.iapPrice
	end

	button:setString(string.format('%s%.2f', symbol, price))
	self.button:setColorMode(kGroupButtonColorMode.blue)



	
	CommonViewLogic:setTimeAndBuyLimit(self.ui:getChildByPath('flag-2'), self.itemData.endTime, self.itemData.buyLimit, self.itemData.buyCount, function ( ... )
		if self.isDisposed then return end
		self:callAncestors('removeStoreItem', self)
	end)

end



local ActGiftView = class(Layer)

function ActGiftView:create( itemData )
	DcUtil:UserTrack({category = 'new_store', sub_category = 'limited_goods_pack', goods_id = itemData.goodsId})
	local goodsId = itemData.goodsId
	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	if #(table.filter(goodsMeta.items or {}, function ( v )
		return v.itemId ~= ItemType.GOLD 
	end) or {}) > 0 then

		local v = ActGiftView.new()
		v:initLayer()
		v:initWithData(itemData)

		return v
	else
		local v = SingleGoldGiftView:create(itemData)
		return v
	end
end



function ActGiftView:initWithData( itemData )
	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/gift-2')
	self.ui = ui
	self:addChild(ui)

	self.itemData = itemData

	self:initView()
end

function ActGiftView:initView( ... )
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

	local hasItems = false

	for _, v in ipairs(goodsMeta.items) do
		if v.itemId ~= ItemType.GOLD then
			local view = RewardItemView:create(v, CCSizeMake(holderBounds.size.width/2, holderBounds.size.height/3))
			local layoutItem = ItemInLayout:create()
			layoutItem:setContent(view)
			itemsLayout:addItem(layoutItem)
			hasItems = true
		end
	end

	if not hasItems then
		self.ui:getChildByPath('bg2'):setVisible(false)
		UIHelper:move(self.ui:getChildByPath('goldNumLabel'), 0, -80)
		UIHelper:move(self.ui:getChildByPath('goldIcon'), 0, -80)
		UIHelper:move(self.ui:getChildByPath('bg1'), 0, -80)
	end


	local posX, posY = holder:getPositionX(), holder:getPositionY()
	itemsLayout:setPositionXY(posX, posY)
	self.ui:addChild(itemsLayout)

	holder:removeFromParentAndCleanup(true)

	self.ui:getChildByPath('flag'):setVisible(false)

	self.button = GroupButtonBase:create(self.ui:getChildByPath('button'))
	self.button:setString('')

	if self.itemData.iapConfig then
		self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol(self.itemData.iapConfig.priceLocale), self.itemData.iapConfig.iapPrice))
	else
		local price = _G.StoreManager:getInstance():getAndroidGoodsPrice(GoodsIdInfoObject:create(self.itemData.goodsId, GoodsType.kItem))
		self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol('CNY'), price))
	end

	self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.isDisposed then return end
		BuyGoodsLogic:getInstance():buy(goodsId, GoodsType.kItem, self.itemData.iapConfig, function ( ... )
			if self.isDisposed then return end
			self:dp(Event.new('AfterBuySuccess', GoodsIdInfoObject:create(self.itemData.goodsId, GoodsType.kItem), self))

			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_buy_success",
				goods_id = goodsId,
			})
			PromotionManager:getInstance():onBuySuccess()

			self:callAncestors('removeStoreItem', self)

		end, function ( ... )
			-- body
		end, function ( ... )
			-- body
		end, function ( payType )
			local payment = PaymentBase:getPayment(payType)
			return payment:getPaymentLevel() == PaymentLevel.kLvOne
		end)
	end))

	local discountUI = self.ui:getChildByPath('discountUI')
	CommonViewLogic:setDiscountRmbAndRmb(discountUI, goodsMeta.discountRmb, goodsMeta.rmb)


	local anim = UIHelper:createArmature2('skeleton/store-anim', 'com.niu2x.store.anim/gift-2-light-anim')
	anim:playByIndex(0, 0)
	anim:setPositionY(-20)
	local flag = self.ui:getChildByPath('flag-2')
	local flagIndex = self.ui:getChildIndex(flag)
	self.ui:addChildAt(anim, flagIndex)

	self.button:setColorMode(kGroupButtonColorMode.blue)



	self.ui:getChildByPath('icons/2'):setVisible(false)

	CommonViewLogic:setTimeAndBuyLimit(self.ui:getChildByPath('flag-2'), self.itemData.endTime, self.itemData.buyLimit, self.itemData.buyCount, function ( ... )
		if self.isDisposed then return end
		self:callAncestors('removeStoreItem', self)
	end)
	self.ui:getChildByPath('icons/3'):setVisible(false)
end


function ActGiftView:setEnabled( bEnabled )
	if self.isDisposed then return end
	self.button:setEnabled(bEnabled)
end


return ActGiftView