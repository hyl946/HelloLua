local kCharacterAnimationTime = 1/24
local kEffectAnimationTime = 1/26
local OFFSET_X, OFFSET_Y = -5, 0

local GhostDirect = table.const{
	kRight = 1,
	kLeft = 2,
}

local AnimationType = table.const
{
    kNone = 0,
    kBorn = 1,
    kWander = 2,
    kAppear = 3,
    kDisappear = 4,
    kHit = 5,
    kSmile = 6,
    kTurn = 7,
}

local OriginalPosition = ccp(40, 45)
local LeftMinX = 40
local LeftMaxX = 220
local RightMinX = 400
local RightMaxX = 595
local MoveSpeed = 55.5
--面朝右时调整
local PosDeltaRight = table.const{
	kDeltaNone = ccp(0, 0),
	kDeltaBorn = ccp(7, 30),
	kDeltaWander = ccp(0, 0),
	kDeltaAppear = ccp(0, -30),
	kDeltaDisappear = ccp(5, -29),
	kDeltaHit = ccp(40, -22),
	kDeltaSmile = ccp(8, 2),
	kDeltaTurn = ccp(5, -3),
}

--面朝左时调整
local PosDeltaLeft = table.const{
	kDeltaNone = ccp(11, 0),
	kDeltaBorn = ccp(4, 30),
	kDeltaWander = ccp(11, 0),
	kDeltaAppear = ccp(11, -30),
	kDeltaDisappear = ccp(6, -29),
	kDeltaHit = ccp(-29, -22),
	kDeltaSmile = ccp(3, 2),
	kDeltaTurn = ccp(6, -3),
}

HalloweenGhost = class(CocosObject)

function HalloweenGhost:create()
	local ghost = HalloweenGhost.new(CCNode:create())
	ghost:init()
	return ghost
end

function HalloweenGhost:init()
	self.pumpkinOnScene = false
    self.body = CocosObject:create()
    self.body:setContentSize(CCSizeMake(9*70, 150))
    self.body:setAnchorPoint(ccp(0, 0))
    self:addChild(self.body)
    self.spriteContainer = CocosObject:create()
    self.sprite = Sprite:createWithSpriteFrameName('halloween_ghost_standby_0000.png')
    self.sprite:setAnchorPoint(ccp(0.5, 0.5))
    self.spriteContainer:addChild(self.sprite)
    self.animationType = AnimationType.kWander
    self.direction = GhostDirect.kRight

    self.body:addChild(self.spriteContainer)
    self.spriteContainer:setPosition(ccp(OriginalPosition.x, OriginalPosition.y))

	self.ghostLight1 = Sprite:createWithSpriteFrameName('halloween_ghost_light_0000.png')
   	self.ghostLight2 = Sprite:createWithSpriteFrameName('halloween_ghost_light_0000.png')
   	self.spriteContainer:addChild(self.ghostLight1)
   	self.ghostLight1:setPosition(ccp(-45, -30))
   	self.spriteContainer:addChild(self.ghostLight2)
   	self.ghostLight2:setPosition(ccp(60, 0))
	self.ghostLight1:setVisible(false)
	self.ghostLight2:setVisible(false)

   	self.lightAnimate1 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_light_%04d.png', 0, 10), kCharacterAnimationTime)
    self.lightAnimate1:retain()
    self.lightAnimate2 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_light_%04d.png', 0, 10), kCharacterAnimationTime)
    self.lightAnimate2:retain()
    ----test------
  --   local function onLayerTouch(evt)
  --   	local layerColor = evt.context
  --   	if layerColor.id == 1 then 
  --   		self:playWander()
		-- elseif layerColor.id == 2 then 
		-- 	self:playTurn()		
		-- elseif layerColor.id == 3 then
		-- 	self:playSmile()
		-- elseif layerColor.id == 4 then 

		-- end
  --   end
  --   for i=1,4 do
	 --   	local layerColor = LayerColor:create()
	 --   	layerColor.id = i
	 --    layerColor:setAnchorPoint(ccp(0, 0))
	 --    layerColor:setColor(ccc3(255,0,0))
	 --    layerColor:changeWidthAndHeight(50, 50)
	 --  	layerColor:setOpacity(255/i)
	 --  	self.body:addChild(layerColor)
	 --  	layerColor:setPosition(ccp(150 + (i-1)*80,150))
	 --  	layerColor:setTouchEnabled(true, 0, true)
	 --  	layerColor:addEventListener(DisplayEvents.kTouchTap, onLayerTouch, layerColor)
  --   end
    -----------------

    self:playBorn()
end

function HalloweenGhost:getBossSpriteWorldPosition()
    if self.body and self.sprite then
        local worldPos = self.body:convertToWorldSpace(self.sprite:getPosition())
        local bossSize = self.sprite:getContentSize()
        local centerPos = ccp(worldPos.x + bossSize.width / 2, worldPos.y)
        return centerPos
    end
    return nil
end

function HalloweenGhost:adjustPostion()
	local posDelta = nil
    if self.direction == GhostDirect.kRight then 
    	posDelta = PosDeltaRight
	elseif self.direction == GhostDirect.kLeft then 
		posDelta = PosDeltaLeft
	end 

	if self.animationType == AnimationType.kBorn then 
		self.sprite:setPosition(ccp(posDelta.kDeltaBorn.x, posDelta.kDeltaBorn.y))
	elseif self.animationType == AnimationType.kWander then
		self.sprite:setPosition(ccp(posDelta.kDeltaWander.x, posDelta.kDeltaWander.y))
	elseif self.animationType == AnimationType.kAppear then
		self.sprite:setPosition(ccp(posDelta.kDeltaAppear.x, posDelta.kDeltaAppear.y))
	elseif self.animationType == AnimationType.kDisappear then
		self.sprite:setPosition(ccp(posDelta.kDeltaDisappear.x, posDelta.kDeltaDisappear.y))
	elseif self.animationType == AnimationType.kHit then
		self.sprite:setPosition(ccp(posDelta.kDeltaHit.x, posDelta.kDeltaHit.y))
	elseif self.animationType == AnimationType.kSmile then
		self.sprite:setPosition(ccp(posDelta.kDeltaSmile.x, posDelta.kDeltaSmile.y))
	elseif self.animationType == AnimationType.kTurn then
		self.sprite:setPosition(ccp(posDelta.kDeltaTurn.x, posDelta.kDeltaTurn.y))
	end
end

function HalloweenGhost:startRandomHit()
	self:stopRandomHit()
	local function randomHit()
		local randomNum = math.random(1,10)
		if randomNum > 5 then 
			self:playHit()
		end
	end
	self.randomHitScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(randomHit, 2,false)
end

function HalloweenGhost:stopRandomHit()
	if self.randomHitScheduler then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.randomHitScheduler)
	end
	self.randomHitScheduler = nil
end

function HalloweenGhost:startRandomAppear()
	self:stopRandomAppear()
	local function randomAppear()
		-- local randomNum = math.random(1,10)
		-- if randomNum > 5 then 
			self:playDisappear()
		-- end
	end
	self.randomAppearScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(randomAppear, 5,false)
end

function HalloweenGhost:stopRandomAppear()
	if self.randomAppearScheduler then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.randomAppearScheduler)
	end
	self.randomAppearScheduler = nil
end

function HalloweenGhost:playWander()
	self.animationType = AnimationType.kWander

    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
    	local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_standby_%04d.png', 0, 42), kCharacterAnimationTime)
    	self.sprite:play(animate)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))

    local currentPos = self.spriteContainer:getPosition()
    local currentPosX = currentPos.x
    local currentPosY = currentPos.y
    if self.pumpkinOnScene then
    	local seqArr = CCArray:create()
    	if self.direction == GhostDirect.kRight then 
    		if currentPosX >= LeftMinX and currentPosX <= LeftMaxX then 
	    		local moveTime = (LeftMaxX - currentPosX)/MoveSpeed
	    		seqArr:addObject(CCMoveTo:create(moveTime, ccp(LeftMaxX, OriginalPosition.y)))
	    		seqArr:addObject(CCCallFunc:create(function ()
	    			self:startRandomHit()
	    			self:startRandomAppear()
	    		end))
    		elseif currentPosX > LeftMaxX and currentPosX < RightMinX then 
    			local moveTime = (RightMinX - currentPosX)/MoveSpeed
    			seqArr:addObject(CCMoveTo:create(moveTime, ccp(RightMinX, OriginalPosition.y)))
	    		seqArr:addObject(CCCallFunc:create(function ()
	    			self:playTurn()
	    		end))
    		elseif currentPosX >= RightMinX and currentPosX <= RightMaxX then 
    			self.spriteContainer:stopAllActions()
    			self:playTurn()
    			return
    		end
    	elseif self.direction == GhostDirect.kLeft then 
    		if currentPosX >= LeftMinX and currentPosX <= LeftMaxX then 
	    		self:playTurn()
	    		return
    		elseif currentPosX > LeftMaxX and currentPosX < RightMinX then 
    			local moveTime = (currentPosX - LeftMaxX)/MoveSpeed
    			seqArr:addObject(CCMoveTo:create(moveTime, ccp(LeftMaxX, OriginalPosition.y)))
	    		seqArr:addObject(CCCallFunc:create(function ()
	    			self.spriteContainer:stopAllActions()
	    			self:playTurn()
	    		end))
    		elseif currentPosX >= RightMinX and currentPosX <= RightMaxX then 
    			local moveTime = (currentPosX - RightMinX)/MoveSpeed
	    		seqArr:addObject(CCMoveTo:create(moveTime, ccp(RightMinX, OriginalPosition.y)))
	    		seqArr:addObject(CCCallFunc:create(function ()
	    			self:startRandomHit()
	    			self:startRandomAppear()
	    		end))
    		end
    	end
    	self.spriteContainer:stopAllActions()
    	self.spriteContainer:runAction(CCSequence:create(seqArr))
    else
    	self:stopRandomHit()
    	self:stopRandomAppear()

    	local seqArr = CCArray:create()
    	if self.direction == GhostDirect.kRight then 
    		local moveTime = (RightMaxX - currentPosX)/MoveSpeed
    		seqArr:addObject(CCMoveTo:create(moveTime, ccp(RightMaxX, OriginalPosition.y)))
    		seqArr:addObject(CCCallFunc:create(function ()
    			self:playTurn()
    		end))
    	elseif self.direction == GhostDirect.kLeft then 
    		local moveTime = (currentPosX - LeftMinX)/MoveSpeed
    		seqArr:addObject(CCMoveTo:create(moveTime, ccp(LeftMinX, OriginalPosition.y)))
    		seqArr:addObject(CCCallFunc:create(function ()
    			self:playTurn()
    		end))
    	end
    	self.spriteContainer:stopAllActions()
    	self.spriteContainer:runAction(CCSequence:create(seqArr))
    end 
end

function HalloweenGhost:playTurn()
	self.animationType = AnimationType.kTurn
	local function callback()
		if self.direction == GhostDirect.kRight then 
	    	self.sprite:setScaleX(-1)
	    	self.direction = GhostDirect.kLeft
		elseif self.direction == GhostDirect.kLeft then 
			self.direction = GhostDirect.kRight
			self.sprite:setScaleX(1)
		end

		self:playWander()
	end

    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
		local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_turn_%04d.png', 0, 18), kCharacterAnimationTime)
	    self.sprite:play(animate, 0, 1, callback)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))
end

function HalloweenGhost:playBorn()
	self.animationType = AnimationType.kBorn
	local function callback()
		self.ghostLight1:setVisible(true)
		self.ghostLight2:setVisible(true)
		self.ghostLight1:play(self.lightAnimate1)
		self.ghostLight2:play(self.lightAnimate2)
		self:playWander()
	end

    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
	    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_born_%04d.png', 0, 31), kCharacterAnimationTime)
	    self.sprite:play(animate, 0, 1, callback)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))
end

function HalloweenGhost:playAppear()
	if self.animationType == AnimationType.kHit then 
		return 
	end
	self.animationType = AnimationType.kAppear
	local function callback()
		self:playWander()
	end

    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
	    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_appear_%04d.png', 0, 31), kCharacterAnimationTime)
	    self.sprite:play(animate, 0, 1, callback)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))
end

function HalloweenGhost:playDisappear()
	if self.animationType == AnimationType.kHit then 
		return 
	end
	self.animationType = AnimationType.kDisappear
	local function callback()
		if self.direction == GhostDirect.kRight then 
	    	self.sprite:setScaleX(-1)
	    	self.direction = GhostDirect.kLeft
	    	self.spriteContainer:setPosition(ccp(RightMinX, OriginalPosition.y))
		elseif self.direction == GhostDirect.kLeft then 
			self.direction = GhostDirect.kRight
			self.sprite:setScaleX(1)
			self.spriteContainer:setPosition(ccp(LeftMaxX, OriginalPosition.y))
		end
		self:playAppear()
	end
	
    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
	    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_disappear_%04d.png', 0, 20), kCharacterAnimationTime)
	    self.sprite:play(animate, 0, 1, callback)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))
end

function HalloweenGhost:playHit()
	if self.animationType == AnimationType.kSmile or 
		self.animationType == AnimationType.kAppear or 
		self.animationType == AnimationType.kDisappear then 
		return 
	end

	self.animationType = AnimationType.kHit
	local function callback()
		self:playWander()
	end

    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
    	local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_hit_%04d.png', 0, 40), kCharacterAnimationTime)
    	self.sprite:play(animate, 0, 1, callback)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))
end

function HalloweenGhost:playSmile()
	if 	self.animationType == AnimationType.kHit or
		self.animationType == AnimationType.kAppear or 
		self.animationType == AnimationType.kDisappear or
		self.animationType == AnimationType.kSmile or
		self.animationType == AnimationType.kTurn then 
		return 
	end

	self.animationType = AnimationType.kSmile
	local function callback()
		self:playWander()
	end

    local function fun1()
    	self:adjustPostion()
    	self.sprite:stopAllActions()
    end
    local function fun2()
	    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('halloween_ghost_smile_%04d.png', 0, 56), kCharacterAnimationTime)
	    self.sprite:play(animate, 0, 1, callback)
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCCallFunc:create(fun1), CCCallFunc:create(fun2)))
end

function HalloweenGhost:setPumpkinOnScene(pumpkinOnScene)
	self.pumpkinOnScene = pumpkinOnScene
	self:playWander()
end

function HalloweenGhost:dispose()
	if self.lightAnimate1 then 
		self.lightAnimate1:release()
	end
	if self.lightAnimate2 then 
    	self.lightAnimate2:release()
    end
    self:stopRandomHit()
	self:stopRandomAppear()
	HalloweenAnimation:getInstance():setHalloweenGhost(nil)
	CocosObject.dispose(self)
end