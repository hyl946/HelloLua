
local AFHFromAddFriends = class(BasePanel)

function AFHFromAddFriends:create(selectCallBack)
	local panel = AFHFromAddFriends.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(selectCallBack)
	return panel
end

function AFHFromAddFriends:init(selectCallBack)
	self.ui = self:buildInterfaceGroup("AskForHelp/interface/AskForHelpFromAddFriends")
	BasePanel.init(self, self.ui)

	self.btnAddFriends = GroupButtonBase:create(self.ui:getChildByName("btnAddFriends"))
	self.btnAddFriends:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onAddFriendsBtn() end)
	self.btnAddFriends:setString("添加好友")

	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true,0,true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onKeyBackClicked() end)


	self.btnHelp = self.ui:getChildByName("btnHelp")
	if self.btnHelp then
		self.btnHelp:setTouchEnabled(true,0,true)
		self.btnHelp:setButtonMode(true)
		self.btnHelp:addEventListener(DisplayEvents.kTouchTap,function( ... )
			local desc = require 'zoo.panel.askForHelp.views.AFHDescPanel'
			desc:create():popout()
		end)
	end
	
	self:refresh()
end

function AFHFromAddFriends:refresh( ... )
end

function AFHFromAddFriends:onAddFriendsBtn( ... )
	createAddFriendPanel("recommend")
end

function AFHFromAddFriends:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function AFHFromAddFriends:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function AFHFromAddFriends:dispose( ... )
	BasePanel.dispose(self)
end

return AFHFromAddFriends