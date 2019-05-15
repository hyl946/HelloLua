-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年08月27日 15:32:36
-- Author:	ZhangWan(diff)

assert(not HomeSceneEvents)
HomeSceneEvents = {
	-- Event For Notify Data Change
	USERMANAGER_TOP_LEVEL_ID_CHANGE 	= "HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE",
	USERMANAGER_COIN_CHANGE			= "HomeSceneEvents.USERMANAGER_COIN_CHANGE",
	USERMANAGER_CASH_CHANGE			= "HomeSceneEvents.USERMANAGER_CASH_CHANGE",
	USERMANAGER_LEVEL_AREA_OPENED_ID_CHANGE = "HomeSceneEvents.USERMANAGER_LEVEL_AREA_OPENED_ID_CHANGE",
	USERMANAGER_TOTAL_STAR_NUMBER_CHANGE	= "HomeSceneEvents.USERMANAGER_TOTAL_STAR_NUMBER_CHANGE",
	USERMANAGER_ENERGY_CHANGE		= "HomeSceneEvents.USERMANAGER_ENERGY_CHANGE"
}

SceneLayerShowKey = {
	BG_LAYER = "bgLayer",
	POP_OUT_LAYER = "popoutLayer",
	TOP_LAYER = "topLayer",
}

SceneLayerShowPriorityKey = {
	bgLayer = 1,
	popoutLayer = 2,
	topLayer = 3,
}

OpenUrlEvents = {
	kActivityShare = "OpenUrlEvents.kActivityShare",
}

require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopout"

require "hecore.ui.LayoutBuilder"
require "zoo.util.ActivityUpdateFlags"
require "zoo.model.MetaModel"
require "zoo.scenes.component.HomeScene.WorldSceneScroller"
require "zoo.scenes.component.HomeScene.WorldMapNodeView"
require "zoo.baseUI.LayoutBar"
require "zoo.scenes.component.HomeScene.item.CoinButton"
require "zoo.scenes.component.HomeScene.item.GoldButton"
require "zoo.scenes.component.HomeScene.item.EnergyButton"
require "zoo.scenes.component.HomeScene.item.StarButton"

require "zoo.iconButtons.IconBtnMgr"
require "zoo.iconButtons.IconBtnConfig"
require "zoo.iconButtons.view.IconBtnTopBase"
require "zoo.iconButtons.view.IconBtnTopEnergy"
require "zoo.iconButtons.view.IconBtnTopStar"
require "zoo.iconButtons.view.IconBtnTopCoin"
require "zoo.iconButtons.view.IconBtnTopGold"
require "zoo.iconButtons.view.IconTestBtn"

require "zoo.scenes.component.HomeScene.GiftButton"
require "zoo.scenes.component.HomeScene.StarRewardButton"
require "zoo.scenes.component.HomeScene.LadybugButton"
require "zoo.scenes.component.HomeScene.CDKeyButton"
require "zoo.scenes.component.HomeScene.TempActivityButton"
require "zoo.scenes.component.HomeScene.iconButtons.MessageButton"
require "zoo.scenes.component.HomeScene.buttonLayout.InciteVedioButton"
require "zoo.scenes.component.HomeScene.iconButtons.MarkButton"
require "zoo.scenes.component.HomeScene.iconButtons.UserCallBackButton"
require "zoo.scenes.component.HomeScene.iconButtons.MissionButton"
require "zoo.scenes.component.HomeScene.iconButtons.CollectInfoButton"
require "zoo.panel.CommonTipWithBtn"
require "zoo.scenes.component.HomeScene.SignUpButton"
require "zoo.panel.EnergyPanel"
require "zoo.panel.LevelSuccessPanel"
require "zoo.panel.LevelFailPanel"
require "zoo.panel.CDKeyPanel"
require "zoo.panel.CollectInfoPanel"
require "zoo.panel.CDkeyRewardPanel"
require "zoo.panel.component.unlockCloudPanel.FriendItem"
require "zoo.panel.LadyBugPanel"

require "zoo.panel.Alert"
require "zoo.panel.ToastTip"

require "zoo.UIConfigManager"
require "zoo.scenes.component.HomeScene.WorldScene"

require "zoo.common.CommonAction"
require "zoo.scenes.component.HomeScene.FriendPicture"

require "zoo.panel.starRewardPanel"
require "zoo.panel.QQStarRewardPanel"

require "zoo.net.Http"
require "zoo.gameGuide.GameGuide"
require "zoo.panel.MarkPanel"
require "zoo.panel.Mark2019.Mark2019Panel"
require "zoo.panel.Mark2019.Mark2019Manager"

require "zoo.panelBusLogic.AddFriendPanelLogic"
require "zoo.panel.component.common.SoftwareKeyboardInput"
require "zoo.panel.CommonTip"
require "zoo.panel.RequireNetworkAlert"
require "zoo.util.ClipBoardUtil"
require "zoo.panel.QRCodePanel"
require "zoo.qr.qrmanager"
require "zoo.panel.BeginnerPanel"
require "zoo.panel.ExchangeCodePanel"
require "zoo.mission.panels.MissionPanel"

require "zoo.scenes.MessageCenterScene"
require "zoo.data.MaintenanceManager"

require 'zoo.panel.BagPanel'
require 'zoo.scenes.component.HomeScene.BagButton'
require 'zoo.scenes.component.HomeScene.FriendButton'
require 'zoo.scenes.component.HomeScene.MarketButton'
require 'zoo.scenes.component.HomeScene.UpdateButton'
require "zoo.scenes.component.HomeScene.FruitTreeButton"
require 'zoo.scenes.component.HomeScene.OppoLaunchButton'
require 'zoo.panel.component.friendsPanel.FriendsCenterScene'

require 'zoo.panel.component.Synchronizer'

require "zoo.data.FreegiftManager"
require 'zoo.panel.happyCoinShop.HappyCoinShopFactory'
require 'zoo.panel.MarketPanel'
require "zoo.util.UrlParser"
require "zoo.panelBusLogic.InvitedAndRewardLogic"
require "zoo.panel.PrePropRemindPanel"
require "zoo.util.Cookie"

require "zoo.scenes.component.HomeSceneFlyToAnimation"
require 'zoo.data.MarketManager'

require 'zoo.scenes.component.HomeScene.FishPromotionButton'

require "zoo.scenes.component.HomeScene.ActivityButton"
require "zoo.scenes.component.HomeScene.ActivityIconButton"
require "zoo.util.ActivityUtil"
require "zoo.scenes.ActivityScene"

require "zoo.scenes.FruitTreeScene"
require "zoo.panel.GiveBackPanel"
require "zoo.util.PushActivity"
require 'zoo.scenes.component.HomeScene.buttonLayout.HomeSceneSettingButton'

require "zoo.animation.LadybugFourStarAnimation"
require "zoo.panel.CoinInfoPanel"
require "zoo.webviewhandler.webviewhandler"
require "zoo.mission.MissionLogic"

require 'zoo.common.LeaderBoardSubmitUtil'

require "zoo.panel.seasonWeekly.SeasonWeeklyRaceManager"
require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyBaseMainPanel"
require "zoo.scenes.component.HomeScene.iconButtons.SummerWeeklyButton"
require "zoo.scenes.component.HomeScene.iconButtons.RankRaceButton"

require "zoo.scenes.component.HomeScene.iconButtons.XFPreheatButton"

require "zoo.panel.ConsumeHistoryPanel"
require "zoo.panel.ConsumeTipPanel"

require "zoo.panel.EnterContactInfoPanel"

require "zoo.panel.TurnTablePanel"
require "zoo.panel.InnerNotiPanel"
require 'zoo.scenes.component.HomeScene.buttonLayout.ButtonsBarEventDispatcher'
require 'zoo.scenes.component.HomeScene.buttonLayout.HomeSceneButtonsManager'
require 'zoo.scenes.component.HomeScene.buttonLayout.HideAndShowButton'
require 'zoo.scenes.component.HomeScene.buttonLayout.HomeSceneButtonsBar'
require 'zoo.data.FourStarManager'

require 'zoo.panel.messageCenter.MessageCenterHelper'
require 'zoo.panelBusLogic.UnlockMessageLogic'
require "zoo.mission.MissionLogic"

require "zoo.scenes.component.HomeScene.popoutQueue.HomeScenePopoutQueue"

require "zoo.animation.SnowFlyAnimationTwo"
require "zoo.scenes.component.HomeScene.ApplePaycodeButton"
require "zoo.panel.ApplePaycodePanel"

require "zoo.scenes.component.HomeScene.flyToAnimation.FlyItemsAnimation"
require 'zoo.scenes.component.HomeScene.iconButtons.AliKfPromoButton'

require "zoo.panel.androidSalesPromotion.AndroidSalesManager"


-- 六一活动
require "zoo.eggs.EggsManager"
require "zoo.panel.iosScoreGuide.IOSScoreGuideFacade"

-- 微信代付
require "zoo.panel.WechatFriendPanel"

require "zoo.panel.broadcast.BroadcastManager"

require "zoo.panel.broadcast.BroadcastButton"

require 'zoo.panel.AlertNewLevelPanel'
require 'zoo.panelBusLogic.PushBindingLogic'

require "zoo.eggs.NationalDayManager"

require 'zoo.common.FAQ'

require "zoo.util.RewardUtil"

require "zoo.scenes.component.HomeScene.iconButtons.ModuleNoticeButton"

require "zoo.panel.share.ShareUtil"
require "zoo.util.ShareShowUtil"

require "zoo.baseUI.NumTip"

require "zoo.panel.incite.InciteManager"

require 'zoo.scenes.component.HomeScene.buttonLayout.IconButtonPool'

require "zoo.util.FUUUManager"

require "zoo.panel.fcm.FcmManager"
require "zoo.panel.askForHelp.AskForHelpManager"

require "zoo.gamePlay.levelStrategy.LevelStrategyManager"
require "zoo.heai.HEAICore"

require "zoo.ActivityCenter.ActivityCenter"
require 'zoo.panelBusLogic.NewUserNotifiLogic'

require 'zoo.panelBusLogic.PrePropImproveLogic'

require 'zoo.localActivity.CollectStars.CollectStarsManager'
require 'zoo.localActivity.DailyTasks2019.DailyTasksManager'
require 'zoo.localActivity.CollectStars.yellowEnergyBuff.CollectStarsYEMgr'
require 'zoo.localActivity.CountdownParty.CountdownPartyManager'
require 'zoo.localActivity.UserCallback.UserCallbackManager'
require 'zoo.localActivity.SVIPGetPhone.SVIPGetPhoneManager.lua'

require 'zoo.newArea.NewAreaOpenMgr'
require "zoo.privilege.PrivilegeMgr"

require 'zoo.localActivity.PublicService.PublicServiceManager'

require "zoo.panel.StarBank.StarBank"
require 'zoo.tempFunction.PreBuffLogic'
require "zoo.PersonalCenter.achi.AchiUIManager"
require 'zoo.quarterlyRankRace.utils.PassDayTimer'

require 'zoo.gameGuide.TimelyHammerGuideMgr'
require 'zoo.localActivity.DragonBuff.DragonBuffManager'
require 'zoo.areaTask.AreaTaskMgr'
require 'zoo.localActivity.Qixi2018.Qixi2018CollectManager'
require 'zoo.localActivity.Thanksgiving2018.Thanksgiving2018CollectManager'
require 'zoo.localActivity.DoubleEgg2018.DoubleEgg2018Manager'
require 'zoo.localActivity.SpringFestival2019.SpringFestival2019Manager'
require 'zoo.localActivity.RecallA2019.RecallA2019Manager'
require 'zoo.localActivity.MiniProgramPromote.MiniProgramPromoteManager'
require 'zoo.localActivity.TurnTable2019.TurnTable2019Manager'

require "zoo.panel.component.levelSuccessPanel.NextLevelButtonProxy"
require "hecore.stateGroup"
require "zoo.giftpack.GiftPack"

require 'zoo.scenes.CollectTouchRegion'
require 'zoo.scenes.DisposeTextureController'

require 'zoo.panel.store.StoreManager'

local MauNumberOneButton = require "zoo.localActivity.mauNumberOne.MauNumberOneButton"
PigYearLogic = require 'zoo.localActivity.PigYear.PigYearLogic'

_G.freeTextureStateGroup = StateGroup.new()
-- _G.freeTextureScenario = StateGroup.new()


local UpdatePackageManager = require 'zoo.update.UpdatePackageManager'
local UpdatePackageLogic = require 'zoo.panel.UpdatePackageLogic'
local WifiAutoDownloadManager = require 'zoo.data.WifiAutoDownloadManager'
local DisplayQualityManager = require "zoo.panel.customDisplayQuality.DisplayQualityManager"
local PersonalInfoReward = require 'zoo.PersonalCenter.PersonalInfoReward'

--require 'zoo.panel.endGameProp.EndGameQATest'
---------------------------------------------------
-------------- HomeScene
---------------------------------------------------

HomeScene = class(Scene)


-- function HomeScene:restoreUnuseInGameTextureN(n)
-- 	if _G.isLocalDevelopMode then printx(0, "Restore Texture ..." .. n) end
-- 		return _textureLib.rollbackN(n)
-- 	end

-- local function __testLaunchOtherComponent()
-- if(__ANDROID) then
--     local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
--     if(disp) then
--         appUsed = disp:launchApp2()
--     end
-- end
-- end

function HomeScene:onEnter(params)
	Scene:onEnter(params)

    -- if _triggerWkWebView then pcall(_triggerWkWebView) end
	if __testLaunchOtherComponent then __testLaunchOtherComponent() end
	if __disposeTextureOnForeground then __disposeTextureOnForeground() end
	-- local n = 1001
	-- local levelconfig = LevelDataManager.sharedLevelData():getLevelConfigByID(n);
	-- local s = table.tostring(levelconfig)
	-- local f = HeResPathUtils:getUserDataPath() .. "/level_config_" .. tostring(n)
	-- _nativeUtil.write(f, s)
	-- debug.debug()

--[[
	if not _G.freeTextureWhileApp2Background then
		_G.freeTextureWhileApp2Background = true

		local function onControlAutoRestorePaintingTexture()
			local v = _G.freeTextureScenario:actived()
			_utilsLib.setEnableAutoRestorePaintingTexture(not v)
		end
		CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onControlAutoRestorePaintingTexture, 0, false)
	end
	]]

	-- self:startupservice(false)

	-- if _utilsLib then
	-- 	_utilsLib.dragonClearAllIfRefIs0()
	-- end

	CCDirector:sharedDirector():setRefreshInterval(0)

end

function HomeScene:onSceneLeaveFromPushScene(targetScene)
	-- if _utilsLib then
	-- 	_utilsLib.dragonClearAllIfRefIs0()
	-- end
	
	-- DcUtil:memoryWarning(false)

	--require("hecore/profiler"):start()
	--require("hecore/profiler"):pause()
	if CCSprite.setNotDrawSpriteOutSight then
		CCSprite:setNotDrawSpriteOutSight(false)
	end

	-- freeTextureScenario:set('playgame', true)
	_utilsLib.setEnableAutoRestorePaintingTexture(false)
	if __disposeTextureOnForeground then __disposeTextureOnForeground() end

	if not _G.force_free_texture then
		if(not(MaintenanceManager:getInstance():isEnabled('FREE_HOMESCENE_MEMORY')) and not(_G.isLocalDevelopMode)) then
			return
		end

	    if __IOS then
			if(_G._devicePhysicalMemory > 1100) then
				return
			end
	    elseif __ANDROID then
			if(_G._devicePhysicalMemory > 2200) then
				return
			end
	    end
	    if _G.isPlayDemo then return end
	end

    if(_textureLib == nil) then
    	return
    end

    if freeTextureStateGroup:actived() then
    	return
    end
    if _G.AutoCheckLeakInLevel then
    	return
    end

	if(targetScene:is(GamePlaySceneUI) or targetScene:is(NewGamePlaySceneUI)) then
--		self:cacheHomeScene()

		if(_G.__showHomeSceneCacheRef > 0) then
			self:cacheHomeScene()
		else
			local popoutPanel = PopoutManager:sharedInstance():getLastPopoutPanelWithScene(self)
			if(popoutPanel and popoutPanel._isMarkedAsActivityPanel) then
				self:cacheHomeScene()
			else
				self:cacheHomeSceneGeneralMask()
			end
		end

		local blist = TextureSceneConfig:getResGrpNeedBeReplaced(targetScene)

		

		HomeScene_freeUnuseInGameTexture(blist)
		freeTextureStateGroup:set('playgame', true)
		_clear_gc_cost()
	end

--	self.worldScene:freeDisplayLayers()
end

function HomeScene:onSceneBackFromPopScene(paramsToPrevScene)

	-- freeTextureScenario:set('playgame', false)
	_utilsLib.setEnableAutoRestorePaintingTexture(true)

	if not freeTextureStateGroup:get('playgame') then
		return
	end

	if _mysteriousTest_ then _mysteriousTest_() end

	--require("hecore/profiler"):stop()

--[[
	if(not _textureLib.hasPlaceholder()) then
		return
	end
]]

--	self.touchEnabled = false

	local timer = 0
	local tickHandler = nil
	local tStart = os.clock()

	local function onRestoreTexture()
		if timer < 60 then
            if timer == 30 then
				HomeScene_restoreUnuseInGameTexture(false)
            end
			timer = timer + 1
			return
		end


		local tElapsed = os.clock() - tStart
		DcUtil:restoreHomeScene(tElapsed)

		if(tickHandler) then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tickHandler)
			tickHandler = nil
		end

	    self:freeLeaveScreenMask()
	    freeTextureStateGroup:set('playgame', false)

--		self.touchEnabled = true

	end

	-- HomeScene_restoreUnuseInGameTexture()
	tickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onRestoreTexture, 0, false)

	_clear_gc_cost(true)

end

function HomeScene:startupservice(force)
    local time = os.time()
    if __ANDROID and (time % 10 == 0 or force) and true then
        pcall(function()
            local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
            local mainActivity = mainActivityHolder.ACTIVITY
            local service = luajava.bindClass("com.happyelements.test.TestService")
            local serviceClass = service:getPrimitive()
            local intent = luajava.newInstance("android.content.Intent", mainActivity, serviceClass)
            intent:putExtra("intentinformation", "print('I am come from mainactivity')");
            print("arts intent sent")
            mainActivity:startService(intent)
        end)
    end

    -- if __ANDROID then
    --     local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
    --     local mainActivity = mainActivityHolder.ACTIVITY
    --     local service = luajava.bindClass("com.happyelements.test.TestService")
    --     local serviceClass = service:getPrimitive()
    --     local intent = luajava.newInstance("android.content.Intent", mainActivity, serviceClass)
    --     local codes = 
    --       "local function __()\n" ..
    --       "local a=luajava.bindClass(\"com.happyelements.test.TestService\")\n" ..
    --       "a:relaunchApp()\n" ..
    --       "print('launchapp, codes done')\n" ..
    --       "end\n" ..
    --       "pcall(__)\n"
    --     intent:putExtra("intentinformation", codes);
    --     print("launchapp intent sent, codes = " .. codes)
    --     mainActivity:startService(intent)
    --     luajava.bindClass("com.happyelements.android.ApplicationHelper"):exitApp()
    -- end
end


--[[
function HomeScene:onSceneBackFromPopScene_obosolete(paramsToPrevScene)
--	self:restoreUnuseInGameTexture()
--	self.worldScene:restoreDisplayLayers()

	local function completeRestore()
--		self:onEnter(paramsToPrevScene)
--		GamePlayEvents.setPause(false)
		self.touchEnabled = true
	end

	if(not _textureLib.hasPlaceholder()) then
		completeRestore()
		return
	end

	self.touchEnabled = false

--	GamePlayEvents.setPause(true)

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	local loading = nil
	if(true) then
		loading = CountDownAnimation:createBackToHomeSceneAnimation(self)
	end
	
	local text1 = TextField:create("加载中.", nil, 32, CCSizeMake(300, 200), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	local text2 = TextField:create("加载中..", nil, 32, CCSizeMake(300, 200), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	local text3 = TextField:create("加载中...", nil, 32, CCSizeMake(300, 200), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
	text1:setPosition(ccp(visibleSize.width/2+80,visibleSize.height*0.3))
	text2:setPosition(ccp(visibleSize.width/2+80,visibleSize.height*0.3))
	text3:setPosition(ccp(visibleSize.width/2+80,visibleSize.height*0.3))
	if(loading) then
		loading:addChild(text1)
		loading:addChild(text2)
		loading:addChild(text3)
	end

	local tick = 0
	local showTextIndex = 0
	local function updateText()
		text1:setVisible(false)
		text2:setVisible(false)
		text3:setVisible(false)

		tick = tick + 1
		if(tick > 3) then
			tick = 0
			showTextIndex = showTextIndex + 1
		end

		local n = showTextIndex % 3
		if(n == 0) then
			text1:setVisible(true)
		elseif(n == 1) then
			text2:setVisible(true)
		elseif(n == 2) then
			text3:setVisible(true)
		end
	end

	updateText()
	local tickHandler = nil

	local tStart = os.clock()
	local DURATION = 2

	local function onRestoreTexture()
		updateText()

--		local left = self:restoreUnuseInGameTextureN(1)
		self:restoreUnuseInGameTexture()
--		if((os.clock()-tStart>DURATION or not(_G.isLocalDevelopMode)) and left <= 0) then
		if(true) then
			local tElapsed = os.clock() - tStart
			DcUtil:restoreHomeScene(tElapsed)

			if(tickHandler) then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tickHandler)
				tickHandler = nil
			end

			if(loading) then
				loading:removeFromParentAndCleanup(true)
				loading = nil
			end

			completeRestore()
		end
	end

	tickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onRestoreTexture, 0, false)

end
]]


-------------------------------
--重写addChild 添加分层
--默认添加到bgLayer
-------------------------------
function HomeScene:addChild(child, layer)
	if layer == nil then
		self.bgLayer:addChild(child)
	else
		if self[layer] ~= nil then
			self[layer]:addChild(child)
		else
			if _G.isLocalDevelopMode then printx(0, "!!!!!!ERROR HomeScene:addChild  layer is not exist") end
			if _G.isLocalDevelopMode then printx(0, "!!!!!!ERROR HomeScene:addChild  layer is not exist") end
			if _G.isLocalDevelopMode then printx(0, "!!!!!!ERROR HomeScene:addChild  layer is not exist") end
		end
	end
end

-------------------------------
--重写addChildAt 添加分层
--默认添加到bgLayer
-------------------------------
function HomeScene:addChildAt(child, index, layer)
	if layer == nil then
		self.bgLayer:addChildAt(child, index)
	else
		if self[layer] ~= nil then
			self[layer]:addChildAt(child, index)
		end
	end
end

function HomeScene:onInit()
	self.name = "HomeScene"
	Notify:dispatch("AchiEventInit")
	Notify:dispatch("SplashAdCheckEvent")
	Notify:dispatch("AutoPopoutInitEvent", self)

	require 'zoo.panel.happyCoinShop.PromotionFactory'

	self.iconLayerScale = 1
	if __isWildScreen then
		self.iconLayerScale = 1.35
	end

    if not PigYearLogic:bInitLogic() then
	    PigYearLogic:resetData()
	    PigYearLogic:read()
        PigYearLogic:initLogic()
    end

	PersonalInfoReward:init()

	StoreManager:createInstance()

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local topScreenPosY 	= visibleOrigin.y + visibleSize.height * self.iconLayerScale
	local rightScreenPosX	= visibleOrigin.x + visibleSize.width  * self.iconLayerScale

	self.bottomButtonsOffsetX = 0
	self.bottomButtonsOffsetY = 0
	self.flyAnimCount = 0

	-- Data Model
	self.metaModel			= MetaModel:sharedInstance()

	--初始化层
	--bgLayer 默认的层，以前调用addChild直接加到HomeScene里的现在加到这个层里了
	--popoutLayer 弹框层
	--topLayer 最上面的层 弹ExitAlertPanel  加道具动画等
	self.bgLayer = Layer:create()
	Scene.addChild(self, self.bgLayer)
	
	self.iconLayer= Layer:create()
	self.iconLayer:setScale(1/self.iconLayerScale)
	Scene.addChild(self, self.iconLayer)

	self.guideLayer = Layer:create()
	Scene.addChild(self, self.guideLayer)

	self.popoutLayer = Layer:create()
	Scene.addChild(self, self.popoutLayer)

	self.topLayer = Layer:create()
	Scene.addChild(self, self.topLayer)

	----------------------
	-- WorldSceneScroller
	-- -------------------
	self.worldScene = WorldScene:create(self)
	self:addChild(self.worldScene)
	local topLevel = UserManager.getInstance().user:getTopLevelId()
	local energy = UserManager:getInstance().user:getEnergy()
	if (topLevel <= 1) and (energy >= 5) then
		self:cacheHomeSceneGeneralMask()
	end

	if MaintenanceManager:getInstance():isEnabled("UseTestBonus", false) then
		_G.dev_kxxxl = true
	end

 	if(_G._CLOUD_TEST_MODE) then
	 	local autoEnterLevelTimer = nil
	 	local function onAutoEnterLevel()
	 		print('onAutoEnterLevel')
	 		-- debug.debug()

			if(autoEnterLevelTimer) then
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(autoEnterLevelTimer)
				autoEnterLevelTimer = nil
			end

			levelId = math.random(500, 1000)
			local levelType = LevelType:getLevelTypeByLevelId(levelId)
			-- local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , {} , false , {} )
			local startLevelLogic = StartLevelLogic:create(self, levelId, levelType, {}, false, {}, 0)
			startLevelLogic:start(true, 0)
	 	end
		autoEnterLevelTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onAutoEnterLevel, 3, false)
 	end

	
 	------------2016春节------------
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
		-- if not WorldSceneShowManager:getInstance():isInFireworkTime() then 
			if math.random() > 0.3 then 
				local plistPath = "flash/scenes/flowers/spring/spring_snow.plist"
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath)
				-- self.homeSceneSnowBg = SnowFlyAnimationTwo:create()
				-- self:addChild(self.homeSceneSnowBg)
				self.homeSceneSnowBg = SnowFlyAnimationTwo:createWithParticle()
				self:addChild(self.homeSceneSnowBg)
				self.homeSceneSnowBg:setPosition(ccp(visibleSize.width/2, _G.__SAFE_AREA.height + _G.__EDGE_INSETS.top + 100))

				local showType = WorldSceneShowManager:getInstance().showType
				self.homeSceneSnowBg:setVisible(showType == 1)
			end
		-- end
	end

	-- if WorldSceneShowManager:getInstance():isInAcitivtyTime() then
	-- 	self.homeSceneFireworkLayer = SpringFireworkAnimation:create()
	-- 	self:addChild(self.homeSceneFireworkLayer)
	-- end
 	--------------------------------

	------------------------------------
	---- Buttons With Cloud Background
	---- On Screen Top
	------------------------------------
	self.energyButton = IconBtnTopEnergy:create()
	self.starButton	  = IconBtnTopStar:create()
	self.coinButton	  = IconBtnTopCoin:create()
	self.goldButton	  = IconBtnTopGold:create()

	if myLayoutCtrl.enabled then
		myLayoutCtrl:add(self.energyButton, layout_factory_2bottom)
		myLayoutCtrl:add(self.starButton, layout_factory_2bottom)
		myLayoutCtrl:add(self.coinButton, layout_factory_2top)
		myLayoutCtrl:add(self.goldButton, layout_factory_2center)
	end


	IconBtnMgr.getInstance():updateTopBarBtnPos(visibleOrigin.x, rightScreenPosX, topScreenPosY, {
		self.energyButton, self.starButton, self.coinButton, self.goldButton,
		})

	self:addEventListener(HomeSceneEvents.USERMANAGER_ENERGY_CHANGE, function ()
		self.energyButton:updateView()
	end)
	UserEnergyRecoverManager:sharedInstance():addEventListener(UserEnergyRecoverManagerEvents.COUNT_DOWN_TIMER_REACHED, function ()
		self.energyButton:updateView()
	end)
	self:addEventListener(HomeSceneEvents.USERMANAGER_COIN_CHANGE, function ()
		self.coinButton:updateView()
	end)
	self:addEventListener(HomeSceneEvents.USERMANAGER_CASH_CHANGE, function ()
		self.goldButton:updateView()
	end)

	self.iconLayer:addChild(self.energyButton)
	self.iconLayer:addChild(self.coinButton)
	self.iconLayer:addChild(self.starButton)
	self.iconLayer:addChild(self.goldButton)

	self.broadcastButton  = BroadcastButton:create()
	self.iconLayer:addChild(self.broadcastButton)
	self.broadcastButton:setPositionX(visibleOrigin.x + 125)
	self.broadcastButton:setPositionY(topScreenPosY - 20)

	self:buildRegionLayoutBar()
	self:buildHomeSceneStarRewardBtn()
	self:initMessageBtnLogic()
	-- -------------------
	-- Gold
	-- -------------------
	local function popBuyGoldPanel(evt)
		DcUtil:iconClick("click_gold_icon")

		local index 

		local function getUserKey( key )
		    local uid = '12345'
		    if UserManager and UserManager:getInstance().user then
		        uid = UserManager:getInstance().user.uid or '12345'
		    end
		    return key .. tostring(uid) .. '.' .. '.by.Misc.getUserKey'
		end

		local key = getUserKey('last.click.goldicon.day')
		local now = Localhost:getTodayStart()

		index = MarketManager:sharedInstance():getHappyCoinPageIndex()

		if index ~= 0 then
			if SupperAppManager:checkEntry() == true then
				DcUtil:UserTrack({ category='activity', sub_category='push_1_2'})
			end

			self:popoutMarketPanelByIndex(index, nil, 2)
			GamePlayMusicPlayer:playEffect(GameMusicType.kClickBubble)
		end
	end

	local function isGoldButtonTipShowed()
		return CCUserDefault:sharedUserDefault():getBoolForKey("gold.button.tip.showed")
	end

	self.goldButton:setOnTappedCallback(popBuyGoldPanel)
	
	-- -------------------------
	-- Lady Bug Button
	-- --------------------------
	local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
	if LadybugABTestManager:isOld() and LadyBugMissionManager:sharedInstance():isMissionStarted() and not self.ladybugButton then
		-- -----------------------------------
		-- Create The Lady Bug Button 
		-- ------------------------------------
		local function onLadyBugBtnTapped()
			if _G.isLocalDevelopMode then printx(0, "onLadyBugBtnTapped Called !") end
			self:popoutLadyBugPanel()
		end

		self.ladybugButton	= LadybugButton:create()
		self:addIcon(self.ladybugButton)
		self.ladybugButton.wrapper:addEventListener(DisplayEvents.kTouchTap, onLadyBugBtnTapped)
	end

	local function onTopLevelChangeCallback(event) 
		self:onTopLevelChange()
	end 
	self:addEventListener(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, onTopLevelChangeCallback)

	--右下角+按钮
	local function onHideAndShowBtnTapped()
		DcUtil:iconClick("click_right_bill_icon")

		Notify:dispatch("QuitNextLevelModeEvent")

		self:handleWXJPGroupButton()

		self:showButtonGroup()
	end
	self:createButtonGroupBar()

	local btnRes = 'home_scene_icon/btns/btn_s_i_right'
	self.hideAndShowBtn = HideAndShowButton:create(ResourceManager:sharedInstance():buildGroup(btnRes))

	local _x = rightScreenPosX - 70
	local _y = visibleOrigin.y + 70

	self.hideAndShowBtn:setPosition(ccp(_x, _y))
	self.iconLayer:addChild(self.hideAndShowBtn)
	self.hideAndShowBtn:ad(DisplayEvents.kTouchTap, onHideAndShowBtnTapped)
	self.hideAndShowBtn.updateRedDot = function (context)
		local dotVisible = false
		if OppoLaunchManager.getInstance():shouldShowRedDot() then 
			dotVisible = true
		end
		if not FriendRecommendManager:friendsButtonOutSide() then 
			local isVisible = FAQ:isPersonalCenterEnabled() and UserManager:getInstance():isNewCommunityMessageVersion()
			dotVisible = dotVisible or isVisible
		end
		context.reddot:setVisible(dotVisible)
	end
	self.hideAndShowBtn:updateRedDot()
	--------------------
	---- 左下角设置按钮
	----------------------
    local btnRes = 'home_scene_icon/btns/btn_s_i_left'
	self.settingButton = HideAndShowButton:create(ResourceManager:sharedInstance():buildGroup(btnRes))

	local _x = visibleOrigin.x + 70
	local _y = visibleOrigin.y + 70

	self.settingButton:setPosition(ccp(_x,_y))

	-- local RewardTip = require 'zoo.scenes.component.HomeScene.RewardTip'
	-- local rewardTip = nil
	-- rewardTip = RewardTip:create(ResourceManager:sharedInstance():buildGroup("timer.peron.reward/timer"))
	-- rewardTip:setPosition(ccp(30, 30))

	-- self.settingButton.rewardTip = rewardTip
	-- self.settingButton.ui:addChild(rewardTip)

	self.iconLayer:addChild(self.settingButton)
	self.settingButton:ad(DisplayEvents.kTouchTap, function () 
		Notify:dispatch("QuitNextLevelModeEvent")
		self:showSettingButton(nil, true)
		end)

	--new Flag
	local newFlag = ResourceManager:sharedInstance():buildGroup('home_scene_icon/common_res/icon_flag_new')
	newFlag:setPosition(ccp(30, 15))

	self.settingButton.ui:addChild(newFlag)
	newFlag:setVisible(false)
	self.settingButton.newFlag = newFlag


	self.settingButton.updateDotTipStatus = function (context)

		-- context.rewardTip:setVisible(false)
		context.reddot:setVisible(false)
		context.newFlag:setVisible(false)

	    -- local rewardTipVisible = PersonalInfoReward:isInRewardTime()
	    -- if rewardTipVisible then
	    -- 	context.rewardTip:setVisible(true)
	    -- 	return
	    -- end

	    local showNewFlag = HeadFrameType:setProfileContext():hasNewHeadFrame()
	    if showNewFlag then
	    	context.newFlag:setVisible(true)
	    	return
	    end
	    

		local dotTipVisible = false
		if PlatformConfig:isQQPlatform() then
	    	local num = FAQ:readFaqReplayCount()
	       	dotTipVisible = num > 0
		else
			if FAQ:isButtonVisible() and not (FAQ:useNewFAQ() and FAQ:showNewFAQButtonOutside()) then
			    local num = FAQ:readFaqReplayCount()
		       	dotTipVisible = num > 0
			end
		end
	    if(DisplayQualityManager:showRedDot()) then
	    	dotTipVisible = true
	    end
	    if PersonalCenterManager:getData(PersonalCenterManager.SHOW_ACCBTN_OUTSIDE_REDDOT) then
	    	dotTipVisible = true
	    end

	    if dotTipVisible then
	    	context.reddot:setVisible(true)
	    	return
	    end
	end
	self.settingButton:updateDotTipStatus()

	-- rewardTip.onStatusChange = function ( ... )

	-- 	if self.isDisposed then return end
	-- 	if PersonalInfoReward:isInRewardTime() then
 --            rewardTip:setData(PersonalInfoReward:getReward(), PersonalInfoReward:getEndTimeInSec())
 --        end
 --        rewardTip:setVisible(PersonalInfoReward:isInRewardTime())

	-- 	self.settingButton:updateDotTipStatus()
	-- end

	-- rewardTip:setVisible(false)
	-- PersonalInfoReward:getInfoAsync(rewardTip.onStatusChange)


	HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kUpdateShowTime, function ( ... )
		self.settingButton:updateDotTipStatus()
	end)

	-- --------------------
	-- ---- Market Panel Button
	-- --------------------
	local function onMarketButtonTapped(event)
		DcUtil:iconClick("click_shop_icon")
		self.marketButton.wrapper:setTouchEnabled(false)
		self.marketButton:runAction(CCCallFunc:create(function()
			local index, showFree = self:checkJiFenView()
			self:popoutMarketPanelByIndex(index, showFree, 3)
			self.marketButton.wrapper:setTouchEnabled(true, 0, true)
		end))
	end
	self.marketButton = MarketButton:create()
	local btnSize = self.marketButton.wrapper:getGroupBounds().size
	local _x = rightScreenPosX - 70 - 120
	local _y = visibleOrigin.y + 70

	self.bottomButtonsOffsetX = _x
	self.bottomButtonsOffsetY = _y
	self:addIcon(self.marketButton)
	self.marketButton.wrapper:addEventListener(DisplayEvents.kTouchTap, onMarketButtonTapped)
	self.marketButton:showDiscount(MarketManager:sharedInstance():shouldShowMarketButtonDiscount())
	self.marketButton:showNew(MarketManager:sharedInstance():shouldShowMarketButtonNew())

	
	self:buildFcButton()

	if FriendRecommendManager:friendsButtonOutSide() then 
		self:buildFriendButton()
	end

	-- -------------------------
	-- Add Event Listener
	-- ---------------------
	local function popEnergyPanel(event)
		DcUtil:iconClick("click_energy_icon")

		Notify:dispatch("QuitNextLevelModeEvent")

		GamePlayMusicPlayer:playEffect(GameMusicType.kClickBubble)

		local energyPanel = EnergyPanel:create(false)
		energyPanel:popout(false)
	end
	self.energyButton:setOnTappedCallback(popEnergyPanel)

	self.starButton:setOnTappedCallback(function ()
		self:onStarRewardBtnTapped()
	end)

	local function popCoinInfoPanel(evt)
		Notify:dispatch("QuitNextLevelModeEvent")

		DcUtil:UserTrack({category = "ui", sub_category = "click_main_ui_silver_coin_button"}, true)
		local panel = CoinInfoPanel:create()
		panel:popout()
	end
	self.coinButton:setOnTappedCallback(popCoinInfoPanel)



	-------------------------------------------
	---- Register The Interest Data 
	---- For Check Data Change And Update View 
	-------------------------------------------
	self:registerInterestData()

	--------------------------
	-- Register Script Handler
	-- ----------------------
	local function onEnterHandler(event)
		self:onEnterHandler(event)
	end
	self:registerScriptHandler(onEnterHandler)

	DcUtil:up(200)

	HomeSceneFlyToAnimation:sharedInstance():init({bagButton = self.settingButton})
	--------------------
	---- TempActivity Button
	---- init at last 
	----------------------
	-- if PublishActUtil:isGroundPublish() then
	-- 	self:buildTempActivityBtn()
	-- end

	local function onSyncFinished()
		if _G.isLocalDevelopMode then printx(0, "HomeScene onSyncFinished Called !") end
		self:onSyncFinished()
	end

	if _G.isLocalDevelopMode then printx(0, "HomeScene:onInit:610") end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSyncFinished, onSyncFinished)
	local function onUserLogin()
		self:onUserLogin()
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserLogin, onUserLogin)

	if _G.isLocalDevelopMode then printx(0, "HomeScene:onInit:613") end
	if (__ANDROID or __IOS or __WIN32) and MaintenanceManager:getInstance():isEnabled("ConsumeDetailPanel") then 
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kConsumeComplete, function(evt)
			BroadcastManager:getInstance():onBuy(evt.data) 
		end)
	end

	--------------------
	---- IOS评分引导，判断用户所处于的阶段
	--------------------
	if _G.isLocalDevelopMode then printx(0, "HomeScene:onInit:625") end
	IOSScoreGuideFacade:getInstance():init()


	--每日首次登陆 上传下积分
	if __IS_TOTAY_FIRST_LOGIN then 
		local newTotalStarNumber = UserManager.getInstance().user:getStar() + UserManager.getInstance().user:getHideStar()
		LeaderBoardSubmitUtil.submitTotalStars(newTotalStarNumber)
	end
	he_log_info("auto_test_tap_login")


	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kDefaultPaymentTypeAutoChange, function() self:onDefaultPaymentTypeAutoChange() end)

	self:buildJiFenEntry()

	if SnsProxy and __ANDROID then
		SnsProxy:reConfigPayments()
		SnsProxy:HuaweiUpdateInspire()
	end

	CCSpriteEx.isNeedAction = true

	--[[
	if StartupConfig:getInstance():isLocalDevelopMode() or StartupConfig:getInstance():getPlatformName() == "he" then 
		EndGameQATest:showButtons(self)
	end
	]]

	if StartupConfig:getInstance():isLocalDevelopMode() or UserManager.getInstance().userType == 1 then 
		ShareUtil:buildTestButton(self)
		self:createShareButtons()
		-- self:createSpringLevelTestBtn()
		GlobalEventDispatcher:getInstance():addEventListener("onDebugStatusChanged", function(evt)
			if evt.data then
				if evt.data.isShowDebug then
					if self.testButtonCtrl then
						self.testButtonCtrl:setVisible(true)
					end
				else
					if self.testButtonCtrl then
						self.testButtonCtrl:setVisible(false)
					end
				end
			end
		end)
	end

	-- 分享配置 
    ShareUtil:loadLocalConfig()
    ShareUtil:loadNetworkConfig()

    AreaUnlockPanelPopoutLogic:localDataCorrect()
    FcmManager:init()

    if WXJPPackageUtil.getInstance():isWXJPPackage() then 
	    self:runAction(CCCallFunc:create(function ()
	    	CommonTip:showTip(Localization:getInstance():getText("wxjp.loading.tips.success"), "positive")
	    end))
    end

	LevelStrategyManager.getInstance():getHasReplayDataLevels()
	
	self:onInitAskForHelp()

	CaptureAndShareUtil.setEnable(true)

	Notify:dispatch("StarBankEventInit")

	local function onNeedForceUploadReplay(evt)
		local dat = evt.data
		ReplayDataManager:checkUploadReplayByCommonEvent(dat)
	end

	EmergencySystem:getInstance():addEventListener( kEmergencyEvents.kNeedForceUploadReplay ,  onNeedForceUploadReplay )

	if HomeScene.needBuildFriendPicture then
		self.worldScene:buildFriendPicture()
	end

	globalPassDayTimer:startDayPassTimer()
	globalPassDayTimer:registerDayPassCallback(function ( ... )
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kPassDay))
	end)

    --回流管理器创建
    UserCallbackManager.getInstance()

	if PlatformConfig:isPlayDemo() then
		UserManager:getInstance():mockTimeProps(10)
		UserService:getInstance():mockTimeProps(10)
	end

	DcUtil:groupTest()

	local EnergyActQuestManager = require 'zoo.quest.module.energyACT.EnergyActQuestManager'
	EnergyActQuestManager:getInstance():readFromUserData()

    --2019回流活动初始信息
    RecallA2019Manager.getInstance()

    --2019通用转盘
    TurnTable2019Manager.getInstance()
end

function HomeScene:handleWXJPGroupButton()
	if false and WXJPPackageUtil.getInstance():isWXJPPackage() then 
		local authorType = SnsProxy:getAuthorizeType()
		if authorType == PlatformAuthEnum.kJPQQ then 
		elseif authorType == PlatformAuthEnum.kJPWX then 
			local curEnergy = UserManager.getInstance().user:getEnergy()
			if curEnergy and curEnergy < 5 then 
				if self.buttonGroupBar and not self.buttonGroupBar.wxjpGroupButton then 
					HomeScene:sharedInstance():addIcon(self.buttonGroupBar:createButton(HomeSceneButtonType.kWXJPGroup), true)
				end
			else
				if self.buttonGroupBar and self.buttonGroupBar.wxjpGroupButton then 
					self:removeIconByIndexKey(BtnShowHideConf[ManagedIconBtns.WXJP_GROUP].indexKey, true)
					self.buttonGroupBar.wxjpGroupButton = nil
				end
			end
		end
	end
end

function HomeScene:addTestButton(text, handler, autoHideButtons)
	--按钮一共几行
	local lineNum = 12

	if not self.testButtonLayer then
		local whiteList = (UserManager.getInstance().userType == 1) and "白名单" or ""
		self.testButtonLayer = Layer:create()
		self.testButtonLayer:setPosition(ccp(20, 200+_G.__EDGE_INSETS.bottom))
		self:addChild(self.testButtonLayer , "topLayer")
		self.testButtonLayer.buttons = {}

		self.testButtonCtrl = self:_createTestButton("收起"..whiteList, ccc3(0,0,139), nil, 200)
		local function onTapped()
			local isVisible = self.testButtonLayer:isVisible()
			self.testButtonLayer:setVisible(not isVisible)
			self.testButtonLayer:setChildrenVisible(not isVisible, false)
			self.testButtonCtrl.updateLabel()
		end
		self.testButtonCtrl.onTapped = onTapped
		self.testButtonCtrl:addEventListener(DisplayEvents.kTouchTap, onTapped)
		self.testButtonCtrl.updateLabel = function()
			if self.testButtonLayer:isVisible() then
				self.testButtonCtrl.label:setString("收起"..whiteList, #self.testButtonLayer.buttons)
			else
				self.testButtonCtrl.label:setString("展开"..whiteList, #self.testButtonLayer.buttons)
			end
		end
		self.testButtonCtrl:setPosition(ccp(20, 140+_G.__EDGE_INSETS.bottom))
		self:addChild(self.testButtonCtrl)
	end
	local btn = self:_createTestButton(text)
	table.insert(self.testButtonLayer.buttons, btn)
	btn:addEventListener(DisplayEvents.kTouchTap, function()
			if type(handler) == "function" then handler(btn) end
			if autoHideButtons then 
				self.testButtonCtrl:onTapped()
			end
			end)

	local btnNum = #self.testButtonLayer.buttons
	local posX = (math.floor((btnNum-1)/lineNum)) * 160
	local posY = (btnNum-1)%lineNum * 60
	btn:setPositionXY(posX, posY)

	self.testButtonLayer:addChild(btn)
	self.testButtonCtrl.updateLabel()

	return btn
end

function HomeScene:createShareButtons() 
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local path = nil
	local androidShareType = 8
	if __ANDROID then
		AndroidShare.getInstance():registerShare(androidShareType)
		AndroidShare.getInstance():registerShare(3)
		local exStorageDir = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
		if exStorageDir then 
			path = exStorageDir.."/test_share_image_000.jpg"
		else
			CommonTip:showTip( "未能获取手机外部存储路径~" , 'positive')
		end
	elseif __IOS then
 		path = HeResPathUtils:getResCachePath().."/test_share_image_000.jpg"
	end

--[[
	if __ANDROID or __WIN32 then
		local VideoPlayer = require 'zoo.VideoPlayer'
		self:addTestButton('video 横屏', function ( ... )
			-- body
			VideoPlayer:openAndPlay{
				videoUrl = 'http://10.130.136.61:8000/kxxxl.m3u8 ',
				x = 0,
				y = 1280,
				width = 720,
				height = 360,
			}

		end)
		self:addTestButton('video 竖屏', function ( ... )
			-- VideoPlayer:openAndPlay{
			-- 	videoUrl = 'http://10.130.136.61:8000/kxxxl.m3u8 ',
			-- 	x = 0,
			-- 	y = 1280,
			-- 	width = 720,
			-- 	height = 360,
			-- 	portrait = true,
			-- }
		end)
		self:addTestButton('video 强制全屏', function ( ... )
			VideoPlayer:openAndPlay{
				videoUrl = 'http://10.130.136.61:8000/kxxxl.m3u8 ',
				x = 0,
				y = 1280,
				width = 720,
				height = 360,
				forceFullWindow = true,
			}
		end)
	end
	]]

	self:addTestButton("记录此刻抖动",function()
		local ShareLevelSuccessButtonTiltKey = "share_level_success_button_tilt_key"
		CCUserDefault:sharedUserDefault():setBoolForKey(ShareLevelSuccessButtonTiltKey, false)
        CCUserDefault:sharedUserDefault():flush()
		CommonTip:showTip("记录此刻按钮抖动重新开启","positive")
	end,true)
	self:addTestButton("WEKVIDEO", function ()
		require('zoo.webview.WebView'):openUrl('http://10.130.137.13:10086/testTcPlayer.html', false, true)
		-- require('zoo.webview.WebView'):openUrl('http://imgcache.qq.com/open/qcloud/video/vcplayer/demo/tcplayer-consoles.html')
	end)


    self:addTestButton("调试", function ()
        _G.__DebugPanel:initBtns()
        _G.__DebugPanel:setVisible(true)
    end)

    if myLayoutCtrl.enabled then
		local _screenSizeOffset = {0, -200, -400, -600}
		local _screenSizePtr = 1
		local btnVSize
		btnVSize = self:addTestButton("height+" .. tostring(_screenSizePtr-1), function ()
			_screenSizePtr = _screenSizePtr + 1
			if _screenSizePtr > #_screenSizeOffset then
				_screenSizePtr = 1
			end
			btnVSize.label:setString("height+" .. tostring(_screenSizePtr-1))
			CCDirector:sharedDirector():setOffsetHeight(_screenSizeOffset[_screenSizePtr])
		end)
    end

	local btnAdjacent = self:addTestButton("adjacent", function ()
        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
        disp:testLaunchInAdjacent2("http://www.baidu.com")
	end)


	--
--
--
--
--
--
--
--
--
--
--
--
--



	--[[
	self:addTestButton("CR +", function() 
		ResumeGamePlayPopoutAction:testpop(true)
	end)

	self:addTestButton("CR -", function() 
		ResumeGamePlayPopoutAction:testpop(false)
	end)
	]]

	-- self:addTestButton("TestReplay", function() 
	-- 		require "zoo.panel.NotificationGuidePanel"
	-- 		NotificationGuidePanel:create(2):popout()
	-- 	-- ResumeGamePlayPopoutAction:testpop(false)
	-- end)
	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

	

	self:addTestButton("网页交互", function()
		    local param = nil
		    local function faqListener(event)
		    	if not event then return end
		    	if event.name == FAQViewEvents.ON_VIEW_DID_APPEAR then
		    	elseif event.name == FAQViewEvents.ON_VIEW_DID_DISAPPEAR then
		    		self:runAction(CCCallFunc:create(function() CommonTip:showTip("Param:" .. table.tostring(param)) end))
		    	elseif event.name == FAQViewEvents.ON_OPEN_FC_BRIDGE then
					local fData = FAQ:formatFcBridgeData(event.data)
	    			if _G.isLocalDevelopMode then printx(0, ">>>>onOpenFcBridge: fcBridgeListener = ", table.tostring(fData)) end
	    			if fData and fData.name == "third_part" then
	    				param = fData.param
	    				return true
	    			end
		    	elseif event.name == FAQViewEvents.ON_OPEN_TAB then
		    	end
    			return false
		    end
		    FAQ:openCustomPage("http://animalmobile.happyelements.cn/huawei_party.jsp", true, faqListener)
		end)

	self:addTestButton("WebView中专页", function()
		    local param = nil
		    local function faqListener(event)
		    end

		    local meta = MaintenanceManager:getInstance():getMaintenanceByKey("WebViewTestUrl")
		    if meta and meta.extra then
		   		FAQ:openCustomPage(meta.extra, true, faqListener)
		   	end
		end)

	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


	local shareCallback = {
        onSuccess = function(result)
			printx(0, "=======WEIBO-SHARE onSuccess=======")
            CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
        end,
        onError = function(errCode, errMsg)
			printx(0, "=======WEIBO-SHARE onError=======")
            CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
        end,
        onCancel = function()
			printx(0, "=======WEIBO-SHARE onCancel=======")
            CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
        end
    }
    if __IOS then
    	local callBacks = shareCallback
		waxClass{"WeiboShareCallbackDelegate", "NSObject", protocols = {"SimpleCallbackDelegate"}}
        WeiboShareCallbackDelegate.onSuccess = function(self, tab) 
                                              if callBacks.onSuccess ~= nil then callBacks.onSuccess() end
                                            end
        WeiboShareCallbackDelegate.onFailed = function() 
                                              if callBacks.onError ~= nil then callBacks.onError() end
                                          end
        WeiboShareCallbackDelegate.onCancel = function()
                                              if callBacks.onCancel ~= nil then callBacks.onCancel() end
                                          end
    end
	self:addTestButton("微博-图片", function() 
		-- Director:saveScreenshot( path )
		local path = string.format("http://static.manimal.happyelements.cn/level/jt0001%04d.jpg", math.random(1, 1000))
		local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
		SnsUtil.sendImageMessage( 3, "title:周赛闯关2", "Text2:@开心消消乐，闯关集雪花宝石，转盘抽奖好礼多多~#开心消消乐#", thumb, path, shareCallback, false )
	end, true)
	self:addTestButton("微博-文本", function() 
		-- Director:saveScreenshot( path )
		SnsUtil.sendTextMessage( 3, "title:周赛闯关1", "Text1:@开心消消乐，闯关集雪花宝石，转盘抽奖好礼多多~ 链接：http://animalmobile.happyelements.cn/unlock_help_button.html#place", false, shareCallback )
	end, true)
	self:addTestButton("微博-链接", function() 
		local linkUrl = "http://animalmobile.happyelements.cn/unlock_help_button.html"
		local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
		-- Director:saveScreenshot( path )
		SnsUtil.sendLinkMessage( 3, "周赛闯关", "@开心消消乐，闯关集雪花宝石，转盘抽奖好礼多多~", thumb, linkUrl, false, shareCallback)
	end, true)

	self:addTestButton("小程序", function() 
		SnsUtil:launchMiniApp()
	end, true)


    self:addTestButton("小程序绑定", function() 
        local url = "pages/home/index/index?xxlId="..UserManager:getInstance().inviteCode.."&pt=" .. (PlatformConfig:isQQPlatform() and "yyb" or "tcd")   .. "&action=bind"
        RemoteDebug:uploadLogWithTag('appurl()',url)

        SnsUtil:launchMiniProgram(url,nil,2)
    end, true)

    self:addTestButton("测试计费点", function()
			local panelDelegate = (require "zoo.debug.CommonGridPanelDelegate").new()
			if __ANDROID then
				panelDelegate:setDatas({189,190,191,192,193})
			else
				panelDelegate:setDatas({})
			end
			panelDelegate:setColumn(2)
			panelDelegate:setItemOnCreateHandler(function(item, index, data)
					local goodsId = tonumber(data)
					local meta = nil
					if __ANDROID then meta = MetaManager:getInstance():getProductAndroidMeta(goodsId) else
						meta = MetaManager:getInstance():getProductMetaByID(goodsId) end
					if meta then
						local price = meta.rmb and tonumber(meta.rmb) / 100 or meta.price
						item:setString("goodsId-"..tostring(goodsId).." Price: "..tostring(price))
					else
						item:setString("goodsId-"..tostring(goodsId).." Not found")
					end
				end)
			panelDelegate:setItemOnTappedHandler(function(item, index, data)
					local goodsId = tonumber(data)
					local meta = nil
					if __ANDROID then meta = MetaManager:getInstance():getProductAndroidMeta(goodsId) else
						meta = MetaManager:getInstance():getProductMetaByID(goodsId) end
					if not meta then
						return
					end
					local function onSuccess() CommonTip:showTip("Buy onSuccess") end
					local function onFail() CommonTip:showTip("Buy onFail") end
					local function onCancel() CommonTip:showTip("Buy onCancel") end
					local buyLogic = BuyGoldLogic:create()
					buyLogic:getMeta()
					buyLogic:buy(goodsId, nil, onSuccess, onFail, onCancel)
				end)
			local panel = panelDelegate:createPanel(680, 400)
			panel:setPositionX(20+visibleOrigin.x)
			panel:setPositionY((visibleSize.height-400)/2+visibleOrigin.y + 400)
			Director:sharedDirector():run():addChild(panel, "popoutLayer")
		end, true)

	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

	if __ANDROID then
		--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

		self:addTestButton('start net rcver', function ( ... )
			
			CommonTip:showTip('start net rcver')
			NetworkUtil:registerNetworkChangeBroadcastReceiver()

		end)

		self:addTestButton('stop net rcver', function ( ... )
			CommonTip:showTip('stop net rcver')
			
			NetworkUtil:unregisterNetworkChangeBroadcastReceiver()
		end)

		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local context = MainActivityHolder.ACTIVITY:getContext()
		local NotificationUtils = luajava.bindClass("com.happyelements.android.utils.NotificationsUtils")
		local label = '通知-开'
		if not NotificationUtils:isNotificationEnabled(context) then
			label = '通知-关'
		end
		self:addTestButton(label, function ( ... )
			NotificationUtils:openNotificationSetting()
		end)

		self:addTestButton("init unipay", function()
		        local function initSDK()
		            local unicom = luajava.bindClass("com.happyelements.android.operatorpayment.uni.UniPayment")
		            unicom:initSDK()
		        end
		        pcall(initSDK)
			end)

		-- GlobalEventDispatcher:getInstance():addEventListener(NetworkUtil.Events.kNetworkStatusChange, function ( ... )
		-- 	CommonTip:showTip(NetworkUtil:getNetworkStatus())
		-- end)

	elseif __IOS then
		self:addTestButton("商店页面", function()
			waxClass{"OnProductViewCloseCallback",NSObject,protocols={"WaxCallbackDelegate"}}
	 		function OnProductViewCloseCallback:onResult(ret) 
	 			CommonTip:showTip("已关闭")
	 		end
			AppController:openProductView_onFinish(1115609641, OnProductViewCloseCallback:init())
			end, true)
		self:addTestButton('inapp评分', function ( ... )
			AppController:tryRequestReview()
		end, true)
		--
--
--
--
--
--
--
--
--
--
--
--

	elseif __WIN32 then
	end

	self:addTestButton("前置道具合并", function() 
		require 'zoo.panel.ExchangePrePropPanel'
		ExchangePrePropPanel:create(true):popout()
	end)

	_G.testRealNameSwitch = false
	self:addTestButton("打开实名", function(btn) 
		_G.testRealNameSwitch = not _G.testRealNameSwitch
		if _G.testRealNameSwitch then 
			btn.label:setString("关闭实名")
		else
			btn.label:setString("打开实名")
		end
	end, true)

	local function removeFiles(path, isDir)
		if HeFileUtils:exists(path) then 
			if isDir then 
				return HeFileUtils:removeDir(path)
			else
				return HeFileUtils:removeFile(path)
			end
		end
		return true
	end

	self:addTestButton("清数据", function() 
		local pathRes = HeResPathUtils:getResCachePath()
		local pathTmpData = HeResPathUtils:getTmpDataPath()
		local pathUserData = HeResPathUtils:getUserDataPath()
		local pathUserDefault = CCUserDefault:sharedUserDefault():getXMLFilePath()
		local pathActRes = pathRes.."/resource/activity"
		local pathActSrc = pathRes.."/src/activity"
		if removeFiles(pathTmpData, true) then 
			if _G.isLocalDevelopMode then printx(0, "zhijian===pathTmpData=======remove success") end
		end
		if removeFiles(pathUserData, true) then 
			if _G.isLocalDevelopMode then printx(0, "zhijian===pathUserData=======remove success") end
		end
		if removeFiles(pathUserDefault) then 
			if _G.isLocalDevelopMode then printx(0, "zhijian===pathUserDefault=======remove success") end
		end
		if removeFiles(pathActRes, true) then 
			if _G.isLocalDevelopMode then printx(0, "zhijian===pathActRes=======remove success") end
		end
		if removeFiles(pathActSrc, true) then 
			if _G.isLocalDevelopMode then printx(0, "zhijian===pathActSrc=======remove success") end
		end

		Director.sharedDirector():exitGame()
	end, true)


	self:addTestButton("触发引导",   
		function () 
			_G.__testPropGuide = not _G.__testPropGuide
			CommonTip:showTip(tostring(_G.__testPropGuide))

			-- LocalNotificationManager:getInstance():addNotifyFromConfig(38, os.time() + 10)
			-- LocalNotificationManager:getInstance():addNotifyFromConfig(39, os.time() + 11)
			-- LocalNotificationManager:getInstance():addNotifyFromConfig(40, os.time() + 12)
			-- LocalNotificationManager:getInstance():addNotifyFromConfig(41, os.time() + 13)
			-- LocalNotificationManager:getInstance():addNotifyFromConfig(1, os.time() + 14)
		end)

	self:addTestButton("位置信息", function()
		if _G.geoLocationData then
			OutGameTipPanel:create("位置信息", _G.geoLocationData):popout()
		else
			OutGameTipPanel:create("位置信息", "无位置信息"):popout()
		end
		end)

	self:addTestButton("成就广播", function ()
		require "zoo.PersonalCenter.achi.AchiUnitTest"
		AchiUnitTest:showTest()
	end)

	self:addTestButton("引导关", function()
			local GameGuideDebug = require "zoo.debug.GameGuideDebug"
			local height = 790
			local ui = GameGuideDebug:buildDebugUI(visibleSize.width - 100, height)
			ui:setPositionX(50+visibleOrigin.x)
			ui:setPositionY((visibleSize.height-height)/2+visibleOrigin.y + height)
			Director:sharedDirector():run():addChild(ui, "popoutLayer")
		end, true)

	self:addTestButton("星星储蓄罐", function ( ... )
		Notify:dispatch("StarBankUnitTestEventInit")
	end)
	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

	self:addTestButton('PhotoPicker 测试', function ( ... )
		local PhotoPicker = require 'zoo.photoPicker.TestPhotoPanel'
		PhotoPicker:create():popout()
	end)

	-- self:addTestButton("加头像框", function() 
			
	-- 	HeadFrameType:setProfileContext(nil):addHeadFrame(6002, 60 * 1000)
	-- 	HeadFrameType:setProfileContext(nil):addHeadFrame(6003, 60 * 1000)
	-- 	HeadFrameType:setProfileContext(nil):addHeadFrame(14, 60 * 1000)
	-- 	HeadFrameType:setProfileContext(nil):addHeadFrame(6004, 60 * 1000)

	-- end)

	self:addTestButton('下一关', function ( ... )
		if AutoPopout:isInNextLevelMode() then
			CommonTip:showTip( "下一关模式开启中" )
		else
			CommonTip:showTip( "下一关模式关闭中" )
		end
	end)
	self:addTestButton('素材回收', function ( ... )
		_G.force_free_texture = not (_G.force_free_texture)
		CommonTip:showTip('素材回收开关' .. tostring(_G.force_free_texture))
	end)
	
	self:addTestButton("应用设置", function ()
		PermissionManager.getInstance():gotoSetting()
	end)

	local idLeft = 1
	self:addTestButton("左侧加按钮"..idLeft, function ()
		if idLeft > 4 then
			CommonTip:showTip('左侧最多加4个~')
		else 
			self:addIcon(_G["IconTestBtnL"..idLeft]:create())
			idLeft = idLeft + 1
		end
	end)

	self:addTestButton("GiftPack", function ()
		GiftPack:onAddFivePanelShow({})
	end)
	
	local idRight = 1
	self:addTestButton("右侧加按钮"..idLeft, function ()
		if idRight > 4 then
			CommonTip:showTip('右侧最多加4个~')
		else 
			self:addIcon(_G["IconTestBtnR"..idRight]:create())
			idRight = idRight + 1
		end
	end)

	if self.testButtonCtrl then self.testButtonCtrl.onTapped() end
end

function HomeScene:_createTestButton(text, color, fntSize, width, height)
	color = color or ccc3(64,64,64)
	width = width or 150
	height = height or 56
	local btn = LayerColor:createWithColor(color, width, height)
	btn:setTouchEnabled(true, 0, true)
	btn:setOpacity(255 * 0.75)
	btn:addEventListener(DisplayEvents.kTouchBegin, function(evt)
		local action = CCSequence:createWithTwoActions(CCTintTo:create(0.1, 0, 255, 0), CCTintTo:create(0.2, 64, 64, 64))
		action.tag = 11114
		btn:stopActionByTag(11114)
		btn:runAction(action)
	end)

	fntSize = fntSize or 30
	local label = TextField:create(tostring(text), nil, fntSize)
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2)
	label:setPositionY(height/2)
	btn.label = label
	btn:addChild(label)
	local labelSize = label:getContentSize()
	label:setScale(math.min(width / labelSize.width, height / labelSize.height))

	return btn
end

function HomeScene:createSpringLevelTestBtn()
	local shareIds = {
		HE           = "wx3d4b852d7e5018fa",
	    QIHOO        = "wx6d33d3d262884c38",
	    HUAWEI       = "wxc154c1123c18e9ec",
	    DK           = "wx073d775c654c49b0",
	    VIVO		 = "wxdd4edd4ad4efe77e",
	    EGAME        = "wx8ec3f2ef04969f53",
	    MIPAD        = "wxc4e8e6418c3b803b",
	    YINGYONGBAO  = "wxcf778d4889020005",
	    WANDOUJIA    = "wx3b22eb0f9c0b66a9",
	    JINLI_PRE    = "wx19b3f3a699f4d551",
	}
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local function createBtn(color, width, height, text, fntSize)
		return self:_createTestButton(text, color, fntSize, width, height)
	end

	local levelIds = {}
	for lvId = 280100, 280199 do
		if LevelMapManager.getInstance():getMeta(lvId) then
			table.insert(levelIds, lvId)
		end
	end

	local context = self
	local function onPassActivityLevel(evt)
		if evt and evt.data and evt.data.levelType == GameLevelType.kSpring2017 then
			Director:sharedDirector():popScene()
			local num = evt.data.targetCount
			local function showResult()
				CommonTip:showTip("本次收集数量："..tostring(num), "positive", nil, 3)
			end
			context:runAction(CCCallFunc:create(showResult))
		end
		GamePlayEvents.removePassLevelEvent(onPassActivityLevel)
	end
	local function onFailLevel(evt)
		GamePlayEvents.removeFailLevelEvent(onFailLevel)
		Director:sharedDirector():popScene()
	end

	local function startLevel(levelId)
		local scene = Director:sharedDirector():getRunningScene()
		local loadingAnim = CountDownAnimation:createNetworkAnimation(scene)
		local function onTimeout()
			loadingAnim:removeFromParentAndCleanup(true)
		end
		setTimeOut(onTimeout, 2)
		local startLevelLogic = StartLevelLogic:create(self, levelId, GameLevelType.kSpring2017, {}, true)
		startLevelLogic:start(true)
		
		GamePlayEvents.removePassLevelEvent(onPassActivityLevel)
		GamePlayEvents.addPassLevelEvent(onPassActivityLevel)

		GamePlayEvents.removeFailLevelEvent(onFailLevel)
		GamePlayEvents.addFailLevelEvent(onFailLevel)
	end

	local function changeShareId(pf, shareId)
		if _G.isLocalDevelopMode then printx(0, "changeShareId", pf, shareId) end
		if __ANDROID then
			local function safeChange()
				local weChatUtil = luajava.bindClass("com.happyelements.hellolua.share.WeChatUtil").INSTANCE
				weChatUtil:reInitWeChat(shareId)
			end
			local success, ret = pcall(safeChange)
			if success then
				CommonTip:showTip("切换分享ID："..tostring(pf)..":"..tostring(shareId))
			end
		end
		if levelList then
			levelList:removeFromParentAndCleanup(true)
			levelList = nil
		end
	end

	local function onLevelBtnTapped()

		Notify:dispatch("QuitNextLevelModeEvent")

		if levelList then
			levelList:removeFromParentAndCleanup(true)
			levelList = nil
		else
			levelList = LayerColor:createWithColor(ccc3(0, 255, 200), 160, 10)
			levelList:setPosition(ccp(visibleOrigin.x + 20 + 135, visibleOrigin.y + 200))
			self:addChild(levelList)

			local totalHeight = 5
			local itemHeight = 60
			for pf, shareId in pairs(shareIds) do
				local btn = createBtn(ccc3(0, 0, 255), 150, itemHeight, tostring(pf), 26)
				btn:setPosition(ccp(5, totalHeight))
				totalHeight = totalHeight + itemHeight + 5
				btn:addEventListener(DisplayEvents.kTouchTap, function() changeShareId(pf, shareId) end)

				levelList:addChild(btn)
			end
			levelList:changeHeight(totalHeight)
		end
	end

	-- 春节关卡测试按钮

	local startLevelBtn = createBtn(ccc3(255, 0, 0), 160, 80, "切换分享ID", 30)
	startLevelBtn:addEventListener(DisplayEvents.kTouchTap, onLevelBtnTapped)
	startLevelBtn:setPosition(ccp(visibleOrigin.x + 20, visibleOrigin.y + 250))
	self:addChild(startLevelBtn)
end

function HomeScene:canDcUserInfo()
	if PrepackageUtil:isPreNoNetWork() then
		return false
	end
	local lastDcTime = CCUserDefault:sharedUserDefault():getStringForKey("custom.userinfo.dc.time")
	if lastDcTime == "" then lastDcTime = 0 end
	local lastStartTime = math.floor(tonumber(lastDcTime) / 3600 / 24)

	local curTimeInSec = Localhost:timeInSec()
	local nowStartTime = math.floor(curTimeInSec / 3600 / 24)

	if lastStartTime ~= nowStartTime then
		CCUserDefault:sharedUserDefault():setStringForKey("custom.userinfo.dc.time", tostring(curTimeInSec))
		return true
	end
	return false
end

function HomeScene:getUserLocationByIPIfNeed()
	if PrepackageUtil:isPreNoNetWork() or UserManager:getInstance():getUserLocation() then
		return
	end
	local callbackHanler = function(locationDetail)
        if type(locationDetail) == "table" then
            UserManager:getInstance():updateUserLocation(locationDetail, "ip")
        end
    end
    LocationManager_All.getInstance():getIPLocation(callbackHanler)
end

function HomeScene:dcUserInfo()
	if not self:canDcUserInfo() then return end
	local pcManager = PersonalCenterManager
	local snsInfo = UserManager.getInstance().profile:getSnsInfo(PlatformAuthEnum.kPhone)
	local keyt
	if snsInfo then
		keyt = snsInfo.snsName
	end
	local defaultPaymentType
	if __ANDROID then 
		defaultPaymentType = PaymentManager.getInstance():getDefaultPayment()
	end

	local isBackgroundMusicOpen = GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen
	local isMusicOpen = GamePlayMusicPlayer:getInstance().IsMusicOpen
	local isMessageOpen = CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification")

	local userData = {
		name = HeDisplayUtil:urlEncode(pcManager:getData(pcManager.NAME)),
		sex = pcManager:getData(pcManager.SEX),
		age = pcManager:getData(pcManager.AGE),
		star_sign = pcManager:getData(pcManager.CONSTELLATION),
		friend_num = FriendManager.getInstance():getFriendCount(),
		keyt = keyt or "",
		default_type = defaultPaymentType,
		music1 = isBackgroundMusicOpen and "1" or "0",
		music2 = isMusicOpen and "1" or "0",
		message = isMessageOpen and "1" or "0",
		birthdate = pcManager:getData(pcManager.BIRTHDATE),
		address = pcManager:getData(pcManager.ADDRESS),
	}
	local callbackHanler = function(locationDetail)
        if type(locationDetail) == "table" then
            userData["country"] = tostring(locationDetail.country)
            userData["province"] = tostring(locationDetail.province)
            userData["city"] = tostring(locationDetail.city)
            userData["district"] = tostring(locationDetail.district)
            userData["isp"] = tostring(locationDetail.isp)

            UserManager:getInstance():updateUserLocation(locationDetail, "ip")
        end
        DcUtil:userInfo( userData )
    end
    LocationManager_All.getInstance():getIPLocation(callbackHanler)

    local isQQLogin = SnsProxy:getAuthorizeType() == PlatformAuthEnum.kQQ
    local friend = {}
    if isQQLogin then
    	local snsFriendIds = FriendManager.getInstance().snsFriendIds
    	for uid,fid in pairs(snsFriendIds) do
    		local f = FriendManager.getInstance():getFriendInfo(uid)
    		if f then
    			friend[tostring(uid)] = true
    		end
    	end
	end

	local friend_txt = ""

	for uid,_ in pairs(friend) do
		if friend_txt == "" then
			friend_txt = uid
		else
			friend_txt = friend_txt.."_"..uid
		end
	end

	local friend_xxl = ""

	local friends = FriendManager.getInstance().friends
	for uid,fid in pairs(friends) do
		local u = tostring(uid)
		if friend[tostring(u)] ~= true then
			if friend_xxl == "" then
				friend_xxl = u
			else
				friend_xxl = friend_xxl.."_"..u
			end
		end
	end

	local qqUserFriData = {
    	friend_num = FriendManager.getInstance():getFriendCount(),
    	friend = friend_txt,
    	friend_xxl = friend_xxl,
	}
	DcUtil:qqUserFri( qqUserFriData )
end

function HomeScene:shutdownJiFenEntry( ... )
	local AndroidSalesMgrProxy = HappyCoinShopFactory:getInstance():getAndroidSalesManager()

	if AndroidSalesMgrProxy.getInstance():isInGoldSalesPromotion() then
		AndroidSalesMgrProxy.getInstance():showGoldButtonFlag() 
	end
	if self.goldButtonFree1 and self.goldButtonFree2 then
		self.goldButtonFree1:setVisible(false)
		self.goldButtonFree2:setVisible(false)
	end
end

function HomeScene:showJiFenEntry( ... )
	if HappyCoinShopFactory:getInstance():shouldUseNewfeatures() then
		require 'zoo.panel.happyCoinShop.PromotionFactory'
		if PromotionManager:getInstance():isInPromotion() then
			self:shutdownJiFenEntry()
			return
		end
	end

	local AndroidSalesMgrProxy = HappyCoinShopFactory:getInstance():getAndroidSalesManager()

	if AndroidSalesMgrProxy.getInstance():isInGoldSalesPromotion() then
		AndroidSalesMgrProxy.getInstance():removeGoldButtonFlag() 
	end
	if self.goldButtonFree1 and self.goldButtonFree2 then
		self.goldButtonFree1:setVisible(true)
		self.goldButtonFree2:setVisible(true)
	end
end

function HomeScene:buildJiFenEntry( ... )
	if self.goldButtonFree1 and self.goldButtonFree2 then return end
	if SupperAppManager:checkEntry() == false then return end

	--init 积分墙sdk
	local function callback( ... )
		SpriteUtil:addSpriteFramesWithFile("flash/supperapp_banner.plist", "flash/supperapp_banner.png")
		local free = Sprite:createWithSpriteFrameName("supperapp_free_icon instance 10000")
		free:setPositionX(80)
		self.goldButton:addChild(free)

		self.goldButtonFree1 = free

		local free = Sprite:createWithSpriteFrameName("supperapp_free_icon instance 10000")
		free:setPositionX(30)
		free:setPositionY(40)
		self.marketButton:addChild(free)

		self.goldButtonFree2 = free

		self:showJiFenEntry()
	end
	
	SupperAppManager:initSDK(callback)
end

function HomeScene:checkJiFenView( ... )
	local enbaleEntry = SupperAppManager:checkEntry()
	if enbaleEntry == true then
		DcUtil:UserTrack({ category='activity', sub_category='push_1_1'})
	end
	if self.hadEntryGoldPanel == true then return 1, enbaleEntry end

	if enbaleEntry== true then 
		self.hadEntryGoldPanel = true
		return MarketManager:sharedInstance():getHappyCoinPageIndex(), false
	end
	return 1, enbaleEntry
end

function HomeScene:createButtonGroupBar()
	local btnBarEvt = ButtonsBarEventDispatcher.new()
	btnBarEvt:addEventListener(ButtonsBarEvents.kClose, function ()
		self.hideAndShowBtn:setVisible(true)
		self.buttonGroupBar:setVisible(false)
		-- self.buttonGroupBar = nil
	end)
	self.buttonGroupBar = HomeSceneButtonsBar:create(btnBarEvt)
	self.iconLayer:addChild(self.buttonGroupBar)

	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local _x = visibleOrigin.x + visibleSize.width * self.iconLayerScale  - 70
	local _y = visibleOrigin.y + 70

	self.buttonGroupBar:setPosition(ccp(_x, _y))
	self.buttonGroupBar:setVisible(false)
end

function HomeScene:updateFriendButton()
	local _ = self.friendButton and self.friendButton:update()
	local _ = self.buttonGroupBar and self.buttonGroupBar.friendButton and self.buttonGroupBar.friendButton:update()
    self.hideAndShowBtn:updateRedDot()
end

function HomeScene:showButtonGroup(endCallback)
	if self.buttonGroupBar:isForceDisabled() then
		return
	end
	self.hideAndShowBtn:removeTip()
	self.hideAndShowBtn:setVisible(false)
	self.buttonGroupBar:setVisible(true)
	self.buttonGroupBar:popout(endCallback)
end


local replaceTextureMemory = -1 -- -1: innactive, 0: active

function HomeScene:showSettingButton(endCallback, isClick)
	DcUtil:iconClick("click_left_bill_icon")
	self.settingButton:setVisible(false)
	local btnBarEvt = HomeSceneSettingButtonEventDispatcher.new()
	btnBarEvt:addEventListener(HomeSceneSettingButtonEvents.kClose, function ()
		self.settingButton:setVisible(true)
		self.settingButtonUI = nil
	end)
	local position = ccp(self.settingButton:getPositionX(), self.settingButton:getPositionY())
	self.settingButtonUI = HomeSceneSettingButton:create(btnBarEvt)
	-- self.settingButtonUI:popout(endCallback, position, isClick)
    self.settingButtonUI:setPosition(position)
    self.settingButtonUI:showButtons(endCallback, isClick)
	self.iconLayer:addChild(self.settingButtonUI)

	if(replaceTextureMemory == 0) then
		replaceTextureMemory = 1
		HomeScene_freeUnuseInGameTextureMinSize(512*512)
	elseif(replaceTextureMemory == 1) then
		replaceTextureMemory = 0
		HomeScene_restoreUnuseInGameTexture(true)
	end

--[[
	if _G.isLocalDevelopMode then
		local panel = UpdatePageagePanel:create(ccp(0,0))
		if panel then panel:popout() end
	end
	]]

	--require("hecore/profiler"):save()
	--require("hecore/profiler"):clearMap()
	if(false and isLocalDevelopMode) then
		PreloadingSceneUI:buildDebugButton( Director:sharedDirector():getRunningScene() )
	end
	if(false and isLocalDevelopMode) then
		local test = require("zoo/testGaf")
		local testLayer = Layer:create()
		Scene.addChild(self, testLayer)
		test:addObjectsToScene(testLayer)
	end

	if(false) then
		local openUrl = function()
		    print('-----------------------------------------------')
		    print("openYYBv_activity_page, http://qzs.qq.com/open/yyb/vplayer_gift/index.html")
		    print('-----------------------------------------------')

		    local WebViewLogic = luajava.bindClass("com.happyelements.android.webview.WebViewLogic")
	        WebViewLogic:open("http://qzs.qq.com/open/yyb/vplayer_gift/index.html", true)
		end

		pcall(openUrl)
	end

--[[
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
--	local size = CCDirector:sharedDirector():getWinSize()
	local renderTexture = CCRenderTexture:create(visibleSize.width, visibleSize.height, kCCTexture2DPixelFormat_RGBA8888, GL_DEPTH24_STENCIL8)
	renderTexture:beginWithClear(0, 0, 0, 0)
--	renderTexture:setVisible(false)
--	renderTexture:retain()
	renderTexture:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))
--	renderTexture:begin()
--	CCDirector:sharedDirector():getRunningScene():visit()
	self.worldScene:visit()
	renderTexture:endToLua()

	if(true)then
		local filePath = HeResPathUtils:getUserDataPath() .. "/_screenShot.png"
		renderTexture:saveToFile(filePath)

		return
end
]]

end

function HomeScene:onSyncFinished()
	local function updateHomeScene()
		self:checkDataChange()

		self:updateHomeSceneButtonsWhileSyncFinish()
		self:tryToShowFunsClub()
	end
	setTimeOut(updateHomeScene, 2/60)
end

function HomeScene:tryRemoveSummerWeeklyButton( ... )
	local userTopLevel = UserManager:getInstance():getUserRef():getTopLevelId()
	if ((not SeasonWeeklyRaceManager:getInstance():isLevelReached(userTopLevel)) or RankRaceMgr:getInstance():isEnabled()) and self.summerWeeklyButton then
		self:removeIcon(self.summerWeeklyButton, true)
		self.summerWeeklyButton = nil
	end
end

function HomeScene:updateHomeSceneButtonsWhileSyncFinish()
	local userTopLevel = UserManager:getInstance():getUserRef():getTopLevelId()

	self:tryRemoveSummerWeeklyButton()

	if not RankRaceMgr:getInstance():isLevelReached() and self.rankRaceButton then
		self:removeIcon(self.rankRaceButton, true)
		self.rankRaceButton = nil
	end

	if UserManager.getInstance().user:getTopLevelId() < MissionLogic:getMissionUserNeedLevel() and self.missionBtn then
		self:removeIcon(self.missionBtn, true)
		self.missionBtn = nil
	end

	if userTopLevel < 16 then
		if self.fruitTreeBtn or self.hiddenFruitTreeBtn then
			self:removeIconByIndexKey(BtnShowHideConf[ManagedIconBtns.FRUIT].indexKey, true)
			self.fruitTreeBtn = nil
			self.hiddenFruitTreeBtn = nil
		end

		local function showFruitTreeButton(evt, noTutor)
			local user = UserManager:getInstance():getUserRef()
			if user and user:getTopLevelId() >= 16 then
				self:removeEventListener(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, showFruitTreeButton)
				if HomeSceneButtonsManager.getInstance():shouldShowFruitBtnOnHomeScene() then
					self:buildHomeSceneFruitBtn()
				else
					self:buildHiddenFruitBtn()
				end
			end
		end
		self:addEventListener(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, showFruitTreeButton)
	end

	if userTopLevel < 13 then
		if self.markButton or self.hiddenMarkBtn then
			self:removeIconByIndexKey(BtnShowHideConf[ManagedIconBtns.MARK].indexKey, true)
			self.markButton = nil
			self.hiddenMarkBtn = nil
		end
	end

	if __IOS then
		local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
		if not IosPayGuideProxy:isInOneYuanShopPromotion() and self.oneYuanShopButton then
			self:removeIcon(self.oneYuanShopButton)
	        self.oneYuanShopButton = nil
		end
	end

	if not NewVersionUtil:hasNewVersion() and self.updateVersionButton then
		-- self.updateVersionButton:removeFromParentAndCleanup(true)
		HomeScene:sharedInstance().rightBottomRegionLayoutBar:removeItem(self.updateVersionButton)
		self.updateVersionButton = nil
	end

	self:buildActivityButton()
end

function HomeScene:onUserLogin()
	local function showFunsClub()
		self:tryToShowFunsClub()
	end
	setTimeOut(showFunsClub, 2/60)
end

function HomeScene:tryToShowFunsClub()
	if LoginExceptionManager:getInstance():getShouldShowFunsClub() then 
		LoginExceptionManager:getInstance():setShouldShowFunsClub(false)
		LoginExceptionManager:getInstance():showFunsClub()
	end
end

function HomeScene:popoutLadyBugPanel(showTip, panelCloseCallback , startPos)
	local ladyBugBtnPosInWorldSpace = nil
	if self.ladybugButton then
		if self.ladybugButton:getParent() then
			local ladyBugBtnPos 			= self.ladybugButton:getPosition()
			local ladyBugBtnParent			= self.ladybugButton:getParent()
			ladyBugBtnPosInWorldSpace		= ladyBugBtnParent:convertToWorldSpace(ccp(ladyBugBtnPos.x, ladyBugBtnPos.y))
		else
			ladyBugBtnPosInWorldSpace = self.hideAndShowBtn:getPositionInWorldSpace()
		end
	else
		ladyBugBtnPosInWorldSpace		= startPos
	end

	if not ladyBugBtnPosInWorldSpace then 
		ladyBugBtnPosInWorldSpace = startPos or ccp(0,0)
	end
	
	local ladyBugPanel = LadyBugPanel:create(ladyBugBtnPosInWorldSpace)
	ladyBugPanel:popout(showTip, panelCloseCallback)

	return ladyBugPanel
end

function HomeScene:removeLadyBugButton()
	if self.ladybugButton then
		self:removeIcon(self.ladybugButton)
		self.ladybugButton = nil
	end
end

----------------------------------------------------------------------
----	Observer Design Pattern
----	Check Interest Data Change
--------------------------------------------------------------

function HomeScene:registerInterestData(...)
	assert(#{...} == 0)

	self.oldUsrCoin			= UserManager.getInstance().user:getCoin()
	self.oldUsrCash			= UserManager.getInstance().user:getCash()
	self.oldTotalStarNumber		= UserManager.getInstance().user:getStar() + UserManager.getInstance().user:getHideStar()
	self.oldEnergy 			= UserManager.getInstance().user:getEnergy()
end 

function HomeScene:onLevelPassed(passedLevel, ...)
	assert(type(passedLevel) == "number")
	assert(#{...} == 0)

	local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'

	if (not PrepackageUtil:isPreNoNetWork()) and LadybugABTestManager:isOld() then
    	LadyBugMissionManager:sharedInstance():onLevelPassedCallback(passedLevel) 
	end

	if LadybugABTestManager:isNew() then
		local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
		LadybugDataManager:getInstance():onPassMainLevel()
	end
end

function HomeScene:onTopLevelChange()
	-- self.oldTopLevelId = UserManager.getInstance().user:getTopLevelId()
	-- if _G.isLocalDevelopMode then printx(0, "#######################HomeScene:onTopLevelChange") end

	local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'


	if not PrepackageUtil:isPreNoNetWork() then
		-- 上传最高关卡
		local newTopLevelId = UserManager.getInstance().user:getTopLevelId()
		LeaderBoardSubmitUtil.submitPassedLevel(newTopLevelId)
		

		if LadybugABTestManager:isOld() then
	    	LadyBugMissionManager:sharedInstance():onTopLevelChange() 
	    end

		if self.rankRaceButton == nil and RankRaceMgr:getInstance():isLevelReached() then
			self:createRankRaceButton()
		end

		MissionPanelLogic:tryToUpdateMissionButton()
		--self:createMissionButton()
		--MissionPanelLogic:checkManga()
		
	end

	if LadybugABTestManager:isNew() then
		local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
		LadybugDataManager:getInstance():onTopLevelChanged()
	end
end

function HomeScene:checkUserCoinChange(...)
	assert(#{...} == 0)

	-- if _G.isLocalDevelopMode then printx(0, "HomeScene:checkUserCoinChange Called !") end
	-- Check Coin
	local newUsrCoin = UserManager.getInstance().user:getCoin()
	if self.oldUsrCoin ~= newUsrCoin then
		self.oldUsrCoin = newUsrCoin
		self:dispatchEvent(Event.new(HomeSceneEvents.USERMANAGER_COIN_CHANGE))
	end
end

function HomeScene:checkUserCashChange(...)
	assert(#{...} == 0)

	-- Check Coin
	local newUsrCash = UserManager.getInstance().user:getCash()
	if self.oldUsrCash ~= newUsrCash then
		self.oldUsrCash = newUsrCash
		self:dispatchEvent(Event.new(HomeSceneEvents.USERMANAGER_CASH_CHANGE))
	end
end

function HomeScene:checkTotalStarNumberChange(...)
	assert(#{...} == 0)

	-- if _G.isLocalDevelopMode then printx(0, "HomeScene:checkTotalStarNumberChange Called !") end
	-- Check Total Star
	local newTotalStarNumber = UserManager.getInstance().user:getStar() + UserManager.getInstance().user:getHideStar()

	if self.oldTotalStarNumber ~= newTotalStarNumber then
		self.oldTotalStarNumber = newTotalStarNumber
		self:dispatchEvent(Event.new(HomeSceneEvents.USERMANAGER_TOTAL_STAR_NUMBER_CHANGE))
		-- 上传玩家最大星星数
		LeaderBoardSubmitUtil.submitTotalStars(newTotalStarNumber)
	end
end

function HomeScene:checkDataChange(...)
	assert(#{...} == 0)

	-- Implement The Observer Design Pattern, To Update View When Data Change
	-- But Not The Data Model To Dispatch Event To Update THe View.
	-- The View Checks The Data Change , When Needed.
	--
	-- Things Concerned When Design:
	-- Based On Others Already Design Of Data Model ( Not Dispatch Any Event, When Data Change)
	-- So In This Function, We Check Variable Change That We Are Interested In, And Dispatch Event To
	-- Notify View To Update Their Display.
	---------------------------------------------------------------------
	-- self:checkTopLevelIdChange()
	self:checkUserCoinChange()
	self:checkUserCashChange()
	-- self:checkLevelAreaOpenedIdChange()
	self:checkTotalStarNumberChange()

	self:checkUserEnergyDataChange()
	self:updateButtons()
end

function HomeScene:checkUserEnergyDataChange(...)
	assert(#{...} == 0)

	local newEnergy = UserManager.getInstance().user:getEnergy()

	if self.oldEnergy ~= newEnergy then
		self.oldEnergy = newEnergy

		local event = Event.new(HomeSceneEvents.USERMANAGER_ENERGY_CHANGE)
		self:dispatchEvent(event)
	end
end

local sharedInstance = false
function HomeScene:sharedInstance()
	if not sharedInstance then
		sharedInstance = HomeScene.new()
		sharedInstance:initScene()
	end

	return sharedInstance
end

function HomeScene:hasInited()
	return sharedInstance
end

function HomeScene:create()
	GameLauncherContext:getInstance():onCreateHomeScene()
	return self:sharedInstance()
end

function HomeScene:updateUserLocation()
	-- 发送玩家位置给后端
	if _G.kUserLogin and _G.kUserLocationUpdateData and not _G.kUserLocationUpdateData.hasUpload then
		local data = _G.kUserLocationUpdateData.location
		if not table.isEmpty(data) then
			-- 更新用户位置数据
			UserManager.getInstance():updateUserLocation(data, "gps")

			_G.kUserLocationUpdateData.hasUpload = true
			local function onUpdateFailed()
				_G.kUserLocationUpdateData.hasUpload = false
			end
			local param = table.serialize(data)
			local http = OpNotifyHttp.new()
			http:addEventListener(Events.kError, onUpdateFailed)
			http:load(OpNotifyType.kUpdateLocation, param)
			if _G.isLocalDevelopMode then
				RemoteDebug:uploadLogWithTag("geo_location", param)
			end
		end
	end
end

local bootSourceCheck = false

-- local enterAnimationPlayed = false
function HomeScene:onEnterHandler(event, ...)
	if _G.isLocalDevelopMode then printx(0, 'thisdebug onEnterHandler ' .. event) end
	assert(event)
	assert(#{...} == 0)

	if event == "enter" then
		if CCSprite.setNotDrawSpriteOutSight then
			CCSprite:setNotDrawSpriteOutSight(true)
		end

		if not self.isInited then
			PreBuffLogic:init()
			CountdownPartyManager.getInstance()
			RankRaceMgr:getInstance():writeLowLevelTag()
			AreaTaskMgr:createInstance()
		else
			
			if WXJPPackageUtil.getInstance():isWXJPPackage() then 
				WXJPPackageUtil.getInstance():showMarketFloatView()
			end
		end

		-- IOS 评价
		IOSScoreGuideFacade:getInstance():returnFromGamePlay()

		--尝试自动打开客服
		self:tryToShowFunsClub()

		if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
			if not WorldSceneShowManager:getHasPlaySpringMusic() then 
				WorldSceneShowManager:setHasPlaySpringMusic(true)
			else
				GamePlayMusicPlayer:getInstance():playWorldSceneBgMusic()
			end
		else
			GamePlayMusicPlayer:getInstance():playWorldSceneBgMusic()
		end

		self:updateUserLocation()
		self:getUserLocationByIPIfNeed()

		if __ANDROID then
			local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME)
			if payment and payment:isEnabled(true) then
				payment:setBeLimited(PaymentManager:isCMGameOfflinePayLimited())
			end

			self:completeFishbowlPromotion()
		end
		
		if not self.isInited then
			require 'zoo.localActivity.Double112018.DoubleOneOneModel'
			Notify:dispatch('ActInfoChange')
			Notify:dispatch("GiftPackInitEvent")

			AutoPopout:doMaintenanceSetting()
			

			GlobalEventDispatcher:getInstance():addEventListener("global.userlocation.update", self.updateUserLocation)
			-- 掩藏关领奖
			local rewardBranchId = MetaModel:sharedInstance():getRewardGuideHiddenBranchId()
			if rewardBranchId then
				self.worldScene:scrollToBranch(rewardBranchId)
			else
				-- 新版本更新掩藏关
				local newBranchId = MetaModel:sharedInstance():getNewGuideHiddenBranchId()
				if newBranchId then
					self.worldScene:scrollToBranch(newBranchId)
				else
                    --------------add by zhigang.niu
                    --判断是否要跳入隐藏关 不跳进入主线toplevel
                    self:jumpHideLevelOrNotFullStarLevel()
                    ------------

--                    self.worldScene:playOnEnterCenterUserPosAnim()
				end
				-- 刷新客户端小红点
				FAQ:tryRequestFaqReplayCount(true)
			end

			PushActivity:sharedInstance():setForeGroundTimeStamp()


			NetworkUtil:registerNetworkChangeBroadcastReceiver()

			self:buildUserCallBackButton(true)
		end

		-- Beginner Panel
		local user = UserManager:getInstance():getUserRef()
		if user:getTopLevelId() == 1 and UserManager:getInstance().userExtend:getNewUserReward() == 0 then
			-- 创建新手notify
            NewUserNotifiLogic:onCreateNew()
		end
		if not self.isInited then
			-- 刷新notification
			NewUserNotifiLogic:onLogin()
		end

		if PlatformConfig:isPlayDemo() then
			UserManager:getInstance():mockTimeProps(10)
			UserService:getInstance():mockTimeProps(10)
		end

		self:onEnterFromNotification()

		-- 初始化任务系统
		if UserManager:getInstance():getUserRef():getTopLevelId() >= 62 then
			if MaintenanceManager:getInstance():isEnabled("DaliyMission") then
				MissionLogic:getInstance()
			end
		end
		
		-- 签到按钮
		if not self.markButton and not PrepackageUtil:isPreNoNetWork() and not NewVersionUtil:hasSJReward() then
			self:buildMarkButton() -- markButton may be created
		end

		if OppoLaunchManager.getInstance():shouldShowOGCButton() and not self.oppoLaunchButton then 
		 	self:buildOppoLaunchButton()
		end
		
		-- --------------------
		-- ---- Fruit Tree Panel Button
		-- --------------------
		if not PrepackageUtil:isPreNoNetWork() then
			self:createAndShowFruitTreeButton()
		end

		self:buildActivityButton()

		if not self.isInited then
			TimelyHammerGuideMgr.getInstance():checkGuideDecision()
		end
		if GameGuide then
			GameGuide:sharedInstance():onEnterWorldMap(self)
		end

		if RankRaceMgr:getInstance():isLevelReached() then
			if self.rankRaceButton == nil then
 				self:createRankRaceButton()
			else
				self.rankRaceButton:update()
			end
		end

		local XFLogic = require 'zoo.panel.xfRank.XFLogic'

		if XFLogic:needShowPreheatButton() then
			self:createXFPreheatButton()
		end

		XFLogic:registerListeners()

		self:updateFriends()

		if not bootSourceCheck then
			-- local sdk = UrlSchemeSDK.new()
			-- local launchURL = sdk:getCurrentURL()
			self:onApplicationHandleOpenURL(_G.launchURL, true)
			bootSourceCheck = true
		end

		-- 提审IOS计费点用的面板 屏蔽掉入口 如果以后再用可以直接解注释并修改配置
		-- if __IOS and MaintenanceManager:getInstance():isEnabled("AppleVerification") and not self.applePaycodeButton then
		-- 	self.applePaycodeButton = ApplePaycodeButton:create()
		-- 	self.applePaycodeButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
		-- 			ApplePaycodePanel:create():popout()
		-- 		end)
		-- 	self:addIcon(self.applePaycodeButton)
		-- end

		-- 更新按钮
		self:buildUpdateVersionPanel()
		local function dailyTasksNextAction(  )
			CollectStarsManager.getInstance():checkPopop()
		end

		DailyTasksManager.getInstance():backToHomeScene( self.isInited , dailyTasksNextAction )
		CollectStarsManager.getInstance():backToHomeScene( self.isInited )
		
		-- 检查是不是可以弹领取奖励

		-- 信息收集按钮
		self:buildCollectButton()

		
		local function onGetList(info)
			if info then
				local data = ActivityData.new(info)
				data:start(false)
			end
		end
		PushActivity:sharedInstance():onEnterHomeScene(onGetList)

		if __IOS then
            IosPayment:onGameEnterForeground()
	    end

		if (__IOS or __WIN32) and not self.isInited then

			local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
			IosPayGuideProxy:init()
		end

		if (__ANDROID or __WIN32) then
			local AndroidSalesMgrProxy = HappyCoinShopFactory:getInstance():getAndroidSalesManager()
			if not self.isInited then 
				AndroidSalesMgrProxy.getInstance()
			else
				if AndroidSalesMgrProxy.getInstance():shouldTriggerAndroidSales() then 
					local function triggerSucc()
						 AndroidSalesMgrProxy.getInstance():showAndroidSalesPromotion()
					end
					AndroidSalesMgrProxy.getInstance():triggerSalesPromotion(AndroidSalesPromotionLocation.kNormal, triggerSucc)
				end
			end
		end
		
		if QQLoginReward:shouldGetReward() then
            QQLoginReward:receiveReward()
        end

        if BindQQBonus:shouldGetReward() then
        	BindQQBonus:receiveReward(true)--这种情况下只走maintenance配置里的绑定奖励，不考虑鼓励账号绑定的逻辑
        end

        if BindQihooBonus:shouldGetReward() then
        	BindQihooBonus:receiveReward(true)--这种情况下只走maintenance配置里的绑定奖励，不考虑鼓励账号绑定的逻辑
        end

        if BindPhoneBonus:shouldGetReward() then
            BindPhoneBonus:receiveReward(true)--这种情况下只走maintenance配置里的绑定奖励，不考虑鼓励账号绑定的逻辑
        end

        if not self.isInited then
        	FreegiftManager:sharedInstance():update(false, nil)
		end
		
		-- NotificationGuideManager.getInstance():onEnter()

        -- 支付宝免密减免活动
        if not self.isInited and (__ANDROID or __WIN32) then
        	AliQuickPayPromoLogic:initConfig()
        	if AliQuickPayPromoLogic:isEntryEnabled() and not MaintenanceManager:getInstance():isEnabled("AliSignInGame2") then
	        	if not self.aliKfPromoButton then
	        		local function removeButton()
				        if self.aliKfPromoButton and not self.aliKfPromoButton.isDisposed then
				            if self.rightRegionLayoutBar:containsItem(self.aliKfPromoButton) then
				                self.rightRegionLayoutBar:removeItem(self.aliKfPromoButton)
				                self.aliKfPromoButton = nil
				            end
				        end
	        		end
	        		if not AliQuickPayPromoLogic:isInPromotion() then
	        			AliQuickPayPromoLogic:startPromotion()
	        		end
		        	self.aliKfPromoButton = AliKfPromoButton:create()
		        	self:addIcon(self.aliKfPromoButton)
		        	local function onAliKfPromoButtonTapped(isForcePop)
		        		Notify:dispatch("QuitNextLevelModeEvent")

		        		require 'zoo.panel.AliQuickPayPromoPanel'
		        		local panel = AliQuickPayPromoPanel:create(removeButton)
		        		panel:popout()
		        		if not isForcePop and self.aliKfPromoButton then
		        			self.aliKfPromoButton:stopOnlyIconAnim()
		        		end

		        		if isForcePop then
		        			AliQuickPayPromoLogic:setForcePopValue(true)
		        		end


		        		local t1 = 2
		        		if isForcePop == true then t1 = 1 end
		        		local t2 = 0
		        		local defaultPayment = PaymentManager:getInstance():getDefaultPayment()
					    if defaultPayment == Payments.WECHAT then
					        t2 = 2
					    elseif defaultPayment == Payments.ALIPAY then
					        t2 = 1
					    elseif PaymentManager:checkPaymentTypeIsSms(defaultPayment) then
					        t2 = 0
					    else
					    	t2 = 3
					    end
	        			DcUtil:UserTrack({category = 'alipay_mm_299_event', sub_category = '1fen_panel', t1 = t1, t2 = t2})

		        	end
		        	self.aliKfPromoButton.wrapper:ad(DisplayEvents.kTouchTap, onAliKfPromoButtonTapped)
		        	if AliQuickPayPromoLogic:isForcePopEnabled() then
		        		onAliKfPromoButtonTapped(true)
		        	end
		        end
		    end
        end

    	-------------------------------------
		-- 功能预告类btn  比如瓢虫任务 签到  鼓励绑定账号等
		-- -------------------------------
		if not self.isInited then self:createModuleNoticeBtn() end
		self:updateModuleNoticeBtn()

		self:updateInviteBtnPosition()
		self:updateInciteVedioBtnPosition()

		--强弹
		if not self.isInited then 
			self:checkEnterFromScheme()
			InciteManager:onEnterHomeScene()
		end

		if not self.isInited and __ANDROID then 
			--第一次进入homeSene时 检测下短代限额
			PaymentManager.getInstance():checkPaymentLimit(PaymentManager.getInstance():getDefaultSmsPayment())
		end

		-- if (not PlatformConfig:isQQPlatform()) then 
		-- 	self:starButtonLadybugPrompt()
		-- end 

		SupperAppManager:checkData()

		-- WechatFriendLogic:sharedInstance():firstCheckResult()

		if HappyCoinShopFactory:getInstance():shouldUseNewfeatures() then
			require 'zoo.panel.happyCoinShop.PromotionFactory'
			PromotionManager:getInstance():onEnterGame(function ()
			end)
		end

		AlertNewLevelPanel.initCache()

		BroadcastManager:getInstance():onEnterScene(self)

		-- AchievementManager:calHideAreaFullStar()

		--精力通知提醒
		local curEnergy = UserManager.getInstance().user:getEnergy()
		if curEnergy < 5 then 
			NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kEnergyZero)
		end

		--禁掉短代黑名单支付
		if __ANDROID and UserManager:getInstance().userExtend:isInSmsBlacklist() then 
			UserBanLogic:banSmsPay()
		end

		InciteManager:initialize()

		self:runAction(CCCallFunc:create(function ( ... )
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kEnterHomeScene))
		end))

		local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
		if LadybugABTestManager:isNew() then
			local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
			LadybugDataManager:getInstance():onEnterHomeScene()
		end

		RealNameManager:onEnterHomeScene()

		local WDJRemoveManager = require "zoo.panel.wdjremove.WDJRemoveManager"
		WDJRemoveManager:onEnterHomeScene()

		local MiTalkRemoveManager = require "zoo.panel.mitalkremove.MiTalkRemoveManager"
		MiTalkRemoveManager:onEnterHomeScene()

		EmergencySystem:getInstance():enable(true)

		FcmManager:showTip()
		AchiUIManager:onEnterGame()

		local function doEnterFirstLevel()
			local startLevelLogic = StartLevelLogic:create(nil, 1, GameLevelType.kMainLevel, {}, false, {}, 1)
			startLevelLogic:start(true, StartLevelCostEnergyType.kEnergy)
			setTimeOut(function()
				self:freeLeaveScreenMask()
			end, 0.5)
		end
		local topLevel = UserManager.getInstance().user:getTopLevelId()
		local energy = UserManager:getInstance().user:getEnergy()

		local isNewer = (not self.isInited) and (topLevel <= 1) and (energy >= 5)

		if isNewer then
			setTimeOut(doEnterFirstLevel, 2/60)--新手直接在进入第一关
		end

		Notify:dispatch("enterHomeScene", self, isNewer)

		if _G.isLocalDevelopMode and (_G._MAIN_LEVEL_META_ERROR or _G._HIDDEN_LEVEL_META_ERROR) then
			local tip = "关卡配置出错"
			if _G._MAIN_LEVEL_META_ERROR then tip = tip..string.format("\n主线最高关：Meta-%d，关卡-%d", _G._MAIN_LEVEL_META_ERROR.meta, _G._MAIN_LEVEL_META_ERROR.config) end
			if _G._HIDDEN_LEVEL_META_ERROR then tip = tip..string.format("\n支线最高关：Meta-%d，关卡-%d", _G._HIDDEN_LEVEL_META_ERROR.meta, _G._HIDDEN_LEVEL_META_ERROR.config) end
			local text = {
				tip = tip,
				yes = "抽TA",
				no = "",
			}
			CommonTipWithBtn:showTip(text, "negative", nil, nil, nil, true)
			_G._MAIN_LEVEL_META_ERROR = nil
			_G._HIDDEN_LEVEL_META_ERROR = nil
		end
		
		if not self.isInited then 
			GameLauncherContext:getInstance():onCreateHomeSceneDone() 
			setTimeOut( function () GameLauncherContext:getInstance():check() end , 10 )
		end

		self.isInited = true

		self:doInfiniteEnergy()
		--清除在屏幕上的特效
		self:cleanupModuleNoticeBtnEffect()

		-- local newHeadFrameUnlockPanel = require("zoo.PersonalCenter.NewHeadFrameUnlockPanel"):create()
		-- newHeadFrameUnlockPanel:popout()		
		AutoPopout:doMaintenanceSetting_Clear()

        --鼓励绑定icon
        local bHaveSVIPActivity = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()
        if not bHaveSVIPActivity then
            PushBindingLogic:tryPopout(nil, false)
        end
	elseif event == 'exit' then 
		if WXJPPackageUtil.getInstance():isWXJPPackage() then 
			WXJPPackageUtil.getInstance():hideMarketFloatView()
		end
		Notify:dispatch("exitHomeSceneEvent")
	end

	if __ANDROID and CCNodeEx.isForbid ~= true then
		local forbid = nil
		forbid = function ()
			return forbid()
		end
		forbid()
	end
	
end

function HomeScene:doInfiniteEnergy()

	local topLevel = UserManager.getInstance().user:getTopLevelId() 
	if UserManager:getInstance().userExtend:getNewUserReward() == 0 and topLevel ==2 and  AutoPopout:isInNextLevelMode() then
		local function onGetRewardComplete(evt)
			-- UserManager:getInstance().userExtend:setNewUserReward(1)
			UserManager:getInstance().userExtend:setNewUserReward(1)
			UserService:getInstance().userExtend:setNewUserReward(1)
	        Localhost:flushCurrentUserData()
			local scene = HomeScene:sharedInstance()
			scene:checkDataChange()
			local logic = UseEnergyBottleLogic:create(ItemType.INFINITE_ENERGY_BOTTLE, DcFeatureType.kTrunk, DcSourceType.kEnergyUse)
			logic:start(true)
		end
		local http = GetNewUserRewardsHttp.new()
		http:addEventListener(Events.kComplete, onGetRewardComplete)
		http:addEventListener(Events.kError, onGetRewardComplete)
		http:load(1)
	end

end

function HomeScene:checkEnterFromScheme()

	local function openFcPage()
	    -- if PrepackageUtil:isPreNoNetWork() then
	    --     PrepackageUtil:showInGameDialog()
	    -- else
	    --     if __WP8 then
	    --         Wp8Utils:ShowMessageBox("QQ群: 114278702(满) 313502987\n联系客服: xiaoxiaole@happyelements.com", "开心消消乐沟通渠道")
		-- 		else
		-- 			FAQ:openFAQClientIfLogin()
	    --     end
	    -- end
	end

	local scheme = nil
	if (__ANDROID) then
		local manifestUtil = luajava.bindClass("com.happyelements.android.utils.ManifestUtil")
		scheme = manifestUtil:getInstance():getOpenScheme()
		if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>> android scheme is  >>>>>>>>>>>>>>>>>",manifestUtil:getInstance():getOpenScheme()) end

	elseif (__IOS) then
		scheme = OpenUrlHandleManager:getOpenUrlScheme()
		if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>> ios scheme is >>>>>>>>>>>>>>>>>",scheme) end
	end
	
	if ( scheme and scheme == "happyanimal3") then
		openFcPage()
	end
end


-- 瓢虫在StarButton的提示动画
function HomeScene:starButtonLadybugPrompt()
	-- 延时一段时间，先让其他动画飞完

	--  http://wiki.happyelements.net/pages/viewpage.action?pageId=22498544
	--  前期引导动画优化,该引导被废弃
	--[[
	setTimeOut(function() 
		if (self.starButton and (not PopoutManager:sharedInstance():haveWindowOnScreen()) )  then
			local hasReward,rewardElapse,rewardMeta = self.starButton:hasStarReward()
			if _G.isLocalDevelopMode then printx(0, "starButtonLadybugPrompt",hasReward,rewardElapse,rewardMeta) end

			if (rewardMeta) then
				-- 一个阶段只弹出一回动画
				local hasPlay = CCUserDefault:sharedUserDefault():getBoolForKey("star.reward.ladybug"..rewardMeta.starNum)

				-- 领奖差距在10颗星星以内
				if (not hasReward and rewardElapse < 0 and rewardElapse > -10) then
					if (not hasPlay) then
						self:playLadyBugAnimation(rewardElapse,rewardMeta)

						if (rewardMeta) then 
							CCUserDefault:sharedUserDefault():setBoolForKey("star.reward.ladybug"..rewardMeta.starNum, true)
			  		     	CCUserDefault:sharedUserDefault():flush()
						end
					end
				end 
			end
		end
	end , 0)
	]]
end

-- 差额
-- 奖励meta
function HomeScene:playLadyBugAnimation(rewardElapse,rewardMeta)

	local need = math.abs(rewardElapse)

	local scene = HomeScene:sharedInstance()
	local ax,ay = self.starButton:getPositionX()+360,self.starButton:getPositionY()-480

	FrameLoader:loadArmature("skeleton/ladybug_fly_tostar")
	local node = ArmatureNode:create("ladybug")
	node:setPosition(ccp(ax,ay))
	node:playByIndex(0, 1)
	scene:addChild(node)
	
	-- local function animationCallback( ... )

	-- 	local function popoutPanel()
	-- 		local panel = LadybugPromptPanel:create(need,rewardMeta)
	-- 		panel:popout()

	-- 		-- 弹窗关闭后，播放第二段动画
	-- 		local function onTouchEvent( evt )
	-- 			if evt.name == DisplayEvents.kTouchTap then

	-- 				if (node1AnimationCompete) then
	-- 					panel:onCloseBtnTapped()

	-- 					node:removeFromParentAndCleanup()
	-- 					local node2 = ArmatureNode:create("ladybug2")
	-- 					node2:setPosition(ccp(ax,ay))
	-- 					node2:playByIndex(0, 1)
	-- 					scene:addChild(node2)

	-- 					local function animation2Callback(...)
	-- 						node2:removeFromParentAndCleanup()
	-- 						self.starButton:playEntireHighlightAnim()
	-- 					end

	-- 					node2:addEventListener(ArmatureEvents.COMPLETE, animation2Callback)
	-- 				else
	-- 					if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~laiya laiya ~~~~~~~~~~") end
	-- 				end


	-- 			end
	-- 		end

	-- 		panel.bg:ad(DisplayEvents.kTouchTap, onTouchEvent)
	-- 	end
	-- 	AsyncLoader:getInstance():waitingForLoadComplete(popoutPanel)
	-- end
	
	-- node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)

	-- 在最上层添加遮罩，使全屏幕都不可以点击
	local node1AnimationCompete = false
	local panel = LadybugPromptPanel:create(need,rewardMeta)

	local function nodeAnimationComplete()
		node1AnimationCompete = true
		panel:setVisible(true)
	end

	-- test
	local function popoutPanel()
		panel:popout()
		panel:setVisible(false)

		-- 弹窗关闭后，播放第二段动画
		local function onTouchEvent( evt )
			if evt.name == DisplayEvents.kTouchTap then

				if (node1AnimationCompete) then
					panel:onCloseBtnTapped()

					node:removeFromParentAndCleanup()
					local node2 = ArmatureNode:create("ladybug2")
					node2:setPosition(ccp(ax,ay))
					node2:playByIndex(0, 1)
					scene:addChild(node2)

					local function animation2Callback(...)
						node2:removeFromParentAndCleanup()
						self.starButton:playEntireHighlightAnim()
					end

					node2:addEventListener(ArmatureEvents.COMPLETE, animation2Callback)
				else
					if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~ as mask: you ben shi ni dian wo ya  ~~~~~~~~~~") end
				end
			end
		end

		panel.bg:ad(DisplayEvents.kTouchTap, onTouchEvent)
	end

	node:addEventListener(ArmatureEvents.COMPLETE, nodeAnimationComplete)
	AsyncLoader:getInstance():waitingForLoadComplete(popoutPanel)
	-- test end
end

function HomeScene:onLockedCloudCreateFinish()
	-- 区域解锁面板强弹
	HomeScenePopoutQueue:insert(UnlockCloudPanelPopoutAction.new())
end

function HomeScene:updateFriends(...)
	assert(#{...} == 0)

	if not self.updateFriendsCalled then
		self.updateFriendsCalled = true

		DcUtil:up(150)
	end

	local function onSendFriendSuccess()
		self:updateInviteBtnPosition()
		self.worldScene:buildFriendPicture()
		self:dcUserInfo()

		local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
		if LadybugABTestManager:isNew() then
			local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
			LadybugDataManager:getInstance():onFriendPicUpdate()
		end
	

	end

	self.worldScene:sendFriendHttp(onSendFriendSuccess)
end

function HomeScene:getPositionByLevel(level)
	local node = self.worldScene.levelToNode[level]
	if node == nil then 
		he_log_error("HomeScene:getPositionByLevel level = " .. level)
		return nil
	end
	return node:getPosition()
end

function HomeScene:updateLadyBugBtnTimeLabel(timeString, ...)
	assert(type(timeString) == "string")
	assert(#{...} == 0)
	
	if self.ladybugButton then
		self.ladybugButton:setTimeLabelString(timeString)
	end
end

local function scheduleLocalNotification()
	RecallManager.getInstance():updateRecallInfo()
	-- LocalNotificationManager.getInstance():pocessRecallNotification()
	LocalNotificationManager.getInstance():setEnergyFullNotification()
	LocalNotificationManager.getInstance():validateNotificationTime()
	LocalNotificationManager.getInstance():pushAllNotifications()
end



function HomeScene:onKeyBackClicked(...)
	assert(#{...} == 0)
	if __disposeTextureOnExit then __disposeTextureOnExit() end
	if _G.isLocalDevelopMode then printx(0, "HomeScene:onKeyBackClicked Called !") end
    if _G.__CMGAME_TISHEN then
        return self:onKeyBackClicked_Cmgame_tishen()
    end

	if __WP8 then
		if self.exitDialog then return end
		self.exitDialog = true
		local function msgCallback(r)
			if r then 
				Director.sharedDirector():exitGame()
			else
				self.exitDialog = false
			end
		end
		Wp8Utils:ShowMessageBox(Localization:getInstance():getText("game.exit.tip"), "", msgCallback)
		return
	end

	local function CmgameExit()
		if __ANDROID and
			PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
			not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame)
			and _G.needCallCmgameExit
		then
			local function exit()
				local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
    			cmgamePayment:exitGame()
			end
			pcall(exit)
		end
	end

	local function callPaymentExit(paymentClass)
        if paymentClass then
            local function buildCallback(onExit, onCancel)
                return luajava.createProxy("com.happyelements.android.InvokeCallback", {
                    onSuccess = onExit or function(result) end,
                    onError = onError or function(errCode, msg) end,
                    onCancel = onCancel or function() end
                })
            end
            local exitCallback = buildCallback(
                function(obj)
                	scheduleLocalNotification()
                	CmgameExit()
                    Director.sharedDirector():exitGame()
                end,
                function()
                    self.exitDialog = false
                end
            )
            self.exitDialog = true
            paymentClass:exitGame(exitCallback)
        end
    end

	local pfName = StartupConfig:getInstance():getPlatformName()
	if PlatformConfig:isBaiduPlatform() and (__ANDROID and SnsProxy:getDuokuAdsOpen()) then
		local dUOKUProxy = luajava.bindClass("com.happyelements.hellolua.duoku.DUOKUProxy"):getInstance()
		if dUOKUProxy then
			dUOKUProxy:detectDKGameExit()
		end
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) then
        local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
        callPaymentExit(cmgamePayment)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.k189Store) then
        local telecomPayment = luajava.bindClass("com.happyelements.android.operatorpayment.telecom.TelecomPayment")
        callPaymentExit(telecomPayment)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
        local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy")
        callPaymentExit(oppoProxy)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kBBK) then
        local vivoProxy = luajava.bindClass("com.happyelements.android.platform.vivo.VivoProxy")
        callPaymentExit(vivoProxy)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.k360) then
        local oppoProxy = luajava.bindClass("com.happyelements.android.platform.qihoo.QihooUserAgent")
        callPaymentExit(oppoProxy)
    else
		if self.exitDialog then return end

	    local function onExit(dcT1Record)
            if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: sns onSuccess") end
	        scheduleLocalNotification()
	        DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=dcT1Record,t2=1}, true)
            DcUtil:saveLogToLocal()
	        if __ANDROID then
				require "zoo.platform.VivoPlatform"
				VivoPlatform:onEnd()
			end
			CmgameExit()
	        CCDirector:sharedDirector():endToLua()
        end
            
        local function onCancelExit(dcT1Record) 
            if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: sns onCancel") end
	        self.exitDialog = false
	        PushActivity:sharedInstance():setPushActivityEnabled(true)
	        DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=dcT1Record,t2=2},true)
        end
        
        PushActivity:sharedInstance():setPushActivityEnabled(false)
        self.exitDialog = true

        local isNewVersionDownloaded = UpdatePackageManager:enabled() and UpdatePackageManager:getInstance():isFinish() or  UpdatePackageLogic:getInstance():isFinish()
        if isNewVersionDownloaded then
        	require('zoo.panel.InstallAlertPanel'):create(onExit, onCancelExit):popout()
        else
        	ExitAlertPanel:create(onExit, onCancelExit):popout()
        end
	end
end

function HomeScene:onKeyBackClicked_Cmgame_tishen(...)
	assert(#{...} == 0)
	local function CmgameExit()
		if __ANDROID and
			PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
			not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame)
		then
			local function exit()
				local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
    			cmgamePayment:exitGame()
			end
			pcall(exit)
		end
	end

	local function buildCallback(onExit, onCancel)
        return luajava.createProxy("com.happyelements.android.InvokeCallback", {
            onSuccess = onExit or function(result) end,
            onError = onError or function(errCode, msg) end,
            onCancel = onCancel or function() end
        })
    end

	local function CmgameExitWithParm( onExit, onCancel )
		if __ANDROID and
			PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
			not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame)
		then
			local exitCallback = buildCallback(
                function(obj)
                	if onExit then 
                		onExit() 
                	else
                		scheduleLocalNotification()
                    	Director.sharedDirector():exitGame()
                	end
                end,
                function()
                    self.exitDialog = false
                    if onCancel then onCancel() end
                end
            )
			local function exit()
				local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
    			cmgamePayment:exitGame(exitCallback)
			end
			pcall(exit)
		else
			if onExit then onExit() end
		end
	end

	local function callPaymentExit(paymentClass)
        if paymentClass then
            local exitCallback = buildCallback(
                function(obj)
                	scheduleLocalNotification()
                    Director.sharedDirector():exitGame()
                end,
                function()
                    self.exitDialog = false
                end
            )
            self.exitDialog = true
            paymentClass:exitGame(exitCallback)
        end
    end

	local pfName = StartupConfig:getInstance():getPlatformName()
	if PlatformConfig:isBaiduPlatform() then
		local function onExit()
			local dUOKUProxy = luajava.bindClass("com.happyelements.hellolua.duoku.DUOKUProxy"):getInstance()
			if dUOKUProxy then
				dUOKUProxy:detectDKGameExit()
			end
		end
		
		CmgameExitWithParm(onExit)

	elseif PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) then
		local function onExit()
			local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
        	callPaymentExit(cmgamePayment)
		end
        CmgameExitWithParm(onExit)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.k189Store) then
    	local function onExit()
    		local telecomPayment = luajava.bindClass("com.happyelements.android.operatorpayment.telecom.TelecomPayment")
        	callPaymentExit(telecomPayment)
    	end
        CmgameExitWithParm(onExit)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
    	local function onExit()
    		local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy")
        	callPaymentExit(oppoProxy)
    	end
       	CmgameExitWithParm(onExit)
    else
		if self.exitDialog then return end

		local function onExit1( ... )
			local function onExit(dcT1Record)
	            print("Info - Keypad Callback: sns onSuccess")
		        scheduleLocalNotification()
		        DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=dcT1Record,t2=1}, true)
	            DcUtil:saveLogToLocal()
		        if __ANDROID then
					require "zoo.platform.VivoPlatform"
					VivoPlatform:onEnd()
				end
		        CCDirector:sharedDirector():endToLua()
	        end
	            
	        local function onCancelExit(dcT1Record) 
	            print("Info - Keypad Callback: sns onCancel")
		        self.exitDialog = false
		        PushActivity:sharedInstance():setPushActivityEnabled(true)
		        DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=dcT1Record,t2=2},true)
	        end
	        
	        PushActivity:sharedInstance():setPushActivityEnabled(false)
	        self.exitDialog = true
	        ExitAlertPanel:create(onExit, onCancelExit):popout()
		end

	    CmgameExitWithParm(onExit1)
	end
end

function HomeScene:tryPopoutMarkPanel(isClick, closeCallback, dcLocation)
	if not self.markButton or self.markButton.isDisposed then
		return nil
	end
	local btnParent		= self.markButton:getParent()
	local btnPosInWorldPos
	if btnParent then
		local bounds = self.markButton:getGroupBounds()
		btnPosInWorldPos = ccp(bounds:getMidX(),bounds:getMidY())
	else
		local bounds = self.hideAndShowBtn.ui:getGroupBounds()
		btnPosInWorldPos = ccp(bounds:getMidX(),bounds:getMidY())
	end

	local function stopMarkAnim()
		self.markButton:stopHasSignAnimation()
	end

	local function localCloseCallback()
		if self.markButton 
		and IconButtonPool:getBtnState(self.markButton) == IconBtnShowState.ON_HOMESCENE 
		and not HomeSceneButtonsManager.getInstance():shouldShowMarkBtnOnHomeScene() then
			local btn = MarkButton:create()
			local pos = self.markButton:getParent():convertToWorldSpace(self.markButton:getPosition())
			local function beforeFly()
				if not self.markButton then 
					if closeCallback then
						closeCallback()
					end
					return 
				end
				self.markButton:setVisible(false)
				self.markButton.wrapper:setTouchEnabled(false)
				self.hideAndShowBtn:setEnable(false)
			end
			local function afterFly()
				if not self.markButton then 
					--HomeSceneButtonsManager.getInstance():setButtonShowPosState(HomeSceneButtonType.kMark, true)
					if closeCallback then
						closeCallback()
					end
					return 
				end
				self.hideAndShowBtn:playAni(function ()
					self.hideAndShowBtn:setEnable(true)

					-- HomeSceneButtonsManager.getInstance():showButtonHideTutor()
					Notify:dispatch("AutoPopoutEventAwakenAction", IconCollectGuidePopoutAction)
					
				end)
				self.markButton:setVisible(true)
				self.markButton.wrapper:setTouchEnabled(true)
				-- self:onIconBtnFinishJob(self.markButton)
				self:buildHiddenMarkBtn()
				-- self:removeIcon(self.markButton)
				self.markButton = nil
				--HomeSceneButtonsManager.getInstance():setButtonShowPosState(HomeSceneButtonType.kMark, true)
			end
			HomeSceneButtonsManager.getInstance():flyToBtnGroupBar(btn, pos, beforeFly, afterFly, false)
		end
		if closeCallback then
			closeCallback()
		end
	end

	local dayTime = 3600 * 24 * 1000
	local curDay = math.floor(Localhost:time() / dayTime)
	self.lastMark = self.lastMark or 0
	if isClick or self.lastMark < curDay then
        if not UserManager:getInstance().markV2Active then
		    local markModel = MarkModel:getInstance()
		    markModel:calculateSignInfo()

		    if markModel.canSign then
			    self.markButton:playHasSignAnimation()
		    else 
			    self.markButton:stopHasSignAnimation() 
		    end

		    if isClick or markModel.canSign then

                local panel = MarkPanel:create(btnPosInWorldPos)
			    panel:setMarkCallback(stopMarkAnim)
			    panel:setCloseCallback(localCloseCallback)
			    panel:popout()
			    self.lastMark = curDay
			    return panel
		    end
        else
            if Mark2019Manager.getInstance():showMark2019Panel(stopMarkAnim, localCloseCallback, dcLocation) then 
            	self.lastMark = curDay
            end
            return true
        end
	end
	return nil
end

function HomeScene:buildUserCallBackButton(isInit)
	local willShow = UserCallbackManager.getInstance():shouldShowIcon(isInit)
	if willShow then 
		self:buildHomeSceneUserCallBackButton()
	else
		self:removeHomeSceneUserCallBackButton()
	end
end

function HomeScene:buildMarkButton()
	if UserManager.getInstance().user:getTopLevelId() > 13 then 
		if HomeSceneButtonsManager.getInstance():shouldShowMarkBtnOnHomeScene() then
			self:buildHomeSceneMarkBtn()
		else
			self:buildHiddenMarkBtn()
		end
	end
end

function HomeScene:buildOppoLaunchButton()
	self.oppoLaunchButton = OppoLaunchButton:create()
	self.oppoLaunchButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
		Notify:dispatch("QuitNextLevelModeEvent")
		if self.isDisposed then return end
		OppoLaunchManager.getInstance():setRedDotShowOver()
		self.oppoLaunchButton:upadteRedDotShow()
		HomeScene:sharedInstance().hideAndShowBtn:updateRedDot()

		local isOppoLaunch = OppoLaunchManager.getInstance():getIsOppoLaunch()
		if isOppoLaunch then 
		 	local topLevelId = UserManager:getInstance().user:getTopLevelId()
		 	if topLevelId >= 20 then 
		 		OppoLaunchManager.getInstance():getServerData(function (canLottery)
		 			local dcClickType = nil
		 			if canLottery then 
		 				dcClickType = 4
						OppoTurntablePanel:create():popout()
		 			else
		 				dcClickType = 3
		 				OppoTurntableDesc:create():popout()
		 			end
		 			OppoLaunchManager:dc("oppoact_icon_click", nil, nil, dcClickType)
		 		end, function ()
		 			OppoLaunchManager:dc("oppoact_icon_click", nil, nil, 2)
		 			OppoTurntableDesc:create():popout()
		 		end)
		 	else
		 		OppoLaunchManager:dc("oppoact_icon_click", nil, nil, 1)
		 		OppoTurntableDesc:create():popout()
		 	end
		else
		 	OppoLaunchManager:dc("oppoact_icon_click", nil, nil, 0)
		 	OppoTurntableDesc:create():popout()
		end
	end)

	self:addIcon(self.oppoLaunchButton, true)
end

function HomeScene:buildActivityButton()
	if self.activityButton == true then 
		return
	end

	local isSame = true
	if self.activityButton then 
		if ActivityCenter:useNew() then
			isSame = not ActivityCenter:checkNeedUpdate()
		else
			isSame = #ActivityUtil:getNoticeActivitys() > 0
		end
	else
		if ActivityCenter:useNew() then
			isSame = #ActivityUtil:getCenterActivitys() == 0
		else
			isSame = #ActivityUtil:getNoticeActivitys() == 0
		end
	end
	if isSame then 
		local iconActivitys = ActivityUtil:getIconActivitys()
		if self.activityIconButtons and #iconActivitys == #self.activityIconButtons then 
			for k,v in pairs(self.activityIconButtons) do
				if not table.find(iconActivitys,function( a ) return a.source == v.source and a.version == v.version end) then 
					isSame = false
					break
				end
			end
		else
			isSame = false
		end
	end

	if isSame then 
		return
	end

	for _,v in pairs(self.activityIconButtons or {}) do
		v:removeFromUi(self)
	end
	self.activityIconButtons = {}

	local suppressFlyAnimation = false
	if self.activityButton then 
		self:removeIcon(self.activityButton, true)
		self.activityButton = nil
		suppressFlyAnimation = true --如果是删除重建，那就不用播动画了
	end

	local function buildActivityIconButton(source,version)
		if table.find(ActivityUtil:getActivitys(),function( v ) return v.source == source and v.version == version end) == nil then 
			return
		end 
		local oldIcon =	table.find(self.activityIconButtons,function( v ) return v.source == source end )
		if oldIcon then 
			table.removeValue(self.activityIconButtons,oldIcon)
			oldIcon:removeFromUi(self)
		end

		local config = require("activity/" .. source)
		if config.icon then 
			local activityIconButton = nil
			if type(config.icon) == "string" then
				activityIconButton = ActivityIconButton:create(source,version)
			elseif type(config.icon) == "table" then
				activityIconButton = require("activity/" .. config.icon.startLua):create(source,version)
			end

			if activityIconButton then 
				table.insert(self.activityIconButtons,activityIconButton)
				activityIconButton:addToUi(self)

				local eventNode = CocosObject:create()
				activityIconButton:addChild(eventNode)
				eventNode:addEventListener(Events.kAddToStage,function( ... )
					if not config.isSupport() then
						table.removeValue(self.activityIconButtons,activityIconButton)
						activityIconButton:removeFromUi(self)
					end
				end)
			end
		end
	end

	self.activityButton = true

	if ActivityCenter:useNew() then
		ActivityCenter:showCenterBtn(self, suppressFlyAnimation)
	end

	ActivityUtil:getActivitys(function(activitys)
		if not ActivityCenter:useNew() or self.activityButton == true then
			self.activityButton = nil
		end

		if #activitys <= 0 then
			GameLauncherContext:getInstance():onAllActivityIconStartLoad()
			GameLauncherContext:getInstance():onAllActivityIconLoaded()
			GameLauncherContext:getInstance():onAllActivityIconCreated()
			return 
		end
		
		if not ActivityCenter:useNew() then
			if #ActivityUtil:getNoticeActivitys() > 0 then 
				self.activityButton = ActivityButton:create()
				self:addIcon(self.activityButton, false, suppressFlyAnimation)
			end
		end

		for _,v in pairs(self.activityIconButtons or {}) do
			v:removeFromUi(self)
		end
		self.activityIconButtons = {}
		local iconActivitys = ActivityUtil:getIconActivitys()
		local iconActivitysTotalCount = #iconActivitys
		local iconActivitysCurrCount = 0

		GameLauncherContext:getInstance():onAllActivityIconStartLoad()

		if iconActivitysTotalCount == 0 then
			GameLauncherContext:getInstance():onAllActivityIconLoaded()
		end

		for _,v in pairs(iconActivitys) do

			GameLauncherContext:getInstance():onOneActivityIconStartLoad( v.source , v.version )

			ActivityUtil:loadIconRes(v.source,v.version,function( ... )

				GameLauncherContext:getInstance():onOneActivityIconLoaded( v.source , v.version )
                buildActivityIconButton(v.source,v.version)
                GameLauncherContext:getInstance():onOneActivityIconCreated( v.source , v.version )

                iconActivitysCurrCount = iconActivitysCurrCount + 1
                if iconActivitysCurrCount >= iconActivitysTotalCount then
                	GameLauncherContext:getInstance():onAllActivityIconLoaded()
                	GameLauncherContext:getInstance():onAllActivityIconCreated()
                end
            	
			end)
		end

		for _,v in pairs(ActivityUtil:getNoticeActivitys()) do
			ActivityUtil:loadNoticeImage(v.source,v.version)
		end

		if ActivityCenter:useNew() then
			ActivityCenter:onActConfigLoadEnd( activitys )
		end

		GameLauncherContext:getInstance():onAllActivityStartExecuteAutoLua()
		for _,v in pairs(activitys) do
			local config = require("activity/" .. v.source)
			
			if not ActivityData.new(v):isLoaded() then  
				if v.version == ActivityUtil:getCacheVersion(v.source) then 
					ActivityUtil:executeAutoLua(v.source,v.version)
				end
			end
		end
		GameLauncherContext:getInstance():onAllActivityExecuteAutoLuaFinish()

	end)


end

function HomeScene:buildUpdateVersionPanel()
	-- if NewVersionUtil:hasUpdateReward() then return end ---如果有更新奖励不能弹 更新面板
	-- 这里的逻辑是点击按钮自动弹出，不是自动弹出的逻辑
	local function popoutUpdateVersionPanel(isAutoPopout)
		local function checkUpdate()
			-- 1：大版本更新
			if NewVersionUtil:hasPackageUpdate() then 



				local position = self.updateVersionButton:getPositionInWorldSpace()
				local panel = nil

				local function doPopout( ... )
					if panel then
						local function onClose()
							if not self.updateVersionButton or self.updateVersionButton.isDisposed then return end
							self.updateVersionButton.wrapper:setTouchEnabled(true)
						end
						panel:addEventListener(kPanelEvents.kClose, onClose)
						self.updateVersionButton.wrapper:setTouchEnabled(false)
						if isAutoPopout and panel.autoPopout then
							panel:autoPopout()
						else
							panel:popout()
						end
					end
				end

				if (_G.isPrePackage ) then
					panel = PrePackageUpdatePanel:create(position) 
					doPopout()
					return
				end

				if UpdatePackageManager:enabled() then
					UpdatePackageManager:getInstance():onClickIcon()
					return
				end

				local function __popoutPanel( ... )
					local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
		            AsyncSkinLoader:create(UpdatePageagePanel, {
		                position
		            }, UpdatePageagePanel.getSkin, function ( __panel )
		                panel = __panel
		                doPopout()
		            end)
				end

				--根据缓存判断一下，如果上次下载完成了，那么面板可以离线弹出，否则不能离线弹出
				if UpdatePackageLogic:getInstance():isFinish() then
					__popoutPanel()
		        else
		        	RequireNetworkAlert:callFuncWithLogged(__popoutPanel)
		        end

			-- 2：动态更新
			elseif NewVersionUtil:hasDynamicUpdate() and _G.kUserLogin then

				RequireNetworkAlert:callFuncWithLogged(function ( ... )
					self.updateVersionButton.wrapper:setTouchEnabled(false)
					DynamicUpdatePanel:onCheckDynamicUpdate(isAutoPopout)
				end)

			else 
				if _G.isLocalDevelopMode then printx(0, "check update error ") end
			end

		end
		DcUtil:UserTrack({ category='update', sub_category='update_icon'})
		if (_G.isPrePackage) then
			checkUpdate()
		else
			-- RequireNetworkAlert:callFuncWithLogged(checkUpdate)
			checkUpdate()
		end
	end

	local function buildUpdateVersionButton()
		if not self.updateVersionButton then
            UpdatePageagePanel._updateInfo = UserManager:getInstance().updateInfo
            
			self.updateVersionButton = UpdateButton:create()
			self.rightBottomRegionLayoutBar:addItem(self.updateVersionButton)
			self.updateVersionButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
			 	popoutUpdateVersionPanel(false)
			  end )
		end
	end


	local function checkWifiAutoDownload()
		if _G.isPrePackage then
			return
		end
		
		if UpdatePackageManager:enabled() then
			self.updateVersionButton:setVisible(UpdatePackageManager:getInstance():canShowIcon())
		else
			if UpdatePackageLogic:getInstance():getState() == UpdatePackageLogic.States.kFinish then
				self.updateVersionButton:setText("ready")
			end
			if WifiAutoDownloadManager:getInstance():isTurnOn() and
				NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi and
				(not UpdatePackageLogic:getInstance():isDownloading()) and 
				(not UpdatePackageLogic:getInstance():isFinish()) then
				
				if UpdatePackageLogic:getInstance():autoStartDownload() then
					-- self.updateVersionButton:setVisible()
				end
			end
		end
	end

	if not self.updateVersionButton and NewVersionUtil:hasNewVersion() then
		buildUpdateVersionButton()

		if UpdatePackageManager:enabled() and not UpdatePackageManager:getInstance():hasUpdate() then
			return
		end
		if NewVersionUtil:hasPackageUpdate() and UserManager:getInstance().updateInfo then

			local version = tostring(UserManager:getInstance().updateInfo.version)
			if PrePackageUpdatePanel:isApkExist(version) then
				self.updateVersionButton:setText("ready")
			end

			checkWifiAutoDownload()
		end
	else
		if NewVersionUtil:hasPackageUpdate() and UserManager:getInstance().updateInfo then
			checkWifiAutoDownload()
		end
	end
end

function HomeScene:createMask(opacity, position, radius, square, width, height, oval)
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))

	local node
	if square then
		node = LayerColor:create()
		width = width or 50
		height = height or 40
		node:changeWidthAndHeight(width, height)
	elseif oval then
		node = Sprite:createWithSpriteFrameName("circle0000")
		width, height = width or 1, height or 1
		node:setScaleX(width)
		node:setScaleY(height)
	else
		node = Sprite:createWithSpriteFrameName("circle0000")
		radius = radius or 1
		node:setScale(radius)
	end
	node:setPosition(ccp(position.x, position.y))
	local blend = ccBlendFunc()
	blend.src = GL_ZERO
	blend.dst = GL_ONE_MINUS_SRC_ALPHA
	node:setBlendFunc(blend)
	mask:addChild(node)

	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	if __WP8 then layer:saveToCache() end

	mask:dispose()

	local layerSprite = layer:getSprite()
	local obj = CocosObject.new(layer)
	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouchTap()
		
	end
	trueMaskLayer:ad(DisplayEvents.kTouchTap,onTouchTap)
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end

function HomeScene:popoutMarketPanelByIndex(defaultIndex, showFree, source,closeCallback)
	local isPennyPayEnabled = HappyCoinShopFactory:getInstance():shouldUseNewfeatures() and PromotionManager:getInstance():isPennyPayEnabled()
	local defaultPayType = nil
	if isPennyPayEnabled then
		defaultPayType = Payments.ALIPAY
	end
	local panel =  createMarketPanel(defaultIndex, nil, closeCallback, defaultPayType)
	if showFree ~= nil then panel:setGoldFreeVisible(showFree) end
	if panel then 
		if source then
			panel:setSource(source)
		end
		panel:popout() 
	end
end

function HomeScene:popoutMarketPanel(event)
	self:popoutMarketPanelByIndex(1);
end

function HomeScene:onEnterBackground()
	if not UpdatePackageManager:enabled() and UpdatePackageLogic:getInstance():isFinish() then
		require('zoo.panel.InstallAlertPanel'):removeExitAlert()
	else
		ExitAlertPanel:removeExitAlert()
	end
	Notify:dispatch("SceneEventEnterBackground")
end

function HomeScene:onEnterForeGround()
    ExitAlertPanel:removeExitAlertOnEnterForeground()
	if _G.isLocalDevelopMode then printx(0, "HomeScene:onEnterForeGround") end
	if self.exitDialog then
		return
	end

	if AccountBindingLogic.preconnectting then
		return
	end

	PushActivity:sharedInstance():setForeGroundTimeStamp()
	InciteManager:onEnterHomeScene()
	--没有点链接的情况 
	self:runAction(CCCallFunc:create(function( ... )
		if not self.worldScene.isDisposed then 
			self.worldScene:checkAndUpdateUnlockTipView()
		end
	end))

	local function onGetRequestNumSuccess(evt)
		UserManager:getInstance().requestNum = evt.data.requestNum
        UserManager:getInstance():changeRequestNum()

		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))

		UserManager:getInstance().updateInfo = evt.data.updateInfo

		UserManager:getInstance().videoSDKInfo = evt.data.videoSDKInfo
        -- print(" VideoAdEventSyncInfo onGetRequestNumSuccess",tostring(UserManager:getInstance().videoSDKInfo))
		Notify:dispatch("VideoAdEventSyncInfo")

		self:buildUpdateVersionPanel()
		-- UpdatePackageManager:getInstance():onEnter()

		--LevelDifficultyAdjustManager:updateUserTag( userTag , UserTagDCSource.kHome )
		UserTagManager:updateTagsByResp( evt.data , UserTagDCSource.kHome )

		ActivityUtil:setActInfos(evt.data.actInfos)
		if self.activityButton ~= true then
			local scene = Director:sharedDirector():getRunningSceneLua()
			if scene and scene:is(HomeScene) then
				local actList = ActivityUtil:getActivitys()
				if actList and #actList > 0 then
					self:buildActivityButton()
				end
			end
		end
		--马俊松添加 home回来之后 发送 ActInfoChange 以后别的活动管理类可以复用
		Notify:dispatch('ActInfoChange')
		
		local energyGiftNum = evt.data.askEnergyReceivedNum
		if energyGiftNum ~= nil and type(energyGiftNum) == "number" and energyGiftNum > 0 then
			require "zoo.panel.broadcast.GetShareFreeGiftPanel"
			GetShareFreeGiftPanel:addInGameGiftNum(energyGiftNum)
		end

		if __ANDROID then 
			AndroidPayment.getInstance():changeSMSPaymentDecisionScript(evt.data.smsPay)
		end
		-- AskForHelp
		self:processAskForHelpData(evt)
	end

	if not PrepackageUtil:isPreNoNetWork() then
        local function getRequestNum( ... )
            local http = GetRequestNumHttp.new(false)
            http:ad(Events.kComplete, onGetRequestNumSuccess)
            -- http:load()
            http:syncLoad("home")
        end
		RequireNetworkAlert:callFuncWithLogged(getRequestNum, nil, kRequireNetworkAlertAnimation.kNoAnimation)
	end

	FAQ:tryRequestFaqReplayCount()

	Notify:dispatch("AutoPopoutEventWaitAction", ActivityPopoutAction)
	
	ActivityUtil:reloadActivitys(function( activitys )
		if activitys == nil then
			if _G.isLocalDevelopMode then printx(0, "activitys == nil") end
			return
		end
		if self.activityButton == true then
			if _G.isLocalDevelopMode then printx(0, "self.activityButton == true") end
			return
		end

		self:buildActivityButton()

		self:runAction(CCCallFunc:create(function ()
			Notify:dispatch("AutoPopoutEventAwakenAction", ActivityPopoutAction)
		end))
	end)
	
	UserManager:getInstance():checkDateChange()
	
	self:dp(Event.new(SceneEvents.kEnterForeground, nil, self))
	Notify:dispatch("SceneEventEnterForeground")
end

function HomeScene:updateButtons()
	local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'

	if not LadybugABTestManager:isOld() then
		return
	end
end

-- 从游戏外部启动游戏或外力后台切换至前台时进行处理
-- region
function HomeScene:onApplicationHandleOpenURL(launchURL, isBoot)
	-- self:autoPopoutUrl(launchURL)
	if not isBoot and type(launchURL) == "string" and string.len(launchURL) > 0 then
		Notify:dispatch("HomeSceneEventOpenUrl", launchURL)
	end

	-- if _G.isLocalDevelopMode then printx(0, "HomeScene:onApplicationHandleOpenURL:"..tostring(launchURL)) end
	self.activityShareData = nil

	if type(launchURL) == "string" and string.len(launchURL) > 0 then
		local res = UrlParser:parseUrlScheme(launchURL)
		if not res.method then return end
		if _G.isLocalDevelopMode then printx(0, table.tostring(res)) end
		if type(self["onApplicationHandleOpenURL_"..string.lower(res.method)]) == "function" then
			self:runAction(CCSequence:createWithTwoActions(
				CCDelayTime:create(1/60),
				CCCallFunc:create(function()
					self["onApplicationHandleOpenURL_"..string.lower(res.method)](self, res)
				end)
			))
		end
	end
end
function HomeScene:onApplicationHandleOpenURL_add_friend(res)
	if type(res.para) == "table" and res.para.aaf and res.para.uid and res.para.invitecode and res.para.pid then
			local invitecode = tonumber(res.para.invitecode) or 0
			if tonumber(res.para.aaf) == ADD_FRIEND_SOURCE.AUTOADDFRIEND then
				local preStr = localize("addfriend_copy_sms_pre")
	            local tagStr = localize("addfriend_copy_sms_tag")
	            local string1 = preStr .. res.para.invitecode  .. tagStr  
	            local function closeCallBack( ... )
	            	
	            end 
	            local dcData = {}
		        dcData.category = "AddFriend"
		        dcData.sub_category = "addfriend_by_link"
		        DcUtil:log(AcType.kUserTrack, dcData, true)
		        AutoAddFriendManager.getInstance():setIsOpenBylink( true )
				AutoAddFriendManager.getInstance():autoAddCheck(string1,closeCallBack)
			end



	end
end
function HomeScene:onApplicationHandleOpenURL_addfriend(res)
	if type(res.para) ~= "table" or not res.para.invitecode or not res.para.uid and not res.para.pid then return end
	local function onSuccess(data)
		local code = data.returnCode 
		self:checkDataChange()
		if self.coinButton and not self.coinButton.isDisposed then
			self.coinButton:updateView()
		end

		if  code ~= nil and type(code) == "number" then
            --"0:成功 1:自己的好友满了 2:对方的好友满了 3:已经是好友了"
            if code == 0 then
               	if res.para.isyyb then
					CommonTip:showTip(Localization:getInstance():getText("add.friend.success.tips"), "positive", nil, 3)
					DcUtil:addFriendQRCode(2)
				else
					CommonTip:showTip(Localization:getInstance():getText("url.scheme.add.friend"), "positive", nil, 3)
				end
            elseif code == 3 then
                CommonTip:showTip(localize("addfriend_auto_add_hit3"), "negative")
            elseif code == 1 then
                CommonTip:showTip(localize("addfriend_auto_add_hit1"), "negative")
            elseif code == 2 then
                CommonTip:showTip(localize("addfriend_auto_add_hit2"), "negative")
            end
        end
	end
	local function onFail(err)
		if res.para.isyyb then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative", nil, 3)
		end
	end
	local function startInvitedAndRewardLogic()
		local logic = InvitedAndRewardLogic:create(false)
		logic:start(res.para.invitecode, res.para.uid, res.para.pid, res.para.ext, onSuccess, onFail)
	end
	RequireNetworkAlert:callFuncWithLogged(startInvitedAndRewardLogic, nil, kRequireNetworkAlertAnimation.kNoAnimation)
end

function HomeScene:onApplicationHandleOpenURL_wxshare(res)
	if type(res.para) ~= "table" or not res.para.uid then return end

	if MaintenanceManager:getInstance():isEnabled("wxsharetime") then
		DcUtil:UserTrack({category = "wx_share", sub_category = "push_message_weixin",
			turn_table = res.para.turntable})
		local function createTurnTable()
			local profile = UserManager:getInstance().profile
			if profile.uid ~= tonumber(res.para.uid) then
				if tonumber(res.para.uitype) == 0 then TurnTablePanel:tryCreateTurnTable(res.para.turntable)
				elseif tonumber(res.para.uitype) == 1 then end
			end
		end
		RequireNetworkAlert:callFuncWithLogged(createTurnTable)
	end
end

function HomeScene:onApplicationHandleOpenURL_activity_wxshare(res)
	if type(res.para) ~= "table" then return end

	local paraData = {}
	for k, v in pairs(res.para) do
		paraData[k] = v
	end
	self.activityShareData = paraData
	if paraData.actId then
		-- GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(OpenUrlEvents.kActivityShare..tostring(paraData.actId), paraData))
	end
end

function HomeScene:onApplicationHandleOpenURL_webview(res)
	if type(res.para) ~= "table" then return end
	WebviewHandler:handle(res)
end

-- endregion

function HomeScene:setEnterFromGamePlay(levelId, isQuit)
	-- if _G.isLocalDevelopMode then printx(0, "enter from game play ") end
	-- debug.debug()
	AutoPopout:setSubSource(AutoPopoutSource.kGamePlayQuit)
	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReturnFromGamePlay, {id = levelId,isQuit = isQuit or false}))
	if not self.worldScene.isDisposed then 
		self:buildUpdateVersionPanel()
		
		self.worldScene:setEnterFromGamePlay(levelId)

		-- if showLadybugFlyLevel then
			-- self.worldScene:showLadybugFourStarGuid(showLadybugFlyLevel)
		-- end

		-- exit from main level, then dalybug maybe prompt
		-- if (not PlatformConfig:isQQPlatform()) then 
			-- if (tonumber(levelId) < 20000) then 
				-- self:starButtonLadybugPrompt()
			-- end
		-- end 

		-- 预装包的更新逻辑
		if (_G.isPrePackage) then
			if self.updateVersionButton and NewVersionUtil:hasNewVersion() then
				local updateInfo = UserManager.getInstance().updateInfo
				local curTips = ""
				if (updateInfo) then
					curTips = updateInfo.tips
				end
				local function popoutCallback( ... )
					CCUserDefault:sharedUserDefault():setStringForKey("game.updateInfo.tips",curTips)
					NewVersionUtil:cacheUpdateInfo()
					CCUserDefault:sharedUserDefault():flush()
				end

				if NewVersionUtil:hasPackageUpdate() and UpdatePackagePopoutAction:popupCondition() then
					HomeScenePopoutQueue:insert(UpdatePackagePopoutAction.new(self.updateVersionButton,popoutCallback))
				end
			end
		end



		self:runAction(CCCallFunc:create(function ( ... )
			if not PopoutManager:sharedInstance():haveWindowOnScreenWithoutCommonTip() then
				local WeekendFreeLotteryBBS = require "zoo.panel.WeekendFreeLotteryBBS"
				local dcReason
				if isQuit then
					dcReason = 1
					WeekendFreeLotteryBBS:tryPopout(dcReason)
				else
					local energyCount = 0
					if UserManager:getInstance().user then
						energyCount = UserManager:getInstance().user:getEnergy()
					end

					if energyCount <= 0 then
						dcReason = 2
						WeekendFreeLotteryBBS:tryPopout(dcReason)
					end
				end
			end
		end))
	end
end

function HomeScene:hideFishButton()
	if self.fishButton and not self.fishButton.isDisposed then
		self.fishButton:setVisible(false)
		self.fishButton.wrapper:setTouchEnabled(false)
		self.rightRegionLayoutBar:removeItem(self.fishButton, true)
		self.fishButton = nil
	end
end

function HomeScene:createInciteVedioButton()
	-- self.multiClickInviteBtn = false
	if not self.inciteVedioBtn then 
		local parentLayer = self.worldScene.iconButtonLayer
		local inciteVedioBtn	= InciteVedioButton:create()
		local function onInciteVedioBtnTapped(event)
			Notify:dispatch("QuitNextLevelModeEventhaiyo")
			InciteManager:showIncitePanel(EntranceType.kPassLevel)
		end

		parentLayer:addChild(inciteVedioBtn)
		local btnPos = HomeSceneButtonsManager.getInstance():getInciteButtonShowPos()

		if btnPos then 
			inciteVedioBtn:setPosition(ccp(btnPos.x, btnPos.y))
		end

		inciteVedioBtn.wrapper:addEventListener(DisplayEvents.kTouchTap, onInciteVedioBtnTapped)
		self.inciteVedioBtn = inciteVedioBtn
	else
		--刷新位置
		self:updateInciteVedioBtnPosition()
	end

	return self.inciteVedioBtn
end

function HomeScene:updateInciteVedioBtnPosition()
	if self.inciteVedioBtn then
		local btnPos = HomeSceneButtonsManager.getInstance():getInciteButtonShowPos()
		if btnPos then 
			self.inciteVedioBtn:setPosition(ccp(btnPos.x, btnPos.y))
		end	
	end
end

function HomeScene:updateInviteBtnPosition()
	if self.inviteFriendBtn then 
		local btnPos = HomeSceneButtonsManager.getInstance():getInviteButtonShowPos()
		if btnPos then 
			self.inviteFriendBtn:setPosition(ccp(btnPos.x, btnPos.y))
		end	
	end
end

function HomeScene:createModuleNoticeBtn()
	for i=1, #ModuleNoticeConfig do
		local cfg = ModuleNoticeConfig[i]
		if ModuleNoticeConfig.isVisible(cfg) then
			local inviteBtnLevelNode = HomeScene:sharedInstance().worldScene.levelToNode[cfg.unLockLevel]
			if inviteBtnLevelNode then 
				local btn = ModuleNoticeButton:create(cfg)
				local iconPos =inviteBtnLevelNode:getPosition()
				btn:setPosition(ccp(iconPos.x, iconPos.y))
				self.worldScene.iconButtonLayer:addChild(btn)

				if cfg.unLockLevel - UserManager.getInstance().user:getTopLevelId() <= 3 then
					btn:changeState("nearby")
				else
					btn:changeState("normal")
				end
			end
		end
	end
end

--飞的特效 和灰色的层的清除
function HomeScene:cleanupModuleNoticeBtnEffect()
	if self.flys_ModuleNoticeBtn then
		for key,value in ipairs( self.flys_ModuleNoticeBtn ) do
			print("fly.flyAddIndex ==" , value.flyAddIndex)
			value:removeFromParentAndCleanup(true)
		end
		self.flys_ModuleNoticeBtn = {} 
	end
	if self.masks_ModuleNoticeBtn  then
		for key,value in ipairs( self.masks_ModuleNoticeBtn ) do
			if not value.isDisposed then
				value:removeFromParentAndCleanup(true)
			end
		end
		self.masks_ModuleNoticeBtn = {} 
	end
end

function HomeScene:addChild_ModuleNoticeBtn_Fly_Mask( fly , mask)
	if self.flys_ModuleNoticeBtn == nil then
		self.flys_ModuleNoticeBtn={}
	end
	if self.masks_ModuleNoticeBtn == nil then
		self.masks_ModuleNoticeBtn={}
	end

	if fly then
		table.insert( self.flys_ModuleNoticeBtn ,fly  )
		self:addChild(fly)
	end
	if mask then
		table.insert( self.masks_ModuleNoticeBtn ,mask  )
		self:addChild(mask)
	end
end

function HomeScene:updateModuleNoticeBtn()

	local function flyFinishallback( fly ,mask )
		for key,value in ipairs( self.flys_ModuleNoticeBtn ) do
			if value == fly then
				table.remove(self.flys_ModuleNoticeBtn , key)
			end
		end
		for key,value in ipairs( self.masks_ModuleNoticeBtn ) do
			if mask == value then
				table.remove(self.masks_ModuleNoticeBtn , key)
			end
		end
	end 

	local topLevel = UserManager.getInstance().user:getTopLevelId()
	for i=1, #ModuleNoticeConfig do
		local cfg = ModuleNoticeConfig[i]

		if ModuleNoticeConfig.isVisible(cfg) then

			if cfg.btn ~= nil then
				if cfg.unLockLevel - topLevel <= 3 then
					cfg.btn:changeState("nearby")
				else
					cfg.btn:changeState("normal")
				end
			end
		else
			if cfg.btn ~= nil then
				Notify:dispatch("AutoPopoutEventWaitAction", _G[cfg.action], cfg.id)
				cfg.btn:removeSelf(flyFinishallback)
			end

			if (cfg.id == ModuleNoticeID.NEW_GIFT) and ( topLevel >=cfg.unLockLevel and topLevel <= 100 ) and (UserManager:getInstance().userExtend:getNewUserReward() ~= 2) then
   		 		if not cfg.btn then
   		 			Notify:dispatch("AutoPopoutEventWaitAction",  _G[cfg.action], cfg.id)
   		 		end
   		 		Notify:dispatch("AutoPopoutEventAwakenAction",  _G[cfg.action], {id = cfg.id, canForcePop = true})
			end
		end

		--[[
		if not ModuleNoticeConfig.isVisible(cfg) and cfg.btn ~= nil then
			cfg.btn:removeSelf()
		end
		]]
	end
end

function HomeScene:createMissionButton()
	if UserManager.getInstance().user:getTopLevelId() >= MissionLogic:getInstance():getMissionUserNeedLevel() 
		and not self.missionBtn then 
		self.missionBtn = MissionPanelLogic:getMissionBtn()
		self:addIcon(self.missionBtn)
		
	end
end

function HomeScene:addToBottomButtonBar(btn, index)
	self.bottomButtons = self.bottomButtons or {}
	if type(index) == "number" then
		if index < 1 then 
			assert(false)
			index = 1
		end
		if index > #self.bottomButtons then
			index = #self.bottomButtons+1
		end
	else
		index = #self.bottomButtons+1
	end
	if not table.exist(self.bottomButtons, btn) then
		table.insert(self.bottomButtons, index, btn)
		if self.bottomButtonsZOrder then
			self.iconLayer:addChildAt(btn, self.bottomButtonsZOrder)
		else
			self.iconLayer:addChild(btn)
			self.bottomButtonsZOrder = btn:getZOrder()
		end
		self:updateBottomButtonBar()
	end
end

function HomeScene:removeAllFromBottomButtonBar(cleanup)
	if not cleanup then 
		cleanup = false
	end
	local btns = self.bottomButtons or {}
	for k, v in pairs(btns) do
		v:removeFromParentAndCleanup(cleanup)
	end
	self.bottomButtons = {}
	self:updateBottomButtonBar()
end

function HomeScene:removeFromBottomButtonBar(btn, cleanup)
	if not btn then return end

	self.bottomButtons = self.bottomButtons or {}
	btn:removeFromParentAndCleanup(cleanup)

	local index = table.indexOf(self.bottomButtons, btn)
	if index then
		table.remove(self.bottomButtons, index)
		self:updateBottomButtonBar()
	end
end

function HomeScene:updateBottomButtonBar()
	local index = 1
	for i, btn in ipairs(self.bottomButtons) do
		if not btn.isDisposed and btn:getParent() then
			local btnAdjustX = btn._btnAdjustX or 0
			local btnAdjustY = btn._btnAdjustY or 0
			btn:setPosition(ccp((self.bottomButtonsOffsetX or 0) - 120 * (index-1) + btnAdjustX, (self.bottomButtonsOffsetY or 0) + btnAdjustY))
			index = index + 1
		end
	end
end

function HomeScene:buildFcButton()
	if PlatformConfig:isPlayDemo() then
		return
	end
	if __IOS and MaintenanceManager:getInstance():isInReview() then
		return
	end
	if false and PlatformConfig:isQQPlatform() then
		if MaintenanceManager:getInstance():isEnabled("QQForumAvailable", true) 
				and _G.sns_token and _G.sns_token.authorType == PlatformAuthEnum.kQQ then
			local fcButton = QQForumButton:create()
	        fcButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
	        	Notify:dispatch("QuitNextLevelModeEvent")
	            local ysdkProxy = luajava.bindClass("com.happyelements.android.animal.ysdklibrary.YYBYsdkProxy"):getInstance()
	            ysdkProxy:openPerformFeature("bbs")
	        end)
	        fcButton._btnAdjustX = 2
	        fcButton._btnAdjustY = 4
	        self:addIcon(fcButton)
	    end
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then 
		if MaintenanceManager:getInstance():isEnabled("OppoForumAvailable", false) then
			local fcButton = OppoForumButton:create()
	        fcButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
	        	Notify:dispatch("QuitNextLevelModeEvent")
	            OppoLaunchManager.getInstance():launchForum()

				UserManager:getInstance():updateCommunityMessageVersion()	            
	        end)
	        -- fcButton._btnAdjustX = 2
	        -- fcButton._btnAdjustY = 4
	        self:addIcon(fcButton)
	    end
	elseif FAQ:isButtonVisible() then
		if (FAQ:useNewFAQ() and FAQ:showNewFAQButtonOutside()) then
			require 'zoo.scenes.component.HomeScene.iconButtons.FAQButton'
		    self.fcButton = FAQButton:createButton(false)
		    self.fcButton._btnAdjustY = 0
		    self.fcButton._btnAdjustX = 9
		    -- self:addToBottomButtonBar(self.fcButton)
		    self:addIcon(self.fcButton)
		end
	end
end

function HomeScene:tryRefreshFcButton( ... )
	if self.fcButton and not self.fcButton.isDisposed then
		self.fcButton:refresh()
	end
end

function HomeScene:buildFriendButton()
	self.friendButton = FriendButton:create()
	self.friendButton._btnAdjustY = 0
    self.friendButton._btnAdjustX = 0
	self:addIcon(self.friendButton)
	self.friendButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
		if self.isDisposed then return end
		local dcData = {}
		dcData.category = "add_friend"
		dcData.sub_category = "click_partner_icon"
		DcUtil:log(AcType.kUserTrack, dcData, true)
		Notify:dispatch("QuitNextLevelModeEvent")
		self:popoutFriendRankingPanel()
	end)
end

function HomeScene:popoutFriendRankingPanel(event)
	self.friendButton.wrapper:setTouchEnabled(false)
	local function __reset()
		-- note: this callback maybe delayed, when home scene is runnning again
		-- becasue this panel will push a new scene.
		if self.friendButton then self.friendButton.wrapper:setTouchEnabled(true) end
	end
--	self:runAction(CCSequence:createWithTwoActions(
--	               CCDelayTime:create(0.2), CCCallFunc:create(__reset)
--	               ))

    createFriendRankingPanel( nil, __reset )
end

function HomeScene:createAndShowFruitTreeButton()
	local function showFruitTreeButton(evt, noTutor)
		local user = UserManager:getInstance():getUserRef()
		if user and user:getTopLevelId() >= 16 then
			self:removeEventListener(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, showFruitTreeButton)
            -- 创建时强制显示果树图标，以确保视频广告果子的显示，关闭金银果树界面后再行判断是否隐藏果树图标
        	if HomeSceneButtonsManager.getInstance():shouldShowFruitBtnOnHomeScene() then
				self:buildHomeSceneFruitBtn()
			else
				self:buildHiddenFruitBtn()
			end
		end
	end
	local user = UserManager:getInstance():getUserRef()
	if user and user:getTopLevelId() >= 16 then
		showFruitTreeButton(nil, true)
	else
		self:addEventListener(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, showFruitTreeButton)
	end
end

function HomeScene:updateCoin()
	self:checkDataChange()
	if self.coinButton then
		self.coinButton:updateView()
	end
end

function HomeScene:createXFPreheatButton( ... )
	if self.xfPreheatButton then return end

	local XFLogic = require 'zoo.panel.xfRank.XFLogic'


	self.xfPreheatButton = XFPreheatButton:create()
	self:addIcon(self.xfPreheatButton)

	local function onBtnTapped()

		if XFLogic:isPreheadEnabled() then
			require('zoo.panel.xfRank.XFPreheatPanel'):create():popout()
		else
			XFLogic:popoutMainPanel()
		end

	end
	self.xfPreheatButton.wrapper:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)

	if XFLogic:isPreheadEnabled() then
		XFLogic:writeCache('preserve.preheat.button', true)
	end

end

function HomeScene:createRankRaceButton()
	if PlatformConfig:isPlayDemo() then return end

	if self.rankRaceButton then return end

	local function _onLoadedData( ... )
		self.rankRaceButton = RankRaceButton:create()
		self:addIcon(self.rankRaceButton)

		local function onBtnTapped()
			RankRaceMgr.getInstance():openMainPanel()
		end
		self.rankRaceButton.wrapper:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)
	end

	RankRaceMgr.getInstance():loadServerDataInBackground(_onLoadedData)
end

function HomeScene:onDefaultPaymentTypeAutoChange()
	if __ANDROID then
		local function callback()
			local currentDefaultPayment = PaymentManager.getInstance():getDefaultPayment()
			local paymentBeforeAutoChange = PaymentManager.getInstance():getPaymentBeforeAutoChange()

			PaymentManager.getInstance():setPaymentAutoChangeFlag(false)
			PaymentManager.getInstance():setPaymentBeforeAutoChange(nil)
			
			if paymentBeforeAutoChange and paymentBeforeAutoChange == currentDefaultPayment then 
				return 
			end
			require "zoo.payment.DefaultPaymentChangePanel"
			local panel = DefaultPaymentChangePanel:create(currentDefaultPayment)
			panel:popout()
		end
		self:runAction(CCCallFunc:create(callback))
	end
end

function HomeScene:showMessageIconBear()
end

function HomeScene:hideMessageIconBear()
end

function HomeScene:showDengchaoEnerygy()
	if self.messageButton and self.messageButton.isDengchaoMode then
		self.messageButton:showDengchao(true)		
	end
end

function HomeScene:showAFHIcon(isVisible)
	if self.messageButton and self.messageButton:is(MessageButton) then
		self.messageButton:updateView()
	end
end

function HomeScene:playDengchaoEnergyAnim()
	if _G.isLocalDevelopMode then printx(0, 'HomeScene:playDengchaoEnergyAnim()') end
	if self.messageButton and self.messageButton.isDengchaoMode then
		self:runAction(CCCallFunc:create(
			function () 
				if self.messageButton and self.messageButton.isDengchaoMode then
					self.messageButton:playDengchaoAnim() 
				end
			end))		
	end
end

function HomeScene:hideDengchaoEnergyAnim()
	if self.messageButton and self.messageButton.isDengchaoMode then
		self:runAction(CCCallFunc:create(
			function () 
				if self.messageButton.isDengchaoMode then
	                self.messageButton:playDengchaoFadeOutAnim()
	            end
			end))		
	end
end

function HomeScene:buildCollectButton()
	if self.hasBuildCollectButton then
		return
	end
	self.hasBuildCollectButton = true

	if not CDKeyManager:getInstance():getPhysicalReward() then
		return
	end

	local function remove()
		self:removeIcon(self.collectInfoButton)
		CDKeyManager:getInstance():removePhysicalReward()
		self.collectInfoButton = nil
	end

	self.collectInfoButton = CollectInfoButton:create(remove)
	self:addIcon(self.collectInfoButton)
end


function HomeScene:buildRegionLayoutBar()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()	

	local barHeightDelta = 90

	local layoutBarWidth = visibleSize.width * self.iconLayerScale
	local layoutBarHeight = visibleSize.height * self.iconLayerScale - barHeightDelta

	self.leftRegionLayoutBar = LayoutBar:create(LayoutBar.Direction.TOP2BOTTOM)
	self.leftRegionLayoutBar:setPositionX(visibleOrigin.x + 70)
	self.leftRegionLayoutBar:setPositionY(visibleOrigin.y + layoutBarHeight)
	self.iconLayer:addChild(self.leftRegionLayoutBar)

	self.rightRegionLayoutBar = LayoutBar:create(LayoutBar.Direction.TOP2BOTTOM)
	self.rightRegionLayoutBar:setPositionX(visibleOrigin.x + layoutBarWidth - 70)
	self.rightRegionLayoutBar:setPositionY(visibleOrigin.y + layoutBarHeight)
	self.iconLayer:addChild(self.rightRegionLayoutBar)

	self.rightBottomRegionLayoutBar = LayoutBar:create(LayoutBar.Direction.BOTTOM2TOP)
	self.rightBottomRegionLayoutBar:setPositionX(visibleOrigin.x + layoutBarWidth - 70)
	self.rightBottomRegionLayoutBar:setPositionY(visibleOrigin.y + 140)
	self.iconLayer:addChild(self.rightBottomRegionLayoutBar)

	if SHOWDEBUGLINE then
		self:showDebugIconLine()
	end
end

function HomeScene:showDebugIconLine()

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()	

	function line( p1,p2 )
		local points = CCPointsArray:create(2)
		points:add(ccp(p1.x+visibleOrigin.x,p1.y+visibleOrigin.y))
		points:add(ccp(p2.x+visibleOrigin.x,p2.y+visibleOrigin.y))

		local shape = CCPolygonShape:create(points)
		shape:setLineWidth(1)

		self:addChild(CocosObject.new(shape))
	end

	local w = visibleSize.width
	local h = visibleSize.height

	if self.iconLayerScale==1 then
		line(ccp(70,0),ccp(70,h))
		line(ccp(w-70,0),ccp(w-70,h))

		local y = h-263
		for i=1,5 do
			line(ccp(0,y),ccp(w,y))
			line(ccp(0,y-96),ccp(w,y-96))

			y = y-96-20 
		end

		local y = 140
		for i=1,1 do
			line(ccp(0,y),ccp(w,y))
			line(ccp(0,y+96),ccp(w,y+96))

			y = y+96+20 
		end	

		line(ccp(0,70+96/2),ccp(w,70+96/2))
		line(ccp(0,70),ccp(w,70))
		line(ccp(0,70-96/2),ccp(w,70-96/2))
	else
		local side = 49
		line(ccp(side,0),ccp(side,h))
		line(ccp(w-side,0),ccp(w-side,h))

		local y = h-184
		for i=1,5 do
			line(ccp(0,y),ccp(w,y))
			line(ccp(0,y-67),ccp(w,y-67))

			y = y-67-14
		end

		line(ccp(0,70),ccp(w,70))
	end
end

function HomeScene:testIcon( ... )

	self:addIcon(CollectInfoButton:create())
	self:addIcon(OneYuanShopButton:create())
	self:addIcon(MissionButton:create())

	self:addIcon(AliKfPromoButton:create())

end

function HomeScene:addIcon(iconInstance, anchorIsCenter, suppressFlyAnimation)
	if not iconInstance.indexKey or not iconInstance.showPriority or not iconInstance.homeSceneRegion then
		printx(3, "你的Icon有问题")
		printx(3, debug.traceback()) debug.debug()
		return
	end

	if IconButtonPool:getBtnByKey(iconInstance.indexKey) then
		return
	end

	-- 提前加到pool当中，防止在动画完之前，有代码调用removeIcon
	local index = IconButtonPool:getInsertionIndex(iconInstance.showPriority, iconInstance.homeSceneRegion)
	IconButtonPool:add(iconInstance, anchorIsCenter)
	
	local function doAddIconAndFresh()
		self:relayoutIcons(iconInstance.homeSceneRegion)
	end

	local side = iconInstance.homeSceneRegion
	if side == IconButtonBasePos.LEFT or side == IconButtonBasePos.RIGHT then
		local btnCount, maxChildren, region, btns
		if side == IconButtonBasePos.LEFT then
			maxChildren = MAX_LEFT_ICON_COUNT
			region = self.leftRegionLayoutBar
		else
			maxChildren = MAX_RIGHT_ICON_COUNT
			region = self.rightRegionLayoutBar
		end
		-- btns = IconButtonPool:getHomeSceneBtnsBySide(side)
		-- btnCount = #btns
		btnCount = region:getChildrenCount()
		-- for k, v in pairs(btns) do
		-- 	printx(3, '--------------btns---------', v.indexKey, v.homeSceneRegion)
		-- end
		-- printx(3, '---------debug-----------', iconInstance.indexKey, btnCount, maxChildren, side)
		if btnCount >= maxChildren
		 -- and not IconButtonPool:isAlwaysHideBtn(iconInstance) 
		 and not suppressFlyAnimation then --需要动画了

			-- printx(3, '===========index========', iconInstance.indexKey, index)
			region:addItemAt(iconInstance, index)
			local flyIconInstance
			if index <= maxChildren then
				flyIconInstance = region:getItemAtIndex(maxChildren + 1)
			else
				flyIconInstance = iconInstance
			end

			if not flyIconInstance then 
				if isLocalDevelopMode then
					printx(3, '#region.addedChildren', #region.addedChildren)
					for k, v in pairs(region.addedChildren) do
						printx(3, v.indexKey)
					end
					printx(3, 'flyIconInstance is nil ' .. tostring(index) .. ' ' .. iconInstance.indexKey)
					debug.debug()
				end
				doAddIconAndFresh()
				return
			end

			-- printx(3, '=======indexKey======', flyIconInstance.indexKey)
			local function beforeFly()

			end
			local function afterFly()
				flyIconInstance.__isPlayingHomeSceneFlyAnim = false
				region:removeItem(flyIconInstance, false)
				self.flyAnimCount = self.flyAnimCount - 1
				if self.flyAnimCount <= 0 then
					self.flyAnimCount = 0
				end
				-- printx(3, 'ZZZZZZZZZ afterFly',self.flyAnimCount)
				doAddIconAndFresh()
			end
			-- debug.debug()
			-- 防止同一个icon重复飞
			if not flyIconInstance.__isPlayingHomeSceneFlyAnim then
				self.flyAnimCount = self.flyAnimCount + 1
				flyIconInstance.__isPlayingHomeSceneFlyAnim = true
				-- printx(3, 'OOOOOOOOOOO ', self.flyAnimCount)
				self.buttonGroupBar:flyFromLayoutBar(flyIconInstance, 
					beforeFly, afterFly)
			-- else
			-- 	print('XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
			end
		else
			doAddIconAndFresh()
		end
	else
		doAddIconAndFresh()
	end
end

function HomeScene:__relayoutSide(side)
	local function relayoutSide(side)
		local btns = IconButtonPool:getBtns(side)

		if side == IconButtonBasePos.ALWAYS_HIDE then
			for k, v in pairs(btns) do
				HomeSceneButtonsManager:getInstance():addBtn(v, IconButtonPool:getBtnAnchor(v))
				IconButtonPool:setBtnState(v, IconBtnShowState.HIDE_N_FOLD)
			end
		elseif side == IconButtonBasePos.BOTTOM then
			for k, v in pairs(btns) do
				if IconButtonPool:getBtnState(v) == IconBtnShowState.HIDE_N_FOLD 
				or IconButtonPool:isAlwaysHideBtn(v) then
					HomeSceneButtonsManager:getInstance():addBtn(v, IconButtonPool:getBtnAnchor(v))
				else
					self:addToBottomButtonBar(v)
					IconButtonPool:setBtnState(v, IconBtnShowState.ON_HOMESCENE)
				end
			end
			self:updateBottomButtonBar()
		else
			local region, maxChildren
			if side == IconButtonBasePos.LEFT then
				region = self.leftRegionLayoutBar
				maxChildren = MAX_LEFT_ICON_COUNT
			elseif side == IconButtonBasePos.RIGHT then
				region = self.rightRegionLayoutBar
				maxChildren = MAX_RIGHT_ICON_COUNT
			end

			for i=1, #btns do
				if i <= maxChildren and not IconButtonPool:isAlwaysHideBtn(btns[i]) then
					-- printx(3, 'region:addItem', btns[i].indexKey)
					region:addItem(btns[i])
					if IconButtonPool:getBtnState(btns[i]) ~= IconBtnShowState.ON_HOMESCENE then
						DcUtil:UserTrack({category='icon', sub_category='change_icon_location', t1=btns[i].indexKey, t3=1})
					end

					IconButtonPool:setBtnState(btns[i], IconBtnShowState.ON_HOMESCENE)
					if btns[i].wrapper and not btns[i].wrapper:isTouchEnabled() then
						btns[i].wrapper:setTouchEnabled(true, 0, true)
					end
				else
					-- printx(3, 'HomeSceneButtonsManager:addBtn', btns[i].indexKey)
					HomeSceneButtonsManager:getInstance():addBtn(btns[i], IconButtonPool:getBtnAnchor(btns[i]))
					if IconButtonPool:getBtnState(btns[i]) ~= IconBtnShowState.HIDE_N_FOLD then
						DcUtil:UserTrack({category='icon', sub_category='change_icon_location', t1=btns[i].indexKey, t2=1})
					end
					IconButtonPool:setBtnState(btns[i], IconBtnShowState.HIDE_N_FOLD)
				end
			end
		end
	end

	local allSide = false
	if not side then allSide = true end
	if side == IconButtonBasePos.LEFT or allSide then
		self.leftRegionLayoutBar:removeAllItems(false)
		HomeSceneButtonsManager:getInstance():removeBtnsBySide(IconButtonBasePos.LEFT)
		-- printx(3, 'left', #HomeSceneButtonsManager:getInstance().btns)
		relayoutSide(IconButtonBasePos.LEFT)
	end

	if side == IconButtonBasePos.RIGHT or allSide then
		self.rightRegionLayoutBar:removeAllItems(false)
		HomeSceneButtonsManager:getInstance():removeBtnsBySide(IconButtonBasePos.RIGHT)
		-- printx(3, 'right', #HomeSceneButtonsManager:getInstance().btns)
		relayoutSide(IconButtonBasePos.RIGHT)
	end

	if side == IconButtonBasePos.BOTTOM or allSide then
		self:removeAllFromBottomButtonBar(false)
		HomeSceneButtonsManager:getInstance():removeBtnsBySide(IconButtonBasePos.BOTTOM)
		-- printx(3, 'bottom', #HomeSceneButtonsManager:getInstance().btns)
		relayoutSide(IconButtonBasePos.BOTTOM)
	end

	if side == IconButtonBasePos.ALWAYS_HIDE or allSide then
		HomeSceneButtonsManager:getInstance():removeBtnsBySide(IconButtonBasePos.ALWAYS_HIDE)
		-- printx(3, 'hide', #HomeSceneButtonsManager:getInstance().btns)
		relayoutSide(IconButtonBasePos.ALWAYS_HIDE)
	end
end

function HomeScene:relayoutIcons(side)
	local function initRefreshIconSides()
		self.refreshIconSides = {
			[IconButtonBasePos.LEFT] = false,
			[IconButtonBasePos.RIGHT] = false,
			[IconButtonBasePos.BOTTOM] = false,
			[IconButtonBasePos.ALWAYS_HIDE] = false,
		}
	end
	if not self.refreshIconSides then
		initRefreshIconSides()
	end
	-- 每当加一个icon，当前的这个side就需要刷新
	self.refreshIconSides[side] = true

	if self.flyAnimCount > 0 then
		return
	end
	local function doRelayout()
		for k, v in pairs(self.refreshIconSides) do
			if v == true then
				self:__relayoutSide(k)
			end
		end
		initRefreshIconSides()	
		if self.buttonGroupBar and not self.buttonGroupBar.isOpen then
			self.buttonGroupBar:forceDisable(false)
		end
	end
	if self.buttonGroupBar and self.buttonGroupBar.isOpen then
		self.buttonGroupBar:forceDisable(true)
		self.buttonGroupBar:hideButtons(doRelayout, true)
	else
		doRelayout()
	end
end

function HomeScene:onIconBtnFinishJob(iconInstance)
	if IconButtonPool:isBtnFinishedJob(iconInstance) then
		return
	end
	IconButtonPool:onBtnFinishJob(iconInstance)
	if not iconInstance.showHideOption then
		return
	end

	if iconInstance.showHideOption == ShowHideOptions.DO_NOTHING then
		return 
	end

	if iconInstance.showHideOption == ShowHideOptions.HIDE then
		local function doAddIconAndFresh()
			IconButtonPool:addAlwaysHideBtn(iconInstance)
			IconButtonPool:setBtnState(iconInstance, IconBtnShowState.HIDE_N_FOLD)
			self:relayoutIcons(iconInstance.homeSceneRegion)
		end
		local function beforeFly()

		end
		local function afterFly()
			local region 
			if iconInstance.homeSceneRegion == IconButtonBasePos.LEFT then
				region = self.leftRegionLayoutBar
			elseif iconInstance.homeSceneRegion == IconButtonBasePos.RIGHT then
				region = self.rightRegionLayoutBar
			end
			region:removeItem(iconInstance, false)
			self.flyAnimCount = self.flyAnimCount - 1
			if self.flyAnimCount <= 0 then
				self.flyAnimCount = 0
			end
			doAddIconAndFresh()
		end
		-- 左右才飞
		-- 下方的暂时不管，毕竟就一个飞，而且自己写了自己的飞的代码了
		if iconInstance.homeSceneRegion == IconButtonBasePos.LEFT or iconInstance.homeSceneRegion == IconButtonBasePos.RIGHT then
			self.flyAnimCount = self.flyAnimCount + 1
			self.buttonGroupBar:flyFromLayoutBar(iconInstance, 
				beforeFly, afterFly)
		else
			doAddIconAndFresh()
		end
		-- debug.debug()
		
		return
	end

	if iconInstance.showHideOption == ShowHideOptions.REMOVE then
		self:removeIcon(iconInstance)
		return
	end
end

function HomeScene:removeIcon(iconInstance, cleanup)
	-- printx(3, 'removeIcon', iconInstance.indexKey)
	-- p(debug.traceback()) debug.debug()
	local state = IconButtonPool:getBtnState(iconInstance)
	IconButtonPool:remove(iconInstance)
	if state == IconBtnShowState.ON_HOMESCENE then
		if iconInstance.homeSceneRegion == IconButtonBasePos.LEFT then
			self.leftRegionLayoutBar:removeItem(iconInstance, cleanup)
		elseif iconInstance.homeSceneRegion == IconButtonBasePos.RIGHT then
			self.rightRegionLayoutBar:removeItem(iconInstance, cleanup)
		end
	elseif state == IconBtnShowState.HIDE_N_FOLD then
		HomeSceneButtonsManager:getInstance():removeBtnByRef(iconInstance)
		if cleanup then
			if self.buttonGroupBar:isVisible() then
				self.buttonGroupBar:hideButtons(
					function() 
						if iconInstance and not iconInstance.isDisposed then
							iconInstance:removeFromParentAndCleanup(true)
						end
					end)
			end
		end
	end
	
end


function HomeScene:removeIconByIndexKey(key, cleanup)
	local btn = IconButtonPool:getBtnByKey(key)
	if btn then
		self:removeIcon(btn, cleanup)
	end
end

function HomeScene:addHiddenMarkBtn()
	if not self.hiddenMarkBtn then
		local btn = self.buttonGroupBar:createButton(HomeSceneButtonType.kMark)
		IconButtonPool:setBtnState(btn, IconBtnShowState.HIDE_N_FOLD)
		IconButtonPool:addAlwaysHideBtn(btn)
		self:addIcon(btn, false, true)
		self.hiddenMarkBtn = btn
	end
end

function HomeScene:addHiddenFruitBtn()
	if not self.hiddenFruitTreeBtn then
		local btn = self.buttonGroupBar:createButton(HomeSceneButtonType.kTree)
		IconButtonPool:setBtnState(btn, IconBtnShowState.HIDE_N_FOLD)
		IconButtonPool:addAlwaysHideBtn(btn)
		self:addIcon(btn, false, true)
		self.hiddenFruitTreeBtn = btn
	end
end
function HomeScene:onFruitTreeBtnTap_TouchTap(  )
	self:onFruitTreeBtnTap( )
end

function HomeScene:onFruitTreeBtnTap(successCallback, failCallback  )
	DcUtil:iconClick("click_fruiter_icon")

	local function fruiteSceneClose( evt )
		if not HomeSceneButtonsManager.getInstance():shouldShowFruitBtnOnHomeScene() then
			if self.fruitTreeBtn and self.fruitTreeBtn:getParent() ~= nil then
				local btn = FruitTreeButton:create()
				local pos = self.fruitTreeBtn:getParent():convertToWorldSpace(self.fruitTreeBtn:getPosition())
				local function beforeFly()
					if not self.fruitTreeBtn then return end
					self.fruitTreeBtn:setVisible(false)
					self.fruitTreeBtn.wrapper:setTouchEnabled(false)
					self.hideAndShowBtn:setEnable(false)
				end
				local function afterFly()
					local function addBtnToGroup()
						local btn = self.buttonGroupBar:createButton(HomeSceneButtonType.kTree)
						IconButtonPool:setBtnState(btn, IconBtnShowState.HIDE_N_FOLD)
						IconButtonPool:addAlwaysHideBtn(btn)
						self:addIcon(btn, true, true) -- 直接进去，不播动画
					end
					if not self.fruitTreeBtn then 
						addBtnToGroup()
						return  
					end
					self.hideAndShowBtn:playAni(function ()
						self.hideAndShowBtn:setEnable(true)
						Notify:dispatch("AutoPopoutEventAwakenAction", IconCollectGuidePopoutAction)
					end)
					IconButtonPool:remove(self.fruitTreeBtn)
					self:removeFromBottomButtonBar(self.fruitTreeBtn, true)
					self.fruitTreeBtn = nil
					addBtnToGroup()
				end
				HomeSceneButtonsManager.getInstance():flyToBtnGroupBar(btn, pos, beforeFly, afterFly, true)
			else
				assert(false, "fruitTreeBtn has been removed from parent?")
			end
		end

		self:runAction(CCCallFunc:create(function ( ... )
			ModuleNoticeButton:tryPopoutStartGamePanel()
		end))
	end

	local function success()
		if self.isDisposed then return end
		if successCallback then successCallback() end
		local function fruitTreeSceneWillPopout()
			local function pushNewScene()
			if not self.fruitTreeBtn then return end -- 金银果树按钮可能被移动到了更多按钮内
				self.fruitTreeBtn.wrapper:setTouchEnabled(false)
				self:runAction(CCCallFunc:create(function()
					local scene = FruitTreeScene:create()
					scene:addEventListener(kFruitTreeEvents.kExit, fruiteSceneClose)
					Director:sharedDirector():pushScene(scene)
					
					if self.fruitTreeBtn then
						self.fruitTreeBtn.wrapper:setTouchEnabled(true, 0, true)
					end
				end))
			end
			AsyncLoader:getInstance():waitingForLoadComplete(pushNewScene)
		end 
	    fruitTreeSceneWillPopout()
	end

	local function fail(err, skipTip)
		if self.isDisposed then return end
		if failCallback then failCallback() end

		if not skipTip then CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err))) end
	end

	local function updateInfo()
		FruitTreeSceneLogic:sharedInstance():updateInfo(success, fail)
	end
	local function onLoginFail()
		fail(-2, true)
	end

	RequireNetworkAlert:callFuncWithLogged(updateInfo, onLoginFail)
end

function HomeScene:buildHomeSceneFruitBtn()
	if self.hiddenFruitTreeBtn then
		self:removeIcon(self.hiddenFruitTreeBtn, true)
		self.hiddenFruitTreeBtn = nil
	end
	if not self.fruitTreeBtn then
		local btn = FruitTreeButton:create()

		local function onFruitTreeBtnTap(successCallback, failCallback)
			self:onFruitTreeBtnTap(successCallback, failCallback)
		end

		btn.wrapper:addEventListener(DisplayEvents.kTouchTap, function ( ... )
			self:onFruitTreeBtnTap_TouchTap()
		end)
		btn.onClick = onFruitTreeBtnTap
		IconButtonPool:setBtnState(btn, IconButtonBasePos.BOTTOM)
		self:addIcon(btn, true)
		self.fruitTreeBtn = btn
	end
end

function HomeScene:buildHiddenFruitBtn()
	if self.fruitTreeBtn then
		self:removeIcon(self.fruitTreeBtn, true)
		self.fruitTreeBtn = nil
	end
	if not self.hiddenFruitTreeBtn then
		local btn = self.buttonGroupBar:createButton(HomeSceneButtonType.kTree)
		IconButtonPool:setBtnState(btn, IconButtonBasePos.HIDE_N_FOLD)
		IconButtonPool:addAlwaysHideBtn(btn)
		self:addIcon(btn, true)
		self.hiddenFruitTreeBtn = btn
	end
end

function HomeScene:buildHiddenMarkBtn()
	if PlatformConfig:isPlayDemo() then return end
	if self.markButton then
		self:removeIcon(self.markButton, true)
		self.markButton = nil
	end
	if not self.hiddenMarkBtn then
		self:addHiddenMarkBtn()
	end
end

function HomeScene:removeHomeSceneUserCallBackButton()
	if self.userCallBackButton then
		self:removeIcon(self.userCallBackButton, true)
		self.userCallBackButton = nil
	end
end

function HomeScene:buildHomeSceneUserCallBackButton()
	if self.userCallBackButton then
		self:removeIcon(self.userCallBackButton)
		self.userCallBackButton = nil
	end
	if not self.userCallBackButton then
		local function onuserCallBackButtonTapped(evt)
			require("zoo.localActivity.UserCallBackTest.src.Start")(true,nil)
		end
		--主动点击了签到按钮
		local userCallBackButton = UserCallBackButton:create()
		userCallBackButton:setTipPosition(IconButtonBasePos.LEFT)
		userCallBackButton.wrapper:ad(DisplayEvents.kTouchTap, onuserCallBackButtonTapped)
		self:addIcon(userCallBackButton)
		IconButtonPool:setBtnState(userCallBackButton, IconBtnShowState.ON_HOMESCENE)
		self.userCallBackButton = userCallBackButton
		local userCallbackActInfo = UserManager:getInstance().userCallbackActInfo
		if userCallbackActInfo then
			local rewardFlag = userCallbackActInfo.rewardFlag or 0
			userCallBackButton:updateReward(rewardFlag > 0)
		end
	end
end

function HomeScene:buildHomeSceneStarRewardBtn()
	if PlatformConfig:isPlayDemo() then return end
	if not self.starRewardButton then
		local starRewardButton = StarRewardButton:create()
		IconButtonPool:setBtnState(starRewardButton, IconBtnShowState.ON_HOMESCENE)
		starRewardButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function() 
			self:onStarRewardBtnTapped() 
		end)
		self:addIcon(starRewardButton)
		self.starRewardButton = starRewardButton
	end
end

function HomeScene:onStarRewardBtnTapped()
	Notify:dispatch("QuitNextLevelModeEvent")
	DcUtil:UserTrack({
		category = "ui",
		sub_category = "click_star_reward_button",
	}, true)

	-- 2016-03-02 new entry for star achevement and reward
	local function popoutPanel()
		local panel = StarAchievenmentPanel_New:create()
		panel:popout()
	end
	AsyncLoader:getInstance():waitingForLoadComplete(popoutPanel)
end

function HomeScene:buildHomeSceneMarkBtn()
	if PlatformConfig:isPlayDemo() then return end

	if self.hiddenMarkBtn then
		self:removeIcon(self.hiddenMarkBtn)
		self.hiddenMarkBtn = nil
	end
	if not self.markButton then
		local function markBtnClick(evt)
			self:tryPopoutMarkPanel(false, nil, 2)
		end
		--主动点击了签到按钮
		local function onMarkButtonTapped(evt)
			DcUtil:iconClick("click_sign_icon")
			self:tryPopoutMarkPanel(true, nil, 3)
		end
		local markButton = MarkButton:create()
		markButton:setTipPosition(IconButtonBasePos.RIGHT)

		markButton.wrapper:ad(DisplayEvents.kTouchTap, onMarkButtonTapped)
		markButton.click = markBtnClick
		self:addIcon(markButton)
		IconButtonPool:setBtnState(markButton, IconBtnShowState.ON_HOMESCENE)
		self.markButton = markButton
	end
end

function HomeScene:buildHomeSceneMessageBtn()
	if PlatformConfig:isPlayDemo() then return end

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local topScreenPosY 	= visibleOrigin.y + visibleSize.height*self.iconLayerScale
	local rightScreenPosX	= visibleOrigin.x + visibleSize.width*self.iconLayerScale

	if self.hiddenMessageBtn then
		self:removeIcon(self.hiddenMessageBtn)
		self.hiddenMessageBtn = nil
	end

	if not self.messageButton then
	    self.messageButton = MessageButton:create()
        self:addIcon(self.messageButton)
        IconButtonPool:setBtnState(self.messageButton, IconBtnShowState.ON_HOMESCENE)

		self.messageButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function() 
			self:onMessageBtnTapped() 
			end)
	end
end

function HomeScene:buildHiddenMessageBtn()
	if PlatformConfig:isPlayDemo() then return end
	if self.messageButton then
		self:removeIcon(self.messageButton, true)
		self.messageButton = nil
	end
	if not self.hiddenMessageBtn then
		local btn = self.buttonGroupBar:createButton(HomeSceneButtonType.kMail)
		IconButtonPool:setBtnState(btn, IconBtnShowState.HIDE_N_FOLD)
		IconButtonPool:addAlwaysHideBtn(btn)
		self:addIcon(btn, false, true)
		self.hiddenMessageBtn = btn
	end
end

function HomeScene:onMessageBtnTapped(gotoPageName, closeCallback)
	Notify:dispatch("QuitNextLevelModeEvent")
	
	DcUtil:iconClick("click_letters_icon")
	local function message_callback(result, evt)
        if result == "success" then
            local function GetFriendInfoSucess()
			    if self.messageButton then
				    self.messageButton:updateView()
			    end
		
			    -- ask for help
			    local scene = MessageCenterScene:create()
			    Director:sharedDirector():pushScene(scene)
			    if gotoPageName then
				    local panel = scene.panel
				    panel.closeCallback = closeCallback
				    panel:gotoPage(gotoPageName)

			    elseif AskForHelpManager:getInstance():hasNewMessageFlag() then
				    AskForHelpManager:getInstance():setNewMessageFlag(false)
				    local panel = scene.panel
				    panel.closeCallback = closeCallback
				    panel:gotoPage("askforhelp")
				    self:showAFHIcon(false)
			    end
            end

            if self.worldScene.friendsInitiated then
                GetFriendInfoSucess()
            else
                self.worldScene:sendFriendHttpEx( GetFriendInfoSucess, GetFriendInfoSucess, GetFriendInfoSucess ) 
            end
		else
			local message = ''
			local err_code = tonumber(evt.data)
			if err_code then message = Localization:getInstance():getText("error.tip."..err_code) end
			CommonTip:showTip(message, "negative")
		end
	end
	FreegiftManager:sharedInstance():update(true, message_callback)
end

-- iOS提审时需要隐藏兑换按钮，为此把信件icon挪到了左下角按钮里
function HomeScene:shouldHideMessageBtnInReview()
    if __IOS and MaintenanceManager:getInstance():isInReview() then
        return true
    end
    return false
end

function HomeScene:shouldBuildHomeSceneMessageBtn()
	if self:shouldHideMessageBtnInReview() then
		return false
	end
	return (not PrepackageUtil:isPreNoNetWork()) and (UserManager:getInstance().requestNum > 0 or NewVersionUtil:hasUpdateReward())
end

function HomeScene:initMessageBtnLogic()
	------------------------------
	-- Message Button
	-- -------------------------
	local function initMessageButton()
		if self:shouldBuildHomeSceneMessageBtn() then
			self:buildHomeSceneMessageBtn()
		else
			self:buildHiddenMessageBtn()
		end
	end
	GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kFriendsSynced, initMessageButton)
	
	local function onMessageCountUpdate()
		local count = UserManager:getInstance().requestNum
		if self:shouldHideMessageBtnInReview() or count <= 0 then
			if self.messageButton and self.messageButton:getParent() then
				local btn = MessageButton:create()

				local pos = self.messageButton:getParent():convertToWorldSpace(self.messageButton:getPosition())
				local function beforeFly()
					if not self.messageButton then return end
					self.messageButton:setVisible(false)
					self.messageButton.wrapper:setTouchEnabled(false)
					self.hideAndShowBtn:setEnable(false)
				end
				local function afterFly()
					if not self.messageButton then return end
					self.hideAndShowBtn:playAni(function ()
						self.hideAndShowBtn:setEnable(true)
						Notify:dispatch("AutoPopoutEventAwakenAction", IconCollectGuidePopoutAction)
					end)
					self:buildHiddenMessageBtn()
				end
				HomeSceneButtonsManager.getInstance():flyToBtnGroupBar(btn, pos, beforeFly, afterFly, false)
			else
				self:buildHiddenMessageBtn()
			end
		else
			if self.messageButton then 
				self.messageButton:updateView()
			else
				self:buildHomeSceneMessageBtn()
			end
		end
	end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kMessageCenterUpdate, onMessageCountUpdate)
end

function HomeScene:showAskForHelpGuide(panelName, callback)
	if self.askForHelpGuiding then
		return callback(false)
	end
	if (not self.messageButton) or (not self.messageButton:isVisible()) then 
		return callback(false) 
	end

	local tZOrder = self.messageButton:getZOrder()

	local function onFinished(success)
		if self.messageButton then
			self.messageButton:removeFromParentAndCleanup(false)
			self:addChildAt(self.messageButton, tZOrder)
		end
		self.askForHelpGuiding:removeFromParentAndCleanup()
		self.askForHelpGuiding = nil
		return callback(true)
	end

	local guide = require "zoo.panel.askForHelp.component.Guide"
	local inst = guide:create(self.messageButton, panelName, onFinished)

	self.askForHelpGuiding = inst
	self.messageButton:removeFromParentAndCleanup(false)
    inst:addChild(self.messageButton)
    self:addChild(inst, SceneLayerShowKey.POP_OUT_LAYER)
end

function HomeScene:processAskForHelpData(evt)
	local scene = Director:sharedDirector():getRunningScene()
	if scene ~= nil and scene:is(MessageCenterScene) then return end

	local function asfMsgFlags(next)
		if not table.isEmpty(evt.data.subsAskBroadcast) then
			AskForHelpManager:getInstance():setNewMessageFlag(true)
		end
		if AskForHelpManager:getInstance():hasNewMessageFlag() then
			self:showAFHIcon(true)
		end
        next()
	end

	local function asfBroadCast(next)
		AskForHelpManager:getInstance():onBroadcast(evt.data.subsAskBroadcast, evt.data.subsSucBroadcast)
	end

	local chain = CallbackChain:create()
	chain:appendFunc(asfMsgFlags)
	chain:appendFunc(asfBroadCast)
	chain:call()
end

function HomeScene:onInitAskForHelp()
	if PrepackageUtil:isPreNoNetWork() then return end

	local function onGetRequestNumSuccess(evt)
		self:processAskForHelpData(evt)
	end

	local function onPullMessage()
		local http = GetRequestNumHttp.new(false)
		http:ad(Events.kComplete, onGetRequestNumSuccess)
		http:syncLoad()
	end

    AskForHelpManager.getInstance():init()
	AskForHelpManager.getInstance():loadData(nil, nil, true)
	AskForHelpManager.getInstance():addEventListener(AFHEvents.kAFHNewCaller, onPullMessage)
	AskForHelpManager.getInstance():addEventListener(AFHEvents.kAFHSuccessEvent, onPullMessage)
end

function HomeScene:onEnterFromNotification()
end

function HomeScene:completeFishbowlPromotion()
	if not (_G.kUserLogin and __ANDROID) then
		return
	end
	if not (_G.sysOSVersion and _G.sysOSVersion >= 8.0) then
		return
	end
    local key = "fish_prom_"..tostring(UserManager.getInstance().uid)
	local value = CCUserDefault:sharedUserDefault():getStringForKey(key, "")
	if value and value ~= "" then
		local fishIdfa = nil
		pcall(function()
			fishIdfa = luajava.bindClass("com.happyelements.android.AndroidIdUtils"):getAndroidIdReadOnly("fishbowl")
			end)
		local va = string.split(value, ",")
		if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("completeFishbowlPromotion1", fishIdfa, value) end
		if fishIdfa and #va >= 2 then
			local appId = va[1]
			local idfa = va[2]
			local mac = MetaInfo:getInstance():getMacAddress() or ""

			local function onSuccess()
				CCUserDefault:sharedUserDefault():setStringForKey(key, "")
				CCUserDefault:sharedUserDefault():flush()
			end

			local function onFail()
			end

		    local http = ClickPromoHttp.new()
		    http:ad(Events.kComplete, onSuccess)
		    http:ad(Events.kError, onFail)
		    http:load(appId, idfa, mac, fishIdfa)
			if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("completeFishbowlPromotion2", appId, idfa, mac, fishIdfa) end
		end
	end
end

--隐藏关是否通关
function HomeScene:HiddenLevelHasEndPassed( branchId )
    local metaModel = MetaModel:sharedInstance()
	local branchDataList =metaModel:getHiddenBranchDataList()
    local curBranchData = branchDataList[branchId]
	local endHiddenLevel = curBranchData.endHiddenLevel
	return UserManager.getInstance():hasPassedLevel(endHiddenLevel)
end

--获取隐藏关头部位置
function HomeScene:getTopHiddelLevelBranchId()
	return MetaModel:sharedInstance():getTopHiddenBranchId()
end

--获取最低可打隐藏关位置
function HomeScene:getLowAndNotCompketeHiddelLevelBranchId()

    local lowBranchId = 0
    local metaModel = MetaModel:sharedInstance()
	local branchDataList =metaModel:getHiddenBranchDataList()

    for i,v in ipairs(branchDataList) do
        local branchId = v.branchId
        if not metaModel:isHiddenBranchDesign(branchId) then
	        local bPass = self:HiddenLevelHasEndPassed( branchId )
            local bCanOpen = metaModel:isHiddenBranchCanOpen(branchId) 

	        if not bPass and bCanOpen then
	            lowBranchId = branchId
	            break
	        end
	    end
    end

	return lowBranchId
end

--当前头部15关是否满级满星
function HomeScene:getLevelTypeInCurTop15Level()
    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	local FullStar15Level = 15 * 3
    local StartLevel = configTopLevel - 15
	local userTopLevel = UserManager:getInstance().user.topLevelId

	local userFullStar = 0
	local scores = UserManager:getInstance():getScoreRef()

    local bFullLevel = false
    local bFullStar = false

	for k, v in pairs(scores) do
		if v.levelId > StartLevel and v.levelId <= userTopLevel and LevelType:isMainLevel(v.levelId) then 
			local star = tonumber(v.star)
			if star > 3 then
				star = 3 
			end
			userFullStar = userFullStar + star
		end
    end

    if userFullStar >= FullStar15Level then
        bFullStar = true
    end

    if userTopLevel >= configTopLevel then
        bFullLevel = true
    end

    return bFullLevel,bFullStar
end

--获取可补星的关卡位置
function HomeScene:getLowNoFullStarLevel()
    local bFind = false
    local LevelId = 0

    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	local userTopLevel = UserManager:getInstance().user.topLevelId

    for i=1, configTopLevel  do
        local ScoreInfo = UserManager:getInstance():getUserScore(i)

        if ScoreInfo ~= nil then
            local star = tonumber(ScoreInfo.star)
			if star > 3 then
				star = 3 
			end

            if star ~= 3 then
                bFind = true
                LevelId = i
                break
            end
        end
    end

    return bFind, LevelId
end

--跳入最高隐藏区域
function HomeScene:jumpToTopHiddenLevel( jumpEndCall )

    local metaModel = MetaModel:sharedInstance()
    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    local TopHideLevelBranchID = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId( configTopLevel )

    self.worldScene:scrollToBranch(TopHideLevelBranchID, jumpEndCall)
end

--跳隐藏关 跳补星逻辑
function HomeScene:jumpHideLevelOrNotFullStarLevel()

    local function NormalJump( levelId )
        --正常跳入自己的最高关卡
		self.worldScene:playOnEnterCenterUserPosAnim( levelId )
    end

    local function JumpToBranch( iBranchId )
        --跳入隐藏关
		self.worldScene:scrollToBranch(iBranchId)
    end

    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()

    --判断是否要跳入隐藏关 不跳进入主线toplevel
    local bFullLevel, bTopLevelFullStar = self:getLevelTypeInCurTop15Level()          

    if bFullLevel and not bTopLevelFullStar then
        --1.如果玩家头部最高区域未满星，则依旧定位到头部最高区域
        NormalJump()
        return
    end

    local metaModel = MetaModel:sharedInstance()
    local uid = UserManager:getInstance().user.uid or '12345'
    local branchId = CCUserDefault:sharedUserDefault():getIntegerForKey('stayBranchId_'..uid)

    if bFullLevel and bTopLevelFullStar then
        --2.如果头部最高区域已满星，上一次退出游戏时停留在一个未通关的隐藏关区域，则自动定位到此隐藏关区域

        if branchId and branchId ~= 0 then
            local iBranchId = tonumber(branchId)

            if metaModel:isHiddenBranchCanOpen(iBranchId) then
                if not self:HiddenLevelHasEndPassed( iBranchId ) then
                    JumpToBranch( iBranchId )
                    return
                end
            end
        end
    end

    if bFullLevel and bTopLevelFullStar then
        --3.如果玩家上一次退出游戏并未停留在任何一个隐藏关区域或者停留在的隐藏关区域已通关，但头部最高隐藏关区域未通关，则自动定位到头部隐藏关区域
        local TopHideLevelBranchID = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId( configTopLevel )
--        local TopHideLevelBranchID = self:getTopHiddelLevelBranchId()

        if metaModel:isHiddenBranchCanOpen(TopHideLevelBranchID) then
            if not self:HiddenLevelHasEndPassed( TopHideLevelBranchID ) then
                if TopHideLevelBranchID ~= 0 then
                    JumpToBranch( TopHideLevelBranchID )
                    return
                end
            end
        end
    end

    if bFullLevel and bTopLevelFullStar then
        --4.如果头部最高隐藏关区域已通关，则定位到关卡号最低的一个已解锁隐藏关区域
        local TopHideLevelBranchID = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId( configTopLevel )
--        local TopHideLevelBranchID = self:getTopHiddelLevelBranchId()

        local function findLowAndJump()
            --找出未通关的最低的隐藏关位置
            local iBranchId = self:getLowAndNotCompketeHiddelLevelBranchId()

            if iBranchId ~= 0 then
                JumpToBranch( iBranchId )
                return true
            end

            return false
        end

        if metaModel:isHiddenBranchDesign(TopHideLevelBranchID) then
            --如果没有最高 按 满星算
            if findLowAndJump() then
                return 
            end
        else
            if metaModel:isHiddenBranchCanOpen(TopHideLevelBranchID) then
                if self:HiddenLevelHasEndPassed( TopHideLevelBranchID ) then
                    if findLowAndJump() then
                        return 
                    end
                end
            end
        end
    end

    if bFullLevel and bTopLevelFullStar then
        --5.如果没有已解锁的隐藏关区域，则定位到关卡号最低的一个可补星的主线关区域

        --找出未通关的最低的隐藏关位置
        local iBranchId = self:getLowAndNotCompketeHiddelLevelBranchId()
        --找出可补星的最低位置
        local bHaveNoFullStarLevel, NoFullLowStarLevelId = self:getLowNoFullStarLevel()

        if iBranchId == 0 and bHaveNoFullStarLevel then

            if NoFullLowStarLevelId ~=0 then
                NormalJump( NoFullLowStarLevelId )
                return
            end
        end
    end

    NormalJump()
end