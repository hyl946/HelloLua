---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-12-26 11:04:50
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2017-09-08 16:32:01
---------------------------------------------------------------------------------------
require "zoo.modules.spring2017.SpringAnimations"

SpringGamePlaySceneTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function SpringGamePlaySceneTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = SpringGamePlaySceneTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function SpringGamePlaySceneTopArea:init(levelSkinConfig, gamePlaySceneUI)
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
	-- self.levelNumberLabel:setVisible(false)
	local ladyBugAnimation = self.scoreProgressBar.ladyBugAnimation
	if ladyBugAnimation and ladyBugAnimation.ladybug then
		ladyBugAnimation.ladybug:setVisible(false)
		ladyBugAnimation.background:setVisible(false)
	end
end

function SpringGamePlaySceneTopArea:initScoreProgressBar( ... )
	-- body
	local gamePlaySceneUI = self.gamePlaySceneUI
	local star1Score = gamePlaySceneUI.curLevelScoreTarget[1]
	local star2Score = gamePlaySceneUI.curLevelScoreTarget[2]
	local star3Score = gamePlaySceneUI.curLevelScoreTarget[3]
	local star4Score = gamePlaySceneUI.curLevelScoreTarget[4]
	local starScoreList = {star1Score, star2Score, star3Score, star4Score}
	
	local scoreProgressBarX = visibleOrigin.x - 17 + 10
	local scoreProgressBarY = visibleOrigin.y + visibleSize.height - 15
	self.scoreProgressBar = ScoreProgress:create(self, starScoreList, ccp(scoreProgressBarX, scoreProgressBarY), GameLevelType.kSpring2017)
	self.scoreProgressBar.scoreTxtLabel:setVisible(false)
	self.scoreProgressBar.scoreLabel:setVisible(false)
	-- self.scoreProgressBar:setPosition(ccp(scoreProgressBarX, scoreProgressBarY))
end


function SpringGamePlaySceneTopArea:initMoveOrTimeCounter( ... )
	levelSkinConfig = self.levelSkinConfig
	local gamePlaySceneUI = self.gamePlaySceneUI
	require "zoo.modules.spring2017.MoveCounter"
	self.moveOrTimeCounter = SpringMoveCounter:create(levelSkinConfig.moveOrTimeCounter,gamePlaySceneUI.levelId, MoveOrTimeCounterType.MOVE_COUNT, gamePlaySceneUI.moveLimit)
	
	local counterSize = self.moveOrTimeCounter:getGroupBounds().size
	local counterX	= visibleOrigin.x + visibleSize.width - counterSize.width/2 - 5
	local counterY	= visibleOrigin.y + visibleSize.height + 25
	self.moveOrTimeCounter:setPosition(ccp(counterX, counterY))
	self.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.moveOrTimeCounter)
end

function SpringGamePlaySceneTopArea:initTopLeftLeaves()
	GamePlaySceneTopArea.initTopLeftLeaves(self)
	local originPos = self.topLeftLeaves:getPosition()
	self.topLeftLeaves:getChildByName("1"):setVisible(false)
	self.topLeftLeaves:getChildByName("2"):setVisible(false)
	self.topLeftLeaves:setPosition(ccp(originPos.x - 10, originPos.y))
	-- local pauseBtn = self.topLeftLeaves:getChildByName("pauseBtn")
end

function SpringGamePlaySceneTopArea:initTopRightLeaves()
	GamePlaySceneTopArea.initTopRightLeaves(self)
	self.topRightLeaves:setVisible(false)
end