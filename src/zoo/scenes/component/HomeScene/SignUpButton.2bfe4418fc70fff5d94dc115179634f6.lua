

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 20:19:29
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- SignUpButton
---------------------------------------------------

SignUpButton = class(Layer)

function SignUpButton:ctor()
end

function SignUpButton:init(...)
	assert(#{...} == 0)

	-- Init Base
	Layer.initLayer(self)

	-- Get UI Resource
	self.ui	= ResourceManager:sharedInstance():buildGroup("button/signUpButton")
	assert(self.ui)
	self:addChild(self.ui)

	-- Get Bubble UI
	-- And Make Bubble Animation
	self.bubble	= self.ui:getChildByName("bubble")
	assert(self.bubble)

	self.bubbleAnimation	= BubbleEnlargeShrinkAnimation:create(self.bubble)
	
end

function SignUpButton:create(...)
	assert(#{...} == 0)

	local newSignUpButton = SignUpButton.new()
	newSignUpButton:init()
	return newSignUpButton
end

