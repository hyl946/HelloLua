require 'zoo.panel.component.common.VerticalScrollable'
require 'zoo.panel.component.common.VerticalTileLayout'
require 'zoo.panel.component.common.VerticalTileItem'
require "zoo.common.DynamicLoadLayout"
require 'zoo.panel.component.friendsPanel.items.FriendRankingItem'

local FriendInfoUtil = require 'zoo.PersonalCenter.FriendInfoUtil'

local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"

local SORT_STR = {"等级顺序","登录顺序","星级顺序"}
local SAVE_SORT_KEY = nil

FriendRankingPage = class(Layer)
local panel = nil
local kItemHeight = 130

local black_magic_posY = {0,0}

function FriendRankingPage:create(mainPanel, config, content, width, height)
	if not SAVE_SORT_KEY then
		SAVE_SORT_KEY = "FRIEND_SORT_KEY_"..UserManager:getInstance().user.uid
	end
	local instance = FriendRankingPage.new()
	instance:init(mainPanel, config, content, width, height)
	return instance
end

function FriendRankingPage:init(mainPanel, config, content, width, height)
	FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")
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

    black_magic_posY[1] = view:getPositionY()
    black_magic_posY[2] = black_magic_posY[1]-listHeight+kItemHeight-2

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
	
	view:setVisible(true)
    zero:setVisible(false)
	--
	self.synchronizer = Synchronizer.new(self)

	-- init
	local myself = UserManager:getInstance().user
	myself.achievement = UserManager:getInstance().achievement
	myself.lastLoginTime = UserManager:getInstance().currentLoginTime
	self.myselfData = myself

	local friends = FriendManager:getInstance().friends
	self.friendList = {}
	for k, v in pairs(friends) do
		table.insert(self.friendList, v)
	end
	self.friendCount = #self.friendList
	table.insert(self.friendList, myself)

	for k, v in pairs(self.friendList) do
		v.isExpand = false
	end

	self:updateList()

	self:initMySelfItem()

    self:scheduleUpdateWithPriority(function ( ... )
            self:update()
    end, 0)

    GlobalEventDispatcher:getInstance():addEventListener("deleteFriendsInFriendsPanel", function(event)
    	print("deleteFriendsInFriendsPanel",table.tostring(event.data))
    	self:afterDeleteFriend(event.data)
    	end)

    GlobalEventDispatcher:getInstance():addEventListener("sendEnergySuccess", function(event)
    	print("FriendRankingPage:sendEnergySuccess()")
    	self:refreshBottom()
    	end)
end

function FriendRankingPage:initMySelfItem()
	local targetItem = self.itemSelf

	local index = self.myselfIndex or table.indexOf(self.friendList,self.myselfData)
	local item = FriendRankingItem:create()
	item:setView(self.view)
	item:setIndex(index)
	item:setPanel(self)
	item:setParentView(self.view)
	item:setFriendRankingPanel(self)
	item:setData(self.myselfData)
	item:setRank(index)
	item:setHeight(119)
	item:setPositionXY(self.scrollable:getPositionX(),black_magic_posY[2])
	item.centerY = (black_magic_posY[2]+black_magic_posY[1])*0.5
    self:addChild(item)
    self.myselfItem = item
    self.myselfItem._fixPosX = item:getPositionX()

	self.itemSelf = targetItem
end

function FriendRankingPage:update()
	if self.isDisposed then return end

	if self.myselfItem then
		local targetPos = nil
		if self.myselfTarget and not self.myselfTarget.isDisposed then
		    local posBase = self.myselfTarget:getPosition()
		    local pos = self.myselfTarget:getParent():convertToWorldSpace(posBase)
		    local myPos = self.myselfItem:getParent():convertToNodeSpace(pos)
		    targetPos = myPos.y
		elseif self.myselfItem.y>self.myselfItem.centerY then
			targetPos = black_magic_posY[1]+1
		end
		if targetPos then
		    self:moveMySelfItem(targetPos)
		end
	end
end

function FriendRankingPage:moveMySelfItem(y)
    y=math.clamp(y,black_magic_posY[2],black_magic_posY[1])
    self.myselfItem:setPositionY(y)
    self.myselfItem.y = y
    if y<black_magic_posY[1] then
    	self.myselfItem:setPositionX(self.myselfItem._fixPosX)
    	self.myselfItem:setVisible(true)
    else
    	-- 隐藏时将元件移除屏幕外，防止点击事件还能响应
    	self.myselfItem:setPositionX(self.myselfItem._fixPosX-self.width)
    	self.myselfItem:setVisible(false)
    end
end

function FriendRankingPage:enableAddFriendsButton()
	if __IOS_FB then return true end
	if WXJPPackageUtil.getInstance():isWXJPPackage() then return true end
	return false
end

function FriendRankingPage:initBottom(bottom)
	self.bottom = bottom

	self.bottomNormal = CocosObject:create()
	self.bottom:addChild(self.bottomNormal)

	self.bottomDel = CocosObject:create()
	self.bottomDel:setVisible(false)
	self.bottom:addChild(self.bottomDel)

	local lbFriendTip = self.bottom:getChildByName("lbFriendTip")
	lbFriendTip:setAnchorPoint(ccp(0.5, 0.8))
	lbFriendTip:changeFntFile('fnt/addfriend1.fnt')
	lbFriendTip:setPositionX(self.width/2)
	lbFriendTip:setColor(ccc3(153,204,255))
	lbFriendTip:removeFromParentAndCleanup(false)
	self.bottomNormal:addChild(lbFriendTip)
	self.lbFriendTip = lbFriendTip

	self.energyTip = self.bottom:getChildByName("lbEnergyTip")
	self.energyTip:removeFromParentAndCleanup(false)
	self.bottomNormal:addChild(self.energyTip)

	local btnUI = bottom:getChildByName('btnAddFriends')
	self.btnAddFriends = GroupButtonBase:create(btnUI)
	self.btnAddFriends:setString("添加好友")
	self.btnAddFriends:ad(DisplayEvents.kTouchTap, function(event) self:onAddFriendsBtnTap(event) end)
	if not self:enableAddFriendsButton() then
		self.btnAddFriends:setVisible(false)
		self.btnAddFriends:setEnabled(false)
	end

	btnUI:removeFromParentAndCleanup(false)
	self.bottomNormal:addChild(btnUI)

	local function onSelectDelItem(isSelected,uid)
		local index = table.indexOf(self.selectedDel,uid)
		if isSelected then
			if not index then
				table.insert(self.selectedDel,uid)
			end
		else
			table.remove(self.selectedDel,index)
		end
		self.btnBatchDelConfirm:setEnabled(#self.selectedDel>0)

		-- print("onSelectDelItem",isSelected,uid,table.concat(self.selectedDel,","))
	end
	self.onSelectDelItem = onSelectDelItem

	local function resetBatchDel(isDelState)
		self.isDelState = isDelState
		self.bottomNormal:setVisible(not isDelState)
		self.bottomDel:setVisible(isDelState)

		self.btnBatchDelConfirm:setEnabled(isDelState)
		self.btnBatchDelCancel:setEnabled(isDelState)

		for k, v in pairs(self:getItems()) do 
			if not v:isOwner() then
				v:changeDelState(isDelState,self.onSelectDelItem)
			end
		end
	end

	local function onBatchDel()
		self.selectedDel = {}
		resetBatchDel(true)
		self.btnBatchDelConfirm:setEnabled(false)

	    local params = {}
	    params.category = "add_friend"
	    params.subcategory = "G_delete_group"
	    DcUtil:UserTrack(params)
	end

	local function onBatchDelConfirm(isConfirm)
		local strs = table.concat(self.selectedDel,",")
        print("onBatchDelConfirm()",isConfirm,strs)
		if not isConfirm then
			resetBatchDel(false)
			return
		end

	    local function onSuccess( ... )
	        print("onBatchDelConfirm()onSuccess")
			resetBatchDel(false)
	    	self:afterDeleteFriend(self.selectedDel)

			CommonTip:showTip("已成功解除好友关系", "positive")
	    end

	    local function onFail( ... )
	        print("onBatchDelConfirm()onFail()--")

	    end
	    
	    local function onSelectCallback(isConfirmed)
	        print("onBatchDelConfirm()onSelectCallback()--",isConfirmed)
	        if isConfirmed then
	            FriendInfoUtil:req_delete(self.selectedDel,onSuccess,onFail)
	        else
	            DataTracking:delFriend(false)
	        end

	    	local params = {}
		    params.category = "add_friend"
		    params.subcategory = "G_delete_confirm"
		    params.t1 = isConfirmed and 1 or 0
		    params.t2 = self.curSortIndex * (self.sortReverse and -1 or 1)
		    params.t3 = #self.selectedDel
		    DcUtil:UserTrack(params)
	    end

	    local DeleteFriendAlter = require 'zoo.panel.component.friendsPanel.func.DeleteFriendAlter'
	    local panel = DeleteFriendAlter:create(onSelectCallback,#self.selectedDel):popout()

	    -- local params = {}
	    -- params.category = "ui"
	    -- params.subcategory = "G_my_card_btn"
	    -- params.other = "t5"
	    -- DcUtil:UserTrack(params)
	end

	self.onBatchDelConfirm = onBatchDelConfirm

	local btnUI = bottom:getChildByName('btnBatchDel')
	self.btnBatchDel = GroupButtonBase:create(btnUI)
	self.btnBatchDel:setString("批量删除")
	self.btnBatchDel:ad(DisplayEvents.kTouchTap, onBatchDel)
	self.btnBatchDel:setColorMode(kGroupButtonColorMode.orange)
	btnUI:removeFromParentAndCleanup(false)
	self.bottomNormal:addChild(btnUI)

	local canDelete = FriendManager:getInstance():canDelete()
	self.btnBatchDel:setVisible(canDelete)

	local btnUI = bottom:getChildByName('btnBatchDelConfirm')
	self.btnBatchDelConfirm = GroupButtonBase:create(btnUI)
	btnUI:removeFromParentAndCleanup(false)
	self.bottomDel:addChild(btnUI)
	self.btnBatchDelConfirm:setColorMode(kGroupButtonColorMode.orange)
	self.btnBatchDelConfirm:setString("解除好友")
	self.btnBatchDelConfirm:ad(DisplayEvents.kTouchTap, function(event) onBatchDelConfirm(true) end)
	self.btnBatchDelConfirm:setEnabled(false)
	
	local btnUI = bottom:getChildByName('btnBatchDelCancel')
	self.btnBatchDelCancel = GroupButtonBase:create(btnUI)
	btnUI:removeFromParentAndCleanup(false)
	self.bottomDel:addChild(btnUI)
	self.btnBatchDelCancel:setString("返回列表")
	self.btnBatchDelCancel:ad(DisplayEvents.kTouchTap, function(event) onBatchDelConfirm(false) end)
	self.btnBatchDelCancel:setEnabled(false)
end


function FriendRankingPage:refresh()
	-- init with data
	if self.isDisposed then return end
	self:refreshBottom()
end

function FriendRankingPage:onAddFriendsBtnTap()
	if __IOS_FB then
		return SnsProxy:inviteFriends(nil)
	end

	self.btnAddFriends:setEnabled(false)

	local shareCallback = {
		onSuccess=function(result)
			if self.isDisposed then return end
			self.btnAddFriends:setEnabled(true)
		end,
		onError=function(errCode, msg) 
			if self.isDisposed then return end
			self.btnAddFriends:setEnabled(true)
		end,
		onCancel=function()
			if self.isDisposed then return end
			self.btnAddFriends:setEnabled(true)
		end
	}

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendInviteMessage(shareType, shareCallback)
end

function FriendRankingPage:hasFriendFromQQ()
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

function FriendRankingPage:afterDeleteFriend(uid)
	if self.isDisposed then return end

	self:refreshBottom()

	local list = {}
	if type(uid)=="table" then
		for i,v in ipairs(uid) do
			list[i]=tostring(v)
		end
	else
		list = {tostring(uid)}
	end

	for i,v in ipairs(list) do
		for ii,vv in ipairs(self.friendList) do
			if tostring(vv.uid) == v then
				table.remove(self.friendList,ii)
				-- break
			end
		end

		if self.selectedDel then
			for ii,vv in ipairs(self.selectedDel) do
				if tostring(vv) == v then
					table.remove(self.selectedDel,ii)
					-- break
				end
			end
		end
	end

	local waitRemove = {}
	for k, v in pairs(self:getDatas()) do
		local strUID = tostring(v.data.uid)
		local index = table.indexOf(list,strUID)
		if index and index>0 then
			table.insert(waitRemove,v)
			table.remove(list,index)
		end
		if #list == 0 then
			break
		end
	end
	print("waitRemove",#waitRemove)
	for i,v in ipairs(waitRemove) do
		print("waitRemove",i,v and v.uid)
		self.itemContainer:removeItemByData(v, false, true)
	end

	self.itemContainer:__layout(false)
	self.view:updateScrollableHeight()

	for k, v in pairs(self:getItems()) do 
		v:setRank(self:getRankIndex(k))
		if v:isOwner() then
			self.myselfItem:setRank(self:getRankIndex(k))
		end
	end

	self.friendCount = #self.friendList-1
	local canDelete = FriendManager:getInstance():canDelete()
	self.btnBatchDel:setVisible(canDelete)
end

function FriendRankingPage:onRequestDeleteFriend(uid)
	local function onDelFriend(uid)
		local selectedIds = {}
		local selectedDatas = {}

		for k, v in pairs(self:getDatas()) do 
			if v.data.uid == uid then
				table.insert(selectedIds, v.data.uid)
				table.insert(selectedDatas, v)
			end
		end

		if #selectedIds == 0 then return end
		
		local function onSuccess(data)
			DataTracking:delFriend(true)
			if self.isDisposed then return end
			self:refreshBottom()

			for k, data in pairs(selectedDatas) do
				DcUtil:delete(data.data.uid)
				self.itemContainer:removeItemByData(data, false, true)
			end
			self.itemContainer:__layout(false)

			self.view:updateScrollableHeight()

			self:exitDeleteMode()

			for k, v in pairs(self:getItems()) do 
				v:setRank(k)
			end
		end

		local function onFail(data)
			local err_code = tonumber(data.data)
			if err_code then
				local msg = Localization:getInstance():getText('error.tip.'..err_code)
				CommonTip:showTip(msg, 'negative', nil)
			end
		end

		local http = DeleteFriendHttp.new()
		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
		http:load(selectedIds)
	end

	local function onSelectCallback(isConfirmed)
		if isConfirmed then
			onDelFriend(uid)
		else
			DataTracking:delFriend(false)
		end
	end

	local DeleteFriendAlter = require 'zoo.panel.component.friendsPanel.func.DeleteFriendAlter'
	DeleteFriendAlter:create(onSelectCallback):popout()
end

function FriendRankingPage:onCancelBtnTap(event)
	self:exitDeleteMode()
end

function FriendRankingPage:buildFriendsLayout(viewWidth, viewHeight)
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
		item = FriendRankingItem:create()
		item:setView(context.view)
		item:setIndex(index)
		item:setPanel(context.ui)
		item:setParentView(context.view)
		item:setFriendRankingPanel(context)
		item:setData(data)
		local rank = context:getRankIndex(index)
		item:setRank(rank)
		local isChoose = context.selectedDel and table.indexOf(context.selectedDel,data.uid)
		item:changeDelState(context.isDelState,context.onSelectDelItem,isChoose)
		item:setHeight(119) -- hack: fix the headImage bounding box issue
		if context.isTimeSort then
			item:changeTimeSort(context.isTimeSort)
		end


		if item:isOwner() then
			context.myselfTarget = item
			context.myselfIndex = index
		end

		-- add item to synchronizer
		context.synchronizer:register(item)

		local function onAfterItemTapped(notUserTap)
			if notUserTap then return end

			itemData.data.isExpand = not itemData.data.isExpand
			if itemData.data.isExpand then
				context.itemContainer:onItemHeightChange(itemData, item:getHeight() + 5)
			else
				context.itemContainer:onItemHeightChange(itemData, kItemHeight)
			end
			context:onAfterItemTapped()
		end
		local function onSelectStateChange(selected)
			itemData.isSelected = selected
		end

		local function onDeleteFriend(uid)
			context:onRequestDeleteFriend(uid or 0)
		end

		local function onAfterDeleteFriend(uid)
			context:afterDeleteFriend(uid or 0)
		end
		--好友栏删除（已废弃）
		item:setDelFriendCallback(onDeleteFriend)
		--好友面板删除
		item:setAfterDelFriendCallback(onAfterDeleteFriend)
		item:setSelectStateChangeCallback(onSelectStateChange)
		item:setAfterToggleCallback(onAfterItemTapped)
		item:setBeforeToggleCallback(function(target, notUserTap) context:onBeforeItemTapped(target, itemData, notUserTap) end)

		return item
	end
	function LayoutRender:onItemViewDidAdd(itemView, itemData)
		if itemData.data.isExpand then
			itemView:onItemTapped(nil, true)
		end
		itemView:refresh()
	end

	local layout = DynamicLoadLayout:create(LayoutRender.new())
  	layout:setPosition(ccp(0, 0))
  	return layout
end

function FriendRankingPage:updateList()
	self.myselfTarget = nil

	self:removeAllItems()
	self.itemContainer:initWithDatas(self.friendList)
	self.view:updateScrollableHeight()
end

function FriendRankingPage:getItems()
	local items = nil
	if self.itemContainer then
		items = self.itemContainer.viewList
	end
	return items or {}
end

function FriendRankingPage:getDatas()
	local datas = nil
	if self.itemContainer then
		datas = self.itemContainer.dataList
	end
	return datas or {}
end

function FriendRankingPage:onBeforeItemTapped(target, itemData, notUserTap)
	if notUserTap then return end

	for __,v in pairs(self:getItems()) do
		if v ~= target then
			v:foldItem()
		end
	end

    local uid = itemData.data.uid
	for _, itemData in pairs(self:getDatas()) do -- 关闭其他
        if uid ~= itemData.data.uid then
		    itemData.data.isExpand = false
		    self.itemContainer:onItemHeightChange(itemData, kItemHeight)
        end
	end
end

function FriendRankingPage:onAfterItemTapped()
	self.itemContainer:__layout()
	self.view:updateScrollableHeight()
	self.view:updateContentViewArea()
end

function FriendRankingPage:removeAllItems()
	self.itemContainer:removeAllItems()
end

function FriendRankingPage:exitDeleteMode()
end

function FriendRankingPage:onSwitchPageFinished(bottom)
	if self.isDisposed then return end
	self:refreshBottom()
end

local function setRichText(textLabel, str, remain)
	local parent = textLabel:getParent()
	textLabel:setVisible(false)
	local tips = localize("friends.panel.addFriends.bottom.desc.2", {n=remain})
	local minSize = CCLabelTTF:create(tips,textLabel:getFontName(),textLabel:getFontSize()):getContentSize()

	local width = minSize.width
	local pos = textLabel:getPosition()
	local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
	
	local size = parent:getGroupBounds().size
	richText:setAnchorPoint(ccp(0.5, 1))

	richText:setPosition(ccp(size.width/2, pos.y))
	
	parent:addChildAt(richText, textLabel:getZOrder())
	return richText
end

function FriendRankingPage:refreshBottom()
	if self.isDisposed then return end

	local friendNum = FriendManager:getInstance():getFriendCount()
	local friendMaxNum = FriendManager:getInstance():getMaxFriendCount()
	local tips = string.format("好友数量 %d/%d", friendNum, friendMaxNum)  
	self.lbFriendTip:setText(tips)

	local _, remain = FreegiftManager:sharedInstance():canSendMore()

	local tips = localize("friends.panel.addFriends.bottom.desc.2", {n=remain})
	if Achievement:getRightsExtra( "SendReceiveEnergyNum" ) > 0 then
		tips = localize("friends.panel.addFriends.bottom.desc.2", {n=string.format("[#FF6600]%d[/#]",remain)})
	end
	-- print("FriendRankingPage:refreshBottom()---------remain",remain,tips)
	if self.energyTip and self.energyTip.richText then
		self.energyTip.richText:removeFromParentAndCleanup(true)
	end
	self.energyTip.richText = setRichText( self.energyTip, tips, remain)
end

function FriendRankingPage:dispose()
	GlobalEventDispatcher:getInstance():removeEventListenerByName("deleteFriendsInFriendsPanel")
	GlobalEventDispatcher:getInstance():removeEventListenerByName("sendEnergySuccess")

	self.synchronizer = nil
	Layer.dispose(self)
	--FrameLoader:unloadArmature('flash/quick_select_level', true)
end

function FriendRankingPage:onCloseBtnTapped()
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

function FriendRankingPage:expandItem(index)
	self.expandItemIndex = index
end

function FriendRankingPage:fold()
	self.expandItemIndex = nil
end

function FriendRankingPage:getGroupBounds( ... )
    local bounds = Layer.getGroupBounds(self)  
    bounds.size = CCSizeMake(self.width,self.height)
    return bounds
end

function FriendRankingPage:checkKeyBack()
	if self.isDelState then
		self.onBatchDelConfirm(false)
		return true
	end
	return false
end

-- 引导时的动画
function FriendRankingPage:refreshForGuide()
	--寻找第一个有社区中心按钮的好友
	local MIN_SCREEN_ITEM_COUNT = 5
	local targetItem = self.itemFirstCommunity
	local targetIndex = targetItem and targetItem.itemIndex

	--没有已存在的item时寻找全好友数据
	if not targetIndex then
		for k, v in ipairs(self.friendList) do
			if v.communityUser and v.uid ~= UserManager:getInstance().user.uid then
				targetIndex = k
				break
			end
		end
	end
	if not targetIndex then
		--所有好友都没有开通时候显示自己
		targetItem = self.myselfItem
		self.isSelfTargetItem = true

	elseif targetIndex>MIN_SCREEN_ITEM_COUNT then
		if targetIndex<#self.friendList-1 then
			targetIndex = targetIndex+1
		end
		targetIndex = targetIndex-MIN_SCREEN_ITEM_COUNT
		local y = targetIndex * kItemHeight
		--跳转到目标好友的位置
		self.view:gotoPositionY(y,0,nil)
		targetItem = self.itemFirstCommunity

	    self:moveMySelfItem(self.myselfItem.itemIndex * kItemHeight)
	else
		--正常范围的好友，直接显示
	end
	self.targetGuideItem = targetItem
end

function FriendRankingPage:initSortList(sortList,btnSortList,tabPos,friendsPanel)
	self.sortList = sortList
	self.btnSortList = btnSortList

	local function hideSortList()
        self.sortList:setVisible(false)
        self.frontLayer:setTouchEnabled(false)
    end

    local function setBtnOnClick(item,callback)
        item:setTouchEnabled(true,0, true,nil,true)
        -- item:setButtonMode(true)
        item:addEventListener(DisplayEvents.kTouchTap, callback)
    end

    local btn = Layer:create()
    btn.btn = self.btnSortList
    local zoder = self.btnSortList:getZOrder()
    self.btnSortList:getParent():addChildAt(btn,zoder)
    self.btnSortList:removeFromParentAndCleanup(false)
    btn:addChild(self.btnSortList)
    self.btnSortList = btn
    btn.btn:setPositionXY(tabPos.x-15,tabPos.y-15)
    setBtnOnClick(self.btnSortList,function()
        self.sortList:setVisible(true)
        self.frontLayer:setTouchEnabled(true,0, true)
    end)

    self.sortList:setVisible(false)
    self.sortList:setPositionX(self.btnSortList.btn:getPositionX()-2)
    self.sortList:removeFromParentAndCleanup(false)
    friendsPanel:addChildAt(self.sortList,20)
    self.sortListItems = {}
    for i=1,3 do
        local item = self.sortList:getChildByName("item" .. i)
        item.txt = item:getChildByName("txt")
        item.txt:setString(SORT_STR[i])
        item.bgOnReverse = item:getChildByName("bgOnReverse")
        item.bgOn = item:getChildByName("bgOn")
        item.bg = item:getChildByName("bg")
        item.index = i
        self.sortListItems[i] = item
        setBtnOnClick(item,function()
        	local index = item.index

		    if self.curSortIndex == index then
		        self.sortReverse = not self.sortReverse
		    else
		        self.sortReverse = false
		    end
		    self.curSortIndex = index

            self:onChangeSort(index)
            hideSortList()

		    local params = {}
		    params.category = "add_friend"
		    params.subcategory = "G_friend_rank"
		    params.t1 = index*(self.sortReverse and -1 or 1)
		    DcUtil:UserTrack(params)
        end)
    end
    --------sortList end


    local vSize = Director:sharedDirector():getVisibleSize()
    local vSizeOri = Director:sharedDirector():ori_getVisibleSize()
    local vOrigin = Director:sharedDirector():getVisibleOrigin()
    local pos = self:getPosition()
    local layer = LayerColor:create()
    layer:setAnchorPoint(ccp(0,0))
    layer:setOpacity(0)
    layer:setContentSize(CCSizeMake(vSizeOri.width, vSizeOri.height*1.5))
    layer:setPosition(ccp(-pos.x,(-pos.y-vSizeOri.height*0.5-vOrigin.y)))
    -- layer:setTouchEnabled(true,0, true)
    layer:addEventListener(DisplayEvents.kTouchTap, hideSortList)
    friendsPanel:addChildAt(layer,10)
    self.frontLayer = layer

    local data = CCUserDefault:sharedUserDefault():getIntegerForKey(SAVE_SORT_KEY,1)
    local index = math.floor(data*0.5)+1
    self.sortReverse = data%2==1
    self:onChangeSort(index)
end

function FriendRankingPage:onSwitchPage(isShow)
    self.sortList:setVisible(false)
    self.btnSortList:setVisible(isShow)

    self:checkKeyBack()
end

function FriendRankingPage:getRankIndex(index)
	return self.sortReverse and #self.friendList-index+1 or index
end

function FriendRankingPage:onChangeSort(index)
	self.curSortIndex = index
    for i,v in ipairs(self.sortListItems) do
        v.bgOnReverse:setVisible(i==index and self.sortReverse)
        v.bgOn:setVisible(i==index)
        v.bg:setVisible(i~=index)
        v.txt:setColor(i==index and ccc3(255, 255, 255) or ccc3(0, 102, 153))
    end
    self:changeSort(index,self.sortReverse)

    local saveData = (index-1)*2+(self.sortReverse and 1 or 0)
    CCUserDefault:sharedUserDefault():setIntegerForKey(SAVE_SORT_KEY,saveData)
    CCUserDefault:sharedUserDefault():flush()
end


-- local SORT_STR = {"等级顺序","登陆顺序","星级顺序"}
function FriendRankingPage:changeSort(index,sortReverse)
	print("FriendRankingPage:changeSort",index)
	local function getStarGlobalRank(user)
		local r = user.achievement and tonumber(user.achievement.starGlobalRank) or 0
		if r <= 0 then
			r = 0x7FFFFFFF
		end
		return r
	end

	local function sortByStarGlobalRank(u1, u2)
		local c1 = getStarGlobalRank(u1)
		local c2 = getStarGlobalRank(u2)
		return c1 < c2 , c1 == c2
	end

	local function sortByPctOfRank(u1, u2)
		local c1 = u1.achievement and tonumber(u1.achievement.pctOfRank) or 0
		local c2 = u2.achievement and tonumber(u2.achievement.pctOfRank) or 0
		return c1 > c2 , c1 == c2
	end

	local function sortByTotalStar(u1, u2)
		local c1 = u1:getTotalStar()
		local c2 = u2:getTotalStar()
		return c1 > c2 , c1 == c2
	end

	local function sortByLevel(u1, u2)
		local c1 = u1:getTopLevelId() 
		local c2 = u2:getTopLevelId()
		return c1 > c2 , c1 == c2
	end

	local function sortByLastTopLevelUpdateTime(u1, u2)
		local c1 = tonumber(u1.lastTopLevelUpdateTime or 0)
		local c2 = tonumber(u2.lastTopLevelUpdateTime or 0)
		return c1 < c2 , c1 == c2
	end

	local function sortByLastLoginTime(u1, u2)
		local c1 = tonumber(u1.lastLoginTime or 0)
		local c2 = tonumber(u2.lastLoginTime or 0)
		return c1 > c2 , c1 == c2
	end

	local function sortOnIndex(u1,u2)
		local sequence
		if index == 3 then
			-- 星级顺序
			-- 星星 > starGlobalRank >pctOfRank >关卡 >  lastTopLevelUpdateTime
			sequence = {
				sortByTotalStar,
				sortByStarGlobalRank,
				sortByPctOfRank,
				sortByLevel,
				sortByLastTopLevelUpdateTime,
			}
		elseif index == 2 then
			-- 登陆顺序
			sequence = {
				sortByLastLoginTime,
			}
		else
			-- 默认 等级顺序
			-- 关卡 > 星星 > starGlobalRank > pctOfRank > lastTopLevelUpdateTime
			sequence = {
				sortByLevel,
				sortByTotalStar,
				sortByStarGlobalRank,
				sortByPctOfRank,
				sortByLastTopLevelUpdateTime,
			}
		end

		local result,equal = nil,nil
		for i,v in ipairs(sequence) do
			result,equal = v(u1,u2)
			if not equal then return result end
		end
		return result
	end
	table.sort(self.friendList, sortOnIndex)
	if sortReverse then
		local r = {}
		for i,v in ipairs(self.friendList) do
			r[#self.friendList-i+1] = v
		end
		self.friendList = r
	end
	self:updateList()
	self.view:scrollToTop()
	self.isTimeSort = index==2
	local myRank = 0

	for k, v in pairs(self:getItems()) do 
		local rank = self:getRankIndex(k)
		v:setRank(rank)
		v:changeTimeSort(self.isTimeSort)
		if v:isOwner() then
			myRank = rank
			self.myselfItem:setRank(rank)
		end
	end
	if myRank==0 then
		myRank = self:getRankIndex(table.indexOf(self.friendList,self.myselfData))
		self.myselfItem:setRank(myRank)
	end
	self.myselfItem:changeTimeSort(self.isTimeSort)
	self:moveMySelfItem(black_magic_posY[2])
end
