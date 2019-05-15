
require("zoo.modules.autumn2018.ZQAnimation")
require("zoo.modules.autumn2018.ZQNpcHunter")
require("zoo.modules.autumn2018.ZQNpcPrey")

ZQPlaySceneTopNode = class()

local kAnimalScale = 0.95
if __isWildScreen then
	kAnimalScale = 0.70
end

function ZQPlaySceneTopNode:create(gamePlayScene, topNodePosY)
	local node = ZQPlaySceneTopNode.new()
	node:init(gamePlayScene, topNodePosY)
	return node
end

function ZQPlaySceneTopNode:init(gamePlayScene, topNodePosY)
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
	self.decorateNode = decorateNode

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
	self.targetLayer= Layer:create()
	frontTopNode:addChild(self.targetLayer)

	self.scoreBoard = gamePlayScene.topArea.zqScoreBoard

	self:initTarget()
end

local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
function ZQPlaySceneTopNode:initTarget()
	local targetsConfig = ZQManager.getInstance():getTargetsConfig()
	if targetsConfig then 
		self.targetLayer:runAction(CCCallFunc:create(function ()
			local ZQTargetLanterns = require "zoo.modules.autumn2018.ZQTargetLanterns"
			local pos = self.targetLayer:convertToNodeSpace(ccp(visibleOrigin.x + visibleSize.width, visibleOrigin.y + visibleSize.height))
			self.targetLanterns = ZQTargetLanterns:create(targetsConfig)
			self.targetLayer:addChild(self.targetLanterns)
			self.targetLanterns:setPosition(ccp(pos.x, pos.y))
			self.targetLanterns:setScale(kAnimalScale)

			ZQManager.getInstance():setTargetLanterns(self.targetLanterns)
		end))
	end
end

function ZQPlaySceneTopNode:getAnimalScale()
	return kAnimalScale
end

function ZQPlaySceneTopNode:getFollowAnimalPos()
	return self:convertToWorldSpace(self:getFollowAnimalPos())
end

function ZQPlaySceneTopNode:getBananaPos()
	return self:convertToWorldSpace(self:getLocalBananaPos())
end

function ZQPlaySceneTopNode:getLocalFollowAnimalPos()
	local followPos = ccp(self.followAnimalBaseX, 60)
	local frontPos = self.frontAnimal:getPosition()

	--printx( 1 , "   ZQPlaySceneTopNode:getLocalFollowAnimalPos ++++++++++++++++++  " , followPos.x , frontPos.x)

	if frontPos.x - followPos.x < 65 then
		return ccp(self.followAnimalBaseX - 30 , 60)
	else
		return ccp(self.followAnimalBaseX, 60)
	end 
end

function ZQPlaySceneTopNode:getLocalFrontAnimalPos()
	return ccp(self.frontAnimalBaseX, 70)
end

function ZQPlaySceneTopNode:getLocalBananaPos()
	return ccp(self.followAnimalBaseX + 60 * kAnimalScale, 55)
end

function ZQPlaySceneTopNode:convertToNodeSpace(pos)
	return self.frontTopNode:convertToNodeSpace(pos)
end

function ZQPlaySceneTopNode:convertToWorldSpace(pos)
	return self.frontTopNode:convertToWorldSpace(pos)
end

function ZQPlaySceneTopNode:createUserHeader(animalId)
	animalId = tonumber(animalId) or 1
	if animalId < 1 or animalId > 6 then return nil end
	local builder = InterfaceBuilder:create( "flash/autumn2018/olympic/olympic_ingame.json" )
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

-- local kHeaderPositionById = {
-- 	[1] = {x=-10, y=120},
-- 	[2] = {x=-10, y=110},
-- 	[3] = {x=-5, y=120},
-- 	[4] = {x=0, y=115},
-- 	[5] = {x=-10, y=110},
-- 	[6] = {x=0, y=75},
-- }
function ZQPlaySceneTopNode:initAnimals(frontAnimalId, frontAnimalBaseX, followAnimalBaseX)
	if frontAnimalBaseX then self.frontAnimalBaseX = self:convertToNodeSpace(ccp(frontAnimalBaseX, 0)).x end
	if followAnimalBaseX then self.followAnimalBaseX = self:convertToNodeSpace(ccp(followAnimalBaseX, 0)).x end
	self.frontAnimalId = frontAnimalId or 1

	-- --头像
	-- local header = self:createUserHeader(self.frontAnimalId)
	-- if header then
	-- 	local headerPos = kHeaderPositionById[self.frontAnimalId]
	-- 	if headerPos then
	-- 		header:setPosition(ccp(headerPos.x, headerPos.y))
	-- 	end
	-- 	self.frontAnimal:addChild(header)
	-- end
	
	local animal = ZQNpcPrey:create()
	animal:setPosition(self:getLocalFrontAnimalPos())
	animal:setScale(kAnimalScale)
	self.animalsLayer:addChild(animal)
	animal:changeStatus(ZQNpcPreyStatus.kStandBy)
	self.frontAnimal = animal

	local animal2 = ZQNpcHunter:create()
	animal2:setPosition(self:getLocalFollowAnimalPos())
	animal2:setScale(kAnimalScale)
	self.animalsLayer:addChild(animal2)
	animal2:changeStatus(ZQNpcHunterStatus.kAppear, function ()
		if self.isDisposed or animal2.isDisposed then return end
		animal2:changeStatus(ZQNpcHunterStatus.kStandBy)
	end)
	self.followAnimal = animal2
end

function ZQPlaySceneTopNode:playFollowAnimalJump(onFinished)
	if not self.isFollowAnimalFall then return false end

	self.followAnimal:changeStatus(ZQNpcHunterStatus.kAppear, function ()
		if self.isDisposed or self.followAnimal.isDisposed then return end
		self.isFollowAnimalFall = false
		self.followAnimal:changeStatus(ZQNpcHunterStatus.kStandBy)
		if onFinished then onFinished() end
	end)
end

function ZQPlaySceneTopNode:playFollowAnimalFall(onFinished)
	if self.isFollowAnimalFall then return false end
	self.isFollowAnimalFall = true

	self.frontAnimal:changeStatus(ZQNpcPreyStatus.kRevive)

	setTimeOut(function ()
		if self.isDisposed then return end
		self.followAnimal:changeStatus(ZQNpcHunterStatus.kPause)
		self:setSwoonRoundLabelVisible(true)
		if onFinished then onFinished() end
	end, 1.2)
end


function ZQPlaySceneTopNode:setSwoonRoundLabelVisible(isVisible)
	if not self.swoonRoundLabel or self.swoonRoundLabel.isDisposed then return end
	self.swoonRoundLabel:setVisible(isVisible == true)
end

function ZQPlaySceneTopNode:updateFollowAnimalSwoonRound(swoonRound)
	if not self.swoonRoundLabel then
		self.swoonRoundLabel = BitmapText:create("0", "fnt/18midautumn_car.fnt", 200)
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

function ZQPlaySceneTopNode:playFrontAnimalRunTo(globalPosX, time)
	time = time or 0.5
	self.frontAnimal:changeStatus(ZQNpcPreyStatus.kRun)
	local actionArr = CCArray:create()
	local posY = self.frontAnimal:getPositionY()
	local targetPosX = self:convertToNodeSpace(ccp(globalPosX, 0)).x
	local followPos = ccp(self.followAnimalBaseX, 60)
	local frontPos = ccp(targetPosX, posY)

	actionArr:addObject(CCMoveTo:create( time, frontPos ))
	local function onRunFinish()
		if self.frontAnimal.isAfraid then 
			self.frontAnimal:changeStatus(ZQNpcPreyStatus.kAfraid1)
		else
			self.frontAnimal:changeStatus(ZQNpcPreyStatus.kStandBy)
		end
	end
	actionArr:addObject(CCCallFunc:create(onRunFinish))

	self.frontAnimal:stopAllActions()
	self.frontAnimal:runAction(CCSequence:create(actionArr))
	--printx( 1 , "   ZQPlaySceneTopNode:playFrontAnimalRunTo  " , frontPos.x , followPos.x , frontPos.x - followPos.x)
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

function ZQPlaySceneTopNode:playFrontAnimalMoveTo(globalPosX, time)
	time = time or 0.5
	local posY = self.frontAnimal:getPositionY()
	local targetPosX = self:convertToNodeSpace(ccp(globalPosX, 0)).x

	local followPos = ccp(self.followAnimalBaseX, 60)
	local frontPos = ccp(targetPosX, posY)

	self.frontAnimal:stopAllActions()

	local actionArr = CCArray:create()
	actionArr:addObject(CCMoveTo:create(time, frontPos ))
	actionArr:addObject(CCCallFunc:create(function () 
		end))
	self.frontAnimal:runAction(CCSequence:create(actionArr))

	--printx( 1 , "   ZQPlaySceneTopNode:playFrontAnimalMoveTo  frontPos.x - followPos.x = " , frontPos.x - followPos.x)
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

function ZQPlaySceneTopNode:playFollowAnimalRun()
	if not self.isFollowAnimalFall then
		self.followAnimal:changeStatus(ZQNpcHunterStatus.kStandBy)
	end
end

function ZQPlaySceneTopNode:playAnimalWaitAnimate()
	if not self.isFollowAnimalFall then
		self.followAnimal:changeStatus(ZQNpcHunterStatus.kStandBy)
	end
	self.frontAnimal:changeStatus(ZQNpcPreyStatus.kStandBy)
end

function ZQPlaySceneTopNode:playFrontAnimalHappyToAfraid()
	if not self.isFrontAnimalAfraid then 
		self.isFrontAnimalAfraid = true
		self.frontAnimal:changeStatus(ZQNpcPreyStatus.kAfraid1)
	end
end

function ZQPlaySceneTopNode:playFrontAnimalAfraidToHappy()
	if self.isFrontAnimalAfraid then
		self.isFrontAnimalAfraid = false 
		self.frontAnimal:changeStatus(ZQNpcPreyStatus.kAfraidToHappy)
	end
end

function ZQPlaySceneTopNode:addRoadHoles(globalPosX, colId, onFinished)
	if not globalPosX then return end
	if self.roadHoles[colId] then
		return
	end
	if colId == 2 then
		globalPosX = globalPosX + 20
	end
	
	local holeSprite = ZQAnimation:createLotus()
	holeSprite:setScale(0.8)

	local function onRepeatFinishCallback()
		if onFinished then onFinished() end
	end
	
	local localPosX = self:convertToNodeSpace(ccp(globalPosX, 0)).x
	holeSprite:setPosition(ccp(localPosX, 50 + math.random(0, 25)))

	self.roadHolesLayer:addChild(holeSprite)
	self.roadHoles[colId] = holeSprite
end


function ZQPlaySceneTopNode:moveHoles(time, getPosFunc)
	--printx( 1 , "   ZQPlaySceneTopNode:moveHoles " , time, getPosFunc)
	local removeHoleColIds = {}
	for colId, hole in pairs(self.roadHoles) do
		local pos, needRemove = getPosFunc(colId)
		local targetPosX = self:convertToNodeSpace(pos).x
		hole:stopAllActions()

		local actionArr = CCArray:create()
		--printx( 1 , "   ZQPlaySceneTopNode:moveHoles  !!!!!!!!!!!!!!!!!!!!!!!! needRemove = " , needRemove , colId , targetPosX)
		if needRemove then
			actionArr:addObject(CCMoveTo:create(time, ccp(targetPosX, hole:getPositionY())))
			actionArr:addObject(CCDelayTime:create(0.1))
			actionArr:addObject(CCCallFunc:create(function() 
					hole.body:play("disappear", 1) 
					self.followAnimal:changeStatus(ZQNpcHunterStatus.kDisappear, function ()
						self.frontAnimal:changeStatus(ZQNpcPreyStatus.kDie)
					end)
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
end

function ZQPlaySceneTopNode:playFlyToBoardEffect(fromGlobalPos)
	if not self.targetEffectNode then
		self.targetEffectNode = CocosObject:create(CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/autumn2018/mid_autumn_ani_res.png"),200))  
		self.targetLayer:addChild(self.targetEffectNode)
	end
	local fromPos = self.targetEffectNode:convertToNodeSpace(fromGlobalPos)
	local endPos = ZQManager.getInstance():getFlyEndPos(self.targetEffectNode)
	if endPos then
		endPos = ccp(endPos.x, endPos.y)
		ZQAnimation:playTailFlyEffect(self.targetEffectNode, fromPos, endPos) 
	end
end

--playFlyToNpcEffect
function ZQPlaySceneTopNode:playFlyToHoleEffect(colId, fromGlobalPos, needRemove, onFinished)
	--printx( 1 , "   ZQPlaySceneTopNode:playFlyToHoleEffect " , colId, fromGlobalPos.x , fromGlobalPos.y , needRemove, onFinished)

	self:playFlyToBoardEffect(fromGlobalPos)

	if self.roadHoles[colId] then
		local holeSprite = self.roadHoles[colId]

		if holeSprite.isDisposed then
			if onFinished then onFinished() end
			return 
		end

		local fromPos = holeSprite:getPosition()
		local targetPos = self.frontAnimal:getPosition()

		local function flyFinishedCallback()
			if onFinished then onFinished() end
		end
		
		if needRemove then
			holeSprite.body:play("disappear", 1)
			holeSprite.body:removeAllEventListeners()
			holeSprite.body:addEventListener(ArmatureEvents.COMPLETE, function ()
				holeSprite.body:stop()
				holeSprite:removeFromParentAndCleanup(true)
			end)
			self.roadHoles[colId] = nil


			local fromCCP = ccp( fromPos.x , fromPos.y + 20 )
			local toCCP = ccp( targetPos.x + 20 , targetPos.y + 50 )

			local function playBoomEff()
				-- local lightSprite = OlympicAnimalAnimation:createGlodBoomAnimal()
				-- lightSprite:setPosition(ccp(toCCP.x, toCCP.y + 40))
				-- self.roadHolesLayer:addChild(lightSprite)
				-- local actionArr3 = CCArray:create()
				-- actionArr3:addObject(CCDelayTime:create(0.5))
				-- actionArr3:addObject(CCCallFunc:create(function() lightSprite:removeFromParentAndCleanup(true) end))
				-- lightSprite.body:runAction(CCSequence:create(actionArr3))
			end

			local ball = Sprite:createWithSpriteFrameName("ZQ_fly_dot")
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
				-- playBoomEff()
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

			local ball2 = Sprite:createWithSpriteFrameName("ZQ_fly_dot")
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

			local ball3 = Sprite:createWithSpriteFrameName("ZQ_fly_dot")
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
			--bling bling
		end
	end
end