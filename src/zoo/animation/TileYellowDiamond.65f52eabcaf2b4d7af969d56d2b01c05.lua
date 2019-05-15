TileYellowDiamond = class(Sprite)


local gressDelayTime = 3
function TileYellowDiamond:create(level, texture)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileYellowDiamond.new(sprite)
	node.parentTexture = texture

	--if _G.isLocalDevelopMode then printx(0, 'RRR  ++++++++++++++++++++++++ TileYellowDiamond:create   levelType = ', levelType) end

    node:createSpriteWeekEx(level)
	node:initLevelweekEx(level)

	return node
end

function TileYellowDiamond:createSpriteWeekEx( level )
    -- body
	if level < 1 or level > 3 then return end

    self.bgCloud = Sprite:createWithSpriteFrameName("gress_normal1.png")
	self.bgCloud:setPosition(ccp(2,-3)) 
	self:addChild(self.bgCloud)
end

function TileYellowDiamond:initLevelweekEx( level )
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
--	        upgradeEffectAnimation:play( animate, 0, 1, onRepeatFinishCallback, false )

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
            local gress_diamond = self:createDiamond( ccp(0.44,0.34))

            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
            if SaijiIndex == 1 then
                gress_diamond:setPosition(ccp(42-2,42-11)) 
            else
                gress_diamond:setPosition(ccp(42-2-4/0.7,42-11)) 
            end

            gress_diamond:setRotation(-16.5)
            self.bgCloud:addChildAt( gress_diamond, 2 )
            self.diamond = gress_diamond

            self:createDiamondStar()
        end
	end
end

function TileYellowDiamond:createDiamondStar()
    local gress_diamondStar = Sprite:createWithSpriteFrameName("gress_starani_0.png")
    gress_diamondStar:setPosition( ccp(30,54) )
    gress_diamondStar:setScale(1)

    local frames = SpriteUtil:buildFrames("gress_starani_".."%d.png", 0, 49)
    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    gress_diamondStar:play( animate, 0, -1  )
    
    self.bgCloud:addChildAt( gress_diamondStar, 3 )
end

function TileYellowDiamond:createDiamond( anchorPoing )

    local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()

    local gress_diamond
    if SaijiIndex == 1 then
        gress_diamond = Sprite:createWithSpriteFrameName("gress_yellow_diamond.png")
    else
        gress_diamond = Sprite:createWithSpriteFrameName("gress_yellow_diamond2.png")
    end

    gress_diamond:setAnchorPoint( anchorPoing )
    gress_diamond:setScale(1)
    
    return gress_diamond
end

function TileYellowDiamond:DiamondNormal( node )
    
    local delayTime = gressDelayTime
    local rotateTime = {5*kCharacterAnimationTime,4*kCharacterAnimationTime,3*kCharacterAnimationTime,3*kCharacterAnimationTime}
    local rotateAngle = 2
	local reverseRotateAngle = -2

    local targetedActions = CCArray:create()

 
    for i=1, 2 do
        local rotate = CCRotateBy:create(rotateTime[(i-1)*2+1], rotateAngle)
	    local rotate2 = CCRotateBy:create(rotateTime[(i-1)*2+2], reverseRotateAngle)
	    targetedActions:addObject(rotate)
        targetedActions:addObject(rotate2)
    end

    local sequence = CCSequence:create(targetedActions)


    node:setRotation(-16.5)
--    node:stopAllActions()
--    node:runAction( sequence )

    return sequence
end

function TileYellowDiamond:DiamondAttack( node )

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


function TileYellowDiamond:changeLevelEx( level, callback )

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
    	    self:initLevelweekEx(level)

            if callback then callback() end
	    end
	    upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, false )

        if level > 0 and level < 3 then
            local gress_diamond = self:createDiamond( ccp(0.44,0.34))

            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
            if SaijiIndex == 1 then
                gress_diamond:setPosition(ccp(42-2,42-11)) 
            else
                gress_diamond:setPosition(ccp(42-2-4/0.7,42-11)) 
            end

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
            upgradeEffectAnimation:removeFromParentAndCleanup(true)
	    end
	    upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, true )

        --宝石飞
        local gress_diamond = self:createDiamond( ccp(0.5,0.5))
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

function TileYellowDiamond:changeLevel( level, callback )

    self.level = level
    if type(callback) == 'boolean' then
        callback = nil
    end
    self:changeLevelEx( level, callback )
end
