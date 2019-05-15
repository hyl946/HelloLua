local NEXT_PAGE_TIME = 10
local MIN_READ_TIME = 10

require 'zoo.panel.IosAliCartoonPanel'

local function shouldShowIOSAliGuide()
    return IosAliGuideUtils:shouldShowIOSAliGuide()
end


local function addReward(rewards)
    UserManager:getInstance():addRewards(rewards)
    UserService:getInstance():addRewards(rewards)
    GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kStore, rewards, DcSourceType.kIosPayGuide)

    if HomeScene:sharedInstance().coinButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().coinButton:updateView()
    end
    if HomeScene:sharedInstance().goldButton then
        HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().goldButton:updateView()
    end
end

require 'zoo.net.Http'
local getRewardHttp = class(HttpBase)
function getRewardHttp:load()
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end    
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("getRewardHttp error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("getRewardHttp success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call("activityReward", { actId = 37 , rewardId = 1 }, loadCallback, rpc.SendingPriority.kHigh, false)
end

IosPayCartoonPanel = class(BasePanel)
function IosPayCartoonPanel:create(cartoonCloseCallback)
    local instance = IosPayCartoonPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.ios_pay_cartoon_panel)
    instance:init(cartoonCloseCallback)
    return instance
end

function IosPayCartoonPanel:init(cartoonCloseCallback)
    local vs = Director:sharedDirector():getVisibleSize()
    local ui = self:buildInterfaceGroup('ios_payguide_phone_panel')
    self.targetScale = vs.height / ui:getGroupBounds().size.height * 0.9
    ui:setScale(self.targetScale)

    BasePanel.init(self, ui)
    self.pager = ui:getChildByName('pager')
    self.selected = self.pager:getChildByName('selected')
    for i=1, 5 do 
        self['page'..i] = ui:getChildByName('page'..i)
        self['dot'..i] = self.pager:getChildByName('dot'..i)
        self['animPos'..i] = ui:getChildByName('animPos'..i)
        self['animPos'..i]:setVisible(false)
    end
    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.btn:setColorMode(kGroupButtonColorMode.blue)
    self.closeBtn = ui:getChildByName('closeBtn')
    self.touchMask = Layer:create()
    local function onTouchTap(event)
        local pos = ccp(event.globalPosition.x, event.globalPosition.y)
        if self.closeBtn:hitTestPoint(pos, true) then
            self:onCloseBtnTapped()
        elseif self.btn.groupNode:hitTestPoint(pos, true) then
            self:onBtnTapped()
        else
            self:onMaskTapped()
        end
    end
    local function onTouchBegin(event)
        if _G.isLocalDevelopMode then printx(0, 'touch begin') end
        self.beginX = event.globalPosition.x
        self.beginY = event.globalPosition.y

    end
    local function onTouchMove(event)

    end
    local function onTouchEnd(event)
        if _G.isLocalDevelopMode then printx(0, 'touch end') end
        local distanceX = event.globalPosition.x - self.beginX
        local distanceY = event.globalPosition.y - self.beginY
        if math.abs(distanceX) > math.abs(distanceY) then
            if distanceX > 10 then
                self:prevPage()
            elseif distanceX < -10 then
                self:nextPage()
            end
        end
    end
    self.touchMask.hitTestPoint = function (_self, worldPosition, useGroupTest)
        return true
    end
    self.touchMask:ad(DisplayEvents.kTouchTap, onTouchTap)
    self.touchMask:ad(DisplayEvents.kTouchBegin, onTouchBegin)
    self.touchMask:ad(DisplayEvents.kTouchMove, onTouchMove)
    self.touchMask:ad(DisplayEvents.kTouchEnd, onTouchEnd)
    self.touchMask:setTouchEnabled(true, 0, true)
    self.ui:addChild(self.touchMask)

    self.cartoonCloseCallback = cartoonCloseCallback

    self.cdSeconds = NEXT_PAGE_TIME
    self.curIndex = 1
    self.playTime = 0

    local function onTick()
        if self.isDisposed then return end
        self.playTime = self.playTime + 1
        if self.isPaused then return false end
        self.cdSeconds = self.cdSeconds - 1
        if self.cdSeconds <= 0 then
            self:nextPage()
        end
    end
    self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
end

function IosPayCartoonPanel:onMaskTapped()

end

function IosPayCartoonPanel:skeleton()
    self.anim = ArmatureNode:create('huanxiong_pointing/huanxiong_pointing')
    local scene = Director:sharedDirector():getRunningScene()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local vs = Director:sharedDirector():getVisibleSize()
    local function animationCallback()
        if self.isDisposed then return end
        self.anim:playByIndex(1, 0)
    end
    scene:addChild(self.anim, SceneLayerShowKey.TOP_LAYER)
    self.anim:playByIndex(0, 1)
    self.anim:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
    -- self.anim:setRotation(-15)
    self.anim:setPositionX(vs.width)
    self.anim:setPositionY(vs.height / 2) -- 初始化只需粗略位置即可
    self.anim:setScale(self.targetScale * 0.8)
end

function IosPayCartoonPanel:removeSkeleton()
    if self.anim and not self.anim.isDisposed then
        self.anim:removeFromParentAndCleanup(true)
        self.anim = nil
    end
end

function IosPayCartoonPanel:onCloseBtnTapped()
    if not CCUserDefault:sharedUserDefault():getBoolForKey("ios.pay.guide.cartoon.played", false)
    and self.playTime < MIN_READ_TIME then
        CommonTip:showTip('先看看小浣熊为您准备的教程吧', 'positive')
        return
    end
    CCUserDefault:sharedUserDefault():setBoolForKey("ios.pay.guide.cartoon.played", true)
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
    if self.cartoonCloseCallback then
        self.cartoonCloseCallback()
    end
end

function IosPayCartoonPanel:popout()
    DcUtil:UserTrack({ category='activity', sub_category='click_ios_tutorial'})
    self:setPositionForPopoutManager()
    -- self:setPositionX(self:getPositionX() + 20*self.targetScale) -- 因为有个原件出框导致偏移
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false)
    self.allowBackKeyTap = true
    -- self:skeleton()
    self:initPlay()
end

function IosPayCartoonPanel:initPlay()
    self.curIndex = 1
    self:gotoPage(1)
    self.cdSeconds = NEXT_PAGE_TIME
    self.isPaused = false
    self:updateButton()
end

function IosPayCartoonPanel:onBtnTapped()
    if self.curIndex < 5 then
        if self.isPaused then
            self:resume()
            self:updateButton()
        else
            self:pause()
            self:updateButton()
        end
    else
        self:replay()
    end
end

function IosPayCartoonPanel:updateButton()
    if self.curIndex == 5 then
        self.btn:setString('再看一遍')
    else
        if self.isPaused then
            self.btn:setString('开始')
        else
            self.btn:setString('暂停')
        end
    end
    -- local pos = self['animPos'..self.curIndex]:getParent():convertToWorldSpace(self['animPos'..self.curIndex]:getPosition())
    -- self.anim:runAction(CCMoveTo:create(0.1, pos))
end

function IosPayCartoonPanel:pause()
    self.isPaused = true
end

function IosPayCartoonPanel:resume()
    self.isPaused = false
end

function IosPayCartoonPanel:replay()
    self.curIndex = 1
    self:gotoPage(1)
    self.isPaused = false
    self.cdSeconds = NEXT_PAGE_TIME
    self:updateButton()
end

function IosPayCartoonPanel:gotoPage(index)
    if _G.isLocalDevelopMode then printx(0, 'gotoPage '..index) end
    for i=1, 5 do 
        if i == index then
            self['page'..i]:setVisible(true)
        else
            self['page'..i]:setVisible(false)
        end
    end
    self.selected:setPositionX(self['dot'..index]:getPositionX())
end

function IosPayCartoonPanel:nextPage()
    if self.curIndex < 5 then
        self.curIndex = self.curIndex + 1
        self:gotoPage(self.curIndex)
        self.cdSeconds = NEXT_PAGE_TIME
        self:updateButton()
    end
end

function IosPayCartoonPanel:prevPage()
    if self.curIndex > 1 then
        self.curIndex = self.curIndex - 1
        self:gotoPage(self.curIndex)
        self.cdSeconds = NEXT_PAGE_TIME
        self:updateButton()
    end
end

function IosPayCartoonPanel:dispose()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
    -- self:removeSkeleton()
    BasePanel.dispose(self)
end

IosPayFailGuidePanel = class(BasePanel)
function IosPayFailGuidePanel:create(cartoonCloseCallback)
    local instance = IosPayFailGuidePanel.new()
    instance:loadRequiredResource(PanelConfigFiles.ios_pay_cartoon_panel)
    instance:init(cartoonCloseCallback)
    return instance
end

function IosPayFailGuidePanel:init(cartoonCloseCallback)
    local ui = self:buildInterfaceGroup('ios_first_pay_fail_panel')
    local vo = Director:sharedDirector():getVisibleOrigin()
    local vs = Director:sharedDirector():getVisibleSize()
    BasePanel.init(self, ui)
    self.guideBtn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.icon1 = ui:getChildByName('icon1')
    self.icon2 = ui:getChildByName('icon2')
    self.num1 = ui:getChildByName('num1')
    self.num2 = ui:getChildByName('num2')
    self.text = ui:getChildByName('text')
    self.text:setString(localize('ios.tuiguang.desc2'))
    self.bubble = ui:getChildByName('bubble')
    local rewards = {{itemId = 10013, num = 1}, {itemId = 2, num = 1000}}
    local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
    for i = 1, 2 do
        local icon = iconBuilder:buildGroup("Prop_"..rewards[i].itemId)
        self['icon'..i]:setVisible(false)
        self['icon'..i]:getParent():addChildAt(icon, self['icon'..i]:getZOrder())
        icon:setPositionX(self['icon'..i]:getPositionX())
        icon:setPositionY(self['icon'..i]:getPositionY())
        icon:setScale(self['icon'..i]:getContentSize().width * self['icon'..i]:getScaleX() / icon:getGroupBounds().size.width)
        self['num'..i]:setString('x'..rewards[i].num)
        self['icon'..i] = icon
    end
    self.rewards = rewards
    self.closeBtn = ui:getChildByName('closeBtn')
    self.closeBtn:setButtonMode(true)
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, 
        function () 
            if self.cartoonCloseCallback then
                self.cartoonCloseCallback()
            end
            self:onCloseBtnTapped() 
        end)

    self.guideBtn:setString('点击查看')
    self.guideBtn:ad(DisplayEvents.kTouchTap, function () self:onGuideBtnTapped() end)
    self.cartoonCloseCallback = cartoonCloseCallback
end

function IosPayFailGuidePanel:popout()
    local function doPop()
        local vs = Director:sharedDirector():getVisibleSize()
        -- self:setPosition(ccp(0,vs.height / 2 + self.ui:getGroupBounds().size.height / 2))
        self:setPositionForPopoutManager()
        PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false)
        self.allowBackKeyTap = true
    end
    local function hasNetwork()
        if not UserManager:getInstance().userExtend:isIosGuideRewardReceived() then -- 只能领奖一次，检查flag
            self.showRewards = true
            self:showRewardItems(true)
        else
            self.showRewards = false
            self:showRewardItems(false)
        end        
        doPop()
    end
    local function noNetwork()
        self.showRewards = false
        self:showRewardItems(false)
        doPop()
    end
    PaymentNetworkCheck.getInstance():check(hasNetwork, noNetwork)
end

function IosPayFailGuidePanel:showRewardItems(enable)
    self.bubble:setVisible(enable)
    self.icon1:setVisible(enable)
    self.icon2:setVisible(enable)
    self.num1:setVisible(enable)
    self.num2:setVisible(enable)
end

function IosPayFailGuidePanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
end

function IosPayFailGuidePanel:onGuideBtnTapped()
    local cartoonCloseCallback = self.cartoonCloseCallback
    if self.showRewards then
        local function popoutPanel()
            if not self.isDisposed then 
                self:onCloseBtnTapped()
            end
            -- 漫画是必须看的

            if shouldShowIOSAliGuide() then
                IosAliCartoonPanel:create(cartoonCloseCallback):popout()
            else
                IosPayCartoonPanel:create(cartoonCloseCallback):popout()
            end
        end
        local function onSuccess()
            if self.isDisposed then return end
            UserManager:getInstance().userExtend:setIosGuideRewardReceived(true)
            addReward(self.rewards)
            self:playRewardAnim(self.rewards, popoutPanel)
        end
        local function onError(event)
            if self.isDisposed then return end
            local errorCode = tonumber(event.data) or 0
            if errorCode == 731084 then
                popoutPanel()
                CommonTip:showTip('该奖励已获得，无法再次获得~', 'negative', nil, 2) --奖励已经领过啦~
            else
                CommonTip:showTip('网络异常，请查看网络后再次尝试~', 'negative', nil, 2)
            end

        end
        local http = getRewardHttp.new(true)
        http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, onError)
        http:load()
    else
        self:onCloseBtnTapped()
        if shouldShowIOSAliGuide() then
            IosAliCartoonPanel:create(cartoonCloseCallback):popout()
        else
            IosPayCartoonPanel:create(cartoonCloseCallback):popout()
        end
    end
end

function IosPayFailGuidePanel:playRewardAnim(rewards, callback)
    local scene = Director:sharedDirector():getRunningScene()
    if not scene then return end
    local callbackCalled = false
    local function animCallback()
        if callbackCalled then return end
        callbackCalled = true
        if callback then callback() end
    end
    HomeScene:sharedInstance():checkDataChange()
    
    for i,v in ipairs(rewards) do
        local anim = FlyItemsAnimation:create({v})
        local bounds = self['icon'..i]:getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:setFinishCallback(animCallback)
        anim:play()
    end
end

