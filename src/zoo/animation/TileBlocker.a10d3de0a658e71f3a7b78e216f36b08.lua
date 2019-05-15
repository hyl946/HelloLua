TileBlocker = class(CocosObject)

local kCharacterAnimationTime = 1/30
local function createSprite(frameName)
	local sprite = Sprite:createWithSpriteFrameName(frameName)
	return sprite
end

local function createLightSprite( frameName )
	-- body
	local time = 0.3
	local sprite = Sprite:createWithSpriteFrameName(frameName)
	local actionList = CCArray:create()
	actionList:addObject(CCFadeIn:create(time))
	actionList:addObject(CCFadeOut:create(time))
	actionList:addObject(CCFadeIn:create(time))
	actionList:addObject(CCFadeOut:create(time))
	actionList:addObject(CCDelayTime:create(time * 4))
	local action_repeate = CCRepeatForever:create(CCSequence:create(actionList))
	sprite:runAction(action_repeate)
	return sprite
end

local function playHightLightAnimation( sprite )
	-- body
	if not sprite then return end
	sprite:setVisible(true)
	local actionList = CCArray:create()
	actionList:addObject(CCFadeIn:create(0.1))
	actionList:addObject(CCFadeOut:create(0.8))
	sprite:runAction(CCSequence:create(actionList))
end

local function playLightCircleAnimation( sprite )
	-- body
	if not sprite then return end
	sprite:setScale(0.5)
	sprite:setVisible(true)
	local totaltime = 1

	local action_rotation = CCRotateBy:create(totaltime, 90)
	local actionList = CCArray:create()
	actionList:addObject(CCFadeIn:create(0.01))
	actionList:addObject(CCScaleTo:create(totaltime / 4, 1.8))
	actionList:addObject(CCScaleTo:create(totaltime / 2, 1.6))
	actionList:addObject( CCFadeOut:create(totaltime / 4))

	sprite:runAction(CCSpawn:createWithTwoActions(CCSequence:create(actionList), action_rotation))
end

function TileBlocker:create( countNumber, isReverseSide )
	-- body
	local node = TileBlocker.new(CCNode:create()) 
	node:initState(countNumber, isReverseSide)
	node.name = "TileBlocker"
	return node
end

function TileBlocker:updateState( countDown)
	-- body
	for k = 1, 3 do 
		if k == countDown then 
			self.lightList[k]:setVisible(true)
		else
			self.lightList[k]:setVisible(false)
		end
	end

end

function TileBlocker:initState( countNumber, isReverseSide )
	-- body
	self.lightCircle = Sprite:createWithSpriteFrameName("TileBlocker_lightCircle")
	self.lightCircle:setVisible(false)
	self:addChild(self.lightCircle)

	self.nodeSprite = isReverseSide and createSprite("TileBlocker_ChangeAnimation_0011")
									or createSprite("TileBlocker_ChangeAnimation_0000")
	self:addChild(self.nodeSprite)


	self.lightList = {}
	for k = 1, 3 do
		local light = createLightSprite("TileBlocker_Light_"..k)
		self.lightList[k] = light
		light:setScale(1.1)
		self:addChild(light)
		light:setPositionX(2) -- 光都有点歪
	end

	self.hightLight = Sprite:createWithSpriteFrameName("TileBlocker_light_high")
	self.hightLight:setVisible(false)
	self:addChild(self.hightLight)

	
	self:updateState(countNumber)
	
end

-----------------------------------------
--isReverseSide: the state of before turn
-----------------------------------------
function TileBlocker:playTurnAnimation( isReverseSide, callback )
	-- body
	if isReverseSide then
		self:playBlockToNodeAnimation(callback)
	else
		self:playNodeToBlockAnimation(callback)
	end
end


function TileBlocker:playNodeToBlockAnimation( callback )
	-- body
	local sprite = self.nodeSprite
	local function animateCallback( ... )
		-- body
		if callback then callback() end
		playHightLightAnimation(self.hightLight)

	end
	local frames = SpriteUtil:buildFrames("TileBlocker_ChangeAnimation_" .. "%04d", 0, 12, false)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sprite:play(animate, 0, 1, animateCallback)

	local function playLightCircleAction( ... )
		-- body
		playLightCircleAnimation(self.lightCircle)
	end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.25), CCCallFunc:create(playLightCircleAction)))
end

function TileBlocker:playBlockToNodeAnimation( callback )
	-- body
	local sprite = self.nodeSprite
	local function animateCallback( ... )
		-- body
		if callback then callback() end
		playHightLightAnimation(self.hightLight)
		-- self:addChild(self:createStarSprite())
	end

	local frames = SpriteUtil:buildFrames("TileBlocker_ChangeAnimation_" .. "%04d", 0, 12, true)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	sprite:play(animate, 0, 1, animateCallback)


	local function playLightCircleAction( ... )
		-- body
		playLightCircleAnimation(self.lightCircle)
	end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.25), CCCallFunc:create(playLightCircleAction)))
end

function TileBlocker:createStarSprite( callback )
	-- body
	local timeStand = 1
	local container = Sprite:createEmpty()
	local posList = {
						ccp(-25, 25), 
						ccp(GamePlayConfig_Tile_Width / 4, GamePlayConfig_Tile_Width / 4), 
						ccp(0, -GamePlayConfig_Tile_Width/4)	
					}
	local maxScaleList = {
							0.8,
							1.3,
							1.6
						}
	for k = 1, 3 do 
		local star =  Sprite:createWithSpriteFrameName("tile_blocker_star")
		star:setScale(0.5)
		star:setPosition(posList[k])
		container:addChild(star)

		local action_rotation = CCRotateBy:create(timeStand, 180)

		local actionList = CCArray:create()
		actionList:addObject(CCDelayTime:create((k -1) * 0.1))
		actionList:addObject(CCScaleTo:create(timeStand /2, maxScaleList[k]))
		actionList:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(timeStand/2, 0.2), CCFadeOut:create(timeStand/2)) )

		star:runAction(CCSpawn:createWithTwoActions(action_rotation, CCSequence:create(actionList)))
	end

	local function animationCallback( ... )
		-- body
		if container then container:removeFromParentAndCleanup(true) end
		if callback then callback() end
	end

	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(animationCallback)))
	return container
end

