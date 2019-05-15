local WXJPConfirmPanel = class(BasePanel)

function WXJPConfirmPanel:create(tipLabel, confirmCB, cancelCB)
    local panel = WXJPConfirmPanel.new()
    panel:loadRequiredResource('ui/WXJPPanels.json')
    panel:init(tipLabel, confirmCB, cancelCB)
    return panel
end

function WXJPConfirmPanel:init(tipLabel, confirmCB, cancelCB)
	self.ui = self:buildInterfaceGroup("WXJPConfirmPanel")
    BasePanel.init(self, self.ui)

	local confirmBtn = GroupButtonBase:create(self.ui:getChildByName("confirmBtn"))
	confirmBtn:setString(localize("告诉TA"))
	confirmBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		if confirmCB then confirmCB() end
		self:removePopout()
	end)

	local cancelBtn = GroupButtonBase:create(self.ui:getChildByName("cancelBtn"))
	cancelBtn:setString(localize("下次吧"))
	cancelBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		if cancelCB then cancelCB() end
		self:removePopout()
	end)

	local tip = self.ui:getChildByName("tip")
	tip:setString(tipLabel)
end

function WXJPConfirmPanel:popout()
	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true, false)
end

function WXJPConfirmPanel:removePopout()
	PopoutManager:sharedInstance():remove(self, true)
end

return WXJPConfirmPanel