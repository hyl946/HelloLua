
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 3日 18:50:58
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- FlipButton
---------------------------------------------------

assert(not FlipButton)
assert(BaseUI)

FlipButton = class(BaseUI)

function FlipButton:ctor()
end

function FlipButton:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	-- Init Base Class
	BaseUI.init(self, ui)

	-- Wrap ui With Another Layer
	self.wrapLayer	= Layer:create()
	self:addChild(self.wrapLayer)

	self.ui:removeFromParentAndCleanup(false)
	self.wrapLayer:addChild(self.ui)

	local uiHeight	= self.ui:getGroupBounds().size.height
	self.ui:setPositionY(uiHeight)
end

function FlipButton:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newFlipButton = FlipButton.new()
	newFlipButton:init(ui)
	return newFlipButton
end

function FlipButton:flipToBack(timeInterval, angle, ...)
	assert(timeInterval)
	assert(timeInterval >= 0)
	assert(angle)
	assert(angle > 0)
	assert(#{...} == 0)

	local action = self:getFlipToBackAction(timeInterval, angle)
	self:runAction(action)
end

function FlipButton:flipToFront(timeInterval, angle, ...)
	assert(timeInterval)
	assert(timeInterval >= 0)
	assert(angle)
	assert(angle > 0)
	assert(#{...} == 0)

	local action = self:getFlipToFrontAction(timeInterval, angle)
	self:runAction(action)
end

function FlipButton:getFlipToBackAction(timeInterval, angle, ...)
	assert(timeInterval)
	assert(timeInterval >= 0)
	assert(angle)
	assert(angle > 0)
	assert(#{...} == 0)

	local halfAngle = angle / 2

	local cameraAction1 = CCOrbitCamera:create(timeInterval, 1, 0, 0, -halfAngle, 90, 0 )
	local easeElasticOut1	= CCEaseElasticOut:create(cameraAction1)
	--self:runAction(easeElasticOut1)
	--self:runAction(cameraAction1)
	easeElasticOut1 = CCTargetedAction:create(self.refCocosObj, easeElasticOut1)

	local cameraAction2 = CCOrbitCamera:create(timeInterval, 1, 0, 0, -halfAngle, 90, 0 )
	local easeElasticOut2	= CCEaseElasticOut:create(cameraAction2)
	--self.wrapLayer:runAction(easeElasticOut2)
	--self.wrapLayer:runAction(cameraAction2)
	easeElasticOut2	= CCTargetedAction:create(self.wrapLayer.refCocosObj, easeElasticOut2)

	local spawn = CCSpawn:createWithTwoActions(easeElasticOut1, easeElasticOut2)
	return spawn
end

function FlipButton:getFlipToFrontAction(timeInterval, angle, ...)
	assert(timeInterval)
	assert(timeInterval >= 0)
	assert(angle)
	assert(angle > 0)
	assert(#{...} == 0)

	local halfAngle = angle / 2

	local cameraAction1 = CCOrbitCamera:create(timeInterval, 1, 0, -halfAngle, halfAngle, 90, 0 )
	local easeElasticOut1	= CCEaseElasticOut:create(cameraAction1)
	--self:runAction(easeElasticOut1)
	--self:runAction(cameraAction1)
	easeElasticOut1 = CCTargetedAction:create(self.refCocosObj, easeElasticOut1)
	

	local cameraAction2 = CCOrbitCamera:create(timeInterval, 1, 0, -halfAngle, halfAngle, 90, 0 )
	local easeElasticOut2	= CCEaseElasticOut:create(cameraAction2)
	--self.wrapLayer:runAction(easeElasticOut2)
	--self.wrapLayer:runAction(cameraAction2)
	easeElasticOut2	= CCTargetedAction:create(self.wrapLayer.refCocosObj, easeElasticOut2)

	local spawn = CCSpawn:createWithTwoActions(easeElasticOut1, easeElasticOut2)
	return spawn
end

