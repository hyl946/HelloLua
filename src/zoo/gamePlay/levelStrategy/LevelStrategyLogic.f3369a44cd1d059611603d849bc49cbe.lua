local ProgressBar = class(BaseUI)

function ProgressBar:init(ui)
	BaseUI.init(self, ui)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("bg1"))
	self.bar	= self.ui:getChildByName("bar")
	self.mask	= self.ui:getChildByName("mask")

	self.barInitialPosX 	= self.bar:getPositionX()
	self.barInitialPosY 	= self.bar:getPositionY()
	self.barWidth		= self.bar:getGroupBounds().size.width

	self.mask:removeFromParentAndCleanup(false)
	self.bar:removeFromParentAndCleanup(false)

	local cppClippingNode = CCClippingNode:create(self.mask.refCocosObj)
	local clipping = ClippingNode.new(cppClippingNode)
	clipping:setAlphaThreshold(0.1)
	clipping:addChild(self.bar)
	self.ui:addChildAt(clipping, childIndex+1)
	clipping:setPosition(ccp(self.barInitialPosX, self.barInitialPosY))

	self.progressBarToControl = self.bar
	self.mask:dispose()

	self:setPercentage(0)
end

function ProgressBar:setPercentage(percentage, ani)
	if percentage < 0 then
		percentage = 0
	elseif percentage > 1 then
		percentage = 1
	end

	local width = self.barWidth * percentage
	local newPosX = -self.barWidth + width
	if ani then 
		self.progressBarToControl:stopAllActions()
		self.progressBarToControl:runAction(CCMoveTo:create(0.2, ccp(newPosX, self.barInitialPosY)))
	else
		self.progressBarToControl:setPositionX(newPosX)
	end
end

function ProgressBar:create(ui)
	local bar = ProgressBar.new()
	bar:init(ui)
	return bar
end



LevelStrategyLogic = {}
LevelStrategyLogic.ReplaySource = {
	kStart = 1,
	kReplayMid = 2,
	kReplayEnd = 3,
}

function LevelStrategyLogic:reset()
	self.progressBar = nil	
	self.guideHand = nil
	self.guideCircle = nil
	-- self.soucePanelId = nil 		--replay播放入口位置 这个不在这里重置
	self.closeCallback = nil

	self.replayBtnEnable = nil
end

function LevelStrategyLogic:playReplay(repData, closeCB)
	self:reset()
	self.closeCallback = closeCB

	FrameLoader:loadImageWithPlist("flash/strategy_replay.plist")

	local simplejson = require("cjson")
	local replayData = simplejson.decode(repData)
	require "zoo.panelBusLogic.NewStartLevelLogic"
	local newStartLevelLogic = NewStartLevelLogic:create(nil, replayData.level, {}, false, {})

	newStartLevelLogic:startWithReplay(ReplayMode.kStrategy, replayData)
end

function LevelStrategyLogic:setSourcePanelId(soucePanelId)
	self.soucePanelId = soucePanelId
end

function LevelStrategyLogic:onGameInit(curScene, callback)
	local wSize = Director:sharedDirector():getWinSize()
	if not self.builder then 
		self.builder = InterfaceBuilder:createWithContentsOfFile("ui/LevelStrategy.json")
	end

	local progressBarRes = self.builder:buildGroup("level_strategy/ProgressBar")
	self.progressBar = ProgressBar:create(progressBarRes)
	local barSize = self.progressBar:getGroupBounds().size
	self.progressBar:setPosition(ccp((wSize.width - barSize.width)/2, wSize.height-2))

	local playBtnRes = self.builder:buildGroup("level_strategy/playBtn")
	playBtnRes:setPosition(ccp(wSize.width/2, wSize.height/2))

	local closeBtnRes = ResourceManager:sharedInstance():buildGroup("ui_buttons/ui_button_close_brown")
	local closeBtnSize = closeBtnRes:getGroupBounds().size
	closeBtnRes:setPosition(ccp(wSize.width - closeBtnSize.width/2, wSize.height - closeBtnSize.height/2))

	local containnerLayer = Layer:create()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity( 255 * 0.7 )
	trueMask:addEventListener(DisplayEvents.kTouchTap, function ()
		if trueMask then trueMask:removeFromParentAndCleanup(true) end
		if playBtnRes then playBtnRes:removeFromParentAndCleanup(false) end
		if closeBtnRes then closeBtnRes:removeFromParentAndCleanup(false) end
		if curScene then 
			LevelStrategyManager:dcClickStrategyInnerPlay(self.soucePanelId, curScene.levelId)
		end
		if callback then callback() end
	end)

	containnerLayer:addChild(trueMask)
	containnerLayer:addChild(self.progressBar)
	containnerLayer:addChild(playBtnRes)
	containnerLayer:addChild(closeBtnRes)

	closeBtnRes:setTouchEnabled(true, 0, true)
	closeBtnRes:addEventListener(DisplayEvents.kTouchTap, function ()
		if trueMask then trueMask:setTouchEnabled(false) end
		if closeBtnRes then closeBtnRes:setTouchEnabled(false) end
		if curScene then 
			LevelStrategyManager:dcCloseStrategyPlay(2, curScene.levelId)
		end
		if self.closeCallback then self.closeCallback() end
	end)

	curScene:superAddChild(containnerLayer)
end

function LevelStrategyLogic:updateProgress(curr , total)
	if self.progressBar then 
		local percentage = curr / total
		self.progressBar:setPercentage(percentage, true)
	end
end

function LevelStrategyLogic:hideProgress()
	if self.progressBar then 
		self.progressBar:setVisible(false)
	end
end

function LevelStrategyLogic:resetGuideShow()
	if not self.guideHand then 
		self.guideHand = Sprite:createWithSpriteFrameName("strategy_hand_0000")
	end
	if not self.guideCircle then 
		self.guideCircle = Sprite:createWithSpriteFrameName("strategy_circle")
	end

	self.guideHand:setVisible(true)
	self.guideCircle:setVisible(true)
end

function LevelStrategyLogic:handGuideSwap(r1, c1, r2, c2, callback)
	self:resetGuideShow()

	local curScene = Director:sharedDirector():getRunningScene()
	local fromPos, toPos = curScene:getPositionFromTo({x = r1, y = c1}, {x = r2, y = c2})
	local posAdjustX = 43
	local posAdjustY = -48
	local framesName = "strategy_hand_%04d"
	local frames1 = SpriteUtil:buildFrames(framesName, 0, 9)
	local animate1 = SpriteUtil:buildAnimate(frames1, kCharacterAnimationTime)
	self.guideHand:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("strategy_hand_0000"))
	self.guideHand:setPosition(ccp(fromPos.x + posAdjustX, fromPos.y + posAdjustY))
	self.guideHand:stopAllActions()
	self.guideHand:play(animate1, 0, 1, function ()
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(0.2))
		arr:addObject(CCMoveTo:create(0.4, ccp(toPos.x + posAdjustX, toPos.y + posAdjustY)))
		arr:addObject(CCCallFunc:create(function ()
			if self.guideHand then 
				self.guideHand:setVisible(false) 
			else
				return
			end 
			if callback then callback() end
		end))
		self.guideHand:runAction(CCSequence:create(arr))
	end)
	curScene:addChild(self.guideHand)

	self.guideCircle:setPosition(ccp(fromPos.x, fromPos.y))
	self.guideCircle:setScale(0)
	self.guideCircle:setOpacity(255)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.4, 1.2))
	arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 1.8), CCFadeTo:create(0.2, 0)))
	self.guideCircle:runAction(CCSequence:create(arr))
	curScene:addChild(self.guideCircle)
end

function LevelStrategyLogic:handGuideProp(itemId, callback)
	self:resetGuideShow()

	local curScene = Director:sharedDirector():getRunningScene()
	local itemCenterPos = curScene.propList:getItemCenterPositionById(itemId)
	if itemCenterPos then 
		local posAdjustX = 43
		local posAdjustY = -48
		local framesName = "strategy_hand_%04d"
		local frames1 = SpriteUtil:buildFrames(framesName, 0, 9)
		local animate1 = SpriteUtil:buildAnimate(frames1, kCharacterAnimationTime)
		self.guideHand:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("strategy_hand_0000"))
		self.guideHand:setPosition(ccp(itemCenterPos.x + posAdjustX, itemCenterPos.y + posAdjustY))
		self.guideHand:stopAllActions()
		self.guideHand:play(animate1, 0, 2, function ()
			if self.guideHand then 
				self.guideHand:setVisible(false) 
			else
				return
			end 
			if callback then callback() end
		end)
		curScene:addChild(self.guideHand)

		self.guideCircle:setPosition(ccp(itemCenterPos.x, itemCenterPos.y))
		self.guideCircle:setScale(0)
		self.guideCircle:setOpacity(255)
		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(0.4, 1.2))
		arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2, 1.8), CCFadeTo:create(0.2, 0)))
		self.guideCircle:runAction(CCSequence:create(arr))
		curScene:addChild(self.guideCircle)
	else
		if callback then callback() end
	end
end

function LevelStrategyLogic:setReplayBtnEnable(isEnable)
	self.replayBtnEnable = isEnable
end

function LevelStrategyLogic:getReplayBtnEnable()
	return self.replayBtnEnable
end