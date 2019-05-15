require "zoo.panel.seasonWeekly.SeasonWeeklyRaceManager"
require "zoo/panel/component/common/BoxRewardTipPanel"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceRulePanel"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceSharePanel"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceChampPanel"
require "zoo.panel.seasonWeekly.SeasonWeeklyRacePassPanel"
require "zoo.panel.TwoChoicePanel"
require "zoo.panel.LimitItemGuidePanel"

require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyMainButtonPart"
require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyTopInfoPart"
require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRewardPart"
require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRankingPart"
require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRaceRewardsPanel_VerB"

local kDragonBonesName = "season_weekly_panel_animation"
local kTextureAtlasName = "season_weekly_panel_animation"

SeasonWeeklyEvents = {
	kPlayWeeklyLevel = "kSeasonWeeklyEvents.kPlayWeeklyLevel",
	kBuyWithRMB = "kSeasonWeeklyEvents.kBuyWithRMB",
	kBuyWithHappyWindCoin = "kSeasonWeeklyEvents.kBuyWithHappyWindCoin",
	kBubbleTapped = "kSeasonWeeklyEvents.kBubbleTapped",
	kUpdateAll = "kSeasonWeeklyEvents.kUpdateAll",
}

SeasonWeeklyBaseMainPanel = class(BasePanel)
function SeasonWeeklyBaseMainPanel:create( resJson , rootGroupName , resBG , weeklyDecisionType )
    local panel = SeasonWeeklyBaseMainPanel.new()
    panel.resJson = resJson
    panel.weeklyDecisionType = weeklyDecisionType
    panel.rootGroupName = rootGroupName
    panel.resBG = resBG
    panel._isMarkedAsActivityPanel = true
    panel:loadRequiredResource( resJson )

	FrameLoader:loadArmature("skeleton/weekly_main_ui")
    return panel
end

function SeasonWeeklyBaseMainPanel:onEnterHandler(event, ...)
	if event == "enter" then
		_G.__showHomeSceneCacheRef = _G.__showHomeSceneCacheRef + 1
	elseif event == "exit" then
		_G.__showHomeSceneCacheRef = _G.__showHomeSceneCacheRef - 1
	end

	BasePanel.onEnterHandler(self, event, ...)
end

function SeasonWeeklyBaseMainPanel:resizeAndReposition()
end

function SeasonWeeklyBaseMainPanel:initUI(rootGroupName, resBG)
	self.ui = self:buildInterfaceGroup( rootGroupName )
	
	
	BasePanel.init(self, self.ui, "SeasonWeeklyBaseMainPanel")
	self.panelLuaName = "SeasonWeeklyBaseMainPanel"
	
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()	

	local bgSize = self.ui:getChildByName("bg"):getGroupBounds().size
	
	local heightScale = visibleSize.height / bgSize.height
	local widthScale = visibleSize.width / bgSize.width
	
	local scale = math.max(heightScale, widthScale)
	scale = math.min(scale, 1)
	self.ui:setScale(scale)
	
	local panelPosX = (visibleSize.width - bgSize.width * scale) / 2
	self.ui:setPosition(ccp(panelPosX, 0))
	local bgPos = self.ui:getChildByName("bg"):getPosition()
	local bounds = self.ui:getChildByName("bg"):getGroupBounds(self.ui)
	local bgZOrder = self.ui:getChildByName("bg"):getZOrder()

	self.ui:getChildByName("bg"):removeFromParentAndCleanup(true)

	local bgImg = Sprite:create(SpriteUtil:getRealResourceName("ui/weeklyMatch/weeklyPanelBg.png"))
	bgImg:setAnchorPoint(ccp(0.5, 0.5))
	bgImg:setPosition(ccp(bgPos.x+bounds.size.width/2,bgPos.y-bounds.size.height/2))

	self.ui:addChildAt(bgImg, bgZOrder)
	self.bgImg = bgImg

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:closePanel() end)

	--initParts
	self:initTopInfo()
	self:initRewardPart()
	self:initMainButtonPart()
	self:initRankingPart() 

	self.dataChangeListener = function (evt) 
		if evt and evt.data and evt.data.needUpdateParts then
			if self.isDisposed then return end

			local needUpdateParts = evt.data.needUpdateParts

			if needUpdateParts.top then
				self.topInfoPart:autoRefreshTopInfoLabel()
			end

			if needUpdateParts.button then
				self.mainButtonPart:updateMainButton()
				self.mainButtonPart:updatePlayCountInfo()
			end

			if needUpdateParts.rewards then
				self.rewardPart:updateAllRewards()
			end

			if needUpdateParts.ranking then
				if needUpdateParts.type == "passlevel" then
					self.rankingPart:updateRankingWithSurpassAnim()
				else
					self.rankingPart:updateRanking()
				end 
			end
		else
			self:updateParts()
		end
	end

	GlobalEventDispatcher:getInstance():addEventListener(
		SummerWeeklyMatchEvents.kDataChangeEvent, self.dataChangeListener )
	self:updateParts()

	-- lockScreen
	local touchLayer = Layer:create()
    self.ui:addChild(touchLayer)
	self.touchLayer = touchLayer

	local instace = self
	self.touchLayer:setTouchEnabled(true, 0, true)
	touchLayer:addEventListener(DisplayEvents.kTouchTap, function( ... )
    end)

	function touchLayer:hitTestPoint(worldPosition, useGroupTest)
		if instace.lockedUI then return true end
	end

	self.exceptionListener = function()
		if self.isDisposed then
			return
		end
		self:runAction(CCCallFunc:create(function ( ... )
			if self.isDisposed then
				return
			end
			self:closePanel()
		end))
	end


	GlobalEventDispatcher:getInstance():addEventListener(
		kGlobalEvents.kExceptionReturnFromGamePlay, 
		self.exceptionListener
	)
end

function SeasonWeeklyBaseMainPanel:scrollBgH(deltaX)
	if self.isDisposed then return end
	if self.bgImg then 
		local oldPosX = self.bgImg:getPositionX()
		self.bgImg:setPositionX(oldPosX + deltaX * 0.5)
	end
end

function SeasonWeeklyBaseMainPanel:playPiecesGuide( ... )
	if self.isDisposed then return end
	
	local skinBtn, worldPos, worldScale = self.mainButtonPart:copySkinBtn()
	
	skinBtn:setTouchEnabled(false)

	local PiecesGuide = require 'zoo.panel.seasonWeekly.guides.PiecesGuide'

	local guide = PiecesGuide:create(function()
		if skinBtn.isDisposed then
			return
		end
		skinBtn:setTouchEnabled(true)

	end, function ( ... )
		if skinBtn.isDisposed then
			return
		end
		skinBtn:removeFromParentAndCleanup(true)
		self:showSnow(true)
	end)

	local guideSkinBtnPos = self:convertToNodeSpace(worldPos)
	skinBtn:setPosition(guideSkinBtnPos)
	skinBtn:setScale(worldScale)
	guide:setScale(worldScale)

	-- printx(61, worldPos.x, worldPos.y)
	-- printx(61, worldPos.x, worldPos.y)

	self:addChild(guide)
	self:addChild(skinBtn)

	local w = skinBtn:getGroupBounds().size.width

	guide:setAnimWorldPos(ccp(worldPos.x + w*1.35/5, worldPos.y))
	self:showSnow(false)

end

function SeasonWeeklyBaseMainPanel:showSnow( bshow )
	-- if self.isDisposed then return end
	-- self.snow:setVisible(bshow)
end

function SeasonWeeklyBaseMainPanel:lockUI(lock)
	self.lockedUI = lock
end

function SeasonWeeklyBaseMainPanel:updateParts()
	if self.isDisposed then return end

	self.topInfoPart:autoRefreshTopInfoLabel()
	self.mainButtonPart:updateMainButton()
	self.mainButtonPart:updatePlayCountInfo()
	self.rewardPart:updateAllRewards()
	self.rankingPart:updateRanking()
end

function SeasonWeeklyBaseMainPanel:initTopInfo()
	local topInfoPart = SeasonWeeklyTopInfoPart:create("2017SummerWeekly/interface/ResTopInfoPart", self.resJson)
	self.ui:addChild(topInfoPart)
	self.topInfoPart = topInfoPart
end

function SeasonWeeklyBaseMainPanel:initMainButtonPart()
	local mainButtonPart = SeasonWeeklyMainButtonPart:create("2017SummerWeekly/interface/ResMainButtonPart" , self.resJson  , self.adDecision )
	self.ui:addChild( mainButtonPart )
	self.mainButtonPart = mainButtonPart

	self.mainButtonPart:addEventListener(SeasonWeeklyEvents.kPlayWeeklyLevel , function() 
			self:startLevel() 
		end )

	self.mainButtonPart:addEventListener(SeasonWeeklyEvents.kBuyWithRMB , function() 
			self:buyWeeklyPlayCount(true)
		end )

	self.mainButtonPart:addEventListener(SeasonWeeklyEvents.kBuyWithHappyWindCoin , function() 
			self:buyWeeklyPlayCount(false)
		end )
end

function SeasonWeeklyBaseMainPanel:initRewardPart()
	local rewardPart = SeasonWeeklyRewardPart:create("2018_s1_weekly/trunk", self.resJson )
	rewardPart:setPositionY(-145 )
	self.ui:addChild( rewardPart )
	self.rewardPart = rewardPart
	self.rewardPart:addEventListener( SeasonWeeklyEvents.kBubbleTapped , function(evt) 
		self:onBubbleTapped(evt) 
	end )
	self.rewardPart:setScollHCallback(function (deltaX)
		self:scrollBgH(deltaX)
	end)
	--self.rewardPart:updateAllRewards()
end

function SeasonWeeklyBaseMainPanel:initRankingPart()
	local rankingPart = SeasonWeeklyRankingPart:create("2017SummerWeekly/interface/ResRankingPart" , self.resJson, self)
	self.ui:addChild(rankingPart)
	self.rankingPart = rankingPart

	--self.rankingPart:updateRanking()
end

function SeasonWeeklyBaseMainPanel:startLevel()

	local function onCancelPlay()
		self.mainButtonPart:updateMainButton()
	end
	
	local function onConfirmPlay()
		if __ANDROID and not self.animation then
			local scene = Director:sharedDirector():getRunningScene()
		    self.animation = CountDownAnimation:createNetworkAnimationInHttp(scene)
		    self.animation.onKeyBackClicked = function(self) end
		end

		local levelId = SeasonWeeklyRaceManager:getInstance():calcLevelId()

		local logic = StartLevelLogic:create(
			self, levelId , GameLevelType.kSummerWeekly, {}, true)
		logic:start(true)
	end

	if SeasonWeeklyRaceManager:getInstance():isNeedShowTimeWarnPanel() then
		self:showTimeNotEnoughWarningPanel(onConfirmPlay, onCancelPlay)
	else
		onConfirmPlay()
	end
end

function SeasonWeeklyBaseMainPanel:showTimeNotEnoughWarningPanel(onConfirm, onCancel)
	if onConfirm then onConfirm() end
	--[[
	local descText = Localization:getInstance():getText("weekly.race.winter.start.tip1")
	local panel = TwoChoicePanel:create(descText, "取消", "继续", "不再提醒", true)
	local function onCancelBtnTapped(dontShowAgain)
		SeasonWeeklyRaceManager:getInstance():setTimeWarningDisabled(dontShowAgain)
		if onCancel then onCancel() end
	end
	local function onConfirmBtnTapped(dontShowAgain)
		SeasonWeeklyRaceManager:getInstance():setTimeWarningDisabled(dontShowAgain)
		if onConfirm then onConfirm() end
	end
	panel:setButton1TappedCallback(onCancelBtnTapped)
	panel:setButton2TappedCallback(onConfirmBtnTapped)
	panel:setCloseButtonTappedCallback(onCancelBtnTapped)
	panel:popout()
	]]
end

function SeasonWeeklyBaseMainPanel:onWillEnterPlayScene()

	local dailyDropPropCount = nil
	local dailyDropPropCount2 = nil
	
	if SeasonWeeklyRaceManager:getInstance() and SeasonWeeklyRaceManager:getInstance().matchData then
		dailyDropPropCount = SeasonWeeklyRaceManager:getInstance().matchData.dailyDropPropCount
		dailyDropPropCount2 = SeasonWeeklyRaceManager:getInstance().matchData.dailyDropPropCount2
	end

	if not dailyDropPropCount then
		dailyDropPropCount = SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount
	end

	if not dailyDropPropCount2 then
		dailyDropPropCount2 = SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing
	end
	GamePlayContext:getInstance().weeklyData.dailyDropPropCount = dailyDropPropCount
	GamePlayContext:getInstance().weeklyData.dailyDropPropCount2 = dailyDropPropCount2
end

function SeasonWeeklyBaseMainPanel:onDidEnterPlayScene(gamePlayScene)
	--printx( 1 , "   SeasonWeeklyBaseMainPanel:onDidEnterPlayScene  ==============+++++++++++++++++++++++++++++++++++++++++++++++++++ " )

	if gamePlayScene and gamePlayScene.gameBoardLogic 
		and ( gamePlayScene.gameBoardLogic.replayMode == nil or gamePlayScene.gameBoardLogic.replayMode == ReplayMode.kNone ) then

		GamePlayContext:getInstance().summerWeeklyData.dropPropsPercent = SeasonWeeklyRaceManager:getInstance():getSpecialPercent()
		GamePlayContext:getInstance().summerWeeklyData.orignalDropPropsPercent = GamePlayContext:getInstance().summerWeeklyData.dropPropsPercent

		ReplayDataManager:updateGamePlayContext()

	end

	if self.animation then
		PopoutManager:sharedInstance():remove(self.animation)
		self.animation = nil
	end
end

function SeasonWeeklyBaseMainPanel:buyWeeklyPlayCount( androidRmbBuy )

	local function onBuyPlayTime(successCallback, failCallback, cancelCallback, finishCallback)
	    if self.isDisposed then return end 
	    local goodsId = SeasonWeeklyRaceManager:getInstance():getBuyGoodId()

	    local function onSuccess()
	        if self.isDisposed then return end
	 		if successCallback then successCallback() end
	    end

	    local function onFail(errCode, errMsg)
	        if self.isDisposed then return end
	        if not errCode then
	            CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
	        else 
	            if __ANDROID then 
	                if errCode == 730241 or errCode == 730247 then
	                    CommonTip:showTip(errMsg, "negative")
	                elseif errCode == -1000061 then
						CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errCode)), "negative")
	                else
	                    CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
	                end
	            else
	                CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errCode)), "negative") 
	            end
	        end
	        if failCallback then failCallback() end
	    end

	    local function onCancel()
	        if self.isDisposed then return end
	  		if cancelCallback then cancelCallback() end
	    end

	    local function updateFunc()
	        if self.isDisposed then return end
	 		if finishCallback then finishCallback() end
	    end
	    --RemoteDebug:uploadLog("RRR   buyWeeklyPlayCount  " , androidRmbBuy)
	    if androidRmbBuy then 
	        if self.adPaymentType == Payments.WECHAT or self.adPaymentType == Payments.QQ or self.adPaymentType == Payments.MI_WXPAY then 
	            setTimeOut(function ()
	                onCancel()
	            end, 3)
	        end
	        local logic = IngamePaymentLogic:create(goodsId, GoodsType.kItem, DcFeatureType.kWeeklyRace, DcSourceType.kWeeklyPlayCount)
	        if logic.dcAndroidInfo then
	        	logic.dcAndroidInfo.currentStage = SeasonWeeklyRaceManager:getInstance():getLevelId()
	        end
	        logic:specialBuy(self.adDecision ,self.adPaymentType, onSuccess, onFail, onCancel, self.adRepayChooseTable)
	    else
	    	local levelId = SeasonWeeklyRaceManager:getInstance():getLevelId()
	        self.dcWindmillInfo = DCWindmillObject:create()
	        self.dcWindmillInfo:setGoodsId(goodsId)
	        self.dcWindmillInfo.currentStage = levelId

	        local logic = WMBBuyItemLogic:create()
	        local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kWeeklyRace, DcSourceType.kWeeklyPlayCount)
	        buyLogic.levelId = levelId
	        logic:buy(goodsId, 1, self.dcWindmillInfo, buyLogic, onSuccess, onFail, onCancel, updateFunc)
	    end
	end

	local function onSuccess() 
		--self.playButton:rma()
		self:startLevel()
	end
	
	local function onFail() 
		--self.playButton:refresh()
		self.mainButtonPart:updateMainButton()
	end
	
	local function onCancel() 
		--self.playButton:refresh() 
		self.mainButtonPart:updateMainButton()
	end

	local function onFinish() 
		--self.playButton:refresh() 
		self.mainButtonPart:updateMainButton()
	end

	local function onCancelBuy()
		self.mainButtonPart:updateMainButton()
	end

	local function onConfirmBuy()
		--self.playButton:rma()
		onBuyPlayTime(onSuccess, onFail, onCancel, onFinish)
	end

	if SeasonWeeklyRaceManager:getInstance():isNeedShowTimeWarnPanel() then
		self:showTimeNotEnoughWarningPanel(onConfirmBuy, onCancelBuy)
	else
		onConfirmBuy()
	end

	--onConfirmBuy()
end

function SeasonWeeklyBaseMainPanel:onBubbleTapped(evt)
	local idx = evt.data
	--local idx = evt.target
	local rewards = SeasonWeeklyRaceManager:getInstance():getNextWeeklyReward()
	local reward = rewards[idx]

	if reward.needMore > 0 and (not reward.hasReceived)then
		self.rewardPart:showTipPanel( idx )
	else
		self:tryToGetReward(idx)
	end
end

function SeasonWeeklyBaseMainPanel:playRewarsAnim(rewards,pos,callback,isWeek)
	if self.isDisposed then 
		return 
	end

	if isWeek then
		local anim = OpenBoxAnimation:create(rewards)
		anim:setFinishCallback(callback)
		anim:play()
	else
		local showGuideItemIds = {
			ItemType.TIMELIMIT_HAMMER,
			ItemType.TIMELIMIT_BRUSH,
			ItemType.TIMELIMIT_SWAP,
			ItemType.TIMELIMIT_BROOM
		}
		if #rewards == 1 and table.exist(showGuideItemIds,rewards[1].itemId) then 
			local panel = LimitItemGuidePanel:create(rewards[1])
			panel:setFinishCallback(function( ... )				
				local anim = FlyItemsAnimation:create(rewards)
				anim:setWorldPosition(pos)
				anim:setFinishCallback(callback)
				anim:play()
			end)
			panel:popout()
		else
			local anim = FlyItemsAnimation:create(rewards)
			anim:setWorldPosition(pos)
			anim:setFinishCallback(callback)
			anim:play()
		end
	end
end

function SeasonWeeklyBaseMainPanel:tryToGetReward(indexId)

	local rewards = SeasonWeeklyRaceManager:getInstance():getNextWeeklyReward()
	local matchData = SeasonWeeklyRaceManager:getInstance().matchData

	local reward = rewards[indexId]

	if not reward then return end

	if reward.needMore == 0 and not reward.hasReceived then
		--local r = reward.items
		local bubbleView = self.rewardPart.rewardViews[indexId]
		local pos = self.rewardPart.ui:convertToWorldSpace(bubbleView.ui:getPosition())
		local size = bubbleView.ui:getGroupBounds().size
		pos.x = ( pos.x + (size.width/2) ) / bubbleView.fixScale
		pos.y = pos.y - (size.height/2)

		SeasonWeeklyRaceManager:getInstance():receiveWeeklyReward(
			
			reward.id,

			function( ... )
				if self.isDisposed then 
					return
				end
				--chestLayer:setVisible(false)
				--self:setArrowMode(arrow,false)
				self:playRewarsAnim( reward.items , pos , function( ... )
					if not self.isDisposed then
						self.rewardPart:updateAllRewards()
					end
				end)

				setTimeOut( function () self.rewardPart:updateAllRewards() end , 0.2 )

			end,

			function( event )
				if self.isDisposed then 
					return
				end

				if tonumber(event.data or 0) == 730770 then
					self:closePanel()
					setTimeOut(function () SeasonWeeklyRaceManager:getInstance():pocessSeasonWeeklyDecision(false) end, 1)
					return
				end

				if tonumber(event.data or 0) == 731083 then
					return
				end

				self.rewardPart:updateAllRewards()
			end
		)

		--pao:removeAllEventListeners()

	elseif reward.hasReceived then 
		CommonTip:showTip(Localization:getInstance():getText("weeklyrace.summer.panel.tip9"), "positive")	
	end
end

function SeasonWeeklyBaseMainPanel:popoutShowTransition()
  	self.hasPopout = true

  	if not SeasonWeeklyRaceManager:getInstance():hadGotInitRewards() then

  		local function next( ... )
  			if self.isDisposed then
  				return
  			end
  			self:checkLastWeekRewards()
  		end

  		local function onSuccess( evt )
  			if self.isDisposed then
  				return
  			end

  			local rewards = {}

  			if evt and evt.data then
  				rewards = evt.data.rewardItems or {}
  			end

  			local InitRewardPanel = require 'zoo.panel.seasonWeekly.mainPanel.InitRewardPanel'
  			InitRewardPanel:create(rewards, next):popout()

  		end
  		
  		SeasonWeeklyRaceManager:getInstance():getInitRewards(onSuccess, next)
  	else
 		self:checkLastWeekRewards()
 	end

	DcUtil:UserTrack({
		category='weeklyrace', 
		sub_category='weeklyrace_winter_2017_puzzle_num', 
		num=SeasonWeeklyRaceManager:getInstance():getTotalPieceNum()
	})
end

function SeasonWeeklyBaseMainPanel:checkLastWeekRewards()
	local function showWeekRewards()
		local weekRewards, rewardLevelId = SeasonWeeklyRaceManager:getInstance():getLastWeekRewardsForRewardsPanel()
		if weekRewards and #weekRewards > 0 then
			self.weeklyDecisionType = nil
			--print("上周未领取奖励:", table.tostring(weekRewards), rewardLevelId)
			--local panel = SeasonWeeklyRaceRewardsPanel:create(weekRewards, rewardLevelId)
			local panel = SeasonWeeklyRaceRewardsPanel_VerB:create(weekRewards, rewardLevelId)
			panel:popout()
		end
	end
	-- 优先显示上周排行奖励
	local rankRewards, rankLevelId, rank, surpass = SeasonWeeklyRaceManager:getInstance():getLastWeekRankRewardsForRewardsPanel()
	if rankRewards and #rankRewards > 0 then
		self.weeklyDecisionType = nil
		--print("上周排行奖励:", table.tostring(rankRewards), rankLevelId, rank,surpass)
		local panel = SeasonWeeklyRaceSharePanel:create(rankRewards, rankLevelId, rank, surpass)
		panel:popout(showWeekRewards)
	else
		showWeekRewards()
	end
end

function SeasonWeeklyBaseMainPanel:onStartLevelLogicSuccess()
	SeasonWeeklyRaceManager:getInstance():onStartLevel()
end

function SeasonWeeklyBaseMainPanel:onStartLevelLogicFailed(err)
	local onStartLevelFailedKey     = "error.tip."..err
    local onStartLevelFailedValue   = Localization:getInstance():getText(onStartLevelFailedKey, {})
    CommonTip:showTip(onStartLevelFailedValue, "negative")
    
    self.mainButtonPart:updateMainButton()
	self.mainButtonPart:updatePlayCountInfo()
end

function SeasonWeeklyBaseMainPanel:onKeyBackClicked()
  	self.allowBackKeyTap = false
  	self:closePanel()
end

function SeasonWeeklyBaseMainPanel:closePanel()
	HomeScene:sharedInstance():checkDataChange()
	if HomeScene:sharedInstance().coinButton and not HomeScene:sharedInstance().coinButton.isDisposed then
		HomeScene:sharedInstance().coinButton:updateView()
	end
	if self.guideLayer and not self.guideLayer.isDisposed then
		self.guideLayer:removeFromParentAndCleanup(true)
		self.guideLayer = nil
	end
	PopoutManager:sharedInstance():remove(self)


	HomeScene:sharedInstance():tryRemoveSummerWeeklyButton()
end

function SeasonWeeklyBaseMainPanel:popup()
	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
        if __ANDROID then 
        	printx( 1 , "   SeasonWeeklyBaseMainPanel:popup  " , decision)

            self.adDecision = decision
            self.adPaymentType = paymentType
            self.dcAndroidStatus = dcAndroidStatus
            self.adRepayChooseTable = repayChooseTable
        end

      	self:initUI( self.rootGroupName , self.resBG ) 
      	PopoutQueue:sharedInstance():push(self)
      	self.allowBackKeyTap = true
    end

	if __ANDROID then 
        PaymentManager.getInstance():getBuyItemDecision(popoutPanel, SeasonWeeklyRaceManager:getInstance():getBuyGoodId())
    else
    	--BroadcastManager:getInstance():showTestTip("decision = " .. tostring(decision))
        popoutPanel()
    end 
end

function SeasonWeeklyBaseMainPanel:dispose()
	self.mainButtonPart:removeAllEventListeners()
	 -- initUI是在回调中调用的,可能是网络检查的异步回调，可能在此之前通过返回按钮关闭面板
	if self.dataChangeListener then
		GlobalEventDispatcher:getInstance():removeEventListener(SummerWeeklyMatchEvents.kDataChangeEvent, self.dataChangeListener)
	end
	if self.exceptionListener then
		GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kExceptionReturnFromGamePlay, self.exceptionListener)
	end
	BasePanel.dispose(self)

	-- ArmatureFactory:remove('weekly_main_ui', 'weekly_main_ui')
	FrameLoader:unloadArmature("skeleton/weekly_main_ui", true)

    local textureTable = {
        "ui/weeklyMatch/weeklyPanelBg.jpg",
    }
    for i,v in ipairs(textureTable) do
        CCTextureCache:sharedTextureCache():removeTextureForKey(
            CCFileUtils:sharedFileUtils():fullPathForFilename(
                SpriteUtil:getRealResourceName(v)
            )
        )
    end

	if HomeScene:sharedInstance().summerWeeklyButton and not HomeScene:sharedInstance().summerWeeklyButton.isDisposed then
		HomeScene:sharedInstance().summerWeeklyButton:update()
	end

	if self.passLevelListener then
		GamePlayEvents.removePassLevelEvent(self.passLevelListener)
		self.passLevelListener = nil
	end

	ModuleNoticeButton:tryPopoutStartGamePanel()
	
end