
local AFHLevelFailed = class(BasePanel)

function AFHLevelFailed:create(selectCallBack)
	local panel = AFHLevelFailed.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(selectCallBack)
	return panel
end

function AFHLevelFailed:unloadRequiredResource( ... )
end

function AFHLevelFailed:init(selectCallBack)
	self.ui = self:buildInterfaceGroup("AskForHelp/interface/LevelFailed")
	BasePanel.init(self, self.ui)

	assert(type(selectCallBack) == "function")
	self.selectCallBack = selectCallBack

	self.btnRetry = GroupButtonBase:create(self.ui:getChildByName("btnRetry"))
	self.btnRetry:addEventListener(DisplayEvents.kTouchTap, function( ... ) self:onRetry() end)
	self.btnRetry:setString(localize("askforhelp.AFHLevelFailed.btnRetry"))

	self.btnCancel = GroupButtonBase:create(self.ui:getChildByName("btnCancel"))
	self.btnCancel:setColorMode(kGroupButtonColorMode.grey)
	self.btnCancel:addEventListener(DisplayEvents.kTouchTap, function( ... ) self:onCancel() end)
	self.btnCancel:setString(localize("askforhelp.AFHLevelFailed.btnCancel"))

	self:refresh()
end

function AFHLevelFailed:refresh( ... )
end

function AFHLevelFailed:onRetry()
	self.selectCallBack(true)
	return self:_close()
end

function AFHLevelFailed:onCancel( ... )
	self.selectCallBack(false)
	return self:_close()
end

function AFHLevelFailed:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function AFHLevelFailed:onKeyBackClicked()
	self:_close()
	return self.selectCallBack(false)
end

function AFHLevelFailed:_close()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function AFHLevelFailed:dispose( ... )
	BasePanel.dispose(self)
end

return AFHLevelFailed