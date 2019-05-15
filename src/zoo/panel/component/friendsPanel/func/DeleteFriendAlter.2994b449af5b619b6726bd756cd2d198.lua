
local DeleteFriendAlter = class(BasePanel)

function DeleteFriendAlter:create(selectCallBack,count)
	local panel = DeleteFriendAlter.new()
	panel:loadRequiredResource(PanelConfigFiles.friends_panel)
	panel:init(selectCallBack,count)
	return panel
end

function DeleteFriendAlter:unloadRequiredResource( ... )
end

function DeleteFriendAlter:init(selectCallBack,count)
	self.ui = self:buildInterfaceGroup("interface/DeleteFriendAlter")
	BasePanel.init(self, self.ui)

	assert(type(selectCallBack) == "function")
	self.selectCallBack = selectCallBack

	self.btnCancel = GroupButtonBase:create(self.ui:getChildByName("btnCancel"))
	self.btnCancel:addEventListener(DisplayEvents.kTouchTap, function( ... ) self:onCancel() end)
	self.btnCancel:setString(localize("friends.panel.DeleteFriendAlter.btnCancel"))

	self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName("btnConfirm"))
	self.btnConfirm:setColorMode(kGroupButtonColorMode.orange)
	self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function( ... ) self:onConfirm() end)
	self.btnConfirm:setString(localize("friends.panel.DeleteFriendAlter.btnConfirm"))

	self.txt = self.ui:getChildByName("lbContent")
	if count then
		self.txt:setString("是否确认删除" .. tostring(count) .. "名好友？")
	else
		self.txt:setString("是否确认删除好友？")
	end

	self:refresh()
end

function DeleteFriendAlter:refresh( ... )
end

function DeleteFriendAlter:onCancel( ... )
	self.selectCallBack(false)
	return self:_close()
end

function DeleteFriendAlter:onConfirm()
	self.selectCallBack(true)
	return self:_close()
end

function DeleteFriendAlter:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function DeleteFriendAlter:onKeyBackClicked()
	self:_close()
	return self.selectCallBack(false)
end

function DeleteFriendAlter:_close()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function DeleteFriendAlter:dispose( ... )
	BasePanel.dispose(self)
end

return DeleteFriendAlter