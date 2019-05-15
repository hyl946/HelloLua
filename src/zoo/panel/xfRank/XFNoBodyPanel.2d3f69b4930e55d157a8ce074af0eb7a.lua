
local UIHelper = require 'zoo.panel.UIHelper'

local XFNoBodyPanel = class(BasePanel)

function XFNoBodyPanel:create()
    local panel = XFNoBodyPanel.new()
    panel:init()
    return panel
end

function XFNoBodyPanel:init()
    local ui = UIHelper:createUI("ui/xf_panel.json", "xf/no")
	BasePanel.init(self, ui)

	UIHelper:buildGroupBtn(ui:getChildByPath('btn'), '知道了', function ( ... )
		self:onCloseBtnTapped()
	end)

	ui:getChildByPath('label'):setString('大家正在努力闯关中，稍后再来吧！')
end

function XFNoBodyPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function XFNoBodyPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function XFNoBodyPanel:onCloseBtnTapped( ... )
    self:_close()
end


return XFNoBodyPanel
