---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-02-22 18:40:18
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-02-22 20:07:35
---------------------------------------------------------------------------------------
local TileDigGround = class(Sprite)
local kCharacterAnimationTime = 1/30

local kAnimFrames = {
	[1] = 22,
	[2] = 44,
	[3] = 22,
}
local kItemOffsets = {
	[1] = {-3, 9},
	[2] = {-0.5, 8},
	[3] = {-0, 9.5},
}

function TileDigGround:create(level, texture)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileDigGround.new(sprite)
	node.parentTexture = texture
	node:init(level)
	return node
end

function TileDigGround:init(level)
	self.name = "digGroundTile"
	self.level = level
	self:initSprite(level)
end

function TileDigGround:initSprite( level )
	local frameName = string.format("weekly_ingame/tile_grass_%d_0000", level)
	self.grassSprite = Sprite:createWithSpriteFrameName(frameName)
	self:addChild(self.grassSprite)
	local offset = kItemOffsets[level]
	if offset then
		self.grassSprite:setPosition(ccp(offset[1], offset[2]))
	end
end

function TileDigGround:changeLevel( level, callback )
	self.level = level
	local oriLevel = level + 1
	if self.grassSprite and kAnimFrames[oriLevel] then
		local pattern = string.format("weekly_ingame/tile_grass_%d", oriLevel).."_%04d"
		local frames = SpriteUtil:buildFrames(pattern, 0, kAnimFrames[oriLevel])
		local anim = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		local offset = kItemOffsets[oriLevel]
		if offset then
			self.grassSprite:setPosition(ccp(offset[1], offset[2]))
		end
		self.grassSprite:stopAllActions()
		self.grassSprite:play(anim, 0, 1, callback)
	end
end

--------------------
--pm2.5生成地块的动画 -- 没有了
--------------------
function TileDigGround:createDigGroundAnimation(midcallback, completeCallback)
	return nil
end

return TileDigGround
