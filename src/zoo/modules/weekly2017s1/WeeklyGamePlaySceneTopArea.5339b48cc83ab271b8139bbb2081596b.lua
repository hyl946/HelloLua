require "zoo.modules.weekly2017s1.WeeklyMoveOrTimeCounter"

WeeklyGamePlaySceneTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function WeeklyGamePlaySceneTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = WeeklyGamePlaySceneTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function WeeklyGamePlaySceneTopArea:init(levelSkinConfig, gamePlaySceneUI)
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
end

function WeeklyGamePlaySceneTopArea:initTopRightLeaves()
	GamePlaySceneTopArea.initTopRightLeaves(self)
	self.topRightLeaves:setVisible(false)
end

function WeeklyGamePlaySceneTopArea:initMoveOrTimeCounter( ... )
	local levelSkinConfig = self.levelSkinConfig
	local gamePlaySceneUI = self.gamePlaySceneUI

	self.moveOrTimeCounter = WeeklyMoveOrTimeCounter:create(levelSkinConfig.moveOrTimeCounter,gamePlaySceneUI.levelId, MoveOrTimeCounterType.MOVE_COUNT, gamePlaySceneUI.moveLimit)

	local counterSize = self.moveOrTimeCounter:getGroupBounds().size
	local counterX	= visibleOrigin.x + visibleSize.width - counterSize.width/2 + 10
	local counterY	= visibleOrigin.y + visibleSize.height+5
	self.moveOrTimeCounter:setPosition(ccp(counterX, counterY))
	self.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.moveOrTimeCounter)
	
end


function WeeklyGamePlaySceneTopArea:initTopLeftLeaves()
	GamePlaySceneTopArea.initTopLeftLeaves(self)
	local originPos = self.topLeftLeaves:getPosition()
	self.topLeftLeaves:getChildByName("1"):setVisible(false)
	self.topLeftLeaves:getChildByName("2"):setVisible(false)
	self.topLeftLeaves:setPosition(ccp(originPos.x, originPos.y - 10))
end

function WeeklyGamePlaySceneTopArea:initScoreProgressBar()
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