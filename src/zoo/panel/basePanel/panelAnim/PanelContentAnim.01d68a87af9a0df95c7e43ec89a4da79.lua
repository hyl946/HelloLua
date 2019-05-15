
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月23日 23:35:42
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.baseUI.BaseClippingUI"

---------------------------------------------------
-------------- PanelContentAnim
---------------------------------------------------

PanelContentAnim = class()

function PanelContentAnim:ctor()
end

function PanelContentAnim:init(panelToControl, ...)
	assert(panelToControl)
	assert(#{...} == 0)

	self.panelToControl = panelToControl
	
	-- ------------------
	-- Get UI Resource
	-- ------------------
	self.fadeArea		= self.panelToControl.ui:getChildByName("fadeArea")
	self.clippingAreaAbove	= self.panelToControl.ui:getChildByName("clippingAreaAbove")
	--self.greenBar		= self.panelToControl.ui:getChildByName("greenBar")
	self.clippingAreaBelow	= self.panelToControl.ui:getChildByName("clippingAreaBelow")

	assert(self.fadeArea)
	assert(self.clippingAreaAbove)
	--assert(self.greenBar)
	assert(self.clippingAreaBelow)

	--self.greenBarSprite	= self.greenBar:getChildByName("greenBar")
	--assert(self.greenBarSprite)

	-----------------
	-- Init UI State
	-- --------------
	--self.greenBarSprite:setOpacity(0)

	----------------------
	-- Get Data About UI
	-- ------------------
	self.areaAboveSize	= self.clippingAreaAbove:getGroupBounds().size
	self.areaAboveSize	= {width = self.areaAboveSize.width, height = self.areaAboveSize.height}
	self.areaBelowSize	= self.clippingAreaBelow:getGroupBounds().size
	self.areaBelowSize	= {width = self.areaBelowSize.width, height = self.areaBelowSize.height}

	--self.greenBarSize	= self.greenBar:getGroupBounds().size

	--self.greenBarScaleX	= self.greenBar:getScaleX()
	--self.greenBarScaleY	= self.greenBar:getScaleY()

	-----------------
	-- Create UI Component
	-- --------------------
	--self.clippingCompoAbove	= BaseClippingUI:create(self.clippingAreaAbove)
	--self.clippingCompoBelow	= BaseClippingUI:create(self.clippingAreaBelow)
end

----------------------------------
---	Get All Opacity Action
--------------------------

function PanelContentAnim:getFadeAreaFadeOutAction(actionTime, ...)
	assert(type(actionTime) == "number")
	assert(#{...} == 0)

	local allChildren 	= self.fadeArea:getChildrenList()
	local actionArray	= CCArray:create()

	for i,v in ipairs(allChildren) do

		local child	= v
		local fadeOut		= CCFadeOut:create(actionTime)
		local childAction	= CCTargetedAction:create(child.refCocosObj, fadeOut)
		actionArray:addObject(childAction)
	end

	local spawn = CCSpawn:create(actionArray)
	return spawn
end

function PanelContentAnim:getFadeAreaFadeInAction(actionTime, ...)
	assert(type(actionTime) == "number")
	assert(#{...} == 0)

	local allChildren 	= self.fadeArea:getChildrenList()
	local actionArray	= CCArray:create()

	for i,v in ipairs(allChildren) do

		local child	= v
		local fadeOut		= CCFadeIn:create(actionTime)
		local childAction	= CCTargetedAction:create(child.refCocosObj, fadeOut)
		actionArray:addObject(childAction)
	end

	local spawn = CCSpawn:create(actionArray)
	return spawn
end

----------------------------------------------
--- Set To Initial Hide / Show State
----------------------------------------------

function PanelContentAnim:setFadeAreaOpacity(opacity, ...)
	assert(type(opacity) == "number")
	assert(#{...} == 0)

	local allChildren = self.fadeArea:getChildrenList()

	for i,v in ipairs(allChildren) do
		local child = v
		child:setOpacity(opacity)
	end
end

function PanelContentAnim:initShowAnim(...)
	assert(#{...} == 0)

	-- Fade Area
	self:setFadeAreaOpacity(0)

	-- Above Green Bar Area
	self.clippingAreaAbove:setPositionY(-self.areaAboveSize.height)

	-- Green Bar
	--self.greenBar:setScaleX(1)
	--self.greenBarSprite:setOpacity(1)

	-- Below Green Bar Area
	self.clippingAreaBelow:setPositionY(self.areaBelowSize.height)
end

function PanelContentAnim:initHideAnimState(...)
	assert(#{...} == 0)

	-- Fade Area
	self:setFadeAreaOpacity(1)

	-- Above Green Bar Area
	self.clippingAreaAbove:setPositionY(0)

	-- Green Bar
	--self.greenBar:setScaleX(0.1)
	--self.greenBarSprite:setOpacity(0)

	-- Below Green Bar Area
	self.clippingAreaBelow:setPositionY(0)
end

function PanelContentAnim:playShowAnim(finishCallback, ...)
	assert(finishCallback == false or type(finishCallback) == "function")
	assert(#{...} == 0)

	-- Show Content Action
	local showContentAct = self:getShowContentAction()

	-- Finish Callback
	local function onFinish()
		if finishCallback then
			finishCallback()
		end
	end
	local finishCallbackAction = CCCallFunc:create(onFinish)

	-- Seq
	local seq = CCSequence:createWithTwoActions(showContentAct, finishCallbackAction)

	self.clippingAreaAbove:runAction(seq)
end

function PanelContentAnim:getShowContentAction(...)
	assert(#{...} == 0)

	local actionTime = 0.5

	-- Init Show State
	local function init()
		self:initShowAnim()
	end
	local initAction = CCCallFunc:create(init)

	-- Fade Area
	local fadeAreaAction = self:getFadeAreaFadeInAction(actionTime)
	-- Above Green Bar Area
	local moveTo		= CCMoveTo:create(actionTime, ccp(0, 0))
	local quartic		= CCEaseQuarticBackOut:create(moveTo, 3, -7.4475, 10.095, -10.195, 5.5475)
	local areaAboveAction	= CCTargetedAction:create(self.clippingAreaAbove.refCocosObj, quartic)
	-- Green Bar Scale
	local scaleTo 			= CCScaleTo:create(actionTime, 0.1, 1)
	--local greenBarScaleAction	= CCTargetedAction:create(self.greenBar.refCocosObj, scaleTo)
	-- Green Bar Fade Out
	local fadeOut			= CCFadeOut:create(actionTime)
	--local greenBarFadeOutAction	= CCTargetedAction:create(self.greenBarSprite.refCocosObj, fadeOut)
	-- Below Green Bar Area
	local moveTo 		= CCMoveTo:create(0.5, ccp(0, 0))
	local quartic		= CCEaseQuarticBackOut:create(moveTo, 3, -7.4475, 10.095, -10.195, 5.5475)
	local areaBelowAction	= CCTargetedAction:create(self.clippingAreaBelow.refCocosObj, quartic)

	-- Spawn
	local array = CCArray:create()
	array:addObject(fadeAreaAction)
	array:addObject(areaAboveAction)
	array:addObject(greenBarScaleAction)
	array:addObject(greenBarFadeOutAction)
	array:addObject(areaBelowAction)
	local spawn = CCSpawn:create(array)

	-- Sequence
	local seq = CCSequence:createWithTwoActions(initAction, spawn)

	return seq
end

function PanelContentAnim:getHideContentAction(...)
	assert(#{...} == 0)

	local actionTime = 0.5

	-- Init Hide State
	local function init()
		self:initHideAnimState()
	end
	local initAction = CCCallFunc:create(init)

	-- Fade Area
	local fadeAreaAction = self:getFadeAreaFadeOutAction(actionTime)
	-- Above Green Bar Area
	local moveTo = CCMoveTo:create(actionTime, ccp(0, -self.areaAboveSize.height))
	local areaAboveAction = CCTargetedAction:create(self.clippingAreaAbove.refCocosObj, moveTo)
	-- Green Bar Scale
	local scaleTo = CCScaleTo:create(actionTime, 1, 1)
	--local greenBarScaleAction	= CCTargetedAction:create(self.greenBar.refCocosObj, scaleTo)
	-- Green Bar Fade In
	local fadeIn			= CCFadeIn:create(actionTime)
	--local greenBarFadeInAction	= CCTargetedAction:create(self.greenBarSprite.refCocosObj, fadeIn)
	-- Below Green Bar Area
	local moveTo = CCMoveTo:create(actionTime, ccp(0, self.areaBelowSize.height))
	local areaBelowAction = CCTargetedAction:create(self.clippingAreaBelow.refCocosObj, moveTo)

	-- Spawn
	local array = CCArray:create()
	array:addObject(fadeAreaAction)
	array:addObject(areaAboveAction)
	array:addObject(greenBarScaleAction)
	array:addObject(greenBarFadeInAction)
	array:addObject(areaBelowAction)
	local spawn = CCSpawn:create(array)

	-- Sequence
	local seq = CCSequence:createWithTwoActions(initAction, spawn)

	return seq
end

function PanelContentAnim:playHideAnim(finishCallback, ...)
	assert(finishCallback == false or type(finishCallback) == "function")
	assert(#{...} == 0)
	
	-- Hide Content Action
	local hideContentAct = self:getHideContentAction()

	-- Finish Callback
	local function onFinish()
		if finishCallback then
			finishCallback()
		end
	end
	local finishCallbackAction = CCCallFunc:create(onFinish)

	-- Seq
	local seq = CCSequence:createWithTwoActions(hideContentAct, finishCallbackAction)

	self.clippingAreaAbove:runAction(seq)
end

function PanelContentAnim:create(panelToControl, ...)
	assert(panelToControl)
	assert(#{...} == 0)

	local newPanelContentAnim = PanelContentAnim.new()
	newPanelContentAnim:init(panelToControl)
	return newPanelContentAnim
end
