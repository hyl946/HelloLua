require "zoo.animation.QixiAnimation"


local kCharacterAnimationTime = 1/26
local kEffectAnimationTime = 1/26
local OFFSET_X, OFFSET_Y = 0, 0

local animationList = table.const
{
    kNone = 0,
    kWating = 1,
    kComeout = 2,
    kDie = 3,
    kHit = 4,
    kRandom = 5,
    kCasting = 6
}

local minPosX = Director:sharedDirector():getVisibleSize().width / 2
local bossTotalProgressDis = 250
local bloodBarfixNum = 40

-- 圣诞节活动boss
-- 因为game mode是halloween，所以叫halloween boss
TileQiXiBoss = class(CocosObject)
function TileQiXiBoss:create()
    local i = TileQiXiBoss.new(CCNode:create())
    i:init()
    return i
end

function TileQiXiBoss:init()
	self.bloodValue = 0
	self.progressValue = 0
    self.body = CocosObject:create()
    self.bossContentWidth = 9*70
    self.bossContentHeight = 150
    --self.body:setContentSize(CCSizeMake(9*70, 150))
    self.body:setAnchorPoint(ccp(0, 0))
    self.body:setPosition(ccp(0,0))
    self:addChild(self.body)
    --self.sprite = Sprite:createWithSpriteFrameName('dragonboat_boss_wander_0000')
    self.sprite = Sprite:createEmpty()
    --self.sprite:setAnchorPoint(ccp(0, 0))
    local testFun = function()
	
	end

	local size = Director:sharedDirector():getVisibleSize()

	--[[
	local testHippo = QixiBoss:build( QixiBossEnum.kHippo , QixiBossState.kWait , testFun )
	testHippo:setPosition(ccp(size.width / 2 , 100))
    testHippo:setScale(0.8)
    self.sprite:addChild(testHippo)
    ]]

    self.hippo = QixiBoss:build( QixiBossEnum.kHippo , QixiBossState.kWait , testFun )
    self.hippo:setPosition(ccp(minPosX - bossTotalProgressDis,110))
    self.hippo:setScale(0.8)
    self.hippo.currProgressX = 0

    self.fox = QixiBoss:build( QixiBossEnum.kFox , QixiBossState.kWait , testFun )
    self.fox:setPosition(ccp(minPosX + bossTotalProgressDis,130))
    self.fox:setScale(0.8)
    self.fox.currProgressX = 0

    self.sprite:addChild(self.fox)
    self.sprite:addChild(self.hippo)
    self.body:addChild(self.sprite)
    self.sprite:setPosition(ccp(0, 20))
    self:createBloodBar()
end

function TileQiXiBoss:getBossSpriteWorldPosition()
    if self.body and self.sprite then
        local worldPos = self.body:convertToWorldSpace(self.sprite:getPosition())
        --printx( 1 , "   PPPPPPPPPPPPPPPPPPPP   worldPos.x = " , worldPos.x)
        local centerPos = ccp(minPosX , worldPos.y)
        return centerPos
    end
    return nil
end

--待机状态
function TileQiXiBoss:playWating(dir)

    if not self.sprite or not self.sprite.refCocosObj then
        return
    end

    self.animate = animationList.kWating

    self.hippo:playWait()
    self.fox:playWait()
end

--被击中状态
function TileQiXiBoss:playHit(fromPosInWorld, callback, isSpecial , hit , totalBlood , index)
    --printx( 1 , "   TileQiXiBoss:playHit   fromPosInWorld = " , fromPosInWorld.x , fromPosInWorld.y)

    local progress = hit / totalBlood
    if progress > 1 then progress = 1 end


    local function localCB()
        --self:playWating(self.dir)
        self.animate = animationList.kWating
        if callback then
            callback()
        end
    end

    local bossPos = self:getBossSpriteWorldPosition()
    local endPos = ccp( bossPos.x + 150 - (300 * math.random()) , bossPos.y + 80 - (160 * math.random()) )
    endPos.y = endPos.y + 100

    local function onQixiAnimationDone(datas)

	    --printx( 1 , "  TileQiXiBoss:playHit  bossTotalProgressDis " , bossTotalProgressDis , "  progress " , progress , "      " , bossTotalProgressDis * progress)
	    --printx( 1 , "  TileQiXiBoss:playHit  hippoNeedMove " , hippoNeedMove , "  foxNeedMove " , foxNeedMove)

	    self.animate = animationList.kHit
	    -- printx( 1 , "  ----------------------  hippo:playHit   hippoNeedMove = " , datas.hippo )
        self.hippo:playHit( datas.hippo , 0.3 , localCB)
        
        -- printx( 1 , "  ----------------------  fox:playHit   foxNeedMove = " , datas.fox * -1 )
    	self.fox:playHit( datas.fox * -1 , 0.3 , nil )

    	QixiAnimation:createExplodeAnimation(endPos , nil)
    end

    local hippoNeedMove = (bossTotalProgressDis - 50) * progress - self.hippo.currProgressX
	local foxNeedMove = (bossTotalProgressDis - 50) * progress - self.fox.currProgressX

	self.hippo.currProgressX = self.hippo.currProgressX + hippoNeedMove
    self.fox.currProgressX = self.fox.currProgressX + foxNeedMove

    QixiAnimation:playFollowStarAnimation( fromPosInWorld , endPos , (0.8 + (0.2 * index)) , onQixiAnimationDone , {hippo=hippoNeedMove,fox=foxNeedMove})
    
end

--鹊桥相会（Boss死亡）  <----艾玛呀这个注释信息量好大-。-
function TileQiXiBoss:playDie(bellNum , bellPos , propNum , propPos , callback)

    if self.animate == animationList.kDie then
        return
    end
    self.animate = animationList.kDie

    self.sprite:stopAllActions()

    local function onFlyAnimFinish(isPropAnim)
    	if isPropAnim then
    		QixiAnimation:createExplodeAnimation(propPos , nil)
    	end

    	if callback then callback(isPropAnim) end
    end

    self.hippo:setVisible(false)
    self.fox:setVisible(false)
    self.bloodEffect_left:setVisible(false)
    self.bloodEffect_right:setVisible(false)
    QixiAnimation:playBossMeetingAnimation(bellNum , bellPos , propNum , propPos , onFlyAnimFinish)
end

--Boss出现动画
function TileQiXiBoss:playComeout(callback)

    if self.animate == animationList.kComeout then
        if callback then callback() end
        return
    end
    self.animate = animationList.kComeout

    self:stopAllActions()
    local function localCB()
        self:playWating(self.dir)
        if callback then
            callback()
        end
    end

    local posX = self.body:getPositionX()
    local posY = self.body:getPositionY()

    self.body:setPositionY(posY - 100)

    local hippoPosX = self.hippo:getPositionX()
	local hippoPosY = self.hippo:getPositionY()
	local foxPosX = self.fox:getPositionX()
	local foxPosY = self.fox:getPositionY()
	self.hippo:setPositionX( hippoPosX - 200 )
	self.fox:setPositionX( foxPosX + 200 )

    local function onAnimeFin2()
    	localCB()
    end

    local function onAnimeFin1()
    	--localCB()
    	----[[
    	self.hippo:runAction( CCMoveTo:create(2, ccp(hippoPosX, hippoPosY)) )
    	self.fox:runAction( CCMoveTo:create(2, ccp(foxPosX, foxPosY)) )

    	TimerUtil.addAlarm( onAnimeFin2, 2.2 , 1 )
    end

    local array = CCArray:create()
    array:addObject(CCMoveTo:create(1, ccp(posX, posY)))
    array:addObject(CCCallFunc:create(onAnimeFin1))
    self.body:runAction(CCSequence:create(array))

    local bossPos = self:getBossSpriteWorldPosition()
    QixiAnimation:createExplodeAnimation( ccp( bossPos.x - 20 , bossPos.y + 150 ) , nil)
end

--Boss释放特效
function TileQiXiBoss:playCasting(destPositions, callback)
    -- if _G.isLocalDevelopMode then printx(0, self.animate) end
    -- debug.debug()?
    if self.animate == animationList.kCasting then
        if callback then callback() end
        return
    end

    if not destPositions or #destPositions < 1 then
        if callback then callback() end
        return
    end
    self.animate = animationList.kCasting

    local count = 0
    local function onAnimationDone()
        count = count + 1
        if count >= #destPositions then
            if callback then
                callback()
            end
        end
    end

    local function playBallsAnim()
        for k,v in pairs(destPositions) do
            local toPos = ccp(v.x , v.y)

            local foxWorldPos = self.fox:convertToWorldSpace(self.fox:getPosition())
            
            QixiAnimation:playFollowStarAnimation( foxWorldPos , toPos , 0.8 , 
            	function () 
            		onAnimationDone()
            		QixiAnimation:createExplodeAnimation( ccp( toPos.x , toPos.y ) , nil)
            	end )
        end
    end

    --self.hippo:playCast()
	self.fox:playCast(playBallsAnim)

	--TimerUtil.addAlarm( playBallsAnim, 2 , 1 )
    --self.sprite:runAction(CCSpawn:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(playBallsAnim)))
end

--创建藤蔓进度条
function TileQiXiBoss:createBloodBar()

	local createBarBG = function(fx)
		local blood = Sprite:createEmpty()

	    local bloodbg_left = Sprite:createWithSpriteFrameName("qixi_boss_bloodbg_0000")
	    local bloodbg_right = Sprite:createWithSpriteFrameName("qixi_boss_bloodbg_0000")

	    --convertToNodeSpace
	    local bloodbgSize = bloodbg_left:getGroupBounds().size
	    bloodbg_left:setAnchorPoint(ccp(1, 0))
	    bloodbg_left:setPosition(ccp( self.bossContentWidth / 2 + bloodBarfixNum , 0))
	    blood:addChild(bloodbg_left)

	    bloodbg_right:setAnchorPoint(ccp( 1 , 0))
	    bloodbg_right:setScaleX(-1)
	    bloodbg_right:setPosition(ccp( self.bossContentWidth / 2 - bloodBarfixNum , 0))
	    blood:addChild(bloodbg_right)
	    

	    local bloodfg_mask_left = Sprite:createWithSpriteFrameName("qixi_boss_bloodbar_mask_0000")
	    local bloodfg_mask_right = Sprite:createWithSpriteFrameName("qixi_boss_bloodbar_mask_0000")
	    local bloodfg_mask = Sprite:createEmpty()

	    bloodfg_mask_left:setAnchorPoint(ccp(1, 0))
	    bloodfg_mask_left:setPosition(ccp( self.bossContentWidth / 2 + bloodBarfixNum , 5 ))

	    bloodfg_mask_right:setAnchorPoint(ccp(1, 0))
	    bloodfg_mask_right:setScaleX(-1)
	    bloodfg_mask_right:setPosition(ccp( self.bossContentWidth / 2 - bloodBarfixNum , 5 ))
	    

	    bloodfg_mask:addChild(bloodfg_mask_left)
	    bloodfg_mask:addChild(bloodfg_mask_right)


	    local bloodfg_left = Sprite:createWithSpriteFrameName("qixi_boss_bloodbar_0000")
	    local bloodfg_right = Sprite:createWithSpriteFrameName("qixi_boss_bloodbar_0000")
	    local bloodfg = Sprite:createEmpty()

	    bloodfg_left:setAnchorPoint(ccp(1, 0))
	    bloodfg_left:setPosition(ccp( self.bossContentWidth / 2 + bloodBarfixNum ,  0 ))

	    bloodfg_right:setAnchorPoint(ccp(1, 0))
	    bloodfg_right:setScaleX(-1)
	    bloodfg_right:setPosition(ccp( self.bossContentWidth / 2 - bloodBarfixNum , 0 ))
	    

	    bloodfg:addChild(bloodfg_left)
	    bloodfg:addChild(bloodfg_right)

	    local clipingnode = ClippingNode.new(CCClippingNode:create(bloodfg_mask.refCocosObj))
	    clipingnode:setPositionX(OFFSET_X)
	    clipingnode:setAlphaThreshold(0.1)

	    --bloodfg_mask:setAnchorPoint(ccp(0, 0))
	    
	    clipingnode:addChild(bloodfg)

	    blood:addChild(clipingnode)
	    
	    blood.bloodfg = bloodfg
	    self.leftBloodBar = bloodfg_mask_left
	    self.rightBloodBar = bloodfg_mask_right

	    
	    local bloodEffect_left = QixiAnimation:createStarShinningAnimation()
	    bloodEffect_left:setPosition(ccp(self.bossContentWidth / 2, 70))
	    blood:addChild(bloodEffect_left)

	    self.bloodEffect_left = bloodEffect_left
	    self.bloodEffect_left:setVisible(true)

	    local bloodEffect_right = QixiAnimation:createStarShinningAnimation()
	    bloodEffect_right:setScaleX(-1)
	    bloodEffect_right:setAnchorPoint(ccp(0, 0))
	    bloodEffect_right:setPosition(ccp(self.bossContentWidth / 2, 70))
	    blood:addChild(bloodEffect_right)

	    self.bloodEffect_right = bloodEffect_right
	    self.bloodEffect_right:setVisible(true)
		
	    blood:setPosition(ccp(0 , -70))
	    return blood
	end
    local bloodBar = createBarBG()

    self.body:addChild(bloodBar)
end

function TileQiXiBoss:setBloodPercent(percent, isPlayAnimation)
    if self.leftBloodBar and self.rightBloodBar and percent then
        if percent > 1 then percent = 1 end
        self.leftBloodBar:stopAllActions()
        self.rightBloodBar:stopAllActions()

        self.bloodEffect_left:stopAllActions()
        self.bloodEffect_right:stopAllActions()

        local leftNewPos = ccp( (percent * (self.bossContentWidth/2 - 80) + 80) , 5)
        local rightNewPos = ccp( 
        	(self.bossContentWidth/2) + (  (1-percent) * (self.bossContentWidth/2 - 80)   ), 
        	5)

        if isPlayAnimation then
            self.leftBloodBar:runAction(CCMoveTo:create(0.5, ccp(leftNewPos.x, leftNewPos.y)))
            self.rightBloodBar:runAction(CCMoveTo:create(0.5, ccp(rightNewPos.x, rightNewPos.y)))

            self.bloodEffect_left:runAction(CCMoveTo:create(0.5, ccp( leftNewPos.x + 10 , 50 + 40*percent)))
            self.bloodEffect_right:runAction(CCMoveTo:create(0.5, ccp( rightNewPos.x - 10 , 50 + 40*percent)))
        else
            self.leftBloodBar:setPosition(leftNewPos)
            self.rightBloodBar:setPosition(rightNewPos)

            self.bloodEffect_left:setPosition(ccp( leftNewPos.x + 10 , 50 + 40*percent))
            self.bloodEffect_right:setPosition(ccp( rightNewPos.x - 10 , 50 + 40*percent))
        end
    end
end

function TileQiXiBoss:getSpriteWorldPosition()
	return self:getBossSpriteWorldPosition()
end

function TileQiXiBoss:setSpriteX(x)
    local pos = ccp(x, 0)
    local realPos = self.body:convertToNodeSpace(pos)
    if realPos.x < 0 then realPos.x = 0 end
    if realPos.x > 7*70 then realPos.x = 7*70 end
    self.sprite:setPositionX(realPos.x)
end

function TileQiXiBoss:buildBossFlyStar(onAnimFinish)
    local starAnim = Sprite:createEmpty()

    local stars = {
        {x=-4, y=-38, dx=1, dy = -190, delay=0, scale = 0.4},
        {x=12, y=-43, dx=-2, dy = -120, delay=0, scale = 0.5},
        {x=-1, y=-65, dx=1, dy = -250, delay=0, scale = 0.4},
        {x=2, y=-43, dx=-1, dy = -160, delay=6 * kEffectAnimationTime, scale = 0.6},
    }
    local animCounter = 0

    local function onAnimComplete()
        animCounter = animCounter - 1
        -- if animCounter == 0 then
        --     if starAnim and starAnim:getParent() then 
        --         starAnim:removeFromParentAndCleanup(true)
        --     end
        --     if onAnimFinish then onAnimFinish() end
        -- end
    end

    for _, v in pairs(stars) do
        animCounter = animCounter + 1
        local star = Sprite:createWithSpriteFrameName("light_fivestar")
        star:setPosition(ccp(v.x, v.y))
        star:setVisible(false)
        if v.scale then
            star:setScale(v.scale)
        end
       
        local starSeq = CCArray:create()
        local delayTime = v.delay or 0
        starSeq:addObject(CCDelayTime:create(delayTime))
        starSeq:addObject(CCCallFunc:create(function() star:setVisible(true) end))
        starSeq:addObject(CCMoveBy:create(11 * kEffectAnimationTime, ccp(v.dx, v.dy)))
        starSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(9 * kEffectAnimationTime, ccp(v.dx, v.dy)), CCFadeOut:create(9 * kEffectAnimationTime)))
        starSeq:addObject(CCCallFunc:create(onAnimComplete))

        star:runAction(CCSequence:create(starSeq))

        starAnim:addChild(star)
    end

    animCounter = animCounter + 1
    local lightSprite = Sprite:createWithSpriteFrameName("light_move")
    lightSprite:setAnchorPoint(ccp(0.5, 1))
    lightSprite:setScale(0.4, 1)
    local lightSeq = CCArray:create()
    lightSeq:addObject(CCScaleTo:create(20 * kEffectAnimationTime, 1, 1))
    lightSeq:addObject(CCCallFunc:create(onAnimComplete))
    lightSprite:runAction(CCSequence:create(lightSeq))

    starAnim:addChild(lightSprite)

    return starAnim
end

function TileQiXiBoss:buildHeartBallAnim(startPos, endPos, completeCallback)
    local anim = Sprite:createWithSpriteFrameName("qixi_boss_comeout_eff_1_0000")

    return anim
end

function TileQiXiBoss:buildWaterBallBreakAnim(onAnimFinish)
    local anim = Sprite:createEmpty()

    local waterBall = Sprite:createWithSpriteFrameName("dragonboat_waterball_break_0000")
    local waterBallAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_waterball_break_%04d", 7, 21), kEffectAnimationTime)
    local function onAnimComplete()
        if anim then anim:removeFromParentAndCleanup(true) end
        if onAnimFinish then onAnimFinish() end
    end
    waterBall:runAction(CCSequence:createWithTwoActions(waterBallAnim, CCCallFunc:create(onAnimComplete)))
    anim:addChild(waterBall)

    return anim
end

function TileQiXiBoss:buildAddMoveLightAnim()
    local anim = Sprite:createEmpty()

    local light = Sprite:createWithSpriteFrameName("dragonboat_addmove_light_0000")
    local lightAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_addmove_light_%04d", 0, 15), kEffectAnimationTime)
    light:runAction(CCRepeatForever:create(lightAnim))
    anim:addChild(light)

    return anim
end

function TileQiXiBoss:buildBloodBarEffect()
    local anim = Sprite:createEmpty()

    local sprite = Sprite:createWithSpriteFrameName("qixi_boss_bloodbar_eff_0000")
    --local spriteAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_bloodbar_effect_%04d", 0, 20), kEffectAnimationTime)
    --sprite:runAction(CCRepeatForever:create(spriteAnim))
    anim:addChild(sprite)

    return anim
end

function TileQiXiBoss:buildHalloweenBoss()
    local bossSprite = Sprite:createWithSpriteFrameName("qixi_boss_tileIcon_0000")
    return bossSprite
end