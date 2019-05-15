local PanelSignResult = class(BasePanel)

function PanelSignResult:create(isSuccess)
	local panel = PanelSignResult.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(isSuccess)

	return panel
end

function PanelSignResult:init(isSuccess)
	self.ui = self:buildInterfaceGroup("PanelSignResult")
    BasePanel.init(self, self.ui)

    self.contentSuccess = self.ui:getChildByName("content_success")
    self.contentFailed = self.ui:getChildByName("content_failed")

    self.contentSuccess:setVisible(isSuccess)
    self.contentFailed:setVisible(not isSuccess)

end

function PanelSignResult:popout(closeCallback)
    self:setPositionForPopoutManager()

    self.closeCallback = closeCallback
    PopoutManager:sharedInstance():add(self, false, false)

    self.timeOutID = setTimeOut(function() 
    		self:onCloseBtnTapped()
    	end, 1.5)
end

function PanelSignResult:onCloseBtnTapped()
	cancelTimeOut(self.timeOutID)

	if self.isDisposed then  return end

    PopoutManager:sharedInstance():remove(self, true)
    if self.closeCallback then
    	self.closeCallback()
    end
end


return PanelSignResult
