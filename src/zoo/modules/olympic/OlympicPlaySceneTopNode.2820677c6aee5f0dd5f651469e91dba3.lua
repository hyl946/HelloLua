---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-03 15:51:09
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-08-08 16:25:53
---------------------------------------------------------------------------------------
require("zoo.modules.olympic.OlympicAnimalAnimation")
require("zoo.modules.olympic.OlympicAnimalRaccoon")

OlympicPlaySceneTopNode = class()

local kAnimalScale = 0.95
if __isWildScreen then
	kAnimalScale = 0.70
end

function OlympicPlaySceneTopNode:create(gamePlayScene, topNodePosY)
	local node = OlympicPlaySceneTopNode.new()
	node:init(gamePlayScene, topNodePosY)
	return node
end

function OlympicPlaySceneTopNode:init(gamePlayScene, topNodePosY)
	topNodePosY = topNodePosY or 0
	local bossLayer = gamePlayScene.bossLayer
	local frontTopNode = CocosObject.new(CCNode:create())
	frontTopNode:setPosition(ccp(0, topNodePosY))
	bossLayer:addChild(frontTopNode)

	local bossLowerLayer = gamePlayScene.bossLowerLayer
	local bellowTopNode = CocosObject.new(CCNode:create())
	bellowTopNode:setPosition(ccp(0, topNodePosY))
	bossLowerLayer:addChild(bellowTopNode)

	self.frontTopNode = frontTopNode
	self.bellowTopNode = bellowTopNode

	self.isFollowAnimalFall = false
	self.frontAnimalBaseX = 110
	self.followAnimalBaseX = 40
	self.roadHoles = {}
	self.roadHolesLayer = Layer:create()
	bellowTopNode:addChild(self.roadHolesLayer)
	self.animalsLayer = Layer:create()
	frontTopNode:addChild(self.animalsLayer)
	self.effectLayer = Layer:create()
	frontTopNode:addChild(self.effectLayer)

	--local playSceneUI = gamePlayScene.gameBoardLogic.PlayUIDelegate
	--self.scoreBoard = playSceneUI.topArea.olympicScoreBoard
	self.scoreBoard = gamePlayScene.topArea.olympicScoreBoard
end

function OlympicPlaySceneTopNode:getAnimalScale()
	return kAnimalScale
end

function OlympicPlaySceneTopNode:getFollowAnimalPos()
	return self:convertToWorldSpace(self:getFollowAnimalPos())
end

function OlympicPlaySceneTopNode:getBananaPos()
	return self:convertToWorldSpace(self:getLocalBananaPos())
end

function OlympicPlaySceneTopNode:getLocalFollowAnimalPos()
	local followPos = ccp(self.followAnimalBaseX, 55)
	local frontPos = self.frontAnimal:getPosition()

	--printx( 1 , "   OlympicPlaySceneTopNode:getLocalFollowAnimalPos ++++++++++++++++++  " , followPos.x , frontPos.x)

	if frontPos.x - followPos.x < 65 then
		return ccp(self.followAnimalBaseX - 30 , 55)
	else
		return ccp(self.followAnimalBaseX, 55)
	end 
end

function OlympicPlaySceneTopNode:getLocalFrontAnimalPos()
	return ccp(self.frontAnimalBaseX, 55)
end

function OlympicPlaySceneTopNode:getLocalBananaPos()
	return ccp(self.followAnimalBaseX + 60 * kAnimalScale, 55)
end

function OlympicPlaySceneTopNode:convertToNodeSpace(pos)
	return self.frontTopNode:convertToNodeSpace(pos)
end

function OlympicPlaySceneTopNode:convertToWorldSpace(pos)
	return self.frontTopNode:convertToWorldSpace(pos)
end

function OlympicPlaySceneTopNode:createUserHeader(animalId)
	animalId = tonumber(animalId) or 1
	if animalId < 1 or animalId > 6 then return nil end
	local builder = InterfaceBuilder:create( "flash/olympic/olympic_ingame.json" )
	local header = builder:buildGroup("OlympicIngame/user_header")

	local border = header:getChildByName("border") --OlympicIngame/head_border_
	local pos = border:getPosition()
	local borderSize = border:getGroupBounds().size

	local replaceBorder = Sprite:createWithSpriteFrameName(string.format("OlympicIngame/head_border_%d0000", animalId))
	replaceBorder:setPosition(ccp(pos.x + borderSize.width/2, pos.y-borderSize.height/2))
	header:addChildAt(replaceBorder, border:getZOrder())
	border:removeFromParentAndCleanup(true)

	local headerHolder = header:getChildByName("header_holder")
	local zIndex = headerHolder:getZOrder()
	local framePos = headerHolder:getPosition()
	local frameSize = headerHolder:getGroupBounds().size
	framePos = {x = framePos.x, y = framePos.y}
	frameSize = {width = frameSize.width, height = frameSize.height}

	headerHolder:removeFromParentAndCleanup(true)

	local profile = UserManager.getInstance().profile
	local uid = UserManager.getInstance().uid
	local headUrl = profile and profile.headUrl or 1
	local function onImageLoadFinishCallback(clipping)
		if not header or header.isDisposed then return end

		local clippingSize = clipping:getContentSize()
		clipping:setScaleX(frameSize.width / clippingSize.width)
		clipping:setScaleY(frameSize.height / clippingSize.height)
		clipping:setPosition(ccp(framePos.x + frameSize.width/2, framePos.y - frameSize.height/2))
		header:addChildAt(clipping, zIndex)
	end
	HeadImageLoader:create(uid, headUrl, onImageLoadFinishCallback)
	return header
end

local kHeaderPositionById = {
	[1] = {x=-10, y=120},
	[2] = {x=-10, y=110},
	[3] = {x=-5, y=120},
	[4] = {x=0, y=115},
	[5] = {x=-10, y=110},
	[6] = {x=0, y=75},
}
function OlympicPlaySceneTopNode:initAnimals(frontAnimalId, frontAnimalBaseX, followAnimalBaseX)
	if frontAnimalBaseX then self.frontAnimalBaseX = self:convertToNodeSpace(ccp(frontAnimalBaseX, 0)).x end
	if followAnimalBaseX then self.followAnimalBaseX = self:convertToNodeSpace(ccp(followAnimalBaseX, 0)).x end
	self.frontAnimalId = frontAnimalId or 1
	--self.frontAnimalId = 6

	local animal = OlympicAnimalAnimation:createAnimal(self.frontAnimalId , OlympicAnimalAnimationState.kWait)
	animal:setPosition(self:getLocalFrontAnimalPos())
	self.frontAnimal = animal
	self.frontAnimal:setScale(kAnimalScale)
	local header = self:createUserHeader(self.frontAnimalId)
	if header then
		local headerPos = kHeaderPositionById[self.frontAnimalId]
		if headerPos then
			header:setPosition(ccp(headerPos.x, headerPos.y))
		end
		self.frontAnimal:addChild(header)
	end

	self.animalsLayer:addChild(animal)
	local animal2 = OlympicAnimalAnimation:createAnimal(0 , OlympicAnimalAnimationState.kWait)
	animal2:setPosition(self:getLocalFollowAnimalPos())
	self.followAnimal = animal2
	self.followAnimal:setScale(kAnimalScale)
	self.animalsLayer:addChild(animal2)
end

function OlympicPlaySceneTopNode:playFollowAnimalJump(finalStatus, onFinished)
	if not self.isFollowAnimalFall then return false end

	finalStatus = finalStatus or OlympicAnimalAnimationState.kWait

	--[[
	local function onJumpComplete()
		self.followAnimal:removeFromParentAndCleanup(true)
		self.isFollowAnimalFall = false

		self.followAnimal = OlympicAnimalAnimation:createAnimal(0, finalStatus)
		self.followAnimal:setScale(kAnimalScale)
		self.followAnimal:setPosition(self:getLocalFollowAnimalPos())
		self.animalsLayer:addChild(self.followAnimal)

		if onFinished then onFinished() end
	end
	local jumpType = OlympicAnimalRaccoonStatus.kJump2
	if finalStatus == OlympicAnimalAnimationState.kRun then
		jumpType = OlympicAnimalRaccoonStatus.kJump1
	end
	self.followAnimal:changeStatus(jumpType, onJumpComplete)
	]]

	self.followAnimal:change(0 , OlympicAnimalAnimationState.kRecover)
	setTimeOut( function () 
			self.isFollowAnimalFall = false
			if onFinished then onFinished() end 
		end , 1 )
end

function OlympicPlaySceneTopNode:playFollowAnimalFall(onFinished)
	if self.isFollowAnimalFall then return false end

	self.isFollowAnimalFall = true

	--[[
	local function playAnimalFallDown()
		self.followAnimal:removeFromParentAndCleanup(true)
		self.followAnimal = OlympicAnimalRaccoon:create()
		self.followAnimal:setScale(kAnimalScale)
		self.followAnimal:setPosition(self:getLocalFollowAnimalPos())
		self.animalsLayer:addChild(self.followAnimal)

		local function onFallComplete()
			self:setSwoonRoundLabelVisible(true)
			self.followAnimal:changeStatus(OlympicAnimalRaccoonStatus.kSwoon)
			if onFinished then onFinished() end
		end
		self.followAnimal:changeStatus(OlympicAnimalRaccoonStatus.kFall, onFallComplete)
	end
	self:playBananaDrop(playAnimalFallDown)
	]]

	self.followAnimal:change(0 , OlympicAnimalAnimationState.kDizziness)

	self:setSwoonRoundLabelVisible(true)
	if onFinished then onFinished() end

	return true
end

function OlympicPlaySceneTopNode:setSwoonRoundLabelVisible(isVisible)
	if not self.swoonRoundLabel or self.swoonRoundLabel.isDisposed then return end
	self.swoonRoundLabel:setVisible(isVisible == true)
end

function OlympicPlaySceneTopNode:updateFollowAnimalSwoonRound(swoonRound)
	if not self.swoonRoundLabel then
		self.swoonRoundLabel = BitmapText:create("0", "fnt/race_rank.fnt", 200)
		self.swoonRoundLabel:setAnchorPoint(ccp(0.5, 0.5))
		self.swoonRoundLabel:ignoreAnchorPointForPosition(false)
		self.swoonRoundLabel:setPreferredSize(120, 44)
		self.swoonRoundLabel:setVisible(false)

		local pos = self:getLocalFollowAnimalPos()
		self.swoonRoundLabel:setPosition(ccp(pos.x, pos.y + 160 * kAnimalScale))
		self.effectLayer:addChild(self.swoonRoundLabel)
	end

	if self.swoonRoundLabel.isDisposed then return end
	if swoonRound < 0 then swoonRound = 0 end
	if swoonRound > 0 then
		self.swoonRoundLabel:setString(tostring(swoonRound))
	else
		self.swoonRoundLabel:setString("")
	end
end

function OlympicPlaySceneTopNode:playBananaDrop(onDropComplete)
	local animation = ArmatureNode:create( "OlympicBanana/banana_drop" )
	animation:playByIndex(0, 1)
	animation:update(0.001)
	animation:stop()
	animation:setScale(kAnimalScale)
	animation:setPosition(self:getLocalBananaPos())
	animation:playByIndex(0, 1)
	local function onComplete()
		animation:removeFromParentAndCleanup(true)
		if onDropComplete then onDropComplete() end
	end
	animation:addEventListener(ArmatureEvents.COMPLETE, onComplete)
	self.animalsLayer:addChild(animation)
end

function OlympicPlaySceneTopNode:playFrontAnimalRunTo(globalPosX, time)
	time = time or 0.5
	self.frontAnimal:change(self.frontAnimalId , OlympicAnimalAnimationState.kRun)
	local actionArr = CCArray:create()
	local posY = self.frontAnimal:getPositionY()
	local targetPosX = self:convertToNodeSpace(ccp(globalPosX, 0)).x
	local followPos = ccp(self.followAnimalBaseX, 55)
	local frontPos = ccp(targetPosX, posY)

	actionArr:addObject(CCMoveTo:create( time, frontPos ))
	local function onRunFinish()
		self.frontAnimal:change(self.frontAnimalId , OlympicAnimalAnimationState.kWait)
	end
	actionArr:addObject(CCCallFunc:create(onRunFinish))

	self.frontAnimal:stopAllActions()
	self.frontAnimal:runAction(CCSequence:create(actionArr))
	--printx( 1 , "   OlympicPlaySceneTopNode:playFrontAnimalRunTo  " , frontPos.x , followPos.x , frontPos.x - followPos.x)
	local labelpos = nil
	if self.swoonRoundLabel then 
		labelpos = self.swoonRoundLabel:getPosition()
	end

	if frontPos.x - followPos.x < 65 then
		self.followAnimal:runAction(CCMoveTo:create(0.4, ccp(followPos.x - 30 , followPos.y) ))
		if self.swoonRoundLabel then 
			self.swoonRoundLabel:runAction(CCMoveTo:create(0.4, ccp(followPos.x - 30 , labelpos.y) )) 
		end
	else
		self.followAnimal:runAction(CCMoveTo:create(0.4, ccp(followPos.x , followPos.y) ))
		if self.swoonRoundLabel then 
			self.swoonRoundLabel:runAction(CCMoveTo:create(0.4, ccp(followPos.x , labelpos.y) )) 
		end
	end 

end

function OlympicPlaySceneTopNode:playFrontAnimalMoveTo(globalPosX, time)
	time = time or 0.5
	local posY = self.frontAnimal:getPositionY()
	local targetPosX = self:convertToNodeSpace(ccp(globalPosX, 0)).x

	local followPos = ccp(self.followAnimalBaseX, 55)
	local frontPos = ccp(targetPosX, posY)

	self.frontAnimal:stopAllActions()

	local actionArr = CCArray:create()
	actionArr:addObject(CCMoveTo:create(time, frontPos ))
	actionArr:addObject(CCCallFunc:create(function () 
		end))
	self.frontAnimal:runAction(CCSequence:create(actionArr))

	--printx( 1 , "   OlympicPlaySceneTopNode:playFrontAnimalMoveTo  frontPos.x - followPos.x = " , frontPos.x - followPos.x)
	local labelpos = nil
	if self.swoonRoundLabel then 
		labelpos = self.swoonRoundLabel:getPosition()
	end

	if frontPos.x - followPos.x < 65 then
		self.followAnimal:runAction(CCMoveTo:create(0.4, ccp(followPos.x - 30 , followPos.y) ))
		if self.swoonRoundLabel then 
			self.swoonRoundLabel:runAction(CCMoveTo:create(0.4, ccp(followPos.x - 30 , labelpos.y) )) 
		end
	else
		self.followAnimal:runAction(CCMoveTo:create(0.4, ccp(followPos.x , followPos.y) ))
		if self.swoonRoundLabel then 
			self.swoonRoundLabel:runAction(CCMoveTo:create(0.4, ccp(followPos.x , labelpos.y) ))
		end 
	end 
end

function OlympicPlaySceneTopNode:playFollowAnimalRun()
	if not self.isFollowAnimalFall then
		self.followAnimal:change(0 , OlympicAnimalAnimationState.kRun)
	end
end

function OlympicPlaySceneTopNode:playAnimalWaitAnimate()
	if not self.isFollowAnimalFall then
		self.followAnimal:change(0 , OlympicAnimalAnimationState.kWait)
	end
	self.frontAnimal:change(self.frontAnimalId , OlympicAnimalAnimationState.kWait)
end

function OlympicPlaySceneTopNode:addRoadHoles(globalPosX, colId, onFinished)
	if not globalPosX then return end
	if self.roadHoles[colId] then
		return
	end
	if colId == 2 then
		globalPosX = globalPosX + 20
	end
	
	--local holeSprite, animate = SpriteUtil:buildAnimatedSprite(1/24, "olympic_hole_appear_%04d", 0, 17)
	local holeSprite = OlympicAnimalAnimation:createHoleStateAnimal()

	local function onRepeatFinishCallback()
		if onFinished then onFinished() end
	end
	
	--holeSprite:play(animate, 0, 1, onRepeatFinishCallback, false)

	local localPosX = self:convertToNodeSpace(ccp(globalPosX, 0)).x
	holeSprite:setPosition(ccp(localPosX, 50 + math.random(0, 25)))

	self.roadHolesLayer:addChild(holeSprite)
	self.roadHoles[colId] = holeSprite
end


function OlympicPlaySceneTopNode:moveHoles(time, getPosFunc)
	--printx( 1 , "   OlympicPlaySceneTopNode:moveHoles " , time, getPosFunc)
	local removeHoleColIds = {}
	for colId, hole in pairs(self.roadHoles) do
		local pos, needRemove = getPosFunc(colId)
		local targetPosX = self:convertToNodeSpace(pos).x
		hole:stopAllActions()

		local actionArr = CCArray:create()
		--printx( 1 , "   OlympicPlaySceneTopNode:moveHoles  !!!!!!!!!!!!!!!!!!!!!!!! needRemove = " , needRemove , colId , targetPosX)
		if needRemove then
			actionArr:addObject(CCMoveTo:create(time, ccp(targetPosX, hole:getPositionY())))
			actionArr:addObject(CCDelayTime:create(0.1))
			actionArr:addObject(CCCallFunc:create(function() 
					hole.body:play( "out" , 1) 
					self.followAnimal:change(0 , OlympicAnimalAnimationState.kLose)
				end))
			actionArr:addObject(CCDelayTime:create(0.5))
			actionArr:addObject(CCCallFunc:create(function() 
					hole.body:stop()
					hole:removeFromParentAndCleanup(true) 
				end))
			table.insert(removeHoleColIds, colId)

			
			

			local function createMask(maskWidth , maskHeight , maskY)
				local theMask = LayerColor:create()
				theMask:changeWidthAndHeight(maskWidth, maskHeight)
				theMask:setTouchEnabled(true, 0, false)
				theMask:setOpacity(255 * 0.7)

				theMask:setPositionY( maskY )

				local actArr = CCArray:create()
				actArr:addObject(CCDelayTime:create(2.3))
				actArr:addObject(CCFadeTo:create(0.1, 0))
				--actArr:addObject(CCDelayTime:create(0.1))
				actArr:addObject(CCCallFunc:create(function()
					theMask:removeFromParentAndCleanup(true) 
				end))

				theMask:runAction(CCSequence:create(actArr))

				return theMask
			end

			local wSize = Director:sharedDirector():getWinSize()
			local trueMask_top = createMask( wSize.width, wSize.height , 200)
			local trueMask_bottom = createMask( wSize.width, wSize.height , (wSize.height * -1 + 40) )
			
			self.effectLayer:addChild(trueMask_top)
			self.effectLayer:addChild(trueMask_bottom)

		else
			if colId == 3 then
				targetPosX = targetPosX + 20
			end

			actionArr:addObject(CCMoveTo:create(time, ccp(targetPosX, hole:getPositionY())))
		end
		hole:runAction(CCSequence:create(actionArr))
	end
	for _, colId in ipairs(removeHoleColIds) do
		self.roadHoles[colId] = nil
	end
	-- self.frontAnimal:stopAllActions()
	-- self.frontAnimal:runAction(CCMoveBy:create(time, ccp(distanceX, 0)))
end

function OlympicPlaySceneTopNode:playFlyToHoleEffect(colId, fromGlobalPos, needRemove, onFinished)
	--printx( 1 , "   OlympicPlaySceneTopNode:playFlyToHoleEffect " , colId, fromGlobalPos.x , fromGlobalPos.y , needRemove, onFinished)
	
	local icePos = self.effectLayer:convertToNodeSpace(fromGlobalPos)
	local scoreBoardPos = self.effectLayer:convertToNodeSpace( self.scoreBoard:convertToWorldSpace(ccp(0,0)) )
	local scoreBoardSize = self.scoreBoard:getGroupBounds().size
	local glodIconFlyToPos = ccp(scoreBoardPos.x + (scoreBoardSize.width/2),scoreBoardPos.y - scoreBoardSize.height + 40)
	

	local glodIcon = Sprite:createWithSpriteFrameName("olympic_gold_icon")
	local actionArrCollect = CCArray:create()
	actionArrCollect:addObject(CCDelayTime:create(1.05)) 
	actionArrCollect:addObject(CCCallFunc:create(function () 
			glodIcon:removeFromParentAndCleanup(true)
		end))

	glodIcon:setPositionXY( icePos.x , icePos.y )

	glodIcon:runAction(CCEaseSineOut:create( CCMoveTo:create( 1 , glodIconFlyToPos ) ))
	glodIcon:runAction(CCFadeTo:create( 1 , 255/3 ))
	glodIcon:runAction(CCSequence:create(actionArrCollect))

	self.effectLayer:addChild(glodIcon)



	if self.roadHoles[colId] then
		local holeSprite = self.roadHoles[colId]

		if holeSprite.isDisposed then
			if onFinished then onFinished() end
			return 
		end

		local fromPos = holeSprite:getPosition()
		local targetPos = self.frontAnimal:getPosition()

		--printx( 1 , "   RRR   OlympicPlaySceneTopNode:playFlyToHoleEffect  fromGlobalPos = " , fromGlobalPos.x,fromGlobalPos.y , "  fromPos = " , fromPos.x , fromPos.y)
		--printx( 1 , "   RRR   OlympicPlaySceneTopNode:playFlyToHoleEffect   holeSprite:getPosition() " , holeSprite:getPosition().x , holeSprite:getPosition().y)
		local function flyFinishedCallback()
			
			if onFinished then onFinished() end

		end
		
		if needRemove then

			holeSprite.body:play( "out" , 1)
			local actionArr = CCArray:create()
			--actionArr:addObject(CCFadeOut:create(8/24))
			actionArr:addObject(CCDelayTime:create(0.5))
			actionArr:addObject(CCCallFunc:create(function() holeSprite:removeFromParentAndCleanup(true) end))
			holeSprite.body:runAction(CCSequence:create(actionArr))

			self.roadHoles[colId] = nil

			local fromCCP = ccp( fromPos.x , fromPos.y + 20 )
			local toCCP = ccp( targetPos.x + 20 , targetPos.y + 50 )

			local function playBoomEff()
				local lightSprite = OlympicAnimalAnimation:createGlodBoomAnimal()
				lightSprite:setPosition(ccp(toCCP.x, toCCP.y + 40))
				self.roadHolesLayer:addChild(lightSprite)
				local actionArr3 = CCArray:create()
				actionArr3:addObject(CCDelayTime:create(0.5))
				actionArr3:addObject(CCCallFunc:create(function() lightSprite:removeFromParentAndCleanup(true) end))
				lightSprite.body:runAction(CCSequence:create(actionArr3))
			end

			local ball = Sprite:createWithSpriteFrameName("olympic_gold_fly_effect")
			ball:setPositionXY( fromCCP.x , fromCCP.y )

			local controlPoint = nil
			controlPoint = ccp(toCCP.x - (toCCP.x - fromCCP.x) / 5, toCCP.y + 200)

			local bezierConfig = ccBezierConfig:new()
			bezierConfig.controlPoint_1 = fromCCP
			bezierConfig.controlPoint_2 = controlPoint
			bezierConfig.endPosition = toCCP
			local bezierAction = CCBezierTo:create(0.5, bezierConfig)

			local actionList = CCArray:create()
			actionList:addObject(bezierAction)
			actionList:addObject(CCCallFunc:create(function() 
				ball:removeFromParentAndCleanup(true) 
				playBoomEff()
				end))
			ball:runAction(CCSequence:create(actionList))
			self.effectLayer:addChild(ball)


			local controlPoint2 = nil
			controlPoint2 = ccp(toCCP.x - (toCCP.x - fromCCP.x) / 5, toCCP.y + 200)

			local bezierConfig2 = ccBezierConfig:new()
			bezierConfig2.controlPoint_1 = fromCCP
			bezierConfig2.controlPoint_2 = controlPoint2
			bezierConfig2.endPosition = toCCP
			local bezierAction2 = CCBezierTo:create(0.5, bezierConfig2)

			local ball2 = Sprite:createWithSpriteFrameName("olympic_gold_fly_effect")
			ball2:setScale(0.78)
			ball2:setPositionXY( fromCCP.x , fromCCP.y )
			local actionList2 = CCArray:create()
			actionList2:addObject(CCDelayTime:create(0.05))
			actionList2:addObject(bezierAction2)
			actionList2:addObject(CCCallFunc:create(function() 
				ball2:removeFromParentAndCleanup(true) 
				end))
			ball2:runAction(CCSequence:create(actionList2))
			self.effectLayer:addChild(ball2)




			local controlPoint3 = nil
			controlPoint3 = ccp(toCCP.x - (toCCP.x - fromCCP.x) / 5, toCCP.y + 200)

			local bezierConfig3 = ccBezierConfig:new()
			bezierConfig3.controlPoint_1 = fromCCP
			bezierConfig3.controlPoint_2 = controlPoint3
			bezierConfig3.endPosition = toCCP
			local bezierAction3 = CCBezierTo:create(0.5, bezierConfig3)

			local ball3 = Sprite:createWithSpriteFrameName("olympic_gold_fly_effect")
			ball3:setScale(0.59)
			ball3:setPositionXY( fromCCP.x , fromCCP.y )
			local actionList3 = CCArray:create()
			actionList3:addObject(CCDelayTime:create(0.1))
			actionList3:addObject(bezierAction3)
			actionList3:addObject(CCCallFunc:create(function() 
				ball3:removeFromParentAndCleanup(true) 
				end))
			ball3:runAction(CCSequence:create(actionList3))
			self.effectLayer:addChild(ball3)

		else
			holeSprite.body:play( "collect" , 1)
			local actionArr2 = CCArray:create()
			actionArr2:addObject(CCDelayTime:create(0.5))
			actionArr2:addObject(CCCallFunc:create(flyFinishedCallback))
			holeSprite.body:runAction(CCSequence:create(actionArr2))
		end

		--local effect = FallingStar:create(fromPos, targetPos, nil, flyFinishedCallback, true, false, true)
		--self.effectLayer:addChild(glodIcon)
	end
end
