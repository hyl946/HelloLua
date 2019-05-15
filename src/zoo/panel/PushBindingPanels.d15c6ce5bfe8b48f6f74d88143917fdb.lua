local Base = class(BasePanel)

local function hasBindedQQ()
    return UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kQQ) ~= nil
end


function Base:create(data)
    local instance = self.new()
    instance:loadRequiredResource('ui/push_binding_base_panel.json')
    instance.data = data
    instance:init()
    return instance
end

function Base:init()
    self.popoutDay = Localhost:getTodayStart()
    local ui = self.builder:buildGroup('pushBinding/push_binding_base_panel')
    BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('close')
    self.closeBtn:setTouchEnabled(true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function ()
            self:onCloseBtnTapped()
    end)

    self.bg_a = self.ui:getChildByName("bg_a")
    self.bg_b = self.ui:getChildByName("bg_b")
    self.bg_c = self.ui:getChildByName("bg_c")
    self.bg_d = self.ui:getChildByName("bg_d")
    self.bg_a:setVisible(false)
    self.bg_b:setVisible(false)
    self.bg_c:setVisible(false)
    self.bg_d:setVisible(false)

    self.title = self.ui:getChildByName("title")
    self.title:setPreferredSize(282, 62)
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPositionXY(317, -62)

    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
    self.btn:setColorMode(kGroupButtonColorMode.blue)
    self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)

    self.firstBindReward = self.ui:getChildByName("firstBindReward")
    self.countDownTimeTf = self.ui:getChildByName("text1")

    self.awardID = -1
    if PushBindingLogic:getAwardTimeLeft() > 0 and PushBindingLogic.pushData.icon ~= nil then
        local rewardStr = nil
        if MetaManager:getInstance():isPushRewardEnable(self.loginType) then
            rewardStr = MetaManager:getInstance():getPushBindReward(self.loginType)
            self.awardID = MetaManager:getInstance():getPushBindRewardId(self.loginType)
        end
        if self.awardID < 0 then
            self.hasBindAward = false 
            self.firstBindReward:setVisible(false)
            self.countDownTimeTf:setVisible(false)
            return
        end

        local rewards = string.split(rewardStr, ":")
        self.hasBindAward = true
        local rewardId = tonumber(rewards[1])
        local itemIcon = ResourceManager:sharedInstance():buildItemGroup(rewardId)
        local itemIconWidth = itemIcon:getGroupBounds().size.width
        itemIcon:setScale(72 / itemIconWidth)
        itemIcon:setPosition(ccp(41, 89))
        self.firstBindReward:addChild(itemIcon)

        local numLabel = BitmapText:create("x" .. rewards[2], "fnt/event_default_digits.fnt")
        numLabel:setPreferredSize(159, 80)
        numLabel:setAnchorPoint(ccp(0.5,0.5))
        numLabel:setPositionXY(110, 38)

        local timeStr = convertSecondToHHMMSSFormat(PushBindingLogic:getAwardTimeLeft())
        self:updaetTimeTf(timeStr)

        self.firstBindReward:addChild(numLabel)
    else
        self.hasBindAward = false 
        self.firstBindReward:setVisible(false)
        self.countDownTimeTf:setVisible(false)
    end

    local contentX, contentY, scale = LogicUtil.getFullScreenUIPosXYScale()
    self:setScale(scale)
    self:setPositionXY(contentX, 0)
end

function Base:show(tag)
    self.showType = tag
    self["bg_" .. tag]:setVisible(true)
end

function Base:updaetTimeTf(timeStr)
    if self.countDownTimeTf ~= nil and not self.ui.isDisposed then
        self.countDownTimeTf:setString(localize("push.binding.panel.countdown.time", {time=timeStr}))
    end
end

function Base:popout(closeCallback)
    self.closeCallback = closeCallback
    if self.popoutDisable then
        self:afterClose()
        return
    end

    if closeCallback ~= nil then--只打强弹情况下的点
        local authName = PlatformConfig:getPlatformAuthName(self.loginType)
        local dcData = {}
        dcData.category = "login"
        dcData.sub_category = "login_push_binding"..authName.."_success_new"
        if self.showType == "a" then
            dcData.t1 = 1
        elseif self.showType == "b" then
            dcData.t1 = 2
        elseif self.showType == "c" then
            dcData.t1 = 1
        elseif self.showType == "d" then
            dcData.t1 = 2
        end
        if self.hasBindAward then 
            dcData.t2 = 1
        else 
            dcData.t2 = 2 
        end
        DcUtil:UserTrack(dcData)
    end
    PopoutQueue:sharedInstance():push(self, true, false)
end

function Base:popoutShowTransition()
    self.allowBackKeyTap = true
    self:setPositionForPopoutManager()
end

function Base:onCloseBtnTapped()
    if self.ui.isDisposed ~= true and not self.closeFlag then
        self.closeFlag = true
        PopoutManager:sharedInstance():remove(self)
        self.allowBackKeyTap = false
        self:afterClose()
    end
end

function Base:afterClose()
    if self.closeCallback then
        self.closeCallback(true)
    end

    if self.popoutDay ~= Localhost:getTodayStart() then
       PushBindingLogic:setTodayPopFlag()
    end
    if PushBindingLogic.pushData ~= nil then
        PushBindingLogic.pushData.pushBindPanel = nil
    end
end

function Base:tryGetBindAward()
    if self.hasBindAward and self.awardID > 0 then
        BindPhoneOr360Reward:receiveReward(self.loginType, self.awardID)
--        PushBindingLogic:removeBindAccountIcon()
    end
    PushBindingLogic:removeBindAccountIcon()

    local authName = PlatformConfig:getPlatformAuthName(self.loginType)
    local dcData = {}
    dcData.category = "login"
    dcData.sub_category = "login_"..authName.."_success_source"
    if self.showType == "a" then
        dcData.t1 = 1
    elseif self.showType == "b" then
        dcData.t1 = 2
    elseif self.showType == "c" then
        dcData.t1 = 10
    elseif self.showType == "d" then
        dcData.t1 = 11
    end
    if self.hasBindAward then 
        dcData.t2 = 1
    else 
        dcData.t2 = 2 
    end
    DcUtil:UserTrack(dcData)
end

function Base:cancelPushBindAward()
    if self.hasBindAward then
        self.hasBindAward = false
        if not self.ui.isDisposed then
            self.firstBindReward:setVisible(false)
            self.countDownTimeTf:setVisible(false)
        end
    end
end

local T360Panel = class(Base)
T360Panel.loginType = PlatformAuthEnum.k360

function T360Panel:init()
    Base.init(self)
    self.title:setString('360登录')
    self.btn:setString('360登录')
--    local showType = MetaManager:getInstance():getPushBind360ABCfg()
--    if #showType > 1 then
--        local typeAry = string.split(showType, ",")
--        local tagIdx = PushBindingLogic:getCycleAllForcePopNum() % 2 + 1
--        showType = typeAry[tagIdx]
--    end
    local showType = 'd'
    self:show(showType)
    DcUtil:UserTrack({category = 'login', sub_category = 'login_push_binding_360'})
end

function T360Panel:onBtnTapped()
    local function onSuccess()
        DcUtil:UserTrack({category = 'login', sub_category = 'login_360_success_source'}) -- 6是偏移量
        CommonTip:showTip(localize('push.binding.360.success'), 'positive')-- text@wenkan
        self:onCloseBtnTapped()
        self:tryGetBindAward()
    end
    local function onFail()
    end
    local function onCancel()
    end
    if __WIN32 then
        setTimeOut(onSuccess, 3)
        return
    end
    AccountBindingLogic:bindNewSns(PlatformAuthEnum.k360, onSuccess, onFail, onCancel, AccountBindingSource.PUSH_BIND_PANEL)
end

local QQPanel = class(Base)
QQPanel.loginType = PlatformAuthEnum.kQQ

function QQPanel:init()
    Base.init(self)
    self.title:setString('QQ登录')
    self.btn:setString('QQ登录')
    local showType = MetaManager:getInstance():getPushBindQQCDCfg()
    if #showType > 1 then
        local dayShift = PushBindingLogic:getQQShowShift()
        local typeAry = string.split(showType, ",")
        local numOfPopDay
        -- if _G.isLocalDevelopMode then printx(0, "qq dayShift----------------------------------", dayShift) end
        if MetaManager:getInstance():isPushNone() then
        -- if _G.isLocalDevelopMode then printx(0, "qq dayShift----------------------------------a") end
            numOfPopDay = math.ceil((PushBindingLogic:getCycleAllForcePopNum() + 0.5)/2) + dayShift
        else
        -- if _G.isLocalDevelopMode then printx(0, "qq dayShift----------------------------------b") end
            numOfPopDay = PushBindingLogic:getCycleAllForcePopNum() + dayShift
        end
        local tagIdx = numOfPopDay % 2 + 1
        -- if _G.isLocalDevelopMode then printx(0, "the pop day:", numOfPopDay, tagIdx) end
        showType = typeAry[tagIdx]
    end
    self:show(showType)
end

function QQPanel:onBtnTapped()
    local function onSuccess()
        CommonTip:showTip(localize('push.binding.qq.success'), 'positive')-- text@wenkan
        self:onCloseBtnTapped()
        self:tryGetBindAward()
    end
    local function onFail()
    end
    local function onCancel()
    end
    if __WIN32 then
        setTimeOut(onSuccess, 3)
        return
    end
    AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, onSuccess, onFail, onCancel, AccountBindingSource.PUSH_BIND_PANEL)
end

local PhonePanel = class(Base)
PhonePanel.loginType = PlatformAuthEnum.kPhone

function PhonePanel:init()
    Base.init(self)
    self.title:setString('手机登录')
    self.btn:setString('手机登录')
    local showType
    -- if hasBindedQQ() then
    --     showType = "b"
    -- else
--        showType = MetaManager:getInstance():getPushBindPhoneABCfg()
--        if #showType > 1 then
--            local dayShift = PushBindingLogic:getPhoneShowShift()
--            local typeAry = string.split(showType, ",")
--            -- if _G.isLocalDevelopMode then printx(0, "phone dayShift----------------------------------", dayShift) end
--            local numOfPopDay
--            if MetaManager:getInstance():isPushNone() then
--            -- if _G.isLocalDevelopMode then printx(0, "phone dayShift----------------------------------a") end
--                numOfPopDay = math.ceil((PushBindingLogic:getCycleAllForcePopNum() + 0.5)/2) + dayShift
--            else
--                -- if _G.isLocalDevelopMode then printx(0, "phone dayShift----------------------------------b") end
--                numOfPopDay = PushBindingLogic:getCycleAllForcePopNum() + dayShift
--            end
--            local tagIdx = numOfPopDay % 2 + 1
--            -- if _G.isLocalDevelopMode then printx(0, "the pop day:", numOfPopDay, tagIdx) end
--            showType = typeAry[tagIdx]
--        end
    -- end

    local showType = 'd'
    self:show(showType)
end

function PhonePanel:onBtnTapped()
    local function onReturnCallback()
    end
    local function onBindSuccessCallback()
        CommonTip:showTip(localize('push.binding.phone.success'), 'positive') -- text@wenkan
        self:onCloseBtnTapped()
        self:tryGetBindAward()
    end
    AccountBindingLogic:bindNewPhone(onReturnCallback, onBindSuccessCallback, AccountBindingSource.PUSH_BIND_PANEL)
end

local WechatPanel = class(Base)
WechatPanel.loginType = PlatformAuthEnum.kWechat

function WechatPanel:init()
    Base.init(self)
    self.title:setString('微信登录')
    self.btn:setString('微信登录')
--    local showType = MetaManager:getInstance():getPushBindABTest(PlatformAuthEnum.kWechat, "a,b")
--    if #showType > 1 then
--        local dayShift = PushBindingLogic:getPushShowShift(PlatformAuthEnum.kWechat)
--        local typeAry = string.split(showType, ",")
--        local numOfPopDay

--        RemoteDebug:uploadLogWithTag(0, "123")

--        if MetaManager:getInstance():isPushNone() then
--            numOfPopDay = math.ceil((PushBindingLogic:getCycleAllForcePopNum() + 0.5)/2) + dayShift
--        else
--            numOfPopDay = PushBindingLogic:getCycleAllForcePopNum() + dayShift
--        end
--        local tagIdx = numOfPopDay % 2 + 1
--        showType = typeAry[tagIdx]
--    end
    local showType = 'd'
    self:show(showType)
end

function WechatPanel:onBtnTapped()
    local function onSuccess()
        CommonTip:showTip(localize('push.binding.wechat.success'), 'positive')-- text@wenkan
        self:onCloseBtnTapped()
        self:tryGetBindAward()
    end
    local function onFail()
    end
    local function onCancel()
    end
    if __WIN32 then
        setTimeOut(onSuccess, 3)
        return
    end
    AccountBindingLogic:bindNewSns(PlatformAuthEnum.kWechat, onSuccess, onFail, onCancel, AccountBindingSource.PUSH_BIND_PANEL)
end

return {QQPanel = QQPanel, PhonePanel = PhonePanel, T360Panel = T360Panel, WechatPanel = WechatPanel}