SunflowerState = class(BaseStableState)

function SunflowerState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function SunflowerState:create(context)
	local v = SunflowerState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function SunflowerState:check()
    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kSunflower]] then
        return 0
    end

	local needBlastFlower = false
	if self.mainLogic.sunflowersAppetite and self.mainLogic.sunflowersAppetite > 0 and self.mainLogic.sunflowerEnergy then
		if self.mainLogic.sunflowerEnergy >= self.mainLogic.sunflowersAppetite then
			needBlastFlower = true
		end
	end

	if needBlastFlower then
		return self:_checkBlastSunflower()
	else
		return 0
	end
end

function SunflowerState:_checkBlastSunflower()
	local sunflower = SunflowerLogic:getActiveSunflower(self.mainLogic)
	if sunflower then
		self:_playSunflowerFlyAnimation(sunflower)
		return 1
	else
		return 0
	end
end

function SunflowerState:_playSunflowerFlyAnimation(sunflower)
    local scene = Director:sharedDirector():getRunningScene()

    local startPos = self.mainLogic.boardView.gameBoardLogic:getGameItemPosInView(sunflower.y, sunflower.x)
    local endPos = self.mainLogic.boardView.gameBoardLogic:getGameItemPosInView(5, 5)

    local animation = Sprite:createWithSpriteFrameName("blocker_sunflower_idle_0000")
    animation:setPosition(startPos)

    local function onfinish()
		if animation then animation:removeFromParentAndCleanup(true) end
		self:_playSunflowerBlastAnimation(sunflower)
		-- if finishCallback then finishCallback() end
    end

    -- 移动末尾的缓动效果
    local midPointPercent = 0.8
    local midTimePercent = 0.3
    local midPoint = ccp(startPos.x + (endPos.x - startPos.x) * midPointPercent, 
        startPos.y + (endPos.y - startPos.y) * midPointPercent)

	local flyAniDuration = 0.3
    local actArr = CCArray:create()
    -- actArr:addObject(CCMoveTo:create(flyAniDuration, ccp(endPos.x, endPos.y)))
    actArr:addObject(CCMoveTo:create(flyAniDuration * midTimePercent, ccp(midPoint.x , midPoint.y)))
    actArr:addObject(CCMoveTo:create(flyAniDuration * (1 - midTimePercent), ccp(endPos.x , endPos.y)))
    actArr:addObject(CCCallFunc:create(onfinish) )
    animation:runAction(CCSequence:create(actArr))

    scene:addChild(animation)

	local sunflowerView = self.mainLogic.boardView.baseMap[sunflower.y][sunflower.x]
	if sunflowerView then sunflowerView:removeSunflowerView() end
end

function SunflowerState:_playSunflowerBlastAnimation(sunflower)
    local scene = Director:sharedDirector():getRunningScene()

    local container = Layer:create()
    container:setTouchEnabled(true, 0, true)
    scene:addChild(container)
    
    local anim = gAnimatedObject:createWithFilename('gaf/sunflowerBlocker/sunflowerBlast.gaf')
    local middlePos = self.mainLogic.boardView.gameBoardLogic:getGameItemPosInView(5, 5)
    local animPos = ccp(middlePos.x - 362, middlePos.y + 572)
    anim:setPosition(animPos)

    local function finishCallback( ... )
        if container then
            container:removeFromParentAndCleanup(true)
            container = nil
        end
    end

    local function onStartPeriodFinished()
        anim:setSequenceDelegate('blast', finishCallback)
        anim:playSequence("blast", false, true, ASSH_RESTART)
        anim:start()

        self:_blastSunflower(sunflower)
    end

    anim:setSequenceDelegate('start', onStartPeriodFinished, true)
    anim:playSequence("start", false, true, ASSH_RESTART)
    anim:start()

    container:addChild(anim)
end

function SunflowerState:_blastSunflower(sunflower)
	local function onSunflowerBlastEnd()
		self:_onBlastEnded()
	end

	local action = GameBoardActionDataSet:createAs(
        GameActionTargetType.kGameItemAction,
        GameItemActionType.kItem_SunFlower_Blast, 
        IntCoord:create(sunflower.x, sunflower.y),
        nil,
        GamePlayConfig_MaxAction_time
        )
	action.targetFlower = sunflower
    action.completeCallback = onSunflowerBlastEnd
    self.mainLogic:addDestroyAction(action)
	self.mainLogic:setNeedCheckFalling()
end

function SunflowerState:_onBlastEnded()
	self.mainLogic.sunflowersAppetite = -1

	FallingItemLogic:preUpdateHelpMap(self.mainLogic)
	self.mainLogic:setNeedCheckFalling()
end
