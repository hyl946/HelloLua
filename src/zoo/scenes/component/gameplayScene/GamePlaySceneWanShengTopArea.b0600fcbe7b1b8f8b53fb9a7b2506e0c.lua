GamePlaySceneWanShengTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function GamePlaySceneWanShengTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = GamePlaySceneWanShengTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end
function GamePlaySceneWanShengTopArea:init(levelSkinConfig, gamePlaySceneUI)
    self.levelSkinConfig = levelSkinConfig
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
end

function GamePlaySceneWanShengTopArea:initAllItems()
	-- body
--	self:initTopRightLeaves()
	self:initScoreProgressBar()
	self:initTopLeftLeaves()
	self:initPauseBtn()
	self:initMoveOrTimeCounter()
	self:initOtherNode()
end

function GamePlaySceneWanShengTopArea:initScoreProgressBar( ... )
	-- body
	local gamePlaySceneUI = self.gamePlaySceneUI
	local star1Score = gamePlaySceneUI.curLevelScoreTarget[1]
	local star2Score = gamePlaySceneUI.curLevelScoreTarget[2]
	local star3Score = gamePlaySceneUI.curLevelScoreTarget[3]
	local star4Score = gamePlaySceneUI.curLevelScoreTarget[4]
	local starScoreList = {star1Score, star2Score, star3Score, star4Score}
	
	local scoreProgressBarX = visibleOrigin.x - 17 + 10 - 39/0.7
	local scoreProgressBarY = visibleOrigin.y + visibleSize.height - 15 -38/0.7

	self.scoreProgressBar = ScoreProgress:create(self, starScoreList, ccp(scoreProgressBarX, scoreProgressBarY) ,nil, gamePlaySceneUI.levelId )
	-- self.scoreProgressBar:setPosition(ccp(scoreProgressBarX, scoreProgressBarY))
end

function GamePlaySceneWanShengTopArea:initTopLeftLeaves()
	-- body
	local topLeftLeaves = ResourceManager:sharedInstance():buildBatchGroup("sprite",self.levelSkinConfig.topLeftLeaves)
	self.displayLayer[GamePlaySceneTopAreaType.kBackground]:addChild(topLeftLeaves)
	self.topLeftLeaves = topLeftLeaves
	local topLeftLeavesX = visibleOrigin.x - 77.40
	local topLeftLeavesY = visibleOrigin.y + visibleSize.height + 22.95
	topLeftLeaves:setPosition(ccp(topLeftLeavesX, topLeftLeavesY))

    local reslist = {}
    reslist[1] = self.topLeftLeaves:getChildByName("1")
    reslist[2] = self.topLeftLeaves:getChildByName("2")
--    reslist[3] = self.topLeftLeaves:getChildByName("3")

    for i,v in ipairs(reslist) do
        v:setVisible(false)
    end
end

function GamePlaySceneWanShengTopArea:initMoveOrTimeCounter( ... )
	-- body
	local levelSkinConfig = self.levelSkinConfig
	local gamePlaySceneUI = self.gamePlaySceneUI
	if gamePlaySceneUI.levelModeType == GameModeType.CLASSIC then
		self.moveOrTimeCounter = MoveOrTimeCounter:create(levelSkinConfig.moveOrTimeCounter, gamePlaySceneUI.levelId , MoveOrTimeCounterType.TIME_COUNT, gamePlaySceneUI.timeLimit)
	else
		self.moveOrTimeCounter = MoveOrTimeCounter:create(levelSkinConfig.moveOrTimeCounter,gamePlaySceneUI.levelId, MoveOrTimeCounterType.MOVE_COUNT, gamePlaySceneUI.moveLimit)
	end
	local counterSize = self.moveOrTimeCounter:getGroupBounds().size
	local counterX	= visibleOrigin.x + visibleSize.width - counterSize.width/2 - 5
	local counterY	= visibleOrigin.y + visibleSize.height + 8
	self.moveOrTimeCounter:setPosition(ccp(counterX, counterY))
	self.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.moveOrTimeCounter)
end

function GamePlaySceneWanShengTopArea:initOtherNode()
	-- body
	local levelSkinConfig = self.levelSkinConfig
	local gamePlaySceneUI = self.gamePlaySceneUI
	if gamePlayType == GameModeTypeId.NONE_ID then
		assert(false)
	elseif gamePlayType == GameModeTypeId.CLASSIC_MOVES_ID or
		gamePlayType == GameModeTypeId.CLASSIC_ID then

		local function onScoreChangeCallback(newScore)
			self:onScoreChangeCallback(newScore)
		end

		self.scoreProgressBar:setOnScoreChangeCallback(onScoreChangeCallback)
	end

	local fntFile			= "fnt/titles.fnt"
	local diguanWidth		= 40
	local diguanHeight		= 40
	local levelNumberWidth		= 210
	local levelNumberHeight		= 40
	local manualAdjustInterval	= -10

	local levelNumberLabelPosX = 4
	local levelNumberLabelPosY = visibleOrigin.y + visibleSize.height - 8.4

	local levelDisplayName
	local levelNumberLabel
	if gamePlaySceneUI.levelType == GameLevelType.kDigWeekly or gamePlaySceneUI.levelType == GameLevelType.kRabbitWeekly then
		local day = (tonumber(os.date('%w', Localhost:time() / 1000)) - 1 + 7) % 7
		levelDisplayName = Localization:getInstance():getText('weekly.race.play.scene.name', {num = day})
		local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len)
		levelNumberLabel:setScale(0.7)
	elseif gamePlaySceneUI.levelType == GameLevelType.kSummerWeekly then
		local day = tonumber(os.date('%w', Localhost:time() / 1000))
		if day == 0 then day = 7 end
		levelDisplayName = Localization:getInstance():getText('weekly.race.play.scene.name', {num = day})
		local len = math.ceil(string.len(levelDisplayName) / 3) -- chinese char is 3 times longer
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len, "fnt/titles_purple.fnt")
		levelNumberLabel:setScale(0.55)
		levelNumberLabelPosX = 16
	elseif gamePlaySceneUI.levelType == GameLevelType.kMayDay then
		levelDisplayName = Localization:getInstance():getText('activity.christmas.start.panel.title')
		local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len)
		levelNumberLabel:setScale(0.7)
	elseif gamePlaySceneUI.levelType == GameLevelType.kWukong then
		levelDisplayName = Localization:getInstance():getText('activity.wukong.start.panel.title')
		--levelDisplayName = Localization:getInstance():getText('weekly.race.play.scene.name')
		local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len)
		levelNumberLabel:setScale(0.7)
	elseif gamePlaySceneUI.levelType == GameLevelType.kTaskForRecall or gamePlaySceneUI.levelType == GameLevelType.kTaskForUnlockArea then
		levelDisplayName = Localization:getInstance():getText('recall_text_5')
		local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len)
		levelNumberLabel:setScale(0.7)
	elseif gamePlaySceneUI.levelType == GameLevelType.kOlympicEndless then
		levelDisplayName = Localization:getInstance():getText('activity.christmas.start.panel.title')
		local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString("周年关卡", len , "fnt/titles_purple.fnt" )
		levelNumberLabel:setScale(0.7)
	elseif gamePlaySceneUI.levelType == GameLevelType.kMidAutumn2018 then
		levelDisplayName = localize('中秋节关卡')
		local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString("中秋节关卡", len , "fnt/titles_purple.fnt" )
		levelNumberLabel:setScale(0.7)	
	elseif gamePlaySceneUI.levelType == GameLevelType.kYuanxiao2017 then
		local levelId = gamePlaySceneUI.levelId
		local num = (levelId) % 100
		local l1 = math.ceil(num / 3) 
		local l2 = num % 3
		if l2 == 0 then l2 = 3 end

		--levelDisplayName = Localization:getInstance():getText('Christmas.level.' .. l1 .. '.' .. l2)
		levelDisplayName = "关卡" .. l1 .. "-" .. l2
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, string.len(levelDisplayName))
		levelNumberLabel:setScale(0.7)
	elseif gamePlaySceneUI.levelType == GameLevelType.kFourYears then
		local levelId = gamePlaySceneUI.levelId
		local val = levelId - LevelConstans.FOURYEARS_LEVEL_ID_START
		local mainId = math.floor(val/3) + 1
		local subId = math.floor(val%3)+1

		--levelDisplayName = Localization:getInstance():getText('Christmas.level.' .. l1 .. '.' .. l2)
		levelDisplayName = "关卡" .. mainId .. "-" .. subId
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, string.len(levelDisplayName))
		levelNumberLabel:setScale(0.7)		
    elseif gamePlaySceneUI.levelType == GameLevelType.kSummerFish then
		local levelId = gamePlaySceneUI.levelId
		local val = levelId - LevelConstans.SUMMER_FISH_LEVEL_ID_START
		local mainId = math.floor(val/3) + 1
		local subId = math.floor(val%3)+1

		--levelDisplayName = Localization:getInstance():getText('Christmas.level.' .. l1 .. '.' .. l2)
		levelDisplayName = "关卡" .. mainId .. "-" .. subId
--		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, string.len(levelDisplayName),"fnt/summer18_titles_blue.fnt" )
        levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, string.len(levelDisplayName) )
		levelNumberLabel:setScale(0.7)	
	elseif gamePlaySceneUI.levelType == GameLevelType.kSpring2017 then
		levelDisplayName = "" -- Localization:getInstance():getText('activity.wukong.start.panel.title')
		local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len)
		levelNumberLabel:setScale(0.7)
    elseif gamePlaySceneUI.levelType == GameLevelType.kMoleWeekly then
        
        local levelId = 0
        local instance = RankRaceMgr:getExistedInstance()
        if instance  then
            levelId = instance:getLevelIndex()
        end

        local diCharKey		= "start.game.panel.title_di"
        local diCharValue 	= Localization:getInstance():getText(diCharKey, {})
        local guanCharKey	= "start.game.panel.title_guan"
        local guanCharValue	= Localization:getInstance():getText(guanCharKey, {})

		levelDisplayName = diCharValue..levelId..guanCharValue
        local len = math.ceil(string.len(levelDisplayName) / 3)
		levelNumberLabel = PanelTitleLabel:createWithString(levelDisplayName, len)
		levelNumberLabel:setScale(0.7)
	else 
		levelDisplayName = LevelMapManager.getInstance():getLevelDisplayName(gamePlaySceneUI.levelId)

        local fntFile = "fnt/halloween.fnt"
		levelNumberLabel = PanelTitleLabel:create(levelDisplayName, diguanWidth, diguanHeight, levelNumberWidth, levelNumberHeight, manualAdjustInterval, fntFile )
	end

	if _isQixiLevel then -- qixi
		levelNumberLabel:setVisible(false)
	end

	self.levelNumberLabel = levelNumberLabel
	local contentSize	= levelNumberLabel:getContentSize()
	self.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(levelNumberLabel)
	levelNumberLabel:ignoreAnchorPointForPosition(false)
	levelNumberLabel:setAnchorPoint(ccp(0,1))


	if gamePlaySceneUI.levelType == GameLevelType.kOlympicEndless then
		levelNumberLabel:setPosition(ccp(levelNumberLabelPosX, levelNumberLabelPosY - 0))
	elseif gamePlaySceneUI.levelType == GameLevelType.kMidAutumn2018 then
		levelNumberLabel:setPosition(ccp(levelNumberLabelPosX, levelNumberLabelPosY)) 
	else
		levelNumberLabel:setPosition(ccp(levelNumberLabelPosX, levelNumberLabelPosY))
	end
end

function GamePlaySceneWanShengTopArea:initPauseBtn( ... )
	-- body
	self.pauseBtnEnable = true
	local gamePlaySceneUI = self.gamePlaySceneUI
	local pauseRes = self.topLeftLeaves:getChildByName("pauseBtn")
	local size_pause = pauseRes:getGroupBounds().size
	self.pauseRes = pauseRes
    pauseRes:setScale(0.8)
    pauseRes:setPositionY( pauseRes:getPositionY()-20/0.7 )
	local transformData = {}
	pauseRes.transformData = transformData
	transformData.width = size_pause.width
	transformData.height = size_pause.height
	transformData.scaleX = pauseRes:getScaleX()
	transformData.scaleY = pauseRes:getScaleY()
	local function onPauseBtnBegin( evt )
		-- body
		-- if _G.isLocalDevelopMode then printx(0, "-------------------onPauseBtnBegin") end
		if not self.pauseBtnEnable then return end
		local scaleX = pauseRes.transformData.scaleX
		local scaleY = pauseRes.transformData.scaleY
		local deltaX = 4 / pauseRes.transformData.width
		local deltaY = 4 / pauseRes.transformData.height
		pauseRes:setScaleX(scaleX + deltaX)
		pauseRes:setScaleY(scaleY + deltaY)
	end

	local function onPauseBtnEnd( evt )
		-- body
		-- if _G.isLocalDevelopMode then printx(0, "-------------------onPauseBtnEnd") end
		if not self.pauseBtnEnable then return end
		if pauseRes.transformData and not pauseRes.isDisposed then
			local scaleX = pauseRes.transformData.scaleX
			local scaleY = pauseRes.transformData.scaleY
			pauseRes:setScaleX(scaleX)
			pauseRes:setScaleY(scaleY)
		end
	end

	local function onPauseBtnTapped()
		-- if _G.isLocalDevelopMode then printx(0, "-------------------onPauseBtnTapped") end
		if not self.pauseBtnEnable then return end
		gamePlaySceneUI:onPauseBtnTapped()
	end

	pauseRes:addEventListener(DisplayEvents.kTouchBegin, onPauseBtnBegin)
	pauseRes:addEventListener(DisplayEvents.kTouchEnd, onPauseBtnEnd)
	pauseRes:addEventListener(DisplayEvents.kTouchTap, onPauseBtnTapped)
	self:addTouchList(pauseRes)
end
