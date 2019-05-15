---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2017-09-04 15:11:29
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-14 10:59:53
---------------------------------------------------------------------------------------
TileNationDayStar = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileNationDayStar:create()
	local node = TileNationDayStar.new(CCNode:create())
	node.name = "coin"

	local effectSprite = Sprite:createWithSpriteFrameName("nationday_star_0000")
	-- local frames = SpriteUtil:buildFrames("nationday_star_%04d", 0, 30)
	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- effectSprite:play(animate, 0, 0)
	effectSprite:setScale(0.95)
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	return node
end

function TileNationDayStar:playDestroyAnimation(flyToPos)
	self.effectSprite:runAction(CCFadeOut:create(0.5))
	-- local frames = SpriteUtil:buildFrames("coin_destroy%02d", 0, 12)
	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- self.effectSprite:play(animate, 0, 1)
end