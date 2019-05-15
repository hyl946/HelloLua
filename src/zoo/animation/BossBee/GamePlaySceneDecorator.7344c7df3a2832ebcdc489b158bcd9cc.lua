require 'zoo.animation.BossBee.BossBeeArmature'
require 'zoo.animation.BossBee.GamePlayRainbow'
local UIHelper = require 'zoo.panel.UIHelper'

local FlyLightLine = require 'zoo.animation.BossBee.FlyLightLine'


local BossBeeController = class()

local BossType = {
    "breath",
    "appear",
    "hit",
    "laugh",
    "attack",
    "die",
    "strike",
    "flag",
    "flagd",
}

function BossBeeController:create(playUI, bossLayer, BossLevel, HPLayer, BossPosInGameBGNode, upBgScale )
    local instance = BossBeeController.new()
    instance:init(playUI, bossLayer, BossLevel,HPLayer, BossPosInGameBGNode, upBgScale )
    return instance
end

function BossBeeController:init(playUI, bossLayer, BossLevel, HPLayer, BossPosInGameBGNode, upBgScale )

    self.playUI = playUI
    self.bossLayer = bossLayer
    self.HPLayer = HPLayer
    self.BossLevel = BossLevel
    self.upBgScale = upBgScale

    self.idlePause = false

    self.currentX = 0

    self.BossPosInGameBGNode = BossPosInGameBGNode

    self.CastCallBackList = {}

    self.BossDieTime = 0

    --点击BOSS
    local function onTouchTap( evt )
		--
        self:BossDiamondTipShow()
	end

    local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(260, 220)
	colorLayer:setColor(ccc3(255, 255, 255))
	colorLayer:setOpacity(0)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition( ccp(self.BossPosInGameBGNode.x-131*self.upBgScale, self.BossPosInGameBGNode.y+60*self.upBgScale) )
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	bossLayer:addChild(colorLayer)

    --BOSS
    local node = nil
    if BossLevel == 1 then
        node = gAnimatedObject:createWithFilename("gaf/MoleWeekly_Boss/boss1/boss1.gaf")
        node:setPosition(ccp(self.BossPosInGameBGNode.x+5/0.7*self.upBgScale,self.BossPosInGameBGNode.y+91/0.7*self.upBgScale))
    elseif BossLevel == 2 then
        node = gAnimatedObject:createWithFilename("gaf/MoleWeekly_Boss/boss2/boss2.gaf")
        node:setPosition(ccp(self.BossPosInGameBGNode.x+5/0.7*self.upBgScale,self.BossPosInGameBGNode.y+91/0.7*self.upBgScale))
    elseif BossLevel == 3 then
        node = gAnimatedObject:createWithFilename("gaf/MoleWeekly_Boss/boss3/boss3.gaf")
        node:setPosition(ccp(self.BossPosInGameBGNode.x+5/0.7*self.upBgScale,self.BossPosInGameBGNode.y+91/0.7*self.upBgScale))
    elseif BossLevel == 4 then
        node = gAnimatedObject:createWithFilename("gaf/MoleWeekly_Boss/boss4/boss4.gaf")
        node:setPosition(ccp(self.BossPosInGameBGNode.x+5/0.7*self.upBgScale,self.BossPosInGameBGNode.y+91/0.7*self.upBgScale))
    end

    node:setScale( upBgScale )
    bossLayer:addChildAt(node,5)

    self.BossNode = node

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()


    self.BossAllHP = 0

    self.Process = 1

        
    --小白旗内容
    if not self.bossLayer.BossDieTipLayer then
        self:initBossDieTip()
    end

     --宝石袋内容
    if not self.bossLayer.BossBagTipLayer then
        self:initBossBagTip()
    end
    
    local cuteInterval = 20
    local function cuteTimerCallback()
        if not playUI or playUI.isDisposed then return end
        self:playCute()
    end
    if self.cuteSchedId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.cuteSchedId)
        self.cuteSchedId = nil
    end
    self.cuteSchedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(cuteTimerCallback, cuteInterval, false)
end

function BossBeeController:dispose()
    if self.cuteSchedId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.cuteSchedId)
        self.cuteSchedId = nil
    end
end

function BossBeeController:getHummerPos()
    local pos = ccp( self.BossPosInGameBGNode.x, self.BossPosInGameBGNode.y)

    pos.x =  pos.x+(93+26/0.7)*self.upBgScale
    pos.y =  pos.y+(264)*self.upBgScale

    return pos
end

function BossBeeController:BossDiamondTipShow()
    
--    local mainLogic = GameBoardLogic:getCurrentLogic()
--    local bossData = mainLogic:getMoleWeeklyBossData()
--    if not bossData then
--        return 
--    end


--    --显示tip
--    if not self.bossLayer.BossDiamondTipLayer then
--        self:initBossDiamondTip()
--    end

--    local bShow = self.bossLayer.BossDiamondTipLayer:isVisible()
--    if bShow == false then

--        local layer = self.bossLayer.BossDiamondTipLayer
--        function MoveOut()
--            layer:setVisible(false)
--        end

--        self:updateBossDiamondTip()

--        local array = CCArray:create()
--	    array:addObject( CCScaleTo:create(0.2, 1.2) )
--        array:addObject( CCScaleTo:create(0.2, 1) )
--        array:addObject( CCDelayTime:create(3) )
--	    array:addObject( CCScaleTo:create(0.3, 0) )
--        array:addObject( CCCallFunc:create( MoveOut ) )

--	    layer:setScale(0)
--	    layer:runAction(CCSequence:create(array))

--        layer:setVisible(true)
--    end

end

function BossBeeController:initBossDiamondTip()
--    local bossPos = self.BossNode:getPosition()


--    local sprite = Sprite:createWithSpriteFrameName("MoleWeekly_BossDiamondBg.png")
--    sprite:setAnchorPoint( ccp(0,1) )
--    sprite:setPosition( ccp( bossPos.x+100, bossPos.y+75 )  )
--    self.HPLayer:addChild( sprite )
--    sprite:setVisible(false)

--    local label1 = BitmapText:create( "打败我可领" ,"fnt/tutorial_white.fnt")
--    label1:setPositionY( 32 )
--    label1:setAnchorPoint(ccp(0.5, 0.5))
--    label1:setColor(ccc3(0, 0, 0))
--    label1:setScale(0.6)
--    sprite:addChild(label1)

--    local DiamondSprite = Sprite:createWithSpriteFrameName("MoleWeekly_target.png")
--    DiamondSprite:setScale(0.5)
--    DiamondSprite:setPositionY( 32 )
--    DiamondSprite:setAnchorPoint(ccp(0.5, 0.5))
--    sprite:addChild( DiamondSprite )

--    local label2 = BitmapText:create( "" ,"fnt/target_amount.fnt")
--    label2:setPositionY( 32 )
----    label2:setColor(ccc3(0, 0, 0))
--    label2:setAnchorPoint(ccp(0.5, 0.5))
--    label2:setScale(0.8)
--    sprite:addChild(label2)

--    sprite.Label1 = label1
--    sprite.DiamondSprite = DiamondSprite
--    sprite.Label2 = label2
--    self.bossLayer.BossDiamondTipLayer = sprite
end

function BossBeeController:updateBossDiamondTip()

    local CanGetNum = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local bossData = mainLogic:getMoleWeeklyBossData()
    if bossData  then
        CanGetNum = bossData.dropItemsOnDie
    end

    local TipLayer = self.bossLayer.BossDiamondTipLayer
    local label1 = TipLayer.Label1
    local DiamondSprite = TipLayer.DiamondSprite
    local label2 = TipLayer.Label2

    label2:setText( "x"..CanGetNum )

    local label1Width = label1:getContentSize().width * label1:getScale()
    local DiamondSpriteWidth = DiamondSprite:getContentSize().width * DiamondSprite:getScale()
    local label2Width = label2:getContentSize().width * label2:getScale()
    local startPos = 14
    local BarWidth = 223 
    local MiddlePos = startPos + BarWidth/2

    local AllWidth = label1Width + 5 + DiamondSpriteWidth + 5 + label2Width

    label1:setPositionX( MiddlePos -AllWidth/2 + label1Width/2 )
    DiamondSprite:setPositionX( MiddlePos -AllWidth/2 + label1Width + 5 + DiamondSpriteWidth/2 )
    label2:setPositionX( MiddlePos -AllWidth/2 + label1Width + 5 + DiamondSpriteWidth + label2Width/2 )
end

--小白旗上的字
function BossBeeController:initBossDieTip()
    
    --根据BOSS位置 算出旗子大概位置
    local bossPos = self.BossNode:getPosition()

    local sprite = Sprite:createEmpty()
    sprite:setAnchorPoint( ccp(0.5,0.5) )
    sprite:setPosition( ccp( bossPos.x+(100-75/0.7)*self.upBgScale, bossPos.y+(75-26/0.7)*self.upBgScale )  )
    self.bossLayer:addChild( sprite )
--    sprite:setRotation( 2.8 )
    sprite:setScale( self.upBgScale )
    sprite:setVisible(false)

--    local label1 = BitmapText:create( "下个地鼠掉落" ,"fnt/tutorial_white.fnt")
--    label1:setPositionY( 32 )
--    label1:setPositionX( 0 )
--    label1:setAnchorPoint(ccp(0.5, 0.5))
--    label1:setColor(ccc3(0, 0, 0))
--    label1:setScale(0.6)
--    sprite:addChild(label1)

    local label1 = Sprite:createWithSpriteFrameName("MoleWeekly_nextbosstip.png")
    label1:setScale(1)
    label1:setPositionY( 32 )
    label1:setPositionX( 0 )
    label1:setAnchorPoint(ccp(0.5, 0.5))
    sprite:addChild( label1 )

    local DiamondSprite = Sprite:createWithSpriteFrameName("MoleWeekly_bosshavetarget.png")
    DiamondSprite:setScale(1)
    DiamondSprite:setPositionY( 0 )
    DiamondSprite:setPositionX( -11/0.7 )
    DiamondSprite:setAnchorPoint(ccp(0.5, 0.5))
    sprite:addChild( DiamondSprite )

    local label2 = BitmapText:create( "" ,"fnt/target_amount.fnt")
    label2:setPositionY( -4/0.7 )
    label2:setPositionX( -7/0.7 )
    label2:setAnchorPoint(ccp(0, 0.5))
    label2:setScale(0.8)
    sprite:addChild(label2)

    sprite.Label1 = label1
    sprite.DiamondSprite = DiamondSprite
    sprite.Label2 = label2
    self.bossLayer.BossDieTipLayer = sprite



end

function BossBeeController:updateBossDieTip()
    local CanGetNum = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local bossData = MoleWeeklyRaceConfig.genNewBoss(mainLogic) --获取新BOSS属性。但是不走创建BOSS

    if bossData  then
        CanGetNum = bossData.demolishReward
    end

    local TipLayer = self.bossLayer.BossDieTipLayer
--    local label1 = TipLayer.Label1
--    local DiamondSprite = TipLayer.DiamondSprite
    local label2 = TipLayer.Label2

    label2:setText( "x"..CanGetNum )

----    local label1Width = label1:getContentSize().width * label1:getScale()
--    local DiamondSpriteWidth = DiamondSprite:getContentSize().width * DiamondSprite:getScale()
--    local label2Width = label2:getContentSize().width * label2:getScale()
--    local startPos = 14
--    local BarWidth = 223 
--    local MiddlePos = 0 --startPos + BarWidth/2

----    local AllWidth = label1Width + 5 + DiamondSpriteWidth + 5 + label2Width

--    local AllWidth =  DiamondSpriteWidth + 5 + label2Width

----    label1:setPositionX( MiddlePos -AllWidth/2 + label1Width/2 )
--    DiamondSprite:setPositionX( MiddlePos -AllWidth/2 + DiamondSpriteWidth/2 )
--    label2:setPositionX( MiddlePos -AllWidth/2 + DiamondSpriteWidth + 5 + label2Width/2  )
end

--宝石袋上的字
function BossBeeController:initBossBagTip()
    
    --根据BOSS位置 算出旗子大概位置
    local bossPos = self.BossNode:getPosition()

    local sprite = Sprite:createEmpty()
    sprite:setScale( self.upBgScale )
    sprite:setAnchorPoint( ccp(0.5,0.5) )

    if self.BossLevel == 1 then
        sprite:setPosition( ccp( bossPos.x+(100+5/0.7)*self.upBgScale, bossPos.y+(75-51/0.7)*self.upBgScale )  )
    elseif self.BossLevel == 2 then
        sprite:setPosition( ccp( bossPos.x+(100+16/0.7)*self.upBgScale, bossPos.y+(75-43/0.7)*self.upBgScale )  )
    elseif self.BossLevel == 3 then
        sprite:setPosition( ccp( bossPos.x+(100+16/0.7)*self.upBgScale, bossPos.y+(75-43/0.7)*self.upBgScale )  )
    elseif self.BossLevel == 4 then
        sprite:setPosition( ccp( bossPos.x+(100+29/0.7)*self.upBgScale, bossPos.y+(75-34/0.7)*self.upBgScale )  )
    end
    self.bossLayer:addChildAt( sprite,6 )
    sprite:setVisible(false)

    local DiamondSprite = Sprite:createWithSpriteFrameName("MoleWeekly_bosshavetarget.png")
    DiamondSprite:setScale(1*self.upBgScale)
    DiamondSprite:setPositionY( 0 )
    DiamondSprite:setPositionX( 0 )
    DiamondSprite:setAnchorPoint(ccp(0.5, 0.5))
    sprite:addChild( DiamondSprite )

    local label2 = BitmapText:create( "" ,"fnt/target_amount.fnt")
    label2:setPositionY( -20+8/0.7 )
    label2:setPositionX( 10-8/0.7 )
    label2:setAnchorPoint(ccp(0, 0.5))
    label2:setScale(0.8*self.upBgScale)
    sprite:addChild(label2)

    sprite.DiamondSprite = DiamondSprite
    sprite.Label2 = label2
    self.bossLayer.BossBagTipLayer = sprite
end

function BossBeeController:updateBossBagTip()
    local CanGetNum = 0
    local mainLogic = GameBoardLogic:getCurrentLogic()
    local bossData = mainLogic:getMoleWeeklyBossData()
    if bossData  then
        CanGetNum = bossData.dropItemsOnDie
    end

    local TipLayer = self.bossLayer.BossBagTipLayer
    local label2 = TipLayer.Label2
    label2:setText( "x"..CanGetNum )
end

function BossBeeController:setBossAllHP( BossAllHP )
    self.BossAllHP = BossAllHP
    self:setBossHP( BossAllHP )
end

function BossBeeController:setBossHP( curNum )
    if self.HPLayer and self.HPLayer.HPLabel then
        self.HPLayer.HPLabel:setText( curNum.."/"..self.BossAllHP )
        self.BossCurHP = curNum
    end
end

function BossBeeController:playNormal( )

    if self.CurAniType == BossType[1] then
        return 
    end

    self.CurAniType = BossType[1]
    self.BossNode:playSequence("breath", true, true, 1)
    self.BossNode:start()

    --BOSS掉落内容显示
    local layer = self.bossLayer.BossBagTipLayer
    layer:setVisible(true)
    self:updateBossBagTip()
end

function BossBeeController:playAppear(actionFinishCallback, bFirstBossAppear )
    -- if _G.isLocalDevelopMode then printx(0, 'playHit') end

    if self.CurAniType == BossType[2] then
        self:addCallBack( actionFinishCallback )
    else
        bFirstBossAppear = bFirstBossAppear or false

        local bShowFlag = true
        local CurTime = Localhost:time()
        local DieTime = 0

        if self.BossDieTime ~= 0 and CurTime >  self.BossDieTime then
            DieTime = CurTime - self.BossDieTime
        end
        
        if self.BossDieTime ~= 0 and DieTime < 2000 then --2秒内复活 不播旗子
            bShowFlag = false
        end

        self.BossDieTime = 0

        if bFirstBossAppear or bShowFlag == false then
            local function finishCallback()
                if self.playUI.isDisposed then return end

                self.HPLayer.clipping:setPercentage(1)
                self.HPLayer:setVisible(true)
    	        self:playNormal()

                self:CallBackAll()
            end

            --小白旗内容消失
            local layer = self.bossLayer.BossDieTipLayer
            layer:setVisible(false)

            self:CallBackAll()
            self:addCallBack( actionFinishCallback )

            self.CurAniType = BossType[2]

            self.BossNode:setSequenceDelegate('appear', finishCallback)
            self.BossNode:playSequence("appear", false, true, 1)
            self.BossNode:start()

            self:BossDiamondTipShow()

            local musicName = GameMusicType[ "kMoleweek_bossIn"..self.BossLevel]
            GamePlayMusicPlayer:playEffect( musicName )
        else
            local function bossAppear()
                local function finishCallback()
                    if self.playUI.isDisposed then return end

                    self.HPLayer.clipping:setPercentage(1)
                    self.HPLayer:setVisible(true)
    	            self:playNormal()

                    self:CallBackAll()
                end

                self.BossNode:setSequenceDelegate('appear', finishCallback)
                self.BossNode:playSequence("appear", false, true, 1)
                self.BossNode:start()

                self:BossDiamondTipShow()

                local musicName = GameMusicType[ "kMoleweek_bossIn"..self.BossLevel]
                GamePlayMusicPlayer:playEffect( musicName )
            end

            --小白旗内容消失
            local layer = self.bossLayer.BossDieTipLayer
            layer:setVisible(false)

            self:CallBackAll()
            self:addCallBack( actionFinishCallback )

            self.CurAniType = BossType[2]

            self.BossNode:setSequenceDelegate('flagd', bossAppear)
            self.BossNode:playSequence("flagd", false, true, 1)
            self.BossNode:start()
        end

        

    end
	-- anim:step()
	-- anim:pause()
end

function BossBeeController:playHit(actionFinishCallback, curHP, HitHP )
    -- if _G.isLocalDevelopMode then printx(0, 'playHit') end
    if self.CurAniType == BossType[3] or self.CurAniType == BossType[6] then
        self:addCallBack( actionFinishCallback )
    else
        local function finishCallback()
            if self.playUI.isDisposed then return end
    	    self:playNormal()
            self:CallBackAll()
        end

        self:CallBackAll()
        self:addCallBack( actionFinishCallback )

        self.CurAniType = BossType[3]
        self.BossNode:setSequenceDelegate('hit', finishCallback )
        self.BossNode:playSequence("hit", false, true, 1)
        self.BossNode:start()
    end

    self.HPLayer.clipping:setPercentage(self.HPLayer.curPercent)
    
    self:FlyBlood( HitHP )
    self:setBossHP( curHP )
end

function BossBeeController:playCute()
    -- if _G.isLocalDevelopMode then printx(0, 'playCute') end

    if self.CurAniType ~= BossType[1] then
        return
    end

    if self.BossCurHP and self.BossCurHP == 0 then
        return
    end

    local function finishCallback()
        if self.playUI.isDisposed then return end
    	self:playNormal()
    end

    self:CallBackAll()

    self.CurAniType = BossType[4]
    self.BossNode:setSequenceDelegate('laugh',  finishCallback )
    self.BossNode:playSequence("laugh", false, true, 1)
    self.BossNode:start()

    local musicName = GameMusicType[ "kMoleweek_bossEnough"..self.BossLevel]
    GamePlayMusicPlayer:playEffect( musicName )
end

function BossBeeController:playCast(actionFinishCallback)
    -- if _G.isLocalDevelopMode then printx(0, 'playCast') end

    if self.CurAniType == BossType[5] or self.CurAniType == BossType[6] then
        self:addCallBack( actionFinishCallback )
    else
        local function finishCallback()
            if self.playUI.isDisposed then return end

    	    self:playNormal()

            self:CallBackAll()
        end

        self:CallBackAll()
        self:addCallBack( actionFinishCallback )

        self.CurAniType =BossType[5]
        self.BossNode:setSequenceDelegate('attack',  finishCallback )
        self.BossNode:playSequence("attack", false, true, 1)
        self.BossNode:start()

        local musicName = GameMusicType[ "kMoleweek_bossUseSkill"..self.BossLevel]
        GamePlayMusicPlayer:playEffect( musicName )
    end
end

function BossBeeController:playDie(actionFinishCallback)
    -- if _G.isLocalDevelopMode then printx(0, 'playCast') end

    self.BossDieTime = Localhost:time()

    if self.CurAniType == BossType[6] then
        self:addCallBack( actionFinishCallback )
    else
        local function finishCallback()
            if self.playUI.isDisposed then return end
            self.HPLayer:setVisible(false)
            self:CallBackAll()

            self:playDieStay()
        end

        self:CallBackAll()
        self:addCallBack( actionFinishCallback )

        self.CurAniType = BossType[6]

        self.BossNode:setSequenceDelegate('die',  finishCallback )
        self.BossNode:playSequence("die", false, true, 1)
        self.BossNode:start()

        self.HPLayer.clipping:setPercentage(0)
        self:setBossHP( 0 )

        --小白旗内容显示
        local layer = self.bossLayer.BossBagTipLayer
        layer:setVisible(false)

        local musicName = GameMusicType[ "kMoleweek_bossDie"..self.BossLevel]
        GamePlayMusicPlayer:playEffect( musicName )
    end
end

function BossBeeController:playDieStay()

    if self.CurAniType == BossType[8] then
        return
    end

    self.CurAniType = BossType[8]

    self.BossNode:playSequence("flag", true, true, 1)
    self.BossNode:start()

    --小白旗内容显示
    local layer = self.bossLayer.BossDieTipLayer
    layer:setVisible(true)
    layer:setOpacity(0)

    local array = CCArray:create()
    array:addObject( CCFadeIn:create(1)  )

    layer:stopAllActions()
    layer:runAction( CCSequence:create( array ) )

    self:updateBossDieTip()
end

function BossBeeController:playSpecialHit(actionFinishCallback )
    -- if _G.isLocalDevelopMode then printx(0, 'playCast') end

    local function finishCallback()
        if self.playUI.isDisposed then return end
       
    	self:playNormal()

        self:CallBackAll()
    end

    self:CallBackAll()
    self:addCallBack( actionFinishCallback )

    self.CurAniType = BossType[7]

    self.BossNode:setSequenceDelegate('strike',  finishCallback )
    self.BossNode:playSequence("strike", false, true, 1)
    self.BossNode:start()

    --延时播声音
    local function PlaySound()
        local musicName = GameMusicType[ "kMoleweek_bigskill"..self.BossLevel]
        GamePlayMusicPlayer:playEffect( musicName )
    end

    local array = CCArray:create()
    array:addObject( CCDelayTime:create(0.2)  )
    array:addObject( CCCallFunc:create( PlaySound ) )

    self.BossNode:runAction( CCSequence:create( array ) )

end

function BossBeeController:changeAniType(Anitype)
    self.CurAniType =Anitype
end

function BossBeeController:resetAnim()
    
end

function BossBeeController:addCallBack( callback )
    table.insert( self.CastCallBackList, callback )
end

function BossBeeController:CallBackAll( )

    if self.playUI.isDisposed then return end

    for i,v in pairs(self.CastCallBackList) do
        if v then v() end
    end

    self.CastCallBackList = {}
end

function BossBeeController:FlyBlood( HitHP )
    --血量飘
    local bossPos = self.BossNode:getPosition()

    local flyDir = math.random(2)
    local offset = math.random(50)-25

    local LeftStartPos = ccp(  bossPos.x, bossPos.y+33/0.7*self.upBgScale )
    local RightStartPos = ccp( bossPos.x+65*self.upBgScale, bossPos.y+50+33/0.7*self.upBgScale )

    local startPos = ccp(0,0)
    local EndPos = ccp(0,0)
    if flyDir == 1 then
        startPos = LeftStartPos
        EndPos = ccp(startPos.x-100*self.upBgScale, startPos.y)
    else
        startPos = RightStartPos
        EndPos = ccp(startPos.x+100*self.upBgScale, startPos.y-100*self.upBgScale)
    end

    local Blood = BitmapText:create( "-"..HitHP ,"fnt/newzhousai_hit.fnt")
	Blood:setAnchorPoint(ccp(0.5,0.5))
	Blood:setPosition( startPos )
	self.bossLayer:addChildAt(Blood,15)

    local function MoveEnd()
        if self.playUI.isDisposed then return end
        Blood:removeFromParentAndCleanup( true )
    end

    local p1 = ccp(0, 0)
    local p2 = ccp(0.8*(EndPos.x - startPos.x), 100+offset )
    local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
    bezierConfig.controlPoint_2 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
    bezierConfig.endPosition = ccp(EndPos.x,EndPos.y)

    local array1 = CCArray:create()
    array1:addObject( CCBezierTo:create(1.2, bezierConfig) )
    array1:addObject( CCCallFunc:create(MoveEnd) )

    local array2 = CCArray:create()
    array2:addObject( CCDelayTime:create(1) )
    array2:addObject( CCFadeOut:create(1.15) )
    
    Blood:runAction( CCSequence:create( array1 ) )
    Blood:runAction( CCSpawn:create( array2 ) )
    
end

------------------------------------------------------

local BossSkillType = {
    "appear",
    "ready",
    "ready_breath",
    "attack",
    "none",
    "stay",
    "runaway",
}

--小地鼠
local BossSkillController = class()

function BossSkillController:create(playUI, bossLowLayer, topEffectLayer, BossPosInGameBGNode, SkillIDList, upBgScale )
    local instance = BossSkillController.new()
    instance:init(playUI, bossLowLayer, topEffectLayer, BossPosInGameBGNode, SkillIDList, upBgScale )
    return instance
end

function BossSkillController:init(playUI, bossLowLayer, topEffectLayer,BossPosInGameBGNode, SkillIDList, upBgScale )

--    SkillIDList = {1,2,3,4,5}
    self.upBgScale = upBgScale
    self.SkillIDList = SkillIDList
    self.BossPosInGameBGNode = BossPosInGameBGNode

    FrameLoader:loadArmature('skeleton/week_bossSkill')

    self.playUI = playUI
    self.bossLayer = bossLowLayer
    self.bossHithLayer = topEffectLayer

    local centerPos = ccp( self.BossPosInGameBGNode.x+20*self.upBgScale,self.BossPosInGameBGNode.y+55/0.7*self.upBgScale )
    self.BossSkillPosList = { 
        ccp(centerPos.x-278*self.upBgScale,centerPos.y+45*self.upBgScale), 
        ccp(centerPos.x-170*self.upBgScale,centerPos.y+13*self.upBgScale), 
        centerPos, 
        ccp(centerPos.x+152*self.upBgScale,centerPos.y+11*self.upBgScale), 
        ccp(centerPos.x+258*self.upBgScale,centerPos.y+46*self.upBgScale)  }

    self:CreateSkillItem( playUI, self.bossLayer, BossPosInGameBGNode, SkillIDList ) 
    self:CreateSkill2Item( playUI, self.bossLayer, BossPosInGameBGNode, SkillIDList )
end

function BossSkillController:CreateSkillItem(playUI, bossLayer, BossPosInGameBGNode, SkillIDList )
    
    local SkillNum = #SkillIDList

    local PosList = {}
    local IndexList = {}
    if SkillNum == 3 then
        table.insert( IndexList, 2 )
        table.insert( IndexList, 3 )
        table.insert( IndexList, 4 )

        table.insert( PosList, self.BossSkillPosList[ IndexList[1] ] )
        table.insert( PosList, self.BossSkillPosList[ IndexList[2] ] )
        table.insert( PosList, self.BossSkillPosList[ IndexList[3] ] )
    elseif SkillNum == 4 then

        table.insert( IndexList, 1 )
        table.insert( IndexList, 2 )
        table.insert( IndexList, 3 )
        table.insert( IndexList, 4 )

        table.insert( PosList, self.BossSkillPosList[ IndexList[1] ] )
        table.insert( PosList, self.BossSkillPosList[ IndexList[2] ] )
        table.insert( PosList, self.BossSkillPosList[ IndexList[3] ] )
        table.insert( PosList, self.BossSkillPosList[ IndexList[4] ] )
    else
        PosList = table.clone( self.BossSkillPosList )

        table.insert( IndexList, 1 )
        table.insert( IndexList, 2 )
        table.insert( IndexList, 3 )
        table.insert( IndexList, 4 )
        table.insert( IndexList, 5 )
    end

    self.SkllItemList = {}
    for i=1, SkillNum do

        local anim = ArmatureNode:create('bossSkill/smallmouseanime_behind')
        anim:playByIndex(0)
        anim:update(0.001)
        anim:stop()
        anim:setPosition( PosList[i] )
        anim.SkillID = SkillIDList[i]
        anim.SkillPosIndex = IndexList[i]
        anim:setScale(self.upBgScale)
        self.bossLayer:addChildAt(anim,8)


        local anim2 = ArmatureNode:create('bossSkill/smallmouseanime_supereffet')
        anim2:playByIndex(0)
        anim2:update(0.001)
        anim2:stop()
        anim2:setPosition( PosList[i] )
        anim2.SavePos = ccp( PosList[i].x, PosList[i].y )
        anim2:setScale(self.upBgScale)
        self.bossHithLayer:addChildAt( anim2,6 )
        anim.boom = anim2

        --牌子
        local CDLayer = Layer:create()
        CDLayer:setPosition( ccp(PosList[i].x+27*self.upBgScale, PosList[i].y+(-6-20/0.6)*self.upBgScale ) )
        self.bossLayer:addChildAt( CDLayer,13 )
        CDLayer:setVisible(false)

        local numberchangeAnim = ArmatureNode:create('bossSkill/numberchange')
        numberchangeAnim:playByIndex(0)
        numberchangeAnim:update(0.001)
        numberchangeAnim:stop()
        numberchangeAnim:setPosition( ccp(0,0) )
        numberchangeAnim:setScale(self.upBgScale)
        CDLayer:addChildAt( numberchangeAnim,1 )
        CDLayer.numberchangeAnim = numberchangeAnim
        
        local srcNum = UIHelper:getCon(numberchangeAnim,"srcNum")
        local dstNum = UIHelper:getCon(numberchangeAnim,"dstNum")

--        local fntFile = "fnt/mark_tip_white.fnt"
--        local srcNumCDLabel = CocosObject.new(CCLabelBMFont:create("",fntFile))
--	    srcNumCDLabel:setAnchorPoint(ccp(0.5,0.5))
--        srcNumCDLabel:setScale(0.7*self.upBgScale)
--        srcNumCDLabel:setPosition(ccp(0,0))
--        srcNumCDLabel.refCocosObj:setColor( hex2ccc3('784611') )
--        srcNum:addChild( srcNumCDLabel.refCocosObj )
--        srcNumCDLabel.setString =  function (_, str )
--            if self.isDisposed then return end
--            srcNumCDLabel.refCocosObj:setString(str)
--        end
--        CDLayer.srcNumCDLabel = srcNumCDLabel
--        srcNumCDLabel:dispose()


--        local fntFile = "fnt/mark_tip_white.fnt"
--        local dstNumCDLabel = CocosObject.new(CCLabelBMFont:create("",fntFile))
--	    dstNumCDLabel:setAnchorPoint(ccp(0.5,0.5))
--        dstNumCDLabel:setPosition(ccp(0,0))
--        dstNumCDLabel:setScale(0.7*self.upBgScale)
--        dstNumCDLabel.refCocosObj:setColor( hex2ccc3('784611') )
--        dstNum:addChild( dstNumCDLabel.refCocosObj )
--        dstNumCDLabel.setString =  function (_, str )
--            if self.isDisposed then return end
--            dstNumCDLabel.refCocosObj:setString(str)
--        end
--        CDLayer.dstNumCDLabel = dstNumCDLabel
--        dstNumCDLabel:dispose()

        local srcNumCDLabel = BitmapText:create( "" ,"fnt/mark_tip_white.fnt")
        srcNumCDLabel:setScale(0.7*self.upBgScale)
        srcNumCDLabel:setAnchorPoint(ccp(0.5, 0.5))
        srcNumCDLabel:setPosition(ccp(0,0))
        srcNumCDLabel:setColor(hex2ccc3('784611'))
        srcNum:addChild(srcNumCDLabel.refCocosObj)
        CDLayer.srcNumCDLabel = srcNumCDLabel.refCocosObj
        srcNumCDLabel:dispose()

        local dstNumCDLabel = BitmapText:create( "" ,"fnt/mark_tip_white.fnt")
        dstNumCDLabel:setScale(0.7*self.upBgScale)
        dstNumCDLabel:setAnchorPoint(ccp(0.5, 0.5))
        dstNumCDLabel:setPosition(ccp(0,0))
        dstNumCDLabel:setColor(hex2ccc3('784611'))
        dstNum:addChild(dstNumCDLabel.refCocosObj)
        CDLayer.dstNumCDLabel = dstNumCDLabel.refCocosObj
        dstNumCDLabel:dispose()

        anim.CDLayer = CDLayer
        anim.PlayType = "none"

        table.insert( self.SkllItemList, anim )
    end

end

function BossSkillController:CreateSkill2Item(playUI, bossLayer, BossPosInGameBGNode, SkillIDList )
    
    local SkillNum = #SkillIDList

    local PosList = {}
    if SkillNum == 3 then
        table.insert( PosList, self.BossSkillPosList[2] )
        table.insert( PosList, self.BossSkillPosList[3] )
        table.insert( PosList, self.BossSkillPosList[4] )
    elseif SkillNum == 4 then
        table.insert( PosList, self.BossSkillPosList[1] )
        table.insert( PosList, self.BossSkillPosList[2] )
        table.insert( PosList, self.BossSkillPosList[3] )
        table.insert( PosList, self.BossSkillPosList[4] )
    else
        PosList = table.clone( self.BossSkillPosList )
    end

    self.SkllItemList2 = {}
    for i=1, SkillNum do

        local anim = ArmatureNode:create('bossSkill/smallmouseanime_infront')
        anim:playByIndex(0)
        anim:update(0.001)
        anim:stop()
        anim:setPosition( PosList[i] )
        anim:setScale(self.upBgScale)
        anim.SkillID = SkillIDList[i]
        self.bossLayer:addChildAt(anim,11)

        table.insert( self.SkllItemList2, anim )
    end

end

function BossSkillController:getSkillCirclePos( SkillID )
     local Item = self:getSkillItem(SkillID)

     if not Item then
        return ccp(0,0)
     end

     local pos = Item:getParent():convertToWorldSpace( Item:getPosition() )

     pos.x = pos.x
     pos.y = pos.y + 153
     return pos
end

function BossSkillController:SkillIn()
    for i,v in pairs(self.SkillIDList) do
        self:PlayInitSkill(v)
    end
end

function BossSkillController:SelectSkill( SkillID, Step )

    if not SkillID  then
        return
    end

    if Step > 1 then

        self:PlayCDLayerShow( SkillID, Step )

        local Item = self:getSkillItem(SkillID)
        if Item and Item.PlayType == BossSkillType[1] then
            return
        end

        self:PlayAppear( SkillID )
    elseif Step == 1 then
        
        self:PlayCDLayerShow( SkillID, Step )

        local Item = self:getSkillItem(SkillID)
        if Item and Item.PlayType == BossSkillType[2] then
            return
        end

        self:PlayReady( SkillID )
    end
end

function BossSkillController:PlayCDLayerShow( SkillID, Step )
    local Item = self:getSkillItem(SkillID)
    local Item2 = self:getSkillItem2(SkillID)

    if Item and Item2 then
        local bVisible = Item.CDLayer:isVisible()

        if bVisible then

            if Item.CDLayer.CurShowNum and Item.CDLayer.CurShowNum == Step then
                return
            end

            local oldStep = 0
            if Item.CDLayer.CurShowNum  then
                oldStep = Item.CDLayer.CurShowNum
                Item.CDLayer.CurShowNum = Step
            end

            Item.CDLayer:setScale(1)

            Item.CDLayer.srcNumCDLabel:setColor( hex2ccc3('784611') )

            if Step == 1 then
                Item.CDLayer.dstNumCDLabel:setColor( hex2ccc3('ff0000') )
            else
                Item.CDLayer.dstNumCDLabel:setColor( hex2ccc3('784611') )
            end

            Item.CDLayer.srcNumCDLabel:setString( ""..oldStep )
            Item.CDLayer.dstNumCDLabel:setString( ""..Step )

            local function NumberChangeCallBack()
                if Step == 1 then
                    Item.CDLayer.srcNumCDLabel:setColor( hex2ccc3('ff0000') )
                else
                    Item.CDLayer.srcNumCDLabel:setColor( hex2ccc3('784611') )
                end

                Item.CDLayer.srcNumCDLabel:setString( ""..Step )
                Item.CDLayer.numberchangeAnim:play( "normal", 0 )
            end
            self:createAnimCallBack( Item.CDLayer.numberchangeAnim, NumberChangeCallBack )

            if Step ~= 1 then
                Item.CDLayer.numberchangeAnim:play( "turnnum", 1 )
            else
                Item.CDLayer.numberchangeAnim:play( "turnnum2", 1 )
            end
        else
            Item.CDLayer.CurShowNum = Step

            Item.CDLayer:setScale(0)
            Item.CDLayer.srcNumCDLabel:setString( ""..Step )
            Item.CDLayer.dstNumCDLabel:setString( ""..Step )

            Item.CDLayer.srcNumCDLabel:setColor( hex2ccc3('784611') )
            Item.CDLayer.dstNumCDLabel:setColor( hex2ccc3('784611') )

            Item.CDLayer:setVisible(true)

            local array = CCArray:create()
            array:addObject( CCScaleTo:create(0.15, 1.3) )
            array:addObject( CCScaleTo:create(0.15, 0.8) )
            array:addObject( CCScaleTo:create(0.15, 1.2) )
            array:addObject( CCScaleTo:create(0.15, 1) )

            Item.CDLayer.numberchangeAnim:play( "normal", 0 )
            Item.CDLayer:runAction( CCSequence:create( array ) )
        end
    end
end

function BossSkillController:PlayInitSkill( SkillID )

    local Item = self:getSkillItem(SkillID)
    local Item2 = self:getSkillItem2(SkillID)
    if Item and Item2 then
        Item.PlayType = BossSkillType[6]

        local function AnimCallBack()
            
        end

        self:createAnimCallBack( Item, AnimCallBack )

        Item:play("stay",1)
        Item2:play("stay",1)
    end
end

function BossSkillController:PlayAppear( SkillID )

    local Item = self:getSkillItem(SkillID)
    local Item2 = self:getSkillItem2(SkillID)
    if Item and Item2 then

        --更换icon
--        if Item.icon then
--            Item.icon:removeFromParentAndCleanup(true)
--        end

        local ResName = self:getSkillRes( SkillID )
        local icon = UIHelper:getCon(Item,"icon")

        local sprite = Sprite:createWithSpriteFrameName(ResName)
        sprite:setPosition( ccp(0,0) )
	    icon:addChild(sprite.refCocosObj)
        sprite:dispose()

--        Item.icon = sprite
        --


        Item.PlayType = BossSkillType[1]

        local function AnimCallBack()
            
        end

        self:createAnimCallBack( Item, AnimCallBack )

        Item:play("appear", 1)
        Item2:play("appear", 1)
    end
end

function BossSkillController:PlayReady( SkillID )

    local Item = self:getSkillItem(SkillID)
    local Item2 = self:getSkillItem2(SkillID)
    if Item and Item2 then

        --更换icon
--        if Item.icon then
--            Item.icon:removeFromParentAndCleanup(true)
--        end

        local ResName = self:getSkillRes( SkillID )
        local icon = UIHelper:getCon(Item,"icon")

        local sprite = Sprite:createWithSpriteFrameName(ResName)
        sprite:setPosition( ccp(0,0) )
	    icon:addChild(sprite.refCocosObj)
        sprite:dispose()

--        Item.icon = sprite
        --

        Item.PlayType = BossSkillType[2]

        local function AnimCallBack()
            self:PlayReadyBreath( SkillID )
        end

        self:createAnimCallBack( Item, AnimCallBack )

        Item:play("ready", 1)
        Item2:play("ready", 1)
    end
end

function BossSkillController:PlayReadyBreath( SkillID )

    local Item = self:getSkillItem(SkillID)
    local Item2 = self:getSkillItem2(SkillID)
    if Item and Item2 then

        if Item.PlayType ~= BossSkillType[7] then
            Item.PlayType = BossSkillType[3]

            Item:play("ready_breath", 0)
            Item2:play("ready_breath", 0)
        end
    end
end

function BossSkillController:PlayAttack( SkillID )

    --anim
    local Item = self:getSkillItem(SkillID)
    local Item2 = self:getSkillItem2(SkillID)
    if Item and Item2 and Item.boom then

         --更换icon
--        if Item.boom.icon then
--            Item.boom.icon:removeFromParentAndCleanup(true)
--        end

        local ResName = self:getSkillRes( SkillID )
        local icon = UIHelper:getCon(Item.boom,"icon")

        local sprite = Sprite:createWithSpriteFrameName(ResName)
        sprite:setPosition( ccp(0,0) )
	    icon:addChild(sprite.refCocosObj)
        sprite:dispose()

--        Item.boom.icon = sprite


        Item.PlayType = BossSkillType[4]

        local function AnimCallBack()
            self:PlayInitSkill( SkillID )
        end

        self:createAnimCallBack( Item, AnimCallBack )

        Item:play("attack", 1)
        Item2:play("attack", 1)

        local moveY = 0
        if Item.SkillPosIndex == 1 or Item.SkillPosIndex == 5 then
            moveY = 120
        elseif Item.SkillPosIndex == 2 or Item.SkillPosIndex == 4 then
            moveY = 130 
        else
            moveY = 150
        end

        Item.boom:play("attack", 1)
        local array = CCArray:create()
        array:addObject( CCMoveBy:create( 0.6, ccp(0, moveY) ) )
    
        Item.boom:setPositionY( Item.boom.SavePos.y )
        Item.boom:runAction( CCSequence:create(array) )

        --hide number
        Item.CDLayer:setVisible(false)
    end
end

function BossSkillController:PlayDead( )


    for i,v in pairs( self.SkllItemList ) do

        local CurType = v.PlayType

        local AniName = ""
        if CurType == BossSkillType[3] then
            AniName = "runaway1"
        elseif CurType == BossSkillType[2] then
            AniName = "runaway2"
        elseif CurType == BossSkillType[1] then
            AniName = "runaway3"
        else
            AniName = "runaway3"
        end

        v.PlayType = BossSkillType[7]
        local SkillID = v.SkillID
        local Item = self:getSkillItem(SkillID)
        local Item2 = self:getSkillItem2(SkillID)
        if Item and Item2 and Item.boom then
            local function AnimCallBack()
                
            end

            self:createAnimCallBack( Item, AnimCallBack )

            Item:play(AniName, 1)
            Item2:play(AniName, 1)

            --hide number
            Item.CDLayer:setVisible(false)
        end
            
    end

end

function BossSkillController:createAnimCallBack( anim, callback )

    if not anim then return end

    anim:addEventListener(ArmatureEvents.COMPLETE, function()
    	anim:removeAllEventListeners()
    	    
        if callback then callback() end
    end)
end

function BossSkillController:getSkillItem( SkillID )

    if not self.SkllItemList then
        return nil
    end

    for i,v in pairs(self.SkllItemList) do
        if v.SkillID == SkillID then
            return v
        end
    end

    return nil
end

function BossSkillController:getSkillItem2( SkillID )

    if not self.SkllItemList2 then
        return nil
    end

    for i,v in pairs(self.SkllItemList2) do
        if v.SkillID == SkillID then
            return v
        end
    end

    return nil
end

function BossSkillController:getSkillRes( SkillID )

    local ResName = ""
    if SkillID == MoleWeeklyBossSkillType.THICK_HONEY then
        ResName = "MoleWeekly_icon4.png"
    elseif SkillID == MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL then
        ResName = "MoleWeekly_icon5.png"
    elseif SkillID == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then
        ResName = "MoleWeekly_icon2.png"
    elseif SkillID == MoleWeeklyBossSkillType.SEED then
        ResName = "MoleWeekly_icon3.png"
    elseif SkillID == MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK or 
            SkillID == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_2 or 
            SkillID == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_1  then
        ResName = "MoleWeekly_icon1.png"
    end

    return ResName
end

------------------------------------------------------
local MAX_SPINE_PERCENT = 0.98
local RAINBOW_SHOW_HIDE_DURATION = 0.5
local RAINBOW_SHOW_HIDE_Y = 50


-- 给GamePlaySceneUI加上新功能
GamePlaySceneDecorator = class()

function GamePlaySceneDecorator:decoSceneForBG(gamePlayScene)

    local visibleSize 	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local gameBg = gamePlayScene.gameBgNode
	local gameBoardView = gamePlayScene.gameBoardView
	local posY = (10 - gameBoardView.startRowIndex) * 70
	local gPos = gameBoardView:convertToWorldSpace(ccp(0, posY))


    --upbg位置适配 缩放
    local deviceType = MetaInfo:getInstance():getMachineType() or ""

	if __isWildScreen then  
		gamePlayScene.gameBgNode.upBg:setScale( visibleSize.width/960 )
	end

    local topSpritePosY = gamePlayScene.gameBgNode:convertToNodeSpace(ccp(0, gPos.y)).y
    gamePlayScene.gameBgNode.upBg:setPositionY( topSpritePosY-10 )
end

function GamePlaySceneDecorator:decoSceneForBossBee(gamePlaySceneInstance)
    -- FrameLoader:loadArmature('skeleton/bee_animation', 'bee_animation', 'bee_animation')

    local upBgScale = gamePlaySceneInstance.gameBgNode.upBg:getScale()
    local BossPosInGameBGNode = gamePlaySceneInstance.gameBgNode.upBg:convertToWorldSpace(ccp(480, 16))

    --底座 洞
    local MoleWeekly_smallhole1 = Sprite:createWithSpriteFrameName("MoleWeekly_smallhole1.png")
	MoleWeekly_smallhole1:setAnchorPoint(ccp(0.5, 0.5))
    MoleWeekly_smallhole1:setPosition(ccp(BossPosInGameBGNode.x+(10/0.7)*upBgScale,BossPosInGameBGNode.y+(34/0.7-1)*upBgScale ))
    MoleWeekly_smallhole1:setScale( upBgScale )
    gamePlaySceneInstance.bossLowerLayer:addChildAt( MoleWeekly_smallhole1, 10 )
--    MoleWeekly_smallhole1:setVisible(false) --test

    local MoleWeekly_smallhole2 = Sprite:createWithSpriteFrameName("MoleWeekly_smallhole2.png")
	MoleWeekly_smallhole2:setAnchorPoint(ccp(0.5, 0.5))
    MoleWeekly_smallhole2:setPosition(ccp(BossPosInGameBGNode.x +( -5/0.7+10/0.7)*upBgScale,BossPosInGameBGNode.y+ (28/0.7+22/0.7+0.5)*upBgScale ))
    MoleWeekly_smallhole2:setScale( upBgScale )
    gamePlaySceneInstance.bossLowerLayer:addChildAt( MoleWeekly_smallhole2, 7 )
--    MoleWeekly_smallhole2:setVisible(false) --test

    --血条
    local HPLayer = Layer:create()
    HPLayer:setScale(upBgScale)
	gamePlaySceneInstance.bossLayer:addChildAt(HPLayer,5)
    
--    local hpOffsetX = 14/0.7
--    local OffsetY = 234/0.7

    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

--    --血条适配
--    local DefaultHPPos = gamePlaySceneInstance.bossLayer:convertToWorldSpace(ccp(0,  BossPosInGameBGNode.y + OffsetY + 25  ))

--    if vo.y + vs.height < DefaultHPPos.y then
--        local inLayerPos  = gamePlaySceneInstance.bossLayer:convertToNodeSpace(ccp(0,  vo.y + vs.height - 25  ))

--        OffsetY = inLayerPos.y - BossPosInGameBGNode.y
--    end

    local ProgressPos = ccp(0,0)
    if __IPHONE_WITH_EDGE then
        ProgressPos = HPLayer:convertToNodeSpace( ccp( vo.x+vs.width/2+20*upBgScale, vo.y+vs.height + ( -59 + 26.5-30/0.3 )*upBgScale ))
    else
        ProgressPos = HPLayer:convertToNodeSpace( ccp( vo.x+vs.width/2+20*upBgScale, vo.y+vs.height + (- 59)*upBgScale ))
    end

    local MoleWeekly_Progress_down = Sprite:createWithSpriteFrameName("MoleWeekly_Progress_down.png")
	MoleWeekly_Progress_down:setAnchorPoint(ccp(0.5, 0.5))
    MoleWeekly_Progress_down:setPosition(ccp(ProgressPos.x,ProgressPos.y))
    HPLayer:addChildAt( MoleWeekly_Progress_down, 1 )

    local MoleWeekly_Progress_middle = Sprite:createWithSpriteFrameName("MoleWeekly_Progress_middle.png")
	MoleWeekly_Progress_middle:setAnchorPoint(ccp(0,0))
    MoleWeekly_Progress_middle:setPosition(ccp(0,0))
    
    local MoleWeekly_Progress_up = Sprite:createWithSpriteFrameName("MoleWeekly_Progress_up.png")
	MoleWeekly_Progress_up:setAnchorPoint(ccp(0.5, 0.5))
    MoleWeekly_Progress_up:setPosition(ccp(ProgressPos.x,ProgressPos.y))
    HPLayer:addChildAt( MoleWeekly_Progress_up, 3 )

--    local fntFile = "fnt/star_entrance.fnt"
--    local HPLabel = CocosObject.new(CCLabelBMFont:create("",fntFile))
--	HPLabel:setAnchorPoint(ccp(0.5,0.5))
--    HPLabel:setPosition(ccp(83/0.7-5/0.7,12/0.7))
--    MoleWeekly_Progress_up:addChildAt( HPLabel, 1 )
--    HPLabel.setString =  function (_, str )
--        if self.isDisposed then return end
--        HPLabel.refCocosObj:setString(str)
--    end

    local HPLabel = BitmapText:create( "" ,"fnt/star_entrance.fnt")
    HPLabel:setAnchorPoint(ccp(0.5, 0.5))
    HPLabel:setPosition(ccp(83/0.7-5/0.7,12/0.7))
    MoleWeekly_Progress_up:addChildAt(HPLabel, 1)

    --进度条
    local size = MoleWeekly_Progress_middle:getContentSize()

    local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(size.width, size.height))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0, 1))
    clipping:ignoreAnchorPointForPosition(false)
    clipping:setPosition( ccp(ProgressPos.x-size.width/2-1/0.7,ProgressPos.y+size.height/2+2/0.7) )
    clipping:addChildAt( MoleWeekly_Progress_middle, 1 )
    HPLayer:addChildAt(clipping,2)
    HPLayer.clipping = clipping
    HPLayer.HPLabel = HPLabel

    clipping.setPercentage =  function (_, percentage )
        if self.isDisposed then return end

        percentage = percentage or 0
        percentage = math.min(1, percentage)
        percentage = math.max(0, percentage)
        clipping:setContentSize(CCSizeMake(size.width * percentage, size.height))
    end
    HPLayer.clipping:setPercentage(1)

    HPLayer:setVisible(false)

    -- 加上一些函数
    gamePlaySceneInstance.setRainbowPercent = function (instance, percent)

        if instance.bossBeeController then
            instance.bossBeeController.HPLayer.curPercent = percent
        end
--        if instance.bossBeeController.HPLayer and not instance.bossBeeController.HPLayer.isDisposed then
--            instance.bossBeeController.HPLayer.clipping:setPercentage(percent)
--        end
    end
    
    --boss出现
    gamePlaySceneInstance.playBossFlyUp = function (instance, finishCallback)

        if instance.bossBeeController then
            local bFirstBossAppear = false
            local mainLogic = GameBoardLogic:getCurrentLogic()
            if mainLogic then
                local bossCount = MoleWeeklyRaceConfig:_getCurrBossCount(mainLogic)

                if bossCount == 1 then
                    bFirstBossAppear = true
                end
            end

            instance.bossBeeController:playAppear( finishCallback, bFirstBossAppear )
        end

        if instance.BossSkillController then
            instance.BossSkillController:SkillIn()
        end
    end


    local function GetBossLevel( GroupID )

        local level = 1
        if GroupID >=1 and GroupID <=3 then
            level = 1
        elseif GroupID >=4 and GroupID <=6 then
            level = 2
        elseif GroupID >=7 and GroupID <=9 then
            level = 3
        else
            level = 4
        end

        return level
    end

    --正常创建BOSS 地鼠
    gamePlaySceneInstance.initBossBee = function (instance, BossSkillList )
        --大招初始动画
        local mainLogic = GameBoardLogic:getCurrentLogic()
        -- local GroupID = mainLogic:getMoleWeeklyBossData().bossGroupID or 1
        local GroupID = MoleWeeklyRaceConfig:getRealCurrGroupID()   --为了兼容回放，因为之前加载的素材用的是真实段位（加载素材时未获取回放段位），所以此处也使用

        local bossLevel = GetBossLevel( GroupID )

        if not instance.bossBeeController then
            instance.bossBeeController = BossBeeController:create(instance, instance.bossLowerLayer, bossLevel, HPLayer, BossPosInGameBGNode, upBgScale )
        end
        
        if not instance.BossSkillController then
            instance.BossSkillController = BossSkillController:create(instance, instance.bossLowerLayer, instance.topEffectLayer, BossPosInGameBGNode,BossSkillList, upBgScale )
        end
        
    end


    --断面创建boss 地鼠 BOSS活的情况
    gamePlaySceneInstance.initBossBeeDuanMian = function (instance, BossSkillList, curHP, maxHP, SkillID, Step )
        -- printx(11, "= = = Set Mole Boss Revert Status", BossSkillList, curHP, maxHP, SkillID, Step)

        local mainLogic = GameBoardLogic:getCurrentLogic()
        local GroupID = mainLogic:getMoleWeeklyBossData().bossGroupID or 1
        local bossLevel = GetBossLevel( GroupID )
        
        if not instance.bossBeeController then
            instance.bossBeeController = BossBeeController:create(instance, instance.bossLowerLayer, bossLevel, HPLayer, BossPosInGameBGNode, upBgScale )
        end
        
        if not instance.BossSkillController then
            instance.BossSkillController = BossSkillController:create(instance, instance.bossLowerLayer, instance.topEffectLayer, BossPosInGameBGNode,BossSkillList, upBgScale )
        end
        

        if instance.bossBeeController then
            instance.bossBeeController:setBossAllHP( maxHP )
            instance.bossBeeController:setBossHP( curHP )
            instance.bossBeeController:playNormal()

            instance.bossBeeController.HPLayer.curPercent = curHP / maxHP
            instance.bossBeeController.HPLayer.clipping:setPercentage(instance.bossBeeController.HPLayer.curPercent)
            instance.bossBeeController.HPLayer:setVisible(true)
        end

        if instance.BossSkillController then
            instance.BossSkillController:SkillIn()
            instance.BossSkillController:SelectSkill( SkillID, Step )
        end
    end
    
    gamePlaySceneInstance.initBossBeeHP = function (instance, AllHP )
        if instance.bossBeeController then
            instance.bossBeeController:setBossAllHP( AllHP )
        end
    end
    
    gamePlaySceneInstance.playPropSkillHammerHit = function (instance, finishCallback, CurHP, HitNum )

        if instance.bossBeeController then
            --提前更改动作类型 防止动画未播的时候 插入调皮动画
            instance.bossBeeController:changeAniType( BossType[7] )

            --大招的位置
            local vs = Director:sharedDirector():getVisibleSize()
            local vo = Director:sharedDirector():getVisibleOrigin()
            local SkillPos = instance.propList:getSpringItemGlobalPosition()

            --
            local HummerStartPos = ccp( BossPosInGameBGNode.x, BossPosInGameBGNode.y-291 )

            --流光
            local function FlyEnd()
                --锤子击打
                local animHummer = ArmatureNode:create('bossSkill/turnhammer')
                animHummer:playByIndex(0)
                animHummer:update(0.001)
                animHummer:stop()
                animHummer:setPosition( HummerStartPos )
                instance.bossLayer:addChildAt(animHummer,11)

                animHummer:addEventListener(ArmatureEvents.COMPLETE, function()
    	            animHummer:removeAllEventListeners()
                end)

                animHummer:play("fly", 1)

                local function HummerFlyEnd()
                    instance.bossBeeController:playSpecialHit(finishCallback, CurHP)
                end

                local function HummerPlayHurt()
                    instance.bossBeeController.HPLayer.clipping:setPercentage(instance.bossBeeController.HPLayer.curPercent)
                    instance.bossBeeController:FlyBlood(HitNum)
                    instance.bossBeeController:setBossHP(CurHP)
                end

                local array = CCArray:create()
                array:addObject(CCDelayTime:create(1.1))
                array:addObject(CCCallFunc:create(HummerFlyEnd))
                array:addObject(CCDelayTime:create(1))
                array:addObject(CCCallFunc:create(HummerPlayHurt))

                animHummer:runAction(CCSequence:create(array))
            end

            FlyLightLine:createLine( instance.bossLayer, 0.3, SkillPos, HummerStartPos, FlyEnd )
        end
    end

    gamePlaySceneInstance.bossBeeDie = function (instance, finishCallback)

        if instance.bossBeeController then
            instance.bossBeeController:playDie(finishCallback)
        end

        if instance.BossSkillController then
            instance.BossSkillController:PlayDead()
        end
    end


    local DiamondPos = gamePlaySceneInstance.gameBgNode.upBg:convertToWorldSpace(ccp(193, 86))
    gamePlaySceneInstance.YellowDiamondFly = function ( instance, num, pos )

        if not instance.DiamondBox then

            local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()

            local anim
            if SaijiIndex == 1 then
                anim = ArmatureNode:create('bossSkill/diamondbox')
            else
                anim = ArmatureNode:create('bossSkill/diamondbox2')
            end

            anim:playByIndex(0)
            anim:update(0.001)
            anim:stop()
            anim:setPosition( DiamondPos )
            instance.bossLayer:addChildAt(anim,20)

            anim.CurDiamondInfo = {}
            anim.boxType = 0

            local diamondInfo = {}
            diamondInfo.num = num
            diamondInfo.pos = pos
            diamondInfo.bisCreate = false

            table.insert( anim.CurDiamondInfo, diamondInfo )
            instance.DiamondBox = anim
        else

            local diamondInfo = {}
            diamondInfo.num = num
            diamondInfo.pos = pos
            diamondInfo.bisCreate = false

            table.insert( instance.DiamondBox.CurDiamondInfo, diamondInfo )
        end


        local function getDiamondCanCreateNum()
            local num = 0

            if instance.DiamondBox then
                for i,v in pairs( instance.DiamondBox.CurDiamondInfo ) do
                    if v.bisCreate == false then
                        num = num +1
                    end
                end   
            end
            return num       
        end

        local function DiamondFly()
            
            for i,v in pairs( instance.DiamondBox.CurDiamondInfo ) do

                if v.bisCreate == false then

                    v.bisCreate = true
                    for i=1, v.num do

                        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()

                        local sprite
                        if SaijiIndex == 1 then
                            sprite = Sprite:createWithSpriteFrameName("gress_yellow_diamond.png")
                        else
                            sprite = Sprite:createWithSpriteFrameName("gress_yellow_diamond2.png")
                        end
                        sprite:setScale(1.3)
                        sprite:setPosition( v.pos )
	                    instance.bossLayer:addChildAt(sprite, 21)

                        local tx, ty = DiamondPos.x, DiamondPos.y
                        local function onIconScaleFinished()

                            local canCreateNum = getDiamondCanCreateNum()

                            if canCreateNum == 0 then

                                if instance.DiamondBox then
                                    instance.DiamondBox:addEventListener(ArmatureEvents.COMPLETE, function()
                                        if instance.DiamondBox then
                                            instance.DiamondBox:removeAllEventListeners()
                                            instance.DiamondBox:removeFromParentAndCleanup(true)
                                            instance.DiamondBox = nil
                                        end
                                    end)
                                    instance.DiamondBox:play("dissapear",1)
                                end
                            end

                            sprite:removeFromParentAndCleanup(true)
                        end 

                        local function onIconMoveFinished()         
                            local sequence = CCSpawn:createWithTwoActions(CCScaleTo:create(0.3, 2), CCFadeOut:create(0.3))
                            sprite:setOpacity(255)
                            sprite:runAction(CCSequence:createWithTwoActions(sequence, CCCallFunc:create(onIconScaleFinished)))
                        end 
                        local moveTo = CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(tx, ty)))
                        local array = CCArray:create()

                        if itemId == 1 then
            	            sprite:setScale(0.3)
            	            local scale_action = CCScaleTo:create(0.3, 1.5)
            	            local index_x = math.random()
            	            local index_y = math.random()
            	            local jump_action = CCJumpBy:create(0.5, ccp(index_x * 2 * GamePlayConfig_Tile_Width, -index_y * 2* GamePlayConfig_Tile_Width), (1 + index_y) * GamePlayConfig_Tile_Width, 1)
            	            array:addObject(CCSpawn:createWithTwoActions(scale_action, jump_action))
            	            array:addObject(CCDelayTime:create(index_y))
                        end
                        array:addObject(CCSpawn:createWithTwoActions(moveTo, CCFadeTo:create(0.5, 150)))
                        array:addObject(CCCallFunc:create(onIconMoveFinished))

                        sprite:runAction(CCSequence:create(array))
                    end
                end
            end
        end

        if instance.DiamondBox.boxType ~= 1 then
            instance.DiamondBox.boxType = 1
            instance.DiamondBox:addEventListener(ArmatureEvents.COMPLETE, function()
    	    instance.DiamondBox:removeAllEventListeners()
                DiamondFly()
                instance.DiamondBox:play("stay",0)
            end)

            instance.DiamondBox:play("open",1)
        elseif instance.DiamondBox.boxType == 1 then
            DiamondFly()
        end
    end


    gamePlaySceneInstance.PlayInitPowerAnim = function ( instance, level, num )
        
        local vs = Director:sharedDirector():getVisibleSize()
        local vo = Director:sharedDirector():getVisibleOrigin()

        local sp = Sprite:createWithSpriteFrameName("MoleWeekly_hammer.png")
        sp:setPosition( ccp(vo.x + vs.width/2, vo.y+vs.height/2) )
        instance.topEffectLayer:addChild( sp )

        local startMoveLeftPosX = 50/0.7

        local LabelBg1 = Sprite:createWithSpriteFrameName("MoleWeekly_Skilllight.png")
        LabelBg1:setPosition( ccp(vo.x + vs.width/2-startMoveLeftPosX, vo.y+vs.height/2-58-25/0.7) )
        LabelBg1:setScale(0.8)
        LabelBg1:setVisible(false)
        instance.bossLayer:addChildAt( LabelBg1,1 )

        local LevelName = localize('rank.race.dan.panel.title.' .. level )
        local label1 = BitmapText:create( LevelName ,"fnt/newzhousai_bonus1.fnt")
        label1:setPosition( ccp(vo.x + vs.width/2-startMoveLeftPosX, vo.y+vs.height/2-58-25/0.7) )
        label1:setScale(0.8)
        label1:setAnchorPoint(ccp(0.5, 0.5))
        label1:setVisible(false)
        instance.bossLayer:addChildAt(label1,2)

        local LabelBg2 = Sprite:createWithSpriteFrameName("MoleWeekly_Skilllight.png")
        LabelBg2:setPosition( ccp(vo.x + vs.width/2-startMoveLeftPosX, vo.y+vs.height/2-106-25/0.7) )
        LabelBg2:setVisible(false)
        instance.bossLayer:addChildAt( LabelBg2,1 )

        local label2 = BitmapText:create( "充能" ,"fnt/newzhousai_bonus2.fnt")
        label2:setPositionY( vo.y+vs.height/2-106-25/0.7 )
        label2:setAnchorPoint(ccp(0.5, 0.5))
        label2:setVisible(false)
        instance.bossLayer:addChildAt(label2,2)

        local label3 = BitmapText:create( "+"..num.."%" ,"fnt/newzhousai_bonus2.fnt")
        label3:setPositionY( vo.y+vs.height/2-106-25/0.7 )
        label3:setAnchorPoint(ccp(0.5, 0.5))
        label3:setVisible(false)
        instance.bossLayer:addChildAt( label3,2 )

        local label2Width = label2:getContentSize().width
        local label3Width = label3:getContentSize().width
        local LabelAddWidth = 0
        local AllWidth = label2Width + LabelAddWidth + label3Width
        label2:setPositionX( vo.x + vs.width/2 - AllWidth/2 + label2Width/2 - startMoveLeftPosX )
        label3:setPositionX( vo.x + vs.width/2 - AllWidth/2 + label2Width + LabelAddWidth + label3Width/2- startMoveLeftPosX   )

        sp:setOpacity(0)
        local array1 = CCArray:create()
        array1:addObject( CCFadeIn:create(0.2)  )
        sp:runAction( CCSequence:create( array1 ) )

        local function ShowLabelBG1()
            LabelBg1:setVisible(true)
        end

        local function HideLabelBG1()
            LabelBg1:setVisible(false)
        end

        local function ShowLabelBG2()
            LabelBg2:setVisible(true)
        end

        local function HideLabelBG2()
            LabelBg2:setVisible(false)
        end

        local function HideSP()
            sp:setVisible(false)
        end

        local function FlySP()
            local startPos = sp:getPosition()
            local EndPos = instance.propList:getSpringItemGlobalPosition()

            local p1 = ccp(0, 0)
            local p2 = ccp(0.5*(EndPos.x - startPos.x), 100 )
            local bezierConfig = ccBezierConfig:new()
	        bezierConfig.controlPoint_1 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
            bezierConfig.controlPoint_2 = ccp(startPos.x +  p2.x, startPos.y +  p2.y)
            bezierConfig.endPosition = ccp(EndPos.x,EndPos.y)

            local array1 = CCArray:create()
            array1:addObject( CCBezierTo:create(0.5, bezierConfig) )

            local array2 = CCArray:create()
            array2:addObject( CCDelayTime:create(0.1) )
            array2:addObject( CCScaleTo:create(0.4, 0.3 ) )

            local array = CCArray:create()
            array:addObject( CCSpawn:create(array1, CCSequence:create( array2 ) ) )
            array:addObject( CCCallFunc:create( HideSP ) )

            sp:runAction( CCSequence:create( array ) )
        end

        local function ShowLabel1()
            label1:setVisible(true)
        end

        local function HideLabel1()
            label1:setVisible(false)
        end

        local array2 = CCArray:create()
        array2:addObject( CCDelayTime:create(0.1) )
        array2:addObject( CCCallFunc:create( ShowLabel1 ) )
        array2:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
        label1:runAction( CCSequence:create( array2 ) )

        
        local bgarray2 = CCArray:create()
        bgarray2:addObject( CCFadeIn:create(0.2) )
        bgarray2:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )

        local bgarray3 = CCArray:create()
        bgarray3:addObject( CCDelayTime:create(0.1)  )
        bgarray3:addObject( CCCallFunc:create( ShowLabelBG1 ) )
        bgarray3:addObject( CCSpawn:create(bgarray2)  )

        LabelBg1:setOpacity(0)
        LabelBg1:runAction( CCSequence:create( bgarray3 ) )


        local function ShowLabel2()
            label2:setVisible(true)
        end

        local function HideLabel2()
            label2:setVisible(false)
        end

        local array3 = CCArray:create()
        array3:addObject( CCDelayTime:create(0.15) )
        array3:addObject( CCCallFunc:create( ShowLabel2 ) )
        array3:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
        label2:runAction( CCSequence:create( array3 ) )

        local function ShowLabel3()
            label3:setVisible(true)
        end

        local function HideLabel3()
            label3:setVisible(false)
        end

        local function MoveOut()
            local array2 = CCArray:create()
            array2:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
            array2:addObject( CCCallFunc:create( HideLabel1 ) )
            label1:runAction( CCSequence:create( array2 ) )

            local bgarray1 = CCArray:create()
            bgarray1:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
            bgarray1:addObject( CCCallFunc:create( HideLabelBG1 ) )
            LabelBg1:runAction( CCSequence:create( bgarray1 ) )

            local array3 = CCArray:create()
            array3:addObject( CCDelayTime:create(0.1) )
            array3:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
            array3:addObject( CCCallFunc:create( HideLabel2 ) )
            label2:runAction( CCSequence:create( array3 ) )

            local bgarray2 = CCArray:create()
            bgarray2:addObject( CCDelayTime:create(0.1) )
            bgarray2:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
            bgarray2:addObject( CCCallFunc:create( HideLabelBG2 ) )
            LabelBg2:runAction( CCSequence:create( bgarray2 ) )

            local array4 = CCArray:create()
            array4:addObject( CCDelayTime:create(0.1) )
            array4:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
            array4:addObject( CCCallFunc:create( HideLabel3 ) )
            array4:addObject( CCDelayTime:create(0.2) )
            array4:addObject( CCCallFunc:create( FlySP ) )
            label3:runAction( CCSequence:create( array4 ) )
        end

        local array4 = CCArray:create()
        array4:addObject( CCDelayTime:create(0.15) )
        array4:addObject( CCCallFunc:create( ShowLabel3 ) )
        array4:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )
        array4:addObject( CCDelayTime:create(0.5) )
        array4:addObject( CCCallFunc:create( MoveOut ) )
        label3:runAction( CCSequence:create( array4 ) )

        local bgarray4 = CCArray:create()
        bgarray4:addObject( CCFadeIn:create(0.2) )
        bgarray4:addObject( CCMoveBy:create(0.2, ccp(startMoveLeftPosX,0) ) )

        local bgarray5 = CCArray:create()
        bgarray5:addObject( CCDelayTime:create(0.1)  )
        bgarray5:addObject( CCCallFunc:create( ShowLabelBG2 ) )
        bgarray5:addObject( CCSpawn:create(bgarray4)  )

        LabelBg2:setOpacity(0)
        LabelBg2:runAction( CCSequence:create( bgarray5 ) )

    end

    return gamePlaySceneInstance
end

