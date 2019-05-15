--=====================================================
-- TileColorFilterA 
-- by zhijian.li
-- (c) copyright 2009 - 2017, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  TileColorFilter.lua 
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2017/06/15
-- descrip:   色彩过滤器 A状态
--=====================================================

TileColorFilterA = class(CocosObject)
local kCharacterAnimationTime = 1/24

function TileColorFilterA:create(colorIndex)
	local node = TileColorFilterA.new(CCNode:create())
	node.name = 'color_filterA'
	node.colorIndex = colorIndex

	node:init()
	return node
end

function TileColorFilterA:init()
	self.bg = Sprite:createWithSpriteFrameName("fiter_a_bg_"..self.colorIndex)
	self:addChild(self.bg)
end

function TileColorFilterA:playFilter()
	if self.lightAni then 
		self.lightAni:removeFromParentAndCleanup(true)
		self.lightAni = nil
	end
	local bg = Sprite:createWithSpriteFrameName("filter_action_bg_"..self.colorIndex)
	local bgSize = bg:getContentSize()
	bg:setOpacity(84)
	self:addChild(bg)
	local light = Sprite:createWithSpriteFrameName("filter_action_light_"..self.colorIndex)
	light:setOpacity(0)
	bg:addChild(light)
	light:setPosition(ccp(bgSize.width/2, bgSize.height/2))

	self.lightAni = bg
	self:addChild(self.lightAni)

	local arr1 = CCArray:create()
	arr1:addObject(CCFadeTo:create(kCharacterAnimationTime*1.6, 255))
	arr1:addObject(CCFadeTo:create(kCharacterAnimationTime*12, 0))
	arr1:addObject(CCCallFunc:create(function ()
		self.lightAni:removeFromParentAndCleanup(true)
		self.lightAni = nil
	end))
	bg:runAction(CCSequence:create(arr1))

	local arr2 = CCArray:create()
	arr2:addObject(CCFadeTo:create(kCharacterAnimationTime*1.6, 255))
	arr2:addObject(CCDelayTime:create(kCharacterAnimationTime*9.6))
	arr2:addObject(CCFadeTo:create(kCharacterAnimationTime*2.4, 0))
	light:runAction(CCSequence:create(arr2))
end