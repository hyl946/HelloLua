
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月28日 15:36:17
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.basePanel.panelAnim.PanelPopRemoveAnim"
---------------------------------------------------
-------------- PanelWithRankPopRemoveAnim
---------------------------------------------------

assert(not PanelWithRankPopRemoveAnim)
PanelWithRankPopRemoveAnim = class()

function PanelWithRankPopRemoveAnim:init(panelToControl, topPanel, rankList, ...)
	assert(panelToControl)
	assert(topPanel)
	assert(rankList)
	assert(#{...} == 0)

	self.panelToControl 	= panelToControl
	self.topPanel		= topPanel
	self.rankList		= rankList

	-- Create Pop Out Action
	self.topPanelPopRemoveAnim	= PanelPopRemoveAnim:create(self.topPanel)
	self.rankListPopRemoveAnim	= PanelPopRemoveAnim:create(self.rankList)
end

function PanelWithRankPopRemoveAnim:setTopPanelShowPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.topPanelPopRemoveAnim:setPopShowPos(x, y)
end

function PanelWithRankPopRemoveAnim:setTopPanelHidePos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.topPanelPopRemoveAnim:setPopHidePos(x, y)
end

function PanelWithRankPopRemoveAnim:getTopPanelShowPos(...)
	assert(#{...} == 0)

	return self.topPanelPopRemoveAnim:getPopShowPos()
end

function PanelWithRankPopRemoveAnim:setRankListPopShowPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.rankListPopRemoveAnim:setPopShowPos(x, y)
end

function PanelWithRankPopRemoveAnim:setRankListPopHidePos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.rankListPopRemoveAnim:setPopHidePos(x, y)
end

function PanelWithRankPopRemoveAnim:getRankListPopAnim(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	----------------------
	-- Rank List Action
	-- --------------------
	
	-- Action Init State
	local function rankListActionInit()
		-- Start From Top Panel Behind
		self.rankList:setPositionY(self.topPanelPopRemoveAnim:getPopShowPos().y)
		--self.rankList:setVisible(true)
	end
	local rankListInitAction = CCCallFunc:create(rankListActionInit)

	-- Move Action
	--local rankListPopAct = self.rankListPopRemoveAnim:getPopAct()
	local rankListPopAct	= self:getRankListPopAct()

	-- Action Finish Callback
	local function rankListActionFinished()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local rankListAnimCallback = CCCallFunc:create(rankListActionFinished)

	-- Seq
	local actionArray = CCArray:create()
	actionArray:addObject(rankListInitAction)
	actionArray:addObject(rankListPopAct)
	actionArray:addObject(rankListAnimCallback)

	local seq = CCSequence:create(actionArray)
	local targetSeq = CCTargetedAction:create(self.rankList.refCocosObj, seq)
	return targetSeq
end

function PanelWithRankPopRemoveAnim:getTopPanelPopAnim(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	--------------------------
	-- Top Panel Pop Action
	-- ------------------------
	-- Action Init State
	local function topPanelActionInit()
		self.topPanel:setToTopOutOfScreen()
		--self.topPanel:setVisible(true)
	end
	local topPanelInitAction = CCCallFunc:create(topPanelActionInit)

	-- Move Action
	local topPanelPopAct = self.topPanelPopRemoveAnim:getPopAct()

	-- Action Finished State:w
	local function topPanelActionFinished()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local topPanelAnimCallback = CCCallFunc:create(topPanelActionFinished)

	-- Seq
	local actionArray = CCArray:create()
	actionArray:addObject(topPanelInitAction)
	actionArray:addObject(topPanelPopAct)
	actionArray:addObject(topPanelAnimCallback)
	local topPanelSeq	= CCSequence:create(actionArray)
	local targetSeq		= CCTargetedAction:create(self.topPanel.refCocosObj, topPanelSeq)

	return targetSeq
end

function PanelWithRankPopRemoveAnim:getTopPanelRemoveAct(...)
	assert(#{...} == 0)

	-- Get Cur Top Panel Pos
	local curTopPanelPos = self.topPanel:getPosition()

	-- Reset Top Panel's Hide Pos
	self.topPanelPopRemoveAnim:setPopShowPos(curTopPanelPos.x, curTopPanelPos.y)

	return self.topPanelPopRemoveAnim:getRemoveAct()
end

function PanelWithRankPopRemoveAnim:getTopPanelRemoveAnim(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local removeAction = self:getTopPanelRemoveAct()

	-- Anim Callback
	local function animCallback()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callBackAction = CCCallFunc:create(animCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(removeAction, callBackAction)

	return seq
end

function PanelWithRankPopRemoveAnim:popout(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local function fadeInFinishCallback()

	end

	PopoutManager:sharedInstance():addWithBgFadeIn(self.panelToControl, true, false, fadeInFinishCallback)
	--self.panelToControl:setVisible(false)
	self.topPanel:setVisible(false)
	self.rankList:setVisible(false)

	-- Top Panel And Rank List Showing Action
	local topPanelAction		= self:getTopPanelPopAnim(false)
	local rankListPanelAction	= self:getRankListPopAnim(false)

	-- Call Back Action
	local function animFinished()
		--self.panelToControl

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local animFinishAction = CCCallFunc:create(animFinished)

	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)

	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(topPanelAction)
	if not self.panelToControl.hiddenRankList then
		actionArray:addObject(rankListPanelAction)
	end
	actionArray:addObject(animFinishAction)

	-- Seq
	local seq = CCSequence:create(actionArray)
	self.topPanel:runAction(seq)
end

function PanelWithRankPopRemoveAnim:popoutWithoutBgFadeIn(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	PopoutManager:sharedInstance():add(self.panelToControl, true, false)

	-- Top Panel And Rank List Showing Action
	local topPanelAction		= self:getTopPanelPopAnim(false)
	local rankListPanelAction	= self:getRankListPopAnim(false)

	-- Call Back Action
	local function animFinished()

		--self.panelToControl

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local animFinishAction = CCCallFunc:create(animFinished)

	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)

	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(topPanelAction)
	actionArray:addObject(rankListPanelAction)
	actionArray:addObject(animFinishAction)

	-- Seq
	local seq = CCSequence:create(actionArray)
	self.topPanel:runAction(seq)
end

function PanelWithRankPopRemoveAnim:getRankListPopAct(...)
	assert(#{...} == 0)

	-- Pre Popout Callback
	local function rankListPrePopCallback()
		if self.rankList.prePopoutCallback then
			self.rankList:prePopoutCallback()
		end
	end
	local prePopCallback = CCCallFunc:create(rankListPrePopCallback)

	-- Pop Out
	local popAct = self.rankListPopRemoveAnim:getPopAct()

	-- Post Popout Callback
	local function rankListPostPopCallback()
		if self.rankList.postPopoutCallback then
			self.rankList:postPopoutCallback()
		end
	end
	local postPopCallback = CCCallFunc:create(rankListPostPopCallback)

	local actionArray = CCArray:create()
	actionArray:addObject(prePopCallback)
	actionArray:addObject(popAct)
	actionArray:addObject(postPopCallback)

	-- Seq
	--local seq = CCSequence:createWithTwoActions(prePopCallback, popAct)
	local seq = CCSequence:create(actionArray)
	return seq
end

function PanelWithRankPopRemoveAnim:getRankListRemoveAct(...)
	assert(#{...} == 0)

	-- In The Case Of Shrink/Expan The Rank List
	-- We Need To Adjust The Initial Show/Hide Pos.
	-- Specificly, Rank List's Pos Is Based On Top Panel Pos
	local rankListShowPos = self.rankListPopRemoveAnim:getPopShowPos()
	local rankListHidePos = self.rankListPopRemoveAnim:getPopHidePos()
	local topPanelShowPos = self.topPanelPopRemoveAnim:getPopShowPos()
	local topPanelHidePos = self.topPanelPopRemoveAnim:getPopHidePos()

	local deltaShowPosY = rankListShowPos.y - topPanelShowPos.y
	local deltaHidePosY = rankListHidePos.y - topPanelHidePos.y

	-- Get Cur Top Panel Pos
	local curTopPanelPos = self.topPanel:getPosition()

	-- Rank List's New Show/Hide Pos
	local newRankListShowPosY = curTopPanelPos.y + deltaShowPosY
	local newRankListHidePosY = curTopPanelPos.y + (topPanelHidePos.y - topPanelShowPos.y) + deltaHidePosY

	self.rankListPopRemoveAnim:setPopShowPos(rankListShowPos.x, newRankListShowPosY)
	self.rankListPopRemoveAnim:setPopHidePos(rankListHidePos.x, newRankListHidePosY)

	return self.rankListPopRemoveAnim:getRemoveAct()
end

function PanelWithRankPopRemoveAnim:getRankListRemoveAnim(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	-- Move Action
	local rankListRemove = self:getRankListRemoveAct()

	-- Anim Finish Callback
	local function animFinish()

		self.rankList:setVisible(false)

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local finishAction = CCCallFunc:create(animFinish)

	-- Seq
	local seq = CCSequence:createWithTwoActions(rankListRemove, finishAction)
	return seq
end

function PanelWithRankPopRemoveAnim:removeWhileKeepBackground(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	self.topPanel:stopAllActions()

	--self.panelToControl:setRankListPanelTouchDisable()

	-- Get Container
	-- Shrink Container
	local container = PopoutManager:sharedInstance():getChildContainer(self.panelToControl)

	-- Set Container's ContentSize Then Anchor Point
	--local containerSize	= container
	container:setContentSize(CCSizeMake(720, 10))
	container:ignoreAnchorPointForPosition(false)
	container:setAnchorPoint(ccp(0.5, 0))
	container:setPositionX(360)

	local actionArray = CCArray:create()

	--
	local scaleTo 		= CCScaleTo:create(0.15, 0.8)
	local targetScaleTo	= CCTargetedAction:create(container.refCocosObj, scaleTo)
	--actionArray:addObject(targetScaleTo)

	-- Top Panel And Rank List Hiding Action
	local rankListPanelAction	= self:getRankListRemoveAnim(false)
	local topPanelAction		= self:getTopPanelRemoveAnim(false)
	-- Panel Action Seq
	local panelActionSeq	= CCSequence:createWithTwoActions(rankListPanelAction, topPanelAction)

	local spawn = CCSpawn:createWithTwoActions(targetScaleTo, panelActionSeq)

	actionArray:addObject(spawn)

	---- Scale And Panel Action Spawn
	--local panelSpawn = CCSpawn:createWithTwoActions(targetScaleTo, panelActionSeq)
	--actionArray:addObject(panelSpawn)

	-- Call Back Action
	local function animFinished()

		local function removeAnimFinished()
			if animFinishCallback then
				animFinishCallback()
			end
		end

		PopoutManager:sharedInstance():removeWhileKeepBackground(self.panelToControl, true)
		removeAnimFinished()
	end
	local animFinishAction = CCCallFunc:create(animFinished)
	actionArray:addObject(animFinishAction)

	-- Seq 
	local seq = CCSequence:create(actionArray)
	--local seq = CCSequence:createWithTwoActions(spawn, animFinishAction)
	self.topPanel:runAction(seq)
end

function PanelWithRankPopRemoveAnim:remove(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	self.topPanel:stopAllActions()

	--self.panelToControl:setRankListPanelTouchDisable()

	-- Top Panel And Rank List Hiding Action
	local rankListPanelAction	= self:getRankListRemoveAnim(false)
	local topPanelAction		= self:getTopPanelRemoveAnim(false)

	-- Call Back Action
	local function animFinished()

		local function removeAnimFinished()
			if animFinishCallback then
				animFinishCallback()
			end
		end

		PopoutManager:sharedInstance():removeWithBgFadeOut(self.panelToControl, removeAnimFinished, true)
	end
	local animFinishAction = CCCallFunc:create(animFinished)

	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)
	
	-- Action Array
	local actionArray = CCArray:create()
	--actionArray:addObject(targetScaleTo)
	actionArray:addObject(rankListPanelAction)
	actionArray:addObject(topPanelAction)
	actionArray:addObject(animFinishAction)

	-- Seq
	local seq = CCSequence:create(actionArray)
	self.topPanel:runAction(seq)
end

function PanelWithRankPopRemoveAnim:create(panelToControl, topPanel, rankList, ...)
	assert(panelToControl)
	assert(topPanel)
	assert(rankList)
	assert(#{...} == 0)

	local newPanelWithRankPopRemoveAnim = PanelWithRankPopRemoveAnim.new()
	newPanelWithRankPopRemoveAnim:init(panelToControl, topPanel, rankList)
	return newPanelWithRankPopRemoveAnim
end
