

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 20:16:26
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


require "zoo.scenes.component.HomeScene.animation.BubbleEnlargeShrinkAnimation"
---------------------------------------------------
-------------- GiftButton
---------------------------------------------------

GiftButton = class(Layer)

function GiftButton:ctor()
end

function GiftButton:init(...)
	assert(#{...} == 0)

	-- Init Base
	Layer.initLayer(self)

	-- Get UI Resource
	self.ui	= ResourceManager:sharedInstance():buildGroup("button/giftButton")
	assert(self.ui)
	self:addChild(self.ui)

	-- Get Bubble UI
	-- And Make Bubble Animation
	self.bubble	= self.ui:getChildByName("bubble")
	assert(self.bubble)

	self.bubbleAnimation	= BubbleEnlargeShrinkAnimation:create(self.bubble)
end

function GiftButton:create(...)
	assert(#{...} == 0)

	local newGiftButton = GiftButton.new()
	newGiftButton:init()
	return newGiftButton
end

