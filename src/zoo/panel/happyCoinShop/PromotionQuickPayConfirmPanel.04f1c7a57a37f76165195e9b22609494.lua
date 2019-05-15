local utils = require 'zoo.panel.happyCoinShop.utils'
local PropsBar = class(HorizontalTileLayoutWithAlignment)

local function wrapText(textUI)
	local label = textUI:getChildByName('label')
	local size = textUI:getChildByName('size')
	local text = TextField:createWithUIAdjustment(size, label)
	textUI:addChild(text)
	return text
end


function PropsBar:create(propItems, builder)
	local instance = PropsBar.new()
	instance:init(propItems, builder)
	return instance
end

function PropsBar:init(propItems, builder)
	HorizontalTileLayoutWithAlignment.init(self, 280, 90)
	table.each(propItems, function(item)
		local icon = ResourceManager:sharedInstance():buildItemGroup(item.itemId)
		local ui = builder:buildGroup('alipayment/quick/promotion/item')
		local hole = ui:getChildByName('hole')
		if item.itemId == 10013 or item.itemId == 10004 or item.itemId == 10018 then
			hole:setPositionX(hole:getPositionX() + 4)
		end
		ui:setScale(1.1)
		local iconHolder = ui:getChildByName('iconHolder')
		utils.scaleNodeToSize(icon, iconHolder:getGroupBounds().size)
		ui:addChildAt(icon, 1)
		iconHolder:removeFromParentAndCleanup(true)
		local numLabel = wrapText(ui:getChildByName('num'))
		numLabel:changeFntFile('fnt/skip_level.fnt')
		numLabel:setString('x'..tostring(item.num))
		local item = ItemInLayout:create()
		item:setContent(ui)
		self:addItem(item)
	end)

	self:__layout()
end

function PropsBar:__layout()
    if #self.items == 0 then return end
    local totalWidth = 0
    table.each(self.items, function(item)
    	totalWidth = totalWidth + item:getWidth()
    end)
    local pageWidth = self.width
    local spacingX = (pageWidth - totalWidth)/(#self.items + 1)
    local x = spacingX
    for _, item in ipairs(self.items) do
    	item:setPositionX(x)
    	x = x + item:getWidth() + spacingX
    end
end

local PromotionQuickPayConfirmPanel = class(BasePanel)

function PromotionQuickPayConfirmPanel:create(giftItems, price, payType)
	local goldItem = table.filter(giftItems, function(item) return item.itemId == ItemType.GOLD end)
	local propItems = table.filter(giftItems, function(item) return item.itemId ~= ItemType.GOLD end)
	local cash = 0
	if #goldItem > 0 then
		cash = goldItem[1].num
	end

	if #propItems <= 0 then
		if payType == Payments.WECHAT then
			local WechatQuickPayConfirmPanel = require "zoo.panel.wechatPay.WechatQuickPayConfirmPanel"
			return WechatQuickPayConfirmPanel:create(cash, price)
		else
			local AliQuickPayConfirmPanel = require "zoo.panel.alipay.AliQuickPayConfirmPanel"
			return AliQuickPayConfirmPanel:create(cash, price)
		end
	else
		local panel = PromotionQuickPayConfirmPanel.new()
		panel:loadRequiredResource("ui/ali_payment.json")
		panel:init(cash, propItems, price, payType)
		return panel
	end
end

function PromotionQuickPayConfirmPanel:init(goldNum, propItems, price, payType)
	self.ui = self:buildInterfaceGroup("NewAliQuickPayConfirmPanel")
    BasePanel.init(self, self.ui)

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName("btnOK"))
    self.btnSave:setString(Localization:getInstance():getText("确定"))
    self.btnSave:addEventListener(DisplayEvents.kTouchTap, function ()
        if self.confirmCallback then
            self.confirmCallback()
        end
        self:removeSelf()
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)

    if payType == Payments.WECHAT then
    	self.panelTitle:setString(Localization:getInstance():getText("wechat.kf.pay2.wc"))
    else
    	self.panelTitle:setString(Localization:getInstance():getText("alipay.pay.kf.confirm1"))
    end

    self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
        end)

    local price = string.format("%.2f", price)

    if payType == Payments.WECHAT then
    	self.ui:getChildByName("tip_price"):setString(localize("wechat.kf.pay2.text")..":¥"..price)
    else
    	self.ui:getChildByName("tip_price"):setString(localize("alipay.pay.kf.confirm")..":¥"..price)
    end

    local label, size = self.ui:getChildByName("labelPrice"), self.ui:getChildByName("labelPrice_size")
    label = TextField:createWithUIAdjustment(size, label)
    label:setString(goldNum)
    self.ui:addChild(label)

    self.propBar = PropsBar:create(propItems, self.builder)
    self.propContainer = self.ui:getChildByName('lineFrame')
    self.propContainer:addChild(self.propBar)
    self.propBar:setPosition(ccp(25, 85))
end



function PromotionQuickPayConfirmPanel:popout(confirmCallback, cancelCallback)
    self:setPositionForPopoutManager()
    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
    PopoutManager:sharedInstance():add(self, true, false)
end

function PromotionQuickPayConfirmPanel:removeSelf()
    PopoutManager:sharedInstance():remove(self, true)
end

function PromotionQuickPayConfirmPanel:onCloseBtnTapped()
    self:removeSelf()
    if self.cancelCallback then
        self.cancelCallback()
    end
end

return PromotionQuickPayConfirmPanel