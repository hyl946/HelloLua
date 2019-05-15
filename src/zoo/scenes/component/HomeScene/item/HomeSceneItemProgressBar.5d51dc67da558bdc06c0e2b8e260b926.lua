
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月15日 12:03:04
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- HomeSceneItemProgressBar
---------------------------------------------------

assert(not HomeSceneItemProgressBar)
assert(BaseUI)

HomeSceneItemProgressBar = class(BaseUI)

if _G.isLocalDevelopMode then printx(0, "this class can common used , rename it !!!") end

function HomeSceneItemProgressBar:init(ui, curNumber, totalNumber, ...)
	assert(ui)
	assert(type(curNumber) == "number")
	assert(type(totalNumber) == "number")
	assert(#{...} == 0)

	----------------------
	-- Init Base Class
	-- -------------------
	BaseUI.init(self, ui)

	-------------------
	-- Get Data
	-- -------------
	self.curNumber		= curNumber
	self.totalNumber	= totalNumber

	---------------------
	-- Get UI Component
	-- ----------------
	self.bar	= self.ui:getChildByName("bar")
	self.mask	= self.ui:getChildByName("mask")

	assert(self.bar)
	assert(self.mask)

	-------------------------------
	-- Get Data About UI Component
	-- --------------------------
	
	self.barInitialPosX 	= self.bar:getPositionX()
	self.barInitialPosY 	= self.bar:getPositionY()
	self.barWidth		= self.bar:getGroupBounds().size.width
	self.barZeroPercentX	= self.barInitialPosX - self.barWidth

	---------------------
	-- Create Clipping 
	-- ------------------
	self.mask:removeFromParentAndCleanup(false)
	self.bar:removeFromParentAndCleanup(false)

	local cppClippingNode	= CCClippingNode:create(self.mask.refCocosObj)
	local clipping		= ClippingNode.new(cppClippingNode)
	clipping:setAlphaThreshold(0.1)
	clipping:addChild(self.bar)
	self.ui:addChild(clipping)

	local manualAdjustClippingPosX	= 1
	local manualAdjustClippingPosY	= 0

	local curClippingPos	= clipping:getPosition()
	clipping:setPosition(ccp(curClippingPos.x + manualAdjustClippingPosX, curClippingPos.y + manualAdjustClippingPosY))
	
	-- ------------
	-- Update UI
	-- ---------------
	self.progressBarToControl = self.bar

	self:setCurNumber(self.curNumber)
	self:setTotalNumber(self.totalNumber)
	self.mask:dispose()
end

function HomeSceneItemProgressBar:_setPercentage(percentage, ...)
	assert(type(percentage) == "number")
	assert(#{...} == 0)

	if percentage < 0 then
		percentage = 0
	elseif percentage > 1 then
		percentage = 1
	end

	--local width = self.barSize.width * percentage
	local width = self.barWidth * percentage
	local newPosX = self.barZeroPercentX + width

	self.progressBarToControl:setPositionX(newPosX)
end

function HomeSceneItemProgressBar:setCurNumber(curNumber, ...)
	assert(type(curNumber) == "number")
	assert(#{...} == 0)

	self.curNumber = curNumber

	local percentage = self.curNumber / self.totalNumber
	self:_setPercentage(percentage)
end

function HomeSceneItemProgressBar:setTotalNumber(totalNumber, ...)
	assert(type(totalNumber) == "number")
	assert(#{...} == 0)

	self.totalNumber = totalNumber
	local percentage = self.curNumber / self.totalNumber
	self:_setPercentage(percentage)
end

function HomeSceneItemProgressBar:create(ui, curNumber, totalNumber, ...)
	assert(ui)
	assert(type(curNumber) == "number")
	assert(type(totalNumber) == "number")
	assert(#{...} == 0)

	local newHomeSceneItemProgressBar = HomeSceneItemProgressBar.new()
	newHomeSceneItemProgressBar:init(ui,curNumber, totalNumber)
	return newHomeSceneItemProgressBar
end
