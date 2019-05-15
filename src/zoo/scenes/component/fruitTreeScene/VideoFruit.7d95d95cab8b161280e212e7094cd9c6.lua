VideoFruit = class(Fruit)
VideoFruit.POS = {x = 128,y = 468}
VideoFruit.FIX_POS = {x = 0,y = 0}
VideoFruit.CREATED_UD_KEY = "fruit.tree.ad.created"
VideoFruit.GUIDE_FLAG = kGuideFlags.FruitTreeVideo_1810

local builder

function VideoFruit:create(id, data)
    print("VideoFruit:create(id, data)",table.tostring(data))
    local ref = VideoFruit.new()
    ref:_init(id,data)
    return ref
end

function VideoFruit:_init(id, data)
    Fruit._init(self,id, data)

    builder = InterfaceBuilder:create(PanelConfigFiles.fruitTreeScene)
    self.video = builder:buildGroup("videoFruit")
    self.video:setPosition(ccp(VideoFruit.FIX_POS.x,VideoFruit.FIX_POS.y))
    self:addChild(self.video)

    local childs = {
        "watchAD",
        -- "video_tomorrow_label",
        -- "video_tomorrow_img",
        -- "video_tomorrow_tip",
        "hit_area"
    }
    for i,v in ipairs(childs) do
        self.video[v] = self.video:getChildByName(v)
    end
    -- self.video.video_tomorrow_tip:setVisible(false)
    
    local function onTouchVideo(evt)
        if not self.isTouchable then return end
        evt.name = kFruitEvents.kNormClicked
        evt.target = self
        self:dispatchEvent(evt)
    end
    self.video.hit_area:setTouchEnabled(true)
    self.video.hit_area:addEventListener(DisplayEvents.kTouchEnd, onTouchVideo)

    local panelChildren = {}
    self.video.hit_area:getVisibleChildrenList(panelChildren)
    for i,v in ipairs(panelChildren) do
        local _ = v.setOpacity and v:setOpacity(0)
    end

    self:refresh(data, "init")
end

function VideoFruit:saveCreatedState(state)
    print("VideoFruit:saveCreatedState()")
    CCUserDefault:sharedUserDefault():setIntegerForKey(VideoFruit.CREATED_UD_KEY,state and 1 or 0)
    CCUserDefault:sharedUserDefault():flush()
end

function VideoFruit:checkShowCreateMovie()
    local index = CCUserDefault:sharedUserDefault():getIntegerForKey(VideoFruit.CREATED_UD_KEY)
    --print("VideoFruit:checkShowCreateMovie()",index)
    if not index or index<1 then
        local hasVideoFruit = FruitModel:sharedInstance().data[self.id]
        if hasVideoFruit then
            self:saveCreatedState(true)
            return
        end
        self:saveCreatedState(true)

        local delayTime = 3
        self.video:setScale(0.01)

        self.video:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(delayTime),
            CCScaleTo:create(0.1,1,1)
            ))

        local anim = nil

        local function onEnd()
            anim:removeFromParentAndCleanup(false)
            self.video:stopAllActions()
            self.video:setScale(1)
        end

        local function playAnim()
            anim = gAnimatedObject:createWithFilename('gaf/videoFruit/videoFruitBorn.gaf')
            anim:setPosition(ccp(-3.5, 18.5))
            anim:setLooped(false)
            anim:start()
            self:addChild(anim)

            self:runAction(CCSequence:createWithTwoActions(
                CCDelayTime:create(delayTime),
                CCCallFuncN:create(onEnd)
                ))
        end

         self:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(0.1),
            CCCallFuncN:create(playAnim)
            ))

    end
end

function VideoFruit:refresh(data, source)
    -- print("VideoFruit:refresh()",data, source,debug.traceback())
    Fruit.refresh(self,data,source)

    local regen, pick, speed = false,false,false

    local hasVideoFruit = FruitModel:sharedInstance().data[self.id]
    local isGuide = source == "guide"
    self.isGuide = isGuide
    if self.video and not self.video.isDisposed then
        local count = InciteManager:getCount(EntranceType.kTree)
        local needWaitTomorrow = count<=0

        if source=="pick" and not data then
            --摘完果子
        end


        self.isTouchable = hasVideoFruit or not needWaitTomorrow
        self.norm:setTouchEnabled(self.isTouchable)

        if not self.isTouchable and not isGuide then
            self:setVisible(false)
            self:saveCreatedState(false)
            return
        end
        self:setVisible(true)


        local regenCount = InciteManager:getCount(EntranceType.kTree,true)
        local isFastRegen = regenCount>0

        if not hasVideoFruit or isFastRegen then
            regen = hasVideoFruit
            pick = hasVideoFruit
            speed = not hasVideoFruit
        else
            regen, pick, speed = FruitModel:sharedInstance():getMethodVisibility(self.id)

        end

        self:checkShowCreateMovie()

        local showFruit = hasVideoFruit
        --print("VideoFruit:refresh()0",showFruit)

        self.norm:setVisible(showFruit)
        self.video:setVisible(not showFruit)
        -- self.video:setTouchEnabled(not showFruit)

        -- self.video.watchAD:setVisible(not showFruit and not needWaitTomorrow)
        -- self.video.video_tomorrow_label:setVisible(not showFruit and needWaitTomorrow)
        -- self.video.video_tomorrow_img:setVisible(not showFruit and needWaitTomorrow)
        -- self.video.needWaitTomorrow = needWaitTomorrow
        -- self.video.needWatchAD = self.video.watchAD:isVisible()
    end


    if self.clicked and not self.clicked.isDisposed then
        if not hasVideoFruit then
            self.clicked.time:setString("")
            
        elseif FruitModel:sharedInstance():getGrowCount(self.id) >= 5 then
            local str =  "已成熟\n不消耗今日可摘取次数哦~"
            self.clicked.time:setString(str)
        end

        self.clicked.regen:setVisible(regen)
        self.clicked.pick:setVisible(pick)
        self.clicked.speed:setVisible(speed)
    end
end

function VideoFruit:showAD(callback)
    print("VideoFruit:showAD()")
    local function onSuccess( ads, placementId, state )
        if state == AdsFinishState.kCompleted then
            local _ = callback and callback()

        elseif state == AdsFinishState.kNotCompleted then
            -- self:refrash()
        else
            -- self:refrash()
        end
    end
    
    local function onFail( ads, code, msg )
        -- self:refrash()
    end

    InciteManager:showAds(EntranceType.kTree,onSuccess,onFail)
end

function VideoFruit:onADCompleted()
    local function onSuccess(evt)
        if not evt or not evt.data then
            return
        end
        InciteManager:subCount( EntranceType.kTree )
        
        local fruitInfo = evt.data.fruitInfo
        self:refresh(fruitInfo)
    end

    local function onFail(evt)
        local errcode = evt and evt.data or nil
        if not errcode then
            -- "error.tip.-6" = "对不起，网络连接失败";
            errcode = -6
        end
        CommonTip:showTip(Localization:getInstance():getText(
            "error.tip."..tostring(errcode)), "negative"
        )
    end

    local function onCancel()
    end

    local function defineHttp( name )
        local http = class(HttpBase)
        function http:load( params )
            if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
            
            local context = self
            local loadCallback = function(endpoint, data, err)
                if err then
                    he_log_info(name .. " error: " .. err)
                    context:onLoadingError(err)
                else
                    he_log_info(name .. " success !")
                    
                    context:onLoadingComplete(data)
                end
            end

            self.transponder:call(name, params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
        end
        return http
    end

    local http = defineHttp("getVideoSDKFruit").new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:ad(Events.kCancel, onCancel)
    http:syncLoad()
end


function VideoFruit:createClickedFruit(hasGuide, animDuration)
    if self.norm.isDisposed then return end

    DcUtil:adsIOSClick({
                sub_category = "click_fruittree_adv",
            })

    -- get & create control
    if not builder then
        builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.fruitTreeScene)
    end

    local hasVideoFruit = FruitModel:sharedInstance().data[-1]
    local regenCount = InciteManager:getCount(EntranceType.kTree,true)
    local isFastRegen = regenCount>0
    if hasVideoFruit and not isFastRegen then
        return Fruit.createClickedFruit(self,hasGuide,animDuration)
    end

    self.clicked = builder:buildGroup(isFastRegen and "clickedVideoFruit" or "clickedVideoFruitEx")
    self.clicked.fruit = self.clicked:getChildByName("fruit")
    self.clicked.methodRing = self.clicked:getChildByName("methodRing")
    self.clicked.regen = self.clicked:getChildByName("regen")
    self.clicked.pick = self.clicked:getChildByName("pick")
    self.clicked.speed = self.clicked:getChildByName("speed")
    -- self.clicked.speed.number = self.clicked.speed:getChildByName("number")
    self.clicked.reward = self.clicked:getChildByName("reward")
    self.clicked.time = self.clicked:getChildByName("time")
    self.clicked.icon2 = self.clicked:getChildByName("icon2")
    self.clicked.icon3 = self.clicked:getChildByName("icon3")
    self.clicked.icon4 = self.clicked:getChildByName("icon4")

    self.clicked.icon2:setVisible(false)
    self.clicked.icon3:setVisible(false)
    self.clicked.icon4:setVisible(false)

    if isFastRegen then
        local dot = getRedNumTip()
        dot:setNum(1)
        dot:setPositionXY(50,50)
        self.clicked.regen:addChild(dot)
    end

    -- state
    local function setMethodUI(ctrl, text)
        local name = {"regen", "pick", "speed"}
        for k, v in ipairs(name) do
            local icn = ctrl:getChildByName("icn_"..v)
            if icn and v ~= text then icn:removeFromParentAndCleanup(true) end
        end
        local label = ctrl:getChildByName("text")
        local size = ctrl:getChildByName('textSize')
        size:setVisible(false)
        local box = {x=size:getPositionX(), y=size:getPositionY(), width=size:getContentSize().width*size:getScaleX(), height=size:getContentSize().height*size:getScaleY()}

        local label = ctrl:getChildByName("text")
        if text=="pick" or (text=="regen" and not isFastRegen) then 
            label:changeFntFile("fnt/guoshu_gai_1.fnt")
            label:setText(Localization:getInstance():getText("fruit.tree.scene."..text))
        else
            label:changeFntFile("fnt/guoshu_gai_2.fnt")
            label:setText(text=="regen" and "立刻重生" or "立刻成熟")
        end
        InterfaceBuilder:centerInterfaceInbox(label, box, true)
    end
    setMethodUI(self.clicked.regen, "regen")
    setMethodUI(self.clicked.speed, "speed")
    setMethodUI(self.clicked.pick, "pick")

    -- local charWidth = 36
    -- local charHeight = 36
    -- local charInterval = 16
    -- local fntFile = "fnt/target_amount.fnt"
    -- local newLabel = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
    -- newLabel:setAnchorPoint(ccp(0,1))
    -- newLabel:setPositionX(self.clicked.speed.number:getPositionX())
    -- newLabel:setPositionY(self.clicked.speed.number:getPositionY())
    -- self.clicked.speed.number:removeFromParentAndCleanup(true)
    -- self.clicked.speed:addChild(newLabel)
    -- self.clicked.speed.number = newLabel
    self:refresh(nil, "init")
    local position = self:getPosition()
    local wPosition = self:getParent():convertToWorldSpace(ccp(position.x, position.y))
    self.clicked:setPosition(ccp(wPosition.x, wPosition.y))

    -- event listener
    local function onAnimFinish()
        local function onReleaseOutside(evt)
            local function isClickOutside(ui)
                if ui:isVisible() then
                    local pos = ui:getPosition()
                    local parent = ui:getParent()
                    local position = parent:convertToWorldSpace(ccp(pos.x, pos.y))
                    local distance = ccpDistance(position, evt.globalPosition)
                    if distance < 75 then return false end
                end
                return true
            end
            local inside = true
            if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
                inside = inside and not isClickOutside(self.clicked.regen)
            end
            if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
                inside = inside and not isClickOutside(self.clicked.regen)
            end
            if self.clicked and self.clicked.regen and not self.clicked.regen.isDisposed then
                inside = inside and not isClickOutside(self.clicked.regen)
            end
            if not inside then self:_clickedOutside() end
        end

        if not self.clicked or self.clicked.isDisposed then return end
        if not hasGuide then self.clicked:setTouchEnabledWithMoveInOut(true) end
        self.clicked:addEventListener(DisplayEvents.kTouchEnd, onReleaseOutside)
        if self.clicked.isDisposed then return end
        local function onRegenerate()
            print("VideoFruit:onRegenerate()")
            local function doRegenerate()
                if RequireNetworkAlert:popout() then self:_regenerate() end
            end
            if isFastRegen then
                self:showAD(doRegenerate)
            else
                doRegenerate()
            end
        end
        self.clicked.regen:setTouchEnabled(true)
        self.clicked.regen:addEventListener(DisplayEvents.kTouchTap, onRegenerate)
        local function onPick()
            print("VideoFruit:onPick()")
            if RequireNetworkAlert:popout() then self:_pick() end
        end
        self.clicked.pick:setTouchEnabled(true)
        self.clicked.pick:addEventListener(DisplayEvents.kTouchTap, onPick)

        local function onCreateVideoFruit()
            print("VideoFruit:onCreateVideoFruit()")
            self:onADCompleted()
        end
        
        local function onSpeed()
            print("VideoFruit:onSpeed()",self.isGuide)
            if self.isGuide then return end
            self:showAD(onCreateVideoFruit)
        end
        self.clicked.speed:setTouchEnabled(true)
        self.clicked.speed:addEventListener(DisplayEvents.kTouchTap, onSpeed)
    end
    self:_clickedEnterAnim(self.clicked, animDuration or 0.3, onAnimFinish)

    return self.clicked
end

--检查视频果子在重生时的版本
function VideoFruit:checkRegenerateVersion(id)
    print("VideoFruit:checkRegenerateVersion",id)
    if id>0 then
        return 0
    end
    --仅首次重生可以视频免费跳过生长CD，之后的为普通重生
    local regenCount = InciteManager:getCount(EntranceType.kTree,true)
    print("VideoFruit:checkRegenerateVersion(id)",id,regenCount)
    return regenCount>0 and 2 or 0
end
