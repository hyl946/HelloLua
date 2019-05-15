TileMoleBossCloud = class(CocosObject)

local kCharacterAnimationTime = 1/30
local animationList = table.const
{
	kNormal = 0,
	kHit = 1,
	kDestroy = 2,
}
local gressDelayTime = 3

function TileMoleBossCloud:create()
	local node = TileMoleBossCloud.new(CCNode:create())
	node.bossType = WeeklyBossType.kBoss5
	node:init()
	return node
end

function TileMoleBossCloud:init()
	self.level = MoleWeeklyRaceParam.SKILL_CLOUD_HP
    self.oldlevel = self.level

    self.gress4_base = Sprite:createWithSpriteFrameName("gress4_base.png")
    self.gress4_base:setAnchorPoint(ccp(0.5,0.5))
    self:addChildAt( self.gress4_base, 1 )

    self:initDiamond()
	self:initBG( self.level, true )
	self:normal()
    self:createDiamondStar()
end

function TileMoleBossCloud:initBG( level, bIsNormal )

    if self.bgCloud then
		self.bgCloud:removeFromParentAndCleanup(true)
        self.bgCloud = nil
	end

    self.bgCloud = Sprite:createWithSpriteFrameName("gress4_gress_0.png")
    self.bgCloud:setAnchorPoint(ccp(0,0))

    self.bgCloud:setPosition(ccp(-90.5+11,-114+5)) 
    self:addChildAt( self.bgCloud, 4 )
end

function TileMoleBossCloud:createDiamondStar()
    local gress_diamondStar = Sprite:createWithSpriteFrameName("gress4_staranim_0.png")
    gress_diamondStar:setPosition( ccp(-21,20) )
--    gress_diamondStar:setScale(1.62)

    local frames = SpriteUtil:buildFrames("gress4_staranim_".."%d.png", 0, 49)
    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    gress_diamondStar:play( animate, 0, -1  )
    
    self:addChildAt( gress_diamondStar, 3 )
end

function TileMoleBossCloud:initDiamond( )
    self.gress4_diamond = Sprite:createWithSpriteFrameName("gress4_diamond.png")
    self.gress4_diamond:setAnchorPoint(ccp(0.5284,0.236))
    self.gress4_diamond:setPosition( ccp(17.5+64-152/2,12+27-153/2))
    self:addChildAt( self.gress4_diamond, 2 )

--    self:DiamondNormal()
end

function TileMoleBossCloud:DiamondNormal( )
    
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


    self.gress4_diamond:setRotation(0)
--    self.gress4_diamond:stopAllActions()
--    self.gress4_diamond:runAction( CCRepeatForever:create( sequence ) )

    return sequence
end

function TileMoleBossCloud:DiamondAttack( )

    local delayTime = 15*kCharacterAnimationTime
    local rotateTime = {5*kCharacterAnimationTime,4*kCharacterAnimationTime,3*kCharacterAnimationTime,3*kCharacterAnimationTime}

    local targetedActions = CCArray:create()

    local delay = CCDelayTime:create(delayTime)
    local rotate = CCRotateBy:create( 4*kCharacterAnimationTime, 7.2)

    local rotate1 = CCRotateBy:create( 4*kCharacterAnimationTime, -3.7)
    local moveby1 = CCMoveBy:create( 4*kCharacterAnimationTime, ccp(0,27.2))
    local spawnMoveScale1		= CCSpawn:createWithTwoActions(rotate1, moveby1)

    local rotate2 = CCRotateBy:create( 3*kCharacterAnimationTime, -7.4)
    local moveby2 = CCMoveBy:create( 3*kCharacterAnimationTime, ccp(0,-27.2))
    local spawnMoveScale2		= CCSpawn:createWithTwoActions(rotate2, moveby2)

    local rotate3 = CCRotateBy:create( 3*kCharacterAnimationTime, 3.9)

    targetedActions:addObject(rotate)
    targetedActions:addObject(spawnMoveScale1)
    targetedActions:addObject(spawnMoveScale2)
    targetedActions:addObject(rotate3)

    function Finished()
--        self:DiamondNormal()
    end

    local callback = CCCallFunc:create(Finished)
    targetedActions:addObject(callback)

    local sequence = CCSequence:create(targetedActions)

    self.gress4_diamond:setRotation(0)
    self.gress4_diamond:stopAllActions()
    self.gress4_diamond:runAction( sequence )
end

function TileMoleBossCloud:DiamondDead( Diamond )

    local delayTime = 15*kCharacterAnimationTime
    local rotateTime = {5*kCharacterAnimationTime,4*kCharacterAnimationTime,3*kCharacterAnimationTime,3*kCharacterAnimationTime}

    local targetedActions = CCArray:create()

--    local delay = CCDelayTime:create(delayTime)
--    local rotate = CCRotateBy:create( 4*kCharacterAnimationTime, 7.2)

    local rotate1 = CCRotateBy:create( 7*kCharacterAnimationTime, 16.5)
    local moveby1 = CCMoveBy:create( 7*kCharacterAnimationTime, ccp(0,50))
    local spawnMoveScale1		= CCSpawn:createWithTwoActions(rotate1, moveby1)

    local moveby2 = CCMoveBy:create( 5*kCharacterAnimationTime, ccp(0,-50))

    local fadeOut = CCFadeOut:create( 3*kCharacterAnimationTime)

    targetedActions:addObject(spawnMoveScale1)
    targetedActions:addObject(moveby2)
    targetedActions:addObject(fadeOut)

    function Finished()
        Diamond:removeFromParentAndCleanup(true)
    end

    local callback = CCCallFunc:create(Finished)
    targetedActions:addObject(callback)

    local sequence = CCSequence:create(targetedActions)

    Diamond:setRotation(0)
    Diamond:stopAllActions()
    Diamond:runAction( sequence )
end

function TileMoleBossCloud:normal()
	if self.currentAnimation == animationList.kNormal then return end
	self.currentAnimation = animationList.kNormal

    local level = self.level

    local path = "gress4_gress_%d.png"

    local startFrame = 0
    local FrameNum = 0
    if level == 1 then
        FrameNum = 182-155
        startFrame = 154
    elseif level == 2 then
        FrameNum = 132-99
        startFrame = 98
    elseif level == 3 then
        FrameNum = 77-53
        startFrame = 52
    elseif level == 4 then
        FrameNum = 30-1
        startFrame = 0
    end

    -- body
--    local frames = SpriteUtil:buildFrames(path, 0, FrameNum)
--    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

    self:initBG( level, true )
--	self.bgCloud:play( animate, 0, -1 )

    local content = self.bgCloud
    function onRunAnimation ()

        function onRepeatFinishCallback ()
        end

        local frames = SpriteUtil:buildFrames(path, startFrame, FrameNum)
        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
        content:play( animate, 0, 1, onRepeatFinishCallback, false  )

        if self.gress4_diamond and self.gress4_diamond.refCocosObj  then
            local action = self:DiamondNormal( self.gress4_diamond )
            self.gress4_diamond:stopAllActions()
            self.gress4_diamond:runAction( action )
        end
    end

    local Sequence = CCSequence:createWithTwoActions(CCCallFunc:create(onRunAnimation),CCDelayTime:create(gressDelayTime))

    self.bgCloud:runAction( CCRepeatForever:create( Sequence ) )
end

function TileMoleBossCloud:hit(currentBlood, callback)
	local function animationComplete()
		if callback then callback() end
		self:normal()
	end

	local maxHP = MoleWeeklyRaceParam.SKILL_CLOUD_HP

	if self.level > maxHP then
		if callback then callback() end
	else
		-- GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyBossHit)
		self.level = currentBlood
		if self.level > maxHP then
			self.level = maxHP
		end
		self.currentAnimation = animationList.kHit


        local aniTime = kCharacterAnimationTime
        local temp = self.oldlevel - self.level
        if temp > 0 then
            aniTime = kCharacterAnimationTime/temp
        end

		self:attack(animationComplete, aniTime, true)
	end
end

function TileMoleBossCloud:attack( done, aniTime, bFirst )

    --如果直接死的 直接播草地破碎
    if self.level == 0 then
        self.oldlevel = 1
    end

    local path = "gress4_gress_%d.png"

    local startFrame = 0
    local FrameNum = 0
    if self.oldlevel == 1 then
        startFrame = 182
        FrameNum = 223-183
    elseif self.oldlevel == 2 then
        startFrame = 132
        FrameNum = 154-133
    elseif self.oldlevel == 3 then
        startFrame = 77
        FrameNum = 98-78
    elseif self.oldlevel == 4 then
        startFrame = 30
        FrameNum = 52-31
    end

	local frames = SpriteUtil:buildFrames(path, startFrame, FrameNum)
    animate = SpriteUtil:buildAnimate(frames, aniTime)

    function BoomEnd()
       
        self.oldlevel = self.oldlevel - 1

        if self.oldlevel ~= self.level  then
            self:attack( done, aniTime, false )
        else
            if self.level > 0 then
                self:normal()
            else
                if self.bgCloud then
		            self.bgCloud:removeFromParentAndCleanup(true)
	            end

                if self.gress4_base then
		            self.gress4_base:removeFromParentAndCleanup(true)
	            end

                if self.gress4_diamond then
		            self.gress4_diamond:removeFromParentAndCleanup(true)
	            end
            end

            if done then done() end
        end
	end

    self:initBG( self.oldlevel, false )
	self.bgCloud:play( animate, 0, 1, BoomEnd, false )

    if self.oldlevel == 1 then
        self.gress4_base:setVisible(false)
        self.gress4_diamond:setVisible(false)


        local DiamondDead =  Sprite:createWithSpriteFrameName("gress4_diamond.png")
        DiamondDead:setAnchorPoint(ccp(0.5284,0.236))
        DiamondDead:setPosition( ccp(17.5+64-152/2,12+27-153/2))
        self:addChildAt( DiamondDead, 4 )

        self:DiamondDead( DiamondDead )
    end


    --花瓣
    if self.oldlevel - self.level == 1 and self.level ~= 0 then

        local gressPart = Sprite:createWithSpriteFrameName("gress4_gresspiece_0.png")
        gressPart:setAnchorPoint(ccp(0,0))
        gressPart:setPosition(ccp(0-152/2,20-153/2))
        self:addChildAt( gressPart, 5 )
        
        local frames = SpriteUtil:buildFrames("gress4_gresspiece_%d.png", 0, 22)
        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

        function parAniEnd()
            
	    end
	    gressPart:play( animate, 0, 1, parAniEnd, true )
    end

    if bFirst then
         --宝石挨打
        self:DiamondAttack()
    end
end

function TileMoleBossCloud:destroy(callback)
	local function animationComplete()
		if callback then callback() end
	end
	self.currentAnimation = animationList.kDestroy

    self.level = 0
    self:attack( animationComplete, kCharacterAnimationTime,false )
end
