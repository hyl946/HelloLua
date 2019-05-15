-------------------------------------------------------------------------
--  Class include: CommonEffect, FallingStar, Firebolt
-------------------------------------------------------------------------

require "hecore.display.Director"
require "hecore.display.ArmatureNode"

local kCharacterAnimationTime = 1/26
local kRad3Ang = -180/3.1415926
local numberLineParticles = 0
--
-- CommonEffect ---------------------------------------------------------
--
CommonEffect = class()
function CommonEffect:reset()
	numberLineParticles = 0
end

function CommonEffect:buildRainbowLineEffect(batchNode)
	local node = Sprite:createEmpty()
	if batchNode then 
		node:setTexture(batchNode.refCocosObj:getTexture())
	end
	local line1 = Sprite:createWithSpriteFrameName('two_year_line_effect_0000')
	line1:setAnchorPoint(ccp(0.2, 0.5))
	line1:setRotation(-180)
	local line2 = Sprite:createWithSpriteFrameName('two_year_line_effect_0000')
	line2:setAnchorPoint(ccp(0.2, 0.5))
	line2:setRotation(-90)
	local line3 = Sprite:createWithSpriteFrameName('two_year_line_effect_0000')
	line3:setAnchorPoint(ccp(0.2, 0.5))
	line3:setRotation(0)
	node:addChild(line1)
	node:addChild(line2)
	node:addChild(line3)
	local center = Sprite:createWithSpriteFrameName('two_year_center_effect_0000')
	center:setAnchorPoint(ccp(0.5, 0.5))

	local function remove()
		if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxxxxxxxxxxxx remove') end
		-- debug.debug()
		if node then 
			node:removeFromParentAndCleanup(true)
			node = nil
		end
	end

	line1:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("two_year_line_effect_%04d", 0, 20), kCharacterAnimationTime), 0, 1, nil)
	line2:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("two_year_line_effect_%04d", 0, 20), kCharacterAnimationTime), 0, 1, nil)
	line3:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("two_year_line_effect_%04d", 0, 20), kCharacterAnimationTime), 0, 1, nil)
	center:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("two_year_center_effect_%04d", 0, 20), kCharacterAnimationTime), 0, 1, remove)
	return node
end

function CommonEffect:buildWrapLineEffect(batchNode)
	local timePerFrame = 1/40
	local node = Sprite:createEmpty()
	if batchNode then 
		node:setTexture(batchNode.refCocosObj:getTexture())
	else
		local sprite = Sprite:createWithSpriteFrameName("line_wrap_effect_0000")
		node:setTexture(sprite:getTexture())
	end

	local function buildLightLine(direction)
		local sprite = Sprite:createWithSpriteFrameName("line_wrap_effect_0000")
		sprite:setScaleX(0.1*direction)
		sprite:setScaleY(1*direction)
		sprite:setOpacity(255)

		local function onActionFinished()
			sprite:removeFromParentAndCleanup(true)
		end

		local lineActionSeq = CCArray:create()
		lineActionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(4*timePerFrame, 0.5*direction, 1*direction), CCMoveBy:create(4*timePerFrame, ccp(80*direction, 0))))
		lineActionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(9*timePerFrame, 1.8*direction, 1*direction), CCMoveBy:create(9*timePerFrame, ccp(350*direction, 0))))
		lineActionSeq:addObject(CCMoveBy:create(3*timePerFrame, ccp(100*direction, 0)))
		lineActionSeq:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(3*timePerFrame), CCMoveBy:create(3*timePerFrame, ccp(100*direction, 0))))
		lineActionSeq:addObject(CCCallFunc:create(onActionFinished))

		sprite:runAction(CCSequence:create(lineActionSeq))
		return sprite
	end

	local function onLightAnimationBegin()
		local right = buildLightLine(1)
		right:setPositionXY(0, 0)
		node:addChildAt(right,0)
		local left = buildLightLine(-1)
		left:setPositionXY(0, 0)
		node:addChildAt(left,0)
	end

	local function onAnimationFinished() 
		node:removeFromParentAndCleanup(true)
	end

 	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.1))
	array:addObject(CCCallFunc:create(onLightAnimationBegin))
	array:addObject(CCDelayTime:create(1.2))
	array:addObject(CCCallFunc:create(onAnimationFinished))
	node:runAction(CCSequence:create(array))

 	return node
end

function CommonEffect:buildWrapEffect(batchNode, delayTime)
	local timePerFrame = 1/36
	local node = Sprite:createEmpty()
	if batchNode then 
		node:setTexture(batchNode.refCocosObj:getTexture())
	end

	local sprite, animate = SpriteUtil:buildAnimatedSprite(timePerFrame, "wrap_effect_%04d", 0, 17)
	sprite:setOpacity(0)

	local function onAnimationFinished( ... )
		node:removeFromParentAndCleanup(true)
	end

	local actionSeq = CCArray:create()
	if delayTime and delayTime > 0 then
		actionSeq:addObject(CCDelayTime:create(delayTime))
	end
	actionSeq:addObject(CCFadeIn:create(0))
	actionSeq:addObject(animate)
	sprite:play(CCSequence:create(actionSeq), 2*timePerFrame, 1, onAnimationFinished)

	node:addChild(sprite)
	return node
end

function CommonEffect:buildLineEffect(batchNode)
	local timePerFrame = 1/48
	local node = Sprite:createEmpty()
	if batchNode then 
		node:setTexture(batchNode.refCocosObj:getTexture())
	end

	local function buildLightLine(direction)
		local sprite = Sprite:createWithSpriteFrameName("line_effect_0000")
		sprite:setScaleX(0.1*direction)
		sprite:setScaleY(1*direction)
		sprite:setOpacity(255)
		-- sprite:setAnchorPoint(ccp(0.3,0.5))

		local function onActionFinished()
			sprite:removeFromParentAndCleanup(true)
		end

		local lineActionSeq = CCArray:create()
		lineActionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(4*timePerFrame, 0.5*direction, 1*direction), CCMoveBy:create(4*timePerFrame, ccp(80*direction, 0))))
		lineActionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(9*timePerFrame, 1.8*direction, 1*direction), CCMoveBy:create(9*timePerFrame, ccp(350*direction, 0))))
		lineActionSeq:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(4*timePerFrame), CCMoveBy:create(2*timePerFrame, ccp(160*direction, 0))))
		lineActionSeq:addObject(CCCallFunc:create(onActionFinished))

		sprite:runAction(CCSequence:create(lineActionSeq))
		return sprite
	end

	local function createStars( ... )
		-- body
		local maxStar = 10
		for k = 1, maxStar do 
			local sprite = Sprite:createWithSpriteFrameName("explode_effect_star_0000")
			sprite:setScale(math.random(5, 11) / 10)
			sprite:setOpacity(0)
			local x =( k - 5) * 50
			local index = k %2 == 0 and 1 or -1
			local y = math.random() *20 * index
			sprite:setPosition(ccp(x,y))
			local actionList = CCArray:create()
			actionList:addObject(CCFadeIn:create(0.1))
			actionList:addObject(CCDelayTime:create(0.5))
			actionList:addObject(CCFadeOut:create(0.2))
			sprite:runAction(CCSpawn:createWithTwoActions(CCSequence:create(actionList), CCRotateBy:create(2, 720)))
			node:addChild(sprite)
		end
	end

	local function onLightAnimationBegin()
		local right = buildLightLine(1)
		right:setPositionXY(0, 0)
		node:addChildAt(right,0)
		local left = buildLightLine(-1)
		left:setPositionXY(0, 0)
		node:addChildAt(left,0)
	end

	local function onAnimationFinished() 
		node:removeFromParentAndCleanup(true)
		numberLineParticles = numberLineParticles - 1
		if numberLineParticles < 0 then numberLineParticles = 0 end
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.1))
	array:addObject(CCCallFunc:create(onLightAnimationBegin))
	array:addObject(CCDelayTime:create(1.2))
	array:addObject(CCCallFunc:create(onAnimationFinished))
	node:runAction(CCSequence:create(array))

	local displayParticles = true
	if numberLineParticles > 4 then
		displayParticles = false
		if math.random() < 0.35 then displayParticles = true end
	end
	if _G.__use_low_effect then displayParticles = false end
	if displayParticles then
		numberLineParticles = numberLineParticles + 1
		createStars()
	end

	return node
end


function CommonEffect:buildBonusLineEffect()
	local node = CocosObject:create()
	node:setScaleY(2)

	local function buildLightLine(direction)
		local sprite = Sprite:createWithSpriteFrameName("speed_line_yellow0000")
		sprite:setScale(0.1*direction)
		sprite:setOpacity(0)
		sprite:setAnchorPoint(ccp(0.3,0.5))

		local lineAnimationTime = 0.25
		local function onLightAnimationEnd()
			if sprite and not sprite.isDisposed then
				sprite:stopAllActions()
				sprite:runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(0.2, ccp(80*direction, 0)), CCFadeOut:create(0.2)))
			end
		end 

		local array = CCArray:create()
		array:addObject(CCScaleTo:create(0.2, 1*direction))
		array:addObject(CCFadeIn:create(0.1))
		array:addObject(CCMoveBy:create(lineAnimationTime, ccp(100*direction, 0)))
		array:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(lineAnimationTime), CCCallFunc:create(onLightAnimationEnd)))
		sprite:runAction(CCSpawn:create(array))
		return sprite
	end

	local function onLightAnimationBegin()
		local right = buildLightLine(1)
		right:setPositionXY(0, 0)
		node:addChildAt(right,0)
		local left = buildLightLine(-1)
		left:setPositionXY(0, 0)
		node:addChildAt(left,0)
	end

	local function onAnimationFinished() node:removeFromParentAndCleanup(true) end
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(0.2))
	array:addObject(CCCallFunc:create(onLightAnimationBegin))
	array:addObject(CCDelayTime:create(1.2))
	array:addObject(CCCallFunc:create(onAnimationFinished))
	node:runAction(CCSequence:create(array))

	if not _G.__use_low_effect then 
		local starLine = ParticleSystemQuad:create("particle/star_line_yellow.plist")
		starLine:setAutoRemoveOnFinish(true)
		starLine:setPosition(ccp(0,0))
		node:addChild(starLine)

		local rightSpeed = ParticleSystemQuad:create("particle/speed_right.plist")
		rightSpeed:setAutoRemoveOnFinish(true)
		rightSpeed:setPosition(ccp(0,0))
		node:addChild(rightSpeed)

		local leftSpeed = ParticleSystemQuad:create("particle/speed_left.plist")
		leftSpeed:setAutoRemoveOnFinish(true)
		leftSpeed:setPosition(ccp(0,0))
		node:addChild(leftSpeed)
	end

	return node
end

function CommonEffect:buildRequireSwipePanel()
	local container = CocosObject:create()
	local function onAnimationFinished() container:removeFromParentAndCleanup(true) end
	local panel = ResourceManager:sharedInstance():buildGroup("panel_require_swape")
	local targetSize = panel:getGroupBounds().size
	local label = panel:getChildByName("label")
	label:setString(Localization:getInstance():getText("level.help.require.swipe"))
	panel:setPosition(ccp(-targetSize.width/2, targetSize.height/2 + 100))
	container:addChild(panel)

	local panelChildren = {}
	panel:getVisibleChildrenList(panelChildren)
	for i,child in ipairs(panelChildren) do
		local array = CCArray:create()
		array:addObject(CCFadeIn:create(0.3))
		array:addObject(CCDelayTime:create(0.7))
		array:addObject(CCFadeOut:create(0.1))
		child:setOpacity(0)
		child:runAction(CCSequence:create(array))
	end

	local seq = CCArray:create()
	seq:addObject(CCEaseElasticOut:create(CCMoveBy:create(0.3, ccp(0, -100)))) 
	seq:addObject(CCDelayTime:create(0.8))
	seq:addObject(CCCallFunc:create(onAnimationFinished))
	panel:runAction(CCSequence:create(seq))
	return container
end

local kSpecialEffectName = {"good_icon", "great_icon", "excellent_icon", "amazing_icon", "unbelievable_icon"}
local kSpecialEffectArmatureName = {"game_play/good", "game_play/great", "game_play/excellent", "game_play/amazing", "game_play/unbelievable"}
local kSpecialEffectArmaturePos = {
	[1] = {x = -127, y = 50, timeScale = 1.3},
	[2] = {x = -128, y = 50, timeScale = 1.3},
	[3] = {x = -190, y = 50, timeScale = 1.3},
	[4] = {x = -170, y = 40, timeScale = 1.3},
	[5] = {x = -235, y = 60, timeScale = 1.3},
}
function CommonEffect:buildSpecialEffectTitle( effectType )
	effectType = effectType or 1
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	local winOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local container = CocosObject.new(CCNode:create())

	local armatureName = kSpecialEffectArmatureName[effectType] or kSpecialEffectArmatureName[1]
	FrameLoader:loadArmature("skeleton/game_play_text_effects")
	local anim = ArmatureNode:create(armatureName)
	anim:playByIndex(0)
	anim:update(0.001)
	anim:stop()

	local armaturePos = kSpecialEffectArmaturePos[effectType] or kSpecialEffectArmaturePos[1]
	if armaturePos.timeScale then
		anim:setAnimationScale(armaturePos.timeScale)
	end
	
	local function finishCallback( ... )
	     anim:rma()
	     container:removeFromParentAndCleanup(true)
	end
	anim:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
	local function playAnim()
		anim:setVisible(true)
		anim:playByIndex(0)
	end
	anim:setVisible(false)
	anim:runAction(CCCallFunc:create(playAnim))

	anim:setPositionXY(armaturePos.x, armaturePos.y)

	container:addChild(anim:wrapWithBatchNode())

	-- local textureKey = kSpecialEffectName[effectType] or "good_icon"
	-- local sprite = Sprite:createWithSpriteFrameName(textureKey .. " instance 10000") 
	-- container:addChild(sprite)

	local topHeight = GamePlayConfig_Top_Height * winSize.width / GamePlayConfig_Design_Width
	local bottomHeight = GamePlayConfig_Bottom_Height * winSize.width / GamePlayConfig_Design_Width
	local actualY = winOrigin.y + (winSize.height - topHeight - bottomHeight) * 0.6 + bottomHeight
	container:setPosition(ccp(winOrigin.x+winSize.width/2, actualY))

	return container
end

function CommonEffect:buildBonusEffectXXL(onAnimationFinished)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local winOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local container = CocosObject.new(CCNode:create())
	local darkLayer = LayerColor:createWithColor(ccc3(0, 0, 0), winSize.width, winSize.height)
	darkLayer:setOpacity(255 * 0.6)
	-- darkLayer:setPositionXY(winOrigin.x, winOrigin.y)
	container:addChild(darkLayer)

	FrameLoader:loadArmature("skeleton/kaixinxiaoxiaole")
	local anim = ArmatureNode:create("kxxxl/bonus")
	anim:playByIndex(0)
	anim:update(0.001)
	anim:stop()

	anim:setAnimationScale(1.1)

	anim:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( evt )
		if darkLayer and not darkLayer.isDisposed then
			darkLayer:removeFromParentAndCleanup(true)
		end
     	if onAnimationFinished then onAnimationFinished() end
	end)

	local function finishCallback( ... )
	     anim:rma()
	     container:removeFromParentAndCleanup(true)
	end
	anim:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
	anim:playByIndex(0)

	anim:setPositionXY(winOrigin.x+winSize.width/2, winOrigin.y+winSize.height/2)

	container:addChild(anim:wrapWithBatchNode())

	return container
end

function CommonEffect:buildBonusEffect(onAnimationFinished)
	if _G.dev_kxxxl then
		return CommonEffect:buildBonusEffectXXL(onAnimationFinished)
	end

	local winSize = CCDirector:sharedDirector():getWinSize()
	local winOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local container = CocosObject.new(CCNode:create())
	local darkLayer = LayerColor:createWithColor(ccc3(0, 0, 0), winSize.width, winSize.height)
	darkLayer:setOpacity(255 * 0.6)
	-- darkLayer:setPositionXY(winOrigin.x, winOrigin.y)
	container:addChild(darkLayer)

	FrameLoader:loadArmature("skeleton/game_play_text_effects")

	local isJamMode = GameBoardLogic:getCurrentLogic().gameMode:is(JamSperadMode)
	local anim
	if isJamMode then
		darkLayer:setOpacity(0)
		anim = ArmatureNode:create("game_play/jam_bonus")
	else
		anim = ArmatureNode:create("game_play/bonus")
	end
	anim:playByIndex(0)
	anim:update(0.001)
	anim:stop()

	anim:setAnimationScale(1.1)

	anim:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( evt )
		if darkLayer and not darkLayer.isDisposed then
			darkLayer:removeFromParentAndCleanup(true)
		end
     	if onAnimationFinished then onAnimationFinished() end
	end)

	local function finishCallback( ... )
	     anim:rma()
	     container:removeFromParentAndCleanup(true)
	end
	anim:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
	anim:playByIndex(0)

	anim:setPositionXY(winOrigin.x+winSize.width/2, winOrigin.y+winSize.height/2)

	container:addChild(anim:wrapWithBatchNode())

	return container
end

function CommonEffect:buildGetPropLightAnimWithoutBg(showForever)
	local fps = 30
	FrameLoader:loadImageWithPlist("flash/get_prop_bganim.plist")
	local anim = Sprite:createEmpty()
	anim.lightBg1 = Sprite:createWithSpriteFrameName("circleLight.png")
	anim.lightBg1:setAnchorPoint(ccp(0.5, 0.5))
	anim.lightBg1:setScale(0.6)
	anim.lightBg1:setCascadeOpacityEnabled(true)
	anim:addChild(anim.lightBg1)

	anim.lightBg1:runAction(CCSpawn:createWithTwoActions(CCScaleTo:create(7 / fps, 1.08), CCFadeTo:create(7 / fps, 0.6 * 255)))
	anim.lightBg1:runAction((CCRepeatForever:create(CCRotateBy:create(0.1, 9))))

	local function createLight()
		local container = Sprite:createEmpty()
		container:setAnchorPoint(ccp(0.5, 0.5))

		local opacity = 0.78 * 255
		local sprite = Sprite:createWithSpriteFrameName("circleLight2.png")
		sprite:setAnchorPoint(ccp(0.5, 0.5))
		sprite:setScale(0.88)
		sprite:setOpacity(0.92 * opacity)
		sprite:setCascadeOpacityEnabled(true)
		container:addChild(sprite)
		
		local seq = CCArray:create()
		seq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(17 / fps, 1.14), CCFadeTo:create(17 / fps, opacity)))
		seq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(19 / fps, 0.88), CCFadeTo:create(19 / fps, 0.92 * opacity)))
		sprite:runAction(CCRepeatForever:create(CCSequence:create(seq)))
		return container
	end

	local function createStarAnim()
		local container = Sprite:createEmpty()
		container:setAnchorPoint(ccp(0.5, 0.5))

		local starLight = Sprite:createWithSpriteFrameName("star_light.png")
		local star = Sprite:createWithSpriteFrameName("star.png")
		container:setCascadeOpacityEnabled(true)
		container:addChild(starLight)
		container:addChild(star)

		local lightAnim = CCSpawn:createWithTwoActions(CCScaleTo:create(10 / fps, 1), CCFadeTo:create(10 / fps, 0.1 * 255))
		local function resetLight() 
			starLight:setScale(0.5)
			starLight:setOpacity(255)
		end
		resetLight()
		local lightSeq = CCSequence:createWithTwoActions(lightAnim, CCCallFunc:create(resetLight))
		starLight:runAction(CCRepeatForever:create(lightSeq))
		local function resetStar()
			star:setOpacity(255)
			star:setScale(0.94)
		end
		resetStar()
		local spawnArr = CCArray:create()
		spawnArr:addObject(CCRotateBy:create(10 / fps, 90))
		spawnArr:addObject(CCFadeTo:create(10 / fps, 0.1 * 255))
		spawnArr:addObject(CCScaleTo:create(10 / fps, 1.22))
		local starAnim = CCSpawn:create(spawnArr)
		local starSeq = CCSequence:createWithTwoActions(starAnim, CCCallFunc:create(resetStar))
		star:runAction(CCRepeatForever:create(starSeq))

		return container
	end

	anim.lightBg3 = createLight()
	anim.lightBg3:setScale(0.85)
	anim.lightBg3:setCascadeOpacityEnabled(true)
	anim:addChild(anim.lightBg3)
	anim.lightBg3:runAction(CCScaleTo:create(7 / fps, 1.4))

	anim.lightBg2 = createLight()
	anim.lightBg2:setScale(1.05)
	anim.lightBg2:setCascadeOpacityEnabled(true)
	anim:addChild(anim.lightBg2)
	local ops = {{x=-1, y=1}, {x=1, y=1},{x=1, y=-1},{x=-1, y=-1}}
	for i = 1, 14 do
		local star = createStarAnim()
		local op = ops[i%4 + 1]
		local posX = (400 - math.random(400)) / 10 * op.x -- [0, 40]
		local posY = (400 - math.random(400)) / 10 * op.y -- [0, 40]

		local pos = ccp(posX, posY)
		star:setPosition(pos)
		-- star:setRotation(math.random(90))
		star:setScale(0.4 + math.random(5) / 10)

		local deltaX, deltaY = 0, 0
		local deltaDistance = (100 + math.random(50))
		if pos.x == 0 or pos.y == 0 then 
			if pos.x == 0 and pos.y ~= 0 then 
				deltaY = deltaDistance
			elseif pos.y == 0 and pos.x ~= 0 then 
				deltaX = deltaDistance 
			else
				deltaX = math.random(deltaDistance)
				deltaY = math.sqrt(deltaDistance * deltaDistance - deltaX * deltaX)
			end
			if math.random(10) > 5 then deltaX = 0-deltaX end
			if math.random(10) > 5 then deltaY = 0-deltaY end
		else
			local a = math.sqrt(pos.x * pos.x + pos.y * pos.y)
			deltaX = deltaDistance * pos.x / a
			deltaY = deltaDistance * pos.y / a
		end

		local function onAnimFinished()
			star:removeFromParentAndCleanup(true)
		end
		local seq = CCArray:create()
		seq:addObject(CCMoveBy:create(6 / fps, ccp(deltaX * 3 / 7, deltaY * 3 / 7)))
		seq:addObject(CCMoveBy:create(9 / fps, ccp(deltaX * 4 / 7, deltaY * 4 / 7)))
		seq:addObject(CCCallFunc:create(onAnimFinished))
		star:runAction(CCSequence:create(seq))
		star:setCascadeOpacityEnabled(true)
		anim:addChild(star)
	end

	return anim
end

function CommonEffect:buildBirdEffectFlyAnim(specialType, fromPos, toPos, duration, arriveCallback, finishCallback)
	local node = CocosObject.new(CCNode:create())

	duration = duration or 0.4

	local flySpriteName = nil
	if specialType == AnimalTypeConfig.kWrap then
		flySpriteName = "special_fly_effect_yellow"
	else
		flySpriteName = "special_fly_effect_blue"
	end	

	local sprite = Sprite:createWithSpriteFrameName(flySpriteName)
	sprite:setScale(1, 0.2)
	sprite:setAnchorPoint(ccp(0.5, 0.2))
	sprite:ignoreAnchorPointForPosition(false)
	sprite:setPosition(ccp(fromPos.x, fromPos.y))

	local toPosX = toPos.x
	local toPosY = toPos.y
	local deltaX = toPos.x - fromPos.x
	local deltaY = toPos.y - fromPos.y
	local maxScale = math.sqrt(deltaX * deltaX + deltaY * deltaY) / 140
	if maxScale > 3 then maxScale = 3 end

	local function onAnimationFinished( ... )
		-- node:removeFromParentAndCleanup(true)
		if finishCallback then finishCallback() end
	end

	local function onFlyArrived()
		local explodeSprite = nil
		local explodeAnime = nil
		if specialType == AnimalTypeConfig.kWrap then
			explodeSprite, explodeAnime = SpriteUtil:buildAnimatedSprite(kCharacterAnimationTime, "special_effect_explode_yellow_%04d", 0, 18)
		else
			explodeSprite, explodeAnime = SpriteUtil:buildAnimatedSprite(kCharacterAnimationTime, "special_effect_explode_blue_%04d", 0, 18)
		end
		explodeSprite:play(explodeAnime, 0, 1, onAnimationFinished)
		explodeSprite:setPosition(ccp(toPosX-5, toPosY))

		node:addChild(explodeSprite)
		if arriveCallback then arriveCallback() end
	end

	local timePerFrame = duration / 11
	local actionSeq = CCArray:create()
	actionSeq:addObject(CCScaleTo:create(4*timePerFrame, 1, maxScale))
	actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(4*timePerFrame, 1, maxScale), CCFadeTo:create(4*timePerFrame, 255*0.63)))
	actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(3*timePerFrame, 1, 0.3), CCFadeTo:create(3*timePerFrame, 0)))
	actionSeq:addObject(CCCallFunc:create(onFlyArrived))

	local moveToAction = CCMoveTo:create(8*timePerFrame, ccp(toPos.x, toPos.y))
	sprite:runAction(CCSpawn:createWithTwoActions(CCSequence:create(actionSeq), moveToAction))

	sprite:setRotation(angleFromPoint(fromPos, toPos)-90)

	node:addChild(sprite)
	return node
end

function CommonEffect:buildMixSpecialAnim(specialType, targetPos, mixPosList, callback)
	local timePerFrame = 1/48
	local animateNode = Sprite:createEmpty()

	local waitCallbackNum = 0

	local function onActionFinished()
		waitCallbackNum = waitCallbackNum - 1
		if waitCallbackNum == 0 then
			animateNode:removeFromParentAndCleanup(true)
			if callback then callback() end
		end
	end

	local explodeSprite = nil
	local explodeAnime = nil
	local flySpriteName = nil
	if specialType == AnimalTypeConfig.kWrap then
		flySpriteName = "special_fly_effect_yellow"
		explodeSprite, explodeAnime = SpriteUtil:buildAnimatedSprite(timePerFrame, "special_effect_explode_yellow_%04d", 0, 18)
	elseif specialType == AnimalTypeConfig.kColor then
		flySpriteName = "special_fly_effect_colorful"
		explodeSprite, explodeAnime = SpriteUtil:buildAnimatedSprite(timePerFrame, "special_effect_explode_blue_%04d", 0, 18)
	else
		flySpriteName = "special_fly_effect_blue"
		explodeSprite, explodeAnime = SpriteUtil:buildAnimatedSprite(timePerFrame, "special_effect_explode_blue_%04d", 0, 18)
	end	

	explodeSprite:setPosition(ccp(-5, 0))
	explodeSprite:setOpacity(0)

	waitCallbackNum = waitCallbackNum + 1
	explodeSprite:play(CCSequence:createWithTwoActions(CCFadeIn:create(0), explodeAnime), 5*timePerFrame, 1, onActionFinished)

	animateNode:setTexture(explodeSprite:getTexture())
	animateNode:addChild(explodeSprite)

	if mixPosList then
		for _, pos in ipairs(mixPosList) do
			local deltaX = pos.x - targetPos.x
			local deltaY = pos.y - targetPos.y
			waitCallbackNum = waitCallbackNum + 1

			local sprite = Sprite:createWithSpriteFrameName(flySpriteName)
			sprite:setOpacity(0)
			sprite:setScaleY(0.125)

			local function onFlyFinished()
				sprite:removeFromParentAndCleanup(true)
				onActionFinished()
			end

			local actionSeq = CCArray:create()
			actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(4*timePerFrame, 1, 1), CCFadeTo:create(4*timePerFrame, 255)))
			actionSeq:addObject(CCScaleTo:create(3*timePerFrame, 1, 0.75))
			actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(2*timePerFrame, 1, 0.25), CCFadeTo:create(2*timePerFrame, 160)))
			actionSeq:addObject(CCDelayTime:create(timePerFrame))
			actionSeq:addObject(CCCallFunc:create(onFlyFinished))
			sprite:setPosition(ccp(deltaY * 70, - deltaX * 70))
			local animate = CCSpawn:createWithTwoActions(CCSequence:create(actionSeq), CCMoveTo:create(9*timePerFrame, ccp(0,0)))
			sprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2*timePerFrame), animate))
			sprite:setRotation(angleFromPoint(pos, targetPos))
			animateNode:addChild(sprite)
		end
	end

	return animateNode
end

function CommonEffect:buildGetPropLightAnim( text , showForever )
	local anim = Layer:create()
	anim.blackLayer = LayerColor:create()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local blackBgScale = 2 -- 针对可能有缩放的情况，直接放大2倍处理

	local blackWidth = vSize.width*blackBgScale
	local blackHeight = vSize.height*blackBgScale
	anim.blackLayer:changeWidthAndHeight(blackWidth, blackHeight)
	anim.blackLayer:setPosition(ccp(-blackWidth/2,-blackHeight/2))
	anim.blackLayer:setOpacity(150)
	anim:addChild(anim.blackLayer)

	local lightAnim = CommonEffect:buildGetPropLightAnimWithoutBg(showForever)
	lightAnim:setScale(1.23)
	anim:addChild(lightAnim)

	local sequenceArr3 = CCArray:create()
	sequenceArr3:addObject(CCDelayTime:create(2.5))
	sequenceArr3:addObject(CCFadeTo:create(0.3, 0))
	local function onAnimationFinished()
		anim:removeFromParentAndCleanup(true)
	end
	sequenceArr3:addObject(CCCallFunc:create(onAnimationFinished))
	anim.blackLayer:setTouchEnabled(true, 0, true)
	anim.blackLayer:stopAllActions()   
	if not showForever then
		anim.blackLayer:runAction(CCSequence:create(sequenceArr3))
	end          
	
	if type(text) == "string" then
		local label = TextField:create(text, nil, 30)
		label:setHorizontalAlignment(kCCTextAlignmentCenter)
		label:setAnchorPoint(ccp(0.5, 0.5))
		label:setPosition(ccp(0, 180))
		anim:addChild(label)
	end
	return anim
end

--
-- FallingStar ---------------------------------------------------------
--
FallingStar = class(Layer)

function FallingStar:buildUI(useWhiteColor, noParticle)
  local textureKey = "fallingstar0000"
  if useWhiteColor then textureKey = "fallingstar_white0000" end

  local sprite = Sprite:createWithSpriteFrameName(textureKey)
  sprite:setAnchorPoint(ccp(0.5, 0.05))
  self:addChild(sprite)
  self.sprite = sprite

  if not _G.__use_low_effect and not noParticle then 
	  local particle = ParticleSystemQuad:create("particle/falling_star.plist")
	  particle:setPosition(ccp(0,0))
	  self:addChild(particle)
  end
end
function FallingStar:create(from, to, animationCallbackFunc, flyFinishedCallback, useWhiteColor, isHalloween, noParticle)
  local ret = FallingStar.new()
  ret:initLayer()
  ret:buildUI(useWhiteColor, noParticle)
  ret:fly(from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, noParticle)
  return ret
end

function FallingStar:fly( from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, noParticle)
  local dx = to.x - from.x
  local dy = to.y - from.y
  local distance = dx * dx + dy * dy
  local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
  local visibleHeight = visibleSize.height
  local time = 1.5*math.sqrt(distance)/visibleHeight		-- 1280 as screen height

  if isHalloween then
    time = time * 3
    self:setScale(1.5)
  end

  -- local time = distance*0.000005
  --if time > 1 then time = 1 end
  --if time < 0.5 then time = 0.5 end
  local angle = math.atan2(dy, dx) * kRad3Ang
  local function onAnimationFinished()
    if animationCallbackFunc ~= nil then animationCallbackFunc() end
    self:removeFromParentAndCleanup(true)
  end

  time = time * 0.7
  self.time = time
  local halfTime = time * 0.5
  local fadeIn = CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime * 1.5, 2, 1.3), CCFadeIn:create(halfTime))
  local fadeOut = CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime * 0.5, 0), CCFadeOut:create(halfTime * 0.5))
  local sprite = self.sprite
  sprite:setRotation(angle-90)
  sprite:setScale(0)
  sprite:setOpacity(0)
  sprite:runAction(CCSequence:createWithTwoActions(fadeIn, fadeOut))

  local array = CCArray:create()
  array:addObject(CCEaseSineInOut:create(CCMoveTo:create(time, to)))
  if flyFinishedCallback ~= nil then array:addObject(CCCallFunc:create(flyFinishedCallback)) end
  if not noParticle then
	  array:addObject(CCDelayTime:create(0.6))
	end
  array:addObject(CCCallFunc:create(onAnimationFinished))
  self:setPosition(from)
  self:runAction(CCSequence:create(array))
end


--
-- Firebolt ---------------------------------------------------------
--
Firebolt = class(Layer)

function Firebolt:buildUI()
	--local glow = Sprite:createWithSpriteFrameName("")

	local sprite = Sprite:createWithSpriteFrameName("thunder_effect10000")
	sprite:setAnchorPoint(ccp(0.5, 0.05))
	self:addChild(sprite)
	self.sprite = sprite

	if not _G.__use_low_effect then 
		local particle = ParticleSystemQuad:create("particle/falling_star.plist")
		particle:setPosition(ccp(0,0))
		self:addChild(particle)
	end
end
function Firebolt:create(from, to, duration, animationCallbackFunc)
  local ret = Firebolt.new()
  ret:initLayer()
  ret:buildUI()
  ret:fly(from, to, duration, animationCallbackFunc)
  return ret
end

function Firebolt:fly( from, to, duration, animationCallbackFunc )
  local dx = to.x - from.x
  local dy = to.y - from.y
  local distance = dx * dx + dy * dy
  local time = duration or 0.4
  local angle = math.atan2(dy, dx) * kRad3Ang
  local function onAnimationFinished()
    if animationCallbackFunc ~= nil then animationCallbackFunc() end
    self:removeFromParentAndCleanup(true)
  end

  local halfTime = time * 0.5
  local fadeIn = CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime, 2, 1.5), CCFadeIn:create(halfTime))
  local fadeOut = CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime, 0), CCFadeOut:create(halfTime))
  local sprite = self.sprite
  sprite:setRotation(angle-90)
  sprite:setScale(0)
  sprite:setOpacity(0)
  sprite:runAction(CCSequence:createWithTwoActions(fadeIn, fadeOut))

  local array = CCArray:create()
  array:addObject(CCEaseSineInOut:create(CCMoveTo:create(time, to)))
  array:addObject(CCDelayTime:create(0.1))
  array:addObject(CCCallFunc:create(onAnimationFinished))
  self:setPosition(from)
  self:runAction(CCSequence:create(array))
end

function Firebolt:createLightOnly( from, to, duration, animationCallbackFunc )
	local sprite = Sprite:createWithSpriteFrameName("thunder_effect20000")
	local container = SpriteBatchNode:createWithTexture(sprite:getTexture())

	sprite:setAnchorPoint(ccp(0.5, 0.05))
	local bird = Sprite:createWithSpriteFrameName("colorbird_effect0000")

	local dx = to.x - from.x
  	local dy = to.y - from.y
  	local distance = dx * dx + dy * dy
  	local time = duration or 0.4
  	local angle = math.atan2(dy, dx) * kRad3Ang
  	local function onLightAnimationEnd()
  		container:removeFromParentAndCleanup(true)
  	end
	local function onAnimationFinished()
		local kStarFactor = 360*3.1415926 / 180
		local fadeOutTime = 0.2
		if animationCallbackFunc ~= nil then animationCallbackFunc() end
		bird:runAction(CCSequence:createWithTwoActions(CCSpawn:createWithTwoActions(CCScaleTo:create(fadeOutTime, 2),CCFadeOut:create(fadeOutTime)), CCCallFunc:create(onLightAnimationEnd)))
		for i = 0, 10 do
			local fadeTime = 0.2 + math.random() * 0.3
			local angle = math.random()*kStarFactor
			local x = math.cos(angle) * (80 + math.random() * 10) 
			local y = math.sin(angle) * (80 + math.random() * 10) 
			local star = Sprite:createWithSpriteFrameName("color_bird_star0000")
			star:setScale(1 + math.random())
			star:setPosition(ccp(math.random()* 15-8, math.random()*15-8))
			star:runAction(CCSpawn:createWithTwoActions(CCMoveTo:create(fadeTime, ccp(x, y)), CCFadeOut:create(fadeTime)))
			container:addChildAt(star, 0)
		end
	end

	local halfTime = (time-0.1) * 0.5

	bird:setOpacity(0)
	bird:runAction(CCFadeIn:create(halfTime))

	local fadeArray = CCArray:create()
	fadeArray:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime, 2, 1), CCFadeIn:create(halfTime)))
	fadeArray:addObject(CCDelayTime:create(0.1))
	fadeArray:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime, 2, 0), CCFadeOut:create(halfTime)))
	
	sprite:setRotation(angle-90)
	sprite:setScaleY(0)
	sprite:setOpacity(0)	
	sprite:runAction(CCSequence:create(fadeArray))

	local array = CCArray:create()
	array:addObject(CCEaseSineInOut:create(CCMoveTo:create(time, to)))
	array:addObject(CCDelayTime:create(0.1))
	array:addObject(CCCallFunc:create(onAnimationFinished))
	container:runAction(CCSequence:create(array))
	container:setPosition(from)
	
	container:addChild(bird)
	container:addChild(sprite)
	return container
end

BonusFallingStar = class(Layer)

function BonusFallingStar:create(from, to, animationCallbackFunc, flyFinishedCallback)
	-- FrameLoader:loadImageWithPlist("flash/bonus_effects.plist")
	local node = BonusFallingStar.new()
	node:init(from, to, animationCallbackFunc, flyFinishedCallback)
	return node
end

function BonusFallingStar:init(from, to, animationCallbackFunc, flyFinishedCallback)
	Layer.initLayer(self)
	local time = 0.4
	local deltaX = from.x - to.x
	local deltaY = from.y - to.y
	local time = math.sqrt(deltaX*deltaX + deltaY * deltaY) / 2000
	if time < 0.2 then time = 0.2 end

	self.motionStreak = self:buildMotionStreak(0.4, 28)
	self.motionStreak:setPosition(from)
	self:addChild(self.motionStreak)

	local star = Sprite:createWithSpriteFrameName("bonus_effects_star00")
	self.starsBatchNode = SpriteBatchNode.new(CCSpriteBatchNode:createWithTexture(star:getTexture()))
	self:addChild(self.starsBatchNode)

	self.light = self:buildLightAnime(time)
	self.light:setPosition(from)
	self:addChild(self.light)

	self.animationCallbackFunc = animationCallbackFunc
	self.flyFinishedCallback = flyFinishedCallback

	star:dispose()

	self:_startFly(from, to, time)
end

function BonusFallingStar:_startFly(from, to, time)
	if self.isFlying then return end
	self.isFlying = true

	time = time or 0.4

	local startX, startY = from.x, from.y
	local endX, endY = to.x, to.y
	local deltaX, deltaY = endX - startX, endY - startY
	local preX, preY = from.x, from.y
	local newX, newY = to.x, to.y

	local function updatePostion(totalTime)
		if totalTime >= time then
			return ccp(endX, endY)
		else
			local progress = totalTime / time
			if progress > 1 then progress = 1 end
			local posX = startX + deltaX * (progress)
			local posY = startY + deltaY * (progress * progress)
			local pos = ccp(posX, posY)
			preX, preY = newX, newY
			newX, newY = pos.x, pos.y
			return pos
		end
	end

	local totalTime = 0
	local tmpTime = 0
	local function onUpdate(deltaTime)
		totalTime = totalTime + deltaTime

		local newPos = updatePostion(totalTime)
		self.motionStreak:setPosition(newPos)

		local rotation = angleFromPoint(ccp(preX, preY), ccp(newX, newY)) - 180 
		self.light:setPosition(newPos)
		self.light:setRotation(rotation)

		if totalTime > 0.05 and totalTime - tmpTime > 0.02 then
			tmpTime = totalTime
			local progress = totalTime / time
			local idx = math.floor(progress / 0.25)
			if idx > 3 then idx = 3 end

			local dx = (preX - newX) * 0.6
			local dy = (preY - newY) * 0.6
			local maxDelta = 16
			if dx < -maxDelta then dx = -maxDelta end
			if dx > maxDelta then dx = maxDelta end
			if dy < -maxDelta then dy = -maxDelta end
			if dy > maxDelta then dy = maxDelta end

			local star = self:buildStarAnime(idx, time, ccp(dx, dy))
			star:setScale((6+math.random(1, 4))/10)
			star:setPosition(ccp(newPos.x+math.random(-10, 10), newPos.y+math.random(-10, 10)))
			star:setRotation(math.random(0, 60))
			self.starsBatchNode:addChild(star)
		end
		if totalTime >= time then
			self:unscheduleUpdate()
			local function onAnimationFinished()
				self:removeFromParentAndCleanup(true)
				if self.animationCallbackFunc then self.animationCallbackFunc() end
			end
			self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.4), CCCallFunc:create(onAnimationFinished)))
			if self.flyFinishedCallback then self.flyFinishedCallback() end
		end
	end
	self:scheduleUpdateWithPriority(onUpdate, 0)
end

function BonusFallingStar:buildLightAnime(time)
	local light = Sprite:createWithSpriteFrameName("bonus_effects_light") 
	local lightActSeq = CCArray:create()
	lightActSeq:addObject(CCScaleTo:create(time * 0.5, 3.4, 0.7))
	lightActSeq:addObject(CCDelayTime:create(time * 0.25))
	lightActSeq:addObject(CCScaleTo:create(time * 0.25, 1.2, 0.8))
	lightActSeq:addObject(CCHide:create())
	light:runAction(CCSequence:create(lightActSeq))
	return light
end

function BonusFallingStar:buildStarAnime(type, time, moveBy)
	local star = Sprite:createWithSpriteFrameName(string.format("bonus_effects_star%02d", type))
	star:setOpacity(0)
	star:runAction(CCRepeatForever:create(CCRotateBy:create(1, 270)))
	local actSeq = CCArray:create()
	actSeq:addObject(CCFadeIn:create(time * 0.2))
	actSeq:addObject(CCDelayTime:create(time * 0.2))
	actSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(time * 0.8, 0), CCMoveBy:create(time * 0.8, moveBy)))
	star:runAction(CCSequence:create(actSeq))
	return star
end

local motionStreakUseTexture = nil
function BonusFallingStar:getMotionStreakUseTexture()
	if not motionStreakUseTexture then
		local sprite = Sprite:createWithSpriteFrameName("bonus_effects_line")
		local renderTexture = CCRenderTexture:create(40, 450)
		renderTexture:beginWithClear(255, 255, 255, 0)
		sprite:setPosition(ccp(20, 225))
		sprite:setFlipY(true)
		sprite:visit()
		sprite:dispose()
		renderTexture:endToLua()
		if __WP8 then renderTexture:saveToCache() end
		renderTexture:retain()

		motionStreakUseTexture = renderTexture:getSprite():getTexture():getTexture()
		motionStreakUseTexture:setAntiAliasTexParameters()
	end
	return motionStreakUseTexture
end

function BonusFallingStar:buildMotionStreak(fade, stroke)
	fade = fade or 0.3
	stroke = stroke or 32
	local texture2d = self:getMotionStreakUseTexture()
	local motionStreakObj = CCMotionStreak:create(fade, 3, stroke, ccc3(255, 255, 255), texture2d)
	local motionStreak = CocosObject.new(motionStreakObj)
    return motionStreak
end

function BonusFallingStar:dispose()
	self:unscheduleUpdate()
	Layer.dispose(self)
end

--
-- BezierFallingStar 贝塞尔曲线飞星星 ---------------------------------------------------------
--
BezierFallingStar = class(FallingStar)

function BezierFallingStar:create(from, to, animationCallbackFunc, flyFinishedCallback, useWhiteColor, isHalloween, direction)
	local ret = BezierFallingStar.new()
	ret:initLayer()
	ret:buildUI(useWhiteColor)
	ret:fly(from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, direction)
	return ret
end
function BezierFallingStar:createMoveAction( from, to,direction )
	local bezierConfig = ccBezierConfig:new() 
	local controlPoint = ccp((from.x + to.x)/2+(to.y-from.y)/4, (from.y + to.y)/2+(-to.x+from.x)/4)

	if direction == false then
		controlPoint = ccp((from.x + to.x)/2-(to.y-from.y)/4, (from.y + to.y)/2-(-to.x+from.x)/4)
	end

	bezierConfig.controlPoint_1 = controlPoint
	bezierConfig.controlPoint_2 = controlPoint
	bezierConfig.endPosition = to

	return CCEaseSineInOut:create(CCBezierTo:create(self.time, bezierConfig))

end

function BezierFallingStar:fly( from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, direction)
	local dx = to.x - from.x
	local dy = to.y - from.y

	if isHalloween then
		local distance = dx * dx + dy * dy
		local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
		local visibleHeight = visibleSize.height
		local time = 1.5*math.sqrt(distance)/visibleHeight		-- 1280 as screen height
		time = time * 3
		self:setScale(1.5)

		time = time * 0.7
		self.time = time
	else
		-- 改成固定时间
		time = 0.7
		self.time = time
	end

	local angle = math.atan2(dy, dx) * kRad3Ang
	local function onAnimationFinished()
	if animationCallbackFunc ~= nil then animationCallbackFunc() end
		self:removeFromParentAndCleanup(true)
	end


	local halfTime = time * 0.5
	local fadeIn = CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime * 1.5, 2, 1.3), CCFadeIn:create(halfTime))
	local fadeOut = CCSpawn:createWithTwoActions(CCScaleTo:create(halfTime * 0.5, 0), CCFadeOut:create(halfTime * 0.5))
	local sprite = self.sprite
	
	sprite:setScale(0)
	sprite:setOpacity(0)

	sprite:runAction(CCSequence:createWithTwoActions(fadeIn, fadeOut))
	

	local array = CCArray:create()

	local bezierConfig = ccBezierConfig:new() 
	local controlPoint = ccp((from.x + to.x)/2+(to.y-from.y)/4, (from.y + to.y)/2+(-to.x+from.x)/4)

	if direction == false then
		controlPoint = ccp((from.x + to.x)/2-(to.y-from.y)/4, (from.y + to.y)/2-(-to.x+from.x)/4)
	end

	bezierConfig.controlPoint_1 = controlPoint
	bezierConfig.controlPoint_2 = controlPoint
	bezierConfig.endPosition = to


	local bezierMove = CCEaseSineInOut:create(CCBezierTo:create(time, bezierConfig))
	array:addObject(bezierMove)
	if flyFinishedCallback ~= nil then array:addObject(CCCallFunc:create(flyFinishedCallback)) end
	array:addObject(CCDelayTime:create(0.6))
	array:addObject(CCCallFunc:create(onAnimationFinished))
	self:setPosition(from)
	self:runAction(CCSequence:create(array))

	local angleStart = math.atan2(controlPoint.y-from.y, controlPoint.x-from.x) * kRad3Ang - 90
	local angleEnd = math.atan2(-controlPoint.y+to.y, -controlPoint.x+to.x) * kRad3Ang - 90
	sprite:setRotation(angleStart)
	sprite:runAction(CCRotateBy:create(time, angleEnd-angleStart))
end


if __PURE_LUA__ then
	require "plua.myCommonEffect"
end