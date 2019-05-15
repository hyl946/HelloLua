
TileHoney = class(CocosObject)

local kCharacterAnimationTime = 1/30

-- local normalAnimationFrames = {21, 11}
local addAnimationFrames = {28, 18}
local disappearAnimationFrames = {19, 10}

function TileHoney:create(honeyLevel)
	-- printx(11, "TileHoney:create * * * * * honeyLevel * * * * *", honeyLevel)
	-- printx(11, "trace:", debug.traceback())
	local node = TileHoney.new(CCNode:create())
	node.name = "honey"
	node.honeyLevel = 1
	if honeyLevel then 
		node.honeyLevel = math.max(honeyLevel, 1) 
	end
	return node
end

function TileHoney:getLevelSuffix()
	local suffix = ""
	if self.honeyLevel and self.honeyLevel > 1 then
		suffix = self.honeyLevel.."_"
	end
	return suffix
end

function TileHoney:normal()
	-- body
	local assetPrefix = "honey_normal_"..self:getLevelSuffix()
	if not self.mainSprite then 
		self.mainSprite = Sprite:createWithSpriteFrameName(assetPrefix.."0000")
		self:addChild(self.mainSprite)
	end
	self.mainSprite:stopAllActions()

	if self.honeyLevel == 1 then
		local frames = SpriteUtil:buildFrames(assetPrefix.."%04d", 0 , 21)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.mainSprite:play(animate)
	else
		self:_startIdleAnimation(5)
	end
end

function TileHoney:_startIdleAnimation(delay)
    if not delay then delay = 0 end

    local function repeatFunc()
        self:_playIdleAnimation()
    end
    local function start()
        self:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(repeatFunc), CCDelayTime:create(5))))
    end
    self:stopAllActions()
    self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(start)))
end

function TileHoney:_playIdleAnimation()
    self.mainSprite:stopAllActions()

    local frames = SpriteUtil:buildFrames("honey_normal_"..self:getLevelSuffix().."%04d", 0, 11)
	local idleAnimation = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    self.mainSprite:play(idleAnimation, 0, 1)
end

function TileHoney:add( callback )
	local assetPrefix = "honey_add_"..self:getLevelSuffix()
	if not self.mainSprite then 
		self.mainSprite = Sprite:createWithSpriteFrameName(assetPrefix.."0000")
		self:addChild(self.mainSprite)
	end
	self.mainSprite:stopAllActions()
	local frames = SpriteUtil:buildFrames(assetPrefix.."%04d", 0 , addAnimationFrames[self.honeyLevel])
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.mainSprite:play(animate, 0, 1, callback)
end

function TileHoney:disappear( callback )
	-- body
	local assetPrefix = "honey_disappear_"..self:getLevelSuffix()
	if not self.mainSprite then 
		self.mainSprite = Sprite:createWithSpriteFrameName(assetPrefix.."0000")
		self:addChild(self.mainSprite)
	end
	self.mainSprite:stopAllActions()
	local frames = SpriteUtil:buildFrames(assetPrefix.."%04d", 0 , disappearAnimationFrames[self.honeyLevel])
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	if self.honeyLevel == 2 then
		self.mainSprite:setPosition(ccp(-115, 76))
	end
	self.mainSprite:play(animate, 0, 1, callback)
end

function TileHoney:createFlyAnimation( fromPos, toPos, callback)
	-- body
	local sprite = Sprite:createWithSpriteFrameName("light_track_0000")
	local frames = SpriteUtil:buildFrames("light_track_%04d", 0, 18)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sprite:play(animate)
	local rotation = 0
	if toPos.y - fromPos.y > 0 then
		rotation = math.deg(math.atan((toPos.x - fromPos.x)/(toPos.y - fromPos.y)))
	elseif toPos.y -fromPos.y < 0 then
		rotation = 180 + math.deg(math.atan((toPos.x - fromPos.x) / (toPos.y - fromPos.y)))
	else
		if toPos.x - fromPos.x > 0 then rotation = 90
		else
			rotation = -90
		end
	end
	sprite:setRotation(rotation)
	sprite:setPosition(fromPos)
	local actionList = CCArray:create()
	actionList:addObject(CCMoveTo:create(0.22, toPos))	--0.4
	actionList:addObject(CCCallFunc:create(callback))
	sprite:runAction(CCSequence:create(actionList))

	return sprite
end
