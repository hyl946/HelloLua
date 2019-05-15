local NewQQMergePanel = class(BasePanel)

--source: 来源，1：账号系统，2：添加好友 
function NewQQMergePanel:create(source, title, message1, message2, message3)
	local panel = NewQQMergePanel.new()
	panel:loadRequiredResource("ui/account_confirm_panels.json")
	panel:init(source, title, message1, message2, message3)

	return panel
end

function NewQQMergePanel:init(source, title, message1, message2, message3)
	self.ui = self:buildInterfaceGroup("NewQQMergePanel"..source)
    BasePanel.init(self, self.ui)

    self.message1 = message1
    self.message2 = message2
    self.message3 = message3
    self.source = source

    self.title = self.ui:getChildByName("title")
    -- self.title:setPreferredSize(333, 63)
	self.title:setText(title)
	local size = self.title:getContentSize()
	local scale = 65 / size.height
	self.title:setScale(scale)
	self.title:setPositionX((self.ui:getChildByName("bg1"):getGroupBounds().size.width - size.width * scale) / 2)

    self:initCloseButton()
    self:initContent()
end

--localize("loading.tips.preloading.warnning.new1")
--localize("loading.tips.preloading.warnning.new2")
function NewQQMergePanel:initContent()
	local function setRichText(textLabel, str)
		textLabel:setVisible(false)
		local width = textLabel:getDimensions().width
		local pos = textLabel:getPosition()
		local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
		richText:setPosition(ccp(pos.x, pos.y))
		self.ui:addChildAt(richText, textLabel:getZOrder())
	end

	if self.message1 then
		setRichText(self.ui:getChildByName("item1"), self.message1)
	end
	if self.message2 then
		setRichText(self.ui:getChildByName("item2"), self.message2)
	end
	if self.message3 then
		setRichText(self.ui:getChildByName("item3"), self.message3)
	end

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

	local btnOK = GroupButtonBase:create(self.ui:getChildByName("btnSave"))
	btnOK:setString(Localization:getInstance():getText("login.panel.button.19"))
	btnOK:addEventListener(DisplayEvents.kTouchTap, onConfirm)
	--btnOK:setColorMode(kGroupButtonColorMode.orange)
end

function NewQQMergePanel:initCloseButton()
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

function NewQQMergePanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
	if self.cancelCallback then
    	self.cancelCallback()
    end
end

function NewQQMergePanel:popout()
	self:setPositionForPopoutManager()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)
end

function NewQQMergePanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function NewQQMergePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end

function NewQQMergePanel:setOkCallback( okCallback )
	self.okCallback = okCallback
end

function NewQQMergePanel:setCancelCallback( cancelCallback )
	self.cancelCallback = cancelCallback
end

return NewQQMergePanel