TileSunFlask = class(CocosObject)

local kCharacterAnimationTime = 1/30

local assetNamePrefix = "blocker_sunFlask_"

function TileSunFlask:create(level)
	local node = TileSunFlask.new(CCNode:create())
	node.name = "sun_flask"
	node.flaskLevel = level
	
	node:init()
	-- printx(11, "TileSunFlask sprite created", debug.traceback())
	return node
end

function TileSunFlask:init( ... )
	self:setIdleAnimation()
end

function TileSunFlask:_cleanSprite()
	if self.sprite then 
		self.sprite:stopAllActions()
		self.sprite:removeFromParentAndCleanup(true)
	end
end

function TileSunFlask:_playCertainAnimation(targetSprite, spritePrefix, animationFrame, animationTime, doubleWithReverse, onAnimationFinished)
	if targetSprite then
		targetSprite:stopAllActions()

	    local frames = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame)
		local animation = SpriteUtil:buildAnimate(frames, animationTime)
		if doubleWithReverse then
			local frames2 = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame, true)
			local animation2 = SpriteUtil:buildAnimate(frames2, animationTime)

			local sequence = CCArray:create()
			-- sequence:addObject(CCDelayTime:create(0.7))
			sequence:addObject(animation)
			sequence:addObject(animation2)
			-- sequence:addObject(CCDelayTime:create(1))
			local action = CCRepeatForever:create(CCSequence:create(sequence))

			targetSprite:runAction(action)
		else
			-- targetSprite:play(animation)
			targetSprite:play(animation, 0, 1, onAnimationFinished, true)
		end
	end
end

--------------------------------------------------------------------------------
--									IDLE
--------------------------------------------------------------------------------
function TileSunFlask:setIdleAnimation()
	-- printx(11, "setIdleAnimation", self.flaskLevel, debug.traceback())
	if self.flaskLevel > 0 then
		self:_cleanSprite()

		local currPrefix = assetNamePrefix.."idle_"..self.flaskLevel
		self.sprite = Sprite:createWithSpriteFrameName(currPrefix.."_0000")
		self:addChild(self.sprite)

		self:_playCertainAnimation(self.sprite, currPrefix, 15, kCharacterAnimationTime * 1.4, true)

		-- self.sprite:setPosition(ccp(0, assetShiftY))
		self.inIdleState = true
	end
end

--------------------------------------------------------------------------------
--									DECREASE
--------------------------------------------------------------------------------
function TileSunFlask:playDecreaseAnimation(currLevel)
	local function onAnimationFinished()
		if self.flaskLevel > 0 then
			self:setIdleAnimation()
			-- self.sprite:setVisible(true)
		else
			self:_cleanSprite()
		end
	end

	if self.flaskLevel > 0 then
		if currLevel then
			self.flaskLevel = currLevel + 1
		end

		local currPrefix = assetNamePrefix.."break_"..self.flaskLevel
		local shiftX, shiftY = 0, 0
		local breakFrame = 30
		if self.flaskLevel == 1 then
			breakFrame = 17
		else
			shiftX = -4
			shiftY = 1
		end

		self:_cleanSprite()

		self.sprite = Sprite:createWithSpriteFrameName(currPrefix.."_0000")
		self:addChild(self.sprite)
		self.sprite:setPosition(ccp(shiftX, shiftY))

		self:_playCertainAnimation(self.sprite, currPrefix, breakFrame, kCharacterAnimationTime, false, onAnimationFinished)

		self.flaskLevel = self.flaskLevel - 1

		if self.flaskLevel > 0 then
			GamePlayMusicPlayer:playEffect(GameMusicType.kSunFlaskMatch)
		else
			GamePlayMusicPlayer:playEffect(GameMusicType.kSunFlaskBreak)
		end
	end
end
