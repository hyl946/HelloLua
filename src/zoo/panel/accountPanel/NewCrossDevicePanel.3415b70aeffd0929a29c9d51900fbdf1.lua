local NewCrossDevicePanel = class(BasePanel)

--source: 来源，1：账号系统，2：添加好友 
function NewCrossDevicePanel:create(source, oldPlatform)
	local panel = NewCrossDevicePanel.new()
	panel:loadRequiredResource("ui/account_confirm_panels.json")
	panel:init(source, oldPlatform)

	return panel
end

function NewCrossDevicePanel:init(source, oldPlatform)
	self.ui = self:buildInterfaceGroup("CrossDevicePanel"..source)
    BasePanel.init(self, self.ui)

    self.source = source

    self.title = self.ui:getChildByName("title")
    -- self.title:setPreferredSize(333, 63)
	self.title:setText(Localization:getInstance():getText("login.panel.title.6"))
	local size = self.title:getContentSize()
	local scale = 65 / size.height
	self.title:setScale(scale)
	self.title:setPositionX((self.ui:getChildByName("bg1"):getGroupBounds().size.width - size.width * scale) / 2)

    self:initCloseButton()
    self:initContent(oldPlatform)
end

function NewCrossDevicePanel:initContent(oldPlatform)
	local function setRichText(textLabel, str)
		textLabel:setVisible(false)
		local width = textLabel:getDimensions().width
		local pos = textLabel:getPosition()
		local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
		richText:setPosition(ccp(pos.x, pos.y))
		self.ui:addChildAt(richText, textLabel:getZOrder())
	end
	local newPlatform = PlatformConfig:getDevicePlatformLocalize()
	setRichText(self.ui:getChildByName("item1"), localize("login.panel.warning.new6", {n="\n", platform1=oldPlatform, platform2=newPlatform}))
	setRichText(self.ui:getChildByName("item2"), localize("login.panel.warning.new7", {n="\n"}))
	setRichText(self.ui:getChildByName("item3"), localize("login.panel.warning.new8", {n="\n"}))
	
	if self.source == 2 then
		setRichText(self.ui:getChildByName("item4"), localize("login.panel.warning.new4", {n="\n"}))
		setRichText(self.ui:getChildByName("subItem4"), localize("login.panel.warning.detail4", {n="\n"}))
	end

	local function onConfirm()
		self:onCloseBtnTapped()

        if self.okCallback then
            self.okCallback()
        end
	end

	local btnOK = GroupButtonBase:create(self.ui:getChildByName("btnOK"))
	btnOK:setString("知道了") -- Localization:getInstance():getText("button.ok")
	btnOK:addEventListener(DisplayEvents.kTouchTap, onConfirm)
end

function NewCrossDevicePanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()

            if self.cancelCallback then
            	self.cancelCallback()
            end
        end)
end

function NewCrossDevicePanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
	if self.cancelCallback then
    	self.cancelCallback()
    end
end

function NewCrossDevicePanel:popout()
	self:setScale(0.96)
	self:setPositionForPopoutManager()
	self:setPositionY(self:getPositionY() - 3)
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)

end

function NewCrossDevicePanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function NewCrossDevicePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end

function NewCrossDevicePanel:setOkCallback( okCallback )
	self.okCallback = okCallback
end

function NewCrossDevicePanel:setCancelCallback( cancelCallback )
	self.cancelCallback = cancelCallback
end

return NewCrossDevicePanel