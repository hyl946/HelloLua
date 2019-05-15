---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-02-22 18:39:56
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-02-22 19:51:43
---------------------------------------------------------------------------------------
local TileDigJewel = class(Sprite)
local kCharacterAnimationTime = 1/30

function TileDigJewel:create(level, texture)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileDigJewel.new(sprite)
	node.parentTexture = texture

	-- if levelType == GameLevelType.kSummerWeekly then
	-- 	node.jewelType = JewelType.kIceCream
	-- end
	node:init(level)
	
	return node
end

local kGrassFrames = 22
local kAnimFramesConfig = {
	[1] = {110, 141},
	[2] = {46, 110},
	[3] = {0, 46},
}

function TileDigJewel:init(level)
	self.name = "digJewelTile"
	self.level = level
	
	self.grassSprite = Sprite:createWithSpriteFrameName("weekly_ingame/tile_grass_1_0000")
	self.grassSprite:setPosition(ccp(-3, 9))
	self:addChild(self.grassSprite)

	local framesCfg = kAnimFramesConfig[level] or kAnimFramesConfig[1]
	local frameName = string.format("weekly_ingame/tile_grass_item_%04d", framesCfg[1])
	self.itemSprite = Sprite:createWithSpriteFrameName(frameName)
	-- self.itemSprite:setScale(0.9)
	self.itemSprite:setPosition(ccp(-2, 3))
	self:addChild(self.itemSprite)
end

function TileDigJewel:changeLevel( level, callback )
	self.level = level
	local oriLevel = level + 1

	local framesCfg = kAnimFramesConfig[oriLevel]
	if framesCfg then
		local begin = framesCfg[1]
		local length = framesCfg[2] - framesCfg[1]
		local frames = SpriteUtil:buildFrames("weekly_ingame/tile_grass_item_%04d", begin, length)
		local anim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.itemSprite:stopAllActions()
		if callback and type(callback) == "function" then 
			self.itemSprite:play(anim, 0, 1, callback)
		else
			self.itemSprite:play(anim, 0, 1)
		end

		if level == 0 and self.grassSprite then 
			local frames = SpriteUtil:buildFrames("weekly_ingame/tile_grass_1_%04d", 0, kGrassFrames)
			local grassAnim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
			local delay = CCDelayTime:create(10*kCharacterAnimationTime)
			self.grassSprite:runAction(CCSequence:createWithTwoActions(delay, grassAnim))
		end
	end
end

return TileDigJewel