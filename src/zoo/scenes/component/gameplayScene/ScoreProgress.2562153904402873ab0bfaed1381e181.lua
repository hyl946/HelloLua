ScoreProgress = class()
local kStarFactor = 24 * 3.1415926 / 180
local kMaskBeginWidth = 17
local kMaskEndWidth = 50
require "zoo.scenes.component.gameplayScene.ScoreProgressAnimation"
function ScoreProgress:create( parent,starScoreList, pos, levelType ,levelId )
	-- body
	local sp = ScoreProgress.new()
	sp:init(parent, starScoreList, pos, levelType , levelId )
	return sp
end

function ScoreProgress:ctor( ... )
	-- body
end

function ScoreProgress:init( parent, starScoreList, pos, levelType , levelId )
	-- body
	self.parent = parent
	self.starScoreList = starScoreList
	self.levelId = levelId
	
	local isStar4Level = false
	self.showStar4 = false

	if levelType == GameLevelType.kOlympicEndless then
		require("zoo.modules.spring2017.SpringScoreProgressAnimation")
		self.ladyBugAnimation = SpringScoreProgressAnimation:create(self, pos)
		--self.ladyBugAnimation:setVisible(false)
	elseif levelType == GameLevelType.kMidAutumn2018 then
		require("zoo.modules.spring2017.SpringScoreProgressAnimation")
		self.ladyBugAnimation = SpringScoreProgressAnimation:create(self, pos)
	elseif levelType == GameLevelType.kSpring2017 then
		require("zoo.modules.spring2017.SpringScoreProgressAnimation")
		self.ladyBugAnimation = SpringScoreProgressAnimation:create(self, pos)
	elseif levelType == GameLevelType.kSummerWeekly then
		require("zoo.modules.weekly2017s1.WeeklyScoreProgressAnimation")
		self.ladyBugAnimation = WeeklyScoreProgressAnimation:create(self, pos)
    elseif levelType == GameLevelType.kSummerFish then
		require("zoo.modules.summerFish.SummerFishScoreProgressAnimation")
		self.ladyBugAnimation = SummerFishScoreProgressAnimation:create(self, pos)
	else
		if starScoreList[4] and starScoreList[4] > 0 then
			isStar4Level = true
		end
		if isStar4Level then
			local curLevelScoreRef	= UserManager:getInstance():getUserScore(self.levelId)
			if curLevelScoreRef and curLevelScoreRef.star >=3  then
				self.showStar4 = true
			end
		end
		self.ladyBugAnimation = ScoreProgressAnimation:create(self, pos ,self.levelId ,self.showStar4 )
	end


	local kPropListScaleFactor = 1
  	if __isWildScreen then  kPropListScaleFactor = 0.92 end
	local config = UIConfigManager:sharedInstance():getConfig()
	local scoreTxtLabel_manualAdjustX 	= pos.x + (config.scoreProgressBar_scoreTxtLabel_manualAdjustX + 5) * kPropListScaleFactor
	local scoreTxtLabel_manualAdjustY 	= pos.y + (config.scoreProgressBar_scoreTxtLabel_manualAdjustY - 165) * kPropListScaleFactor
	local scoreLabel_manualAdjustX		= pos.x + (config.scoreProgressBar_scoreLabel_manualAdjustX) * kPropListScaleFactor
	local scoreLabel_manualAdjustY		= pos.y + (config.scoreProgressBar_scoreLabel_manualAdjustY - 192) * kPropListScaleFactor
	
	-- Create Score Txt Label
	local designFontName	= "Berlin Sans FB"
	local fontName		= LayoutBuilder:getGlobalFontFace(designFontName)

	local fontSize		= 23
	local dimension		= CCSizeMake(80, 24)
	local hAlignment	= kCCTextAlignmentLeft
	local vAlignment	= kCCVerticalTextAlignmentCenter
	local color			= ccc3(0xDE, 0xCF, 0x63)

	local filename = "fnt/game_scores.fnt"
	if _G.useTraditionalChineseRes then filename = "fnt/zh_tw/game_scores.fnt" end
	self.scoreTxtLabel = LabelBMMonospaceFont:create(40, 40, 20, filename)
	self.scoreTxtLabel:setPosition(ccp(scoreTxtLabel_manualAdjustX, scoreTxtLabel_manualAdjustY))
	self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.scoreTxtLabel)

	-- Create Score Label
	local fontSize		= 23
	local dimension		= CCSizeMake(200, 28)
	local hAlignment	= kCCTextAlignmentLeft
	local positionX		= 15 + scoreLabel_manualAdjustX
	local positionY		= -155 + scoreLabel_manualAdjustY
	self.scoreLabel = LabelBMMonospaceFont:create(42, 42, 12, filename)
	self.scoreLabel:setPosition(ccp(scoreLabel_manualAdjustX, scoreLabel_manualAdjustY))
	self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(self.scoreLabel)

    if SpringFestival2019Manager.getInstance():getCurIsActSkill() then
        local addPercentSprite = Sprite:createWithSpriteFrameName("SpringFestival_2019res/addpercent0000")
        if addPercentSprite then
            addPercentSprite:setPosition(ccp(scoreLabel_manualAdjustX + 63/0.7, scoreLabel_manualAdjustY + 34/0.7))
            self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]:addChild(addPercentSprite)
            self.addPercentSprite = addPercentSprite

            addPercentSprite:setVisible(false)
        end
    end
	---------------------
	-- Data
	-- -------------------
	self.maxPercentage = 0.88
	self.score = 0

	self.star1Score = starScoreList[1]
	self.star2Score = starScoreList[2]
	self.star3Score = starScoreList[3]
	self.star4Score = starScoreList[4]

	self.star1PosPer = false
	self.star2PosPer = false
	self.star3PosPer = false

	self.onScoreChangeCallback	= false

	-- Set Initial Star Position
	local star1PosPer
	local star2PosPer
	local star3PosPer 
	local star4PosPer = nil  
	if self.showStar4 then
		star1PosPer = self.star1Score / self.star4Score * self.maxPercentage
		star2PosPer = self.star2Score / self.star4Score * self.maxPercentage
		star3PosPer = self.star3Score / self.star4Score * self.maxPercentage
		star4PosPer = self.maxPercentage
	else
		star1PosPer = self.star1Score / self.star3Score * self.maxPercentage
		star2PosPer = self.star2Score / self.star3Score * self.maxPercentage
		star3PosPer = self.maxPercentage
	end


	self.star1PosPer = star1PosPer
	self.star2PosPer = star2PosPer
	self.star3PosPer = star3PosPer

	-----------------
	-- Update View
	-- --------------
	self.ladyBugAnimation:reset()
	self.ladyBugAnimation:setStarsPosition(star1PosPer, star2PosPer, star3PosPer , star4PosPer)
	self.ladyBugAnimation:setStarsScore(self.star1Score, self.star2Score, self.star3Score , self.star4Score )
	
	local scoreTxtLabelKey		= "score.progress.bar.score.txt"
	local scoreTxtLabelValue	= Localization:getInstance():getText(scoreTxtLabelKey, {})
	self.scoreTxtLabel:setString(scoreTxtLabelValue)
	
	self.scoreTxtLabel:setOpacity(0)
	self.scoreTxtLabel:delayFadeIn(2.5, 0.4)

	self.scoreLabel:setString(tostring(self.score))
	self.scoreLabel:setOpacity(0)
	self.scoreLabel:delayFadeIn(2.5, 0.4)
end

function ScoreProgress:calcStar( _score )
	if self.star4Score and self.star4Score > 0 and _score >= self.star4Score then
		return 4
	end
	if self.star3Score and self.star3Score > 0 and _score >= self.star3Score then
		return 3
	end
	if self.star2Score and self.star2Score > 0 and _score >= self.star2Score then
		return 2
	end
	if self.star1Score and self.star1Score > 0 and _score >= self.star1Score then
		return 1
	end
	return 0
end

function ScoreProgress:dispose( ... )
	-- body
	if self.ladyBugAnimation then 
		self.ladyBugAnimation:dispose()
		self.ladyBugAnimation = nil
	end

end

function ScoreProgress:setScore(newScore, globalPos, animTime)
	assert(type(newScore) == "number")
	if not __PURE_LUA__ then
		assert(globalPos == false or type(globalPos) == "userdata")
	end

	local _animTime = animTime or 0.2
	self.score = newScore
	self.scoreLabel:setString(tostring(self.score))

	-- Update Scroll Bar
	local percentage	= false
	local percentage = 0
	if self.showStar4 then 
		percentage = newScore /  self.star4Score * self.maxPercentage
	else
		percentage = newScore /  self.star3Score * self.maxPercentage
	end

	if self.star4Score and newScore >= self.star4Score and not self._hasReachedFourStar then
		self._hasReachedFourStar = true
		self.ladyBugAnimation:playFourStarAnimation()
	else
		self.ladyBugAnimation:animateTo(percentage, _animTime)
	end

	if self.onScoreChangeCallback then
		local newStar = self:calcStar(newScore)
		self.onScoreChangeCallback(newScore, newStar)
	end
end

function ScoreProgress:setOnScoreChangeCallback( callback, ... )
	-- body
	assert(type(callback) == "function")
	assert(#{...} == 0)

	self.onScoreChangeCallback = callback
end

function ScoreProgress:revertScoreTo( newScore, ... )
	-- body
	assert(type(newScore) == "number")
	assert(#{...} == 0)

	self.score = newScore
	self.scoreLabel:setString(tostring(self.score))

	-- Update Scroll Bar
	local percentage	= false
	local percentage = 0
	if self.showStar4 then 
		percentage = newScore /  self.star4Score * self.maxPercentage
	else
		percentage = newScore /  self.star3Score * self.maxPercentage
	end
	self.ladyBugAnimation:revertTo(percentage)

	self:setScore( self.score , ccp(0,0) )
end

function ScoreProgress:addScore(deltaScore, globalPos, animTime)
	assert(deltaScore)
	if not __PURE_LUA__ then
		assert(globalPos == false or type(globalPos) == "userdata")
	end

	local curScore = self:getScore()
	local newScore = curScore + deltaScore

	if GameBoardLogic:getCurrentLogic() then
		local mainlogic = GameBoardLogic:getCurrentLogic()
		if mainlogic.totalScore and newScore > mainlogic.totalScore then
			newScore = mainlogic.totalScore
		end
	end

	self:setScore(newScore, globalPos, animTime)
end

function ScoreProgress:getScore( ... )
	-- body
	assert(#{...} == 0)

	return self.score
end

function ScoreProgress:getBigStarPosInWorldSpace(...)
	assert(#{...} == 0)

	return self.ladyBugAnimation:getBigStarPosInWorldSpace()
end

function ScoreProgress:getBigStarSize( ... )
	-- body
	assert(#{...} == 0)

	return self.ladyBugAnimation:getBigStarSize()
end

function ScoreProgress:setBigStarVisible( starIndex, visible, ... )
	-- body
	assert(type(starIndex) == "number")
	assert(type(visible) == "boolean")
	assert(#{...} == 0)

	self.ladyBugAnimation:setBigStarVisible(starIndex, visible)
end

function ScoreProgress:getStarWorldPos( starIndex )
	-- body
	if self.ladyBugAnimation.getStarWorldPos then
		return self.ladyBugAnimation:getStarWorldPos(starIndex)
	end
end