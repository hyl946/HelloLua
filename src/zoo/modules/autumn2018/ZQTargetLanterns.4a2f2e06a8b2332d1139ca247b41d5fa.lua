local ZQTargetLanterns = class(CocosObject)

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

function ZQTargetLanterns:ctor()
end

function ZQTargetLanterns:create(targetsConfig)
	local node = ZQTargetLanterns.new(CCNode:create())
	node:init(targetsConfig)
	return node
end

function ZQTargetLanterns:dispose()
	CocosObject.dispose(self)
end

function ZQTargetLanterns:init(targetsConfig)
	self.batchNode = CocosObject:create(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/autumn2018/mid_autumn_target.png"),20))
	self:addChild(self.batchNode)
	self.targetsConfig = targetsConfig
	self.curScore = 0
	self.lanterns = {}
	local lanternNum = #targetsConfig 
	self.lanternNum = lanternNum
	local posStartX = 0
	for i=lanternNum, 1, -1 do
		self.lanterns[i] = {}
		local pieceSmall = Sprite:createWithSpriteFrameName("target_piece")
		self.batchNode:addChild(pieceSmall)
		pieceSmall:setPosition(ccp(posStartX + (i-lanternNum) * 115 - 54, -126))
		self.lanterns[i].pieceSmall = pieceSmall

		local lantern = Sprite:createWithSpriteFrameName("target_lantern")
		lantern:setAnchorPoint(ccp(1, 1))
		self.batchNode:addChild(lantern)
		lantern:setPosition(ccp(posStartX + (i-lanternNum) * 115, 0))
		self.lanterns[i].lantern = lantern

		local numL = BitmapText:create(self.curScore, "fnt/18midautumn_lantern.fnt")
		numL:setAnchorPoint(ccp(1, 0.5))
		numL:setPosition(ccp(posStartX + (i-lanternNum) * 115 - 62, -72))
		self:addChild(numL)
		self.lanterns[i].numL = numL
		numL:setVisible(i == 1)

		local numR = BitmapText:create("/"..targetsConfig[i].num, "fnt/18midautumn_lanternylw.fnt")
		numR:setAnchorPoint(ccp(0, 0.5))
		numR:setPosition(ccp(posStartX + (i-lanternNum) * 115 - 62, -72))
		self:addChild(numR)
		self.lanterns[i].numR = numR
		numR:setVisible(i == 1)

		local numMid = BitmapText:create(targetsConfig[i].num, "fnt/18midautumn_lanternylw.fnt")
		numMid:setAnchorPoint(ccp(0.5, 0.5))
		numMid:setPosition(ccp(posStartX + (i-lanternNum) * 115 - 57, -72))
		self:addChild(numMid)
		self.lanterns[i].numMid = numMid
		numMid:setVisible(i ~= 1)

		self.lanterns[i].id = i
		self.lanterns[i].targetIndex = targetsConfig[i].targetIndex
		self.lanterns[i].numLimit = targetsConfig[i].num
		self.lanterns[i].isPlaying = false
		self.lanterns[i].isValid = true
	end

	self.curLantern = self.lanterns[1]
end

function ZQTargetLanterns:updateScore(score, withAni, callback)
	if self.curLantern then 
		self.curScore = score
		local curLantern = self.curLantern
		local curNumLimit = curLantern.numLimit
		curLantern.numL:setText(score)
		if self.curScore >= curNumLimit and not curLantern.isPlaying then
			local curIndex = curLantern.id
			self:playLanternFlyAni(curIndex, callback)
			if curIndex < self.lanternNum then
				self.curLantern = self.lanterns[curIndex+1]
				self.curLantern.numL:setText(score)
				self.curLantern.numL:setVisible(true)
				self.curLantern.numR:setVisible(true) 
				self.curLantern.numMid:setVisible(false)
			else
				ZQManager.getInstance():setTargetLanterns(nil)
				self.curLantern = nil
			end
		end
	end
end

function ZQTargetLanterns:playLanternFlyAni(lanternId, callback)
	local lantern = self.lanterns[lanternId]
	if lantern then
		lantern.isPlaying = true

		lantern.numL:runAction(CCFadeTo:create(0.3, 0)) 
		lantern.numR:runAction(CCFadeTo:create(0.3, 0)) 
		lantern.lantern:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(1, ccp(0, 200)), CCCallFunc:create(function ()
			lantern.lantern:setVisible(false)
		end)))

		lantern.pieceSmall:setOpacity(0)

		local pieceBig = Sprite:createWithSpriteFrameName("target_piece_big")
		local pieceNum = Sprite:createWithSpriteFrameName("target_piece_num_"..lantern.targetIndex)
		pieceBig:addChild(pieceNum)
		pieceNum:setPosition(ccp(53, 52))

		pieceBig:setScale(0.35)
		pieceBig:setRotation(-12.5)
		lantern.pieceSmall:addChild(pieceBig)

		local arr0 = CCArray:create()
		arr0:addObject(CCDelayTime:create(1))
		arr0:addObject(CCFadeTo:create(0.2, 0))
		pieceNum:runAction(CCSequence:create(arr0))

		local arr1 = CCArray:create()
		arr1:addObject(CCScaleTo:create(0.3, 1))
		arr1:addObject(CCScaleTo:create(0.2, 1.1))
		arr1:addObject(CCScaleTo:create(0.2, 1))
		arr1:addObject(CCDelayTime:create(0.3))
		arr1:addObject(CCFadeTo:create(0.2, 0))
		arr1:addObject(CCCallFunc:create(function ()
			pieceBig:setVisible(false)
			if lanternId == self.lanternNum then
				if callback then callback(true) end
			else
				if callback then callback(false) end
			end
		end))
		pieceBig:runAction(CCSequence:create(arr1))

		local arr2 = CCArray:create()
		local pos = self.batchNode:convertToNodeSpace(ccp(visibleOrigin.x + visibleSize.width/2, 0)) 
		local nowPos = lantern.pieceSmall:getPosition()
		local posDelta = pos.x - nowPos.x
		arr2:addObject(CCMoveBy:create(0.3, ccp(posDelta + 45, -80)))
		arr2:addObject(CCCallFunc:create(function ()
			local lightSp, animate = SpriteUtil:buildAnimatedSprite(1/30, "target_light_%04d", 0, 21)
			lightSp:setScale(1.8)
			lantern.pieceSmall:addChildAt(lightSp, 0)
			lightSp:play(animate, 0, 1, function ()
				lightSp:setVisible(false)
			end)
		end))
		lantern.pieceSmall:runAction(CCSequence:create(arr2))
	end
end

function ZQTargetLanterns:getFlyEndPos(specifyNodeSpace)
	if self.curLantern then
		local nodePos = self.curLantern.lantern:getPosition()
		nodePos = {x = nodePos.x - 55, y = nodePos.y - 55}
		local worldPos = self.batchNode:convertToWorldSpace(ccp(nodePos.x, nodePos.y))
		local endPos 
		if specifyNodeSpace then
			endPos = specifyNodeSpace:convertToNodeSpace(ccp(worldPos.x, worldPos.y))
		else
			endPos = worldPos 
		end
		return {x = endPos.x, y = endPos.y} 
	end
end

return ZQTargetLanterns