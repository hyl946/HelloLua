
TileVenom = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileVenom:create()
	local node = TileVenom.new(CCNode:create())
	node.name = "venom"

	local effectSprite = Sprite:createWithSpriteFrameName("venom0000")
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	return node
end

function TileVenom:playNormalAnimation()
	local frames = SpriteUtil:buildFrames("venom%04d", 0, 19)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.effectSprite:play(animate)
end

function TileVenom:playTempInvisibleAnimation()
	self.effectSprite:setVisible(false)
end

function TileVenom:playRevertVisibleAnimation()
	self.effectSprite:setVisible(true)
end

function TileVenom:playDirectionAnimation(direction)
	local dirString = ""
	if direction.x > 0 then
		dirString = "right"
		self.effectSprite:setPosition(ccp(27, 1))
	elseif direction.x < 0 then
		dirString = "left"
		self.effectSprite:setPosition(ccp(-34, 0))
	else
		if direction.y > 0 then
			dirString = "down"
			self.effectSprite:setPosition(ccp(0, -35))
		else
			dirString = "up"
			self.effectSprite:setPosition(ccp(1, 33))
		end
	end

	local function onAnimComplete()
		self:dp(Event.new(Events.kComplete, animation, self))
	end

	local frames = SpriteUtil:buildFrames("venom_" .. dirString .. "%04d", 4, 17)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.effectSprite:play(animate, 0, 1, onAnimComplete)
end

function TileVenom:playDestroyAnimation()
	self.effectSprite:stopAllActions()
	self.effectSprite:setVisible(false)

	local function onAnimationFinished()
		self:dp(Event.new(Events.kComplete, nil, sprite));
	end

	local destroySprite = Sprite:createWithSpriteFrameName("venom_destroy0000")
	self.destroySprite = destroySprite
	self:addChild(destroySprite)

	local frames = SpriteUtil:buildFrames("venom_destroy%04d", 0, 13)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	destroySprite:play(animate, 0, 1, onAnimationFinished)

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPoisonClear )
end