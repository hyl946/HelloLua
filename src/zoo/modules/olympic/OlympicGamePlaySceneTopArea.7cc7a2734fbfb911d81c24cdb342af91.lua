---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-01 17:28:04
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-04 14:28:04
---------------------------------------------------------------------------------------
require "zoo.modules.olympic.OlympicScoreBoard"

OlympicGamePlaySceneTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function OlympicGamePlaySceneTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = OlympicGamePlaySceneTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function OlympicGamePlaySceneTopArea:init(levelSkinConfig, gamePlaySceneUI)
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
	-- 	self:initTopRightLeaves()
	-- self:initScoreProgressBar()
	-- self:initTopLeftLeaves()
	-- self:initPauseBtn()
	-- self:initMoveOrTimeCounter()
	-- self:initOtherNode()
	self.levelNumberLabel:setVisible(true)
end

function OlympicGamePlaySceneTopArea:initTopRightLeaves()
	GamePlaySceneTopArea.initTopRightLeaves(self)
	self.topRightLeaves:setVisible(false)
end

function OlympicGamePlaySceneTopArea:initMoveOrTimeCounter()
	GamePlaySceneTopArea.initMoveOrTimeCounter(self)
	self.moveOrTimeCounter:setVisible(false)

	self.olympicScoreBoard = OlympicScoreBoard:create()
	self:addChild(self.olympicScoreBoard)
	local counterSize = self.olympicScoreBoard:getGroupBounds(self).size
	local counterX	= visibleOrigin.x + (visibleSize.width / 2) - (counterSize.width / 2)
	local counterY	= visibleOrigin.y + visibleSize.height + 15
	self.olympicScoreBoard:setPosition(ccp(counterX, counterY))
end

function OlympicGamePlaySceneTopArea:initTopLeftLeaves()
	GamePlaySceneTopArea.initTopLeftLeaves(self)
	local originPos = self.topLeftLeaves:getPosition()
	self.topLeftLeaves:getChildByName("1"):setVisible(false)
	self.topLeftLeaves:getChildByName("2"):setVisible(false)
	self.topLeftLeaves:setPosition(ccp(originPos.x, originPos.y - 10))
end

function OlympicGamePlaySceneTopArea:initScoreProgressBar()

	----[[
	local gamePlaySceneUI = self.gamePlaySceneUI
	local star1Score = gamePlaySceneUI.curLevelScoreTarget[1]
	local star2Score = gamePlaySceneUI.curLevelScoreTarget[2]
	local star3Score = gamePlaySceneUI.curLevelScoreTarget[3]
	local star4Score = gamePlaySceneUI.curLevelScoreTarget[4]
	local starScoreList = {star1Score, star2Score, star3Score, star4Score}
	
	local scoreProgressBarX = visibleOrigin.x - 17 + 10
	local scoreProgressBarY = visibleOrigin.y + visibleSize.height - 15 + 80
	self.scoreProgressBar = ScoreProgress:create(self, starScoreList, ccp(scoreProgressBarX, scoreProgressBarY), GameLevelType.kOlympicEndless)
	

	self.scoreProgressBar.scoreTxtLabel:setVisible(false)
	self.scoreProgressBar.scoreLabel:setVisible(false)

	--]]
end