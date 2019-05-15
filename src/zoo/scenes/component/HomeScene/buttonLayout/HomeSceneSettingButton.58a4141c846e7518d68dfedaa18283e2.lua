require 'zoo.panel.NewGameSettingPanel'
require 'zoo.panel.AccountPanel'
require 'zoo.common.FAQ'

require 'zoo.scenes.component.HomeScene.buttonLayout.HomeSceneSettingButtonManager'
require 'zoo.scenes.component.HomeScene.iconButtons.FcButton'
require 'zoo.scenes.component.HomeScene.iconButtons.SettingButton'
require 'zoo.scenes.component.HomeScene.iconButtons.ForumButton'
require 'zoo.scenes.component.HomeScene.iconButtons.AccountButton'
require 'zoo.scenes.component.HomeScene.iconButtons.FAQButton'

require "zoo.PersonalCenter.PersonalCenterManager"


local function getFAQParams()
    return FAQ:getParams()
end

local function getNewFAQurl(params)
    return FAQ:getUrl("http://fansclub.happyelements.com/fans/faq.php",params)
end


HomeSceneSettingButton = class(BaseUI)
local ButtonState = table.const{
    kNoButton = 0,
}

function HomeSceneSettingButton:create(btnBarEvent)
    local bar = HomeSceneSettingButton.new()
    bar.btnBarEvent = btnBarEvent
    bar:init()
    return bar
end

function HomeSceneSettingButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_left_bar')

    BaseUI.init(self, self.ui)

    self.buttonsInfoTable = {}

    self.visibleSize    = CCDirector:sharedDirector():getVisibleSize()
    self.visibleOrigin  = CCDirector:sharedDirector():getVisibleOrigin()

    self.blueBtn = HideAndShowButton:create(self.ui:getChildByName("blueBtn"))
    self.blueBtn:ad(DisplayEvents.kTouchTap, function ()
        
        self:onBlueBtnTap()
    end)

    HomeSceneSettingButtonManager.getInstance():setBtnGroupBar(self)

    local hideFCInReview = false
    if __IOS and MaintenanceManager:getInstance():isInReview() then
        hideFCInReview = true
    end
    if not (PlatformConfig:isPlayDemo() or hideFCInReview) then
        if FAQ:isButtonVisible() then
            if PlatformConfig:isQQPlatform() then
                if MaintenanceManager:getInstance():isEnabled("Close_YYB_BBS", false) then
                    HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kNewFaqBtn, true)
                else
                    HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kFcBtn, true)
                end
            else
                if FAQ:useNewFAQ() then
                    if not FAQ:showNewFAQButtonOutside() then
                        HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kNewFaqBtn, true)
                    end
                else
                    if MaintenanceManager:getInstance():isEnabled("OldFCEnable", false) then
                        HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kFcBtn, true)
                    end
                end
            end
        end
        if PlatformConfig:isQQPlatform() and not MaintenanceManager:getInstance():isEnabled("Close_YYB_BBS", false) then
            HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kForumBtn, self:shouldShowForumBtn())
        end
    end

    HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kAccountBtn, true)
    HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kSettingBtn, true)
    HomeSceneSettingButtonManager.getInstance():setButtonShowPosState(HomeSceneSettingButtonType.kBagBtn, true)
end

function HomeSceneSettingButton:onBgTap()
    -- self:hideButtons()
    local node = CocosObject.new(CCNode:create())
    local function delayHide()
        if not self.isDisposed then
            self:hideButtons()
        end
        node:removeFromParentAndCleanup(true)
    end
    node:runAction(CCCallFunc:create(delayHide))
    self:addChild(node)
end

function HomeSceneSettingButton:onBlueBtnTap()
    self:hideButtons()
end

local function getBgNameByBtnCount(count)
    if count >= 1 and count <= 4 then
        return 'buttonBar_bg' .. count
    elseif count == 5 then
        return 'buttonBar_bg4',485
    elseif count == 6 then
        return 'buttonBar_bg4',485
    elseif count == 7 then
        return 'buttonBar_bg4',605
    elseif count == 8 then
        return 'buttonBar_bg4',605
    end
    return ret
end

function HomeSceneSettingButton:initBg(count)
    local bgName, height = getBgNameByBtnCount(count)
    local bg = ResourceManager:sharedInstance():buildGroup(bgName)

    if height then
        local bgSprite = bg:getChildByName("sprite")
        local bgSize = bgSprite:getContentSize()
        local bounds = bgSprite:boundingBox()
        bgSprite:setVisible(false)

        local newSprite = Scale9Sprite:createWithSpriteFrame(
            bgSprite:displayFrame(),
            CCRectMake(bgSize.width/3,bgSize.height/2,bgSize.width/3,2)
        )       
        newSprite:setPreferredSize(CCSizeMake(bgSize.width,height))
        newSprite:setAnchorPoint(ccp(0,1))
        newSprite:setPositionX(bgSprite:getPositionX())
        newSprite:setPositionY(height - bgSize.height + bgSprite:getPositionY())
        bg:addChild(newSprite)
    end

    local x = 2
    local y = 0

    bg:setScaleX(-1)
    bg:setPosition(ccp(x, y))
    self.ui:addChildAt(bg, 0)
    self.bg = bg
    self.animBg = bg

    self.bg:setTouchEnabled(true, 0, true)
    self.bg:ad(DisplayEvents.kTouchBegin, function ()
        self:onBgTap()
    end)

    self.bg.hitTestPoint = function (worldPosition, useGroupTest)
        return true
    end

    local dotTipVisible = false
    self.blueBtn:setRedDotVisible(dotTipVisible)
end

function HomeSceneSettingButton:showButtons(endCallback, isClick)
    if self.isButtonsShown then return end
    self.isButtonsShown = true

    self:initBg(HomeSceneSettingButtonManager:getInstance():getButtonCount())
    local size = self.bg:getGroupBounds().size
    --黑背景动画
    local bgWidth, bgHeight = size.width, size.height --HomeSceneButtonsManager.getInstance():getBarBgSize()
    --加号按钮动画
    self.bg:setTouchEnabled(false)
    self.blueBtn:setEnable(false)
    self.blueBtn:playAni(function ()
        self.blueBtn:setEnable(true)
        if endCallback then 
            endCallback()
        end
    end)

    local baseScaleX = -1
    local baseScaleY = 1
    local seqArr = CCArray:create()
    seqArr:addObject(CCScaleTo:create(2/24, 0.9*baseScaleX, 1*baseScaleY))
    seqArr:addObject(CCScaleTo:create(2/24, 1.1*baseScaleX, 1.1*baseScaleY))
    seqArr:addObject(CCScaleTo:create(2/24, 0.95*baseScaleX, 1*baseScaleY))
    seqArr:addObject(CCScaleTo:create(1/24, 1.05*baseScaleX, 1.05*baseScaleY))
    seqArr:addObject(CCScaleTo:create(1/24, 1*baseScaleX, 1*baseScaleY))
    seqArr:addObject(CCCallFunc:create(function ()
        self.bg:setTouchEnabled(true, 0, false)
        for i,v in ipairs(self.buttonsInfoTable) do
            v.wrapper:setTouchEnabled(true, 0, true)
        end
    end))

    local pos = self:convertToNodeSpace(ccp(100, 100))
    --加防点击穿透层
    local touchLayer = LayerColor:create()
    touchLayer:setColor(ccc3(255,0,0))
    touchLayer:setOpacity(0)
    touchLayer:setContentSize(CCSizeMake(bgWidth, bgHeight-120))
    touchLayer:setTouchEnabled(true, 0, true)
    touchLayer:setPosition(ccp(-bgWidth+60, 57))
    self.animBg:addChild(touchLayer)
    self.animBg:runAction(CCSequence:create(seqArr))
    local calltrace = debug.traceback()
    local buttonTypeTable = HomeSceneSettingButtonManager.getInstance():getBtnTypeInfoTable()
    for row,rowConfig in pairs(buttonTypeTable) do
        for col,btnConfig in ipairs(rowConfig) do
            local buttonNode = {}
            buttonNode.btn = self:createButton(btnConfig.btnType)
            if row == 1 then 
                buttonNode.row = col + 1 
            else
                buttonNode.row = col
            end
            if buttonNode.btn ~= ButtonState.kNoButton then 
                buttonNode.calltrace = calltrace -- online debug
                buttonNode.wrapper = buttonNode.btn.wrapper
                buttonNode.wrapper:setTouchEnabled(false)
                self:addChild(buttonNode.btn)
                buttonNode.btn:setPosition(ccp(btnConfig.posX, btnConfig.posY))
                buttonNode.btn:setScale(0)
                table.insert(self.buttonsInfoTable, buttonNode)
            end
        end
    end

    for i,v in ipairs(self.buttonsInfoTable) do
        local seqArr1 = CCArray:create()
        seqArr1:addObject(CCDelayTime:create(v.row * 0.05 - 0.05))
        seqArr1:addObject(CCScaleTo:create(3/24, 0.9))
        seqArr1:addObject(CCScaleTo:create(2/24, 1.1))
        seqArr1:addObject(CCScaleTo:create(2/24, 0.95))
        seqArr1:addObject(CCScaleTo:create(1/24, 1.05))
        seqArr1:addObject(CCScaleTo:create(1/24, 1))
        v.btn:runAction(CCSequence:create(seqArr1))
    end
    -- if self.accountBtn and isClick then
        -- BindPhoneGuideLogic:get():onOpenSettingBtn(self.accountBtn)
    -- end
end

function HomeSceneSettingButton:hideButtons()
    if not self.isButtonsShown then return end
    self.isButtonsShown = false
    
    self.bg:setTouchEnabled(false)
    self.blueBtn:setEnable(false)

    local seqArr = CCArray:create()
    seqArr:addObject(CCScaleTo:create(1/24, -1.05, 1.05))
    seqArr:addObject(CCScaleTo:create(2/24, -0.4, 0.4))
    seqArr:addObject(CCHide:create())
    self.animBg:runAction(CCSequence:create(seqArr))

    local buttonTypeTable = HomeSceneSettingButtonManager.getInstance():getBtnTypeInfoTable()
    local onelineBtnNum = #buttonTypeTable[2]
    local buttonTableSize = #self.buttonsInfoTable
    for i,v in ipairs(self.buttonsInfoTable) do
        if v.wrapper.isDisposed then
            he_log_error(tostring(buttonTableSize) .. " - wrapper disposed:"..tostring(v.calltrace))
        else
            v.wrapper:setTouchEnabled(false)
            local seqArr1 = CCArray:create()
            local time = onelineBtnNum * 1/24 - v.row * 1/24
            seqArr1:addObject(CCDelayTime:create(time))
            seqArr1:addObject(CCScaleTo:create(1/24, 1.1))
            seqArr1:addObject(CCScaleTo:create(2/24, 0))
            v.btn:stopAllActions()
            v.btn:runAction(CCSequence:create(seqArr1))
        end
    end

    self.blueBtn:playAni(function ()
        self.btnBarEvent:dispatchCloseEvent()
        self:removePopout()
    end)
end

-- function HomeSceneSettingButton:popout(endCallback, position, isClick)
--     local scene = Director:sharedDirector():getRunningScene()
--     if scene then
--         if scene:is(HomeScene) then
--             scene:addChild(self)
--             self:setPosition(position)
--             self:showButtons(endCallback, isClick)
--         else
--             assert(false, "popout not in homescene")
--         end
--     else
--         print("function HomeSceneSettingButton:popout is a nil value")
--     end
-- end

function HomeSceneSettingButton:removePopout()
    HomeSceneSettingButtonManager.getInstance():setBtnGroupBar(nil)
    self:removeFromParentAndCleanup(true)
end

function HomeSceneSettingButton:createButton(buttonType)
    local button = ButtonState.kNoButton
    if buttonType == HomeSceneSettingButtonType.kNull then
    elseif buttonType == HomeSceneSettingButtonType.kBagBtn then
        button = BagButton:create()
        self.bagButton = button
        self.bagButton.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            self:popoutBagPanel()
        end)
    elseif buttonType == HomeSceneSettingButtonType.kFcBtn then
        button = FcButton:create()
        button.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            if (PrepackageUtil:isPreNoNetWork()) then
                PrepackageUtil:showSettingNetWorkDialog()
            else
                self:onFcBtnTapped()
            end
        end)
        self.fcButton = button
    elseif buttonType == HomeSceneSettingButtonType.kAccountBtn then
        button = AccountButton:create()
        button.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            self:onAccountBtnTapped()
        end)
        self.accountBtn = button
    elseif buttonType == HomeSceneSettingButtonType.kSettingBtn then
        button = SettingButton:create()
        button.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            self:onSettingPanelBtnTapped()
        end)
        self.settingButton = button
    elseif buttonType == HomeSceneSettingButtonType.kForumBtn then
        if PlatformConfig:isQQPlatform() then 
            button = QQForumButton:create()
        else
            button = ForumButton:create()
        end
        button.wrapper:addEventListener(DisplayEvents.kTouchTap, function ()
            if self.isDisposed then return end
            self:onForumBtnTapped()
        end)
        self.forumButton = button
    elseif buttonType == HomeSceneSettingButtonType.kNewFaqBtn then
        button = FAQButton:createButton(true, function() self:hideButtons() return false end)
        button:setPosition(ccp(1, -4))
        self.newFaqButton = button
    else
        button = ForumButton:create()
    end

    return button
end

function HomeSceneSettingButton:popoutBagPanel()
    DcUtil:iconClick("click_bag_icon")
    self:hideButtons()
    local bagButtonPos              = self.bagButton:getPosition()
    local bagButtonParent           = self.bagButton:getParent()
    local bagButtonPosInWorldSpace  = bagButtonParent:convertToWorldSpace(ccp(bagButtonPos.x, bagButtonPos.y))
    local panel = BagPanel:createBagPanel(bagButtonPosInWorldSpace)
    if panel then 
        panel:popout()
    end
end

function HomeSceneSettingButton:onFcBtnTapped()
    DcUtil:iconClick("click_service_icon")
    self:hideButtons()

    if PrepackageUtil:isPreNoNetWork() then
        PrepackageUtil:showInGameDialog()
    else
        if PlatformConfig:isQQPlatform() then
            FAQ:openFAQClientIfLogin(nil, FAQTabTags.kKeFu)
        else
            if __WP8 then
                Wp8Utils:ShowMessageBox("QQ群: 114278702(满) 313502987\n联系客服: xiaoxiaole@happyelements.com", "开心消消乐沟通渠道")
            else
                FAQ:openFAQClientIfLogin(nil, FAQTabTags.kSheQu)
            end
        end

        -- 点击后重置小红点显示逻辑
        resetRedDotRefresh()

        self.fcButton:refresh()
    end
end

function HomeSceneSettingButton:onSettingPanelBtnTapped()
    DcUtil:iconClick("click_set_up_icon")
    self:hideButtons()
    Notify:dispatch("QuitNextLevelModeEvent")
    NewGameSettingPanel:create(0):popout()
end

function HomeSceneSettingButton:onAccountBtnTapped()
    DcUtil:iconClick("click_user_icon")
    
    Notify:dispatch("QuitNextLevelModeEvent")

    --PopoutManager:sharedInstance():add(AccountPanel:create(), true, false)
    if PrepackageUtil:isPreNoNetWork() and not PlatformConfig:isPlayDemo() then
        if (__ANDROID) then
            PrepackageUtil:showSettingNetWorkDialog()
        end
    else
         self:hideButtons()
         PersonalCenterManager:showPersonalCenterPanel()
    end
end

function HomeSceneSettingButton:shouldShowForumBtn()
    if __WIN32 then return true end
    -- if __IOS_QQ or PlatformConfig:isQQPlatform() then
    --     if _G.sns_token and UserManager.getInstance().profile:isQQBound() then
    --         return true
    --     end
    -- end
    if MaintenanceManager:getInstance():isEnabled("QQForumAvailable", true) 
     and _G.sns_token and _G.sns_token.authorType == PlatformAuthEnum.kQQ then
        return true
    end
    return false
end

function HomeSceneSettingButton:onForumBtnTapped()
    DcUtil:iconClick("click_forum_icon")
    self:hideButtons()

    if __IOS_QQ then
        if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
            SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
        end
        waxClass{"OnCloseCallback",NSObject,protocols={"WaxCallbackDelegate"}}
        function OnCloseCallback:onResult(ret) 
            if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
                SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
            end
        end

        local formumUrl = FAQ:getUrl("http://fansclub.happyelements.com/fans/ff.php",getFAQParams())
        OpenUrlHandleManager:openUrlWithWebview_onClose(formumUrl, OnCloseCallback:init())
    elseif PlatformConfig:isQQPlatform() then
        local function startAppBar(sub)
            -- ShareManager:openAppBar( sub )
            local ysdkProxy = luajava.bindClass("com.happyelements.android.animal.ysdklibrary.YYBYsdkProxy"):getInstance()
            ysdkProxy:openPerformFeature("bbs")
        end
        pcall(startAppBar)
    end
end

