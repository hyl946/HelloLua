MissionAnimation = class()

local _instance = nil
function MissionAnimation:getInstance()
	if not _instance then
		_instance = MissionAnimation.new()
	end

	return _instance
end

function MissionAnimation:init()
	FrameLoader:loadArmature("skeleton/user_mission_animation")
	FrameLoader:loadImageWithPlist("flash/missionAnime.plist")
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/missionAnime.plist"))
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/common/properties.plist"))
	self.initialized = true
end

function MissionAnimation:createWaveAnimation()
	if not self.initialized then
		self:init()
	end

	local container = Layer:create()
	local wave = Sprite:createWithSpriteFrameName("wave_level_1_0001")
	container:changeWidthAndHeight(wave:getContentSize().width, wave:getContentSize().height)
	container:setAnchorPoint(ccp(0,0))
	container:addChild(wave)
	local wave_frames = SpriteUtil:buildFrames("wave_level_1_%04d", 1, 3)
	local wave_animate = SpriteUtil:buildAnimate(wave_frames, 1/3)
	wave:play(wave_animate, 0, 0, nil, false)

	local wave = Sprite:createEmpty()
	container:setPosition( ccp( wave:getContentSize().width/-2 , wave:getContentSize().height/2 ) )
	wave:addChild(container)

	return wave
end

function MissionAnimation:createShineStarEff()
	if not self.initialized then
		self:init()
	end

	local container = Layer:create()
	local starBG = Sprite:createWithSpriteFrameName("mission_addWaterStarBG_0001")
	container:changeWidthAndHeight(starBG:getContentSize().width, starBG:getContentSize().height)
	container:setAnchorPoint(ccp(0.5, 0.5))
	starBG:setAnchorPoint(ccp(0.5, 0.5))
	starBG:setScaleX(2)
	starBG:runAction( CCFadeTo:create( 1/60 , 0 ) )

	local function onShowStarBG()
		container:addChild( starBG )

		local actArr = CCArray:create()
		actArr:addObject( CCScaleTo:create( 5/24 , 1 , 1) )
		actArr:addObject( CCScaleTo:create( 8/24 , 0.1 , 1) )
		actArr:addObject( CCCallFunc:create( function () 
				starBG:removeFromParentAndCleanup(true) 
				--if container and container:getParent() then
				--	container:removeFromParentAndCleanup(true)
				--end
			end ) )
		starBG:runAction( CCSequence:create(actArr) )
		starBG:runAction( CCFadeTo:create( 5/24 , 255 ) )

	end

	TimerUtil.addAlarm( onShowStarBG, 10/24 , 1 )

	local particleSprite = Sprite:createEmpty()
	local starParticle = self:createStarParticle()
	particleSprite:addChild(starParticle)
	particleSprite:setPosition( ccp( 0 , -80 ) )
	container:addChild(particleSprite)

	local function onHideParticle()
		local array = CCArray:create()
		array:addObject( CCFadeTo:create( 5/24 , 0 ) )
		array:addObject( CCCallFunc:create( function () particleSprite:removeFromParentAndCleanup(true) end ) )
		particleSprite:runAction( CCSequence:create(array) )
	end
	TimerUtil.addAlarm( onHideParticle , 15/24 , 1 )

	return container
end

function MissionAnimation:createStarParticle()
	local node = CocosObject:create()

	local stars = ParticleSystemQuad:create("particle/missionStar.plist")
	stars:setAutoRemoveOnFinish(true)
	stars:setPosition(ccp(0, 0))

	node:addChild(stars)

	if _G.isLocalDevelopMode then printx(0, "group bounds:", node:getGroupBounds().size.width, node:getGroupBounds().size.height) end
	--[[
	local starLine = ParticleSystemQuad:create("particle/flowstar.plist")
	starLine:setAutoRemoveOnFinish(true)
	starLine:setPosition(ccp(0, -35))
	node:addChild(starLine)
	]]

	if __use_small_res then
		--heart:setTotalParticles(math.floor(heart:getTotalParticles()/3))
		--starLine:setTotalParticles(math.floor(starLine:getTotalParticles()/3))
	end
	
	return node
end

function MissionAnimation:createAddWaterEff(showStarEff , callback)

	if not self.initialized then
		self:init()
	end

	local container = Layer:create()

	local stars = nil

	local waterBG = Sprite:createWithSpriteFrameName("mission_addWaterBG_0001")
	container:changeWidthAndHeight(waterBG:getContentSize().width, waterBG:getContentSize().height)
	container:setAnchorPoint(ccp(0.5, 0.5))
	waterBG:setAnchorPoint( ccp(0.5,0.5) )
	waterBG:setPosition( ccp(0,0) )
	waterBG:setScale(0.2)

	if showStarEff then
		stars = self:createShineStarEff()
		container:addChild(stars)
	end

	


	local function onShowWaterEff()
		container:addChild(waterBG)

		local waterEff = Sprite:createWithSpriteFrameName("mission_addWater_0001")
		container:addChild(waterEff)
		--waterEff:setPositionX(-30)
		local waterEff_frames = SpriteUtil:buildFrames("mission_addWater_%04d", 1, 10)
		local waterEff_animate = SpriteUtil:buildAnimate(waterEff_frames, 1/24)
		waterEff:play(waterEff_animate, 0, 1, nil, false)

		local function onEffFin()
			waterBG:removeFromParentAndCleanup(true)
			waterEff:stopAllActions()
			waterEff:removeFromParentAndCleanup(true)

			if container and container:getParent() then
				container:removeFromParentAndCleanup(true)
			end

			if callback and type(callback) == "function" then
				callback()
			end
		end

		local actArr = CCArray:create()
		actArr:addObject( CCScaleTo:create( 4/24 , 1 ) )
		actArr:addObject( CCFadeTo:create( 7/24 , 0 ) )
		actArr:addObject( CCCallFunc:create(onEffFin) )
		waterBG:runAction( CCSequence:create(actArr) )
	end

	if showStarEff then
		TimerUtil.addAlarm( onShowWaterEff, 14/24 , 1 )
	else
		onShowWaterEff()
	end

	return container

end


function MissionAnimation:createMissionChangeEff()

	local container = Layer:create()
	FrameLoader:loadArmature("skeleton/user_mission_animation")
	local eff = ArmatureNode:create("user_mission_panel/mission_bubble_changed")
	local effSize = eff:getGroupBounds().size
	eff:setAnchorPoint(ccp(0,0))
	eff:setPosition( effSize.width / -2 , effSize.height / -2 )

	local function onTimeOut()
		if container and container:getParent() then
			container:removeFromParentAndCleanup(true)
		end
	end

	local actArr = CCArray:create()
	actArr:addObject( CCDelayTime:create( eff:getTotalTime() ) )
	actArr:addObject( CCCallFunc:create( onTimeOut ) )
	eff:runAction( CCSequence:create(actArr) )

	container:addChild(eff)
	eff:playByIndex(0 , 1)

	return container
end


function MissionAnimation:createMissionBubbleExplodeEff()

	local container = Layer:create()
	FrameLoader:loadArmature("skeleton/user_mission_animation")
	local eff = ArmatureNode:create("user_mission_panel/mission_bubble_explode")
	local effSize = eff:getGroupBounds().size
	eff:setAnchorPoint(ccp(0,0))
	eff:setPosition( effSize.width / -2 , effSize.height / -2 )

	local function onTimeOut()
		if container and container:getParent() then
			container:removeFromParentAndCleanup(true)
		end
	end

	local actArr = CCArray:create()
	actArr:addObject( CCDelayTime:create( eff:getTotalTime() ) )
	actArr:addObject( CCCallFunc:create( onTimeOut ) )
	eff:runAction( CCSequence:create(actArr) )

	container:addChild(eff)
	eff:playByIndex(0 , 1)

	return container
end