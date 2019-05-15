local Feed = require('zoo.panel.askForHelp.component.Feed')

local AFHFromWeixin = class(BasePanel)
function AFHFromWeixin:create(selectCallBack)
	local panel = AFHFromWeixin.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(selectCallBack)
	return panel
end

function AFHFromWeixin:init(selectCallBack)
	self.ui = self:buildInterfaceGroup("AskForHelp/interface/AskForHelpFromWeixin")
	BasePanel.init(self, self.ui)

	self.btnWxFriend = ButtonIconsetBase:create(self.ui:getChildByName("btnFriend"))
	self.btnWxFriend:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onClkWxFriendBtn() end)
	self.btnWxFriend:setString("微信好友")
	self.btnWxFriend:setIconByFrameName("common_icon/sns/icon_wechat0000")

	self.btnWxCircle = ButtonIconsetBase:create(self.ui:getChildByName("btnCircle"))
	self.btnWxCircle:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onClkWxCircleBtn() end)
	self.btnWxCircle:setString("朋友圈")
	self.btnWxCircle:setIconByFrameName("common_icon/sns/icon_timeline0000")

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

function AFHFromWeixin:refresh( ... )

	

end

function AFHFromWeixin:onClkWxFriendBtn( ... )
	if Feed:shareDisabled() then
		return CommonTip:showTip(localize("askforhelp.sharedisabled.wxFriend"), "negative")
	end
	local userId = UserManager:getInstance().user.uid
	local topLevel = UserManager:getInstance().user:getTopLevelId()

	local function onSuccess()
		local function dummy()
			DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_request_help_wx_friend_success', t1=topLevel})
		end
		Feed:askForHelpFromWxFriend(topLevel, nil, nil, dummy, nil, nil)
	end
	
	local function onFail()
		CommonTip:showTip(localize("askforhelp.geturllink.failed"), "negative")
	end

	local http = OpNotifyHttp.new(true)
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
	http:syncLoad(OpNotifyType.kAskForHelp, topLevel)
	DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_request_help_wx_friend', t1=topLevel})
end

function AFHFromWeixin:onClkWxCircleBtn( ... )
	if Feed:shareDisabled() then
		return CommonTip:showTip(localize("askforhelp.sharedisabled.wxCircle"), "negative")
	end
	local userId = UserManager:getInstance().user.uid
	local topLevel = UserManager:getInstance().user:getTopLevelId()

	local function onSuccess()
		local function dummy() 
			DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_request_help_wx_pyq_success', t1=topLevel})
		end
		Feed:askForHelpFromWxCircle(userId, topLevel, dummy, nil, nil)
	end
	
	local function onFail()
		CommonTip:showTip(localize("askforhelp.geturllink.failed"), "negative")
	end

	local http = OpNotifyHttp.new(true)
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
	http:syncLoad(OpNotifyType.kAskForHelp, topLevel)
	DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_request_help_wx_pyq', t1=topLevel})
end

function AFHFromWeixin:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function AFHFromWeixin:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function AFHFromWeixin:dispose( ... )
	BasePanel.dispose(self)
end

return AFHFromWeixin