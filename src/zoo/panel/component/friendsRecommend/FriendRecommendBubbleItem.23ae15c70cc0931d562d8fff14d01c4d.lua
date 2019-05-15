require 'zoo.panel.component.common.LayoutItem'

FriendRecommendBubbleItem = class(ItemInClippingNode)

local COLOR_LABLE_BLUE = ccc3(0,102,153)

function FriendRecommendBubbleItem:ctor()
end

function FriendRecommendBubbleItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function FriendRecommendBubbleItem:init()
	ItemInClippingNode.init(self)
	local ui = self.builder:buildGroup("recommendFriends/RecommendFriendItem")

	self.avatar = ui:getChildByName('avatar')
	self.nameLabel = ui:getChildByName('labelName')

	-- self.sex0 = ui:getChildByName("sex0")
	-- self.sex1 = ui:getChildByName("sex1")
	-- self.sex2 = ui:getChildByName("sex2")

	self.levelLabel = ui:getChildByName('levelLabel')
	self.levelLabel:setAnchorPoint(ccp(0.5, 0.5))
	local pos = self.levelLabel:getPosition()
	self.levelLabel:setPosition(ccp(pos.x + 60, pos.y - 19))

	self.tip = ui:getChildByName("labelRank")
	self.tip:setString(localize("virtual.bottle.receive"))

	self.acceptBtn = ui:getChildByName("sendBtn")
	self.acceptBtn:setTouchEnabled(true, 0 , true)
	self.acceptBtn:setButtonMode(true)
	self.acceptBtn:ad(DisplayEvents.kTouchTap, function ()
		DcUtil:UserTrack({category='add_friend', sub_category='luckyenery_receive'})
		self:onAcceptBtnTapped(true)
	end)

	self:setContent(ui)
	self.ui = ui


    ui:setTouchEnabled(true, 0, false)
    ui:ad(DisplayEvents.kTouchBegin, function(event)
        self.lastTouchPos = event.globalPosition
    end)
    ui:ad(DisplayEvents.kTouchEnd, function(event,x,y)
        if self.lastTouchPos then
            local distance = ccpDistance(self.lastTouchPos, event.globalPosition)
            if distance<10 then
                local uid = self.data.uid
                require("zoo.PersonalCenter.FriendInfoPanel"):create(uid)
                local dcKey = uid==UserManager:getInstance().uid and 0 or FriendManager.getInstance():getFriendInfo(uid) and 1 or 2
                DcUtil:UserTrack({category='ui', sub_category="G_my_card_click ",t1="3",t2=1}, true)
            end
        end
    end)
end

function FriendRecommendBubbleItem:onAcceptBtnTapped(showItemFly)
	self:disableAccept()
	local function onSuccess()
		if self.isDisposed then return end
		self:onAcceptSuccess(showItemFly)
	end

	local function onFail()
		if self.isDisposed then return end
		self:onAcceptFail()
		self:enableAccept()
	end
	FriendRecommendManager.getInstance():sendAccept({self.data.uid}, onSuccess, onFail)
end

function FriendRecommendBubbleItem:onAcceptSuccess(showItemFly)
	self:onRemoveItem(false, showItemFly)
end

function FriendRecommendBubbleItem:onAcceptFail()
end

function FriendRecommendBubbleItem:onRemoveItem(isBatch, showItemFly)
    if self.isDisposed then return end

    function endCallback()
    	if self.onItemRemovedCallback then self.onItemRemovedCallback(self, isBatch) end
    end

    local fadeOutTime = 0.3
    if isBatch then
        if not self:isVisible() then
            endCallback()
            self.parentLayout:removeItemAt(self.arrayIndex)
        else
            self.ui:runAction(CCSequence:createWithTwoActions(
		        CCDelayTime:create(0.15 * self.arrayIndex),
		        CCCallFunc:create(function(...)
		        	if showItemFly then self:flyItem() end
                    self:fadeOut(fadeOutTime, endCallback)
                    self.parentLayout:removeItemAt(self.arrayIndex, true)
                end)
                )
            )
        end
    else
        self.ui:runAction(CCSequence:createWithTwoActions(
		    CCDelayTime:create(0.2),
		    CCCallFunc:create(function(...)
		    	if showItemFly then self:flyItem() end
                self:fadeOut(fadeOutTime, endCallback)
                self.parentLayout:removeItemAt(self.arrayIndex, true)
            end)
        ))
    end
end

function FriendRecommendBubbleItem:flyItem()
    local pos = self.acceptBtn:getPosition()
    local rPos = {x = pos.x - 55, y = pos.y + 45}
    local worldPos = self.ui:convertToWorldSpace(ccp(rPos.x, rPos.y))

    local reward = {itemId = 10012, num = 1}
	local anim = FlyItemsAnimation:create({reward})
	anim:setWorldPosition(ccp(worldPos.x, worldPos.y))
	anim:play()
end

function FriendRecommendBubbleItem:fadeOut(fadeOutTime, onFinish)
	local childrenList = self.ui:getChildrenList()
	for i, v in ipairs(childrenList) do
        local fadeOut = CCFadeOut:create(fadeOutTime)
        v:setCascadeOpacityEnabled(true)
        v:runAction(fadeOut)
	end

    if self.currentHead then
        self.currentHead:runAction(CCFadeOut:create(fadeOutTime))
    end

    if type(onFinish) == "function" then
        self.ui:runAction(CCSequence:createWithTwoActions(
		    CCDelayTime:create(fadeOutTime),
            CCCallFunc:create(function() onFinish(self) end)
            )
        )
    end
end

function FriendRecommendBubbleItem:setData(data)
	self.data = table.clone(data)

	local level = data.topLevelId
	if not level or level == '' then 
		level = 1
	end
	self.levelLabel:setColor(COLOR_LABLE_BLUE)
	self.levelLabel:setText(localize('level.number.label.txt', {level_number = level}))

	local username = nameDecode(data.name or '')
	if string.isEmpty(username) then 
		username = 'ID: '..data.uid
	end

	local nickName = TextUtil:ensureTextWidth(username, self.nameLabel:getFontSize(), self.nameLabel:getDimensions())
	if nickName then 
		self.nameLabel:setString(nickName) 
	else
		self.nameLabel:setString(username) 
	end
	
	local headUrl = data.headUrl
	if string.isEmpty(headUrl) then
		headUrl = 1
	end
	self:changePlayerHead(tonumber(data.uid), headUrl, data.profile)

	-- local sex = data.sex or 0
	-- for i=1,3 do
	-- 	local sexId = i - 1
	-- 	self["sex"..sexId]:setVisible(sexId == sex)
	-- end
end

function FriendRecommendBubbleItem:changePlayerHead(uid, headUrl, _profile)
	local function onImageLoadFinishCallback(head)
		if self.isDisposed then return end ---  prevent from crashes
		local headHolder = self.avatar:getChildByName('holder')
		local pos = headHolder:getPosition()
		local headHolderSize = headHolder:getContentSize()
		local tarWidth = headHolderSize.width * headHolder:getScaleX()
		local realWidth = head:getContentSize().width
		local scale = tarWidth / realWidth
		head:setPositionXY(pos.x + tarWidth/2, pos.y - tarWidth/2)
		head:setScale(scale)
		if self.currentHead then
			self.currentHead:removeFromParentAndCleanup(true)
			self.currentHead:dispose()
			self.currentHead = head
		else
			self.currentHead = head
		end
		headHolder:setVisible(false)
		self.avatar:addChildAt(head, 0)
	end

	local head = HeadImageLoader:createWithFrame(uid, headUrl, nil, nil, _profile)
	onImageLoadFinishCallback(head)
end


function FriendRecommendBubbleItem:enableAccept()
	if self.isDisposed then return end
	self.acceptBtn:setVisible(true)
	self.acceptBtn:setTouchEnabled(true, 0, true)
	self.acceptBtn:setButtonMode(true)
end

function FriendRecommendBubbleItem:disableAccept()
	if self.isDisposed then return end
	self.acceptBtn:setVisible(false)
	self.acceptBtn:setTouchEnabled(false)
	self.acceptBtn:setButtonMode(false)
end

function FriendRecommendBubbleItem:setParentLayout(parentLayout)
	self.parentLayout = parentLayout
end

function FriendRecommendBubbleItem:create()
	local instance = FriendRecommendBubbleItem.new()
	instance:loadRequiredResource(PanelConfigFiles.friends_panel)
	instance:init()
	return instance
end