---------------------------
-- Added in version 1.25
---------------------------
TwoChoicePanel = class(BasePanel)

function TwoChoicePanel:ctor()
	self.checkBoxSelected = false
end

function TwoChoicePanel:create(descText, btn1Text, btn2Text, checkboxText, isSelected)
	local instance = TwoChoicePanel.new()
    instance:loadRequiredJson(PanelConfigFiles.two_choice_panel)
    instance:init(descText, btn1Text, btn2Text, checkboxText, isSelected)
    return instance
end

function TwoChoicePanel:setButton1Mode(btnMode)
	if self.btn1 then self.btn1:setColorMode(btnMode) end
end

function TwoChoicePanel:setButton2Mode(btnMode)
	if self.btn2 then self.btn2:setColorMode(btnMode) end
end

function TwoChoicePanel:setButton1TappedCallback(onBtn1Tapped)
	self.onBtn1Tapped = onBtn1Tapped
end

function TwoChoicePanel:setButton2TappedCallback(onBtn2Tapped)
	self.onBtn2Tapped = onBtn2Tapped
end

function TwoChoicePanel:setCloseButtonTappedCallback(onCloseCallback)
	self.onCloseCallback = onCloseCallback
end

function TwoChoicePanel:init(descText, btn1Text, btn2Text, checkboxText, isSelected)
	descText = descText or ""
	btn1Text = btn1Text or ""
	btn2Text = btn2Text or ""
	checkboxText = checkboxText or ""

	if isSelected == true then
		self.checkBoxSelected = true
	end

	local ui = self:buildInterfaceGroup('TwoChoicePanel/panel')
	BasePanel.init(self, ui)

	ui:getChildByName("text"):setString(descText)

	self.btn2 = GroupButtonBase:create(ui:getChildByName('btn2'))
	self.btn2:setColorMode(kGroupButtonColorMode.orange)
	self.btn2:setString(btn2Text)
	local function onBtn2Tapped(evt)
		if self.onBtn2Tapped then self.onBtn2Tapped(self.checkBoxSelected) end
		self:closePanel()
	end
	self.btn2:ad(DisplayEvents.kTouchTap, onBtn2Tapped)

	self.btn1 = GroupButtonBase:create(ui:getChildByName('btn1'))
	self.btn1:setColorMode(kGroupButtonColorMode.blue)
	self.btn1:setString(btn1Text)
	local function onBtn1Tapped(evt)
		if self.onBtn1Tapped then self.onBtn1Tapped(self.checkBoxSelected) end
		self:closePanel()
	end
	self.btn1:ad(DisplayEvents.kTouchTap, onBtn1Tapped)

	self.checkbox = ui:getChildByName('checkbox')
	self.checkbox.selected = self.checkbox:getChildByName("selected")
	self.checkbox:getChildByName("text"):setString(checkboxText)
	self.checkbox:setTouchEnabled(true)
	local function onCheckboxTapped(evt)
		self:onCheckboxTapped()
	end
	self.checkbox:ad(DisplayEvents.kTouchTap, onCheckboxTapped)
	-- 默认选择
	if isSelected then
		self.checkbox.selected:setVisible(true)
	else
		self.checkbox.selected:setVisible(false)
	end

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
end

function TwoChoicePanel:popout()
	PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function TwoChoicePanel:onCheckboxTapped()
	self.checkBoxSelected = not self.checkBoxSelected
	self.checkbox.selected:setVisible(self.checkBoxSelected)
end

function TwoChoicePanel:dispose( ... )
	BaseUI.dispose(self)
end

function TwoChoicePanel:closePanel()
    PopoutManager:sharedInstance():remove(self, true)
    self.allowBackKeyTap = false
end

function TwoChoicePanel:onCloseBtnTapped( ... )
	if self.onCloseCallback then self.onCloseCallback(self.checkBoxSelected) end
	self:closePanel()
end

function TwoChoicePanel:onKeyBackClicked(...)
	assert(#{...} == 0)
	if self.allowBackKeyTap then
    	self:onCloseBtnTapped()
	end
end
