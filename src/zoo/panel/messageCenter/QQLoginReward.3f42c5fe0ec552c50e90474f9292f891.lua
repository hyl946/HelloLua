--这个文件现在是各种绑定账号后给奖励的面板集合
local function addReward(rewards, source)
    rewards = rewards or {}
    source = source or DcSourceType.kLoginRewardQQ
    if #rewards > 0 then
        UserManager:getInstance():addRewards(rewards, true)
        UserService:getInstance():addRewards(rewards)
        GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kAccountLogin, rewards, source)
        if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
            else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
    end
end

local Panel = class(BasePanel)
function Panel:create(rewards, loginType)
    local instance = Panel.new()
    instance:loadRequiredResource(PanelConfigFiles.request_message_panel)
    instance:init(rewards, loginType)
    return instance
end
local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
local function buildItemIcon(itemId)
    if ItemType:isTimeProp(itemId) then itemId = ItemType:getRealIdByTimePropId(itemId) end
    local propName = 'Prop_'..itemId
    if itemId == ItemType.GOLD then
        propName = 'homeSceneGoldItem'
    elseif itemId == ItemType.COIN then
        propName = 'stackIcon'
    end
    return iconBuilder:buildGroup(propName)
end
function Panel:init(rewards, loginType)
    local ui = self.builder:buildGroup('qq_login_reward_panel')
    BasePanel.init(self, ui)
    self.btn = GroupButtonBase:create(ui:getChildByName('confirm'))
    self.btn:setString('领取')
    self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)

    local bg = self.ui:getChildByName("bg")
    local title = ui:getChildByName('title')
    title._setText = title.setText
    title._bgWidth= bg:getGroupBounds().size.width
    function title:setText( text )
        self:_setText(text)
        self:setPositionX(self._bgWidth/2 - self:getContentSize().width/2)
    end 
    title:setText(localize('get.login.bonus.title'))
    if loginType == nil then
        ui:getChildByName('label'):setString(localize('get.login.bonus.content'))
    else
        ui:getChildByName('label'):setString(localize('get.login.bonus.content' .. loginType))
    end

    self.rewards = rewards
    if rewards and #rewards > 0 then
        local reward = self.rewards[1]
        local icon = buildItemIcon(reward.itemId)
        local res = self.ui:getChildByName('item1')
        local ph = res:getChildByName('item')
        local num = res:getChildByName('num')
        local rect = res:getChildByName('rect')
        local rcSize = rect:getGroupBounds().size
        local rcPositionX = rect:getPositionX()
        local position = num:getPosition()
        rect:setVisible(false)
        ph:setVisible(false)
        icon:setPositionX(ph:getPositionX())
        icon:setPositionY(ph:getPositionY())
        icon:setScale(ph:getContentSize().width*ph:getScaleX() / icon:getGroupBounds().size.width)
        res:addChildAt(icon, ph:getZOrder())
        num:setText('x'..reward.num)
        local size = num:getContentSize()
        num:setPosition(ccp(rcPositionX + rcSize.width - size.width, position.y))
        self.icon = icon
    else
        self.ui:getChildByName('item1'):setVisible(false)
        ui:getChildByName('label'):setString('您已经领取过奖励了~')
        self.btn:setString('确定')
    end
end

function Panel:onBtnTapped()
    self.btn:setEnabled(false)
    if self.rewards and #self.rewards > 0 then
        local function cb()
            self:removeSelf()
        end

        local bounds = self.icon:getGroupBounds()

        HomeScene:sharedInstance():checkDataChange()
        
        local anim = FlyItemsAnimation:create({self.rewards[1]})
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:setScaleX(self.icon:getScaleX())
        anim:setScaleY(self.icon:getScaleY())
        anim:setFinishCallback(cb)
        anim:play()

    else
        self:removeSelf()
    end
end

function Panel:popout()
    self:setPositionForPopoutManager()
    PopoutQueue:sharedInstance():push(self)
    self.allowBackKeyTap = true
end

function Panel:removeSelf()
    PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
    self.allowBackKeyTap = false
end

local NewGetRewardHttp = class(HttpBase)
function NewGetRewardHttp:load(rewardId)
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("NewGetRewardHttp error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("NewGetRewardHttp success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call(kHttpEndPoints.getRewards, {rewardId = rewardId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

QQLoginReward = class()

function QQLoginReward:shouldGetReward()
    return CCUserDefault:sharedUserDefault():getBoolForKey('message.center.qq.login.reward', false) == true
end

function QQLoginReward:setShouldGetReward(value)
    CCUserDefault:sharedUserDefault():setBoolForKey('message.center.qq.login.reward', value)
end

function QQLoginReward:receiveReward()
    local function onSuccess(evt)
        if _G.isLocalDevelopMode then printx(0, 'QQLoginReward:receiveReward onSuccess') end
        if evt.data.rewardItems then
            addReward(evt.data.rewardItems, DcSourceType.kLoginRewardQQ)
            Panel:create(evt.data.rewardItems, PlatformAuthEnum.kQQ):popout()    
            local dcId = CCUserDefault:sharedUserDefault():getIntegerForKey('message.center.login.success.source')
            DcUtil:UserTrack({category = 'message', sub_category = 'message_center_get_qq_reward', where = dcId}, true)
            local t2 = CCUserDefault:sharedUserDefault():getIntegerForKey('login.success.source.'..tostring(PlatformAuthEnum.kQQ))
            DcUtil:UserTrack({category = 'login', sub_category = 'login_success_reward', t1 = 1, t2 = t2}, true)
        end    
        QQLoginReward:setShouldGetReward(false)
    end
    local function onFail()
        if _G.isLocalDevelopMode then printx(0, 'QQLoginReward:receiveReward onFail') end
    end

    local http = NewGetRewardHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load(5)
end

function QQLoginReward:loginRewardEnabled()
    if __WIN32 then return true end
    return MaintenanceManager:getInstance():isEnabled('GetLoginBonus')
end

------------------------------------------------------------------------------------------------------------------------------------
--返回值  开关关闭时返回nil
----------开关打开时返回   奖励绑定类型[phone, qq]默认phone      领奖请求ID     奖励物品ID    奖励物品数量
------------------------------------------------------------------------------------------------------------------------------------
local function getBindPhoneOrQQCfg()
    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("BindPhoneOrQQBonus")
    local cfgStr = nil
    if maintenance ~= nil then
         if maintenance.enable then
            cfgStr = maintenance.extra
         else
            return nil
         end
    end
    cfgStr = cfgStr or ""

    local cfgAry = string.split(cfgStr, "|")
    if #cfgAry < 3 then
        return nil
    end

    local rewardAry = string.split(cfgAry[3], ":")
    return cfgAry[1], tonumber(cfgAry[2]), tonumber(rewardAry[1]), tonumber(rewardAry[2])
end


-- 游戏内有两种鼓励账号绑定，
-- 第一种是global配置，最初是面板形式，后来可能是收进新版活动中心了。
-- 第二种是maintenance配置，ui表现是 在账号登录按钮, 账户设置条目 上有个泡泡
-- BindQQBonus BindPhoneBonus BindQihooBonus 是第二种, Qihoo 就是 360，但用数字的话，语法高亮有问题
-- BindPhoneOr360Reward 是给第一种用的
-- QQLoginReward 初次用qq登录领奖
-- 以上纯属臆测


BindQQBonus = class()

function BindQQBonus:shouldGetReward()
    return CCUserDefault:sharedUserDefault():getBoolForKey('bind.qq.from.preloader.or.accountset.reward', false) == true
end

function BindQQBonus:setShouldGetReward(value)
    CCUserDefault:sharedUserDefault():setBoolForKey('bind.qq.from.preloader.or.accountset.reward', value)
end

function BindQQBonus:receiveReward(ignorePushBindingCheck, rewardId)
    local function onSuccess(evt)
        if _G.isLocalDevelopMode then printx(0, 'BindQQBonus:receiveReward onSuccess') end
        if evt.data.rewardItems then
            addReward(evt.data.rewardItems, DcSourceType.kLoginRewardQQ)
            Panel:create(evt.data.rewardItems, PlatformAuthEnum.kQQ):popout()    
            local dcId = CCUserDefault:sharedUserDefault():getIntegerForKey('message.center.login.success.source')
            DcUtil:UserTrack({category = 'message', sub_category = 'message_center_get_qq_reward', where = dcId}, true)
            local t2 = CCUserDefault:sharedUserDefault():getIntegerForKey('login.success.source.'..tostring(PlatformAuthEnum.kQQ))
            DcUtil:UserTrack({category = 'login', sub_category = 'login_success_reward', t1 = 1, t2 = t2}, true)
        end    
        BindQQBonus:setShouldGetReward(false)
    end
    local function onFail()
        if _G.isLocalDevelopMode then printx(0, 'BindQQBonus:receiveReward onFail') end
    end
        local http = NewGetRewardHttp.new()
        http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, onFail)
        if rewardId then
            http:load(rewardId)
            return
        end

        if ignorePushBindingCheck then
            local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
            http:load(rewardID)
        elseif PushBindingLogic:getAwardTimeLeft() > 0 then
            http:load(MetaManager:getInstance():getPushBindQQRewardID())
        else
            local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
            http:load(rewardID)
        end
end

function BindQQBonus:loginRewardEnabled(isGuestTryLogin)
    local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
    if rcmdBindType == "qq" and type(rewardID) == "number" and rewardID > 0 and 
       not PlatformConfig:isPlatform(PlatformNameEnum.k360) and
       PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ) then
        if HomeScene:hasInited() then --只是游客情况下才有这个奖励
            local homeScene = HomeScene:sharedInstance()
            if homeScene ~= nil and homeScene.isInited then
                if _G.sns_token then
                    return false
                end
            end
        end

        if isGuestTryLogin ~= nil then
            return isGuestTryLogin
        end

        return true
    end
    return false
end

function BindQQBonus:getBindRewards()
    local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
    if rcmdBindType == "qq" then
        return itemID, itemNum, rewardID
    end

    return 10013, 1, 5
end

BindPhoneBonus = class()

function BindPhoneBonus:shouldGetReward()
    return CCUserDefault:sharedUserDefault():getBoolForKey('bind.phone.from.preloader.or.accountset.reward', false) == true
end

function BindPhoneBonus:setShouldGetReward(value)
    CCUserDefault:sharedUserDefault():setBoolForKey('bind.phone.from.preloader.or.accountset.reward', value)
end

function BindPhoneBonus:receiveReward(ignorePushBindingCheck, rewardId)
    local function onSuccess(evt)
        if evt.data.rewardItems then
            addReward(evt.data.rewardItems, DcSourceType.kLoginRewardPhone)
            Panel:create(evt.data.rewardItems, PlatformAuthEnum.kPhone):popout()    
        end    
        BindPhoneBonus:setShouldGetReward(false)
    end
    local function onFail()
    end
    -- if __WIN32 then
    --     onSuccess({data = {rewardItems = {{itemId = 10012, num =1}}}})
    -- else
        local http = NewGetRewardHttp.new()
        http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, onFail)
        if rewardId then
            http:load(rewardId)
            return
        end

        if ignorePushBindingCheck then
            local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
            http:load(rewardID)
        elseif PushBindingLogic:getAwardTimeLeft() > 0 then
            http:load(MetaManager:getInstance():getPushBindPhoneRewardID())
        else
            local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
            http:load(rewardID)
        end
    -- end
end

function BindPhoneBonus:loginRewardEnabled(isGuestTryLogin)
    -- if __WIN32 then return true end

    if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
        return false
    end

    ----SVIP 绑定手机活动 不弹旧手机绑定
    local bIsHaveIcon = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()
    if bIsHaveIcon then
        return false
    end
    
    local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
    if rcmdBindType == "phone" and type(rewardID) == "number" and rewardID > 0 and 
       PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone) then
        if HomeScene:hasInited() then --只是游客情况下才有这个奖励
            local homeScene = HomeScene:sharedInstance()
            if homeScene ~= nil and homeScene.isInited then
                if _G.sns_token then
                    return false
                end
            end
        end

        if isGuestTryLogin ~= nil then
            return isGuestTryLogin
        end

        return true
    end

    return false
end

function BindPhoneBonus:getBindRewards()
    local rcmdBindType, rewardID, itemID, itemNum = getBindPhoneOrQQCfg()
    if rcmdBindType == "phone" then
        return itemID, itemNum, rewardID
    end

    return 14, 10, 7
end



BindQihooBonus = class()

function BindQihooBonus:getBindCfg()
    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("Bind360Bonus") 
    local cfgStr = nil
    if maintenance ~= nil then
         if maintenance.enable then
            cfgStr = maintenance.extra
         else
            return nil
         end
    end
    cfgStr = cfgStr or "9|14:5" --默认配置 
    local cfgAry = string.split(cfgStr, "|")
    if #cfgAry < 2 then
        return nil
    end

    local rewardAry = string.split(cfgAry[2], ":")
    return tonumber(cfgAry[1]), tonumber(rewardAry[1]), tonumber(rewardAry[2])
end


function BindQihooBonus:shouldGetReward()
    return CCUserDefault:sharedUserDefault():getBoolForKey('bind.qihoo.from.preloader.or.accountset.reward', false) == true
end

function BindQihooBonus:setShouldGetReward(value)
    CCUserDefault:sharedUserDefault():setBoolForKey('bind.qihoo.from.preloader.or.accountset.reward', value)
end

function BindQihooBonus:receiveReward(ignorePushBindingCheck, rewardId)
    local function onSuccess(evt)
        if evt.data.rewardItems then
            addReward(evt.data.rewardItems, DcSourceType.kLoginReward360)
            Panel:create(evt.data.rewardItems, PlatformAuthEnum.k360):popout()    
        end    
        BindQihooBonus:setShouldGetReward(false)
    end
    local function onFail()
    end
    local http = NewGetRewardHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    if rewardId then
        http:load(rewardId)
        return
    end

    if ignorePushBindingCheck then
        local rewardID, itemID, itemNum = self:getBindCfg()
        http:load(rewardID)
    elseif PushBindingLogic:getAwardTimeLeft() > 0 then
        http:load(MetaManager:getInstance():getPushBind360RewardID())
    else
        local rewardID, itemID, itemNum = self:getBindCfg()
        http:load(rewardID)
    end
end

function BindQihooBonus:loginRewardEnabled(isGuestTryLogin)
    if not PlatformConfig:isPlatform(PlatformNameEnum.k360) then
        return false
    end
    
    if HomeScene:hasInited() then --只是游客情况下才有这个奖励
        local homeScene = HomeScene:sharedInstance()
        if homeScene ~= nil and homeScene.isInited then
            if _G.sns_token then
                return false
            end
        end
    end

    local rewardID, itemID, itemNum = self:getBindCfg()
    if rewardID == nil then
        return false
    end

    if isGuestTryLogin ~= nil then
        return isGuestTryLogin
    end

    return true
end

function BindQihooBonus:getBindRewards()
    local rewardID, itemID, itemNum = self:getBindCfg()
    return itemID, itemNum, rewardID
end




BindPhoneOr360Reward = class()

function BindPhoneOr360Reward:receiveReward(bindType, awardID)
    local function onSuccess(evt)
        if evt.data.rewardItems then
            local source = nil
            if bindType == PlatformAuthEnum.kPhone then
                source = DcSourceType.kLoginRewardPhone
            elseif bindType == PlatformAuthEnum.k360 then
                source = DcSourceType.kLoginReward360
            end
            addReward(evt.data.rewardItems, source)
            Panel:create(evt.data.rewardItems, bindType):popout()    
            local dcId = CCUserDefault:sharedUserDefault():getIntegerForKey('message.center.login.success.source')
            DcUtil:UserTrack({category = 'message', sub_category = 'message_center_get_qq_reward', where = dcId}, true)
            local t2 = CCUserDefault:sharedUserDefault():getIntegerForKey('login.success.source.'..tostring(PlatformAuthEnum.kQQ))
            DcUtil:UserTrack({category = 'login', sub_category = 'login_success_reward', t1 = 1, t2 = t2}, true)
        end
        if bindType == PlatformAuthEnum.kPhone then
            BindPhoneBonus:setShouldGetReward(false)
        end
    end
    local function onFail()
    end
    -- if __WIN32 then
    --     onSuccess({data = {rewardItems = {{itemId = 10012, num =1}}}})
    -- else
        local http = NewGetRewardHttp.new()
        http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, onFail)
        http:load(awardID)
    -- end
end