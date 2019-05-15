TileChameleon = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileChameleon:create()
	local node = TileChameleon.new(CCNode:create())
	node.name = "chameleon"

	local itemSprite = Sprite:createWithSpriteFrameName("blocker_chameleon_idle_0000")
	node.itemSprite = itemSprite
	node.itemSprite:setPosition(ccp(0, -5))
	node:addChild(itemSprite)

	-- node:init()

	-- pirntx(11, "Chameleon sprite created")

	return node
end

--去掉待机动画
-- function TileChameleon:init()
--     self:_startIdleAnimation(5)
-- end

-- function TileChameleon:_startIdleAnimation(delay)
--     if not delay then delay = 0 end

--     local function repeatFunc()
--         self:_playIdleAnimation()
--     end
--     local function start()
--         self:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(repeatFunc), CCDelayTime:create(5))))
--     end
--     self:stopAllActions()
--     self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(start)))
-- end

-- function TileChameleon:_playIdleAnimation()
--     self.itemSprite:stopAllActions()

--     local frames = SpriteUtil:buildFrames("blocker_chameleon_idle_%04d", 0, 10)
-- 	local idleAnimation = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
-- 	-- self.itemSprite:play(idleAnimation)
--     self.itemSprite:play(idleAnimation, 0, 1)
--     -- self.itemSprite:setVisible(true)
-- end

function TileChameleon:playChameleonBlastAnimation(callback)
	self.itemSprite:stopAllActions()
	self.itemSprite:setVisible(false)

	-- local function onAnimationFinished()
	-- 	self:dp(Event.new(Events.kComplete, nil, sprite));
	-- end

	local destroySprite = Sprite:createWithSpriteFrameName("blocker_chameleon_blast_0000")
	self.destroySprite = destroySprite
	destroySprite:setPosition(ccp(-5, -3))
	self:addChild(destroySprite)

	local frames = SpriteUtil:buildFrames("blocker_chameleon_blast_%04d", 0, 16)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	destroySprite:play(animate, 0, 1, callback)
end