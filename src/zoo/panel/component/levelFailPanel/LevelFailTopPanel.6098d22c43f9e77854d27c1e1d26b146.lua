

local FailReason = {success = 0, move = 6, time = 14, score = 19, lotus = 20, addStep = 22 , noMatch = 99 , venom = 100}
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月22日 16:17:55
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.component.common.BubbleCloseBtn"
require "zoo.baseUI.ButtonWithShadow"
require "zoo.panel.jumpLevel.JumpLevelIcon"
require "zoo.panel.component.LevelPanelDifficultyChanger"
local UIHelper = require 'zoo.panel.UIHelper'
-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'


---------------------------------------------------
-------------- LevelFailTopPanel
---------------------------------------------------

assert(not LevelFailTopPanel)
assert(BaseUI)
LevelFailTopPanel = class(BaseUI)

LevelFailTopPanel.Events = {
	kPromotionItemDisposed = 'kPromotionItemDisposed',
}

function LevelFailTopPanel:init(parentPanel, levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove, ...)
	Notify:dispatch("QuitNextLevelModeEvent", true)
	if CountdownPartyManager.getInstance():shouldShowActCollection(levelId) then
		CountdownPartyManager.getInstance():loadSkeletonAssert()
	end

    if DragonBuffManager.getInstance():shouldShowActCollection(levelId) then
		DragonBuffManager.getInstance():loadSkeletonAssert()
	end

    if Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(levelId) then 
		Thanksgiving2018CollectManager.getInstance():loadSkeletonAssert()
	end

	if PublicServiceManager:shouldShowActCollection(levelId) then
		PublicServiceManager:addTotalTargetCount( 1 )
		PublicServiceManager:loadSkeletonAssert()
	end
	------------------------------------
	---- Get UI Resource
	-------------------------------
	self.resourceManager	= ResourceManager:sharedInstance()

	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelFailTopPanel)
	self.uncommonSkin = uncommonSkin

	printx(103 , "skinName = " , skinName )

	self.ui = ResourceManager:sharedInstance():buildGroup(skinName)
	BaseUI.init(self, self.ui)

	


	self.tipNode = CocosObject.new(CCNode:create())
	self.ui:addChild(self.tipNode)

	self.levelFlag ,self.isFirst = MetaManager:getInstance():getLevelDifficultFlag_ForStartPanel( levelId )
	if self.uncommonSkin then
		self.skinLevelFlag = self.levelFlag
		self.levelFlag = LevelDiffcultFlag.kNormal
		self.isFirst = false
		self:hanleForSkin()
	end

	---------------------
	---- Get UI Resource
	----------------------
	self.fadeArea		= self.ui:getChildByName("fadeArea")
	self.clippingAreaAbove	= self.ui:getChildByName("clippingAreaAbove")
    self.clippingAreaAbove:setOpacity(0)
	self.clippingAreaBelow	= self.ui:getChildByName("clippingAreaBelow")
	assert(self.fadeArea)
	assert(self.clippingAreaAbove)
	assert(self.clippingAreaBelow)

	he_log_warning("Not Tackle The targetIcon Resource !")
	self.titleLabel		= self.ui:getChildByName("titleLabel")
	self.replayBtnRes	= self.clippingAreaBelow:getChildByName("replayBtn")
	self.failDes		= self.fadeArea:getChildByName("failDes")
	self.questionMark 	= self.ui:getChildByName('questionMark')
	self.questionMark:ad(DisplayEvents.kTouchTap, function () self:onQuestionMarkTapped(failReason) end)
	self.questionMark:setTouchEnabled(true)

	-- Close Btn
	self.bg			= self.ui:getChildByName("bg")
	-- assert(self.bg)
	self.closeBtnRes	= self.ui:getChildByName("closeBtn")
	assert(self.closeBtnRes)

	assert(self.titleLabel)
	assert(self.replayBtnRes)
	assert(self.failDes)

	--------------------
	-- Create Failed Anim
	-- --------------------
	local failAnim
	if self.uncommonSkin then
		failAnim = UIHelper:createArmature3('skeleton/spring/level_fail_cry', 'level_fail_cry', 'level_fail_cry', 'spring_2019/he')
		failAnim:playByIndex(0)
		failAnim:setPositionX(35)
	else
		failAnim = CommonSkeletonAnimation:createNewFailAnimation()
	end
	self.clippingAreaAbove:addChild(failAnim)

	if failReason ~= 'refresh' then
		self.questionMark:setVisible(false)
	end
	--------------------------
	---- Data
	-----------------------
	self.levelId	= levelId
	self.levelType 	= levelType

	he_log_warning("already doesn't need these information !")
	self.failScore	= failScore
	self.failStar	= failStar
	self.costMove 	= costMove
	self.stageTime  = stageTime

	local metaModel		= MetaModel:sharedInstance()
	--self.levelModeTypeId	= metaModel:getLevelModeTypeId(self.levelId)

	self.parentPanel	= parentPanel

	------------------------------------
	-- Variable To Indicate Tapped State
	-- ---------------------------------
	self.BTN_TAPPED_STATE_CLOSE_BTN_TAPPED	= 1
	self.BTN_TAPPED_STATE_REPLAY_BTN_TAPPED	= 2
	self.BTN_TAPPED_STATE_NONE		= 3
	self.btnTappedState			= self.BTN_TAPPED_STATE_NONE

	-------------------
	-- Get Data About UI
	-- ------------------
	local titleLabelPos = self.titleLabel:getPosition()

	-------------------------------
	-- Create UI Component
	-- -------------------
	--- Panel Title
	local diguanWidth		= 58
	local diguanHeight		= 58
	local levelNumberWidth		= 205.52
	local levelNumberHeight		= 68.5
	local manualAdjustInterval	= -15


	local panelTitle = nil

	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		panelTitle = BitmapText:create(levelDisplayName, "fnt/helllevel.fnt", -1, kCCTextAlignmentCenter)
		panelTitle:setScale(0.8)
	else
		panelTitle = self:createPanelTitle(levelType, levelId)
	end
	
	local contentSize = panelTitle:getContentSize()
	self.ui:addChild(panelTitle)
	panelTitle:ignoreAnchorPointForPosition(false)
	panelTitle:setAnchorPoint(ccp(0,1))
	panelTitle:setPositionY(titleLabelPos.y)
	panelTitle:setToParentCenterHorizontal()

	-- Bubble Close Btn
	if self.uncommonSkin then
		self.closeBtn = {}
		self.closeBtn.ui = self.closeBtnRes
		self.closeBtn.ui:setButtonMode(true)
		self.closeBtn.ui:setTouchEnabled(true)
	else
		self.closeBtn = BubbleCloseBtn:create(self.closeBtnRes)
	end

	-- Replay Button
	self.replayBtn	= GroupButtonBase:create(self.replayBtnRes)

	-------------------------
	---- Update View
	-------------------------
	-- Get Panel Title
	local titleTxtKey	= "level.fail.title"
	local titleTxt		= Localization:getInstance():getText(titleTxtKey, {level_id = self.levelId})
	self.titleLabel:setString(titleTxt)
	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		self.titleLabel:setColor((ccc3(93,64,168)))
	end

	he_log_warning("only need it's pos info")
	self.titleLabel:setVisible(false)

	-- Get Repaly Button Label Txt
	local replayBtnTxtKey	= "level.fail.replay.button.label.txt"
	local replayBtnTxt
	if PublishActUtil:isGroundPublish() then
		replayBtnTxt	= Localization:getInstance():getText("prop.info.panel.close.txt", {})
	elseif self.levelType == GameLevelType.kDigWeekly
		or LevelType.isActivityLevelType(self.levelType)
		or self.levelType == GameLevelType.kRabbitWeekly 
		or self.levelType == GameLevelType.kSummerWeekly 
		or self.levelType == GameLevelType.kTaskForRecall then
		replayBtnTxt	= Localization:getInstance():getText('button.ok', {})
	else
		replayBtnTxt	= Localization:getInstance():getText(replayBtnTxtKey, {})
	end
	self.replayBtn:setString(replayBtnTxt)

	local manualAdjustBtnPosX	= 0
	local manualAdjustBtnPosY	= -9
	-- local label		= self.replayBtn:getLabel()
	-- local curLabelPos	= label:getPosition()
	-- label:setPosition(ccp(curLabelPos.x + manualAdjustBtnPosX, curLabelPos.y + manualAdjustBtnPosY)) 

	local failReasonType, failDesValue = LevelFailTopPanel:getFailResonAndDes(levelId, failReason, isTargetReached)
	if failDesValue then
		self.failDes:setString(failDesValue)
	end

	-----------------------------
	---- Add Event Listener
	----------------------------
	local function onReplayBtnTapped(event)
		if PublishActUtil:isGroundPublish() then 
			self:onCloseBtnTapped(event)
		elseif self.levelType == GameLevelType.kTaskForRecall or self.levelType == GameLevelType.kSummerWeekly then
			self:onCloseBtnTapped(event)
		elseif LevelType.isActivityLevelType(self.levelType) then
			self.btnTappedState = self.BTN_TAPPED_STATE_NONE
			self:onCloseBtnTapped()
		else
			self:onReplayBtnTapped(event)
		end
	end
	self.replayBtn:addEventListener(DisplayEvents.kTouchTap, onReplayBtnTapped)

	-- Close Button Event Listener
	local function onCloseBtnTapped(event)
		self:onCloseBtnTapped(event)
	end

	self.closeBtn.ui:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	self:initJumpLevelArea()

	local askForHelpStub = self.ui:getChildByName("askForHelpStub")
	if askForHelpStub then 
		askForHelpStub:setVisible(false)
	end

	self.askforhelpNeedGuide = false
	local showIcon = AskForHelpManager.getInstance():shouldShowFuncIcon(self.levelId)
	local needPopout = AskForHelpManager.getInstance():needPopout(self.levelId) or 
		AskForHelpManager.getInstance():needGuidance(kAskForHelpGuideEnum.EGUIDE_FAILLEVEL)

	if showIcon and needPopout then
		self.askforhelpNeedGuide = true
	end

	require 'zoo.panel.happyCoinShop.HappyCoinShopFactory'
	require 'zoo.panel.happyCoinShop.PromotionFactory'
	self.hasSthShowOnTopPart = false 
	if PromotionManager and PromotionManager:getInstance():isPennyPayEnabled() and not PromotionManager:getInstance():hadShowPennyFailTop() and (not self.askforhelpNeedGuide)  then
		PromotionManager:getInstance():setShowPennyFailTop()
		self:addPennyPayTopItem()
		self.hasSthShowOnTopPart = true
	elseif HappyCoinShopFactory:getInstance():shouldUse_1_45() and PromotionManager:getInstance():isInPromotion() and (not self.askforhelpNeedGuide)  then
		if not PromotionManager:getInstance():hadShowFailTop()  then
			PromotionManager:getInstance():setShowFailTop()
			self:addPromotionTopItem()
			self.hasSthShowOnTopPart = true
		end
	end

	self:levelDiffcultFlagVisable()

	self:processTailAnimationQueue()
end

function LevelFailTopPanel:hanleForSkin()
	local bgUI = self.ui:getChildByName("bg")
	local titleBg = bgUI:getChildByName("titleBg")
	local titleBgHard1 = bgUI:getChildByName("titleBgHard1")
	local titleBgHard2 = bgUI:getChildByName("titleBgHard2")
	titleBg:setVisible(false)
	titleBgHard1:setVisible(false)
	titleBgHard2:setVisible(false)
	if self.skinLevelFlag == LevelDiffcultFlag.kDiffcult then
		titleBgHard1:setVisible(true)
	elseif self.skinLevelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		titleBgHard2:setVisible(true)
	else
		titleBg:setVisible(true)
	end
end

-- 不要检测活动强弹
function LevelFailTopPanel:skipCheckActivity()
	if self.hasPromotionItem and self:hasPromotionItem() then return true end
	if self.askforhelpNeedGuide then return true end
	return false
end

function LevelFailTopPanel:addPennyPayTopItem( ... )
	if self.promotionLayer then return end

	local GoldPage = nil
	if __ANDROID or __WIN32 then
		GoldPage = HappyCoinShopFactory:getInstance():getAndroidGoldPage()
	end

	if GoldPage then

		local promotionLayer = Layer:create()
		self.promotionLayer = promotionLayer
		self:addChild(promotionLayer)

		local FailTopPanel = require 'zoo.panel.happyCoinShop.failTop.FailTopPanel'

		local promotionTopPanel = FailTopPanel:createWithConfig(GoldPage:getPennyPayConfig(), function ( ... )
			if self.isDisposed then return end
			self:removePromotionTopItem()
		end)
		if self.ui:getChildByName("hang_2") then
			self.ui:getChildByName("hang_2"):setVisible(false)
		end
		if self.ui:getChildByName("hang_4") then
			self.ui:getChildByName("hang_4"):setVisible(false)
		end
		promotionLayer:addChild(promotionTopPanel)
		self.promotionTopPanel = promotionTopPanel
		self.ui:setPositionY(self.ui:getPositionY() - 231)

	end
end

function LevelFailTopPanel:addPromotionTopItem( ... )

	printx(104 , "GoldPage = " , table.tostring(GoldPage))

	if self.promotionLayer then return end

	local GoldPage
	if __IOS or __WIN32 then
		GoldPage = HappyCoinShopFactory:getInstance():getIosGoldPage()
	elseif __ANDROID then
		GoldPage = HappyCoinShopFactory:getInstance():getAndroidGoldPage()
	end



	if GoldPage then

		local promotionLayer = Layer:create()
		self.promotionLayer = promotionLayer
		self:addChild(promotionLayer)

		local FailTopPanel = require 'zoo.panel.happyCoinShop.failTop.FailTopPanel'

		local promotionTopPanel = FailTopPanel:createWithConfig(GoldPage:getPromotionConfig(), function ( ... )
			if self.isDisposed then return end
			self:removePromotionTopItem()
		end)

		if self.ui:getChildByName("hang_2") then
			self.ui:getChildByName("hang_2"):setVisible(false)
		end
		if self.ui:getChildByName("hang_4") then
			self.ui:getChildByName("hang_4"):setVisible(false)
		end

		promotionLayer:addChild(promotionTopPanel)

		self.ui:setPositionY(self.ui:getPositionY() - 231)

	end
end

function LevelFailTopPanel:removePromotionTopItem( ... )
	if self.promotionLayer and (not self.promotionLayer.isDisposed) then
		self.promotionLayer:removeFromParentAndCleanup(true)
		self.ui:setPositionY(self.ui:getPositionY() + 231)
		self:setPositionY(self:getPositionY() - 231)
		self.promotionLayer = nil
		self:dispatchEvent(Event.new(LevelFailTopPanel.Events.kPromotionItemDisposed, nil, self))
	end
	self.promotionLayer = nil
end

function LevelFailTopPanel:hasPromotionItem( ... )
	return self.promotionLayer ~= nil
end

function LevelFailTopPanel:createPanelTitle(levelType, levelId)
	local fntFile, fntScale = WorldSceneShowManager.getInstance():getPanelTitleFntInfo()

	local panelTitle = nil
	if PublishActUtil:isGroundPublish() then
		panelTitle = BitmapText:create("精彩活动关", "fnt/titles.fnt", -1, kCCTextAlignmentCenter)
	else
		local levelDisplayName = nil
		if levelType == GameLevelType.kQixi then
			levelDisplayName = Localization:getInstance():getText('activity.qixi.fail.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kDigWeekly then
			levelDisplayName = Localization:getInstance():getText('weekly.race.panel.start.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kMayDay then
			levelDisplayName = Localization:getInstance():getText('activity.christmas.start.panel.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kRabbitWeekly then
			levelDisplayName = Localization:getInstance():getText('weekly.race.panel.rabbit.begin.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kSummerWeekly then
			levelDisplayName = Localization:getInstance():getText('weeklyrace.summer.panel.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kTaskForRecall or levelType == GameLevelType.kTaskForUnlockArea then
			levelDisplayName = Localization:getInstance():getText("recall_text_5")
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kWukong then
			levelDisplayName = Localization:getInstance():getText('春节关卡')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kOlympicEndless then
			levelDisplayName = "运动会关卡"
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kMidAutumn2018 then
			assert("false", "GameLevelType.kMidAutumn2018 failed???")
		elseif levelType == GameLevelType.kSpring2017 then
			levelDisplayName = Localization:getInstance():getText('国庆关卡')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)

		elseif self.levelType == GameLevelType.kSpring2019 then 
			require "zoo.localActivity.PigYear.PigYearStartGame"
			levelDisplayName = string.format("周年第%d关",self.levelId-PigYearStartGame.ACT_LEVEL_START)
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len, fntFile)
			if fntScale then panelTitle:setScale(fntScale) end

		else
			levelDisplayName = LevelMapManager.getInstance():getLevelDisplayName(levelId)
			panelTitle = PanelTitleLabel:create(levelDisplayName, nil, nil, nil, nil, nil, fntFile)
			if fntScale then panelTitle:setScale(fntScale) end
		end
	end
	return panelTitle
end

function LevelFailTopPanel:onCloseBtnTapped(event, ...)
	if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
		self.btnTappedState = self.BTN_TAPPED_STATE_CLOSE_BTN_TAPPED
	else
		return
	end

	local function onPopAnimFinish()
		self.parentPanel:exitGamePlaySceneUI()
	end
	self.parentPanel:remove(onPopAnimFinish)
end

function LevelFailTopPanel:onReplayBtnTapped(event, ...)
	assert(event)
	assert(#{...} == 0)

	if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
		self.btnTappedState = self.BTN_TAPPED_STATE_REPLAY_BTN_TAPPED
	else
		return
	end

	if not self.hasClickedReplay then
		self.hasClickedReplay = true
	else
		return
	end

	self.parentPanel:changeToStartGamePanel(false)
end

function LevelFailTopPanel:onQuestionMarkTapped(failReason)
	if failReason == 'refresh' then
		if self.levelType and self.levelType == GameLevelType.kWukong then 
			CommonTip:showTip(Localization:getInstance():getText("小猴子与同色动物三消\n也能攒能量哦~试着移动\n猴子吧！"), 'positive')
		else
			CommonTip:showTip(Localization:getInstance():getText('level.fail.animal.tips', {n = '\n'}), 'positive')
		end
	else
		assert(false, 'failReason not supported, Check you code!')
	end
end


function LevelFailTopPanel:closeTwoBtnAction()

	if self.isDisposed then return end
	if not self.newJumpBtn then
		return 
	end
	if not self.smallSubBtn_Left then
		return
	end
	if not self.smallSubBtn_Right then
		return
	end

	if not self.isOpenStatic then
		return 
	end


	if self.isMoveingAction then
		return 
	end


	self.isMoveingAction = true 

	local function animFinishCallback( ... )
		if self.isDisposed then return end
		self.isOpenStatic = false
		self.isMoveingAction = false 
	end

	local function animFinishCallback_Left( ... )
		if self.isDisposed then return end
		if self.smallSubBtn_Left then
			self.smallSubBtn_Left:removeFromParentAndCleanup(true)
			self.smallSubBtn_Left = nil
		end

	end

	local function animFinishCallback_Right( ... )
		if self.isDisposed then return end
		if self.smallSubBtn_Right then
			self.smallSubBtn_Right:removeFromParentAndCleanup(true)
			self.smallSubBtn_Right = nil
		end

		local scaleActionArray = CCArray:create()
		scaleActionArray:addObject( CCScaleTo:create(0.2 , 0.7) )
		scaleActionArray:addObject( CCScaleTo:create(0.2 , 1.0) )

		local spawnArray = CCArray:create()
		spawnArray:addObject( CCSequence:create(scaleActionArray) )
		spawnArray:addObject( CCFadeTo:create(0.4, 255)  )
		local spaw = CCSpawn:create( spawnArray )

		local actionArray = CCArray:create()
		actionArray:addObject( spaw )
		actionArray:addObject( CCCallFunc:create( animFinishCallback) )
		
		local seq = CCSequence:create(actionArray)
		self.newJumpBtn:runAction( seq )
	end
	local moveToLeftAction1 = CCArray:create()
	moveToLeftAction1:addObject( CCMoveBy:create(0.25, ccp(0, -10)) )
	local spawnArray2 = CCArray:create()
	spawnArray2:addObject( CCMoveBy:create(0.25, ccp(50, 80)) )
	spawnArray2:addObject( CCScaleTo:create(0.25, 0)  )
	moveToLeftAction1:addObject( CCSpawn:create( spawnArray2 ) )
	
	moveToLeftAction1:addObject( CCCallFunc:create( animFinishCallback_Left ) )
	self.smallSubBtn_Left:runAction( CCSequence:create( moveToLeftAction1 ) )
	local moveToLeftAction2 = CCArray:create()
	moveToLeftAction2:addObject( CCMoveBy:create(0.25, ccp(0, -10)) )
	local spawnArray3 = CCArray:create()
	spawnArray3:addObject( CCMoveBy:create(0.25, ccp(-50, 80)) )
	spawnArray3:addObject( CCScaleTo:create(0.25, 0)  )
	moveToLeftAction2:addObject(CCDelayTime:create( 0.05 ))
	moveToLeftAction2:addObject( CCSpawn:create( spawnArray3 ) )

	moveToLeftAction2:addObject( CCCallFunc:create( animFinishCallback_Right ) )
	self.smallSubBtn_Right:runAction( CCSequence:create( moveToLeftAction2 ) )
end



function LevelFailTopPanel:showTwoBtnAction()

	if self.isDisposed then return end

	if not self.newJumpBtn then
		return
	end
	if self.isOpenStatic then
		self:closeTwoBtnAction()
		return
	end

	if self.isMoveingAction then
		return 
	end

	self.isMoveingAction = true 
	--缩小变大 同时变浅颜色
	local scaleActionArray = CCArray:create()
	scaleActionArray:addObject( CCScaleTo:create(0.2 , 0.7) )
	scaleActionArray:addObject( CCScaleTo:create(0.2 , 1.0) )

	local spawnArray = CCArray:create()
	spawnArray:addObject( CCSequence:create(scaleActionArray) )
	spawnArray:addObject( CCFadeTo:create(0.4, 155)  )

	local spaw = CCSpawn:create( spawnArray )

	local function animFinishCallback( ... )

		local function animFinishCallback_Left( ... )

			if self.isDisposed then return end

		end

		local function animFinishCallback_Right( ... )
			if self.isDisposed then return end
			self.isMoveingAction = false 
			if self.darkLayerForGuide then
				local smallSubBtn_Right  = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/friendhelpicon_new0000" )
				self.darkLayerForGuide:addChild( smallSubBtn_Right )
				local worldPosition =  self.smallSubBtn_Right:getParent(): convertToWorldSpace(ccp(self.smallSubBtn_Right:getPositionX(),self.smallSubBtn_Right:getPositionY()))
				local nodePosition = self.darkLayerForGuide:convertToNodeSpace( ccp(worldPosition.x , worldPosition.y) )
				smallSubBtn_Right:setPositionXY( nodePosition.x , nodePosition.y )
				local boundsSize = self.smallSubBtn_Right:getGroupBounds().size
				smallSubBtn_Right:setScale( boundsSize.width / smallSubBtn_Right:getGroupBounds().size.width  )

			end
		end

		if self.isDisposed then return end

		if self.smallSubBtn_Left then
			self.smallSubBtn_Left:removeFromParentAndCleanup(true)
			self.smallSubBtn_Left = nil
		end
		if self.smallSubBtn_Right then
			self.smallSubBtn_Right:removeFromParentAndCleanup(true)
			self.smallSubBtn_Right = nil
		end
		local parent = self.newJumpBtn:getParent()
		self.smallSubBtn_Left = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/jump_level_icon_new0000" )
		parent:addChild( self.smallSubBtn_Left )
		self.smallSubBtn_Left:setPositionXY( self.newJumpBtn:getPositionX() , self.newJumpBtn:getPositionY() )
		self.smallSubBtn_Left:setScale(0)

		self.smallSubBtn_Right = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/friendhelpicon_new0000" )
		parent:addChild( self.smallSubBtn_Right )
		self.smallSubBtn_Right:setPositionXY( self.newJumpBtn:getPositionX() , self.newJumpBtn:getPositionY() )
		self.smallSubBtn_Right:setScale(0)

		local moveToLeftAction1 = CCArray:create()
		moveToLeftAction1:addObject(CCDelayTime:create( 0.05 ))

		local spawnArray2 = CCArray:create()
		spawnArray2:addObject( CCMoveBy:create(0.25, ccp(-50, -80)) )
		spawnArray2:addObject( CCScaleTo:create(0.25, 1)  )

		moveToLeftAction1:addObject( CCSpawn:create( spawnArray2 ) )
		moveToLeftAction1:addObject( CCMoveBy:create(0.25, ccp(0, 10)) )
		moveToLeftAction1:addObject( CCCallFunc:create( animFinishCallback_Left ) )
		self.smallSubBtn_Left:runAction( CCSequence:create( moveToLeftAction1 ) )

		local moveToLeftAction2 = CCArray:create()

		local spawnArray3 = CCArray:create()
		spawnArray3:addObject( CCMoveBy:create(0.25, ccp(50, -80)) )
		spawnArray3:addObject( CCScaleTo:create(0.25, 1)  )

		moveToLeftAction2:addObject( CCSpawn:create( spawnArray3 ) )
		moveToLeftAction2:addObject( CCMoveBy:create(0.25, ccp(0, 10)) )
		moveToLeftAction2:addObject( CCCallFunc:create( animFinishCallback_Right ) )
		self.smallSubBtn_Right:runAction( CCSequence:create( moveToLeftAction2 ) )

		
		UIUtils:setTouchHandler(  self.smallSubBtn_Left  , function ()
			if self.isDisposed then return end
	        if self.jumpLevelArea and self.jumpLevelArea.onTapped then
				self.jumpLevelArea:onTapped()
			end
	     end)

		UIUtils:setTouchHandler(  self.smallSubBtn_Right  , function ()
			if self.isDisposed then return end
			self:doAskForHelp()
	     end)

	end 

	local actionArray = CCArray:create()
	actionArray:addObject( spaw )
	actionArray:addObject( CCCallFunc:create( animFinishCallback) )
	

	local seq = CCSequence:create(actionArray)
	self.newJumpBtn:runAction( seq )
	


	self.isOpenStatic = true
end
--优化开始面板UI，整合跳关与好友代打icon，去掉原添加好友气泡。
function LevelFailTopPanel:shouldShowTwoBtnType( ... )

	local num = 0
	local showJump = JumpLevelManager:getInstance():shouldShowJumpLevelIcon(self.levelId)
	local showAsk = AskForHelpManager.getInstance():shouldShowFuncIcon(self.levelId)
	if showJump and showAsk then
		return 3
	elseif showJump then
		return 2
	elseif showAsk then
		return 1
	end
	return num
end



function LevelFailTopPanel:initJumpLevelArea( zCur )
	-- body
	local area = self.ui:getChildByName("jump_level_area")
	local pos = area:getPosition()

	pos = ccp(pos.x + 7, pos.y + 35)

	-- isFakeIcon31-39关可见跳关按钮，但并走真正的逻辑
	-- 只是弹出tip提示xx关开启跳关功能
	local isFakeIcon = JumpLevelManager:shouldShowFakeIcon(self.levelId)
	if self:shouldShowTwoBtnType()>0 then
		FrameLoader:loadImageWithPlist("ui/gamestaradd/panel_game_start_add.plist")
		if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
			FrameLoader:loadArmature('skeleton/jump_level_btn_animation_purple', 'jump_level_btn_animation_purple')
		elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then 
			FrameLoader:loadArmature('skeleton/jump_level_btn_animation_blue', 'jump_level_btn_animation_blue')
		else
			if self.uncommonSkin then
				FrameLoader:loadArmature('skeleton/spring/jump_level_btn_animation', 'jump_level_btn_animation', 'jump_level_btn_animation')
			else
				FrameLoader:loadArmature('skeleton/jump_level_btn_animation', 'jump_level_btn_animation')
			end
		end

		local armature = nil
		if isFakeIcon and self:shouldShowTwoBtnType() == 2 then
			armature = ArmatureNode:create('skip2', true)
		else
			armature = ArmatureNode:create('skip', true)
		end

		local slot = armature:getSlot("skipbubble")
		if slot then
			if self.newJumpBtn then
				self.newJumpBtn:removeFromParentAndCleanup(true)
				self.newJumpBtn = nil
			end
			local spriteBtn = nil
			if self:shouldShowTwoBtnType() == 3 then
				if self.uncommonSkin then
					spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "spring_2019/jump_level_btn0000" )
				else
					spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/jump_level_btn0000" )
				end
				spriteBtn.name = "jumptwobtn"
				LevelPanelDifficultyChanger:changeNodeByDifficulty( spriteBtn ,self.levelFlag )
			elseif JumpLevelManager:getInstance():shouldShowJumpLevelIcon(self.levelId) then
				if self.uncommonSkin then
				 	spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "spring_2019/jump_level_icon_new0000" )
				else
					spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/jump_level_icon_new0000" )
				end
			else
				if self.uncommonSkin then
				 	spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "spring_2019/friendhelpicon_new0000" )
				else
					spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/friendhelpicon_new0000" )
				end
			end
			self.newJumpBtn = spriteBtn
			if self.uncommonSkin then
			 	spriteBtn:setPositionXY(69.5,-26.5)
			else
				spriteBtn:setPositionXY(60,-50)
			end
			local sprite = Sprite:createEmpty()
			sprite:addChild(spriteBtn)
			slot:setDisplayImage(sprite.refCocosObj)
		end
		armature:playByIndex(0, 1)
		armature:update(0.001)
		armature:stop()
		self.jumpLevelIconArmature = armature
		local layer = Layer:create()
		layer:addChild(armature)
		
		self.jumpLevelAreaLayer = layer
		area:getParent():addChildAt(layer, area:getZOrder())
		layer:setPosition(ccp(pos.x, pos.y))
		self.jumpLevelArea = JumpLevelIcon:create(layer, self.levelId, self.levelType, nil, isFakeIcon,self)

		local function onTapped(evt)
			if self.isDisposed then return end		
			if self:shouldShowTwoBtnType() == 3 then
				self:showTwoBtnAction()
			elseif JumpLevelManager:getInstance():shouldShowJumpLevelIcon(self.levelId) then
				if self.jumpLevelArea.onTapped then
					self.jumpLevelArea:onTapped()
				end
			else
				self:doAskForHelp()
			end
		end

		self.jumpLevelArea:setJumpCallBack( onTapped )

		area:setVisible(false)

		armature:addEventListener(ArmatureEvents.COMPLETE, function ()
			if self.isDisposed then return end	
			if self.autoOpenForGuide then
				self:showTwoBtnAction()
				self.autoOpenForGuide = false
			end
		end)

		

	else
		area:setVisible(false)
	end
end

function LevelFailTopPanel:doAskForHelp()

	if self.isDisposed then return end	
	local function onPropInfoPanelClosed()
		if self.isDisposed then return end	
		self.parentPanel:setRankListPanelTouchEnable()
	end
	self.parentPanel:setRankListPanelTouchDisable()

	local friends = FriendManager.getInstance().friends or {}
	if table.size(friends) <= 0 then
		return AskForHelpManager.getInstance():onHelpless( onPropInfoPanelClosed )
	end	
	DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'trigger_icon', t1=self.levelId, t2=(evt and 2) or 1})
	AskForHelpManager.getInstance():onAskForHelp(self.levelId, self.parentPanel, forcePopout == true)

end

	

-- 好友代打
function LevelFailTopPanel:initAskForHelpArea( ... )

	local showIcon = AskForHelpManager.getInstance():shouldShowFuncIcon(self.levelId)
	if not showIcon then return end

	-- body
	local stub = self.ui:getChildByName("askForHelpStub")
	local stubZ = stub:getZOrder()
	local stubP = stub:getPosition()

	-- flagButton
	local szTouch = CCSizeMake(200, 200)
    --local askForHelpBtn = LayerColor:createWithColor(ccc3(0, 0, 0), szTouch.width, szTouch.height)

	FrameLoader:loadArmature("skeleton/AskForHelp/askforhelper_animation")
    local animFlag = ArmatureNode:create("AskForHelp/interface/AskForHelpButton", true)
	animFlag:playByIndex(0, 0)
	animFlag:setAnchorPoint(ccp(0.5, 0.5))
	animFlag:setPosition(ccp(stubP.x-szTouch.width/2, stubP.y+szTouch.height/2))
	animFlag.refCocosObj:setZOrder(stubZ)
	self.ui:addChild(animFlag)
    self.animFlag = animFlag

    self.animFlag:setVisible(false)

	local askForHelpBtn = Layer:create()
	askForHelpBtn:setContentSize(CCSizeMake(szTouch.width, szTouch.height))
    self.ui:addChild(askForHelpBtn)
	askForHelpBtn:setAnchorPoint(ccp(0.5, 0.5))
	askForHelpBtn:setPosition(ccp(stubP.x-szTouch.width/2, stubP.y-szTouch.height/2))
	askForHelpBtn.refCocosObj:setZOrder(stubZ)
	
	stub:removeFromParentAndCleanup()

	local function onAskForHelpTapped(evt, forcePopout)
		DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'trigger_icon', t1=self.levelId, t2=(evt and 2) or 1})
		AskForHelpManager.getInstance():onAskForHelp(self.levelId, self.parentPanel, forcePopout == true)
	end
    askForHelpBtn:setTouchEnabled(true)
    -- askForHelpBtn:addEventListener(DisplayEvents.kTouchTap, onAskForHelpTapped)

	-- 强弹
	local function tryPopout()
		local needPopout = AskForHelpManager.getInstance():needPopout(self.levelId)
		if needPopout then
			onAskForHelpTapped({}, true)
		end
	end

	if AskForHelpManager.getInstance():needGuidance(kAskForHelpGuideEnum.EGUIDE_FAILLEVEL)  then
		-- ask for help user guide
		local kDarkOpacity = 150
		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local visibleSize =  Director:sharedDirector():getVisibleSize()
		local winSize = CCDirector:sharedDirector():getWinSize()

		local ptOri = self.ui:convertToNodeSpace(ccp(0, 0))

		local animFinished = false
		local clippingAreaAboveZOrder = self.clippingAreaAbove.refCocosObj:getZOrder()

		local darkLayer = LayerColor:createWithColor(ccc3(0, 0, 0), winSize.width*1024, winSize.height*1024)
        self.ui:addChild(darkLayer)

		function darkLayer:hitTestPoint( worldPosition, useGroupTest )
			return true
		end
		self.parentPanel:setRankListPanelTouchDisable()
		darkLayer:addEventListener(DisplayEvents.kTouchTap, function( ... )
			if animFinished then
				AskForHelpManager.getInstance():setHasGuidanced(kAskForHelpGuideEnum.EGUIDE_FAILLEVEL)
				self.clippingAreaAbove.refCocosObj:setZOrder(clippingAreaAboveZOrder)
				
				darkLayer:removeFromParentAndCleanup()
				self.avatar:removeFromParentAndCleanup()

				self.parentPanel:setRankListPanelTouchEnable()
				self.darkLayerForGuide = nil
				-- 引导后强弹
				tryPopout()
			end
		end)
		darkLayer:setTouchEnabled(true, 0, true)
        darkLayer:setAnchorPoint(ccp(0, 0))
		darkLayer:setOpacity(kDarkOpacity)
		darkLayer:setPosition(ccp(ptOri.x, ptOri.y))

		FrameLoader:loadArmature("skeleton/AskForHelp/askforhelper_animation")
		local avatar = ArmatureNode:create("AskForHelp/interface/Guide")
		self.ui:addChild(avatar)
		avatar:setPosition(ccp(260, -150))
		self.avatar = avatar
		self.avatar:playByIndex(0, 1)
		avatar:addEventListener(ArmatureEvents.COMPLETE, function( ... )
    		animFinished = true
    	end)

		local zCur = darkLayer.refCocosObj:getZOrder()

		self.darkLayerForGuide = darkLayer
		if self:shouldShowTwoBtnType() == 3 then
			
			--默认给打开
			-- self:showTwoBtnAction()
			self.autoOpenForGuide = true
		else
			if self.jumpLevelAreaLayer then
				self.jumpLevelAreaLayer.refCocosObj:setZOrder(zCur)
			end
		end
		

		

	else
		tryPopout()
	end
end

function LevelFailTopPanel:dispose()
	BasePanel.dispose(self)
	FrameLoader:unloadArmature('skeleton/AskForHelp/askforhelper_animation', true)
    if DragonBuffManager.getInstance():shouldShowActCollection(self.levelId) then
		DragonBuffManager.getInstance():unloadSkeletonAssert()
	end

    if Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(self.levelId) then
		Thanksgiving2018CollectManager.getInstance():unloadSkeletonAssert()
	end

	if PublicServiceManager:shouldShowActCollection(self.levelId) then
		PublicServiceManager:unloadSkeletonAssert()
	end
	FrameLoader:unloadArmature('skeleton/jump_level_btn_animation_purple', true)
	FrameLoader:unloadArmature('skeleton/jump_level_btn_animation_blue', true)
	FrameLoader:unloadArmature('skeleton/jump_level_btn_animation',true)
	FrameLoader:unloadImageWithPlists("ui/gamestaradd/panel_game_start_add.plist")
	PreBuffLogic:unloadLevelInfoSkeletonAssert()
end

function LevelFailTopPanel:create(parentPanel, levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove, ...)

	-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
	-- if not (FTWLocalLogic:isActEnabled()) then
	-- 	NextLevelButtonProxy:getInstance():setFindTheWayEnabled(false)
	-- end

	-- FTWLocalLogic:onLevelEnd()
	
	-- assert(type(parentPanel) 	== "table")
	-- assert(type(levelId) 		== "number")
	-- assert(type(levelType) 		== "number")
	-- assert(type(failScore) 		== "number")
	-- assert(type(failStar) 		== "number")
	-- assert(type(isTargetReached)	== "boolean")
	--assert(levelModeTypeId)

	local newLevelFailTopPanel = LevelFailTopPanel.new()
	newLevelFailTopPanel:init(parentPanel, levelId, levelType, failScore, failStar, isTargetReached, failReason, stageTime, costMove)
	return newLevelFailTopPanel
end

function LevelFailTopPanel:afterPopout()
	if self.jumpLevelIconArmature then
		self.jumpLevelIconArmature:playByIndex(0, 1)
	end

    self:initAskForHelpArea()

	local QixiManager = require 'zoo.eggs.QixiManager'
	if QixiManager:getInstance():shouldSeeRose() then
		if self.promotionLayer or self.hasPushActivity then
			CommonTip:showTip(localize('qixi.in.package.get.rose'), 'positive')
		else
			local anim = WinAnimation:createQixi2017Anim(2)
			self.laborTopAnim = anim
			self.ui:addChildAt(self.laborTopAnim, 2)
			anim:play(0)
			anim:setPosition(ccp(350, -360))
		end
	elseif PublicServiceManager:shouldShowActCollection(self.levelId) then
		local anim = WinAnimation:createPublicServiceAni(2)
		self.ui:addChildAt(anim, 4)
		anim:play(0)
		anim:setPosition(ccp(350, -350))

		local ActCollectionPanel = require 'zoo.localActivity.PublicService.ActCollectionPanel'
		local panel = ActCollectionPanel:create(2)
		panel:setPosition(ccp(490, -280))
		self.tipNode:addChild(panel)
		panel:playShowAni()

	elseif not self.hasSthShowOnTopPart and CountdownPartyManager.getInstance():shouldShowActCollection(self.levelId) then
		local anim = WinAnimation:createCountdownPartyAni(2)
		self.ui:addChildAt(anim, 4)
		anim:play(0)
		anim:setPosition(ccp(350, -350))

		local ActCollectionPanel = require 'zoo.localActivity.CountdownParty.ActCollectionPanel'
		local countdownPartyPanel = ActCollectionPanel:create(2)
		countdownPartyPanel:setPosition(ccp(490, -280))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()

    elseif not self.hasSthShowOnTopPart and Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(self.levelId) then
		local anim = WinAnimation:createCountdownPartyAni(2)
		self.ui:addChildAt(anim, 4)
		anim:play(0)
		anim:setPosition(ccp(350, -350))

		local Thanksgiving2018CollectPanel = require 'zoo.localActivity.Thanksgiving2018.Thanksgiving2018CollectPanel'
		local countdownPartyPanel = Thanksgiving2018CollectPanel:create(2)
		countdownPartyPanel:setPosition(ccp(490, -280))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()


        --隐藏绳子
        for i=1, 4 do
            local line	= self.ui:getChildByName("line"..i)

            if line then
                line:setVisible(false)
            end
        end
    elseif RecallA2019Manager.getInstance():getActStartPanelBubble() then
		local ActCollectionPanel = require 'zoo.localActivity.RecallA2019.RecallA2019CollectionPanel'
		local countdownPartyPanel = ActCollectionPanel:create(2)
		countdownPartyPanel:setPosition(ccp(490, -280))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()
	end


	

	local function _prebuffAnim( done )
		if PreBuffLogic:checkEnableBuff( self.levelId )  then
			
			local hasUpgrade = PreBuffLogic:getBuffUpgradeOnLastPlayForLevelInfo()
			local buffLevel = PreBuffLogic:getBuffGradeAndConfig()
			-- self.buffLevel = buffLevel
			PreBuffLogic:loadLevelInfoSkeletonAssert()
			local oldLevel = PreBuffLogic:getOldGrade()
			if oldLevel and oldLevel > 0 and buffLevel == 0   then
			
				local animNode = ArmatureNode:create("PreBuffLogic_up/showAction_dis")
				self.ui:addChild( animNode )
				animNode:setPositionX( 440 )
				animNode:setPositionY( -755 )
				animNode:playByIndex(0, 1)
				local enmpySprite1 = Sprite:createEmpty()
				if oldLevel > 0 then
					local png1 = Sprite:createWithSpriteFrameName( "PreBuff002Png/png"..(oldLevel).."0000" )
					enmpySprite1:addChild( png1 )
					png1:setPosition(ccp( 35, -35 ))
					PreBuffLogic:setBuffUpgradeOnLastPlayForLevelInfo( false )
				end
				local slot1 = animNode:getSlot( "png1" )
				slot1:setDisplayImage( enmpySprite1.refCocosObj )
				local function onFinished()
					PreBuffLogic:doBuffDisappear()
					done()
				end 
				animNode:addEventListener( ArmatureEvents.COMPLETE , onFinished )
			else
				done()
			end
		else
			done()
		end
	end


	local function popOtherAnim( ... )
		if self.isDisposed then return end

		local Misc = require('zoo.quarterlyRankRace.utils.Misc')
		local asyncRunner = Misc.AsyncFuncRunner.new()

		for _, elem in ipairs(self.tailAnimQueue or {}) do
			local checker = elem[1]
			local worker = elem[2]
			if checker() then
				asyncRunner:add(function ( done )
					if self.isDisposed then return end
					if self._willDisposed then return end
					worker(done)
				end)			
			end
		end
		asyncRunner:add(_prebuffAnim)
		asyncRunner:run()
	end

	popOtherAnim()
end


function LevelFailTopPanel:processTailAnimationQueue( ... )
	self.tailAnimQueue = {}
	self.tailAnimQueue.push = function ( _, elem )
		table.insert(self.tailAnimQueue, elem)
	end
	-- 任务系统
	self.tailAnimQueue:push{function ( ... )
		return (require 'zoo.quest.QuestActLogic'):isActEnabled()
	end, function ( done )
		_G.QuestChangeContext:getInstance():popTip(done)
	end}

	-- 无限精力任务
	self.tailAnimQueue:push{function ( ... )
		local EnergyActQuestManager = require 'zoo.quest.module.energyACT.EnergyActQuestManager'
		local energyActMgr = EnergyActQuestManager:getInstance()
		if energyActMgr:isActEnabled() then
			if energyActMgr:hasRewards() and energyActMgr:needShowRewardsPanel() then
				return true
			end
		end
	end, function ( done )
		local EnergyActQuestManager = require 'zoo.quest.module.energyACT.EnergyActQuestManager'
		local energyActMgr = EnergyActQuestManager:getInstance()
		energyActMgr:popRewardsPanel(done)
	end}
end


function LevelFailTopPanel:getFailResonAndDes(levelId, failReason, isTargetReached)
	local failReasonType = nil
	local failDesValue = false
	local levelGameData	= LevelMapManager.getInstance():getMeta(levelId).gameData
	local gameModeName	= levelGameData.gameModeName

	-- 刷新出错导致的失败，优先级最高
	if failReason == 'refresh' then
		failDesKey	= "level.fail.animal.effect.mode"
		failDesValue = Localization:getInstance():getText('level.fail.animal.effect.mode', {})
		failReasonType = FailReason.noMatch
	elseif isTargetReached then
		local failDesKey
		if gameModeName == GameModeType.CLASSIC then failDesKey = "level.fail.time.mode"
		else failDesKey	= "level.fail.score.not.reached" end
		failDesValue = Localization:getInstance():getText(failDesKey, {})
		failReasonType = FailReason.score
	else
		if gameModeName == GameModeType.CLASSIC_MOVES then
			failDesKey	= "level.fail.step.mode"
			failReasonType = FailReason.score
		elseif gameModeName == GameModeType.CLASSIC then
			failDesKey	= "level.fail.time.mode"
			failReasonType = FailReason.time
		elseif gameModeName == GameModeType.DROP_DOWN then
			failDesKey	= "level.fail.drop.mode"
			failReasonType = FailReason.move
		elseif gameModeName == GameModeType.TASK_UNLOCK_DROP_DOWN then 
			failDesKey = "level.fail.drop.key.mode"
			failReasonType = FailReason.move
		elseif gameModeName == GameModeType.LIGHT_UP then
			failDesKey	= "level.fail.ice.mode"
			failReasonType = FailReason.move
		elseif gameModeName == GameModeType.DIG_MOVE then
			failDesKey	= "level.fail.dig.step.mode"
			failReasonType = FailReason.move
		elseif gameModeName == GameModeType.ORDER or gameModeName == GameModeType.SEA_ORDER then
			local function getOrderType(str) return string.sub(str, 1, string.find(str, '_') - 1) end
			if levelGameData.orderList and #levelGameData.orderList > 0 then
				local orderType, isMatch = tonumber(getOrderType(levelGameData.orderList[1].k)), true
				if orderType == 2 or orderType == 3 then
					for k, v in ipairs(levelGameData.orderList) do
						if tonumber(getOrderType(v.k)) ~= orderType then
							failDesKey = "level.fail.objective.mode"
							isMatch = false
							break
						end
					end
					if isMatch then
						if orderType == 2 then failDesKey = "level.fail.eliminate.effect.mode"
						elseif orderType == 3 then failDesKey = "level.fail.swap.effect.mode" end
					end
				else failDesKey = "level.fail.objective.mode" end
			else failDesKey = "level.fail.objective.mode" end

			-- 由gameMode指定的failReason,属于特殊的失败原因类型
			if failReason == 'venom' then 
				failDesKey = 'level.fail.venom.effect.mode' 
				failReasonType = FailReason.venom
			else
				failReasonType = FailReason.move
			end
		elseif gameModeName == GameModeType.DIG_MOVE_ENDLESS then
			failDesKey	= "level.fail.dig.endless.mode"
			failReasonType = FailReason.score
		elseif gameModeName == GameModeType.RABBIT_WEEKLY then
			failDesKey	= "level.fail.dig.endless.mode"
			failReasonType = FailReason.score
		elseif gameModeName == GameModeType.MAYDAY_ENDLESS or gameModeName == GameModeType.HALLOWEEN 
				or gameModeName == GameModeType.HEDGEHOG_DIG_ENDLESS or gameModeName == GameModeType.WUKONG_DIG_ENDLESS then
			failDesKey	= "level.fail.mayday.endless.mode"
			failReasonType = FailReason.score
		elseif gameModeName == GameModeType.LOTUS then
			failDesKey	= "level.fail.meadow.mode"
			failReasonType = FailReason.lotus
		elseif gameModeName == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS then
			failDesKey	= "level.fail.mayday.endless.mode"
			failReasonType = FailReason.score
        elseif gameModeName == GameModeType.JAM_SPERAD then
			failDesKey	= "level.fail.mayday.endless.mode"
			failReasonType = FailReason.move
		else
			if _G.isLocalDevelopMode then printx(0, "levelModeTypeId: " .. tostring(self.levelModeTypeId)) end
			assert(false, "not implemented !")
		end
		failDesValue = Localization:getInstance():getText(failDesKey, {})
	end
	return failReasonType, failDesValue
end


function LevelFailTopPanel:levelDiffcultFlagVisable(  )
	
	LevelPanelDifficultyChanger:changeBgByDifficulty(self,self.levelFlag,HomeScenePanelSkinType.kLevelFailTopPanel)
	--如果有打折的面板 那么设置对应关卡难度标记的颜色
	if self.promotionTopPanel then
		LevelPanelDifficultyChanger:changeBgByDifficulty( self.promotionTopPanel ,self.levelFlag,HomeScenePanelSkinType.kLevelFailTopPanel)
	end
	
end
