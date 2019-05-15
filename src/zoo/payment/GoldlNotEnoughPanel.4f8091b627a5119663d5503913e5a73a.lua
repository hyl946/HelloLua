if __IOS or __WIN32 then
	require 'zoo.gameGuide.IosPayGuide'
end

GoldlNotEnoughPanel = class(BasePanel)

function GoldlNotEnoughPanel:ctor()
	
end

function GoldlNotEnoughPanel:init()
	self.ui	= self:buildInterfaceGroup("GoldlNotEnoughPanel") 
	BasePanel.init(self, self.ui)

	self:initTitlePart()

	local text = self.ui:getChildByName("text")
	text:setString(Localization:getInstance():getText("buy.prop.no.gold.context"))

	self.buyButton = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn"))
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:setString(Localization:getInstance():getText("buy.prop.no.gold.button"))
	self.buyButton:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
	self.buyButton:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onBuyBtnTap()
		end)

	-- if __IOS or __WIN32 then
	-- 	if IosPayGuide:shouldShowMarketOneYuanFCash() or IosPayGuide:isInFCashPromotion() then
	-- 		self:showDiscountSign(true)
	-- 	end
	-- end
end

function GoldlNotEnoughPanel:initTitlePart()
	local panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(panelTitle)
	panelTitle:setString(Localization:getInstance():getText("buy.prop.no.gold.title"))

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:removeSelf()
	end)
end

-- function GoldlNotEnoughPanel:showDiscountSign(enable)
-- 	self.discountSign:setVisible(enable == true)
-- end

function GoldlNotEnoughPanel:onBuyBtnTap()
	if self.confirmFunc then self.confirmFunc() end
	self:removePopout()
end

function GoldlNotEnoughPanel:removeSelf()
	if self.cancelFunc then self.cancelFunc() end
	self:removePopout()
end

function GoldlNotEnoughPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
	self.allowBackKeyTap = true 
end

function GoldlNotEnoughPanel:removePopout()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function GoldlNotEnoughPanel:onCloseBtnTapped()
	self:removeSelf()
end

function GoldlNotEnoughPanel:create(confirmFunc, cancelFunc)
	local panel = GoldlNotEnoughPanel.new()
	panel.confirmFunc = confirmFunc
	panel.cancelFunc = cancelFunc
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end

function GoldlNotEnoughPanel:createWithTipOnly(confirmFunc)
	CommonTip:showTip(localize("buy.prop.no.gold.context"), "negative", function ()
		if confirmFunc then confirmFunc() end
	end, 1)
end