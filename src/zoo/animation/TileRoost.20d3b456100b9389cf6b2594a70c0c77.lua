
TileRoost = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileRoost:create(level)
	local node = TileRoost.new(CCNode:create())
	node.name = "roost"

	-- local effectSprite = Sprite:createWithSpriteFrameName("roost_1_level_0000")
	local effectSprite = TileRoost._getInitSprite(level)
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	node.level = level
	node.targetLevel = level
	node.isPlaying = false

	return node
end

local frameNumLevel0 = 19
local frameNumLevel1 = 65
local frameNumLevel2 = 25
local frameNumLevel3 = 35
local frameNumReplace = 36
local frameNumReplaceEffect = 36

function TileRoost._getInitSprite(level)
	local numFrames = 0
	local pos = nil
	local frameLevel = level
	if level == 1 then 
		numFrames = frameNumLevel1
		pos = ccp(0, -1)
	elseif level == 2 then 
		numFrames = frameNumLevel2
		pos = ccp(0, 8.7)
	elseif level == 3 or level == 4 then 
		numFrames = frameNumLevel3
		pos = ccp(0, -3.2)
		frameLevel = 3
	end

	local characterPattern = "roost_" .. frameLevel .. "_level_%04d"
	effectSprite = Sprite:createWithSpriteFrameName(string.format(characterPattern, 0))
	effectSprite:setPosition(pos)
	if level == 4 then
		local frames = SpriteUtil:buildFrames(characterPattern, 0, numFrames)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		effectSprite:play(animate, 0, 0)
	end
	return effectSprite
end

function TileRoost:_playUpgradeAnimation(level)
	self.isPlaying = true

	local context = self
	local function playAnimComplete()
		if level > 0 then
			context:playUpgradeAnimationComplete()
		else
			--self.isPlaying = false
			context:playUpgradeAnimationComplete()
		end
	end

	local numFrames = 0
	local repeatTimes = 1
	local pos = nil
	local soundName = nil
	if level == 0 then 
		numFrames = frameNumLevel0
		pos = ccp(0, -3)
		soundName = string.format(GameMusicType.kRoostUpgrade, 0)
	elseif level == 1 then 
		numFrames = frameNumLevel1
		pos = ccp(0, -1)
		soundName = string.format(GameMusicType.kRoostUpgrade, 1)
	elseif level == 2 then 
		numFrames = frameNumLevel2
		pos = ccp(0, 8.7)
		soundName = string.format(GameMusicType.kRoostUpgrade, 2)
	elseif level == 3 then 
		numFrames = frameNumLevel3
		repeatTimes = 0
		pos = ccp(0, -3.2)
	end

	local characterPattern = "roost_" .. level .. "_level_%04d"
	local frames = SpriteUtil:buildFrames(characterPattern, 0, numFrames)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.effectSprite:removeFromParentAndCleanup(true)
	self.effectSprite = Sprite:createWithSpriteFrameName(string.format(characterPattern, 0))
	self:addChild(self.effectSprite)
	self.effectSprite:setPosition(pos)
	self.effectSprite:play(animate, 0, repeatTimes, playAnimComplete)

	if soundName then GamePlayMusicPlayer:playEffect(soundName) end
end

function TileRoost:playUpgradeAnimationComplete()

	self.level = self.level + 1
	if self.targetLevel > self.level then
		self:_playUpgradeAnimation(self.level)
	else
		self.isPlaying = false
	end
end

function TileRoost:playUpgradeAnimation(times)
	self.targetLevel = self.targetLevel + times
	if not self.isPlaying then
		self:_playUpgradeAnimation(self.level)
	end
end

function TileRoost:playReplaceAnimation()
	-- self.targetLevel = 1
	-- self.level = 1
	self.targetLevel = 0
	self.level = 0

	local context = self
	local function playReplaceComplete()
		self:dp(Event.new(Events.kComplete, nil, self));
		--self:_playUpgradeAnimation(0)
		self.isPlaying = false
		self:playUpgradeAnimation(1)
	end

	local pos = ccp(-3.5, 0.5)
	local characterPattern = "roost_replace_%04d"
	local replaceFrames = SpriteUtil:buildFrames("roost_replace_%04d", 0, frameNumReplace)
	local replaceAnimate = SpriteUtil:buildAnimate(replaceFrames, kCharacterAnimationTime)
	self.effectSprite:removeFromParentAndCleanup(true)
	self.effectSprite = Sprite:createWithSpriteFrameName(string.format(characterPattern, 0))
	self:addChild(self.effectSprite)
	self.effectSprite:stopAllActions()
	self.effectSprite:setPosition(pos)
	self.effectSprite:play(replaceAnimate, 0, 1, playReplaceComplete)
	local soundName = string.format(GameMusicType.kRoostUpgrade, 3)
	GamePlayMusicPlayer:playEffect(soundName)
end

function TileRoost:createFlyEffect()
	local node
	local function animationComplete()
		node:dp(Event.new(Events.kComplete, nil, node))
	end

	node = TileRoost.new(CCNode:create())
	node.name = "roostEffect"
	
	local effectSprite = Sprite:createWithSpriteFrameName("roost_replace_effect_0000")
	node.effectSprite = effectSprite
	effectSprite:setPosition(ccp(-5, -3))
	node:addChild(effectSprite)

	local frames = SpriteUtil:buildFrames("roost_replace_effect_%04d", 0, frameNumReplaceEffect)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	node.effectSprite:play(animate, 0, 1, animationComplete)

	return node
end