local NewQQSyncPanel = class(BasePanel)

--source: 来源，1：账号系统，2：添加好友 
function NewQQSyncPanel:create(source, title, message1, message2)
	local panel = NewQQSyncPanel.new()
	panel:loadRequiredResource("ui/account_confirm_panels.json")
	panel:init(source, title, message1, message2)

	return panel
end

function NewQQSyncPanel:init(source, title, message1, message2)
	self.ui = self:buildInterfaceGroup("NewQQSyncPanel"..source)
    BasePanel.init(self, self.ui)

    self.message1 = message1
    self.message2 = message2
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
function NewQQSyncPanel:initContent()
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

	if self.source == 2 then
		setRichText(self.ui:getChildByName("item3"), localize("login.panel.warning.new4", {n="\n"}))
		setRichText(self.ui:getChildByName("subItem3"), localize("login.panel.warning.detail4", {n="\n"}))
	end

	local function onConfirm()
		self:onCloseBtnTapped()

        if self.okCallback then
            self.okCallback()
        end
	end

	local btnOK = GroupButtonBase:create(self.ui:getChildByName("btnContinue"))
	btnOK:setString(Localization:getInstance():getText("login.panel.button.22"))
	btnOK:addEventListener(DisplayEvents.kTouchTap, onConfirm)
	btnOK:setColorMode(kGroupButtonColorMode.blue)

	local btnSave = GroupButtonBase:create(self.ui:getChildByName("btnSave"))
	btnSave:setColorMode(kGroupButtonColorMode.green)

	local function onSyncFinished()
		CommonTip:showTip("已为您成功保存关卡数据！", "positive",nil, 2)
		btnSave:setString("数据已保存")
		btnSave:setEnabled(false)
	end

	local function onSyncError(errorCode)
		errorCode = tonumber(errorCode) or -1
		if errorCode <= 10 then
			CommonTip:showTip("同步关卡数据失败！", "negative", nil, 2)
		end
	end
	
	local function onSave()
		SyncManager.getInstance():sync(onSyncFinished, onSyncError, kRequireNetworkAlertAnimation.kDefault)
	end

	local cachedHttpList = UserService.getInstance():getCachedHttpData()
	if cachedHttpList and #cachedHttpList > 0 then
		btnSave:setString(localize("loading.tips.preloading.warnning.btn1"))
		btnSave:addEventListener(DisplayEvents.kTouchTap, onSave)
	else
		btnSave:setString(localize("button.cancel"))
		btnSave:addEventListener(DisplayEvents.kTouchTap, function() 
					self:onCloseBtnTapped()
					
					if self.cancelCallback then
						self.cancelCallback()
					end
			end)
	end
end

function NewQQSyncPanel:initCloseButton()
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

function NewQQSyncPanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
	if self.cancelCallback then
    	self.cancelCallback()
    end
end

function NewQQSyncPanel:popout()
	self:setPositionForPopoutManager()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)
end

function NewQQSyncPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function NewQQSyncPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end

function NewQQSyncPanel:setOkCallback( okCallback )
	self.okCallback = okCallback
end

function NewQQSyncPanel:setCancelCallback( cancelCallback )
	self.cancelCallback = cancelCallback
end

return NewQQSyncPanel