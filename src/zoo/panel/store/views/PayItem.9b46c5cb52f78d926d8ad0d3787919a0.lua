
local UIHelper = require 'zoo.panel.UIHelper'
local AliQuickItem = require 'zoo.panel.store.views.AliQuickItem'

local PayItem = class(Layer)

function PayItem:create(goodsIdInfo)
    local item = PayItem.new()
    item:initLayer()
    item:init(goodsIdInfo)
    return item
end

function PayItem:init(goodsIdInfo)
	local ui = UIHelper:createUI('ui/store.json', 'com.niu2x.store/pay-item')
	self.ui = ui
	self:addChild(ui)

	self.goodsIdInfo = goodsIdInfo

	self.check = self.ui:getChildByPath('check')
	self.checkBg2 = self.ui:getChildByPath('check-bg-2')
	self.checkBg1 = self.ui:getChildByPath('check-bg-1')
	self.bg2 = self.ui:getChildByPath('bg-2')
	self.bg1 = self.ui:getChildByPath('bg-1')

    self:setSelected(false)


	local layer = Layer:create()
	local bounds = self.bg1:getGroupBounds()
	local w, h = bounds.size.width, bounds.size.height
	layer:changeWidthAndHeight(w, h)
	layer:setAnchorPoint(ccp(0, 1))
	self.ui:addChild(layer)
	layer:ignoreAnchorPointForPosition(false)

	layer:setTouchEnabled(true, 0, true)
	layer:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if not self.bSelected then
			self:setSelected(not self.bSelected)
		end
	end))
end

function PayItem:setSelected( bSelected )
	if self.isDisposed then return end
	self.bg1:setVisible(bSelected)
	self.bg2:setVisible(not bSelected)

	self.checkBg1:setVisible(bSelected)
	self.checkBg2:setVisible(not bSelected)

	self.check:setVisible(bSelected)

	self.bSelected = bSelected

	

	if self.pluginItem then
		self.pluginItem:setVisible(bSelected)
	end

	if bSelected then
		self:dp(Event.new('onPayItemSelected', nil, self))
	end
end



function PayItem:setPayType( payType )
	self.payType = payType

	local showConfig = PaymentManager:getPaymentShowConfig(payType)
	local paymentName = showConfig.name
	local bigIcon = showConfig.bigIcon

	self.ui:getChildByPath('pay_name'):setString(paymentName)

	local pay_icon = self.ui:getChildByPath('pay_icon')
	UIUtils:positionNode(pay_icon, UIHelper:createSpriteFrame('ui/common_pay_icon.json', 'common_pay_icon/' .. bigIcon),  true)


	if payType == Payments.ALIPAY and PaymentManager.getInstance():shouldShowAliQuickPay()
	and PaymentManager.getInstance():checkCanAliQuickPay(_G.StoreManager:getInstance():getAndroidGoodsPrice(self.goodsIdInfo)) then
		local pluginItem = AliQuickItem:create()
		self.ui:addChild(pluginItem)
		pluginItem:setPositionY(-self.ui:getChildByPath('bg-2'):getPreferredSize().height)
		pluginItem:setVisible(self.bSelected)
		self.pluginItem = pluginItem
	end
end

function PayItem:getPayType( ... )
	return self.payType
end

function PayItem:refresh( ... )
	if self.isDisposed then return end
	-- body
	if self.pluginItem then
		self.pluginItem:refresh()
	end
end


return PayItem
