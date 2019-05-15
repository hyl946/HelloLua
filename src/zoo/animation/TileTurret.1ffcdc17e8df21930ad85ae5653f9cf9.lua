TileTurret = class(Sprite)

TileTurretConst = table.const {
	turretMaxLevel = 2
}

local kCharacterAnimationTime = 1/30
local TurretScale = 0.9

function TileTurret:create(turretturretDir, turretIsTypeRandom, turretLevel, isSuper)
	local tile = TileTurret.new(CCSprite:create())
	tile:init(turretturretDir, turretIsTypeRandom, turretLevel, isSuper)
	return tile
end

function TileTurret:init(turretDir, isTypeRandom, turretLevel, isSuper)
	-- printx(11, "TileTurret:init params:", turretDir, isTypeRandom, turretLevel, isSuper)

	self.turretDir = tonumber(turretDir)
	self.turretLevel = turretLevel + 1	--素材level从1开始
	self.isSuper = isSuper
    self.CurIsSuper = isSuper
	self.rotation = 90 * (turretDir - 1)

	self.stoneSpriteContainer = Sprite:createEmpty()
	self.stoneSpriteContainer:setAnchorPoint(ccp(0.5, 0.5))
--	self.stoneSpriteContainer:setRotation(self.rotation)
	self:addChildAt(self.stoneSpriteContainer, 0)

	self:updateStoneSprite()
end

function TileTurret:updateStoneSprite()
	if self.stoneSprite and not self.stoneSprite.isDisposed then
		self.stoneSprite:removeFromParentAndCleanup(true)
	end

    if self.superEffect and not self.superEffect.isDisposed then
		self.superEffect:removeFromParentAndCleanup(true)
	end

	local stoneSprite = self:createStoneWithLevel()
	self.stoneSpriteContainer:addChild(stoneSprite)

	self.stoneSprite = stoneSprite
end

function TileTurret:getAssetPrefix()
	local assetPrefix = "blocker_turret_1_"
	if self.isSuper then
		assetPrefix = assetPrefix.."super".."_"
	end
	return assetPrefix
end

function TileTurret:getAssetPath( Dir, level, isSuper)
    --- Dir 1234代表上右下左
    local DirName = { 'up','right','down','right'}

    local path = ""
    local EffetNum = 0
    if level == 1 then
        path = 'turret_'..DirName[Dir]..'_normal'
    elseif level == 2 then
        if isSuper then
            path = 'turret_'..DirName[Dir]..'_special_Ready_'
        else
            path = 'turret_'..DirName[Dir]..'_ready_'
        end
        EffetNum = 29
    else
        --default
        path = 'turret_'..DirName[Dir]..'_normal'
    end

	return path, EffetNum
end

function TileTurret:createStoneWithLevel()

    --- Dir 1234代表上右下左
    local DirName = { 'up','right','down','right'}

    local Path = ""
    local EffectNum = 0

    if self.setDisabledView then
        Path = 'turret_'..DirName[self.turretDir]..'_dark'
    else
        Path, EffectNum = self:getAssetPath( self.turretDir, self.turretLevel, self.isSuper )
    end

    local ResPath = ""
    if EffectNum == 0 then
        ResPath = Path..".png"
    else
        ResPath = Path.."0.png"
    end

	local sprite = Sprite:createWithSpriteFrameName(ResPath)
    sprite:setScale(TurretScale)

    if EffectNum ~= 0 then
        local frames = SpriteUtil:buildFrames(Path.."%d.png", 0, EffectNum)
	    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	    sprite:play( animate,0,-1 )
    end

    if self.isSuper then
        local upgradeEffectAnimation = Sprite:createWithSpriteFrameName("turret_specialstar_0.png")
        upgradeEffectAnimation:setPosition(ccp(0,0)) 
        self.stoneSpriteContainer:addChildAt( upgradeEffectAnimation, 2 )
        
        local frames = SpriteUtil:buildFrames("turret_specialstar_".."%d.png", 0, 19)
	    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	    upgradeEffectAnimation:play( animate,0,-1 )

        self.superEffect = upgradeEffectAnimation
    else
        
    end

    --pos
    local posOffset = ccp(0,0)
    if self.turretDir == 1 then
        if self.setDisabledView then
            posOffset = ccp( 1, -3 )
        else
            if self.turretLevel == 1 then
                posOffset = ccp( 1, -3 )
            elseif self.turretLevel == 2 then

                if self.isSuper then
                    posOffset = ccp( 0.33, 0.83 )
                else
                    posOffset = ccp( 0,0.7 )
                end
            end
        end
    elseif self.turretDir == 2 then

        if self.setDisabledView then
            posOffset = ccp( 1, -4.2 )
        else
            if self.turretLevel == 1 then
                posOffset = ccp( 1, -3 )
            elseif self.turretLevel == 2 then

                if self.isSuper then
                    posOffset = ccp( -0.1, -0.1 )
                else
                    posOffset = ccp( 1, -4.4 )
                end
            end
        end
    elseif self.turretDir == 3 then
        if self.setDisabledView then
            posOffset = ccp( 1, -3.5 )
        else
            if self.turretLevel == 1 then
                posOffset = ccp( 1, -3 )
            elseif self.turretLevel == 2 then

                if self.isSuper then
                    posOffset = ccp( 0,0 )
                else
                    posOffset = ccp( 1.2, -3.2 )
                end
            end
        end
    elseif self.turretDir == 4 then
        if self.setDisabledView then
            posOffset = ccp( 1, -3.5 )
        else
            if self.turretLevel == 1 then
                posOffset = ccp( 1, -3 )
            elseif self.turretLevel == 2 then

                if self.isSuper then
                    posOffset = ccp( 2, 1 )
                else
                    posOffset = ccp( 1, -3.5 )
                end
            end
        end
    end

    
    --横向的翻转就可以了
    if self.turretDir == 4 then
        sprite:setFlipX(true)
    end

    sprite:setPosition( posOffset )
	return sprite
end

function TileTurret:playPreUpgradeAnimation( done )
	-- printx(11, " + + + + + view playPreUpgradeAnimation")

    --- Dir 1234代表上右下左
    local DirName = { 'up','right','down','right'}

    local Path = 'turret_'..DirName[self.turretDir]..'_preturn_'
    local ResPath = Path.."0.png"
    local EffectNum = 7

    if self.stoneSprite and not self.stoneSprite.isDisposed then
		self.stoneSprite:removeFromParentAndCleanup(true)
	end

    if self.superEffect and not self.superEffect.isDisposed then
		self.superEffect:removeFromParentAndCleanup(true)
	end

    local posOffset = ccp( 0,0 )
    if self.turretDir == 1 then
        posOffset = ccp( 1, -3.5 )
    elseif self.turretDir == 2 then
        posOffset = ccp( 1, -3.8 )
    elseif self.turretDir == 3 then
        posOffset = ccp( 1, -3 )
    elseif self.turretDir == 4 then
        posOffset = ccp( 1, -3 )
    end

	local upgradeEffectAnimation = Sprite:createWithSpriteFrameName(ResPath)
    upgradeEffectAnimation:setPosition(posOffset) 
    upgradeEffectAnimation:setScale(TurretScale)
	self:addChildAt(upgradeEffectAnimation, 1)	--1: upper than itemSprite
    if self.turretDir == 4 then
        upgradeEffectAnimation:setFlipX(true)
    end

    local function onAnimationFinished()
        upgradeEffectAnimation:removeFromParentAndCleanup(true) 
--        self:updateStoneSprite()

        if done then done() end
    end

    local frames = SpriteUtil:buildFrames(Path.."%d.png", 0, EffectNum)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    upgradeEffectAnimation:play(animate, 0, 1, onAnimationFinished, true)

--    self.stoneSprite = upgradeEffectAnimation
end

function TileTurret:playSuperPreReadyAnimation( done )
	-- printx(11, " + + + + + view playSuperPreReadyAnimation")

    --- Dir 1234代表上右下左
    local DirName = { 'up','right','down','right'}

    local Path = 'turret_'..DirName[self.turretDir]..'_special_preReady_'
    local ResPath = Path.."0.png"
    local EffectNum = 6

    if self.stoneSprite and not self.stoneSprite.isDisposed then
		self.stoneSprite:removeFromParentAndCleanup(true)
	end

    if self.superEffect and not self.superEffect.isDisposed then
		self.superEffect:removeFromParentAndCleanup(true)
	end

    local posOffset = ccp( 0,0 )
    if self.turretDir == 1 then
        posOffset = ccp(  0.5,0.6 )
    elseif self.turretDir == 2 then
        posOffset = ccp(  -0.3, 0 )
    elseif self.turretDir == 3 then
        posOffset = ccp(  0.5,-0.2 )
    elseif self.turretDir == 4 then
        posOffset = ccp(  2.3,1 )
    end

	local upgradeEffectAnimation = Sprite:createWithSpriteFrameName(ResPath)
    upgradeEffectAnimation:setPosition(posOffset) 
    upgradeEffectAnimation:setScale( TurretScale )
	self:addChildAt(upgradeEffectAnimation, 1)	--1: upper than itemSprite
    upgradeEffectAnimation:setScale(TurretScale)
    if self.turretDir == 4 then
        upgradeEffectAnimation:setFlipX(true)
    end

    local function onAnimationFinished()
        upgradeEffectAnimation:removeFromParentAndCleanup(true) 
        if done then
            done()
        end
    end

    local frames = SpriteUtil:buildFrames(Path.."%d.png", 0, EffectNum)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    upgradeEffectAnimation:play(animate, 0, 1, onAnimationFinished, true)

--    self.stoneSprite = upgradeEffectAnimation
end

function TileTurret:playUpgradeAnimation(toSuper, layer, fromPos )
	-- printx(11, " + + + + + view playUpgradeAnimation")

	if toSuper then self.isSuper = true end

    --- Dir 1234代表上右下左
    local DirName = { 'up','right','down','right'}

    local Path = ""
    local ResPath = ""
    local EffectNum = 0
    local PosOffset = ccp(0,0)

	if self.turretLevel == TileTurretConst.turretMaxLevel then

        if self.isSuper then
		    Path = 'turret_'..DirName[self.turretDir]..'_special_shoot_'
            ResPath = Path.."0.png"
            EffectNum = 16

            if self.turretDir == 1 then
                PosOffset = ccp( 0.69,0 )
            elseif self.turretDir == 2 then
                PosOffset = ccp( 0,0.27 )
            elseif self.turretDir == 3 then
                PosOffset = ccp( 0.4,-1 )
            elseif self.turretDir == 4 then
                PosOffset = ccp( 2,1 )
            end

        else
            Path = 'turret_'..DirName[self.turretDir]..'_shoot_'
            ResPath = Path.."0.png"
            EffectNum = 16

            if self.turretDir == 1 then
                PosOffset = ccp( 1, 2.2 )
            elseif self.turretDir == 2 then
                PosOffset = ccp( 6,-4.5 )
            elseif self.turretDir == 3 then
                PosOffset = ccp( 1.2, -8 )
            elseif self.turretDir == 4 then
                PosOffset = ccp( -4.5,-3.5 )
            end
        end

        self.CurIsSuper = self.isSuper

		self.turretLevel = 1	--升到顶级以后变回1级
		self.isSuper = false
		self.setDisabledView = true

        --开炮
        if self.stoneSprite and not self.stoneSprite.isDisposed then
		    self.stoneSprite:removeFromParentAndCleanup(true)
	    end

        if self.superEffect and not self.superEffect.isDisposed then
		    self.superEffect:removeFromParentAndCleanup(true)
	    end

	    local upgradeEffectAnimation = Sprite:createWithSpriteFrameName(ResPath)
    --	upgradeEffectAnimation:setRotation(self.rotation)
        upgradeEffectAnimation:setPosition( PosOffset )
        upgradeEffectAnimation:setScale(TurretScale)
	    self:addChildAt(upgradeEffectAnimation, 1)	--1: upper than itemSprite

        if self.turretDir == 4 then
            upgradeEffectAnimation:setFlipX(true)
        end

	    local function onAnimationFinished()
            self:updateStoneSprite()
	    end

	    local frames = SpriteUtil:buildFrames(Path.."%d.png", 0, EffectNum)
	    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	    upgradeEffectAnimation:play(animate, 0, 1, onAnimationFinished, true)

        self.stoneSprite = upgradeEffectAnimation


        --爆炸的炮弹轨迹
        self:playShootLineAnimation( layer, fromPos )

	else
		self.turretLevel = self.turretLevel + 1

        if self.turretLevel > TileTurretConst.turretMaxLevel+1 then
            self.turretLevel = TileTurretConst.turretMaxLevel+1
        end

        if self.isSuper then
            function PreEnd() 
                self:updateStoneSprite()
            end
            self:playSuperPreReadyAnimation( PreEnd )
        else
            self:updateStoneSprite()
        end
	end
end

function TileTurret:playShootLineAnimation( ParentLayer, StartPoint)
    local layer = Layer:create()

    local rotate = 0
    if self.CurIsSuper then
        if self.turretDir == 1 then
            PosOffset = ccp( -2.59-2, 136.79 )
            rotate = -90
        elseif self.turretDir == 2 then
            PosOffset = ccp( 137.41,1.41+2 )
            rotate = 0
        elseif self.turretDir == 3 then
            PosOffset = ccp( 2.61+2,-135.27 )
            rotate = 90
        elseif self.turretDir == 4 then
            PosOffset = ccp( -130.21, -1.27-2 )
            rotate = 180
        end

    else
        if self.turretDir == 1 then
            PosOffset = ccp( -8.09+2, 136.07 )
            rotate = -90
        elseif self.turretDir == 2 then
            PosOffset = ccp( 137.61,7.23-2 )
            rotate = 0
        elseif self.turretDir == 3 then
            PosOffset = ccp( 9.11-2, -135.07 )
            rotate = 90
        elseif self.turretDir == 4 then
            PosOffset = ccp( -134.62,-8.09+2 )
            rotate = 180
        end
    end

    local mainBoomSprite = nil
    local animate = nil
    if self.CurIsSuper then
        mainBoomSprite = Sprite:createWithSpriteFrameName("turret_shootline_special_0.png")
        mainBoomSprite:setPosition(ccp(StartPoint.x+PosOffset.x,StartPoint.y+PosOffset.y)) 
        layer:addChildAt( mainBoomSprite, 2 )
        
        local frames = SpriteUtil:buildFrames("turret_shootline_special_".."%d.png", 0, 11)
	    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    else

        mainBoomSprite = Sprite:createWithSpriteFrameName("turret_shootline_0.png")
        mainBoomSprite:setPosition(ccp(StartPoint.x+PosOffset.x,StartPoint.y+PosOffset.y)) 
        layer:addChildAt( mainBoomSprite, 2 )
        
        local frames = SpriteUtil:buildFrames("turret_shootline_".."%d.png", 0, 11)
	    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    end
    mainBoomSprite:setRotation( rotate)

    function BoomEnd()
        layer:removeFromParentAndCleanup(true) 
    end
	mainBoomSprite:play( animate, 0, 1, BoomEnd, true )

    ParentLayer:addChild( layer )
end


function TileTurret:playMainBoomAnimation(endPoint)
    local layer = Layer:create()

    local mainBoomSprite = nil
    local animate = nil
    if self.CurIsSuper then
        mainBoomSprite = Sprite:createWithSpriteFrameName("turret_special_mainboom_0.png")
        mainBoomSprite:setPosition(ccp(endPoint.x-7,endPoint.y+2)) 
        layer:addChildAt( mainBoomSprite, 2 )
        
        local frames = SpriteUtil:buildFrames("turret_special_mainboom_".."%d.png", 0, 20)
	    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    else

        mainBoomSprite = Sprite:createWithSpriteFrameName("turret_mainboom_0.png")
        mainBoomSprite:setPosition(ccp(endPoint.x-7,endPoint.y+2)) 
        layer:addChildAt( mainBoomSprite, 2 )
        
        local frames = SpriteUtil:buildFrames("turret_mainboom_".."%d.png", 0, 19)
	    animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    end

    function BoomEnd()
        layer:removeFromParentAndCleanup(true) 
    end
	mainBoomSprite:play( animate, 0, 1, BoomEnd, true )

    return layer
end

function TileTurret:playHitEffectAnimation(startPoint, endPoint)

    --准星
	local layer = Layer:create()

	local assetPrefix = "turret_target_"
	local animation = Sprite:createWithSpriteFrameName(assetPrefix.."0.png")
	local frames = SpriteUtil:buildFrames(assetPrefix.."%d.png", 0, 13)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

    local function onAnimationFinished()
		layer:removeFromParentAndCleanup(true) 
	end
	animation:play(animate, 0, 2, onAnimationFinished, true)

	animation:setPosition(endPoint)
	animation:setAnchorPoint(ccp(0.5, 0.5))

	layer:addChild(animation)

	return layer
end

function TileTurret:playPiectFly( startPoint, endPoint, delayTime, PieceInedx, done, isSuper )

    local layer = Layer:create()

    --ani
    local assetPrefix = "starHead.png"
	local animation = Sprite:createWithSpriteFrameName(assetPrefix)

    --bezier
    local p1 = ccp(0, 0)
    local p2 = ccp(0.15*(endPoint.x - startPoint.x), 0.85*(endPoint.y - startPoint.y))
    local bezierConfig = ccBezierConfig:new()

    bezierConfig.controlPoint_1 = ccp(startPoint.x +  p2.x, startPoint.y +  p2.y)
        bezierConfig.controlPoint_2 = ccp(startPoint.x +  p2.x, startPoint.y +  p2.y)
    
    bezierConfig.endPosition = ccp(endPoint.x,endPoint.y)

    --action
    local function finishCallback()
        animation:removeFromParentAndCleanup(true) 

        local upgradeEffectAnimation = nil
        local animate = nil
        if isSuper then
            upgradeEffectAnimation = Sprite:createWithSpriteFrameName("turret_special_pieceboom_0.png")
            upgradeEffectAnimation:setPosition(ccp(endPoint.x+5,endPoint.y-2)) 
            layer:addChildAt( upgradeEffectAnimation, 2 )

            local frames = SpriteUtil:buildFrames("turret_special_pieceboom_".."%d.png", 0, 15)
	        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

        else 
            upgradeEffectAnimation = Sprite:createWithSpriteFrameName("turret_pieceboom_0.png")
            upgradeEffectAnimation:setPosition(ccp(endPoint.x,endPoint.y-2)) 
            layer:addChildAt( upgradeEffectAnimation, 2 )

            local frames = SpriteUtil:buildFrames("turret_pieceboom_".."%d.png", 0, 15)
	        animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

        end

        function BoomEnd()
--            upgradeEffectAnimation:removeFromParentAndCleanup(true) 
            layer:removeFromParentAndCleanup(true) 
        end
	    upgradeEffectAnimation:play( animate, 0, 1, BoomEnd, true )

        if done then done(PieceInedx) end
	end

    --60像素0.2m
    local leng = 60
    local lengSpeed = 0.2/leng --1像素的速度

    local PosLength = math.sqrt( (startPoint.x-endPoint.x)*(startPoint.x-endPoint.x) + (startPoint.y-endPoint.y)*(startPoint.y-endPoint.y) )
    local useTime = lengSpeed * PosLength


    function AddPartical()
        local pop = ParticleSystemQuad:create("particle/turret.plist")
        pop:setAutoRemoveOnFinish(true)
        local contentSize = animation:getContentSize()
        pop:setPosition(ccp(contentSize.width/2,contentSize.height/2))
        animation:addChild(pop)
    end

    local actArr = CCArray:create()
    actArr:addObject(CCDelayTime:create(delayTime))
    actArr:addObject(CCCallFunc:create(AddPartical) )
	actArr:addObject(CCBezierTo:create(useTime, bezierConfig))
    actArr:addObject(CCDelayTime:create(0.1))
	actArr:addObject(CCCallFunc:create(finishCallback) )

    animation:setPosition(startPoint)
	animation:runAction(CCSequence:create(actArr))



    layer:addChild(animation)

	return layer
end

function TileTurret:setViewBackToActive()
	self.setDisabledView = false
	self:updateStoneSprite()
end
