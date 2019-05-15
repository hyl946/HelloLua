require "zoo.panel.component.friendsRecommend.FriendRecommendBubbleItem"

FriendRecommendPanel = class(BasePanel)

local kItemHeight = 108
function FriendRecommendPanel:ctor()
end

function FriendRecommendPanel:init(friendInfo)
	self.ui = self:buildInterfaceGroup("recommendFriends/RecommendFriendPanel")
    BasePanel.init(self, self.ui)

    self.closeBtn = self.ui:getChildByName('btnClose')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)

	self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
	self.btn:addEventListener(DisplayEvents.kTouchTap, function ()
		DcUtil:UserTrack({category='add_friend', sub_category='luckyenery_receive_all'})
		self:onAllAcceptBtnTapped()
	end)
	self.btn:setString(localize("virtual.bottle.receive.all"))

	self.tip = self.ui:getChildByName("tip")
	self.tip:setString(localize("virtual.bottle.friend.request"))

	self.recommendSum = #friendInfo
	self:initContent(friendInfo)

	DcUtil:UserTrack({category='add_friend', sub_category='luckyenery_on'})
end

function FriendRecommendPanel:initContent(friendInfo)
	local pagePadding = {left = 0, top = 0}
	local listWidth = 590 + pagePadding.left * 2
	local listHeight = 720 + pagePadding.top * 2

	local view = VerticalScrollable:create(listWidth, listHeight, true)
    view.name = "list"
    view:setIgnoreHorizontalMove(false)
    view:setPosition(ccp(37, -170))
    self:addChild(view)
	self.view = view

	local layout = VerticalTileLayout:create(listWidth)
	self.view:setContent(layout)
	local elems = {}

	for i,v in ipairs(friendInfo) do
		local item = FriendRecommendBubbleItem:create()
		-- item:setPanelRef(self)
		item:setParentView(view)
		item:setData(v)
		item:setParentLayout(layout)
		item:setHeight(kItemHeight)
		table.insert(elems, item)
		item.onItemRemovedCallback = function(ctx, isBatch)
			self:onItemRemoved(ctx, isBatch)
		end
	end
    layout:setItemVerticalMargin(pagePadding.left)
    layout:addItemBatch(elems)
    view:updateScrollableHeight()
    layout:__layout()
end

function FriendRecommendPanel:onItemRemoved(item, isBatch)
	if (not self.isDisposed) and self.view then 
		local layout = self.view:getContent()
		if layout then 
			local items = layout:getItems()
			if #items == 0 then
				self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(function()
			    	self:onCloseBtnTapped()
	            end)))
			end
		end
	end
end

function FriendRecommendPanel:onAllAcceptBtnTapped()
	if self.view then 
		self.btn:setEnabled(false)

		local layout = self.view:getContent()
		if layout then 
			local items = layout:getItems()
			local _items = {}
			local _uids = {}
			for i,v in ipairs(items) do
				table.insert(_items, v)
				table.insert(_uids, v.data.uid)
			end
			local itemNum = #_items
			if itemNum > 0 then 
				local function onSuccess()
					if self.isDisposed then return end
					self.view:addEventListener(ScrollableEvents.kEndMoving, function ()
						for i,v in ipairs(_items) do
							local oriVisible = v:isVisible()
							v:setVisible(true)
							v:disableAccept()
							v:onRemoveItem(true, oriVisible)
						end
					end)

					self.view:__moveTo(self.view.bottomMostOffset, 0.1)
					self.view:setScrollEnabled(false)
				end

				local function onFail()
					if self.isDisposed then return end
					self.btn:setEnabled(true)
				end

				FriendRecommendManager.getInstance():sendAccept(_uids, onSuccess, onFail)
			end
		end
	end
end

function FriendRecommendPanel:popout()
	self.allowBackKeyTap = true
	PopoutQueue:sharedInstance():push(self, true, false)
    -- PopoutManager:sharedInstance():add(self, true, false)
end

function FriendRecommendPanel:popoutShowTransition()
	local uisize = self.ui:getGroupBounds().size
	local director = Director:sharedDirector()
    local origin = director:getVisibleOrigin()
    local size = director:getVisibleSize()
    local hr = size.height / uisize.height
    local wr = size.width / uisize.width
    if hr < 1 then
    	self:setScale((hr < wr) and hr or wr)
    end

    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
        
    self:setPosition(ccp(centerPosX, centerPosY))
end

function FriendRecommendPanel:onCloseBtnTapped()
	local leftNum = self.recommendSum
	local layout = self.view:getContent()
	if layout then 
		local items = layout:getItems()
		if items then 
			leftNum = #items
		end
	end
	local addNum = self.recommendSum - leftNum
	DcUtil:UserTrack({category='add_friend', sub_category='	luckyenery_receive_num', num = addNum})

	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

function FriendRecommendPanel:create(friendInfo)
	local panel = FriendRecommendPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.friends_panel)
    panel:init(friendInfo)
    return panel
end