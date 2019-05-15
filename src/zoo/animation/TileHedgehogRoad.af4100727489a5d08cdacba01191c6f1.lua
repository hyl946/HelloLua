-- TileHedgehogRoad = class(CocosObject)
-- local kCharacterAnimationTime = 1/20

-- function TileHedgehogRoad:create( roadType, rotation, state )
-- 	-- body
-- 	local node = TileHedgehogRoad.new(CCSprite:createWithSpriteFrameName("hedgehog_road_other_0010"))
-- 	node:init(roadType, rotation, state)
-- 	return node
-- end

-- function TileHedgehogRoad:init( roadType, rotation, state )
-- 	-- body
-- 	local river = Sprite:createWithSpriteFrameName("hedgehog_road_dark_0000")
-- 	local frames = SpriteUtil:buildFrames("hedgehog_road_dark_%04d", 0, 30)
-- 	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
-- 	river:play(animate)
-- 	self:addChild(river)
-- 	self.river = river

-- 	local str = "hedgehog_road_other_0007"
-- 	if roadType == TileRoadType.kLine then
-- 		str = "hedgehog_road_other_0006"
-- 	end
-- 	local river_board = Sprite:createWithSpriteFrameName(str)
-- 	self:addChild(river_board)
-- 	river_board:setRotation(rotation)
-- 	self.river_board = river_board

-- 	if roadType == TileRoadType.kLine then
-- 		if rotation == 0 then
-- 			str = "hedgehog_road_other_0000"
-- 		else
-- 			str = "hedgehog_road_other_0001"
-- 		end
-- 	else
-- 		if rotation == 0 then
-- 			str = "hedgehog_road_other_0003"
-- 		elseif rotation == 90 then
-- 			str = "hedgehog_road_other_0002"
-- 		elseif rotation == 180 then
-- 			str = "hedgehog_road_other_0005"
-- 		elseif rotation == 270 then
-- 			str = "hedgehog_road_other_0004"
-- 		end
-- 	end
-- 	local grass_board = Sprite:createWithSpriteFrameName(str)
-- 	self:addChild(grass_board)
-- 	self.grass_board = grass_board
-- 	grass_board:setVisible(false)
-- 	self.state = HedgeRoadState.kStop
-- 	self:changeState(state, false)
-- end

-- function TileHedgehogRoad:changeState( state, isPlayAnimation )
-- 	-- body
-- 	if state then
-- 		if state == HedgeRoadState.kPass then
-- 			self:changeBright(isPlayAnimation)
-- 		elseif state == HedgeRoadState.kDestroy then
-- 			self:changeDestruction()
-- 		end
-- 	end
-- end

-- function TileHedgehogRoad:changeBright( isPlayAnimation )
-- 	-- body
-- 	local function animateCallback( ... )
-- 		-- body
-- 		self.grass_board:setVisible(true)
-- 	end
-- 	self.river_board:removeFromParentAndCleanup(true)
-- 	self.river:removeFromParentAndCleanup(true)
-- 	if isPlayAnimation then
-- 		self.river = Sprite:createWithSpriteFrameName("hedgehog_road_bright_0000")
-- 		local frames = SpriteUtil:buildFrames("hedgehog_road_bright_%04d", 0, 30)
-- 		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
-- 		self.river:play(animate, 0, 1, animateCallback)
-- 	else
-- 		self.river = Sprite:createWithSpriteFrameName("hedgehog_road_bright_0029")
-- 		animateCallback()
-- 	end
-- 	self:addChildAt(self.river, 0)
-- end

-- function TileHedgehogRoad:changeDestruction( ... )
-- 	-- body
-- 	if self.state == HedgeRoadState.kDestroy then return end
-- 	self.state = HedgeRoadState.kDestroy
-- 	if self.river then self.river:removeFromParentAndCleanup(true) end
-- 	if self.river_board then self.river_board:removeFromParentAndCleanup(true) end
	
-- 	self.river = Sprite:createWithSpriteFrameName("hedgehog_road_other_0009")
-- 	self:addChildAt(self.river, 0)
-- 	self.grass_board:setVisible(true)
-- end


--[[

TileHedgehogRoad = class(CocosObject)
local kCharacterAnimationTime = 1/20

function TileHedgehogRoad:create( roadType, rotation, state )
	-- body
	local node = TileHedgehogRoad.new(CCSprite:createWithSpriteFrameName("road_christmas_0008"))
	node:init(roadType, rotation, state)
	return node
end

function TileHedgehogRoad:init( roadType, rotation, state )
	-- body
	self.roadType = roadType
	self.rotation = rotation

	local river = Sprite:createWithSpriteFrameName("road_christmas_0000")

	self:addChild(river)
	self.river = river

	local str = "road_christmas_0002"
	if roadType == TileRoadType.kLine then
		str = "road_christmas_0001"
	end
	local river_board = Sprite:createWithSpriteFrameName(str)
	self:addChild(river_board)
	river_board:setRotation(rotation)
	self.river_board = river_board

	if roadType == TileRoadType.kLine then
		if rotation == 0 then
			str = "road_christmas_0010"
		else
			str = "road_christmas_0003"
		end
	else
		if rotation == 0 then
			str = "road_christmas_0007"
		elseif rotation == 90 then
			str = "road_christmas_0006"
		elseif rotation == 180 then
			str = "road_christmas_0004"
		elseif rotation == 270 then
			str = "road_christmas_0005"
		end
	end
	local grass_board = Sprite:createWithSpriteFrameName(str)
	self:addChild(grass_board)
	self.grass_board = grass_board
	grass_board:setVisible(false)
	self.state = HedgeRoadState.kStop
	self:changeState(state)
end

function TileHedgehogRoad:copy( ... )
	-- body
	local s = TileHedgehogRoad:create(self.roadType, self.rotation, self.state)
	return s
end

function TileHedgehogRoad:changeState( state )
	-- body
	if state then
		if state == HedgeRoadState.kPass then
			self:changeBright()
		elseif state == HedgeRoadState.kDestroy then
			self:changeDestruction()
		end
	end
end

function TileHedgehogRoad:changeBright(  )
	-- body
	self.river_board:removeFromParentAndCleanup(true)
	self.river:removeFromParentAndCleanup(true)
	self.grass_board:setVisible(true)
	self.state = HedgeRoadState.kPass
end

function TileHedgehogRoad:changeDestruction( ... )
	-- body
	if self.state == HedgeRoadState.kDestroy then return end
	self.state = HedgeRoadState.kDestroy
	if self.river then self.river:removeFromParentAndCleanup(true) end
	if self.river_board then self.river_board:removeFromParentAndCleanup(true) end
	self.grass_board:setVisible(true)
end

function TileHedgehogRoad:createChangeBrightAnimation( road, pos, callback )
	-- body
	local node = TileHedgehogRoad.new(CCSprite:createWithSpriteFrameName("road_christmas_0008"))
	node:initAnimation(road, pos, callback )
	return node
end

function TileHedgehogRoad:initAnimation( road, pos, callback  )
	-- body
	local kuang = Sprite:createWithSpriteFrameName("road_christmas_0009")
	road:addChild(kuang)
	local _size = road:getGroupBounds().size
	road:setPosition(ccp(_size.width/2, -_size.height/2))
	local clipping = ClippingNode:create({size= _size}, road)
	self:addChild(clipping)

	local function finishCallback( ... )
		-- body
		if callback then callback() end
	end
	local time = 0.5
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(time, ccp(0, _size.height)))
	arr:addObject(CCCallFunc:create(finishCallback))
	road:runAction(CCSequence:create(arr))

	local _fadeAc = CCSequence:createWithTwoActions(CCDelayTime:create(time * 3 /5),
		CCFadeOut:create(time * 2 / 5))
	local _moveAc = CCMoveBy:create(time, ccp(0, -_size.height))
	kuang:setPosition(ccp(0, _size.height))
	kuang:runAction(CCSpawn:createWithTwoActions(_fadeAc, _moveAc))

	self:setPosition(ccp(pos.x - _size.width/2, pos.y + _size.height/2))
	self:runAction(CCMoveBy:create(time, ccp(0, -_size.height)))
end

]]




TileHedgehogRoad = class(CocosObject)
TileHedgehogRoadResLoaded = false
local kCharacterAnimationTime = 1/20

local function buildAnimation(animationName , noAnimation)
	
	local anim = nil
	if noAnimation then
		anim = Sprite:createWithSpriteFrameName( animationName .. "_0017" )
	else
		anim = Sprite:createWithSpriteFrameName( animationName .. "_0001" )
		local anim_frames = SpriteUtil:buildFrames( animationName .. "_%04d", 1 , 17 )
		local anim_animate = SpriteUtil:buildAnimate(anim_frames, 1/24)
		anim:play(anim_animate, 0, 1, nil, false)
	end

	return anim
end



function TileHedgehogRoad:create( roadType, rotation, state )
	-- body
	local node = TileHedgehogRoad.new(CCSprite:createWithSpriteFrameName("hedgehog_V3_road_earth_bg"))
	node:init(roadType, rotation, state)
	return node
end

function TileHedgehogRoad:init( roadType, rotation, state )
	-- body
	self.roadType = roadType
	self.rotation = rotation

	local earth = Sprite:createWithSpriteFrameName("hedgehog_V3_road_earth")
	earth:setPosition( ccp( 36 , 35 ) )
	self:addChild(earth)
	self.earth = earth

	if not TileHedgehogRoadResLoaded then
		FrameLoader:loadArmature("skeleton/hedgehog_V3_animation")
		TileHedgehogRoadResLoaded = true
	end
	--
	
	local darkBounds = Sprite:createEmpty()
	local dbe_1 = nil
	local dbe_2 = nil
	local dbe_3 = nil
	local dbe_4 = nil
	local str = "hedgehog_V3_road_drak_left"
	if roadType == TileRoadType.kLine then
		if rotation == 0 then
			
			dbe_1 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_up")
			dbe_2 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_down")

			dbe_1:setPosition( ccp( 36 , 65 ) )
			dbe_2:setPosition( ccp( 36 , 0 ) )

			darkBounds:addChild(dbe_1)
			darkBounds:addChild(dbe_2)
			
		else
			dbe_1 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_left")
			dbe_2 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_right")

			dbe_1:setPosition( ccp( 6 , 35 ) )
			dbe_2:setPosition( ccp( 66 , 35 ) )

			darkBounds:addChild(dbe_1)
			darkBounds:addChild(dbe_2)
		end
	else
		if rotation == 0 then--7
			dbe_1 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_right")
			dbe_2 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_down")

			dbe_1:setPosition( ccp( 66 , 35 ) )
			dbe_2:setPosition( ccp( 36 , 0 ) )

			darkBounds:addChild(dbe_1)
			darkBounds:addChild(dbe_2)
		elseif rotation == 90 then--6
			dbe_1 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_left")
			dbe_2 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_down")

			dbe_1:setPosition( ccp( 6 , 35 ) )
			dbe_2:setPosition( ccp( 36 , 0 ) )

			darkBounds:addChild(dbe_1)
			darkBounds:addChild(dbe_2)
		elseif rotation == 180 then--4
			dbe_1 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_left")
			dbe_2 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_up")

			dbe_1:setPosition( ccp( 6 , 35 ) )
			dbe_2:setPosition( ccp( 36 , 65 ) )

			darkBounds:addChild(dbe_1)
			darkBounds:addChild(dbe_2)
		elseif rotation == 270 then--5
			dbe_1 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_right")
			dbe_2 = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_up")

			dbe_1:setPosition( ccp( 66 , 35 ) )
			dbe_2:setPosition( ccp( 36 , 65 ) )
			

			darkBounds:addChild(dbe_1)
			darkBounds:addChild(dbe_2)
		end
	end

	local earth_board = darkBounds
	self:addChild(earth_board)
	self.earth_board = earth_board
	--printx( 1 , "    -------------------  TileHedgehogRoad:init    state = " , state)
	if not state then state = HedgeRoadState.kStop end
	--self.state = state
	self:changeState(state , true)
end

function TileHedgehogRoad:showGrass(noAnimation)

	if self.hasShowGrass then return end
	self.hasShowGrass = true
	--local grass = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_grass")
	local grass = buildAnimation("hedgehog_V3_road_grass" , noAnimation)
	grass:setPosition( ccp( 36 , 35 ) )
	grass:setScale(0.9)
	self:addChild(grass)
	self.grass = grass


	local grass_board = nil
	if self.roadType == TileRoadType.kLine then
		if self.rotation == 0 then
			--grass_board = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_light_line_2")
			grass_board = buildAnimation("hedgehog_V3_road_light_line_2" , noAnimation)
		else
			--grass_board = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_light_line_1")
			grass_board = buildAnimation("hedgehog_V3_road_light_line_1" , noAnimation)
		end
	else
		if self.rotation == 0 then
			--grass_board = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_light_corner_1")
			grass_board = buildAnimation("hedgehog_V3_road_light_corner_1" , noAnimation)
		elseif self.rotation == 90 then
			--grass_board = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_light_corner_2")
			grass_board = buildAnimation("hedgehog_V3_road_light_corner_2" , noAnimation)
		elseif self.rotation == 180 then
			--grass_board = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_light_corner_3")
			grass_board = buildAnimation("hedgehog_V3_road_light_corner_3" , noAnimation)
		elseif self.rotation == 270 then
			--grass_board = ArmatureNode:create("hedgehog_V3/hedgehog_V3_road_light_corner_4")
			grass_board = buildAnimation("hedgehog_V3_road_light_corner_4" , noAnimation)
		end
	end

	grass_board:setPosition( ccp( 36 , 35 ) )
	grass_board:setScale(1)
	self:addChild(grass_board)
	self.grass_board = grass_board

end

function TileHedgehogRoad:copy( ... )
	-- body
	local s = TileHedgehogRoad:create(self.roadType, self.rotation, self.state)
	return s
end

function TileHedgehogRoad:changeState( state , noAnimation )
	-- body
	if state and self.state ~= state then
		if state == HedgeRoadState.kPass then
			self:changeBright(noAnimation)
		elseif state == HedgeRoadState.kDestroy then
			self:changeDestruction(noAnimation)
		end
	end
end

function TileHedgehogRoad:changeBright( noAnimation )
	-- body
	self.earth_board:removeFromParentAndCleanup(true)
	self.earth:removeFromParentAndCleanup(true)
	
	--self.grass:setVisible(true)
	--self.grass_board:setVisible(true)
	
	self:showGrass(noAnimation)

	if noAnimation then
		--self.grass:gotoAndStopByIndex(15)
		--self.grass_board:gotoAndStopByIndex(15)
	else
		--self.grass:playByIndex(0)
		--self.grass_board:playByIndex(0)
	end

	self.state = HedgeRoadState.kPass
end

function TileHedgehogRoad:changeDestruction( noAnimation )
	-- body
	if self.state == HedgeRoadState.kDestroy then return end
	self.state = HedgeRoadState.kDestroy
	if self.earth then self.earth:removeFromParentAndCleanup(true) end
	--if self.grass then self.grass:removeFromParentAndCleanup(true) end
	if self.earth_board then self.earth_board:removeFromParentAndCleanup(true) end

	--self.grass:setVisible(true)
	--self.grass_board:setVisible(true)

	self:showGrass(noAnimation)

	if noAnimation then
		--self.grass:gotoAndStopByIndex(15)
		--self.grass_board:gotoAndStopByIndex(15)
	else
		--self.grass:playByIndex(0)
		--self.grass_board:playByIndex(0)
	end
end

function TileHedgehogRoad:createChangeBrightAnimation( road, pos, callback )
	-- body
	--local node = TileHedgehogRoad.new(CCSprite:createWithSpriteFrameName("road_christmas_0008"))
	local node = TileHedgehogRoad.new(CCSprite:createWithSpriteFrameName("hedgehog_V3_road_earth"))
	node:initAnimation(road, pos, callback )
	return node
end

function TileHedgehogRoad:initAnimation( road, pos, callback  )
	-- body
	--local kuang = Sprite:createWithSpriteFrameName("road_christmas_0009")
	local kuang = Sprite:createWithSpriteFrameName("hedgehog_V3_road_drak_down")
	road:addChild(kuang)
	local _size = road:getGroupBounds().size
	road:setPosition(ccp(_size.width/2, -_size.height/2))
	local clipping = ClippingNode:create({size= _size}, road)
	self:addChild(clipping)

	local function finishCallback( ... )
		-- body
		if callback then callback() end
	end
	local time = 0.5
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(time, ccp(0, _size.height)))
	arr:addObject(CCCallFunc:create(finishCallback))
	road:runAction(CCSequence:create(arr))

	local _fadeAc = CCSequence:createWithTwoActions(CCDelayTime:create(time * 3 /5),
		CCFadeOut:create(time * 2 / 5))
	local _moveAc = CCMoveBy:create(time, ccp(0, -_size.height))
	kuang:setPosition(ccp(0, _size.height))
	kuang:runAction(CCSpawn:createWithTwoActions(_fadeAc, _moveAc))

	self:setPosition(ccp(pos.x - _size.width/2, pos.y + _size.height/2))
	self:runAction(CCMoveBy:create(time, ccp(0, -_size.height)))
end
