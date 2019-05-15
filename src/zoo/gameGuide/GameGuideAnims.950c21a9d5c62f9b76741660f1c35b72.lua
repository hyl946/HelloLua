

GameGuideAnims = class()

function GameGuideAnims:handclickAnim(delay, fade)
	delay = delay or 1.8
	fade = fade or 0.1
	local anim = Sprite:createEmpty()
	local hand1 = Sprite:createWithSpriteFrameName("guide_hand_up0000")
	local hand2 = Sprite:createWithSpriteFrameName("guide_hand_down0000")
	local ring = Sprite:createWithSpriteFrameName("guide_hand_ring0000")
	hand1:setAnchorPoint(ccp(1, 0))
	hand2:setAnchorPoint(ccp(1, 0))
	ring:setAnchorPoint(ccp(0.5, 0.5))
	hand1:setPosition(ccp(150, -120))
	hand2:setPosition(ccp(150, -124))
	hand1:runAction(CCMoveBy:create(0, ccp(40, -40)))
	hand1:setOpacity(0)
	hand2:setOpacity(0)
	ring:setOpacity(0)

	local function onDelayOver()
		local actions1 = CCArray:create()
		actions1:addObject(CCFadeIn:create(0))
		actions1:addObject(CCDelayTime:create(0.2))
		actions1:addObject(CCMoveBy:create(fade + 0.2, ccp(-40, 40)))
		actions1:addObject(CCRotateBy:create(0.2, 20))
		actions1:addObject(CCDelayTime:create(0.1))
		actions1:addObject(CCFadeOut:create(0))
		actions1:addObject(CCDelayTime:create(0.2))
		actions1:addObject(CCRotateBy:create(0, -20))
		actions1:addObject(CCDelayTime:create(0))
		actions1:addObject(CCFadeIn:create(0))
		actions1:addObject(CCMoveBy:create(fade + 0.2, ccp(40, -40)))
		actions1:addObject(CCDelayTime:create(1.8))
		hand1:runAction(CCRepeatForever:create(CCSequence:create(actions1)))
		local actions2 = CCArray:create()
		actions2:addObject(CCDelayTime:create(0.7 + fade))
		actions2:addObject(CCFadeIn:create(0))
		actions2:addObject(CCDelayTime:create(0.2))
		actions2:addObject(CCFadeOut:create(fade))
		actions2:addObject(CCDelayTime:create(2))
		hand2:runAction(CCRepeatForever:create(CCSequence:create(actions2)))
		local action3 = CCArray:create()
		action3:addObject(CCDelayTime:create(0.7 + fade))
		action3:addObject(CCScaleTo:create(0, 0.1))
		action3:addObject(CCFadeIn:create(0))
		action3:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2 + fade, 1.3), CCFadeOut:create(0.2 + fade)))
		action3:addObject(CCDelayTime:create(2))
		ring:runAction(CCRepeatForever:create(CCSequence:create(action3)))
	end

	anim:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(onDelayOver)))

	anim:addChild(hand1)
	anim:addChild(hand2)
	anim:addChildAt(ring, 0)
	return anim
end

function GameGuideAnims:handslideAnim(from, to, delay, fade, handStartCallback)
	delay = delay or 0.9
	fade = fade or 0.1
	local anim = Sprite:createEmpty()
	local hand1 = Sprite:createWithSpriteFrameName("guide_hand_up0000")
	local hand2 = Sprite:createWithSpriteFrameName("guide_hand_down0000")
	local ring = Sprite:createWithSpriteFrameName("guide_hand_ring0000")
	local motion_streak = Sprite:createWithSpriteFrameName('guide_motion_streak0000')
	motion_streak:setAnchorPoint(ccp(0.5, 0))
	motion_streak:setScaleY(0)
	hand1:setAnchorPoint(ccp(1, 0))
	hand2:setAnchorPoint(ccp(1, 0))
	ring:setAnchorPoint(ccp(0.5, 0.5))
	hand1:setPosition(ccp(150, -120))
	hand2:setPosition(ccp(150, -120))
	hand1:setOpacity(0)
	hand2:setOpacity(0)
	ring:setOpacity(0)

	anim:addChild(motion_streak)
	anim:addChild(hand1)
	anim:addChild(hand2)
	anim:addChildAt(ring, 0)
	anim:setPosition(ccp(from.x, from.y))


	local function getDir()
		if from.y > to.y then return 'down'
		elseif from.y < to.y then return 'up'
		elseif from.x > to.x then return 'left'
		elseif from.x < to.x then return 'right'
		end
	end

	local rotation = 0
	local dir = getDir()
	if dir == 'down' then
		rotation = 0
	elseif dir == 'up' then
		rotation = 180
	elseif dir == 'left' then
		rotation = 90
	elseif dir == 'right' then
		rotation = 270
	end
	motion_streak:setRotation(rotation)

	local function onDelayOver()
		local actions1 = CCArray:create()
		actions1:addObject(CCFadeIn:create(fade))
		actions1:addObject(CCDelayTime:create(0.2))
		actions1:addObject(CCRotateBy:create(0.1, 20))
		actions1:addObject(CCRotateBy:create(0.1, -20))
		actions1:addObject(CCFadeOut:create(0))
		actions1:addObject(CCDelayTime:create(1.0))
		actions1:addObject(CCDelayTime:create(0.2))
		actions1:addObject(CCDelayTime:create(2 + fade))
		hand1:runAction(CCRepeatForever:create(CCSequence:create(actions1)))
		local actions2 = CCArray:create()
		actions2:addObject(CCDelayTime:create(0.4 + fade))
		actions2:addObject(CCFadeIn:create(0))
		actions2:addObject(CCDelayTime:create(1.0))
		actions2:addObject(CCRotateBy:create(0.1, 20))
		actions2:addObject(CCFadeOut:create(fade))
		actions2:addObject(CCRotateBy:create(0, -20))
		actions2:addObject(CCDelayTime:create(2.1))

		hand2:runAction(CCRepeatForever:create(CCSequence:create(actions2)))
		local actions3 = CCArray:create()
		actions3:addObject(CCDelayTime:create(0.4 + fade))
		actions3:addObject(CCScaleTo:create(0, 0.1))
		actions3:addObject(CCFadeIn:create(0))
		actions3:addObject(CCScaleTo:create(0.1, 1.3))
		actions3:addObject(CCScaleTo:create(0.1, 1))
		actions3:addObject(CCDelayTime:create(0.6))
		actions3:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(fade, 1.3), CCFadeOut:create(fade)))
		actions3:addObject(CCDelayTime:create(2.4))
		ring:runAction(CCRepeatForever:create(CCSequence:create(actions3)))
		local action = CCArray:create()
		action:addObject(CCCallFunc:create(function () if handStartCallback then handStartCallback() end end))
		action:addObject(CCMoveTo:create(0, ccp(from.x, from.y)))
		action:addObject(CCDelayTime:create(0.7 + fade))
		action:addObject(CCMoveTo:create(0.5, ccp(to.x, to.y)))
		action:addObject(CCDelayTime:create(fade + 2.4))
		anim:runAction(CCRepeatForever:create(CCSequence:create(action)))

		

		local scale = 1
		if dir == 'left' or dir == 'right' then
			scale = math.abs(from.x - to.x)/50
		else
			scale = math.abs(from.y-to.y)/50
		end
		local motionAction = CCArray:create()
		motionAction:addObject(CCDelayTime:create(0.7 + fade))
		-- motionAction:addObject(CCCallFunc:create(function () motion_streak:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0)) end))
		motionAction:addObject(CCScaleTo:create(0, 1, 0))
		motionAction:addObject(CCShow:create())
		-- motionAction:addObject(CCCallFunc:create(function () 
		-- 	motion_streak:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0)) 
		-- end))
		motionAction:addObject(CCScaleTo:create(0.5, 1, scale))
		-- motionAction:addObject(CCCallFunc:create(function() motion_streak:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0)) end))
		motionAction:addObject(CCScaleTo:create(fade, 1, 0))
		motionAction:addObject(CCDelayTime:create(2.4))

		motion_streak:runAction(CCRepeatForever:create(CCSequence:create(motionAction)))
	end

	anim:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(onDelayOver)))

	return anim
end

function GameGuideAnims:handcurveSlideAnim(from, to, distance, delay)
	delay = delay or 0.9
	fade = fade or 0.1
	local anim = Sprite:createEmpty()
	local hand1 = Sprite:createWithSpriteFrameName("guide_hand_up0000")
	local hand2 = Sprite:createWithSpriteFrameName("guide_hand_down0000")
	local ring = Sprite:createWithSpriteFrameName("guide_hand_ring0000")
	hand1:setAnchorPoint(ccp(1, 0))
	hand2:setAnchorPoint(ccp(1, 0))
	ring:setAnchorPoint(ccp(0.5, 0.5))
	hand1:setPosition(ccp(150, -120))
	hand2:setPosition(ccp(150, -120))
	hand1:setOpacity(0)
	hand2:setOpacity(0)
	ring:setOpacity(0)


	anim:addChild(hand1)
	anim:addChild(hand2)
	anim:addChildAt(ring, 0)
	anim:setPosition(ccp(from.x, from.y))

	local function onDelayOver()
		local actions1 = CCArray:create()
		actions1:addObject(CCFadeIn:create(fade))
		actions1:addObject(CCDelayTime:create(0.2))
		actions1:addObject(CCRotateBy:create(0.1, 20))
		actions1:addObject(CCRotateBy:create(0.1, -20))
		actions1:addObject(CCFadeOut:create(0))
		actions1:addObject(CCDelayTime:create(3.3 + fade))
		hand1:runAction(CCRepeatForever:create(CCSequence:create(actions1)))
		local actions2 = CCArray:create()
		actions2:addObject(CCDelayTime:create(0.4 + fade))
		actions2:addObject(CCFadeIn:create(0))
		actions2:addObject(CCDelayTime:create(1.3))
		actions2:addObject(CCFadeOut:create(fade))
		actions2:addObject(CCDelayTime:create(2))
		hand2:runAction(CCRepeatForever:create(CCSequence:create(actions2)))
		local actions3 = CCArray:create()
		actions3:addObject(CCDelayTime:create(0.4 + fade))
		actions3:addObject(CCScaleTo:create(0, 0.1))
		actions3:addObject(CCFadeIn:create(0))
		actions3:addObject(CCScaleTo:create(0.1, 1.3))
		actions3:addObject(CCScaleTo:create(0.1, 1))
		actions3:addObject(CCDelayTime:create(1.1))
		actions3:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(fade, 1.3), CCFadeOut:create(fade)))
		actions3:addObject(CCDelayTime:create(2))
		ring:runAction(CCRepeatForever:create(CCSequence:create(actions3)))
		local action = CCArray:create()
		action:addObject(CCMoveTo:create(0, ccp(from.x, from.y)))
		action:addObject(CCDelayTime:create(0.7 + fade))
		local function bezier()
			anim:runAction(HeBezierTo:create(1, ccp(to.x, to.y), distance > 0, math.abs(distance)))
		end
		action:addObject(CCCallFunc:create(bezier))
		action:addObject(CCDelayTime:create(1))
		action:addObject(CCDelayTime:create(fade + 2))
		anim:runAction(CCRepeatForever:create(CCSequence:create(action)))
	end

	anim:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(onDelayOver)))

	return anim
end

function GameGuideAnims:handUsePropAnim(propPos,cellPosFrom,cellPosTo)
	local hand1 = Sprite:createWithSpriteFrameName("guide_hand_up0000")
	local hand2 = Sprite:createWithSpriteFrameName("guide_hand_down0000")

	hand1:setScale(0.5)
	hand2:setScale(0.5)
	hand1:setVisible(false)
	hand2:setVisible(false)
	hand1:setAnchorPoint(ccp(0,1))
	hand2:setAnchorPoint(ccp(0,1))

	local anim = Sprite:createEmpty()
	anim:setCascadeOpacityEnabled(true)
	anim:addChild(hand1)
	anim:addChild(hand2)

	local function t1( action )
		return CCTargetedAction:create(hand1.refCocosObj,action)
	end
	local function t2( action )
		return CCTargetedAction:create(hand2.refCocosObj,action)
	end

	local function spawn( ... )
		local actions = CCArray:create()
		for k,v in pairs({...}) do
			actions:addObject(v)
		end
		return CCSpawn:create(actions)
	end

	local function touchActions( ... )
		local actions = CCArray:create()

		actions:addObject(t2(CCHide:create()))
		actions:addObject(t1(CCShow:create()))
		actions:addObject(t1(spawn(
			CCRotateTo:create(3/24,19),
			CCMoveTo:create(3/24,ccp(9,15)),
			CCScaleTo:create(3/24,0.6)
		)))
		actions:addObject(t1(spawn(
			CCRotateTo:create(3/24,0),
			CCMoveTo:create(3/24,ccp(0,0)),
			CCScaleTo:create(3/24,0.5)
		)))
		actions:addObject(t1(CCHide:create()))
		actions:addObject(t2(CCShow:create()))

		return CCSequence:create(actions)
	end

	local function cellMoveActions( ... )
		local actions = CCArray:create()

		actions:addObject(touchActions())
		actions:addObject(CCDelayTime:create(1/24))
		actions:addObject(CCMoveTo:create(5/24,cellPosTo))
		actions:addObject(CCDelayTime:create(6/24))
		actions:addObject(CCFadeOut:create(9/24))

		return CCSequence:create(actions)
	end

	local function runClickSlide( ... )
		local actions = CCArray:create()

		actions:addObject(t2(CCHide:create()))
		actions:addObject(t1(CCHide:create()))	
		actions:addObject(CCDelayTime:create(1))

		actions:addObject(CCPlace:create(propPos))
		actions:addObject(CCFadeIn:create(0))

		actions:addObject(t2(CCHide:create()))
		actions:addObject(t1(CCShow:create()))	

		actions:addObject(t1(CCPlace:create(ccp(80,-5))))
		actions:addObject(t1(CCShow:create()))
		actions:addObject(t1(CCMoveTo:create(7/24,ccp(0,0))))

		actions:addObject(touchActions())
		actions:addObject(CCDelayTime:create(7/24))

		actions:addObject(CCMoveTo:create(18/24,cellPosFrom))

		actions:addObject(cellMoveActions())

		anim:stopAllActions()
		anim:runAction(CCRepeatForever:create(
			CCSequence:create(actions)
		))
	end

	local function runOnlySlide( ... )
		local actions = CCArray:create()

		actions:addObject(t2(CCHide:create()))
		actions:addObject(t1(CCHide:create()))
		actions:addObject(CCDelayTime:create(1))

		actions:addObject(CCPlace:create(cellPosFrom))
		actions:addObject(CCFadeIn:create(0))

		actions:addObject(cellMoveActions())
		anim:stopAllActions()
		
		anim:runAction(CCRepeatForever:create(
			CCSequence:create(actions)
		))
	end

	runClickSlide()

	function anim:runOnlySlide( ... )
		runOnlySlide()
	end

	return anim
end