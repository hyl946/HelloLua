
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê12ÔÂ23ÈÕ 11:50:50
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- FriendPicForStack
---------------------------------------------------

FriendPicForStack = class()

FriendPicForStackAnimDirection = {
	LEFT	= 1,
	RIGHT	= 2
}

UserPictureType = {
	NORMAL	= 1,
	HELP	= 2,
	ACTIVITY = 99
}

-- FriendPicForStackStaticInit = false
local function checkFriendPicForStackAnimDirection(direction, ...)
	assert(direction)
	assert(#{...} == 0)

	assert(direction == FriendPicForStackAnimDirection.LEFT or
		direction == FriendPicForStackAnimDirection.RIGHT)
end

function FriendPicForStack:create(friendId, friendInfo, userPictureType)
	assert(type(friendId) == "number")

	local newFriendPicForStack = FriendPicForStack.new()
	newFriendPicForStack:init(friendId, friendInfo, userPictureType)
	return newFriendPicForStack
end

function FriendPicForStack:dispose()
	self.ui:dispose()
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end
	-- G_TEST = 0
function FriendPicForStack:init(friendId, friendInfo, userPictureType)
	assert(type(friendId) == "number")

	-- if (not FriendPicForStackStaticInit) then
	-- 	ResourceManager:sharedInstance():addJsonFile("flash/scenes/homeScene/homeScene.json")
	-- 	FriendPicForStackGroup =  ResourceManager:sharedInstance():buildGroup("friendPictureForStack")
	-- 	FriendPicForStackStaticInit = true
	-- end
	-------------
	-- Data
	-- -------
	self.friendId	= friendId
	self.friendRef	= FriendManager.getInstance().friends[tostring(self.friendId)]
	if friendInfo ~= nil then self.friendRef = friendInfo end

	self.userPictureType = userPictureType
	if self.userPictureType == nil then self.userPictureType = UserPictureType.NORMAL end

	assert(self.friendRef)

	local resName = "jHeadUI/friend"
	self.ui = ResourceManager:sharedInstance():buildGroup(resName)
	if self.userPictureType == UserPictureType.NORMAL then
		self.totalStar = tonumber(self.friendRef.star) + tonumber(self.friendRef.hideStar)
	else
		self.totalStar = 0
	end
	local name = nameDecode(self.friendRef.name)
	if name == nil or name == "" then name = self.friendRef.uid end
	self.name	= name

	self.SHOW_STATE_HIDDED	= 1
	self.SHOW_STATE_SHOWED	= 2
	self.HIDDEN_DELTA = 4
	self.SHOW_DELTA = 99
	self.showState		= self.SHOW_STATE_HIDDED

	-------------------
	-- Get UI Resource
	-- -----------------
	self.iconBg = self.ui:getChildByName("iconBg") 
	self.iconBg:removeFromParentAndCleanup(true)

	self.defaultPic = self.ui:getChildByName("defaultPic")
	self.picTop = self.ui:getChildByName("top")
	self.picTop:setVisible(false)
	self.nameLabel = self.ui:getChildByName("nameLabel")
	self.infoLabel = self.ui:getChildByName("infoLabel")
	self.starIcon = self.ui:getChildByName("starIcon")
	self.starNumberLabel = self.ui:getChildByName("starNumberLabel")
	self.rightBg = self.ui:getChildByName("rightBg")

	self.size = self.rightBg:getContentSize()
	self.size = {width = self.size.width, height = self.size.height}
	self.rightBgOriginX = self.rightBg:getPositionX()

	self.rightBg:setPositionX(self.rightBgOriginX - self.size.width)
	self.starIcon:setPositionX(self.starIcon:getPositionX() - self.size.width)
	self.nameLabel:setPositionX(self.nameLabel:getPositionX() - self.size.width)

	self.infoLabel:setPositionX(self.infoLabel:getPositionX() - self.size.width)
	self.showInfoButton = self.userPictureType == UserPictureType.NORMAL

	if self.userPictureType == UserPictureType.NORMAL then
		self.nameLabel:setString(self.name)
	else
		self.infoLabel:setString("好友:" .. self.name)
		self.nameLabel:setString(localize("askforhelp.head.text"))
	end
	self.starNumberLabel:setPositionX(self.starNumberLabel:getPositionX() - self.size.width)
	self.starNumberLabel:setString(self.totalStar)

	local framePos = self.defaultPic:getPosition()
	
	local frameSize = self.defaultPic:getGroupBounds(self.ui).size
	frameSize = {width = frameSize.width, height = frameSize.height}
	local function onImageLoadFinishCallback(clipping)
		if not self.defaultPic or self.defaultPic.isDisposed then return end
		local clippingSize = clipping:getContentSize()
		clipping:setScaleX(frameSize.width / clippingSize.width)
		clipping:setScaleY(frameSize.height / clippingSize.height)
		clipping:setPositionXY(self.defaultPic:getPositionX() + frameSize.width / 2, self.defaultPic:getPositionY() - frameSize.height / 2)
		clipping:setVisible(self.defaultPic:isVisible())
		self.defaultPic:getParent():addChild(clipping)
		self.defaultPic:removeFromParentAndCleanup(true)
		self.defaultPic = clipping
	end
	-- @Peng for test 
	local head = HeadImageLoader:createWithFrame(self.friendRef.uid, self.friendRef.headUrl, nil, 2)
	onImageLoadFinishCallback(head)
		-- G_TEST = G_TEST + (os.clock() - start)
	-- if _G.isLocalDevelopMode then printx(0, "soga use time: ", G_TEST) end


	--180907 我的名片优化，隐藏好友详细信息
    local builder = InterfaceBuilder:createWithContentsOfFile("ui/common_ui.json")
    local btnUI = builder:buildGroup("ui_buttons_new/btn_text")
    -- btnUI:setContentSize(CCSize(100,50))
    btnUI:setScale(0.35)
    -- btnUI:setScaleY(0.45)

    local tmpBtn = GroupButtonBase:create(btnUI)
    tmpBtn:setString("查看")
    tmpBtn:setPosition(ccp(20,50))
    tmpBtn:ad(DisplayEvents.kTouchTap, function () 
    	if not self.isShow then return end
		require("zoo.PersonalCenter.FriendInfoPanel"):create(self.friendId)
    end)
    self.btnInfo = tmpBtn
    self.ui:addChild(btnUI)
	self.btnInfo:setEnabled(false)

	self.hideForInfoList = {self.starIcon,self.infoLabel,self.starNumberLabel,self.starNumberConcreteLabel}
	--180907 我的名片优化，隐藏好友详细信息  end

	self.isShow = false
	self.picTop.baseY = self.picTop:getPositionY()
end

function FriendPicForStack:getFriendId(...)
	assert(#{...} == 0)

	return self.friendId
end

function FriendPicForStack:getFriendIconSize(...)
	assert(#{...} == 0)

	local size = self.friendIcon:getGroupBounds().size
	size = {width = size.width, height = size.height}
	return size
end

function FriendPicForStack:setNameAndStarHide(...)
	assert(#{...} == 0)
	self.friendNameAndStar:setPositionX(self.friendNameAndStarRightHidePosX)
end

function FriendPicForStack:getExpandedWidth(...)
	assert(#{...} == 0)

	return self.friendNameAndStarResInitPosX + self.friendNameAndStarWidth
end

-- return {
-- 		clipping = self.clipping,
-- 		bgAndStar = self.bgStarBatch,
-- 		star = self.starBatch,
-- 		name = self.nameLayer,
-- 		picBg = self.picBgBatch,
-- 		head = self.headLayer,
-- 	}

function FriendPicForStack:addToStack(stack)
	local list = stack:getLayerList()
	if not list then return end

	self.defaultPic:removeFromParentAndCleanup(false)
	list.head:addChild(self.defaultPic)
	list.head:setVisible(false)  -- @Peng Test 

	self.picTop:removeFromParentAndCleanup(false)
	list.picTop:addChild(self.picTop)
	self.rightBg:removeFromParentAndCleanup(false)
	list.bgAndStar:addChild(self.rightBg)
	self.starIcon:removeFromParentAndCleanup(false)
	self.nameLabel:removeFromParentAndCleanup(false)
	list.name:addChild(self.nameLabel)

	self.btnInfo.groupNode:removeFromParentAndCleanup(false)
	list.btn:addChild(self.btnInfo.groupNode)

	self.infoLabel:removeFromParentAndCleanup(false)
	self.starNumberConcreteLabel = list.star:createLabel(self.starNumberLabel:getString())
	self.starNumberConcreteLabel:setAnchorPoint(ccp(0, 1))
	local tSize = self.starNumberLabel:getDimensions()
	local size = self.starNumberConcreteLabel:getContentSize()
	self.starNumberLabel:setScale(tSize.height / size.height)
	self.starNumberConcreteLabel:setPositionX(self.starNumberLabel:getPositionX() + (tSize.width - size.width * self.starNumberConcreteLabel:getScale()) / 2)
	self.starNumberConcreteLabel:setPositionY(self.starNumberLabel:getPositionY() + 1 - (tSize.height - size.height * self.starNumberConcreteLabel:getScale()) / 2)
	if self.userPictureType == UserPictureType.NORMAL then 
		list.bgAndStar:addChild(self.starIcon)
		list.star:addChild(self.starNumberConcreteLabel)
	else
		list.info:addChild(self.infoLabel)
	end
end

function FriendPicForStack:removeFromStack(stack)
	self.defaultPic:removeFromParentAndCleanup(false)
	self.ui:addChild(self.defaultPic)
	self.picTop:removeFromParentAndCleanup(false)
	self.ui:addChild(self.picTop)
	self.rightBg:removeFromParentAndCleanup(false)
	self.ui:addChild(self.rightBg)
	self.starIcon:removeFromParentAndCleanup(false)
	self.nameLabel:removeFromParentAndCleanup(false)
	self.ui:addChild(self.nameLabel)
	self.btnInfo.groupNode:removeFromParentAndCleanup(false)
	self.ui:addChild(self.btnInfo.groupNode)

	self.infoLabel:removeFromParentAndCleanup(false)
	self.starNumberConcreteLabel:removeFromParentAndCleanup(true)
	if self.userPictureType == UserPictureType.NORMAL then 
		self.ui:addChild(self.starIcon)
	else
		self.ui:addChild(self.infoLabel)
	end
end

function FriendPicForStack:removeBgAndPicFromBatchNode( stack )
	local list = stack:getLayerList()

	self.defaultPic:removeFromParentAndCleanup(false)

	list.bottomPic:addChild(self.defaultPic)
end

function FriendPicForStack:revertBgAndPicToBatchNode( stack )
	local list = stack:getLayerList()

	self.defaultPic:removeFromParentAndCleanup(false)
	list.head:addChild(self.defaultPic)
end

function FriendPicForStack:refreshInfoVisible()
	for i,v in ipairs(self.hideForInfoList) do
		v:setVisible(not self.showInfoButton)
	end
	self.btnInfo:setVisible(self.showInfoButton)
end

function FriendPicForStack:reposition(indexFromBottom)
	local originDelta = self.picTop:getPositionY() - self.picTop.baseY

	local delta = self.HIDDEN_DELTA
	if self.showState == self.SHOW_STATE_SHOWED then
		delta = self.SHOW_DELTA
	end
	if indexFromBottom <= 4 then
		self.defaultPic:setPositionY(self.defaultPic:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.defaultPic:setVisible(indexFromBottom <= 1)
		self.picTop:setPositionY(self.picTop:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.picTop:setVisible(true)
		self.rightBg:setPositionY(self.rightBg:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.rightBg:setVisible(true)
		self.starIcon:setPositionY(self.starIcon:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.starIcon:setVisible(true)
		self.nameLabel:setPositionY(self.nameLabel:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.nameLabel:setVisible(true)
		self.starNumberConcreteLabel:setPositionY(self.starNumberConcreteLabel:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.starNumberConcreteLabel:setVisible(true)
		self.infoLabel:setPositionY(self.infoLabel:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.infoLabel:setVisible(true)

		self.btnInfo:setPositionY(self.btnInfo:getPositionY() - originDelta + (indexFromBottom - 1) * delta)
		self.btnInfo:setVisible(true)

		self:refreshInfoVisible()
	else
		self.defaultPic:setPositionY(self.defaultPic:getPositionY() - originDelta + 4 * delta)
		self.defaultPic:setVisible(false)
		self.picTop:setPositionY(self.picTop:getPositionY() - originDelta + 4 * delta)
		self.picTop:setVisible(false)
		self.rightBg:setPositionY(self.rightBg:getPositionY() - originDelta + 4 * delta)
		self.rightBg:setVisible(false)
		self.starIcon:setPositionY(self.starIcon:getPositionY() - originDelta + 4 * delta)
		self.starIcon:setVisible(false)
		self.nameLabel:setPositionY(self.nameLabel:getPositionY() - originDelta + 4 * delta)
		self.nameLabel:setVisible(false)
		self.starNumberConcreteLabel:setPositionY(self.starNumberConcreteLabel:getPositionY() - originDelta + 4 * delta)
		self.starNumberConcreteLabel:setVisible(false)
		self.infoLabel:setPositionY(self.infoLabel:getPositionY() - originDelta + 4 * delta)
		self.infoLabel:setVisible(false)

		self.btnInfo:setPositionY(self.btnInfo:getPositionY() - originDelta + 4 * delta)
		self.btnInfo:setVisible(false)
	end
end

function FriendPicForStack:playHideNameAndStarAnim(index, animFinishCallback)
	local originDelta = self.picTop:getPositionY() - self.picTop.baseY
	self.defaultPic:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.2, ccp(self.defaultPic:getPositionX(),
		self.defaultPic:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)), CCCallFunc:create(function()
			self.defaultPic:setVisible(index <= 1)
			self.picTop:setVisible(index <= 4)
			self.rightBg:setVisible(index <= 4)
			self.nameLabel:setVisible(index <= 4)
			self.starNumberConcreteLabel:setVisible(index <= 4)
			self.starIcon:setVisible(index <= 4)
			self.infoLabel:setVisible(index <= 4)

			if animFinishCallback then animFinishCallback() end

			self:refreshInfoVisible()
		end)))

	self.picTop:runAction(CCMoveTo:create(0.2, ccp(self.picTop:getPositionX(),
		self.picTop:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))
	self.rightBg:runAction(CCMoveTo:create(0.2, ccp(self.rightBg:getPositionX() - self.size.width,
		self.rightBg:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))
	self.starIcon:runAction(CCMoveTo:create(0.2, ccp(self.starIcon:getPositionX() - self.size.width,
		self.starIcon:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))
	self.nameLabel:runAction(CCMoveTo:create(0.2, ccp(self.nameLabel:getPositionX() - self.size.width,
		self.nameLabel:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))
	self.infoLabel:runAction(CCMoveTo:create(0.2, ccp(self.infoLabel:getPositionX() - self.size.width,
		self.infoLabel:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))
	self.starNumberConcreteLabel:runAction(CCMoveTo:create(0.2, ccp(self.starNumberConcreteLabel:getPositionX() - self.size.width,
		self.starNumberConcreteLabel:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))

	self.btnInfo.groupNode:runAction(CCMoveTo:create(0.2, ccp(-30,
		self.btnInfo:getPositionY() - originDelta + (index <= 4 and index - 1 or 4) * self.HIDDEN_DELTA)))

	self.defaultPic:setVisible(true)
	self.picTop:setVisible(true)
	self.rightBg:setVisible(true)
	self.nameLabel:setVisible(true)
	self.starNumberConcreteLabel:setVisible(true)
	self.starIcon:setVisible(true)
	self.infoLabel:setVisible(true)

	self.isShow = false
	self.btnInfo:setVisible(true)
	self.btnInfo:setEnabled(false)

	self:refreshInfoVisible()	
end

function FriendPicForStack:playShowNameAndStarAnim(index, animFinishCallback)
	local originDelta = self.picTop:getPositionY() - self.picTop.baseY
	local arr = CCArray:create()
	arr:addObject(CCMoveTo:create(0.2, ccp(self.defaultPic:getPositionX(),
		self.defaultPic:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)))
	arr:addObject(CCDelayTime:create(0.1))
	arr:addObject(CCCallFunc:create(function()
			self.defaultPic:setVisible(index < 16)
			self.picTop:setVisible(index < 16)
			self.rightBg:setVisible(index < 16)
			self.nameLabel:setVisible(index < 16)
			self.starNumberConcreteLabel:setVisible(index < 16)
			self.starIcon:setVisible(index < 16)
			self.infoLabel:setVisible(index < 16)
			-- self.infoLabel:setVisible(index < 16)

			if animFinishCallback then animFinishCallback() end

			self:refreshInfoVisible()
		end))
	self.defaultPic:runAction(CCSequence:create(arr))

	self.picTop:runAction(CCMoveTo:create(0.2, ccp(self.picTop:getPositionX(),
		self.picTop:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)))
	self.rightBg:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.2, ccp(self.rightBg:getPositionX(),
		self.rightBg:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)),
		CCMoveTo:create(0.1, ccp(self.rightBg:getPositionX() + self.size.width,
		self.rightBg:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA))))
	self.starIcon:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.2, ccp(self.starIcon:getPositionX(),
		self.starIcon:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)),
		CCMoveTo:create(0.1, ccp(self.starIcon:getPositionX() + self.size.width,
		self.starIcon:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA))))
	self.nameLabel:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.2, ccp(self.nameLabel:getPositionX(),
		self.nameLabel:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)),
		CCMoveTo:create(0.1, ccp(self.nameLabel:getPositionX() + self.size.width,
		self.nameLabel:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA))))
	self.infoLabel:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.2, ccp(self.infoLabel:getPositionX(),
		self.infoLabel:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)),
		CCMoveTo:create(0.1, ccp(self.infoLabel:getPositionX() + self.size.width,
		self.infoLabel:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA))))
	self.starNumberConcreteLabel:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.2, ccp(self.starNumberConcreteLabel:getPositionX(),
		self.starNumberConcreteLabel:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)),
		CCMoveTo:create(0.1, ccp(self.starNumberConcreteLabel:getPositionX() + self.size.width,
		self.starNumberConcreteLabel:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA))))

	self.btnInfo.groupNode:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(0.2, ccp(20,
		self.btnInfo:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA)),
		CCMoveTo:create(0.1, ccp(110,
		self.btnInfo:getPositionY() - originDelta + (index - 1) * self.SHOW_DELTA))))
	
	
	self.defaultPic:setVisible(true)
	self.picTop:setVisible(true)
	self.rightBg:setVisible(true)
	self.nameLabel:setVisible(true)
	self.starNumberConcreteLabel:setVisible(true)
	self.starIcon:setVisible(true)
	self.infoLabel:setVisible(true)

	self.isShow = true
	self.btnInfo:setEnabled(true)

	self:refreshInfoVisible()	
end

function FriendPicForStack:isActivityFrame(  )
	return self.isActivityHeadFrame and self.friendRef and table.exist({11, 12, 13}, tonumber(self.friendRef.headFrame or 0) or 0)
end

function FriendPicForStack:getActivityFrameTip( ... )
	if self:isActivityFrame() then
		if tonumber(self.friendRef.headFrame) == 11 then
			return '参与十一活动并升级技能至4级获得'
		elseif tonumber(self.friendRef.headFrame) == 12 then
			return '参与十一活动并升级技能至3级获得'
		elseif tonumber(self.friendRef.headFrame) == 13 then
			return '参与十一活动并升级技能至2级获得'
		end
	end
	return ''
end