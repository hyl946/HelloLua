
local SuccessFinishPanel = class(BasePanel)

function SuccessFinishPanel:create()
    local panel = SuccessFinishPanel.new()
    panel:loadRequiredResource("ui/newLadybug.json")
    panel:init()
    return panel
end

function SuccessFinishPanel:init()
    local ui = self:buildInterfaceGroup("ladybug.new/ladybug.x/allFinish")
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.btn = self.ui:getChildByName('btn')
    self.btn = GroupButtonBase:create(self.btn)
    self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:onCloseBtnTapped()
    end)
    self.btn:setString('知道了')
end

function SuccessFinishPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function SuccessFinishPanel:popout()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function SuccessFinishPanel:onCloseBtnTapped( ... )
    self:_close()
end

return SuccessFinishPanel
