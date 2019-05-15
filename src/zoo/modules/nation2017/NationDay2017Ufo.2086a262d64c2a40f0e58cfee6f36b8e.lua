---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-09-05 17:23:30
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-26 18:49:25
---------------------------------------------------------------------------------------
NationDay2017Ufo = class(CocosObject)

local kCharacterAnimationTime = 1/30

NationDay2017UfoState = {
	kIdle = 1,
	kLoad = 2,
	kReady = 3,
	kFire = 4,
}

function NationDay2017Ufo:create(bombNum)
	local node = NationDay2017Ufo.new(CCNode:create())
	node:init(bombNum)
	node:changeState(NationDay2017UfoState.kIdle, true)
	return node
end

function NationDay2017Ufo:init(bombNum)
	self.animation = nil
	self.currentState = 0
	self.cacheAnimations = {}
	self.cacheAnimationNode = CocosObject.new(CCNode:create())
	self.cacheAnimationNode:setVisible(false)
	
	self:addChild(self.cacheAnimationNode)

	self.targetNum = 0
	self.bombNum = bombNum or 0

	self.touchLayer = Layer:create() --LayerColor:createWithColor(ccc3(255, 0, 0), 220, 220)
	self.touchLayer:changeWidthAndHeight(220, 220)
	self.touchLayer:setPosition(ccp(-110, -110))
	self:addChild(self.touchLayer)
	self.touchLayer:setTouchEnabled(true)
	local function onTouch(evt)
		if self.onTouchListener then self.onTouchListener(evt) end
	end
	self.touchLayer:addEventListener(DisplayEvents.kTouchTap, onTouch)

	self.touchLayer2 = Layer:create() --LayerColor:createWithColor(ccc3(255, 0, 0), 100, 100)
	self.touchLayer2:changeWidthAndHeight(100, 100)
	self.touchLayer2:setPosition(ccp(-50, -210))
	self:addChild(self.touchLayer2)
	self.touchLayer2:setTouchEnabled(true)
	local function onTouch2(evt)
		if self.onTouchListener then self.onTouchListener(evt) end
	end
	self.touchLayer2:addEventListener(DisplayEvents.kTouchTap, onTouch2)

	self.animationContainer = CocosObject.new(CCNode:create())
	self:addChild(self.animationContainer)

	self.effectNode = CocosObject.new(CCNode:create())
	self:addChild(self.effectNode)

	self:changeState(NationDay2017UfoState.kIdle, true)

	local actionSeq = CCSequence:createWithTwoActions(CCMoveBy:create(0.7, ccp(0, 10)), CCMoveBy:create(0.7, ccp(0, -10)))
	self:runAction(CCRepeatForever:create(actionSeq))
end

function NationDay2017Ufo:setOnTouchLitener(listener)
	self.onTouchListener = listener
end

function NationDay2017Ufo:_getAnimationByState(state)
	if not self.cacheAnimations[state] then
		local animation = nil
		if state == NationDay2017UfoState.kIdle then
			animation = NationDay2017Animations:createUFOIdle()
		elseif state == NationDay2017UfoState.kLoad then
			animation = NationDay2017Animations:createUFOLoad()
		elseif state == NationDay2017UfoState.kReady then
			animation = NationDay2017Animations:createUFOReady()
		elseif state == NationDay2017UfoState.kFire then
			animation = NationDay2017Animations:createUFOFire()
		end
		self.cacheAnimationNode:addChild(animation)
		self.cacheAnimations[state] = animation
	end
	return self.cacheAnimations[state]
end

function NationDay2017Ufo:_changeAnimation(toState)
	if self.animation then
		self.animation:addOnCompleteLitener(nil)
		self.animation:addFrameEventLitener(nil)

		self.animation.node:stop()
		self.animation.node:playByIndex(0, 1)
		self.animation.node:update(0.02)
		self.animation.node:stop()

		self.animation:removeFromParentAndCleanup(false)
		self.cacheAnimationNode:addChild(self.animation)
		self.animation = nil
	end
	self.animation = self:_getAnimationByState(toState)
	self.animation:removeFromParentAndCleanup(false)
	self.animationContainer:addChild(self.animation)
	self.animation.node:playByIndex(0, 1)

	self.animation:updateTargetNum(self.targetNum)
	self.animation:updateBombNum(self.bombNum)
end

function NationDay2017Ufo:updateTargetNum(tNum)
	tNum = tNum or 0
	self.targetNum = tNum
	if self.animation then 
		self.animation:updateTargetNum(tNum)
	end
end

function NationDay2017Ufo:updateBombNum(bNum)
	bNum = bNum or 0
	self.bombNum = bNum
	if self.animation then 
		self.animation:updateBombNum(bNum)
	end
end

function NationDay2017Ufo:getCollectPosition()
	if not self.targetPos then
		local phSlot = self.animation.node:getSlot("target_ph")
		local phDisplay = tolua.cast(phSlot:getCCDisplay(),"CCSprite")
		local wPos = self.animation.node:convertToWorldSpace(ccp(phDisplay:getPositionX()+28, phDisplay:getPositionY()-25))
		local lPos = self:convertToNodeSpace(wPos)
		-- self.targetPos = {x = lPos.x+25, y = lPos.y-20}
		self.targetPos_local = {x = lPos.x, y = lPos.y}
		self.targetPos = {x = wPos.x, y= wPos.y}
	end
	return ccp(self.targetPos.x, self.targetPos.y)
end

function NationDay2017Ufo:getBombPosition()
	return self:convertToWorldSpace(ccp(0, 30))
end

function NationDay2017Ufo:changeState(newState)
	if newState ~= self.currentState then
		self:_changeAnimation(newState)
		self.currentState = newState
	end
end

function NationDay2017Ufo:playLoadAnimation(onFinish)
	self:changeState(NationDay2017UfoState.kLoad)
	local function onCompleteLitener()
		if onFinish then onFinish() end
	end
	self.animation:addOnCompleteLitener(onCompleteLitener)
end

function NationDay2017Ufo:playReadyAnimation()
	self:changeState(NationDay2017UfoState.kReady)
end

function NationDay2017Ufo:playIdleAniamtion()
	self:changeState(NationDay2017UfoState.kIdle)
end

function NationDay2017Ufo:playFireAnimation(onFire, onFinish)
	self:changeState(NationDay2017UfoState.kFire)
	local function onCompleteLitener()
		if onFinish then onFinish() end
	end
	self.animation:addOnCompleteLitener(onCompleteLitener)
	local function frameEventLitener(evt)
		if evt.data.frameLabel == "dropBomb" then
			if onFire then onFire() end
		end
	end
	self.animation:addFrameEventLitener(frameEventLitener)
end

function NationDay2017Ufo:getFireBombPosition()
	return self.animation:convertToWorldSpace(ccp(40, -140))
end

function NationDay2017Ufo:playHit(onFinish)
	
end

function NationDay2017Ufo:playCollectEffect()
	if self.targetPos_local then
		local effect = NationDay2017Animations:createCollectEffect()
		effect:setPosition(ccp(self.targetPos_local.x-3, self.targetPos_local.y-7))
		self.effectNode:addChild(effect)
	end
end
