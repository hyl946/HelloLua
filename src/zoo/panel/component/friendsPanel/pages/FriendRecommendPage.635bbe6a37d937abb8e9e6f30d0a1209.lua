require 'zoo.panel.component.common.VerticalScrollable'
require 'zoo.panel.component.common.VerticalTileLayout'
require 'zoo.panel.component.common.VerticalTileItem'
require "zoo.common.DynamicLoadLayout"
require 'zoo.panel.component.friendsPanel.items.FriendRecommendItem'

local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

FriendRecommendPage = class(Layer)
local panel = nil
local kItemHeight = 166

function FriendRecommendPage:create(mainPanel, config, content, width, height)
	local instance = FriendRecommendPage.new()
	instance:init(mainPanel, config, content, width, height)
	return instance
end

function FriendRecommendPage:init(mainPanel, config, content, width, height)
	self.name = 'FriendRankingPanel'
	self.width = width
	self.height = height

	Layer.initLayer(self)
	self:setTouchEnabled(true, 0, true)

    self.pageIndex = config.pageIndex

    local listUseClipping = false
    local pagePadding = {top=0,left=0,bottom=0,right=0}
    if type(config.pagePadding) == "table" then
        pagePadding.top     = config.pagePadding.top or 0
        pagePadding.left    = config.pagePadding.left or 0
        pagePadding.bottom  = config.pagePadding.bottom or 0
        pagePadding.right   = config.pagePadding.right or 0
        listUseClipping = true
    end

    -- empty layer
    local zero = config.zero():create(width, height)
    zero.name = 'zero'
    self:addChild(zero)

    local listWidth = width - pagePadding.left - pagePadding.right
    local listHeight = height - pagePadding.top - pagePadding.bottom

    -- VerticalScrollable
    local view = VerticalScrollable:create(listWidth, listHeight, listUseClipping)
    view.name = "list"
    view:setIgnoreHorizontalMove(false)
    view:setPosition(ccp(pagePadding.left, 0-pagePadding.top))
    self:addChild(view)

	self.view = view

	local itemContainer = self:buildFriendsLayout(width, height)
	self.view:setContent(itemContainer)
	self.itemContainer = itemContainer

	self.layout = layout
    self.layer = layer
    self.items = elems
    self.zero = zero
    self.scrollable = view
	self.panel = mainPanel

	self.syncTimer = nil
	
	self.tasksWaiting = 0
	self.synchronizer = Synchronizer.new(self)

end

function FriendRecommendPage:initBottom(bottom)
	self.btnConfirm = GroupButtonBase:create(bottom:getChildByName('btnConfirm'))
	self.btnConfirm:setString("发出申请")
	self.btnConfirm:ad(DisplayEvents.kTouchTap, function(event) self:onAddConfirmBtnTap(event) end)

	self.lbRefresh = bottom:getChildByName('lbRefresh')
	self.lbRefresh:setString("刷新")

	self.lbSelectAll = bottom:getChildByName('lbSelectAll')

	self.btnSync = GroupButtonBase:create(bottom:getChildByName('btnSync'))
	self.btnSync:ad(DisplayEvents.kTouchTap, function(event) self:onNewRecommend() end)
	function self.btnSync:playSyncAnim(play)
		if play then
			self.background:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 180)))
		else
			self.background:stopAllActions()
			self.background:setRotation(0)
		end
	end
	local pos = self.btnSync.background:getPosition()
    local sz = self.btnSync.background:getContentSize()
    self.btnSync.background:setPosition(ccp(pos.x+sz.width/2, pos.y-sz.height/2))
	self.btnSync.background:setAnchorPoint(ccp(0.5, 0.5))

	self.btnSelAll = GroupButtonBase:create(bottom:getChildByName('btnSelAll'))
	self.btnSelAll:ad(DisplayEvents.kTouchTap, function(event) self:onSelectAll(event) end)

	local context = self
	function self.btnSelAll:switchFace(isSelected)
		if isSelected then
			self:setColorMode(self.colorMode, true)
			context.lbSelectAll:setString("全选")
		else
			local background = self.background
			if background and background.refCocosObj then
				background:applyAdjustColorShader()
				background:adjustColor(0, -1, 0, 0)
			end
			context.lbSelectAll:setString("未全选")
		end
	end
end

function FriendRecommendPage:playCoolDownAnimation()
	local counter = 0
	local MAX_TIME = 3
	local schedule = nil
	local function update()
		counter = counter + 1
		if self.isDisposed or counter >= MAX_TIME then
			if schedule then
				Director:sharedDirector():getScheduler():unscheduleScriptEntry(schedule)
				schedule = nil
			end

			if not self.isDisposed then
				self.lbRefresh:setString('刷新')
				self.btnSync:setEnabled(true)
			end
			return
		end
		self.lbRefresh:setString(tostring(MAX_TIME-counter))
	end
	self.btnSync:setEnabled(false)
	self.lbRefresh:setString(tostring(MAX_TIME))
	schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)			
end

function FriendRecommendPage:onNewRecommend(isAutoRefresh, showLoading)
	self.dataInited = true
	local function onSendRequest()
		local function onSuccess(evt)
			if self.isDisposed then return end
			self:setData(evt.data)
			self:refresh()
			self:playCoolDownAnimation()
			self.btnSync:playSyncAnim(false)
		end
	
		local function onError(error)
			if self.isDisposed then return end
			self:refresh()
			self.btnSync:playSyncAnim(false)
		end
	
		local http = GetRecommendFriendsHttp.new()
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onError)
		http:addEventListener(Events.kCancel, onError)

		if showLoading then
			http.timeout = 0.0001
		end

		http:load()
	end

	if not isAutoRefresh then
		PaymentNetworkCheck.getInstance():check(function ()
			onSendRequest()
		end, function ()
			CommonTip:showNetworkAlert()
		end)
		DataTracking:refreshRecommend()
	else
		onSendRequest()
	end
end

function FriendRecommendPage:onSelectAll()
	local isSelectedAll = self:isSelectedAll()
	local action = not isSelectedAll
    local uiAction = action
    if action then
		uiAction = self:canSelectAnyone()
	end
    self.btnSelAll:switchFace(uiAction)

	for k, item in pairs(self.itemContainer.viewList) do 
		if item and not item:isFinished() then
			item:setSelectedSlient(action)
		end
	end

	for k, v in pairs(self:getDatas()) do 
		if not v.isFinished then
			v.isSelected = action
		end
	end

	self.btnConfirm:setEnabled(self:hasSelectedItem())
end

function FriendRecommendPage:hasSelectedItem()
	if not self:getDatas() then return false end
	for k, v in pairs(self:getDatas()) do 
		if v.isSelected and not v.isFinished then
			return true
		end
	end
	return false
end

function FriendRecommendPage:canSelectAnyone()
	if not self:getDatas() then return false end
	if self:isFinishedAll() then return false end

	for k, v in pairs(self:getDatas()) do 
		if not v.isSelected and not v.isFinished then
			return true
		end
	end
	return false
end

function FriendRecommendPage:isSelectedAll()
	if not self:getDatas() then return false end
	if self:isFinishedAll() then return false end

	for k, v in pairs(self:getDatas()) do 
		if not v.isSelected and not v.isFinished then
			return false
		end
	end
	return true
end

function FriendRecommendPage:isFinishedAll()
	if not self:getDatas() then return false end
	for k, v in pairs(self:getDatas()) do 
		if not v.isFinished then
			return false
		end
	end
	return true
end

function FriendRecommendPage:refresh()
	self.btnSelAll:switchFace(self:isSelectedAll())
	self.btnConfirm:setEnabled(self:hasSelectedItem())

	if table.size(self.friendList or {}) > 0 then
		self.view:setVisible(true)
		self.zero:setVisible(false)
	else
		self.view:setVisible(false)
		self.zero:setVisible(true and self.dataInited)
	end
end

function FriendRecommendPage:onAddConfirmBtnTap(event)
	local isFull,noZombie = FriendsFullPanel:checkFullZombieShow()
	if isFull then
		if noZombie then
			self.panel:gotoPageIndex(1)
		end
		return
	end

	--if self:isBusy() then return end
	self.btnConfirm:setEnabled(false)

	local selectedIds = {}
	for k, v in pairs(self:getDatas()) do 
		if v.isSelected then
			table.insert(selectedIds, v.user.uid)
		end
	end

	if #selectedIds == 0 then
		self.btnConfirm:setEnabled(true) 
		return CommonTip:showTip(localize("friends.panel.Request.comfirm"), "negative") 
	end

	DataTracking:requestByRecommend(#selectedIds)
	
	local function setItemFinished(uids)
		for i=1, #uids do
			local uid = uids[i]
			for k, v in pairs(self:getItems()) do 
				if v:isPerson(uid) then
					v:setSelected(false)
					v:onAddFinished()
				end
			end
			for k, v in pairs(self:getDatas()) do 
				if v.user.uid == uid then
					v.isSelected = false
					v.isFinished = true
				end
			end
		end
	end

	local function onSendRequest(selectedIds)
		self:p()
	
		local function onSuccess(evt)
			CommonTip:showTip(localize("add.friend.panel.add.success"), "positive") 
			if self.isDisposed then return end
			self:v()
			setItemFinished(selectedIds)
			self.btnConfirm:setEnabled(true)
			self:refresh()
		end

		local function onFail(evt)
			self:v()
			if self.isDisposed then return end
			self.btnConfirm:setEnabled(true)
		end

		local function onCancel(evt)
			self:v()
			if self.isDisposed then return end
			self.btnConfirm:setEnabled(true)
		end

		local http = RequestFriendHttp.new(true)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:addEventListener(Events.kCancel, onCancel)
		http:load(nil, nil, ADD_FRIEND_SOURCE.RECOMMEND, selectedIds)		
	end

	PaymentNetworkCheck.getInstance():check(function ()
		onSendRequest(selectedIds)
	end, function ()
		self.btnConfirm:setEnabled(true)
		CommonTip:showNetworkAlert()
	end)
end

function FriendRecommendPage:onSwitchPageFinished(bottom)
	if self.isDisposed then return end
	if not self.dataInited then
		self:onNewRecommend(true, true)
	end
end

function FriendRecommendPage:onWXJPAddFriends()
	self.addFriendBtn:setEnabled(false)

	local shareCallback = {
		onSuccess=function(result)
			if self.isDisposed then return end
			self.addFriendBtn:setEnabled(true)
		end,
		onError=function(errCode, msg) 
			if self.isDisposed then return end
			self.addFriendBtn:setEnabled(true)
		end,
		onCancel=function()
			if self.isDisposed then return end
			self.addFriendBtn:setEnabled(true)
		end
	}

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendInviteMessage(shareType, shareCallback)
end

function FriendRecommendPage:hasFriendFromQQ()
	for _, friendData in pairs(self.friendList) do 
		if friendData and friendData.friendSource then
			local friendSource = AskForHelpManager.getInstance():getPlatformEnum(friendData.friendSource)
			if friendSource == kAskForHelpSnsEnum.EQQ then
				return true
			end
		end
	end
	return false
end

function FriendRecommendPage:onCancelBtnTap(event)
	if self:isBusy() then return end
	self:exitDeleteMode()
end

function FriendRecommendPage:buildFriendsLayout(viewWidth, viewHeight)
	local context = self

	local LayoutRender = class(DynamicLoadLayoutRender)
	function LayoutRender:getColumnNum()
		return 1
	end
	function LayoutRender:getItemSize()
		return {width = viewWidth, height = kItemHeight}
	end
	function LayoutRender:getVisibleHeight()
		return viewHeight
	end
	function LayoutRender:buildItemView(itemData, index)
		local data = itemData.data
		local item = nil

		item = FriendRecommendItem:create()
		item:setView(context.view)
		item:setIndex(index)
		item:setPanel(context.ui)
		item:setParentView(context.view)
		item:setFriendRankingPanel(context)
		item:setData(data)
		item:setHeight(129)
		item:refresh()

		-- add item to synchronizer
		context.synchronizer:register(item)

		local function onAfterItemTapped(notUserTap)
			if notUserTap then return end

			itemData.isExpand = not itemData.isExpand
			if itemData.isExpand then
				context.itemContainer:onItemHeightChange(itemData, item:getHeight() + 5)
			else
				context.itemContainer:onItemHeightChange(itemData, kItemHeight)
			end
			context:onAfterItemTapped()
		end
		local function onSelectStateChange(selected, idx)
			context.friendList[idx].isSelected = selected
			context:refresh()
		end
		item:setSelectStateChangeCallback(onSelectStateChange)
		item:setAfterToggleCallback(onAfterItemTapped)
		item:setBeforeToggleCallback(function(target, notUserTap) context:onBeforeItemTapped(target, itemData, notUserTap) end)

		return item
	end
	function LayoutRender:onItemViewDidAdd(itemView, itemData)
	end

	local layout = DynamicLoadLayout:create(LayoutRender.new())
  	layout:setPosition(ccp(0, 0))
  	return layout
end

function FriendRecommendPage:setData(dataProvider)
	if self:isBusy() then return end

	local function getData(dataProvider, idx)
		local ret = {user={}, profile={}}
		if not dataProvider.users[idx] then
			return ret
		end

		local user = dataProvider.users[idx]
		local profile = {}
		for k,v in pairs(dataProvider.profiles) do
			if v.uid == user.uid then
				profile = v
			end
		end
		return {user=user, profile=profile}
	end

	if dataProvider and type(dataProvider) == 'table' then
		self:p()
		self:removeAllItems()

		local provider = {}
		for i=1, #dataProvider.users do
			provider[i] = getData(dataProvider, i)
			provider[i].isSelected = true
			provider[i].isFinished = false
		end
		self.friendList = provider
		self.itemContainer:initWithDatas(self.friendList)
		self.itemContainer:__layout(false)
		self.view:updateScrollableHeight()
		self.view:updateContentViewArea()
		self.view:scrollToTop()
		self:v()
	end
end

function FriendRecommendPage:getItems()
	local items = nil
	if self.itemContainer then
		items = self.itemContainer.viewList
	end
	return items or {}
end

function FriendRecommendPage:getDatas()
	return self.friendList or {}
end

function FriendRecommendPage:onBeforeItemTapped(target, itemData, notUserTap)
end

function FriendRecommendPage:onAfterItemTapped()
	self.itemContainer:__layout()
	self.view:updateScrollableHeight()
	self.view:updateContentViewArea()

	self:refresh()
end

function FriendRecommendPage:removeAllItems()
	self.itemContainer:removeAllItems()
	self.friendList = {}
end

function FriendRecommendPage:exitDeleteMode()
end

function FriendRecommendPage:dispose()
	self.synchronizer = nil
	Layer.dispose(self)
end

function FriendRecommendPage:onCloseBtnTapped()
	if self.privateScene then
		Director:sharedDirector():popScene()
		self.allowBackKeyTap = false
		self.privateScene = nil
	end

	local dcData = {}
	dcData.category = "add_friend"
	dcData.t1 = 2
	dcData.sub_category = "friends_panel_add_button"
	DcUtil:log(AcType.kUserTrack, dcData, true)

	panel = nil

	local home = HomeScene:sharedInstance()
	if home then home:updateFriends() end
end

function FriendRecommendPage:p()
	self.tasksWaiting = self.tasksWaiting + 1
	if self:isBusy() then
		--self.enterDeleteModeBtn:setEnabled(false)
	end
end

function FriendRecommendPage:v()
	self.tasksWaiting = self.tasksWaiting - 1
	if not self:isBusy() then
		--self.enterDeleteModeBtn:setEnabled(true)
	end
end

function FriendRecommendPage:isBusy()
	return self.tasksWaiting > 0
end

function FriendRecommendPage:expandItem(index)
	self.expandItemIndex = index
end

function FriendRecommendPage:fold()
	self.expandItemIndex = nil
end

function FriendRecommendPage:getGroupBounds( ... )
    local bounds = Layer.getGroupBounds(self)  
    bounds.size = CCSizeMake(self.width,self.height)
    return bounds
end
