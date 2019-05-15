---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-03 14:27:39
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-08 18:03:34
---------------------------------------------------------------------------------------
OlympicScoreProgressAnimation = class(ScoreProgressAnimation)

local kStarFactor = 24 * 3.1415926 / 180
local kMaskBeginWidth = 17
local kMaskEndWidth = 50

function OlympicScoreProgressAnimation:create(scoreProgress, pos)
	-- body
	local s = OlympicScoreProgressAnimation.new()
	s:init(scoreProgress, pos)
	s:moveTo(0)
	return s
end

function OlympicScoreProgressAnimation:init( scoreProgress, pos )
	ScoreProgressAnimation.init(self, scoreProgress, pos)
	-- self.animal:setVisible(false)
end

function OlympicScoreProgressAnimation:setStarPosition( star, progress )
	-- body
	if progress < 0 then progress = 0 end
	if progress > 1 then progress = 1 end
	local position = self.spine:calculatePosition(progress)
	local gPos = self.ladybug:convertToWorldSpace(position)
	local displayLayer = self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]
	star:setPosition(displayLayer:convertToNodeSpace(gPos))
end

function OlympicScoreProgressAnimation:setStarsPosition( star1progress, star2progress, star3progress )	
	if star3progress > 0.8 then star3progress = 0.8 end

	self.star1progress = star1progress
	self.star2progress = star2progress
	self.star3progress = star3progress

	self:setStarPosition(self.star1, star1progress)
	self:setStarPosition(self.star2, star2progress)
	self:setStarPosition(self.star3, star3progress)
end

function OlympicScoreProgressAnimation:updateMaskProgress( progress )
	-- body
	local position = self.animal:getPosition()
	local width = position.x - kMaskBeginWidth
	local max = self.spriteWidth - kMaskEndWidth
	if width > max then width = max end
     -- 为什么是0.88？因为ScoreProgressBar里面的maxPercentage是0.88
     -- 就是说达到3星分数时，progress是0.88
	if progress >= 0.8 then width = self.spriteWidth end
	self.stencilNode:setContentSize(CCSizeMake(width, self.spriteHeight)) 
end

function OlympicScoreProgressAnimation:getBigStarPosInWorldSpace(...)
	assert(#{...} == 0)

	local star1Pos	= self.star1:getPosition()
	local star2Pos	= self.star2:getPosition()
	local star3Pos	= self.star3:getPosition()
    local star4Pos  = self.fourthStar:getPosition()

    local displayLayer = self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]
	-- Convert To World Space
	local star1WorldPos = displayLayer:convertToWorldSpace(ccp(star1Pos.x, star1Pos.y))
	local star2WorldPos = displayLayer:convertToWorldSpace(ccp(star2Pos.x, star2Pos.y))
	local star3WorldPos = displayLayer:convertToWorldSpace(ccp(star3Pos.x, star3Pos.y))
    local star4WorldPos = displayLayer:convertToWorldSpace(ccp(star4Pos.x, star4Pos.y))

	return {star1WorldPos, star2WorldPos, star3WorldPos, star4WorldPos}
end

function OlympicScoreProgressAnimation:createDarkStar( textKey, starIndex )
	-- body
	self.ladybug:getChildByName(textKey):setVisible(false)
	local pos = self.ladybug:getChildByName(textKey):getPosition()
	local globalPos = self.ladybug:convertToWorldSpace(pos)

	local ArmatureNodeNames = {"olympic_medals/bronze", "olympic_medals/silver", "olympic_medals/golden"}
	local OffsetPositions = {ccp(-15, 28), ccp(-15, 20), ccp(-13, 13)}
	local container = Sprite:createEmpty() -- LayerColor:createWithColor(ccc3(255, 0, 0), 60, 60) -- self.ladybug:getChildByName(textKey)
	local node = ArmatureNode:create( ArmatureNodeNames[starIndex] )
	node:playByIndex(0, 1)
	node:update(0.001)
	node:stop()
	node:setPosition(OffsetPositions[starIndex])
	container.medalNode = node
	container:addChild(node)

	local displayLayer = self.parent.displayLayer[GamePlaySceneTopAreaType.kEffect]
	container:setPosition(displayLayer:convertToNodeSpace(globalPos))
	displayLayer:addChild(container)

	container.starIndex = starIndex

	local function onTouchTap(evt) 
		local score = self["star"..starIndex.."score"] or 0
		local dark = self["star"..starIndex]
		-- local light = self["bigstar"..starIndex]
		if light then dark = light end
		local fntFile = "fnt/energy_cd.fnt"
		local label = BitmapText:create(tostring(score), fntFile)
		local function onAnimationFinished() label:removeFromParentAndCleanup(true) end
		local array = CCArray:create()
		array:addObject(CCEaseBackOut:create(CCMoveBy:create(0.3, ccp(0, 20)))) 
		array:addObject(CCDelayTime:create(0.5))
		array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5), CCMoveBy:create(0.3, ccp(0, 10))))
		array:addObject(CCCallFunc:create(onAnimationFinished))
		label:runAction(CCSequence:create(array))
		label:setPosition(container:convertToWorldSpace(ccp(0, 0)))
		
		-- local shake = CCArray:create()
		-- shake:addObject(CCMoveBy:create(0.05, ccp(-3, 0)))
		-- shake:addObject(CCMoveBy:create(0.1, ccp(6, 0)))
		-- shake:addObject(CCMoveBy:create(0.05, ccp(-3, 0)))
		-- dark:runAction(CCSequence:create(shake))

		local scene = Director:sharedDirector():getRunningScene()
		if scene then scene:addChild(label) end
	end

	container:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.parent:addTouchList(container)
	return container
end

function OlympicScoreProgressAnimation:showStar( star, starName )
	if star.hasShowed then return end

	if star and star.medalNode then
		star.medalNode:playByIndex(0, 1)
		star.hasShowed = true
	end
	if star == self.star1 then
		self.starLevel = 1
	elseif star == self.star2 then
		self.starLevel = 2
	elseif star == self.star3 then
		self.starLevel = 3
	end
end

function OlympicScoreProgressAnimation:updateStarProgress( progress )
	if progress < 0 then progress = 0 end
	if progress > 1 then progress = 1 end
	if self.star1progress ~= nil and self.star2progress ~= nil and self.star3progress ~= nil then
		if progress >= self.star1progress and self.bigstar1 == nil then
			self:showStar(self.star1, "bigstar1")
		end

		if progress >= self.star2progress and self.bigstar2 == nil then
			self:showStar(self.star2, "bigstar2")
		end

		if progress >= self.star3progress and self.bigstar3 == nil then
			self:showStar(self.star3, "bigstar3")
		end
	end
end