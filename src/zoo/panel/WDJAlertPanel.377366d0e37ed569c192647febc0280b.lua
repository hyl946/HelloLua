local function setRichText(parent, textLabel, str)

	if parent.isDisposed then return end
	if textLabel.isDisposed then return end

	if textLabel.richText then
		textLabel.richText:removeFromParentAndCleanup(true)
		textLabel.richText = nil
	end

	textLabel:setVisible(false)

	if not str then
		return
	end

	local width = textLabel:getDimensions().width
	local pos = textLabel:getPosition()
	local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
	richText:setPosition(ccp(pos.x, pos.y))
	parent:addChildAt(richText, textLabel:getZOrder())

	textLabel.richText = richText
end


local skipXiBaoCheckFlag = false
local skipMergeTipFlag = false


local WDJAlertPanel = class(BasePanel)

function WDJAlertPanel:create()
    local panel = WDJAlertPanel.new()
    panel:loadRequiredResource("ui/wdj_alert.json")
    panel:init()
    return panel
end

function WDJAlertPanel:init()
    local ui = self:buildInterfaceGroup("wdj_alert_un_connect/panel")
	BasePanel.init(self, ui)


	local texts = 'wdj.alert.panel.texts_wdj'

	if __WIN32  or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		texts = 'wdj.alert.panel.texts_mitalk'
	end

	local label = self.ui:getChildByName('label_1')
	setRichText(self.ui, label, localize(texts, {n='\n'}))

	local height = label.richText:getContentSize().height 

	local adjustY = math.max(0, height - 196)

	local bg = self.ui:getChildByName('bg')
	local bg2 = self.ui:getChildByName('bg2')

	local bgSize = bg:getPreferredSize()
	local bg2Size = bg2:getPreferredSize()

	bg:setPreferredSize(CCSizeMake(bgSize.width, bgSize.height + adjustY))
	bg2:setPreferredSize(CCSizeMake(bg2Size.width, bg2Size.height + adjustY))

	self.ui:getChildByName('button'):setPositionY(self.ui:getChildByName('button'):getPositionY() - adjustY)

	self.button = GroupButtonBase:create(self.ui:getChildByName('button'))
	self.button:setString('登 录')

	self.button:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onButton()
	end)

    
end

function WDJAlertPanel:_close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)

end

function WDJAlertPanel:popout(callback)

	skipXiBaoCheckFlag = true
	skipMergeTipFlag = true

	self.callback = callback


    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
end

function WDJAlertPanel:onButton( ... )
    self:_close()

    if self.callback then
    	self.callback()
    end

    self.callback = nil
end

function WDJAlertPanel:shouldSkipXiBaoCheck( ... )
	return skipXiBaoCheckFlag
end

function WDJAlertPanel:shouldSkipMergeTip( ... )
	return skipMergeTipFlag
end

return WDJAlertPanel