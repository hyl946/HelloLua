local FriendsUtils = require "zoo.panel.component.friendsPanel.FriendsUtils"
local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

local ChoosePhoneUserPanel = class(BasePanel)
function ChoosePhoneUserPanel:create(profiles, dataProvider, closeCallback)
	local panel = ChoosePhoneUserPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.friends_panel)
	panel:init(profiles, dataProvider, closeCallback)

	return panel
end

function ChoosePhoneUserPanel:init(profiles, dp, closeCallback)
	self.ui = self:buildInterfaceGroup("interface/ChoosePhoneUserPanel")
    BasePanel.init(self, self.ui)

    self.title = self.ui:getChildByName("title")
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPreferredSize(286, 48)
    self.title:setString(localize("add.friend.panel.tag.BindPhone.btn"))

	self.closeCallback = closeCallback

	self.itemHeight = 152

	self.profiles = profiles or {}
	self.dataProvider = {}
	for k,v in ipairs(profiles) do
		self.dataProvider[k] = FriendsUtils:getData({users=dp.users or {}, profiles=profiles}, k)
        self.dataProvider[k].isSelected = true
        self.dataProvider[k].isFinished = false
	end

    self:initCloseButton()
	self:initContent()
	
	self:refresh()
end

function ChoosePhoneUserPanel:appendData(profile, user)
    local data = {user=user or {}, profile=profile}
    data.isSelected = true
    data.isFinished = false
    self.dataProvider[#self.dataProvider+1] = data
end

function ChoosePhoneUserPanel:unloadRequiredResource()
end

function ChoosePhoneUserPanel:initContent()
	self.listBg = self.ui:getChildByName("content")
	self.listSize = self.listBg:getGroupBounds().size
	self.listPos = ccp(self.listBg:getPositionX(), self.listBg:getPositionY())
	self.listHeight = self.listSize.height
	self.listWidth = self.listSize.width
	self.listBg:removeFromParentAndCleanup(true)

	self:buildGridLayout()
end

function ChoosePhoneUserPanel:refresh()
	if self.isDisposed then return end

	self.btnSelAll:switchFace(self:isAllSelected())
	self.btnConfirm:setEnabled(self:hasAnyoneSelected())
end

function ChoosePhoneUserPanel:canSelectAnyone()
	local datas =  self:getDatas()
	if table.size(datas) == 0 then return false end

    if self:isAllFinished() then return false end

	for k, v in pairs(datas) do 
		if not v.isSelected and not v.isFinished then
			return true
		end
	end
	return false
end

function ChoosePhoneUserPanel:onSelectAll(event)
	local isAllSelected = self:isAllSelected()
	local action = not isAllSelected
	local uiAction = action
	if uiAction then
		uiAction = self:canSelectAnyone()
	end
	self.btnSelAll:switchFace(uiAction)

	local items = self.content:getItems() or {}
	for k, item in pairs(items) do 
		if item and not item.finished then
			item:setSelectedSlient(action)
		end
	end

	for k, v in pairs(self:getDatas()) do 
		if not v.isFinished then
			v.isSelected = action
		end
	end
	self.btnConfirm:setEnabled(self:hasAnyoneSelected())
end

function ChoosePhoneUserPanel:isAllSelected()
	local data = self:getDatas()
	if table.size(data) == 0 then return false end

    if self:isAllFinished() then return false end

	for k,v in pairs(data) do
		if not v.isSelected and not v.isFinished then 
            return false 
        end
	end
	return true
end

function ChoosePhoneUserPanel:isAllFinished()
	for k,v in pairs(self:getDatas()) do
		if not v.isFinished then 
            return false 
        end
	end
	return true
end

function ChoosePhoneUserPanel:hasAnyoneSelected()
	for k,v in pairs(self:getDatas()) do
		if v.isSelected and not v.isFinished then return true end
	end
	return false
end

function ChoosePhoneUserPanel:createChooseFriendList(onTileItemTouch, minWidth, minHeight, view, profiles, dp, itemHeight)
	local container = GridLayout:create()
	container:setWidth(minWidth)
	container:setColumn(1)
	container:setItemSize(CCSizeMake(275, 139))
	container:setColumnMargin(25)
	container:setRowMargin(11.8)

	for k,v in ipairs(dp) do
		local layoutItem = require("zoo.panel.component.friendsPanel.func.ChoosePhoneItem"):create(dp[k], onTileItemTouch)
		layoutItem:setParentView(view)
		layoutItem:setSelected(true)
		container:addItem(layoutItem, false)

		local function onSelectStateChange(selected, index)
			self.dataProvider[index+1].isSelected = selected
			self:refresh()
		end
		layoutItem:setSelectStateChangeCallback(onSelectStateChange)
	end

	return container
end

function ChoosePhoneUserPanel:buildGridLayout()
	local function onTileItemTouch(item)
		if item then end
	end

	self.scrollable = VerticalScrollable:create(self.listWidth, self.listHeight, true, false)
	self.content = self:createChooseFriendList(onTileItemTouch, self.listWidth, self.listHeight, self.scrollable, self.profiles, self.dataProvider, self.itemHeight)

	self.scrollable:setContent(self.content)
	self.scrollable:setPositionXY(self.listPos.x + 2, self.listPos.y + 3)
	self.ui:addChild(self.scrollable)
	self.title:setPositionXY(324, -69)
end

function ChoosePhoneUserPanel:appendItems(profiles, data)
    local users = data.users or {}
	for k, v in ipairs(profiles) do
        self:appendData(v, users[k])
		local data = self.dataProvider[#self.dataProvider]
		local layoutItem = require("zoo.panel.component.friendsPanel.func.ChoosePhoneItem"):create(data, nil)
		layoutItem:setParentView(self.scrollable)
		layoutItem:setHeight(self.itemHeight)
		layoutItem:setSelected(true)
		self.content:addItem(layoutItem, false)
	end

	if self.scrollable.content then
		self.scrollable:updateScrollableHeight()
	end
end

local baseHeight = 235
local heightList = {baseHeight, baseHeight, baseHeight + 107, baseHeight + 107 *2, baseHeight + 107 *3}
function ChoosePhoneUserPanel:updateBGSize(profileCount)

	local rows = math.floor((profileCount+1)/2)
	local curHeight = heightList[rows]

	local bg1 = self.ui:getChildByName("bg1")
	local bg2 = self.ui:getChildByName("bg2")

	local size = bg1:getGroupBounds().size
	bg1:setPreferredSize(CCSizeMake(size.width, curHeight + 102))

	local size2 = bg2:getGroupBounds().size
	bg2:setPreferredSize(CCSizeMake(size2.width, curHeight))
end

function ChoosePhoneUserPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
		end)
	--
	self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName('btnConfirm'))
	self.btnConfirm:setString("发出申请")
	self.btnConfirm:ad(DisplayEvents.kTouchTap, function(event) self:onConfirmBtnTap(event) end)

	self.lbSelectAll = self.ui:getChildByName('lbSelectAll')

	self.btnSelAll = GroupButtonBase:create(self.ui:getChildByName('btnSelAll'))
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
				background:adjustColor(0,-1, 0, 0)
			end
			context.lbSelectAll:setString("未全选")
		end
	end
end

function ChoosePhoneUserPanel:getDatas()
	return self.dataProvider or {}
end

function ChoosePhoneUserPanel:onConfirmBtnTap(event)
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

	DataTracking:sendRequest2PhoneFriends()
	
	local function setItemFinished(selectedIds)
		for i=1, #selectedIds do
			local uid = selectedIds[i]
			for k, v in pairs(self.content:getItems()) do 
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
		local function onSuccess(evt)
			if self.isDisposed then return end
	
			setItemFinished(selectedIds)
			self.btnConfirm:setEnabled(true)
			self:refresh()
	
			CommonTip:showTip(localize("add.friend.panel.add.success"), "positive") 
		end
		
		local function onFail(evt)
			if self.isDisposed then return end
			self.btnConfirm:setEnabled(true)
		end
		
		local function onCancel(evt)
			if self.isDisposed then return end
			self.btnConfirm:setEnabled(true)
		end
	
		local http = RequestFriendHttp.new(true)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:addEventListener(Events.kCancel, onCancel)
		http:load(nil, nil, ADD_FRIEND_SOURCE.PHONE, selectedIds)
	end

	PaymentNetworkCheck.getInstance():check(function ()
		onSendRequest(selectedIds)
	end, function ()
		self.btnConfirm:setEnabled(true)
		CommonTip:showNetworkAlert()
	end)
end

function ChoosePhoneUserPanel:onKeyBackClicked(...)
	if type(self.closeCallback) == "function" then self.closeCallback() end
	BasePanel.onKeyBackClicked(self)
end

local loadFriendsLogic = require("zoo.panel.addFriend2.LoadFriendsLogic"):create()

function ChoosePhoneUserPanel:loadRemaining()
	local remainingUids = loadFriendsLogic:getRemainingUids()
	local function onSuccess(items4Append, users)
		self.isLoadingRemaining = false
		if self.isDisposed or #remainingUids == 0  then
			return
		end

		self:appendItems(items4Append, users)
	end

	local function onCancel()
		self.isLoadingRemaining = false
	end

	local function onError()
		self.isLoadingRemaining = false
	end
	
	if not self.isDisposed and #remainingUids > 0 and not self.isLoadingRemaining then
		loadFriendsLogic:loadProfilesByUids(remainingUids, onSuccess)
		self.isLoadingRemaining = true
	end
end

function ChoosePhoneUserPanel:popout()
	self:setPositionForPopoutManager()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)

	if self.scrollable then
		self.scrollable:addEventListener(ScrollableEvents.kEndMoving, function()
			self:loadRemaining()
		end)
	end
end

function ChoosePhoneUserPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function ChoosePhoneUserPanel:onCloseBtnTapped()
	if type(self.closeCallback) == "function" then self.closeCallback() end
	PopoutManager:sharedInstance():remove(self, true)
end

return ChoosePhoneUserPanel