
ZQScoreBoard = class(CocosObject)

function ZQScoreBoard:ctor()
end

function ZQScoreBoard:create()
	local node = ZQScoreBoard.new(CCNode:create())
	node:init()
	return node
end

function ZQScoreBoard:init()
	local scoreBoard = Sprite:createWithSpriteFrameName("score_board_lantern")
	scoreBoard:setAnchorPoint(ccp(1, 1))
	self:addChild(scoreBoard)
	self.scoreBoard = scoreBoard

	local numberLabel = BitmapText:create("0", "fnt/18midautumn_lanternylw.fnt")
	numberLabel:setAnchorPoint(ccp(0.5, 0.5))
	numberLabel:setPosition(ccp(-45, -60))
	self:addChild(numberLabel)
	self.numberLabel = numberLabel

	self.currScore = 0
	self:updateScore(0)
end

function ZQScoreBoard:updateScoreNode(scoreNode, num, withAnimation)
end

function ZQScoreBoard:updateScore(score, withAnimation)
	if score < self.currScore then
		return
	end
	self.currScore = score
	self.numberLabel:setText( tostring(score) )

	-- local size = self.numberLabel:getGroupBounds().size
	-- self.numberLabel:setPositionX( self.totalWidth - size.width - 10 )
end

function ZQScoreBoard:getFlyEndPos(specifyNodeSpace)
	local parent = self:getParent()
	local nodePos = self:getPosition()
	nodePos = {x = nodePos.x - 45, y = nodePos.y - 45}
	local worldPos = parent:convertToWorldSpace(ccp(nodePos.x, nodePos.y))
	local endPos 
	if specifyNodeSpace then
		endPos = specifyNodeSpace:convertToNodeSpace(ccp(worldPos.x, worldPos.y))
	else
		endPos = worldPos 
	end
	return {x = endPos.x, y = endPos.y}
end

function ZQScoreBoard:dispose()
	CocosObject.dispose(self)
end