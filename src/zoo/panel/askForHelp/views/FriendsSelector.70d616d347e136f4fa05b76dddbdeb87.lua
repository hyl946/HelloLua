local Feed = require('zoo.panel.askForHelp.component.Feed')

local SelectableButton = class(EventDispatcher)
function SelectableButton:ctor(groupNode)
	self.groupNode = groupNode
end

function SelectableButton:create(buttonGroup, selected)
	local button = SelectableButton.new(buttonGroup)
	button:buildUI(selected)
	return button
end

function SelectableButton:buildUI(selected)
	self.selected = selected
	self.selectedWidget = self.groupNode:getChildByName("selected")
	self.selectedWidget:setVisible(selected)

	self.groupNode:setTouchEnabled(true)
	self.groupNode:setButtonMode(true)

	local function onTouchTap( evt )
		self:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, self, evt.globalPosition))
		GamePlayMusicPlayer:playEffect(GameMusicType.kClickCommonButton)
	end
	self.groupNode:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
end

function SelectableButton:setSelected(selected)
	if self.selected == selected then return end
	self.selected = selected
	self.selectedWidget:setVisible(self.selected)
end

function SelectableButton:getSelected()
	return self.selected
end

function SelectableButton:setEnabled(isEnabled, notChangeColor)
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setTouchEnabled(isEnabled, 0, true)
	end
end

function SelectableButton:setVisible(v)
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setVisible(v)
		self.groupNode:setTouchEnabled(v, 0, true)
	end
end

function SelectableButton:isVisible()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:isVisible()
	end
	return false
end

function SelectableButton:setString(v)
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:getChildByName("lbText"):setString(v)
	end
end

-----------------------------------------------------------------------
local FriendsSelector = class(BasePanel)
function FriendsSelector:create(dataProvider, levelId, selectCallBack, panelforhide)
	local panel = FriendsSelector.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(dataProvider, levelId, selectCallBack, panelforhide)
	return panel
end

function FriendsSelector:init(dataProvider, levelId, selectCallBack, panelforhide)
	self.cellItems = {} --对应显示render
	self.dataProvider = dataProvider or {}
	self.levelId = levelId
	self.panelforhide = panelforhide

	self.selectCallBack = selectCallBack
	self.cellWidth = 630
	self.cellHeight = 170
	self.defaultSelected = 10
	self.defaultActive = 5
	self.maxSelectNum = 10
	self.logicMaxSelectNum = 10
	self.cellItemSize = {width = 145, height = 167}

	self.hasAskedFriend = false

	self.ui = self:buildInterfaceGroup("AskForHelp/interface/AskForHelp")
	BasePanel.init(self, self.ui)

	--[[
    local cfg = AskForHelpManager.getInstance():getConfig()
	local tm = os.date("*t", cfg.endTime)
    local textTime = string.format(localize("askforhelp.friendselector.lbTime"), tm.month, tm.day)
	self.ui:getChildByName("lbTime"):setString(textTime)
	--]]

	self.btnHelp = self.ui:getChildByName("btnHelp")
	self.btnHelp:setTouchEnabled(true,0,true)
	self.btnHelp:setButtonMode(true)
	self.btnHelp:addEventListener(DisplayEvents.kTouchTap,function( ... )
		local desc = require 'zoo.panel.askForHelp.views.AFHDescPanel'
		desc:create():popout()
	end)

	self.btnWxFriend = ButtonIconsetBase:create(self.ui:getChildByName("btnFriend"))
	self.btnWxFriend:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onClkWxFriendBtn() end)
	self.btnWxFriend:setString(localize("askforhelp.friendselector.btnFriend"))
	self.btnWxFriend:setIconByFrameName("common_icon/sns/icon_player0000")

	self.btnWxCircle = ButtonIconsetBase:create(self.ui:getChildByName("btnCircle"))
	self.btnWxCircle:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onClkWxCircleBtn() end)
	self.btnWxCircle:setString(localize("askforhelp.friendselector.btnCircle"))
	self.btnWxCircle:setIconByFrameName("common_icon/sns/icon_timeline0000")

	local cellItem = self:buildInterfaceGroup("AskForHelp/interface/CellItem")
	local szItem = cellItem:getChildByName("normal"):getGroupBounds().size
	self.cellWidth, self.cellHeight = szItem.width, szItem.height
	cellItem:dispose()

	local tableViewStub = self.ui:getChildByName("tableViewStub")
	local rcStub = tableViewStub:getGroupBounds()
	self.tableView = self:buildListView(rcStub.size.width, rcStub.size.height)
	self.tableView:setPosition(rcStub.origin)
	self.ui:addChild(self.tableView)
	tableViewStub:removeFromParentAndCleanup()

	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true,0,true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnClicked() end)

	self:refresh()
end

function FriendsSelector:refresh( ... )
	for _,v in pairs(self.cellItems) do
		v:dispose()
	end
	self.cellItems = {}
	self.tableView:reloadData()
end

function FriendsSelector:buildListView(width, height)
	local tableViewRender = { setData = function () end }
	local context = self
	function tableViewRender:getContentSize(tableView,idx)
		return context:cellSize(idx)
	end
	function tableViewRender:numberOfCells()
		return context:numberOfCells()
	end
	function tableViewRender:buildCell(cell, idx)
		context:buildCell(cell,idx)
	end

	local tableView = TableView:create(tableViewRender, width, height)
	return tableView
end

function FriendsSelector:cellSize(idx)
	return CCSizeMake(self.cellWidth, self.cellHeight)
end

function FriendsSelector:numberOfCells( ... )
	return #self.dataProvider
end

function FriendsSelector:headIconLoader(uid, headIcon, headUrl)
    local headHolder = headIcon:getChildByName('holder')
    headIcon:getChildByName("mask"):setVisible(false)
	local headHolderSize = headHolder:getContentSize()
	headHolder:setAnchorPointCenterWhileStayOrigianlPosition()

    local head = headHolder:getChildByName("head")
	if head then
		head:removeFromParentAndCleanup(true)
	end
	head = HeadImageLoader:createWithFrame(uid, headUrl)
	head.name = "head"
	head:setPositionX(headHolder:getContentSize().height/2)
	head:setPositionY(headHolder:getContentSize().width/2)
	head:setScaleX(headHolder:getContentSize().width/100)
	head:setScaleY(headHolder:getContentSize().height/100)
	headHolder:addChild(head)
end

function FriendsSelector:buildCell(cell, idx)
	local index = idx + 1 -- convert to lua index
	local cellItem = self.cellItems[index]
	
	if not cellItem then
		cellItem = self:buildInterfaceGroup("AskForHelp/interface/CellItem")
		self.cellItems[index] = cellItem

		local context = self
		local dp = self.dataProvider[index]

		-- friendSource
		local function setIndex(ui, rhs, idx)
    		for i=1, rhs do
        		ui:getChildByName(tostring(i)):setVisible(i==idx)
    		end
		end

		local eFriendSource = self.dataProvider[index].friendSource
		local eSnsMode = eFriendSource >= kAskForHelpSnsEnum.EQQ
		local icons = cellItem:getChildByName("icons")
		setIndex(icons, 4, self.dataProvider[index].friendSource)

		-- lbReqFinished
		cellItem.lbReqFinished = cellItem:getChildByName("lbReqFinished")
		cellItem.lbReqFinished:setVisible(false)

		-- lbLevel
		cellItem:getChildByName("lbLevel"):setString(tostring(dp.topLevelId))

		local uid = self.dataProvider[index].uid

		-- btnRequest
		local btnRequest = GroupButtonBase:create(cellItem:getChildByName("btnRequest"))
		cellItem.btnRequest = btnRequest
		btnRequest:setString(localize("askforhelp.friendselector.btnRequest.request"))

		local snsNotify = true
		if eFriendSource < kAskForHelpSnsEnum.EQQ then
			snsNotify = false
		end

		-- SNS状态
		local function change2SnsStatus()
			btnRequest:setEnabled(true)
			btnRequest:setColorMode(kGroupButtonColorMode.blue)

			local caption = localize("askforhelp.friendselector.btnRequest.sns.qq")
			if eFriendSource == kAskForHelpSnsEnum.EWX then
				caption = localize("askforhelp.friendselector.btnRequest.sns.wx")
			end
			btnRequest:setString(caption)
		end

		local function change2FinishedStatus()
			btnRequest:setEnabled(false)
			btnRequest:setVisible(false)
			cellItem.lbReqFinished:setVisible(true)
		end

		local helpData = AskForHelpManager.getInstance():getHelpData()
		local notified = helpData:hasAskedFriend(uid)
		if notified then
			if snsNotify then 
				change2SnsStatus()
			else
				change2FinishedStatus()
			end
		end

		btnRequest:addEventListener(DisplayEvents.kTouchTap, function()
			-- snsNotify:是SNS开关（其中XXL好友需要Server发送邮件和SystemNotify; 其它情况走SNS 1：微信（手机|微信） 2：QQ(QQ)）

			cellItem.btnRequest:setEnabled(false)
			notified = helpData:hasAskedFriend(uid)	--update
			local topLevel = context.levelId

			local function onNotifySuccess()
				if eSnsMode then
					change2SnsStatus()
					CommonTip:showTip(localize("askforhelp.friendselector.btnRequest.notify.withoutSnsSelected.success"), "positive")
				else
					change2FinishedStatus()
					CommonTip:showTip(localize("askforhelp.friendselector.btnRequest.notify.success"), "positive")
				end
				context.hasAskedFriend = true
				helpData:addLevelAskedFriends(uid)
				AskForHelpManager.getInstance():addAskedLevelId()
				AskForHelpManager.getInstance():flushToStorage()
			end

			if notified then
				DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_notify', t1=topLevel, t2=uid})
				context:sendNotifyBySNS(index, eFriendSource, change2SnsStatus, change2SnsStatus)
			else
				local function onNotifyFail(evt)
					AskForHelpManager.getInstance():errorTip(evt)
					btnRequest:setEnabled(true)
				end
				context:sendNotifyByServer(index, onNotifySuccess, onNotifyFail)
				DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'choose_notify', t1=topLevel, t2=(snsNotify and 1) or 2, t3=uid})
			end
        end)

		local text = FriendManager.getInstance():getFriendName(uid)
		local headUrl = FriendManager.getInstance():getFriendHeadUrl(uid)

		if headUrl then
			local headIcon = cellItem:getChildByName("avatarCon")
			self:headIconLoader(uid, headIcon, headUrl)
		end

		local name = cellItem:getChildByName("name")
		name:setString(text)
	end
	
	cellItem.refCocosObj:removeFromParentAndCleanup(false)
	local size = cellItem:getChildByName("normal"):getBounds().size
	cellItem:setPositionX(0)
	cellItem:setPositionY(self.cellHeight/2 + size.height/2)
	cell.refCocosObj:addChild(cellItem.refCocosObj)
end

function FriendsSelector:sendNotifyByServer(idx, onSuccess, onFail) 
	local friendIds = {}
	table.insert(friendIds, self.dataProvider[idx].uid)

	local topLevel = self.levelId

	-- system notification
	local http = PushNotifyHttp.new()
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:syncLoad(friendIds, nil, LocalNotificationType.KAskForHelpReq, Localhost:time(), topLevel)
end

function FriendsSelector:sendNotifyBySNS(idx, eFriendSource, onSuccess, onFail)
	if AskForHelpManager:getInstance():shareDisabled() then
		CommonTip:showTip(localize("askforhelp.sharedisabled.sendNotifyBySNS"), "negative")
		if type(onFail) == "function" then onFail() end
		return
	end

	local uid = self.dataProvider[idx].uid
	local topLevel = self.levelId

	local eSNSType = kAskForHelpSnsEnum.EWX
	if eFriendSource == kAskForHelpSnsEnum.EQQ then
		eSNSType = kAskForHelpSnsEnum.EQQ
	end

	local function onSendSuccess()
		if eSNSType == kAskForHelpSnsEnum.EWX then
			DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_notify_wx_success', t1=topLevel, t2=uid})
		end
		if type(onSuccess) == "function" then onSuccess() end
	end

	local title = "askforhelp.share.askForHelp.snsnotify.title"
	local message = "askforhelp.share.askForHelp.snsnotify.msg"
	Feed:askForHelpFromSNS(eSNSType, topLevel, title, message, onSendSuccess, onFail, onFail)
end

function FriendsSelector:onClkWxFriendBtn( ... )
	if Feed:shareDisabled() then
		return CommonTip:showTip(localize("askforhelp.sharedisabled.wxFriend"), "negative")
	end
	local userId = UserManager:getInstance().user.uid
	local topLevel = self.levelId

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

function FriendsSelector:onClkWxCircleBtn( ... )
	if Feed:shareDisabled() then
		return CommonTip:showTip(localize("askforhelp.sharedisabled.wxCircle"), "negative")
	end
	local userId = UserManager:getInstance().user.uid
	local topLevel = self.levelId
	
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

function FriendsSelector:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

    self:scaleAccordingToResolutionConfig()

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()
	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)

	if self.panelforhide and (not self.panelforhide.isDisposed) then
		self.panelforhide:setVisible(false)
	end
end

function FriendsSelector:onCloseBtnClicked()
	self:onKeyBackClicked()
	if self.hasAskedFriend then
		NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kAskForHelp)
	end
end

function FriendsSelector:onKeyBackClicked()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function FriendsSelector:dispose( ... )
	if self.panelforhide and (not self.panelforhide.isDisposed) then
		self.panelforhide:setVisible(true)
	end

	for _,v in pairs(self.cellItems) do
		v:dispose()
	end
	BasePanel.dispose(self)
end

return FriendsSelector