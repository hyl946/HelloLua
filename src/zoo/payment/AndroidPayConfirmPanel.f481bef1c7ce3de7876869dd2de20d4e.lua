
local AndroidPayConfirmPanel = class(BasePanel)

function AndroidPayConfirmPanel:create(goodsInfo, confirmCallback, denyCallback)
	local panel = AndroidPayConfirmPanel.new()
	panel:init(goodsInfo, confirmCallback, denyCallback)
	return panel
end

function AndroidPayConfirmPanel:init(goodsInfo, confirmCallback, denyCallback)
	self.denyCallback = denyCallback
	self:loadRequiredResource("ui/BuyConfirmPanel.json")
	local ui = self:buildInterfaceGroup("AndroidPayConfirmPanel")
	BasePanel.init(self, ui)

	local game = ui:getChildByName("game")
	game:setString(Localization:getInstance():getText("payment_confirm_game_name")..
		Localization:getInstance():getText("payment_game_xxl"))
	local prop = ui:getChildByName("prop")
	prop:setString(Localization:getInstance():getText("payment_confirm_prop_name")..
		tostring(goodsInfo.name))
	local price = ui:getChildByName("price")
	price:setString(Localization:getInstance():getText("payment_confirm_prop_price")..
		Localization:getInstance():getText("payment_confirm_sale_price", {num = tostring(goodsInfo.price)}))
	local desc = ui:getChildByName("desc")
	desc:setString(Localization:getInstance():getText("payment_confirm_detail1")..'\n'..
		Localization:getInstance():getText("payment_confirm_detail2"))
	local desc2 = ui:getChildByName("desc2")
	desc2:setDimensions(CCSizeMake(0, 0))
	desc2:setString(Localization:getInstance():getText("payment_confirm_detail3"))
	local size1 = desc2:getContentSize()
	local desc3 = ui:getChildByName("desc3")
	desc3:setDimensions(CCSizeMake(0, 0))
	desc3:setString(Localization:getInstance():getText("payment_confirm_phone_num"))
	local size2 = desc3:getContentSize()
	local bg = ui:getChildByName("bg1")
	local size = bg:getPreferredSize()
	local margin = (size.width - size1.width - size2.width) / 2
	desc2:setPositionX(margin)
	desc3:setPositionX(margin + size1.width)

	local button1 = GroupButtonBase:create(ui:getChildByName("btn1"))
	button1:setString(Localization:getInstance():getText("payment_confirm_button_buy"))
	button1:addEventListener(DisplayEvents.kTouchTap, function()
			if confirmCallback then confirmCallback() end
			self:remove()
		end)
	local button2 = GroupButtonBase:create(ui:getChildByName("btn2"))
	button2:setString(Localization:getInstance():getText("payment_confirm_button_cancel"))
	button2:setColorMode(kGroupButtonColorMode.grey)
	button2:addEventListener(DisplayEvents.kTouchTap, function()
			if denyCallback then denyCallback() end
			self:remove()
		end)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
end

function AndroidPayConfirmPanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function AndroidPayConfirmPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	if self.denyCallback then self.denyCallback() end
	self:remove()
end

function AndroidPayConfirmPanel:remove()
	PopoutManager:sharedInstance():remove(self)
end

return AndroidPayConfirmPanel