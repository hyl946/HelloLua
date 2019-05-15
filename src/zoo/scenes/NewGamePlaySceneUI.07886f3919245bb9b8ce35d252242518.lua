require "zoo.scenes.GamePlaySceneUI"
require "zoo.scenes.NewGamePlayScene"
require "zoo.gamePlay.BoardLogic.GameInitDiffChangeLogic"
require "zoo.panel.endGameProp.WeekRaceEndGamePropPanel"
require "zoo.panel.endGameProp.MoleWeekRaceEndGamePropPanel"

local UserReviewLogic = require 'zoo.gamePlay.review.UserReviewLogic'

NewGamePlaySceneUI = class(GamePlaySceneUI)

function NewGamePlaySceneUI:create(levelConfig , selectedItemsData, ...)
	assert(type(levelConfig)			== "table")
	assert(type(selectedItemsData)		== "table")
	assert(#{...} == 0)

	local scene = NewGamePlaySceneUI.new()
	scene:init( levelConfig , selectedItemsData )

	return scene
end

function NewGamePlaySceneUI:isReplayMode()
	if self.replayMode and self.replayMode ~= ReplayMode.kNone then
		return true
	end

	return false
end


function NewGamePlaySceneUI:createWithReplayData( levelConfig , replayMode , replayData , sectionData )
	assert(tonumber(levelConfig.level) == tonumber(replayData.level) or tonumber(levelConfig.level) == tonumber(replayData.meta_level))

	local scene = NewGamePlaySceneUI.new()
	scene:initWithReplayData( levelConfig , replayMode , replayData , sectionData )

	return scene
end

function NewGamePlaySceneUI:getUsePropLog()
	if self.formatedReplaySteps then
		local results = {}
		if self.replayMode == ReplayMode.kResume 
			or self.replayMode == ReplayMode.kReview
		then 
			for k,v in ipairs(self.formatedReplaySteps) do
				if v.prop and v.pt ~= UsePropsType.TEMP and not ItemType:inPreProp(v.prop) and not ItemType:inTimePreProp(v.prop) then
					table.insert(results, v)
				end
			end
		elseif self.replayMode == ReplayMode.kStrategy then 
			for k,v in ipairs(self.formatedReplaySteps) do
				if v.prop and (v.pt ~= UsePropsType.TEMP or (v.pt == UsePropsType.TEMP and v.prop == ItemType.ADD_FIVE_STEP)) and
				 not ItemType:inPreProp(v.prop) and not ItemType:inTimePreProp(v.prop) then
					table.insert(results, v)
				end
			end
		end
		return results
	end

	return {}
end

function NewGamePlaySceneUI:initWithReplayData( levelConfig , replayMode , replayData , sectionData )
	
	self.replayMode = replayMode
	self.replayData = replayData
	self.sectionData = sectionData
	self.replayDataMD5 = HeMathUtils:md5( table.serialize( replayData ) )
	self.isCheckReplayScene = true

	--[[
	-- for test
	if self.replayData.replaySteps[4] then
		self.replayData.replaySteps[4] = "7,8:6,8"
	end
	]]
	--if self.replayData.replaySteps[1] then
		--self.replayData.replaySteps[1] = "7,8:6,8"
	--end

	--if self.replayData.replaySteps[23] then
		--self.replayData.replaySteps[23] = "p:10004:1:7,8:6,8"
	--end

	self.formatedReplaySteps = ReplayDataManager:formatReplaySteps(self.replayData.replaySteps, self.replayData.ver)
	
	local selectedItemsData = self.replayData.selectedItemsData
	levelConfig.randomSeed = self.replayData.randomSeed


	local propIds = {}
	if self.replayData.selectedItemsData then
		for _, v in pairs(self.replayData.selectedItemsData) do
			table.insert(propIds, tonumber(v.id))
		end
	end
	StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )
	StageInfoLocalLogic:initStageInfo( UserManager:getInstance().user.uid , levelConfig.level , propIds )

	if self.replayData.ctx then
		require "zoo.gamePlay.GamePlayContext"

		if self.replayMode ~= ReplayMode.kSectionResume then
			self.replayData.ctx.upl = nil
		end
		
		GamePlayContext:getInstance():decodeContextDataForReplay( self.replayData.ctx )
		IngamePropGuideManager:getInstance():setGuidedProp(GamePlayContext:getInstance():getGuidedProp())
	end
	if self.replayData.ndCtx then
		require "zoo.gamePlay.GamePlayContext"
		GamePlayContext:getInstance():decodeNationDayData( self.replayData.ndCtx )
	end

	if type(self.replayData.rankRaceCtx) == 'table' then
		RankRaceMgr:getInstance():setLevelIndex(self.replayData.rankRaceCtx.levelIndex or 1)
	end

	-- if self.replayData.ftwData then
		-- FTWLocalLogic:setDataForRevert(self.replayData.ftwData)
	-- end

	self:init( levelConfig , selectedItemsData )

	if self.replayMode == ReplayMode.kResume 
		or self.replayMode == ReplayMode.kReview
	then
		local usePropLog = self:getUsePropLog()
		for k,v in ipairs(usePropLog) do
			self.propList:addFakeItemForReplay(v.prop, 1, 0)
		end
	elseif self.replayMode == ReplayMode.kSectionResume then
		--do nothing
	elseif self.replayMode == ReplayMode.kStrategy then 
		self.propList:addFakeAllProp(0)
		local usePropLog = self:getUsePropLog()
		local addStepShow = false 
		for k,v in ipairs(usePropLog) do
			if v.prop == ItemType.ADD_FIVE_STEP and not addStepShow then 
				self.propList:showAddStepItem(true)
				addStepShow = true
			end
			self.propList:addFakeItemForReplay(v.prop, 1, 0)
		end
	else
		self.propList:addFakeAllProp(999)
	end
	
	local _isConsistencyCheck = false

	if self.replayMode == ReplayMode.kConsistencyCheck_Step1 
		or self.replayMode == ReplayMode.kConsistencyCheck_Step2 then
		_isConsistencyCheck = true
	end

	if self.replayMode == ReplayMode.kCheck 
		or self.replayMode == ReplayMode.kQACheck 
		or self.replayMode == ReplayMode.kConsistencyCheck_Step1
		then

		if _isConsistencyCheck then
			GameSpeedManager:changeSpeedForCrashResumePlay()
		end
		
		local function onReplayErrorOccurred(evt)
			local errorData = evt and evt.data or nil
			if errorData and errorData.msg == "use_prop_error" then
				self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kUsePropError, errorData)
			else
				self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kSwapFail, errorData)
			end

			if self.replayMode == ReplayMode.kConsistencyCheck_Step1 then
				ReplayAutoCheckManager:outputResult( false , datas )
			elseif self.replayMode == ReplayMode.kConsistencyCheck_Step2 then
				local currSectionDatas = SectionResumeManager:getCurrSectionDatas()
				ReplayAutoCheckManager:setSectionDataInStepTwo( currSectionDatas )
				local result , datas = ReplayAutoCheckManager:compareResult()
				ReplayAutoCheckManager:outputResult( false , datas )
			end
			
		end
		self:ad("replay_error", onReplayErrorOccurred)

		if CheckPlayCrashListener then
			GlobalEventDispatcher:getInstance():removeEventListener("lua_crash", CheckPlayCrashListener)
			CheckPlayCrashListener = nil
		end
		CheckPlayCrashListener = function(evt)
			self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kCrash, {msg="lua_crash"})
		end
		GlobalEventDispatcher:getInstance():addEventListener("lua_crash", CheckPlayCrashListener)
	elseif self.replayMode == ReplayMode.kAutoPlayCheck or self.replayMode == ReplayMode.kConsistencyCheck_Step2 then

		if self.replayData.addSpeed then
			GameSpeedManager:changeSpeedForCrashResumePlay()
		end
		
		if CheckPlayCrashListener then
			GlobalEventDispatcher:getInstance():removeEventListener("lua_crash", CheckPlayCrashListener)
			CheckPlayCrashListener = nil
		end
		CheckPlayCrashListener = function(evt)

			if evt and evt.data and evt.data.errorMsg then
				AutoCheckLevelManager:onCheckFinish( false , AutoCheckLevelFinishReason.kLuaCrash ,  self.gameBoardLogic.realCostMove , evt.data.errorMsg )
			else
				AutoCheckLevelManager:onCheckFinish( false , AutoCheckLevelFinishReason.kLuaCrash ,  self.gameBoardLogic.realCostMove )
			end

			self:endReplay()

			AutoCheckLevelManager:nextCheck()

		end
		GlobalEventDispatcher:getInstance():addEventListener("lua_crash", CheckPlayCrashListener)

	elseif self.replayMode == ReplayMode.kResume then

		local function logreplay()
			local tableStr = table.serialize( self.replayData )
			local datastr = HeMathUtils:base64Encode(tableStr, string.len(tableStr)) 
			local currTime = tostring( os.date( "%x" , Localhost:timeInSec() ) ) .. " " .. tostring( os.date( "%X" , Localhost:timeInSec() ) )
			local hasUseProp = false
			for i = 1 , #self.formatedReplaySteps do
				if self.formatedReplaySteps[i].prop then
					hasUseProp = true
					break
				end
			end

			DcUtil:uploadReplayData( "ReplayErrorUpload" , 
					datastr , 
					nil , nil , 
					self.levelId , nil , 
					self.gameBoardLogic.totalScore , 
					currTime , nil ,
					{ costMove = self.gameBoardLogic.realCostMove , useProp = hasUseProp }
				)
		end

		local function onReplayErrorOccurred(evt)
			if self.gameBoardLogic and not self.gameBoardLogic.replaying then
				return
			end

			local errorData = evt and evt.data or nil
			local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"

			if errorData then
				if errorData.msg == "use_prop_error" then
					DcUtil:crashResumeEnd( 2 , self.levelId , self.gameBoardLogic.replayStep , 
						UserManager.getInstance().user.uid , udid , self.replayData.uid , self.replayData.udid , self.replayDataMD5)--道具使用错误，恢复结束
					--pcall( logreplay )
					self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kUsePropError, errorData)
				elseif errorData.msg == "swap_fail" then
					DcUtil:crashResumeEnd( 1 , self.levelId , self.gameBoardLogic.replayStep , 
						UserManager.getInstance().user.uid , udid , self.replayData.uid , self.replayData.udid , self.replayDataMD5)--交换失败，恢复结束
					if math.random() >= 0.9 then 
						pcall( logreplay )
						--logreplay()
					end
					--self:removeEventListenerByName("replay_error")
					self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kSwapFail, errorData)
				else
					DcUtil:crashResumeEnd( 5 , self.levelId , self.gameBoardLogic.replayStep , 
						UserManager.getInstance().user.uid , udid , self.replayData.uid , self.replayData.udid , self.replayDataMD5)--道具使用错误，恢复结束
					--pcall( logreplay )
					self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kSwapFail, errorData)
				end
			end
		end
		self:ad("replay_error", onReplayErrorOccurred)

		if CrashResumeGamePlaySpeedUp then
			GameSpeedManager:changeSpeedForCrashResumePlay()
		end
	elseif self.replayMode == ReplayMode.kMcts then

		--[[
		local function onReplayErrorOccurred(evt)
			if self.gameBoardLogic and not self.gameBoardLogic.replaying then
				return
			end

			local errorData = evt and evt.data or nil
			local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"

			if errorData then
				if errorData.msg == "use_prop_error" then
					self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kUsePropError, errorData)
				elseif errorData.msg == "swap_fail" then
					self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kSwapFail, errorData)
				else
					self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kSwapFail, errorData)
				end
			end
		end

		self:ad("replay_error", onReplayErrorOccurred)
		]]

		if CheckPlayCrashListener then
			GlobalEventDispatcher:getInstance():removeEventListener("lua_crash", CheckPlayCrashListener)
			CheckPlayCrashListener = nil
		end
		CheckPlayCrashListener = function(evt)
			self:onReplayErrorOccurred(CheckPlay.RESULT_ID.kCrash, {msg="lua_crash"})
		end
		GlobalEventDispatcher:getInstance():addEventListener("lua_crash", CheckPlayCrashListener)

	elseif self.replayMode == ReplayMode.kAuto then
		GameSpeedManager:changeSpeedForCrashResumePlay()
	end

	self.gameBoardLogic.replaySteps = self.formatedReplaySteps

	self.gameBoardLogic:ReplayStart(self.replayMode)
	

	self.gameBoardLogic:onGameInit()

	--[[
	if self.replayMode ~= ReplayMode.kResume then
		self.gameBoardLogic:setWriteReplayOff()
	end
	]]
	
	--self.gameBoardLogic.dragonBoatData = self.replayData.dragonBoatData
	--self.gameBoardLogic.summerWeeklyData = self.replayData.summerWeeklyData

	if self.replayMode == ReplayMode.kSnapshot then
		CheckPlay:loadLocalReplaySS()
		self.gameBoardLogic:setSnapshotModeEnable()
	end

	GamePlayMusicPlayer:getInstance():playGameSceneBgMusic()
end

--function NewGamePlaySceneUI:init(levelId, levelType, selectedItemsData, gamePlaySceneUiType,  ...)
function NewGamePlaySceneUI:init( levelConfig , selectedItemsData, gamePlaySceneUiType,  ... )

	self.levelConfig = levelConfig

	local levelId = levelConfig.level
	local levelType = LevelType:getLevelTypeByLevelId(levelId)
	self.levelId		= levelId
	self.levelType 		= levelType

	if _G.AutoCheckLeakInLevel then
		self.autoCheckLeakTag = tostring(os.time())
		startObjectRefDebug(self.autoCheckLeakTag, self.levelId)
	end

	--2017元宵节
	-- _G.IS_PLAY_YUANXIAO2017_LEVEL = LevelType:isYuanxiao2017Level(levelId)

	_G.IS_PLAY_NATIONDAY2017_LEVEL = (self.levelType == GameLevelType.kSpring2017)
	-- if _G.IS_PLAY_NATIONDAY2017_LEVEL then
	-- 	local val = self.levelId - LevelConstans.SPRING2018_LEVEL_ID_START
	-- 	local type = (math.floor(val/3) + 1) % 6
	-- 	if type == 0 then type = 6 end
	-- 	require "zoo.modules.spring2018.TileCoinLikeA"
	-- 	_G.SPRING2018_COLLECTION_TYPE = type
	-- end

	--------------
	--- Init Base Class
	------------------
	Scene.initScene(self)
	self.gamePlaySceneUiType = gamePlaySceneUiType or GamePlaySceneUIType.kNormal
	-------------
	--- Get Data
	--------------
	
	GamePlaySceneSkinManager:initCurrLevel(levelType)
	self.levelSkinConfig = GamePlaySceneSkinManager:getConfig(levelType)

	local function convertTimePropToRealId(data)
		local ret = {}
		for k, v in pairs(data) do
			local item = {}
			for x, y in pairs(v) do
				item[x] = y
			end
			item.propId = v.id
			item.id = ItemType:getRealIdByTimePropId(v.id)
			item.isPrivilegeFree = v.isPrivilegeFree
			table.insert(ret, item)
		end
		return ret
	end


	self.selectedItemsData		= convertTimePropToRealId(selectedItemsData)

	self.name			= "GamePlaySceneUI"
	self.gameInit = false

	self.disposResourceCache = true          ------是否在游戏结束时删除缓存的贴图 ，replay的时候置为false

	he_log_warning("use MetaModel, replace it with MetaManager !")
	self.metaModel			= MetaModel:sharedInstance()
	self.metaManager		= MetaManager.getInstance()

	self.levelModeTypeId 		= self.metaModel:getLevelModeTypeId(self.levelId)
	assert(self.levelModeTypeId)
	self.curLevelScoreTarget 	= MetaModel:sharedInstance():getLevelTargetScores(self.levelId)


	assert(self.curLevelScoreTarget)
	assert(self.curLevelScoreTarget[1])
	assert(self.curLevelScoreTarget[2])
	assert(self.curLevelScoreTarget[3])

	-- ------------------
	-- Data About Level
	-- -------------------

	self.levelModeType = self.levelConfig.gameMode
	assert(self.levelModeType)
	self.gamePlayType = LevelMapManager.getInstance():getLevelGameModeByName(self.levelConfig.gameMode)

	-- if _G.IS_PLAY_NATIONDAY2017_LEVEL then
	-- 	require "zoo.modules.nation2017.NationDay2017Files"
	-- 	NationDay2017Animations:loadRes()
	-- end

	-- Time Limit
	self.timeLimit = false
	self.moveLimit = false
	if self.levelModeType == GameModeType.CLASSIC then
		self.timeLimit = tonumber(self.levelConfig.timeLimit)
		self.moveOrTimeCount = tonumber(self.levelConfig.timeLimit)
		assert(self.timeLimit)
	else

		if self.gamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID then
			self.moveLimit = RabbitWeeklyConfig.stageInitEnd
			self.moveOrTimeCount = RabbitWeeklyConfig.stageInitEnd
		else
			-- Move Step Limit
			self.moveLimit = tonumber(self.levelConfig.moveLimit)
			self.moveOrTimeCount = tonumber(self.levelConfig.moveLimit)
			assert(self.moveLimit)
		end
	end

	--- Other Data
	local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local winSize = CCDirector:sharedDirector():getWinSize()
	
	local realVisibleOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
	local realVisibleSize = CCDirector:sharedDirector():ori_getVisibleSize()

	---------------
	--- Create UI
	----------------

	-- Background
	local centerPos = ccp(realVisibleOrigin.x + realVisibleSize.width/2, realVisibleOrigin.y + realVisibleSize.height/2)
	local game_bg = nil
	if self.gamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then -- levelType == GameLevelType.kMayDay 
		require('zoo.scenes.component.gameplayScene.ChildrensDayGameBg')
		game_bg = ChildrensDayGameBg:create()
		game_bg:setPosition(ccp(0, visibleOrigin.y + visibleSize.height))
		game_bg:startScrollForever(10)
	elseif self.gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		require "zoo.modules.autumn2018.ZQResourceManager"
		ZQResourceManager:loadGameResources()
		require('zoo.modules.autumn2018.ZQGameBg')
		game_bg = ZQGameBg:create()
		game_bg:setPosition(centerPos)
	elseif self.levelType == GameLevelType.kSummerWeekly then
		require('zoo.scenes.component.gameplayScene.ScrollGameBg')
		game_bg = WeeklyScrollGameBg_H:create()
		-- game_bg:setPositionX(visibleOrigin.x + (visibleSize.width - game_bg:getWidth()) / 2)
		game_bg:setPosition(centerPos)
		-- game_bg:startScrollForever(100)
	elseif self.levelType == GameLevelType.kSpring2017 then
		game_bg = Sprite:createWithSpriteFrameName(self.levelSkinConfig.gameBG)
		local scale = realVisibleSize.height / (1280 * visibleSize.width / 720)
		game_bg:setScale(math.max(scale, 1))
		game_bg:setPosition(centerPos)
    elseif self.levelType == GameLevelType.kMoleWeekly then
		game_bg = Sprite:createWithSpriteFrameName(self.levelSkinConfig.gameBG)
		game_bg:setPosition(ccp(centerPos.x,centerPos.y))

        --获取棋盘最上边位置
        local upBg =  Sprite:createWithSpriteFrameName(self.levelSkinConfig.gameupBG)
        upBg:setAnchorPoint( ccp(0.5,0))
		upBg:setPosition(ccp(960/2,0))
        game_bg:addChild( upBg)
        game_bg.upBg = upBg

        local downBg =  Sprite:createWithSpriteFrameName(self.levelSkinConfig.gameDownBG)
        downBg:setAnchorPoint( ccp(0.5,0))
		downBg:setPosition(ccp(960/2,32))
        game_bg:addChild( downBg)
--    elseif self.levelType == GameLevelType.kJamSperadLevel then
--        game_bg = Sprite:createWithSpriteFrameName(self.levelSkinConfig.gameBG)
--		local scale = realVisibleSize.height / (1280 * visibleSize.width / 720)
--		game_bg:setScale(math.max(scale, 1))
--		game_bg:setAnchorPoint( ccp(0.5,0))
--		game_bg:setPosition(ccp(720/2,0))
	else 
		local gradients = {
			{startColor="1059BD", endColor="1488D2", height=300},
			{startColor="1488D2", endColor="1386D2", height=300},
			{startColor="1386D2", endColor="69EAEF", height=1200},
		}
		local gradientBg = NewGamePlaySceneUI:buildBackgroundLayer(gradients)
		self:addChild(gradientBg)

		game_bg = Sprite:createWithSpriteFrameName(self.levelSkinConfig.gameBG)
		-- 1440 适配背景图
		local scale = realVisibleSize.height / (1559 * visibleSize.width / 720)
		game_bg:setAnchorPoint(ccp(0.5, 0))
		game_bg:ignoreAnchorPointForPosition(false)
		game_bg:setScale(math.max(scale, 1))
		game_bg:setPosition(ccp(centerPos.x, 0))
	end
	
	self.gameBgNode = game_bg
	self:addChild(game_bg)

	if LevelType:isNationalDayLevel(self.levelId)
		and self.gamePlaySceneUiType == GamePlaySceneUIType.kNormal then
		-- local snowBg = SnowFlyAnimation:create()
		-- self:addChild(snowBg)
		-- snowBg:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
	end
	
	

	--------------------------------
	--  bossLowerLayer
	--------------------------------

	local bossLowerLayer = CocosObject:create()
	self.bossLowerLayer = bossLowerLayer
	self:addChild(bossLowerLayer)


	-- ------------------------
	-- Create Game Play Scene
	-- ------------------------
	local forceUseDropBuff = false
	if self.gamePlaySceneUiType == GamePlaySceneUIType.kReplay then
		if self.replayRecords and self.replayRecords.hasDropBuff then
			forceUseDropBuff = true
		end
	end

	local gamePlayScene	= self:createGamePlayScene(self.levelId, self.gamePlaySceneUiType, self.levelType, forceUseDropBuff)
	self.gamePlayScene	= gamePlayScene
	self:addChild(gamePlayScene)

	local gameBoardLogic = gamePlayScene.mygameboardlogic

	-- 传过去的道具id不带限时道具，不然每次都要转id就很麻烦
	gameBoardLogic.selectedItemsData = self.selectedItemsData

	self.gameBoardLogic = gameBoardLogic
	local gameBoardView = gamePlayScene.mygameboardview
	self.gameBoardView = gameBoardView
	assert(gameBoardLogic)


	gameBoardLogic.PlayUIDelegate = self
	gameBoardView.PlayUIDelegate = self

	self:checkGuideContext()

	self:initTopArea()

--    local bossLowerLayer = CocosObject:create()
--	self.bossLowerLayer = bossLowerLayer
--	self:addChild(bossLowerLayer)



    --boss Layer
    local bossLayer = CocosObject:create()
	self.bossLayer = bossLayer
	self:addChild(bossLayer)



	-- 分数星星飞行效果
	self.scoreStarsBatch = CocosObject:create()
	self.scoreStarsBatch:setRefCocosObj(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/scenes/flowers/home_effects.png"), 200));
	self:addChild(self.scoreStarsBatch)

	local effectLayer = CocosObject:create()
	self.effectLayer = effectLayer
	self:addChild(effectLayer)

	local otherElementsLayer = CocosObject:create()
	self.otherElementsLayer = otherElementsLayer
	self:addChild(otherElementsLayer)


	-- Format For Used By PropListAnimation
	-- Example Format
	--{
	--	{itemId=10001, itemNum=1, temporary=0},
	--	{itemId=10003, itemNum=3, temporary=1},
	--},
	PropsModel.instance():init(self.levelId, self.levelType, self.selectedItemsData, gameBoardLogic:hasItemOfType(GameItemType.kPoisonBottle), self.sectionData)
	-- -----------
	-- Prop List
	-- -----------

	self.propList = PropListAnimation:create(self.levelId, self.levelModeType, self.levelType, self.gameBoardView, self.replayMode or ReplayMode.kNone)
	-- self.propList:setLevelModeType(self.levelModeType)


    --游戏类道具列表
    local SkillProps = PropsModel.instance().addToBarProps
	self.propList:show(SkillProps)
	self:addChild(self.propList.layer)

	local function usePropCallback(propId, usePropType, expireTime,isRequireConfirm, isGuideRefresh, noGuide, ...)
		assert(type(propId) == "number")
		assert(type(usePropType) == "number")
		assert(type(isRequireConfirm) == "boolean")
		assert(#{...} == 0)
		return self:usePropCallback(propId, usePropType, expireTime, isRequireConfirm, isGuideRefresh, noGuide, ...)
	end

	local function cancelPropUseCallback(propId,confirm, ...)
		assert(type(propId) == "number")
		assert(#{...} == 0)
		self:cancelPropUseCallback(propId, confirm)
	end

	local function buyPropCallback(propId, ...)
		assert(type(propId) == "number")
		assert(#{...} == 0)

		if table.includes({
			ItemType.ADD_15_STEP,
			ItemType.ADD_1_STEP,
			ItemType.ADD_2_STEP,
		}, propId) then
			return
		end

		self:buyPropCallback(propId)
	end

	local function helpCallback( ... )
		local panel = PropInfoPanel:create(2, self.levelId,gameBoardLogic)
    	if panel then
    		self:pause()
    		panel:setExitCallback(function( ... )
    			self:continue()
    		end)
    		panel:popout() 
    	end
	end

	self.propList.controller:registerUsePropCallback(usePropCallback)
	self.propList.controller:registerCancelPropUseCallback(cancelPropUseCallback)
	self.propList.controller:registerBuyPropCallback(buyPropCallback)
	self.propList.controller:registerSpringItemCallback(function (notUseEnergy, noReplayRecord) 
			self:useSpringItemCallback(notUseEnergy, noReplayRecord) 
		end)
	self.propList.controller:registerHelpCallback(helpCallback)

	local levelTargetLayer 	= CocosObject:create()
	self.levelTargetLayer	= levelTargetLayer
	self:addChild(levelTargetLayer)

	local extandLayer = CocosObject:create()
	self.extandLayer = extandLayer
	self:addChild(extandLayer)

	local topEffectLayer = CocosObject:create()
	self.topEffectLayer = topEffectLayer
	self:addChild(topEffectLayer)

	local gamePlayPopoutLayer = CocosObject:create()
	self.gamePlayPopoutLayer = gamePlayPopoutLayer
	self:addChild(gamePlayPopoutLayer)

	local guideLayer = CocosObject:create()
	self.guideLayer = guideLayer
	self:addChild(guideLayer)

	local wSize = Director:sharedDirector():getWinSize()
	self.mask = LayerColor:create()
	self.mask:changeWidthAndHeight(wSize.width, wSize.height)
	self.mask:setOpacity(0)
	self.mask:setPosition(ccp(0, 0))
	self.mask:setTouchEnabled(true, 0, true)
	self:addChild(self.mask)
	
	------------------------
	-- Get Data About Level Target
	-- --------------------------
	local orderList		= gameBoardLogic.theOrderList
	assert(orderList)

	self.targetType = false

	local function onTimeModeStart()
		self:onTimeModeStart()
	end

	---------------------
	-- Register Script Handler
	-- ---------------------
	local function onEnterHandler(event)
		self:onEnterHandler(event)
	end
	self:registerScriptHandler(onEnterHandler)

	self.useItem = false

	if StartupConfig:getInstance():isLocalDevelopMode() then
	    -- 掉落逻辑调试信息显示
		if gameBoardLogic.dropBuffLogic and gameBoardLogic.dropBuffLogic.canBeTriggered then
			-- dropBuffLogic debug panel
			self:addDropStatDisplayLayer()
		end
	end

	if self.gamePlayType == GameModeTypeId.HALLOWEEN_ID then
		GamePlaySceneDecorator:decoSceneForBossBee(self)
	elseif self.gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
        GamePlaySceneDecorator:decoSceneForBG(self)
		GamePlaySceneDecorator:decoSceneForBossBee(self)
	elseif self.gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		ZQPlaySceneDecorator:decoPlayScene(self)
	elseif self.gamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
		NationDay2017PlaySceneDecorator:decoPlayScene(self)
    end

	-- if FTWLocalLogic:isFTWEnabled() then
		-- local FindingTheWayGamePlaySceneDecorator = require 'zoo.localActivity.FindingTheWay.FindingTheWayGamePlaySceneDecorator'
		-- FindingTheWayGamePlaySceneDecorator:decoPlayScene(self)
	-- end

	
	FUUUManager:onGameStart(self.levelId)
	local totalPlayed = FUUUManager:getLevelTotalPlayed(self.levelId)
	local preItems = {}
	if selectedItemsData and #selectedItemsData then
		for _, v in pairs(selectedItemsData) do
			table.insert(preItems, tonumber(v.id))
		end
	end
	local hasDropBuff = gameBoardLogic.dropBuffLogic and gameBoardLogic.dropBuffLogic.canBeTriggered or false
	DcUtil:logStageStart(self.levelId, totalPlayed, preItems, hasDropBuff)

	if _G.__testPropGuide then
		self:initTestGuideBtn()
	end
end

function NewGamePlaySceneUI:addChild(child, layer)
	if layer and layer == SceneLayerShowKey.POP_OUT_LAYER then
		self.gamePlayPopoutLayer:addChild(child)
	else
		Scene.addChild(self, child)
	end
end

function NewGamePlaySceneUI:checkGuideContext()
	local gameContext = GamePlayContext:getInstance()
	local guideContext = gameContext:getGuideContext()

	if self:isReplayMode() then

		return
	end

	if self.gamePlayScene.allowRepeatGuide then --关卡启动时有引导，且已经引导过

		if (not self.selectedItemsData or #self.selectedItemsData == 0) --进关卡没有带前置道具
			and not (GameInitBuffLogic:hasAnyInitBuffIncludedReplay() 
						or ScoreBuffBottleLogic:hasScoreBuffBottleInLevel()) --进关卡没有带buff & 没有刷星
			then
			--有引导的关卡，且允许显示“重复引导按钮”
			guideContext.showRepeatGuideButton = true
		else
			--有引导的关卡，且不显示“重复引导”按钮
			guideContext.showRepeatGuideButton = false
		end

		-- if FTWLocalLogic:isFTWEnabled() then
			-- guideContext.showRepeatGuideButton = false
		-- end

	end

	--如果self.gamePlayScene.allowRepeatGuide = false，则需要计算出第几步可以丢buff

	local maxMoves = -1
	for k , v in pairs( Guides ) do
		if v.appear then

			local levelIdMatched = false
			local numMoves = -1

			for k1 , v1 in pairs(v.appear) do

				if v1.type == "scene" and v1.scene == "game" and v1.para == self.levelId then
					levelIdMatched = true
					if numMoves ~= -1 then break end
				elseif v1.type == "numMoves" then
					numMoves = v1.para
					if levelIdMatched then break end
				end
			end

			if levelIdMatched then
				if numMoves > maxMoves then
					maxMoves = numMoves
				end
			end
		end
	end

	guideContext.lastGuideStep = maxMoves

	-- printx( 1,  "guideContext ======================================= " , table.tostring(guideContext))
	
end

-- 创建多重渐变色的天空背F景
function NewGamePlaySceneUI:buildBackgroundLayer(gradients)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local winHeight = winSize.height
	local winWidth = winSize.width
	local bgLayer = Layer:create()
	bgLayer:setContentSize(CCSizeMake(winWidth, winHeight))

	local offsetPosY = 0
	for index = #gradients, 1, -1 do
		local gradient = gradients[index]
		local layerHeight = gradient.height
		if layerHeight > 0 then
			if index == 1 and offsetPosY + layerHeight < winHeight then
				layerHeight = winHeight - offsetPosY
			end
			local lg = LayerGradient:createWithColor(hex2ccc3(gradient.startColor), hex2ccc3(gradient.endColor))
			lg:changeWidthAndHeight(winWidth, layerHeight+1) -- +1让最后一个像数与下一个渐变的第一个像数重合
			lg:setPosition(ccp(0, offsetPosY))
			bgLayer:addChild(lg)

			offsetPosY = offsetPosY + layerHeight
		end
		if offsetPosY >= winHeight then
			break
		end
	end
	return bgLayer
end

function NewGamePlaySceneUI:initTestGuideBtn()
	local counter = 1
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local function buildBtn(text, func)
		local width, height = 48, 50
		local posX = vo.x + 0 + (counter - 1) * width
		local posY = vo.y+vs.height-100
		local btn = LayerColor:create()
		btn:setColor(ccc3(255/counter, 0, 0))
		btn:ignoreAnchorPointForPosition(false)
		btn:setContentSize(CCSizeMake(width, height))
		btn:setAnchorPoint(ccp(0, 1))
		btn:setPosition(ccp(posX, posY))
		btn:setTouchEnabled(true,0,true)
		btn:ad(DisplayEvents.kTouchTap, func)
		local t = TextField:create(tostring(text))
		t:setScale(1.5)
		btn:addChild(t)
		t:setPositionY(30)
		t:setAnchorPoint(ccp(0, 1))
		self:addChild(btn)

		counter = counter + 1
	end
	local function showHammer()
		IngamePropGuideManager:getInstance():tryTriggerHammer()
		GameGuideData:sharedInstance():setGuideIndex(500010101)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end

	buildBtn('锤子\n强', showHammer)
	-- buildBtn('锤子\n弱', function() 
	-- 	GameGuideData:sharedInstance():setGuideIndex(5000101011)
	-- 	GameGuideData:sharedInstance():setActionIndex(1)
	-- 	GameGuideRunner:runGuide(paras)
	-- end)
	buildBtn('豆荚', function() 
		IngamePropGuideManager:getInstance():tryTriggerForceSwapIngredient()
		GameGuideData:sharedInstance():setGuideIndex(5000101021)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	buildBtn('特效', function() 
		IngamePropGuideManager:getInstance():tryTriggerForceSwapSpecial()
		GameGuideData:sharedInstance():setGuideIndex(500010102)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	-- buildBtn('交换\n弱', function() 
	-- 	GameGuideData:sharedInstance():setGuideIndex(5000101022)
	-- 	GameGuideData:sharedInstance():setActionIndex(1)
	-- 	GameGuideRunner:runGuide(paras)
	-- end)
	buildBtn('刷新\n强', function() 
		GameGuideData:sharedInstance():setGuideIndex(5000101001)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	buildBtn('刷新\n弱', function() 
		GameGuideData:sharedInstance():setGuideIndex(500010100)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	buildBtn('刷子\n强', function() 
		IngamePropGuideManager:getInstance():tryTriggerBrush()
		GameGuideData:sharedInstance():setGuideIndex(500010103)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	-- buildBtn('刷子\n弱', function() 
	-- 	GameGuideData:sharedInstance():setGuideIndex(5000101031)
	-- 	GameGuideData:sharedInstance():setActionIndex(1)
	-- 	GameGuideRunner:runGuide(paras)
	-- end)
	buildBtn('鸟\n强', function() 
		GameGuideData:sharedInstance():setGuideIndex(500010107)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	-- buildBtn('鸟\n弱', function() 
	-- 	GameGuideData:sharedInstance():setGuideIndex(5000101071)
	-- 	GameGuideData:sharedInstance():setActionIndex(1)
	-- 	GameGuideRunner:runGuide(paras)
	-- end)
	buildBtn('扫把\n强', function()
		GameGuideData:sharedInstance():setGuideIndex(500010108)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	-- buildBtn('扫把\n弱', function() 
	-- 	GameGuideData:sharedInstance():setGuideIndex(5000101081)
	-- 	GameGuideData:sharedInstance():setActionIndex(1)
	-- 	GameGuideRunner:runGuide(paras)
	-- end)
	-- buildBtn('后退\n弱', function() 
	-- 	GameGuideData:sharedInstance():setGuideIndex(500010106)
	-- 	GameGuideData:sharedInstance():setActionIndex(1)
	-- 	GameGuideRunner:runGuide(paras)
	-- end)
	buildBtn('后退\n强', function() 
		GameGuideData:sharedInstance():setGuideIndex(500010105)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
	buildBtn('章鱼冰\n强', function() 
		GameGuideData:sharedInstance():setGuideIndex(500010104)
		GameGuideData:sharedInstance():setActionIndex(1)
		GameGuideRunner:runGuide(paras)
	end)
end


function NewGamePlaySceneUI:onPauseBtnTapped(...)

	if self:isReplayMode() then
		--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

		if self.replayMode == ReplayMode.kResume 
			or self.replayMode == ReplayMode.kReview
		then
			return
		end
	end

	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		GameSpeedManager:resuleDefaultSpeed()
	end

	self:pause()

	local dcLevelType = {
		[GameModeTypeId.NONE_ID] = "null",
		[GameModeTypeId.CLASSIC_MOVES_ID] = "step",
		[GameModeTypeId.CLASSIC_ID] = "time",
		[GameModeTypeId.DROP_DOWN_ID] = "drop",
		[GameModeTypeId.LIGHT_UP_ID] = "ice",
		[GameModeTypeId.DIG_TIME_ID] = "time_land",
		[GameModeTypeId.DIG_MOVE_ID] = "step_land",
		[GameModeTypeId.ORDER_ID] = "clear_up",
		[GameModeTypeId.DIG_MOVE_ENDLESS_ID] = "endless_land",
		[GameModeTypeId.RABBIT_WEEKLY_ID] = "rabbit_weekly",
		[GameModeTypeId.CHRISTMAS_ENDLESS_ID] = "christmas",
		[GameModeTypeId.MAYDAY_ENDLESS_ID] = "mayday",
		[GameModeTypeId.WORLD_CUP_ID] = "worldcup",
		[GameModeTypeId.SEA_ORDER_ID] = "sea_order",
	    [GameModeTypeId.HALLOWEEN_ID] = "halloween",
	    [GameModeTypeId.WUKONG_DIG_ENDLESS_ID] = "wukong",
	    [GameModeTypeId.LOTUS_ID] = "meadow",
	    [GameModeTypeId.MOLE_WEEKLY_RACE_ID] = "moleWeeklyRace",
        [GameModeTypeId.JAMSPREAD_ID] = "jamSpread",
	}

	local dcData = {
		current_stage = self.levelId,
		meta_level_id = LevelMapManager.getInstance():getMetaLevelId(self.levelId),
		stage_first = 1,
		results = 0,
		stage_mode = dcLevelType[self.gamePlayType],
		stage_objective = 0,
		stage_finish = 0,
		use_item = self.useItem,
	}
	local scoreRef = UserService:getInstance():getUserScore(self.levelId)
	if scoreRef then
		if scoreRef.star < 1 then dcData.stage_first = 2
		else dcData.stage_first = 3 end
	end
	if self.timeLimit then
		dcData.stage_objective = self.timeLimit
	elseif self.moveLimit then
		if self.gamePlayType == GameModeTypeId.RABBIT_WEEKLY_ID then
			local stage = self.gameBoardLogic:getStageIndex()
			local moveLimit = self.gameBoardLogic:getStageMoveLimit()
			dcData.stage_objective = moveLimit
			dcData.stage_rabbit = stage
		else
			dcData.stage_objective = self.moveLimit
			dcData.stage_rabbit = 0
		end
	end
	dcData.stage_finish = self.moveOrTimeCount
	self.quitDcData = dcData

	local function onClosePanelBtnTappedCallback()
		if _G.isLocalDevelopMode then printx(0, 'onClosePanelBtnTappedCallback') end
		self.quitDcData = nil
		self:continue()
		if self.quitDcData then self.quitDcData = nil end
		if GameSpeedManager:getGameSpeedSwitch() > 0 then
			GameSpeedManager:changeSpeedForFastPlay()
		end
	end

	local function onReplayCallback()
		dcData.results = 4
		if not _isQixiLevel then
			if self.levelType == GameLevelType.kDigWeekly then
				CommonTip:showTip(Localization:getInstance():getText('weekly.race.replay.tip'), 'negative', nil, 3)
				onClosePanelBtnTappedCallback()
				return
			end

			if self.levelType == GameLevelType.kTaskForRecall then 
				local levelId = RecallManager.getInstance():getAreTaskLevelId()
				local selectedItemsData = {}
				local levelType = LevelType:getLevelTypeByLevelId(levelId)
				if levelId%2==0 then 
					DcUtil:UserTrack({category = "recall", sub_category = "push_start_task", id = 5})
				else
					DcUtil:UserTrack({category = "recall", sub_category = "push_start_task", id = 3})
				end
				local startLevelLogic = StartLevelLogic:create(self, levelId, levelType, selectedItemsData, true)
				startLevelLogic:start(true)
				return
			end

			if PrePropImproveLogic:tryTriggerGuide(self.levelId, self.levelType, nil, function(accepted, propId)
				self:onPrePropGuideFinish(accepted, propId)
			end) then
				
			else
				self:popReplayPanel(onClosePanelBtnTappedCallback)
			end
			
		else
			local panel = QixiPanel:create()
			panel:setOnClosePanelCallback(onClosePanelBtnTappedCallback)
			panel:popout()
		end
	end

	local function onAFHQuitWithAlter()
		local function onQuitCallback()
			self:onQuitGameCallbackForAFHLogic()
		end

		local logic = require 'zoo.panel.askForHelp.logic.AskForHelpLevelFailedLogic'
    	logic:create(self.levelId, onQuitCallback):start()
	end	

	local mode = QuitPanelMode.QUIT_LEVEL
	if LevelType.isActivityLevelType(self.levelType)
		or self.levelType == GameLevelType.kSummerWeekly 
		or self.levelType == GameLevelType.kMoleWeekly
		or self.levelType == GameLevelType.kYuanxiao2017
		or self.levelType == GameLevelType.kFourYears
        or self.levelType == GameLevelType.kSummerFish 
        or self.levelType == GameLevelType.kMidAutumn2018 
        or self.levelType == GameLevelType.kJamSperadLevel then
		mode = QuitPanelMode.NO_REPLAY
	end

	if AskForHelpManager:getInstance():isInMode() then
		mode = QuitPanelMode.NO_REPLAY
	end

	local quitPanel
	if self.replayMode == ReplayMode.kStrategy then 
		LevelStrategyManager:dcClickStrategyPause(self.levelId)

		local Panel = require "zoo.gamePlay.levelStrategy.LevelStrategyPausePanel"
		quitPanel = Panel:create(self.gameBoardLogic)
		quitPanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback)
		quitPanel:setOnReplayBtnTappedCallback(function ()
				LevelStrategyManager:dcClickStrategyReplay(0, self.levelId)

				GameInitBuffLogic:endLevel()
				
				LevelStrategyManager.getInstance():getReplayData(self.levelId, function (replayInfo)
					if replayInfo then 
						LevelStrategyLogic:playReplay(replayInfo.data, function ()
							self:quitForStrategyReplay()
						end)
					else
						assert(false, "NewGamePlaySceneUI:onPauseBtnTapped() no replay data?")
					end
				end)
			end)
		quitPanel:setOnQuitGameBtnTappedCallback(function ()
				LevelStrategyManager:dcCloseStrategyPlay(0, self.levelId)
				self:quitForStrategyReplay()
			end)
	else
		quitPanel = QuitPanel:create(mode, self.gameBoardLogic)
		quitPanel:setOnReplayBtnTappedCallback(onReplayCallback)
		quitPanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback)
		quitPanel:setOnQuitGameBtnTappedCallback(function() self:onQuitGameCallback() end)
		if AskForHelpManager:getInstance():isInMode() then
			quitPanel:setOnQuitGameBtnTappedCallback(onAFHQuitWithAlter)
		end
		--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--

	end
	quitPanel:popout()
end

function NewGamePlaySceneUI:popReplayPanel(onClosePanelBtnTappedCallback, propId , isAlreadyFailedLevel)
	self.gameBoardLogic.onReplayPanelShow = true
    --恢复过程中，主动放弃结束恢复-- 重玩也要发送pass level
	local function replayStartGameCallback()

		
	end

	local function replayCallbackBeforStartLevel()

		if isAlreadyFailedLevel then
			--关卡失败后，有可能弹出加三步引导购买面板，这个面板会直接唤起重玩面板，但这时并不需要执行replayCallbackBeforStartLevel的相关逻辑
			--因为上一次关卡的失败结算已经执行完毕。
			return
		end

		GamePreStartContext:getInstance():setActive(false)
		GamePlayContext:getInstance().levelInfo.lastPlayResult = false
		GamePlayContext:getInstance():onLevelWillEnd()
		
		self.gameBoardLogic.onReplayPanelShow = false
		-- 重玩也要发送pass level
		local stageTime = math.floor(self.gameBoardLogic.timeTotalUsed)
		if not self.levelType ~= GameLevelType.kRabbitWeekly and not self.levelType ~= GameLevelType.kSummerWeekly and not self.levelType ~= GameLevelType.kMoleWeekly then
			local costMove = self.gameBoardLogic.realCostMove
			local extraData = nil
			--[[if self.levelType == GameLevelType.kYuanxiao2017 then 
				extraData = 'dragon_boat'
			end]]--
			local isGuideLevel = GameGuide:isNoPreBuffLevel(levelId)
			PassLevelLogic:sendPassLevelMessageOnly(self.levelId, self.levelType, stageTime, costMove, extraData , 
														self.gameBoardLogic.randomSeed , 
														LevelDifficultyAdjustManager:getCurrStrategyID() ,
														self.gameBoardLogic.initAdjustData,
														isGuideLevel,
														true
														 )
			self:checkUploadReplayForDiffAdjust( self.levelId )
		end

		----------------------------------------------
		local totalScore = nil
		if self.gameBoardLogic and self.gameBoardLogic.totalScore then
			totalScore = self.gameBoardLogic.totalScore
		end
		SnapshotManager:passLevel(self.gameBoardLogic, false)
		ReplayDataManager:onPassLevel( ReplayDataEndType.kTryAgain , totalScore)
		FUUUManager:onGameDefiniteFinish(false , self.gameBoardLogic)
		local flag = false
		if self.levelType == GameLevelType.kRabbitWeekly or self.levelType == GameLevelType.kSummerWeekly or self.levelType == GameLevelType.kMoleWeekly then
			-- 重玩也要发送pass level
			self.gameBoardLogic:quitLevel()
			flag = true
		end
		
		local star = self.gameBoardLogic.gameMode:getScoreStarLevel()
		local useItem = 0
		if StageInfoLocalLogic:hasUsePropInLevel(UserService.getInstance().user.uid) then 
			useItem = 1
		end
		local stageState = StageInfoLocalLogic:getStageState(UserService.getInstance().user.uid)
		self:logStageQuit(self.levelId, totalScore, star, 1, stageTime, useItem, stageState)

		if not flag then
			ProductItemDiffChangeLogic:endLevel()
			GameInitDiffChangeLogic:endLevel()
			GameInitBuffLogic:endLevel()
		end

		-- 重玩时下一关的一些打点会在当前Scene dispose前，会带上本关的AI seed data
		if LevelDifficultyAdjustManager:getAICoreInfo() then
			if self.quitDcData then
				self.quitDcData.seed_value 		= LevelDifficultyAdjustManager:getAISeedValue()
				self.quitDcData.event_id 		= LevelDifficultyAdjustManager:getAIEventID()
				self.quitDcData.algorithm_tag 	= LevelDifficultyAdjustManager:getAIAlgorithmTag()
			end	 
			LevelDifficultyAdjustManager:clearAICoreInfo()
		end
		
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterReplayLevel, {
			levelId = self.levelId,
			levelType = self.levelType,
		}))


		GamePlayContext:getInstance():endLevel()
		GamePreStartContext:getInstance():setActive(true)

        if Thanksgiving2018CollectManager.getInstance():isActivitySupportAll() then 
            Thanksgiving2018CollectManager.getInstance():setLevelPass( self.levelId )
        end

        if TurnTable2019Manager.getInstance():getCurIsAct() then 
            TurnTable2019Manager.getInstance():setLevelPlayedCount(self.levelId)
        end
	end

	local function onReplayPanelCloseCallback(...)
		self.gameBoardLogic.onReplayPanelShow = false

		if onClosePanelBtnTappedCallback then onClosePanelBtnTappedCallback(...) end
	end

	local startGamePanel = StartGamePanel:create(self.levelId, self.levelType, nil, StartLevelSource.kReplayPanel)
	startGamePanel:setReplayCallbackBeforStartLevel(replayCallbackBeforStartLevel)
	startGamePanel:setReplayCallback(replayStartGameCallback)
	startGamePanel:setOnClosePanelCallback(onReplayPanelCloseCallback)
	if propId then
		startGamePanel.levelInfoPanel:selectPreProp(propId)
	end
	startGamePanel:popout(false)
end

function NewGamePlaySceneUI:onQuitGameCallback()

	-- AchievementManager:judgeWithId(AchievementManager.shareId.NW_SILVER_CONSUMER, true)
	GamePlayContext:getInstance().levelInfo.lastPlayResult = false
	GamePlayContext:getInstance():onLevelWillEnd()
	if self:isReplayMode() and self.replayMode ~= ReplayMode.kResume and self.replayMode ~= ReplayMode.kSectionResume and self.replayMode ~= ReplayMode.kReview then
		self:endReplay()
		return
	end

	if self.levelType ~= GameLevelType.kMoleWeekly then
		Notify:dispatch("AchiEventQuitGame")
	end
	
	UserService.getInstance():onQuitLevel(self.levelId)

	IOSScoreGuideFacade:getInstance():setPassLevelState(kPassLevelState.kQuit)

	local totalScore = nil
	if self.gameBoardLogic and self.gameBoardLogic.totalScore then
		totalScore = self.gameBoardLogic.totalScore
	end
	ReplayDataManager:onPassLevel( ReplayDataEndType.kQuit , totalScore)
	SnapshotManager:passLevel(self.gameBoardLogic, false)

	if self.replayRecordController and self.replayRecordController:isRecording() then
		self.replayRecordController:stopWithoutPreview()
	end
	-- self:unloadResources()

	local stageTime = math.floor(self.gameBoardLogic.timeTotalUsed)
	-- 退出游戏也要发送pass level
	if self.levelType == GameLevelType.kRabbitWeekly or 
		self.levelType == GameLevelType.kSummerWeekly or 
		self.levelType == GameLevelType.kMoleWeekly then
		self.gameBoardLogic:quitLevel()
	elseif self.levelType == GameLevelType.kMainLevel or 
			self.levelType == GameLevelType.kHiddenLevel or 
			self.levelType == GameLevelType.kYuanxiao2017 or
			self.levelType == GameLevelType.kFourYears or
            self.levelType == GameLevelType.kSummerFish or 
            self.levelType == GameLevelType.kMidAutumn2018 or
            self.levelType == GameLevelType.kJamSperadLevel  then
		local costMove = self.gameBoardLogic.realCostMove
		local extraData = nil
		--[[if self.levelType == GameLevelType.kYuanxiao2017 then 
			extraData = 'dragon_boat'
		end]]--
		if self.levelType == GameLevelType.kMidAutumn2018 then
			extraData = {}
			extraData.passedCol = ZQManager.getInstance():getTargetPieceIndexes()
		end
		local isGiveUp = true
		local isGuideLevel = GameGuide:isNoPreBuffLevel(self.levelId)
		PassLevelLogic:sendPassLevelMessageOnly(self.levelId, self.levelType, stageTime, costMove, extraData , 
													self.gameBoardLogic.randomSeed , 
													LevelDifficultyAdjustManager:getCurrStrategyID() ,
													self.gameBoardLogic.initAdjustData,
													isGuideLevel,isGiveUp
													 )
	end
	
	if self.levelType == GameLevelType.kMainLevel
	     	or self.levelType == GameLevelType.kHiddenLevel then		
		HomeScene:sharedInstance():setEnterFromGamePlay(self.levelId, true)		
		PrePropImproveLogic:onLevelEnd(false,self.levelId)
	end

	--周赛主动退出 加一个kReturnFromGamePlay事件
	if self.levelType == GameLevelType.kSummerWeekly or self.levelType == GameLevelType.kMoleWeekly then
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReturnFromGamePlay, {id = self.levelId,isQuit = true}))
	end

	if self.gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID and 
			self.gameBoardLogic and self.gameBoardLogic.isFullFirework then
		--（五一)关卡结束技能未使用
        -- DcUtil:UserTrack({ category='activity', sub_category='labourday_no_click_skill', quit_level = true })
	end
	if self.quitDcData then
		self.quitDcData.results = 3
	end
	FUUUManager:onGameDefiniteFinish(false , self.gameBoardLogic)
	wukongLastGuideCastingCount = -1
	MissionModel:getInstance():updateDataOnGameFinish(false , self.gameBoardLogic)

	local star = self.gameBoardLogic.gameMode:getScoreStarLevel()
	local useItem = 0
	if StageInfoLocalLogic:hasUsePropInLevel(UserService.getInstance().user.uid) then 
		useItem = 1
	end
	local stageState = StageInfoLocalLogic:getStageState(UserService.getInstance().user.uid)
	self:logStageQuit(self.levelId, totalScore, star, 0, stageTime, useItem, stageState)

    if SpringFestival2019Manager.getInstance():getCurIsAct() then 
--        PigYearLogic:afterPassLevel( self.levelId )
        SpringFestival2019Manager.getInstance():getPassLevelCanGet( false, 0 )
    end

    if TurnTable2019Manager.getInstance():getCurIsAct() then 
        TurnTable2019Manager.getInstance():setLevelPlayedCount(self.levelId)
    end

	if self.levelType == GameLevelType.kYuanxiao2017 then
		GamePlayEvents.dispatchFailLevelEvent({
			levelType = self.levelType, 
			levelId = self.levelId, 					
		})
	elseif self.levelType == GameLevelType.kMidAutumn2018 then
	 	GamePlayEvents.dispatchFailLevelEvent({
			levelType = self.levelType, 
			levelId = self.levelId, 	
			targetCount = self.gameBoardLogic:getTargetCount(),	
			targetsGrp = ZQManager.getInstance():getTargetPieceIndexes(),
			isQuit = true,
		})
	elseif self.levelType == GameLevelType.kSpring2017 
			or self.levelType == GameLevelType.kFourYears
			or self.levelType == GameLevelType.kOlympicEndless
            or self.levelType == GameLevelType.kSummerFish
		then
		GamePlayEvents.dispatchFailLevelEvent({
			levelType = self.levelType, 
			levelId = self.levelId, 	
			targetCount = self.gameBoardLogic:getTargetCount(),	
			star = 0,	
			isQuit = true,
		})
    elseif self.levelType == GameLevelType.kJamSperadLevel then
        GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId,
                star = 0,	
                isQuit = true,
			})
    elseif self.levelType == GameLevelType.kSpring2019  then

        local step = 0
        if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
            step = SpringFestival2019Manager.getInstance().EndMoveStep
        end

        GamePlayEvents.dispatchFailLevelEvent({
            levelType = self.levelType, 
			levelId = self.levelId,
			leftStep = step, 
            star = 0,	
            isQuit = true,
		})
	else
		Director:sharedDirector():popScene()
	end

	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()

	_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterQuitLevel, {
		levelId = self.levelId,
		levelType = self.levelType,
	}))

	GamePlayContext:getInstance():endLevel()

	self:checkUploadReplayForDiffAdjust( self.levelId )

    if Thanksgiving2018CollectManager.getInstance():isActivitySupportAll() then 
        Thanksgiving2018CollectManager.getInstance():setLevelPass( self.levelId )
    end

	-- FTWLocalLogic:onLevelEnd()
    
end

function NewGamePlaySceneUI:onQuitGameCallbackForAFHLogic()
	GamePlayContext:getInstance().levelInfo.lastPlayResult = false
	GamePlayContext:getInstance():onLevelWillEnd()
	Notify:dispatch("AchiEventQuitGame", true)
	-- AchievementManager:judgeWithId(AchievementManager.shareId.NW_SILVER_CONSUMER, true)
	IOSScoreGuideFacade:getInstance():setPassLevelState(kPassLevelState.kQuit)

	-- ???
	local totalScore = nil
	if self.gameBoardLogic and self.gameBoardLogic.totalScore then
		totalScore = self.gameBoardLogic.totalScore
	end
	ReplayDataManager:onPassLevel( ReplayDataEndType.kQuit , totalScore)
	SnapshotManager:passLevel(self.gameBoardLogic, false)

	if self.replayRecordController and self.replayRecordController:isRecording() then
		self.replayRecordController:stopWithoutPreview()
	end
	-- self:unloadResources()

	-- 退出游戏也要发送pass level
	local stageTime = math.floor(self.gameBoardLogic.timeTotalUsed)
	local costMove = self.gameBoardLogic.realCostMove
	local extraData = nil
	
	local doneeUid = AskForHelpManager:getInstance():getDoneeUId()
	PassLevelLogic:sendAFHPassLevelMessageOnly(self.levelId, self.levelType, stageTime, costMove, extraData,
												self.gameBoardLogic.randomSeed, 
												LevelDifficultyAdjustManager:getCurrStrategyID(), doneeUid)

	if self.levelType == GameLevelType.kMainLevel or self.levelType == GameLevelType.kHiddenLevel then		
		HomeScene:sharedInstance():setEnterFromGamePlay(self.levelId)
	end

	-- ???
	self.quitDcData.results = 3
	FUUUManager:onGameDefiniteFinish(false , self.gameBoardLogic)
	MissionModel:getInstance():updateDataOnGameFinish(false , self.gameBoardLogic)

	local star = self.gameBoardLogic.gameMode:getScoreStarLevel()
	local useItem = 0
	if StageInfoLocalLogic:hasUsePropInLevel(UserService.getInstance().user.uid) then 
		useItem = 1
	end
	local stageState = StageInfoLocalLogic:getStageState(UserService.getInstance().user.uid)
	self:logFriendHelpStageQuit(self.levelId, totalScore, star, 0, stageTime, useItem, stageState)

	Director:sharedDirector():popScene()

	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()
	GamePlayContext:getInstance():endLevel()
end

function NewGamePlaySceneUI:createGamePlayScene(levelId , gamePlaySceneUiType , levelType , forceUseDropBuff)

	local strategyData = nil

	if self:isReplayMode() then

		strategyData = LevelDifficultyAdjustManager:getStrategyReplayDataByStrategyID( self.replayData.strategyID )
		--RemoteDebug:uploadLog( "NewGamePlaySceneUI:createGamePlayScene  strategyData =" , strategyData )
		if strategyData then
			--RemoteDebug:uploadLog( "NewGamePlaySceneUI:createGamePlayScene  !!!  " , strategyData.seed , strategyData.mode , strategyData.ds )
		end

	end

	local passAllDiffAdjust = false
	if self.gamePlaySceneUiType == GamePlaySceneUIType.kDev then
		passAllDiffAdjust = true
	end

	local gamePlayScene	= NewGamePlayScene:create( self.levelConfig , self.replayMode , self.replayData , gamePlaySceneUiType , forceUseDropBuff , strategyData , passAllDiffAdjust)
	return gamePlayScene
end

function NewGamePlaySceneUI:onEnterHandler(event, ...)

	if event == "enter" then
		GamePlayContext:getInstance():setTestInfo( "levelStartProgress" , 
			{info = "levelStartProgress" , levelId = self.levelId , playId = GamePlayContext:getInstance():getIdStr() , p = 200} , true , testStartLevelInfoFilterUids )
		
		if GamePlayContext:getInstance().syncExceptionOccur then -- 在关卡过程中其他Scene中发生了数据修复异常，回来后需要退出关卡
			local function onConfirm()
				self:forceQuitPlay()
			end
			CommonTipWithBtn:showTip({tip = "由于游戏问题的修复，本关数据将无法保存~请重新开始闯关吧~", yes = "知道了"}, "negative", onConfirm, nil, nil, true)
		end
	end

	if self:isReplayMode() then
		self.gameInit = true
		return
	end
	assert(event)
	assert(#{...} == 0)
	if _G.isLocalDevelopMode then 
		printx(0, '>>>>>>>>>>today debug onEnterHandler', event)
		printx(0, table.tostring(event))
	end

	if event == "enter" then
		if not self.gameInit then
			self.gameInit = true
			-- Play Background Music
			GamePlayMusicPlayer:getInstance():playGameSceneBgMusic()
			self.gameBoardLogic:onGameInit()
		end
	end
end

function NewGamePlaySceneUI:initTopArea( ... )
	-- body
	local topArea = nil
	if self.levelType == GameLevelType.kSpring2018 then
		topArea = require("zoo.modules.spring2018.SPGamePlaySceneTopArea"):create(self.levelSkinConfig, self)
	elseif self.gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		require("zoo.modules.autumn2018.ZQGamePlaySceneTopArea")
		topArea = ZQGamePlaySceneTopArea:create(self.levelSkinConfig, self)
		local day = self.levelId - 280400
		if day >= 1 and day <= 6 then
			local titleNode = topArea.topLeftLeaves:getChildByName("title")
			if titleNode then
				for i = 1, 6 do
					titleNode:getChildByName("day"..i):setVisible(day == i)
				end
			end
		end
	elseif self.gamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
		require("zoo.modules.spring2017.SpringGamePlaySceneTopArea")
		topArea = SpringGamePlaySceneTopArea:create(self.levelSkinConfig, self)
	elseif self.gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID then
		require("zoo.modules.weekly2017s1.WeeklyGamePlaySceneTopArea")
		topArea = WeeklyGamePlaySceneTopArea:create(self.levelSkinConfig, self)
    elseif self.gamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID then
		require("zoo.modules.moleweekly.MoleWeeklyGamePlaySceneTopArea")
		topArea = MoleWeeklyGamePlaySceneTopArea:create(self.levelSkinConfig, self)
    elseif self.gamePlayType == GameModeTypeId.SEA_ORDER_ID and self.levelType == GameLevelType.kSummerFish then
		require("zoo.modules.summerFish.SummerFishGamePlaySceneTopArea")
		topArea = SummerFishGamePlaySceneTopArea:create(self.levelSkinConfig, self)
    elseif self.gamePlayType == GameModeTypeId.JAMSPREAD_ID then
		require("zoo.modules.jamSpeard2018.jamSpeard2018TopArea")
		topArea = JamSpeard2018TopArea:create(self.levelSkinConfig, self)
	else
		topArea = GamePlaySceneTopArea:create(self.levelSkinConfig, self)
	end
	topArea:setPositionY(topArea:getPositionY()) --  + _G.__EDGE_INSETS.top / 2 原来为了让上面少空点故意往上提的，现在为了应付挖孔屏去掉，效果尚可
	self:addChild(topArea)
	self.moveOrTimeCounter = topArea.moveOrTimeCounter
	self.scoreProgressBar = topArea.scoreProgressBar
	self.topArea = topArea

	-- local cnlbLogic = NextLevelButtonProxy:getInstance():getProxy()
	-- if cnlbLogic and cnlbLogic:shouldHideLevelTitle() then
	-- 	local specLevelTitle = {'特', FTWLocalLogic:getLevelIndex(self.levelId) ,'关'}
	-- 	if topArea and topArea.setLevelTitle then
	-- 		topArea:setLevelTitle(unpack(specLevelTitle))
	-- 	end
	-- end

	
	local gameContext = GamePlayContext:getInstance()
	local guideContext = gameContext:getGuideContext()

	if not self:isReplayMode() 
		and guideContext.showRepeatGuideButton
		and (LevelType:isMainLevel(self.levelId) or LevelType:isYuanxiao2017Level(self.levelId)) then
		local button = Layer:create()
		FrameLoader:loadArmature('skeleton/repeat_guide_animation', 'repeat_guide_animation', 'repeat_guide_animation')
		local node = ArmatureNode:create('repeat_guide_button')
		button:addChild(node)

		button.removeSelf = function (_self, isClick)

			if node and node.isInAnim then return end
			if button and not button.isDisposed then
				button:removeAllEventListeners()
			end
			if node then
				node:ad(ArmatureEvents.COMPLETE, 
				function () 
					if button then 
						button:removeFromParentAndCleanup(true) 
						button = nil 
						node = nil
						self.repeatGuideBtn = nil
					end
				end)
				node:playByIndex(1, 1)
				node.isInAnim = true
				if not isClick then
					DcUtil:UserTrack({category='newplayer', sub_category = 'repeat', click = 2}, true)
				end
			end
		end
		button:ad(DisplayEvents.kTouchTap, function ()
			button:setTouchEnabled(false)
			button:removeSelf(true)
			DcUtil:UserTrack({category='newplayer', sub_category = 'repeat', click = 1}, true)
			GameGuide:sharedInstance():setRepeatGuide(true)
			GameGuide:sharedInstance():onGameAnimOver() 

			local gameContext = GamePlayContext:getInstance()
			local guideContext = gameContext:getGuideContext()
			guideContext.clickRepeatGuide = true

			end)
		button:setTouchEnabled(true, 0, true)
		self:addChild(button)
		local pos = self:convertToNodeSpace(self.moveOrTimeCounter:getParent():convertToWorldSpace(self.moveOrTimeCounter:getPosition()))
		pos.x = pos.x - 50
		pos.y = pos.y - 190
		button:setPosition(pos)
		self.repeatGuideBtn = button
		-- button:setPosition(ccp(300, 300))	
	end

	if _G.isLocalDevelopMode then
		-- self:addBonusBtn()
		-- self:addDropUsePropBtn()
	end
end


function NewGamePlaySceneUI:usePropCallback(propId, usePropType, expireTime, isRequireConfirm, isGuideRefresh,noGuide, ...)
	assert(type(propId) == "number")
	assert(type(usePropType) == "number")
	assert(type(isRequireConfirm) == "boolean")
	assert(#{...} == 0)
	--printx(1 , "NewGamePlaySceneUI:usePropCallback  propId:" , propId , "usePropType:" , usePropType , "isRequireConfirm:" , isRequireConfirm , "self:isReplayMode() =" , self:isReplayMode())

	if self:isReplayMode() then

		self.usePropType = usePropType

		local realItemId = propId
		if self.usePropType == UsePropsType.EXPIRE then  realItemId = ItemType:getRealIdByTimePropId(propId) end
		
		if not isRequireConfirm then -- use directly
			local function sendUseMsgSuccessCallback()
				self.propList:confirm(propId)
				self.gameBoardView:useProp(realItemId, isRequireConfirm, usePropType , isGuideRefresh)
				self.useItem = true

				--printx(1 , "NewGamePlaySceneUI:usePropCallback  sendUseMsgSuccessCallback  self.replayMode =" , self.replayMode , self.replayMode == ReplayMode.kResume)
			end
			sendUseMsgSuccessCallback()
			return true
		else -- can be canceled, must kill the process before use
			
			if self:checkPropEnough(usePropType, propId) then --replay模式下永远返回true
				self.needConfirmPropId = propId
				-- self.needConfirmPropIsTempProperty = true
				self.gameBoardView:useProp(realItemId, isRequireConfirm, usePropType , isGuideRefresh)
				
				return true
			else
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(730311)))
				return false
			end
		end


	else
		local propItem = self.propList:findItemByItemID(propId)
		if propItem then
			local pos = propItem:getItemCenterPosition()
			self.usePropItemPos = pos
		else
			self.usePropItemPos = nil
		end

		self.propId = propId
		self.usePropType = usePropType
		self.expireTime = expireTime

		local realItemId = propId
		if self.usePropType == UsePropsType.EXPIRE then  realItemId = ItemType:getRealIdByTimePropId(propId) end
		
		if not isRequireConfirm then -- use directly
			local revertPropInfo = nil
			local isBackProp = realItemId == GamePropsType.kBack or realItemId == GamePropsType.kBack_b or realItemId == GamePropsType.kBack_l
			if isBackProp then
				revertPropInfo = self.gameBoardLogic:getRevertPropInfo()
			end
			local function sendUseMsgSuccessCallback(isFake)
				if isBackProp then
					self.levelTargetPanel:forceStopAnimation()
				end
				self.propList:confirm(propId)
				self.gameBoardView:useProp(realItemId, isRequireConfirm , usePropType, isGuideRefresh)
				self.useItem = true

				if self.repeatGuideBtn then
					self.repeatGuideBtn:removeSelf()
				end
			end
			local function sendUseMsgFailCallback(evt)
				self.propList:cancelFocus()
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)))
			end

			if usePropType == UsePropsType.FAKE then
				sendUseMsgSuccessCallback(true)
			else
				self:sendUsePropMessage(propId, usePropType, sendUseMsgSuccessCallback, sendUseMsgFailCallback,revertPropInfo)
			end

			return true
		else -- can be canceled, must kill the process before use
			if self:checkPropEnough(usePropType, propId) then
				self.needConfirmPropId = propId
				-- self.needConfirmPropIsTempProperty = true
				self.gameBoardView:useProp(realItemId, isRequireConfirm , usePropType)

				if GameGuide and not noGuide then
					GameGuide:sharedInstance():onBeforeUseProp(realItemId)
				end
				return true
			else
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(730311)))
				return false
			end
		end
	end
	
end

function NewGamePlaySceneUI:cancelPropUseCallback(propId,confirm, ...)
	assert(type(propId) == "number")
	assert(#{...} == 0)

	self.needConfirmPropId 			= false
	-- self.needConfirmPropIsTempProperty 	= false

	if not self:isReplayMode() then
		if GameGuide then
			GameGuide:sharedInstance():onCancelUseProp(propId)
		end
	end
	
	self.gameBoardView:usePropCancelled(propId, confirm)
end

function NewGamePlaySceneUI:confirmPropUsed(pos, successCallback , failCallback)

	if self:isReplayMode() then
		-- Previous Must Recorded The Used Prop
		assert(self.needConfirmPropId)

		-- Send Server User This Prop Message
		local function onUsePropSuccess()
			self.propList:confirm(self.needConfirmPropId, pos)
			self.needConfirmPropId 			= false
			self.useItem = true
			if successCallback and type(successCallback) == 'function' then
				successCallback()
			end
		end
		onUsePropSuccess()
	else
		-- Previous Must Recorded The Used Prop
		assert(self.needConfirmPropId)

		-- Send Server User This Prop Message
		local function onUsePropSuccess()
			self.propList:confirm(self.needConfirmPropId, pos)
			self.needConfirmPropId = false
			self.useItem = true
			if successCallback and type(successCallback) == 'function' then
				successCallback()
			end
			IngamePropGuideManager:getInstance():onConfirmPropUsed()
		end
		local function onUsePropFail(evt)
			self.propList:cancelFocus()
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)))
			if failCallback and type(failCallback) == 'function' then
				failCallback()
			end
		end

		if self.usePropType == UsePropsType.FAKE then
			onUsePropSuccess()
		else
			self:sendUsePropMessage(self.needConfirmPropId, self.usePropType, onUsePropSuccess, onUsePropFail)
		end
		
		if self.repeatGuideBtn then
			self.repeatGuideBtn:removeSelf()
		end
	end
	
end

function NewGamePlaySceneUI:checkPropEnough(usePropType, propId)

	if self:isReplayMode() then
		return true
	else
		-- 恢复用虚拟道具
		if usePropType == UsePropsType.FAKE then
			return true
		end

		-- 临时道具
		if usePropType == UsePropsType.TEMP then
			return true
		end
		-- 限时道具
		if usePropType == UsePropsType.EXPIRE then
			local uNum = UserManager:getInstance():getUserTimePropNumber(propId)
			local sNum = UserService:getInstance():getUserTimePropNumber(propId)
			if uNum > 0 and sNum > 0 then
				return true
			end
			return false
		end
		-- 普通道具
		if usePropType == UsePropsType.NORMAL then 
			local uNum = UserManager:getInstance():getUserPropNumber(propId)
			local sNum = UserService:getInstance():getUserPropNumber(propId)
			if uNum > 0 and sNum > 0 then
				return true
			end
			return false
		end

		return false
	end
end

function NewGamePlaySceneUI:onGameAnimOverByGuide()
	local res
	if not self:isReplayMode() and GameGuide then
		res = GameGuide:sharedInstance():onGameAnimOver()
	end
end

function NewGamePlaySceneUI:onGameSwap(from, to)

	if not self:isReplayMode() then
		if _G.isLocalDevelopMode then printx(0, "*****NewGamePlaySceneUI:onGameSwap") end
		if self.repeatGuideBtn then
			self.repeatGuideBtn:removeSelf()
		end
		if  GameGuide then
			return GameGuide:sharedInstance():onGameSwap(from, to)
		end
	end
end

function NewGamePlaySceneUI:onGetItem(itemType)

	if not self:isReplayMode() then
		if _G.isLocalDevelopMode then printx(0, "*****NewGamePlaySceneUI:onGetItem") end
		if GameGuide then
			return GameGuide:sharedInstance():onGetGameItem(itemType)
		end
	end
end

function NewGamePlaySceneUI:onGameStable(hasGift)
	if not self:isReplayMode() and GameGuide then
		return GameGuide:sharedInstance():onGameStable(hasGift)
	end
end

function NewGamePlaySceneUI:onExitGame()

	-- require("hecore/profiler"):pause()

	if not self:isReplayMode() then
		if _G.isLocalDevelopMode then printx(0, "*****NewGamePlaySceneUI:onExitGame") end
		if GameGuide then
			return GameGuide:sharedInstance():onExitGame()
		end
	end
end

function NewGamePlaySceneUI:onFullFirework()
	if not self:isReplayMode() and GameGuide then
		local winSize = Director:sharedDirector():getWinSize()

        local icon = self.propList:findSpringItemIcon()
        if icon then
	        local worldPoint = icon:convertToWorldSpace(ccp(0, icon:getGroupBounds().size.height))
            if _G.isLocalDevelopMode then printx(0, "offset: ", worldPoint.x - winSize.width/2) end
            --updated the worldPoint
			local pos = self.propList:getSpringItemGlobalPosition()
    		local hasGuide = GameGuide:sharedInstance():tryFirstFullFirework(pos) 

            --关闭飞出来的动画
--    		if not hasGuide then

--    			if not GameGuideData:sharedInstance():getRunningGuide() then
--    				local delay = 1
--	    			if self.propList.leftPropList and self.propList.leftPropList:isPlayingAddTimePropAnim() then
--	    				delay = 3.5
--	    			end
--					local springItem = self.propList:findSpringItem()
--	    			springItem:playFlyNutAnim(delay)
--    			end
--    		else
    			local springItem = self.propList:findSpringItem()
    			springItem.animPlayed = true
--    		end
        end
    end
end

function NewGamePlaySceneUI:onShowFullFireworkTip()
	if not self:isReplayMode() and GameGuide then
		local pos = self.propList:getSpringItemGlobalPosition()
        GameGuide:sharedInstance():onShowFullFireworkTip(pos)
    end
end

function NewGamePlaySceneUI:playFirstShowFireworkGuide()
	if not self:isReplayMode() and GameGuide then
		local pos = self.propList:getSpringItemGlobalPosition()
		GameGuide:sharedInstance():onFirstShowFirework(pos)
    end
end

function NewGamePlaySceneUI:playFirstBuyFirewordGuide()
	if not self:isReplayMode() and GameGuide then
		local pos = self.propList:getSpringItemGlobalPosition()
		GameGuide:sharedInstance():tryFirstBuyFirework(pos)
    end
end

--周赛购买大招标记
function NewGamePlaySceneUI:playFirstBuyMoleWeekFirewordGuide()
	if not self:isReplayMode() and GameGuide then
		local pos = self.propList:getSpringItemGlobalPosition()
		GameGuide:sharedInstance():tryFirstBuyMoleWeekFirework(pos)
    end
end

function NewGamePlaySceneUI:tryFirstQuestionMark(mainLogic)
	if not self:isReplayMode() and GameGuide then
		local row, col = 0, 0
		local found = false
		for r = #mainLogic.gameItemMap, 1, -1  do
			for c = 1, #mainLogic.gameItemMap[r] do 
				local item = mainLogic.gameItemMap[r][c]
				if item.ItemType == GameItemType.kQuestionMark then
					row = r
					col = c
					found = true
					break
				end
			end
			if found == true then break end
		end
		if not found then -- 没有找到福袋，直接返回
			mainLogic.firstProduceQuestionMark = false
		 	return 
		end 

		GameGuide:sharedInstance():tryFirstQuestionMark(row, col)
		
		local summerWeeklyData = SeasonWeeklyRaceManager:getInstance().matchData
		if summerWeeklyData and not summerWeeklyData.firstGuideRewarded then

			--[[
			if mainLogic.summerWeeklyData then
				mainLogic.summerWeeklyData.dropPropsPercent = 100
			end
			]]
			GamePlayContext:getInstance().summerWeeklyData.dropPropsPercent = 100
			ReplayDataManager:updateGamePlayContext()

			summerWeeklyData.firstGuideRewarded = true
		end
	end
end

function NewGamePlaySceneUI:passLevel(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount,activityForceShareData, ...)
	assert(type(levelId)	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(type(stageTime)	== "number")
	assert(type(coin)	== "number")
	assert(#{...} == 0)

	local hadPassed = UserManager:getInstance():hasPassedLevelEx(levelId)

	GamePlayContext:getInstance().levelInfo.lastPlayResult = true
	GamePlayContext:getInstance():onLevelWillEnd()

	if self.passOpLog then
		--
--

	end



	-- 2017十一国庆活动
	local levelType = self.levelType
	local originTotalTargetCount = 0
	if levelType == GameLevelType.kSummerWeekly then
		local matchData = SeasonWeeklyRaceManager:getInstance().matchData
		originTotalTargetCount = matchData and matchData.weeklyScore or 0
	end
	local ingameTargetCount = targetCount
	local ndAddNum = 0
	local ndAddition = 100
	if levelType == GameLevelType.kSpring2017 then
		coin = 0 -- 不能获得银币
		local gameMode = self.gameBoardLogic.gameMode
		ndAddNum = gameMode.encryptData.targetAddNum
		ndAddition = gameMode.encryptData.targetAddition
		if ndAddNum > 0 or ndAddition ~= 100 then
			targetCount = math.ceil((ingameTargetCount + ndAddNum) * ndAddition / 100)
		end
	end

	if self.isGameGuideDebugMode then
		self:forceQuitPlay()
		return
	end

	if self:isReplayMode() then

		if self.replayMode ~= ReplayMode.kResume 
		then
			self:replayResult(levelId, score, star, coin, targetCount, bossCount , true)
			return
		end
		
	end

	if AskForHelpManager.getInstance():isInMode() then
		return self:passLevelAFH(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount,activityForceShareData, ...)
	end

	IOSScoreGuideFacade:getInstance():setPassLevelState(kPassLevelState.kSuccess)
	IOSScoreGuideFacade:getInstance():passLevel(levelId)

	-- ----------------------------------
	-- Ensure Only Call This Func Once
	-- ----------------------------------
	assert(not self.levelFinished, "only call this function one time !")
	if not self.levelFinished then
		self.levelFinished = true
	end

	if self.gamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID and 
			self.gameBoardLogic and self.gameBoardLogic.isFullFirework then
		--（五一)关卡结束技能未使用
        -- DcUtil:UserTrack({ category='activity', sub_category='labourday_no_click_skill', quit_level = false })
	end

	if levelType == GameLevelType.kOlympicEndless then
		local dcData = {
			game_type = "stage",
			game_name = "olympic ",
			category = "other",
			sub_category = "olympic_playing_record",
			t1 = levelId,
			t2 = self.gameBoardLogic.realCostMove,
			t3 = self.gameBoardLogic.passedCol,
		}
		DcUtil:activity(dcData)
	elseif levelType == GameLevelType.kMidAutumn2018 then
		--dc for pass level 
	end

	if self.levelType == GameLevelType.kMainLevel then 
		PrePropImproveLogic:onLevelEnd(true,self.levelId)
	end

	------------------------
	--- Success Callback
	------------------------
	local function onSendPassLevelMessageSuccessCallback(levelId, score, rewardItems, buffUpgrade, ...)
		assert(type(levelId)	== "number")
		assert(type(score)	== "number")
		assert(rewardItems)
		assert(#{...} == 0)

		if CountdownPartyManager.getInstance():isActivitySupportAll() then 
			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
				CountdownPartyManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum * 10)
			end
		end

--        if DragonBuffManager.getInstance():isActivitySupportAll() then 
--			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
--                DragonBuffManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum * 10)
--			end
--		end

--        if Qixi2018CollectManager.getInstance():isActivitySupportAll()
--            or Qixi2018CollectManager.getInstance():isActivityOppoSupportAll() then 
--			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
--                Qixi2018CollectManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum * 10)
--			end

--            local maxLevel = Qixi2018CollectManager.getInstance().maxLevel
--            local oppoMaxLevel = Qixi2018CollectManager.getInstance().maxOppoLevel
--            if Qixi2018CollectManager.getInstance():getUserStateByActivityMaxLevel(maxLevel) ==  Qixi2018CollectManager.UserState.kTopStar or 
--                Qixi2018CollectManager.getInstance():getUserStateByActivityMaxLevel(oppoMaxLevel) ==  Qixi2018CollectManager.UserState.kTopStar then

--                if targetCount and type(targetCount) == "string" then 
--				    local targetsAmount = string.split(targetCount, ",")
--                    Qixi2018CollectManager.getInstance():addWeekCollectionNum( tonumber( targetsAmount[1] ) )
--                end

--            end
--		end

        if Thanksgiving2018CollectManager.getInstance():isActivitySupportAll() then 
			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 

                local bFirstPlayTask = Thanksgiving2018CollectManager.getInstance():RewardIsDouble(levelId)

                local DoubuleNum = 10
                if bFirstPlayTask then
                    DoubuleNum = 20
                end

                Thanksgiving2018CollectManager.getInstance():CollectDC( self.gameBoardLogic.actCollectionNum * DoubuleNum )
                Thanksgiving2018CollectManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum * DoubuleNum)
			end

            Thanksgiving2018CollectManager.getInstance():setPassLevel( levelId )
            Thanksgiving2018CollectManager.getInstance():setLevelPass( levelId )
		end

        if SpringFestival2019Manager.getInstance():getCurIsAct() then 
--            PigYearLogic:afterPassLevel( levelId, true )
            SpringFestival2019Manager.getInstance():getPassLevelCanGet( true, star )

            local Reward = SpringFestival2019Manager:getInstance():getCurLevelPassCanGetInfo( false )
            PigYearLogic:addPassLevelRewards(Reward)

            --打点
            SpringFestival2019Manager.getInstance():DCForStageEnd()
        end

        if TurnTable2019Manager.getInstance():getCurIsAct() then 
            TurnTable2019Manager.getInstance():setLevelPlayedCount(levelId)
        end

        --回流任务
        local bActMission = RecallA2019Manager.getInstance():getActMission()
        if bActMission then
            RecallA2019Manager.getInstance():setLevelPass( levelID )
        end

		-- insert digged gems as the first reward
		if levelType == GameLevelType.kDigWeekly then
			local tmp = {}
			table.insert(tmp, {itemId = ItemType.GEM, num = targetCount})
			table.insert(tmp, rewardItems[1])
			table.insert(tmp, rewardItems[2])
			rewardItems = tmp
		elseif levelType == GameLevelType.kMayDay then
			local tmp = {}
			-- table.insert(tmp, {itemId = ItemType.XMAS_BOSS, num = bossCount})
			table.insert(tmp, {itemId = ItemType.XMAS_BELL, num = targetCount})
			table.insert(tmp, rewardItems[1])
			rewardItems = tmp
		elseif levelType == GameLevelType.kMoleWeekly then
			local tmp = {}
			for _, v in pairs(rewardItems) do
				table.insert(tmp, v)
			end
			if targetCount and type(targetCount) == "string" then 
				local targetsAmount = string.split(targetCount, ",")
				table.insert(tmp, {itemId = ItemType.RACE_TARGET_0, num = tonumber(targetsAmount[1])})
				table.insert(tmp, {itemId = ItemType.RACE_TARGET_1, num = tonumber(targetsAmount[2])})
			end
			rewardItems = tmp
		elseif levelType == GameLevelType.kWukong then
			local tmp = {}
			for _, v in pairs(rewardItems) do
				table.insert(tmp, v)
			end
			table.insert(tmp, {itemId = ItemType.WUKONG, num = targetCount})
			rewardItems = tmp

		elseif levelType == GameLevelType.kRabbitWeekly then
			local tmp = {}
			table.insert(tmp, {itemId = ItemType.WEEKLY_RABBIT, num = targetCount})
			table.insert(tmp, rewardItems[1])
			table.insert(tmp, rewardItems[2])
			rewardItems = tmp
		elseif levelType == GameLevelType.kSummerWeekly then
			local tmp = {}
			for _, v in pairs(rewardItems) do
				table.insert(tmp, v)
			end
			table.insert(tmp, {itemId = ItemType.KWATER_MELON, num = targetCount})
			rewardItems = tmp
		elseif levelType == GameLevelType.kTaskForRecall then
			rewardItems = {}
		elseif levelType == GameLevelType.kOlympicEndless or levelType == GameLevelType.kMidAutumn2018 then
			rewardItems = {}
		end

		if levelType == GameLevelType.kSummerWeekly then
			-- rewardItems 需要添加本关道具云块敲出的东东
			-- 周赛逻辑应该保证道具数量不高于上限限制
			

			if self.gameBoardLogic.getProps then
				if (not rewardItems) then  rewardItems = {} end
				local rewardsCount = {}

				for i,v in ipairs(self.gameBoardLogic.getProps) do

					if (not rewardsCount[v]) then rewardsCount[v] = 0 end
					
					local canAdd = false
					if tostring(v) == "10012" then 
						if rewardsCount[v] < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing then
							canAdd = true
						end
					else
						if rewardsCount[v] < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount then
							canAdd = true
						end
					end

					if  canAdd then 
						rewardsCount[v] = rewardsCount[v] + 1
						table.insert(rewardItems , {itemId = v ,num = 1})
					end 
				end
			end

			local boxRewards = SeasonWeeklyRaceManager:getInstance().lottery.boxRewards
			for _, v in pairs(boxRewards) do
				table.insert(rewardItems , {itemId = v.id ,num = v.num}) 
			end
			if _G.isLocalDevelopMode then printx(0, "wtf rewards ",table.tostring(rewardItems)) end

			local panel 
			panel = SeasonWeeklyRaceResultPanel:create(
				self:getStarLevelFromScore(score), 
				score, 
				rewardItems, 
				self.gameBoardLogic.passedRow , 
				self.gameBoardLogic.replayMode)
			if panel then panel:popout() end

			local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
			if LadybugABTestManager:isNew() then
				local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
				LadybugDataManager:getInstance():onPlaySeasonWeekly()
			end

			--panel.replayMode = self.gameBoardLogic.replayMode
			panel:setCloseCallBack(function()
				local function SeasonWeeklyPanelWillPopout()
					-- play level act mark 
					if self.gameBoardLogic.replayMode == ReplayMode.kResume then
						SeasonWeeklyRaceManager:getInstance():pocessSeasonWeeklyDecision(false , true)
					end
				end 

				SeasonWeeklyPanelWillPopout()

			end)
			local data = {id = self.levelId,levelType = levelType}
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReturnFromGamePlay, data))
			
		elseif levelType == GameLevelType.kMoleWeekly then

			local RankRacePassLevelSharePanel = require 'zoo.quarterlyRankRace.view.RankRacePassLevelSharePanel'

			local panel 
			panel = RankRacePassLevelSharePanel:create(rewardItems, star)
			if panel then panel:popout() end

			local LadybugABTestManager = require 'zoo.panel.newLadybug.LadybugABTestManager'
			if LadybugABTestManager:isNew() then
				local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
				LadybugDataManager:getInstance():onPlaySeasonWeekly()
			end

			panel:setCloseCallBack(function()
				if self.gameBoardLogic.replayMode == ReplayMode.kResume then
					RankRaceMgr:getInstance():openMainPanel()
				end
			end)
			local data = {id = self.levelId,levelType = levelType}
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReturnFromGamePlay, data))
		elseif levelType == GameLevelType.kYuanxiao2017 or 
			levelType == GameLevelType.kFourYearsor or
			levelType == GameLevelType.kSummerFish then
			
			GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
				star = star,
			})
		elseif levelType == GameLevelType.kSpring2017 then

			GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
				ingameTargetCount = ingameTargetCount,
				targetAddNum = ndAddNum,
				targetAddition = ndAddition,
			})
		elseif levelType == GameLevelType.kOlympicEndless then
			GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
			})
		elseif levelType == GameLevelType.kMidAutumn2018 then
		 	GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 	
				targetCount = targetCount,	
				targetsGrp = ZQManager.getInstance():getTargetPieceIndexes()
			})
        elseif levelType == GameLevelType.kJamSperadLevel  then
            GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				star = star,
			})
		else
			local pigYearLevelIndex = PigYearLogic.datas.nextActLevelIndex
			PigYearLogic.pigYearLevelIndex = pigYearLevelIndex

            if SpringFestival2019Manager.getInstance():getCurIsAct() then
                 --停掉成就分享
                ShareManager:disableShareUi()
            end

            if levelType == GameLevelType.kSpring2019  then

                local step = 0
                if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
                    step = SpringFestival2019Manager.getInstance().EndMoveStep
                end

                GamePlayEvents.dispatchPassLevelEvent({
	                    levelType = self.levelType, 
					    levelId = self.levelId, 
	                    star = star,
					    leftStep = step, 
				    })
            end
			-----------------------------
			-- Popout Game Success Panel
			-- --------------------------
			--panelType,panelTypeData
			local levelSuccessPanel = nil

			--[[
			if self.gameBoardLogic and self.gameBoardLogic.gameMode and self.gameBoardLogic.gameMode:is(OlympicHorizontalEndlessMode) then
				local distance = targetCount or 0
				levelSuccessPanel = LevelSuccessPanel:create(levelId, levelType, score, rewardItems, coin, activityForceShareData ,
					LevelSuccessPanelTpye.kOlympic , { distance = distance }
					)
			else
				levelSuccessPanel = LevelSuccessPanel:create(levelId, levelType, score, rewardItems, coin, activityForceShareData)
			end
			]]

			levelSuccessPanel = LevelSuccessPanel:create(levelId, levelType, score, rewardItems, coin, activityForceShareData, nil, nil, buffUpgrade)
			
			--self.mainLogic.olympicScore	
			

			-- Set The Star Pop Position And Star Size
			local bigStarSize	= self.scoreProgressBar:getBigStarSize()
			local bigStarPosTable	= self.scoreProgressBar:getBigStarPosInWorldSpace()

			for index = 1,#bigStarPosTable do
				local posX = bigStarPosTable[index].x
				local posY = bigStarPosTable[index].y
				levelSuccessPanel:setStarInitialPosInWorldSpace(index, ccp(bigStarPosTable[index].x, bigStarPosTable[index].y))
			end

			for index = 1,#bigStarPosTable do
				levelSuccessPanel:setStarInitialSize(index, bigStarSize.width, bigStarSize.height)
			end

			-- Set The Hide Star Callback
			local function hideScoreProgressBarStarCallback(starIndex, ...)
				assert(type(starIndex) == "number")
				assert(#{...} == 0)

				self.scoreProgressBar:setBigStarVisible(starIndex, false)
			end
			levelSuccessPanel:registerHideScoreProgressBarStarCallback(hideScoreProgressBarStarCallback)

			levelSuccessPanel:popout()

            require "zoo.localActivity.PigYear.PigYearStartGame"
		    PigYearStartGame:decorateLevelEnd(levelSuccessPanel,true)
		end

		if GameSpeedManager:getGameSpeedSwitch() > 0 then
			GameSpeedManager:resuleDefaultSpeed()
		end

		self.gameBoardLogic:releasReplayReordPreviewBlock()

		if self.replayRecordController and self.replayRecordController:isRecording() then
			self.replayRecordController:stopWithPreview()
		end
	end

	local isNewBranchUnlock = self:checkHiddenAreaUnlockAchievement(levelId, levelType, star)
	self:checkScoreAndCompleteAchievement(score)

	PrePropRemindPanelModel:resetCounter()

	--五一活动
	local QixiManager = require 'zoo.eggs.QixiManager'

	local extraData = {}
    local DataEx = {}
	if levelType == GameLevelType.kOlympicEndless then

		local useFreePropFlag = "false"

		local activityModel = self.activityStageData
		if activityModel and activityModel.getUsedFreePropFlag then
			-- local model = ThirdAnniversaryModel:getInstance()
			if activityModel:getUsedFreePropFlag() then
				useFreePropFlag = "true"
			end
		end

		extraData.passedCol = tostring(self.gameBoardLogic.passedCol) .. "," .. useFreePropFlag
	elseif levelType == GameLevelType.kMidAutumn2018 then 
		-- self.gameBoardLogic.passedCol
		extraData.passedCol = ZQManager.getInstance():getTargetPieceIndexes()
	elseif levelType == GameLevelType.kSpring2017 then
		if self.gameBoardLogic.gameMode.getGameExtraData then
			extraData = self.gameBoardLogic.gameMode:getGameExtraData()
			extraData.orin = ingameTargetCount
			extraData.finn = targetCount
			extraData.addn = ndAddNum
			extraData.addp = ndAddition
		end
	elseif QixiManager:getInstance():shouldSeeRose() then
		extraData = {'qixi2017'}
	elseif CountdownPartyManager.getInstance():isActivitySupportAll() then 
		extraData = CountdownPartyManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum)
--    elseif DragonBuffManager.getInstance():isActivitySupportAll() then 
--		extraData = DragonBuffManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum*10)
--    elseif Qixi2018CollectManager.getInstance():isActivitySupportAll() 
--        or Qixi2018CollectManager.getInstance():isActivityOppoRankSupport() then 
--		extraData = Qixi2018CollectManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum*10)
    elseif Thanksgiving2018CollectManager.getInstance():isActivitySupportAll() then 
		extraData = Thanksgiving2018CollectManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum*10)
	end

	local safeFlag = 0
	if self.gameBoardLogic.randFactory and self.gameBoardLogic.randFactory.hasModifyAct then
		safeFlag = safeFlag + 1 -- 1<<0
		DcUtil:UserTrack({category="user_modify",sub_category="rand_factory",levelId=levelId,score=score})
	end

	local isGuideLevel = GameGuide:isNoPreBuffLevel(levelId)
	
	local strategyInfo = LevelStrategyManager.getInstance():getStrategyInfo(self.gameBoardLogic.leftMoves, star)
	strategyInfo = table.serialize(strategyInfo)
	local costMove = self.gameBoardLogic.realCostMove
	if levelType == GameLevelType.kFourYears then
		local model = self.activityStageData
		local mainId, subId = model:convertLevelId(levelId)
		model:setStageData(subId, targetCount, star >= 3 and true or false)

		if levelId % 100 % 3 == 0 then
			local data = model:getStageData()
			if not extraData then extraData = {} end
			if data.level_1 then table.insert(extraData, levelId - 2) end
			if data.level_2 then table.insert(extraData, levelId - 1) end
			if data.level_3 then table.insert(extraData, levelId) end
			if #extraData == 0 then extraData = nil end
			targetCount = targetCount + data.score_extra
		end 
    elseif levelType == GameLevelType.kSummerFish then
		local model = self.activityStageData
		local mainId, subId = model:convertLevelId(levelId)
		model:setStageData( subId, targetCount, star, levelId )

		if levelId % 100 % 3 == 0 then
			local data = model:getStageData()
			local FishExtraData = {}
			if data.level_1 then table.insert(FishExtraData, data.level_1 ) end
			if data.level_2 then table.insert(FishExtraData, data.level_2 ) end
			if data.level_3 then table.insert(FishExtraData, data.level_3 ) end
			targetCount = targetCount + data.score_extra
            DataEx.SummerFishData = FishExtraData
		end 
	end

	local passLevelLogic = PassLevelLogic:create(levelId,
							score,
							star,
							stageTime,
							coin,
							targetCount, 
							opLog,
							levelType,
							costMove,
							extraData,
							onSendPassLevelMessageSuccessCallback,
							safeFlag,
							self.gameBoardLogic.randomSeed , 
							LevelDifficultyAdjustManager:getCurrStrategyID() ,
							nil ,
							self.gameBoardLogic.initAdjustData,
							strategyInfo,
							isGuideLevel,
                            DataEx)
	passLevelLogic:start()

	local uid = UserService.getInstance().user.uid
	local useItem = 0
	if StageInfoLocalLogic:hasUsePropInLevel(uid) then 
		useItem = 1
	end
	local stageState = StageInfoLocalLogic:getStageState(uid)
	self:logStageEnd(levelId, score, star, 0, stageTime, useItem, stageState, originTotalTargetCount, targetCount)
	SnapshotManager:passLevel( self.gameBoardLogic , true )

    if levelType == GameLevelType.kMoleWeekly then
        DcUtil:logMoleWeekStageEnd()
    end

	GameGuideData:sharedInstance():addToPassedLevelIds( tostring(levelId) )
	GameGuideData:sharedInstance():writeToFile()

	Notify:dispatch("AchiEventDataUpdate", AchiDataType.kUnlockHideLevel, isNewBranchUnlock or false)


	_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterPassOrFailLevel, {
		levelId = levelId,
		targetCount = targetCount,
		star = star,
		oldStar = GamePlayContext:getInstance().levelInfo.oldStar,
		levelType = levelType,
		isGuideLevel = isGuideLevel,
		passLevel = true,
		hadPassed = hadPassed,
	}))


	-- local playInfo = GamePlayContext:getInstance():getPlayInfo()
	-- printx(61, 'playInfo begin')
	-- printx(61, playInfo.line_cover)	
	-- printx(61, playInfo.line_match_swap)	
	-- printx(61, playInfo.line_line_swap)	
	-- printx(61, playInfo.line_wrap_swap)	
	-- printx(61, playInfo.bird_line_swap)
	-- printx(61, 'end')

	GamePlayContext:getInstance():endLevel()
end

function NewGamePlaySceneUI:logStageQuit(levelId, score, star, isRestart, stageTime, useItem, stageState, originTotalTargetCount, targetCount)
	stageTime = stageTime or 0
	CollectStarsManager.getInstance():setFailReason( -1 ,levelId )
	local failCount1 , failCount2 = FUUUManager:getLevelFailNumBeforeFirstPass( levelId )
	local historyMaxContinuousFailuresNum = FUUUManager:getLevelHistoryMaxContinuousFailuresNum( levelId )
	DcUtil:logStageQuit(levelId, score, star, isRestart, stageTime, self.gameBoardLogic.leftMoves , useItem , stageState , 
		failCount1 , failCount2 , historyMaxContinuousFailuresNum)
end

function NewGamePlaySceneUI:logStageEnd(levelId, score, star, failReason, stageTime, useItem, stageState, originTotalTargetCount, targetCount)
	stageTime = stageTime or 0
	failReason = failReason or 0
	CollectStarsManager.getInstance():setFailReason( failReason ,levelId)
	local failCount1 , failCount2 = FUUUManager:getLevelFailNumBeforeFirstPass( levelId )
	local historyMaxContinuousFailuresNum = FUUUManager:getLevelHistoryMaxContinuousFailuresNum( levelId )
	DcUtil:logStageEnd(levelId, score, star, failReason, stageTime, self.gameBoardLogic.leftMoves , useItem , stageState , 
		failCount1 , failCount2 , historyMaxContinuousFailuresNum, originTotalTargetCount, targetCount)
end 

function NewGamePlaySceneUI:logFriendHelpStageQuit(levelId, score, star, isRestart, stageTime, useItem, stageState, originTotalTargetCount, targetCount)
	stageTime = stageTime or 0
	CollectStarsManager.getInstance():setFailReason( -1 ,levelId )
	local failCount1 , failCount2 = FUUUManager:getLevelFailNumBeforeFirstPass( levelId )
	local historyMaxContinuousFailuresNum = FUUUManager:getLevelHistoryMaxContinuousFailuresNum( levelId )
	DcUtil:logFriendHelpStageQuit(levelId, score, star, isRestart, stageTime, self.gameBoardLogic.leftMoves , useItem , stageState , 
		failCount1 , failCount2 , historyMaxContinuousFailuresNum)
end

function NewGamePlaySceneUI:failLevel(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)


	-- assert(type(levelId) 	== "number")
	-- assert(type(score)	== "number")
	-- assert(type(star)	== "number")
	-- assert(type(stageTime))
	-- assert(type(coin))
	-- assert(type(isTargetReached)	== "boolean")
	-- assert(#{...} == 0)

	local hadPassed = UserManager:getInstance():hasPassedLevelEx(levelId)

	GamePlayContext:getInstance().levelInfo.lastPlayResult = false
	GamePlayContext:getInstance():onLevelWillEnd()

	if self.isGameGuideDebugMode then
		self:forceQuitPlay()
		return
	end

	if self:isReplayMode() then
		self:replayResult(levelId, score, star, coin, targetCount, bossCount , false , failReason)
		return
	end

	--------------好友代打--------------
	if AskForHelpManager:getInstance():isInMode() then
		return self:failLevelAFH(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)
	end
	
	if self.levelType == GameLevelType.kMainLevel then 
		AskForHelpManager.getInstance():onFailLevel(self.levelId)
		PrePropImproveLogic:onLevelEnd(false,self.levelId)
	end
	-----------------------------------


	


	IOSScoreGuideFacade:getInstance():setPassLevelState(kPassLevelState.kFail)

	local levelType = self.levelType
	-- ----------------------------------
	-- Ensure Only Call This Func Once
	-- ----------------------------------
	assert(not self.levelFinished, "only call this function one time !")
	if not self.levelFinished then
		self.levelFinished = true
	end

	if levelType == GameLevelType.kMayDay and star > 0 then
		GamePlayEvents.dispatchPassLevelEvent(
			{
				levelType=self.levelType, 
				levelId=self.levelId, 
				rewardsIdAndPos={{itemId = 11, num = targetCount}}, 
				isPlayNextLevel=false
			})
	elseif levelType == GameLevelType.kOlympicEndless or levelType == GameLevelType.kMidAutumn2018 then
		GamePlayEvents.dispatchPassLevelEvent(
			{
				levelType=self.levelType, 
				levelId=self.levelId, 
				rewardsIdAndPos={}, 
				isPlayNextLevel=false
			})
	end

	local function onGuideFinish(accepted, propId)
		self:onPrePropGuideFinish(accepted, propId, failReason, true)
	end
	-- 移动步数
	local costMove = self.gameBoardLogic.realCostMove

	local uid = UserService.getInstance().user.uid
	local useItem = 0
	if StageInfoLocalLogic:hasUsePropInLevel(uid) then 
		useItem = 1
	end

	local function onPassLevelMsgSuccess(event)
		assert(event)
		assert(event.name == Events.kComplete)
		assert(event.data)

		if CountdownPartyManager.getInstance():isActivitySupportAll() then 
			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
				CountdownPartyManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum)
			end
		end

--        if DragonBuffManager.getInstance():isActivitySupportAll() then 
--			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
--                DragonBuffManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum)
--			end
--		end

--        if Qixi2018CollectManager.getInstance():isActivitySupportAll() 
--            or Qixi2018CollectManager.getInstance():isActivityOppoRankSupport() then 
--			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
--                Qixi2018CollectManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum)
--			end
--		end

        if Thanksgiving2018CollectManager.getInstance():isActivitySupportAll() then 
			if self.gameBoardLogic and self.gameBoardLogic.actCollectionNum and self.gameBoardLogic.actCollectionNum > 0 then 
                Thanksgiving2018CollectManager.getInstance():CollectDC( self.gameBoardLogic.actCollectionNum )
                Thanksgiving2018CollectManager.getInstance():addCollectionNum(self.gameBoardLogic.actCollectionNum)
			end
            Thanksgiving2018CollectManager.getInstance():setLevelPass( levelId )
		end

        if SpringFestival2019Manager.getInstance():getCurIsAct() then 
--            PigYearLogic:afterPassLevel( levelId )
            SpringFestival2019Manager.getInstance():getPassLevelCanGet( false, 0 )

            local Reward = SpringFestival2019Manager:getInstance():getCurLevelPassCanGetInfo( false )
            PigYearLogic:addPassLevelRewards(Reward)

            --打点
            SpringFestival2019Manager.getInstance():DCForStageEnd()
        end

        if TurnTable2019Manager.getInstance():getCurIsAct() then 
            TurnTable2019Manager.getInstance():setLevelPlayedCount(levelId)
        end

		local function refreshDifficultyTagResult(result)
			if not result then
				SyncManager:getInstance():sync()
			end
		end
		SyncManager:getInstance():sync()


		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterPassOrFailLevel, {
			levelId = levelId,
			targetCount = targetCount,
			star = star,
			oldStar = GamePlayContext:getInstance().levelInfo.oldStar,
			levelType = self.levelType,
			-- isGuideLevel = isGuideLevel,
			passLevel = false,
			hadPassed = hadPassed,
		}))
		

		if self.levelType == GameLevelType.kYuanxiao2017 then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 					
			})
		elseif self.levelType == GameLevelType.kFourYears then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = 0,
				star = 0,
			})
        elseif self.levelType == GameLevelType.kSummerFish then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = 0,
				star = 0,
			})
		elseif self.levelType == GameLevelType.kSpring2017 then
			GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
			})
		elseif self.levelType == GameLevelType.kMidAutumn2018 then
		 	GamePlayEvents.dispatchPassLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 	
				targetCount = targetCount,	
				targetsGrp = ZQManager.getInstance():getTargetPieceIndexes()
			})
        elseif self.levelType == GameLevelType.kJamSperadLevel then
		 	GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId,
			})
		else
--			if self.levelType == GameLevelType.kSpring2019  then
--	            GamePlayEvents.dispatchFailLevelEvent({
--	                levelType = self.levelType, 
--					levelId = self.levelId,
--					leftStep = self.gameBoardLogic.theCurMoves, 
--				})
--	        end

			local failReasonType, failDesValue = LevelFailTopPanel:getFailResonAndDes(levelId, failReason, isTargetReached)
			local stageState = StageInfoLocalLogic:getStageState(uid)

			self:logStageEnd(levelId, score, star, failReasonType, stageTime, useItem , stageState)
			
			if PrePropImproveLogic:tryTriggerGuide(levelId, levelType, failReason, onGuideFinish) then
			else
				local levelFailPanel = LevelFailPanel:create(levelId, levelType, score, star, isTargetReached, failReason, stageTime, costMove)
				levelFailPanel:popout(false)

                require "zoo.localActivity.PigYear.PigYearStartGame"
			    PigYearStartGame:decorateLevelEnd(levelFailPanel,false)
			end
			ShareManager:onFailLevel(levelId, score)
			InciteManager:onPassLevel()
		end
		

		UserTagManager:refreshDifficultyTag( levelId , nil , UserTagDCSource.kPassLevel)

		if GameSpeedManager:getGameSpeedSwitch() > 0 then
			GameSpeedManager:resuleDefaultSpeed()
		end
		
		local updateLevelScoreLogic = UpdateLevelScoreLogic:create(levelId, levelType, 0, 0)
		updateLevelScoreLogic:start()
	end

	local function onPassLevelMsgFailed()
        if SpringFestival2019Manager.getInstance():getCurIsAct() then 
--            PigYearLogic:afterPassLevel( levelId )
            SpringFestival2019Manager.getInstance():getPassLevelCanGet( false, 0 )
        end

		--assert(false)
		if self.levelType == GameLevelType.kYuanxiao2017 then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 					
			})
		elseif self.levelType == GameLevelType.kFourYears then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
				star = 0,
				isFail = true,
			})
        elseif self.levelType == GameLevelType.kSummerFish then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
				star = 0,
				isFail = true,
			})
		elseif self.levelType == GameLevelType.kSpring2017 then
			GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 
				targetCount = targetCount,
				isFail = true,
			})
		elseif self.levelType == GameLevelType.kMidAutumn2018 then
		 	GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId, 	
				targetCount = targetCount,	
				targetsGrp = ZQManager.getInstance():getTargetPieceIndexes(),
				isFail = true,
			})
        elseif self.levelType == GameLevelType.kJamSperadLevel then
		 	GamePlayEvents.dispatchFailLevelEvent({
				levelType = self.levelType, 
				levelId = self.levelId,
				isFail = true,
			})
        elseif levelType == GameLevelType.kSpring2019  then

            local step = 0
            if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
                step = SpringFestival2019Manager.getInstance().EndMoveStep
            end

            GamePlayEvents.dispatchFailLevelEvent({
                levelType = self.levelType, 
				levelId = self.levelId,
				leftStep = step, 
                isFail = true,
			})
		else
			local failReasonType, failDesValue = LevelFailTopPanel:getFailResonAndDes(levelId, failReason, isTargetReached)
			local stageState = StageInfoLocalLogic:getStageState(uid)
			self:logStageEnd(levelId, score, star, failReasonType, stageTime, useItem, stageState)
			if PrePropImproveLogic:tryTriggerGuide(levelId, levelType, failReason, onGuideFinish) then

			else
				local levelFailPanel = LevelFailPanel:create(levelId, levelType, score, star, isTargetReached, failReason, stageTime, costMove)
				levelFailPanel:popout(false)
			end
			ShareManager:onFailLevel(levelId, score)
			InciteManager:onPassLevel()
		end
	end

	PrePropRemindPanelModel:sharedInstance():increaseCounter(self.levelId)

	LevelStrategyManager.getInstance():setLevelFail(levelId)

	local extraData = nil

	---------------------------- QIXI ---------------------------
	local QixiManager = require 'zoo.eggs.QixiManager'
	if QixiManager:getInstance():shouldSeeRose() then
		extraData = {'qixi2017'}
	elseif CountdownPartyManager.getInstance():isActivitySupportAll() then 
		extraData = CountdownPartyManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum)
--    elseif DragonBuffManager.getInstance():isActivitySupportAll() then 
--		extraData = DragonBuffManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum)
--    elseif Qixi2018CollectManager.getInstance():isActivitySupportAll() then 
--		extraData = Qixi2018CollectManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum)
--    elseif  Qixi2018CollectManager.getInstance():isActivityOppoRankSupport()then 
--		extraData = Qixi2018CollectManager.getInstance():getPasslevelOppoExtraData(levelId, star, self.gameBoardLogic.actCollectionNum)
    elseif  Thanksgiving2018CollectManager.getInstance():isActivitySupportAll()then 
		extraData = Thanksgiving2018CollectManager.getInstance():getPasslevelExtraData(levelId, star, self.gameBoardLogic.actCollectionNum)
	end

	local http = PassLevelHttp.new()
	http:addEventListener(Events.kComplete, onPassLevelMsgSuccess)
	http:addEventListener(Events.kError, onPassLevelMsgFailed)

	local initAdjustStr = GameInitDiffChangeLogic:createVirtualSeedDataStr( self.gameBoardLogic.initAdjustData )
	local isGuideLevel = GameGuide:isNoPreBuffLevel(levelId) or failReason == 'refresh'

	if star < 1 then
		http.logicalFail = true
	end

	http:load(levelId, score, star, stageTime, coin, targetCount, opLog, levelType, costMove, extraData  , nil ,
					self.gameBoardLogic.randomSeed , 
					LevelDifficultyAdjustManager:getCurrStrategyID() ,
					initAdjustStr,
					nil, nil,
					isGuideLevel )
	
	PreBuffLogic:onPassLevel(levelId, 0, isGuideLevel , false , failReason or "failed" )

	--关卡失败 刷新推送召回功能的相关数据
	if self.levelType == GameLevelType.kMainLevel then 
		RecallManager.getInstance():updateRecallInfo()
		-- LocalNotificationManager.getInstance():pocessRecallNotification()
	elseif self.levelType == GameLevelType.kSummerWeekly then
		SeasonWeeklyRaceManager:getInstance():onPassLevel(self.levelId, 0)
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReturnFromGamePlay,{id = self.levelId}))
	elseif self.levelType == GameLevelType.kMoleWeekly then
		RankRaceMgr:getInstance():onPassLevel(self.levelId, 0)
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReturnFromGamePlay,{id = self.levelId}))
	end
	
	self:checkUploadReplayForDiffAdjust( levelId )


	SnapshotManager:passLevel( self.gameBoardLogic , false )

	GamePlayContext:getInstance():endLevel()
end

function NewGamePlaySceneUI:checkUploadReplayForDiffAdjust( levelId )
	
	--RemoteDebug:uploadLogWithTag( "UPLOAD" , "NewGamePlaySceneUI:checkUploadReplayForDiffAdjust !!!" , levelId == UserManager:getInstance().user:getTopLevelId() )

	if levelId == UserManager:getInstance().user:getTopLevelId() then

		--RemoteDebug:uploadLogWithTag( "UPLOAD" , "UPLOAD_1" , MaintenanceManager:getInstance():isEnabledInGroup( "UploadReplayForDiffAdjust" , "UPLOAD_1" , UserManager:getInstance().uid ) )
		--RemoteDebug:uploadLogWithTag( "UPLOAD" , "UPLOAD_2" , MaintenanceManager:getInstance():isEnabledInGroup( "UploadReplayForDiffAdjust" , "UPLOAD_2" , UserManager:getInstance().uid ) )

		if (	
				MaintenanceManager:getInstance():isEnabledInGroup( "UploadReplayForDiffAdjust" , "UPLOAD_1" , UserManager:getInstance().uid ) 
				and math.random( 1 , 100000 ) <= 1
			) or MaintenanceManager:getInstance():isEnabledInGroup( "UploadReplayForDiffAdjust" , "UPLOAD_2" , UserManager:getInstance().uid )
		then
			
			local topLevelFailCounts = UserTagManager:getTopLevelLogicalFailCounts()
			local strategyIDList = LevelDifficultyAdjustManager:getStrategyIDList() or {}
			local strategyID = 0

			if strategyIDList[ #strategyIDList ] and strategyIDList[ #strategyIDList ].id then
				strategyID = strategyIDList[ #strategyIDList ].id
			end
			--RemoteDebug:uploadLogWithTag( "UPLOAD" , "topLevelFailCounts" , topLevelFailCounts , "strategyID" , strategyID )

			if topLevelFailCounts > 30 and strategyID >= 13000000 then
				local replay = ReplayDataManager:getCurrLevelReplayData()

				replay.sectionData = nil
				replay.lastSectionData = nil

				local tableStr = table.serialize( replay )

				DcUtil:uploadReplayData("upload_replay_forDiffAdjust", 
					HeMathUtils:base64Encode(tableStr, string.len(tableStr)) , 
					replay.info , replay.ver , replay.level , replay.passed , replay.score , replay.currTime , #replay.replaySteps )

			end
		end

	end
end

function NewGamePlaySceneUI:onReplayErrorOccurred(errorId, error)
	-- printx(1, "NewGamePlaySceneUI:onReplayErrorOccurred:  ", table.tostring(error))

	if self:isReplayMode() then 
		if self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kQACheck then 
			self.gameBoardLogic.replayError = error
			local function endReplay()
				if self.replayMode == ReplayMode.kCheck and CheckPlay then
					CheckPlay:checkResult(errorId , {} , self.gameBoardLogic)
				elseif self.replayMode == ReplayMode.kQACheck then 
					QACheckPlayManager.getInstance():updateLastResult(errorId)
					setTimeOut(function ()
						QACheckPlayManager.getInstance():check()
					end, 0.1)
				end
				self:endReplay()
			end
			setTimeOut(endReplay, 0.1)
		elseif self.replayMode == ReplayMode.kResume then 

			self:onResumeReplayEnd()
			self.replayMode = ReplayMode.kNone
			self.gameBoardLogic.replaying = false
			--local text = {tip = "我已经尽力帮你恢复了，接下来就靠你了", yes = "好哒"}
			--CommonTipWithBtn:showTip( text , 1 , nil, nil , nil , true )

			--local panel = CrashResumePanel:create( CrashResumePanelType.kFailedTipPanel , nil , nil )
			--panel:popout()
			--do send DC
		elseif self.replayMode == ReplayMode.kStrategy then 
			self:onStrategyReplayEnd(true)
		elseif self.replayMode == ReplayMode.kMcts then 
			--lua crash
		end
	end
end

function NewGamePlaySceneUI:endReplay() --结束整个replay,退出gamePlayScene
	self:forceQuitPlay()
	if self.replayMode ~= ReplayMode.kCheck then
		GameSpeedManager:resuleDefaultSpeed()
	end
end

function NewGamePlaySceneUI:forceQuitPlay(didQuitGamePlayScene)
	local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene == self then
		if __use_low_effect then 
			FrameLoader:unloadImageWithPlists(self.fileList, true)
		end

		if self.replayMode == ReplayMode.kReview then
			UserReviewLogic:onReplayEnd()
		else
			setTimeOut(function()
					Director:sharedDirector():popScene()
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kExceptionReturnFromGamePlay))
					if type(didQuitGamePlayScene) == "function" then
						setTimeOut(didQuitGamePlayScene, 0)
					end
				end, 0)
		end
	end
	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()
end

function NewGamePlaySceneUI:onReplayEnd()
	if type(self.onReplayEndHandler) == "function" then
		self:onReplayEndHandler()
	end
end

--[[
function NewGamePlaySceneUI:onGameAnimOver()
	local result = GamePlaySceneUI.onGameAnimOver(self)

	if self.replayMode == ReplayMode.kResume then
		--self:onResumeReplayStart()
	end

	return result
end
]]

function NewGamePlaySceneUI:onReplayProgressChanged(curr , total)
	if self.replayMode == ReplayMode.kResume and self.ResumeReplayBlocker and self.ResumeReplayBlocker.animation then
		self.ResumeReplayBlocker.animation:updateProgress(curr , total)
	elseif self.replayMode == ReplayMode.kStrategy then 
		LevelStrategyLogic:updateProgress(curr , total)
	end
end


function NewGamePlaySceneUI:onResumeReplayStart()

	if self.replayMode == ReplayMode.kReview then
		UserReviewLogic:attachMenu(self)
		return
	end

	--printx( 1 , "NewGamePlaySceneUI:onResumeReplayStart  ==================  1")
	if (self.replayMode ~= ReplayMode.kResume and self.replayMode ~= ReplayMode.kSectionResume) or not CrashResumeGamePlaySpeedUp then
		return
	end
	--printx( 1 , "NewGamePlaySceneUI:onResumeReplayStart  ==================  2")
	local containnerLayer = Layer:create()
	local wSize = Director:sharedDirector():getWinSize()
	local trueMask = LayerColor:create()
	trueMask:changeWidthAndHeight(wSize.width, wSize.height)
	trueMask:setTouchEnabled(true, 0, true)
	trueMask:setOpacity( 255 / 0.7 )

	require "zoo.scenes.CrashResumeProgressAnimation"
	local anim = nil
	if self.replayMode == ReplayMode.kResume then
		anim = CrashResumeProgressAnimation:create(1)
	elseif self.replayMode == ReplayMode.kSectionResume then
		anim = CrashResumeProgressAnimation:create(2)
	end
	anim:setPositionXY( wSize.width / 2 , wSize.height / 2 )
	--printx( 1 , "NewGamePlaySceneUI:onResumeReplayStart  ==================  3")

	local function clickCallback()

		DcUtil:crashResumeEnd( 3 , self.levelId , self.gameBoardLogic.replayStep , 
				UserManager.getInstance().user.uid , udid , self.replayData.uid , self.replayData.udid , self.replayDataMD5 , totalSteps)--恢复过程中，主动放弃结束恢复

		self:endReplay()
		local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
		local totalSteps = 0
		if self.gameBoardLogic.replaySteps then
			totalSteps = #self.gameBoardLogic.replaySteps
		end
		
	end

	containnerLayer:addChild(trueMask)
	containnerLayer:addChild(anim)

	if self.replayMode == ReplayMode.kResume then
		local closeUI = CrashResumeCloseUI:create( clickCallback )
		closeUI:setPositionXY( anim:getPositionX() + 100 , anim:getPositionY() + 130 )

		setTimeOut( function () 
			if containnerLayer and not containnerLayer.isDisposed then
				containnerLayer:addChild(closeUI)
			end
		end , 0.8 )

		containnerLayer.closeUI = closeUI
	end

	containnerLayer.animation = anim

	self:superAddChild(containnerLayer)

	self.ResumeReplayBlocker = containnerLayer
end

function NewGamePlaySceneUI:onResumeReplayEnd()

	if self.replayMode == ReplayMode.kReview then
		UserReviewLogic:detachMenu(self)
		return
	end

	if self.ResumeReplayBlocker then

		local function onremove()
			if self.ResumeReplayBlocker and not self.ResumeReplayBlocker.isDisposed then
				self.ResumeReplayBlocker.animation:removeSelf()
				self:superRemoveChild( self.ResumeReplayBlocker , true )
				self.ResumeReplayBlocker = nil
			end
		end

		if self.ResumeReplayBlocker.closeUI then
			self.ResumeReplayBlocker.closeUI:removeFromParentAndCleanup(true)
		end

		if self.replayMode == ReplayMode.kResume then
			self.ResumeReplayBlocker.animation:changeState( CrashResumeProgressAnimationState.kOut , onremove )
		elseif self.replayMode == ReplayMode.kSectionResume then
			setTimeOut( onremove , 0.6 )
		end
	end

	GameSpeedManager:resuleDefaultSpeed()
	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		GameSpeedManager:changeSpeedForFastPlay()
	end
end
function NewGamePlaySceneUI:quitForStrategyReplay()
	if self.levelType == GameLevelType.kMainLevel or self.levelType == GameLevelType.kHiddenLevel then	
		HomeScene:sharedInstance().worldScene:setEnterFromGamePlay(self.levelId, self.replayMode)	
	end
	Director:sharedDirector():popScene()
	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()
	GamePlayContext:getInstance():endLevel()
end

function NewGamePlaySceneUI:onStrategyReplayEnd(hasError)
	local quitPanel 
	if hasError then 
		LevelStrategyManager.getInstance():cleanLevelReplayData(self.levelId)
		local Panel = require "zoo.gamePlay.levelStrategy.LevelStrategyErrorPanel"
		quitPanel = Panel:create()
	else
		local Panel = require "zoo.gamePlay.levelStrategy.LevelStrategyOverPanel"
		quitPanel = Panel:create()
		quitPanel:setOnReplayBtnTappedCallback(function ()
			LevelStrategyManager:dcClickStrategyReplay(1, self.levelId)

			LevelStrategyManager.getInstance():getReplayData(self.levelId, function (replayInfo)
				if replayInfo then 
					LevelStrategyLogic:playReplay(replayInfo.data, function ()
						self:quitForStrategyReplay()
					end)
				else
					assert(false, "NewGamePlaySceneUI:onStrategyReplayEnd() no replay data?")
				end
			end)
		end)
	end
	quitPanel:setOnQuitGameBtnTappedCallback(function ()
			if hasError then 
				LevelStrategyManager:dcCloseStrategyPlay(-1, self.levelId)
			else
				LevelStrategyManager:dcCloseStrategyPlay(1, self.levelId)
			end
			self:quitForStrategyReplay()
		end)
	quitPanel:popout()
end

function NewGamePlaySceneUI:onReplayEndHandler() --默认逻辑是指replay的步数全部回放完毕了
	if self:isReplayMode() then
		if self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kQACheck then
			local function endReplay()
				if self.checkPlayIsEnd then
					self.checkPlayIsEnd = nil
					return
				end
				if self.replayMode == ReplayMode.kCheck and CheckPlay then
					CheckPlay:checkResult(CheckPlay.RESULT_ID.kNotEnd, {} , self.gameBoardLogic)
				elseif self.replayMode == ReplayMode.kQACheck then
					QACheckPlayManager.getInstance():updateLastResult(CheckPlay.RESULT_ID.kNotEnd)
					setTimeOut(function ()
						QACheckPlayManager.getInstance():check()
					end, 0.1)
				end
				self:endReplay()
			end
			setTimeOut(endReplay, 0.1)
		elseif self.replayMode == ReplayMode.kResume then
			self:onResumeReplayEnd()
			self.replayMode = ReplayMode.kNone
		elseif self.replayMode == ReplayMode.kSectionResume then
			self:onResumeReplayEnd()
			self.replayMode = ReplayMode.kNone
		elseif self.replayMode == ReplayMode.kStrategy then
			self:onStrategyReplayEnd(false)
		-- elseif self.replayMode == ReplayMode.kNormal then
		-- 	self:endReplay()
		elseif self.replayMode == ReplayMode.kReview then
			self:onResumeReplayEnd()
		end
	end
end

function NewGamePlaySceneUI:replayResult( levelId, score, star, coin, targetCount, bossCount , result , failReason )--replay触发了关卡结束或者关卡失败

	if self:isReplayMode() then 
		if self.replayMode == ReplayMode.kCheck or self.replayMode == ReplayMode.kQACheck then
			local ret = {}
			ret.levelId = levelId
			ret.totalScore = score
			ret.star = star
			ret.coin = coin
			ret.bossCount = bossCount or 0
			ret.targetCount = targetCount or 0

			if _G.isLocalDevelopMode then printx(0, "=====================Check Play Result=====================") end
			if _G.isLocalDevelopMode then printx(0, "=====================   Ver   1.0.1   =====================") end
			if _G.isLocalDevelopMode then printx(0, table.tostring(ret)) end
			if _G.isLocalDevelopMode then printx(0, "===========================================================") end

			local function endReplay()
				local retCode = CheckPlay:checkReplayReusltData(ret)
				if self.replayMode == ReplayMode.kCheck and CheckPlay then
					CheckPlay:checkResult(retCode, ret , self.gameBoardLogic)
				elseif self.replayMode == ReplayMode.kQACheck then
					QACheckPlayManager.getInstance():updateLastResult(retCode)
					setTimeOut(function ()
						QACheckPlayManager.getInstance():check()
					end, 0.1)
				end
				self:endReplay()
				self.checkPlayIsEnd = true
			end
			setTimeOut(endReplay, 0.1)
		elseif self.replayMode == ReplayMode.kAuto then
			local function endReplay()
				self:endReplay()
				if _G.__autoPlayCount and _G.__autoPlayCount > 1 then
					local step = {randomSeed = 0, replaySteps = {}, level = levelId, selectedItemsData = {}}
					local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , {} , false , {} )
					newStartLevelLogic:startWithReplay( ReplayMode.kAuto , step )
					_G.__autoPlayCount = _G.__autoPlayCount - 1
				end
			end
			setTimeOut(endReplay, 0.1)
		elseif self.replayMode == ReplayMode.kAutoPlayCheck or self.replayMode == ReplayMode.kConsistencyCheck_Step2 then
			local function doNextPlay()
				AutoCheckLevelManager:nextCheck()
				--GameSpeedManager:changeSpeedForCrashResumePlay()
			end

			local function endReplay()

				local autoCheckLevelFinishReason = nil
				if result then
					autoCheckLevelFinishReason = AutoCheckLevelFinishReason.kFinished
				else
					if failReason == "refresh" then
						autoCheckLevelFinishReason = AutoCheckLevelFinishReason.kFinishedButHasNoSwap
					elseif failReason == "venom" then
						autoCheckLevelFinishReason = AutoCheckLevelFinishReason.kFinishedButHasNoVenom
					else
						autoCheckLevelFinishReason = AutoCheckLevelFinishReason.kFinishedButNotReachOneStar
					end
				end

				AutoCheckLevelManager:onCheckFinish( result , autoCheckLevelFinishReason , self.gameBoardLogic.realCostMove , nil , score )
				self:endReplay()
				setTimeOut( doNextPlay , 0.3)
			end

			setTimeOut(endReplay, 0.1)
		elseif self.replayMode == ReplayMode.kConsistencyCheck_Step1 then

			local currReplayDatas = ReplayDataManager:getCurrLevelReplayData()
			local currSectionDatas = SectionResumeManager:getCurrSectionDatas()

			ReplayAutoCheckManager:setReplayDataInStepOne( currReplayDatas )
			ReplayAutoCheckManager:setSectionDataInStepOne( currSectionDatas )

			local function donextPlay()
				local newStartLevelLogic = NewStartLevelLogic:create( nil , currReplayDatas.level , {} , false , {} )
				newStartLevelLogic:startWithReplay( ReplayMode.kConsistencyCheck_Step2 , currReplayDatas )
				GameSpeedManager:changeSpeedForCrashResumePlay()
			end

			local function endReplay()
				self:endReplay()
				setTimeOut( donextPlay , 0.3)
				--newStartLevelLogic:startWithReplay( ReplayMode.kNormal , currReplayDatas )
			end

			setTimeOut(endReplay, 0.1)
		--[[
		elseif self.replayMode == ReplayMode.kConsistencyCheck_Step2 then

			local currSectionDatas = SectionResumeManager:getCurrSectionDatas()
			ReplayAutoCheckManager:setSectionDataInStepTwo( currSectionDatas )

			local function endReplay()
				self:endReplay()

				local result , datas = ReplayAutoCheckManager:compareResult()

				if result and ReplayAutoCheckManager:needContinueCheck() then
					ReplayAutoCheckManager:saveResult( levelId , true )
					ReplayAutoCheckManager:doCheck( levelId )
				elseif not result then
					ReplayAutoCheckManager:outputResult( false , datas )
				elseif not ReplayAutoCheckManager:needContinueCheck() then
					ReplayAutoCheckManager:outputResult( true )
				end
			end

			setTimeOut(endReplay, 0.1)
		]]
		elseif self.replayMode == ReplayMode.kMcts then
			local function endReplay()
				local function didQuitGamePlayScene()
					startMctsLevel()
				end
				self:forceQuitPlay(didQuitGamePlayScene)
			end
			local currentNode = self.gameBoardLogic.currentNode
			local result = 0
			if self.gameBoardLogic.gameMode:reachTarget() then
				result = 1
			end
			if _G.launchCmds.domain then
				local simplejson = require("cjson")
				local task = _G.cnnTask
				local obj = {
					r = result,
					sc = score,
					st = star,
					s = task.s,
					b = task.b,
					o = ReplayDataManager:getCurrLevelReplayDataCopyWithoutSectionData()
				}
				local redisClient = _G.redisClient
				redisClient:lpush("cnn_result" , simplejson.encode(obj))
			elseif not _G.launchCmds.mock then
				local simplejson = require("cjson")
				local reqObj = {
					method = "status",
					result = result,
					score = score,
					targets = self.levelTargetPanel:getTargets(),
					eliminates = GamePlayContext:getInstance():getPlayInfoForAI(),
					level = levelId,
				}
				local req = simplejson.encode(reqObj)
				StartupConfig:getInstance():sendMsg(req)
			else
				-- local scores = _G.__scores
				-- scores[#scores + 1] = score
				-- table.sort(scores)
				-- local q1Index = #scores / 4
				-- local q1
				-- if math.ceil(q1Index)>q1Index then
				-- 	q1 = scores[math.ceil(q1Index)]
				-- else 
				-- 	q1 = (scores[q1Index] + scores[q1Index + 1]) / 2
				-- end 
				-- local q3Index = #scores * 3 / 4
				-- local q3
				-- if math.ceil(q3Index)>q3Index then
				-- 	q3 = scores[math.ceil(q3Index)]
				-- else 
				-- 	q3 = (scores[q3Index] + scores[q3Index + 1] ) / 2
				-- end 
				-- local maxScore = q3 + 1.5 * (q3 - q1)
				-- local minScore = math.max(0, q1 - 1.5 * (q3 - q1))
				local targets = self.levelTargetPanel:getTargets()
				local targetNum = 0
				local percent = 0
				for i, target in ipairs(targets) do
					percent = percent + math.min(1, (target.sum - target.num) / target.sum)
					targetNum = targetNum + 1
				end

				-- local maxScore = 500000
				-- local minScore = 200000
				-- local signal = math.max(0, math.min(1, (score - minScore) / (maxScore - minScore)))
				-- if score == minScore then
				-- 	signal = 0
				-- end
				signal = percent / targetNum
				signal = math.pow(signal, 2)

				currentNode.sum = currentNode.sum + 1
				currentNode.signal = currentNode.signal + signal--math.pow(signal, 2)
				if not self.gameBoardLogic.playout then
					currentNode.exit = true
				end
				local allChosen = false
				if currentNode.parent.choose then
					allChosen = true
				end
				if result == 1 then
					currentNode.success = currentNode.success + 1
					currentNode.signal = currentNode.signal + 1
				end
				while currentNode.parent do
					currentNode = currentNode.parent
					currentNode.sum = currentNode.sum + 1
					currentNode.signal = currentNode.signal + signal--math.pow(signal, 2)
					if result == 1 then
						currentNode.success = currentNode.success + 1
						currentNode.signal = currentNode.signal + 1
					end
				end
				he_log_error("sum = " .. currentNode.sum)
				he_log_error("success = " .. currentNode.success)
				he_log_error("signal = " .. currentNode.signal)
				if allChosen then
					-- local printNode
					-- printNode = function(currentNode, tab, action)
					-- 	if  currentNode.sum > 0 then
					-- 		for k, v in pairs(currentNode.child) do 
					-- 			printNode(v, tab .. " ", k)
					-- 		end
					-- 		he_log_error(tab .. "action = "  .. (action or ""))
					-- 		he_log_error(tab .. "sum = " .. currentNode.sum)
					-- 		he_log_error(tab .. "success = " .. currentNode.success)
					-- 		he_log_error(tab .. "signal = " .. currentNode.signal)
					-- 		he_log_error(tab .. "choose = " .. (currentNode.choose or ""))
					-- 	end
					-- end
					-- printNode(_G.__root, "")
					-- while currentNode.choose do
					-- 	he_log_error("chosen path:" .. currentNode.choose)
					-- 	currentNode = currentNode.child[currentNode.choose]
					-- end
					he_log_error("chosen path score:" .. score)
					he_log_error("chosen path result:" .. result)
					he_log_error("cost time:" .. (os.time() - _G.__startTime))
					if _G.launchCmds.exit then
						os.exit()
					end
					debug.debug()
				else
					if _G.launchCmds.try and (currentNode.sum % _G.launchCmds.try == 0) then
						while currentNode.choose do
							currentNode = currentNode.child[currentNode.choose]
						end
						local maxUct = -1
						local index = 0
						for k, v in pairs(currentNode.child) do 
							local uct = v.signal / v.sum
							if uct > maxUct then
								maxUct = uct
								index = k
							end
						end
						currentNode.choose = index
						if _G.launchCmds.random then
							currentNode = currentNode.child[index]
							currentNode.child = nil
							currentNode.sum = 0
							currentNode.success = 0
							currentNode.signal = 0
						end
					end
				end
			end
			setTimeOut(endReplay, 0.1)
		elseif self.replayMode == ReplayMode.kReview then
			self:endReplay()
		end
	end
end

function NewGamePlaySceneUI:addStep(levelId, score, star, isTargetReached, isAddStepCallback, panelType , panelTypeData ,...)
	if self:isReplayMode() then

		local canUseAddStep, stepPropId = self.gameBoardLogic:checkReplayCanUseAddStep()
		
		if not canUseAddStep and self.replayMode == ReplayMode.kNormal 
				and self.gameBoardLogic.replayStep < #self.gameBoardLogic.replaySteps then
			canUseAddStep = true
		end

		local function doCallAddStep( ... )

			local stepsAdded = {
				[ItemType.ADD_15_STEP] = 15,
				[ItemType.ADD_1_STEP] = 1,
				[ItemType.ADD_2_STEP] = 2,
			}

			if stepsAdded[stepPropId] then
				isAddStepCallback(true, stepPropId, stepsAdded[stepPropId])
			else
				isAddStepCallback(true)
			end
		end

		if self.replayMode == ReplayMode.kAuto 
			or self.replayMode == ReplayMode.kConsistencyCheck_Step1 
			or self.replayMode == ReplayMode.kConsistencyCheck_Step2
			or self.replayMode == ReplayMode.kAutoPlayCheck
			then
			local function callback()
				if scheduleId then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
				end
				doCallAddStep()
				self:setPauseBtnEnable(true)
			end
			scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0, false)
			return
		end

		if self.replayMode == ReplayMode.kMcts then
			local function callback()
				if scheduleId then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
				end
				isAddStepCallback(false)
				self:setPauseBtnEnable(true)
			end
			scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0, false)
			return
		end

		--printx(1 , "NewGamePlaySceneUI:addStep   self.gameBoardLogic.replayStep = " , self.gameBoardLogic.replayStep)
		local scheduleId 
		--printx(1 , "NewGamePlaySceneUI:addStep   canUseAddStep =" , canUseAddStep)
		if canUseAddStep then
			local function addStepSucCb()
				if self.isDisposed then return end 
				if stepPropId then
					self.gameBoardLogic:countReplayStep()
				end

				doCallAddStep()

				if not table.includes({
					ItemType.ADD_1_STEP,
					ItemType.ADD_2_STEP,
					ItemType.ADD_15_STEP,
				}, stepPropId) then
					PropsModel:instance():addAddStepItemUsedTime()
				end
				self:setPauseBtnEnable(true)
			end  
			local function callback()
				if scheduleId then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
				end
				--printx(1 , "NewGamePlaySceneUI:addStep   WWWFFFF 1  " , self.gameBoardLogic.replayStep , #self.gameBoardLogic.replaySteps )
				if self.gameBoardLogic.replayStep <= #self.gameBoardLogic.replaySteps then 
					--printx(1 , "NewGamePlaySceneUI:addStep   WWWFFFF 2")
					if self.replayMode == ReplayMode.kStrategy then
						if self.gameMode == GameModeType.CLASSIC or self.gameMode == GameModeType.DIG_TIME then 
							addStepSucCb()
						else
							LevelStrategyLogic:handGuideProp(ItemType.ADD_FIVE_STEP, function ()
								if self.isDisposed then return end 
								self.propList:addFakeItemForReplay(ItemType.ADD_FIVE_STEP, -1)
								local size = CCDirector:sharedDirector():getVisibleSize()
								local origin = CCDirector:sharedDirector():getVisibleOrigin()
								local anim = PropsAnimation:createAdd5Anim()
								anim:setPositionX(origin.x + size.width/2)
								anim:setPositionY(origin.y + size.height/2)
								self:addChild(anim)
								anim:addEventListener(Events.kComplete,function()
									addStepSucCb()
								end)
								anim:play()		
							end)
						end
					else
						addStepSucCb()
					end
				else
					isAddStepCallback(false)
				end
			end
			scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0, false)

			if self.levelType == GameLevelType.kSummerWeekly then--周赛的开宝箱
				local manager = SeasonWeeklyRaceManager:getInstance()
				manager:updateGotExtraTargetNum()
				for num = 1, manager:getLeftExtraTargetNum() do 
					for i = 1, 4 do
						if not manager.lottery:getBoxReward(i) then 
							manager.lottery:getNextBoxReward(i)
							manager:setUseExtraTargetNum(1)
							break
						end
					end
				end
			end
			--printx(1 , "NewGamePlaySceneUI:addStep   WWWFFFF 3")
			return
		else

			self.gameBoardLogic.replaying = false
			self:onReplayEnd()

			local udid = MetaInfo:getInstance():getUdid() or "hasNoUdid"
			DcUtil:crashResumeEnd( 4 , self.levelId , self.gameBoardLogic.replayStep - 1 , 
				UserManager.getInstance().user.uid , udid , self.replayData.uid , self.replayData.udid , self.replayDataMD5 )--关卡意外提前失败

			--[[
			local function callback( ... )
				-- body
				if scheduleId then 
					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleId)
				end

				isAddStepCallback(false)
			end
			scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0, false)
			]]
		end
	end


	assert(type(levelId) 	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(type(isTargetReached)	== "boolean")
	assert(type(isAddStepCallback)	== "function")
	assert(#{...} == 0)

	if PropsModel:instance():isAddStepItemMaxUsed() then
		isAddStepCallback(false)
		return
	end

	local useTipText = nil
	local addStepItem = PropsModel:instance():getAddStepItemData()
	if addStepItem and not addStepItem:isMaxUseUnlimited() then
		local canUseTime = addStepItem.maxUsetime - addStepItem.usedTimes
		useTipText = localize("weeklyrace.summer.panel.desc23", {num=canUseTime})
	end

	local addFiveItemType = ItemType.ADD_FIVE_STEP
	local addStep5Number = UserManager:getInstance():getUserPropNumber(ItemType.ADD_FIVE_STEP)
	local addStep5NumberTime = UserManager:getInstance():getUserTimePropNumber(ItemType.TIMELIMIT_ADD_FIVE_STEP)
	if self.levelType == GameLevelType.kSummerWeekly 
        or self.levelType == GameLevelType.kMoleWeekly  then
		addFiveItemType = ItemType.ADD_BOMB_FIVE_STEP
		addStep5Number = UserManager:getInstance():getUserPropNumber(ItemType.ADD_BOMB_FIVE_STEP)
		addStep5NumberTime = 0
    elseif self.levelType == GameLevelType.kJamSperadLevel then
		addFiveItemType = ItemType.JAMSPEARD_ADD_FIVE
		addStep5Number = UserManager:getInstance():getUserPropNumber(ItemType.JAMSPEARD_ADD_FIVE)
		addStep5NumberTime = 0
	end

	local function onUseBtnTapped(propId, propType, isBuyAddFive, isFromLottery)

        self:onGameStable()

		local size = CCDirector:sharedDirector():getVisibleSize()
		local origin = CCDirector:sharedDirector():getVisibleOrigin()

		if not table.includes({
					ItemType.ADD_1_STEP,
					ItemType.ADD_2_STEP,
					ItemType.ADD_15_STEP,
				}, propId) then
      		PropsModel:instance():addAddStepItemUsedTime()
		end


      	--todo 15步可能需要不同的动画

		local function bind( func, obj )
			return function ( ... )
				return function ( ... )
					return func(obj, ...)
				end
			end
		end

		local animCreator = lua_switch(propId){
			[ItemType.ADD_15_STEP] = bind(PropsAnimation.createAdd15Anim, PropsAnimation),
			[ItemType.ADD_1_STEP] = bind(PropsAnimation.createAdd1Anim, PropsAnimation),
			[ItemType.ADD_2_STEP] = bind(PropsAnimation.createAdd2Anim, PropsAnimation),
			default = bind(PropsAnimation.createAdd5Anim, PropsAnimation),
		}

		local anim = animCreator()

		anim:setPositionX(origin.x + size.width/2)
		anim:setPositionY(origin.y + size.height/2)
		self:addChild(anim)

		anim:addEventListener(Events.kComplete,function( ... )
			self.moveOrTimeCounter.addEffect = true

			if GameSpeedManager:getGameSpeedSwitch() > 0 then
				GameSpeedManager:changeSpeedForFastPlay()
			end

			local stepsAdded = {
				[ItemType.ADD_15_STEP] = 15,
				[ItemType.ADD_1_STEP] = 1,
				[ItemType.ADD_2_STEP] = 2,
			}
			
			if stepsAdded[propId] then
				isAddStepCallback(true, propId, stepsAdded[propId])
			else
				isAddStepCallback(true)
			end


			self.moveOrTimeCounter.addEffect = false
		end)
		anim:play()

        local bActivitySupport = SpringFestival2019Manager.getInstance():getCurIsAct()
        if bActivitySupport and ( propId == ItemType.ADD_FIVE_STEP or propId == ItemType.TIMELIMIT_ADD_FIVE_STEP ) then
            local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"

            local info = {}
            table.insert( info, {itemId = PicYearMeta.ItemIDs.GEM_4, num = PicYearMeta.ADDFIVE_ADD_GETNUM}  )
            PigYearLogic:addRewards(info)
            SpringFestival2019Manager.getInstance():addGemNum( 4, PicYearMeta.ADDFIVE_ADD_GETNUM )
        end
        

		local hasTimeProp = addStep5NumberTime and addStep5NumberTime > 0
		
		-- printx(11, "============ !!! isBuyAddFive, hasTimeProp, isFromLottery:", isBuyAddFive, hasTimeProp, isFromLottery)
		-- printx(11, "============ !!! propId, propType:", propId, propType)
		if not (isBuyAddFive and hasTimeProp) and addFiveItemType == ItemType.ADD_FIVE_STEP then
			-- 走使用非限时+5步流程时，需要刷新显示（因为可能购买普通+5礼包）
			-- 直接在+5面板上购买一个并马上使用的，不用刷新显示（一直为0）
			-- 购买+5礼包，其实是通过别的途径买完以后，走使用道具的流程，所以需要刷新显示
			---- update: Lottery获得为什么要算是Buy？？？？？？ 不应该是use吗？？？？？？
			----         不了解那个需求不敢随便改，只能加字段规避了……
			if isFromLottery then
				addStep5Number = UserManager:getInstance():getUserPropNumber(ItemType.ADD_FIVE_STEP)
			else
				if not isBuyAddFive and not hasTimeProp then
					-- 限时+5步不会被购买，不用更新数量
					-- 因为之后要调用useItemWithType，所以显示的数字要额外+1
					addStep5Number = UserManager:getInstance():getUserPropNumber(ItemType.ADD_FIVE_STEP) + 1
				end
			end
			self.propList:setItemNumber(addFiveItemType, addStep5Number)
		end
		
		if not isBuyAddFive or hasTimeProp then
			self.propList:useItemWithType(propId, propType)
		end
		
		self.propList:hideAddMoveItem()

		StageInfoLocalLogic:addPropsUsedInLevel(UserManager:getInstance().uid, propId, isBuyAddFive)

		-- Re Enable Pause Btn
		self:setPauseBtnEnable(true)
	end

	local function onCancelBtnTapped()
		if self.gameBoardLogic and not self.gameBoardLogic.isDisposed then
			if GameSpeedManager:getGameSpeedSwitch() > 0 then
				GameSpeedManager:changeSpeedForFastPlay()
			end
			isAddStepCallback(false)
		else
			he_log_error("onCancelBtnTapped gameBoardLogic is disposed")
		end
	end

	local function onGetLotteryRewards( rewardItems )
		-- body

		for _, rewardItem in ipairs(rewardItems) do

			local needAddToPropList = true
			if ItemType:inPreProp(rewardItem.itemId) or ItemType:inTimePreProp(rewardItem.itemId) then
				if ItemType:getPrePropType(rewardItem.itemId) ~= PrePropType.ADD_TO_BAR then
					needAddToPropList = false
				end
			end

			if needAddToPropList then
				if ItemType:isTimeProp(rewardItem.itemId) then
					local propMeta = MetaManager:getInstance():getPropMeta(rewardItem.itemId)
					if propMeta and propMeta.expireTime then
						local expireTime = Localhost:time() + propMeta.expireTime
						self.propList:addTimeProp(rewardItem.itemId, rewardItem.num, expireTime, ccp(0, 0), nil, '', nil, true)
					end
				else
					self.propList:addItemNumber(rewardItem.itemId, rewardItem.num)
				end
			end
		end
	end

	local function onUpdatePropBarDisplay(propID, newNum)
		-- printx(11, "======== Outer, onUpdatePropBarDisplay:", propID, newNum)
		if ItemType:isTimeProp(propID) then
			local propMeta = MetaManager:getInstance():getPropMeta(propID)
			if propMeta and propMeta.expireTime then
				local expireTime = Localhost:time() + propMeta.expireTime
				self.propList:addTimeProp(propID, newNum, expireTime, ccp(0, 0), nil, '', nil, true)
			end
		else
			self.propList:addItemNumber(propID, newNum)
		end
	end

	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		GameSpeedManager:resuleDefaultSpeed()
	end

	if LevelType:isFourYearsLevel(levelId) then 
		local EndGamePropActivity = require ("activity/FourthAnniversary/src/view/EndGamePropActivity")
		if EndGamePropActivity then
			if EndGamePropActivity:handleActivity(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, nil, onGetLotteryRewards) then 
				return 
			end
		end
	end

    if LevelType:isSummerFishLevel(levelId) then 
		local EndGamePropActivity = require ("activity/NationalDay2018/autoSrc/view/EndGamePropActivity")
		if EndGamePropActivity then
			if EndGamePropActivity:handleActivity(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, nil, onGetLotteryRewards) then 
				return 
			end
		end
	end

    if LevelType:isJamSperadLevel(levelId) then 
		local EndGamePropActivity = require ("activity/Christmas2018/autoSrc/view/EndGamePropActivity")
		if EndGamePropActivity then
			if EndGamePropActivity:handleActivity(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, nil, onGetLotteryRewards) then 
				return 
			end
		end
	end

	local addStepType = 'normal'
	if self.levelType == GameLevelType.kSummerWeekly then
		addStepType = 'SummerWeekly'
		--周赛全部钥匙使用完，走传统的+5步
		if SeasonWeeklyRaceManager:getInstance():getUseExtraTargetNum() >= 4 then
			addStepType = 'normal'
		end
	end

    if self.levelType == GameLevelType.kMoleWeekly then
        addStepType = 'MoleWeekly'
    end

	-- if bNewAddStep then
	-- 	if __ANDROID then
	-- 		WeekRaceEndGamePropAndroidPanel:create(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText)  
	-- 	else
	-- 		WeekRaceEndGamePropIosPanel:create(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText) 
	-- 	end
	-- else
	-- 	if __ANDROID then 
	-- 		EndGamePropAndroidPanel_VerB:create(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, nil, onGetLotteryRewards)
	-- 	else
	-- 		EndGamePropIosPanel_VerB:create(self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, nil, onGetLotteryRewards)
	-- 	end
	-- end

	EndGamePropManager:create(addStepType, self.levelId, self.levelType, addFiveItemType, onUseBtnTapped, onCancelBtnTapped, useTipText, nil, onGetLotteryRewards, onUpdatePropBarDisplay)
end

-------------------------
--显示加时间面板
-------------------------
function NewGamePlaySceneUI:showAddTimePanel(levelId, score, star, isTargetReached, addTimeCallback, ...)

	if self:isReplayMode() then
		self:addStep(levelId, score, star, isTargetReached, addTimeCallback)
		return
	end

	assert(type(levelId) 	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(type(isTargetReached)	== "boolean")
	assert(type(addTimeCallback)	== "function")
	assert(#{...} == 0)
	local function onUseBtnTapped(propId, propType)
		addTimeCallback(true)

		-- Re Enable Pause Btn
		self:setPauseBtnEnable(true)
	end

	local function onCancelBtnTapped()
		addTimeCallback(false)
	end

	-- if __ANDROID then 
	-- 	EndGamePropAndroidPanel_VerB:create(self.levelId, self.levelType, ItemType.ADD_TIME, onUseBtnTapped, onCancelBtnTapped)
	-- else
	-- 	EndGamePropIosPanel_VerB:create(self.levelId, self.levelType, ItemType.ADD_TIME, onUseBtnTapped, onCancelBtnTapped)
	-- end

	EndGamePropManager:create(false, self.levelId, self.levelType, ItemType.ADD_TIME, onUseBtnTapped, onCancelBtnTapped)

end

-------------------------
--显示加兔兔导弹面板
-------------------------
function NewGamePlaySceneUI:showAddRabbitMissilePanel( levelId, score, star, isTargetReached, isAddPropCallback )

	if self:isReplayMode() then
		self:addStep( levelId, score, star, isTargetReached, isAddPropCallback)
		return
	end

	-- body
	local propsNumber = UserManager:getInstance():getUserPropNumber(ItemType.RABBIT_MISSILE)
	local function onUseBtnTapped(propId, propType)
		isAddPropCallback(true)
		self:setPauseBtnEnable(true)

        local bActivitySupport = SpringFestival2019Manager.getInstance():getCurIsAct()
        if bActivitySupport and propId == ItemType.RABBIT_MISSILE  then
            local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"

            local info = {}
            table.insert( info, {itemId = PicYearMeta.ItemIDs.GEM_4, num = PicYearMeta.ADDFIVE_ADD_GETNUM}  )
            PigYearLogic:addRewards(info)
            SpringFestival2019Manager.getInstance():addGemNum( 4, PicYearMeta.ADDFIVE_ADD_GETNUM )
        end
	end

	local function onCancelBtnTapped()
		if _G.isLocalDevelopMode then printx(0, "lyhtest-----------NewGamePlaySceneUI:showAddRabbitMissilePanel:onCancelBtnTapped") end
		isAddPropCallback(false)
	end

	-- if __ANDROID then 
	-- 	EndGamePropAndroidPanel_VerB:create(self.levelId, self.levelType, ItemType.RABBIT_MISSILE, onUseBtnTapped, onCancelBtnTapped)
	-- else
	-- 	EndGamePropIosPanel_VerB:create(self.levelId, self.levelType, ItemType.RABBIT_MISSILE, onUseBtnTapped, onCancelBtnTapped, useTipText)
	-- end

	EndGamePropManager:create(false, self.levelId, self.levelType, ItemType.RABBIT_MISSILE, onUseBtnTapped, onCancelBtnTapped)
	
end

function NewGamePlaySceneUI:playPreGamePropAddToBarAnim(itemData, animFinishCallback , fromGuide)

	if self:isReplayMode() then
		local itemFound, itemIndex = self.propList:findItemByItemID(PropsModel.kTempPropMapping[tostring(itemData.id)])
		if not itemFound then
			local function delayCallback()
				if not self.isDisposed then
					animFinishCallback()
				end
			end
			setTimeOut(delayCallback, 0.1)
			return
		end
		local toPos = self.propList.leftPropList:ensureItemInSight(itemFound, 0.3)

		local anim = PropsAnimation:createAddToBarAnim(toPos)
		anim:setPositionX(itemData.destXInWorldSpace)
		anim:setPositionY(itemData.destYInWorldSpace)
		self:addChild(anim)

		anim:addEventListener(Events.kComplete,function( ... )
			
			self.propList:addFakeItemForReplay( itemData.id , 1   )
			PropsAnimation:playAddToBarEffect(itemFound,animFinishCallback)
		end)

		anim:play()
	else
		GamePlaySceneUI.playPreGamePropAddToBarAnim(self , itemData, animFinishCallback , fromGuide)
	end
end

function NewGamePlaySceneUI:addTmpPropNum( ... )
	--这应该是废弃的方法
	if self:isReplayMode() then

	else
		GamePlaySceneUI.addTmpPropNum(self)
	end
	-- body
	-- self.propList:addFakeAllProp(999)
end

function NewGamePlaySceneUI:addTemporaryItem(itemId, itemNum, fromGlobalPosition, fromGuide ,...)

	if self:isReplayMode() then
		printx(1 , "NewGamePlaySceneUI:addTemporaryItem  " , itemId, itemNum)
		--self.propList:addTemporaryItem(itemId, itemNum, ccp(0,0))
		self.propList:addFakeItemForReplay( itemId , itemNum   )
		return
	end

	assert(#{...} == 0)

	-- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
	-- if _G.isLocalDevelopMode then printx(0, "fromGuide",fromGuide) end
	-- debug.debug()

	local function onSuccessCallback()
		self.propList:addTemporaryItem(itemId, itemNum, fromGlobalPosition)
	end

	local function onFailedCallback()
	end

	if fromGuide then
		onSuccessCallback()
	else
		local http = OpenGiftBlockerHttp.new()
		http:addEventListener(Events.kComplete, onSuccessCallback)
		http:load(self.levelId, {itemId})
	end
end

function NewGamePlaySceneUI:addTimeProp(propId, num, fromGlobalPosition, activityId, text)

	if self:isReplayMode() then

		--local realItemId = ItemType:getRealIdByTimePropId(propId)
		--self.propList:addFakeItemForReplay( realItemId , num   )

		--福袋、道具云块、水塘（活动）获得道具
		--由于获得的不是临时道具而是限时道具，所以replay时不要增加虚假道具，因为道具剩余道具已在背包

		return
	end

	local function onSuccessCallback()
		if _G.isLocalDevelopMode then printx(0, "success call back ..........") end

		local propMeta = MetaManager:getInstance():getPropMeta(propId)
		assert(propMeta)
		if propMeta and propMeta.expireTime then
			local expireTime = Localhost:timeInSec() * 1000 + propMeta.expireTime
			
			if self.gameBoardLogic.levelType == GameLevelType.kSummerWeekly then

				if _G.isLocalDevelopMode then printx(0, "SeasonWeeklyRaceManager addDayly limit") end
				if (tonumber(propId) == 10012) then
					if SeasonWeeklyRaceManager:getInstance().matchData.dailyDropPropCount2 < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing then
						SeasonWeeklyRaceManager:getInstance().matchData:addDailyTimePropCount2(1)
						self.propList:addTimeProp(propId, num, expireTime, fromGlobalPosition, nil,text,true)
					end
				else
					if SeasonWeeklyRaceManager:getInstance().matchData.dailyDropPropCount < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount then
						SeasonWeeklyRaceManager:getInstance().matchData:addDailyTimePropCount(1)
						self.propList:addTimeProp(propId, num, expireTime, fromGlobalPosition, nil,text,true)
					end
				end

				SeasonWeeklyRaceManager:getInstance():flushToStorage()
			else
				self.propList:addTimeProp(propId, num, expireTime, fromGlobalPosition, nil, text,false) 
			end
		end
	end
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>>>NewGamePlaySceneUI:addTimeProp", propId, num) end
	-- debug.debug()
	local shouldGetProp = false
	if self.gameBoardLogic.levelType == GameLevelType.kSummerWeekly then
		if (tonumber(propId) == 10012) then
			if SeasonWeeklyRaceManager:getInstance().matchData.dailyDropPropCount2 < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing then
				shouldGetProp = true
			end
		else
			if SeasonWeeklyRaceManager:getInstance().matchData.dailyDropPropCount < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount then
				shouldGetProp = true
			end
		end

	else
		shouldGetProp = true
	end

	if shouldGetProp then 
		local http = GetPropsInGameHttp.new()
		http:addEventListener(Events.kComplete, onSuccessCallback)
		http:load(self.levelId, {propId}, activityId)
	end
end

function NewGamePlaySceneUI:dispose()
	if self:isReplayMode() then
		StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )
		if CheckPlayCrashListener then
			GlobalEventDispatcher:getInstance():removeEventListener("lua_crash", CheckPlayCrashListener)
			CheckPlayCrashListener = nil
		end
		GamePlaySceneUI.dispose(self)
		return
	end

	GlobalEventDispatcher:getInstance():removeEventListenerByName(kGlobalEvents.kShowReplayRecordPreview)
	if self.replayRecordController then
		self.replayRecordController:dispose()
		self.replayRecordController = nil
	end
	if self.disposResourceCache and self.fileList ~= nil then
		self:unloadResources()

		-- local function checkPngIsUnload( ... )
		-- 	-- body
		-- 	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
		-- end
		-- CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(checkPngIsUnload, 10, false)
	end
	if _G.isLocalDevelopMode then printx(0, '*******************GamePlaySceneUI:dispose') end
	if _G.isLocalDevelopMode then printx(0, '_isQixiLevel = false') end
	if self.quitDcData then
		DcUtil:newLogUserStageQuit(self.quitDcData)
	end
	_isQixiLevel = false -- qixi
	self:onExitGame()

	Scene.dispose(self)

	if self.gamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then
		ZQResourceManager:unloadGameResources()
		ZQManager.getInstance():reset()
	end
	-- StageInfoLocalLogic:clearStageInfo( UserManager.getInstance().user.uid )
	if _G.AutoCheckLeakInLevel and self.autoCheckLeakTag then
		stopObjectRefDebug(self.autoCheckLeakTag)
		dumpObjectRefDebugWithAlert(self.autoCheckLeakTag, true)
	end
end


-- 好友代打
function NewGamePlaySceneUI:passLevelAFH(levelId, score, star, stageTime, coin, targetCount, opLog, bossCount, activityForceShareData, ...)
	assert(type(levelId)	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(type(stageTime)	== "number")
	assert(type(coin)	== "number")
	assert(#{...} == 0)

	-- ???
	assert(not self.levelFinished, "only call this function one time !")

	GamePlayContext:getInstance().levelInfo.lastPlayResult = true
	GamePlayContext:getInstance():onLevelWillEnd()

	if not self.levelFinished then
		self.levelFinished = true
	end

	local levelType = self.levelType

	------------------------
	--- Success Callback
	------------------------
	local function onSendPassLevelMessageSuccessCallback(levelId, score, rewardItems, ...)
		assert(type(levelId) == "number")
		assert(type(score) == "number")
		assert(rewardItems)
		assert(#{...} == 0)

		-- ???
		self.gameBoardLogic:releasReplayReordPreviewBlock()

		if self.replayRecordController and self.replayRecordController:isRecording() then
			self.replayRecordController:stopWithPreview()
		end
	end

	PrePropRemindPanelModel:resetCounter()

	local extraData = {}

	-- ???
	local safeFlag = 0
	if self.gameBoardLogic.randFactory and self.gameBoardLogic.randFactory.hasModifyAct then
		safeFlag = safeFlag + 1 -- 1<<0
		DcUtil:UserTrack({category="user_modify",sub_category="rand_factory",levelId=levelId,score=score})
	end
	
	local costMove = self.gameBoardLogic.realCostMove
	local doneeUid = AskForHelpManager:getInstance():getDoneeUId()

	local logic = PassLevelLogic:create(levelId,
					score,
					star,
					stageTime,
					coin,
					targetCount, 
					opLog,
					levelType,
					costMove,
					extraData,
					onSendPassLevelMessageSuccessCallback,
					safeFlag,
					self.gameBoardLogic.randomSeed, 
					LevelDifficultyAdjustManager:getCurrStrategyID(),
					doneeUid)
	logic:startAFH()

	local uid = UserService.getInstance().user.uid
	local useItem = 0
	if StageInfoLocalLogic:hasUsePropInLevel(uid) then 
		useItem = 1
	end
	local stageState = StageInfoLocalLogic:getStageState(uid)

	local failCount1 , failCount2 = FUUUManager:getLevelFailNumBeforeFirstPass( levelId )
	local historyMaxContinuousFailuresNum = FUUUManager:getLevelHistoryMaxContinuousFailuresNum( levelId )
	DcUtil:logFriendHelpStageEnd(levelId, score, star, 0, stageTime, self.gameBoardLogic.leftMoves , useItem , stageState , 
		failCount1 , failCount2 , historyMaxContinuousFailuresNum, doneeUid)


	_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, {
		levelId = levelId,
		targetCount = targetCount,
		levelType = levelType,
		passLevel = true,
	}))

	-- 前边的logic:startAFH()是异步操作 GamePlayContext:getInstance():endLevel() 应该在异步 操作完成后 
	-- GamePlayContext:getInstance():endLevel() 
	
	if GameSpeedManager:getGameSpeedSwitch() > 0 then
		GameSpeedManager:resuleDefaultSpeed()
	end

end

function NewGamePlaySceneUI:failLevelAFH(levelId, score, star, stageTime, coin, targetCount, opLog, isTargetReached, failReason, ...)
	assert(type(levelId) == "number")
	assert(type(score) == "number")
	assert(type(star) == "number")
	assert(type(stageTime))
	assert(type(coin))
	assert(type(isTargetReached) == "boolean")
	assert(#{...} == 0)
	GamePlayContext:getInstance().levelInfo.lastPlayResult = false
	GamePlayContext:getInstance():onLevelWillEnd()
	AskForHelpManager.getInstance():onFailLevel(levelId)

	local function onAFHQuiteFinished()
		Director:sharedDirector():popScene()
	end

	local function onPassLevelMsgSuccess(event)
		assert(event)
		assert(event.name == Events.kComplete)
		assert(event.data)

		SyncManager:getInstance():sync()

		local uid = UserService.getInstance().user.uid
		local useItem = 0
		if StageInfoLocalLogic:hasUsePropInLevel(uid) then 
			useItem = 1
		end

		local doneeUid = AskForHelpManager:getInstance():getDoneeUId()
		DcUtil:logFriendHelpStageEnd(levelId, score, star, 0, stageTime, self.gameBoardLogic.leftMoves , useItem , stageState , 
										failCount1 , failCount2 , historyMaxContinuousFailuresNum, doneeUid)
		
		local logic = require 'zoo.panel.askForHelp.logic.AskForHelpLevelFailedLogic'
		logic:create(levelId, onAFHQuiteFinished):start()

		GamePlayContext:getInstance():endLevel()

		if GameSpeedManager:getGameSpeedSwitch() > 0 then
			GameSpeedManager:resuleDefaultSpeed()
		end
	end

	local function onPassLevelMsgFailed()
		local logic = require 'zoo.panel.askForHelp.logic.AskForHelpLevelFailedLogic'
		logic:create(levelId, onAFHQuiteFinished):start()

		GamePlayContext:getInstance():endLevel()
	end

	-- ???
	assert(not self.levelFinished, "only call this function one time !")
	if not self.levelFinished then
		self.levelFinished = true
	end

	-- ???
	PrePropRemindPanelModel:sharedInstance():increaseCounter(self.levelId)



	_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, {
		levelId = levelId,
		targetCount = targetCount,
		levelType = self.levelType,
		passLevel = false,
	}))

	local extraData = nil
	local costMove = self.gameBoardLogic.realCostMove
	local levelType = self.levelType
    local doneeUid = AskForHelpManager:getInstance():getDoneeUId()

	local http = AFHPassLevelHttp.new()
	http:addEventListener(Events.kComplete, onPassLevelMsgSuccess)
	http:addEventListener(Events.kError, onPassLevelMsgFailed)
	http:load(levelId, score, star, stageTime, coin, targetCount, opLog, levelType, costMove, extraData, 0, doneeUid, false)
end

function NewGamePlaySceneUI:onPrePropGuideFinish(accepted, propId, failReason, isFailLevel)
	if isFailLevel then
		local function popScene()
			if self.levelType == GameLevelType.kMainLevel 
					or self.levelType == GameLevelType.kHiddenLevel then	
				HomeScene:sharedInstance():setEnterFromGamePlay(self.levelId)
			end
			Director:sharedDirector():popScene()
		end
		if accepted then
			self:popReplayPanel(popScene, propId , isFailLevel)
		else
			popScene()
		end
	else
		local function onClose()
			self.quitDcData = nil
			self:continue()
		end
		if accepted then
			self:popReplayPanel(onClose, propId)
		else
			onClose()
		end
	end
end
