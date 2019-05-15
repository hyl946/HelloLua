
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月13日 16:46:49
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com
require "zoo.panel.component.startGamePanel.PreGameToolItem"
require "zoo.scenes.GamePlaySceneUI"
require "zoo.scenes.NewGamePlaySceneUI"
require "zoo.panel.basePanel.PanelWithContentAnim"
require "zoo.panel.basePanel.PanelShowHideProtocol"
require "zoo.panelBusLogic.StartLevelLogic"
require "zoo.panelBusLogic.NewStartLevelLogic"
require "zoo.panel.component.startGamePanel.LevelTarget"
require "zoo.panel.component.common.PanelTitleLabel"
require "zoo.panel.component.startGamePanel.StartGameButton"
require "zoo.panel.component.LevelPanelDifficultyChanger"

require "zoo.panel.component.common.BubbleCloseBtn"
require "zoo.util.QixiUtil"
require "zoo.panel.jumpLevel.JumpLevelIcon"

require "zoo.localActivity.PigYear.PigYearStartGame"


-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
local UIHelper = require 'zoo.panel.UIHelper'

---------------------------------------------------
-------------- LevelInfoPanel
---------------------------------------------------
LevelInfoPanel = class(BasePanel)

function LevelInfoPanel:init(parentPanel, levelId, levelType, startLevelType, ...)

	Notify:register('PigYearStartGameCreate', self.onPigYearStartGameCreate, self )

	if CountdownPartyManager.getInstance():shouldShowActCollection(levelId) then
		CountdownPartyManager.getInstance():loadSkeletonAssert()
	end

	self.isLoadLevelInfoSkeletonAssert_Collect = false
	if CollectStarsManager.getInstance():canShowTitle(levelId ,startLevelType ,true ) then
		self.isLoadLevelInfoSkeletonAssert_Collect = true
		CollectStarsManager.getInstance():loadLevelInfoSkeletonAssert()
	end
	CollectStarsManager.getInstance():setIsActivationBuff( true ) 
    Thanksgiving2018CollectManager.getInstance():updateUserState()
    if Thanksgiving2018CollectManager.getInstance():shouldShowActCollection(levelId) then
		Thanksgiving2018CollectManager.getInstance():loadSkeletonAssert()
	end

	FrameLoader:loadImageWithPlist("ui/gamestaradd/panel_game_start_add.plist")
	self.panelLuaName = "LevelInfoPanel"
	-- Get UI Resource
	self.resourceManager	= ResourceManager:sharedInstance()

	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelInfoPanel)
	self.uncommonSkin = uncommonSkin
	self.ui = ResourceManager:sharedInstance():buildGroup(skinName)
	self.levelFlag ,self.isFirst = MetaManager:getInstance():getLevelDifficultFlag_ForStartPanel( levelId )
	if self.uncommonSkin then
		self.skinLevelFlag = self.levelFlag
		self.levelFlag = LevelDiffcultFlag.kNormal
		self.isFirst = false
		self:hanleForSkin()
	end

	BasePanel.init(self, self.ui)

	self.tipNode = CocosObject.new(CCNode:create())
	self.ui:addChild(self.tipNode)
	
	if self.levelFlag ~= LevelDiffcultFlag.kNormal then
		FrameLoader:loadArmature('skeleton/LevelDiffcultFlag/level_tips2', 'level_tips', 'level_tips')
	end

	-- -----------------
	-- Init Base Class
	-- -------------------


	---------------------
	-- Additional Layer To Play User Guide
	-- -----------------------------------
	self.userGuideLayer	= Layer:create()
	self:addChild(self.userGuideLayer)

	-- ------------------
	-- Get UI Resource
	-- ------------------
	self.fadeArea		= self.ui:getChildByName("fadeArea")
	self.clippingAreaAbove	= self.ui:getChildByName("clippingAreaAbove_new")
	self.clippingAreaBelow	= self.ui:getChildByName("clippingAreaBelow")
	assert(self.fadeArea)
	assert(self.clippingAreaAbove)
	assert(self.clippingAreaBelow)

	-- 老素材隐藏
	local newClippingAreaAbove	= self.ui:getChildByName("clippingAreaAbove")
	if newClippingAreaAbove then
		newClippingAreaAbove:setVisible(false)
	end

	self.levelLabelPlaceholder		= self.ui:getChildByName("levelLabelPlaceholder")

	-- In Fade Area
	self.targetDesLabel			= self.fadeArea:getChildByName("targetDesLabel")
	self.targetIconPlaceholder		= self.fadeArea:getChildByName("targetIconPlaceholder")

	-- In Clipping Area Above
	-- self.chooseItemLabel			= self.clippingAreaAbove:getChildByName("chooseItemLabel")

	-- In Clipping Area Below
	self.startButton			= self.clippingAreaBelow:getChildByName("startButton")
	--self.clippingAreaBelowBG			= self.clippingAreaBelow:getChildByName("rectBG")
	--self.clippingAreaBelowBG:setVisible(false)

	self.helpIcon			= self.clippingAreaAbove:getChildByName("helpIcon")

	-- Get Close Button
	self.bg				= self.ui:getChildByName("bg")
	self.closeBtnRes		= self.ui:getChildByName("closeBtn")

	-- Init Resource InVisible
	-- for index = 1, #self.preGameToolResource do
	-- 	self.preGameToolResource[index]:setVisible(false)
	-- end

	-----------------------
	-- Init UI Component
	-- --------------------
	self.targetIconPlaceholder:setVisible(false)
	self.levelLabelPlaceholder:setVisible(false)

	-------------------------
	--- Get Data About UI
	-------------------------
	local targetIconPlaceholderPos	= self.targetIconPlaceholder:getPosition()
	local levelLabelPlaceholderPosY	= self.levelLabelPlaceholder:getPositionY()

	--------------------
	----- Data
	---------------------
	self.parentPanel 		= parentPanel
	self.levelId 			= levelId
	self.startLevelType     = startLevelType
	self.totalSubtractedCoin 	= 0
	self.levelType 			= levelType

	-- If Playing Flying Selected Item Anim
	self.isPlayingFlyingSelectedItemAnim	= true

	-- Flag To Indicate Tapped State
	self.TAPPED_STATE_START_BTN_TAPPED	= 1
	self.TAPPED_STATE_CLOSE_BTN_TAPPED	= 2
	self.TAPPED_STATE_NONE			= 3
	self.tappedState			= self.TAPPED_STATE_NONE


	---- Get Current Level Data
	self.metaModel = MetaModel:sharedInstance()
	self.metaManager = MetaManager.getInstance()

	-- Current Level Mode Id
	self.levelModeTypeId = self.metaModel:getLevelModeTypeId(self.levelId)
	assert(self.levelModeTypeId)
	
	-- Pre Game Tool
	local initialProps = PrePropImproveLogic:getInitialProps(self.levelId, true)--newInitialProps
	assert(initialProps)

	self:initPreGameTools(initialProps)

	-- -----------------------
	-- Level Mode And Target
	-- ------------------------
	local levelMeta = LevelMapManager.getInstance():getMeta(self.levelId)
	local levelGameData 
	if levelMeta then
		levelGameData = levelMeta.gameData
	else
		he_log_error("LevelInfoPanel levelMeta is nil:" .. tostring(self.levelId))
	end
	assert(levelGameData)

	local gameModeName = levelGameData.gameModeName
	assert(gameModeName)

	local orderList		= levelGameData.orderList

	--------------------------
	--- Create UI Component 
	---------------------------
	-- Start Button

	self.startButton	= StartGameButton:create(self.startButton)
	
	if CollectStarsYEMgr.getInstance():isBuffEffective(self.levelId, self.startLevelType) then
		self.startButton:showActInfiniteEnergy(true)
	end
	
	if self.uncommonSkin then
		self.closeBtn = {}
		self.closeBtn.ui = self.closeBtnRes
		self.closeBtn.ui:setButtonMode(true)
		self.closeBtn.ui:setTouchEnabled(true)
	else
		self.closeBtn = BubbleCloseBtn:create(self.closeBtnRes)
	end

	-- Pre Game Tools
	local isShowFlash = PrePropImproveLogic:isShowFlash(self.levelId)
	if isShowFlash then
		FrameLoader:loadImageWithPlist("flash/bubble_flash.plist")
	end

	self.preGameTools = {}
	local hasPrivilegeFreeItem = false 
	for index = 1, #initialProps do
		self.preGameToolResource[index]:setVisible(true)
		if PublishActUtil:isGroundPublish() then 
			self.preGameTools[index] = PreGameToolItem:create(self.preGameToolResource[index], initialProps[index].propId, 400 )
			self.preGameTools[index]:setSelected(true)
		else
			self.preGameTools[index] = PreGameToolItem:create(self.preGameToolResource[index], initialProps[index].propId, self.levelId )
		end

		if isShowFlash then
			self.preGameTools[index]:showLightFlash()
		end

		if initialProps[index].privilegeFree then 
			hasPrivilegeFreeItem = true
			self.preGameTools[index]:setIsPrivilegeFree(true)
		end
		-------------- qixi ----------------------
		-- local isFreeItem = false -- qixi
		-- if QixiUtil:hasCompeleted() then
		-- 	local remainingCount = QixiUtil:getRemainingFreeItem(initialProps[index].propId)
		-- 	if _G.isLocalDevelopMode then printx(0, '-------', initialProps[index].propId, remainingCount) end
		-- 	isFreeItem = (remainingCount > 0)
		-- end

		-- if isFreeItem then 
		-- 	self.preGameTools[index]:setFreePrice()
		-- 	self.preGameTools[index]:updatePriceColor()
		-- end
		---------------- end qixi ----------------
	end

	self:checkPreMagicBirdDiscountAct()

	-- self:initPreGameTools 时已经处理了自动勾选，所以这时preGameTools选中的都是有剩余数量，且会自动带进关卡里的道具
	GamePreStartContext:getInstance():initPreProps( self.preGameTools , initialProps )

	self:updateFreeItemAniShow()

	if self:canShowPrePropVideoAd() then
		if #self.preGameTools <= 3 then
			self.preItemsScrollable:scrollToRightOffset(0, 180)
		else
			self.preItemsScrollable:scrollToRightEnd()
		end
		self.needRunVideoAdAction = true
	end

	if hasPrivilegeFreeItem then 
		local isEffective, _, leftMesc = PrivilegeMgr.getInstance():isPrivilegeEffctive(PrivilegeType.kPreProp)
		if isEffective and leftMesc <= 10 * 60 * 1000 then 
			self:showToastTip(0.5, "召回特权将要过期啦！")
		end
	end

	-- Level Target
	local levelTarget		= LevelTarget:create(gameModeName, orderList)
	local levelTargetSize		= levelTarget:getGroupBounds().size
	local targetIconPlaceholderSize = self.targetIconPlaceholder:getGroupBounds().size

	local deltaWidth	= targetIconPlaceholderSize.width - levelTargetSize.width
	local deltaHeight	= targetIconPlaceholderSize.height - levelTargetSize.height
	local halfDeltaWidth	= deltaWidth / 2
	local halfDeltaHeight	= deltaHeight / 2

	local posX = targetIconPlaceholderPos.x + halfDeltaWidth
	local posY = targetIconPlaceholderPos.y - halfDeltaHeight

	levelTarget:setPosition(ccp(posX, posY))
	self.fadeArea:addChild(levelTarget)
	self.levelTarget = levelTarget

	-------------------------
	---- Add Event Listener
	-------------------------

	local touchMoved = false
	local function onPreGameItemMoveOut(event, ...)
		if touchMoved then return end
		self:onPreGameItemMoveOut(event)
	end

	local function onPreGameItemMoveIn(event, ...)
		if touchMoved then return end
		self:onPreGameItemMoveIn(event)
	end

	local function onPreGameItemTouchBegin(event, ...)
		self.lastBubbleTouchBeginPos = ccp( event.globalPosition.x , event.globalPosition.y )
		touchMoved = false
		self:onPreGameItemTouchBegin(event)
	end

	local function onPreGameItemTapped(event, ...)
		if touchMoved then return end
		if self.clippingAreaAbove:hitTestPoint(event.globalPosition, true) then
			self:onPreGameItemTapped(event)
		end
	end

	local function onPreGameItemTouchMoved(event, ...)

		if self.lastBubbleTouchBeginPos 
			and ( math.abs(event.globalPosition.x - self.lastBubbleTouchBeginPos.x) > 15 
					or math.abs(event.globalPosition.y - self.lastBubbleTouchBeginPos.y) > 15 ) then
			touchMoved = true

		end
	end

	for index = 1, #initialProps do
		local ui = self.preGameTools[index]:getUI()
		if PublishActUtil:isGroundPublish() then 
			ui:setTouchEnabledWithMoveInOut(false, 0, false)
		else
			ui:setTouchEnabledWithMoveInOut(true, 0, false)
		end

		ui:addEventListener(DisplayEvents.kTouchMoveIn, onPreGameItemMoveIn, index)
		ui:addEventListener(DisplayEvents.kTouchMoveOut, onPreGameItemMoveOut, index)
		ui:addEventListener(DisplayEvents.kTouchBegin, onPreGameItemTouchBegin, index)
		ui:addEventListener(DisplayEvents.kTouchTap, onPreGameItemTapped, index)
		ui:addEventListener(DisplayEvents.kTouchMove, onPreGameItemTouchMoved, index)
	end

	-- ----------------------------
	-- Start Btn Event Listener
	-- -----------------------
	local function onStartButtonTapped(event)
		if not _G.editorMode and self.levelId > PigYearStartGame.ACT_LEVEL_START and not PigYearLogic:isActInMain() then
			CommonTip:showTip("活动已过期","negative")
			self:onCloseBtnTapped()
			return
		end
		LevelStrategyLogic:setReplayBtnEnable(false)
		self:onStartButtonTapped(event)
		GamePlayMusicPlayer:playEffect(GameMusicType.kClickCommonButton)
	end
	-- self.startButton.ui:setTouchEnabled(true)
	self.startButton:addEventListener(DisplayEvents.kTouchTap, onStartButtonTapped)

	local function onCloseBtnTapped(event)
		self:onCloseBtnTapped(event)
	end
	self.closeBtn.ui:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	-- Property Info Btn Event Listener
	local function onHelpIconTapped(event)

		local function onPropInfoPanelClosed()
			self.parentPanel:setRankListPanelTouchEnable()
		end

		self.parentPanel:setRankListPanelTouchDisable()

		local panel = PropInfoPanel:create(1, self.levelId)
		panel:setExitCallback(onPropInfoPanelClosed)

	    if panel then panel:popout() end		
	end
	self.helpIcon:setTouchEnabled(true)
	self.helpIcon:setButtonMode(true)
	self.helpIcon:setAnchorPointCenterWhileStayOrigianlPosition()
	self.helpIcon:ad(DisplayEvents.kTouchTap, onHelpIconTapped)
	
	-- ---------------
	-- Update View
	-- -------------
	
	-- Choose Item
	local stringKey		= "start.game.panel.choose.item.title"
	-- local chooseItemLabelTxt= Localization:getInstance():getText(stringKey, {})
	-- assert(chooseItemLabelTxt)
	-- self.chooseItemLabel:setString(chooseItemLabelTxt)

	-- Get self.targetDesLabel Text
	local stringKey	= false

	if self.levelModeTypeId == GameModeTypeId.CLASSIC_MOVES_ID then
		stringKey	= "level.start.step.mode"
	elseif self.levelModeTypeId == GameModeTypeId.CLASSIC_ID then
		stringKey	= "level.start.time.mode"
	elseif self.levelModeTypeId == GameModeTypeId.DROP_DOWN_ID then
		stringKey	= "level.start.drop.mode"
	elseif self.levelModeTypeId == GameModeTypeId.LIGHT_UP_ID then
		stringKey	= "level.start.ice.mode"
	elseif self.levelModeTypeId == GameModeTypeId.DIG_TIME_ID then
		stringKey	= "level.start.dig.time.mode"
	elseif self.levelModeTypeId == GameModeTypeId.DIG_MOVE_ID then
		stringKey	= "level.start.dig.step.mode"
	elseif self.levelModeTypeId == GameModeTypeId.ORDER_ID or self.levelModeTypeId == GameModeTypeId.SEA_ORDER_ID then
		local function getOrderType(str) return string.sub(str, 1, string.find(str, '_') - 1) end
		if levelGameData.orderList and #levelGameData.orderList > 0 then
			local orderType, isMatch = tonumber(getOrderType(levelGameData.orderList[1].k)), true
			if orderType == 2 or orderType == 3 then
				for k, v in ipairs(levelGameData.orderList) do
					if tonumber(getOrderType(v.k)) ~= orderType then
						stringKey = "level.start.objective.mode"
						isMatch = false
						break
					end
				end
				if isMatch then
					if orderType == 2 then stringKey = "level.start.eliminate.effect.mode"
					elseif orderType == 3 then stringKey = "level.start.swap.effect.mode" end
				end
			else stringKey = "level.start.objective.mode" end
		else stringKey = "level.start.objective.mode" end
	elseif self.levelModeTypeId == GameModeTypeId.DIG_MOVE_ENDLESS_ID then
		stringKey	= "level.start.dig.endless.mode"
	elseif self.levelModeTypeId == GameModeTypeId.TASK_UNLOCK_DROP_DOWN_ID then 
		stringKey = "unlock.cloud.panel.play.desc"
	elseif self.levelModeTypeId == GameModeTypeId.LOTUS_ID then
		stringKey = "level.start.meadow.mode"
	elseif self.levelModeTypeId == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		stringKey = "level.start.dig.endless.mode"
    elseif self.levelModeTypeId == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
		stringKey = "level.start.moleWeekly.mode"
     elseif self.levelModeTypeId == GameModeTypeId.JAMSPREAD_ID then
		stringKey = "level.start.JamSperad.mode"
	else 
		if _G.isLocalDevelopMode then printx(0, "levelModeTypeId: " .. self.levelModeTypeId) end
		assert(false)
	end

	local targetDesLabelTxt = Localization:getInstance():getText(stringKey)
	assert(targetDesLabelTxt)
	self.targetDesLabel:setString(targetDesLabelTxt)
	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		self.targetDesLabel:setColor((ccc3(93,64,168)))
	elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then
		self.targetDesLabel:setColor((ccc3(126,174,82)))
	end

	if self.ui:getChildByName("jump_level_area") ~= nil then
		self.ui:getChildByName("jump_level_area"):setVisible(false)
	end

	if JumpLevelManager:getInstance():hasJumpedLevel(self.levelId) then
		self.ui:getChildByName('jumpLevelMark'):getChildByName('text'):setText(localize('skipLevel.tips3', {n = '\n', s = ' ', replace1 = JumpLevelManager:getLevelPawnNum(self.levelId)}))
	else
		self.ui:getChildByName('jumpLevelMark'):setVisible(false)
	end

	self.onCLickCloseBtn = false 

	self:levelDiffcultFlagVisable()



	self.gifttouchLayer = self.ui:getChildByName('gifttouchLayer')
    if self.gifttouchLayer and self.gifttouchLayer:getChildByName("gift") then
		self.gifttouchLayer:getChildByName("gift"):setVisible( false )
	end

    if Thanksgiving2018CollectManager.getInstance():shouldShowActCollection(self.levelId) then
        self.halloween_house = self.ui:getChildByName("bg"):getChildByName("halloween_house")
        if self.halloween_house then
            self.halloween_house:setVisible(false)
        end
    else
	    if self.gifttouchLayer and self.levelFlag ~= LevelDiffcultFlag.kNormal then
 		
		    self.isPlayFinish = true
 		    -- local btn = GroupButtonBase:create( self.title_pur_gift  )

		    local function onTouchGiftTip(  )

			    if self.isDisposed then return end
			    if self.isPlayFinish == false then return end
			    if self.isFirst == false then return end

			    self.isPlayFinish = false
			
			    if self.level_tipsNode  then
				    self.level_tipsNode :playByIndex(0, 1)
			    else
				    local node = ArmatureNode:create('level_tips')
			        node:playByIndex(0, 1)   
			        node:update(0.01)
			        node:stop()
			        node:playByIndex(0, 1)
			        local function animationCallback()
			    	    if self.isDisposed then return end
			    	    self.isPlayFinish = true
			        end
			        node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
			 	    node:setAnimationScale( 1.0 )
			 	    node:setScale(1.5)
			        node:setPosition(ccp( 747/2, -230  ))
			        self.ui:addChild(node)
			        self.level_tipsNode = node 
			    end
		    end 

		    self.gifttouchLayer:setTouchEnabled(true)
            self.gifttouchLayer:ad(DisplayEvents.kTouchTap, onTouchGiftTip )
		    -- self.title_pur_gift.ui:addEventListener(DisplayEvents.kTouchTap, onTouchGiftTip)
	    end
    end
end

function LevelInfoPanel:hanleForSkin()
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

function LevelInfoPanel:updateFreeItemAniShow()
	local anyOneSelected = false
	local timeFreePreItem
	local normalFreePreItem

	for i,v in ipairs(self.preGameTools) do
		if not anyOneSelected then
			anyOneSelected = v:isSelected() 
		end
		v:stopFreeBubbleAni()
		if v:isFreeItemAniEffective() then 
			if v:isTimeFreeItem() then
				if not timeFreePreItem then
					timeFreePreItem = v
				else
					if v:getFreeItemAniPriority() < timeFreePreItem:getFreeItemAniPriority() then
						timeFreePreItem = v 
					end
				end
			elseif v:isFreeItem() then
				if not normalFreePreItem then
					normalFreePreItem = v
				else
					if v:getFreeItemAniPriority() < normalFreePreItem:getFreeItemAniPriority() then
						normalFreePreItem = v 
					end
				end
			end
		end
	end
	if not anyOneSelected then
		local itemToPlayAni = timeFreePreItem or normalFreePreItem
		if itemToPlayAni then
			 itemToPlayAni:showFreeBubbleAni()
		end
	end
end

function LevelInfoPanel:showToastTip(delayTime, str, delayFunc, pos)
	if self.autoPropTip then 
		self.autoPropTip:onClose()
		self.autoPropTip=nil
	end
	self.fadeArea:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(function ()
		if delayFunc then delayFunc() end
		local params = {}
		params.msg = str
		if pos then 
			params.x = pos.x
			params.y = pos.y
		else
		    local vSize0 = CCDirector:sharedDirector():getVisibleSize()
		    local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
			local pos = self.fadeArea:getPosition()
		    local po = self.fadeArea:getParent():convertToWorldSpace(pos)
		    params.y = po.y - vOrigin.y - vSize0.height - 160
		end
		self.autoPropTip = ToastTip:create(params)
	end)))
end

function LevelInfoPanel:initPreGameTools(initialProps)
	local num = table.size(initialProps)
	local gameToolsNode = self.clippingAreaAbove:getChildByName("preGameTools")
	local containerSize = gameToolsNode:getGroupBounds().size
	local itemPh = gameToolsNode:getChildByName("itemPh")
	local size = itemPh:getGroupBounds().size
	local pos = itemPh:getGroupBounds().origin
	itemPh:removeFromParentAndCleanup(true)
	self.preGameToolResource = {}

	local mask = gameToolsNode:getChildByName("mask")
	mask:removeFromParentAndCleanup(false)
	local scrollable = HorizontalScrollable:create(containerSize.width, containerSize.height, true, false)
	scrollable.clipping:setStencil(mask.refCocosObj)
	mask.refCocosObj:setPosition(ccp(0, 265))
	scrollable.clipping:setInverted(false)
    scrollable.clipping:setAlphaThreshold(0.6)
	mask:dispose()

	local offsetX = 0
	local width = 0
	local widthAdjust = 0
	local itemScale = 1
	local fourItemOffset = -145	--默认皮肤
	local fourItemScale = 0.95	--默认皮肤
	if num > 4 then
		width = 143
		offsetX = fourItemOffset
		widthAdjust = 60
		scrollable:setScrollEnabled(true)
		itemScale = fourItemScale
	elseif num == 4 then
		width = 143
		offsetX = fourItemOffset
		scrollable:setScrollEnabled(false)
		itemScale = fourItemScale
	else
		width = 180
		offsetX = -150
		scrollable:setScrollEnabled(false)
	end

	local content = Layer:create()
	content:setContentSize(CCSizeMake(width * num + widthAdjust, size.height))
	for i = 1, num do
		local item = nil 
		if self.levelFlag == LevelDiffcultFlag.kNormal then
			item = ResourceManager:sharedInstance():buildGroup("z_new_2017_game/preGameToolItem")
		else
			item = ResourceManager:sharedInstance():buildGroup("z_new_2017_game/preGameToolItem")
			if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
				local labelbg = item:getChildByName("_priceBg")
				if labelbg then
				--	labelbg:adjustColor( 1 , 0 , -0.0161 , -0.1278)
					labelbg:adjustColor( -0.66 , 0 , 0 , 0)
					labelbg:applyAdjustColorShader()
				end

				local bubble = item:getChildByName("bubbleItem"):getChildByName("bubble"):getChildByName("sprite")
				if bubble then
				--	bubble:adjustColor( 0.8788 , -0.3532 , -0.067917 , -0.067817)
					bubble:adjustColor( -0.85 , 0 , 0 , 0)
					bubble:applyAdjustColorShader()
				end
			else

			end

		end
		if item then item:setScale(itemScale) end
		content:addChild(item)
		-- item:setPosition(ccp(width * i + offsetX, -20))
		item:setPosition(ccp(width * i + offsetX, -50))

		self["preGameTool"..i.."Resource"] = item
		table.insert(self.preGameToolResource, item)
	end
	-- content:setPosition(ccp(-150, -200))
	scrollable:setContent(content)
	-- scrollable:setPosition(ccp(-150, -20))
	gameToolsNode:addChild(scrollable)

	self.preItemsScrollable = scrollable

	local autoUseNum = 0
	for i,v in ipairs(initialProps) do
		if v.autoUse then 
			autoUseNum = autoUseNum + 1
		end
	end
	if autoUseNum > 0 then
		self:showToastTip(1, "带上道具，过关更容易！", function ()
			for i=1, autoUseNum do
				local tappedPreGameItem	= self.preGameTools[i]
				tappedPreGameItem:setSelected(true)
			end
		end)
	end
end

function LevelInfoPanel:borrowPrePropUI(node, addToNode)
	local wpos = node:getParent():convertToWorldSpace(node:getPosition())
	node:removeFromParentAndCleanup(false)
	node:setPosition(addToNode:convertToNodeSpace(wpos))
	addToNode:addChild(node)
end

function LevelInfoPanel:giveBackPrePropUI(node)
	local wpos = node:getParent():convertToWorldSpace(node:getPosition())
	local preItemsContainer = self.preItemsScrollable:getContent()
	node:removeFromParentAndCleanup(false)
	node:setPosition(preItemsContainer:convertToNodeSpace(wpos))
	preItemsContainer:addChild(node)
end

function LevelInfoPanel:dispose( )

	CollectStarsYEMgr.getInstance():setDelegate( nil )

	if self.passDayHandler then
		GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kPassDay, self.passDayHandler)
		self.passDayHandler = nil
	end

	--2018/04/17  文档 马俊松添加 点击下一关 不被强弹打算 使玩家闯关过程更流畅，不被其他功能面板打断，减少流失提高留存。
	if self.onCLickCloseBtn == true then
		--统一强弹
		Notify:dispatch("QuitNextLevelModeEvent", true, true)
	end
	BasePanel.dispose(self)
	if CountdownPartyManager.getInstance():shouldShowActCollection(self.levelId) then
		CountdownPartyManager.getInstance():unloadSkeletonAssert()
	end
	if self.isLoadLevelInfoSkeletonAssert_Collect then
		CollectStarsManager.getInstance():unloadLevelInfoSkeletonAssert()
	end
    if Thanksgiving2018CollectManager.getInstance():shouldShowActCollection(self.levelId) then
		Thanksgiving2018CollectManager.getInstance():unloadSkeletonAssert()
	end
	FrameLoader:unloadImageWithPlists("flash/bubble_flash.plist",true)
	if self.autoPropTip then
		self.autoPropTip:onClose()
		self.autoPropTip=nil
	end

	FrameLoader:unloadImageWithPlists("ui/gamestaradd/panel_game_start_add.plist")
	PreBuffLogic:unloadLevelInfoSkeletonAssert()

	self:stopDiscountCountdown()

	Notify:unregister("PigYearStartGameCreate", self)
end

-- he_log_warning("Debug Item Scale 9 Bg Group Bounds !")

function LevelInfoPanel:onCloseBtnTapped(event, ...)
	assert(#{...} == 0)	
	if self.tappedState == self.TAPPED_STATE_NONE then

		local runningScene = Director:sharedDirector():getRunningScene()
		if _G.isLocalDevelopMode then printx(0, "runningScene.name", runningScene.name) end
		if GameGuide then
			local name = GameGuide:sharedInstance():currentGuideType()
			if _G.isLocalDevelopMode then printx(0, "GameGuide:sharedInstance():currentGuideType()", name) end
			if name then if _G.isLocalDevelopMode then printx(0, "name", name) end
				if name == "startInfo" or name == "showPreProp" or name == 'showNewPreProp' then
					if _G.isLocalDevelopMode then printx(0, "should return") end
					return
				end
			end
		end

		self.tappedState = self.TAPPED_STATE_CLOSE_BTN_TAPPED
	else
		return
	end
	
	local function onRemoveAnimFinished()
		self:backTheCoinUsedInPreGameItem()

		if self.parentPanel.onClosePanelCallback then
			self.parentPanel:onClosePanelCallback()
		end
	end

	self:removeItemTip()
	self.parentPanel:remove(onRemoveAnimFinished)
	self:removeGuide()
	
	self.onCLickCloseBtn = true
end

function LevelInfoPanel:removeItemTip()
	for _,item in ipairs(self.preGameTools) do
		item:hideVideoAdTip()
	end
end

--bugfix 在调起跳关面板时，其实会销毁当前开始游戏面板，关掉跳关面板时，重新创建一个开始游戏面板
--重新创建的面板 丢失了之前被注册的一些回调
function LevelInfoPanel:recordCallback( ... )
	if self.parentPanel then
		self.parentPanel:recordCallback()
	end
end


function LevelInfoPanel:backTheCoinUsedInPreGameItem(...)
	assert(#{...} == 0)

	if QixiUtil:hasCompeleted() then
		if _G.isLocalDevelopMode then printx(0, 'here') end

		for k, v in pairs(self.preGameTools) do
			-------------- qixi ----------------------
			if v:isFreeItem() then -- qixi
				if v:isSelected() then
					-- QixiUtil:unConsumeFreeItem(v.itemId)
				end
			end
		end
	end
	--------------- end qixi --------------------

	if self.totalSubtractedCoin > 0 then
		-- Close Panel, Means Cancel To Play Game
		-- Add The Subtracted Coin Back To User
		local curCoin = UserManager.getInstance().user:getCoin()
		assert(curCoin)

		local newCoin = curCoin + self.totalSubtractedCoin
		UserManager.getInstance().user:setCoin(newCoin)

		--local runningScene = Director:sharedDirector():getRunningScene()
		local homeScene = HomeScene:sharedInstance()
		homeScene:checkDataChange()
		homeScene.coinButton:updateView()

	elseif self.totalSubtractedCoin == 0 then
		-- Do Nothing
	else 
		assert(false)
	end
end

function LevelInfoPanel:onPreGameItemMoveIn(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchMoveIn)
	assert(event.context)
	assert(#{...} == 0)

	if self.tappedState ~= self.TAPPED_STATE_NONE then
		return
	end

	local index 		= event.context
	local tappedPreGameItem	= self.preGameTools[index]
	assert(tappedPreGameItem)

	if tappedPreGameItem:isLocked() then
		tappedPreGameItem:playShakeLockAndLabelAnim(false)
		return
	end

	if tappedPreGameItem:isPrivilegeFree() then
		return 
	end

	-- Play Bubble Touched Anim One Time, Then
	-- Play Bubble Normal Anim
	if not tappedPreGameItem:isSelected() then
		local function onBubbleTouchedAnimFinish()
			tappedPreGameItem:playBubbleNormalAnim(true)
		end
		tappedPreGameItem:playBubbleTouchedAnim(false, onBubbleTouchedAnimFinish)
	end
end

function LevelInfoPanel:onPreGameItemMoveOut(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchMoveOut)
	assert(event.context)
	assert(#{...} == 0)


end

function LevelInfoPanel:onPreGameItemTouchBegin(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchBegin)
	assert(event.context)
	assert(#{...} == 0)

	if self.tappedState ~= self.TAPPED_STATE_NONE then
		return
	end

	local index = event.context
	local tappedPreGameItem = self.preGameTools[index]
	assert(tappedPreGameItem)

	if tappedPreGameItem:isLocked() then
		tappedPreGameItem:playShakeLockAndLabelAnim(false)
		return
	end

	if tappedPreGameItem:isSelected() then
		return 
	end

	if tappedPreGameItem:isPrivilegeFree() then
		return 
	end
	
	-- Play Bubble Touched Anim One Time, Then
	-- Play Bubble Normal Anim
	local function onBubbleTouchedAnimFinish()
		tappedPreGameItem:playBubbleNormalAnim(true)
	end
	tappedPreGameItem:playBubbleTouchedAnim(false, onBubbleTouchedAnimFinish)
end

function LevelInfoPanel:onPreGameItemTapped(event, ...)

	if self.tappedState ~= self.TAPPED_STATE_NONE then
		return
	end

	print("LevelInfoPanel:onPreGameItemTapped")

	local index = event.context

	local tappedPreGameItem = self.preGameTools[index]
	assert(tappedPreGameItem)

	if tappedPreGameItem:isLocked() then
		--tappedPreGameItem:playShakeLockAnim(false)
		return
	end

	if tappedPreGameItem:isPrivilegeFree() then 
		return 
	end

	if tappedPreGameItem.isTimeProp 
	and UserManager:getInstance():getUserTimePropNumber(tappedPreGameItem.itemId) < 1 then
		local levelId, levelType = self.parentPanel.levelId, self.parentPanel.levelType
		PopoutManager:sharedInstance():remove(self.parentPanel, true)
		local panel = StartGamePanel:create(levelId, levelType, nil, StartLevelSource.kPrePropExpire)
		panel:popout(false)
		CommonTip:showTip('不好意思哦~您选用的道具已过期~', 'negative', nil, 2)
		return 
	end

	if tappedPreGameItem.isVideoAdOpenV2 then
		tappedPreGameItem:setSelected(not tappedPreGameItem:isSelected())
		GamePlayMusicPlayer:playEffect(GameMusicType.kClickBubble)
		return
	end

	local itemId = tappedPreGameItem.itemId

	if tappedPreGameItem:isFreeItem() then 
		local curNum = UserManager:getInstance():getUserPropNumber(itemId)
		if tappedPreGameItem:isSelected() then
			tappedPreGameItem:setSelected(false)
			-- UserManager:getInstance():setUserPropNumber(itemId, curNum + 1)
		else
			tappedPreGameItem:setSelected(true)
			-- UserManager:getInstance():setUserPropNumber(itemId, curNum - 1)
		end
	elseif tappedPreGameItem:isBuyWithHappyCoin() then
		if tappedPreGameItem:isSelected() then
			tappedPreGameItem:setSelected(false)
		else
			-- Can Buy
			tappedPreGameItem:setSelected(true)
			GamePlayMusicPlayer:playEffect(GameMusicType.kClickBubble)
		end
	else

		if tappedPreGameItem:isSelected() then

			-- Unselect
			tappedPreGameItem:setSelected(false)

			-- Add The Price Back To User
			local curCoin = UserManager.getInstance().user:getCoin()
			assert(curCoin)
			local newCoin = curCoin + tappedPreGameItem:getPrice()
			UserManager.getInstance().user:setCoin(newCoin)

			local homeScene = HomeScene:sharedInstance()
			homeScene:checkDataChange()
			homeScene.coinButton:updateView()

			self.totalSubtractedCoin = self.totalSubtractedCoin - tappedPreGameItem:getPrice()
			self:updateEachPreGameItemPriceColor()
		else
			-- Compare Usr Cur Coin With This Item's Price
			local curCoin = UserManager.getInstance().user:getCoin()
			assert(curCoin)

			local function chooseItem()
				local curCoin = UserManager.getInstance().user:getCoin()
				tappedPreGameItem:setSelected(true)

				GamePlayMusicPlayer:playEffect(GameMusicType.kClickBubble)

				-- Subtract The Price
				local newCoin = curCoin - tappedPreGameItem:getPrice()
				UserManager.getInstance().user:setCoin(newCoin)
				local homeScene = HomeScene:sharedInstance()
				homeScene:checkDataChange()
				homeScene.coinButton:updateView()
				
				self.totalSubtractedCoin = self.totalSubtractedCoin + tappedPreGameItem:getPrice()
			end

			local function afterBuy()
				CommonTip:showTip("购买成功~","positive")
				for i = 1, #self.preGameTools do self.preGameTools[i]:updatePriceColor() end
			end

			-- local function chooseItemAfterBuy()
			-- 	CommonTip:showTip("购买成功~","positive")
			-- 	for i = 1, #self.preGameTools do self.preGameTools[i]:updatePriceColor() end
			-- 	-- tappedPreGameItem:updatePriceColor()
			-- 	local curCoin = UserManager.getInstance().user:getCoin()
			-- 	if curCoin >= tappedPreGameItem:getPrice() then
			-- 		chooseItem()
			-- 	end
			-- end

			if curCoin >= tappedPreGameItem:getPrice() then
				-- Can Buy
				chooseItem()
			else
				-- Can't Buy
				-- 银币不足
				-- CommonTip:showTip(Localization:getInstance():getText("start.panel.net.enough.coin"), "negative")
				require "zoo.payment.PayPanelCoin"
				--PayPanelCoin:create(tappedPreGameItem:getPrice(), BuyCoinReasonType.kPregameProp, chooseItemAfterBuy)
				PayPanelCoin:create(tappedPreGameItem:getPrice(), BuyCoinReasonType.kPregameProp, afterBuy)
			end

			self:updateEachPreGameItemPriceColor()
		end
	end
	
	self:updateFreeItemAniShow()
end

function LevelInfoPanel:updateEachPreGameItemPriceColor(...)
	assert(#{...} == 0)

	for k,v in pairs(self.preGameTools) do
		v:updatePriceColor()
	end
end

function LevelInfoPanel:onStartButtonTapped(event)
	self.startButton:setEnabled(false, true)
	if self.tappedState == self.TAPPED_STATE_NONE then
		--self.tappedState = self.TAPPED_STATE_START_BTN_TAPPED
	else
		self.startButton:setEnabled(true)
		return
	end
	self:removeGuide()
    if Thanksgiving2018CollectManager.getInstance():shouldShowActCollection(self.levelId) then
        Thanksgiving2018CollectManager.getInstance():StartLevelDC()
    end	

    local function startGame()
    	self:startGame(self.startButton.costType)
    end

	local function unregisterScheduler()
		if self.schedulerId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId) 
		end
		self.schedulerId = nil
	end
    if HEAICore:getInstance():shouldDelayStartGame() then 
    	unregisterScheduler()
    	self.schedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ()
    		if not HEAICore:getInstance():shouldDelayStartGame() then
	    		unregisterScheduler()
	    		startGame()
	    	end
    	end, 0.01, false)
    else
    	startGame()
    end
end

function LevelInfoPanel:createFlyingEnergyAction(costType , ...)
	assert(#{...} == 0)

	local actionArray = CCArray:create()

	local newEnergyRes	= nil
	local manualAdjustDestPosX = -5
	local manualAdjustDestPosY = 5


	-- --------------------------------------------------
	-- Get The Energy Button's Energy Icon In The HomeScene
	-- ----------------------------------------------------
	-- local runningScene = Director:sharedDirector():getRunningScene()
	-- if runningScene.name == "GamePlaySceneUI" then
		
	-- 	local emptyAction = CCDelayTime:create(0)
	-- 	return emptyAction
	-- end

	local energyButton = HomeScene:sharedInstance().energyButton
	assert(energyButton)
	local energyBtnIcon = energyButton:getIconRes()
	assert(energyBtnIcon)
	
	-- Get Button's Energy Icon's Pos, In Self Space
	local startPosInSelfSpace	= self:getNodePosInSelfSpace(energyBtnIcon)
	assert(startPosInSelfSpace)

	-----------------------------------------
	-- Get Energy Icon In Self Start Button
	-- ---------------------------------------
	local energyIconInStartBtn = self.startButton:getIcon()
	assert(energyIconInStartBtn)
	
	-- Get Energy Pos
	
	
	local destPosInSelfSpace	= self:getNodePosInSelfSpace(energyIconInStartBtn)
	--正常体力的偏移
	destPosInSelfSpace = ccpAdd( destPosInSelfSpace ,  self.startButton:getPosOffset() )

	assert(destPosInSelfSpace)


	if costType == StartLevelCostEnergyType.kEnergyBottleSmall then
		newEnergyRes	= ResourceManager:sharedInstance():buildGroup("homeSceneEnergyBottle_s")
		manualAdjustDestPosX = -7
		manualAdjustDestPosY = 15

		local plusBtnIcon = HomeScene:sharedInstance().hideAndShowBtn.ui
		startPosInSelfSpace	= self:getNodePosInSelfSpace(plusBtnIcon)
	elseif costType == StartLevelCostEnergyType.kEnergyBottleMiddle then
		newEnergyRes	= ResourceManager:sharedInstance():buildGroup("homeSceneEnergyBottle_m")
		manualAdjustDestPosX = -13
		manualAdjustDestPosY = 15

		local plusBtnIcon = HomeScene:sharedInstance().hideAndShowBtn.ui
		startPosInSelfSpace	= self:getNodePosInSelfSpace(plusBtnIcon)
	else
		newEnergyRes	= ResourceManager:sharedInstance():buildGroup("homeSceneEnergyItem")
		manualAdjustDestPosX = -16
		manualAdjustDestPosY = 10
	end

	destPosInSelfSpace.x = destPosInSelfSpace.x + manualAdjustDestPosX
	destPosInSelfSpace.y = destPosInSelfSpace.y + manualAdjustDestPosY

	-------------------
	-- Init Anim Action
	-- -----------------
	local function initAnimFunc()
		self:addChild(newEnergyRes)
		newEnergyRes:setPosition(ccp(startPosInSelfSpace.x, startPosInSelfSpace.y))
	end
	local initAnimAction = CCCallFunc:create(initAnimFunc)

	actionArray:addObject(initAnimAction)

	------------------
	-- Move To Action
	-- -------------
	local moveTo 	= CCMoveTo:create(0.5, ccp(destPosInSelfSpace.x, destPosInSelfSpace.y))
	local ease	= CCEaseSineOut:create(moveTo)
	moveTo = ease

	actionArray:addObject(moveTo)

	local function playSoundEffect()
		GamePlayMusicPlayer:playEffect(GameMusicType.kUseEnergy)
	end
	local playSoundAction = CCCallFunc:create(playSoundEffect)
	actionArray:addObject(playSoundAction)
	actionArray:addObject(CCDelayTime:create(0.2))

	------------------
	-- Anim Finish Clean Up Action
	-- --------------------------
	
	local function animFinishCleanUpFunc()
		-- For Test Purpose

	end
	local animFinishCleanUpAction = CCCallFunc:create(animFinishCleanUpFunc)

	actionArray:addObject(animFinishCleanUpAction)

	-------------
	-- Seq
	-- ----------
	local seq = CCSequence:create(actionArray)
	local target = CCTargetedAction:create(newEnergyRes.refCocosObj, seq)

	--return seq
	return target
end

function LevelInfoPanel:playFlyingEnergyAnimation(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)


	local flyingEnergyAction = self:createFlyingEnergyAction()

	-- Anim Finish Callback
	local function animFinishCallbackFunc()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local animFinishCallbackAction = CCCallFunc:create(animFinishCallbackFunc)

	-- Seq
	local seq = CCSequence:createWithTwoActions(flyingEnergyAction, animFinishCallbackAction)


	self:runAction(seq)
end

function LevelInfoPanel:playFlyingEnergyAndSelectedItemAnim(selectedItemsData, animFinishCallback, costType,...)
	assert(selectedItemsData)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	HomeScene:sharedInstance():checkDataChange()
	HomeScene:sharedInstance().energyButton:updateView()

	-- Flying Energy
	local flyingEnergyAction = self:createFlyingEnergyAction(costType)

	-- Flying Selected Item
	-- local selectedItemAction = self:createSelectedItemFlyingAction(selectedItemsData)

	-- Anim Finish Callback
	local function animFinishCallbackFunc()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local animFinishCallbackAction = CCCallFunc:create(animFinishCallbackFunc)

	local actionArray = CCArray:create()
	actionArray:addObject(flyingEnergyAction)
	-- actionArray:addObject(selectedItemAction)
	actionArray:addObject(animFinishCallbackAction)

	-- Seq
	local seq = CCSequence:create(actionArray)
	self:runAction(seq)
end

--function LevelInfoPanel:getSelectedItemPosInWorldPos(selectedItemsData, ...)
function LevelInfoPanel:setSelectedItemAnimDestPos(selectedItemsData, ...)
	assert(type(selectedItemsData) == "table")
	assert(#{...} == 0)

	for k,data in pairs(selectedItemsData) do

		local preGameToolItem = data.node
		assert(PreGameToolItem)

		local itemRes = preGameToolItem:getItemRes()
		assert(itemRes)

		--local nodeSpacePos = self:getNodePosInSelfSpace(itemRes)

		local itemResParent = itemRes:getParent()
		assert(itemResParent)

		local itemResPos		= itemRes:getPosition()
		local itemResPosInWorldSpace = itemResParent:convertToWorldSpace(ccp(itemResPos.x, itemResPos.y))

		data.destXInWorldSpace = itemResPosInWorldSpace.x
		data.destYInWorldSpace = itemResPosInWorldSpace.y --+ 150
	end
end


function LevelInfoPanel:createSelectedItemFlyingAction(selectedItemsData, ...)
	assert(false, "should not be used")
	local actionArray = CCArray:create()
	for k,data in pairs(selectedItemsData) do
		local preGameToolItem = data.node
		if preGameToolItem then
			local itemRes = preGameToolItem:getItemRes()
			local nodeSpacePos = self:getNodePosInSelfSpace(itemRes)
			itemRes:removeFromParentAndCleanup(false)
			
			local container = PrefixPropAnimation:createShineAnimation()
			container:setPosition(nodeSpacePos)
			itemRes:setPositionX(0)
			itemRes:setPositionY(0)
			container:addChild(itemRes)

			self:addChild(container)

			actionArray:addObject(CCDelayTime:create(0.2))
		end
	end
	-- Empty Action
	local emptyAction = CCDelayTime:create(0)
	actionArray:addObject(emptyAction)

	local spawn = CCSpawn:create(actionArray)
	return spawn
end

function LevelInfoPanel:playSelectedItemFlyingAnim(selectedItemsData, animFinishCallback, ...)
	assert(type(selectedItemsData) == "table")
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local selectedItemsAction = self:createSelectedItemFlyingAction(selectedItemsData)

	-- Callback Function
	local function animFinishCallbackFunc()
		
		for k, data in pairs(selectedItemsData) do
			data.width 	= data.itemRes:getGroupBounds().width
			data.height	= data.itemRes:getGroupBounds().height
		end

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction = CCCallFunc:create(animFinishCallbackFunc)

	-- Seq 
	local seq = CCSequence:createWithTwoActions(selectedItemsAction, callbackAction)
	
	if self.isPlayingFlyingSelectedItemAnim then
		self:runAction(seq)
	else
		animFinishCallbackFunc()
	end
end

function LevelInfoPanel:startGame(costType)
	-- Get Data About Selected Item
	-- Set Anim Pos About Selected Item
	
	-- FTWLocalLogic:onStartLevelInfoPanel(self.levelId)

	if LevelStrategyManager.getInstance():shouldAskForReplayData(self.levelId) then 
		LevelStrategyManager.getInstance():getReplayData(self.levelId, nil, true)
	end

	local selectedItemsData, useBagPropList,allPropIDs = self:getSelectedItemsData()

	if PublishActUtil:isGroundPublish() then 
		selectedItemsData = PublishActUtil:getTempSelectedPropTable()
	end

	self.selectedItemsData = selectedItemsData
	self.useBagPropList = useBagPropList

	self.startFromEnergyPanel = false

	-- -------------------------------------
	-- Run The Start Level Bussiness Logic
	-- --------------------------------------
	local eStartLevelType = StartLevelType.kCommon
	if self.startLevelType == StartLevelType.kAskForHelp then
		eStartLevelType = StartLevelType.kAskForHelp
	end

	if self.parentPanel.replayStartGameCallbackBeforStartLevel then
        self.parentPanel.replayStartGameCallbackBeforStartLevel()
        self.parentPanel.replayStartGameCallbackBeforStartLevel = nil
		self.startByReplay = true
    end

    _G.QuestChangeContext:getInstance():reset(0)
    
	local startLevelLogic = StartLevelLogic:create(self, self.levelId, self.levelType, selectedItemsData, notConsumeEnergy, useBagPropList, eStartLevelType)
	startLevelLogic:start(true, costType)

	if self.parentPanel.replayStartGameCallback then
        self.parentPanel.replayStartGameCallback()
    end
    PrePropImproveLogic:onStartGame(self.levelId, allPropIDs)

end


function LevelInfoPanel:onStartLevelLogicSuccess()
	-- Block Tapped
	self.tappedState = self.TAPPED_STATE_START_BTN_TAPPED
	if self.jumpLevelArea and self.jumpLevelArea.ui and not self.jumpLevelArea.ui.isDisposed then
		self.jumpLevelArea:setEnabled(false)
	end

	if self.levelType == GameLevelType.kMainLevel 
			or self.levelType == GameLevelType.kHiddenLevel then
		SeasonWeeklyRaceManager:getInstance():onPlayMainLevel()
		--春节活动用的事件
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new('springFestival2017.play.main.level'))
	end
end

function LevelInfoPanel:onStartLevelLogicFailed(err)
	local onStartLevelFailedKey 	= "error.tip."..err
	local onStartLevelFailedValue	= Localization:getInstance():getText(onStartLevelFailedKey, {})
	CommonTip:showTip(onStartLevelFailedValue, "negative")
end

function LevelInfoPanel:startGameForEnergyPanel( ... )

	-- FTWLocalLogic:onStartLevelInfoPanel(self.levelId)

	
	self.startFromEnergyPanel = true

	local eStartLevelType = StartLevelType.kCommon
	if self.startLevelType == StartLevelType.kAskForHelp then
		eStartLevelType = StartLevelType.kAskForHelp
	end

	local startLevelLogic = StartLevelLogic:create(self, self.levelId, self.levelType, self.selectedItemsData, false, self.useBagPropList, eStartLevelType)
	startLevelLogic:start(true)
end

function LevelInfoPanel:onEnergyNotEnough()
	self.isPlayingFlyingSelectedItemAnim = false

	if self.startFromEnergyPanel then
		assert(false, "not possible !")
		return
	end

	if self.energyPanelPoped then return end
	self.energyPanelPoped = true

	local function startGameForEnergyPanel()
		self:startGameForEnergyPanel()
	end

	local function onEnergyPanelCloseBackTheCoin()
		self:backTheCoinUsedInPreGameItem()
		if self.startByReplay then
			Director:sharedDirector():popScene()
		end
	end
	self.parentPanel:changeToEnergyNotEnoughPanel(startGameForEnergyPanel, onEnergyPanelCloseBackTheCoin)
end

function LevelInfoPanel:onWillEnterPlayScene( ... )
	-- Update The Energy Button
	HomeScene:sharedInstance():checkDataChange()
	HomeScene:sharedInstance().energyButton:updateView()

	--fix
	-- disable WorldScene touch events,
	-- prevent touch before entering GamePlaySceneUI
	local worldScene = HomeScene:sharedInstance().worldScene
	if worldScene then
		worldScene:setIsTouched(true)
	end

	Notify:dispatch("WillEnterPlaySceneEvent")

	if self.parentPanel and not self.parentPanel.isDisposed then
		if _G.isLocalDevelopMode then printx(0, "onWillEnterPlaySceneCallback remove parentPanel") end
		PopoutManager:sharedInstance():remove(self.parentPanel, true)
		self:removeGuide()
	end
	--end fix
end

function LevelInfoPanel:playEnergyAnim(onAnimFinish, selectedItemsData , costType)
	if self.startFromEnergyPanel then
		if onAnimFinish then onAnimFinish() end
		return
	end
	-- When Anim Finished 
	-- Truely Start The Game
	local function onFlyingItemAnimFinished()
		-- notPlayStartGamePanelAnimAndStartTheGame()
		if onAnimFinish then onAnimFinish() end
	end

 	selectedItemsData = selectedItemsData or {}
	-- Play The Anim
	self:playFlyingEnergyAndSelectedItemAnim(selectedItemsData, onFlyingItemAnimFinished , costType)
end

function LevelInfoPanel:getSelectedItemsData()
	local result = {}
	local useBagPropList = {}
	local allPropIDs = {}

	for index = 1, #self.preGameTools do
		local curItem = self.preGameTools[index]
		local itemData 		= {}
		itemData.id 		= curItem:getItemId()
		itemData.node		= curItem

		if curItem:isPrivilegeFree() then 
			itemData.isPrivilegeFree = true
			table.insert(result, itemData)
		elseif curItem:isSelected() then
			itemData.isVideoAd = curItem:isFromFreeVideo()
			table.insert(result, itemData)
			table.insert(allPropIDs, itemData.id)
			if not itemData.isVideoAd and curItem:isFreeItem() then
				table.insert(useBagPropList, itemData.id)
			end
		end
	end

	return result, useBagPropList, allPropIDs
end

function LevelInfoPanel:create(parentPanel, levelId, levelType, startLevelType, ...)

	if MaintenanceManager:getInstance():isEnabledInGroup(
		'LevelDifficultyAdjustFarmStar', 
		'A1', 
		UserManager:getInstance():getUID() or "12345"
	) then
		LevelDifficultyAdjustManager:loadLevelTargetProgerssData(levelId)
	end

	local newPanel = LevelInfoPanel.new()
	printx( 1 , "    LevelInfoPanel:create   " , parentPanel, levelId, levelType, startLevelType)
	newPanel:init(parentPanel, levelId, levelType, startLevelType)
	return newPanel
end

function LevelInfoPanel:getPrePropPositionByIndex(index)
	local item = self.preGameToolResource[index]
	local pos1 = item:getPosition()
	pos1 = item:getParent():convertToWorldSpace(ccp(pos1.x, pos1.y))
	local size = item:getGroupBounds().size
	return ccp(pos1.x + size.width / 2, pos1.y)
end

function LevelInfoPanel:getLevelTargetPosition()
	--此函数被调用时，面板还不在最终位置，所以算的位置不对
	--手动调整一个偏移

	local item = self.levelTarget
	local pos1 = item:getPosition()
	local size = item:getGroupBounds().size
	local pos2 = item:getParent():convertToWorldSpace(pos1)
	return ccp(pos2.x + size.width / 2, pos2.y - size.height/2)
end

--马俊松 18年8月3日添加 游戏失败 点击再一次吊起开始面板后的回调 于afterPopout时机一致
function LevelInfoPanel:changeToStartGamePanelAfterPopout()

	self:afterPopout( true )
	self:afterPopoutAndAfterGuideCheck()
	
end


function LevelInfoPanel:afterPopout( afterPopoutFromFailPanel )
	if not afterPopoutFromFailPanel then
		afterPopoutFromFailPanel = false
	end
	self.afterPopoutFromFailPanel = afterPopoutFromFailPanel
	if _G.isLocalDevelopMode then printx(0, 'LevelInfoPanel:afterPopout') end
	if QixiUtil:hasCompeleted() then
		local itemPos = {}
		for k, v in pairs(self.preGameTools) do
			local pos = v.priceLabel:getParent():convertToWorldSpace(v.priceLabel:getPosition())
			table.insert(itemPos, pos)
		end
		QixiUtil:playMagpieAnimation(ccp(-100, 750), ccp(820, 750), itemPos)
	end
	if self.isDisposed then return end
	-- self:initJumpLevelArea()	--延后检测
	
	local len = table.size(self.preGameTools)
	for i = 1, len do
		local tappedPreGameItem	= self.preGameTools[i]
		local function playBubbleAnim()
			if tappedPreGameItem and not tappedPreGameItem.isDisposed and 
				not tappedPreGameItem:isLocked() and 
				not tappedPreGameItem:isSelected() and 
				not tappedPreGameItem:isPrivilegeFree() then
				local function onBubbleTouchedAnimFinish()
					if not tappedPreGameItem or tappedPreGameItem.isDisposed then return end
					tappedPreGameItem:playBubbleNormalAnim(true)
				end
				tappedPreGameItem:playBubbleTouchedAnim(false, onBubbleTouchedAnimFinish)
			end
		end
		if tappedPreGameItem and not tappedPreGameItem.isDisposed then
			tappedPreGameItem:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(-0.15 + 0.15 * i), CCCallFunc:create(playBubbleAnim)))
		end
	end

	self.hasAfterPopout = true
	if self.showPrePropAction then
		self:runShowPreProp(self.showPrePropAction)
	end

	if self.needRunVideoAdAction then
		self:runPrePropVideoAdAnim()
	end

	if self.showNewPrePropAction then
		self:runNewShowPreProp(self.showNewPrePropAction)
	end

	if self.showStartButtonAction then
		self:runShowStartButton(self.showStartButtonAction)
	end

	if self.showIngredientGuide then
		self:tryIngredientGuide()
	end

    local anim
	if CountdownPartyManager.getInstance():shouldShowActCollection(self.levelId  ) then
		anim = WinAnimation:createCountdownPartyAni(3)
		self.ui:addChildAt(anim, 5)
		anim:play(0)
		anim:setPosition(ccp(350, -400))

		local ActCollectionPanel = require 'zoo.localActivity.CountdownParty.ActCollectionPanel'
		local countdownPartyPanel = ActCollectionPanel:create(3)
		countdownPartyPanel:setPosition(ccp(490, -330))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()
	end
	if CollectStarsManager.getInstance():canShowTitle(self.levelId ,self.startLevelType ,true ) and not self.collectStarsDoNotCreate then
		local order = self.ui:getChildByName('bg'):getZOrder()
		anim = WinAnimation:createCollectStarsAni(3)
		self.ui:addChildAt(anim, order)
		anim:play(0)
		anim:setPosition(ccp(350, -400))

		local ActCollectStarsPanel = require 'zoo.localActivity.CollectStars.ActCollectStarsPanel'
		local customPanel = nil
		if self.afterPopoutFromFailPanel then
			customPanel = ActCollectStarsPanel:create(5)
		else
			customPanel = ActCollectStarsPanel:create(3)
		end
		customPanel:setPosition(ccp(180 + 300, -200-135))

		self.ui:addChildAt(customPanel, 9)
		customPanel:playShowAni()
		self.CollectStarCustomPanel = customPanel
		self.CollectStarWinAnim = anim
	end
    Thanksgiving2018CollectManager.getInstance():SaveActCollectionSupport( false )
    if Thanksgiving2018CollectManager.getInstance():shouldShowActCollection(self.levelId) then
        Thanksgiving2018CollectManager.getInstance():SaveActCollectionSupport( true )

		anim = WinAnimation:createCountdownPartyAni(3)
		self.ui:addChildAt(anim, 5)
		anim:play(0)
		anim:setPosition(ccp(350, -400))

		local Thanksgiving2018CollectPanel = require 'zoo.localActivity.Thanksgiving2018.Thanksgiving2018CollectPanel'
		local countdownPartyPanel = Thanksgiving2018CollectPanel:create(3)
		countdownPartyPanel:setPosition(ccp(490, -330))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()
	end

    RecallA2019Manager.getInstance():setActStartPanelBubble( false )
    local topLevelId = UserManager:getInstance().user:getTopLevelId()
    if RecallA2019Manager.getInstance():getCutLevelIsCanShowMission(self.levelId) and topLevelId >= 30 then
        RecallA2019Manager.getInstance():setActStartPanelBubble( true )

        local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
        if ver > 64 then
		    anim = WinAnimation:createRecallA2019Ani(3)
		    self.ui:addChildAt(anim, 5)
		    anim:play(0)
		    anim:setPosition(ccp(350, -400))
        end

		local ActCollectionPanel = require 'zoo.localActivity.RecallA2019.RecallA2019CollectionPanel'
		local countdownPartyPanel = ActCollectionPanel:create(3)
		countdownPartyPanel:setPosition(ccp(490, -330))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()
	end

    if TurnTable2019Manager.getInstance():isActivitySupport( self.levelId ) then
        anim = WinAnimation:createRecallA2019Ani(3)
		self.ui:addChildAt(anim, 5)
		anim:play(0)
		anim:setPosition(ccp(350, -400))
        
        local ActCollectionPanel = require 'zoo.localActivity.TurnTable2019.TurnTable2019CollectionPanel'
		local countdownPartyPanel = ActCollectionPanel:create(3,self.levelId)
		countdownPartyPanel:setPosition(ccp(490, -330))
		self.tipNode:addChild(countdownPartyPanel)
		countdownPartyPanel:playShowAni()
    end

	self:updatePreBuffTitle()
	self:updateCollectStarBuff()

    local context = self
    self.passDayHandler = function ()
    	context:updatePreBuffTitle()
    	context:updateCollectStarBuff()
    end
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, self.passDayHandler)

	local cdInSec = PreBuffLogic:getActEndTimeLeft()
	if cdInSec and cdInSec > 0 then
		local replaceFlagAction = CCSequence:createWithTwoActions(CCDelayTime:create(cdInSec + 1), CCCallFunc:create( onPassDay ))
		self:runAction(replaceFlagAction)
	end
end


function LevelInfoPanel:flylabelTipsOnStartBtnWithText( labelText )
	local pos = self.startButton:getPositionInScreen()
	pos = self.ui:convertToNodeSpace(pos)
	local halfBtnWidth = 120
	local halfBtnHeight = 55
		--使用分数加成
	local userBuffLabel = TextField:create(labelText, nil, 26)
	userBuffLabel:setColor(ccc3(153, 102, 3))
	userBuffLabel:setAnchorPoint(ccp(0.5,0))
	self.ui:addChild(userBuffLabel)
	userBuffLabel:setPosition(ccp( pos.x , pos.y + halfBtnHeight -10 ))

	local kAnimationTime = 1/20

	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(kAnimationTime*10,ccp(0,20)))
	arr:addObject(CCCallFunc:create(function ()
		-- local leftBuffCount = math.max(context.leftBuffCount - 1, 0)
		-- leftTimeLabel:setText("x".. leftBuffCount)
	end))
	arr:addObject(CCSpawn:createWithTwoActions(
		 CCFadeOut:create(kAnimationTime*8),
		 CCMoveBy:create(kAnimationTime*8, ccp(0,10))
	))
	arr:addObject(CCCallFunc:create(function()
		if endCallback then endCallback() end
		userBuffLabel:removeFromParentAndCleanup(true)
	end))
	userBuffLabel:runAction(CCSequence:create(arr))
end


function LevelInfoPanel:onHideLayBuy()
	if self.isDisposed then return end
	if self.startButton then
		self.startButton:showActInfiniteEnergy(false)
	end
	CollectStarsManager.getInstance():setIsActivationBuff( false ) 
	self:flylabelTipsOnStartBtnWithText( "取消分数加成" )
end


function LevelInfoPanel:onShowLayBuy()
	if self.isDisposed then return end
	if self.startButton then
		self.startButton:showActInfiniteEnergy(true)
	end
	CollectStarsManager.getInstance():setIsActivationBuff( true ) 

	self:flylabelTipsOnStartBtnWithText( "使用分数加成" )
end

function LevelInfoPanel:onPigYearStartGameCreate()
	if self.isDisposed then return end

	self.collectStarsDoNotCreate = true

	if self.CollectStarCustomPanel then
		self.CollectStarCustomPanel:setVisible(false)
	end
	if self.CollectStarWinAnim then
		self.CollectStarWinAnim:setVisible(false)
	end

end
function LevelInfoPanel:updateCollectStarBuff()

	CollectStarsYEMgr.getInstance():setDelegate(self)

	local function showLadybugAnim()
		if not self.ladybugAnim then
			self.ladybugAnim = CollectStarsYEMgr.getInstance():buildStartGameLadybug()
			local halfBtnWidth = 120
			local halfBtnHeight = 55
			local pos = self.startButton:getPositionInScreen()
			pos = self.ui:convertToNodeSpace(pos)
			self.ui:addChild(self.ladybugAnim)
			self.ladybugAnim:setPosition(ccp(pos.x + halfBtnWidth, pos.y + halfBtnHeight))
			self.ladybugAnim:playShowAnim()
			self.startButton:showActInfiniteEnergy(true)
		else
			if CollectStarsManager.getInstance():isActivitySupport(  )  then
				self.ladybugAnim:updateNum()
			end
		end
	end

	if self.isDisposed then return end
	if CollectStarsYEMgr.getInstance():isBuffEffective(self.levelId, self.startLevelType , true ) then
		showLadybugAnim()
	else
		if self.CollectStarCustomPanel then
			self.CollectStarCustomPanel:setVisible(false)
		end
		if self.CollectStarWinAnim then
			self.CollectStarWinAnim:setVisible(false)
		end
		self.startButton:showActInfiniteEnergy(false)
		if self.ladybugAnim then
			self.ladybugAnim:removeFromParentAndCleanup(true)
			self.ladybugAnim = nil 
		end
	end


end

function LevelInfoPanel:updatePreBuffTitle()
	if self.isDisposed then return end
	if self.animNode  then
		self.animNode :removeFromParentAndCleanup(true)
	end
	self.animNode = nil 
	local curScene = Director:sharedDirector():getRunningScene()
	if PreBuffLogic:checkEnableBuff( self.levelId ) and curScene and curScene:is(HomeScene) then
		local hasUpgrade = PreBuffLogic:getBuffUpgradeOnLastPlayForLevelInfo()
		local buffLevel = PreBuffLogic:getBuffGradeAndConfig()
		if buffLevel >= 1 then
			PreBuffLogic:updateUserDefKey()
		end

		local halfBtnWidth = 120
		local halfBtnHeight = 55
		local pos = self.startButton:getPositionInScreen()
		pos = self.ui:convertToNodeSpace(pos)

		PreBuffLogic:loadLevelInfoSkeletonAssert()
		if PreBuffLogic:getBuffDisappear() and buffLevel == 0  then
			--消失
			local oldLevel = PreBuffLogic:getOldGrade()
			local animNode = ArmatureNode:create("PreBuffLogic_up/showAction_dis")
			self.ui:addChild( animNode )
			animNode:setPosition(ccp(pos.x + halfBtnWidth - 30, pos.y + halfBtnHeight + 30))
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
			end 
			animNode:addEventListener( ArmatureEvents.COMPLETE , onFinished )
			self.animNode = animNode
		elseif PreBuffLogic:willShowLevel0( self.levelId )  then
			--要显示0的碟子
			local animNode = ArmatureNode:create("PreBuffLogic_up/upeff2")
			self.ui:addChild( animNode )
			animNode:playByIndex(0, 1)
			animNode:setPositionX( 100 )
			animNode:setPositionY( -400 )
			local function onFinished()
			end 
			
			-- animNode:addEventListener( ArmatureEvents.COMPLETE , onFinished )
			local tipsTouchSprite = Layer:create()
			tipsTouchSprite:changeWidthAndHeight( 150 , 150 )
			self.ui:addChild( tipsTouchSprite )
			tipsTouchSprite:setPosition( ccp( 50 , -450 ) )
			local function showActionTips(  )
				if self.isDisposed then return end
				if self.animNodeTips then
					self.animNodeTips:playByIndex(0, 1)
				end
			end 
	    	local function createShowActionTips(  )
				if self.isDisposed then return end
				local animNodeTips = ArmatureNode:create("PreBuffLogic_up/upeff3")
				self.ui:addChild( animNodeTips )
				animNodeTips:playByIndex(0, 1)
				animNodeTips:setPositionX( 30 )
				animNodeTips:setPositionY( -375 )
				self.animNodeTips = animNodeTips
			end 
			UIUtils:setTouchHandler( tipsTouchSprite , function ()
	        	showActionTips()
	    	 end)
			setTimeOut(createShowActionTips, 0.5)
			self.animNode = animNode
		elseif buffLevel > 0 and hasUpgrade  then
			--升级
			local animNode = ArmatureNode:create("PreBuffLogic_up/upeff")
			self.ui:addChild( animNode )
			animNode:setPosition(ccp(pos.x + halfBtnWidth - 30, pos.y + halfBtnHeight + 30))
			if buffLevel > 0 then
				animNode:playByIndex(0, 1)
				local enmpySprite1 = Sprite:createEmpty()
				local enmpySprite2 = Sprite:createEmpty()
				if buffLevel > 1 then
					local png1 = Sprite:createWithSpriteFrameName( "PreBuff002Png/png"..(buffLevel-1).."0000" )
					enmpySprite1:addChild( png1 )
					png1:setPosition(ccp( 35, -35 ))
					PreBuffLogic:setBuffUpgradeOnLastPlayForLevelInfo( false )
				end
				local png2 = Sprite:createWithSpriteFrameName( "PreBuff002Png/png"..buffLevel.."0000" )
				png2:setPosition(ccp( 35, -35 ))

				enmpySprite2:addChild( png2 )
				local slot1 = animNode:getSlot( "png1" )
				slot1:setDisplayImage( enmpySprite1.refCocosObj )
				local slot2 = animNode:getSlot( "png2" )
				slot2:setDisplayImage( enmpySprite2.refCocosObj )	
			end
			self.animNode = animNode
		elseif buffLevel > 0  then
			local png2 = Sprite:createWithSpriteFrameName( "PreBuff002Png/png"..buffLevel.."0000" )
			self.ui:addChild( png2 )
			self.animNode = png2

			png2:setPosition(ccp(pos.x + halfBtnWidth, pos.y + halfBtnHeight))
		end
	end
end


-- 调用流程：
-- LevelInfoPanel:afterPopout -> check GameGuide in StartGamePanel -> LevelInfoPanel:afterPopoutAndAfterGuideCheck
function LevelInfoPanel:afterPopoutAndAfterGuideCheck()
	if self.isDisposed then return end

	self:initJumpLevelArea()	--因为此检测带独立引导面板，会和默认引导序列中的引导面板冲突，所以延后检测
	if self.jumpLevelIconArmature then
		self.jumpLevelIconArmature:playByIndex(0, 1)
	end

	if self.needCheckPopMagicBirdDiscountNotiPanel then
		self:popMagicBirdDiscountNotiPanel(self.discountGoodsID)
	end
end

function LevelInfoPanel:initJumpLevelArea( ... )
	if JumpLevelManager:getInstance():showJumpLevelGuide(self.levelId)  then
		self.guidePopedOut = true

		local Guide = require "zoo.panel.component.startGamePanel.JumpLevelGuide"
		Guide:create(self, function()
			self:__initJumpLevelArea( true )
		end , self.levelId )
	else
		self:__initJumpLevelArea()
	end
end
--优化开始面板UI，整合跳关与好友代打icon，去掉原添加好友气泡。
function LevelInfoPanel:shouldShowTwoBtnType( ... )
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


function LevelInfoPanel:closeTwoBtnAction()

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



function LevelInfoPanel:showTwoBtnAction()

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

function LevelInfoPanel:doAskForHelp()

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
	AskForHelpManager.getInstance():onAskForHelp(self.levelId, self.parentPanel)
	DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'trigger_icon', t1=self.levelId, t2=2})

end




function LevelInfoPanel:__initJumpLevelArea(bFromGuideEnd)
	if self.ui == nil or self.ui.isDisposed then return end

    if bFromGuideEnd == nil then bFromGuideEnd = false end

	local area = self.ui:getChildByName("jump_level_area")
	local pos = area:getPosition()

	--ui上的元件位置 和 骨骼动画里的位置 必须一模一样才对，否则就需要如下手动调整
	pos = ccp(pos.x + 7, pos.y + 35)

	-- isFakeIcon31-39关可见跳关按钮，但并走真正的逻辑
	-- 只是弹出tip提示xx关开启跳关功能
	local isFakeIcon = JumpLevelManager:shouldShowFakeIcon(self.levelId)
	if self:shouldShowTwoBtnType()>0 then
		if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
			FrameLoader:loadArmature('skeleton/jump_level_btn_animation_purple', 'jump_level_btn_animation_purple')
		elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then 
			FrameLoader:loadArmature('skeleton/jump_level_btn_animation_blue', 'jump_level_btn_animation_blue')
		else
			FrameLoader:loadArmature('skeleton/jump_level_btn_animation', 'jump_level_btn_animation')
		end
		local armature = nil
		if isFakeIcon and self:shouldShowTwoBtnType() == 2 then
			armature = ArmatureNode:create('skip2', true)
		else
			armature = ArmatureNode:create('skip', true)
		end

		local slot = armature:getSlot("skipbubble")
		if slot then
			local spriteBtn = nil
			if self:shouldShowTwoBtnType() == 3 then
				if self.uncommonSkin then
					spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "spring_2019/jump_level_btn0000" )
				else
					spriteBtn = SpriteColorAdjust:createWithSpriteFrameName( "panel_game_start_add/jump_level_btn0000" )
				end
				spriteBtn.name = "jumptwobtn"
				LevelPanelDifficultyChanger:changeNodeByDifficulty( spriteBtn ,self.levelFlag )
				self.newJumpBtn = spriteBtn
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
			if self.uncommonSkin then
			 	spriteBtn:setPositionXY(69.5,-26.5)
			else
				spriteBtn:setPositionXY(60,-50)
			end
			local sprite = Sprite:createEmpty()
			sprite:addChild(spriteBtn)
			slot:setDisplayImage(sprite.refCocosObj)
		end


		-- armature:setAnimationScale(0.7)
		armature:playByIndex(0, 1)
		armature:update(0.001)
		armature:stop()
		self.jumpLevelIconArmature = armature
		local layer = Layer:create()
		layer:addChild(armature)
		area:getParent():addChildAt(layer, area:getZOrder())
		layer:setPosition(ccp(pos.x, pos.y))

        if bFromGuideEnd then
            self.jumpLevelIconArmature:playByIndex(0, 1)
        end

		if self.afterPopoutFromFailPanel then
			self.jumpLevelArea = JumpLevelIcon:create(layer, self.levelId, self.levelType, nil, isFakeIcon,self)	
		else
			self.jumpLevelArea = JumpLevelIcon:create(layer, self.levelId, self.levelType, self, isFakeIcon)	
		end

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

		LevelPanelDifficultyChanger:changeBgByDifficulty( self.jumpLevelArea ,self.levelFlag,HomeScenePanelSkinType.kLevelInfoPanel)

		area:setVisible(false)
	else
		area:setVisible(false)
	end
end

function LevelInfoPanel:tryIngredientGuide(levelId)
	--if levelId == 13 then return end -- 13关有前置道具引导，金豆荚引导不在13关弹出

	--local uid = UserManager:getInstance().user.uid or "12345"
	--local key = 'jump.level.ingredient.guide'
	--if not CCUserDefault:sharedUserDefault():getBoolForKey(key, false) then
		if not self.hasAfterPopout then
	    	self.showIngredientGuide = true
	    	return
	    end

		if self.isGuideOnScreen then 
			GameGuide:sharedInstance():onGuideComplete()
			return 
		end
	    self.isGuideOnScreen = true

	    local size = self.fadeArea:getGroupBounds().size
	    local pos = self.fadeArea:getPosition()
	    pos = ccp(pos.x - 56, pos.y - size.height + 5)
	    pos = self.fadeArea:getParent():convertToWorldSpace(pos)
		local action = 
	    {
	        opacity = 0xCC, 
	        panType = "up", panAlign = "winY", panPosY = pos.y - 40, panFlip = true,
	        maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.3, touchDelay = 1,
	        panelName = 'guide_dialogue_ingredient_level'
	    }
	    local panel = GameGuideUI:panelS(nil, action, false)
	    local mask = GameGuideUI:mask(
	        action.opacity, 
	        action.touchDelay, 
	        pos,
	        1.5, 
	        true, 
	        size.width, 
	        size.height, 
	        false,
	        true)

	    mask.setFadeIn(action.maskDelay, action.maskFade)
	    self.guidePanel = panel
	    self.guideMask = mask
	    local function newOnTouch(evt)
	        self.isGuideOnScreen = false
	        if panel and not panel.isDisposed then
	            panel:removeFromParentAndCleanup(true)
	        end
	        if mask and not mask.isDisposed then
	            mask:removeFromParentAndCleanup(true)
	        end

	        GameGuide:sharedInstance():onGuideComplete()
	        --CCUserDefault:sharedUserDefault():setBoolForKey(key, true)
	    end
	    mask:removeEventListenerByName(DisplayEvents.kTouchTap)
	    mask:ad(DisplayEvents.kTouchTap, newOnTouch)
	    local scene = Director:sharedDirector():getRunningScene()
	    if scene then
	        scene:addChild(mask, SceneLayerShowKey.POP_OUT_LAYER)
	        scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)
	    end
	--end
end

function LevelInfoPanel:removeGuide()
	if self.guidePanel and not self.guidePanel.isDisposed then
		self.guidePanel:removeFromParentAndCleanup(true)
		self.guidePanel = nil
	end
	if self.guideMask and not self.guideMask.isDisposed then
		self.guideMask:removeFromParentAndCleanup(true)
		self.guideMask = nil
	end
	if GameGuide then
		GameGuide:sharedInstance():onClickReplay()
	end
end

function LevelInfoPanel:converPreItemIndexs(configIndexs)
	local preItemIndexs = {}
	-- 以前是以+3步为基准，优化后，相对位置不再固定，故不能沿用此法
	for i, v in ipairs(configIndexs) do
		local configVal = tonumber(v)
		if configVal > 10000 then
			-- 配置的是道具ID
			local targetPropIndex = self:getTargetPrePropIndex(configVal)
			if targetPropIndex <= 0 then targetPropIndex = 1 end
			table.insert(preItemIndexs, targetPropIndex)
		else
			-- 配置的是次序
			table.insert(preItemIndexs, configVal)
		end
	end

	return preItemIndexs
end

function LevelInfoPanel:getTargetPrePropIndex(propID)
	for i, v in ipairs(self.preGameTools) do
		if ItemType:getRealIdByTimePropId(v.itemId) == propID then
			return i
		end
	end
	return 0
end

function LevelInfoPanel:canShowPrePropVideoAd()
	local hasVideoAd = false
	for _,item in ipairs(self.preGameTools) do
		if item.isVideoAdOpen then
			hasVideoAd = true break
		end
	end
	if not hasVideoAd then return false end

	local time = CCUserDefault:sharedUserDefault():getIntegerForKey("videoad.preprop.show.anim.time", 0)
	local now = math.floor(Localhost:timeInSec()/3600/24)
	return time ~= now
end

function LevelInfoPanel:runPrePropVideoAdAnim()
	local time = math.floor(Localhost:timeInSec()/3600/24)
	CCUserDefault:sharedUserDefault():setIntegerForKey("videoad.preprop.show.anim.time", time)
	self.needRunVideoAdAction = false

	self.preItemsScrollable:scrollToLeftEnd(0.3)

    local bShowJumpLevelGuide = JumpLevelManager:getInstance():bCanShowJumpLevelGuide(self.levelId)
	setTimeOut(function ( ... )
		if self.isDisposed then return end
		for _,item in ipairs(self.preGameTools) do
			if item.isVideoAdOpen and not bShowJumpLevelGuide then
				item:showVideoAdTip(localize("watch_ad_startlevel_tip1", {n='\n'}))
			end
		end
	end, 0.4)
end

-- 引导用
function LevelInfoPanel:runShowPreProp( action )
	local scene = Director:sharedDirector():getRunningScene()
	if not scene then
		return
	end

	self:removeShowPreProp()

	if not self.hasAfterPopout then
		self.showPrePropAction = action
		return
	end

	self.guidePopedOut = true

	-- 前置道具引导特殊处理
	local preItemIndexs = self:converPreItemIndexs(action.preItemIndexs)

	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	
	local bounds = self.clippingAreaAbove:getGroupBounds()
	local maskSize = self.clippingAreaAbove:getGroupBounds(self.clippingAreaAbove).size

	local mask = LayerColor:create()
	mask:setOpacity(action.opacity)

	mask:changeWidthAndHeight(visibleSize.width, maskSize.height)
	mask:setPosition(self.clippingAreaAbove:convertToNodeSpace(ccp(
		visibleOrigin.x,bounds:getMinY() + 5
	)))
	mask:setScaleX(2) --startpanel 有缩放
	self.clippingAreaAbove:addChild(mask)

	local maskBounds = mask:getGroupBounds()

	local topMask = LayerColor:create()
	topMask:setOpacity(action.opacity)
	topMask:changeWidthAndHeight(
		visibleSize.width, 
		visibleSize.height - maskBounds:getMaxY()
	)
	topMask:setScale(2)
	topMask:setPositionX(maskBounds:getMinX())
	topMask:setPositionY(maskBounds:getMaxY())
	scene:addChild(topMask, SceneLayerShowKey.POP_OUT_LAYER)

	local bottomMask = LayerColor:create()
	bottomMask:setOpacity(action.opacity)
	bottomMask:changeWidthAndHeight(
		visibleSize.width, 
		maskBounds:getMinY()
	)
	bottomMask:setAnchorPoint(ccp(0,1))
	bottomMask:ignoreAnchorPointForPosition(false)
	bottomMask:setPositionX(maskBounds:getMinX())
	bottomMask:setPositionY(maskBounds:getMinY())
	scene:addChild(bottomMask, SceneLayerShowKey.POP_OUT_LAYER)

	local panel
	if action.panelName then
		panel = GameGuideUI:dialogue(nil, action, true)
		panel:setPositionX(maskBounds:getMinX() - 50)
		panel:setPositionY(maskBounds:getMinY())
		scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)

		local node = ArmatureNode:create("movein_tutorial_3")
		node:setPositionX(220)
		node:setPositionY(-50)
		node:playByIndex(0)
		node:setAnimationScale(1.25)
		node:setScaleX(-1)

		panel:addChild(node)
	end

	local function showHelp( ... )
		self.clippingAreaAbove:setChildIndex(
			self.helpIcon,
			self.clippingAreaAbove:getNumOfChildren()
		)
	end

	local function shwoPrePropByIndex( index )
		if action.showFree then
			self.preGameTools[index]:setFreePrice(true)
		end
		self:borrowPrePropUI(self.preGameToolResource[index], self.clippingAreaAbove)
		-- self.clippingAreaAbove:setChildIndex(
		-- 	self.preGameToolResource[index],
		-- 	self.clippingAreaAbove:getNumOfChildren()
		-- )
	end

	local function removeMask( ... )
		for k,v in pairs(preItemIndexs) do
			self:giveBackPrePropUI(self.preGameToolResource[v])
			if action.autoSelect then 
				self.preGameTools[v]:fakeIncreaseItemNumber() 		--就给引导用
				self:onPreGameItemTapped({context = v})
				local itemToolUI = self.preGameTools[v]:getUI()
				itemToolUI:removeEventListenerByName(DisplayEvents.kTouchTap)
			end
		end
		mask:removeFromParentAndCleanup(true)
		topMask:removeFromParentAndCleanup(true)
		bottomMask:removeFromParentAndCleanup(true)
		if panel then
			panel:removeFromParentAndCleanup(true)
		end
	end

	local function setLabelColor( index,color )
		local item = self.preGameToolResource[index]
		local unlockLabel = item:getChildByName("unlockLabel")
		if unlockLabel then unlockLabel:setColor(color) end
		local priceLabel = item:getChildByName("priceLabel")
		if priceLabel then priceLabel:setColor(color) end
		-- item:getChildByName("unlockLabel"):setColor(color)
		-- item:getChildByName("priceLabel"):setColor(color)
	end

	if action.helpIcon then
		showHelp()
	end
	for k,v in pairs(preItemIndexs) do
		shwoPrePropByIndex(v)		
		setLabelColor(v,ccc3(0xFF,0xFF,0xFF))
	end

	self.showPrePropGuideMask = mask
	function self.showPrePropGuideMask:remove( ... )
		removeMask()
		for k,v in pairs(preItemIndexs) do
			setLabelColor(v,ccc3(0x66,0x3C,0x11))
		end	
	end
end

function LevelInfoPanel:removeShowPreProp( ... )
	if self.isDisposed then return end
	self.showPrePropAction = nil

	if self.showPrePropGuideMask then
		self.showPrePropGuideMask:remove()
		self.showPrePropGuideMask = nil
	end
end

function LevelInfoPanel:getPreAdd3StepPropIndex()
	for i,v in ipairs(self.preGameTools) do
		if ItemType:getRealIdByTimePropId(v.itemId) == ItemType.ADD_THREE_STEP then
			return i
		end
	end
	return 0
end

function LevelInfoPanel:runNewShowPreProp(action)
	self:removeNewShowPreProp()

	if not self.hasAfterPopout then
		self.showNewPrePropAction = action
		return
	end

	local scene = Director:sharedDirector():getRunningScene()
	if not scene then
		return
	end

	-- 前置道具引导特殊处理
	local preItemIndexs = {}
	local add3StepIndex = self:getPreAdd3StepPropIndex()
	if add3StepIndex > 0 then
		self.preItemsScrollable:scrollToRightEnd(0)
		for i, v in ipairs(action.preItemIndexs) do
			table.insert(preItemIndexs, v + add3StepIndex - 1)
		end
	else
		preItemIndexs = action.preItemIndexs
	end

	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	
	local bounds = self.clippingAreaAbove:getGroupBounds()
	local maskSize = self.clippingAreaAbove:getGroupBounds(self.clippingAreaAbove).size

	local mask = LayerColor:create()
	mask:setOpacity(action.opacity)

	mask:changeWidthAndHeight(visibleSize.width, maskSize.height)
	mask:setPosition(self.clippingAreaAbove:convertToNodeSpace(ccp(
		visibleOrigin.x,bounds:getMinY()
	)))
	mask:setScaleX(2) --startpanel 有缩放
	self.clippingAreaAbove:addChild(mask)

	local maskBounds = mask:getGroupBounds()

	local topMask = LayerColor:create()
	topMask:setOpacity(action.opacity)
	topMask:changeWidthAndHeight(
		visibleSize.width, 
		visibleSize.height - maskBounds:getMaxY()
	)
	topMask:setScale(2)
	topMask:setPositionX(maskBounds:getMinX())
	topMask:setPositionY(maskBounds:getMaxY())
	scene:addChild(topMask, SceneLayerShowKey.POP_OUT_LAYER)

	local bottomMask = LayerColor:create()
	bottomMask:setOpacity(action.opacity)
	bottomMask:changeWidthAndHeight(
		visibleSize.width, 
		maskBounds:getMinY()
	)
	bottomMask:setAnchorPoint(ccp(0,1))
	bottomMask:ignoreAnchorPointForPosition(false)
	bottomMask:setPositionX(maskBounds:getMinX())
	bottomMask:setPositionY(maskBounds:getMinY())
	scene:addChild(bottomMask, SceneLayerShowKey.POP_OUT_LAYER)

	local panel
	if action.panelName then
		panel = GameGuideUI:dialogue(nil, action, true)
		panel:setPositionX(maskBounds:getMinX() - 50)
		panel:setPositionY(maskBounds:getMinY())
		scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)
	end

	local function showHelp( ... )
		self.clippingAreaAbove:setChildIndex(
			self.helpIcon,
			self.clippingAreaAbove:getNumOfChildren()
		)
	end

	local function shwoPrePropByIndex( index )
		self:borrowPrePropUI(self.preGameToolResource[index], self.clippingAreaAbove)
		-- self.clippingAreaAbove:setChildIndex(
		-- 	self.preGameToolResource[index],
		-- 	self.clippingAreaAbove:getNumOfChildren()
		-- )
	end

	local function removeMask( ... )
		for k,v in pairs(preItemIndexs) do
			self:giveBackPrePropUI(self.preGameToolResource[v])
		end
		mask:removeFromParentAndCleanup(true)
		topMask:removeFromParentAndCleanup(true)
		bottomMask:removeFromParentAndCleanup(true)
		if panel then
			panel:removeFromParentAndCleanup(true)
		end
	end

	local function setLabelColor( index,color )
		local item = self.preGameToolResource[index]
		item:getChildByName("unlockLabel"):setColor(color)
		item:getChildByName("priceLabel"):setColor(color)
	end

	for k,v in pairs(preItemIndexs) do
		shwoPrePropByIndex(v)		
		setLabelColor(v,ccc3(0xFF,0xFF,0xFF))
	end

	self.showNewPrePropGuideMask = mask
	function self.showNewPrePropGuideMask:remove( ... )
		removeMask()
		for k,v in pairs(preItemIndexs) do
			setLabelColor(v,ccc3(0x66,0x3C,0x11))
		end	
	end
end

function LevelInfoPanel:removeNewShowPreProp( ... )
	if self.isDisposed then return end
	self.showNewPrePropAction = nil

	if self.showNewPrePropGuideMask then
		self.showNewPrePropGuideMask:remove()
		self.showNewPrePropGuideMask = nil
	end
end


function LevelInfoPanel:runShowStartButton( action , closeCallback )
	--if true then return end
	printx( 1 , "   LevelInfoPanel:runShowStartButton   " , action , closeCallback)
	if not self.showStartButtonCloseCallback then
		self.showStartButtonCloseCallback = closeCallback
	end

	local scene = Director:sharedDirector():getRunningScene()
	if not scene then
		return
	end
	--[[
	action = {}
	action.opacity = action.opacity or 0xCC
	action.helpIcon = action.helpIcon or true
	action.preItemIndexs = action.preItemIndexs or {1}
	action.panelName = "guide_dialogue_43_1"
	action.panDelay = 1
	action.panFade = 1
	]]

	action.helpIcon = false
	action.preItemIndexs = {}
	--self:removeShowStartButton()
	if not self.hasAfterPopout then
		self.showStartButtonAction = action
		return
	end

	self.parentPanel.rankListTouchEnabled = false

	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	
	local bounds = self.clippingAreaAbove:getGroupBounds()
	local maskSize = self.clippingAreaAbove:getGroupBounds(self.clippingAreaAbove).size

	local mask = LayerColor:create()
	mask:setOpacity(action.opacity)
	--mask:setOpacity(40)

	mask:changeWidthAndHeight(visibleSize.width, maskSize.height)
	mask:setPosition(self.clippingAreaAbove:convertToNodeSpace(ccp(
		visibleOrigin.x,bounds:getMinY()
	)))
	mask:setScaleX(2) --startpanel 有缩放
	self.clippingAreaAbove:addChild(mask)
	mask:setTouchEnabled(true, 0 , true)

	local maskBounds = mask:getGroupBounds()

	local topMask = LayerColor:create()
	topMask:setOpacity(action.opacity)
	topMask:changeWidthAndHeight(
		visibleSize.width, 
		visibleSize.height - maskBounds:getMaxY() + 200
	)
	topMask:setScale(2)
	--topMask:setAnchorPoint(ccp(0,0))

	local topMaskPos = self:getParent():convertToNodeSpace( ccp( maskBounds:getMinX() , maskBounds:getMaxY() ) )
	topMask:setPositionXY( topMaskPos.x , topMaskPos.y )
	--topMask:setPositionX(maskBounds:getMinX())
	--topMask:setPositionY(maskBounds:getMaxY())
	--scene:addChild(topMask, SceneLayerShowKey.POP_OUT_LAYER)
	self:getParent():addChild(topMask)
	topMask:setTouchEnabled(true, 0, true)

	local bounds_bottom = self.clippingAreaBelow:getGroupBounds()

	local bottomMask = LayerColor:create()
	bottomMask:setOpacity(action.opacity)
	--bottomMask:setOpacity(150)
	bottomMask:changeWidthAndHeight(
		visibleSize.width, 
		maskBounds:getMinY()
		--50
	)
	bottomMask:setScaleX(2)
	bottomMask:setScaleY(2)
	bottomMask:setAnchorPoint(ccp(0,1))
	bottomMask:ignoreAnchorPointForPosition(false)

	local bottomMaskPos = self.clippingAreaBelow:convertToNodeSpace( mask:convertToWorldSpace( ccp(0,0) ) )
	bottomMask:setPositionXY(bottomMaskPos.x , bottomMaskPos.y )
	self.clippingAreaBelow:addChild(bottomMask)
	--scene:addChild(bottomMask, SceneLayerShowKey.POP_OUT_LAYER)
	bottomMask:setTouchEnabled(true, 0, true)

	--clippingAreaBelow

	local panel
	if action.panelName then
		panel = GameGuideUI:dialogue(nil, action, true)

		local panelPos = self:getParent():convertToNodeSpace( 
											ccp( 
												maskBounds:getMinX() + tonumber(action.fixPosX) , 
												maskBounds:getMinY() + tonumber(action.fixPosY) 
												) 
											)

		panel:setPositionXY( panelPos.x - 20 , panelPos.y + 50)
		--panel:setPositionX(maskBounds:getMinX() + tonumber(action.fixPosX) )
		--panel:setPositionY(maskBounds:getMinY() + tonumber(action.fixPosY) )
		--scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)
		self:getParent():addChild(panel)
		
		--[[
		local node = ArmatureNode:create("movein_tutorial_3")
		node:setPositionX(220)
		node:setPositionY(-50)
		node:playByIndex(0)
		node:setAnimationScale(1.25)
		node:setScaleX(-1)
		

		panel:addChild(node)
		--]]
	end

	local btn = GroupButtonBase:create(ResourceManager:sharedInstance():buildGroup('ui_buttons_new/btn_text'))
	btn:setScale(0.8)
	btn:setString('知道了')
	self:getParent():addChild(btn.groupNode)
	local pos = self:getParent():convertToNodeSpace(ccp(visibleOrigin.x+visibleSize.width/2, visibleOrigin.y+visibleSize.height/12 - 15))
	btn:setPositionX(pos.x)
	btn:setPositionY(pos.y)

	local function showHelp( ... )
		self.clippingAreaAbove:setChildIndex(
			self.helpIcon,
			self.clippingAreaAbove:getNumOfChildren()
		)
	end

	local function showStartLevelButton()
		self.clippingAreaBelow:setChildIndex(
			self.startButton.groupNode,
			self.clippingAreaBelow:getNumOfChildren()
		)
	end

	local function showPrePropByIndex( index )
		self.clippingAreaAbove:setChildIndex(
			self.preGameToolResource[index],
			self.clippingAreaAbove:getNumOfChildren()
		)
	end

	local function removeMask( ... )
		mask:removeFromParentAndCleanup(true)
		topMask:removeFromParentAndCleanup(true)
		bottomMask:removeFromParentAndCleanup(true)
		if panel then
			panel:removeFromParentAndCleanup(true)
		end
		btn:removeFromParentAndCleanup(true)
	end

	local function setLabelColor( index,color )
		local item = self.preGameToolResource[index]
		item:getChildByName("unlockLabel"):setColor(color)
		item:getChildByName("priceLabel"):setColor(color)
	end

	if action.helpIcon then
		showHelp()
	end

	if action.showStartLevelButton then
		--showStartLevelButton()
	end
	showStartLevelButton()

	for k,v in pairs(action.preItemIndexs) do
		showPrePropByIndex(v)		
		setLabelColor(v,ccc3(0xFF,0xFF,0xFF))
	end

	self.showStartButtonGuideMask = mask
	function self.showStartButtonGuideMask:remove( ... )
		removeMask()
		for k,v in pairs(action.preItemIndexs) do
			setLabelColor(v,ccc3(0x66,0x3C,0x11))
		end	
	end

	local function onTapped()
		if self.showStartButtonCloseCallback then
			self.showStartButtonCloseCallback()
		end
		self.parentPanel.rankListTouchEnabled = true
	end
	----[[
	-- mask:addEventListener(DisplayEvents.kTouchBegin,onTapped)
	-- bottomMask:addEventListener(DisplayEvents.kTouchBegin,onTapped)
	-- topMask:addEventListener(DisplayEvents.kTouchBegin, onTapped)
	btn:ad(DisplayEvents.kTouchTap, onTapped)
	--]]

	self.startButton:setEnabled(false, true)
	self.allowBackKeyTap = false
	self.parentPanel.allowBackKeyTap = false
	
end

function LevelInfoPanel:removeShowStartButton( ... )
	self.startButton:setEnabled(true, true)
	self.showStartButtonAction = nil
	self.showStartButtonCloseCallback = nil
	if self.showStartButtonGuideMask then
		self.showStartButtonGuideMask:remove()
		self.showStartButtonGuideMask = nil
	end
	self.allowBackKeyTap = true
	self.parentPanel.allowBackKeyTap = true
end

function LevelInfoPanel:selectPreProp(propId)
	local function doFly()
		local item, index = table.find(self.preGameTools, function(v) 
			if v.isTimeProp then
				return ItemType:getRealIdByTimePropId( tonumber(  v:getItemId() ) ) == propId
				-- return ItemType:getTimePropItemByRealId(propId) == tonumber(v:getItemId())
			else
				return tonumber(v:getItemId()) == propId
			end
		end)
		if not item then return end
		-- onArrive()
		if ItemType:isTimeProp(propId) then
			propId = ItemType:getRealIdByTimePropId(propId)
		end
		local icon = ResourceManager:sharedInstance():buildItemSprite(propId)
		icon:setAnchorPoint(ccp(0.5, 0.5))
		local dest_pos = item.itemRes:getParent():convertToWorldSpace(item.itemRes:getPosition())
		local btn_pos = self.startButton:getParent():convertToWorldSpace(self.startButton:getPosition())
		local scene = Director:sharedDirector():getRunningSceneLua()
		scene:addChild(icon)
		icon:setPosition(btn_pos)
		local function onArrive()
			if icon then
				icon:removeFromParentAndCleanup(true)
				icon = nil
			end
			if self.isDisposed or not self.ui or self.ui.isDisposed then return end
			self:onPreGameItemTapped({context = index})
		end
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(1))
		arr:addObject(CCMoveTo:create(0.5, dest_pos))
		arr:addObject(CCCallFunc:create(onArrive))
		icon:runAction(CCSequence:create(arr))
	end
	self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(doFly)))

end

function LevelInfoPanel:levelDiffcultFlagVisable()
	LevelPanelDifficultyChanger:changeBgByDifficulty(self,self.levelFlag,HomeScenePanelSkinType.kLevelInfoPanel)


	local fntFile, fntScale = WorldSceneShowManager.getInstance():getPanelTitleFntInfo()

	local levelLabelPlaceholderPosY	= self.levelLabelPlaceholder:getPositionY()

	local panelTitle = nil
	local levelDisplayName = nil 
	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then

		levelDisplayName = "第"..self.levelId.."关"

		panelTitle = BitmapText:create(levelDisplayName, "fnt/helllevel.fnt", -1, kCCTextAlignmentCenter)
		panelTitle:setScale(0.8)	
	else

		if self.levelFlag == LevelDiffcultFlag.kDiffcult then

			local parent = self.ui:getChildByName("bg")

			levelDisplayName = LevelMapManager.getInstance():getLevelDisplayName(self.levelId)

			panelTitle = PanelTitleLabel:create(levelDisplayName)

		end

		local function disposePanelTitleIfNeeded( ... )
			if panelTitle and (not panelTitle.isDisposed) then
				panelTitle:dispose()
				panelTitle = nil
			end
		end


		if PublishActUtil:isGroundPublish() then
			disposePanelTitleIfNeeded()
			panelTitle = BitmapText:create("精彩活动关", "fnt/titles.fnt", -1, kCCTextAlignmentCenter)
		else
			-- compatible with weekly race mode
			if self.levelType == GameLevelType.kDigWeekly then
				levelDisplayName = Localization:getInstance():getText('weekly.race.panel.start.title')
				local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
				disposePanelTitleIfNeeded()
				panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
			elseif self.levelType == GameLevelType.kTaskForUnlockArea then 
				levelDisplayName = Localization:getInstance():getText("recall_text_5")
				local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
				disposePanelTitleIfNeeded()
				panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)

			elseif self.levelType == GameLevelType.kSpring2019 then 
				levelDisplayName = string.format("周年第%d关",self.levelId-PigYearStartGame.ACT_LEVEL_START)
				local len = string.utf8len(levelDisplayName)
				disposePanelTitleIfNeeded()
				panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len, fntFile)
				if fntScale then panelTitle:setScale(fntScale) end

			else
				levelDisplayName = LevelMapManager.getInstance():getLevelDisplayName(self.levelId)
				disposePanelTitleIfNeeded()
				panelTitle = PanelTitleLabel:create(levelDisplayName, nil, nil, nil, nil, nil, fntFile)
				if fntScale then panelTitle:setScale(fntScale) end
			end
		end

	end
		
	local contentSize = panelTitle:getContentSize()
	local zorder = self.levelLabelPlaceholder:getZOrder()
	self.ui:addChildAt(panelTitle, zorder)
	panelTitle:ignoreAnchorPointForPosition(false)
	panelTitle:setAnchorPoint(ccp(0,1))
	panelTitle:setPositionY(levelLabelPlaceholderPosY)
	panelTitle:setToParentCenterHorizontal()
end

----------------------------- Discount Goods Activity -----------------------------------
function LevelInfoPanel:checkPreMagicBirdDiscountAct()
	-- 22级以前的开始面板不显示该活动（因为21关会有魔力鸟引导，引导中又会给一个魔力鸟，所以产品决定不在此关显示活动）
	if self.levelId and self.levelId < 22 then
		return
	end

	local keyName = "BirdDiscountIOS"
	-- local groupIDs = {"D6", "D7", "D8", "D9"}	-- 分组
	-- local goodsIDs = {583, 584, 585, 586}		-- 分组对应的GoodsID
	local configGoodsID = 583

	local function getGoodsIDOfbirdDiscount()
		local currGoodsID = 0

		-- for index = 1, #groupIDs do
		-- 	local groupID = groupIDs[index]
		-- 	local activityOpened = MaintenanceManager:getInstance():isEnabledInGroup(keyName, groupID, UserManager:getInstance().uid)
		-- 	-- printx(11, "group:", groupID, ". opened:", activityOpened)
		-- 	if activityOpened then
		-- 		currGoodsID = goodsIDs[index]
		-- 		break
		-- 	end
		-- end
		
		-- local activityOpened = MaintenanceManager:getInstance():isEnabledConsiderBeginAndEndDate(keyName)
		local activityOpened = MaintenanceManager:getInstance():isEnabled(keyName)
		if activityOpened then
			local activityBeginTime = -1
			local activityEndTime = -1
			local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey(keyName)
			if maintenance then
				if maintenance.beginDate then
					activityBeginTime = parseDateStringToTimestamp(maintenance.beginDate)
				end
				if maintenance.endDate then
					activityEndTime = parseDateStringToTimestamp(maintenance.endDate)
					activityEndTime = activityEndTime + 3600 * 24	-- 配置的是有效的开启时间，因为活动持续24小时，所以结束后1天内仍需检测活动
				end
			end
			local nowTime = Localhost:timeInSec()
			-- printx(11, "nowTime, activityBeginTime, endTime:", nowTime, activityBeginTime, activityEndTime)
			if activityBeginTime and activityEndTime 
				and activityBeginTime <= nowTime 
				and activityEndTime >= nowTime
				then
				-- 时间符合
				currGoodsID = configGoodsID
			end
		end
		
		return currGoodsID
	end

	local preMagicBird = self:getCanShowDiscountPreMagicBird() 
	if preMagicBird then
		local currGoodsID = getGoodsIDOfbirdDiscount()
		-- printx(11, "currGoodsID -- outer", currGoodsID)
		if currGoodsID and currGoodsID > 0 then
			-- 对该用户开关是打开的
		else
			-- 开关关着不做后续检测了
			return
		end

		local function onCheckEndTimeCallback(evt)
			-- printx(11, "=== onCheckEndTimeCallback ===")
			local inActivityPeriod = false

			if evt and evt.data and evt.data.extra then
				local rawActivityStartTime = evt.data.extra
				-- printx(11, "raw activityStartTime:", rawActivityStartTime)
				local activityStartTime = tonumber(rawActivityStartTime)
				if activityStartTime > 0 then
					activityStartTime = activityStartTime / 1000 -- 毫秒to秒

					-- 首先判断，触发时间是在活动结束之前（因为后端不会判断开关时间，所以活动结束后24小时内首次获取时间会出现触发时间在活动结束后）
					local maintenanceEndTime = -1
					local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey(keyName)
					if maintenance and maintenance.endDate then
						maintenanceEndTime = parseDateStringToTimestamp(maintenance.endDate)
					end

					-- printx(11, "maintenanceEndTime, activityStartTime", maintenanceEndTime, activityStartTime)
					if (maintenanceEndTime > 0) and (activityStartTime < maintenanceEndTime) then
						local activityEndTime = activityStartTime + 3600 * 24
						local nowTime = Localhost:timeInSec()
					    -- printx(11, "nowTime, endTime:", nowTime, activityEndTime)
						if activityEndTime > nowTime then
							self.discountEndTime = activityEndTime
							inActivityPeriod = true
						end
					end
				end
			end
			
			if inActivityPeriod then
				local currGoodsID = getGoodsIDOfbirdDiscount()
				-- printx(11, "currGoodsID -- inner", currGoodsID)
				if currGoodsID and currGoodsID > 0 then
					-- 为防止回调间的状态变化，再取一次
					preMagicBird = self:getCanShowDiscountPreMagicBird()
					if preMagicBird then
				        nowTime = Localhost:timeInSec()
				        preMagicBird:setDiscountStatus(currGoodsID)

			        	self:addDiscountPreMagicBirdCountDown(preMagicBird)

			        	self.needCheckPopMagicBirdDiscountNotiPanel = true
			        	self.discountGoodsID = currGoodsID
					end
				end
			end
		end

		local function hasNoNetwork()
			-- 没有联网，不显示该活动
			-- printx(11, "=== not network ===")
		end

		local function hasNetwork()
			-- printx(11, "=== has network ===")

			local http = OpNotifyHttp.new(true)
		    http:ad(Events.kComplete, onCheckEndTimeCallback)
		    -- http:ad(Events.kError, onRequestFail)
		    -- http:ad(Events.kCancel, onRequestCancel)
			http:syncLoad(OpNotifyType.kPreMagicBirdDiscountIOS)
		end

		PaymentNetworkCheck:getInstance():check(hasNetwork, hasNoNetwork, true)
	end
end

function LevelInfoPanel:getCanShowDiscountPreMagicBird()
	local preMagicBird
	for i, v in ipairs(self.preGameTools) do
		if ItemType:getRealIdByTimePropId(v.itemId) == ItemType.PRE_RANDOM_BIRD then
			preMagicBird = v
		end
	end

	-- 目前显示的是可风车币购买状态，即，不持有该道具、已解锁该道具等
	if preMagicBird then
		-- printx(11, "pre magic bird display status:", preMagicBird.isDisposed, preMagicBird:isSelected(), preMagicBird.isVideoAdOpen, preMagicBird:isHappyCoinDisplayVisible())
	end
	if preMagicBird 
		and not preMagicBird.isDisposed 
		and not preMagicBird:isSelected() 
		and not preMagicBird.isVideoAdOpen
		and preMagicBird:isHappyCoinDisplayVisible() 
		then
		return preMagicBird
	end

	return nil
end

function LevelInfoPanel:addDiscountPreMagicBirdCountDown(preMagicBird)
	local preMagicBirdUI
	local preMagicBirdUIIndex = -1
	if preMagicBird and preMagicBird.itemId then
		preMagicBirdUIIndex = self:getTargetPrePropIndex(preMagicBird.itemId)
		if preMagicBirdUIIndex > 0 then
			preMagicBirdUI = self.preGameToolResource[preMagicBirdUIIndex]
		end
	end

	if not preMagicBirdUI or preMagicBirdUI.isDisposed then
		return
	end

	local countDownPlate = ResourceManager:sharedInstance():buildGroup("z_new_2017_game/timeLimitPop")
	if countDownPlate and self.clippingAreaAbove and not self.clippingAreaAbove.isDisposed then
		self.countDownPlate = countDownPlate
		
		local flagView = self.clippingAreaAbove:getChildByName("flag")
		if flagView then
			local flagIndex = self.clippingAreaAbove:getChildIndex(flagView)
			self.clippingAreaAbove:addChildAt(self.countDownPlate, flagIndex + 1)
		else
			self.clippingAreaAbove:addChild(self.countDownPlate)
		end

		local pos = preMagicBirdUI:getPosition()
		self.countDownPlate:setPosition(ccp(pos.x + 27, pos.y))

		local countDownLabel = self.countDownPlate:getChildByName("countDownLabel")
		if countDownLabel then
			countDownLabel:setPosition(ccp(70, -12))
		end

		self:updateDiscountCountDown()
		self:scheduleDiscountCountdown()
	end
end

function LevelInfoPanel:stopDiscountCountdown()
	if self.scheduleScriptFuncID ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID) 
		self.scheduleScriptFuncID = nil
	end
end

function LevelInfoPanel:scheduleDiscountCountdown()
	if self.scheduleScriptFuncID == nil then
		self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(
			function() self:updateDiscountCountDown() end, 1, false
			)
	end
end

function LevelInfoPanel:updateDiscountCountDown()
	self:stopDiscountCountdown()

	if self.isDisposed then return end
	if not self.countDownPlate or self.countDownPlate.isDisposed then return end

	local cdInSec = self.discountEndTime - Localhost:timeInSec()
	if cdInSec > 0 then
		local countDownLabel = self.countDownPlate:getChildByName("countDownLabel")
		if countDownLabel then
			local strTime = getTimeFormatString(cdInSec, 1)
			countDownLabel:setString(strTime)
		end

		self:scheduleDiscountCountdown()
	else
		-- 倒计时结束
		self:endPreMagicBirdDiscountAct()
	end
end

-- 开着面板的时候，倒计时结束，关闭显示
function LevelInfoPanel:endPreMagicBirdDiscountAct()
	self.discountEndTime = -1
	self.discountGoodsID = nil

	local preMagicBird = self:getCanShowDiscountPreMagicBird()
	if preMagicBird then
		preMagicBird:setDiscountStatus(self.discountGoodsID)
	end
	

	if self.countDownPlate and not self.countDownPlate.isDisposed then
		self.countDownPlate:setVisible(false)
		self.countDownPlate:dispose()
		self.countDownPlate = nil
	end

	self:stopDiscountCountdown()
end




function LevelInfoPanel:popMagicBirdDiscountNotiPanel(currGoodsID)
	if not currGoodsID then return end
	if self.guidePopedOut then 
		return 
	end

	local popFlag = Localhost:readFileData("magicBirdDiscountNotiPoped_2nd")
	if popFlag and popFlag == "true" then
		return
	end

	local goodsData = MetaManager.getInstance():getGoodMeta(currGoodsID)
	if goodsData and goodsData.discountQCash > 0 then
		local price = goodsData.discountQCash
		local origPrice = goodsData.qCash
		local discountPercent = BuyLogic:getDiscountPercentageForDisplay(origPrice, price)

		if discountPercent > 0 and discountPercent < 10 then
			local PrePropDiscountNotiPanel = require "zoo.panel.component.startGamePanel.PrePropDiscountNotiPanel"
			local notiPanel = PrePropDiscountNotiPanel:create(discountPercent)
			if notiPanel then
				notiPanel:popout()
				Localhost:writeToFile("magicBirdDiscountNotiPoped_2nd", "true")
				DcUtil:UserTrack({category = 'birddiscount', sub_category = 'push_icon', t1 = discountPercent})
			end
		end
	end
end

