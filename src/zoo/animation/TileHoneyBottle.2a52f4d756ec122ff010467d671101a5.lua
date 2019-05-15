
TileHoneyBottle = class(CocosObject)

local kCharacterAnimationTime = 1/30
local AnimationFrames = {24, 21, 5}

function TileHoneyBottle:create(level)
	local node = TileHoneyBottle.new(CCNode:create())
	node.name = "honey_bottle"
	node.level = level
	node.targetLevel = level
	node:init()
	return node
end

function TileHoneyBottle:init( ... )
	-- body
	if self.level <= 3 then
		local mainSprite = Sprite:createWithSpriteFrameName("honey_bottle_"..self.level.."_0000")
		self.mainSprite = mainSprite
		self:addChild(mainSprite)
	else
		self.mainSprite = Sprite:createWithSpriteFrameName("honey_bottle_3_0000")
		self:addChild(self.mainSprite)
		local frames = SpriteUtil:buildFrames("honey_bottle_3_%04d", 0, AnimationFrames[3])
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.mainSprite:play(animate)
	end
	
end

function TileHoneyBottle:playIncreaseComplete( ... )
	-- body
	self.level = self.level + 1
	if self.targetLevel > self.level then
		self:_playIncreaseAnimation()
	else
		self.isPlaying = false
	end
end

function TileHoneyBottle:_playIncreaseAnimation( ... )
	-- body
	self.isPlaying = true
	local function animationCallBack( ... )
		-- body
		self:playIncreaseComplete()
	end

	local frames = SpriteUtil:buildFrames("honey_bottle_"..self.level.."_%04d", 0, AnimationFrames[self.level])
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	if self.level < 3 then
		self.mainSprite:play(animate, 0, 1, animationCallBack)
	else
		self.mainSprite:play(animate)
		animationCallBack()
	end

end

function TileHoneyBottle:playIncreaseAnimation( times )
	-- body
	self.targetLevel = self.targetLevel + times
	if not self.isPlaying then
		self:_playIncreaseAnimation()
	end
end

function TileHoneyBottle:playBrokenAnimation( callback )
	-- body
	if not self.mainSprite then 
		self.mainSprite = Sprite:createWithSpriteFrameName("honey_bottle_4_0000")
		self:addChild(mainSprite)
	end
	self.mainSprite:stopAllActions()
	local frames = SpriteUtil:buildFrames("honey_bottle_4_%04d", 0, 21)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.mainSprite:play(animate, 0, 1, callback)
end
