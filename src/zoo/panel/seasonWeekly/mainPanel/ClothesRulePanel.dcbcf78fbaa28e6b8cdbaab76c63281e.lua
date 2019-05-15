local ClothesRulePanel = class(BasePanel)


function ClothesRulePanel:create()
    local panel = ClothesRulePanel.new()
    panel:loadRequiredResource('ui/clothespress.json')
    panel:init() 
    return panel
end

function ClothesRulePanel:init()

	self.ui = self:buildInterfaceGroup('clothespress/rule/panel')
	BasePanel.init(self, self.ui)

	self:initCloseButton()
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:closePanel() end)
	self:initLabel()
	self:adjustBG()
end

function ClothesRulePanel:initLabel()
	self.label_title = self.ui:getChildByName("label_title")
	self.label_title:setString( Localization:getInstance():getText("2016_weeklyrace.summer.panel.detail.title2") )

	self.labels = {}
	self.icons = self.ui:getChildByName('icons')

	for i = 1, 5 do
		self.labels[i] = self.ui:getChildByName('label_'..i)
		self.labels[i]:setDimensions(CCSizeMake(self.labels[i]:getDimensions().width, 0))
		self.labels[i]:setString( Localization:getInstance():getText("weekly.clothes.rule.tip."..i) )
	end

	local posY = self.labels[1]:getPositionY()
	local firstLabelPosY = posY

	local spacingY = 40
	local firstIconPosY = self.icons:getChildByName('icon1'):getPositionY()

	for i = 1, 5 do
		self.labels[i]:setPositionY(posY)
		local icon = self.icons:getChildByName('icon'..i)
		if icon then
			icon:setPositionY(posY - firstLabelPosY + firstIconPosY + 10)
		end
		posY = posY - self.labels[i]:getContentSize().height - spacingY
	end

end

function ClothesRulePanel:adjustBG( ... )
	local bg = self.ui:getChildByName('bg'):getChildByName('14')

	local bottomPosY = bg:getPositionY() - bg:getPreferredSize().height

	local bottomLabel = self.labels[#self.labels]
	local bottomLabelPosY = bottomLabel:getPositionY() - bottomLabel:getContentSize().height

	local spacingY = 50
	local adjustY = bottomLabelPosY - bottomPosY - spacingY

	if adjustY < 0 then
		local size = bg:getPreferredSize()
		bg:setPreferredSize(CCSizeMake(size.width, size.height - adjustY))
	end
end

function ClothesRulePanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("closeBtn")
end

function ClothesRulePanel:popout()

	self:scaleAccordingToResolutionConfig()

	self:setPositionForPopoutManager()

	PopoutManager:sharedInstance():add(self , true)
	self.allowBackKeyTap = true
end

function ClothesRulePanel:closePanel()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function ClothesRulePanel:onCloseBtnTapped( ... )
    self:closePanel()
end

function ClothesRulePanel:unloadRequiredResource()

end

return ClothesRulePanel