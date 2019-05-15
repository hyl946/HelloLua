

NationalDayAnimation = {}

function NationalDayAnimation:getActivityIcon( ... )
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == "Guoqing2016/Config.lua" then
			return v
		end
	end
end

function NationalDayAnimation:createMoveAnim( ... )
	local activityIcon = self:getActivityIcon()
	if not activityIcon then
		return
	end
	local iconAnim = Sprite:createWithSpriteFrame(activityIcon.icon:displayFrame())--:buildIcon()

	local anim = CocosObject:create()

	local arrowAnim = ArmatureNode:create("nationalDayWinAnimation/arrow")
	
	iconAnim:setAnchorPoint(ccp(0.5,0.5))

	function iconAnim:playShowAnim( ... )
		self:setScaleX(0)
		self:setScaleY(0)

		self:runAction(CCScaleTo:create(0.1,self.scaleX,self.scaleY))
	end

	function iconAnim:playHideAnim( ... )
		local actions = CCArray:create()

		actions:addObject(CCScaleTo:create(0.1,self.scaleX * 1.2,self.scaleY * 1.2))
		actions:addObject(CCScaleTo:create(0.2,0,0))

		self:runAction(CCSequence:create(actions))
	end


	anim:addChild(iconAnim)
	anim:addChild(arrowAnim)

	anim:setVisible(false)
	function anim:play( callback )
		if activityIcon.isDisposed then
			if callback then
				callback()
			end
			return
		end
		self:setVisible(true)

		local bounds = activityIcon:getGroupBounds()
		local localPos = self:convertToNodeSpace(ccp(bounds:getMidX(),bounds:getMidY()))
		iconAnim:setPosition(localPos)

		local iconBounds =  iconAnim:getGroupBounds()
		iconAnim:setScaleX(bounds.size.width/iconBounds.size.width)
		iconAnim:setScaleY(bounds.size.height/iconBounds.size.height)
		
		iconAnim.scaleX = iconAnim:getScaleX()
		iconAnim.scaleY = iconAnim:getScaleY()
		iconAnim:playShowAnim()

		arrowAnim:setRotation(math.deg(math.atan2(-localPos.y,localPos.x))+90)

		local t = 10/24

		local actions = CCArray:create()
		actions:addObject(CCMoveTo:create(t,localPos))
		actions:addObject(CCCallFunc:create(function( ... )
			iconAnim:playHideAnim()
			if callback then
				callback()
			end
		end))
		arrowAnim:runAction(CCSequence:create(actions))

		local actions = CCArray:create()
		actions:addObject(CCScaleTo:create(t/2,2,1))
		actions:addObject(CCScaleTo:create(t/2,2,0))
		arrowAnim:setScaleY(0)
		arrowAnim:setScaleX(2)
		arrowAnim:runAction(CCSequence:create(actions))

		local actions = CCArray:create()
		actions:addObject(CCFadeTo:create(t,255 * 0.3))
		arrowAnim:runAction(CCSequence:create(actions))

	end

	return anim
end

function NationalDayAnimation:playSuccessAnim( successTopPanel,happyAnimalBgLayer )
	local anim = CocosObject:create()

	local chicken = ArmatureNode:create("nationalDayWinAnimation/chicken")
	chicken:setPositionX(-196.5)
	chicken:setPositionY(-10.65)
	chicken:playByIndex(0,0)
	anim:addChild(chicken)

	local huanxiong_anime = ArmatureNode:create("nationalDayWinAnimation/huanxiong_anime")
	huanxiong_anime:setPositionX(253.35)
	huanxiong_anime:setPositionY(-10.65)
	huanxiong_anime:playByIndex(0,0)
	anim:addChild(huanxiong_anime)

	for k,v in pairs({chicken,huanxiong_anime}) do
		v:setPositionY(v:getPositionY() - 200)
		v:runAction(CCMoveBy:create(0.3,ccp(0,200)))
	end

	local icon = nil
	if NationalDayManager:hasGetProp() then
		icon = ArmatureNode:create("nationalDayWinAnimation/card")
	elseif NationalDayManager:hasGetDice() then
		icon = ArmatureNode:create("nationalDayWinAnimation/dice")
	end

	if icon then
		icon:setPositionX(0)
		icon:setPositionY(60)
		anim:addChild(icon)

		local moveAnim = self:createMoveAnim()
		if moveAnim then
			moveAnim:setPositionX(icon:getPositionX() + happyAnimalBgLayer:getPositionX())
			moveAnim:setPositionY(icon:getPositionY() + happyAnimalBgLayer:getPositionY())
			successTopPanel.ui:addChild(moveAnim)
		end

		icon:setScaleX(0)
		icon:setScaleY(0)
		local actions = CCArray:create()
		actions:addObject(CCDelayTime:create(1.5))
		actions:addObject(CCScaleTo:create(0.2,1.1,1.1))
		actions:addObject(CCScaleTo:create(0.1,1.0,1.0))
		actions:addObject(CCDelayTime:create(0.5))
		actions:addObject(CCCallFunc:create(function( ... )
			if moveAnim then
				moveAnim:play()
			end
		end))
		-- actions:addObject(CCScaleTo:create(0.1,0.0,0.0))
		icon:runAction(CCSequence:create(actions))
	end

	happyAnimalBgLayer:addChild(anim)

	NationalDayManager:clear()
	return anim
end

function NationalDayAnimation:playFailAnim( failTopPanel )
	local anim = ArmatureNode:create("nationalDayWinAnimation/failAnim")
	anim:setPositionX(20)
	anim:setPositionY(-70)
	anim:playByIndex(0)

	local _bg = failTopPanel.bg:getChildByName("_bg")
	_bg:addChildAt(anim,2)

	local moveAnim = self:createMoveAnim()
	if moveAnim then
		moveAnim:setPositionX(360)
		moveAnim:setPositionY(-200)
		failTopPanel.ui:addChild(moveAnim)
	end

	anim:addEventListener(ArmatureEvents.BONE_FRAME_EVENT,function( ... )
		if moveAnim then
			moveAnim:play()
		end
	end)

	NationalDayManager:clear()
	return anim
end

function NationalDayAnimation:playWeeklyAnim( weeklyPanel, onFinishCallback )
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	local container = Layer:create()

	local anim = ArmatureNode:create("nationalDayWinAnimation/weekly")
	anim:playByIndex(0)
	anim:setPositionX(visibleSize.width/2)
	anim:setPositionY(-visibleSize.height/2)
	container:addChild(anim)

	local moveAnim = self:createMoveAnim()
	if moveAnim then
		moveAnim:setPositionX(visibleSize.width/2)
		moveAnim:setPositionY(-visibleSize.height/2)
		container:addChild(moveAnim)
	end

	anim:addEventListener(ArmatureEvents.COMPLETE,function( ... )
		if not anim:isVisible() then
			return
		end

		anim:setVisible(false)

		if moveAnim then
			moveAnim:play(function( ... )
				PopoutManager:remove(container)
				if type(onFinishCallback) == "function" then onFinishCallback() end
			end)
		else
			PopoutManager:remove(container)
			if type(onFinishCallback) == "function" then onFinishCallback() end
		end
	end)

	PopoutManager:add(container,true,false)

	container:setTouchEnabled(true)
	function container:hitTestPoint(worldPosition, useGroupTest)
		return true
	end
	container:addEventListener(DisplayEvents.kTouchTap,function( ... )
		if not anim:isVisible() then
			return
		end

		anim:setVisible(false)

		if moveAnim then
			moveAnim:play(function( ... )
				PopoutManager:remove(container)
			end)
		else
			PopoutManager:remove(container)
		end
	end)

	NationalDayManager:clear()
	return container
end