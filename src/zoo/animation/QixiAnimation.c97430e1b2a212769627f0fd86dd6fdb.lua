QixiAnimation = class()

QixiBossAnimationEnum = 
{
	kHippoWalk = "hippo_walk",
	kFoxWalk   = "fox_walk",
	kHippoWait = "hippo_wait",
	kFoxWait   = "fox_wait",
	kHippoHit  = "hippo_hit",
	kFoxHit    = "fox_hit",
	kFoxCast   = "fox_cast",
	kBossMeeting = "boss_meeting"
}

QixiBossEnum =
{
	kHippo = "hippo",
	kFox   = "fox",
}

QixiBossState = 
{
	kWalk = "walk",
	kWait = "wait",
	kHit  = "hit",
	kCast = "cast",
}

QixiBossAnimationConfig = {
	[QixiBossAnimationEnum.kHippoWalk] = { scaleX = -0.7, scaleY = 0.7},
	[QixiBossAnimationEnum.kFoxWalk]   = { scaleX =  0.53, scaleY = 0.53},
	[QixiBossAnimationEnum.kHippoWait] = { scaleX = -0.7, scaleY = 0.7},
	[QixiBossAnimationEnum.kFoxWait]   = { scaleX = 0.53, scaleY = 0.53},
	[QixiBossAnimationEnum.kHippoHit]  = { scaleX = -0.7, scaleY = 0.7},
	[QixiBossAnimationEnum.kFoxHit]    = { scaleX = 0.53, scaleY = 0.53},
	[QixiBossAnimationEnum.kFoxCast]   = { scaleX = 0.53, scaleY = 0.53},
	[QixiBossAnimationEnum.kBossMeeting]   = { scaleX = 0.7,    scaleY = 0.7},
}

local _instance = nil

function QixiAnimation:getInstance()
	if not _instance then
		_instance = QixiAnimation.new()
	end

	return _instance
end

local function getRealPlistPath(path)
	local plistPath = path
	if __use_small_res then  
		plistPath = table.concat(plistPath:split("."),"@2x.")
	end

	return plistPath
end

function QixiAnimation:init()
	FrameLoader:loadArmature( "skeleton/qixi_boss_animation")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/dig_block.plist"))
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/qixi_boss.plist"))
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/common/properties.plist"))
	self.initialized = true
end

function QixiAnimation:dispose()
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/qixi_boss_animation/texture.png"))
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("flash/dig_block.plist"))
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("flash/qixi_boss.plist"))
	self.initialized = false
end

function QixiAnimation:createStarShinningAnimation()
	if not self.initialized then
		self:init()
	end

	local container = Layer:create()
	local star = Sprite:createWithSpriteFrameName("star_shinning_0000")
	container:changeWidthAndHeight(star:getContentSize().width, star:getContentSize().height)
	container:setAnchorPoint(ccp(0.5, 0.5))
	container:addChild(star)
	star:setPositionX(-30)
	local star_shinning_frames = SpriteUtil:buildFrames("star_shinning_%04d", 0, 18)
	local star_shinning_animate = SpriteUtil:buildAnimate(star_shinning_frames, 1/30)
	star:play(star_shinning_animate, 0, 0, nil, false)

	return container
end

function QixiAnimation:createAnimation(name)
	if not self.initialized then
		self:init()
	end

	local node = ArmatureNode:create(name)
	assert(node, "invalid animation name: "..tostring(name))
	node:playByIndex(0)

	node:setScaleX(QixiBossAnimationConfig[name].scaleX)
	node:setScaleY(QixiBossAnimationConfig[name].scaleY)
	return node
end

local function createFollowStarParticle()
	local node = CocosObject:create()

	local heart = ParticleSystemQuad:create("particle/heart.plist")
	heart:setAutoRemoveOnFinish(true)
	heart:setPosition(ccp(0, 0))

	node:addChild(heart)

	local starLine = ParticleSystemQuad:create("particle/flowstar.plist")
	starLine:setAutoRemoveOnFinish(true)
	starLine:setPosition(ccp(0, -35))
	node:addChild(starLine)

	if __use_small_res then
		heart:setTotalParticles(math.floor(heart:getTotalParticles()/3))
		starLine:setTotalParticles(math.floor(starLine:getTotalParticles()/3))
	end
	
	return node
end

function QixiAnimation:createExplodeAnimation(targetPos, completeCallback)
	local scene = Director:sharedDirector():getRunningScene()
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/qixi_explode_ui.json")
	local star_animation = builder:buildGroup("star_animation")
	star_animation:setPosition(targetPos)

	local star_in = star_animation:getChildByName("star_in")
	star_in:setAnchorPoint(ccp(0.5, 0.5))
	star_in:setVisible(false)

	local star_out = star_animation:getChildByName("star_out")
	star_out:setAnchorPoint(ccp(0.5, 0.5))
	star_out:setVisible(false)

	local star_init = star_animation:getChildByName("star_init")
	star_init:setAnchorPoint(ccp(0.5, 0.5))
	star_init:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(5/30, 3.42),
		CCCallFunc:create(function()
				star_init:setVisible(false)
				star_in:setVisible(true)
				star_out:setVisible(true)
				
				star_in:runAction(CCScaleTo:create(9/30, 0.72))
				star_in:getChildByName("star"):runAction(CCFadeOut:create(9/30))

				local actions = CCArray:create()
				actions:addObject(CCDelayTime:create(5/30))
				actions:addObject(CCFadeOut:create(13/30))
				actions:addObject(CCCallFunc:create(function() 
						if completeCallback then
							completeCallback()
						end
					end))

				star_out:runAction(CCScaleTo:create(18/30, 1.5))
				star_out:getChildByName("star"):runAction(
					CCSequence:create(actions))
			end)))

	scene:addChild(star_animation)

	return star_animation
end

function QixiAnimation:playFollowStarAnimation(startPos, endPos, duration, completeCallback , parameters)
	local sf = createFollowStarParticle()
	local scene = Director:sharedDirector():getRunningScene()
	sf:setPosition(start)
	scene:addChild(sf)

	local offsetx = math.random() < 0.5  and -100 or 100
	local controlPoint = ccp(startPos.x + (endPos.x - startPos.x)*2/3 + offsetx, startPos.y + (endPos.y - startPos.y)*2/3)
	local points = CCPointArray:create(3)
	points:addControlPoint(startPos)
	points:addControlPoint(controlPoint)
	points:addControlPoint(endPos)

	duration = duration or 0.8
	local move_action =CCEaseSineOut:create(CCCardinalSplineTo:create(duration, points, 0))
	
	local actions = CCArray:create()

	actions:addObject(move_action)
	--actions:addObject(CCDelayTime:create(0.2))
	actions:addObject(CCCallFunc:create(
			function() 
				if completeCallback then
					completeCallback(parameters)
				end

				sf:removeFromParentAndCleanup(true)
			end))

	sf:runAction(CCSequence:create(actions))
end

function QixiAnimation:createGalaxyBackgruond()
	if not self.initialized then
		self:init()
	end

	local container = Sprite:createEmpty()

	local bg = Sprite:createWithSpriteFrameName("gland")
	local width = bg:getContentSize().width
	local height = bg:getContentSize().height
	bg:setPositionXY(width/2, height/2)
	bg.name = "background"
	container:addChild(bg)

	local node = ClippingNode:create(CCRectMake(0,0,210,140))
	local starLine = ParticleSystemQuad:create("particle/star.plist")
	starLine:setAutoRemoveOnFinish(true)
	starLine:setPosition(ccp(210/2, 140/2))
	if __use_small_res then
		starLine:setTotalParticles(math.floor(starLine:getTotalParticles()/3))
	end
	node:addChild(starLine)

	node:setPositionXY(0, 8)
	container:addChild(node)

	container.hide = function(hideCompleteCallback)
		bg:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(1), 
				CCCallFunc:create(function() 
						if hideCompleteCallback then
							hideCompleteCallback()
						end
					end)
			 ))
		if not starLine.isDisposed then
			starLine:setDuration(0.5)
		end
	end

	--container:setScale()
	return container
end

local function heartPosition(rad)
    local x = 16 * math.pow(math.sin(rad), 3)
    local y = (15 * math.cos(rad) - 5 * math.cos(2 * rad) - 2 * math.cos(3 * rad) - math.cos(4 * rad))

    return x, y
end

local Radius = 20

local function getHeartCurvePointsLeft()
	local points = {}
	for rad = 2*math.pi, 5*math.pi/4, -0.1 do
		local x, y = heartPosition(rad)
		table.insert(points, ccp(Radius*x, Radius*y))

		--if _G.isLocalDevelopMode then printx(0, "("..x..", "..y..")") end
	end

	return points
end

local function getHeartCurvePointsRight()
	local points = {}
	for rad = 0, 3*math.pi/4, 0.1 do
		local x, y = heartPosition(rad)
		table.insert(points, ccp(Radius*x, Radius*y))

		--if _G.isLocalDevelopMode then printx(0, "("..x..", "..y..")") end
	end

	return points
end

local function createAdd5StepProp()
	local add5step_prop = Sprite:createWithSpriteFrameName("add5step_prop0000")

	local add5step_prop_frames = SpriteUtil:buildFrames("add5step_prop%04d", 0, 15)
	local add5step_prop_animate = SpriteUtil:buildAnimate(add5step_prop_frames, 1/30)
	add5step_prop:play(add5step_prop_animate, 0, 0, nil, false)

	return add5step_prop
end

local function createAdd5StepFly()

	local container = Layer:create()
	local add5step_fly = Sprite:createWithSpriteFrameName("add5step_fly0000")
	container:changeWidthAndHeight(add5step_fly:getContentSize().width, add5step_fly:getContentSize().height)
	container:addChild(add5step_fly)
	container:setAnchorPoint(ccp(0, 0))

	local add5step_fly_frames = SpriteUtil:buildFrames("add5step_fly%04d", 0, 15)
	local add5step_fly_animate = SpriteUtil:buildAnimate(add5step_fly_frames, 1/30)
	add5step_fly:play(add5step_fly_animate, 0, 0, nil, false)

	return container
end

function QixiAnimation:playBossMeetingAnimation(diamondCount, diamondTargetPos, propCount, propTargetPos, completeCallback)

	if not self.initialized then
		self:init()
	end

	local winSize = Director:sharedDirector():getVisibleSize()
	local origin = Director:sharedDirector():getVisibleOrigin()
	local scene = Director:sharedDirector():getRunningScene()
	local container = Layer:create()
    container:setTouchEnabled(true, 0, true)
    container:setPositionXY(origin.x, origin.y)
	scene:addChild(container)

    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height))
    greyCover:setPosition(ccp(0, 0))
    container:addChild(greyCover)

    diamondTargetPos = diamondTargetPos or ccp(winSize.width/2, winSize.height)
    diamondCount = diamondCount or 20
    propCount = propCount or 1
    propTargetPos = propTargetPos or ccp(0, 0)

    local diamonds = {}



    --local propIndex = math.random(1, diamondCount)
    for i=1, diamondCount do
    	local diamond = Sprite:createWithSpriteFrameName("dig_jewel_qixi_0000")
    	diamond.name = "diamond"
		diamond:setPositionXY(winSize.width/2, winSize.height/2 + 50)
		diamond:setScale(1)
		diamond:setVisible(false)
		container:addChild(diamond)
		table.insert(diamonds, diamond)
    end

	local boss_meeting = QixiAnimation:getInstance():createAnimation(QixiBossAnimationEnum.kBossMeeting)
	local size = boss_meeting:getGroupBounds().size
	if _G.isLocalDevelopMode then printx(0, "boss_meeting size: ", size.width, size.height) end

	local targetRect = CCRectMake(winSize.width/2 - 100, winSize.height/2 - size.height, 200, 100)
	local targetPoints = {}

	local function isValidPoint(point, minDistance)
		if not targetPoints or #targetPoints ==0 then
			return true
		end

		for i,v in ipairs(targetPoints) do
			local diffPoint = ccp(point.x - v.x, point.y - v.y)
			if math.pow(diffPoint.x , 2) + math.pow(diffPoint.y, 2) > minDistance*minDistance then
				return false
			end 
		end

		return true
	end

	local function randomTargetPoint()
		local point = ccp(targetRect.origin.x + math.random(0, 200), targetRect.origin.y + math.random(0, 100))
		local count = 0

		while count < 5 and not isValidPoint(point, 10) do
	
			count = count + 1
			point = ccp(targetRect.origin.x + math.random(0, 200), targetRect.origin.y + math.random(0, 100))
		end

		table.insert(targetPoints, point)
		return point
	end

    local function addTimeProp(callback)
	 	local propAddFiveStep = createAdd5StepProp()
	 	propAddFiveStep.name = "prop"

	 	local targetPos = randomTargetPoint()
	 	propAddFiveStep:setPositionXY(targetPos.x, targetPos.y)
	 	propAddFiveStep:setScale(1)
	 	propAddFiveStep:setVisible(true)
	 	container:addChild(propAddFiveStep)

	 	local points = CCPointArray:create(4)
	 	--points:addControlPoint(ccp(targetPos.x - 100, targetPos.y + 200))
	 	--points:addControlPoint(ccp(targetPos.x - 50, targetPos.y + 200))
	 	points:addControlPoint(ccp(targetPos.x , targetPos.y + 100))
	 	--points:addControlPoint(ccp(targetPos.x , targetPos.y + 50))
	 	points:addControlPoint(ccp(targetPos.x, targetPos.y))
	 	local move_action = CCEaseBounceOut:create(CCEaseSineIn:create(CCCardinalSplineTo:create(1, points, 0)))
	 	local complete = CCCallFunc:create(function() if callback then callback() end end)
	 	propAddFiveStep:runAction(CCSequence:createWithTwoActions(move_action, complete))

	 	table.insert(diamonds, propAddFiveStep)

	 	return propAddFiveStep
    end

	local flyCompleteCount = 0
	local function flyProp(prop, index)
		local targetPos = propTargetPos

		local actions = CCArray:create()
		actions:addObject(CCDelayTime:create((index-1) * 0.1))
		actions:addObject(CCCallFunc:create(function()
					local fly = createAdd5StepFly()
					fly:setPositionXY(prop:getPositionX(), prop:getPositionY())

					local rad =  math.atan2(targetPos.y- fly:getPositionY(), targetPos.x - fly:getPositionX())
					local endRotation = 90 - rad*180 / math.pi

					fly:setRotation(endRotation)
					container:addChild(fly)

					local move_action = CCMoveTo:create(0.4, targetPos)
					local complete = CCCallFunc:create(function()
								if completeCallback then
									completeCallback(true)
								end

								flyCompleteCount = flyCompleteCount + 1
								if flyCompleteCount == #diamonds then
									container:removeFromParentAndCleanup(true)	
								end
								fly:removeFromParentAndCleanup(true)
						end)
					fly:runAction(CCSequence:createWithTwoActions(move_action, complete))
					prop:removeFromParentAndCleanup(true)
			end))
		prop:runAction(CCSequence:create(actions))
	end

	local function onComplete()
		local function onAllDropComplete()
			for i,v in ipairs(diamonds) do
				local actions = CCArray:create()
				local targetPos = v.name == "diamond" and diamondTargetPos or propTargetPos

				if v.name == "prop" then
					flyProp(v, i)
				else
					local move_action = CCMoveTo:create(0.3, targetPos)
					actions:addObject(CCDelayTime:create((i-1) * 0.1))
					actions:addObject(move_action)

					actions:addObject(CCCallFunc:create(function() 
							if completeCallback then
								completeCallback(false)
							end
							flyCompleteCount = flyCompleteCount + 1
							if flyCompleteCount == #diamonds then
								container:removeFromParentAndCleanup(true)
							end
							v:removeFromParentAndCleanup(true)
						end))

					v:runAction(CCSequence:create(actions))
				end
			end
			if _G.isLocalDevelopMode then printx(0, "allDiamond drop completed!!!!!!!!!") end
			--container:removeFromParentAndCleanup(true)
		end
		local leftPoints  = getHeartCurvePointsLeft()
		local rightPoints = getHeartCurvePointsRight()
		for i=1, #diamonds do
			local diamond = diamonds[i]

			local unitOffsetX = winSize.width/3
			local points = CCPointArray:create(4)

			if i%2==0 then
				for _,v in ipairs(leftPoints) do
					points:addControlPoint(ccp(winSize.width/2 + v.x , winSize.height/2 + v.y))
				end
			else
				for _,v in ipairs(rightPoints) do
					points:addControlPoint(ccp(winSize.width/2 + v.x , winSize.height/2 + v.y))
				end	
			end

			local target = randomTargetPoint()
			points:addControlPoint(ccp(target.x, target.y))

			local actions = CCArray:create()
			actions:addObject(CCDelayTime:create(math.floor(i/2)*0.1))
			actions:addObject(CCCallFunc:create(function() diamond:setVisible(true) end))
			actions:addObject(CCEaseSineOut:create(CCCardinalSplineTo:create(1.5, points, 0)))
			if i == 1 then
				if propCount >= 1 then
					actions:addObject(CCCallFunc:create(function() 
							addTimeProp(nil)
						end))
				end
			end
			if i == diamondCount then
				actions:addObject(CCCallFunc:create(onAllDropComplete))
			end
			diamond:runAction(CCSequence:create(actions))
		end
	end

	local function playBossKissEffect()
		if boss_meeting and not boss_meeting.isDisposed then
			GamePlayMusicPlayer:playEffect(GameMusicType.kQiXiBoss)
		end
	end

	boss_meeting:setPositionXY(winSize.width/2, winSize.height/2 + size.height/2)
	container:addChild(boss_meeting)
	setTimeOut(onComplete, 0.6)
	setTimeOut(playBossKissEffect, 0.8)
end

----
----  qixi_boss implementation
----

QixiBoss = class(Layer)

--static create function
function QixiBoss:create()
  local layer = QixiBoss.new()
  layer:initLayer()
  return layer
end

function QixiBoss:build(name, state, stateCompleteCallback)
	local boss = QixiBoss:create()
	local bossState = state or QixiBossState.kWait
	boss:init(name, bossState, stateCompleteCallback)
	boss:playWait()

	return boss
end

function QixiBoss:dispose()
	Layer.dispose(self)

	self:clearTimeOut()
end

function QixiBoss:setStateCompleteCallback(callback)
	self.animation:removeAllEventListeners()
	self.stateCompleteCallback = callback

	local function animationCallback()
		if not self.isDisposed and self.stateCompleteCallback then
			self.stateCompleteCallback(self.state)
		end
	end

	self.animation:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
end

function QixiBoss:initAnimation(name, state, stateCompleteCallback)
	self.animation = QixiAnimation:getInstance():createAnimation(name.."_"..state)
	self:changeWidthAndHeight(self.animation:getGroupBounds().size.width, self.animation:getGroupBounds().size.height)
	self:addChild(self.animation)
	self:setAnchorPoint(ccp(0.5, 0.5))
	if name == QixiBossEnum.kFox then
		self.animation:setPositionX(self.animation:getPositionX() - 145)
	elseif name == QixiBossEnum.kHippo then
		self.animation:setPositionX(self.animation:getPositionX() - 25)
	end

	self:setStateCompleteCallback(stateCompleteCallback)
end

function QixiBoss:init(name, state, stateCompleteCallback)
	self.name = name
	self.state = state

	self:initAnimation(name, state, stateCompleteCallback)
end

function QixiBoss:setState(state, stateCompleteCallback)
	if self.state~= state then
		self.state = state
		if self.animation then
			self.animation:removeAllEventListeners()
			self.animation:removeFromParentAndCleanup(true)
		end

		self:init(self.name, state, stateCompleteCallback)
	else
		self:play()
	end
end

function QixiBoss:playWalkWithoutChangeState()
	if self.animation then
		self.animation:removeAllEventListeners()
		self.animation:removeFromParentAndCleanup(true)
	end

	self:initAnimation(self.name, QixiBossState.kWalk, nil)
end

function QixiBoss:playWaitWithoutChangeState(completeCallback)
	if self.animation then
		self.animation:removeAllEventListeners()
		self.animation:removeFromParentAndCleanup(true)
	end

	self:initAnimation(self.name, QixiBossState.kWait, completeCallback)
end

function QixiBoss:playWait()
	if _G.isLocalDevelopMode then printx(0, "play wait called-----------------------------------") end
	self:stopAllActions()
	self.cachedActions = {}
	self:clearTimeOut()

	self.state = QixiBossState.kWait

	local function doWait()
		if self.isDisposed then
			return
		end
		if _G.isLocalDevelopMode then printx(0, "dowait called!!!!!!!!!!!!!!") end
		self:playWalkWithoutChangeState()

		self.waitTimeOutID = setTimeOut(
				function()
					self:playWaitWithoutChangeState(function() 
						doWait()
					end)
				end, 10)
	end

	doWait()
	--self.waitTimeOutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(doWait, 10, false)
end

function QixiBoss:clearTimeOut()
	if self.waitTimeOutID then
		  CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.waitTimeOutID)
		  self.waitTimeOutID = nil
	end
end

function QixiBoss:playCast(completeCallback)
	if _G.isLocalDevelopMode then printx(0, "play cast called-----------------------------------") end
	if self.state == QixiBossState.kWalk or self.state == QixiBossState.kHit then
		local totalDistance = 0
		local moveCompleteCallback = nil
		for _,v in ipairs(self.cachedActions) do
			totalDistance = totalDistance + v.distance
			if not moveCompleteCallback then
				moveCompleteCallback = v.completeCallback
			end
		end

		self:setPositionX(self:getPositionX() + totalDistance)
		if moveCompleteCallback then
			moveCompleteCallback()
		end

		if _G.isLocalDevelopMode then printx(0, "boss walk interrupted: walk the rest distance: "..tostring(totalDistance)) end
	end
	self:stopAllActions()
	self.cachedActions = {}

	--clear the wait state before cast.
	self:clearTimeOut()

	self:setState(QixiBossState.kCast, completeCallback)
end

function QixiBoss:playHit(distance, duration, completeCallback)
	--self:stopAllActions()
	self:clearTimeOut()

	if _G.isLocalDevelopMode then printx(0, "distance: "..tostring(distance)..",duration: "..tostring(duration)) end
	if not self.cachedActions then
		self.cachedActions = {}
	end

	table.insert(self.cachedActions, {distance = distance, duration = duration, callback = completeCallback})

	local function playWalkAction()
		if not self.cachedActions or #self.cachedActions == 0 then
			return
		end

		local actionData = self.cachedActions[1]
		

		local action1 = CCMoveBy:create(actionData.duration, ccp(actionData.distance, 0))
		local action2 = CCCallFunc:create(function()  
				--execute the current action completeCallback
				if actionData.callback then
					actionData.callback()
				end
				if _G.isLocalDevelopMode then printx(0, "walk action completed, distance: "..tostring(actionData.distance).." ,duration: "..tostring(actionData.duration)) end

				--remove the first action
				table.remove(self.cachedActions, 1)

				--execute the next action in the list, if there is one.
				if #self.cachedActions > 0 then
					playWalkAction()
				else
					self:playWait()
					if _G.isLocalDevelopMode then printx(0, "===========walk all COMPLETE==================================== ") end
				end
			end)
		self:runAction(CCSequence:createWithTwoActions(action1, action2))
	end

	if self.state ~= QixiBossState.kHit and self.state ~= QixiBossState.kWalk then
		if self.state == QixiBossState.kCast then --if it is in the casting state, finished the cast first.
			if self.stateCompleteCallback then
				self.stateCompleteCallback()
			end
			if _G.isLocalDevelopMode then printx(0, "boss casting interrupted================= callback: "..tostring(self.stateCompleteCallback)) end
		end

		self:setState(QixiBossState.kHit)
		self:setStateCompleteCallback(function() 
			self:setState(QixiBossState.kWalk)
			playWalkAction()
		 end)
	else
		if _G.isLocalDevelopMode then printx(0, "current state: ", self.state) end
	end
end


function QixiBoss:play()
	self.animation:playByIndex(0)
end


