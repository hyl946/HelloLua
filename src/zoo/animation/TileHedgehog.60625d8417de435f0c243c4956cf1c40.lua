TileHedgehog = class(CocosObject)
local kCharacterAnimationTime = 1/30
local HedgehogAnimation = table.const{
	kIdle = 1,
	kAppear = 2, 
	kChange = 3,
	kMove = 4, 
	kShocked =5,
	kToShell = 6, 
	kOutShell = 7
}

function TileHedgehog:create( level, beforeStart )
	-- body
	local node = TileHedgehog.new(CCNode:create())
	node.level = level or 1
	node:init(beforeStart)
	return node
end

function TileHedgehog:init( beforeStart )
	-- body
	FrameLoader:loadArmature("skeleton/hedgehog_V3_animation")

	local hedgehog
	if beforeStart then
		--hedgehog = Sprite:createWithSpriteFrameName("hedgehog_out_0000")
		hedgehog = ArmatureNode:create("hedgehog_V3/come_out")
		--hedgehog = ArmatureNode:create("hedgehog_V3/wait")
	elseif self.level == 1 then
		--hedgehog = Sprite:createWithSpriteFrameName("hedgehog_wait_0000")
		hedgehog = ArmatureNode:create("hedgehog_V3/wait")
	else
		--hedgehog = Sprite:createWithSpriteFrameName("hedgehog_wait_b_0000")
		hedgehog = ArmatureNode:create("hedgehog_V3/wait_b")
	end
	self.hedgehog = hedgehog
	hedgehog:setPosition(ccp( 0 , 0 ) )  ---------产品非要调
	hedgehog:setScaleX(-1)
	self:addChild(hedgehog)
	hedgehog:playByIndex(0)
	hedgehog:update(0.001) -- 此处的参数含义为时间
	hedgehog:stop()

	local arrow = Sprite:createWithSpriteFrameName("hedgehog_V3_arrow_0001")
	self.arrow = arrow
	self:addChild(arrow)
	local frames = SpriteUtil:buildFrames("hedgehog_V3_arrow_%04d", 0, 20)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	arrow:play(animate)
	self.arrow:setVisible(false)
	if not beforeStart then
		self:playIdleAnimation()
	end
end

function TileHedgehog:changeAnimation(animationName , justCreate)
	local hedgehog = ArmatureNode:create("hedgehog_V3/" .. animationName)
	
	if not hedgehog then return end
	
	if not justCreate then
		if self.hedgehog and not self.hedgehog.isDisposed then
			self.hedgehog:stop()
			self.hedgehog:removeFromParentAndCleanup(true)
			self.hedgehog = nil
		end
		self.hedgehog = hedgehog
		self:addChild(self.hedgehog)
	end
	
	hedgehog:playByIndex(0)
	hedgehog:setScaleX(-1)

	return hedgehog
end

function TileHedgehog:updateArrow( direction )
	-- body
	self.arrow:setVisible(true)
	if direction ==  RouteConst.kUp then 
		self.arrow:setRotation(-90)
		self.arrow:setPosition(ccp(0, GamePlayConfig_Tile_Height/2))
	elseif direction == RouteConst.kDown then
		self.arrow:setRotation(90)
		self.arrow:setPosition(ccp(0, -GamePlayConfig_Tile_Height/2))
	elseif direction == RouteConst.kLeft or direction == RouteConst.kRight then
		self.arrow:setRotation(0)
		self.arrow:setPosition(ccp(GamePlayConfig_Tile_Width/2,0))
	else
		self.arrow:setVisible(false)
	end
end

function TileHedgehog:playToShellAnimation( callback, isCrazy )
	-- body
	-- local frames
	-- if self.level == 1 then
	-- 	frames = SpriteUtil:buildFrames("hedgehog_out_%04d", 1, 13, true)
	-- else
	-- 	frames = SpriteUtil:buildFrames("hedgehog_to_super_%04d", 0, 11)
	-- end

	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- self.hedgehog:stopAllActions()
	-- self.hedgehog:play(animate, 0, 1, callback)
	-- self.animation = HedgehogAnimation.kToShell

	if callback then callback() end
end

function TileHedgehog:changeVisibleMoveSnail( value )
	-- body
	if self.hedgehog then 
		self.hedgehog:setVisible(not value)
	end
	if self.moveHedgehog then 
		self.moveHedgehog:setVisible(value)
	end
end

function TileHedgehog:playOutShellAnimation( callback )
	-- body
	self:changeVisibleMoveSnail(false)

	-- local frames
	-- if self.level == 1 then
	-- 	frames = SpriteUtil:buildFrames("hedgehog_out_%04d", 1, 13)
	-- else
	-- 	frames = SpriteUtil:buildFrames("hedgehog_to_super_%04d", 0, 11, true)
	-- end
	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- self.hedgehog:stopAllActions()
	-- local function animationCallback( ... )
	-- 	-- body
	-- 	if callback then callback() end
	-- end 
	-- self.hedgehog:play(animate, 0, 1, animationCallback)
	-- self.animation = HedgehogAnimation.kOutShell

	if callback then callback() end
end

function TileHedgehog:playIdleAnimation( ... )
	-- body
	if self.animation ~= HedgehogAnimation.kIdle then

		local hedgehog = nil
		if self.level == 1 then
			self:changeAnimation("wait")
			--frames = SpriteUtil:buildFrames("hedgehog_wait_%04d", 0, 170)
		else
			self:changeAnimation("wait_b")
			--frames = SpriteUtil:buildFrames("hedgehog_wait_b_%04d", 0, 79)
		end

		self.animation = HedgehogAnimation.kIdle
	end
end

function TileHedgehog:createMoveSnail( callback, isCrazy )
	-- body
	local time = 0.5
	local moveHedgehog = Sprite:createEmpty()

	-- --shadow
	-- local str_sprite_frame_name = isCrazy and "hedgehog_tail_0001" or "hedgehog_tail_0000"
	-- local shadow = Sprite:createWithSpriteFrameName(str_sprite_frame_name)
	-- shadow:setAnchorPoint(ccp(0.55, 0.5))
	-- local action_move_1 = CCMoveBy:create(time/2, ccp(-GamePlayConfig_Tile_Width/3, 0))
	-- local action_move_2 = CCMoveBy:create(time/2, ccp(GamePlayConfig_Tile_Width/3, 0))
	-- shadow:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action_move_1, action_move_2)) )
	-- moveHedgehog:addChild(shadow)
	-- moveHedgehog.shadow = shadow

	local function createLight( minScale, maxScale, position )
		-- body
		minScale = minScale or 1
		maxScale = maxScale or 1
		position = position or ccp(0, 0)
		local light =  Sprite:createWithSpriteFrameName("hedgehog_V3_tail_1")
		light:setAnchorPoint(ccp(1, 0.5))
		light:setScale(minScale)
		light:setPosition(position)
		local function reset( ... )
			-- body
			light:setOpacity(255)
			light:setScale(minScale)
		end

		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(time/2, maxScale))
		arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(time/2, 1.1 * maxScale), CCFadeOut:create(time/2)))
		arr:addObject(CCCallFunc:create(reset))

		light:runAction(CCRepeatForever:create(CCSequence:create(arr)))
		return light
	end

	-- local light_1 = createLight(0.2, 1, ccp(-GamePlayConfig_Tile_Width/4, GamePlayConfig_Tile_Height/5))
	-- moveHedgehog:addChild(light_1)
	-- moveHedgehog.light_1 = light_1

	-- local light_2 = createLight(0.15, 0.75, ccp(GamePlayConfig_Tile_Width/4, -GamePlayConfig_Tile_Height/3))
	-- moveHedgehog:addChild(light_2)
	-- moveHedgehog.light_2 = light_2

	local light = createLight(0.2, 1)
	moveHedgehog:addChild(light)
	moveHedgehog.light = light

	--snail
	local str_sprite_frame_name_1 = isCrazy and "hedgehog_move_b_" or "hedgehog_move_"
	local main_sprite = nil

	if isCrazy then
		main_sprite = self:changeAnimation("move_b" , true)
	else
		main_sprite = self:changeAnimation("move" , true)
	end
	moveHedgehog:addChild(main_sprite)
	moveHedgehog.main_sprite = main_sprite

	--stars
	if isCrazy then
		local star = Sprite:createWithSpriteFrameName("hedgehog_star_0000")
		local frames = SpriteUtil:buildFrames("hedgehog_star_%04d", 0, 20)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		star:play(animate)
		moveHedgehog:addChild(star)
		moveHedgehog.star = star
	end


	self.moveHedgehog = moveHedgehog
	self.moveHedgehog:setPositionY(5)
	self:addChild(moveHedgehog)
	self.moveHedgehog.light:setVisible(false)
end

function TileHedgehog:playMoveAnimation( callback, isCrazy )
	-- body
	if not self.moveHedgehog then 
		self:createMoveSnail(callback, isCrazy)
	end
	self:changeVisibleMoveSnail(true)
end

function TileHedgehog:setMainSpriteRotation( rotation )
	-- body
	if self.moveHedgehog then
		self.moveHedgehog.main_sprite:setRotation(-rotation)

		self.moveHedgehog.light:setVisible(true)
	end
end

function TileHedgehog:playChangeAnimation(level, callback )
	-- body
	if self.level == level then
		if callback then callback() end
		return  
	end
	-- GamePlayMusicPlayer:playEffect(GameMusicType.kHedgehogCrazy)

	local function animaCallback( ... )
		-- body
		if callback then callback() end
		self:playIdleAnimation()
	end

	local frames
	if self.level < level then
		--frames = SpriteUtil:buildFrames("hedgehog_grow_%04d", 0, 49)
		self:changeAnimation("grow")
	else
		--frames = SpriteUtil:buildFrames("hedgehog_grow_%04d", 0, 49, true)
		self:changeAnimation("grow")
	end

	setTimeOut( function () animaCallback() end , 1.1 )

	self.animation = HedgehogAnimation.kChange
	self.level = level
end

function TileHedgehog:playHedgehogOutAnimation( callback )
	--[[
	local frames = SpriteUtil:buildFrames("hedgehog_out_%04d", 0, 32)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	local function animationCallback( ... )
		-- body
		if callback then callback() end
		self:playIdleAnimation()
	end 
	self.hedgehog:play(animate, 0, 1, animationCallback)
	]]

	self.hedgehog:playByIndex(0)

	setTimeOut( function () 
		if self.isDisposed or not self.refCocosObj then return end
		self:playIdleAnimation()
		if callback then callback() end 

		end , 1 )
end
