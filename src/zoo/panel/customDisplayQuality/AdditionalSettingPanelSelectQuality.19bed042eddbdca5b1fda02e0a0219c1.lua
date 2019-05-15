local SelectQualityPanel = require "zoo.panel.customDisplayQuality.SelectQualityPanel"
local DisplayQualityManager = require "zoo.panel.customDisplayQuality.DisplayQualityManager"


local AdditionalSettingPanelSelectQuality = class(BasePanel)

function AdditionalSettingPanelSelectQuality:create()
    local panel = AdditionalSettingPanelSelectQuality.new()
    panel:loadRequiredResource("ui/customDisplayQuality.json")
    panel:init()
    return panel
end

function AdditionalSettingPanelSelectQuality:init()
    local ui = self:buildInterfaceGroup("custom.display.quality/set/setting")
	BasePanel.init(self, ui)
--    self.closeBtn = self.ui:getChildByName('closeBtn')
--    self.closeBtn:setTouchEnabled(true, 0, true)
--    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.label_quality = self.ui:getChildByName('label_quality')
    local desc = SelectQualityPanel.QUALITY_DESCRIPTS[DisplayQualityManager:getQuality()]
    self.label_quality:setString("当前画质：" .. desc)

    self.label = self.ui:getChildByName('label')
    self.label:setString("去设置画质")


--    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
--    self.btn:setString('立即更换')
    self.icon = self.ui:getChildByName('icon')
    self.icon:setTouchEnabled(true, 0, true)
    self.icon:ad(DisplayEvents.kTouchTap, function ( ... )
        DcUtil:startChooseGraphicQuality(1)
    	local panel = SelectQualityPanel:create()
        panel:popout()
    end)

    self.reddot = self.icon:getChildByName('dot')

    if(DisplayQualityManager:showRedDot()) then
        DisplayQualityManager:markShowRedDot()
    
        self.reddot:setVisible(true)
    else
        self.reddot:setVisible(false)
    end

--    self.radio_1 = self.ui:getChildByName('radio_1')
--    self.radio_2 = self.ui:getChildByName('radio_2')
--    self.radio_3 = self.ui:getChildByName('radio_3')
    
end

--[[
function AdditionalSettingPanelSelectQuality:_close()

	if self.isDisposed then return end

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end
]]

function AdditionalSettingPanelSelectQuality:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

--[[
function AdditionalSettingPanelSelectQuality:onCloseBtnTapped( ... )
    self:_close()
end
]]

return AdditionalSettingPanelSelectQuality
