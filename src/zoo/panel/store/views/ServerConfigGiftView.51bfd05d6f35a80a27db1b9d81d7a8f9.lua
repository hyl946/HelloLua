local UIHelper = require 'zoo.panel.UIHelper'

local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'

local RewardItemView = require 'zoo.panel.store.views.RewardItemView'



local ServerConfigGiftView = class(Layer)

function ServerConfigGiftView:create( itemData )
	local goodsId = itemData.goodsId

	DcUtil:UserTrack({category = 'new_store', sub_category = 'limited_goods_pack', goods_id = goodsId})

	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	if #(table.filter(goodsMeta.items or {}, function ( v )
		return v.itemId ~= ItemType.GOLD 
	end) or {}) > 0 then

		local v = ServerConfigGiftView.new()
		v:initLayer()
		v:initWithData(itemData)

		return v
	else
		local v = SingleGoldGiftView:create(itemData)
		return v
	end
end



function ServerConfigGiftView:initWithData( itemData )
	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/gift-2')
	self.ui = ui
	self:addChild(ui)

	self.itemData = itemData

	self:initView()
end

function ServerConfigGiftView:initView( ... )
	if self.isDisposed then return end
	local titleLabel = self.ui:getChildByPath('name')

	local goodsId = self.itemData.goodsId
	CommonViewLogic:setTitle(titleLabel, goodsId, 'fnt/libao5.fnt', 1.05)

	local goodsMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	local goldItem = table.find(goodsMeta.items or {}, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local goldNumLabel = self.ui:getChildByPath('goldNumLabel')

	if goldItem then
		UIHelper:setLeftText(goldNumLabel, tostring(goldItem.num), 'fnt/libao3.fnt')
	end
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
		if goodsMeta.discountRmb and goodsMeta.discountRmb > 0 then
			self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol('CNY'), goodsMeta.discountRmb/100))
		else
			self.button:setString(string.format('%s%.2f', BuyHappyCoinManager:getCurrencySymbol('CNY'), goodsMeta.rmb/100))
		end
	end

	self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.isDisposed then return end
		
		BuyGoodsLogic:getInstance():buy(goodsId, GoodsType.kItem, self.itemData.iapConfig, function ( ... )
			if self.isDisposed then 
				if _G.StoreManager:getInstance():getPanelInstance() then
					_G.StoreManager:getInstance():getPanelInstance():refreshGoldLabel()
				end
				return 
			end
			
			self:dp(Event.new('AfterBuySuccess', GoodsIdInfoObject:create(self.itemData.goodsId, GoodsType.kItem), self))

			local scgMgr = require('zoo.panel.store.modules.ServerConfigGiftManager'):getInstance()
			if scgMgr:onBuySuccess(self.itemData.serverConfigGiftId) then
				self:callAncestors('removeStoreItem', self)
			else

				if self.ui:getChildByPath('flag-2').onBuyCountChange then
					self.itemData.buyCount = self.itemData.buyCount + 1 
					self.ui:getChildByPath('flag-2'):onBuyCountChange(self.itemData.buyCount)
				end

			end
		end, function ( ... )
			-- body
		end, function ( ... )
			-- body
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


	local icon = math.clamp(self.itemData.serverConfigGiftIcon, 0, 3)

	for _icon = 0, 3 do
		self.ui:getChildByPath('icons/' .. _icon):setVisible(icon == _icon)
	end


	CommonViewLogic:setTimeAndBuyLimit(self.ui:getChildByPath('flag-2'), self.itemData.endTime, self.itemData.buyLimit, self.itemData.buyCount, function ( ... )
		if self.isDisposed then return end
		self:callAncestors('removeStoreItem', self)
	end, not self.itemData.needShowEndTime)

end


function ServerConfigGiftView:setEnabled( bEnabled )
	if self.isDisposed then return end
	self.button:setEnabled(bEnabled)
end


return ServerConfigGiftView

