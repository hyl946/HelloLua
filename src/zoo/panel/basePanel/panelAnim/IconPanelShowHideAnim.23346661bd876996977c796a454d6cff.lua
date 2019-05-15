
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月 6日 16:29:03
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- IconPanelShowHideAnim
---------------------------------------------------

assert(not IconPanelShowHideAnim)
IconPanelShowHideAnim = class()

function IconPanelShowHideAnim:init(panelToControl, scaleOriginPosInWorldSpace, ...)
	assert(panelToControl)
	assert(scaleOriginPosInWorldSpace)
	assert(#{...} == 0)

	self.panelToControl 		= panelToControl
	self.panelScaleX, self.panelScaleY = panelToControl:getScaleX(), panelToControl:getScaleY()
	self.scaleOriginPosInWorldSpace	= scaleOriginPosInWorldSpace
end

function IconPanelShowHideAnim:createHideAnim(...)
	assert(#{...} == 0)
	
	local selfParent = self.panelToControl:getParent()
	local pos	= selfParent:convertToNodeSpace(ccp(self.scaleOriginPosInWorldSpace.x, self.scaleOriginPosInWorldSpace.y))

	local moveTo	= CCMoveTo:create(0.1, pos)
	local scale	= CCScaleTo:create(0.1, 0.05)
	local spawn  = CCSpawn:createWithTwoActions(moveTo, scale)

	local hide	= CCHide:create()

	local seq = CCSequence:createWithTwoActions(spawn, hide)
	return seq
end

function IconPanelShowHideAnim:playHideAnim(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	-- Hide Anim
	local hideAnim = self:createHideAnim()

	-- Callback
	local function callbackFunc()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction = CCCallFunc:create(callbackFunc)

	local seq = CCSequence:createWithTwoActions(hideAnim, callbackAction)
	self.panelToControl:runAction(seq)
end

function IconPanelShowHideAnim:createShowAnim(...)
	assert(#{...} == 0)

	local defaultEaseRate	= 0.3

	local centerPosX 	= self.panelToControl:getHCenterInParentX()
	local centerPosY	= self.panelToControl:getVCenterInParentY()

	-- Init Action
	local p = self.scaleOriginPosInWorldSpace or ccp(360,640)
	local function initActionFunc()
		-- Convert Star Reward Icon Pos In World Space To Self Parent Space
		local selfParent = self.panelToControl:getParent()
		local pos	= selfParent:convertToNodeSpace(ccp(p.x, p.y))
		self.panelToControl:setPosition(pos)

		-- Initial Size
		self.panelToControl:setScale(0.05)
		self.panelToControl:setVisible(true)
	end
	local initAction = CCCallFunc:create(initActionFunc)

	local actionArray = CCArray:create()

	-- Move TO Center
	local moveToCenter		= CCMoveTo:create(0.2, ccp(centerPosX, centerPosY))
	-- local easeMoveToCenter		= CCEaseSineOut:create(moveToCenter, defaultEaseRate)
	local easeMoveToCenter		= CCEaseSineOut:create(moveToCenter)
	local targetedMoveToCenter	= CCTargetedAction:create(self.panelToControl.refCocosObj, easeMoveToCenter)
	actionArray:addObject(targetedMoveToCenter)

	-- Scale Large
	local scaleLarge = CCScaleTo:create(0.2, self.panelScaleX, self.panelScaleY)
	-- local easeScaleLarge = CCEaseSineOut:create(scaleLarge, defaultEaseRate)
	local easeScaleLarge = CCEaseSineOut:create(scaleLarge)
	actionArray:addObject(easeScaleLarge)
	
	local spawn = CCSpawn:create(actionArray)

	-- -- Scale TO Origianl
	-- local scaleSmall = CCScaleTo:create(0.02, 0.97)
	-- local easeScaleOut	= CCEaseInOut:create(scaleSmall, defaultEaseRate)

	-- -- Scale TO Origianl
	-- local scaleOrigin	= CCScaleTo:create(0.02, 1)
	-- local easeScaleOrigin	= CCEaseIn:create(scaleOrigin, defaultEaseRate)

	-- Seq
	local seqArray = CCArray:create()
	seqArray:addObject(initAction)
	seqArray:addObject(spawn)
	-- seqArray:addObject(easeScaleOut)
	-- seqArray:addObject(easeScaleOrigin)
	local seq = CCSequence:create(seqArray)
	return seq
end

function IconPanelShowHideAnim:playShowAnim(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	-- --------
	-- Show Anim
	-- ----------
	local showAnim 	= self:createShowAnim()

	-- ---------
	-- Callback
	-- ----------
	local function finishCallback()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction = CCCallFunc:create(finishCallback)

	local seq = CCSequence:createWithTwoActions(showAnim, callbackAction)
	--self:runAction(seq)
	self.panelToControl:runAction(seq)
end

function IconPanelShowHideAnim:create(panelToControl, scaleOriginPosInWorldSpace, ...)
	assert(panelToControl)
	assert(scaleOriginPosInWorldSpace)
	assert(#{...} == 0)

	local newIconPanelPopoutRemoveAnim = IconPanelShowHideAnim.new()
	newIconPanelPopoutRemoveAnim:init(panelToControl, scaleOriginPosInWorldSpace)
	return newIconPanelPopoutRemoveAnim
end
