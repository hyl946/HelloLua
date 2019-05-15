---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-01 20:32:22
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-04 12:20:51
---------------------------------------------------------------------------------------
OlympicScoreBoard = class(CocosObject)

function OlympicScoreBoard:ctor( ... )
	-- body
end

function OlympicScoreBoard:create()
	local node = OlympicScoreBoard.new(CCNode:create())
	node:init()
	return node
end

function OlympicScoreBoard:init()
	self.builder = InterfaceBuilder:create("flash/olympic/olympic_ingame.json")
	local scoreBoard = self.builder:buildGroup("OlympicIngame/score_board2")
	--local scoreBoard = self.builder:buildGroup("OlympicIngame/score_board")
	self:addChild(scoreBoard)
	self.scoreBoard = scoreBoard

	self.numberLabel = scoreBoard:getChildByName("number")

	self.totalWidth = self:getGroupBounds().size.width
	self.currScore = 0
	self:updateScore(0)

	--self.lowAnimateZIndex = scoreBoard:getChildByName("lowAnimate"):getZOrder()
	--self.hightAnimateZIndex = scoreBoard:getChildByName("highAnimate"):getZOrder()

	--[[
	self.scoreNodes = {}
	for i = 1, 5 do
		local scoreNode = self.scoreBoard:getChildByName("score"..tostring(i))
		local gb = scoreNode:getChildByName("numberSize"):getGroupBounds(scoreNode)
		local numberLabel = BitmapText:create("0", "fnt/score.fnt")
		local numberSize = numberLabel:getContentSize()
		numberLabel:setAnchorPoint(ccp(0.5, 0.5))
		numberLabel:ignoreAnchorPointForPosition(false)
		numberLabel:setScale(gb.size.height/numberSize.height * 1.1) -- math.min(gb.size.width/numberSize.width, gb.size.height/numberSize.height)
		numberLabel:setPosition(ccp(gb.origin.x + gb.size.width/2 - 2, gb.origin.y + gb.size.height/2))
		local zIndex = scoreNode:getChildByName("numberSize"):getZOrder()
		scoreNode:addChildAt(numberLabel, zIndex)
		scoreNode.numberLabel = numberLabel
		scoreNode:getChildByName("numberSize"):removeFromParentAndCleanup(true)
		scoreNode:getChildByName("number"):removeFromParentAndCleanup(true)
		self.scoreNodes[i] = scoreNode
	end
	]]
end

function OlympicScoreBoard:updateScoreNode(scoreNode, num, withAnimation)
	--[[
	scoreNode.numberLabel:setText(tostring(num))

	if not withAnimation then return end

	local posOffsetX, posOffsetY = 16, -10
	local posX, posY = scoreNode:getPositionX(), scoreNode:getPositionY()
	local card, animate = SpriteUtil:buildAnimatedSprite(1 / 24, "olympic_score_card_%04d", 0, 4)
	local function onFinish()
		card:removeFromParentAndCleanup(true)
		local card2, animate = SpriteUtil:buildAnimatedSprite(1 / 24, "olympic_score_card_%04d", 5, 7)
		local function onFinish2()
			card2:removeFromParentAndCleanup(true)
		end
		card2:play(animate, 0, 1, onFinish2)
		card2:setPosition(ccp(posX+posOffsetX, posY+posOffsetY))
		self.scoreBoard:addChildAt(card2, self.hightAnimateZIndex)
	end
	card:play(animate, 0, 1, onFinish)
	card:setPosition(ccp(posX+posOffsetX, posY+posOffsetY))
	self.scoreBoard:addChildAt(card, self.lowAnimateZIndex)
	]]
end

function OlympicScoreBoard:updateScore(score, withAnimation)

	if score < self.currScore then
		return
	end
	self.currScore = score
	self.numberLabel:setText( tostring(score) )

	local size = self.numberLabel:getGroupBounds().size

	--printx( 1 , "    OlympicScoreBoard:updateScore   score = " , score)
	self.numberLabel:setPositionX( self.totalWidth - size.width - 10 )
	--[[
	local scoreNums = string.format("%05d", score)
	scoreNums = string.sub(scoreNums, string.len(scoreNums) - 5 + 1)
	for i = 1, 5 do
		local num = string.sub(scoreNums, i, i)
		local scoreNode = self.scoreNodes[i]
		if scoreNode and scoreNode.numberLabel and scoreNode.numberLabel:getString() ~= num then
			self:updateScoreNode(scoreNode, num, withAnimation)
		end
	end
	]]
end

function OlympicScoreBoard:dispose()
	CocosObject.dispose(self)
end