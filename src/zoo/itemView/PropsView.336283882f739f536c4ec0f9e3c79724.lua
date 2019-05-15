
PropsView = class{}

-- 动画的播放速度
local kPropsAnimationTime = 1 / 24

-- 动画的时间长度
local AnimationFrames = table.const
{
	kHammer = 14,
	kLineBrush = 25
}

function PropsView:playHammerAnimation(boardView, position)
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		position = boardView.gameBoardLogic:getGameItemPosInView(position.x, position.y)
	else
		local tile = boardView.baseMap[position.x][position.y]
		position = ccp(tile.pos_x, tile.pos_y)
	end

	local layer = boardView
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		layer = boardView.PlayUIDelegate.effectLayer 
	end

	local function viberate( ... )
		boardView:viberate()
	end

	local anim = PropsAnimation:createHammerAnim(viberate,boardView.PlayUIDelegate)
	anim:setPositionX(position.x)
	anim:setPositionY(position.y)
	layer:addChild(anim)

	anim:play()
end

local disablePropAnimPlayingPosition = {}

function PropsView:playHammerDisableAnimation(boardView, position)
	PropsView:playPropDisableAnimation(boardView, position, 10010)
end

function PropsView:playLineBrushDisableAnimation(boardView, position)
	PropsView:playPropDisableAnimation(boardView, position, 10005)
end

function PropsView:playForceSwapDisableAnimation(boardView, position)
	PropsView:playPropDisableAnimation(boardView, position, 10003)
end

function PropsView:playBroomDisableAnimation(boardView, position)
	PropsView:playPropDisableAnimation(boardView, position, GamePropsType.kBroom)
end

function PropsView:playJamSpeardHammerDisableAnimation(boardView, position)
	PropsView:playPropDisableAnimation(boardView, position, 10103)
end

function PropsView:playLineEffectDisableAnimation(boardView, position, isColumn)
	local itemID = 10105
	if isColumn then itemID = 10109 end
	PropsView:playPropDisableAnimation(boardView, position, itemID)
end

function PropsView:playPropDisableAnimation(boardView, position, itemId)
	if disablePropAnimPlayingPosition[position.x .. "_" .. position.y] then
		return
	end
	disablePropAnimPlayingPosition[position.x .. "_" .. position.y] = true

	local viewPos = nil
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		viewPos = boardView.gameBoardLogic:getGameItemPosInView(position.x, position.y)
	else
		local tile = boardView.baseMap[position.x][position.y]
		viewPos = ccp(tile.pos_x, tile.pos_y)
	end

	local hammer = PropsView:buildPropDisableAnimation(itemId, position)
	hammer:setPosition(ccp(viewPos.x, viewPos.y + GamePlayConfig_Hammer_Pos.y))

	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		boardView.PlayUIDelegate.effectLayer:addChild(hammer)
	else
		boardView:addChild(hammer)
	end
end

function PropsView:buildPropDisableAnimation(itemId, position)
	local hammerIcon = PropListAnimation:createIcon(itemId) --Sprite:createWithSpriteFrameName("Prop_".. itemId .." instance 10000")
	local disableIcon = Sprite:createWithSpriteFrameName("disableImage0000")
	disableIcon:setPosition(ccp(5, -10))
	disableIcon:setScale(0.8)

	local tip = Localization:getInstance():getText("prop.disabled.tip5")
	local label = TextField:create(tip, nil, 22)
	label:setPositionY(50)

	local container = Sprite:createEmpty()
	container:addChild(hammerIcon)
	container:addChild(disableIcon)
	container:addChild(label)

	local function animationComplete()
		if container and container:getParent() then
			container:removeFromParentAndCleanup(true)
			disablePropAnimPlayingPosition[position.x .. "_" .. position.y] = nil
		end
	end

	local function getFadeAction(shake)
		local fadeIn = CCFadeIn:create(0.1)
		local delay = CCDelayTime:create(1)
		local fadeOut = CCFadeOut:create(0.5)
		local complete = CCCallFunc:create(animationComplete)
		local actionList = CCArray:create()
		actionList:addObject(fadeIn)
		actionList:addObject(delay)
		actionList:addObject(fadeOut)
		actionList:addObject(complete)
		local fadeSequence = CCSequence:create(actionList)

		if not shake then
			return fadeSequence
		end

		local shakeActionList = CCArray:create()
		shakeActionList:addObject(CCMoveBy:create(0.05, ccp(-10, 0)))
		shakeActionList:addObject(CCMoveBy:create(0.09, ccp(18, 0)))
		shakeActionList:addObject(CCMoveBy:create(0.06, ccp(-13, 0)))
		shakeActionList:addObject(CCMoveBy:create(0.05, ccp(10, 0)))
		shakeActionList:addObject(CCMoveBy:create(0.025, ccp(-5, 0)))
		local shakeSequence = CCSequence:create(shakeActionList)
		local targetAction = CCSpawn:createWithTwoActions(fadeSequence, shakeSequence)
		return targetAction
	end
	
	hammerIcon:runAction(getFadeAction(true))
	disableIcon:runAction(getFadeAction(true))
	label:runAction(getFadeAction(false))

	return container
end

function PropsView:playLineBrushAnimation(boardView, position, targetpos)
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		position = boardView.gameBoardLogic:getGameItemPosInView(position.x, position.y)
	else
		local tile = boardView.baseMap[position.x][position.y]
		position = ccp(tile.pos_x, tile.pos_y)
	end

	local layer = boardView
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		layer = boardView.PlayUIDelegate.effectLayer 
	end 

	local anim = PropsAnimation:createLineAnim(boardView.PlayUIDelegate)
	anim:setPositionX(position.x)
	anim:setPositionY(position.y)

	local size = CCDirector:sharedDirector():getVisibleSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	if position.x > origin.x + size.width/2 then
		anim:setScaleX(-1)
	end
	layer:addChild(anim)
	anim:play()
end

function PropsView:buildHammerAnimation()
	local hammer = Sprite:createWithSpriteFrameName("props_hammer.png")
	hammer:setAnchorPoint(ccp(0.5, 0.1))
	hammer:setRotation(GamePlayConfig_Hammer_InitAngle)
	local ring = Sprite:createWithSpriteFrameName("props_hammer_ring.png")
	ring:setPosition(GamePlayConfig_Impact_Pos)
	ring:setScale(GamePlayConfig_Impact_InitScale)
	ring:setOpacity(GamePlayConfig_Impact_InitOpacity)
	ring:runAction(CCToggleVisibility:create())

	local function onRepeatFinishCallback()
		hammer:removeFromParentAndCleanup(true)
		ring:removeFromParentAndCleanup(true)
	end

	local rotation = CCArray:createWithCapacity(4)
	rotation:addObject(CCRotateTo:create(BoardViewAction:getActionTime(GamePlayConfig_Hammer_1stUpTime), GamePlayConfig_Hammer_UpAngle))
	rotation:addObject(CCRotateTo:create(BoardViewAction:getActionTime(GamePlayConfig_Hammer_DownTime), GamePlayConfig_Hammer_HitAngle))
	rotation:addObject(CCRotateTo:create(BoardViewAction:getActionTime(GamePlayConfig_Hammer_2ndUpTime), GamePlayConfig_Hammer_FinalAngle))
	rotation:addObject(CCCallFunc:create(onRepeatFinishCallback))
	local rolling = CCSequence:create(rotation)
	local impactArr = CCArray:createWithCapacity(5)
	impactArr:addObject(CCDelayTime:create(BoardViewAction:getActionTime(GamePlayConfig_Hammer_1stUpTime + GamePlayConfig_Hammer_DownTime)))
	impactArr:addObject(CCToggleVisibility:create())
	impactArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(BoardViewAction:getActionTime(GamePlayConfig_Impact2ndTime),
		GamePlayConfig_Impact_2ndScale), CCFadeTo:create(BoardViewAction:getActionTime(GamePlayConfig_Impact2ndTime),
		GamePlayConfig_Impact_2ndOpacity)))
	impactArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(BoardViewAction:getActionTime(GamePlayConfig_ImpackFinalTime),
		GamePlayConfig_Impact_FinalScale),
		CCFadeTo:create(BoardViewAction:getActionTime(GamePlayConfig_ImpackFinalTime), GamePlayConfig_Impact_FinalOpacity)))
	impactArr:addObject(CCCallFunc:create(onRepeatFinishCallback))
	local impact = CCSequence:create(impactArr)

	hammer:runAction(rolling)
	ring:runAction(impact)

	return hammer, ring
end

function PropsView:buildLineBrushAnimation(boardView, position, targetpos)
	local targetPosition = ccp(position.x + targetpos.x * 2.5 * GamePlayConfig_Tile_Width, position.y + targetpos.y * 2.5 *
		GamePlayConfig_Tile_Height)

	local wand = Sprite:createWithSpriteFrameName("props_linebrush_wand.png")
	local comet = Sprite:createWithSpriteFrameName("props_linebrush_comet.png")
	local star1 = Sprite:createWithSpriteFrameName("props_linebrush_star.png")
	local star2 = Sprite:createWithSpriteFrameName("props_linebrush_star.png")
	local star3 = Sprite:createWithSpriteFrameName("props_linebrush_star.png")

	local function onRepeatFinishCallback()
		wand:removeFromParentAndCleanup(true)
		comet:removeFromParentAndCleanup(true)
		star1:removeFromParentAndCleanup(true)
		star2:removeFromParentAndCleanup(true)
		star3:removeFromParentAndCleanup(true)
	end

	wand:setAnchorPoint(GamePlayConfig_LineBrush_AnchorPoint)
	wand:setPosition(position)
	wand:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.3, targetPosition), CCToggleVisibility:create()))
	comet:setAnchorPoint(ccp(0.5, 0))
	if targetpos.x > 0 then comet:setRotation(270)
	elseif targetpos.x < 0 then comet:setRotation(90)
	elseif targetpos.y > 0 then comet:setRotation(180)
	elseif targetpos.y < 0 then comet:setRotation(0) end
	comet:setPosition(position)
	comet:runAction(CCToggleVisibility:create())
	local scaleMotionArr = CCArray:createWithCapacity(5)
	scaleMotionArr:addObject(CCDelayTime:create(GamePlayConfig_LineBrush_Comet_ShowDelay))
	scaleMotionArr:addObject(CCToggleVisibility:create())
	scaleMotionArr:addObject(CCDelayTime:create(GamePlayConfig_LineBrush_Comet_ScaleWait))
	scaleMotionArr:addObject(CCScaleTo:create(GamePlayConfig_LineBrush_Comet_ScaleDuration, 0, GamePlayConfig_LineBrush_Comet_FinalScaleY))
	scaleMotionArr:addObject(CCToggleVisibility:create())
	local scaleMotion = CCSequence:create(scaleMotionArr)
	comet:runAction(CCSpawn:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Comet_MovingTime),
		targetPosition), scaleMotion))
	local rotation = comet:getRotation()
	star1:setScale(GamePlayConfig_LineBrush_Star1_Scale)
	star2:setScale(GamePlayConfig_LineBrush_Star2_Scale)
	star3:setScale(GamePlayConfig_LineBrush_Star3_Scale)
	if targetpos.x > 0 then
		star1:setPosition(ccp(position.x - GamePlayConfig_LineBrush_Star1_InitY, position.y + GamePlayConfig_LineBrush_Star1_InitX))
		star1:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star1_MovingTime),
			ccp(targetPosition.x - GamePlayConfig_LineBrush_Star1_FinalY, targetPosition.y + GamePlayConfig_LineBrush_Star1_FinalX)),
			CCToggleVisibility:create()))
		star2:setPosition(ccp(position.x - GamePlayConfig_LineBrush_Star2_InitY, position.y + GamePlayConfig_LineBrush_Star2_InitX))
		star2:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star2_MovingTime),
			ccp(targetPosition.x + GamePlayConfig_LineBrush_Star2_FinalY, targetPosition.y - GamePlayConfig_LineBrush_Star2_FinalX)),
			CCToggleVisibility:create()))
		star3:setPosition(ccp(position.x - GamePlayConfig_LineBrush_Star3_InitY, position.y + GamePlayConfig_LineBrush_Star3_InitX))
		star3:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star3_MovingTime),
			ccp(targetPosition.x - GamePlayConfig_LineBrush_Star3_FinalY, targetPosition.y + GamePlayConfig_LineBrush_Star3_FinalX)),
			CCCallFunc:create(onRepeatFinishCallback)))
	elseif targetpos.x < 0 then
		star1:setPosition(ccp(position.x + GamePlayConfig_LineBrush_Star1_InitY, position.y - GamePlayConfig_LineBrush_Star1_InitX))
		star1:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star1_MovingTime),
			ccp(targetPosition.x + GamePlayConfig_LineBrush_Star1_FinalY, targetPosition.y - GamePlayConfig_LineBrush_Star1_FinalX)),
			CCToggleVisibility:create()))
		star2:setPosition(ccp(position.x + GamePlayConfig_LineBrush_Star2_InitY, position.y - GamePlayConfig_LineBrush_Star2_InitX))
		star2:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star2_MovingTime),
			ccp(targetPosition.x - GamePlayConfig_LineBrush_Star2_FinalX, targetPosition.y + GamePlayConfig_LineBrush_Star2_FinalY)),
			CCToggleVisibility:create()))
		star3:setPosition(ccp(position.x + GamePlayConfig_LineBrush_Star3_InitY, position.y - GamePlayConfig_LineBrush_Star3_InitX))
		star3:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star3_MovingTime),
			ccp(targetPosition.x + GamePlayConfig_LineBrush_Star3_FinalY, targetPosition.y - GamePlayConfig_LineBrush_Star3_FinalX)),
			CCCallFunc:create(onRepeatFinishCallback)))
	elseif targetpos.y > 0 then
		star1:setPosition(ccp(position.x - GamePlayConfig_LineBrush_Star1_InitX, position.y - GamePlayConfig_LineBrush_Star1_InitY))
		star1:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star1_MovingTime),
			ccp(targetPosition.x - GamePlayConfig_LineBrush_Star1_FinalX, targetPosition.y - GamePlayConfig_LineBrush_Star1_FinalY)),
			CCToggleVisibility:create()))
		star2:setPosition(ccp(position.x - GamePlayConfig_LineBrush_Star2_InitX, position.y - GamePlayConfig_LineBrush_Star2_InitY))
		star2:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star2_MovingTime),
			ccp(targetPosition.x + GamePlayConfig_LineBrush_Star2_FinalX, targetPosition.y + GamePlayConfig_LineBrush_Star2_FinalY)),
			CCToggleVisibility:create()))
		star3:setPosition(ccp(position.x - GamePlayConfig_LineBrush_Star3_InitX, position.y - GamePlayConfig_LineBrush_Star3_InitY))
		star3:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star3_MovingTime),
			ccp(targetPosition.x - GamePlayConfig_LineBrush_Star3_FinalX, targetPosition.y - GamePlayConfig_LineBrush_Star3_FinalY)),
			CCCallFunc:create(onRepeatFinishCallback)))
	elseif targetpos.y < 0 then
		star1:setPosition(ccp(position.x + GamePlayConfig_LineBrush_Star1_InitX, position.y + GamePlayConfig_LineBrush_Star1_InitY))
		star1:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star1_MovingTime),
			ccp(targetPosition.x + GamePlayConfig_LineBrush_Star1_FinalX, targetPosition.y + GamePlayConfig_LineBrush_Star1_FinalY)),
			CCToggleVisibility:create()))
		star2:setPosition(ccp(position.x + GamePlayConfig_LineBrush_Star2_InitX, position.y + GamePlayConfig_LineBrush_Star2_InitY))
		star2:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star2_MovingTime),
			ccp(targetPosition.x - GamePlayConfig_LineBrush_Star2_FinalX, targetPosition.y - GamePlayConfig_LineBrush_Star2_FinalY)),
			CCToggleVisibility:create()))
		star3:setPosition(ccp(position.x + GamePlayConfig_LineBrush_Star3_InitX, position.y + GamePlayConfig_LineBrush_Star3_InitY))
		star3:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_LineBrush_Star3_MovingTime),
			ccp(targetPosition.x + GamePlayConfig_LineBrush_Star3_FinalX, targetPosition.y + GamePlayConfig_LineBrush_Star3_FinalY)),
			CCCallFunc:create(onRepeatFinishCallback)))
	end

	return wand, comet, star1, star2, star3
end

function PropsView:playOctopusForbidCastingAnimation(boardView, fromPos, toPos, callback)

	local function buildExplosion(callback)
		local dust = Sprite:createWithSpriteFrameName('frost_dust_0000')
		local small_cercle = Sprite:createWithSpriteFrameName('frost_cercle_small_0000')
		local medium_cercle = Sprite:createWithSpriteFrameName('frost_cercle_medium_0000')
		local large_cercle = Sprite:createWithSpriteFrameName('frost_cercle_large_0000')
		local node = CocosObject:create()
		dust:setScale(0)
		small_cercle:setScale(0)
		medium_cercle:setScale(0)
		large_cercle:setScale(0)
		dust:setAnchorPoint(ccp(0.5, 0.5))
		small_cercle:setAnchorPoint(ccp(0.5, 0.5))
		small_cercle:setAnchorPoint(ccp(0.5, 0.5))
		large_cercle:setAnchorPoint(ccp(0.5, 0.5))
		local fps = 30
		local a_dust, a_small, a_medium, a_large = CCArray:create(), CCArray:create(), CCArray:create(), CCArray:create()

		a_small:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7/fps, 1), CCFadeTo:create(7/fps, 0.5)))
		a_small:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7/fps, 2.42), CCFadeTo:create(7/fps, 0.1)))
		small_cercle:runAction(CCSequence:create(a_small))

		a_medium:addObject(CCDelayTime:create(2/fps))
		a_medium:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7/fps, 1), CCFadeTo:create(7/fps, 0.5)))
        a_medium:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7/fps, 2.42), CCFadeTo:create(7/fps, 0.1)))
        medium_cercle:runAction(CCSequence:create(a_medium))

        a_large:addObject(CCDelayTime:create(6/fps))
        a_large:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7/fps, 1), CCFadeTo:create(7/fps, 0.5)))
        a_large:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7/fps, 2.42), CCFadeTo:create(7/fps, 0.1)))
        a_large:addObject(CCCallFunc:create(callback))
        large_cercle:runAction(CCSequence:create(a_large))

        a_dust:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(6/fps, 1), CCFadeIn:create(6/fps)))
        a_dust:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(6/fps, 1.2), CCFadeOut:create(6/fps)))
        dust:runAction(CCSequence:create(a_dust))


		node:addChild(dust)
		node:addChild(small_cercle)
		node:addChild(medium_cercle)
		node:addChild(large_cercle)
		return node
	end

	local function finishCallback()
		local explosion
		local function explodeCallback()
			if explosion then explosion:removeFromParentAndCleanup(true) end
		end
		explosion = buildExplosion(explodeCallback)

		boardView:addChild(explosion)
		explosion:setPosition(toPos)

		if callback then
			-- local callbackAction = CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(callback))
			-- boardView:runAction(callbackAction)
			callback()
		end
	end
	local flyTo = FallingStar:create(fromPos, toPos, nil, finishCallback)
	boardView:addChild(flyTo)

end

-- interval:你想要每隔多少时间爆掉一列动物，这个interval用来计算女巫飞行的速度
function PropsView:playWitchFlyingAnimation(boardView, interval, row)
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local mainLogic = boardView.gameBoardLogic

	local boardScale = boardView:getScale()

	local boardRightX = mainLogic:getGameItemPosInView(1, 9).x
	local boardLeftX = mainLogic:getGameItemPosInView(1, 1).x
	local witchHeight = mainLogic:getGameItemPosInView(row + 0.5, 1).y
	local flyingDistance = vs.width + 200 -- 加上左右各200
	local sprite = Sprite:createWithSpriteFrameName('witch0000')
	sprite:setScale(boardScale)
	sprite:setAnchorPoint(ccp(0.5, 0.5))
	local startPos = ccp(vo.x + vs.width + 100, witchHeight - 30)
	local destPos = ccp(vo.x -200, witchHeight)

	local speed = (boardRightX - boardLeftX) / (8 * interval) 
	local time = flyingDistance / speed
	local startBombingDelay = (100 + (vo.x + vs.width) - boardRightX) / speed

	local container = LayerColor:create()
	container:setPosition(ccp(0, 0))

	--test
	container:setContentSize(CCSizeMake(10, 10))
	container:setColor(ccc3(0,0,0))

	sprite:setPosition(startPos)
	sprite:runAction(CCSequence:createWithTwoActions(
		CCMoveTo:create(time, destPos), 
		CCCallFunc:create(
			function () 
				if container then 
					container:removeFromParentAndCleanup(true) 
					container = nil
				end
			end)
		))

	local actionWobble = CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(0.5, ccp(0, 30)), CCMoveBy:create(0.5, ccp(0, -30))))
	sprite:runAction(actionWobble)
	local schedId = nil
	local function repeatFunc()
		if container then
			self:createWitchTail(sprite:getPosition(), sprite:getZOrder()-1, boardScale, container)
		else
			if schedId then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(schedId) 
				schedId = nil
			end
		end
	end

	local scene = Director:sharedDirector():getRunningScene()

	if scene then
		scene:addChild(container)
		container:addChild(sprite)
	end

	local interval = 0.2
	schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(repeatFunc,interval,false)
	repeatFunc()

	return startBombingDelay
end

function PropsView:createWitchTail(pos, zOrder, boardScale, container)
	local starCount = 5
	local tailCount = 4
	local function getRandPos(point)
		local x = point.x + math.random(-30*boardScale, 100*boardScale)
		local y = point.y + math.random(-60*boardScale, 70*boardScale)
		return ccp(x, y)
	end
	local totalTime = 1

	-- 不用remove,丢给container去remove
	local function getStar(pos)
		local spriteStar = Sprite:createWithSpriteFrameName('win_star_shine0000')
		local array = CCArray:create()
		array:addObject(CCSequence:createWithTwoActions(CCEaseSineOut:create(CCFadeIn:create(totalTime/2)), CCEaseSineIn:create(CCFadeOut:create(totalTime/2))))
		array:addObject(CCScaleBy:create(totalTime, 2*boardScale))
		array:addObject(CCRotateBy:create(totalTime, 200))
		array:addObject(CCMoveBy:create(totalTime, ccp(30*boardScale, 0)))
		spriteStar:setPosition(pos)
		spriteStar:setOpacity(0)
		spriteStar:setScale(0.5*boardScale)
		spriteStar:runAction(CCSpawn:create(array))
		return spriteStar

	end

	local function getTail(pos)
		local spriteTail = Sprite:createWithSpriteFrameName('witch_tail0000')
		local array = CCArray:create()
		array:addObject(CCSequence:createWithTwoActions(CCEaseSineOut:create(CCFadeIn:create(totalTime/2)), CCEaseSineIn:create(CCFadeOut:create(totalTime/2))))
		array:addObject(CCScaleBy:create(totalTime, 2.5*boardScale))
		array:addObject(CCMoveBy:create(totalTime, ccp(30*boardScale, 0)))
		spriteTail:setOpacity(0)
		spriteTail:setScale(0.5*boardScale)
		spriteTail:setPosition(pos)
		spriteTail:runAction(CCSpawn:create(array))
		return spriteTail
	end
	for i=1, starCount do 
		local star = getStar(getRandPos(pos))
		container:addChildAt(star, zOrder)
	end

	for i=1, tailCount do
		local tail = getTail(getRandPos(pos))
		container:addChildAt(tail, zOrder)
	end

end

function PropsView:playJamSpeardHammerAnimation(boardView, position)
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		position = boardView.gameBoardLogic:getGameItemPosInView(position.x, position.y)
	else
		local tile = boardView.baseMap[position.x][position.y]
		position = ccp(tile.pos_x, tile.pos_y)
	end

	local layer = boardView
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		layer = boardView.PlayUIDelegate.effectLayer 
	end

	local function viberate( ... )
		boardView:viberate()
	end

	local anim = PropsAnimation:createJamSpeardHammerAnim(viberate,boardView.PlayUIDelegate)
	anim:setPositionX(position.x)
	anim:setPositionY(position.y)
	layer:addChild(anim)

	anim:play()
end

function PropsView:playLineEffectAnimation(boardView, position, isColumn, posInLine)
	local r, c = position.x, position.y
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		position = boardView.gameBoardLogic:getGameItemPosInView(position.x, position.y)
	else
		local tile = boardView.baseMap[position.x][position.y]
		position = ccp(tile.pos_x, tile.pos_y)
	end

	local layer = boardView
	if boardView.PlayUIDelegate and boardView.PlayUIDelegate.effectLayer then
		layer = boardView.PlayUIDelegate.effectLayer 
	end

	local function viberate( ... )
		boardView:viberate()
	end

	local rotation = 0
	if posInLine <= 5 then
		rotation = 180
	end

	local anim = PropsAnimation:createLineEffectAnim(viberate, boardView.PlayUIDelegate, isColumn)
	anim:setPositionX(position.x)
	anim:setPositionY(position.y)
	anim:setRotation(rotation)
	layer:addChild(anim)

	anim:play()
end

