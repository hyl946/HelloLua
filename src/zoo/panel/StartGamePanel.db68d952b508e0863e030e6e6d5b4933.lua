require "zoo.panel.PanelWithRankList"
require "zoo.config.ui.StartGamePanelConfig"
require "zoo.panel.basePanel.panelAnim.PanelWithRankExchangeAnim"
require "zoo.panel.component.startGamePanel.LevelInfoPanel"
require "zoo.mission.panels.MissionBugOnLevelInfoPanel"
-- require "zoo.panel.rabbitWeekly.RabbitWeeklyLevelInfoPanel"
-- require "zoo.panel.weeklyRace.WeeklyRaceLevelInfoPanel"

---------------------------------------------------
-------------- StartGamePanel
---------------------------------------------------

assert(not StartGamePanel)
assert(PanelWithRankList)

StartGamePanel = class(PanelWithRankList)

function StartGamePanel:init(levelId, levelType, startLevelType, source, ...)
	assert(type(levelId) == "number")
	assert(#{...} == 0)
	self.source = source or StartLevelSource.kDefault
	NextLevelButtonProxy:getInstance():onStartGamePanelPopout(self.source)

	self.hiddenRankList = false

	-------------------
	-- Get Data About UI
	-- --------------------
	self.levelId 		= levelId
	self.levelType 		= levelType
	self.startLevelType = startLevelType or StartLevelType.kCommon
	self.resourceManager	= ResourceManager:sharedInstance()
	self.hiddenRankList = self:isNeedHideRankList(levelId, levelType)
    self.levelInfoPanel = self:createLevelInfoPanel(levelId, levelType, startLevelType)

	local panelPosYOffset = 40
	local winSize = Director:sharedDirector():getWinSize()
	-- if _G.isLocalDevelopMode then printx(0, winSize.height) end 
	if winSize.height > 960 then
		panelPosYOffset = 80
	end
	if levelType == GameLevelType.kRabbitWeekly then
		panelPosYOffset = panelPosYOffset + 50 -- 兔子周赛开始面板需要向上偏移一定距离
	end

	---------------------------
	-- Data About LevelInfoPanel
	-- ------------------------
	local size = self.levelInfoPanel:getGroupBounds().size

	-- ---------------
	-- Init Base Class
	-- ---------------
	local posYAdjust = 0
	local _, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelInfoPanel)
	if uncommonSkin then
		posYAdjust = 350
	end
	PanelWithRankList.init(self, self.levelId, self.levelType, self.levelInfoPanel, "startGamePanel", posYAdjust)

	--self.selfWidth = 713.95

	--------------------------------
	-- Create Show / Hide Animation
	-- -------------------------------
	local topPanel	= self:getTopPanel()
	local rankList	= self:getRankList()

	if HomeScene:sharedInstance().worldScene:checkMissionBubbleShow(levelId) then
		--local wave = Sprite:createWithSpriteFrameName("wave_level_1_0001")
		--FrameLoader:loadImageWithPlist("flash/missionAnime.plist")
		--local missionBug = Sprite:createWithSpriteFrameName("mission_bug_on_level_info_panel")

		local missionBug = MissionBugOnLevelInfoPanel:create(self.levelId)

		--local targetDesLabelPosition = self.targetDesLabel:getPosition()
		--self.ui:convertToWorldSpace( ccp( self.itemIcon:getPosition().x , self.itemIcon:getPosition().y) )
		
		--missionBug:setPosition( ccp( rankListInitX + 580 , rankListInitY - 180 ) )
		missionBug:setPosition( ccp( 600 , -600 ) )
		missionBug:setScale(1)
		self.missionBug = missionBug
		topPanel:addChild(missionBug)
	end

	self.exchangeAnim = PanelWithRankExchangeAnim:create(self, topPanel, rankList)
	--self.

	------------------------------------
	-- Get Data About Top Panel  / Rank List
	-- ----------------------------------
	local topPanelHeight = topPanel:getGroupBounds().size.height
	local rankListHeight = rankList:getGroupBounds().size.height

	-------------------------------------------------
	--- Set Top Panel And Rank List Initial Position
	-------------------------------------------------
	-- Get Config From PanelConfig.lua
	local config = StartGamePanelConfig:create(self)
	
	local fisPos = -10  -- 春节版本的微调

	-- Top Panel Init X,Y And Expanded X,Y
	local topPanelInitX = config:topPanelInitX()
	local topPanelInitY = config:topPanelInitY() + panelPosYOffset 

	self:setTopPanelInitPos(topPanelInitX+fisPos, topPanelInitY+fisPos)			-- This Control Drag Rank List Panel

	local topPanelExpanX	= config:topPanelExpanX()
	local topPanelExpanY	= config:topPanelExpanY() + panelPosYOffset
	self:setTopPanelExpanPos(topPanelExpanX+fisPos, topPanelExpanY+fisPos)

	-- Rank List Init X,Y And Expanded X,Y
	local rankListInitX	= config:rankListInitX()
	local rankListInitY	= config:rankListInitY()


	-- self:setRankListInitPos(rankListInitX, rankListInitY)
	self:setRankListInitPos(rankListInitX, rankListInitY - 20 +fisPos) -- 春节版本的微调

	local rankListExpanX	= config:rankListExpanX()
	local rankListExpanY	= config:rankListExpanY()
	-- self:setRankListExpanPos(rankListExpanX, rankListExpanY)
	self:setRankListExpanPos(rankListExpanX, rankListExpanY - 20+fisPos) -- 春节版本的微调

	------------------------------------
	-- Config Show / Hide Animation
	-- ------------------------------
	self.exchangeAnim:setTopPanelShowPos(topPanelInitX, topPanelInitY)
	-- self.exchangeAnim:setTopPanelHidePos(topPanelInitX, topPanelHeight)
	self.exchangeAnim:setTopPanelHidePos(topPanelInitX, topPanelHeight + 50) -- 春节版本的微调

	-- self.exchangeAnim:setRankListPopShowPos(rankListInitX, rankListInitY)
	self.exchangeAnim:setRankListPopShowPos(rankListInitX, rankListInitY-20) -- 春节版本的微调
	self.exchangeAnim:setRankListPopHidePos(rankListInitX, topPanelInitY - topPanelHeight + rankListHeight + 100)

	--------------------
	-- Event Callback
	-- ----------------
	self.onClosePanelCallback	= false
	self.popoutAnimFinishCallback	= false

	---------------------------------------
	--  Scale According To Screen Resolution
	--  -------------------------------------
	self:scaleAccordingToResolutionConfig()
	--self:setToScreenCenterHorizontal()

	if self.levelType == GameLevelType.kMainLevel then
		if HEAICore:getInstance():isEnable(self.levelId) and HEAICore:getInstance():checkSeedDataNeedUpdate(self.levelId) then
			HEAICore:getInstance():requestSeeds(levelId)
		end
	end

	GamePreStartContext:getInstance():buildStartPanel( self.levelId , self.levelType , self.startLevelType , self.source )


    local bActivitySupport = SpringFestival2019Manager.getInstance():isActivitySupport(levelId)
    if bActivitySupport and startLevelType ~= StartLevelType.kAskForHelp then
    	require "zoo.localActivity.PigYear.PigYearStartGame"
        PigYearStartGame:decorateStart(self,levelId)
	end
end

function StartGamePanel:createLevelInfoPanel(levelId, levelType, startLevelType)
	local infoPanel = nil
	if levelType == GameLevelType.kDigWeekly then
		infoPanel = WeeklyRaceLevelInfoPanel:create(self, levelId)
	-- elseif levelType == GameLevelType.kRabbitWeekly then
	-- 	infoPanel = RabbitWeeklyLevelInfoPanel:create(self, levelId)
	else 
		infoPanel = LevelInfoPanel:create(self, levelId, levelType, startLevelType)
	end
	return infoPanel
end

function StartGamePanel:isNeedHideRankList( levelId, levelType )
	if levelType == GameLevelType.kTaskForUnlockArea then 
		return true
	else
		return false
	end
end

function StartGamePanel:setOnClosePanelCallback(callback, ...)
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.onClosePanelCallback = callback
end

function StartGamePanel:setPopoutAnimFinishCallback(animFinish, ...)
	assert(type(animFinish) == "function")
	assert(#{...} == 0)

	self.popoutAnimFinishCallback = animFinish
end

function StartGamePanel:popout(animFinishCallback, ...)

	if _G.isLocalDevelopMode then printx(0, 'StartGamePanel:popout') end
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)
	
	local function onPopoutAnimFinished()
		
		self:setRankListPanelTouchEnable()
		if animFinishCallback then
			animFinishCallback()
		end

		self.allowBackKeyTap = true
		if self.levelInfoPanel and self.levelInfoPanel.afterPopout then
			self.levelInfoPanel:afterPopout()
		end

		if self.popoutAnimFinishCallback then
			self.popoutAnimFinishCallback()
		end

		if GameGuide and GameGuide.isInited then
			printx( 1 , "    StartGamePanel:onEnterHandler   GameGuide   enter")
			if not CollectStarsYEMgr.getInstance():isBuffEffective(self.levelId) then
				GameGuide:sharedInstance():onPopup(self)
				self.__guide_popup_called = true
			end
		end

		if self.levelInfoPanel and self.levelInfoPanel.afterPopout then
			self.levelInfoPanel:afterPopoutAndAfterGuideCheck()	--处理检测完引导以后的一些逻辑
		end

		local size = self.rankListPanelClipping:getContentSize()
		self.rankListPanelClipping:setContentSize(CCSizeMake(size.width, size.height + 300))

		he_log_info("auto_test_tap_level")
	end
	
	self.exchangeAnim:popout(onPopoutAnimFinished)
end

function StartGamePanel:popoutWithoutBgFadeIn(animFinishCallback, ...)
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local function callback()
		self:setRankListPanelTouchEnable()

		if animFinishCallback then
			animFinishCallback()
		end

		if self.levelInfoPanel and self.levelInfoPanel.changeToStartGamePanelAfterPopout then
			self.levelInfoPanel:changeToStartGamePanelAfterPopout()
		end

		if self.popoutAnimFinishCallback then
			self.popoutAnimFinishCallback()
		end
	end

	self.exchangeAnim:popoutWithoutBgFadeIn(callback)
end

function StartGamePanel:remove(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)
	local function callback()
		if animFinishCallback then
			animFinishCallback()
		end
	end

	self:removeRankListPanelSceneListener()
	self.exchangeAnim:remove(callback)

	if self.missionBug and self.missionBug:getParent() then
		self.missionBug:removeFromParentAndCleanup(true)
	end

	GamePreStartContext:getInstance():closeStartPanel()
end

function StartGamePanel:removeWhileKeepBackground(animFinishCallback, ...)
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

function StartGamePanel:show(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)

	local function onShowAnimFinish()
		self:setRankListPanelTouchEnable()
		if animFinishCallbck then
			animFinishCallbck()
		end
	end

	self.exchangeAnim:show(onShowAnimFinish)
end

function StartGamePanel:hide(animFinishCallbck, ...)
	assert(animFinishCallbck == false or type(animFinishCallbck) == "function")
	assert(#{...} == 0)
	self:setRankListPanelTouchDisable()
	self.exchangeAnim:hide(animFinishCallbck)
end

function StartGamePanel:onEnterHandler(event, ...)
	assert(event)
	assert(#{...} == 0)

	if event == "enter" then
		BroadcastManager:getInstance():onPopup(self)
	elseif event == "exit" then
		-- debug.debug()
		if GameGuide and GameGuide.isInited then
			printx( 1 , "    BasePanel:onEnterHandler   GameGuide   exit")
			if self.__guide_popup_called then
				GameGuide:sharedInstance():onPopdown(self)
			end
		end
	end

	if event == "enter" then
		self.topPanel:setToScreenCenterHorizontal()
		self.rankList:setToScreenCenterHorizontal()

	elseif event == "exit" then
		-- 修复开始游戏面板上切换到添加好友页面后回来导致面板无法滑动的问题
		-- local runningScene = Director:sharedDirector():getRunningScene()
		-- if runningScene then
		-- 	runningScene:removeEventListener(DisplayEvents.kTouchBegin, PanelWithRankList.onSceneTouchBegan)
		-- end
	end
end

function StartGamePanel:changeToEnergyNotEnoughPanel(energyPanelContinuCallback, energyPanelCloseCallback, ...)
	if _G.isLocalDevelopMode then printx(0, "StartGamePanel:changeToEnergyNotEnoughPanel", energyPanelCloseCallback) end
	assert(energyPanelContinuCallback == false or type(energyPanelContinuCallback) == "function")
	assert(false == energyPanelCloseCallback or type(energyPanelCloseCallback) == "function")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "energyPanelCloseCallback", energyPanelCloseCallback) end

	self:removeWhileKeepBackground(false) 

	-- Delay Popout Energy Panel
	local delay = CCDelayTime:create(0.4)

	local function delayCallFunc()
		-- Create Energy Panel
		local energyPanel = EnergyPanel:create(energyPanelContinuCallback)

		-- -- Set On Close Callback
		-- if energyPanelCloseCallback then
		-- 	energyPanel:setOnClosePanelCallback(energyPanelCloseCallback)
		-- end

		-- if self.onClosePanelCallback then
		-- 	energyPanel:setOnClosePanelCallback(self.onClosePanelCallback)
		-- end

		local function onCloseCallback(isCloseBtnClick)
			if energyPanelCloseCallback then energyPanelCloseCallback() end
			if self.onClosePanelCallback then self.onClosePanelCallback() end

			GamePreStartContext:getInstance():closeStartPanel()
			
			if isCloseBtnClick and Director.sharedDirector():getRunningScene() == HomeScene:sharedInstance() then 
				PushActivity:sharedInstance():onEnergyNotEnough(function( info )
					ActivityData.new(info):start(false)
				end)
			end
		end
		energyPanel:setOnClosePanelCallback(onCloseCallback)

		energyPanel:popoutWithoutBgFadeIn(false)
	end
	local delayCallAction = CCCallFunc:create(delayCallFunc)

	-- Seq
	local seq = CCSequence:createWithTwoActions(delay, delayCallAction)

	local scene = Director:sharedDirector():getRunningScene()
	scene:runAction(seq) 

	local currentPlay = FUUUManager:getLevelTotalPlayed(self.levelId) + 1
	DcUtil:UserTrack({category = "stage", sub_category = "click_start", current_stage=self.levelId, current_play=currentPlay, t1 = 1}, true)
end

function StartGamePanel:onCloseBtnTapped(...)
	assert(#{...} == 0)
	self.levelInfoPanel:onCloseBtnTapped()
end

function StartGamePanel:setReplayCallback(replayStartGameCallback)
	self.replayStartGameCallback = replayStartGameCallback
end

function StartGamePanel:setReplayCallbackBeforStartLevel(replayStartGameCallbackBeforStartLevel)
	self.replayStartGameCallbackBeforStartLevel = replayStartGameCallbackBeforStartLevel
end

--override
function StartGamePanel:reBecomeTopPanel()
	PanelWithRankList.reBecomeTopPanel(self)
	if _G.isLocalDevelopMode then printx(0, "StartGamePanel:reBecomeTopPanel Called !") end

	if self.tipPanelContainer then 
		self:setRankListPanelTouchDisable()
	else
		self:setRankListPanelTouchEnable()
	end
end

function StartGamePanel:dispose()
	if HEAICore:getInstance():isEnable(self.levelId) then
		HEAICore:getInstance():cancelSeedsRequest()
	end
	PanelWithRankList.dispose(self)
end

--local instance = nil
function StartGamePanel:create(levelId, levelType, startLevelType, source, ...)
	assert(type(levelId) == "number")
	assert(type(levelType) == "number")
	assert(#{...} == 0)

	--if instance and not instance.isDisposed then return instance end

	local newStartGamePanel = StartGamePanel.new()
	if _G.isLocalDevelopMode then printx(0, "StartGamePanel:create", levelId, levelType) end
	newStartGamePanel:init(levelId, levelType, startLevelType, source)

	--instance = newStartGamePanel
	return newStartGamePanel
end


--bugfix 在调起跳关面板时，其实会销毁当前开始游戏面板，关掉跳关面板时，重新创建一个开始游戏面板
--重新创建的面板 丢失了之前被注册的一些回调

local protectedCallbacks = {}

function StartGamePanel:recordCallback( ... )
	protectedCallbacks.replayStartGameCallbackBeforStartLevel = self.replayStartGameCallbackBeforStartLevel
	protectedCallbacks.replayStartGameCallback = self.replayStartGameCallback
end

function StartGamePanel:revertCallback( ... )
	if not self.replayStartGameCallbackBeforStartLevel then
		self:setReplayCallbackBeforStartLevel(protectedCallbacks.replayStartGameCallbackBeforStartLevel)
	end
	if not self.replayStartGameCallback then
		self:setReplayCallback(protectedCallbacks.replayStartGameCallback)
	end
end