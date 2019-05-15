---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-19 18:20:28
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-02-02 18:36:58
---------------------------------------------------------------------------------------
TileCoinLikeA = class(CocosObject)

local kCharacterAnimationTime = 1/30

local kSpriteNames = {
	{name="sp2018_coin_1",offsetX=7,offsetY=-7},
	{name="sp2018_coin_2",offsetX=7,offsetY=-7},
	{name="sp2018_coin_3",offsetX=3,offsetY=-7},
	{name="sp2018_coin_6",offsetX=1,offsetY=-7},
	{name="sp2018_coin_5",offsetX=3,offsetY=-7},
	{name="sp2018_coin_4",offsetX=3,offsetY=-2},
}

function TileCoinLikeA:create()
	local t = _G.SPRING2018_COLLECTION_TYPE or 1
	local node = TileCoinLikeA.new(CCNode:create())
	node.name = "coin"

	local cfg = kSpriteNames[t]
	local effectSprite = Sprite:createWithSpriteFrameName(cfg.name)
	effectSprite:setPosition(ccp(cfg.offsetX, cfg.offsetY))
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	return node
end

function TileCoinLikeA:playDestroyAnimation()
	local breakSprite, animate = SpriteUtil:buildAnimatedSprite(kCharacterAnimationTime, "sp2018_break_effect_%04d", 0, 20)
	breakSprite:play(animate, 0, 1)
	self:addChild(breakSprite)
	self.effectSprite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(kCharacterAnimationTime*5,0.42), CCHide:create()))
end
