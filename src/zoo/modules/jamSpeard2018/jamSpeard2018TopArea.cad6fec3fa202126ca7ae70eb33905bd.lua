require "zoo.modules.jamSpeard2018.jamSpeard2018MoveOrTimeCounter"

JamSpeard2018TopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function JamSpeard2018TopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = JamSpeard2018TopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function JamSpeard2018TopArea:init(levelSkinConfig, gamePlaySceneUI)
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
end

function JamSpeard2018TopArea:initAllItems()
	-- body
	self:initTopRightLeaves()
    self:initTopLeftLeaves()
	self:initScoreProgressBar()
	self:initPauseBtn()
	self:initMoveOrTimeCounter()
	self:initOtherNode()
end

function JamSpeard2018TopArea:initTopRightLeaves()
	GamePlaySceneTopArea.initTopRightLeaves(self)

    local originPos = self.topRightLeaves:getPosition()
	self.topRightLeaves:setPosition(ccp(originPos.x+210/0.7, originPos.y))
end

function JamSpeard2018TopArea:initMoveOrTimeCounter( ... )
	local levelSkinConfig = self.levelSkinConfig
	local gamePlaySceneUI = self.gamePlaySceneUI

	self.moveOrTimeCounter = JamSpeard2018MoveOrTimeCounter:create(levelSkinConfig.moveOrTimeCounter,gamePlaySceneUI.levelId, MoveOrTimeCounterType.MOVE_COUNT, gamePlaySceneUI.moveLimit)

	local counterSize = self.moveOrTimeCounter:getGroupBounds().size
	local counterX	= visibleOrigin.x + visibleSize.width - counterSize.width/2 + 30
	local counterY	= visibleOrigin.y + visibleSize.height - 20
	self.moveOrTimeCounter:setPosition(ccp(counterX, counterY))
    self.moveOrTimeCounter:setScale(0.75)
	self.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.moveOrTimeCounter)

    if __isWildScreen then  
        self.moveOrTimeCounter:setScale(0.6)
    end
end

function JamSpeard2018TopArea:initTopLeftLeaves()
	GamePlaySceneTopArea.initTopLeftLeaves(self)
	local originPos = self.topLeftLeaves:getPosition()
	self.topLeftLeaves:setPosition(ccp(originPos.x+35/0.7, originPos.y))


    local pauseBtnPosY = self.topLeftLeaves:getChildByName("pauseBtn"):getPositionY()
    self.topLeftLeaves:getChildByName("pauseBtn"):setPositionY( pauseBtnPosY - 15 )
end

function JamSpeard2018TopArea:initScoreProgressBar()
	-- body
	local gamePlaySceneUI = self.gamePlaySceneUI
	local star1Score = gamePlaySceneUI.curLevelScoreTarget[1]
	local star2Score = gamePlaySceneUI.curLevelScoreTarget[2]
	local star3Score = gamePlaySceneUI.curLevelScoreTarget[3]
	local star4Score = gamePlaySceneUI.curLevelScoreTarget[4]
	local starScoreList = {star1Score, star2Score, star3Score, star4Score}
	
	local scoreProgressBarX = visibleOrigin.x - 17
	local scoreProgressBarY = visibleOrigin.y + visibleSize.height - 15 - 30/0.7
	self.scoreProgressBar = ScoreProgress:create(self, starScoreList, ccp(scoreProgressBarX, scoreProgressBarY), GameLevelType.kJamSperadLevel)
--	self.scoreProgressBar.scoreTxtLabel:setVisible(false)
--	self.scoreProgressBar.scoreLabel:setVisible(false)

    local txtPos = self.scoreProgressBar.scoreTxtLabel:getPosition()
    self.scoreProgressBar.scoreTxtLabel:setPosition( ccp(txtPos.x+10/0.7, txtPos.y +30/0.7 ) )

    local scorePos = self.scoreProgressBar.scoreLabel:getPosition()
    self.scoreProgressBar.scoreLabel:setPosition( ccp(scorePos.x+10/0.7, scorePos.y+30/0.7) )

--    if __isWildScreen then  
--		self.scoreProgressBar.ladyBugAnimation.ladybug:setScale( 0.5 )
--	end
end