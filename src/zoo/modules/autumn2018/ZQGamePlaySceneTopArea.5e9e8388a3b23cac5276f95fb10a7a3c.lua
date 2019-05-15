require "zoo.modules.autumn2018.ZQManager"
require "zoo.modules.autumn2018.ZQScoreBoard"

ZQGamePlaySceneTopArea = class(GamePlaySceneTopArea)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
local winSize = CCDirector:sharedDirector():getWinSize()

function ZQGamePlaySceneTopArea:create(levelSkinConfig, gamePlaySceneUI)
	local s = ZQGamePlaySceneTopArea.new(CCNode:create())
	s:init(levelSkinConfig, gamePlaySceneUI)
	return s
end

function ZQGamePlaySceneTopArea:init(levelSkinConfig, gamePlaySceneUI)
	GamePlaySceneTopArea.init(self, levelSkinConfig, gamePlaySceneUI)
	-- 	self:initTopRightLeaves()
	-- self:initScoreProgressBar()
	-- self:initTopLeftLeaves()
	-- self:initPauseBtn()
	-- self:initMoveOrTimeCounter()
	-- self:initOtherNode()
	self.levelNumberLabel:setVisible(true)
end

function ZQGamePlaySceneTopArea:initTopRightLeaves()
	GamePlaySceneTopArea.initTopRightLeaves(self)
	self.topRightLeaves:setVisible(false)
end

function ZQGamePlaySceneTopArea:initMoveOrTimeCounter()
	GamePlaySceneTopArea.initMoveOrTimeCounter(self)
	self.moveOrTimeCounter:setVisible(false)

	self.zqScoreBoard = ZQScoreBoard:create()
	self:addChild(self.zqScoreBoard)
	-- local counterSize = self.zqScoreBoard:getGroupBounds(self).size
	local counterX	= visibleOrigin.x + visibleSize.width
	local counterY	= visibleOrigin.y + visibleSize.height - 2
	self.zqScoreBoard:setPosition(ccp(counterX, counterY))

	local targetsConfig = ZQManager.getInstance():getTargetsConfig()
	if targetsConfig then 
		self.zqScoreBoard:setVisible(false)
	else
		self.zqScoreBoard:setVisible(true)
	end
	ZQManager.getInstance():setScoreBoard(self.zqScoreBoard)
end

function ZQGamePlaySceneTopArea:initTopLeftLeaves()
	GamePlaySceneTopArea.initTopLeftLeaves(self)
	local originPos = self.topLeftLeaves:getPosition()
	self.topLeftLeaves:getChildByName("1"):setVisible(false)
	self.topLeftLeaves:getChildByName("2"):setVisible(false)
	self.topLeftLeaves:setPosition(ccp(originPos.x, originPos.y - 10))
end

function ZQGamePlaySceneTopArea:initScoreProgressBar()

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