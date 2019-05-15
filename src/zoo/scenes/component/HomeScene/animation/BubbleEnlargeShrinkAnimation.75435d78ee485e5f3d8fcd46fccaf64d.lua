

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 20:59:56
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com
--

---------------------------------------------------
-------------- BubbleEnlargeShrinkAnimation
---------------------------------------------------

assert(not BubbleEnlargeShrinkAnimation)
BubbleEnlargeShrinkAnimation = class()

function BubbleEnlargeShrinkAnimation:ctor()
end

function BubbleEnlargeShrinkAnimation:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)


	self.ui = ui

	local curScaleX	= ui:getScaleX()
	local curScaleY	= ui:getScaleY()

	local shrinkScale	= 0.95 
	local enlargeScale	= 1.05

	self.shrinkScaleX	= curScaleX * shrinkScale
	self.shrinkScaleY	= curScaleY * shrinkScale
	self.enlargeScaleX	= curScaleX * enlargeScale
	self.enlargeScaleY	= curScaleY * enlargeScale
end


function BubbleEnlargeShrinkAnimation:setBubbleVisible(visible, ...)
	assert(type(visible) == "boolean")
	assert(#{...} == 0)

	if visible then
		self.ui:setVisible(true)
		--self:playEnlargeShrinkAnim()
	else
		self.ui:setVisible(false)
		--self.ui:stopAllActions()
	end
end

function BubbleEnlargeShrinkAnimation:getShrinkToZeroAnim( ...)
	assert(#{...} == 0)

	---- Action Finish Callback
	--local function actionFinishCallback()
	--end
	--local finishCallback = CCCallFunc:create(actionFinishCallback)
	
	-- Stop Previous Action
	local function stopPrevious()
		self.ui:stopAllActions()
	end
	local stopPreviousAction = CCCallFunc:create(stopPrevious)

	--  Scale To Zero
	local scaleAction = CCScaleTo:create(0.1, 0.1, 0.1)
	-- Fade Out
	local fadeOut	= CCFadeOut:create(0.3)
	-- Spawn
	local spawn = CCSpawn:createWithTwoActions(scaleAction, fadeOut)

	local seq = CCSequence:createWithTwoActions(stopPreviousAction, spawn)
	local targetSeq = CCTargetedAction:create(self.ui.refCocosObj, seq)

	--return spawn
	return targetSeq
end

function BubbleEnlargeShrinkAnimation:playEnlargeShrinkAnim(...)
	assert(#{...} == 0)

	self.ui:stopAllActions()

	self.ui:setVisible(true)

	he_log_warning("Change Anhor Point May Result Other Sprite's Positon 1")
	self.ui:setAnchorPointCenterWhileStayOrigianlPosition(ccp(0.5, 0.5))

	local shrinkXEnlargeY	= self:getShrinkXEnlargeYAnim()
	local enlargeXShrinkY	= self:getEnlargeXShrinkYAnim()

	local seq = CCSequence:createWithTwoActions(shrinkXEnlargeY, enlargeXShrinkY)
	local repeate = CCRepeatForever:create(seq)

	self.ui:runAction(repeate)
end

function BubbleEnlargeShrinkAnimation:getShrinkXEnlargeYAnim(...)
	assert(#{...} == 0)

	-- Set Initial Scale
	-- Enlarged X
	-- Shrinked Y
	local function setInitialScale()
		self.ui:setScaleX(self.enlargeScaleX)
		self.ui:setScaleY(self.shrinkScaleY)
	end
	local setInitialScaleAction = CCCallFunc:create(setInitialScale)

	-- Shrink X
	-- Enlarge Y
	-- Ease In Out
	local shrinkAction	 = CCScaleTo:create(0.5, self.shrinkScaleX, self.enlargeScaleY)
	local easeInOut		= CCEaseSineInOut:create(shrinkAction)

	local seq = CCSequence:createWithTwoActions(setInitialScaleAction, easeInOut)
	return seq
end

function BubbleEnlargeShrinkAnimation:getEnlargeXShrinkYAnim(...)
	assert(#{...} == 0)

	-- Set Initial Scale
	-- Shrinked X
	-- Enlarged Y
	local function setInitialScale()
		self.ui:setScaleX(self.shrinkScaleX)
		self.ui:setScaleY(self.enlargeScaleY)
	end
	local setInitialScaleAction = CCCallFunc:create(setInitialScale)

	-- Enlarge X
	-- Shrink Y
	-- Ease In Out
	local enlargeAction	 = CCScaleTo:create(0.5, self.enlargeScaleX, self.shrinkScaleY)
	local easeInOut		= CCEaseSineInOut:create(enlargeAction)

	local seq = CCSequence:createWithTwoActions(setInitialScaleAction, easeInOut)

	return seq
end


---	shrink and enlarge a CCNode , based on CCScaleTo actions.
--	typical used in animate a bubble
--	@param ui the CocosObject, to operate on
function BubbleEnlargeShrinkAnimation:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newBubbleEnlargeShrinkAnimation = BubbleEnlargeShrinkAnimation.new()
	newBubbleEnlargeShrinkAnimation:init(ui)
	return newBubbleEnlargeShrinkAnimation
end
