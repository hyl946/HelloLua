require "hecore.display.Director"

kTileCuteBallAnimation = { kNormal = 1, kUp = 2, kDown = 3, kLeft = 4, kRight = 5, kDestroy = 6 }
TileCuteBall = class(CocosObject)

local kCharacterAnimationTime = 1/30
local kTileCuteBallContentSize = 65

function TileCuteBall:toString()
	return string.format("TileCuteBall [%s]", self.name and self.name or "nil");
end

function TileCuteBall:create(name)	
	name = name or "ball_grey"

	local node = TileCuteBall.new(CCNode:create())
	node.name = name

	local hitArea = CocosObject:create()
	hitArea.name = kHitAreaObjectName
	hitArea:setContentSize(CCSizeMake(kTileCuteBallContentSize, kTileCuteBallContentSize))
	node:addChild(hitArea)

  	local mainSprite = Sprite:createWithSpriteFrameName(name.."_normal0000")
  	node:addChild(mainSprite)
  	node.mainSprite = mainSprite

	return node
end

function TileCuteBall:play(animation)
	self.mainSprite:stopAllActions()

	if animation == kTileCuteBallAnimation.kUp then self:playDirectionAnimation(animation)
	elseif animation == kTileCuteBallAnimation.kDown then self:playDirectionAnimation(animation)
	elseif animation == kTileCuteBallAnimation.kLeft then self:playDirectionAnimation(animation)
	elseif animation == kTileCuteBallAnimation.kRight then self:playDirectionAnimation(animation) 
	elseif animation == kTileCuteBallAnimation.kDestroy then self:playDestroyAnimation() end
end

function TileCuteBall:playDirectionAnimation(animation)
	self.mainSprite:setVisible(false)

	local pattern = self.name
	local positionOffset = nil
	if animation == kTileCuteBallAnimation.kUp then 
		pattern = pattern.."_up"
		positionOffset = ccp(1.3, 41)
	elseif animation == kTileCuteBallAnimation.kDown then 
		pattern = pattern.."_down"
		positionOffset = ccp(1.85, -35.45)
	elseif animation == kTileCuteBallAnimation.kLeft then 
		pattern = pattern.."_left"
		positionOffset = ccp(-33.55, 8.05)
	elseif animation == kTileCuteBallAnimation.kRight then 
		pattern = pattern.."_right" 
		positionOffset = ccp(37, 7.05)
	end

	local function onAnimComplete()
		self:dp(Event.new(Events.kComplete, animation, self))
	end

	local number = 16 
	local first = Sprite:createWithSpriteFrameName(pattern .. "0000")
	self:addChild(first)
	local frames = SpriteUtil:buildFrames(pattern .. "%04d", 0, number)
  	local animate = SpriteUtil:buildAnimate(frames, (kCharacterAnimationTime * 30 / 36))
  	first:setPosition(positionOffset)
  	first:play(animate, 0, 1, onAnimComplete)
end

function TileCuteBall:playDestroyAnimation()
	self.mainSprite:setVisible(false)

	local destroySprite = Sprite:createWithSpriteFrameName(self.name.."_destroy0000")
	destroySprite:setPosition(ccp(-0.85,-2.45))
  	self:addChild(destroySprite)
	local frames = SpriteUtil:buildFrames(self.name.."_destroy%04d", 0, 24)
  	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

  	local function onRepeatFinishCallback()
  		self:dp(Event.new(Events.kComplete, kTileCuteBallAnimation.kDestroy, self))
  	end 
  	destroySprite:play(animate, 0, 1, onRepeatFinishCallback)
end

function TileCuteBall:playFurballUnstableAnimation()
	local rightAction = CCMoveTo:create(kCharacterAnimationTime, ccp(2, 0))
	local leftAction = CCMoveTo:create(kCharacterAnimationTime, ccp(0, 0))
	local actionList = CCArray:create()
	actionList:addObject(rightAction)
	actionList:addObject(leftAction)
	local sequenceAction = CCSequence:create(actionList)
	self.mainSprite:runAction(CCRepeatForever:create(sequenceAction))
end

function TileCuteBall:playFurballSplitAnimation(dir, callback)
	self.mainSprite:setVisible(false)
	self.isSpliting = true

	local animationName = ""
	local positionOffset = nil
	if dir.x ~= 0 then
		if dir.x > 0 then
			animationName = "right"
			positionOffset = ccp(37.15, -4.85)
		else
			animationName = "left"
			positionOffset = ccp(-33.15, -5.3)
		end
	else
		if dir.y > 0 then
			animationName = "down"
			positionOffset = ccp(2, -29)
		elseif dir.y < 0 then
			animationName = "up"
			positionOffset = ccp(1.25, 27.65)
		else
			animationName = "origin"
			positionOffset = ccp(2.4, -4.5)
		end
	end
	local animationName = "ball_brown_split_" .. animationName
	local frames = SpriteUtil:buildFrames(animationName .. "%04d", 0, 26)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	
	local first = Sprite:createWithSpriteFrameName(animationName .. "0000")
	self:addChild(first)
  	first:setPosition(positionOffset)
  	local function onAnimComplete( ... )
  		-- body
  		if callback and type(callback) then callback() end
  	end 
  	first:play(animate, 0, 1, onAnimComplete)
end

function TileCuteBall:playFurballShieldAnimation()
	self.mainSprite:setVisible(false)
	local context = self
	local first = nil
	local function onAnimComplete()
		if _G.isLocalDevelopMode then printx(0, "on shield anim complete") end
		context.isShield = false
		if not context.isSpliting then
			context.mainSprite:setVisible(true)
		end
		first:removeFromParentAndCleanup(true)
	end

	if not self.isShield then
		self.isShield = true

		first = Sprite:createWithSpriteFrameName("ball_brown_shield0000")
		first:setPosition(ccp(0, 0))
		self:addChild(first)
		local frames = SpriteUtil:buildFrames("ball_brown_shield%04d", 0, 22)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		first:play(animate, 0, 1, onAnimComplete)
	end
end