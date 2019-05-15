
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月15日 13:59:52
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- HomeSceneBubbleItem
---------------------------------------------------

assert(not HomeSceneBubbleItem)
assert(BaseUI)
HomeSceneBubbleItem = class(BaseUI)

function HomeSceneBubbleItem:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	-----------------
	-- Init Base Class
	-- -------------
	BaseUI.init(self, ui)

	--------------
	-- Get UI Component
	-- -----------------
	self.placeHolder	= self.ui:getChildByName("placeHolder")
	self.bubble		= self.ui:getChildByName("bubble")

	assert(self.placeHolder)
	assert(self.bubble)

	----------------
	-- Get Data About UI
	---------------------
	self.itemPlaceholderPos		= self.placeHolder:getPosition()
	self.itemPlaceholderSize 	= self.placeHolder:getGroupBounds().size
	self.itemPlaceholderSize 	= {width = self.itemPlaceholderSize.width, height = self.itemPlaceholderSize.height}
	self.itemPlaceholderCenterPos	= ccp(self.itemPlaceholderPos.x + self.itemPlaceholderSize.width / 2,
						self.itemPlaceholderPos.y - self.itemPlaceholderSize.height / 2)

	------------------
	-- Play Bubble Anim
	-- ----------------
	self:playBubbleNormalAnimForever()
end

function HomeSceneBubbleItem:playBubbleNormalAnimForever(...)
	assert(#{...} == 0)

	self.bubble:stopAllActions()

	local bubbleAnim	= self:createBubbleAnim()
	local repeatForever	= CCRepeatForever:create(bubbleAnim)
	self.bubble:runAction(repeatForever)
end

function HomeSceneBubbleItem:getItemRes(...)
	assert(#{...} == 0)

	return self.placeHolder
end

function HomeSceneBubbleItem:playHighlightAnim(itemHighlightRes, ...)
	assert(itemHighlightRes)
	assert(#{...} == 0)

	itemHighlightRes:setAnchorPoint(ccp(0.5, 0.5))
	itemHighlightRes:setPosition(ccp(self.itemPlaceholderCenterPos.x, self.itemPlaceholderCenterPos.y))
	self.ui:addChild(itemHighlightRes)

	itemHighlightRes:setOpacity(0)

	--local fadeInTime 	= 0.25
	--local fadeOutTime	= 0.25
	local fadeInTime 	= 0.1
	local fadeOutTime	= 0.1

	-- Play Enlarge And Fade IN
	local fadeIn	= CCFadeIn:create(fadeInTime)
	local fadeOut	= CCFadeOut:create(fadeOutTime)

	local function animFinishedFunc()
		itemHighlightRes:removeFromParentAndCleanup(true)
	end
	local animFinishedAction = CCCallFunc:create(animFinishedFunc)

	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(fadeIn)
	actionArray:addObject(fadeOut)
	actionArray:addObject(animFinishedAction)

	local seq = CCSequence:create(actionArray)
	itemHighlightRes:runAction(seq)
end

function HomeSceneBubbleItem:createBubbleAnim(...)
	assert(#{...} == 0)

	-- Same In The Class BubbleItem.lua (getBubbleNormalAnim)

	local animationInfo = {

		secondPerFrame = 1 / 24,

		object = {
			node = self.bubble,
			--deltaScaleX	= 71.90 / 67.05,
			--deltaScaleY	= 71.90 / 67.05,
			deltaScaleX	= 93.40 / 67.05,
			deltaScaleY	= 93.40 / 67.05,
			originalScaleX		= 1,
			originalScaleY		= 1,
		},

		keyFrames = {
			-- 1
			{ tweenType = "normal",  x = -4.35, y = 4.40, sx = 1.089, sy = 1.089, frameIndex = 1},
			-- 2
			{ tweenType = "normal",  x = -2.60, y = 4.40, sx = 1.041, sy = 1.089, frameIndex = 11},
			-- 3
			{ tweenType = "normal",  x = -4.35, y = 2.70, sx = 1.089, sy = 1.054, frameIndex = 21},
			-- 4
			{ tweenType = "static",  x = -4.35, y = 4.40, sx = 1.089, sy = 1.089, frameIndex = 26}
		}
	}

	local bubbleAction = FlashAnimBuilder:sharedInstance():buildTimeLineAction(animationInfo)
	return bubbleAction
end

function HomeSceneBubbleItem:_createSkewingBubbleAnim(...)
	assert(#{...} == 0)

	local bubbleWidth 	= 93.40
	local bubbleHeight	= 93.40

	local animationInfo = {
		secondPerFrame	= 1 / 30,

		object = {
			node		= self.bubble,
			deltaScaleX	= 1,
			deltaScaleY	= 1,
			originalScaleX	= 1,
			originalScaleY	= 1,
		},

		keyFrames = {
			{ tweenType = "normal", frameIndex = 24, x = bubbleWidth*(1- 0.736) /2, y = -bubbleHeight*(1- 1.513)/2	, sx = 0.736,	sy = 1.513}, 
			{ tweenType = "normal", frameIndex = 28, x = bubbleWidth*(1- 1.167) /2, y = -bubbleHeight*(1- 1.167)/2	, sx = 1.167,	sy = 1.167},
			{ tweenType = "normal", frameIndex = 31, x = bubbleWidth*(1- 0.99)  /2, y = -bubbleHeight*(1- 1.379)/2	, sx = 0.99,	sy = 1.379},
			{ tweenType = "normal", frameIndex = 34, x = bubbleWidth*(1- 1.167) /2, y = -bubbleHeight*(1- 1.167)/2 	, sx = 1.167,	sy = 1.167},
			{ tweenType = "normal", frameIndex = 36, x = bubbleWidth*(1- 1.039) /2, y = -bubbleHeight*(1- 1.274)/2 	, sx = 1.039, 	sy = 1.274},
			{ tweenType = "static", frameIndex = 38, x = bubbleWidth*(1- 1.167) /2, y = -bubbleHeight*(1- 1.167)/2	, sx = 1.167,	sy = 1.167},
			{ tweenType = "delay",	frameIndex = 50}
		}
	}

	local bubbleAction = FlashAnimBuilder:sharedInstance():buildTimeLineAction(animationInfo)
	return bubbleAction
end

function HomeSceneBubbleItem:playBubbleSkewAnim(...)
	assert(#{...} == 0)

	-- Stop Previous Anim
	self.bubble:stopAllActions()

	-- Skew Anim
	local bubbleSkewAction	=  self:_createSkewingBubbleAnim()

	-- Replay Normal Anim Forever
	local function onSkewAnimFinishedFunc()
		self:playBubbleNormalAnimForever()
	end
	local onSkewAnimFinishAction = CCCallFunc:create(onSkewAnimFinishedFunc)

	-- seq
	local seq = CCSequence:createWithTwoActions(bubbleSkewAction, onSkewAnimFinishAction)

	self.bubble:runAction(seq)
end

function HomeSceneBubbleItem:create(ui, ...)
	assert(ui)
	--assert(itemRes)
	assert(#{...} == 0)

	local newHomeSceneItem = HomeSceneBubbleItem.new()
	newHomeSceneItem:init(ui)
	return newHomeSceneItem
end
