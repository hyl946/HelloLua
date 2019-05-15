require "hecore.display.Director"

TileCharacter = class(CocosObject)

local kTileContentSize = 65
local kResourcePrefix = "flash/"
local kCharacterAnimationTime = 1/24
local kCharacterSelectAnimationNum = 30
local kCharacterNormalAnimationNum = 50
local kCharacterLinearAnimationNum = 29
local kCharacterWrapperAnimationNum = 49
local kCharacterDestroyAnimationNum = 27

function TileCharacter:toString()
	return string.format("TileCharacter [%s]", self.name and self.name or "nil");
end

function TileCharacter:create( name )
	local pngName = SpriteUtil:getRealResourceName(GamePlayResourceConfig:getCharacterSpriteSheetName(name));
	
	local node = TileCharacter.new(CCNode:create())
	node.name = name

	-- local hitArea = CocosObject:create()
	-- hitArea.name = kHitAreaObjectName
	-- hitArea:setContentSize(CCSizeMake(kTileContentSize, kTileContentSize))
	-- node:addChild(hitArea)

	local baseNode = CocosObject:create()
	baseNode:setRefCocosObj(CCSpriteBatchNode:create(pngName, 4));
	node:addChild(baseNode);

	local config = GamePlayResourceConfig:getCharacterAnimationConfig(name, kTileCharacterAnimation.kSelect)
  	local mainSprite = Sprite:createWithSpriteFrameName(string.format(config.pattern, 0))

  	baseNode:addChild(mainSprite)
  	baseNode.name = "baseNode"
  	node:addChild(baseNode)

  	node.mainSprite = mainSprite

  	return node
end

function TileCharacter:createCharactorSprite(name, specialType)
	local config = nil
	if specialType == AnimalTypeConfig.kLine then
	  	config = GamePlayResourceConfig:getCharacterAnimationConfig(name, kTileCharacterAnimation.kLineRow)
	elseif specialType == AnimalTypeConfig.kColumn then
	  	config = GamePlayResourceConfig:getCharacterAnimationConfig(name, kTileCharacterAnimation.kLineColumn)
	elseif specialType == AnimalTypeConfig.kWrap then
	  	config = GamePlayResourceConfig:getCharacterAnimationConfig(name, kTileCharacterAnimation.kWrap)
	else
		config = GamePlayResourceConfig:getCharacterAnimationConfig(name, kTileCharacterAnimation.kSelect)
	end
	if config then
		return Sprite:createWithSpriteFrameName(string.format(config.pattern, 0))
	end
	return nil
end

function TileCharacter:play( animation, delayTime )
	self:stopAllAnimations()

	if animation == kTileCharacterAnimation.kNormal then self:playNormalAnimation()
	elseif animation == kTileCharacterAnimation.kSelect then self:playDirectionAnimation(animation)
	elseif animation == kTileCharacterAnimation.kUp then self:playDirectionAnimation(animation)
	elseif animation == kTileCharacterAnimation.kDown then self:playDirectionAnimation(animation)
	elseif animation == kTileCharacterAnimation.kLeft then self:playDirectionAnimation(animation)
	elseif animation == kTileCharacterAnimation.kRight then self:playDirectionAnimation(animation) 
	elseif animation == kTileCharacterAnimation.kLineColumn then self:playLineAnimation(animation) 
	elseif animation == kTileCharacterAnimation.kLineRow then self:playLineAnimation(animation) 
	elseif animation == kTileCharacterAnimation.kWrap then self:playWrapAnimation(animation, delayTime)
	elseif animation == kTileCharacterAnimation.kDestroy then self:playDestroyAnimation()
	end
end

function TileCharacter:stopAllAnimations()
	if self.mainSprite then self.mainSprite:setVisible(false) end;

	if self.mainSprite then self.mainSprite:stopAllActions() end;
end

function TileCharacter:playNormalAnimation()
	return;
end

function TileCharacter:playSelectAnimation()
  	local context = self
  	local config = GamePlayResourceConfig:getCharacterAnimationConfig(self.name, kTileCharacterAnimation.kSelect)
	local pattern = config.pattern
	local frame = config.frame
	local adjustPos = config.adjustPos
  	local function playAnim()
		local frames = SpriteUtil:buildFrames(pattern, 0, frame)
	  	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
  		context.mainSprite:play(animate, 0, 1)
  	end

  	local sequenceAction = CCSequence:createWithTwoActions(CCCallFunc:create(playAnim), CCDelayTime:create(2))
  	self.mainSprite:removeFromParentAndCleanup(true)
	self.mainSprite = Sprite:createWithSpriteFrameName(string.format(pattern, 0))
	-- self.mainSprite:setScale(1.0286)
	self:addChild(self.mainSprite)
	if adjustPos then
		self.mainSprite:setPosition(ccp(adjustPos.x, adjustPos.y))
	end
  	self.mainSprite:runAction(CCRepeatForever:create(sequenceAction))
end

function TileCharacter:stopSelectAnimation()
	if self.mainSprite then
		self.mainSprite:setPosition(ccp(0, 0))
		self.mainSprite:stopAllActions()
	end
end

---取消方向动画
function TileCharacter:playDirectionAnimation(animation)
	return;
	-- if self.name == "fox" then 
	-- 	self:playNormalAnimation()
	-- 	return
	-- end

	-- self.mainSprite:setVisible(true)

	-- local pattern = self.name
	-- if animation == kTileCharacterAnimation.kSelect then pattern = pattern.."_select%04d"
	-- elseif animation == kTileCharacterAnimation.kUp then pattern = pattern.."_up%04d"
	-- elseif animation == kTileCharacterAnimation.kDown then pattern = pattern.."_down%04d"
	-- elseif animation == kTileCharacterAnimation.kLeft then pattern = pattern.."_left%04d"
	-- elseif animation == kTileCharacterAnimation.kRight then pattern = pattern.."_right%04d" end

	-- local number = kCharacterNormalAnimationNum
	-- if animation == kTileCharacterAnimation.kSelect then number = kCharacterSelectAnimationNum end
	-- local frames = SpriteUtil:buildFrames(pattern, 0, number)
 --  	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
 --  	self.mainSprite:play(animate)
end

function TileCharacter:playLineAnimation( animation )
	self.mainSprite:setVisible(true)

  	local config = GamePlayResourceConfig:getCharacterAnimationConfig(self.name, animation)
	local characterPattern = config.pattern
	local frame = config.frame
	local adjustPos = config.adjustPos

	self.mainSprite:removeFromParentAndCleanup(true)
	self.mainSprite = Sprite:createWithSpriteFrameName(string.format(characterPattern, 0))
	self:addChild(self.mainSprite)

	local frames = SpriteUtil:buildFrames(characterPattern, 0, frame)
  	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
  	self.mainSprite:play(animate)

  	local effectPattern = "animal_direction_%04d"
  	local eframes = SpriteUtil:buildFrames(effectPattern, 0, 19)
  	local eanimate1 = SpriteUtil:buildAnimate(eframes, kCharacterAnimationTime)
  	local eanimate2 = SpriteUtil:buildAnimate(eframes, kCharacterAnimationTime)

  	local part1 = Sprite:createWithSpriteFrameName("animal_direction_0000");
  	local part2 = Sprite:createWithSpriteFrameName("animal_direction_0000");

  	part1:play(eanimate1);
  	part2:play(eanimate2);

	local baseNode = CocosObject:create()
	baseNode:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/board_effects.png"), 4));
	baseNode.name = "tileEffect"
	self:addChild(baseNode);

	if animation == kTileCharacterAnimation.kLineRow then 
		baseNode:setRotation(90);
		baseNode:setPosition(ccp(0,0));
	end
	baseNode:addChild(part1);
	baseNode:addChild(part2);

	part1:setPosition(ccp(0, 34))
	part2:setPosition(ccp(0, -34))

	part2:setFlipY(true);
end

function TileCharacter:playWrapAnimation(animation, delayTime)
	self.mainSprite:setVisible(true)

  	local config = GamePlayResourceConfig:getCharacterAnimationConfig(self.name, animation)
	local characterPattern = config.pattern
	local frame = config.frame
	local adjustPos = config.adjustPos

	self.mainSprite:removeFromParentAndCleanup(true)
	self.mainSprite = Sprite:createWithSpriteFrameName(string.format(characterPattern, 0))
	self.mainSprite.name = "mainSprite"
	self:addChild(self.mainSprite)
	
	local frames = SpriteUtil:buildFrames(characterPattern, 0, frame)
  	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
  	self.mainSprite:play(animate)

	local effectSprite = Sprite:createWithSpriteFrameName("animal_wrap_effect_0000")
	local effectFrames = SpriteUtil:buildFrames("animal_wrap_effect_%04d", 0, 21)
  	local effectAnimate = SpriteUtil:buildAnimate(effectFrames, kCharacterAnimationTime)
	effectSprite.name = "tileEffect"
  	effectSprite:play(effectAnimate)
  	self:addChild(effectSprite)
end

function TileCharacter:playDestroyAnimation()
	--self.destroySprite:setVisible(true)
	--local frames = SpriteUtil:buildFrames(self.name.."_destroy%04d", 0, kCharacterDestroyAnimationNum)
  	--local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

 --  	local function onRepeatFinishCallback()
 --  		self:dp(Event.new(Events.kComplete, kTileCharacterAnimation.kDestroy, self))
 --  		self:removeFromParentAndCleanup(true);				----将自己从父节点删除
 --  	end 
 --  	self:addChild(destroySprite);

 --  	local destroySprite = Sprite:createWithSpriteFrameName("destroy_effect_0.png")
	-- local frames = SpriteUtil:buildFrames("destroy_effect_%d.png", 0, 20)
 --  	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- destroySprite:play(animate, 0, 1, onRepeatFinishCallback)

  	--self.destroySprite:play(animate, 0, 1, onRepeatFinishCallback)
end