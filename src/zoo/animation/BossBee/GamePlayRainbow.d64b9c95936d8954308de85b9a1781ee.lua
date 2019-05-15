GamePlayRainbow = class(BaseUI)

function GamePlayRainbow:create()
    local instance = GamePlayRainbow.new()
    instance.panelConfigFile = 'flash/scenes/gamePlaySceneUI/rainbow.json'
    instance.builder = InterfaceBuilder:createWithContentsOfFile(instance.panelConfigFile)
    instance:init()
    return instance
end

function GamePlayRainbow:init()
    local ui = self.builder:buildGroup('GPSUI_rainbow')
    BaseUI.init(self, ui)
    self.percent = 0


    -- 彩虹百分比路径
    local pathNode = ui:getChildByName('rainbow'):getChildByName("path")
    local offset = pathNode:getPosition()
    local path = {}
    for i,v in ipairs(pathNode.list) do
        local p = v:getPosition()
        path[i] = ccp(offset.x + p.x, offset.y + p.y)
    end
    pathNode:removeFromParentAndCleanup(true)

    local spine = CardinalSpline.new(path, 0.25)
    self.spine = spine


    -- boss出生动画路径
    local bossPathNode = ui:getChildByName("bossPath")
    local offset = bossPathNode:getPosition()
    local path = {}
    for i,v in ipairs(bossPathNode.list) do
        local p = v:getPosition()
        path[i] = ccp(offset.x + p.x, offset.y + p.y)
    end
    bossPathNode:removeFromParentAndCleanup(true)

    self.bossSpine = CardinalSpline.new(path, 0.02)


    self.mark = ui:getChildByName('rainbow'):getChildByName('mark')
    self.rainbow = ui:getChildByName('rainbow'):getChildByName('rainbow')
    self.rainbowBg = ui:getChildByName('rainbow'):getChildByName('rainbowBg')
    -- self.rainbowBg:setVisible(false)

    self.rainbowWidth = self.rainbow:getContentSize().width
    self.rainbowHeight = self.rainbow:getContentSize().height
    self.maxMarkScale = 1
    self.minMarkScale = 0.6
    self.clipping = SimpleClippingNode:create()
    -- self.clipping = LayerColor:create()
    -- self.clipping:setOpacity(100)
    self.clipping:setContentSize(CCSizeMake(self.rainbowWidth, self.rainbowHeight))
    self.clipping:setRecalcPosition(true)
    self.clipping:setAnchorPoint(ccp(0, 1))
    self.clipping:ignoreAnchorPointForPosition(false)

    self.ui:getChildByName('rainbow'):addChildAt(self.clipping, self.rainbowBg:getZOrder()+1)
    self.clipping:setPositionY(self.rainbow:getPositionY())
    self.clipping:setPositionX(self.rainbow:getPositionX())
    self.baseClippingX = self.rainbow:getPositionX()
    self.rainbow:removeFromParentAndCleanup(false)
    self.clipping:addChild(self.rainbow)
    self.rainbow:setPositionY(self.rainbowHeight)

    self.targetPercent = 0
    self.currentPercent = 0
    self.startPercent = 0
    self.moveTime = 1 -- 1 sec

    self:initStars()
    self:initScheduler()
    self:setPercent(0.001)
end

function GamePlayRainbow:initStars()
    for i = 1, 9 do 
        local star = self.mark:getChildByName('s'..i)
        local pos = ccp(star:getPositionX(), star:getPositionY())
        local delay = i * 0.1
        local baseScale = star:getScaleX()
        local arr = CCArray:create()
        arr:addObject(CCSequence:createWithTwoActions(CCMoveBy:create(17/30, ccp(-13, 3)), CCPlace:create(pos)))
        arr:addObject(CCSequence:createWithTwoActions(CCScaleTo:create(9/30, baseScale*1.1), CCScaleTo:create(8/30, baseScale*0.9)))
        star:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCSpawn:create(arr))))
        star:getChildByName('sprite'):setOpacity(0)
        star:getChildByName('sprite'):runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCSequence:createWithTwoActions(CCFadeIn:create(9/30), CCFadeOut:create(8/30)))))
    end
end

function GamePlayRainbow:removeScheduler()
    if self.schedId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function GamePlayRainbow:initScheduler()
    self:removeScheduler()
    local function callback(dt)
        if self.isDisposed then return end
        -- if _G.isLocalDevelopMode then printx(0, self.currentPercent, self.startPercent, self.targetPercent) end
        if self.currentPercent ~= self.targetPercent then
            local nextPercent = (dt / self.moveTime) * (self.targetPercent - self.startPercent) + self.currentPercent
            if self.startPercent < self.targetPercent then
                if nextPercent > self.targetPercent then
                    nextPercent = self.targetPercent
                end
            elseif self.startPercent > self.targetPercent then
                if nextPercent < self.targetPercent then
                    nextPercent = self.targetPercent
                end
            -- else
            --     nextPercent = self.targetPercent
            end
            -- if _G.isLocalDevelopMode then printx(0, 'dt', dt, 'targetPercent', self.targetPercent, 'startPercent', self.startPercent, 'currentPercent', self.currentPercent, 'nextPercent', nextPercent) end
            local nextPosition = self.spine:calculatePosition(nextPercent)
            local nextAngle = self.spine:calculateAngle(nextPercent)
            self.currentPercent = nextPercent
            -- if _G.isLocalDevelopMode then printx(0, self.currentPercent) end
            self:setMark(nextPosition, nextAngle, nextPercent)
        end
    end
    self.schedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(callback, 1/60, false)
end

function GamePlayRainbow:setMark(position, angle, percent)
    -- if _G.isLocalDevelopMode then printx(0, 'setMark', position.x, position.y, angle) end
    self.clipping:setPositionX(position.x - self.rainbowWidth)
    self.rainbow:setPositionX(-(position.x - self.rainbowWidth))
    self.mark:setPosition(ccp(position.x, position.y))
    self.mark:setRotation(angle)
    self.mark:setScale(self.minMarkScale + (1 - percent) * (self.maxMarkScale - self.minMarkScale))
end

function GamePlayRainbow:setPercent(percent)
    -- if _G.isLocalDevelopMode then printx(0, 'QAAAAAAAAAAAAAAAAAAAAAAAAA setPercent', percent) end
    -- debug.debug()
    self.targetPercent = percent
    self.startPercent = self.currentPercent
end

function GamePlayRainbow:getCurrentPercent()
    return self.targetPercent
end

function GamePlayRainbow:setPercentInstant(percent)
    self.targetPercent = percent
    self.startPercent = percent
    self.currentPercent = percent
    local nextPosition = self.spine:calculatePosition(percent)
    local nextAngle = self.spine:calculateAngle(percent)
    self:setMark(nextPosition, nextAngle, percent)
end

function GamePlayRainbow:dispose()
    self:removeScheduler()
    InterfaceBuilder:unloadAsset(self.panelConfigFile)
    BaseUI.dispose(self)
end

function GamePlayRainbow:getBossPathPositionAngle(percent)
    return self.bossSpine:calculatePosition(percent), self.bossSpine:calculateAngle(percent)
end

function GamePlayRainbow:getMarkPositionInWorldSpaceByPercent(percent)
    return self.mark:getParent():convertToWorldSpace(self.spine:calculatePosition(percent))
end

function GamePlayRainbow:getCurrentMarkPositionInWorldSpace()
    return self.mark:getParent():convertToWorldSpace(self.spine:calculatePosition(self.currentPercent))
end

function GamePlayRainbow:buildDecoCloud()
    local ui = self.builder:buildGroup('GPS_deco_cloud')
    return ui
end

function GamePlayRainbow:buildIsland()
    local ui = self.builder:buildGroup('GPS_Island')
    return ui
end

