local FriendsUtils = require "zoo.panel.component.friendsPanel.FriendsUtils"
local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

FriendsFullPanel = class(BasePanel)

local MAX_FRIENDS_COUNT = 300

local lastCheckResult
local MAX_ITEM_COUNT = 5

function FriendsFullPanel:checkFullZombieShow(callback)
	-- 判断该玩家是否有好友最近登录在21天以上
	if not FriendManager:getInstance():isFriendCountReachedMax() then
		local _ = callback and callback(false)
		return false
	end
	local function showFullTip()
		-- "error.tip.731014" = "您的小伙伴已经达到上限啦，清理不活跃好友后可继续添加哦~";
		CommonTip:showTip(Localization:getInstance():getText("error.tip.731014"), "negative")
	end

	local noZombie = true

	if WXJPPackageUtil.getInstance():isWXJPPackage() then
		showFullTip()
		local _ = callback and callback(true,noZombie)
		return true,noZombie
	end

	local function onCheckDataDone()
		local friends = FriendManager:getInstance().friends
		local list = {}
		if not FriendsFullPanel.expireTime then
			FriendsFullPanel.expireTime = 21*24*3600*1000
		end
		for k,v in pairs(friends) do
			if v.lastLoginTime < Localhost:time()-FriendsFullPanel.expireTime then
				local index = 0
				for ii,vv in ipairs(list) do
					if v.lastLoginTime > vv.lastLoginTime then
						index = ii
						break
					end
				end
				if index<=0 then index = #list+1 end
				table.insert(list,index,v)
			end
		end
		local function onSort(a,b)
			return a.lastLoginTime<b.lastLoginTime
		end
		noZombie = #list == 0
		if not noZombie then
			table.sort(list,onSort)
			lastCheckResult = {}
			for i,v in ipairs(list) do
				lastCheckResult[i]=v
				if i >= MAX_ITEM_COUNT then break end
			end

			FriendsFullPanel:create()
		else
			showFullTip()
		end

		local _ = callback and callback(true,noZombie)
	end	

	FriendManager:getInstance():checkFullInfo(onCheckDataDone)
	
	return true,noZombie
end


-- 297942799

local FriendsFullItem = class(require("zoo.panel.component.friendsPanel.func.ChoosePhoneItem"))


function FriendsFullItem:create(itemData, onTileItemTouch)
	local instance = FriendsFullItem.new()
	instance:loadRequiredResource(PanelConfigFiles.friends_panel)
	instance:init(itemData, onTileItemTouch)
	return instance
end

function FriendsFullItem:initUI()
	self.ui = self.builder:buildGroup('interface/FriendFullItem')
end

function FriendsFullItem:refreshUserInfo(user)
	self.canNotBeDeleted = false
	if WXJPPackageUtil.getInstance():isWXJPPackage() then
		self.canNotBeDeleted = FriendManager.getInstance():isSnsFriend(user.uid)
	end

	local level = user.topLevelId
	if not level or level == '' then 
		level = 1
	end
	local star = tonumber(user.star or 0) + tonumber(user.hideStar or 0)
	self.labelStar:setString(tostring(star))
	self.levelLabel:setText(Localization:getInstance():getText('level.number.label.txt', {level_number = level}))
	self.levelLabel:setColor(ccc3(0,102,153))
end

function FriendsFullItem:setData(data)
	self.user = data
	self.profile = data

	self:setSelected(false)

	self:refreshUserInfo(self.user)
	self:refreshProfile(self.profile)

	local str = "最后登录 999日前"
	local delta = Localhost:time()-(self.profile.lastLoginTime or 0)
	delta = delta/1000
	local hour = delta/3600
	local day = hour/24
	if day<999 then
		if day>=1 then
			str = math.floor(day) .. "日"
		elseif hour>=1 then
			str = math.floor(hour) .. "小时"
		else
			str = math.floor(delta/60) .. "分"
		end
		str = "最后登录 " .. str .. "前"
	end
	self.labelDesc:setString(str)


	local pf = AskForHelpManager:getPlatformEnum(data.friendSource or 0)
	local img = nil
	if pf == kAskForHelpSnsEnum.EWX then
		img = "wx"
	elseif pf == kAskForHelpSnsEnum.EQQ then
		img = "qq"
	elseif pf == kAskForHelpSnsEnum.EPHONE then
		img = "contact"
	end
	self.friendSource = self.ui:getChildByName("friendSource")
	self.friendSource:setVisible(img~=nil)
	if img~=nil then
		for i,v in ipairs(self.friendSource:getChildrenList()) do
			v:setVisible(v.name == img)
		end
	end
end

function FriendsFullPanel:create()
	local panel = FriendsFullPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.friends_panel)
	panel:init()
	panel:popout()
	return panel
end

function FriendsFullPanel:init()
	self.ui = self:buildInterfaceGroup("interface/FriendsFullPanel")
    BasePanel.init(self, self.ui)

    self.title = self.ui:getChildByName("title")
    -- self.title:setAnchorPoint(ccp(0.5, 0.5))
    -- self.title:setPreferredSize(286, 48)
	-- self.title:setPositionXY(324, -69)
    self.title:setString("好友已满，是否解除以下不活跃好友后继续添加?")

	self.dataProvider = lastCheckResult or {}
	for k,v in ipairs(self.dataProvider) do
        self.dataProvider[k].isSelected = true
        self.dataProvider[k].isFinished = false
	end

    self:initCloseButton()

	self.itemHeight = 120

	self.listBg = self.ui:getChildByName("content")
	self.listSize = self.listBg:getGroupBounds().size
	self.listPos = ccp(self.listBg:getPositionX(), self.listBg:getPositionY())
	self.listHeight = self.listSize.height
	self.listWidth = self.listSize.width
	-- print("self.listHeight",self.listHeight,self.listWidth)
	self.listBg:removeFromParentAndCleanup(true)

	-- self.scrollable = VerticalScrollable:create(self.listWidth, self.listHeight, true, false)
	self.content = self:createChooseFriendList( self.listWidth, self.listHeight, self.scrollable, self.itemHeight)
	self.content:setPositionXY(self.listPos.x, self.listPos.y)
	self.ui:addChild(self.content)

	-- self.scrollable:setContent(self.content)
	-- self.scrollable:setPositionXY(self.listPos.x, self.listPos.y)
	-- self.ui:addChild(self.scrollable)
	
	self:refresh()
end

function FriendsFullPanel:appendData(profile, user)
    local data = {user=user or {}, profile=profile}
    data.isSelected = true
    data.isFinished = false
    self.dataProvider[#self.dataProvider+1] = data
end

function FriendsFullPanel:unloadRequiredResource()
end


function FriendsFullPanel:refresh()
	if self.isDisposed then return end

	self.btnSelAll:switchFace(self:isAllSelected())
	self.btnConfirm:setEnabled(self:hasAnyoneSelected())
end

function FriendsFullPanel:canSelectAnyone()
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

function FriendsFullPanel:onSelectAll(event)
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

function FriendsFullPanel:isAllSelected()
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

function FriendsFullPanel:isAllFinished()
	for k,v in pairs(self:getDatas()) do
		if not v.isFinished then 
            return false 
        end
	end
	return true
end

function FriendsFullPanel:hasAnyoneSelected()
	for k,v in pairs(self:getDatas()) do
		if v.isSelected and not v.isFinished then return true end
	end
	return false
end

function FriendsFullPanel:createChooseFriendList(minWidth, minHeight, view, itemHeight)
	local container = GridLayout:create()
	container:setWidth(minWidth)
	container:setColumn(1)
	container:setItemSize(CCSizeMake(275, itemHeight))
	container:setColumnMargin(25)
	container:setRowMargin(11.8)

	for k,v in ipairs(self.dataProvider ) do
		local layoutItem = FriendsFullItem:create(v)
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

function FriendsFullPanel:appendItems(profiles, data)
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
function FriendsFullPanel:updateBGSize(profileCount)

	local rows = math.floor((profileCount+1)/2)
	local curHeight = heightList[rows]

	local bg1 = self.ui:getChildByName("bg1")
	local bg2 = self.ui:getChildByName("bg2")

	local size = bg1:getGroupBounds().size
	bg1:setPreferredSize(CCSizeMake(size.width, curHeight + 102))

	local size2 = bg2:getGroupBounds().size
	bg2:setPreferredSize(CCSizeMake(size2.width, curHeight))
end

function FriendsFullPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
		end)
	--
	self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName('btnConfirm'))
	self.btnConfirm:setString("解除好友")
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

function FriendsFullPanel:getDatas()
	return self.dataProvider or {}
end

function FriendsFullPanel:onConfirmBtnTap(event)
	self.btnConfirm:setEnabled(false)

	local selectedIds = {}
	for k, v in pairs(self:getDatas()) do 
		if v.isSelected then
			table.insert(selectedIds, v.uid)
		end
	end

	local function reset()
		if self.isDisposed then return end
		self.btnConfirm:setEnabled(true)
	end

	if #selectedIds == 0 then
		reset()
		-- 当前未选中任何玩家
		return CommonTip:showTip(localize("friends.panel.Request.comfirm"), "negative") 
	end


	local strs = table.concat(selectedIds,",")

    local function onSuccess( ... )
		-- reset(false)
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new("deleteFriendsInFriendsPanel",selectedIds))

		CommonTip:showTip("已成功解除好友关系。玩家可返回先前添加好友面板继续操作。", "positive") 

		self:onCloseBtnTapped()
    	-- self:afterDeleteFriend(selectedIds)
    end

    local function onSelectCallback(isConfirmed)
        if isConfirmed then
			local FriendInfoUtil = require 'zoo.PersonalCenter.FriendInfoUtil'
            FriendInfoUtil:req_delete(selectedIds,onSuccess,reset)
        else
        	reset()
            DataTracking:delFriend(false)
        end

	    local params = {}
	    params.category = "add_friend"
	    params.subcategory = "top_delete_confirm"
	    params.t1 = isConfirmed and 1 or 0
	    params.t2 = #selectedIds
	    DcUtil:UserTrack(params)
    end

	PaymentNetworkCheck.getInstance():check(function ()
	    local DeleteFriendAlter = require 'zoo.panel.component.friendsPanel.func.DeleteFriendAlter'
	    DeleteFriendAlter:create(onSelectCallback,#selectedIds):popout()
	end, function ()
		self.btnConfirm:setEnabled(true)
		CommonTip:showNetworkAlert()
	end)
end

function FriendsFullPanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
end

local loadFriendsLogic = require("zoo.panel.addFriend2.LoadFriendsLogic"):create()

function FriendsFullPanel:loadRemaining()
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

function FriendsFullPanel:popout()
	self:setPositionForPopoutManager()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)

	if self.scrollable then
		self.scrollable:addEventListener(ScrollableEvents.kEndMoving, function()
			-- self:loadRemaining()
		end)
	end


	-- local vSize = Director:sharedDirector():ori_getVisibleSize()
	-- local vOrigin = Director:sharedDirector():getVisibleOrigin()
	-- -- local size = self:getChildByName("bg1"):getGroupBounds().size
	-- local size = self:getGroupBounds().size
	-- self:setPositionY(vOrigin.y+size.height-vSize.height)
	-- print("size,",size.height)
end

function FriendsFullPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function FriendsFullPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end
