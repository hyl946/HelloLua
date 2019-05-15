
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月18日 11:47:16
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.common.CommonAction"
require "hecore.display.ParticleSystem"
require "zoo.panel.component.levelSuccessPanel.RewardItem"
require "zoo.data.MetaManager"

require "zoo.panel.component.common.BubbleCloseBtn"
require "zoo.panel.component.LevelPanelDifficultyChanger"
-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
-- local FTWUI = require 'zoo.localActivity.FindingTheWay.FindingTheWayUI'


-- require 'zoo.localActivity.CollectStars.CollectStarsManager'

require "zoo.localActivity.PigYear.PigYearStartGame"

local UserReviewLogic = require 'zoo.gamePlay.review.UserReviewLogic'
---------------------------------------------------
-------------- LevelSuccessTopPanel
---------------------------------------------------

assert(not LevelSuccessTopPanel)
assert(BaseUI)
LevelSuccessTopPanel = class(BaseUI)

--四星展示相关
LevelSuccessStar4Tpye = {
	kNormal = 1 ,	--原逻辑
	kFirstStar3 = 2,	--首次3星
	kShowStar4 = 3, --显示3星半
}


function LevelSuccessTopPanel:create(parentPanel, levelId, levelType, newScore, rewardItemsDataFromServer, extraCoin, activityForceShareData,panelType,panelTypeData,buffUpgrade, ...)
	assert(parentPanel)
	assert(type(levelId) == "number")
	assert(type(levelType) == "number")
	assert(type(newScore) == "number")
	assert(rewardItemsDataFromServer)
	assert(extraCoin)
	assert(#{...} == 0)


	-- local FTWLocalLogic = require 'zoo.localActivity.FindingTheWay.FindingTheWayLocalLogic'
	-- if not (F/TWLocalLogic:isActEnabled()) then
		-- NextLevelButtonProxy:getInstance():setFindTheWayEnabled(false)
	-- end


	if not panelType then panelType = LevelSuccessPanelTpye.kNomal end
	-- self.panelType = panelType

	--panelType = LevelSuccessPanelTpye.kOlympic -- for test

	local newLevelSuccessTopPanel = LevelSuccessTopPanel.new()
	newLevelSuccessTopPanel:init(parentPanel, levelId, levelType, newScore, rewardItemsDataFromServer, extraCoin, activityForceShareData, panelType , panelTypeData, buffUpgrade)
	return newLevelSuccessTopPanel
end

function LevelSuccessTopPanel:dispose()
	BaseUI.dispose(self)

	local QixiManager = require 'zoo.eggs.QixiManager'
	-- if QixiManager:getInstance():shouldSeeRose() then
		QixiManager:getInstance():unloadSkeletonAssert()
	-- end
	if CountdownPartyManager.getInstance():shouldShowActCollection(self.levelId) then
		CountdownPartyManager.getInstance():unloadSkeletonAssert()
	end

    if DragonBuffManager.getInstance():shouldShowActCollection(self.levelId) then
		DragonBuffManager.getInstance():unloadSkeletonAssert()
	end

    if Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(self.levelId) then
		Thanksgiving2018CollectManager.getInstance():unloadSkeletonAssert()
	end

	if PublicServiceManager:shouldShowActCollection(self.levelId) then
		PublicServiceManager:unloadSkeletonAssert()
	end

	if CollectStarsManager.getInstance():isBuffEffective(self.levelId , self.levelType ) then
		CollectStarsManager:unloadSkeletonAssert()
	end
	
	CollectStarsManager:unloadProp10113()
	FrameLoader:unloadArmature('skeleton/LevelDiffcultFlag/numEft', true )
	FrameLoader:unloadArmature('skeleton/LevelDiffcultFlag/level_tips', true )
	FrameLoader:unloadArmature('skeleton/LadybugFourStarAnimation', true )

	if _G.isLocalDevelopMode then printx(0, "dispose levelSuccessTopPanel") end
end

function LevelSuccessTopPanel:updateRewardItemPos( rewardNum )

	self.rewardItempos1 = self.ui:getChildByName("rewardItempos1")
	self.rewardItempos2 = self.ui:getChildByName("rewardItempos2")
	self.rewardItempos3 = self.ui:getChildByName("rewardItempos3")
		
	self.rewardItempos1:setVisible(false)
	self.rewardItempos2:setVisible(false)
	self.rewardItempos3:setVisible(false)

	local isFourModel = rewardNum >= 4 
	-- printx(104 , "updateRewardItemPos isFourModel rewardNum = " , isFourModel ,rewardNum)

	local offset = - 72/2
	if not isFourModel then
		self.rewardItem1:setPositionX( self.rewardItempos1:getPositionX() + offset )
		self.rewardItem2:setPositionX( self.rewardItempos2:getPositionX() + offset )
		self.rewardItem3:setPositionX( self.rewardItempos3:getPositionX() + offset )
	else

	end
	self.rewardItem4:setVisible( isFourModel )

end

function LevelSuccessTopPanel:init(parentPanel, levelId, levelType, newScore, rewardItemsDataFromServer, extraCoin, activityForceShareData, panelType,panelTypeData,buffUpgrade, ...)
	assert(parentPanel)
	assert(type(levelId) == "number")
	assert(type(newScore) == "number")
	assert(rewardItemsDataFromServer)
	assert(extraCoin)
	assert(#{...} == 0)

	self.isActLevel = LevelType:isSpringFestival2019Level( levelId ) 

	local QixiManager = require 'zoo.eggs.QixiManager'
	-- if QixiManager:getInstance():shouldSeeRose() then
		QixiManager:getInstance():loadSkeletonAssert()
	-- end
	if CountdownPartyManager.getInstance():shouldShowActCollection(levelId) then
		CountdownPartyManager.getInstance():loadSkeletonAssert()
	end

    if DragonBuffManager.getInstance():shouldShowActCollection(levelId) then
		DragonBuffManager.getInstance():loadSkeletonAssert()
	end


    if  Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(levelId) then
		Thanksgiving2018CollectManager.getInstance():loadSkeletonAssert()
	end

	if PublicServiceManager:shouldShowActCollection(levelId) then
		PublicServiceManager:addTotalTargetCount( 1 )
		PublicServiceManager:loadSkeletonAssert()
	end


	if CollectStarsManager.getInstance():isBuffEffective(self.levelId,self.levelType) then
		CollectStarsManager:loadSkeletonAssert()
	end
	if CollectStarsManager.getInstance():getAutoAddBuffNum() >0 then
		CollectStarsManager:loadProp10113()
	end
	self.panelType = panelType

	self.buffUpgrade = buffUpgrade

	self.isInterfaceBuilder = false

	-- ---------------
	-- Get UI Resource
	-- ----------------
	printx( 1 , "    LevelSuccessTopPanel:init   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    panelType = " , panelType)

	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelSucTopPanel)
	self.uncommonSkin = uncommonSkin
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

	self.panelTypeData = panelTypeData

	self.scoreLabel		= self.ui:getChildByName("scoreLabel")
	self.rewardTxt		= self.ui:getChildByName("rewardTxt")
	self.star1Res		= self.ui:getChildByName("star1")
	self.star2Res		= self.ui:getChildByName("star2")
	self.star3Res		= self.ui:getChildByName("star3")
	self.star4Res 		= self.ui:getChildByName("star4")

	self.starRes		= {self.star1Res, self.star2Res, self.star3Res, self.star4Res}

	self.star1Bg		= self.ui:getChildByName("star1Bg")
	self.star2Bg		= self.ui:getChildByName("star2Bg")
	self.star3Bg		= self.ui:getChildByName("star3Bg")
	self.star4Bg 		= self.ui:getChildByName("star4Bg")
	self.starBgs 		= {self.star1Bg, self.star2Bg, self.star3Bg, self.star4Bg}
	self.star4Bg:setVisible(false) --  hide the forth star

	self.rewardItem1Res	= self.ui:getChildByName("rewardItem1")
	self.rewardItem2Res	= self.ui:getChildByName("rewardItem2")
	self.rewardItem3Res	= self.ui:getChildByName("rewardItem3")
	self.rewardItem4Res	= self.ui:getChildByName("rewardItem4")


	self.nextLevelBtnRes	= self.ui:getChildByName("nextLevelBtn")
	-- self.shareToWeiBoBtnRes	= self.ui:getChildByName("shareToWeiBoBtn")
	
	self.nextLevelBtnShadowRes	= self.ui:getChildByName("nextLevelBtn_shadow")
	-- self.shareToWeiBoBtnShadowRes	= self.ui:getChildByName("shareToWeiBoBtn_shadow")

	if self.nextLevelBtnShadowRes then
		--春节皮肤
		local function addShadow(shadow,btn,scaleEx)
			shadow:setScaleX(1)
			shadow:setScaleY(1)
			local size = btn:getGroupBounds().size
			local size0 = shadow:getGroupBounds().size
			shadow:removeFromParentAndCleanup(false)
			btn:addChildAt(shadow,0)
			shadow:setScaleX(size.width/size0.width*scaleEx)
			shadow:setScaleY(size.height/size0.height*scaleEx)
			shadow:setPositionXY(-size.width*0.5-8*scaleEx,size.height*0.5-10/scaleEx)
		end

		addShadow(self.nextLevelBtnShadowRes,self.nextLevelBtnRes,1.1)
		-- addShadow(self.shareToWeiBoBtnShadowRes,self.shareToWeiBoBtnRes,1.3)
	end

	self.happyAnimalBgLayer	= self.ui:getChildByName("happyAnimalBgLayer")

	-- self.yellowBg		= self.ui:getChildByName("yellowBg")
	self.bg			= self.ui:getChildByName("bg")
	self.closeBtnRes	= self.ui:getChildByName("closeBtn")

	self.panelTitlePlaceholder	= self.ui:getChildByName("panelTitlePlaceholder")

	assert(self.scoreLabel)
	assert(self.rewardTxt)
	assert(self.star1Res)
	assert(self.star2Res)
	assert(self.star3Res)

	assert(self.star1Bg)
	assert(self.star2Bg)
	assert(self.star3Bg)

	assert(self.rewardItem1Res)
	assert(self.rewardItem2Res)
	assert(self.rewardItem3Res)
	assert(self.rewardItem4Res)

	assert(self.nextLevelBtnRes)

	-- assert(self.shareToWeiBoBtnRes)

	assert(self.happyAnimalBgLayer)

	-- assert(self.yellowBg)
	-- assert(self.bg)
	assert(self.closeBtnRes)

	assert(self.panelTitlePlaceholder)

	---------------
	-- Init UI
	-- -------------
	self.star1Res:setAnchorPointCenterWhileStayOrigianlPosition()
	self.star2Res:setAnchorPointCenterWhileStayOrigianlPosition()
	self.star3Res:setAnchorPointCenterWhileStayOrigianlPosition()
	self.star4Res:setAnchorPointCenterWhileStayOrigianlPosition()

	for index = 1, #self.starRes do
		self.starRes[index]:setVisible(false)
	end

	self.panelTitlePlaceholder:setVisible(false)
	self.panelTitlePlaceholderPosY = self.panelTitlePlaceholder:getPositionY()


	-------------------------
	---- Get Data About UI
	-------------------------
	self.starResInitWorldPos = {
	}

	self.starResInitScale = {
		{scaleX = self.star1Res:getScaleX(), scaleY = self.star1Res:getScaleY()},
		{scaleX = self.star2Res:getScaleX(), scaleY = self.star2Res:getScaleY()},
		{scaleX = self.star3Res:getScaleX(), scaleY = self.star3Res:getScaleY()},
		{scaleX = self.star4Res:getScaleX(), scaleY = self.star4Res:getScaleY()}
	}

	self.starResInitPos = {
			ccp(self.star1Res:getPositionX(), self.star1Res:getPositionY()),
			ccp(self.star2Res:getPositionX(), self.star2Res:getPositionY()),
			ccp(self.star3Res:getPositionX(), self.star3Res:getPositionY()),
			ccp(self.star4Res:getPositionX(), self.star4Res:getPositionY())
		}

	self.starResInitZOrder = {
		self.star1Res:getZOrder(),
		self.star2Res:getZOrder(),
		self.star3Res:getZOrder(),
		self.star4Res:getZOrder()
	}

	-------------------------
	---- Create UI Component
	-----------------------
	-- printx( 1 , "    LevelSuccessTopPanel:init   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@222222    panelType = " , panelType)

	self.rewardItem1	= RewardItem:create(self.rewardItem1Res, false, panelType) 
	self.rewardItem2	= RewardItem:create(self.rewardItem2Res, false, panelType)
	self.rewardItem3	= RewardItem:create(self.rewardItem3Res, false, panelType)
	self.rewardItem4	= RewardItem:create(self.rewardItem4Res, false, panelType)
	
	self.rewardItems 	= {self.rewardItem1, self.rewardItem2, self.rewardItem3 , self.rewardItem4 }	

	if self.uncommonSkin then
		self.closeBtn = {}
		self.closeBtn.ui = self.closeBtnRes
		self.closeBtn.ui:setButtonMode(true)
		self.closeBtn.ui:setTouchEnabled(true)
	else
		self.closeBtn = BubbleCloseBtn:create(self.closeBtnRes)
	end
	self.nextLevelBtn	= GroupButtonBase:create(self.nextLevelBtnRes)
	self.nextLevelBtn.blueBg		= self.nextLevelBtn.background
	self.nextLevelBtn:setEnabled( true )
	self.nextLevelBtn:useBubbleAnimation()
	-- self.shareToWeiBoBtn	= ButtonWithShadow:create(self.shareToWeiBoBtnRes)

	-- self.shareToWeiBoBtn	= ButtonIconsetBase:create(self.shareToWeiBoBtnRes)
	-- self:showShareIcon()
	self.levelId		= levelId
	self.levelType 		= levelType
	self.parentPanel 	= parentPanel
	self.newScore		= newScore
	self.extraCoin		= extraCoin

	-- Create Panel Tilte
	local panelTitle = nil

	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		local  levelDisplayName = "第"..self.levelId.."关"
		panelTitle = BitmapText:create(levelDisplayName, "fnt/helllevel.fnt", -1, kCCTextAlignmentCenter)
		panelTitle:setScale(0.8)
	else
		panelTitle = self:createPanelTitle(levelId, self.levelType)
	end	
	self.ui:addChild(panelTitle)
	panelTitle:ignoreAnchorPointForPosition(false)
	panelTitle:setAnchorPoint(ccp(0,1))
	panelTitle:setPositionY(self.panelTitlePlaceholderPosY)
	panelTitle:setToParentCenterHorizontal()

	---------------------
	----  Data
	--------------------
	self.metaModel			= MetaModel:sharedInstance()
	self.metaManager		= MetaManager.getInstance()

	self.rewardItemsDataFromServer	= rewardItemsDataFromServer
	if CollectStarsManager.getInstance():getAutoAddBuffNum() > 0 then
		table.insert( self.rewardItemsDataFromServer ,{itemId = ItemType.COLLECT_STAR_2019 , num = CollectStarsManager.getInstance():getAutoAddBuffNum()} )
	end
	self.newStarLevel 	= self:getStarLevelByScore(self.newScore)

	if self.newStarLevel == 4 then
		for k, v in pairs(self.starBgs) do
			local offset = (tonumber(k) - 2.5) * 10
			v:setRotation(offset)
			v:setVisible(true)
			v:setAnchorPoint(ccp(0.5, 0.5))
			local pos = self.ui:getChildByName('fourStarLocator'..k):getPosition()
			v:setPosition(ccp(pos.x, pos.y))
			v:setScale(0.9)
		end
	end

	if panelType == LevelSuccessPanelTpye.kOlympic then
		self.rewardItem4Res	= self.ui:getChildByName("rewardItem4")
		self.rewardLabel4	= self.ui:getChildByName("rewardLabel4")
		if panelTypeData then
			self.rewardLabel4:setString( tostring( panelTypeData.distance ) )
		end
		panelTitle:setVisible(false)
	end
	----------------------
	-- Flag To Indicate Btn Tapped State
	-- ----------------------------------
	self.BTN_TAPPED_STATE_CLOSE_BTN_TAPPED	= 1
	self.BTN_TAPPED_STATE_NEXT_BTN_TAPPED	= 2
	self.BTN_TAPPED_STATE_NONE		= 3
	self.btnTappedState			= self.BTN_TAPPED_STATE_NONE

	-- Get Cur Level Old Star And Score
	local curLevelScoreRef	= UserManager:getInstance():getUserScore(self.levelId)
	local oldLevelScoreRef	= UserManager:getInstance():getOldUserScore(self.levelId)

	he_log_warning("this logic should implemented in UserManager !")
	self.oldStarLevel	= false
	self.oldScore		= false

	if oldLevelScoreRef then
		self.oldStarLevel	= oldLevelScoreRef.star
		self.oldScore		= oldLevelScoreRef.score
	else
		self.oldStarLevel	= 0
		self.oldScore		= 0
	end

	if self.isActLevel then
		self.oldStarLevel = SpringFestival2019Manager:getInstance().lastLevelStar or self.oldStarLevel
		SpringFestival2019Manager:getInstance().lastLevelStar = nil
	end

	if _G.isLocalDevelopMode then printx(0, "self.oldStarLevel: " .. self.oldStarLevel) end

	------------------------------------
	-- Data About Callback During Action 
	-- -------------------------------
	self.hideStarCallback = false

	-- Cur Level Reward
	self.level_reward = self.metaManager:getLevelRewardByLevelId(self.levelId)
	assert(self.level_reward)

	self.ingredientTip	= self.ui:getChildByName('ingredient_tip')
	self.ingredientTip:setVisible(self:isIngredientRefunded())

	-- Get Reward Txt
	local rewardTxtKey	= "level.success.reward.txt"
	local rewardTxtValue	= Localization:getInstance():getText(rewardTxtKey, {})

	--新版素材已经不需要这显示文字了, 但某个引导需要它去定位
	rewardTxtValue = ' '

	self.rewardTxt:setString(rewardTxtValue)

	-- Get Score Txt
	-- And Set Score
	local scoreTxtKey	= "level.success.score.txt"
	local scoreTxtValue	= Localization:getInstance():getText(scoreTxtKey)
	self.scoreLabel:setString(scoreTxtValue .. tostring(self.newScore))

	-- Get Next Level Button Label Txt

	local topLevelId = UserManager:getInstance().user:getTopLevelId()
    -- self.justPassedTopLevel = topLevelId>UserManager:getInstance().lastPassedLevel
    self.justPassedTopLevel = UserManager:getInstance().justPassedTopLevel
    --print("self.justPassedTopLevel",self.justPassedTopLevel,self.levelId , topLevelId,UserManager:getInstance().lastPassedLevel)

	if PublishActUtil:isGroundPublish() then
		self.nextLevelBtn:setString(Localization:getInstance():getText("prop.info.panel.close.txt", {}))
		self.nextLevelBtn:setPositionX(self.nextLevelBtn:getPositionX() + 100)
		-- self.shareToWeiBoBtn:setEnabled(false)
		-- self.shareToWeiBoBtn:setVisible(false)
	else
		if self.levelType == GameLevelType.kMainLevel then
			local nextLevelBtnTxtkey	= "level.success.next.level.button.label.txt"
			if not self.justPassedTopLevel then
				--再试一次
				nextLevelBtnTxtkey = "level.fail.replay.button.label.txt"
			end
			local nextLevelBtnTxt	= Localization:getInstance():getText(nextLevelBtnTxtkey)
			self.nextLevelBtn:setString(nextLevelBtnTxt)

		else
			if SpringFestival2019Manager:getInstance():getCurIsAct() and self.levelId-PigYearStartGame.ACT_LEVEL_START == PigYearLogic.pigYearLevelIndex then
				local nextLevelBtnTxtkey	= "level.success.next.level.button.label.txt"
				local nextLevelBtnTxt	= Localization:getInstance():getText(nextLevelBtnTxtkey)
				self.nextLevelBtn:setString(nextLevelBtnTxt)
				self.nextLevelBtn.needAutoPopoutNext = true
			else

				local replayBtnTxtKey	= "button.ok"
				local replayBtnTxt	= Localization:getInstance():getText(replayBtnTxtKey, {})
				self.nextLevelBtn:setString(replayBtnTxt)
			end
		end
	end

	local cnlbLogic = NextLevelButtonProxy:getInstance():getProxy()

	if cnlbLogic then
		self.nextLevelBtn:setString(cnlbLogic:getButtonString())
	end


	-- local shareToWeiBoBtnTxtKey	= "level.success.share.to.weibo.btn.label"
	-- local shareToWeiBoBtnTxtValue	= Localization:getInstance():getText(shareToWeiBoBtnTxtKey, {})
	-- self.shareToWeiBoBtn:setString(shareToWeiBoBtnTxtValue)

	local manualAdjustLabelX	= -3
	local manualAdjustLabelY	= -10

	local curLevelScoreTarget = self.metaModel:getLevelTargetScores(self.levelId)
	local star1Score	= curLevelScoreTarget[1]
	local star2Score	= curLevelScoreTarget[2]
	local star3Score	= curLevelScoreTarget[3]

	-- ----------------------------------
	-- Set Default Reward Items Number
	-- ----------------------------------
	--不算上关卡难度标记时的奖励数值
	self.rewardsFromServer	= {}

	-- 算上关卡难度标记加成后的实际数据
	self.rewardsFromServer_LevelDiffcultFlag= {}

	--标记位 
	self.hasLevelDiffcultFlag = false

	for k,v in pairs( self.rewardItemsDataFromServer ) do
		local num = self.rewardsFromServer_LevelDiffcultFlag[v.itemId] or 0
		self.rewardsFromServer_LevelDiffcultFlag[v.itemId] = num + v.num

		if v.awardType ~= REWARDITEM_AWARDTYPE.LEVELDIFFCULTFLAG then
			local num2 = self.rewardsFromServer[v.itemId] or 0
			self.rewardsFromServer[v.itemId] = num2 + v.num
		elseif v.awardType == REWARDITEM_AWARDTYPE.LEVELDIFFCULTFLAG then
			if v.num > 0 then
				self.hasLevelDiffcultFlag = true
			end
		end

	end

	--加载骨骼动画
	if self.hasLevelDiffcultFlag then
		FrameLoader:loadArmature('skeleton/LevelDiffcultFlag/numEft', 'numEft', 'numEft')
		FrameLoader:loadArmature('skeleton/LevelDiffcultFlag/level_tips', 'level_tips', 'level_tips')
	end

	if not _isQixiLevel then -- qixi
		local allRewardIds = self:getAllRewardIds(self.levelId, self.levelType)
		
		local sorrRewardIds = {}
		for k, v in pairs( allRewardIds ) do
			table.insert( sorrRewardIds , v)
		end

		local smallestLevel = math.min(self.oldStarLevel, self.newStarLevel)
		local defaultRewards = self:getDefaultRewards(self.level_reward, smallestLevel)
		
		if CollectStarsManager.getInstance():getAutoAddBuffNum() > 0 then
			-- 倒数第一个是豆荚 倒数第二个是刷星瓶子
			local has_COLLECT_STAR_2019 = false
			for index=1,#sorrRewardIds do
				if ItemType.COLLECT_STAR_2019 == sorrRewardIds[index] then
					has_COLLECT_STAR_2019 = true
					table.remove( sorrRewardIds , index )
				end
			end
			local has_INGREDIENT = false
			for index=1,#sorrRewardIds do
				if ItemType.INGREDIENT == sorrRewardIds[index] then
					has_INGREDIENT = true
					table.remove( sorrRewardIds , index )
				end
			end
			if has_COLLECT_STAR_2019 then
				table.insert( sorrRewardIds , ItemType.COLLECT_STAR_2019)
			end
			if has_INGREDIENT then
				table.insert( sorrRewardIds , ItemType.INGREDIENT)
			end
			-- 倒数第一个是豆荚 倒数第二个是刷星瓶子
		end

		local index = 1
		local itemNum = 0
		for index=1,#sorrRewardIds do
			local v = sorrRewardIds[ index ]
			self.rewardItems[index]:setRewardId(tonumber(v))
			index = index + 1
			itemNum = itemNum + 1
		end
		self:updateRewardItemPos( itemNum )
		index = 1 
		-- update default rewards
		for itemId,num in pairs(defaultRewards) do
			local rewardItemComponent = self:getRewardItemComponentFromItemId(itemId)
			assert(rewardItemComponent)
			rewardItemComponent:addNumber( num  )
		end

		if CollectStarsManager.getInstance():getAutoAddBuffNum() > 0 then
			local rewardItemComponent = self:getRewardItemComponentFromItemId( ItemType.COLLECT_STAR_2019 )
			assert(rewardItemComponent)
			rewardItemComponent:addNumber( 0  )
		end

	end

	if LevelType:isMainLevel( self.levelId ) or LevelType:isHideLevel( self.levelId ) then
		Notify:dispatch("StarBankEventAddStar", self.oldStarLevel, self.newStarLevel)
	end
	AreaTaskMgr:getInstance():onLevelSuccess(self.levelId)
	 
	---------------------------
	--- Add Event Listener
	------------------------
	-- Next Level Button Event Listener
	-- only main level has play next level button
	local function onNextLevelBtnTapped(event)

		if self.nextLevelBtn and self.nextLevelBtn.needAutoPopoutNext then
			self.nextLevelBtn.needAutoPopoutNext = false
            PigYearStartGame:onNextLevelBtnTapped(self.levelId)
		end

		if StarBank and StarBank.needPopPanel then
			return
		end
		
		if PublishActUtil:isGroundPublish() then
			self:onCloseBtnTapped(event)
		elseif self.levelType == GameLevelType.kMainLevel then
			-- if self.levelId == 1 then 
			-- 	self:onCloseBtnTapped(event)
			-- else
			-- 	self:onNextLevelBtnTapped(event)
			-- end


			if cnlbLogic then
				cnlbLogic:onTap(self)
				return
			end
		

			if self.justPassedTopLevel then
				self:onNextLevelBtnTapped(event)
			else
				self.parentPanel:changeToStartGamePanel()
			end
		else
			self:onCloseBtnTapped(event)
		end
	end
	self.nextLevelBtn:addEventListener(DisplayEvents.kTouchTap, onNextLevelBtnTapped)

	-- Close Button Event Listener
	local function onCloseBtnTapped(event)
		if StarBank and StarBank.needPopPanel then
			return
		end
		self:onCloseBtnTapped(event)
	end
	self.closeBtn.ui:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	-- For Restore Anim
	self.overlayAnims = {}

	-- four star logic
	self.ui:getChildByName('flowers_deco'):setVisible(false)
	for i=1, 4 do
		self.ui:getChildByName('fourStarLocator'..i):setVisible(false)
	end
	if activityForceShareData and activityForceShareData.activityId then

		local function onActivityShareToWeiBoBtnTapped()
			if PrepackageUtil:isPreNoNetWork() then
				PrepackageUtil:showInGameDialog()
			else
				self:onActivityShareToWeiBoBtnTapped(activityForceShareData)
			end
		end
		if activityForceShareData.reward then
			self.nextLevelBtn:setEnabled(false)
			self.nextLevelBtn:setVisible(false)
			-- self.shareToWeiBoBtn:setPositionX(self.shareToWeiBoBtn:getPositionX() - 150)

			-- local itemIcon = ResourceManager:sharedInstance():buildItemSprite(activityForceShareData.reward.itemId)
			-- -- local facebookIcon = self.shareToWeiBoBtn.ui:getChildByName("facebookIcon")
			-- -- local pos = facebookIcon:getPosition()
			-- -- local size_const = 80
			-- -- local size = facebookIcon:getGroupBounds().size
			-- -- local itemIconSize = itemIcon:getGroupBounds().size
			-- -- itemIcon:setPosition(ccp(pos.x - (size_const - size.width)/2, pos.y + (size_const - size.height)/2))
			-- -- itemIcon:setScaleX(size_const/itemIconSize.width)
			-- -- itemIcon:setScaleY(size_const/itemIconSize.height)
			-- self.shareToWeiBoBtn:setIcon(itemIcon)
			-- self.shareRewardIcon = itemIcon

			self:showShareIcon(true)
		end
		-- self.shareToWeiBoBtn:addEventListener(DisplayEvents.kTouchTap, onActivityShareToWeiBoBtnTapped)
		
		
	elseif LevelType.isShareEnable(self.levelType) and not PlatformConfig:isPlayDemo() then
		local function onShareToWeiBoBtnTapped()
			if PrepackageUtil:isPreNoNetWork() then
				PrepackageUtil:showInGameDialog()
			else
				self:onShareToWeiBoBtnTapped()
			end
		end
		-- self.shareToWeiBoBtn:addEventListener(DisplayEvents.kTouchTap, onShareToWeiBoBtnTapped)
	else
		-- self.shareToWeiBoBtn:setEnabled(false)
		-- self.shareToWeiBoBtn:setVisible(false)
		-- self.nextLevelBtn:setPositionX(self.nextLevelBtn:getPositionX() + 100)
	end

	self:fourStarGuide()

	self:levelDiffcultFlagVisable()

	--四星展示
	-- self.oldStarLevel, self.newStarLevel
	local isStar4Level = MetaModel:sharedInstance():isStar4Level( self.levelId   )
	self.showStar4Tpye = LevelSuccessStar4Tpye.kNormal
	if isStar4Level then
		if self.oldStarLevel < 3 and self.newStarLevel==3 then
			self.showStar4Tpye = LevelSuccessStar4Tpye.kFirstStar3
		elseif self.oldStarLevel >= 3  then
			self.showStar4Tpye = LevelSuccessStar4Tpye.kShowStar4

		end
	end
	if LevelSuccessStar4Tpye.kFirstStar3 == self.showStar4Tpye then
		FrameLoader:loadArmature('skeleton/LadybugFourStarAnimation', 'dgdfh', 'dgdfh')
	end
	if self.showStar4Tpye == LevelSuccessStar4Tpye.kShowStar4 then
		for k, v in pairs(self.starBgs) do
			local offset = (tonumber(k) - 2.5) * 10
			v:setRotation(offset)
			v:setVisible(true)
			v:setAnchorPoint(ccp(0.5, 0.5))
			local pos = self.ui:getChildByName('fourStarLocator'..k):getPosition()
			v:setPosition(ccp(pos.x, pos.y))
			v:setScale(0.9)
		end
	end
	
	
	if PreBuffLogic:checkEnableBuffForLevelSuccess( self.levelId ) then
		local halfBtnWidth = 120
		local halfBtnHeight = 55
		local pos = self.nextLevelBtn:getPosition()
		pos = self.nextLevelBtn:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
		pos = self.ui:convertToNodeSpace(pos)

		local buffLevel = PreBuffLogic:getBuffGradeAndConfig()
		if PreBuffLogic:getBuffUpgradeOnLastPlay() and buffLevel > 0 then
			PreBuffLogic:loadLevelInfoSkeletonAssert()
			local animNode = ArmatureNode:create("PreBuffLogic_up/upeff")
			self.ui:addChild( animNode )
			animNode:setPosition(ccp(pos.x + halfBtnWidth - 30, pos.y + halfBtnHeight + 30))
			self.animNode_LevelInfo = animNode

			animNode:playByIndex(0)
		    animNode:update(0.001)
		    animNode:stop()
		
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
		elseif buffLevel and buffLevel > 0  then
			PreBuffLogic:loadLevelInfoSkeletonAssert()
			local png2 = Sprite:createWithSpriteFrameName( "PreBuff002Png/png"..buffLevel.."0000" )
			self.ui:addChild( png2 )
			png2:setPosition(ccp(pos.x + halfBtnWidth, pos.y + halfBtnHeight))
		end
	end


	self.userReviewBtn = self.ui:getChildByName('userReviewBtn')
	UIUtils:setTouchHandler(self.userReviewBtn, function ( ... )
		if self.isDisposed then return end
		self:onTapUserReviewBtn()
	end)
	self.userReviewBtn:setVisible(UserReviewLogic:isEnabled())

	self.successShareBtn = self.ui:getChildByName('shareLevelSuccessBtn')
	local successShareBtnUtil = require "zoo.panel.share.sharePanelVerB.shareLevelSuccess.ShareLevelSuccessButtonUtil"
	if successShareBtnUtil:canShow() then
		successShareBtnUtil:init(self.successShareBtn, levelId, self.newStarLevel, newScore)
	else
		self.successShareBtn:setVisible(false)
	end

	self:processTailAnimationQueue()
end

function LevelSuccessTopPanel:onTapUserReviewBtn( ... )
	if self.isDisposed then return end

	self:onCloseBtnTapped()


	local dcLevelType = 1

	if self.levelType == GameLevelType.kHiddenLevel then
		dcLevelType = 4
	elseif self.levelType == GameLevelType.kMainLevel then
		if self.skinLevelFlag == LevelDiffcultFlag.kDiffcult then
			dcLevelType = 2
		elseif self.skinLevelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
			dcLevelType = 3
		end
	end

	DcUtil:UserTrack({category='video', sub_category='video_replay_button', 
		t1 = self.levelId, 
		t2 = self.newStarLevel,
		t3 = dcLevelType,
	}, false)

	UserReviewLogic:cacheDCInfo(self.levelId, self.newStarLevel, dcLevelType)

	UserReviewLogic:test()

end

function LevelSuccessTopPanel:getUserReviewBtnPos( ... )
	if self.isDisposed then return end
	local pos = ccp(0, 0)
	local bounds = self.userReviewBtn:getGroupBounds()
	pos = ccp(bounds:getMidX(), bounds:getMidY())
	return pos, CCSizeMake(bounds.size.width, bounds.size.height)
end

function LevelSuccessTopPanel:processTailAnimationQueue( ... )

	self.tailAnimQueue = {}
	self.tailAnimQueue.push = function ( _, elem )
		table.insert(self.tailAnimQueue, elem)
	end


	self.tailAnimQueue:push{function ( ... )
		return (not UserManager:getInstance():hasGuideFlag(kGuideFlags.kUserReview_1)) and UserReviewLogic:isEnabled() and PopoutManager:sharedInstance():findPopoutPanel('ShareLevelSuccessPanel') == nil
	end, function ( done )
		if self.isDisposed then return end
		local UserReviewGuide = require 'zoo.gamePlay.review.UserReviewGuide'
		local pos, size = self:getUserReviewBtnPos()
		UserReviewGuide:tryShowGuide_1(pos, size, function ( ... )
			if self.isDisposed then return end
			self:onTapUserReviewBtn()
		end, done)
	end}


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

	for _, elem in ipairs(self.tailAnimQueue) do
		local checker = elem[1]
		if checker() then
			ShareManager:disableShareUi()
			break
		end
	end
end

function LevelSuccessTopPanel:hanleForSkin()
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

function LevelSuccessTopPanel:playPreBuffUpgradeAction()
	if self.isDisposed then return end
	if self.animNode_LevelInfo then
		self.animNode_LevelInfo:playByIndex(0, 1)
	end

end


function LevelSuccessTopPanel:getAllRewardIds( levelId, levelType )
	local allRewardIds = {}
	for k, v in pairs(self.level_reward.oneStarReward) do
		if not allRewardIds[v.itemId] then
			allRewardIds[v.itemId] = v.itemId
		end
	end
	for k, v in pairs(self.level_reward.twoStarReward) do
		if not allRewardIds[v.itemId] then
			allRewardIds[v.itemId] = v.itemId
		end
	end
	for k, v in pairs(self.level_reward.threeStarReward) do
		if not allRewardIds[v.itemId] then
			allRewardIds[v.itemId] = v.itemId
		end
	end
	for k, v in pairs(self.level_reward.fourStarReward) do
		if not allRewardIds[v.itemId] then
			allRewardIds[v.itemId] = v.itemId
		end
	end

	-- 活动道具
	if self.levelType == GameLevelType.kDigWeekly then
		allRewardIds[ItemType.GEM] = ItemType.GEM
	elseif self.levelType == GameLevelType.kMayDay then
		-- allRewardIds[ItemType.XMAS_BOSS] = ItemType.XMAS_BOSS
		allRewardIds[ItemType.XMAS_BELL] = ItemType.XMAS_BELL
	elseif self.levelType == GameLevelType.kWukong then
		allRewardIds[ItemType.WUKONG] = ItemType.WUKONG
	elseif self.levelType == GameLevelType.kRabbitWeekly then
		allRewardIds[ItemType.WEEKLY_RABBIT] = ItemType.WEEKLY_RABBIT
	elseif self.levelType == GameLevelType.kTaskForUnlockArea then 
		allRewardIds[ItemType.KEY_GOLD] = ItemType.KEY_GOLD
	elseif self:isHasIngredientReward() then
		allRewardIds[ItemType.INGREDIENT] = ItemType.INGREDIENT
	end
	
	if CollectStarsManager.getInstance():getAutoAddBuffNum() > 0 then
		allRewardIds[ItemType.COLLECT_STAR_2019] = ItemType.COLLECT_STAR_2019
	else
		allRewardIds[ItemType.COLLECT_STAR_2019] = nil
	end

	return allRewardIds
end

function LevelSuccessTopPanel:isHasIngredientReward( ... )
	-- body
	for k, v in pairs(self.rewardItemsDataFromServer) do
		if v.itemId == ItemType.INGREDIENT then
			return true
		end
	end
	return false
end

function LevelSuccessTopPanel:onNextLevelBtnTapped( event, ... )

	--2018/04/17  文档 马俊松添加 点击下一关 不被强弹打算 使玩家闯关过程更流畅，不被其他功能面板打断，减少流失提高留存。
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	local topPassedLevelId = UserManager:getInstance():getTopPassedLevel()
	-- if self.levelType == GameLevelType.kMainLevel then

	-- end

	local nextLevelModel = false
	if ((topLevelId == topPassedLevelId + 1 or topLevelId == topPassedLevelId )and self.levelId == topPassedLevelId ) 
		and self.levelType == GameLevelType.kMainLevel 
		and false == UserManager:getInstance():hasPassedLevelEx( topPassedLevelId +1 ) 
		and true == UserManager:getInstance():hasPassedLevelEx( topPassedLevelId ) 
	then
		nextLevelModel = true
	end

	if nextLevelModel then
		Notify:dispatch("EnterNextLevelModeEvent")
	end

	if  self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
		self.btnTappedState = self.BTN_TAPPED_STATE_NEXT_BTN_TAPPED
	else
		return
	end
	self:callLevelPassedCallback(true)
end

function LevelSuccessTopPanel:getDefaultRewards( levelReward, smallestLevel )
	assert(levelReward)

	local result = {}
	-- 过关默认奖励
	for starLevel = 1, smallestLevel do
		local defaultRewards = false
		if starLevel == 1 then
			defaultRewards = levelReward.oneStarDefaultReward
		elseif starLevel == 2 then
			defaultRewards = levelReward.twoStarDefaultReward
		elseif starLevel == 3 then
			defaultRewards = levelReward.threeStarDefaultReward
		elseif starLevel == 4 then
			defaultRewards = levelReward.fourStarDefaultReward
		end
		assert(defaultRewards)

		for k,rewardItemRef in ipairs(defaultRewards) do
			local num = result[rewardItemRef.itemId] or 0
			result[rewardItemRef.itemId] = num + rewardItemRef.num
		end
	end

	-- 活动道具
	local function getRewardItemNumber(itemId)
		for k, v in ipairs(self.rewardItemsDataFromServer) do
			if v.itemId == itemId then return v.num end
		end
		return 0
	end
	if self.levelType == GameLevelType.kDigWeekly then
		result[ItemType.GEM] = getRewardItemNumber(ItemType.GEM)
	elseif self.levelType == GameLevelType.kMayDay then
		-- result[ItemType.XMAS_BOSS] = getRewardItemNumber(ItemType.XMAS_BOSS)
		result[ItemType.XMAS_BELL] = getRewardItemNumber(ItemType.XMAS_BELL)
	elseif self.levelType == GameLevelType.kWukong then
		result[ItemType.WUKONG] = getRewardItemNumber(ItemType.WUKONG)
	elseif self.levelType == GameLevelType.kRabbitWeekly then
		result[ItemType.WEEKLY_RABBIT] = getRewardItemNumber(ItemType.WEEKLY_RABBIT)
	elseif self.levelType == GameLevelType.kTaskForUnlockArea then 
		result[ItemType.KEY_GOLD] = 1
	end

	-- Extra Coin
	local coinNum = result[ItemType.COIN] or 0
	local extraCoinRatio = MetaManager.getInstance().global.coin 

    if self.levelType == GameLevelType.kMainLevel or self.levelType == GameLevelType.kHiddenLevel then
        --成就银币加成
        local addPercent = MetaManager.getInstance():getAchiCoinExtraNum()
        if addPercent > 0 then
            coinNum = math.ceil( coinNum * (1+addPercent) )
        end
    end

	local extraRewardConfig = MetaManager:getInstance():getLevelExtraRewards( self.levelId )
	local coinIncrease_Icon = 0
	if self.isFirst then
		coinIncrease_Icon = extraRewardConfig.coinIncrease
	end
	local addCoin_F = coinNum + self.extraCoin * extraCoinRatio
	result[ItemType.COIN] =  math.ceil( addCoin_F * (1 + coinIncrease_Icon) )


	return result
end

function LevelSuccessTopPanel:createPanelTitle( levelId, levelType)
	local fntFile, fntScale = WorldSceneShowManager.getInstance():getPanelTitleFntInfo()
	
	local levelDisplayName
	local panelTitle
	if PublishActUtil:isGroundPublish() then
		panelTitle = BitmapText:create("精彩活动关", "fnt/titles.fnt", -1, kCCTextAlignmentCenter)
	else
		-- compatible with weekly race mode
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
		elseif levelType == GameLevelType.kWukong then
			levelDisplayName = Localization:getInstance():getText( "activity.wukong.start.panel.title" )
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kRabbitWeekly then
			levelDisplayName = Localization:getInstance():getText('weekly.race.panel.rabbit.begin.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)	
		elseif levelType == GameLevelType.kTaskForRecall or levelType == GameLevelType.kTaskForUnlockArea then
			levelDisplayName = Localization:getInstance():getText('recall_text_5')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)		
		elseif levelType == GameLevelType.kOlympicEndless then
			levelDisplayName = Localization:getInstance():getText('activity.christmas.start.panel.title')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)
		elseif levelType == GameLevelType.kMidAutumn2018 then
			levelDisplayName = localize('中秋节关卡')
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len)

		elseif self.levelType == GameLevelType.kSpring2019 then 
			levelDisplayName = string.format("周年第%d关",self.levelId-LevelConstans.SPRINGFESTIVAL2019_LEVEL_ID_START+1)
			local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
			panelTitle = PanelTitleLabel:createWithString(levelDisplayName, len, fntFile)
			if fntScale then panelTitle:setScale(fntScale) end
			
		else
			if _G.isLocalDevelopMode then printx(0, "levelId", levelId) end
			levelDisplayName = LevelMapManager.getInstance():getLevelDisplayName(levelId)
			panelTitle = PanelTitleLabel:create(levelDisplayName, nil, nil, nil, nil, nil, fntFile)
			if fntScale then panelTitle:setScale(fntScale) end
		end
	end
	return panelTitle
end

function LevelSuccessTopPanel:restoreToOriginalPos(...)
	assert(#{...} == 0)

	self:restoreStarToOriginalPos()
end

-- ------------------------------------------------------
-- The Star Which In The Score Progress Bar's Position
-- --------------------------------------------------------

function LevelSuccessTopPanel:setStarInitialPosInWorldSpace(starIndex, worldPos, ...)
	assert(type(starIndex) == "number")
	if not __PURE_LUA__ then
		assert(type(worldPos) == "userdata")
	end
	assert(#{...} == 0)

	self.starResInitWorldPos[starIndex] = ccp(worldPos.x, worldPos.y)
end

function LevelSuccessTopPanel:registerHideScoreProgressBarStarCallback(hideStarCallback, ...)
	assert(type(hideStarCallback) == "function")
	assert(#{...} == 0)

	self.hideStarCallback = hideStarCallback
end

function LevelSuccessTopPanel:getStarPosFromWorldSpace(...)
	assert(#{...} == 0)

	if #self.starResInitWorldPos > 0 then
		for index = 1,#self.starResInitWorldPos do
			local posInWorld = self.starResInitWorldPos[index]
			self.starResInitPos[index] = self.ui:convertToNodeSpace(ccp(posInWorld.x, posInWorld.y))
		end
	else
		assert(false, "should set the world pos first !")
	end
end

function LevelSuccessTopPanel:setStarInitialSize(starIndex, width, height, ...)
	assert(type(starIndex)	== "number")
	assert(type(width)	== "number")
	assert(type(height)	== "number")
	assert(#{...} == 0)

	local star = self:getStarByIndex(starIndex)

	local curSize = star:getGroupBounds().size

	local deltaScaleX = width / curSize.width
	local deltaScaleY = height / curSize.height

	self.starResInitScale[starIndex] = {scaleX = deltaScaleX, scaleY = deltaScaleY}
end

function LevelSuccessTopPanel:restoreStarToOriginalPos(...)
	assert(#{...} == 0)

	for index = 1, 3 do

		local originalPos = self.starResInitPos[index]
		local star = self.starRes[index]

		star:setPosition(ccp(originalPos.x, originalPos.y))
		star:stopAllActions()

		star:removeFromParentAndCleanup(false)
		self.ui:addChildAt(star, self.starResInitZOrder[index])
	end
end

function LevelSuccessTopPanel:restoreStarToInitialScale(...)
	assert(#{...} == 0)

	assert(#self.starResInitScale)

	for index = 1, #self.starResInitScale do

		local star = self.starRes[index]

		star:setScaleX(self.starResInitScale[index].scaleX)
		star:setScaleY(self.starResInitScale[index].scaleY)
	end
end

function LevelSuccessTopPanel:getStarByIndex(index, ...)
	assert(type(index) == "number")
	assert(#{...} == 0)

	local star = self.starRes[index]
	assert(star)
	return star
end

function LevelSuccessTopPanel:getStarBgByIndex(index, ...)
	assert(type(index) == "number")
	assert(#{...} == 0)

	local bg = self.starBgs[index]
	assert(bg)

	return bg
end

function LevelSuccessTopPanel:getStarBgCenterByIndex(index,isGetReward, ...)
	assert(type(index) == "number")
	assert(#{...} == 0)
	if not isGetReward then
		isGetReward =false
	end

	if self.showStar4Tpye == LevelSuccessStar4Tpye.kFirstStar3 and isGetReward then
		local bgPos = self.ui:getChildByName('fourStarLocator'..index):getPosition()
		local centerX = bgPos.x
		local centerY = bgPos.y
		return ccp(centerX, centerY)
	end

	--	self.showStar4Tpye == LevelSuccessStar4Tpye.kNormal
	if self.newStarLevel < 4  then 
		local bg = self:getStarBgByIndex(index)

		local bgSize	= bg:getGroupBounds(self).size
		local bgPos	= bg:getPosition()

		local centerX = bgPos.x + bgSize.width / 2
		local centerY = bgPos.y - bgSize.height / 2
		return ccp(centerX, centerY)
	else
		local bgPos = self.ui:getChildByName('fourStarLocator'..index):getPosition()
		local centerX = bgPos.x
		local centerY = bgPos.y
		return ccp(centerX, centerY)
	end

end

-- function LevelSuccessTopPanel:onActivityShareToWeiBoBtnTapped( activityForceShareData )
-- 	if not self.isOnShareToWeiBoBtnTappedCalled then
-- 		self.isOnShareToWeiBoBtnTappedCalled = true
-- 		local function closePanel( ... )
-- 			if self.isDisposed then return end
-- 			self:onCloseBtnTapped()
-- 		end
-- 		local shareCallback = {
-- 			onSuccess = function(result)
-- 				if self.isDisposed then return end
-- 				self.isOnShareToWeiBoBtnTappedCalled = false
-- 				if result and self.shareRewardIcon then
-- 					self:showShareIcon()
-- 					local reward = {itemId = result.itemId, num = 1}
-- 					local anim = FlyItemsAnimation:create({reward})
-- 					local bounds = self.shareRewardIcon:getGroupBounds()
-- 					anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
-- 					anim:play()

-- 					self.shareRewardIcon:removeFromParentAndCleanup(true)
-- 				end
-- 			end,
-- 			onError = function(errCode, msg)
-- 				if self.isDisposed then return end
-- 				self.isOnShareToWeiBoBtnTappedCalled = false
-- 			end,
-- 			onCancel = function()
-- 				if self.isDisposed then return end
-- 				self.isOnShareToWeiBoBtnTappedCalled = false
-- 			end
-- 		}

-- 		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
-- 			SnsUtil.sendLevelMessage( PlatformShareEnum.kMiTalk, self.levelType, self.levelId, shareCallback )
-- 		else
-- 			--back state of btn
-- 			local delay	= CCDelayTime:create(1)
-- 			local function onDelayFinished()
-- 			 	self.isOnShareToWeiBoBtnTappedCalled = false
-- 			end
-- 			local callFuncAction = CCCallFunc:create(onDelayFinished)

-- 			local seq = CCSequence:createWithTwoActions(delay, callFuncAction)
-- 			self:runAction(seq)

-- 			local evt = Event.new(kGlobalEvents.kActivityLevelShare)
-- 			evt.shareCallback = shareCallback
-- 			evt.rewards = self.rewardItemsDataFromServer
-- 			evt.activityId = activityForceShareData.activityId
-- 			evt.extraData=self.panelTypeData
-- 			GlobalEventDispatcher:getInstance():dispatchEvent(evt)
-- 		end
-- 	end
-- end

-- function LevelSuccessTopPanel:onShareToWeiBoBtnTapped(...)
-- 	assert(#{...} == 0)
	
-- 	if not self.isOnShareToWeiBoBtnTappedCalled then
-- 		self.isOnShareToWeiBoBtnTappedCalled = true

-- 		if _G.isLocalDevelopMode then printx(0, "LevelSuccessTopPanel:onShareToWeiBoBtnTapped Called !") end

-- 		if __IOS_FB then -- facebook
-- 			if not SnsProxy:isShareAvailable() then
-- 				-- SnsProxy:shareLogin()
-- 				self.isOnShareToWeiBoBtnTappedCalled = false
-- 			else
-- 				local shareTitle = Localization:getInstance():getText("share.feed.title")
				
-- 				local timer = os.time() or 0
-- 				local datetime = tostring(os.date("%y%m%d", timer))
-- 				local txtToShare = nil
-- 				local imageURL = nil
-- 				if self.levelType == GameLevelType.kMainLevel then
-- 					txtToShare = Localization:getInstance():getText("share.feed.text", {level=self.levelId})
-- 					imageURL = string.format("http://statictw.animal.he-games.com/mobanimal/fb/level/fb%04d.jpg?v="..datetime, self.levelId)
-- 				elseif self.levelType == GameLevelType.kHiddenLevel then
-- 					local hidenLevelId = self.levelId - LevelConstans.HIDE_LEVEL_ID_START
-- 					txtToShare = Localization:getInstance():getText("share.feed.text", {level="+"..hidenLevelId})
-- 					imageURL = string.format("http://statictw.animal.he-games.com/mobanimal/fb/level/yc%04d.jpg?v="..datetime, hidenLevelId)
-- 				end

-- 				-- imageURL = "http://c.hiphotos.baidu.com/image/h%3D800%3Bcrop%3D0%2C0%2C1280%2C800/sign=d32e0d42808ba61ec0eec52f710ff478/ca1349540923dd543455ace0d309b3de9c824817.jpg"
				
-- 				local callback = {
-- 					onSuccess = function(result)
-- 						if _G.isLocalDevelopMode then printx(0, "result="..table.tostring(result)) end	
-- 						self.isOnShareToWeiBoBtnTappedCalled = false
-- 						CommonTip:showTip(Localization:getInstance():getText("share.feed.success.tips"), "positive")
-- 						DcUtil:shareFeed("next_level",self.levelId,self.newScore)
-- 						DcUtil:logSendNewsFeed("feed",result.id,"feed_pass_level")
-- 					end,
-- 					onError = function(err)
-- 						if _G.isLocalDevelopMode then printx(0, "err="..err) end
-- 						self.isOnShareToWeiBoBtnTappedCalled = false
-- 						CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips"), 'negative', nil, 2)
-- 						DcUtil:shareFeed("next_level",self.levelId,self.newScore)
-- 					end
-- 				}
-- 				local image = {{url=imageURL, user_generated="true"}}
-- 				SnsProxy:sendNewFeedsWithParams(FBOGActionType.PASS, FBOGObjectType.LEVEL, shareTitle, txtToShare, image, link, callback)
-- 			end
-- 		else
-- 			local shareType, delayResume = SnsUtil.getShareType()

-- 			local shareCallback = {
-- 				onSuccess = function(result)
-- 					if _G.isLocalDevelopMode then printx(0, "result="..table.tostring(result)) end	
-- 					self.isOnShareToWeiBoBtnTappedCalled = false

-- 					if shareType == PlatformShareEnum.kWechat or 
-- 						shareType == PlatformShareEnum.kMiTalk or 
-- 						shareType == PlatformShareEnum.kJPQQ or 
-- 						shareType == PlatformShareEnum.kJPWX then
-- 						CommonTip:showTip(Localization:getInstance():getText("share.feed.success.tips"), "positive")
-- 					end
-- 				end,
-- 				onError = function(errCode, msg)
-- 					if _G.isLocalDevelopMode then printx(0, "err="..tostring(errCode)) end
-- 					self.isOnShareToWeiBoBtnTappedCalled = false

-- 					if errCode and errCode == -1 then 
-- 						if shareType == PlatformShareEnum.kJPQQ then 
-- 							CommonTip:showTip(Localization:getInstance():getText("请安装QQ后再分享~"))
-- 						elseif shareType == PlatformShareEnum.kJPWX then 
-- 							CommonTip:showTip(Localization:getInstance():getText("请安装微信后再分享~"))
-- 						end
-- 					elseif shareType == PlatformShareEnum.kWechat or 
-- 							shareType == PlatformShareEnum.kJPQQ or 
-- 							shareType == PlatformShareEnum.kJPWX then
-- 						CommonTip:showTip(Localization:getInstance():getText("share.feed.invite.code.faild.tips"))
-- 					end
-- 					if shareType == PlatformShareEnum.kJPQQ or shareType == PlatformShareEnum.kJPWX then 
-- 						self.shareToWeiBoBtn:setEnabled(true)
-- 						-- self.shareToWeiBoBtn.blueBg:clearAdjustColorShader()
-- 						self.shareToWeiBoBtn:setColorMode( kGroupButtonColorMode.green )
-- 					end
-- 				end,
-- 				onCancel = function()
-- 					self.isOnShareToWeiBoBtnTappedCalled = false
-- 					if shareType == PlatformShareEnum.kWechat or 
-- 					    shareType == PlatformShareEnum.kJPQQ or 
-- 						shareType == PlatformShareEnum.kJPWX then
-- 						CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips"))
-- 					end
-- 					if shareType == PlatformShareEnum.kJPQQ or shareType == PlatformShareEnum.kJPWX then 
-- 						self.shareToWeiBoBtn:setEnabled(true)
-- 						-- self.shareToWeiBoBtn.blueBg:clearAdjustColorShader()
-- 						self.shareToWeiBoBtn:setColorMode( kGroupButtonColorMode.green )
-- 					end
-- 				end
-- 			}
			
-- 			if shareType then 
-- 				if shareType == PlatformShareEnum.kJPQQ or shareType == PlatformShareEnum.kJPWX then 
-- 					self.shareToWeiBoBtn:setEnabled(false)
-- 					-- self.shareToWeiBoBtn.blueBg:applyAdjustColorShader()
-- 					-- self.shareToWeiBoBtn.blueBg:adjustColor(0,-1, 0, 0)
-- 					self.shareToWeiBoBtn:setColorMode( kGroupButtonColorMode.blue )

-- 				end
-- 				if delayResume then 
-- 					SnsUtil.sendLevelMessage( shareType, self.levelType, self.levelId, shareCallback, true )
-- 					local delay	= CCDelayTime:create(1)
-- 					local function onDelayFinished()
-- 					 	self.isOnShareToWeiBoBtnTappedCalled = false
-- 					end
-- 					local callFuncAction = CCCallFunc:create(onDelayFinished)

-- 					local seq = CCSequence:createWithTwoActions(delay, callFuncAction)
-- 					self:runAction(seq)
-- 				else
-- 					SnsUtil.sendLevelMessage( shareType, self.levelType, self.levelId, shareCallback, true )
-- 				end
-- 			else
-- 				shareCallback.onError(-101);
-- 			end
-- 			DcUtil:shareFeed("next_level",self.levelId,self.newScore)
-- 		end	
-- 	end
-- end

function LevelSuccessTopPanel:onCloseBtnTapped(event, ...)
	assert(#{...} == 0)

--	PopoutQueue:sharedInstance():pushGuide( PopoutLayerPriority.Guide_PersonalInfoPanel , true )
	--如果本来是连续通关模式 那么回到主界面的时候弹出面板
--	if _G.nextLevelModel == true then
		
--	end

	Notify:dispatch("QuitNextLevelModeEvent", true)

	if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
		self.btnTappedState = self.BTN_TAPPED_STATE_CLOSE_BTN_TAPPED
	else
		return
	end
	
	self:callLevelPassedCallback(false)
end

function LevelSuccessTopPanel:callLevelPassedCallback(isStartPanelAutoPopout, ...)
	assert(#{...} == 0)
	_G.isStartPanelAutoPopoutForWorldScene = isStartPanelAutoPopout
	--------------------
	-- Get Reward Pos
	-- ----------------
	--for k,v in pairs(self.newStarLevelReward) do
	--for itemId,num in pairs(self.rewardItemsDataFromServer) do
--	for itemId,num in pairs(self.rewardsFromServer) do
	for itemId,num in pairs(self.rewardsFromServer_LevelDiffcultFlag) do
		-- Reward Item
		local rewardItemRes = self:getRewardItemByRewardId(itemId)
		assert(rewardItemRes)
		local rewardItemPos		= rewardItemRes:getPosition()
		local rewardItemParent 		= rewardItemRes:getParent()
		local rewardItemPosInWorldspace	= rewardItemParent:convertToWorldSpace(ccp(rewardItemPos.x, rewardItemPos.y))
		self.rewardsFromServer_LevelDiffcultFlag[itemId] = { itemId = itemId, num = num, posInWorld = ccp(rewardItemPosInWorldspace.x, rewardItemPosInWorldspace.y)}
	end

	PopoutManager:sharedInstance():remove(self.parentPanel, true)

	if self.levelType == GameLevelType.kMainLevel 
			or self.levelType == GameLevelType.kHiddenLevel then	
		-- local _type = self.four_star_guide_type
		-- local _level = self.four_star_guide_recommend_level
		-- local showLadybugFlyLevel = nil
		-- if _type and not _level then
		-- 	showLadybugFlyLevel = self.levelId
		-- elseif _type and _level then
		-- 	showLadybugFlyLevel = _level
		-- end
		-- HomeScene:sharedInstance():setEnterFromGamePlay(self.levelId, showLadybugFlyLevel)
		HomeScene:sharedInstance():setEnterFromGamePlay(self.levelId)
	end
	
	self._willDisposed = true
	Director:sharedDirector():popScene()

	-- Return Successed Level Id, And Play Next Level = True
	--self.levelPassedCallback(self.levelId, self.newStarLevelReward, true)

	if self.levelType == GameLevelType.kMayDay or self.levelType == GameLevelType.kWukong 
		or self.levelType == GameLevelType.kOlympicEndless or self.levelType == GameLevelType.kMidAutumn2018 then
		GamePlayEvents.dispatchPassLevelEvent({levelType=self.levelType, levelId=self.levelId, rewardsIdAndPos=self.rewardItemsDataFromServer, isPlayNextLevel=false, extraData=self.panelTypeData})
    elseif self.levelType == GameLevelType.kSpring2019 then
        Notify:dispatch("FifthAnniversaryPassLevel_gamescene_Popout")
	else

		for i=1, #ModuleNoticeConfig do
			if ModuleNoticeConfig[i].unLockLevel == self.levelId + 1 and ModuleNoticeConfig[i].id ~= ModuleNoticeID.JUMP_LEVEL then
				ModuleNoticeButton:setPlayNext(true)
				-- isStartPanelAutoPopout = false
				break
			end
		end
		_G.forUnlockAreaFromPassLevel = true
		GamePlayEvents.dispatchPassLevelEvent({levelType=self.levelType, levelId=self.levelId, rewardsIdAndPos=self.rewardsFromServer_LevelDiffcultFlag, isPlayNextLevel=isStartPanelAutoPopout})
	end
end

function LevelSuccessTopPanel:getRewardItemComponentFromItemId(itemId, ...)
	assert(itemId)
	assert(type(itemId) == "number")
	assert(#{...} == 0)
	for index = 1,#self.rewardItems do
		local rewardId = self.rewardItems[index]:getRewardId()
		if rewardId == itemId then
			return self.rewardItems[index]
		end
	end
	return nil
end

function LevelSuccessTopPanel:getStarLevelByScore(score, ...)
	assert(score)
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "!!!!!!!!!!!!!!! LevelSuccessTopPanel:getStarLevelByScore !!!!!!!!!!!!!!!!!!!") end

	-- Get Cur Level Target Scores
	local curLevelScoreTarget = self.metaModel:getLevelTargetScores(self.levelId)

	local star1Score	= curLevelScoreTarget[1]
	local star2Score	= curLevelScoreTarget[2]
	local star3Score	= curLevelScoreTarget[3]
	local star4Score 	= curLevelScoreTarget[4]

	local starLevel = false
	if score < star1Score then
		starLevel = 0
	elseif score >= star1Score and score < star2Score then
		starLevel = 1
	elseif score >= star2Score and score < star3Score then
		starLevel = 2
	elseif score >= star3Score then
		starLevel = 3
		if star4Score ~= nil and score >= star4Score then
			starLevel = 4
		end
	else	
		assert(false)
	end

	if _G.isLocalDevelopMode then printx(0, "score: " .. score) end
	if _G.isLocalDevelopMode then printx(0, "star1Score: " .. star1Score) end
	if _G.isLocalDevelopMode then printx(0, "star2Score: " .. star2Score) end
	if _G.isLocalDevelopMode then printx(0, "star3Score: " .. star3Score) end
	if _G.isLocalDevelopMode then printx(0, "starLevel: " .. starLevel) end
	if _G.isLocalDevelopMode then printx(0, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!") end

	return starLevel
end

---------------------------------------------------
-------	Start Animation
----------------------------------------------

function LevelSuccessTopPanel:playAnimation(...)
	assert(#{...} == 0)

	self:getStarPosFromWorldSpace()

	-- Restore happyAnimalsAnim
	if self.happyAnimalsAnim then
		self.happyAnimalsAnim:removeFromParentAndCleanup(true)
		self.happyAnimalsAnim = false
	end
	-- Restore Pop Txt Anim
	if self.passLevelTxtRes then
		self.passLevelTxtRes:removeFromParentAndCleanup(true)
		self.passLevelTxtRes = false
	end
	-- Restore Star Anim
	self:restoreStarToOriginalPos()
	self:restoreStarToInitialScale()

	if self.overlayAnims then
		for k,v in pairs(self.overlayAnims) do
			v:removeFromParentAndCleanup(true)
		end
	end

	local actionArray = CCArray:create()

	-- --------------------
	-- Happy Animals Anim
	-- -------------------
	local happyAnimalsAnim = self:createHappyAnimalsAction()

	if LevelSuccessStar4Tpye.kFirstStar3 ~= self.showStar4Tpye then
		actionArray:addObject(happyAnimalsAnim)
	end
	

	-- -----------------
	-- Pop Out Txt Anim
	-- ------------------
	local passLevelTxtAnim = self:createPopoutPassLevelTxtAnim()
	if LevelSuccessStar4Tpye.kFirstStar3 ~= self.showStar4Tpye then
		actionArray:addObject(passLevelTxtAnim)
	end
	

	-- ---------------------------
	-- Create Parabola Stars Anim
	-- ---------------------------

	--四星展示效果 

	if self.newStarLevel == 4 or LevelSuccessStar4Tpye.kShowStar4 == self.showStar4Tpye  then -- four star animation goes Here!
		local parabolaStarActionArray = CCArray:create()
		local delayTimeBetweenStars = 0.2
		for index = 1,self.newStarLevel do

			local delay = CCDelayTime:create((index-1) * delayTimeBetweenStars)

			local parabolaStarAction = self:createFourStarParabolaStarAction(index, false)
			local seq = CCSequence:createWithTwoActions(delay, parabolaStarAction)
			parabolaStarActionArray:addObject(seq)
		end
		-- Spawn Parabola Star Action
		local spawn = CCSpawn:create(parabolaStarActionArray)
		actionArray:addObject(spawn)
	elseif self.newStarLevel > 0 and self.newStarLevel < 4  or LevelSuccessStar4Tpye.kFirstStar3 == self.showStar4Tpye then
		local parabolaStarActionArray = CCArray:create()
		local delayTimeBetweenStars = 0.2
		for index = 1,self.newStarLevel do
			local delay = CCDelayTime:create((index-1) * delayTimeBetweenStars)
			local parabolaStarAction = self:createParabolaStarAction(index, false)
			local seq = CCSequence:createWithTwoActions(delay, parabolaStarAction)
			parabolaStarActionArray:addObject(seq)
		end
		-- Spawn Parabola Star Action
		local spawn = CCSpawn:create(parabolaStarActionArray)
		actionArray:addObject(spawn)
		if LevelSuccessStar4Tpye.kFirstStar3 == self.showStar4Tpye then
			local startMoveAction = self:createEmptyStar4Action()
			actionArray:addObject(startMoveAction)
			actionArray:addObject(happyAnimalsAnim)
			actionArray:addObject(passLevelTxtAnim)
		end


	else

	end


	if self.newStarLevel == 4 then  -- four star level, play the flowers blooming animation
		actionArray:addObject(self:createFlowersAnimation())
	end

	------------------------------
	-- Create Parabola New Star Reward Action
	-- -----------------------------
	
	local starRewardActionArray = CCArray:create()

	for index = 1,self.newStarLevel do

		if index > self.oldStarLevel then

			-- -------------------
			-- Star Reward Action
			-- --------------------
			local starRewardAction	= self:createStarRewardAction(index)
			--actionArray:addObject(starRewardAction)
			if starRewardAction ~= nil and type(starRewardAction) == 'userdata' then
				starRewardActionArray:addObject(starRewardAction)
			end
		end
	end

	-- explain: starRewardActionArray could be empty,
	-- so we need to fill it so that CCSpawn:create() could pass.
	local emptyAction = CCDelayTime:create(0)
	starRewardActionArray:addObject(emptyAction)
	
	-- Spawn
	local starRewardAction = CCSpawn:create(starRewardActionArray)
	actionArray:addObject(starRewardAction)
	-- actionArray:addObject(CCDelayTime:create(0.8))

	local function checkCollectStarsPanel(...)

	end

	local function popoutPreBuff(  )
		if PreBuffLogic:getBuffUpgradeOnLastPlay() then
			PreBuffLogic:setBuffUpgradeOnLastPlay(true)
			PreBuffLogic:playBuffUpgradeAnimation( checkCollectStarsPanel , self.levelId )
		else
			checkCollectStarsPanel()
		end
		
	end

	-- 检测星星储蓄罐面板
	local function checkStarBankPanel()
		--如果有buff动画 并且星星储蓄罐没哟满呢 那么直接buff动画
		if  PreBuffLogic:getBuffUpgradeOnLastPlay() and not StarBank.needPopPanel or self.isActLevel then
			popoutPreBuff()
		else
			if LevelType:isMainLevel( self.levelId ) or LevelType:isHideLevel( self.levelId ) then
				Notify:dispatch("StarBankEventShowAddStarSuccessPanel", popoutPreBuff)
			else
				popoutPreBuff()
			end
		end	
	end

	local function difAnimationCallback(  )
		if self.isDisposed then return end
		if self._willDisposed then return end

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


        if self.showPigYearEndPanel then
			--print("difAnimationCallback(  ) self.showPigYearEndPanel",self.showPigYearEndPanel)
			asyncRunner:add(function ( done )
				self.showPigYearEndPanel(done)
			end)
		end

		asyncRunner:add(function ( done )
			if self.isDisposed then return end
			if self._willDisposed then return end

			if AreaTaskMgr:getInstance():hasTaskAndFinished(self.levelId + 1) then
				AreaTaskMgr:getInstance():getRewardByLevelId(self.levelId + 1, done)
			else
				if done then done() end
			end
		end)

		asyncRunner:add(function ( done )
			if self.isDisposed then return end
			if self._willDisposed then return end
			checkStarBankPanel()
		end)
		asyncRunner:run()
	end 



	if self.hasLevelDiffcultFlag == true and LevelSuccessStar4Tpye.kFirstStar3 == self.showStar4Tpye then
		local function CreateDifLevelTips(  )
			self:CreateDifLevelTips( )
		end 
		actionArray:addObject(CCCallFunc:create(CreateDifLevelTips))
		local function createLadybugFirstFourStar( ... )
			self:createLadybugFirstFourStar( difAnimationCallback )
		end
		actionArray:addObject(CCCallFunc:create(createLadybugFirstFourStar))
	elseif self.hasLevelDiffcultFlag == true and LevelSuccessStar4Tpye.kFirstStar3 ~= self.showStar4Tpye then
		local function CreateDifLevelTips(  )
			self:CreateDifLevelTips( difAnimationCallback )
		end 
		actionArray:addObject(CCCallFunc:create(CreateDifLevelTips))
	elseif self.hasLevelDiffcultFlag == false and LevelSuccessStar4Tpye.kFirstStar3 == self.showStar4Tpye then
		local function createLadybugFirstFourStar( ... )
			self:createLadybugFirstFourStar( difAnimationCallback )
		end
		actionArray:addObject(CCCallFunc:create(createLadybugFirstFourStar))
	else
		actionArray:addObject(CCCallFunc:create(function ( ... )
			difAnimationCallback()
		end))
	end

	local seq = CCSequence:create(actionArray)
	self:runAction(seq)
end




function LevelSuccessTopPanel:createPopoutPassLevelTxtAnim(...)
	assert(#{...} == 0)

	local filename = "passLevelSuccess"
	if _G.useTraditionalChineseRes then filename = "passLevelSuccess_zh_tw" end
	if self.newStarLevel == 4 then
		filename = 'passLevelSuccess_fourStar'
	end
	local passLevelTxtRes = ResourceManager:sharedInstance():buildGroup(filename)
	self.passLevelTxtRes = passLevelTxtRes

	local function addTheResourceFunc()
		passLevelTxtRes:setVisible(false)
		-- Add To Screen
		self:addChild(passLevelTxtRes)
		--self.happyAnimalBgLayer:addChild(passLevelTxtRes)
	end
	local addTheResourceAction = CCCallFunc:create(addTheResourceFunc)

	local manualAdjustPosX = -68
	local manualAdjustPosY = -73

	local QixiManager = require 'zoo.eggs.QixiManager'
	if QixiManager:getInstance():shouldSeeRose() then
		manualAdjustPosY = manualAdjustPosY + 80

		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 40
		end
	elseif PublicServiceManager:shouldShowActCollection(self.levelId) then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
	elseif CountdownPartyManager.getInstance():shouldShowActCollection(self.levelId) then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
    elseif DragonBuffManager.getInstance():shouldShowActCollection(self.levelId) then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
    elseif Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(self.levelId) then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
    elseif RecallA2019Manager.getInstance():getActStartPanelBubble() then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
	elseif CollectStarsManager.getInstance():isBuffEffectiveForLevelSuccessTopLevel (self.levelId )  and CollectStarsManager.getInstance():canShowTitle( self.levelId  ) then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
    elseif TurnTable2019Manager.getInstance():getCurIsAct() then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
	elseif self.uncommonSkin then
		manualAdjustPosY = manualAdjustPosY + 75
		if self.newStarLevel == 4 then
			manualAdjustPosY = manualAdjustPosY + 35
		end
	end

	local function isValideLevelId()
		return (self.levelId > LevelConstans.MAIN_LEVEL_ID_START and self.levelId < LevelConstans.MAIN_LEVEL_ID_END)
		or (self.levelId > LevelConstans.HIDE_LEVEL_ID_START and self.levelId < LevelConstans.HIDE_LEVEL_ID_END)
		or (self.levelId > LevelConstans.SUMMER_MATCH_LEVEL_ID_START and self.levelId < LevelConstans.SUMMER_MATCH_LEVEL_ID_END)
	end


	local animationInfo = {

		secondPerFrame = 1/24,

		object = {
			node = passLevelTxtRes,

			deltaScaleX = 1,
			deltaScaleY = 1,
			originalScaleX = 1,
			originalScaleY = 1,
		},

		keyFrames = {
			{ tweenType = "delay", frameIndex = 1},
			{ tweenType = "normal", frameIndex = 3, x = 265.55 + manualAdjustPosX, y = 17.75 + manualAdjustPosY,	sx = 1, sy = 1},
			{ tweenType = "normal", frameIndex = 5,	x = 265.55 + manualAdjustPosX, y = -76.85 + manualAdjustPosY,	sx = 1, sy = 1},
			{ tweenType = "normal", frameIndex = 7,	x = 265.55 + manualAdjustPosX, y = -61.45 + manualAdjustPosY,	sx = 1, sy = 1},
			{ tweenType = "static", frameIndex = 9,	x = 265.55 + manualAdjustPosX, y = -70.25 + manualAdjustPosY,	sx = 1, sy = 1},
		}
	}

	local action = FlashAnimBuilder:sharedInstance():buildTimeLineAction(animationInfo)

	-- Seq
	local seq = CCSequence:createWithTwoActions(addTheResourceAction, action)
	return seq
end

function LevelSuccessTopPanel:createHappyAnimalsAction()
	local animPopoutTime = 0.2
	--local manualAdjustAnimPosX = -15
	local manualAdjustAnimPosX = 0

	-- index = self.ui:getChildIndex( self.label_pur2 )
	--    self.ui:addChildAt( label_green , index)

	local function createAnimFun()


		local anim

		local QixiManager = require 'zoo.eggs.QixiManager'

		if QixiManager:getInstance():shouldSeeRose() then
			anim = WinAnimation:createQixi2017Anim()
        elseif RecallA2019Manager.getInstance():getActStartPanelBubble() and  RecallA2019Manager.getInstance():getMissonInfo() then
			local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
            anim = WinAnimation:createRecallA2019Ani(1)
            if ver <= 64 then
                anim:setVisible(false)
            end

			local ActCollectionPanel = require 'zoo.localActivity.RecallA2019.RecallA2019CollectionPanel'
		    local countdownPartyPanel = ActCollectionPanel:create(1)
		    countdownPartyPanel:setPosition(ccp(530, -250))
		    self.tipNode:addChild(countdownPartyPanel)
		    countdownPartyPanel:playShowAni()

		elseif PublicServiceManager:shouldShowActCollection(self.levelId) then
			anim = WinAnimation:createPublicServiceAni(1)
			local ActCollectionPanel = require 'zoo.localActivity.PublicService.ActCollectionPanel'
			local panel = ActCollectionPanel:create(1)
			panel:setPosition(ccp(490, -250))
	   		self.tipNode:addChild(panel)
			panel:playShowAni()
		elseif CountdownPartyManager.getInstance():shouldShowActCollection(self.levelId) then
			anim = WinAnimation:createCountdownPartyAni()
			local ActCollectionPanel = require 'zoo.localActivity.CountdownParty.ActCollectionPanel'
			local countdownPartyPanel = ActCollectionPanel:create(1)
			countdownPartyPanel:setPosition(ccp(540, -240))
			self.tipNode:addChild(countdownPartyPanel)
			countdownPartyPanel:playShowAni()
		elseif Thanksgiving2018CollectManager.getInstance():getActCollectionSupport(self.levelId) then
			anim = WinAnimation:createCountdownPartyAni()
			local Thanksgiving2018CollectPanel = require 'zoo.localActivity.Thanksgiving2018.Thanksgiving2018CollectPanel'
			local countdownPartyPanel = Thanksgiving2018CollectPanel:create(1)
			countdownPartyPanel:setPosition(ccp(540, -240))
			self.tipNode:addChild(countdownPartyPanel)
			countdownPartyPanel:playShowAni()
        elseif DragonBuffManager.getInstance():shouldShowActCollection(self.levelId) then
			anim = WinAnimation:createCountdownPartyAni()
			local DragonBuffPanel = require 'zoo.localActivity.DragonBuff.DragonBuffPanel'
			local countdownPartyPanel = DragonBuffPanel:create(1)
			countdownPartyPanel:setPosition(ccp(540, -240))
			self.tipNode:addChild(countdownPartyPanel)
			countdownPartyPanel:playShowAni()
		elseif CollectStarsManager.getInstance():isBuffEffectiveForLevelSuccessTopLevel (self.levelId )  and CollectStarsManager.getInstance():canShowTitle( self.levelId  ) then
			CollectStarsManager:loadSkeletonAssert()
			anim = WinAnimation:createCollectStarsAni(3)
			local ActCollectStarsPanel = require 'zoo.localActivity.CollectStars.ActCollectStarsPanel'
			local countdownPartyPanel = ActCollectStarsPanel:create(1)
			countdownPartyPanel:setPosition(ccp(180 + 300, -120+10 - 135))
			self.tipNode:addChild(countdownPartyPanel)
			countdownPartyPanel:playShowAni()
        elseif TurnTable2019Manager.getInstance():getCurIsAct() then
            anim = WinAnimation:create(self.uncommonSkin)
        
            local ActCollectionPanel = require 'zoo.localActivity.TurnTable2019.TurnTable2019CollectionPanel'
		    local countdownPartyPanel = ActCollectionPanel:create(1,self.levelId)
		    countdownPartyPanel:setPosition(ccp(480, -240))
		    self.tipNode:addChild(countdownPartyPanel)
		    countdownPartyPanel:playShowAni()
        else
			anim = WinAnimation:create(self.uncommonSkin)
		end

		-- local scoreBuffBottleAmount = CollectStarsManager:getInstance():getProgressNunForLevelInfo(self.levelId , self.startLevelType )
		-- if scoreBuffBottleAmount and scoreBuffBottleAmount >= 0 then
		-- 	anim = WinAnimation:createCollectStarsAni(3)
		-- 	self.ui:addChildAt(anim, 5)
		-- 	anim:play(0)
		-- 	anim:setPosition(ccp(350, -400))

		-- 	local ActCollectStarsPanel = require 'zoo.localActivity.CollectStars.ActCollectStarsPanel'
		-- 	local customPanel = nil
		-- 	if self.afterPopoutFromFailPanel then
		-- 		customPanel = ActCollectStarsPanel:create(5, scoreBuffBottleAmount)
		-- 	else
		-- 		customPanel = ActCollectStarsPanel:create(3, scoreBuffBottleAmount)
		-- 	end
		-- 	customPanel:setPosition(ccp(135, -200))
		-- 	self.ui:addChildAt(customPanel, 9)
		-- 	customPanel:playShowAni()
		-- end

		self.happyAnimalsAnim = anim
		self.happyAnimalBgLayer:addChild(anim)
		anim:play(animPopoutTime)
	end
	local action = CCCallFunc:create(createAnimFun)

	local delayAction = CCDelayTime:create(animPopoutTime)

	-- Seq
	local seq = CCSequence:createWithTwoActions(action, delayAction)
	return seq
end


function LevelSuccessTopPanel:createStarSinkAndBounceAction(starIndex, duration, vx, vy, ...)
	assert(type(starIndex)	== "number")
	assert(type(duration)	== "number")
	assert(type(vx)		== "number")
	assert(type(vy)		== "number")
	assert(#{...} == 0)

	local targetToControl = self:getStarByIndex(starIndex)

	local originalX = targetToControl:getPositionX()
	local originalY = targetToControl:getPositionY()

	local deltaX = duration * 0.5 * vx
	local deltaY = duration * 0.5 * vy
	
	-- ---------
	-- Ease Down
	-- ----------
	local moveTo		= CCMoveTo:create(duration, ccp(originalX + deltaX, originalY + deltaY))
	local easeMoveTo	= CCEaseBackOut:create(moveTo)

	-- -------------------
	-- Move To Original
	-- ----------------
	local moveToOriginal = CCMoveTo:create(duration, ccp(originalX, originalY))
	he_log_warning("CCEaseInOut second parameter has no corresponding value in actionScript example ")
	local easeMoveToOriginal = CCEaseInOut:create(moveToOriginal, 1)

	-- Delay
	local delay = CCDelayTime:create(duration)

	--------------
	-- Action Array
	-- -----------
	local actionArray = CCArray:create()
	actionArray:addObject(easeMoveTo)
	actionArray:addObject(easeMoveToOriginal)
	actionArray:addObject(delay)

	-- Seq
	local seq = CCSequence:create(actionArray)
	local targetSeq = CCTargetedAction:create(targetToControl.refCocosObj, seq)

	return targetSeq
end



function LevelSuccessTopPanel:createParabolaStarAction(starIndex, parabolaCallbackFunc , ...)
	assert(type(starIndex) == "number")
	assert(parabolaCallbackFunc == false or type(parabolaCallbackFunc) == "function")
	assert(#{...} == 0)

	local star = false

	if starIndex == 1 then
		star  = self.star1Res
	elseif starIndex == 2 then
		star = self.star2Res
	elseif starIndex == 3 then
		star = self.star3Res
	else
		assert(false)
	end

	local starBgCenter = self:getStarBgCenterByIndex(starIndex)


	local actionArray = CCArray:create()

	-----------------------
	-- Create Shing Score Progress Bar Star
	-- -------------------------------------
	local function createShingStarFunc()
		local scoreStarPos = ccp(self.starResInitPos[starIndex].x, self.starResInitPos[starIndex].y)
		local star = ScoreProgressAnimation:createFinishStarAnimation(scoreStarPos)
		self:addChild(star)
	end
	local createShingStarAction = CCCallFunc:create(createShingStarFunc)
	actionArray:addObject(createShingStarAction)

	-- Delay For Shing Star Finish
	local delayForStarScoreFinish = CCDelayTime:create(0.2)
	actionArray:addObject(delayForStarScoreFinish)


	-- ------------------
	-- Init Anim Action
	-- -------------------
	local function initAnim()
		star:setVisible(true)
		star:removeFromParentAndCleanup(false)
		self:addChild(star)
		star:setPosition(ccp(self.starResInitPos[starIndex].x, self.starResInitPos[starIndex].y))

		-- Call The Hide Star Callback Function
		if self.hideStarCallback then
			self.hideStarCallback(starIndex)
		end
	end
	local initAnimAction = CCCallFunc:create(initAnim)
	actionArray:addObject(initAnimAction)

	-- -------------------
	-- Parabola Move To
	-- -------------------
	local parabolaMoveTo = CCParabolaMoveTo:create(15 * 1/24, starBgCenter.x, starBgCenter.y, -3000)

	local curY			= false
	local alreadyBringToFront	= false

	local function parabolaCallback(newX, newY, vXInitial, vYInitial, vX, vY, duration, actionPercent)

		if parabolaCallbackFunc then
			parabolaCallbackFunc(newX, newY, vXInitial, vYInitial, vX, vY, duration, actionPercent)
		end

		if not curY then
			curY = newY
		else
			if curY < newY then
				curY = newY
			else
				-- Start To Fall 
				if not alreadyBringToFront then
					alreadyBringToFront = true
					star:removeFromParentAndCleanup(false)
					self.ui:addChild(star)
				end
			end
		end
	end

	parabolaMoveTo:registerScriptHandler(parabolaCallback)

	local ease = CCEaseSineOut:create(parabolaMoveTo)
	parabolaMoveTo = ease

	-- Rotate
	local rotate = CCRotateBy:create(30 * 1/60, 360)
	local easeBack = CCEaseBackOut:create(rotate)
	local rotate = easeBack

	local function playStarFlyFinishSoundEffect()
		GamePlayMusicPlayer:playEffect(GameMusicType.kStarOnPanel)
	end
	local scaleStarNormal = 1.0
	-- Scale
--	local scaleTo = CCSequence:createWithTwoActions(CCScaleTo:create(8 * 1/24, scaleStarNormal), CCCallFunc:create(playStarFlyFinishSoundEffect))
	

	local parabolaMoveTo_Seq = CCSequence:createWithTwoActions( parabolaMoveTo , CCCallFunc:create(playStarFlyFinishSoundEffect))
	-- Action Array
	local starActionArray = CCArray:create()
	starActionArray:addObject(parabolaMoveTo_Seq)
	starActionArray:addObject(rotate)
	starActionArray:addObject(CCScaleTo:create(8 * 1/24, scaleStarNormal))
	starActionArray:addObject(CCScaleTo:create(8 * 1/24, scaleStarNormal *0.6 ) )
	-- Spawn
	local moveToAndRotate = CCSpawn:create(starActionArray)
	actionArray:addObject(moveToAndRotate)

	
	

	------------------------
	-- Final Explode Action
	-- --------------------
	local function finalExplodeFunc()
		local pos = ccp(starBgCenter.x, starBgCenter.y)

		if self.panelType == LevelSuccessPanelTpye.kOlympic then
			--pos.y = pos.y + 10
		end

		local explode = ScoreProgressAnimation:createFinsihExplodeStar(pos)
		self:addChild(explode)

		local overlay = ScoreProgressAnimation:createFinsihShineStar(pos)

		if self.panelType == LevelSuccessPanelTpye.kOlympic then
			overlay:setScale(2)
		end
		
		self:addChild(overlay)
		table.insert(self.overlayAnims, overlay)
	end
	local finalExplodeAction = CCCallFunc:create(finalExplodeFunc)
	actionArray:addObject(finalExplodeAction)

	actionArray:addObject(CCScaleTo:create(10 * 1/60, scaleStarNormal * 1.3) )
	actionArray:addObject(CCScaleTo:create(10 * 1/60, scaleStarNormal ) )

	-- ------
	-- Seq
	-- -------
	local seq = CCSequence:create(actionArray)
	local targetedSeq = CCTargetedAction:create(star.refCocosObj, seq)

	return targetedSeq 
end

function LevelSuccessTopPanel:createFourStarParabolaStarAction(starIndex, parabolaCallbackFunc)
	local star = false

	if starIndex == 1 then
		star  = self.star1Res
	elseif starIndex == 2 then
		star = self.star2Res
	elseif starIndex == 3 then
		star = self.star3Res
	elseif starIndex == 4 then
		star = self.star4Res
	end

	local starCenterPos = self.ui:getChildByName('fourStarLocator'..starIndex):getPosition()


	local actionArray = CCArray:create()

	-----------------------
	-- Create Shing Score Progress Bar Star
	-- -------------------------------------
	local function createShingStarFunc()
		local scoreStarPos = ccp(self.starResInitPos[starIndex].x, self.starResInitPos[starIndex].y)
		local star = ScoreProgressAnimation:createFinishStarAnimation(scoreStarPos)
		self:addChild(star)
	end
	local createShingStarAction = CCCallFunc:create(createShingStarFunc)
	actionArray:addObject(createShingStarAction)

	-- Delay For Shing Star Finish
	local delayForStarScoreFinish = CCDelayTime:create(0.2)
	actionArray:addObject(delayForStarScoreFinish)


	-- ------------------
	-- Init Anim Action
	-- -------------------
	local function initAnim()
		star:setVisible(true)
		star:removeFromParentAndCleanup(false)
		self:addChild(star)
		star:setPosition(ccp(self.starResInitPos[starIndex].x, self.starResInitPos[starIndex].y))

		-- Call The Hide Star Callback Function
		if self.hideStarCallback then
			self.hideStarCallback(starIndex)
		end
	end
	local initAnimAction = CCCallFunc:create(initAnim)
	actionArray:addObject(initAnimAction)

	-- -------------------
	-- Parabola Move To
	-- -------------------
	local parabolaMoveTo = CCParabolaMoveTo:create(15 * 1/24, starCenterPos.x, starCenterPos.y, -3000)

	local curY			= false
	local alreadyBringToFront	= false

	local function parabolaCallback(newX, newY, vXInitial, vYInitial, vX, vY, duration, actionPercent)

		if parabolaCallbackFunc then
			parabolaCallbackFunc(newX, newY, vXInitial, vYInitial, vX, vY, duration, actionPercent)
		end

		if not curY then
			curY = newY
		else
			if curY < newY then
				curY = newY
			else
				-- Start To Fall 
				if not alreadyBringToFront then
					alreadyBringToFront = true
					star:removeFromParentAndCleanup(false)
					self.ui:addChild(star)
				end
			end
		end
	end

	parabolaMoveTo:registerScriptHandler(parabolaCallback)

	local ease = CCEaseSineOut:create(parabolaMoveTo)
	-- local ease = CCEaseBounceOut:create(parabolaMoveTo)
	parabolaMoveTo = ease

	local function playStarFlyFinishSoundEffect()
		GamePlayMusicPlayer:playEffect(GameMusicType.kStarOnPanel)
	end
	
	local scaleStarNormal = 0.9
	local parabolaMoveTo_Seq = CCSequence:createWithTwoActions( parabolaMoveTo , CCCallFunc:create(playStarFlyFinishSoundEffect))

	-- Scale
--	local scaleTo = CCSequence:createWithTwoActions(CCScaleTo:create(30 * 1/60, scaleStarNormal ), CCCallFunc:create(playStarFlyFinishSoundEffect))

	-- rotate
	star:setRotation(0)
	local offset = (starIndex - 2.5) * 10
	local rotate = CCRotateTo:create(30 * 1/60, 720 + offset)


	-- Action Array
	local starActionArray = CCArray:create()
	starActionArray:addObject(parabolaMoveTo_Seq)
	starActionArray:addObject(rotate)
	starActionArray:addObject(CCScaleTo:create(8 * 1/24, scaleStarNormal))
	starActionArray:addObject(CCScaleTo:create(8 * 1/24, scaleStarNormal *0.6 ) )
	starActionArray:addObject(rotate)


	-- Spawn
	local moveToAndRotate = CCSpawn:create(starActionArray)
	actionArray:addObject(moveToAndRotate)

	------------------------
	-- Final Explode Action
	-- --------------------
	local function finalExplodeFunc()
		local pos = ccp(starCenterPos.x, starCenterPos.y)
		local explode = ScoreProgressAnimation:createFinsihExplodeStar(pos)
		self:addChild(explode)

		local overlay = ScoreProgressAnimation:createFinsihShineStar(pos)
		self:addChild(overlay)
		table.insert(self.overlayAnims, overlay)
	end
	local finalExplodeAction = CCCallFunc:create(finalExplodeFunc)
	actionArray:addObject(finalExplodeAction)

	actionArray:addObject(CCScaleTo:create(10 * 1/60, scaleStarNormal * 1.3) )
	actionArray:addObject(CCScaleTo:create(10 * 1/60, scaleStarNormal ) )
	-- ------
	-- Seq
	-- -------
	local seq = CCSequence:create(actionArray)
	local targetedSeq = CCTargetedAction:create(star.refCocosObj, seq)

	return targetedSeq
end


-------------------------------------------------------
---------	Star Reward Animation
--------------------------------------------------------

function LevelSuccessTopPanel:createStarRewardAction(starIndex, ...)
	assert(starIndex)
	assert(#{...} == 0)

	-- Get Current Star 's Reward
	-- Only If This Star Is First Opened
	-- If Previous Reached This Star Level ,
	-- Then The Default Reward Is Used And Not Play THe Flying Animation

	-- Check If THis Star Level Is First Reached
	if _G.isLocalDevelopMode then printx(0, self.newStarLevel, starIndex, self.oldStarLevel) end
	if self.newStarLevel >= starIndex and starIndex > self.oldStarLevel then
		-- This Star Level Is First Reached
		-- Play The Flying Animation

		local isGetReward = true 

		local moveFromPoint = self:getStarBgCenterByIndex(starIndex , isGetReward)

		-- ----------------------------
		-- Create Flying Reward Resouce
		-- ----------------------------
		local function getRewardItemNumber(itemId)
			for k, v in pairs(self.rewardsFromServer) do
				if k == itemId then return v end
			end
			return 0
		end
		
		--- Get Reward Data
		local curStarReward = false
		if starIndex == 1 then
			curStarReward = self.level_reward.oneStarReward 
		elseif starIndex == 2 then
			curStarReward = self.level_reward.twoStarReward
		elseif starIndex == 3 then
			curStarReward = self.level_reward.threeStarReward
		elseif starIndex == 4 then
			curStarReward = self.level_reward.fourStarReward
		else 
			assert(false)
		end

        if self.levelType == GameLevelType.kMainLevel or self.levelType == GameLevelType.kHiddenLevel then
            local addPercent = MetaManager.getInstance():getAchiCoinExtraNum()
            if addPercent > 0 then
                for i,v in ipairs(curStarReward) do
                    if v.itemId == ItemType.COIN then
                        v.num = math.ceil(v.num * (1+addPercent))
                    end
                end
            end
        end

		assert(curStarReward)
		if (self.newStarLevel == starIndex and self.newStarLevel <= 3)
		or (self.newStarLevel == 4 and starIndex == 3) then
			if self:isHasIngredientReward() then
				local ingredientItem 
				for k, v in pairs(curStarReward) do
					if v.itemId == ItemType.INGREDIENT then
						ingredientItem = v
					end
				end
				if ingredientItem then
					ingredientItem.num = getRewardItemNumber(ItemType.INGREDIENT)
				else
					table.insert(curStarReward, {itemId = ItemType.INGREDIENT, num = getRewardItemNumber(ItemType.INGREDIENT)})
				end
			end
		end

		if _isQixiLevel then -- qixi
			curStarReward = {}
		end
		

		-- --------------------------
		-- Create Each Reward Action
		-- -------------------------
		local rewardActions = {}
		local numberOfRewardAction = 0
		local typeIndex	= 0

		if CollectStarsManager.getInstance():getAutoAddBuffNum() > 0 then
			table.insert(curStarReward , {itemId = ItemType.COLLECT_STAR_2019 , num=1})
		end
		for k,v in pairs(curStarReward) do
			typeIndex = typeIndex + 1
			rewardActions[typeIndex] = {}
			local rewardAction = self:createParabolaRewardAction(v.itemId, v.num, moveFromPoint)
			numberOfRewardAction = numberOfRewardAction + 1
			table.insert(rewardActions[typeIndex], rewardAction)
		end

		local totalTypes = typeIndex 
		-- ---------------------------------
		-- Arrange Reward Actions To Queue
		-- ---------------------------------
		local rewardActionQueue = {}
		local typeIndex = false
		local countForModulusLoop = 0

		for index = 1, numberOfRewardAction do

			local repeatCount = 0
			repeat
				typeIndex = countForModulusLoop % totalTypes + 1
				countForModulusLoop = countForModulusLoop + 1

				repeatCount = repeatCount + 1

				if repeatCount > totalTypes then
					assert(false, "When Loop totalTypes Count, Must Find An Action, Some Thing May Wrong !")
				end
			until rewardActions[typeIndex][1]

			table.insert(rewardActionQueue, rewardActions[typeIndex][1])
			table.remove(rewardActions[typeIndex], 1)
		end

		-- Assert
		for typeIndex = 1, totalTypes do
			assert(#rewardActions[typeIndex] == 0)
		end

		--------------------------
		--- Create Actions With First Delay
		-------------------------------

		-- Action Array
		local actionArray	= CCArray:create()
		local delayStep		= 0.1
		local startDelayTime	= 0

		for index = 1, #rewardActionQueue do

			local delay = CCDelayTime:create(startDelayTime)
			startDelayTime = startDelayTime + delayStep

			local firstDelayRewardAction = CCSequence:createWithTwoActions(delay, rewardActionQueue[index])
			actionArray:addObject(firstDelayRewardAction)
		end

		local spawn	= CCSpawn:create(actionArray)

		return spawn

		--local runningScene	= Director:getRunningScene()
		--runningScene:runAction(spawn)
	else
		-- Default Reward 
		-- Already Add When This Panel Is Initiated
	end

	-- Return A Null Action
	local function nothing()
		local tmp = 10
	end
	local noOpAction = CCCallFunc:create(nothing)
	return noOpAction
end

function LevelSuccessTopPanel:getRewardItemByRewardId(rewardId, ...)
	assert(type(rewardId) == "number")
	assert(#{...} == 0)
	for index = 1, #self.rewardItems do
		local id = self.rewardItems[index]:getRewardId()
		if _G.isLocalDevelopMode then printx(0, 'test ', id) end
		if id == rewardId then
			return self.rewardItems[index] , index
		end
	end
	return nil , nil
end

-- deprecated
function LevelSuccessTopPanel:createSmallStarAction(smallStar, ...)
	assert(smallStar)
	assert(#{...} == 0)

	local starWithGlow	= smallStar:getChildByName("starWithGlow")
	local starWithoutGlow	= smallStar:getChildByName("starWithoutGlow")
	assert(starWithGlow)
	assert(starWithoutGlow)

	local secondPerFrame = 1/24

	-----------------------
	-- Init Animation
	-- --------------------
	local function initAnim()
		starWithGlow:setOpacity(255)
		starWithoutGlow:setOpacity(255)
	end
	local initAnimAction = CCCallFunc:create(initAnim)

	-----------------
	---- Fade Out
	------------------
	local starWithGlowFadeOut 	= CCTargetedAction:create(starWithGlow.refCocosObj, CCFadeOut:create( 6 * secondPerFrame))
	local starWithoutGlowFadeOut	= CCTargetedAction:create(starWithoutGlow.refCocosObj, CCFadeOut:create(13 * secondPerFrame))
	local spawnFadeOut		= CCSpawn:createWithTwoActions(starWithGlowFadeOut, starWithoutGlowFadeOut)

	----------------
	-- Fade In
	-- -------------
	local delay 			= CCDelayTime:create(6 * secondPerFrame)
	local starWithGlowFadeIn	= CCTargetedAction:create(starWithGlow.refCocosObj, CCFadeIn:create( (25 - 13 - 6) * secondPerFrame))
	local starWithGlowDelayFadeIn	= CCSequence:createWithTwoActions(delay, starWithGlowFadeIn)

	local starWithoutGlowFadeIn	= CCTargetedAction:create(starWithoutGlow.refCocosObj, CCFadeIn:create( (25 - 13) * secondPerFrame))
	local spawnFadeIn		= CCSpawn:createWithTwoActions(starWithGlowDelayFadeIn, starWithoutGlowFadeIn)

	-------------
	-- Delay
	-- ------------
	local delay = CCDelayTime:create((33 - 25) * secondPerFrame)

	-----------
	-- Action Array
	-- --------
	local actionArray = CCArray:create()
	actionArray:addObject(spawnFadeOut)
	actionArray:addObject(spawnFadeIn)
	actionArray:addObject(delay)

	-- Seq
	local seq = CCSequence:create(actionArray)

	-- Random Start Point
	local duration = seq:getDuration()

	-- Repeat Forever
	local repeatForever = CCRepeatForever:create(seq)
	return repeatForever, duration
end

-- deprecated
function LevelSuccessTopPanel:createStarShakeAction(star, ...)
	assert(star)
	assert(#{...} == 0)

	local secondPerFrame = 1 / 24
	local rotateAngle	= 5

	----------------
	-- First Delay
	-- --------------
	local firstDelay = CCDelayTime:create((14 - 1) * secondPerFrame)

	-------------------------
	----	Shake One Time
	--------------------------
	local backToOriginal1	= CCRotateTo:create(0, 0)
	local delay1		= CCDelayTime:create( 1*secondPerFrame)
	local rotateRight	= CCRotateTo:create(0, rotateAngle)
	local delay2		= CCDelayTime:create( 1*secondPerFrame)
	local backToOriginal2	= CCRotateTo:create(0, 0)
	local delay3		= CCDelayTime:create( 1*secondPerFrame)
	local rotateLeft	= CCRotateTo:create(0, -rotateAngle)
	local delay4		= CCDelayTime:create( 1*secondPerFrame)
	local backToOriginal3	= CCRotateTo:create(0, 0)

	local actionArray = CCArray:create()
	actionArray:addObject(backToOriginal1)
	actionArray:addObject(delay1)
	actionArray:addObject(rotateRight)
	actionArray:addObject(delay2)
	actionArray:addObject(backToOriginal2)
	actionArray:addObject(delay3)
	actionArray:addObject(rotateLeft)
	actionArray:addObject(delay4)
	actionArray:addObject(backToOriginal3)

	local starShake1Time = CCSequence:create(actionArray)

	-------------------------
	--- Repeat 3 Times
	---------------------
	local repeat3Time = CCRepeat:create(starShake1Time, 3)

	------------------
	--- Last Delay
	-------------
	local lastDelay = CCDelayTime:create((33 - 26) * secondPerFrame)

	-- Seq
	local actionArray	= CCArray:create()
	actionArray:addObject(firstDelay)
	actionArray:addObject(repeat3Time)
	actionArray:addObject(lastDelay)

	local seq		= CCSequence:create(actionArray)
	local targetedSeq	= CCTargetedAction:create(star.refCocosObj,seq)

	return targetedSeq
end

-- deprecated
function LevelSuccessTopPanel:createRoundBeam(numberOfBeam, ...)
	assert(type(numberOfBeam) == "number")
	assert(numberOfBeam >= 1)
	assert(#{...} == 0)

	local beams = Layer:create()

	for index = 1,numberOfBeam do

		local beam = ResourceManager:sharedInstance():buildSprite("beam")
		beam:setAnchorPoint(ccp(0.5, 0))

		local rotateAngle = 360 / numberOfBeam * (index - 1)
		beam:setRotation(rotateAngle)

		beams:addChild(beam)
	end

	return beams
end

-- deprecated
function LevelSuccessTopPanel:createNewStarTxtAnim(newStarTxtAnimRes, ...)
	assert(newStarTxtAnimRes)
	assert(#{...} == 0)

	----------------
	-- Get UI Resource
	-- ---------------
	local ben	= newStarTxtAnimRes:getChildByName("ben")
	local guan	= newStarTxtAnimRes:getChildByName("guan")
	local xin	= newStarTxtAnimRes:getChildByName("xin")
	local huo	= newStarTxtAnimRes:getChildByName("huo")
	local de	= newStarTxtAnimRes:getChildByName("de")

	assert(ben)
	assert(guan)
	assert(xin)
	assert(huo)
	assert(de)

	local secondPerFrame = 1 / 24

	local function createCharAnim(charToControl, delayFrame, scaleFrame, ...)
		assert(charToControl)
		assert(type(delayFrame) == "number")
		assert(type(scaleFrame) == "number")
		assert(#{...} == 0)

		-- Delay
		local delay = CCDelayTime:create(delayFrame * secondPerFrame)

		-- Init
		local function initCharAnim()
			charToControl:setAnchorPointCenterWhileStayOrigianlPosition()
			charToControl:setScale(2)
			charToControl:setVisible(true)
		end
		local initCharAnimAction = CCCallFunc:create(initCharAnim)

		-- Scale To 1
		local scaleToOriginal = CCScaleTo:create(scaleFrame * secondPerFrame, 1)

		-- Seq
		local actionArray = CCArray:create()
		actionArray:addObject(delay)
		actionArray:addObject(initCharAnimAction)
		actionArray:addObject(scaleToOriginal)

		local seq = CCSequence:create(actionArray)
		local targetedSeq = CCTargetedAction:create(charToControl.refCocosObj, seq)
		return targetedSeq
	end

	-- --------------
	-- Char Actions
	-- --------------
	
	local function initAnim()
		newStarTxtAnimRes:setVisible(true)
		newStarTxtAnimRes:setChildrenVisible(false, false)
	end
	local initAnimAction = CCCallFunc:create(initAnim)

	local benAction		= createCharAnim(ben, 0, 4)
	local guanAction	= createCharAnim(guan, 4, 4)
	local xinAction		= createCharAnim(xin, 8, 4)
	local huoAction		= createCharAnim(huo, 12, 4)
	local deAction		= createCharAnim(de, 16, 4)

	local actionArray = CCArray:create()
	actionArray:addObject(initAnimAction)
	actionArray:addObject(benAction)
	actionArray:addObject(guanAction)
	actionArray:addObject(xinAction)
	actionArray:addObject(huoAction)
	actionArray:addObject(deAction)
	local spawn = CCSpawn:create(actionArray)

	local seq = CCSequence:createWithTwoActions(initAnimAction, spawn)
	return seq
end

function LevelSuccessTopPanel:createParabolaRewardAction(rewardId, number, fromPoint, ...)
	assert(type(rewardId)	== "number")
	assert(type(number)	== "number")
	assert(fromPoint)
	assert(#{...} == 0)

	-- Get Item Icon
	local rewardItem	= false
	local toPoint		= false
	local toRewardItem	= false

	-- Get Flying Reward toPoint Based On rewardId
	local toRewardItem , itemIndex = self:getRewardItemByRewardId(rewardId)
	assert(toRewardItem)
	---- Get Center Pos As toPoint
	local center	= toRewardItem:getPlaceHolderCenterInParentSpace()
	toPoint = ccp(center.x, center.y)

	-- Create Flying Reward Resource
	-- local rewardItem = ResourceManager:sharedInstance():buildItemSprite(rewardId)
	local rewardItem = nil 

	rewardItem = ResourceManager:sharedInstance():buildItemSprite(rewardId)
	

	rewardItem:setVisible(false)
	self:addChild(rewardItem)

	-- -----------
	-- Init Anim
	-- ------------
	local function initAnim()
		rewardItem:setAnchorPoint(ccp(0.5, 0.5))
		rewardItem:setScale(0.1, 0.1)
		rewardItem:setPosition(ccp(fromPoint.x, fromPoint.y))
		rewardItem:setVisible(true)
	end
	local initAnimAction = CCCallFunc:create(initAnim)

	-- ---------
	-- Enlarge
	-- ------------
	local scaleTo = CCScaleTo:create(0.25, 1)

	-- --------------------
	-- Parabola Animation
	-- ---------------------
	--local parabolaMoveTo = CCParabolaMoveTo:create(36 * 1/60, toPoint.x, toPoint.y, -1600)
	local parabolaMoveTo = CCParabolaMoveTo:create(36 * 1/60, toPoint.x, toPoint.y, -3200)

	-- -------------------
	-- Enlarge And Fade Out
	-- ----------------------
	local enlargeTo	= CCScaleTo:create(0.2, 4)
	local fadeOut	= CCFadeOut:create(0.2)
	local enlargeAndFadeOut	= CCSpawn:createWithTwoActions(enlargeTo, fadeOut)

	-------------------------
	-- Anim Finish Callback
	-- ------------------------
	-- Add The Number To The Reward Number
	local function onMoveToFinished()
		rewardItem:removeFromParentAndCleanup(true)
		toRewardItem:addNumber( number )
	end

	local function difRewardEft()
		if self.hasLevelDiffcultFlag then
			print("rewardId == " , rewardId ) 
			local info1 = self.rewardsFromServer[rewardId]
			local info2 = self.rewardsFromServer_LevelDiffcultFlag[rewardId]
			if info1 and info2 and tonumber(info1) < tonumber(info2) then
				self:CreateDifRewardEft( itemIndex ,rewardId)
			end
		end
	end

	local moveToFinishAction = CCCallFunc:create(onMoveToFinished)
	local difRewardEftAction = CCCallFunc:create( difRewardEft )
	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(initAnimAction)
	actionArray:addObject(scaleTo)
	actionArray:addObject(parabolaMoveTo)
	actionArray:addObject(enlargeAndFadeOut)
	actionArray:addObject(moveToFinishAction)
	actionArray:addObject( difRewardEftAction )
	-- Sequence
	local seq	= CCSequence:create(actionArray)
	local targetedSeq	= CCTargetedAction:create(rewardItem.refCocosObj, seq)
	return targetedSeq
end

function LevelSuccessTopPanel:getStarScoreLabelByIndex(index, ...)
	assert(type(index) == "number")
	assert(#{...} == 0)

	local label = self.starScoreLabels[index]
	assert(label)
	return label
end

function LevelSuccessTopPanel:createStarScoreLabelAction(labelIndex, ...)
	assert(type(labelIndex) == "number")
	assert(#{...} == 0)

	local labelToControl = self:getStarScoreLabelByIndex(labelIndex)

	----------------
	-- Init Anim
	----------------
	local function initAnim()
		labelToControl:setScale(0.1)
		labelToControl:setOpacity(0)
	end
	local initAnimAction = CCCallFunc:create(initAnim)

	----------
	-- Show
	-- -------
	-- Scale To 1
	local scale	= CCScaleTo:create(0.2, 1)
	local easeScale	= CCEaseBackOut:create(scale)
	-- Fade In
	local fadeIn	= CCFadeIn:create(0.2)
	local easeSpawn = CCSpawn:createWithTwoActions(easeScale, fadeIn)

	----------
	-- Delay
	----------
	local delay	= CCDelayTime:create(0.2)

	----------
	-- Hide
	-- -------
	local scale	= CCScaleTo:create(0.2, 0.1)
	local fadeOut	= CCFadeOut:create(0.2)
	local spawn	= CCSpawn:createWithTwoActions(scale, fadeOut)

	---------------
	-- Action Array
	-- -----------
	local actionArray = CCArray:create()
	actionArray:addObject(initAnimAction)
	actionArray:addObject(easeSpawn)
	actionArray:addObject(delay)
	actionArray:addObject(spawn)

	-- Seq
	local seq = CCSequence:create(actionArray)
	local targetedSeq = CCTargetedAction:create(labelToControl.refCocosObj, seq)

	return targetedSeq
end

function LevelSuccessTopPanel:createFlowersAnimation(finishCallback)
	local bloomTime = 24/60
	local rotateTime = 20/60
	local reverseRotateTime = 4/60
	local bloomInterval = 4/60
	local rotateAngle = 150
	local reverseRotateAngle = -15
	local numOfFlowers = 13
	local layer = self.ui:getChildByName('flowers_deco')
	layer:setVisible(true)
	local delayTime = 0
	local targetedActions = CCArray:create()
	for i=1, numOfFlowers do 
		local flower = layer:getChildByName('f'..i)
		local endScale = flower:getScale()
		flower:setVisible(true)
		flower:setScale(0)
		flower:setAnchorPoint(ccp(0.5, 0.5))
		local actions = CCArray:create()
		local delay = CCDelayTime:create(delayTime)
		local enlarge = CCScaleTo:create(bloomTime, endScale * 1.2)
		local rotate = CCRotateBy:create(rotateTime, rotateAngle)
		local reverseRotate = CCRotateBy:create(reverseRotateTime, reverseRotateAngle)
		local shrink = CCScaleTo:create(reverseRotateTime, endScale)
		actions:addObject(delay)
		actions:addObject(CCSpawn:createWithTwoActions(rotate, enlarge))
		actions:addObject(CCSpawn:createWithTwoActions(reverseRotate, shrink))
		delayTime = delayTime + 0.05
		-- flower:runAction(CCSequence:create(actions))
		local targetedAction = CCTargetedAction:create(flower.refCocosObj, CCSequence:create(actions))
		targetedActions:addObject(targetedAction)
	end
	return CCSpawn:create(targetedActions)
end

function LevelSuccessTopPanel:fourStarGuide( ... )
	-- body
	local _type, _level = FourStarManager:getInstance():getLadyBugAnimationType(self.levelId, self.newStarLevel)
	self.four_star_guide_type = _type
	self.four_star_guide_recommend_level = _level
end

function LevelSuccessTopPanel:createLadybugFourStarGuideAnimation( ... )
	-- body
	local _type = self.four_star_guide_type
	local _level = self.four_star_guide_recommend_level
	
	local function callback( ... )
		-- body
		if _level then
			self:onCloseBtnTapped()
			local function timeoutcallback()
				HomeScene:sharedInstance().worldScene:startLevel(_level)
			end
			setTimeOut(timeoutcallback, 0)
		end
	end

	if _type then
		local pos_to = self.rewardTxt:getPosition()
		local txt_size = self.rewardTxt:getGroupBounds().size
		pos_to.x = pos_to.x + txt_size.width/2
		local txt = Localization:getInstance():getText("fourstar_this_stage_tips_1")
		if _level then
			txt = Localization:getInstance():getText("fourstar_other_stage_tips",{replace = _level})
		end
		local sprite = LadybugFourStarAnimation:create(pos_to, 300, _type, txt, callback)
		self.ui:addChild(sprite)
	end
end




-- 如果奖励的金豆荚多余配置中的数量，那就是跳关返回的
function LevelSuccessTopPanel:isIngredientRefunded()
	local threeStarReward = self.level_reward.threeStarReward
	local baseCount = 0
	for k, v in pairs(threeStarReward) do
		if v.itemId == ItemType.INGREDIENT then
			baseCount = baseCount + v.num
		end
	end
	local totalCount = 0
	for k, v in pairs(self.rewardItemsDataFromServer) do
		if v.itemId == ItemType.INGREDIENT then
			totalCount = totalCount + v.num
		end
	end
	return totalCount > baseCount
end

-- function LevelSuccessTopPanel:showShareIcon(allHide)

-- 	-- if _G.isLocalDevelopMode then printx(101, "  " , debug.traceback() ) end
	
-- 	if self.isDisposed then return end

-- 	if not self.shareToWeiBoBtn then return end

-- 	self.shareToWeiBoBtn:setIcon(nil)

-- 	local shareType = SnsUtil.getShareType()

-- 	if _G.isLocalDevelopMode then printx(101, "LevelSuccessTopPanel showShareIcon shareType = " , shareType ) end



-- 	if allHide then return end

-- 	self.shareToWeiBoBtn:setColorMode( kGroupButtonColorMode.blue )
-- 	self.shareToWeiBoBtn:setIconByFrameName("common_icon/sns/icon_wechat0000")
	
-- 	if __IOS_FB then 
-- 		-- self.shareFB:setVisible(true)
-- 	else 
		
-- 		if shareType then 
-- 			if shareType == PlatformShareEnum.kMiTalk then 
-- 				self.shareToWeiBoBtn:setIconByFrameName("common_icon/sns/icon_mi0000")
-- 			elseif shareType == PlatformShareEnum.kJPQQ then 
-- 				self.shareToWeiBoBtn:setIconByFrameName("common_icon/sns/icon_qq0000")
-- 			elseif shareType == PlatformShareEnum.kJPWX then
-- 				self.shareToWeiBoBtn:setIconByFrameName("common_icon/sns/icon_wechat0000")
-- 			else
-- 				self.shareToWeiBoBtn:setIconByFrameName("common_icon/sns/icon_wechat0000")
-- 			end
-- 		end
-- 	end
	
-- end

function LevelSuccessTopPanel:popPreBuffPanel( callback )
	if self.isDisposed then return end


	-- PreBuffLogic:setBuffUpgradeOnLastPlay(true)
	-- PreBuffLogic:playBuffUpgradeAnimation( callback )

	local levelId = self.levelId
	local function popPanel()

		PreBuffLogic:popActPanel(
			function() 
				if self.isDisposed then return end
				callback()
				-- self:onNextLevelBtnTapped() 
			end, levelId)

	end
	HomeScene:sharedInstance():runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(popPanel)))
end

function LevelSuccessTopPanel:CreateDifRewardEft( index ,itemID  )


	if not self.effectItemIDTable then
		self.effectItemIDTable = {}
	end

	local hasItemID = table.find( self.effectItemIDTable , function( v )
	    	return v == itemID end
	    ) 
	if not hasItemID then
		table.insert( self.effectItemIDTable ,itemID )
	else
		return
	end

	-- local itemNumAdd = 0
	-- for k,v in pairs(self.rewardItemsDataFromServer) do
	-- 	if v.awardType == REWARDITEM_AWARDTYPE.LEVELDIFFCULTFLAG and v.itemId == itemID then
	-- 		itemNumAdd = itemNumAdd + v.num
	-- 	end
	-- end
	-- if itemNumAdd == 0 then
	-- 	return
	-- end
	-- print(" table.tostring( self.rewardItemsDataFromServer ) = " , table.tostring( self.rewardItemsDataFromServer ) )

	--不算上关卡难度标记时的奖励数值
	local num_1 = self.rewardsFromServer[itemID]
	-- 算上关卡难度标记加成后的实际数据
	local num_2 = self.rewardsFromServer_LevelDiffcultFlag[itemID]

	-- num_1 = 2 
	-- num_2 = 9

	if not index then
		return
	end
	if not num_1 then
		return
	end
	if not num_2 then
		return
	end


	local distanceNum = num_2 - num_1
    if distanceNum == 0 then
    	return
    end
	local rewardItemNode = self.rewardItems[index]
	if not rewardItemNode then
		return
	end
	if rewardItemNode.numberLabel then
		rewardItemNode.numberLabel:setString(" ")
		rewardItemNode.numberLabel:setVisible(false)
	end

	local rewardItemNodePosX = rewardItemNode:getPositionX()
	local rewardItemNodePosY = rewardItemNode:getPositionY()

	local no_AnchorPoint_X = rewardItemNode.numberLabel:getAnchorPoint().x
	local no_AnchorPoint_Y = rewardItemNode.numberLabel:getAnchorPoint().y

	local no_Pos_X = rewardItemNode.numberLabel:getPositionX()
	local no_Pos_Y = rewardItemNode.numberLabel:getPositionY()

	no_Pos_X = no_Pos_X + 10  
	no_Pos_Y = no_Pos_Y + 82 

	local labelNo_1_PosOffset_X = 0
	local labelNo_1_PosOffset_Y = 0
	local labelNo_2_PosOffset_X = 0
	local labelNo_2_PosOffset_Y = 0

	local labelNo_3_PosOffset_X = 0
	local labelNo_3_PosOffset_Y = 30

	local labelScale_1 = 1
	local labelScale_2 = 1
	local labelScale_3 = 1
	if num_1 > 9999 then

	elseif num_1 > 999 then
		labelNo_1_PosOffset_X = 0
		labelNo_1_PosOffset_Y = -2

	elseif num_1 > 99 then
		labelScale_1 = 1.3
		labelNo_1_PosOffset_X = 0
		labelNo_1_PosOffset_Y = 0
	elseif num_1 > 9 then
		labelScale_1 = 1.35
		labelNo_1_PosOffset_X = -10
		labelNo_1_PosOffset_Y = 5
	else
		labelScale_1 = 1.35
		labelNo_1_PosOffset_X = -10
		labelNo_1_PosOffset_Y = 5
	end

	if num_2 > 9999 then

	elseif num_2 > 999 then
		labelNo_2_PosOffset_X = 0
		labelNo_2_PosOffset_Y = -2
	elseif num_2 > 99 then
		labelScale_2 = 1.3
		labelNo_2_PosOffset_X = 0
		labelNo_2_PosOffset_Y = 0
	elseif num_2 > 9 then
		labelScale_2 = 1.35
		labelNo_2_PosOffset_X = -10
		labelNo_2_PosOffset_Y = 5
	else
		labelScale_2 = 1.35
		labelNo_2_PosOffset_X = -10
		labelNo_2_PosOffset_Y = 5
	end



	if distanceNum > 9999 then

	elseif distanceNum > 999 then
		labelScale_3 = 1.0
		labelNo_3_PosOffset_X = 0
		labelNo_3_PosOffset_Y = -2
	elseif distanceNum > 99 then
		labelScale_3 = 1.0
		labelNo_3_PosOffset_X = 0
		labelNo_3_PosOffset_Y = 0
	elseif distanceNum > 9 then
		labelScale_3 = 1.0
		labelNo_3_PosOffset_X = -10
		labelNo_3_PosOffset_Y = 5
	else
		labelScale_3 = 1.0
		labelNo_3_PosOffset_X = -10
		labelNo_3_PosOffset_Y = 5
	end

	if itemID == ItemType.ENERGY_LIGHTNING then
		labelNo_1_PosOffset_X = labelNo_1_PosOffset_X - 20
		labelNo_2_PosOffset_X = labelNo_2_PosOffset_X - 20
		labelNo_3_PosOffset_X = labelNo_3_PosOffset_X - 20 

		-- labelNo_1_PosOffset_Y = labelNo_1_PosOffset_Y - 3
		-- labelNo_2_PosOffset_Y = labelNo_2_PosOffset_Y - 3
		-- labelNo_3_PosOffset_Y = labelNo_3_PosOffset_Y - 3 


	end
--	ItemType.COIN 



	rewardItemNodePosX = rewardItemNodePosX - 95 
--	rewardItemNodePosY = rewardItemNodePosY + 48
	rewardItemNodePosY = rewardItemNodePosY + 58
	labelNo_1_PosOffset_Y = labelNo_1_PosOffset_Y - 10
	labelNo_2_PosOffset_Y = labelNo_2_PosOffset_Y - 10
	labelNo_3_PosOffset_Y = labelNo_3_PosOffset_Y - 10 

	-- print("rewardItemNodePosX = " , rewardItemNodePosX )
	-- print("rewardItemNodePosY = " , rewardItemNodePosY )

	local worldPos_NumberLabel = rewardItemNode.numberLabel:convertToWorldSpace(ccp(0,0))

	local contentSize = rewardItemNode.numberLabel:getContentSize()

	local right_DownPos_X = worldPos_NumberLabel.x + (1-no_AnchorPoint_X) * contentSize.width 
	local right_DownPos_Y = worldPos_NumberLabel.y - (1-no_AnchorPoint_X) * contentSize.height 

    local node = ArmatureNode:create('numEft')
    node:playByIndex(0, 1)   
    node:update(0.01)
    node:stop()
    node:playByIndex(0, 1)
    local function animationCallback()
        if difAnimationCallback then
        	difAnimationCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
 	node:setAnimationScale( 1.0 )
 	node:setScale(1.0)
    node:setPosition(ccp( rewardItemNodePosX, rewardItemNodePosY  ))
    self.ui:addChild(node)


    local labelPosX = 20
    local labelPosY = 0
    local slotNode_No1 = node:getSlot("NO1")
    if slotNode_No1 then
		local labelNo1 = BitmapText:create(tostring(num_1), 'fnt/scene_icon_lable.fnt')
		local width_LabelNo1 = labelNo1:getContentSize().width
		local scaleNo1 = 60 / width_LabelNo1

		labelNo1:setScale( labelScale_1 )
		labelNo1:setAnchorPoint(ccp( 1 , 1))
		labelNo1:setPosition(ccp( no_Pos_X + labelNo_1_PosOffset_X , no_Pos_Y + labelNo_1_PosOffset_Y ))

		local emptySprite = Sprite:createEmpty()
        emptySprite:addChild( labelNo1 )
        emptySprite:setAnchorPoint(ccp(0, 0))
        slotNode_No1:setDisplayImage( emptySprite.refCocosObj )
    end
    local slotNode_No2 = node:getSlot("NO2")
    if slotNode_No2 then
		local labelNo2 = BitmapText:create(tostring(num_2), 'fnt/scene_icon_lable.fnt')

		-- local width_LabelNo2 = labelNo2:getContentSize().width
		-- local scaleNo2 = 60 / width_LabelNo2
		labelNo2:setScale( labelScale_2 )
		labelNo2:setAnchorPoint(ccp( 1 , 1))

		labelNo2:setPosition(ccp( no_Pos_X + labelNo_2_PosOffset_X , no_Pos_Y + labelNo_2_PosOffset_Y -5 ))

		local emptySprite = Sprite:createEmpty()
        emptySprite:addChild( labelNo2 )
        emptySprite:setAnchorPoint(ccp(0, 0))
        emptySprite:setPosition(ccp( 0 , 0 ))
        slotNode_No2:setDisplayImage( emptySprite.refCocosObj )
    end



    local slotNode_No3 = node:getSlot("NO3")
    if slotNode_No3 then

    --	local labelNo3 = TextField:create("+ "..tostring(distanceNum), nil, 30 , CCSizeMake( 100 , 50), kCCTextAlignmentRight, kCCVerticalTextAlignmentBottom)

		local labelNo3 = BitmapText:create("+ "..tostring(distanceNum), 'fnt/hud.fnt')
		labelNo3:setScale( labelScale_3 )
		labelNo3:setAnchorPoint(ccp( 1 , 1))
		labelNo3:setColor((ccc3(199,89,70)))
		labelNo3:setPosition(ccp( no_Pos_X + labelNo_3_PosOffset_X , no_Pos_Y + labelNo_3_PosOffset_Y  ))

		local emptySprite = Sprite:createEmpty()
        emptySprite:addChild( labelNo3 )
        emptySprite:setAnchorPoint(ccp(0, 0))
        emptySprite:setPosition(ccp( 0 , 0 ))
        slotNode_No3:setDisplayImage( emptySprite.refCocosObj )
    end






end

function LevelSuccessTopPanel:levelDiffcultFlagVisable()

	LevelPanelDifficultyChanger:changeBgByDifficulty(self,self.levelFlag,HomeScenePanelSkinType.kLevelSucTopPanel)

	--花的位置 

	local flowersLayer = self.ui:getChildByName('flowers_deco')

	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		local f2 = flowersLayer:getChildByName("f2")
		f2:setScale(0.6)
		f2:setPosition(ccp(130,-9))

		local f11 = flowersLayer:getChildByName("f11")
		f11:setScale(1.2)
		f11:setPosition(ccp(84,-49))

		local f12 = flowersLayer:getChildByName("f12")
		f12:setScale(1.5)
		f12:setPosition(ccp(475,-42))

		local f8 = flowersLayer:getChildByName("f8")
		f8:setScale(1.0)
		f8:setPosition(ccp(435,-22))
	elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then 
		local f2 = flowersLayer:getChildByName("f2")
		f2:setScale(0.7)
		f2:setPosition(ccp(111,-58))

		local f11 = flowersLayer:getChildByName("f11")
		f11:setScale(1.0)
		f11:setPosition(ccp(74,-28))

		local f12 = flowersLayer:getChildByName("f12")
		f12:setScale(1.5)
		f12:setPosition(ccp(501,-50))

		local f8 = flowersLayer:getChildByName("f8")
		f8:setScale(1.0)
		f8:setPosition(ccp(442,-17))
	end


end

function LevelSuccessTopPanel:CreateDifLevelTips( difAnimationCallback )
    local node = ArmatureNode:create('level_tips')
    node:playByIndex(0, 1)   
    node:update(0.01)
    node:stop()
    node:playByIndex(0, 1)
    local function animationCallback()
        if difAnimationCallback then
        	difAnimationCallback()
        end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
 	node:setAnimationScale( 1.0 )
 	node:setScale(1.5)
    node:setPosition(ccp( 747/2, -530  ))
    self.ui:addChild(node)
end

function LevelSuccessTopPanel:createLadybugFirstFourStar( flyFinishCallback )


    local node = ArmatureNode:create('dgdfh')
    node:playByIndex(0, 1)   
    node:update(0.01)
    node:stop()
    node:playByIndex(0, 1)
    local function animationCallback()
    	if flyFinishCallback then
    		flyFinishCallback()
    	end
    end
    node:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
 	node:setAnimationScale( 1.0 )
 	node:setScale(1.0)

 	local pos = self.ui:getChildByName('fourStarLocator4'):getPosition()

    node:setPosition(ccp( 747/2 - 200 , -530  ))
    self.ui:addChild(node)
	


end



function LevelSuccessTopPanel:createEmptyStar4Action()

	local actionArray_Star = CCArray:create()
	local actionArray_Bg = CCArray:create()

	local delayTime = 0.15
	local scale_Noemal = 0.9
	local scale_Big = 1.1

	local function setPos(  )
		for i=1,3 do
			local star = self.starRes[i]
			local starBg = self.starBgs[i]
			if star and starBg then
				local anPoint_X = star:getAnchorPoint().x
				local anPoint_y= star:getAnchorPoint().x
				local pos_X = star:getPositionX() 
				local pos_y = star:getPositionY()
				starBg:setAnchorPoint(ccp( anPoint_X , anPoint_y ) )
				starBg:setPosition(ccp( pos_X , pos_y ) )
			--	starBg:setVisible(false)
			end
		end
	end 

	

	for i=1,3 do
		local v = self.starRes[i]
		if v then

			local offset = (i - 2.5) * 10
			local rotate = CCRotateTo:create( delayTime ,   offset)

			local pos = self.ui:getChildByName('fourStarLocator'..i):getPosition()

			local targetPos = ccp(pos.x, pos.y)

			local actionArrayNode = CCArray:create()

			local scaleToBig = CCScaleTo:create( delayTime, scale_Big )

			local moveToLeft = CCMoveTo:create( delayTime , targetPos )
			local scaleTonormal = CCScaleTo:create( delayTime , scale_Noemal )

			local dely = CCDelayTime:create( 0.5 )

			actionArrayNode:addObject( dely )
			actionArrayNode:addObject(scaleToBig)

			local actionArrayNode_Spa = CCArray:create()
			actionArrayNode_Spa:addObject(moveToLeft)
			actionArrayNode_Spa:addObject(rotate)
			actionArrayNode_Spa:addObject( scaleTonormal )

			actionArrayNode:addObject( CCSpawn:create( actionArrayNode_Spa ) )
			actionArrayNode:addObject(scaleTonormal)


			local seq = CCSequence:create(actionArrayNode)
			local starAct = CCTargetedAction:create(v.refCocosObj, seq)
			actionArray_Star:addObject( starAct )
		end
	end

	for i=1,3 do
		local v = self.starBgs[i]
		if v then

			local offset = (i - 2.5) * 10
			local rotate = CCRotateTo:create( delayTime, offset)

			local pos = self.ui:getChildByName('fourStarLocator'..i):getPosition()

			local targetPos = ccp(pos.x, pos.y)

			local actionArrayNode = CCArray:create()

			local scaleToBig = CCScaleTo:create( delayTime, scale_Big )

			local moveToLeft = CCMoveTo:create( delayTime , targetPos )
			local scaleTonormal = CCScaleTo:create( delayTime  , scale_Noemal )

			local dely = CCDelayTime:create( 0.5 )

			actionArrayNode:addObject( dely )
			actionArrayNode:addObject(scaleToBig)

			local actionArrayNode_Spa = CCArray:create()
			actionArrayNode_Spa:addObject(moveToLeft)
			actionArrayNode_Spa:addObject(rotate)
			actionArrayNode_Spa:addObject( scaleTonormal )

			actionArrayNode:addObject( CCSpawn:create( actionArrayNode_Spa ) )
			actionArrayNode:addObject(scaleTonormal)


			local seq = CCSequence:create(actionArrayNode)
			local starAct = CCTargetedAction:create(v.refCocosObj, seq)
			actionArray_Bg:addObject( starAct )
		end
	end

	

	local function createEmptyStar4(  )
		if  self.spriteStar4 then
			 self.spriteStar4:setVisible(true)
		end


	end 

	if not self.spriteStar4 then

		local spriteStar4 = Sprite:createWithSpriteFrameName( "assets/1111/assetsreq/grtgret0000" )
		local pos = self.ui:getChildByName('fourStarLocator4'):getPosition()
		spriteStar4:setPosition(ccp(pos.x,pos.y))

		spriteStar4:setAnchorPoint(ccp(0.5 , 0.5))
		self.ui:addChild( spriteStar4 )
		local offset = (4 - 2.5) * 10
		spriteStar4:setRotation( offset )
		spriteStar4:setVisible(false)
		spriteStar4:setScale( 0 )

		self.spriteStar4 = spriteStar4
	end

	local scaleToBig = CCScaleTo:create( 0.2, scale_Big )
	local scaleToSmall = CCScaleTo:create( 0.2, scale_Noemal - 0.1 )
	local scaleToNormal = CCScaleTo:create( 0.2, scale_Noemal )

	local actionArrayNode_Scale = CCArray:create()
	actionArrayNode_Scale:addObject( scaleToBig )
	actionArrayNode_Scale:addObject( scaleToSmall )
	actionArrayNode_Scale:addObject( scaleToNormal )

	local seq_Scale = CCSequence:create( actionArrayNode_Scale )

	local starEMptyAct = CCTargetedAction:create( self.spriteStar4.refCocosObj, seq_Scale)

	local actionArray_Spawn = CCArray:create()

	local starAct = CCSpawn:create( actionArray_Star )
	local bgAct = CCSpawn:create( actionArray_Bg )
	
	local callFun = CCCallFunc:create( setPos )
	
	actionArray_Spawn:addObject( starAct )
	actionArray_Spawn:addObject( bgAct )


	local actionArray_Seq = CCArray:create()

	

	actionArray_Seq:addObject( callFun )
	actionArray_Seq:addObject(  CCSpawn:create( actionArray_Spawn )   )
	actionArray_Seq:addObject(  CCCallFunc:create( createEmptyStar4 ) )
	actionArray_Seq:addObject( starEMptyAct )


	return CCSequence:create( actionArray_Seq )
 
end