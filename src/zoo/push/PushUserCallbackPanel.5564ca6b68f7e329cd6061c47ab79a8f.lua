-- 通知召回

local PushUserCallbackPanel = class(CocosObject)

function PushUserCallbackPanel:create(rewards,callback,needEnterLevel)
    print("PushUserCallbackPanel:create(rewards,callback)",table.tostring(rewards))
    
	local panel = PushUserCallbackPanel.new(CCNode:create())
    panel.needEnterLevel=needEnterLevel
	panel:init(rewards,callback)
    panel:popout()
	return panel
end

function PushUserCallbackPanel:init(rewards,callback)
    self.rewards=rewards
    self.callback=callback

    self:initGaf()
    self:initRewards()
	self:initTouch()
end

function PushUserCallbackPanel:initTouch()
    local btnW=400
    

    local backBlocking = LayerColor:create()
    backBlocking:setAnchorPoint(ccp(1,0.5))
    backBlocking:setColor(ccc3(0, 20, 0))
    backBlocking:setOpacity(0)
    backBlocking:setContentSize(CCSizeMake(btnW, 200))
    backBlocking:setPosition(ccp(360-btnW*0.5,-1580))
    backBlocking:setTouchEnabled(true, 0, true)
    backBlocking:ad(DisplayEvents.kTouchBegin, function(event)
        self:onClose()
    end)
    self.con:addChild(backBlocking)

    local builder = InterfaceBuilder:createWithContentsOfFile("ui/common_ui.json")
    local btnUI = builder:buildGroup("ui_buttons_new/btn_text")
    
    backBlocking:addChild(btnUI)
    local tmpBtn = GroupButtonBase:create(btnUI)
    tmpBtn:setString(self.needEnterLevel and "领取并闯关" or "领取")
    tmpBtn:setPosition(ccp(btnW*0.5,100))
    tmpBtn:ad(DisplayEvents.kTouchTap, function () 
        self:onClose()
    end)
    self.btn = tmpBtn

    backBlocking:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(1.9),
            CCMoveTo:create(0.1,ccp(360-btnW*0.5,-1180))
            ))
end

function PushUserCallbackPanel:initRewards()
    self.rewardsList={}
    -- self.rewards[2]=self.rewards[1]
    -- self.rewards[3]=self.rewards[1]
    local n=#self.rewards
    local gap = 150+(4-n)*40
    for i,v in ipairs(self.rewards) do
        local tx=360+(i-n*0.5-0.5)*gap
        local ty = -540-math.abs(i-n*0.5-0.5)*70

        local node=CocosObject:create()
        node:setPosition(ccp(360, -840))
        node:setScale(0.01)
        self.con:addChild(node)
        local actionMove=CCSpawn:createWithTwoActions(
            CCMoveTo:create(0.5,ccp(tx,ty)),
            CCScaleTo:create(0.5,1,1)
            )
        local actionSeq=CCSequence:createWithTwoActions(
            CCDelayTime:create(1.9),
            CCEaseBackOut:create(actionMove)
            )
        node:runAction(actionSeq)

        local anim = gAnimatedObject:createWithFilename('gaf/bubble/bubble.gaf')
        anim:setPosition(ccp(-125, 125))
        anim:setLooped(true)
        anim:start()
        node:addChild(anim)

        local rewardIcon = ResourceManager:sharedInstance():buildItemSprite(v.itemId)
        rewardIcon:setAnchorPoint(ccp(0.5,0.5))
        -- rewardIcon:setPositionXY(tx,ty)
        node:addChild(rewardIcon)

        local text = BitmapText:create("x" ..tostring(v.num or 0), "fnt/profile2018.fnt")
        text:setScale(2)
        text:setPositionXY(20,-50)
        node:addChild(text)

        self.rewardsList[i]=node
    end
end

function PushUserCallbackPanel:initGaf()
    local winSize = Director:sharedDirector():getWinSize()
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()

    -- local scene = Director:sharedDirector():getRunningScene()

    -- local container = Layer:create()
    -- container:setTouchEnabled(true, 0, true)
    -- self:addChild(container)

    local container=self

    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height+vo.y*2))
    greyCover:setPosition(ccp(0 ,  -winSize.height))
    container:addChild(greyCover)
    self.bg = greyCover

    self.con=CocosObject:create()
    self:addChild(self.con)
    
    local anim = gAnimatedObject:createWithFilename('gaf/notification/notification_user_callback.gaf')
    local animPos = ccp(215, -200)
    anim:setPosition(animPos)
    anim:setLooped(false)
    anim:start()

    self.con:addChild(anim)
end

function PushUserCallbackPanel:onClose()
    print("PushUserCallbackPanel:onClose()")

    local callback = self.callback

    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self,true)

    local _ = callback and callback()
end

function PushUserCallbackPanel:popout()
    self.allowBackKeyTap = true

    PopoutManager:sharedInstance():add(self, false)
    -- self:popoutShowTransition()

    local winSize = Director:sharedDirector():getWinSize()
    self:setContentSize(CCSizeMake(winSize.width, winSize.height))

    local visibleSize =  Director:sharedDirector():getVisibleSize()
    local visibleRatio = Director:sharedDirector():ori_getVisibleSize().height / visibleSize.width
    if visibleRatio<1280/720 then
        scale = visibleSize.height / 1280
        self.con:setScale(scale)
        self.con:setPositionX(visibleSize.width*(1-scale)*0.5)
    end
end

function PushUserCallbackPanel:onKeyBackClicked(...)
    print("PushUserCallbackPanel:onKeyBackClicked()")

    if self.allowBackKeyTap then
        self:onClose()
    end
end

return PushUserCallbackPanel

