local UIHelper = require 'zoo.panel.UIHelper'

local TestPanel = class(BasePanel)

function TestPanel:create()
    local panel = TestPanel.new()
    panel:init()
    return panel
end

function TestPanel:init()
    local ui = UIHelper:createUI("ui/test.json", "plugin.test/testPanel")
	BasePanel.init(self, ui)

    -- self.ui:getChildByPath('1'):setRewardItem({itemId=14, num=1})
    -- self.ui:getChildByPath('2'):setRewardItem({itemId=10086, num=12})
    -- self.ui:getChildByPath('3'):setRewardItem({itemId=10085, num=21})
end

function TestPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function TestPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function TestPanel:onCloseBtnTapped( ... )
    self:_close()
    return true
end

return TestPanel
