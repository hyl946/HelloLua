AndroidQuickPayCheckItem = class(ItemInClippingNode)
function AndroidQuickPayCheckItem:create(paymentType, clickCallback)
	local instance = AndroidQuickPayCheckItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items)
	instance:init(paymentType, clickCallback)
	return instance
end

function AndroidQuickPayCheckItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function AndroidQuickPayCheckItem:init(paymentType, clickCallback)
	ItemInClippingNode.init(self)
	local ui = self.builder:buildGroup("market_panel_quick_pay_check")
	self:setContent(ui)
	self.ui = ui
	
	self.clickCallback = clickCallback
	self.paymentType = paymentType

	ui:getChildByName('ph'):setVisible(false)

	self.check_box = ui:getChildByName('check_box')
	self.check_icon = self.check_box:getChildByName('icon')
	self.text_not_signed = ui:getChildByName('text_not_signed')
	self.text_signed = ui:getChildByName('text_signed')

	if self.ui:getChildByName('reduceText') then
		self.reduceText = self.ui:getChildByName('reduceText')
		self.reduceIcon = self.ui:getChildByName('reduceIcon')
		self.reduceText:setVisible(false)
		self.reduceIcon:setVisible(false)
	end

	self.help_btn = ui:getChildByName('help_btn')

	ui:ad(DisplayEvents.kTouchTap, function() self:onTapped() end)

	self.help_btn:setTouchEnabled(true, 0, true)
	self.help_btn:ad(DisplayEvents.kTouchTap, function () self:onHelpBtnTapped() end)

	self:refresh()

end

function AndroidQuickPayCheckItem:onTapped()
	self:setCheck(not self.check_icon:isVisible())
	if self.clickCallback then
		self.clickCallback(self.check_icon:isVisible())
	end
end

function AndroidQuickPayCheckItem:setCheck(value)

	self.check_icon:setVisible(value)
end

function AndroidQuickPayCheckItem:onHelpBtnTapped()
   if self.paymentType == Payments.ALIPAY then
	   	local AliQuickPayInfoPanel = require "zoo.panel.alipay.AliQuickPayInfoPanel"
		local p = AliQuickPayInfoPanel:create()
		p:popout()
		-- 转移到panel里面打点
		-- DcUtil:UserTrack({ category='alipay_mianmi_accredit ', sub_category = 'help'})
	elseif self.paymentType == Payments.WECHAT then
		local WechatQuickPayInfoPanel = require "zoo.panel.wechatPay.WechatQuickPayInfoPanel"
		local p = WechatQuickPayInfoPanel:create()
		p:popout()
		DcUtil:UserTrack({ category='wechat_mm_accredit ', sub_category = 'help'})
	end
end

function AndroidQuickPayCheckItem:refresh()
	if self.paymentType == Payments.ALIPAY then
		if UserManager:getInstance():isAliSigned() then
			self.text_signed:setString(localize('panel.choosepayment.alipay.ykt'))
			self.text_not_signed:setString('')
			self.check_box:setVisible(false)
			self.ui:setTouchEnabled(false)
		else
			self.text_signed:setString('')
			self.text_not_signed:setString(localize('panel.choosepayment.alipay.kuaifu'))
			self.check_box:setVisible(true)
			self.check_icon:setVisible(_G.use_ali_quick_pay)
			self.ui:setTouchEnabled(true, 0, true)
		end
		if AliQuickPayPromoLogic:isEntryEnabled() then
			self.text_signed:setVisible(false)
			self.text_not_signed:setVisible(false)
			self.reduceText:setVisible(true)
			self.reduceText:setString(localize('alipay.kf.shop.2.99'))
			self.reduceIcon:setVisible(true)
		else
			self.text_signed:setVisible(true)
			self.text_not_signed:setVisible(true)
			self.reduceText:setVisible(false)
			self.reduceIcon:setVisible(false)
		end

	elseif self.paymentType == Payments.WECHAT then
		if UserManager:getInstance():isWechatSigned() then
			self.text_signed:setString(localize('wechat.kf.enter2'))
			self.text_not_signed:setString('')
			self.check_box:setVisible(false)
			self.ui:setTouchEnabled(false)
		else
			self.text_signed:setString('')
			self.text_not_signed:setString(localize('wechat.kf.enter1'))
			self.check_box:setVisible(true)
			self.check_icon:setVisible(_G.use_wechat_quick_pay)
			self.ui:setTouchEnabled(true, 0, true)
		end
	end
end

function AndroidQuickPayCheckItem:enableClick()
	self.ui:setTouchEnabled(true, 0, true)
	self.help_btn:setTouchEnabled(true, 0, true)
end

function AndroidQuickPayCheckItem:disableClick()
	self.ui:setTouchEnabled(false)
	self.help_btn:setTouchEnabled(false)
end

