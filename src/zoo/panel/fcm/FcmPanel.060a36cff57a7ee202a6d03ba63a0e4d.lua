local FcmPanel = class(BasePanel)

function FcmPanel:create(ptype, callback)
	local panel = FcmPanel.new()
    panel:loadRequiredResource("ui/fcmpanel.json")
    panel:init(ptype, callback)
    return panel
end

function FcmPanel:init(ptype, callback)
	self.ptype = ptype
    self.callback = callback
	local ui = self:buildInterfaceGroup("fcm/fcmpanel")
	BasePanel.init(self, ui)
    self.close_btn = self.ui:getChildByName('close_btn')
    self.close_btn:setTouchEnabled(true)
    self.close_btn:setButtonMode(true)
    self.close_btn:ad(DisplayEvents.kTouchTap, function()
    	self:close()
    end)

    self.ok_btn = self.ui:getChildByName('ok_btn')
    self.ok_btn = GroupButtonBase:create(self.ok_btn)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function()
    	self:close()
    end)
    self.ok_btn:setString(localize("anti.addiction.alert.btn"))

    self.txt_tf = self.ui:getChildByName('txt_tf')
    self.txt_tf:setString(localize("anti.addiction.alert."..self.ptype.."hour"))

    DcUtil:UserTrack({category = "ui", sub_category = "anti_addiction", hour = self.ptype})
end

function FcmPanel:close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
    if self.callback then self.callback() end
    if self.close_cb then self.close_cb() end
end

function FcmPanel:popout(close_cb)
    self.close_cb = close_cb
	if self.isDisposed then return end
    self:setPositionForPopoutManager()
	PopoutQueue:sharedInstance():push(self, true)
end

return FcmPanel