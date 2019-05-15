
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月18日 17:36:48
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- EnlargeRestore
---------------------------------------------------

assert(not EnlargeRestore)
EnlargeRestore = class()

function EnlargeRestore:create(ui, originSize, enlargeScale, enlargeDuration, restoreDuration, ...)
	assert(ui)
	assert(enlargeScale)
	assert(enlargeDuration)
	assert(restoreDuration)
	assert(#{...} == 0)

	local originScale = ui:getScale()
	local newScale = originScale * enlargeScale

	local positionOffsetRatio = (enlargeScale - 1) / 2  
	local largeDeltaPosition = ccp(-originSize.width * positionOffsetRatio, originSize.height * positionOffsetRatio)
	local smallDeltaPosition = ccp(originSize.width * positionOffsetRatio, -originSize.height * positionOffsetRatio)

	local largeMoveAction = CCMoveBy:create(enlargeDuration, largeDeltaPosition)
	local largeScaleAction = CCScaleTo:create(enlargeDuration, newScale)
	local largeAction = CCSpawn:createWithTwoActions(largeMoveAction, largeScaleAction)
	local smallMoveAction = CCMoveBy:create(restoreDuration, smallDeltaPosition)
	local smallScaleAction = CCScaleTo:create(restoreDuration, originScale)
	local smallAction = CCSpawn:createWithTwoActions(smallMoveAction, smallScaleAction)
	local sequence = CCSequence:createWithTwoActions(largeAction, smallAction)

	return sequence
end

---------------------------------------------------
-------------- LargeRestore
---------------------------------------------------

assert(not LargeRestore)
LargeRestore = class()

function LargeRestore:create(ui, enlargeScale, restoreDuration, ...)
	assert(ui)
	assert(enlargeScale)
	assert(restoreDuration)
	assert(#{...} == 0)

	ui:setAnchorPointCenterWhileStayOrigianlPosition()

	local origScaleX	= ui:getScaleX()
	local origScaleY	= ui:getScaleY()


	local newScalX	= origScaleX * enlargeScale
	local newScalY	= origScaleY * enlargeScale

	-- Enlarge
	local enlarge	= CCScaleTo:create(0, enlargeScale)
	-- Restore To Original
	local restore	= CCScaleTo:create(restoreDuration, origScaleX, origScaleY)
	-- Sequence
	local sequence	= CCSequence:createWithTwoActions(enlarge, restore)

	return sequence
end

------------------------------------------------------
--------- Bubble Normal Action
----------------------------------------------------

BubbleNormalAction = class()

function BubbleNormalAction:create(ui, curWidth, curHeight, originalScaleX, originalScaleY, ...)
	assert(ui)
	assert(type(curWidth) == "number")
	assert(type(curHeight) == "number")
	assert(type(originalScaleX) == "number")
	assert(type(originalScaleY) == "number")
	assert(#{...} == 0)

	local animationInfo = {

		secondPerFrame = 1 / 24,

		object = {
			node = ui,
			deltaScaleX	= curWidth / 67.05,		-- Scale The The Animation Data To Match Cur Object Size
			deltaScaleY	= curHeight / 67.05,			
			originalScaleX	= originalScaleX,	-- The Base To Apply The Scale
			originalScaleY	= originalScaleY
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
