TileBlackCuteBall = class(CocosObject)

local kCharacterAnimationTime = 1/30

-- common: 普通黑毛球，有两条命
-- fragile: 一条命的毛球，外形是银灰色小鸟
BlackCuteBallType = table.const
{
    COMMON = 1,
    FRAGILE = 2,
}

local assetPrefixCommon = "black_cute_ball_"
local assetPrefixFragile = "mole_fragile_cuteball_"

local fragileAnimationYShift = 15

function TileBlackCuteBall:create(strength, maxStrength)
	local s = TileBlackCuteBall.new(CCNode:create())
	s.type = BlackCuteBallType.COMMON
	if maxStrength == 1 then
		s.type = BlackCuteBallType.FRAGILE
	end
	s.animation = Sprite:createWithSpriteFrameName(s:getAssetPrefix()..strength.."_0000")
	s:addChild(s.animation)
	if strength >= 2 then
		local function callback( ... )
			s:playLife2()
		end 
		s:playLifeP1(callback)
	elseif strength == 1 then
		s:playLife1()
	end
	return s
end

function TileBlackCuteBall:removeOldAnimation()
	if self.animation and not self.animation.isDisposed then
		self.animation:removeFromParentAndCleanup(true)
		self.animation = nil
	end
end

function TileBlackCuteBall:preparationsBeforeNewAnimation(newAssetName)
	if self.type == BlackCuteBallType.FRAGILE then
		self:removeOldAnimation()
		self.animation = Sprite:createWithSpriteFrameName(newAssetName)
		self.animation:setPosition(ccp(0, fragileAnimationYShift))
		self:addChild(self.animation)
	else
		self.animation:stopAllActions()
	end
end

function TileBlackCuteBall:getAssetPrefix()
	if self.type == BlackCuteBallType.FRAGILE then
		return assetPrefixFragile
	else
		return assetPrefixCommon
	end
end

function TileBlackCuteBall:playLife2(callback)
	self.animation:stopAllActions()
	local frames = SpriteUtil:buildFrames(assetPrefixCommon.."2_%04d", 0, 1)	--fragile没有二级状态
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.animation:play(animate)
	if callback then callback() end
end

function TileBlackCuteBall:playLife1( callback )
	self.animation:stopAllActions()
	local frameCount
	if self.type == BlackCuteBallType.COMMON then frameCount = 28 else frameCount = 1 end
	local frames = SpriteUtil:buildFrames(self:getAssetPrefix().."1_%04d", 0, frameCount)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.animation:play(animate)

	if callback then callback() end
end

function TileBlackCuteBall:playLife0( callback )
	self:preparationsBeforeNewAnimation(self:getAssetPrefix().."0_0000")
	local frameCount
	if self.type == BlackCuteBallType.COMMON then frameCount = 34 else frameCount = 24 end
	local frames = SpriteUtil:buildFrames(self:getAssetPrefix().."0_%04d", 0, frameCount)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.animation:play(animate, 0, 1, callback)
end

function TileBlackCuteBall:playLifeP1( callback )
	self.animation:stopAllActions()
	local frames = SpriteUtil:buildFrames(assetPrefixCommon.."p1_%04d", 0, 29)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.animation:play(animate, 0, 1, callback)
end

function TileBlackCuteBall:playJump0( callback )
	self:preparationsBeforeNewAnimation(self:getAssetPrefix().."jump0_0000")
	local frameCount
	if self.type == BlackCuteBallType.COMMON then frameCount = 5 else frameCount = 15 end
	local frames = SpriteUtil:buildFrames(self:getAssetPrefix().."jump0_%04d", 0, frameCount)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.animation:play(animate, 0, 1, callback)
end

function TileBlackCuteBall:playJump1(  callback )
	self:preparationsBeforeNewAnimation(self:getAssetPrefix().."jump1_0000")
	local frames 
	if self.type == BlackCuteBallType.COMMON then
		frames = SpriteUtil:buildFrames(self:getAssetPrefix().."jump1_%04d", 11, 18)
	else
		frames = SpriteUtil:buildFrames(self:getAssetPrefix().."jump1_%04d", 0, 23)
	end
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.animation:play(animate, 0, 1, callback)
end

function TileBlackCuteBall:playJumpToAnimation( toPosition,midcallback, callback )
	local function endJumpCallback( ... )
		if callback then callback() end
	end

	local function jumppingCallback( ... )
		self:playJump1(endJumpCallback)
		if midcallback then midcallback() end
	end

	local function startJumpCallback( ... )
		if self.type == BlackCuteBallType.FRAGILE then
			self:playLife1()
		else
			self:playLife2()
		end
		local fromPos = self:getPosition()
		if self.type == BlackCuteBallType.FRAGILE then 
			fromPos.y = fromPos.y + fragileAnimationYShift
		end
		local jumpHeight = math.abs(toPosition.y - fromPos.y) /2 + GamePlayConfig_Tile_Height * 1.5
		local actionList  = CCArray:create()
		actionList:addObject(CCJumpTo:create(0.5, toPosition, jumpHeight, 1))
		actionList:addObject(CCCallFunc:create(jumppingCallback))
		self:runAction(CCSequence:create(actionList))
	end  
	self:playJump0(startJumpCallback)
end