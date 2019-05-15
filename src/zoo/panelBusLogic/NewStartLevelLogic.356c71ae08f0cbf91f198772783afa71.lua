require "zoo.gamePlay.GamePlayContext"
require "zoo.scenes.NewGamePlaySceneUI"
require 'zoo.tempFunction.PreBuffLogic'

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê10ÔÂ28ÈÕ  19:18:09
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- NewStartLevelLogic
---------------------------------------------------
NewStartLevelLogic = class()

StartLevelCostEnergyType = {
	kEnergy = 1,
	kInfiniteEnergy = 2,
	kEnergyBottleSmall = 3,
	kEnergyBottleMiddle = 4,
}
-----------------------------------------------
-- startGameDelegate(Delegate) 所有方法均为optional
-- Delegate:onStartLevelLogicSuccess()
-- Delegate:onStartLevelLogicFailed(err)
-- Delegate:onEnergyNotEnough()		精力不足的处理
-- Delegate:playEnergyAnim(onAnimFinish, selectedItemsData) 播放精力消耗的动画
-- Delegate:onWillEnterPlayScene()	进入GamePlayScene之前执行的逻辑
-- Delegate:onDidEnterPlayScene(gamePlayScene)	进入GamePlayScene之后执行的逻辑
---------
-- notConsumeEnergy 是否消耗精力
-----------------------------------------------

function NewStartLevelLogic:create(startGameDelegate, levelId , itemList, notConsumeEnergy, usePropList, startLevelType, activityFlag, ...)
	assert(type(levelId) == "number")
	assert(type(itemList) == "table")
	assert(#{...} == 0)
	
	local newNewStartLevelLogic = NewStartLevelLogic.new()
	newNewStartLevelLogic:init(startGameDelegate, levelId , itemList, notConsumeEnergy, usePropList, startLevelType, activityFlag)
	return newNewStartLevelLogic
end


function NewStartLevelLogic:init(startGameDelegate, levelId , itemList, notConsumeEnergy, usePropList, startLevelType, activityFlag)
	LocalBox:initByStep0()
	self.replayMode     = ReplayMode.kNone
	self.levelId		= levelId
	self.levelType		= LevelType:getLevelTypeByLevelId(levelId)
	self.itemList		= itemList
	self.useInfiniteEnergy 	= false
	self.usePropList = usePropList or {}
	self.startLevelType = startLevelType or StartLevelType.kCommon
	self.activityFlag = activityFlag

	if self.startLevelType ~= StartLevelType.kAskForHelp then
		--处理可能相关的召回关卡需求
		self:pocessRecall()
		AskForHelpManager:getInstance():leaveMode()
	end

	self.notConsumeEnergy = notConsumeEnergy
	self.delegate = startGameDelegate or {}
end


function NewStartLevelLogic:isReplayMode()
	return self.replayMode and ( self.replayMode ~= ReplayMode.kNone )
end


function NewStartLevelLogic:pocessRecall()
	if RecallManager.getInstance():getRecallLevelState(self.levelId) then
		local winSize = CCDirector:sharedDirector():getWinSize()
		for i,v in ipairs(RecallManager.getInstance():getRecallItems()) do
			local itemData = {}
			itemData.id = v
			itemData.destXInWorldSpace = winSize.width/2 
			itemData.destYInWorldSpace = winSize.height/2
			itemData.isForRecall = true

			if not self:checkRecallItemDuplicate(v) then
				table.insert(self.itemList,itemData)
			end
		end
	end
end

function NewStartLevelLogic:checkRecallItemDuplicate(itemId)
	if self.itemList then 
		for i,v in ipairs(self.itemList) do
			if v.id == itemId then 
				return true
			end
		end
	end
	return false
end

function NewStartLevelLogic:startWithReplay( replayMode , replayData )
	self.replayMode = replayMode
	self.replayData = replayData
	self.sectionData = nil

	if replayData.sectionData then
		self.sectionData = replayData.sectionData
		replayData.sectionData = nil
		replayData.lastSectionData = nil
	elseif replayData.lastSectionData then
		self.sectionData = replayData.lastSectionData
		replayData.sectionData = nil
		replayData.lastSectionData = nil
	end

	GamePlayContext:getInstance():startLevel( self.levelId , self.levelType )
	GameInitBuffLogic:clearInitBuff()

	if self.replayMode == ReplayMode.kNormal or self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kConsistencyCheck_Step2 then

		if self.replayData.actContext then
			for k,v in pairs( self.replayData.actContext ) do
				if v == Thanksgiving2018CollectManager.getInstance():getReplayFlag() then
					Thanksgiving2018CollectManager.getInstance():setNextPlayShouldShowActCollectionForReplay( true )
				end
			end
		end
	end

    ------------------ spring
    local IsHaveSpringReplayData = false
    local IsUseSpringSkill = false
    if self.sectionData and self.sectionData.springFestival2019Data then 
        IsHaveSpringReplayData = self.sectionData.springFestival2019Data.CurIsActSkill or false
    end

    if replayData.replaySteps then
        for i,v in ipairs(replayData.replaySteps) do
            local params = string.split(v, ":")
			if params[1] == "p" then
                local SkillID = tonumber(params[2])
				if SkillID >= GamePropsType.kSpringSkill1 and SkillID <= GamePropsType.kSpringSkill4 then
                    IsUseSpringSkill = true
                    break
                end
            end
        end
    end

    if SpringFestival2019Manager.getInstance():isActivitySupportShowSkill( self.levelId, IsHaveSpringReplayData or IsUseSpringSkill ) then
        SpringFestival2019Manager.getInstance():beforeInGame(self.levelId)

        if self.sectionData and self.sectionData.springFestival2019Data then 
            SpringFestival2019Manager.getInstance():setByRevertData( self.sectionData.springFestival2019Data )
        end
    else
        SpringFestival2019Manager.getInstance():reset()
    end
    ------------------
    if TurnTable2019Manager.getInstance():isActivitySupportBeforeGame( self.levelId, self.startLevelType ) then
        TurnTable2019Manager.getInstance():beforeInGame(self.levelId)

        if self.sectionData and self.sectionData.TurnTable2019Data then 
            TurnTable2019Manager.getInstance():setByRevertData( self.sectionData.TurnTable2019Data )
        end
    else
        TurnTable2019Manager.getInstance():reset()
    end

	if self.replayData then
		if self.replayData.buffsV2 and #self.replayData.buffsV2 > 0 then
			GameInitBuffLogic:setFlag_isReplayAndHasBuff(true)
		end
		
		-- if self.replayData.buffsV3 and #self.replayData.buffsV3 > 0 then
		-- 	GameInitBuffLogic:setFlag_isReplayAndHasBuff(true)
		-- end

		if self.replayData.act5003Effctive then
			CollectStarsYEMgr.getInstance():setReplayFlag(true) 
		end
	end

	if self.replayData and self.replayData.ctx and self.replayData.ctx.scoreBuffBottleInitAmount then
		-- printx(11, "= = = Set replay initAmount ! ", self.replayData.ctx.scoreBuffBottleInitAmount)
		if self.replayData.ctx.scoreBuffBottleInitAmount > 0 then
			ScoreBuffBottleLogic:setScoreBuffAssetFlag()
		end
	end

	GamePlayContext:getInstance():onStartLevelMessageSuccessed( self.levelId , self.levelType )
	GamePlayContext:getInstance().replayModeWhenStart = replayMode
	GamePlayContext:getInstance().replayData = replayData

	self:startGamePlayScene()
end

function NewStartLevelLogic:start(popWaitTip, costType)
	Notify:dispatch("WillEnterPlaySceneEvent")
	
	if _G.isLocalDevelopMode then printx(0, "type:" .. type(popWaitTip)) end
	assert(type(popWaitTip) == "boolean")

	GamePlayContext:getInstance():startLevel( self.levelId , self.levelType )
	GameInitBuffLogic:clearInitBuff()
	GameInitBuffLogic:addBuffByTestFlag()

    if SpringFestival2019Manager.getInstance():isActivitySupportShowSkill( self.levelId ) then
        SpringFestival2019Manager.getInstance():beforeInGame(self.levelId,self.startLevelType)

        if PigYearLogic:bInitLogic() then 
            PigYearLogic:afterStartLevel(self.levelId)
        end
    else
        SpringFestival2019Manager.getInstance():reset()
    end

    if TurnTable2019Manager.getInstance():isActivitySupportBeforeGame( self.levelId ,self.startLevelType ) then
        TurnTable2019Manager.getInstance():beforeInGame(self.levelId)
    else
        TurnTable2019Manager.getInstance():reset()
    end

    --RecallA2019
    local isCanShowMission = RecallA2019Manager.getInstance():getCutLevelIsCanShowMission( self.levelId )
    RecallA2019Manager.getInstance():setActMission( isCanShowMission, self.levelId )

	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
		{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 1} , true , testStartLevelInfoFilterUids )
	-- -------------
	-- Check Energy
	-- ------------
	if self.notConsumeEnergy then -- don't need energy
		self:startLevelWithoutEnergy(popWaitTip)
		return
	end

	self.isAct5003Effective = false
	if CollectStarsYEMgr.getInstance():isBuffEffective(self.levelId) then
    	if self.delegate.ladybugAnim and not self.delegate.ladybugAnim.isDisposed then 
    		self.delegate.ladybugAnim:playDecreaseAnim()
    	end
    	self.isAct5003Effective = true
		self:startLevelWithoutEnergy(popWaitTip)
		return 
    end
	-- Get Energy State
	local energyState = UserEnergyRecoverManager:sharedInstance():getEnergyState()
	if energyState == UserEnergyState.INFINITE then
		self.useInfiniteEnergy = true
		self:startLevelWithoutEnergy(popWaitTip)
	elseif energyState == UserEnergyState.COUNT_DOWN_TO_RECOVER then
		self.useInfiniteEnergy = false
		self:startLevelWithEnergy(popWaitTip , costType)
	else
		assert(false)
	end
end

function NewStartLevelLogic:startLevelWithoutEnergy( popWaitTip )
	local function sendStartLevelMessage(callback)
		self:sendStartLevelMessage(popWaitTip, callback)
	end

	-- On Success
	local function onSendStartLevelMsgSuccess()
		self:onSendStartLevelMsgSuccess()
	end

	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
		{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 2} , true , testStartLevelInfoFilterUids )

	local chain = CallbackChain:create()
	chain:appendFunc(sendStartLevelMessage)
	chain:appendFunc(onSendStartLevelMsgSuccess)
	chain:call()
end

function NewStartLevelLogic:getStartLevelCostEnergyType()
	local user = UserManager:getInstance().user
	local currEnergy = user:getEnergy()
	local bottle_s_num = UserManager:getInstance():getUserPropNumber(10012)
	local bottle_m_num = UserManager:getInstance():getUserPropNumber(10013)
	local energyConsumedPerLevel = MetaManager.getInstance().global.user_energy_level_consume

	local costType = StartLevelCostEnergyType.kEnergy
	if currEnergy < energyConsumedPerLevel then
		if bottle_s_num >= energyConsumedPerLevel then
			costType = StartLevelCostEnergyType.kEnergyBottleSmall
		elseif bottle_m_num > 0 then
			costType = StartLevelCostEnergyType.kEnergyBottleMiddle
		else
			costType = StartLevelCostEnergyType.kEnergy
		end
	else
		costType = StartLevelCostEnergyType.kEnergy
	end

	return costType
end

function NewStartLevelLogic:startLevelWithEnergy( popWaitTip , costType )

	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
		{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 3} , true , testStartLevelInfoFilterUids )

	local energyConsumedPerLevel = MetaManager.getInstance().global.user_energy_level_consume
	assert(energyConsumedPerLevel)

	UserManager:getInstance():refreshEnergy()
	local curEnergy = UserManager.getInstance().user:getEnergy()
	assert(curEnergy)

	local function sendStartLevelMessage(callback)
		self:sendStartLevelMessage(popWaitTip, callback)
	end

	-- On Success
	local function onSendStartLevelMsgSuccess()
		-- Subtract The Energy
		if self.lastCostType == StartLevelCostEnergyType.kEnergy then
			local newEnergy = curEnergy - energyConsumedPerLevel
			UserManager.getInstance().user:setEnergy(newEnergy)
		else
			UserManager.getInstance().user:setEnergy(UserManager.getInstance().user:getEnergy() - energyConsumedPerLevel )
		end

		self:onSendStartLevelMsgSuccess()
	end


	local function doAddEnergy()
		GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 999} , true , testStartLevelInfoFilterUids )
		if self.delegate.onEnergyNotEnough then
			self.delegate:onEnergyNotEnough()
		end
	end

	local function doUseEnergyBottle( callback )

		local itemId = 10012

		local function __doUseEnergyBottle( itemId , callback)
			local logic = UseEnergyBottleLogic:create(itemId, DcFeatureType.kStageStart, DcSourceType.kEnergyUse)
			logic:setSuccessCallback(function () 
					if callback then callback() end
				end)
			logic:setFailCallback(function () doAddEnergy() end)
			logic:start(true)
		end

		if self.lastCostType == StartLevelCostEnergyType.kEnergyBottleMiddle then
			itemId = 10013
			__doUseEnergyBottle(itemId , callback)
		elseif self.lastCostType == StartLevelCostEnergyType.kEnergyBottleSmall then
			itemId = 10012
			local bottleNum = 0

			local function onDoUseEnergyBottleFin()
				bottleNum = bottleNum + 1
				if bottleNum >= energyConsumedPerLevel then
					if callback then callback() end
				else
					__doUseEnergyBottle(itemId , onDoUseEnergyBottleFin)
				end
			end

			__doUseEnergyBottle(itemId , onDoUseEnergyBottleFin)
		end
	end

	local function doStartLevel()
		GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 4} , true , testStartLevelInfoFilterUids )

		local chain = CallbackChain:create()
		chain:appendFunc(sendStartLevelMessage)
		chain:appendFunc(onSendStartLevelMsgSuccess)
		chain:call()
	end

	--if MaintenanceManager:getInstance():isEnabled("autoUseEnergyToStartLevel") and 
	-- if MaintenanceManager:getInstance():isEnabledInGroup( nil , "autoUseEnergyToStartLevel2" , UserManager:getInstance().uid) and 
	if true and 
		(costType == StartLevelCostEnergyType.kEnergyBottleMiddle or costType == StartLevelCostEnergyType.kEnergyBottleSmall) then
		
		self.lastCostType = costType
		doUseEnergyBottle( doStartLevel )
		DcUtil:clickAutoUseEnergyBottle(costType)
	else
		if curEnergy < energyConsumedPerLevel then
			self.lastCostType = StartLevelCostEnergyType.kEnergy
			doAddEnergy()
		else
			self.lastCostType = StartLevelCostEnergyType.kEnergy
			doStartLevel()
		end
	end
end

function NewStartLevelLogic:onSendStartLevelMsgSuccess()
	
	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
		{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 101} , true , testStartLevelInfoFilterUids )

	GamePlayContext:getInstance():onStartLevelMessageSuccessed( self.levelId , self.levelType )

	if self.delegate.onStartLevelLogicSuccess then
		self.delegate:onStartLevelLogicSuccess(self.useInfiniteEnergy)
	end	

	if not self.isAct5003Effective and not self.useInfiniteEnergy and self.delegate.playEnergyAnim then
		local function onEnergyConsumeAnimFinish()
			self:startGamePlayScene()
		end
		self.delegate:playEnergyAnim(onEnergyConsumeAnimFinish, self.itemList , self.lastCostType)
	else
		self:startGamePlayScene()
	end
end

function NewStartLevelLogic:sendStartLevelMessage(popWaitTip, onSuccessCallback, ...)
	assert(type(onSuccessCallback) == "function")
	assert(#{...} == 0)

	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
		{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 100} , true , testStartLevelInfoFilterUids )

	local levelId	= self.levelId
	local useInfiniteEnergy = self.useInfiniteEnergy
	local selectedItemIds = {}
	local videoAdItemIds = {}

	if self.itemList then
		--推送召回功能特殊处理
		local itemTable = {}
		if RecallManager.getInstance():getRecallLevelState(self.levelId) and self.startLevelType ~= StartLevelType.kAskForHelp then
			for k,v in pairs(self.itemList) do
				if not v.isForRecall then 
					table.insert(itemTable,v)
				end
			end
		else
			itemTable = self.itemList
		end

		for k,v in pairs(itemTable) do
			--特权特殊处理
			if not v.isPrivilegeFree then 
				table.insert(selectedItemIds, v.id)
			end

			if v.isVideoAd then
				table.insert(videoAdItemIds, v.id)
				DcUtil:adsIOSReward({
					sub_category = "get_reward",
					entry = EntranceType.kStartLevel,
					reward_id = v.id,
				})
			end
		end
	end

	local function onSuccess()
		if onSuccessCallback then onSuccessCallback() end

		-- 本地记录上一次进入关卡的时间
		local uid = UserManager.getInstance().uid
		local data = Localhost:readLocalLevelDataByLevelId(uid,levelId)
		data.lastEnterTime = Localhost:time()
		Localhost:writeLocalLevelDataByLevelId(uid,levelId,data)
	end

	local function onFailed(event)
		assert(event)
		assert(event.name == Events.kError)

		local err = event.data

		local errorMessage = "LevelInfoPanel:sendStartLevelMessage Failed !!\n"
		errorMessage = "errorMessage:" .. err
		if _G.isLocalDevelopMode then printx(0, errorMessage) end
		
		if self.delegate.onStartLevelLogicFailed then
			self.delegate:onStartLevelLogicFailed(err)
		end
	end

	for k, v in pairs(self.usePropList) do
		if ItemType:isTimeProp(v) then
			UserManager:getInstance():useTimeProp(v)
		else
			UserManager:getInstance():setUserPropNumber(v, UserManager:getInstance():getUserPropNumber(v) - 1)
		end
	end

	local prebuffGrade = 0
	local prebuffConfig = {}
	-- CommonTip:showTip(table.tostring(prebuffConfig))

	local http = nil
	if self.startLevelType == StartLevelType.kAskForHelp then
		http = AFHStartLevelHttp.new(popWaitTip)
		prebuffGrade = nil
	else

		if UserCallbackManager:getInstance():isActivitySupport() and 
            UserCallbackManager:getInstance():getCurHaveCallBackBuff() and 
			UserCallbackManager:getInstance():isTopLevel(levelId) and
			LevelType:isMainLevel(levelId) and not GameGuide:isNoPreBuffLevel(levelId) then

            local BuffLevel = 5 --默认给5级
            if UserCallbackManager:getInstance().buffStartLevel ~= 0 then
                --关卡BUFF
                local CanUseBuff, CanUseBuffLevel = UserCallbackManager:getInstance():getLevelCanUseBuff( levelId )

                BuffLevel = CanUseBuffLevel
            else
                --时间BUFF
                BuffLevel = UserCallbackManager:getInstance().buffTimeLevel
            end

            local UserCallbackBuffLogic = require 'zoo.tempFunction.UserCallbackBuffLogic'
            local buffGrade = 0
            local buffConfig = {}
			buffGrade, buffConfig = UserCallbackBuffLogic:getBuffGradeAndConfigByClassGrade(BuffLevel)
			if buffConfig and #buffConfig > 0 then
				-- GameInitBuffLogic:clearInitBuff()
				GameInitBuffLogic:addInitBuffs( buffConfig )
				GameInitBuffLogic:setAddBuffAnimeType(AddGameInitBuffAnimeType.kPreBuffActivity2017, buffGrade)
			end
			DcUtil:activity({category = 'UserCallback', sub_category = 'Buff_stage_start', t1 = buffGrade, t2 = GamePlayContext:getInstance():getIdStr()} )


		-- elseif (LevelType:isMainLevel(levelId) or LevelType:isHideLevel(levelId)) and not GameGuide:isNoPreBuffLevel(levelId) and PreBuffLogic:isActOn() then
		elseif PreBuffLogic:checkEnableBuff( levelId ) then
			prebuffGrade, prebuffConfig, description = PreBuffLogic:getBuffInfos()
			if prebuffConfig and #prebuffConfig > 0 then
				-- GameInitBuffLogic:clearInitBuff()
				GameInitBuffLogic:addInitBuffs( prebuffConfig )
				GameInitBuffLogic:setAddBuffAnimeType(AddGameInitBuffAnimeType.kPreBuffActivity2018, description)
			end
			DcUtil:activity({category = 'Buff', sub_category = 'Buff_stage_start', t1 = prebuffGrade, t2 = GamePlayContext:getInstance():getIdStr()} )
        elseif not GameGuide:isNoPreBuffLevel(levelId) and  DragonBuffManager:getInstance():InGame( levelId ) then
            --add dragonbuff 端午BUFF
            local DragonBuffInfo = DragonBuffManager:getInstance():getCurBuffLevelInGame()
            if DragonBuffInfo then

                local ConfigInfo = DragonBuffManager:getInstance():getBuffConfigByLevel( DragonBuffInfo[1] )
                for i,v in pairs(ConfigInfo.buff) do
                    GameInitBuffLogic:addInitBuff( { buffType = v } )
                end

                GameInitBuffLogic:setAddBuffAnimeType( AddGameInitBuffAnimeType.kDragonBuff2018, DragonBuffInfo[1] )
            end
		end

		if UserEnergyRecoverManager:sharedInstance():getEnergyState() == UserEnergyState.INFINITE then
			local actIds = {}
			for _, v in pairs(ActivityUtil:getActivitys()) do
			    if v.source then
			        local config = require ('activity/'..v.source)
			        table.insert(actIds, config.actId or 0)
			    end
			end
			actIds = table.concat(actIds, ',')
			DcUtil:UserTrack({category='stage', sub_category='level_start', t1 = GamePlayContext:getInstance():getIdStr(), t2 = actIds})
		end
		
		http = StartLevelHttp.new(popWaitTip)
	end

	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFailed)
	--http:addEventListener(Events.kError, onSuccess)
	
	if #videoAdItemIds > 0 then
		InciteManager:subCount( EntranceType.kStartLevel )
	end

	http:load(levelId, selectedItemIds, useInfiniteEnergy, self.levelType, self.usePropList, prebuffGrade, self.activityFlag, videoAdItemIds)

	
	
end

function NewStartLevelLogic:loadLevelConfig(onLoadFinish)
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>> self.levelId",self.levelId) end

	local createNewInstance = false

	local levelIdForConfig = self.levelId
	if self:isReplayMode() and self.replayData then
		createNewInstance = true	
		levelIdForConfig = self.replayData.meta_level or self.levelId
	end
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelIdForConfig , createNewInstance)
	if self:isReplayMode() and self.replayMode ~= ReplayMode.kResume and self.replayMode ~= ReplayMode.kSectionResume and self.replayMode ~= ReplayMode.kReview then
		--非kResume和kSectionResume的恢复模式 不会上传数据 这里强行改self.levelId为关卡实际id
		levelConfig.level = levelIdForConfig
	else
		levelConfig.level = self.levelId
	end

	local fileList , featureMap = levelConfig:getDependingSpecialAssetsList(self.levelType , self.replayMode)
	
	self.levelConfig = levelConfig
	self.featureMap = featureMap
	self.fileList = fileList
	
	GamePlayContext:getInstance().levelFeatureMap = self.featureMap
	
	local loader = FrameLoader.new()
	local function onFrameLoadComplete( evt )
		loader:removeAllEventListeners()
		if onLoadFinish then onLoadFinish() end
	end 

	for i,v in ipairs(fileList) do 
		loader:add(v, kFrameLoaderType.plist) end
	loader:addEventListener(Events.kComplete, onFrameLoadComplete)
	loader:load()
end

function NewStartLevelLogic:startGamePlayScene()
	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
		{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 102} , true , testStartLevelInfoFilterUids )
	
	local itemConsume = {}
	local itemFree = {}
	for i,v in ipairs(self.itemList) do
		if v.isPrivilegeFree then 
			table.insert(itemFree, v)
		else
			table.insert(itemConsume, v)
		end
	end
	GameInitBuffLogic:initWithSelectedPreItems(itemConsume)
	GameInitBuffLogic:initWithPrivilegePreItems(itemFree)

	local function onLevelConfigLoadFinish()
		GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 103} , true , testStartLevelInfoFilterUids )

		GamePlayContext:getInstance():onLevelConfigLoadFinish()

        if not self:isReplayMode() and self.delegate.onWillEnterPlayScene then 
        	self.delegate:onWillEnterPlayScene()
        end
        self:createGamePlayScene()
    end
    
    self:loadLevelConfig(onLevelConfigLoadFinish)
end

function NewStartLevelLogic:createGamePlayScene()

	GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelid = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 104} , true , testStartLevelInfoFilterUids )

	local runningScene = Director:sharedDirector():getRunningSceneLua()
	if runningScene and runningScene.name == "GamePlaySceneUI" then
		runningScene.disposResourceCache = false
		Director:sharedDirector():popScene(true, nil, true)
	end

	local function pushNewScene()

		local gamePlayScene	= nil
		local selectedItemsData = self.itemList or {}

		if self:isReplayMode() then
			selectedItemsData = self.replayData.selectedItemsData
			gamePlayScene = NewGamePlaySceneUI:createWithReplayData( self.levelConfig  , self.replayMode , self.replayData , self.sectionData )
		else
			selectedItemsData = self.itemList or {}
			gamePlayScene = NewGamePlaySceneUI:create(self.levelConfig , selectedItemsData)
		end

		self:removeWaitingPanel()

		assert(gamePlayScene)
		gamePlayScene.fileList = self.fileList --为了结束关卡时卸载资源
		--print("RRR   NewStartLevelLogic:createGamePlayScene  Director:sharedDirector():pushScene(gamePlayScene)")
		Director:sharedDirector():pushScene(gamePlayScene)

	    if self.delegate and self.delegate.onDidEnterPlayScene then 
	    	self.delegate:onDidEnterPlayScene(gamePlayScene)
	    end

	    if not self:isReplayMode() then
	    	if MissionManager then
				local triggerContext = TriggerContext:create(TriggerContextPlace.START_LEVEL_AND_CREATE_GAME_PLAY_SCENE)
				triggerContext:addValue( "data" , self )
				MissionManager:getInstance():checkAll(triggerContext)
			end
	    end

	    GamePlayContext:getInstance():onGamePlayScenePushed()

	    Notify:dispatch("AchiEventStartLevel", self.levelId, self.levelType)
	end

	if self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kQACheck then
		pushNewScene() --校验模式没有异步加载的资源，ResourceConfig.asyncPlist里的资源已被合并到ResourceConfig.plist同步加载
	else
		AsyncLoader:getInstance():waitingForLoadComplete(pushNewScene)
	end
	
end

function NewStartLevelLogic:addWaitingPanel()
	self.animation = nil
    local function onCloseButtonTap()
        if self.animation then
            self.animation:removeFromParentAndCleanup(true)
            self.animation = nil
        end
    end
    local scene = Director:sharedDirector():getRunningScene()
    self.animation = CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap)
end

function NewStartLevelLogic:removeWaitingPanel()
	if self.animation then
        self.animation:removeFromParentAndCleanup(true)
        self.animation = nil
    end
end

