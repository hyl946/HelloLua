TileDigGround = class(Sprite)
local kCharacterAnimationTime = 1/30

function TileDigGround:create(level, texture, levelType)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileDigGround.new(sprite)
	node.parentTexture = texture
	node.name = "digGroundTile"
	node.level = level
    node.levelType = levelType
    node:createSprite(level)
	return node
end

function TileDigGround:createSprite( level )

    if self.levelType == GameLevelType.kMoleWeekly then
        self:createSpriteMoleWeekly(level)
    else
        self:createSpriteCloud(level)
    end
end

function TileDigGround:createSpriteMoleWeekly( level )
    if self.bgCloud then
		self.bgCloud:removeFromParentAndCleanup(true)
	end

	-- body
	if level == 3 then 
		self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal3.png")
		self.bgCloud:setPosition(ccp(2,-3)) 
		self:addChild(self.bgCloud)
	elseif level == 2 then 
		self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal2.png")
		self.bgCloud:setPosition(ccp(2,-4)) 
		self:addChild(self.bgCloud)
    elseif level == 1 then 
		self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal1.png")
		self.bgCloud:setPosition(ccp(2,-3)) 
		self:addChild(self.bgCloud)
	end
end

function TileDigGround:createSpriteCloud( level )
    -- body
	self.bgCloud = Sprite:createWithSpriteFrameName("dig_cloud_b_0000")
	self:addChild(self.bgCloud)

	if level > 1 then 
		self.rainbow = Sprite:createWithSpriteFrameName("dig_rainbow_0000")
		self:addChild(self.rainbow)
	end

	if level > 2 then 
		self.rain = Sprite:createWithSpriteFrameName("dig_rain_0000")
		local characterPattern = "dig_rain_%04d"
		local numFrames = 20
		local frames = SpriteUtil:buildFrames(characterPattern, 0, numFrames)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.rain:play(animate)
		self.rain:setAnchorPoint(ccp(0.5, 1))
		self:addChild(self.rain)
	end
end

function TileDigGround:changeLevel( level, callback )
	if self.levelType == GameLevelType.kMoleWeekly then
        self:changeLevelMoleWeekly(level,callback)
    else
        self:changeLevelCloud(level,callback)
    end
end

function TileDigGround:changeLevelMoleWeekly( level, callback )
    -- body
	self.level = level
	if level == 2 then
        --蒲公英散开
		self:playAttact1(callback)
	elseif level == 1 then
		--根茎断开
		self:playAttact2(callback)
	elseif level == 0 then 
		--草地消失
		self:playAttact3(callback)
	end
end

function TileDigGround:changeLevelCloud( level, callback )
    -- body
	self.level = level
	if level == 2 then
		self:playDripbombAnimation(callback)
	elseif level == 1 then
		self:playRainbowDisappearAnimation(callback)
	elseif level == 0 then 
		self:playCloudDisappearAnimation(callback)
	end
end

function TileDigGround:playAttact1( afterAnimationCallback )

	if self.bgCloud then
		self.bgCloud:removeFromParentAndCleanup(true)
	end

    self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal1.png")
	self.bgCloud:setPosition(ccp(2,-3)) 
	self:addChild(self.bgCloud)

	-- body
	upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_attact1_0.png")
    upgradeEffectAnimation:setPosition(ccp(60,58)) 
    self.bgCloud:addChildAt( upgradeEffectAnimation, 1 )

    local frames = SpriteUtil:buildFrames("gress_attact1_".."%d.png", 0, 15)
    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

    function BoomEnd()
    	self:createSprite(2)

        if afterAnimationCallback then afterAnimationCallback() end
	end
	upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, true )
end

function TileDigGround:playAttact2( afterAnimationCallback )

	if self.bgCloud then
		self.bgCloud:removeFromParentAndCleanup(true)
	end

    self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal1.png")
	self.bgCloud:setPosition(ccp(2,-3)) 
	self:addChild(self.bgCloud)

	-- body
	upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_attact2_0.png")
    upgradeEffectAnimation:setPosition(ccp(38,45)) 
    self.bgCloud:addChildAt( upgradeEffectAnimation, 1 )

    local frames = SpriteUtil:buildFrames("gress_attact2_".."%d.png", 0, 24)
    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

    function BoomEnd()
    	self:createSprite(1)

        if afterAnimationCallback then afterAnimationCallback() end
	end
	upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, true )
end

function TileDigGround:playAttact3( afterAnimationCallback )

	if self.bgCloud then
		self.bgCloud:removeFromParentAndCleanup(true)
	end

	-- body
	upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_attact3_0.png")
    upgradeEffectAnimation:setPosition(ccp(-5,0)) 
    self:addChildAt( upgradeEffectAnimation, 1 )

    local frames = SpriteUtil:buildFrames("gress_attact3_".."%d.png", 0, 24)
    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

    function BoomEnd()
    	if self.bgCloud then
			self.bgCloud:removeFromParentAndCleanup(true)
		end

        if afterAnimationCallback then afterAnimationCallback() end
	end
	upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, true )
	self.bgCloud = upgradeEffectAnimation
end


local function getStars( ... )
	-- body
	local time = 0.5
	local sprite = Sprite:createWithSpriteFrameName("dig_star")
	local action_rotation = CCRotateBy:create(time, -90)
	local action_fadein = CCFadeIn:create(time/3)
	local action_fadeout = CCFadeOut:create(time/3)
	local action_delay = CCDelayTime:create(time/3)
	local array = CCArray:create()
	array:addObject(action_fadein)
	array:addObject(action_delay)
	array:addObject(action_fadeout)
	local action_sequence = CCSequence:create(array)

	local action_spawn = CCSpawn:createWithTwoActions(action_sequence, action_rotation)
	local action_delay_2 = CCDelayTime:create(time * 4)
	sprite:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action_spawn,action_delay_2) ))
	return sprite
end

---------------------------
--动画 云彩爆炸
------------------------------
function TileDigGround:playCloudDisappearAnimation( afterAnimationCallback )
	-- body
	local sprite_name = "dig_cloud_0000"
	if self.bgCloud then self.bgCloud:removeFromParentAndCleanup(true) end
	local container = Sprite:createEmpty()
	container:setTexture(self.parentTexture)
	for k = 1, 8 do 
		local sprite = Sprite:createWithSpriteFrameName(sprite_name)
		local angle = (k-1) * 360/8   ----------角度
		local radian = angle * math.pi / 180
		-- if _G.isLocalDevelopMode then printx(0, "angle = ", angle, "radian = ",radian) end
		-- sprite:setRotation(angle)
		sprite:setScale(0.8)
		sprite:setAnchorPoint(ccp(0.5,0.5))
		local time_spaw = 0.5
		local action_move_1 = CCMoveBy:create(time_spaw*0.5, ccp(math.sin(radian) * 2 *GamePlayConfig_Tile_Width/3 , math.cos(radian) * 2 *GamePlayConfig_Tile_Width/3  ))
		local action_scale = CCScaleTo:create(time_spaw*0.5,1)
		local action_spaw_1 = CCSpawn:createWithTwoActions(action_move_1, action_scale)
		
		local action_fadeout = CCFadeOut:create(time_spaw * 1.6)
		local action_move_2 = CCMoveBy:create(time_spaw * 1.6, ccp(math.sin(radian) * GamePlayConfig_Tile_Width/10 , math.cos(radian) * GamePlayConfig_Tile_Width/10  ))
		local action_scale_2 = CCScaleTo:create(time_spaw * 1.6, 0.6)
		local actionArray_spawn_2 = CCArray:create()
		actionArray_spawn_2:addObject(action_fadeout)
		actionArray_spawn_2:addObject(action_move_2)
		actionArray_spawn_2:addObject(action_scale_2)
		local action_spaw_2 = CCSpawn:create(actionArray_spawn_2)

		local actionArray = CCArray:create()
		actionArray:addObject(action_spaw_1)
		actionArray:addObject(action_spaw_2)

		sprite:runAction(CCSequence:create(actionArray))
		container:addChild(sprite)

		local star = getStars()
		star:setScale(0.1)
		local move_by
		if k == 1 then
			move_by = ccp(math.sin(radian) * 2 *GamePlayConfig_Tile_Width/4 , math.cos(radian) * 2 *GamePlayConfig_Tile_Width/4  ) 
		else 
			move_by = ccp(math.sin(radian) * 2 *GamePlayConfig_Tile_Width/3 , math.cos(radian) * 2 *GamePlayConfig_Tile_Width/3  )
		end
		local action_move_star = CCMoveBy:create(time_spaw, move_by)
		local action_decSpeed = CCEaseExponentialOut:create(action_move_star)
		local action_scale_star = CCScaleTo:create(time_spaw/ 2, 0.5)
		local action_fadeout_star = CCFadeOut:create(time_spaw / 2)

		local function starCallback()
			if star then star:removeFromParentAndCleanup(true) end
		end

		local action_seq = CCSequence:createWithTwoActions(action_scale_star, action_fadeout_star)
		local star_array = CCArray:create()
		star_array:addObject(CCDelayTime:create(time_spaw/3))
		star_array:addObject(CCSpawn:createWithTwoActions(action_seq, action_move_star))
		star_array:addObject(CCCallFunc:create(starCallback))
		local action_star =CCSequence:create(star_array ) 
		star:runAction(action_star)
		container:addChild(star)

	end
	local function callback( ... )
		-- body
		container:removeFromParentAndCleanup(true)
		if afterAnimationCallback and type(afterAnimationCallback) == "function" then 
			afterAnimationCallback()
		end
	end

	self:addChild(container)
	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(callback)))
end
---------------------------
--动画 彩虹扩散
--------------------------
function TileDigGround:playRainbowDisappearAnimation( afterAnimationCallback )
	-- body
	if not self.rainbow then return end

	local function callback( ... )
		-- body
		if self.rainbow then 
			self.rainbow:removeFromParentAndCleanup(true)
			if afterAnimationCallback and type(afterAnimationCallback) == "function" then 
				afterAnimationCallback()
			end
		end
	end

	local pList = {
					{x = 0, y = 0},
					{x = -30, y = 30},
					{x = 20, y = 35},
					{x = -20, y = -20},
					{x = 0, y = -30},
					{x = 30, y = -25},
					{x = -15, y = -15},
					{x = 0, y = 20}
				}
	for k = 1, 8 do 
		local star = Sprite:createWithSpriteFrameName("dig_star")
		star:setScale(math.random())
		star:setPositionXY(pList[k].x, pList[k].y)

		if not (star and star.refCocosObj and self and self.refCocosObj) then return end

		self:addChild(star)
		star:getAlpha(0)
		local function removeStar( ... )
			-- body
			if star and star.refCocosObj then 
				star:removeFromParentAndCleanup(true)
			end
		end

		local star_arr = CCArray:create()
		star_arr:addObject(CCDelayTime:create(math.random() * 0.4))
		star_arr:addObject(CCFadeIn:create(0.15))
		star_arr:addObject(CCDelayTime:create(0.5))
		star_arr:addObject(CCFadeOut:create(0.15))
		star_arr:addObject(CCCallFunc:create(removeStar))
		local action = CCSpawn:createWithTwoActions(CCSequence:create(star_arr), CCRotateBy:create(1.2, -270))
		star:runAction(action)
	end

	local spawn_time = 0.5
	local action_scale_1 = CCScaleTo:create(spawn_time*0.3, 0.7)
	local action_scale_2 = CCEaseExponentialOut:create(CCScaleTo:create(spawn_time*0.8 , 1.7))
	local action_scale_3 = CCScaleTo:create(spawn_time*0.6, 1.9)
	local action_fadeout = CCFadeOut:create(spawn_time*0.6)
	local action_spawn = CCSpawn:createWithTwoActions(action_scale_3, action_fadeout)
	local action_callfunc = CCCallFunc:create(callback)

	local array = CCArray:create()
	array:addObject(action_scale_1)
	array:addObject(action_scale_2)
	array:addObject(action_spawn)
	array:addObject(action_callfunc)

	local result_action = CCSequence:create(array)
	self.rainbow:runAction(result_action)

end

--------------------
--动画 雨滴爆炸
--------------------
function TileDigGround:playDripbombAnimation( afterAnimationCallback )
	-- body
	if self.rain then self.rain:removeFromParentAndCleanup(true) end
	local sprite_name = "dig_drip_0000"
	local container = Sprite:createEmpty()
	container:setTexture(self.parentTexture)
	for k = 1, 8 do 
		local sprite_drip = Sprite:createWithSpriteFrameName(sprite_name)
		local angle = (k-1) * 360/8   ----------角度
		local radian = angle * math.pi / 180
		local sin_radian = math.sin(radian)
		local cos_radian = math.cos(radian)
		sprite_drip:setRotation(angle)
		sprite_drip:setAnchorPoint(ccp(0.5,0))
		local time_spaw = 0.5
		local action_move = CCEaseExponentialOut:create( CCMoveBy:create(time_spaw *2, ccp(sin_radian *2 *  GamePlayConfig_Tile_Width/3 , cos_radian *2 * GamePlayConfig_Tile_Width/3  )))
		local action_scale = CCScaleTo:create(time_spaw*0.3, 1.4)
		local action_fadeout = CCFadeOut:create(time_spaw*1.5)
		local action_spawn = CCSpawn:createWithTwoActions(action_move, CCSequence:createWithTwoActions(action_scale, action_fadeout))
		
		sprite_drip:runAction(action_spawn)
		container:addChild(sprite_drip)

		local sprite_drip_small = Sprite:createWithSpriteFrameName(sprite_name)
		sprite_drip_small:setRotation(angle)
		sprite_drip_small:setAnchorPoint(ccp(0.5, 0))
		sprite_drip_small:setScale(0.5)
		local action_move_small = CCEaseExponentialOut:create( CCMoveBy:create(time_spaw * 4, ccp(sin_radian * GamePlayConfig_Tile_Width/2 , cos_radian * GamePlayConfig_Tile_Width/2  )))
		local action_scale_small = CCScaleTo:create(time_spaw * 1.2 , 1)
		local action_fadeout_small = CCFadeOut:create(time_spaw )
		local action_spawn_small = CCSpawn:createWithTwoActions(action_move_small, CCSequence:createWithTwoActions(action_scale_small, action_fadeout_small))
		sprite_drip_small:runAction(action_spawn_small )
		container:addChild(sprite_drip_small)
	end
	local function callback( ... )
		-- body
		container:removeFromParentAndCleanup(true)
		if afterAnimationCallback and type(afterAnimationCallback) == "function" then 
			afterAnimationCallback()
		end
	end

	self:addChild(container)
	container:setPosition(ccp(0, -GamePlayConfig_Tile_Width / 6))
	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(callback)))
end

local function playLightCircleAnimation( ... )
	-- body
	local light_cirlce = Sprite:createWithSpriteFrameName("dig_light_cirlce")
	local time = 0.5
	local action_fadein = CCFadeIn:create(time)
	local action_rotateby = CCRotateBy:create(3 * time, 180)
	local action_fadeout = CCFadeOut:create(time)
	local action_sequence = CCSequence:createWithTwoActions(action_fadein, action_fadeout)
	local action = CCSpawn:createWithTwoActions(action_sequence, action_rotateby)
	local function localCallback( ... )
		-- body
		light_cirlce:setVisible(false)
	end 
	local action_result = CCSequence:createWithTwoActions(action, CCCallFunc:create(localCallback))
	light_cirlce:runAction(action_result)
	return light_cirlce

end


--------------------
--pm2.5生成地块的动画
--------------------
function TileDigGround:createDigGroundAnimation(midcallback, completeCallback)

    if self.levelType == GameLevelType.kMoleWeekly then
	    return self:createDigGroundAnimationMoleWeekly(midcallback, completeCallback)
    else
        return self:createDigGroundAnimationCloud(midcallback, completeCallback)
    end
end

function TileDigGround:createDigGroundAnimationMoleWeekly(midcallback, completeCallback)

    local animation = Sprite:createEmpty()
	local time = 1

	--background
	local bgCloud = Sprite:createWithSpriteFrameName("gress_normal1.png")
	animation:addChild(bgCloud)

	local function animation_bg_callback( ... )
		-- body

	end

	local bgCloudArr = CCArray:create()
	bgCloudArr:addObject(CCFadeIn:create(time))
	bgCloudArr:addObject(CCCallFunc:create(animation_bg_callback))
	bgCloud:runAction(CCSequence:create(bgCloudArr))

	return animation

end


function TileDigGround:createDigGroundAnimationCloud(midcallback, completeCallback)

    local animation = Sprite:createEmpty()
	local time = 1

	--light_cirlce
	local light_cirlce = Sprite:createWithSpriteFrameName("pm25_circle")
	light_cirlce:setVisible(false)
	animation:addChild(light_cirlce)

	--background
	local bgCloud = Sprite:createWithSpriteFrameName("dig_cloud_b_0000")
	animation:addChild(bgCloud)
	local function light_cirlce_callback( ... )
		-- body
		if completeCallback and type(completeCallback) == "function" then completeCallback() end
	end

	local function animation_bg_callback( ... )
		-- body
		light_cirlce:setVisible(true)
		if midcallback then midcallback() end
		local action_cirlce = CCArray:create()
		action_cirlce:addObject(CCFadeIn:create(time/2))
		action_cirlce:addObject(CCRotateBy:create(1 * time, 180))
		action_cirlce:addObject(CCFadeOut:create(time/2))
		action_cirlce:addObject(CCCallFunc:create(light_cirlce_callback))
		light_cirlce:runAction(CCSequence:create(action_cirlce))

	end

	local bgCloudArr = CCArray:create()
	bgCloudArr:addObject(CCFadeIn:create(time))
	bgCloudArr:addObject(CCCallFunc:create(animation_bg_callback))
	bgCloud:runAction(CCSequence:create(bgCloudArr))

	--clouds
	for k = 1, 4 do 
		local x, y 
		
		x = (k == 1 or k == 3) and -1 or 1
		y = (k == 1 or k == 2) and 1 or -1
		local cloud = Sprite:createWithSpriteFrameName("pm25_cloud")
		local initPos = ccp(GamePlayConfig_Tile_Width * x * 3, GamePlayConfig_Tile_Height * y * 0.5)
		local desPos  = ccp(GamePlayConfig_Tile_Width * x * 0.3, GamePlayConfig_Tile_Height * y * 0.3)
		cloud:setPosition(initPos)
		local arr = CCArray:create()
		arr:addObject(CCFadeIn:create(time /4 ))
		arr:addObject(CCDelayTime:create(time/2))
		arr:addObject(CCFadeOut:create(time /4))
		cloud:runAction(CCSpawn:createWithTwoActions(CCEaseSineOut:create(CCMoveTo:create(3 * time/4 , desPos)), CCSequence:create(arr))) 

		animation:addChild(cloud)
	end

	return animation
end