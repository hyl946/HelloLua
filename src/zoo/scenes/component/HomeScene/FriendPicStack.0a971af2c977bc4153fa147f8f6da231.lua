
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê12ÔÂ23ÈÕ 11:59:04
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com
--

require "zoo.scenes.component.HomeScene.FriendPicForStack"

---------------------------------------------------
-------------- FriendPicStack
---------------------------------------------------

FriendPicStackState = {
	FRIEND_PIC_SHOW_STATE_EXPANDED	= 1,
	FRIEND_PIC_SHOW_STATE_HIDEED	= 2,
	FRIEND_PIC_SHOW_STATE_IN_ANIMATING	= 3,
}

function checkFriendPicStackState(state, ...)
	assert(#{...} == 0)

	assert(state == FriendPicStackState.FRIEND_PIC_SHOW_STATE_EXPANDED or
		state == FriendPicStackState.FRIEND_PIC_SHOW_STATE_HIDEED)
end

assert(not FriendPicStack)
assert(Layer)
FriendPicStack = class(Layer)

function FriendPicStack:create(levelId, userPicture, ...)
	assert(type(levelId) == "number")
	assert(userPicture)
	assert(#{...} == 0)

	local newFriendPicStack = FriendPicStack.new()
	newFriendPicStack:init(levelId, userPicture)
	return newFriendPicStack
end

function FriendPicStack:dispose()
	for i, v in ipairs(self.friendPics) do
		v:dispose()
	end
	Layer.dispose(self)
end

function FriendPicStack:init(levelId, userPicture, ...)
	assert(#{...} == 0)

	-- -----------
	-- Init Base Class
	-- --------------
	Layer.initLayer(self)

	self.visibleEnabled = true

	self.clipping = SimpleClippingNode:create()
	self.clipping:setContentSize(CCSizeMake(300, 1600))
	self.clipping:setRecalcPosition(true)
	self:addChild(self.clipping)
	local sprite = Sprite:createWithSpriteFrameName("jHeadFrames_assert/yr/friend_bg_0000")
	self.bgStarBatch = SpriteBatchNode:createWithTexture(sprite:getTexture())
	self.clipping:addChild(self.bgStarBatch)
	self.starBatch = BMFontLabelBatch:create("fnt/hud.png", "fnt/hud.fnt", 220)
	self.clipping:addChild(self.starBatch)
	self.nameLayer = Layer:create()
	self.clipping:addChild(self.nameLayer)
	self.btnLayer = Layer:create()
	self.clipping:addChild(self.btnLayer)
	self.infoLayer = Layer:create()
	self.clipping:addChild(self.infoLayer)
	local picLayer = Layer:create()
	self:addChild(picLayer)
	local sprite2 = Sprite:createWithSpriteFrameName("jHeadFrames_assert/yr/friend_bg_0000")
	self.picBgBatch = SpriteBatchNode:createWithTexture(sprite2:getTexture())
	self.picBgBatch:setContentSize(sprite2:getContentSize())
	self.touchLayer = Layer:create()
	self.touchLayer:setContentSize(sprite2:getContentSize())
	self.touchLayer:setPositionX(-sprite2:getContentSize().width/2)
	self.touchLayer:setTouchEnabled(true)
	picLayer:addChild(self.touchLayer)
	self.headLayer = Layer:create()
	picLayer:addChild(self.headLayer)
	picLayer:addChild(self.picBgBatch)
	self.picTopBatch = SpriteBatchNode:createWithTexture(sprite:getTexture())
	self.picTopBatch:setVisible(false)
	picLayer:addChild(self.picTopBatch)

	sprite:dispose()
	sprite2:dispose()

	self.bottomPicLayer = Layer:create()
	self.bottomBGLayer = Layer:create()
	picLayer:addChild(self.bottomPicLayer)
	picLayer:addChild(self.bottomBGLayer)


	----------
	-- Data
	-- --------
	self.levelId 		= levelId
	self.userPicture	= userPicture

	-- Added Friend Pic
	self.friendPics = {}

	self.FRIEND_PIC_SHOW_STATE_EXPANDED	= FriendPicStackState.FRIEND_PIC_SHOW_STATE_EXPANDED
	self.FRIEND_PIC_SHOW_STATE_HIDEED	= FriendPicStackState.FRIEND_PIC_SHOW_STATE_HIDEED

	self.friendPicShowState			= self.FRIEND_PIC_SHOW_STATE_HIDEED
	self.clipping:setVisible(false)
end

function FriendPicStack:isHitted(worldPos, ...)
	assert(worldPos)
	assert(#{...} == 0)

	if self.friendPicShowState == FriendPicStackState.FRIEND_PIC_SHOW_STATE_EXPANDED then
		return self:hitTestPoint(worldPos, true)

	elseif self.friendPicShowState == FriendPicStackState.FRIEND_PIC_SHOW_STATE_HIDEED then
		return self.touchLayer:hitTestPoint(worldPos, true)
	end
end

function FriendPicStack:getShowState(...)
	assert(#{...} == 0)

	return self.friendPicShowState
end

function FriendPicStack:onTapped(...)
	assert(#{...} == 0)
	if (not self.touchEnabled) or not self.refCocosObj then 
		return false
	end

	----------------------------------
	-- Check If Conflict With Top Level
	-- -----------------------------
	local topLevel = UserManager:getInstance().user:getTopLevelId()

	if self.friendPicShowState == self.FRIEND_PIC_SHOW_STATE_EXPANDED then
		self.friendPicShowState	= self.FRIEND_PIC_SHOW_STATE_IN_ANIMATING

		-- Stop Previous Action
		self:stopAllActions()

		local function onAnimFinish()
			self.friendPicShowState = self.FRIEND_PIC_SHOW_STATE_HIDEED
			if self.expanHideCallback then self.expanHideCallback(self, FriendPicStackState.FRIEND_PIC_SHOW_STATE_HIDEED) end
		end

		self:playHideFriendPicsAnim(onAnimFinish)

	elseif self.friendPicShowState == self.FRIEND_PIC_SHOW_STATE_HIDEED then
		self.friendPicShowState	= self.FRIEND_PIC_SHOW_STATE_IN_ANIMATING
		

		-- Stop Previosu
		self:stopAllActions()
		

		-- Position Self To Top
		local selfParent = self:getParent()
		self:removeFromParentAndCleanup(false)
		selfParent:addChild(self)

		local function onAnimFinish()
			self.friendPicShowState = self.FRIEND_PIC_SHOW_STATE_EXPANDED
		end

		local next_state = self.FRIEND_PIC_SHOW_STATE_EXPANDED

		if topLevel == self.levelId then
			-------------------------------------------
			-- 为了美观，如果好友在区域最后一关，并且跟自己的头像在一起
			-- 那么就隐藏好友头像
			local visible = (self.levelId % 15 ~= 0)
			if visible then
				self:playExpandFriendPicsAnim(onAnimFinish, true)
				-- ---------------------
				-- Position User Picture TOp
				-- ----------------------------
				local userPictureParent = self.userPicture:getParent()
				self.userPicture:removeFromParentAndCleanup(false)
				userPictureParent:addChild(self.userPicture)
			else
				self.friendPicShowState = self.FRIEND_PIC_SHOW_STATE_HIDEED
				next_state = self.FRIEND_PIC_SHOW_STATE_HIDEED
			end

		elseif HomeSceneButtonsManager:getInstance():getRewardBtnPosLevelId() == self.levelId then
			local button = HomeScene:sharedInstance().starRewardButton
			self:playExpandFriendPicsAnim(onAnimFinish, button ~= nil)
			if button then
				local layer = button:getParent()
				button:removeFromParentAndCleanup(false)
				layer:addChild(button)
			end
		elseif HomeSceneButtonsManager:getInstance():getInviteButtonLevelId() == self.levelId then
			local button = HomeScene:sharedInstance().inviteFriendBtn
			self:playExpandFriendPicsAnim(onAnimFinish, button ~= nil)
			if button then
				local layer = button:getParent()
				button:removeFromParentAndCleanup(false)
				layer:addChild(button)
			end
		else
			self:playExpandFriendPicsAnim(onAnimFinish, false)
		end
		if self.expanHideCallback then self.expanHideCallback(self, next_state) end

	elseif self.friendPicShowState == self.FRIEND_PIC_SHOW_STATE_IN_ANIMATING then
		-- Do  Nothing
	else
		assert(false)
	end
		
end

function FriendPicStack:checkActivityHeadFrame( ... )
	local friendPic = self.friendPics[#(self.friendPics)]
	
	if not friendPic then
		return
	end
	if not friendPic.isActivityFrame then
		return
	end

	if friendPic:isActivityFrame() then
		CommonTip:showTip(friendPic:getActivityFrameTip(), 'positive')
	end
end

function FriendPicStack:addFriendId(friendId, ...)
	assert(type(friendId) == "number")
	assert(#{...} == 0)
	
	local friendPic = self:getFriendPicById(friendId)

	if friendPic then
		friendPic.cleanFlag = false
	else
		local newFriendPic = FriendPicForStack:create(friendId)
		newFriendPic.cleanFlag = false

		-- Add To Self
		newFriendPic:addToStack(self)
		
		self:onInsertFriendPic(newFriendPic)

		table.insert(self.friendPics, newFriendPic)
		-- Re Position All FriendPicture
		self:repositionFriendPics()
	end
end

function FriendPicStack:addHelpId(profile)
	local helpPic = self:getFriendPicById(tonumber(profile.uid))

	if helpPic then
		helpPic.cleanFlag = false
	else
		local newFriendPic = FriendPicForStack:create(tonumber(profile.uid), profile, UserPictureType.HELP)
		newFriendPic.cleanFlag = false

		-- Add To Self
		newFriendPic:addToStack(self)
		
		self:onInsertFriendPic(newFriendPic)

		table.insert(self.friendPics, newFriendPic)
		-- Re Position All FriendPicture
		self:repositionFriendPics()
	end
end

function FriendPicStack:removeFriendId(friendId, ...)
	assert(type(friendId) == "number")
	assert(#{...} == 0)

	--if not self.friendPics[friendId] then
	--	return
	local friendPic 	= self:getFriendPicById(friendId)
	local friendPicIndex	= self:getFriendPicIndexById(friendId)

	if not friendPic then
		return
	else
		self:onRemoveFriendPic(friendPic, friendPicIndex)
		friendPic:removeFromStack(true)
		friendPic:dispose()
		table.remove(self.friendPics, friendPicIndex)
	end
end

function FriendPicStack:onInsertFriendPic(friendPic)
	if #(self.friendPics) >= 1 then
		local lastOne = self.friendPics[#(self.friendPics)]
		if lastOne and (not lastOne.isDisposed) then
			lastOne:revertBgAndPicToBatchNode(self)
		end
	end
	if friendPic and (not friendPic.isDisposed) then
		friendPic:removeBgAndPicFromBatchNode(self)
	end
end

function FriendPicStack:onRemoveFriendPic(friendPic, friendPicIndex)
	if friendPicIndex == #(self.friendPics) then
		friendPic:revertBgAndPicToBatchNode(self)

		local newLastOne = self.friendPics[friendPicIndex - 1]
		if newLastOne and (not newLastOne.isDisposed) then
			newLastOne:removeBgAndPicFromBatchNode(self)
		end
	end
end

function FriendPicStack:setExpanHideCallback(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.expanHideCallback = callback
end

function FriendPicStack:getLevelId(...)
	assert(#{...} == 0)

	return self.levelId
end

function FriendPicStack:getFriendPicById(id, ...)
	assert(type(id) == "number")
	assert(#{...} == 0)

	for k,v in pairs(self.friendPics) do

		if v:getFriendId() == id then
			return v
		end
	end
end

function FriendPicStack:getFriendPicIndexById(id, ...)
	assert(type(id) == "number")
	assert(#{...} == 0)

	for k,v in pairs(self.friendPics) do
		if v:getFriendId() == id then
			return k
		end
	end
end

function FriendPicStack:repositionFriendPics()
	local length = #self.friendPics
	for i, v in ipairs(self.friendPics) do
		v:reposition(length - i + 1)
	end
end

function FriendPicStack:playExpandFriendPicsAnim(animFinishCallback, expandOneExtra, ...)
	if _G.isLocalDevelopMode then printx(0, "FriendPicStack:playExpandFriendPicsAnim") end
	self.clipping:setVisible(true)
	local length, count = #self.friendPics, #self.friendPics
	for i, v in ipairs(self.friendPics) do
		local function onAnimFinish()
			count = count - 1
			if count == 0 then
				if animFinishCallback then animFinishCallback() end
			end
		end
		if expandOneExtra then
			v:playShowNameAndStarAnim(length - i + 2, onAnimFinish)
		else
			v:playShowNameAndStarAnim(length - i + 1, onAnimFinish)
		end
	end

	self:checkActivityHeadFrame()
end

function FriendPicStack:playHideFriendPicsAnim(animFinishCallback, ...)
	if _G.isLocalDevelopMode then printx(0, "FriendPicStack:playHideFriendPicsAnim") end
	local length, count = #self.friendPics, #self.friendPics
	for i, v in ipairs(self.friendPics) do
		local function onAnimFinish()
			count = count - 1
			if count == 0 then
				self.clipping:setVisible(false)
				if animFinishCallback then animFinishCallback() end
			end
		end
		v:playHideNameAndStarAnim(length - i + 1, onAnimFinish)
	end
end

function FriendPicStack:setFriendPicsCleanFlag(...)
	assert(#{...} == 0)

	for k,v in pairs(self.friendPics) do
		v.cleanFlag = true
	end
end

function FriendPicStack:cleanFriendPicsBasedOnCleanFlag(...)
	assert(#{...} == 0)

	for k,v in pairs(self.friendPics) do
		if v.cleanFlag then
			self:removeFriendId(v:getFriendId())
		end
	end
end

function FriendPicStack:getLayerList()
	return {
		clipping = self.clipping,
		bgAndStar = self.bgStarBatch,
		star = self.starBatch,
		name = self.nameLayer,
		btn = self.btnLayer,
		info = self.infoLayer,
		picBg = self.picBgBatch,
		head = self.headLayer,
		picTop = self.picTopBatch,
		bottomPic = self.bottomPicLayer,
		bottomBG = self.bottomBGLayer,
	}
end

function FriendPicStack:setVisible( ... )
	if self.visibleEnabled then
		Layer.setVisible(self, ...)
	end
end

function FriendPicStack:setVisibleEnabled( b )
	self.visibleEnabled = b
end