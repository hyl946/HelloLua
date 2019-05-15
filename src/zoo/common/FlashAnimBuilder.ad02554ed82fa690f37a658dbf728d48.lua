
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月30日 13:21:51
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

function interpolate(value1, value2, ratio, ...)
	assert(type(value1) == "number")
	assert(type(value2) == "number")
	assert(type(ratio) == "number")
	assert(#{...} == 0)

	return value1 + (value2 - value1) * ratio
end

---------------------------------------------------
-------------- FlashAnimBuilder
---------------------------------------------------

local sharedInstance = false

assert(not FlashAnimBuilder)
FlashAnimBuilder = class()

function FlashAnimBuilder:ctor()
end

function FlashAnimBuilder:init(...)
	assert(#{...} == 0)
end

function FlashAnimBuilder:buildTimeLineAction(animationInfo, ...)
	assert(type(animationInfo) == "table")
	assert(#{...} == 0)

	--------------------------------
	--	Exanple animationInfo Format
	-----------------------------------
	--local animationInfo = {
	--
	--	secondPerFrame = 1 / 24, 
	--
	--	object	= {
	--		node	= self.bubble,
	--		deltaScaleX	= 2.0,		-- Scale The The Animation Data To Match Cur Object Size
	--		deltaScaleY	= 2.0
	--		originalScaleX	= 61.55,	-- The Base To Apply The Scale
	--		originalScaleY	= 61.55
	--	},
	--
	--	keyFrames = {
	--		{ tweenType = "normal", x = -4.35, y = -4.35, sx = 1.089 , sy = 1.089, frameIndex = 1 },
	--		{ tweenType = "delay", frameIndex = 11}
	--		{ tweenType = "perFrame" , x = 11, y = 22, sx = 1, sy = 2, frameIndex = 2}|
	--		{ tweenType = "static", x = 11, y = 11, sx = 1, sy = 1, frameIndex = 1 }
	--	}
	--}

	-- --------------------------
	-- Check animationInfo Format
	-- ---------------------------
	assert(type(animationInfo.secondPerFrame) 	== "number")
	assert(type(animationInfo.object)		== "table")
	assert(type(animationInfo.object.node)		== "table")

	assert(type(animationInfo.object.deltaScaleX)	== "number")
	assert(type(animationInfo.object.deltaScaleY)	== "number")
	assert(type(animationInfo.object.originalScaleX) == "number")
	assert(type(animationInfo.object.originalScaleY) == "number")

	assert(type(animationInfo.keyFrames)		== "table")

	for index = 1, #animationInfo.keyFrames do
		self:checkTweenType(animationInfo.keyFrames[index])
	end

	---------------------------
	-- Create The Animation 
	-- ------------------------
	local actionArray = CCArray:create()

	local nodeToControl			= animationInfo.object.node

	local keyFrames = animationInfo.keyFrames
	
	for index = 1,#keyFrames do

		local curKeyFrame 	= keyFrames[index]
		local nextKeyFrame	= keyFrames[index + 1]

		if curKeyFrame.tweenType == "delay" then

			local delayAction = self:buildDelayTween(animationInfo, curKeyFrame, nextKeyFrame)
			actionArray:addObject(delayAction)

		elseif curKeyFrame.tweenType == "normal" then

			local normalAction = self:buildNormalTween(animationInfo, curKeyFrame, nextKeyFrame)
			actionArray:addObject(normalAction)

		elseif curKeyFrame.tweenType == "static" then

			local staticAction = self:buildStaticTween(animationInfo, curKeyFrame, nextKeyFrame)
			actionArray:addObject(staticAction)
		elseif curKeyFrame.tweenType == "perFrame" then

			local perFrameAction = self:buildPerFrameTween(animationInfo, curKeyFrame, nextKeyFrame)
			actionArray:addObject(perFrameAction)

		elseif curKeyFrame.tweenType == "nop" then
		else
			assert(false)
		end
	end

	local seq 	= CCSequence:create(actionArray)
	local targetSeq	= CCTargetedAction:create(nodeToControl.refCocosObj, seq)
	return targetSeq
end

function FlashAnimBuilder:buildDelayTween(animInfo, curKeyFrame, nextKeyFrame, ...)
	assert(type(animInfo)		== "table")
	assert(type(curKeyFrame)	== "table")
	assert(#{...} == 0)

	local secondPerFrame = animInfo.secondPerFrame
	assert(secondPerFrame)

	if nextKeyFrame ~= nil then
	
		-- Time Duration
		assert(nextKeyFrame.frameIndex > curKeyFrame.frameIndex)
		local duration	= (nextKeyFrame.frameIndex - curKeyFrame.frameIndex) * secondPerFrame
		assert(duration)

		local delayAction = CCDelayTime:create(duration)
		return delayAction
	else

		local delayAction = CCDelayTime:create(0)
		return delayAction
	end
end

function FlashAnimBuilder:buildNormalTween(animInfo, curKeyFrame, nextKeyFrame, ...)
	assert(type(animInfo) == "table")
	assert(type(curKeyFrame) == "table")
	assert(type(nextKeyFrame) == "table")
	assert(#{...} == 0)

	-- About Node To Control
	local nodeToControl	= animInfo.object.node
	local deltaScaleX	= animInfo.object.deltaScaleX
	local deltaScaleY	= animInfo.object.deltaScaleY
	local originalScaleX	= animInfo.object.originalScaleX
	local originalScaleY	= animInfo.object.originalScaleY

	local secondPerFrame			= animInfo.secondPerFrame

	local actionArray = CCArray:create()

	-- Init
	local function changeToActionStartState()
		-- Set Init Pos
		-- Set Init Scale
		nodeToControl:setScaleX(curKeyFrame.sx * originalScaleX)
		nodeToControl:setScaleY(curKeyFrame.sy * originalScaleY)
		nodeToControl:setPosition(ccp(curKeyFrame.x * deltaScaleX, curKeyFrame.y * deltaScaleY))
		nodeToControl:setVisible(true)
	end
	local initStartStateAction = CCCallFunc:create(changeToActionStartState)
	actionArray:addObject(initStartStateAction)

	-- Move To Next Key Frame State
	if nextKeyFrame ~= nil then

		-- Time Duration
		assert(nextKeyFrame.frameIndex > curKeyFrame.frameIndex)
		local duration	= (nextKeyFrame.frameIndex - curKeyFrame.frameIndex) * secondPerFrame
		assert(duration)

		local moveToAction 	= CCMoveTo:create(duration, ccp(nextKeyFrame.x * deltaScaleX, nextKeyFrame.y * deltaScaleY))
		local scaleToAction	= CCScaleTo:create(duration, nextKeyFrame.sx * originalScaleX, nextKeyFrame.sy * originalScaleY)
		local spawn = CCSpawn:createWithTwoActions(moveToAction, scaleToAction)
		actionArray:addObject(spawn)
	else
		-- index == #keyFrames
		-- The Last Action
		-- Do Nothing
	end

	local seq = CCSequence:create(actionArray)
	return seq
end

function FlashAnimBuilder:buildStaticTween(animInfo, curKeyFrame, nextKeyFrame, ...)
	assert(type(animInfo)		== "table")
	assert(type(curKeyFrame)	== "table")
	assert(#{...} == 0)

	self:checkStaticKeyFrame(curKeyFrame)

	-- About Node To Control
	local nodeToControl	= animInfo.object.node
	local deltaScaleX	= animInfo.object.deltaScaleX
	local deltaScaleY	= animInfo.object.deltaScaleY
	local originalScaleX	= animInfo.object.originalScaleX
	local originalScaleY	= animInfo.object.originalScaleY

	local secondPerFrame	= animInfo.secondPerFrame

	local actionArray = CCArray:create()

	-- Init
	local function changeToActionStartState()

		-- Set Init Pos
		-- Set Init Scale
		nodeToControl:setScaleX(curKeyFrame.sx * originalScaleX)
		nodeToControl:setScaleY(curKeyFrame.sy * originalScaleY)
		nodeToControl:setPosition(ccp(curKeyFrame.x * deltaScaleX, curKeyFrame.y * deltaScaleY))
		nodeToControl:setVisible(true)
	end
	local initStartStateAction = CCCallFunc:create(changeToActionStartState)
	actionArray:addObject(initStartStateAction)

	-- Delay Until The Next Key Frame
	if nextKeyFrame ~= nil then

		assert(nextKeyFrame.frameIndex)
		assert(curKeyFrame.frameIndex)

		local duration	= (nextKeyFrame.frameIndex - curKeyFrame.frameIndex) * secondPerFrame
		assert(duration)

		local delay = CCDelayTime:create(duration)
		actionArray:addObject(delay)
	else
		-- index == #keyFrames
		-- The Last Action
		-- Do Nothing
	end

	local seq = CCSequence:create(actionArray)
	return seq
end

function FlashAnimBuilder:buildPerFrameTween(animInfo, curKeyFrame, nextKeyFrame, ...)
	assert(type(animInfo)		== "table")
	assert(type(curKeyFrame)	== "table")
	assert(type(nextKeyFrame)	== "table")
	assert(#{...} == 0)

	local keyFrames = {}

	------------------------------
	-- Insert Start Key Frame
	-- ------------------------
	local startKeyFrame = {}
	startKeyFrame.x		= curKeyFrame.x
	startKeyFrame.y		= curKeyFrame.y
	startKeyFrame.sx	= curKeyFrame.sx
	startKeyFrame.sy	= curKeyFrame.sy
	startKeyFrame.tweenType	= "static"
	startKeyFrame.frameIndex= curKeyFrame.frameIndex

	table.insert(keyFrames, startKeyFrame)

	-- -----------------------------
	-- Interpolate New Key Frame
	-- -------------------------
	
	assert(nextKeyFrame.frameIndex > curKeyFrame.frameIndex)
	local deltaFrame = nextKeyFrame.frameIndex - curKeyFrame.frameIndex

	for index = curKeyFrame.frameIndex + 1, nextKeyFrame.frameIndex - 1 do

		local ratio = (index - curKeyFrame.frameIndex) / deltaFrame
		local keyFrame = {}
		keyFrame.x		= interpolate(curKeyFrame.x, nextKeyFrame.x, ratio)
		keyFrame.y		= interpolate(curKeyFrame.y, nextKeyFrame.y, ratio)
		keyFrame.sx		= interpolate(curKeyFrame.sx, nextKeyFrame.sy, ratio)
		keyFrame.sy		= interpolate(curKeyFrame.sy, nextKeyFrame.sy, ratio)
		keyFrame.frameIndex	= index
		keyFrame.tweenType	= "static"

		table.insert(keyFrames, keyFrame)
	end

	-----------------------
	-- Insert End Key Frame
	-- --------------------
	local endKeyFrame	= {}
	endKeyFrame.x		= nextKeyFrame.x
	endKeyFrame.y		= nextKeyFrame.y
	endKeyFrame.sx		= nextKeyFrame.sx
	endKeyFrame.sy		= nextKeyFrame.sy
	endKeyFrame.frameIndex	= nextKeyFrame.frameIndex
	endKeyFrame.tweenType	= "static"

	table.insert(keyFrames, endKeyFrame)

	---------------------
	--- Create The Action
	----------------------
	local actionArray = CCArray:create()
	
	for index = 1, #keyFrames - 1 do
		local staticAction = self:buildStaticTween(animInfo, keyFrames[index], keyFrames[index + 1])
		actionArray:addObject(staticAction)
	end

	local seq = CCSequence:create(actionArray)
	return seq
end


function FlashAnimBuilder:checkTweenType(keyFrame, ...)
	assert(type(keyFrame) == "table")
	assert(#{...} == 0)

	assert(keyFrame.tweenType)
	assert(keyFrame.frameIndex)

	if keyFrame.tweenType == "normal" then

		assert(type(keyFrame.x)		== "number")
		assert(type(keyFrame.y)		== "number")
		assert(type(keyFrame.sx)	== "number")
		assert(type(keyFrame.sy)	== "number")

	elseif keyFrame.tweenType == "delay" then
		-- No Thing

	elseif keyFrame.tweenType == "static" then

		self:checkStaticKeyFrame(keyFrame)

	elseif keyFrame.tweenType == "perFrame" then

		assert(type(keyFrame.x)		== "number")
		assert(type(keyFrame.y)		== "number")
		assert(type(keyFrame.sx)	== "number")
		assert(type(keyFrame.sy)	== "number")
	else
		if _G.isLocalDevelopMode then printx(0, "tweenType: " .. keyFrame.tweenType .. " not suppport !") end
		assert(false)
	end
end

function FlashAnimBuilder:checkStaticKeyFrame(keyFrame, ...)
	assert(keyFrame)
	assert(#{...} == 0)

	assert(type(keyFrame.tweenType)	== "string")
	assert(keyFrame.tweenType	== "static")
	assert(keyFrame.frameIndex)
	assert(type(keyFrame.x)		== "number")
	assert(type(keyFrame.y)		== "number")
	assert(type(keyFrame.sx)	== "number")
	assert(type(keyFrame.sy)	== "number")
end

function FlashAnimBuilder:sharedInstance(...)
	assert(#{...} == 0)

	if not sharedInstance then

		sharedInstance = FlashAnimBuilder.new()
		sharedInstance:init()
	end

	return sharedInstance
end
