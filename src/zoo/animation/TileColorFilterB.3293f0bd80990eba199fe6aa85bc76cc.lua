--=====================================================
-- TileColorFilterB 
-- by zhijian.li
-- (c) copyright 2009 - 2017, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  TileColorFilter.lua 
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2017/06/15
-- descrip:   色彩过滤器 B状态
--=====================================================

local DecPosAdjust = {
	{x = 0, y = 2},
	{x = 8, y = 7},
	{x = -5, y = 3},
	{x = 0.5, y = 6},
	{x = 0.5, y = 13},
}

local DisappearPosAdjust = {
	{x = 0, y = 2},
	{x = 8, y = 7},
	{x = -5, y = 3},
	{x = 0.5, y = 6},
	{x = 0.5, y = 13},
}

local LightOriPos = {x = -1, y = 5}

local FramesInfo = {
	{frames = "filter_b_1to0_%04d", first = "filter_b_1to0_0000"},
	{frames = "filter_b_2to1_%04d", first = "filter_b_2to1_0000"},
	{frames = "filter_b_3to2_%04d", first = "filter_b_3to2_0000"},
	{frames = "filter_b_4to3_%04d", first = "filter_b_4to3_0000"},
	{frames = "filter_b_5to4_%04d", first = "filter_b_5to4_0000"},	
}


TileColorFilterB = class(CocosObject)
local kCharacterAnimationTime = 1/30

function TileColorFilterB:create(texture, colorIndex, level)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileColorFilterB.new(sprite)
	node.name = 'color_filterB'
	node.colorIndex = colorIndex
	node.level = level

	node:init()
	return node
end

function TileColorFilterB:init()
	self.isDisappearing = false

	local spName = FramesInfo[self.level].first
	self.bg = Sprite:createWithSpriteFrameName(spName)
	self.bgLight = Sprite:createWithSpriteFrameName("filter_b_in_"..self.colorIndex.."_0008")

	self:addChild(self.bg)
	self:addChild(self.bgLight)

	local bgPos = DecPosAdjust[self.level]
	self.bg:setPosition(ccp(bgPos.x, bgPos.y))
	self.bgLight:setPosition(ccp(LightOriPos.x, LightOriPos.y))
end

function TileColorFilterB:playDisappear(callback)
	self.isDisappearing = true

	-- 非1级直接削减到0级，需要调整动画位置
	local xShift, yShift = 0, 0
	if self.level == 5 then
		yShift = -11
	elseif self.level == 4 then
		yShift = -4
	elseif self.level == 3 then
		xShift = 5
		yShift = -1
	elseif self.level == 2 then
		xShift = -7.5
		yShift = -5.5
	end

	local frames = FramesInfo[1].frames
	local spName = FramesInfo[1].first

	local frames1 = SpriteUtil:buildFrames(frames, 0, 25)
	local animate1 = SpriteUtil:buildAnimate(frames1, kCharacterAnimationTime)
	self.bg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spName))
	local bgPos = DisappearPosAdjust[self.level] or DisappearPosAdjust[1]
	self.bg:setPosition(ccp(bgPos.x + xShift, bgPos.y + yShift))
	self.bg:stopAllActions()
	self.bg:play(animate1, 0, 1, function ()
		if callback then callback() end
	end)

	local frames2 = SpriteUtil:buildFrames("filter_b_out_"..self.colorIndex.."_%04d", 0, 16)
	local animate2 = SpriteUtil:buildAnimate(frames2, kCharacterAnimationTime)
	self.bgLight:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("filter_b_out_"..self.colorIndex.."_0000"))
	self.bgLight:setPosition(ccp(LightOriPos.x, LightOriPos.y - 0.75))
	self.bgLight:stopAllActions()
    self.bgLight:play(animate2, 0, 1, function ()
    	if self.isDisposed then return end 
    	self.bgLight:setVisible(false)
    end)
end

function TileColorFilterB:playDec(oldLevel)
	if self.isDisappearing == true then return end

	if oldLevel > 1 then 
		self.level = oldLevel - 1

		local frames = FramesInfo[oldLevel].frames
		local spName = FramesInfo[oldLevel].first

		local frames1 = SpriteUtil:buildFrames(frames, 0, 25)
		local animate1 = SpriteUtil:buildAnimate(frames1, kCharacterAnimationTime)
		self.bg:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spName))
		self.bg:setPosition(ccp(DecPosAdjust[oldLevel].x, DecPosAdjust[oldLevel].y))
		self.bg:stopAllActions()
		self.bg:play(animate1, 0, 1)
		
	    local frames2 = SpriteUtil:buildFrames("filter_b_blink_"..self.colorIndex.."_%04d", 1, 9)
		local animate2 = SpriteUtil:buildAnimate(frames2, kCharacterAnimationTime)
		self.bgLight:stopAllActions()
	    self.bgLight:play(animate2, 0, 1)
	end
end 