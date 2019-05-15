
local CheckFAQPanel = class(BasePanel)

function CheckFAQPanel:ctor()
end

function CheckFAQPanel:init()
	self.ui = self:buildInterfaceGroup("manual_order_check/CheckFAQPanel")
    BasePanel.init(self, self.ui)

    self.tip = self.ui:getChildByName("tip")

    self.btnFAQ = GroupButtonBase:create(self.ui:getChildByName('btnFAQ'))
	self.btnFAQ:setString('联系客服')
	self.btnFAQ:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onFAQBtnTap()
	end)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTap()
	end)
end

function CheckFAQPanel:onFAQBtnTap()
	self:remove()
	if self.faqCallback then self.faqCallback() end
	FAQ:openFAQClient('http://fansclub.happyelements.com/fans/faq.php?first=ask&index1=0&index2=0', FAQTabTags.kKeFu, true)
end

function CheckFAQPanel:onCloseBtnTap()
	self:remove()
	if self.cancelCallback then self.cancelCallback() end
end

function CheckFAQPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
end

function CheckFAQPanel:remove()
	PopoutManager:sharedInstance():remove(self, true)
end

function CheckFAQPanel:setTipShow(tipStr)
	if self.tip then self.tip:setString(tipStr) end
end

function CheckFAQPanel:setFaqCallback(faqCallback)
	self.faqCallback = faqCallback
end
function CheckFAQPanel:setCancelCallback(cancelCallback)
	self.cancelCallback = cancelCallback
end

function CheckFAQPanel:create()
	local panel = CheckFAQPanel.new()
	panel:loadRequiredResource("ui/ManualOrderCheck.json")
	panel:init()
	return panel
end

return CheckFAQPanel