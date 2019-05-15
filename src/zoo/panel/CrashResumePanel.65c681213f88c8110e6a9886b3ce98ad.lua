CrashResumePanel = class(BasePanel)

CrashResumePanelType = {
	
	kSelectPanel = 1 ,
	kFailedTipPanel = 2 ,
}

local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
local visibleSize = Director.sharedDirector():getVisibleSize()

function CrashResumePanel:create( panelType ,levelNameStr, yesCallback , noCallback )
	local panel = CrashResumePanel.new()
	panel:loadRequiredResource("ui/CrashResumePanel.json")
	panel:init(panelType , levelNameStr , yesCallback , noCallback)
	return panel
end

function CrashResumePanel:init( panelType ,levelNameStr, yesCallback , noCallback )

	self.ui = self:buildInterfaceGroup("CrashResumePanel/CrashResumePanel")
	BasePanel.init(self, self.ui)

	self.yesCallback = yesCallback
	self.noCallback = noCallback

	self.label_desc = self.ui:getChildByName("label_desc")

	local function onCloseBtnTapped(evnet)
		self:onCloseBtnTapped()

		if self.noCallback then self.noCallback() end
	end

	self.closeBtn	= self.ui:getChildByName("button_close")
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	local function onDoBtnTapped(evnet)
		if self.yesCallback then self.yesCallback() end

		if panelType == CrashResumePanelType.kFailedTipPanel then
			self:onCloseBtnTapped()
		end
	end

	self.button_do_Res	= self.ui:getChildByName("button_do")
	self.button_do		= GroupButtonBase:create(self.button_do_Res)
	
	if panelType == CrashResumePanelType.kSelectPanel then
		self.label_desc:setString( Localization:getInstance():getText("crash.resume.tip.start" ,{level = levelNameStr} ) ) 
		self.button_do:setString( Localization:getInstance():getText("crash.resume.btn.start") )
	else
		self.label_desc:setString( Localization:getInstance():getText("crash.resume.tip.not.success") ) 
		self.button_do:setString( Localization:getInstance():getText("crash.resume.btn.not.success") )
	end

	self.button_do:addEventListener(DisplayEvents.kTouchTap, onDoBtnTapped)
end

function CrashResumePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end

function CrashResumePanel:popout()

	local scene = Director.sharedDirector():getRunningScene()
	if scene == nil then 
		self:dispose()
		return 
	end

	self:setPositionForPopoutManager()


	PopoutManager:sharedInstance():add(self, true, false)

end





CrashResumeCloseUI = class(BasePanel)

function CrashResumeCloseUI:create( clickCallback )
	local panel = CrashResumeCloseUI.new()
	panel:loadRequiredResource("ui/CrashResumePanel.json")
	panel:init(clickCallback)
	return panel
end

function CrashResumeCloseUI:init( clickCallback )

	self.ui = self:buildInterfaceGroup("CrashResumePanel/CloseBtnUI")
	BasePanel.init(self, self.ui)

	self.clickCallback = clickCallback

	local function onCloseBtnTapped(evnet)
		if self.clickCallback then self.clickCallback() end
	end

	self.closeBtn	= self.ui:getChildByName("btn")
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)
end