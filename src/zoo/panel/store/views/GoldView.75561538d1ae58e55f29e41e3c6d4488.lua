local UIHelper = require 'zoo.panel.UIHelper'

local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
local GoldView = class(Layer)

function GoldView:create( itemData )
	-- body
	local v = GoldView.new()
	v:initLayer()
	v:initWithData(itemData)

	return v
end

function GoldView:setEnabled( bEnabled )
	if self.isDisposed then return end
	self.button:setEnabled(bEnabled)
end


function GoldView:initWithData( itemData )
	self.itemData = itemData

	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/gold')
	self.ui = ui
	self:addChild(ui)

	local CommonViewLogic = require 'zoo.panel.store.views.CommonViewLogic'
	CommonViewLogic:setDiscount(ui:getChildByName('discount'), self.itemData.productMeta.discount or 0 )

	local bg = self.ui:getChildByName('bg')

	local cash = self.itemData.productMeta.cash
	local extraCash = self.itemData.productMeta.extraCash
	local oriCash = cash - extraCash

	local items = {}
	table.insert(items, {node = self.ui:getChildByName('icon'), margin = {left = 25, right = -8}})
	local oriCashLabel = BitmapText:create(tostring(oriCash), 'fnt/libao3.fnt')
	oriCashLabel:setAnchorPoint(ccp(0.5, 0.5))
	oriCashLabel:setPositionY(-bg:getContentSize().height/2 + bg:getPositionY())
	self.ui:addChild(oriCashLabel)
	table.insert(items, {node = oriCashLabel})

	if extraCash > 0 then
		table.insert(items, {node = self.ui:getChildByName('song'), margin = {left = 8}})

		local extraCashLabel = BitmapText:create(tostring(extraCash), 'fnt/libao3.fnt')
		self.ui:addChild(extraCashLabel)
		extraCashLabel:setAnchorPoint(ccp(0.5, 0.5))
		extraCashLabel:setPositionY(-bg:getContentSize().height/2 + bg:getPositionY())
		table.insert(items, {node = extraCashLabel})

	else
		self.ui:getChildByName('song'):setVisible(false)
	end


	layoutUtils.horizontalLayoutItems(items)


	local iapConfig 


	if __IOS or __WIN32 then
		local stMgr = StoreManager:getInstance()
		iapConfig = stMgr:getIosProductInfoByProductMeta(self.itemData.productMeta)
	end

	local button = GroupButtonBase:create(self.ui:getChildByName('button'))
	button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.isDisposed then return end
		BuyGoodsLogic:getInstance():buy(self.itemData.productMeta.id, GoodsType.kCurrency, iapConfig, function ( ... )
			if self.isDisposed then return end
			self:dp(Event.new('AfterBuySuccess', GoodsIdInfoObject:create(self.itemData.productMeta.id, GoodsType.kCurrency), self))
		end, function ( ... )
		end, function ( ... )
			-- body
		end)

	end))

	self.button = button


	local price = 0
	local symbol = ''

	if __ANDROID then
		symbol = BuyHappyCoinManager:getCurrencySymbol('CNY')
		price = self.itemData.productMeta.price
	end

	if __IOS or __WIN32 then
		local stMgr = StoreManager:getInstance()
		symbol = BuyHappyCoinManager:getCurrencySymbol(iapConfig.priceLocale)
		price = iapConfig.iapPrice
	end

	button:setString(string.format('%s%.2f', symbol, price))
	self.button:setColorMode(kGroupButtonColorMode.blue)

end

return GoldView

