
local UIHelper = require 'zoo.panel.UIHelper'

local AreaTaskDescPanel = class(BasePanel)

function AreaTaskDescPanel:create()
    local panel = AreaTaskDescPanel.new()
    panel:init()
    return panel
end

function AreaTaskDescPanel:init()
    local ui = UIHelper:createUI("ui/area_task.json", "area_task.panel/DescPanel")
	BasePanel.init(self, ui)

	local label = TextField:createWithUIAdjustment(self.ui:getChildByPath('titleHolder'), self.ui:getChildByPath('title'))
	self.ui:addChild(label)
    label:setString(localize('area.goal.detail.title'))
    label:setVisible(false)

    local charWidth = 65
    local charHeight = 65
    local charInterval = 57
    local fntFile = "fnt/caption.fnt"

    self.newCaptain = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
    self.newCaptain:setAnchorPoint(ccp(0.5,0.5))
    self.newCaptain:setString(Localization:getInstance():getText("area.goal.detail.title"))
    self.ui:addChild(self.newCaptain)
    self.newCaptain:setPositionX(662.95/2)
    self.newCaptain:setPositionY(-56)

    local content = self.ui:getChildByPath('content')
    local items = content:getItems()
    for index, item in ipairs(items) do
    	local label = item:findChildByName('label')
    	local dimensions = label:getDimensions()
        label:setDimensions(CCSizeMake(dimensions.width, 0))
    	label:setString(localize('area.goal.detail.desc' .. index))
        item:findChildByName('bg'):setVisible(false)
    end
    content:updateItemsHeight()
    content:pluginRefresh()

    local btn = GroupButtonBase:create(self.ui:getChildByPath('btn'))
    btn:setString(localize('area.goal.detail.btn'))
    btn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:onCloseBtnTapped()
    end)
end

function AreaTaskDescPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function AreaTaskDescPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function AreaTaskDescPanel:onCloseBtnTapped( ... )
    self:_close()
end

return AreaTaskDescPanel
