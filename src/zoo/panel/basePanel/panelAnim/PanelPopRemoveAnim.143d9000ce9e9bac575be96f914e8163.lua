
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月28日 15:20:44
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- PanelPopRemoveAnim
---------------------------------------------------

assert(not PanelPopRemoveAnim)
PanelPopRemoveAnim = class()

function PanelPopRemoveAnim:init(panelToControl, ...)
	assert(panelToControl)
	assert(#{...} == 0)

	self.panelToControl = panelToControl
	--self.moveToTime		= 0.9
	self.popOutTime	= false
	self.removeTime = false

	local config = UIConfigManager:sharedInstance():getConfig()
	self.popOutTime = config.panelPopRemoveAnim_popOutTime
	self.removeTime	= config.panelPopRemoveAnim_removeTime
	assert(self.popOutTime)
	assert(self.removeTime)

	self.showX	= false
	self.showY	= false
	self.hideX	= false
	self.hideY	= false

	self._isBlackBgEnable	= true
end

function PanelPopRemoveAnim:enablePanelBlackBg(enable, ...)
	assert(type(enable) == "boolean")
	assert(#{...} == 0)

	self._isBlackBgEnable = enable
end

function PanelPopRemoveAnim:setPopHidePos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.hideX = x
	self.hideY = y
end

function PanelPopRemoveAnim:getPopHidePos(...)
	assert(#{...} == 0)

	assert(self.hideX, "May Not Set Hide X !")
	assert(self.hideY, "May Not Set Hide Y !")

	return ccp(self.hideX, self.hideY)
end

function PanelPopRemoveAnim:setPopShowPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.showX = x
	self.showY = y
end

function PanelPopRemoveAnim:getPopShowPos(...)
	assert(#{...} == 0)

	assert(self.showX, "May Not Set Show X !")
	assert(self.showY, "May Not Set Show Y !")
	
	return ccp(self.showX, self.showY)
end

function PanelPopRemoveAnim:getPopAct(...)
	assert(#{...} == 0)

	local hCenterXInParent	= self.panelToControl:getHCenterInParentX()

	-- Move Top Out Of Screen
	local function moveTopOutOfScreen()
		-- self.panelToControl:setPosition(ccp(self.hideX, self.hideY))
		self.panelToControl:setPosition(ccp(hCenterXInParent, self.hideY))
		self.panelToControl:setVisible(true)
	end
	local outOfScreenAction = CCCallFunc:create(moveTopOutOfScreen)

	-- Move To
	--local moveToAction	= CCMoveTo:create(self.popOutTime, ccp(self.showX, self.showY))
	local moveToAction	= CCMoveTo:create(self.popOutTime, ccp(hCenterXInParent, self.showY))
	local quarticBackOut	= CCEaseQuarticBackOut:create(moveToAction, 3, -7.4475, 10.095, -10.195, 5.5475)
	local targetAction	= CCTargetedAction:create(self.panelToControl.refCocosObj, quarticBackOut) 

	-- Sequence
	local seq = CCSequence:createWithTwoActions(outOfScreenAction, targetAction)
	return seq
end

function PanelPopRemoveAnim:getRemoveAct(...)
	assert(#{...} == 0)

	-- local hCenterXInParent	= self.panelToControl:getHCenterInParentX()
	local hCenterXInParent = self.panelToControl:getPositionX()

	-- Set To Start Pos
	local function setToStartPos()
		self.panelToControl:setPosition(ccp(hCenterXInParent, self.showY))
	end
	local setToStartPosAction = CCCallFunc:create(setToStartPos)

	-- Move To Hide Pos
	local moveToAction	= CCMoveTo:create(self.removeTime, ccp(hCenterXInParent, self.hideY))
	local targetAction	= CCTargetedAction:create(self.panelToControl.refCocosObj, moveToAction)

	-- Seq
	local seq = CCSequence:createWithTwoActions(setToStartPosAction, targetAction)
	return seq
end

function PanelPopRemoveAnim:popout(animFinishCallbck, noBgFadeIn , needDark)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	if needDark == nil then needDark = true end
	-- --------------
	-- Pop Out Panel
	-- --------------
	
	local function fadeInFinishCallback()

	end
	self.panelToControl:setVisible(false)
	if noBgFadeIn then 
		PopoutManager:sharedInstance():add(self.panelToControl, needDark , false)
	else
		PopoutManager:sharedInstance():addWithBgFadeIn(self.panelToControl, needDark, false, fadeInFinishCallback)
	end

	---------------------------
	--- Run Slide In Animation
	----------------------
	
	-- Get Pop Action
	local popAction = self:getPopAct()

	-- Finish Callback Action
	local function finishCallback()
		if animFinishCallbck then
			animFinishCallbck()
		end
	end
	local callbackAction = CCCallFunc:create(finishCallback)

	-- Run Action
	local seq = CCSequence:createWithTwoActions(popAction, callbackAction)
	self.panelToControl:runAction(seq)
	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)
end

function PanelPopRemoveAnim:popoutWithoutBgFadeIn(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	-- --------------
	-- Pop Out Panel
	-- --------------
	local function fadeInFinishCallback()

	end
	PopoutManager:sharedInstance():add(self.panelToControl, true, false)
	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)

	---------------------------
	--- Run Slide In Animation
	----------------------
	
	-- Get Pop Action
	local popAction = self:getPopAct()

	-- Finish Callback Action
	local function finishCallback()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction = CCCallFunc:create(finishCallback)

	-- Run Action
	local seq = CCSequence:createWithTwoActions(popAction, callbackAction)
	self.panelToControl:runAction(seq)
end

function PanelPopRemoveAnim:remove(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "PanelPopRemoveAnim:remove Called !") end

	-- Get Remove Action
	local removeAction = self:getRemoveAct()

	-- Finish Callback Action
	local function finishCallback()

		local function animFinish()
			if animFinishCallbck then
				if _G.isLocalDevelopMode then printx(0, "lyhtest-----------PanelPopRemoveAnim:finishCallback:animFinish") end
				animFinishCallbck()
			end
		end
		if _G.isLocalDevelopMode then printx(0, "lyhtest-----------PanelPopRemoveAnim:remove") end
		PopoutManager:sharedInstance():removeWithBgFadeOut(self.panelToControl, animFinish, true)
	end
	local callbackAction = CCCallFunc:create(finishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(removeAction, callbackAction)
	self.panelToControl:runAction(seq)
	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)
end

function PanelPopRemoveAnim:removeWhileKeepBackground(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local actionArray = CCArray:create()

	-- -----------------------------------
	-- Shrink PopoutManager's Container 
	-- ------------------------------
	
	-- Get Container
	-- Shrink Container
	local container = PopoutManager:sharedInstance():getChildContainer(self.panelToControl)
	--local childContainer = 

	local scaleTo 		= CCScaleTo:create(2, 0.5)
	local targetScaleTo	= CCTargetedAction:create(container.refCocosObj, scaleTo)
	actionArray:addObject(targetScaleTo)
	
	-- Get Remove Action
	local removeAction = self:getRemoveAct()
	actionArray:addObject(removeAction)

	-- Finish Callback Action
	local function finishCallback()

		local function animFinish()
			if animFinishCallbck then
				animFinishCallbck()
			end
		end

		--PopoutManager:sharedInstance():removeWithBgFadeOut(self.panelToControl, animFinish, true)
		PopoutManager:sharedInstance():removeWhileKeepBackground(self.panelToControl, true)
	end
	local callbackAction = CCCallFunc:create(finishCallback)
	actionArray:addObject(callbackAction)

	-- Seq
	--local seq = CCSequence:createWithTwoActions(removeAction, callbackAction)
	local seq = CCSequence:create(actionArray)
	self.panelToControl:runAction(seq)
end

function PanelPopRemoveAnim:create(panelToControl, ...)
	assert(panelToControl)
	assert(#{...} == 0)

	local newPanelPopRemoveAnim = PanelPopRemoveAnim.new()
	newPanelPopRemoveAnim:init(panelToControl)
	return newPanelPopRemoveAnim
end
