BindPhoneGuideLogic = class()

local function isHomeScene()
    return Director:sharedDirector():getRunningScene():is(HomeScene)
end

local instance = nil
function BindPhoneGuideLogic:get()
    if not instance then
        instance = BindPhoneGuideLogic.new()
        instance:init()
    end
    return instance
end

function BindPhoneGuideLogic:init()

end

function BindPhoneGuideLogic:writeFlag()
    CCUserDefault:sharedUserDefault():setBoolForKey("bind.phone.guide.has.played", true)
end

function BindPhoneGuideLogic:isPhoneBinded()
    if UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) ~= nil then
        return true
    end
    return false
end

function BindPhoneGuideLogic:supportPhone()
    local authConfig = PlatformConfig.authConfig
    if type(authConfig) == 'table' then
        for k, v in pairs(authConfig) do
            if v == PlatformAuthEnum.kPhone then
                return true
            end
        end
    elseif authConfig == PlatformAuthEnum.kPhone then
        return true
    end
    return false
end

function BindPhoneGuideLogic:shouldPlayGuide()
    return (not self:isPhoneBinded()) and (not self:hasPlayed()) 
end

function BindPhoneGuideLogic:hasPlayed()
    return CCUserDefault:sharedUserDefault():getBoolForKey("bind.phone.guide.has.played", false)
end

function BindPhoneGuideLogic:onShowLoginBtn(loginBtn)
    if not isHomeScene() then return end
    if CCUserDefault:sharedUserDefault():getBoolForKey("bind.phone.guide.login.has.played", false) then return end
    if not self:supportPhone() then return end
    local image = ResourceManager:sharedInstance():buildGroup("bind_phone_guide_image")
    local localPos = ccp(loginBtn:getGroupBounds():getMaxX(), loginBtn:getGroupBounds():getMaxY())
    local worldPos = loginBtn:getParent():convertToWorldSpace(localPos)
    local finalPos = loginBtn:convertToNodeSpace(ccp(worldPos.x - 60, worldPos.y + image:getGroupBounds().size.height - 60))
    loginBtn:addChild(image)
    image:setPosition(finalPos)
    CCUserDefault:sharedUserDefault():setBoolForKey("bind.phone.guide.login.has.played", true)
end

function BindPhoneGuideLogic:hasPersonalGuidePlayed()
    return CCUserDefault:sharedUserDefault():getBoolForKey("personal.center.btn.guide.has.played", false)
end

function BindPhoneGuideLogic:onOpenSettingBtn(accountBtn)

    if (PrepackageUtil:isPreNoNetWork()) then
        return
    end
    if HomeSceneButtonsManager:getInstance().hasGuideOnScreen == true then 
        return  
    end
    if not isHomeScene() then return end
    if self:hasPersonalGuidePlayed() then return end
    if self.isGuideOnScreen then return end

    self.isGuideOnScreen = true

    local guide1Played = CCUserDefault:sharedUserDefault():getBoolForKey("personal.center.panel.guide.has.played", false)
    local guide2Played = CCUserDefault:sharedUserDefault():getBoolForKey("personal.center.panel.guide.has.played2", false)
    local text = "tutorial.my.card.text1"

    if guide1Played and not guide2Played then
        text = "tutorial.achievement.text1"
    end

    local pos = accountBtn:getParent():convertToWorldSpace(accountBtn:getPosition())
    local action = 
    {
        opacity = 0xCC, 
        text = text,
        panType = "down", panAlign = "viewY", panPosY = pos.y + 200, panFlip = false,
        maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5, touchDelay = 1,
        panelName = 'guide_dialogue_mingpian1',
    }
    local panel = GameGuideUI:panelS(nil, action, false)
    local mask = GameGuideUI:mask(
        action.opacity, 
        action.touchDelay, 
        pos,
        1.5, 
        false, 
        nil, 
        nil, 
        false,
        true)
    mask.setFadeIn(action.maskDelay, action.maskFade)
    self.panel = panel
    self.mask = mask
    local function newOnTouch(evt)
        self.isGuideOnScreen = false
        if panel and not panel.isDisposed then
            panel:removeFromParentAndCleanup(true)
        end
        if mask and not mask.isDisposed then
            mask:removeFromParentAndCleanup(true)
        end

        if accountBtn:hitTestPoint(evt.globalPosition, true) then  
            local event = {name = DisplayEvents.kTouchTap}
            accountBtn.wrapper:dispatchEvent(event)
            if not self:supportPhone() then -- 如果不支持绑定手机，那么这里就是引导的最后一步，应该写下flag
                self:writeFlag()
            end
        else
            -- 点击别处就认为是取消了引导
            self:writeFlag()
        end
    end
    mask:removeEventListenerByName(DisplayEvents.kTouchTap)
    mask:ad(DisplayEvents.kTouchTap, newOnTouch)
    local scene = Director:sharedDirector():getRunningScene()
    if scene then
        scene:addChild(mask, SceneLayerShowKey.POP_OUT_LAYER)
        scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)
    end

    CCUserDefault:sharedUserDefault():setBoolForKey("personal.center.btn.guide.has.played", true)
    HomeScene:sharedInstance().settingButton:updateDotTipStatus()
end

function BindPhoneGuideLogic:onShowAccountPanel(theBtn)
    if not isHomeScene() then return end
    if not self:shouldPlayGuide() then return end
    if self.isGuideOnScreen then return end
    self.isGuideOnScreen = true

    local pos = theBtn:getParent():convertToWorldSpace(theBtn:getPosition())
    local action = 
    {
        opacity = 0xCC, 
        text = "tutorial.game.setting.3",
        panType = "down", panAlign = "viewY", panPosY = pos.y + 300, panFlip = true,
        maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5, touchDelay = 1
    }
    local panel = GameGuideUI:panelS(nil, action, false)
    local mask = GameGuideUI:mask(
        action.opacity, 
        action.touchDelay, 
        ccp(pos.x + theBtn:getGroupBounds().size.width / 2, pos.y - theBtn:getGroupBounds().size.height / 2 + 10),
        2, 
        false, 
        nil, 
        nil, 
        false,
        true)
    mask.setFadeIn(action.maskDelay, action.maskFade)
    self.panel = panel
    self.mask = mask
    local function newOnTouch(evt)
        self.isGuideOnScreen = false
        if panel and not panel.isDisposed then
            panel:removeFromParentAndCleanup(true)
        end
        if mask and not mask.isDisposed then
            mask:removeFromParentAndCleanup(true)
        end

        if theBtn:hitTestPoint(evt.globalPosition, true) then       
            local event = {name = DisplayEvents.kTouchTap}
            theBtn:dispatchEvent(event)
            self:writeFlag() -- 所有引导步均已结束
        else
            -- 点击别处就认为是取消了引导
            self:writeFlag()
        end
    end
    mask:removeEventListenerByName(DisplayEvents.kTouchTap)
    mask:ad(DisplayEvents.kTouchTap, newOnTouch)
    local scene = Director:sharedDirector():getRunningScene()
    if scene then
        scene:addChild(mask, SceneLayerShowKey.POP_OUT_LAYER)
        scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)
    end

end

function BindPhoneGuideLogic:onEnterHomeSceneFromGameplay(settingBtn)
    if not (self:shouldPlayGuide() and UserManager:getInstance().user:getTopLevelId() >= 36) then return end
    if self.isGuideOnScreen then return end
    self.isGuideOnScreen = true

    local pos = settingBtn:getParent():convertToWorldSpace(settingBtn:getPosition())
    local action = 
    {
        opacity = 0xCC, 
        text = "tutorial.game.setting.1",
        panType = "down", panAlign = "viewY", panPosY = pos.y + 400,
        maskDelay = 0.3,maskFade = 0.4 ,panDelay = 0.5, touchDelay = 1
    }
    local panel = GameGuideUI:panelS(nil, action, false)
    local mask = GameGuideUI:mask(
        action.opacity, 
        action.touchDelay, 
        pos,
        1.5, 
        false, 
        nil, 
        nil, 
        false,
        true)
    mask.setFadeIn(action.maskDelay, action.maskFade)

    self.panel = panel
    self.mask = mask
    local function newOnTouch(evt)
        self.isGuideOnScreen = false
        if panel and not panel.isDisposed then
            panel:removeFromParentAndCleanup(true)
        end
        if mask and not mask.isDisposed then
            mask:removeFromParentAndCleanup(true)
        end

        if settingBtn:hitTestPoint(evt.globalPosition, true) then       
            local event = {name = DisplayEvents.kTouchTap}
            settingBtn:dispatchEvent(event)
        else
            -- 点击别处就认为是取消了引导
            self:writeFlag()
        end
    end
    mask:removeEventListenerByName(DisplayEvents.kTouchTap)
    mask:ad(DisplayEvents.kTouchTap, newOnTouch)
    local scene = Director:sharedDirector():getRunningScene()
    if scene then
        scene:addChild(mask, SceneLayerShowKey.POP_OUT_LAYER)
        scene:addChild(panel, SceneLayerShowKey.POP_OUT_LAYER)
    end
end

function BindPhoneGuideLogic:removeGuide()
    if self.panel and not self.panel.isDisposed then
        self.panel:removeFromParentAndCleanup(true)
        self.panel = nil
    end
    if self.mask and not self.mask.isDisposed then
        self.mask:removeFromParentAndCleanup(true)
        self.mask = nil
    end
end
