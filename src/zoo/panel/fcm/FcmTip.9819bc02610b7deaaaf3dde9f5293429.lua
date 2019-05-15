local FcmTip = class(BasePanel)

function FcmTip:create()
	local panel = FcmTip.new()
    panel:loadRequiredResource("ui/fcmpanel.json")
    panel:init()
    return panel
end

function FcmTip:init()
	local ui = self:buildInterfaceGroup("fcm/fcmtip")
	BasePanel.init(self, ui)

    self.txt_tf = self.ui:getChildByName('txt_tf')
    --self.txt_tf:setString(localize("anti.addiction.loading.tip"))
    self.txt_tf:setString("合理安排游戏时间，劳逸结合更快乐！")
end

function FcmTip:popout()
	if self.isDisposed then return end
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self)

	local function timeoutCallback( ... )
		self:close()
	end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), 
		CCCallFunc:create(timeoutCallback)))
end

function FcmTip:close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

return FcmTip