require "zoo.gamePlay.levelTarget.LevelTargetAnimationBase"

----------------------------------------------------------
--LevelTargetAnimationTime, LevelTargetAnimationMove
-----------------------------------------------------------

LevelTargetAnimationTime = class(LevelTargetAnimationBase)
function LevelTargetAnimationTime:setTargetNumber( itemType, itemId, itemNum, animate, globalPosition, rotation, percent )
	-- body
	self.time:setTargetNumber(itemId, itemNum)
end

function LevelTargetAnimationTime:revertTargetNumber( itemType, itemId, itemNum )
	-- body
	self.time:revertTargetNumber(itemId, itemNum)
end

function LevelTargetAnimationTime:setNumberOfTargets( v, animationCallbackFunc, flyFinishedCallback , noAnimation)
	-- body
	if self.isInitialized then return end
	self.isInitialized = true
	v = v or 1
	if v < 1 then v = 1 end
	if v > 4 then v = 4 end

	self.numberOfTargets = v
	local delayBeforeTime = 1
	local delayTime = 1.6
    for i=1,4 do
		self["c"..i] = self:buildTargetItem("c"..i, i)
	end
	self:updateTargets()

	local panel = self.panel
	local winSize = CCDirector:sharedDirector():getVisibleSize()
  	local panelSize = panel:getContentSize()
  	local x = (winSize.width - panelSize.width)/2
  	local y = (winSize.height+panelSize.height)/2
  	panel:setPosition(ccp(x, y + 180))
  	panel:fadeIn(delayBeforeTime)

  	self.time_label:setOpacity(0)
	self.time_label:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayBeforeTime), CCFadeIn:create(0.5)))

	local function onDelayFinished()
  		self.layer:rma()
		self.layer:setTouchEnabled(false)
  		self:flyTarget(animationCallbackFunc, flyFinishedCallback  , noAnimation)
  	end 
  	
  	local sequence = CCArray:create()
  	sequence:addObject(CCDelayTime:create(delayBeforeTime))
  	sequence:addObject(CCEaseQuarticBackOut:create(CCMoveTo:create(0.5, ccp(x, y)), 33, -106, 126, -67, 15))
  	sequence:addObject(CCDelayTime:create(delayTime))
  	sequence:addObject(CCCallFunc:create(onDelayFinished))

	panel:stopAllActions()
	panel:runAction(CCSequence:create(sequence))

	local function onTouchLayer( evt )		
		panel:stopAllActions()

		self.layer:rma()
		self.layer:setTouchEnabled(false)
		self:flyTarget(animationCallbackFunc, flyFinishedCallback , noAnimation)
	end

	self.layer:ad(DisplayEvents.kTouchTap, onTouchLayer)
	self.layer:setTouchEnabled(true, -10000, true)

	if noAnimation then
		onTouchLayer()
	end
end

function LevelTargetAnimationTime:setTimeBgVisible( ... )
	-- body
	self.timeBg:setVisible(true)
end

function LevelTargetAnimationTime:updateTargets()
	-- body
	for i=1,4 do 
		 self["c"..i]:setVisible(false)
		 self["c"..i]:rma()
		 self["tile"..i]:setVisible(false)
	end
	local itemNum = self.targets[1].num
	self.time:setVisible(true)
	self.time:setContentIcon(nil, itemNum)
	self.time.itemNum = itemNum
	self:setTimeBgVisible()
	self.time_label:setVisible(true)
	self.time_label:setString(tostring(itemNum or 0))

	local tileArray = CCArray:create()
	tileArray:addObject(CCDelayTime:create(1.6))
	tileArray:addObject(CCScaleTo:create(0.2, 1.6))
	tileArray:addObject(CCScaleTo:create(0.2, 1.27))
	self.time_label:runAction(CCSequence:create(tileArray))

	local itemType = self:getTargetTypeByTargets()
	self.tip_label:setString(Localization:getInstance():getText(kLevelTargetTypeTexts[itemType]))
	
	local tipSize = self.tip_label:getContentSize()
	local tipPos = self.tip_label:getPosition()

	-- local array = CCArray:create()
	-- array:addObject(CCDelayTime:create(1.9))
	-- array:addObject(CCEaseElasticOut:create(CCScaleTo:create(1, 1.4)))
	-- self.tip_label:setScale(1)
	-- self.tip_label:stopAllActions()
	-- self.tip_label:runAction(CCSequence:create(array))
	self.tip_label:setPosition(ccp(tipPos.x + tipSize.width/2, tipPos.y - tipSize.height/2))
end

function LevelTargetAnimationTime:flyTimeTarget(noAnimation)
	local size = self.time_label:getContentSize()
	local position = self.time:getPosition()
	position = self.time:getParent():convertToWorldSpace(ccp(position.x, position.y))
	position = self.time_label:getParent():convertToNodeSpace(position)

	local time_position = self.time_label:getPosition()
	local tx, ty = time_position.x, time_position.y

	if noAnimation then
		self.time_label:setPosition(ccp(tx, ty))
		return
	end

	local function onAnimationFinished()
		self.time_label:setPosition(ccp(tx, ty))
	end 

	local spawn = CCArray:create()
	spawn:addObject(CCScaleTo:create(0.4, 1.1))
	spawn:addObject(CCFadeTo:create(1, 0))
	spawn:addObject(CCEaseBackIn:create(CCMoveTo:create(0.96, position)))

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.02))
	array:addObject(CCScaleTo:create(0.2, 1.65))
	array:addObject(CCSpawn:create(spawn)) 
	array:addObject(CCCallFunc:create(onAnimationFinished))

	self.time_label:stopAllActions()
	self.time_label:runAction(CCSequence:create(array))
end

function LevelTargetAnimationTime:getTargetTypeByTargets( ... )
	-- body
	if self.targets then
		local selectedItem = self.targets[1]
		if selectedItem then
			return selectedItem.type
		end
	end
	return nil
end

function LevelTargetAnimationTime:flyTarget( animationCallbackFunc, flyFinishedCallback , noAnimation)
	-- body
	if self.isTargetFly then return end
	self.isTargetFly = true

	local panel = self.panel
	local function onAnimationFinished()
		self:dropLeaf() 
  		self.time:fadeIn(0.3)
  		self.panel:removeFromParentAndCleanup(true)
  	end

	local sequence = CCArray:create()
	sequence:addObject(CCDelayTime:create(0.4))
	sequence:addObject(CCCallFunc:create(onAnimationFinished))

	panel:stopAllActions()
	panel:fadeOut()
	panel:runAction(CCSequence:create(sequence))
	self:flyTimeTarget(noAnimation)

	local function onCountDownAnimationFinished()			
		if self.layer and not self.layer.isDisposed then 
			local winSize = CCDirector:sharedDirector():getVisibleSize()
			local star = FallingStar:create(ccp(winSize.width/2, winSize.height/2), 
						ccp(winSize.width - 100, winSize.height-100), 
						animationCallbackFunc, 
						flyFinishedCallback)
			self.layer:addChild(star) 
		end
	end

	if noAnimation then
		panel:stopAllActions()
		onAnimationFinished()

		if flyFinishedCallback then flyFinishedCallback() end
		if animationCallbackFunc then animationCallbackFunc() end
	else
		local winSize = CCDirector:sharedDirector():getVisibleSize()
		local countDownAnimation = CountDownAnimation:create(0.1, onCountDownAnimationFinished)
		countDownAnimation:setPosition(ccp(winSize.width/2, winSize.height/2))
		self.layer:addChild(countDownAnimation)
	end
end

function LevelTargetAnimationTime:getLevelTileByIndex( index )
	-- body
	return self.time
end

function LevelTargetAnimationTime:shake( ... )
	-- body
	self.time:shake()
end


LevelTargetAnimationMove = class(LevelTargetAnimationTime)

function LevelTargetAnimationMove:flyTarget( animationCallbackFunc, flyFinishedCallback , noAnimation)
	-- body
	if self.isTargetFly then return end
	self.isTargetFly = true
	local panel = self.panel
	local function onAnimationFinished()
		self:dropLeaf() 
		self.time:fadeIn(0.3)
		if animationCallbackFunc ~= nil then animationCallbackFunc() end
		if flyFinishedCallback ~= nil then flyFinishedCallback() end
  		self.panel:removeFromParentAndCleanup(true)
  	end

	local sequence = CCArray:create()
	sequence:addObject(CCDelayTime:create(0.4))
	sequence:addObject(CCCallFunc:create(onAnimationFinished))

	panel:stopAllActions()
	panel:fadeOut()
	panel:runAction(CCSequence:create(sequence))
	self:flyTimeTarget(noAnimation)

	if noAnimation then
		panel:stopAllActions()
		onAnimationFinished()
	end
end

function LevelTargetAnimationMove:setTimeBgVisible( ... )
	-- body
	self.timeBg:setVisible(false)
end


