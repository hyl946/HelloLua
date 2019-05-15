

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月17日 15:08:01
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.common.ItemType"
require "zoo.panel.component.common.BubbleItem"

---------------------------------------------------
-------------- EnergyItem
---------------------------------------------------

assert(not EnergyItem)
--assert(BaseUI)
assert(BubbleItem)
--EnergyItem = class(BaseUI)
EnergyItem = class(BubbleItem)

function EnergyItem:init(ui, itemType, animLayer, flyToPosInAnimLayer, ...)
	assert(ui)
	assert(itemType)
	assert(animLayer)
	assert(flyToPosInAnimLayer)
	assert(#{...} == 0)

	self.ui	= ui
	self.numTip = getRedNumTip()
	self.numTip:setScale(1.35)
	self.numTip:setPositionXY(137, -15)
	self.ui:addChild(self.numTip)


	-- ---------------
	-- Init Base Class
	-- ----------------
	--BaseUI.init(self, self.ui)
	BubbleItem.init(self, self.ui, itemType)

	-- ----------
	-- Data
	-- -----------
	self.itemType			= itemType
	self.animLayer			= animLayer
	self.flyToPosInAnimLayer	= flyToPosInAnimLayer
	self.flyingTime			= 0.5

	--------------
	--- Play Bubble Anim
	-------------------
	self:playBubbleNormalAnim(true)

	self.itemRes:setPositionX(self.itemRes:getPositionX() + 10)
end

function EnergyItem:getEnergyPointToAdd(...)
	assert(#{...} == 0)

	local curEnergy = UserEnergyRecoverManager:sharedInstance():getEnergy()
	local maxEnergy	= UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
	local maxToAdd = maxEnergy - curEnergy

	local itemType = self.itemType

	if itemType == ItemType.SMALL_ENERGY_BOTTLE then
		return math.min(1, maxToAdd)
	elseif itemType == ItemType.MIDDLE_ENERGY_BOTTLE then
		return math.min(5, maxToAdd)
	elseif itemType == ItemType.LARGE_ENERGY_BOTTLE then
		return math.min(30, maxToAdd)
	else
		assert(false)
	end
end

function EnergyItem:playFlyingEnergyAnimation(animFinishCallback, flyFinishCallback, ...)
	assert(type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local selfCenterInWorld = self:convertToWorldSpace(ccp(self.centerX, self.centerY))
	local selfCenterInAnimLayer = self.animLayer:convertToNodeSpace(ccp(selfCenterInWorld.x, selfCenterInWorld.y))

	-- Create New Energy Icon
	local flyIcon	= ResourceManager:sharedInstance():buildItemSprite(self.itemType)
	flyIcon:setAnchorPoint(ccp(0.5, 0.5))
	flyIcon:setPosition(ccp(selfCenterInAnimLayer.x, selfCenterInAnimLayer.y))
	self.animLayer:addChild(flyIcon)

	-- Move To Action

	local controlPointX = (self.flyToPosInAnimLayer.x - selfCenterInAnimLayer.x)/2
	controlPointX = math.min(controlPointX, -200)
	local controlPointY = (selfCenterInAnimLayer.x - self.flyToPosInAnimLayer.x)*2
	controlPointY = math.min(controlPointY, 300)

	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = ccp(selfCenterInAnimLayer.x + controlPointX, selfCenterInAnimLayer.y - controlPointY)
	bezierConfig.controlPoint_2 = ccp(self.flyToPosInAnimLayer.x, self.flyToPosInAnimLayer.y - 100)
	bezierConfig.endPosition = ccp(self.flyToPosInAnimLayer.x, self.flyToPosInAnimLayer.y)

	local function getBezierPoint(p0, p1, p2, p3, t)
		local p01 = {x=p0.x*(1-t)+p1.x*t, y=p0.y*(1-t)+p1.y*t}
		local p12 = {x=p1.x*(1-t)+p2.x*t, y=p1.y*(1-t)+p2.y*t}
		local p23 = {x=p2.x*(1-t)+p3.x*t, y=p2.y*(1-t)+p3.y*t}

		local p02 = {x=p01.x*(1-t)+p12.x*t, y=p01.y*(1-t)+p12.y*t}
		local p13 = {x=p12.x*(1-t)+p23.x*t, y=p12.y*(1-t)+p23.y*t}

		local p03 = {x=p02.x*(1-t)+p13.x*t, y=p02.y*(1-t)+p13.y*t}

		return ccp(p03.x, p03.y)
	end

	local function getBezierLength(p0, p1, p2 ,p3, n)
		local delta = 1/n
		local length = 0
		local last = getBezierPoint(p0, p1, p2, p3, 0)
		local t = delta
		while t <= 1 do
			local cur = getBezierPoint(p0, p1, p2, p3, t)
			length = length + math.sqrt((cur.x-last.x)*(cur.x-last.x)+(cur.y-last.y)*(cur.y-last.y))
			last = cur
			t = t + delta
		end
		return length
	end

	-- 为了匀速飞行，计算贝塞尔曲线长度
	local p0 = flyIcon:getPosition()
	local p1 = bezierConfig.controlPoint_1
	local p2 = bezierConfig.controlPoint_2
	local p3 = bezierConfig.endPosition
	local bezierLength = getBezierLength(p0, p1, p2, p3, 128)
	local duration = 10/24*bezierLength/408
	local bezierAction = CCBezierTo:create(duration, bezierConfig)

	local function afterFly()
		if flyFinishCallback and type(flyFinishCallback) == 'function' then
			flyFinishCallback()
		end
	end

	local onFlyFinish = CCCallFunc:create(afterFly)

	local zoomIn = CCScaleBy:create(4/24, 1.2)
	local zoomOut = CCScaleBy:create(4/24, 1/1.2)

	-- Finish Callback
	local function finish()
		flyIcon:removeFromParentAndCleanup(true)
		animFinishCallback()
	end
	local callFunc	= CCCallFunc:create(finish)

	-- Sequence
	local actionArray	= CCArray:create()
	actionArray:addObject(bezierAction)
	actionArray:addObject(onFlyFinish)
	actionArray:addObject(zoomIn)
	actionArray:addObject(zoomOut)
	actionArray:addObject(callFunc)

	local sequence	= CCSequence:create(actionArray)

	flyIcon:runAction(sequence)
end

function EnergyItem:create(ui, itemType, animLayer, flyToPosInAnimLayer, ...)
	assert(ui)
	assert(itemType)
	assert(animLayer)
	assert(flyToPosInAnimLayer)

	assert(#{...} == 0)

	local newEnergyItem = EnergyItem.new()
	newEnergyItem:init(ui, itemType, animLayer, flyToPosInAnimLayer)
	return newEnergyItem
end