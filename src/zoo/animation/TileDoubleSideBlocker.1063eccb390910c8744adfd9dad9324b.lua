TileDoubleSideBlocker = class(CocosObject)

local kCharacterAnimationTime = 1/12
local kCharacterAnimationTime2 = 1/24

TileDoubleSideBlockerAnimeType = {
	
	kDefault = "default" ,
	kChangeTop = "change_top" ,
	kChangeBack = "change_back" ,
}


local function deleteAnimation(nodeSprite) 
	if nodeSprite and not nodeSprite.isDisposed then
		nodeSprite:stopAllActions()
		nodeSprite:removeFromParentAndCleanup(true)
	end
end

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

function TileDoubleSideBlocker:create( countNumber, isReverseSide )
	-- body
	local node = TileDoubleSideBlocker.new(CCNode:create()) 
	node:initState(countNumber, isReverseSide)
	node.name = "TileDoubleSideBlocker"
	return node
end

function TileDoubleSideBlocker:updateState( countDown)
	--printx( 1 , "   TileDoubleSideBlocker:updateState  ----------->  " ,countDown)

	--self.hightLight1:setOpacity(0)
	--self.hightLight2:setOpacity(0)
	--self.hightLight1:stopAllActions()
	--self.hightLight2:stopAllActions()

	self.hightLight1:setVisible(false)
	self.hightLight2:setVisible(false)

	if countDown == 1 then

		if self.hightLight then

			self.hightLight:setVisible(true)
		end
	end
end

function TileDoubleSideBlocker:createFrameAnimations( animeType , isReverseSide , animateCallback )
	local pindex  = 1
	if isReverseSide then
		pindex = 2
	end

	local resHead = "TileDoubleSideBlocker_" .. animeType ..  "_" .. tostring(pindex) .. "_"
	local animeSprite = createSprite( resHead .. "0001")

	local totalFrames = 10
	local framePreSec = kCharacterAnimationTime2
	local repeatTimes = 0

	if animeType == TileDoubleSideBlockerAnimeType.kDefault then
		totalFrames = 19
		framePreSec = kCharacterAnimationTime1
		repeatTimes = 0
	elseif animeType == TileDoubleSideBlockerAnimeType.kChangeTop then
		totalFrames = 41
		framePreSec = kCharacterAnimationTime2
		repeatTimes = 1
	elseif animeType == TileDoubleSideBlockerAnimeType.kChangeBack then
		totalFrames = 14
		framePreSec = kCharacterAnimationTime2
		repeatTimes = 1
	end

	local frames = SpriteUtil:buildFrames( resHead .. "%04d" , 1 , totalFrames , false )
	local animate = SpriteUtil:buildAnimate( frames , framePreSec )
	animeSprite:play(animate , 0 , repeatTimes , animateCallback)

	if animeType == TileDoubleSideBlockerAnimeType.kDefault then
		if pindex == 1 then
			animeSprite:setPositionX( animeSprite:getPositionX() + 2 )
			animeSprite:setPositionY( animeSprite:getPositionY() - 3 )
		elseif pindex == 2 then
			animeSprite:setPositionX( animeSprite:getPositionX() + 3 )
			animeSprite:setPositionY( animeSprite:getPositionY() - 5 )
		end

		local array = CCArray:create()
		array:addObject(CCFadeTo:create( 1.25 , 63 ))
		array:addObject(CCDelayTime:create(2.5))
		array:addObject(CCFadeTo:create( 1.25 , 170 ))
		animeSprite:runAction(CCRepeatForever:create(CCSequence:create(array)))
		
	elseif animeType == TileDoubleSideBlockerAnimeType.kChangeTop then
		
	elseif animeType == TileDoubleSideBlockerAnimeType.kChangeBack then
		if pindex == 1 then
			animeSprite:setPositionX( animeSprite:getPositionX() + 1 )
			animeSprite:setPositionY( animeSprite:getPositionY() - 2 )
		elseif pindex == 2 then
			animeSprite:setPositionX( animeSprite:getPositionX() + 1 )
			animeSprite:setPositionY( animeSprite:getPositionY() - 2 )
		end
	end

	return animeSprite
end

function TileDoubleSideBlocker:initState( countNumber, isReverseSide )
	--printx( 1 , "   =================   TileDoubleSideBlocker:initState " , isReverseSide)
	self.nodeSprite = self:createFrameAnimations( TileDoubleSideBlockerAnimeType.kDefault , isReverseSide , nil )
	self:addChild(self.nodeSprite)


	self.lightList = {}

	local hightLight1 = createLightSprite("TileDoubleSideBlocker_HighLight_1")
	local hightLight2 = createLightSprite("TileDoubleSideBlocker_HighLight_2")

	self:addChild(hightLight1)
	self:addChild(hightLight2)

	self.hightLight1 = hightLight1
	self.hightLight2 = hightLight2

	self.hightLight1:setOpacity(0)
	self.hightLight2:setOpacity(0)

	self.hightLight1:setVisible(false)
	self.hightLight2:setVisible(false)

	if isReverseSide then
		self.hightLight = self.hightLight2
	else
		self.hightLight = self.hightLight1
	end	
	

	self:updateState(countNumber)
	
end

-----------------------------------------
--isReverseSide: the state of before turn
-----------------------------------------
function TileDoubleSideBlocker:playTurnAnimation( isReverseSide, callback )
	-- body
	--printx( 1 , "   =================   TileDoubleSideBlocker:playTurnAnimation " , isReverseSide)
	if isReverseSide then
		self:playBlockToNodeAnimation(callback)
	else
		self:playNodeToBlockAnimation(callback)
	end
end


function TileDoubleSideBlocker:playNodeToBlockAnimation( callback )
	-- body
	--printx( 1 , "   =================   TileDoubleSideBlocker:playNodeToBlockAnimation ")
	local function animateCallback( ... )
		-- body
		deleteAnimation(self.change_back)
		self.change_back = nil

		if callback then callback() end

	end

	local change_back = self:createFrameAnimations( TileDoubleSideBlockerAnimeType.kChangeBack , false , animateCallback )
	self:addChild(change_back)
	self.change_back = change_back

	local function changeNodeSprite()
		deleteAnimation(self.nodeSprite)

		self.nodeSprite = self:createFrameAnimations( TileDoubleSideBlockerAnimeType.kDefault , true , nil )
		self:addChildAt(self.nodeSprite , 0)
	end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(changeNodeSprite)))

	self.hightLight = self.hightLight2
end

function TileDoubleSideBlocker:playBlockToNodeAnimation( callback )

	--printx( 1 , "   =================   TileDoubleSideBlocker:playBlockToNodeAnimation ")
	local function animateCallback( ... )
		-- body
		deleteAnimation(self.change_back)
		self.change_back = nil

		if callback then callback() end

	end

	--printx( 1 , "  self.change_back = " , self.change_back)
	local change_back = self:createFrameAnimations( TileDoubleSideBlockerAnimeType.kChangeBack , true , animateCallback )
	self:addChild(change_back)
	self.change_back = change_back

	local function changeNodeSprite()
		--printx( 1 , "  WTFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF  self.nodeSprite " , self.nodeSprite)
		deleteAnimation(self.nodeSprite)

		self.nodeSprite = self:createFrameAnimations( TileDoubleSideBlockerAnimeType.kDefault , false , nil )
		self:addChildAt(self.nodeSprite , 0)
	end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(changeNodeSprite)))

	self.hightLight = self.hightLight1

end

function TileDoubleSideBlocker:createStarSprite( callback )
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

