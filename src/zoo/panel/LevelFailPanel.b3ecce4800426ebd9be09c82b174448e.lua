
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月22日 16:13:21
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.component.levelFailPanel.LevelFailTopPanel"
require "zoo.panel.PushActivityPanel"

---------------------------------------------------
-------------- LevelFailPanel
---------------------------------------------------

assert(not LevelFailPanel)
assert(PanelWithRankList)

LevelFailPanel = class(PanelWithRankList)

function LevelFailPanel:init(levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove, ...)
	-- assert(type(levelId) 		== "number")
	-- assert(type(failScore) 		== "number")
	-- assert(type(failStar) 		== "number")
	-- assert(type(isTargetReached)	== "boolean")
	-- assert(#{...} == 0)


	Notify:dispatch("QuitNextLevelModeEvent", true)
	
	local QixiManager = require 'zoo.eggs.QixiManager'

	-- if QixiManager:getInstance():shouldSeeRose() then
		QixiManager:getInstance():loadSkeletonAssert()
	-- end
	
	-------------
	-- Get Data
	-- ----------
	self.levelId 	= levelId
	self.levelType 	= levelType

	self.hiddenRankList = false

	-- 活动关不显示排行
	local showRankList = LevelType.isShowRankList(levelType)
	if not showRankList then
		self.hiddenRankList = true
	end

	--------------------
	---- Create UI Component
	------------------------
	self.levelFailTopPanel	= LevelFailTopPanel:create(self, levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove)

	--促销栏消失时处理ui
	self.levelFailTopPanel:ad(LevelFailTopPanel.Events.kPromotionItemDisposed, function ( ... )
		if self.isDisposed then return end
		self:setInitAndExpanPos()
		self:stopAutomaticAction()
		self:automaticCloseRanklist()
	end)

	--------------------
	---- Init Base Class
	--------------------
	local posYAdjust = 0
	local _, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelFailTopPanel)
	if uncommonSkin then
		posYAdjust = 350
	end
	PanelWithRankList.init(self, levelId, self.levelType, self.levelFailTopPanel, "levelFailPanel", posYAdjust)

	--------------------------------
	-- Create Show / Hide Animation
	-- -------------------------------
	local topPanel	= self:getTopPanel()
	local rankList	= self:getRankList()
	self.exchangeAnim = PanelWithRankExchangeAnim:create(self, topPanel, rankList)

	

	-------------------------------------------------
	--- Set Top Panel And Rank List Initial Position
	-------------------------------------------------
	
	-- Get Config From PanelConfig.lua
	he_log_warning("May Change StartGamePanelConfig To Another Name, May Be PanelWithRankListConfig !")

	self:setInitAndExpanPos()

end

function LevelFailPanel:setInitAndExpanPos( ... )

	if self.isDisposed then return end

	self:setScale(1)

	local topPanel	= self:getTopPanel()
	local rankList	= self:getRankList()

	local topPanelHeight = topPanel:getGroupBounds(self).size.height
	local rankListHeight = rankList:getGroupBounds(self).size.height

	local config = StartGamePanelConfig:create(self)

	-------------------------------------------------
	--- Set Top Panel And Rank List Initial Position
	-------------------------------------------------
	local topPanelInitX = config:topPanelInitX()
	local topPanelInitY = config:topPanelInitY()
	self:setTopPanelInitPos(topPanelInitX, topPanelInitY)			-- This Control Drag Rank List Panel

	local topPanelExpanX	= config:topPanelExpanX()
	local topPanelExpanY	= config:topPanelExpanY()


	--有促销栏的时候需要额外移动一些距离
	if self.levelFailTopPanel and self.levelFailTopPanel.hasPromotionItem and self.levelFailTopPanel:hasPromotionItem() then
		topPanelExpanY = topPanelExpanY + 200
	end

	self:setTopPanelExpanPos(topPanelExpanX, topPanelExpanY)

	local rankListInitX	= config:rankListInitX()
	local rankListInitY	= config:rankListInitY()
	self:setRankListInitPos(rankListInitX, rankListInitY)

	local rankListExpanX	= config:rankListExpanX()
	local rankListExpanY	= config:rankListExpanY()


	self:setRankListExpanPos(rankListExpanX, rankListExpanY)

	------------------------------------
	-- Config Show / Hide Animation
	-- ------------------------------
	self.exchangeAnim:setTopPanelShowPos(topPanelInitX, topPanelInitY)
	self.exchangeAnim:setTopPanelHidePos(topPanelInitX, topPanelHeight)

	-- self.exchangeAnim:setRankListPopShowPos(rankListInitX, rankListInitY)
	self.exchangeAnim:setRankListPopShowPos(rankListInitX, rankListInitY ) --春节UI
	self.exchangeAnim:setRankListPopHidePos(rankListInitX, topPanelInitY - topPanelHeight + rankListHeight + 100)

	self:scaleAccordingToResolutionConfig()
end

function LevelFailPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)

	GamePlayMusicPlayer:playEffect(GameMusicType.kPanelVerticalPopout)
	self.levelFailTopPanel:onCloseBtnTapped()
end

function LevelFailPanel:popout(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local function animFinished()
		-- self.allowBackKeyTap = true		
		local size = self.rankListPanelClipping:getContentSize()
		self.rankListPanelClipping:setContentSize(CCSizeMake(size.width, size.height + 300))

		if not (self.levelFailTopPanel and self.levelFailTopPanel:skipCheckActivity())  then
			self:checkPushActivity(animFinishCallback)
		else
			self:setRankListPanelTouchEnable()
			self.allowBackKeyTap = true
			if animFinishCallback then animFinishCallback() end
		end

		if self.levelFailTopPanel then
			self.levelFailTopPanel:afterPopout()
		end
	end

	self.exchangeAnim:popout(animFinished)

	-- play level act mark 
end

function LevelFailPanel:remove(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	self:removeRankListPanelSceneListener()
	self.exchangeAnim:remove(animFinishCallback)
end

function LevelFailPanel:show(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)

	local function animFinished()
		self:setRankListPanelTouchEnable()
		if animFinishCallbck then
			animFinishCallbck()
		end
	end

	self.exchangeAnim:show(animFinishCallbck)
end

function LevelFailPanel:changeToStartGamePanel(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)
	
	self:removeWhileKeepBackground(false)

	-- Delay Popout StartGamePanel
	local delay = CCDelayTime:create(0.4)

	local function delayCallFunc()

		-- WARNING: Not A Proper Design
		local function onStartGamePanelCancel()
			self:exitGamePlaySceneUI()
		end

		if _isQixiLevel then -- qixi
			self:exitGamePlaySceneUI()

		else

			local startGamePanel = StartGamePanel:create(self.levelId, self.levelType, nil, StartLevelSource.kFailPanel)
			startGamePanel:setOnClosePanelCallback(onStartGamePanelCancel)


			startGamePanel:popoutWithoutBgFadeIn(false)
		end
	end
	local delayCallAction = CCCallFunc:create(delayCallFunc)

	-- Seq
	local seq = CCSequence:createWithTwoActions(delay, delayCallAction)

	local scene = Director:sharedDirector():getRunningScene()
	scene:runAction(seq) 
end


function LevelFailPanel:exitGamePlaySceneUI(...)
	assert(#{...} == 0)
	if self.levelType == GameLevelType.kMainLevel 
			or self.levelType == GameLevelType.kHiddenLevel then	
		HomeScene:sharedInstance():setEnterFromGamePlay(self.levelId)
	end
	-- CCDirector:sharedDirector():popScene()
	Director:sharedDirector():popScene()
end

function LevelFailPanel:removeWhileKeepBackground(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local function callback()
		if animFinishCallback then
			animFinishCallback()
		end
	end

	self:removeRankListPanelSceneListener()
	self.exchangeAnim:removeWhileKeepBackground(callback)
end

function LevelFailPanel:hide(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)

	self:setRankListPanelTouchDisable()
	self.exchangeAnim:hide(animFinishCallbck)
end

function LevelFailPanel:create(levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove, ...)
	-- assert(type(levelId)		== "number")
	-- assert(type(levelType)		== "number")
	-- assert(type(failScore)		== "number")
	-- assert(type(failStar)		== "number")
	-- assert(type(stageTime)		== "number")
	-- assert(type(isTargetReached)	== "boolean")

	-- assert(#{...} == 0)

	local newLevelFailPanel = LevelFailPanel.new()
	newLevelFailPanel:init(levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove)
	return newLevelFailPanel
end

function LevelFailPanel:checkPushActivity(animFinishCallbck)
	local info = PushActivity:sharedInstance():onFailLevel(self.levelId)
	if _G.isLocalDevelopMode then printx(0, "onFailLevel") end
	if _G.isLocalDevelopMode then printx(0, table.tostring(info)) end
	-- TODO: popout push panel and then call animFinishCallbck and set allowBackKeyTap true
	local function onAnimFinish()
		self:setRankListPanelTouchEnable()
		self.allowBackKeyTap = true
		if animFinishCallbck then animFinishCallbck() end
	end
	if info then
		self.levelFailTopPanel.hasPushActivity = true
		local panel = PushActivityPanelFail:create(info)
		if panel then
			self:addPanel(panel)
			panel:popout(self, onAnimFinish)
		end
	else onAnimFinish() end
end

function LevelFailPanel:addPanel(panel)
	local pos = self:convertToNodeSpace(ccp(65, 0))
	panel:setPositionX(pos.x)
	panel:setPositionY(-30)
	self.topPanel:addChild(panel)
end

function LevelFailPanel:dispose( ... )
	
	PanelWithRankList.dispose(self, ...)

	local QixiManager = require 'zoo.eggs.QixiManager'

	-- if QixiManager:getInstance():shouldSeeRose() then
		QixiManager:getInstance():unloadSkeletonAssert()
	-- end
end