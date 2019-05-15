require "zoo.animation.TileVenom"

TilePoisonBottle = class(TileVenom)

local kCharacterAnimationTime = 1/30

local defaultPosX = 0
local defaultPosY = -3

function TilePoisonBottle:create()
	local node = TilePoisonBottle.new(CCNode:create())
	node.name = "PoisonBottle"

	local effectSprite = Sprite:createWithSpriteFrameName("PoisonBottle_Normal_0000")
	effectSprite:setPosition(ccp(defaultPosX, defaultPosY))
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	return node
end

function TilePoisonBottle:playNormalAnimation()
	local frames = SpriteUtil:buildFrames("PoisonBottle_Normal_%04d", 0, 49)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.effectSprite:play(animate)
end

function TilePoisonBottle:playTempInvisibleAnimation()
	self.effectSprite:setVisible(false)
end

function TilePoisonBottle:playRevertVisibleAnimation()
	self.effectSprite:setVisible(true)
end

function TilePoisonBottle:playDirectionAnimation( direction )
	-- body
	local function onAnimComplete()
		self:dp(Event.new(Events.kComplete, animation, self))
	end


	self.effectSprite:setVisible(false)
	local positionSpread_1 = Sprite:createWithSpriteFrameName("PoisonSpread_1_0000")
	self:addChild(positionSpread_1)
	local frames_1 = SpriteUtil:buildFrames("PoisonSpread_1_%04d", 1, 17)
	local animate_1 = SpriteUtil:buildAnimate(frames_1, kCharacterAnimationTime)
	positionSpread_1:play(animate_1, 0, 1)
	self.positionSpread_1 = positionSpread_1

	local positionSpread_2 = Sprite:createWithSpriteFrameName("PoisonSpread_2_0000")
	self.positionSpread_2 = positionSpread_2
	self:addChild(positionSpread_2)
	self.positionSpread_2:setAnchorPoint(ccp(0.5, 0))
	local frames_2 = SpriteUtil:buildFrames("PoisonSpread_2_%04d",1, 5)
	local animate_2 = SpriteUtil:buildAnimate(frames_2, kCharacterAnimationTime)

	local spread_3_position 
	if direction.x > 0 then  											--right
		positionSpread_2:setRotation(90)
		spread_3_position = ccp(GamePlayConfig_Tile_Width, 0)
	elseif direction.x < 0 then											--left
		positionSpread_2:setRotation(-90)
		spread_3_position = ccp(-GamePlayConfig_Tile_Width, 0)
	else
		if direction.y > 0 then											--down
			positionSpread_2:setRotation(180)
			spread_3_position = ccp(0, -GamePlayConfig_Tile_Height)
		else
			positionSpread_2:setRotation(0)								--up
			spread_3_position = ccp(0, GamePlayConfig_Tile_Height)
		end
	end

	self.positionSpread_3 = Sprite:createWithSpriteFrameName("PoisonSpread_3_0000")
	self:addChild(self.positionSpread_3)
	self.positionSpread_3:setPosition(spread_3_position)
	self.positionSpread_3:setVisible(false)

	local function onVenomUnStable( ... )
		-- body
		if self.positionSpread_2 then 
			self.positionSpread_2:removeFromParentAndCleanup(true) 
			self.positionSpread_2 = nil 
		end
		self.positionSpread_3:setVisible(true)
		local frames_3 = SpriteUtil:buildFrames("PoisonSpread_3_%04d",1, 13)
		local animate_3 = SpriteUtil:buildAnimate(frames_3, kCharacterAnimationTime)
		self.positionSpread_3:play(animate_3, 0, 1, onAnimComplete)
	end
	positionSpread_2:play(animate_2, kCharacterAnimationTime * 9, 1, onVenomUnStable)

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayOctopusProduce )
end

function TilePoisonBottle:playDestroyAnimation()
	self.effectSprite:stopAllActions()

	local function onAnimationFinished()
		self:dp(Event.new(Events.kComplete, nil, sprite));
	end

	if self.spit_sprite then self.spit_sprite:removeFromParentAndCleanup(true) self.spit_sprite = nil end
	if self.venom_sprite then self.venom_sprite:removeFromParentAndCleanup(true) self.venom_sprite = nil end
	if self.effectSprite then self.effectSprite:removeFromParentAndCleanup(true) self.effectSprite = nil end
	onAnimationFinished()
end

function TilePoisonBottle:playForbiddenLevelAnimation(level, playAnim, callback)
	if level == 3 then
		self:playForbiddenLevelThree(playAnim, callback)
	elseif level == 2 then
		self:playForbiddenLevelTwo(playAnim, callback)
	elseif level == 1 then
		self:playForbiddenLevelOne(playAnim, callback)
	elseif level == 0 then
		self:playChangeToNormal(playAnim, callback)
	end
end

function TilePoisonBottle:playChangeToNormal(playAnim, callback)
	local ice_break = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("ice_break_%04d",1, 7), 1/20)
	
	self.effectSprite:removeFromParentAndCleanup(true)
	self.effectSprite = Sprite:createWithSpriteFrameName("PoisonBottle_Normal_0000")
	self.effectSprite:setPositionY(defaultPosY)
	self:addChild(self.effectSprite)
	self:playNormalAnimation()

	if playAnim then
		local animation = Sprite:createWithSpriteFrameName("ice_break_0000")
		local function localCallback()
			if animation then
				animation:removeFromParentAndCleanup(true)
			end
			if callback then
				callback()
			end
		end
		self:addChild(animation)
		animation:play(ice_break, 0, 1, localCallback)
		animation:runAction(CCMoveBy:create(7/20, ccp(0, -100)))
	else
		if callback then
			callback()
		end
	end
end

function TilePoisonBottle:playForbiddenLevelOne(playAnim, callback)
	local ice_break = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("ice_break_%04d",1, 7), 1/20)

	self.effectSprite:removeFromParentAndCleanup(true)
	self.effectSprite = Sprite:createWithSpriteFrameName("forbidden_1_0000")
	self.effectSprite:setPositionY(defaultPosY - 1.5)
	self:addChild(self.effectSprite)

	if playAnim then
		local animation = Sprite:createWithSpriteFrameName("ice_break_0000")
		local function localCallback()
			if animation then
				animation:removeFromParentAndCleanup(true)
			end		
			if callback then
				callback()
			end
		end
		self:addChild(animation)
		animation:play(ice_break, 0, 1, localCallback)
		animation:runAction(CCMoveBy:create(7/20, ccp(0, -100)))
	else
		if callback then
			callback()
		end
	end
end

function TilePoisonBottle:playForbiddenLevelTwo(playAnim, callback)
	local ice_break = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("ice_break_%04d",1, 7), 1/20)
	
	self.effectSprite:removeFromParentAndCleanup(true)
	self.effectSprite = Sprite:createWithSpriteFrameName("forbidden_2_0000")
	self.effectSprite:setPositionY(defaultPosY - 1.5)
	self:addChild(self.effectSprite)

	if playAnim then
		local animation = Sprite:createWithSpriteFrameName("ice_break_0000")
		local function localCallback()
			if animation then
				animation:removeFromParentAndCleanup(true)
			end		
			if callback then
				callback()
			end
		end
		self:addChild(animation)
		animation:play(ice_break, 0, 1, localCallback)
		animation:runAction(CCMoveBy:create(7/20, ccp(0, -100)))
	else
		if callback then
			callback()
		end
	end
end

function TilePoisonBottle:playForbiddenLevelThree(playAnim, callback)

	local function repeatFuc()
		if self.effectSprite then
			local forbidden3 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("forbidden_3_%04d",1, 29), 1/20)
			self.effectSprite:play(forbidden3, 0, 1)
		end
	end
	self.effectSprite:stopAllActions()
	self.effectSprite:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(repeatFuc), CCDelayTime:create(3))))

	if callback then
		callback()
	end
end