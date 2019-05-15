---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-01 11:34:57
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-04 20:53:58
---------------------------------------------------------------------------------------
local kSpriteOffsetByLevel = {}
kSpriteOffsetByLevel[1] = {x= 1, y = -1.5}
kSpriteOffsetByLevel[2] = {x= 6, y = 12}
kSpriteOffsetByLevel[3] = {x= 3.5, y = 9}
kSpriteOffsetByLevel[4] = {x= 2.5, y = 8}
TileOlympicLock = class(Sprite)

--local kSpriteScale = 0.93
local kSpriteScale = 1

function TileOlympicLock:ctor()

end

function TileOlympicLock:create(level)
	local node = TileOlympicLock.new(CCSprite:create())
	node:init(level)
	return node 
end

function TileOlympicLock:init(level)
	self:updateLevel(level)
	self:setTexture(self.sprite:getTexture())
end

function TileOlympicLock:updateLevel(level)
	assert(level > 0 and level < 5)
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	local sprite = Sprite:createWithSpriteFrameName(string.format("ZQ_lock_lv%d_0001", level))
	sprite:setScale(kSpriteScale)
	self:addChild(sprite)
	self.sprite = sprite
	local offsetPos = kSpriteOffsetByLevel[level]
	if offsetPos then
		self.sprite:setPosition(ccp(offsetPos.x, offsetPos.y))
	end
end

function TileOlympicLock:playDecAnimation( level, callback )
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	self.sprite = self:buildDecAnimation(level, callback)
	self.sprite:setScale(kSpriteScale)
	self:addChild(self.sprite)
	local offsetPos = kSpriteOffsetByLevel[level]
	if offsetPos then
		self.sprite:setPosition(ccp(offsetPos.x, offsetPos.y))
	end
end

function TileOlympicLock:buildDecAnimation( level, callback )
	assert(level > 0 and level < 5)
	local lengthByLevel = {}
	lengthByLevel[1] = 28
	lengthByLevel[2] = 18
	lengthByLevel[3] = 17
	lengthByLevel[4] = 19

	local sprite, animate = SpriteUtil:buildAnimatedSprite(1/30, "ZQ_lock_lv"..tostring(level).."_%04d", 1 , lengthByLevel[level], false)
	sprite:play(animate, 0, 1, callback, false)
	return sprite
end
