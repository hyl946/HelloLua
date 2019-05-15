
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月27日 18:12:00
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- EnergyNumberCounter
---------------------------------------------------

assert(not EnergyNumberCounter)
EnergyNumberCounter = class(BaseUI)

function EnergyNumberCounter:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	-- Init Base Class
	BaseUI.init(self, ui)

	-- --------------
	-- Get UI Resource
	-- --------------

	self.curEnergyLabel	= TextField:createWithUIAdjustment(self.ui:getChildByName("curPh"), self.ui:getChildByName("curEnergyLabel"))
	ui:addChild(self.curEnergyLabel)

	self.maxEnergyLabel	= TextField:createWithUIAdjustment(self.ui:getChildByName("maxPh"), self.ui:getChildByName("maxEnergyLabel"))
	ui:addChild(self.maxEnergyLabel)

	self.separatorLabel	= self.ui:getChildByName("separatorLabel")
	self.nextCurEnergyLabel	= self.ui:getChildByName("nextCurEnergyLabel")
	self.nextMaxEnergyLabel	= self.ui:getChildByName("nextMaxEnergyLabel")

	--self.curEnergyLabel	= BitmapTextWithBoundingBox:create(self.curEnergyLabel)
	--self.maxEnergyLabel	= BitmapTextWithBoundingBox:create(self.maxEnergyLabel)
	--self.separatorLabel	= BitmapTextWithBoundingBox:create(self.separatorLabel)
	--self.nextCurEnergyLabel	= BitmapTextWithBoundingBox:create(self.nextCurEnergyLabel)
	--self.nextMaxEnergyLabel	= BitmapTextWithBoundingBox:create(self.nextMaxEnergyLabel)
	--self.ui:addChild(self.curEnergyLabel)
	--self.ui:addChild(self.maxEnergyLabel)
	--self.ui:addChild(self.separatorLabel)
	--self.ui:addChild(self.nextCurEnergyLabel)
	--self.ui:addChild(self.nextMaxEnergyLabel)

	assert(self.curEnergyLabel)
	assert(self.maxEnergyLabel)
	assert(self.separatorLabel)
	assert(self.nextCurEnergyLabel)
	assert(self.nextMaxEnergyLabel)

	self.labelsInRollingAnim = {self.curEnergyLabel, self.maxEnergyLabel,
				self.nextCurEnergyLabel, self.nextMaxEnergyLabel}

	-- -------------------
	-- Get Data About UI
	-- ----------------
	self.topLabelPosY	= self.curEnergyLabel:getPositionY()
	self.belowLabelPosY	= self.nextCurEnergyLabel:getPositionY()
	self.clippingHeight	= self.topLabelPosY - self.belowLabelPosY

	-- ------------
	-- Init UI
	-- -----------
	self.separatorLabel:setString("/")

	-- ---------------
	-- Create Clipping
	-- ---------------
	
	-- Get Data About UI
	--local curEnergyLabelPosY	= self.curEnergyLabel:getPositionY()
	--local nextCurEnergyLabelPosY	= self.nextCurEnergyLabel:getPositionY()	
	--local clippingHeight		= curEnergyLabelPosY - nextCurEnergyLabelPosY
	--self.clippingHeight		= clippingHeight
	
	local clippingWidth		= 400

	local clipRect	= { 
			size	= {
				width = clippingWidth, height = self.clippingHeight}
			}

	local clipping	= ClippingNode:create(clipRect)
	clipping:getStencil():setPositionY(-self.clippingHeight)
	clipping:getStencil():setPositionX(-10)
	self:addChild(clipping)

	-- Add self.ui to clipping
	self.ui:removeFromParentAndCleanup(false)
	clipping:addChild(self.ui)
end

function EnergyNumberCounter:setCurEnergy(curEnergy, ...)
	assert(type(curEnergy) == "number")
	assert(#{...} == 0)

	self.curEnergy	= curEnergy

	if self.curEnergyLabel and not self.curEnergyLabel.isDisposed then
		if self.curEnergy < 10 then
			self.curEnergyLabel:setString(" " .. tostring(curEnergy))
		else
			self.curEnergyLabel:setString(tostring(curEnergy))
		end
	end
	-- self.curEnergyLabel:setScaleX(self.maxEnergyLabel:getScaleX())
	-- self.curEnergyLabel:setScaleY(self.maxEnergyLabel:getScaleY())
end

function EnergyNumberCounter:setTotalEnergy(totalEnergy, ...)
	assert(type(totalEnergy) == "number")
	assert(#{...} == 0)
	if not self or self.isDisposed then return end
	self.totalEnergy = totalEnergy
	if not self.maxEnergyLabel or self.maxEnergyLabel.isDisposed then return end
	self.maxEnergyLabel:setString(tostring(totalEnergy))
end

function EnergyNumberCounter:setCurAndTotalEnergyWithAnim(curEnergy, totalEnergy, animFinishCallback, ...)
	assert(type(curEnergy)	== "number")
	assert(type(totalEnergy)== "number")
	assert(type(animFinishCallback) == "function" or false == animFinishCallback)
	assert(#{...} == 0)

	self.nextCurEnergyLabel:setString(tostring(curEnergy))
	self.nextMaxEnergyLabel:setString(tostring(totalEnergy))

	local rollingAction = self:createRollingLabelAnim()

	-- Anim Finish Callback
	local function animFinishedFunc()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local animFinishedAction = CCCallFunc:create(animFinishedFunc)

	local seq = CCSequence:createWithTwoActions(rollingAction, animFinishedAction)
	self:runAction(seq)
end

function EnergyNumberCounter:createRollingLabelAnim(...)
	assert(#{...} == 0)

	-- Move The Next curEnergyLabel/maxEnergyLabel
	
	local rollingTime = 0.5


	---------------
	-- Init Action
	-- -----------
	local function initActionFunc()
		-- Swap
		self.curEnergyLabel, self.nextCurEnergyLabel	= self.nextCurEnergyLabel, self.curEnergyLabel
		self.maxEnergyLabel, self.nextMaxEnergyLabel	= self.nextMaxEnergyLabel, self.maxEnergyLabel
	end

	local initAction = CCCallFunc:create(initActionFunc)


	-- -------------------
	-- Spawn Label Move To
	-- --------------------
	local spawnMoveToActionArray	= CCArray:create()
	for k,v in pairs(self.labelsInRollingAnim) do

		local curLabelPos	= v:getPosition()
		local moveTo		= CCMoveTo:create(rollingTime, ccp(curLabelPos.x, curLabelPos.y + self.clippingHeight))
		local targetMoveTo	= CCTargetedAction:create(v.refCocosObj, moveTo)

		spawnMoveToActionArray:addObject(targetMoveTo)
	end

	-- Spawn
	local spawn = CCSpawn:create(spawnMoveToActionArray)

	-- -----------------------
	-- Anim Finished Callback
	-- ---------------------
	local function animFinishedFunc()
		self.curEnergyLabel:setPositionY(self.topLabelPosY)
		self.maxEnergyLabel:setPositionY(self.topLabelPosY)
		self.nextCurEnergyLabel:setPositionY(self.belowLabelPosY)
		self.nextMaxEnergyLabel:setPositionY(self.belowLabelPosY)
	end
	local animFinishedAction = CCCallFunc:create(animFinishedFunc)


	-- Seq
	local actionArray = CCArray:create()
	actionArray:addObject(initAction)
	actionArray:addObject(spawn)
	actionArray:addObject(animFinishedAction)

	local seq = CCSequence:create(actionArray)
	return seq
end

function EnergyNumberCounter:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newEnergyNumberCounter = EnergyNumberCounter.new()
	newEnergyNumberCounter:init(ui)
	return newEnergyNumberCounter
end
