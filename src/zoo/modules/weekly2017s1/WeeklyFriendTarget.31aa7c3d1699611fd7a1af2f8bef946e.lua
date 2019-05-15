

local WeeklyFriendTarget = class(BaseUI)

-- friendInfo = {
-- 	uid = 123,
-- 	headUrl = "",
-- 	name = "abc"
-- 	itemNum = 10,
--  globalRank = 123 --全国排名 可能为空
--  isGlobal = true --来源于全国排行榜
-- }
function WeeklyFriendTarget:create(friendInfo)
	local target = WeeklyFriendTarget.new()
	target.friendInfo = friendInfo
	target:init()
	return target
end

function WeeklyFriendTarget:init()
	self.ui = ResourceManager:sharedInstance():buildGroup("2017_weekly_s2_target/weekly_friend_target")
	BaseUI.init(self, self.ui)

	self.ui:getChildByName('content'):setVisible(false)
	self.ui:getChildByName('label'):setVisible(false)

	local headIcon = self.ui:getChildByName("headIcon")
   	headIcon:setVisible(false)


   	self.need_dispose = {}

	self.targetDecoration = ArmatureNode:create('2018_s1_target_anim/ani_friend')
	self.targetDecoration:update(0.001)

	local bubbleIndex = self.ui:getChildIndex(self.ui:getChildByName("bubble"))
	self.ui:addChildAt(self.targetDecoration, bubbleIndex)
	self.targetDecoration:setPosition(ccp(-20, -25))
	self.targetDecoration:playByIndex(0, 0)


	--有一次头像出不来 不知原因，只有重启手机才好
	--所以无论如何先垫一个小浣熊


	


	local head = HeadImageLoader:create(self.friendInfo.uid, self.friendInfo.headUrl)
	head.name = "head"

	local headCon = self.targetDecoration:getCon('head')

	local maskedHead = Layer:create()

	local size = headCon:getContentSize()
	local sx = headCon:getScaleX()
	local sy = headCon:getScaleY()


	local headSize = CCSizeMake(100, 100)
	head:setScaleX(sx * size.width / headSize.width)
	head:setScaleY(sy * size.height / headSize.height)

	maskedHead:setPositionX(sx * size.width/2)
	maskedHead:setPositionY(sy * size.height/2)

	if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName('h0') then
		local defaultHead = Sprite:createWithSpriteFrameName('h0')
		defaultHead:setScaleX(sx * size.width / 100)
		defaultHead:setScaleY(sy * size.height / 100)
		maskedHead:addChild(defaultHead)
	end
	maskedHead:addChild(head)

	headCon:addChild(maskedHead.refCocosObj)

	table.insert(self.need_dispose, maskedHead)

	local nameLabel = TextField:create("", nil, 16)
	nameLabel:setDimensions(CCSizeMake(85, 24))
	nameLabel:setAnchorPoint(ccp(0.5, 0))
	nameLabel:setPositionX(85/2)
	nameLabel:setColor(hex2ccc3('FFFFFF'))
	nameLabel:setHorizontalAlignment(kCCTextAlignmentCenter)
	nameLabel:setPositionY(-6)

	local nickName = TextUtil:ensureTextWidth(HeDisplayUtil:urlDecode(self.friendInfo.name), nameLabel:getFontSize(), nameLabel:getDimensions())
	nameLabel:setString(nickName)

	table.insert(self.need_dispose, nameLabel)
	self.targetDecoration:getCon('name'):addChild(nameLabel.refCocosObj)

	--label
	local fntFile	= "fnt/target_amount.fnt"
	local text = BitmapText:create("", fntFile, -1, kCCTextAlignmentRight)
	text:setText(self.friendInfo.itemNum)
	text:setAnchorPoint(ccp(0.5, 0))
	if self.friendInfo.itemNum >= 1000 then 
		text:setScale(0.7)
		text:setPosition(ccp(60/2, 7))
	elseif self.friendInfo.itemNum >=100 then 
			text:setScale(0.85)
			text:setPosition(ccp(57/2+1, 4))
	else
		text:setPositionX(54/2+1)
	end
	table.insert(self.need_dispose, text)
	self.targetDecoration:getCon('label'):addChild(text.refCocosObj)


	--bubble tip
	self.canShowBubble = true
	self.bubbleUI = self.ui:getChildByName("bubble")
	local bubbleLabel = self.bubbleUI:getChildByName("label")
	local bubbleBg = self.bubbleUI:getChildByName("bg")
	if self.friendInfo.isGlobal then
		if self.friendInfo.globalRank > 0 then 
			bubbleLabel:setString(localize("2017_weeklyrace.summer.quanguo.tip", {num=self.friendInfo.globalRank}))
		else
			self.canShowBubble = false
		end
	else
		bubbleLabel:setString(localize("2017_weeklyrace.summer.friend.tip"))
	end 

	bubbleLabel:setOpacity(0)
	bubbleBg:setOpacity(0)
	self.ui:setTouchEnabled(true, 0, true)
	self.ui:addEventListener(DisplayEvents.kTouchTap, function ()
		if self.canShowBubble then 
			self.canShowBubble = false
			local parent = self:getParent()
			if parent then 
				parent:addChild(self.bubbleUI)
				local pos = self:getPosition()
				if self.bubbleUI then 
					self.bubbleUI:setPosition(ccp(pos.x, pos.y))
				end
				local arr1 = CCArray:create()
				arr1:addObject(CCFadeTo:create(0.5, 255))
				arr1:addObject(CCDelayTime:create(2))
				arr1:addObject(CCFadeTo:create(0.5, 0))
				bubbleLabel:stopAllActions()
				bubbleLabel:runAction(CCSequence:create(arr1))

				local arr2 = CCArray:create()
				arr2:addObject(CCFadeTo:create(0.5, 255))
				arr2:addObject(CCDelayTime:create(2))
				arr2:addObject(CCFadeTo:create(0.5, 0)) 
				arr2:addObject(CCCallFunc:create(function ()
					if self.bubbleUI then 
						self.bubbleUI:removeFromParentAndCleanup(false)
					end
					self.canShowBubble = true
				end))
				bubbleBg:runAction(CCSequence:create(arr2))
			end
		end
	end)

	self.bubbleUI:removeFromParentAndCleanup(false)
end

function WeeklyFriendTarget:dispose()
	BaseUI.dispose(self)

	for _, head in ipairs(self.need_dispose or {}) do
		head:dispose()
	end
	if self.bubbleUI and not self.bubbleUI.isDisposed then
		self.bubbleUI:dispose()
	end
end

function WeeklyFriendTarget:getTargetNum()
	return self.friendInfo.itemNum or 0
end

function WeeklyFriendTarget:setBubbleTipVisible(isVisible)
	if self.bubbleUI then 
		self.bubbleUI:setVisible(isVisible)
	end
	if isVisible == true then 
		self.ui:setTouchEnabled(true, 0, true)
	else
		self.ui:setTouchEnabled(false)
	end
end

function WeeklyFriendTarget:playAnim( ... )
	self.targetDecoration:playByIndex(0, 0)
end

return WeeklyFriendTarget



