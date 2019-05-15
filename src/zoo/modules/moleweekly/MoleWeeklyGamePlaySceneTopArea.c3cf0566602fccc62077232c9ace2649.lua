local MoleWeeklyMoveOrTimeCounter = require("zoo.modules.moleweekly.MoleWeeklyMoveOrTimeCounter")

MoleWeeklyGamePlaySceneTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function MoleWeeklyGamePlaySceneTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = MoleWeeklyGamePlaySceneTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function MoleWeeklyGamePlaySceneTopArea:init(levelSkinConfig, gamePlaySceneUI)
    self.levelSkinConfig = levelSkinConfig
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
end

function MoleWeeklyGamePlaySceneTopArea:initTopRightLeaves()
	-- body
	local topRightLeaves = ResourceManager:sharedInstance():buildBatchGroup("sprite", self.levelSkinConfig.topRightLeaves)
	self.displayLayer[GamePlaySceneTopAreaType.kBackground]:addChild(topRightLeaves)
	self.topRightLeaves = topRightLeaves
	local topRightLeavesSize = topRightLeaves:getGroupBounds().size
	local topRightLeavesX = visibleOrigin.x + visibleSize.width - topRightLeavesSize.width + 8/0.3
	local topRightLeavesY = visibleOrigin.y + visibleSize.height + 2
	topRightLeaves:setPosition(ccp(topRightLeavesX, topRightLeavesY))
end

function MoleWeeklyGamePlaySceneTopArea:initMoveOrTimeCounter( ... )

    local mainLogic = GameBoardLogic:getCurrentLogic()

    local bgScale = 1
    if mainLogic and mainLogic.PlayUIDelegate then
        local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
        if __isWildScreen then  
		    bgScale = visibleSize.width/960
        end
    end

 
	-- body
	local levelSkinConfig = self.levelSkinConfig
	local gamePlaySceneUI = self.gamePlaySceneUI
	self.moveOrTimeCounter = MoleWeeklyMoveOrTimeCounter:create(levelSkinConfig.moveOrTimeCounter,gamePlaySceneUI.levelId, MoveOrTimeCounterType.MOVE_COUNT, gamePlaySceneUI.moveLimit)
    self.moveOrTimeCounter.label:setPositionY(-154 + 68)

	local counterSize = self.moveOrTimeCounter:getGroupBounds().size
	local counterX	= visibleOrigin.x + visibleSize.width - counterSize.width/2 - 5
	local counterY	= visibleOrigin.y + visibleSize.height + 8
	self.moveOrTimeCounter:setPosition(ccp(counterX, counterY))
    self.moveOrTimeCounter:setScale( bgScale )
	self.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.moveOrTimeCounter)
end

function MoleWeeklyGamePlaySceneTopArea:initTopLeftLeaves()

     local mainLogic = GameBoardLogic:getCurrentLogic()

    local bgScale = 1
    local offsetX = 0
    local offsetY = 0
    if mainLogic and mainLogic.PlayUIDelegate then
        local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
        if __isWildScreen then  
		    bgScale = visibleSize.width/960
            offsetX = 15
            offsetY = -5
        end
    end

	-- body
	local topLeftLeaves = ResourceManager:sharedInstance():buildBatchGroup("sprite",self.levelSkinConfig.topLeftLeaves)
    topLeftLeaves:setScale( bgScale )
	self.displayLayer[GamePlaySceneTopAreaType.kBackground]:addChild(topLeftLeaves)
	self.topLeftLeaves = topLeftLeaves
	local topLeftLeavesX = visibleOrigin.x - 61*bgScale + offsetX
	local topLeftLeavesY = visibleOrigin.y + visibleSize.height - 5*bgScale + offsetY
	topLeftLeaves:setPosition(ccp(topLeftLeavesX, topLeftLeavesY))
end

function MoleWeeklyGamePlaySceneTopArea:initScoreProgressBar()
	local gamePlaySceneUI = self.gamePlaySceneUI
	local star1Score = gamePlaySceneUI.curLevelScoreTarget[1]
	local star2Score = gamePlaySceneUI.curLevelScoreTarget[2]
	local star3Score = gamePlaySceneUI.curLevelScoreTarget[3]
	local star4Score = gamePlaySceneUI.curLevelScoreTarget[4]
	local starScoreList = {star1Score, star2Score, star3Score, star4Score}
	
	local scoreProgressBarX = visibleOrigin.x - 17 + 10
	local scoreProgressBarY = visibleOrigin.y + visibleSize.height - 15
	self.scoreProgressBar = ScoreProgress:create(self, starScoreList, ccp(scoreProgressBarX, scoreProgressBarY), GameLevelType.kSummerWeekly)
	self.scoreProgressBar.scoreTxtLabel:setVisible(false)
	self.scoreProgressBar.scoreLabel:setVisible(false)
	-- self.scoreProgressBar:setPosition(ccp(scoreProgressBarX, scoreProgressBarY))
end