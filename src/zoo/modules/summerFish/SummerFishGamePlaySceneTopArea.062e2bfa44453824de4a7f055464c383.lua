
SummerFishGamePlaySceneTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function SummerFishGamePlaySceneTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = SummerFishGamePlaySceneTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function SummerFishGamePlaySceneTopArea:init(levelSkinConfig, gamePlaySceneUI)
    self.levelSkinConfig = levelSkinConfig
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
end

function SummerFishGamePlaySceneTopArea:initScoreProgressBar()
	-- body
	local gamePlaySceneUI = self.gamePlaySceneUI
	local star1Score = gamePlaySceneUI.curLevelScoreTarget[1]
	local star2Score = gamePlaySceneUI.curLevelScoreTarget[2]
	local star3Score = gamePlaySceneUI.curLevelScoreTarget[3]
	local star4Score = gamePlaySceneUI.curLevelScoreTarget[4]
	local starScoreList = {star1Score, star2Score, star3Score, star4Score}
	
	local scoreProgressBarX = visibleOrigin.x - 17
	local scoreProgressBarY = visibleOrigin.y + visibleSize.height - 15
	self.scoreProgressBar = ScoreProgress:create(self, starScoreList, ccp(scoreProgressBarX, scoreProgressBarY), GameLevelType.kSummerFish)
--	self.scoreProgressBar.scoreTxtLabel:setVisible(false)
--	self.scoreProgressBar.scoreLabel:setVisible(false)

    local txtPos = self.scoreProgressBar.scoreTxtLabel:getPosition()
    self.scoreProgressBar.scoreTxtLabel:setPosition( ccp(txtPos.x+10/0.7, txtPos.y) )

    local scorePos = self.scoreProgressBar.scoreLabel:getPosition()
    self.scoreProgressBar.scoreLabel:setPosition( ccp(scorePos.x+10/0.7, scorePos.y) )
end