
local ConfirmRestartSelectQualityPanel = class(BasePanel)

function ConfirmRestartSelectQualityPanel:create()
    local panel = ConfirmRestartSelectQualityPanel.new()
    panel:loadRequiredResource("ui/customDisplayQuality.json")
    panel:init()
    return panel
end

function ConfirmRestartSelectQualityPanel:init()
    local ui = self:buildInterfaceGroup("custom.display.quality/success")
	BasePanel.init(self, ui)

    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.label = self.ui:getChildByName('label')
    self.label:setString('画质更换成功！需要退出重进游戏才能生效哦！是否现在退出？')

    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
    self.btn:setString('立即退出')
    self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
        DcUtil:restartSelectGraphicQuality(1)
        Director.sharedDirector():exitGame()
    end)

--    self.radio_1 = self.ui:getChildByName('radio_1')
--    self.radio_2 = self.ui:getChildByName('radio_2')
--    self.radio_3 = self.ui:getChildByName('radio_3')
    
end

function ConfirmRestartSelectQualityPanel:_close()

	if self.isDisposed then return end

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function ConfirmRestartSelectQualityPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function ConfirmRestartSelectQualityPanel:onCloseBtnTapped( ... )
    DcUtil:restartSelectGraphicQuality(0)
    self:_close()
end

return ConfirmRestartSelectQualityPanel
