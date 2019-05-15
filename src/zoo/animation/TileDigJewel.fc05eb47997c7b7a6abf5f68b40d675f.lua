TileDigJewel = class(Sprite)

-- modify GameItemData.digJewelType
local JewelType = 
{
	kJewel = 0,
	kCake = 1,
	kHolycup = 2,
	kBell = 3,
	kRedbag = 4,
	kBlueJewel = 5,
	kGoldZongZi = 6,
	kQiXi2015 = 7,
	kCupcake = 8,
	kHalloween2015 = 9,
	kWukong = 10,
	kWeekly = 11,
	kChildrensDay = 12,
}

TileDigJewel.JewelTypeConfig = JewelType


local gressDelayTime = 3

function TileDigJewel:create(level, texture, levelType)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileDigJewel.new(sprite)
	node.parentTexture = texture

	--if _G.isLocalDevelopMode then printx(0, 'RRR  ++++++++++++++++++++++++ TileDigJewel:create   levelType = ', levelType) end

    node.levelType = levelType
	if levelType == GameLevelType.kSummerWeekly then
		node.jewelType = JewelType.kWeekly
	elseif levelType == GameLevelType.kMayDay then
		node.jewelType = JewelType.kChildrensDay
	elseif levelType == GameLevelType.kWukong then
		node.jewelType = JewelType.kWukong
	else
		node.jewelType = JewelType.kJewel
	end
	node.name = "digJewelTile"

    --鼹鼠周赛另走一套
    if levelType == GameLevelType.kMoleWeekly then
        node:createSpriteMoleWeekly(level)
	    node:initLevelMoleWeekly(level)
    else
	    node:createSprite(level)
	    node:initLevel(level)
    end
	
	return node
end

function TileDigJewel:createSpriteMoleWeekly( level )
    -- body
	if level < 1 or level > 3 then return end

    self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal1.png")
	self.bgCloud:setPosition(ccp(2,-3)) 
	self:addChild(self.bgCloud)
end

function TileDigJewel:initLevelMoleWeekly( level )
    -- body
	self.level = level

    if self.bgCloud then
		self.bgCloud.refCocosObj:removeAllChildrenWithCleanup(true)
	end

	if level > 0 then 
		if level == 2 then
            -- body
	        upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_gress_0.png")
            upgradeEffectAnimation:setPosition(ccp(37,40)) 
            self.bgCloud:addChildAt( upgradeEffectAnimation, 4 )

            local content = upgradeEffectAnimation
            function onRunAnimation ()

                function onRepeatFinishCallback ()
                end

                local frames = SpriteUtil:buildFrames("gress_gress_".."%d.png", 0, 32)
                animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
                content:play( animate, 0, 1, onRepeatFinishCallback, false  )

                if self.diamond and self.diamond.refCocosObj  then
                    local action = self:DiamondNormal( self.diamond )
                    self.diamond:stopAllActions()
                    self.diamond:runAction( action )
                end
            end

            local Sequence = CCSequence:createWithTwoActions(CCCallFunc:create(onRunAnimation),CCDelayTime:create(gressDelayTime))

            upgradeEffectAnimation:runAction( CCRepeatForever:create( Sequence ) )

        elseif level ==1 then
            -- body
	        upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_gress_68.png")
            upgradeEffectAnimation:setPosition(ccp(37,40)) 
            self.bgCloud:addChildAt( upgradeEffectAnimation, 4 )

            local content = upgradeEffectAnimation
            function onRunAnimation ()

                function onRepeatFinishCallback ()
                end

                local frames = SpriteUtil:buildFrames("gress_gress_".."%d.png", 68, 97-69)
                animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
                content:play( animate, 0, 1, onRepeatFinishCallback, false  )

                if self.diamond and self.diamond.refCocosObj  then
                    local action = self:DiamondNormal( self.diamond )
                    self.diamond:stopAllActions()
                    self.diamond:runAction( action )
                end
            end

            local Sequence = CCSequence:createWithTwoActions(CCCallFunc:create(onRunAnimation),CCDelayTime:create(gressDelayTime))

            upgradeEffectAnimation:runAction( CCRepeatForever:create( Sequence ) )
        end

        if level > 0 and level < 3 then
            local gress_diamond =self:createDiamond(ccp(0.44,0.34))
            gress_diamond:setPosition(ccp(42-2,41-11)) 
            gress_diamond:setRotation(-16.5)
            self.bgCloud:addChildAt( gress_diamond, 2 )
            self.diamond = gress_diamond

            self:createDiamondStar()
        end
	end
end

function TileDigJewel:createDiamondStar()
    local gress_diamondStar = Sprite:createWithSpriteFrameName("gress_starani_0.png")
    gress_diamondStar:setPosition( ccp(30,54) )
    gress_diamondStar:setScale(1)

    local frames = SpriteUtil:buildFrames("gress_starani_".."%d.png", 0, 49)
    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    gress_diamondStar:play( animate, 0, -1  )
    
    self.bgCloud:addChildAt( gress_diamondStar, 3 )
end

function TileDigJewel:createDiamond( anchorPoing )
    
    local gress_diamond = Sprite:createWithSpriteFrameName("gress_diamond.png")
    gress_diamond:setAnchorPoint( anchorPoing )
    gress_diamond:setScale(0.4)

    return gress_diamond
end


function TileDigJewel:DiamondNormal( node )
    
    local delayTime = 15*kCharacterAnimationTime
    local rotateTime = {5*kCharacterAnimationTime,4*kCharacterAnimationTime,3*kCharacterAnimationTime,3*kCharacterAnimationTime}
    local rotateAngle = 2
	local reverseRotateAngle = -2

    local targetedActions = CCArray:create()

    local delay = CCDelayTime:create(delayTime)

    for i=1, 2 do
        local rotate = CCRotateBy:create(rotateTime[(i-1)*2+1], rotateAngle)
	    local rotate2 = CCRotateBy:create(rotateTime[(i-1)*2+2], reverseRotateAngle)
	    targetedActions:addObject(rotate)
        targetedActions:addObject(rotate2)
    end
    targetedActions:addObject(delay)

    local sequence = CCSequence:create(targetedActions)


    node:setRotation(-16.5)
--    node:stopAllActions()
--    node:runAction( CCRepeatForever:create( sequence ) )
    return sequence
end

function TileDigJewel:DiamondAttack( node )

    local delayTime = 15*kCharacterAnimationTime
    local rotateTime = {5*kCharacterAnimationTime,4*kCharacterAnimationTime,3*kCharacterAnimationTime,3*kCharacterAnimationTime}

    local targetedActions = CCArray:create()

    local delay = CCDelayTime:create(delayTime)
    local rotate = CCRotateBy:create( 4*kCharacterAnimationTime, 7.2)

    local rotate1 = CCRotateBy:create( 4*kCharacterAnimationTime, -3.7)
    local moveby1 = CCMoveBy:create( 4*kCharacterAnimationTime, ccp(0,8.2))
    local spawnMoveScale1		= CCSpawn:createWithTwoActions(rotate1, moveby1)

    local rotate2 = CCRotateBy:create( 3*kCharacterAnimationTime, -7.4)
    local moveby2 = CCMoveBy:create( 3*kCharacterAnimationTime, ccp(0,-8.2))
    local spawnMoveScale2		= CCSpawn:createWithTwoActions(rotate2, moveby2)

    local rotate3 = CCRotateBy:create( 3*kCharacterAnimationTime, 3.9)

    targetedActions:addObject(rotate)
    targetedActions:addObject(spawnMoveScale1)
    targetedActions:addObject(spawnMoveScale2)
    targetedActions:addObject(rotate3)

    function Finished()
--        self:DiamondNormal( node )
    end

    local callback = CCCallFunc:create(Finished)
    targetedActions:addObject(callback)

    local sequence = CCSequence:create(targetedActions)

    node:setRotation(-16.5)
    node:stopAllActions()
    node:runAction( sequence )
end


function TileDigJewel:changeLevelMoleWeekly( level, callback )

    self.level = level
    if self.bgCloud then
		self.bgCloud.refCocosObj:removeAllChildrenWithCleanup(true)
	end

    if level == 1 then 
		-- body
	    upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_gress_33.png")
        upgradeEffectAnimation:setPosition(ccp(37,40)) 
        self.bgCloud:addChildAt( upgradeEffectAnimation, 3 )

        local frames = SpriteUtil:buildFrames("gress_gress_".."%d.png", 33, 68-34)
        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

        function BoomEnd()
    	    self:initLevelMoleWeekly(level)

            if callback then callback() end
	    end
	    upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, false )

        if level > 0 and level < 3 then
            local gress_diamond =self:createDiamond(ccp(0.44,0.34))
            gress_diamond:setPosition(ccp(42-2,41-11)) 
            gress_diamond:setRotation(-16.5)
            self.bgCloud:addChildAt( gress_diamond, 2 )
            self:DiamondAttack( gress_diamond )
        end

	elseif level == 0 then 

        if self.bgCloud then
		    self.bgCloud:removeFromParentAndCleanup(true)
	    end

		-- body
	    upgradeEffectAnimation = Sprite:createWithSpriteFrameName("gress_gress_97.png")
        upgradeEffectAnimation:setPosition(ccp(2,-3+10)) 
        self:addChildAt( upgradeEffectAnimation, 3 )

        local frames = SpriteUtil:buildFrames("gress_gress_".."%d.png", 97, 122-98)
        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

        function BoomEnd()
	    end
	    upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, true )

        --宝石飞
        local gress_diamond =self:createDiamond(ccp(0.5,0.5))
        gress_diamond:setPosition(ccp(5,0)) 
        gress_diamond:setRotation(-16.5)
        self:addChildAt( gress_diamond, 4 )

        function moveEnd()
            gress_diamond:removeFromParentAndCleanup(true)
            if callback then callback() end
        end

        local action_move = CCMoveBy:create(0.3, ccp(24,70))
        local array = CCArray:create()
	    array:addObject(action_move)
	    array:addObject(CCCallFunc:create(moveEnd))
	    local action_sequence = CCSequence:create(array)

        local action_fadeout = CCFadeOut:create(0.3)
        local action_spawn = CCSpawn:createWithTwoActions(action_sequence, action_fadeout)

        gress_diamond:runAction( action_spawn )
	end

end

------添加抖动动画
local function addJewAction( sprite, durationTime )
	-- body
	if sprite then sprite:stopAllActions() end

	local action_rotation_1 = CCRotateTo:create(0.1, -8.7)
	local action_rotation_2 = CCRotateTo:create(0.1, 9.2 )
	local action_rotation_3 = CCRotateTo:create(0.1, -10.7)
	local action_rotation_4 = CCRotateTo:create(0.05, 8)
	local action_rotation_5 = CCRotateTo:create(0.01, 0)

	durationTime = durationTime or 3
	local action_delay = CCDelayTime:create(durationTime)
	local array = CCArray:create()
	array:addObject(action_delay)
	array:addObject(action_rotation_1)
	array:addObject(action_rotation_2)
	array:addObject(action_rotation_3)
	array:addObject(action_rotation_4)
	array:addObject(action_rotation_5)
	
	local action_sequence = CCSequence:create(array)
	local action = CCRepeatForever:create(action_sequence)
	sprite:runAction(action)
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

function TileDigJewel:createSprite( level )
	-- body
	if level < 1 or level > 3 then return end
	local lightCircleOffsetX, lightCircleOffsetY = 0, 0
	if self.jewelType == JewelType.kWeekly then
		lightCircleOffsetX = -2
		lightCircleOffsetY = -8
	end

	self.bgCloud = Sprite:createWithSpriteFrameName("dig_cloud_b_0000")
	self:addChild(self.bgCloud)
	
	if self.jewelType == JewelType.kBell then
		self.light_cirlce = Sprite:createWithSpriteFrameName("dig_light_cirlce_zongzi_0000")
		self.light_cirlce:setPosition(ccp(0 + lightCircleOffsetX, GamePlayConfig_Tile_Width/6 - 7))
	else
		self.light_cirlce = Sprite:createWithSpriteFrameName("dig_light_cirlce")
		self.light_cirlce:setPosition(ccp(0 + lightCircleOffsetX, GamePlayConfig_Tile_Width/6 + lightCircleOffsetY))
	end
	self:addChild(self.light_cirlce)
	self.light_cirlce:setVisible(false)

	local jewelActionDurationTime = 3
	if self.jewelType == JewelType.kJewel then
		self.jewel = Sprite:createWithSpriteFrameName("dig_jewel_0000") 
	elseif self.jewelType == JewelType.kWeekly then
		jewelActionDurationTime = 6
		self.jewel = Sprite:createWithSpriteFrameName("dig_weekly_0000")
		self.jewel:setScale(0.9)
		self.jewel:setPosition(ccp(-2.2, 6)) 
	elseif self.jewelType == JewelType.kCupcake then
		self.jewel = Sprite:createWithSpriteFrameName("dig_cupcake_0000")
		self.jewel:setScale(0.9)
		self.jewel:setPositionY(self.jewel:getPositionY()+5)
	elseif self.jewelType == JewelType.kWukong then
		self.jewel = Sprite:createWithSpriteFrameName("dig_wukong_peach")
	elseif self.jewelType == JewelType.kChildrensDay then
		self.jewel = Sprite:createWithSpriteFrameName("dig_cupcake_0000")
		self.jewel:setPositionY(5)
	end
	self:addChild(self.jewel)
	addJewAction(self.jewel, jewelActionDurationTime)

	self.star_1 = getStars()
	self:addChild(self.star_1)
	local starOffset = ccp(0,0)
	if self.jewelType == JewelType.kWeekly then
		starOffset = ccp(-7, 0)
	end
	self.star_1:setPosition(ccp(-GamePlayConfig_Tile_Width/4+starOffset.x, GamePlayConfig_Tile_Width/4+starOffset.y))
end

function TileDigJewel:initLevel( level )
	-- body
	self.level = level
	if level > 0 then 
		local nameStr = "dig_jewel_front_0000"
		if level == 2 then 
			nameStr = "dig_jewel_front_0001"
		elseif level == 3 then
			nameStr = "dig_jewel_front_0002"
		end
		self.frontCloud = Sprite:createWithSpriteFrameName(nameStr)
		if (self.jewelType == JewelType.kBell or self.jewelType == JewelType.kCupcake) and level > 1 then
			if leve == 2 then
				self.frontCloud:setScaleY(0.95)
			else
				self.frontCloud:setScaleY(0.8)
				self.frontCloud:setPosition(ccp(0, -5))
			end
		end
		self:addChild(self.frontCloud)
	end
end

function TileDigJewel:changeLevel( level, callback )
    if self.levelType == GameLevelType.kMoleWeekly then 
        if type(callback) == 'boolean' then
            callback = nil
        end
        self:changeLevelMoleWeekly( level, callback )
    else
	    -- body
	    self:changeLevelNormal(level, callback)
    end
end

function TileDigJewel:changeLevelNormal( level, callback )
    -- body
	local index = 0
	self.level = level
	if self.frontCloud then
		local index = self.frontCloud:getParent():getChildIndex(self.frontCloud)
		self.frontCloud:removeFromParentAndCleanup(true)
	end

	if level > 0 then 
		local nameStr = "dig_jewel_front_0000"
		if level == 2 then 
			nameStr = "dig_jewel_front_0001"
		elseif level == 3 then
			nameStr = "dig_jewel_front_0002"
		end
		self.frontCloud = Sprite:createWithSpriteFrameName(nameStr)
		if self.jewelType == JewelType.kBell and level > 1 then
			if leve == 2 then
				self.frontCloud:setScaleY(0.95)
			else
				self.frontCloud:setScaleY(0.8)
				self.frontCloud:setPosition(ccp(0, -5))
			end
		end
		if index > 0 then
			self:addChildAt(self.frontCloud, index)
		else
			self:addChild(self.frontCloud)
		end
	end
	
	if level == 2 then 
		self:playlevel3ExplorAnimation()
	elseif level == 1 then 
		self:playLevel2ExplorAnimation()
	elseif level == 0 then 
		self:playLevel1ExplorAnimation(callback);
	end
end

function TileDigJewel:playLightCircleAnimation( ... )
	-- body
	self.light_cirlce:setVisible(true)
	local time = 0.5
	local action_fadein = CCFadeIn:create(time)
	local action_rotateby = CCRotateBy:create(3 * time, 180)
	local action_fadeout = CCFadeOut:create(time)
	local action_sequence = CCSequence:createWithTwoActions(action_fadein, action_fadeout)
	local action = CCSpawn:createWithTwoActions(action_sequence, action_rotateby)
	local function localCallback( ... )
		-- body
		self.light_cirlce:setVisible(false)
	end 
	local action_result = CCSequence:createWithTwoActions(action, CCCallFunc:create(localCallback))
	self.light_cirlce:runAction(action_result)

end

function TileDigJewel:playlevel3ExplorAnimation( callback )
	-- body
	local cloud_fly = Sprite:createWithSpriteFrameName("dig_cloud_fly_animation_0000")
	self:addChild(cloud_fly)
	local characterPattern = "dig_cloud_fly_animation_%04d"
	local numFrames = 20
	local frames = SpriteUtil:buildFrames(characterPattern, 0, numFrames)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	local function finsishCallback( ... )
		-- body
		if cloud_fly then cloud_fly:removeFromParentAndCleanup(true) end
		if callback and type(callback) == "function" then 
			callback()
		end
	end
	cloud_fly:play(animate, 0, 1, finsishCallback)
end

function TileDigJewel:playLevel2ExplorAnimation( callback )
	-- body
	local cloud_fly = Sprite:createWithSpriteFrameName("dig_cloud_fly_animation_0000")
	self:addChild(cloud_fly)
	cloud_fly:setPosition(ccp(0,- GamePlayConfig_Tile_Width / 4))
	local characterPattern = "dig_cloud_fly_animation_%04d"
	local numFrames = 20
	local frames = SpriteUtil:buildFrames(characterPattern, 0, numFrames)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	local function finsishCallback( ... )
		-- body
		if cloud_fly then cloud_fly:removeFromParentAndCleanup(true) end
		if callback and type(callback) == "function" then 
			callback()
		end
	end
	cloud_fly:play(animate, 0, 1, finsishCallback)
	self:playLightCircleAnimation()
end

function TileDigJewel:playLevel1ExplorAnimation( callback )
	-- body
	if self.frontCloud then self.frontCloud:removeFromParentAndCleanup(true) end

	local time = 0.5
	local jewel = self.jewel
	self:playLightCircleAnimation()
	if jewel then jewel:stopAllActions() jewel:setRotation(0) end
	local function localCallback( ... )
		-- body
		if jewel then jewel:removeFromParentAndCleanup(true) end
	end 
	local action_jump = CCJumpBy:create(time / 2, ccp(0, 0), GamePlayConfig_Tile_Width/5, 1)
	local action_callback = CCCallFunc:create(localCallback)
	local array = CCArray:create()
	array:addObject(action_jump)
	array:addObject(CCDelayTime:create(0.5))
	array:addObject(action_callback)
	local action_result = CCSequence:create(array)
	jewel:runAction(action_result)
	self.bgCloud:setVisible(false)
	self:playCloudDisappearAnimation(callback)

end

function TileDigJewel:playCloudDisappearAnimation( afterAnimationCallback )
	-- body
	local sprite_name = "dig_cloud_0000"
	local container = Sprite:createEmpty()
	container:setTexture(self.parentTexture)
	for k = 1, 8 do 
		local sprite = Sprite:createWithSpriteFrameName(sprite_name)
		local angle = (k-1) * 360/8   ----------角度
		local radian = angle * math.pi / 180
	
		sprite:setScale(0.8)
		sprite:setAnchorPoint(ccp(0.5,0.5))
		local time_spaw = 0.5
		local action_move_1 = CCMoveBy:create(time_spaw/2, ccp(math.sin(radian) * 2 *GamePlayConfig_Tile_Width/3 , math.cos(radian) * 2 *GamePlayConfig_Tile_Width/3  ))
		local action_scale = CCScaleTo:create(time_spaw/2,1)
		local action_spaw_1 = CCSpawn:createWithTwoActions(action_move_1, action_scale)
		
		local action_fadeout = CCFadeOut:create(time_spaw * 2)
		local action_move_2 = CCMoveBy:create(time_spaw * 2, ccp(math.sin(radian) * GamePlayConfig_Tile_Width/10 , math.cos(radian) * GamePlayConfig_Tile_Width/10  ))
		local action_scale_2 = CCScaleTo:create(time_spaw * 2, 0.5)
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
	end
	local function callback( ... )
		-- body
		container:removeFromParentAndCleanup(true)
		if afterAnimationCallback and type(afterAnimationCallback) == "function" then 
			afterAnimationCallback()
		end
	end

	self:addChildAt(container,0)
	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.25), CCCallFunc:create(callback)))
end