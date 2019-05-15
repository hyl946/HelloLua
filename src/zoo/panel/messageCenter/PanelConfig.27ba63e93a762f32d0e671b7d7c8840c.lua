RequestMessagePageBackgroundType = {
    kNone = 0,
    kClover_AddFriend = 1,
}

local function debug_log(arg)
    if _G.isLocalDevelopMode then printx(0, arg) end
    if not _G.isLocalDevelopMode then return end
    local filename = HeResPathUtils:getUserDataPath() .. '/debug_log'
    local file = io.open(filename,"a+")
    if file then 
        file:write(arg)
        file:write('\n')
        file:close()
    end
end

local function supportQQLogin()
    if PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ) then
        return true
    end
    return false
end

local function isQQLogin()
    local qqAccount = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kQQ)
    if qqAccount then
        return true
    end
    return false
end

local fmgr = FriendManager:getInstance()

local pages = 
{
    news = 1,
    friends = 2,
    energy = 3,
    unlock = 4,
    activity = 5,
    update = 6,
    clover = 7,
	pushActivity = 8,
    askForHelp = 9, -- 求好友闯关
}

local panelConfig = {}

panelConfig[pages.news] = 
{ 
    msgType = {
        RequestType.kPassMaxNormalLevel,
        RequestType.kThanks,
        RequestType.kLevelSurpass, 
        RequestType.kLevelSurpassLimited, 
        RequestType.kWeeklyRace,
        RequestType.kScoreSurpass,
        RequestType.kPassLastLevelOfLevelArea,
        RequestType.kLevelSurpassNation,
        RequestType.kScoreSurpassNation,
        RequestType.kWeeklySurpassNation,
        RequestType.kAskForHelpSuccess,
        RequestType.kActRecallRemind,
        RequestType.kFCGift,
        RequestType.kThanksForYourFullGift,
        RequestType.KFLGInbox,
        RequestType.kMergedThanksForYourFullGift,
        RequestType.kNewVersionRewardItem,
    },
    rejectAllType = {
        RequestType.kPassMaxNormalLevel,
        RequestType.kThanks,
        RequestType.kLevelSurpass, 
        RequestType.kLevelSurpassLimited, 
        RequestType.kWeeklyRace,
        RequestType.kScoreSurpass,
        RequestType.kPassLastLevelOfLevelArea,
        RequestType.kLevelSurpassNation,
        RequestType.kScoreSurpassNation,
        RequestType.kWeeklySurpassNation,
        RequestType.kAskForHelpSuccess,
        RequestType.kActRecallRemind,
        RequestType.kFCGift,
        RequestType.kThanksForYourFullGift,
        RequestType.KFLGInbox,
        RequestType.kMergedThanksForYourFullGift,
        RequestType.kNewVersionRewardItem,
    },
    pageName = 'news',
    pageIndex = 1, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("request.message.panel.tab.news"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return false end, 
        rejectAll = function() return true end,
        class = function(msg) if _G.isLocalDevelopMode then printx(0, msg.type) end return MessageOriginTypeClass[msg.type] end, 
        zero = function() return RequestMessageZeroNews end
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        -- if __WIN32 then return false end
        return true 
    end,
}

panelConfig[pages.friends] = 
{ 
    msgType = {RequestType.kAddFriend, RequestType.kFriendWithEnergy},
    -- acceptAllType = {RequestType.kFriendWithEnergy},
    rejectAllType = {RequestType.kAddFriend, RequestType.kFriendWithEnergy},
    pageName = 'addFriend',
    pageIndex = 2, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("request.message.panel.tab.friend"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return false end, 
        rejectAll = function() return true end,
        class = 
        function(msg)
            if msg.type == RequestType.kFriendWithEnergy then
                return FriendWithEnergyItem
            else 
                return FriendRequestItem 
            end
        end, 
        zero = 
        function()
			return RequestMessageZero_AddFriend
        end
    },
    showWhenNotEmpty = function () 
        -- 非游客  平台好友数达上限  不显示这一页，因为不能再加
        -- if _G.sns_token and FriendManager:getInstance():getAppFriendsCount() >= FriendManager:getInstance():getMaxFriendCount()
        -- then
        --     debug_log('zero friends 3')
        --     return false
        -- else 
        --     debug_log('zero friends 4')
        --     return true
        -- end
        return true
    end,
    hideWhenEmpty = function () 
        if FriendManager:getInstance():isFriendCountReachedMax() then
            debug_log('zero friends 5')
            return true
        end
        debug_log('zero friends 6')
        return false 
    end,
    alwaysHide = function ()
        if WXJPPackageUtil.getInstance():isWXJPPackage() then
            return true
        else
            return false
        end
    end,
}

panelConfig[pages.energy] =
{ 
    msgType = {RequestType.kSendFreeGift, RequestType.kReceiveFreeGift, RequestType.kPushEnergy, RequestType.kDengchaoEnergy},
    rejectAllType = {RequestType.kSendFreeGift, RequestType.kReceiveFreeGift},
    pageName = 'energy',    
    pageIndex = 3,
    tabConfig = 
    { 
        key = Localization:getInstance():getText("request.message.panel.tab.receive"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return true end, 
        rejectAll = function() return true end,
        class = 
        function(msg)
            if msg.type == RequestType.kPushEnergy then
                debug_log('zero energy 1')
                return PushEnergyItem
            else 
                debug_log('zero energy 2')
                return EnergyRequestItem 
            end
        end, 
        zero = 
        function()  
            return RequestMessageZeroWithAskFriend

            -- -- 玩家当前平台好友数已达上限
            -- if FriendManager:getInstance():getAppFriendsCount() >= FriendManager:getInstance():getMaxFriendCount() or __WIN32
            -- then
            --     -- 当天仍可接收精力，则显示主动请好友赠送按钮
            --     if FreegiftManager:sharedInstance():canReceiveMore() or __WIN32
            --     then
            --         debug_log('zero energy 3')
            --         return RequestMessageZeroWithAskFriend
            --     else -- 当前处理完全部消息，当天接收精力已达上限，显示文案为request.message.panel.zero.energy.text2
            --         debug_log('zero energy 4')
            --         return RequestMessageZeroEnergy
            --     end
            -- else -- 玩家当前平台好友数未达上限
            --     -- 当前未绑定QQ，则显示如图6：显示按钮"QQ登录"及对应文案，提醒玩家绑定QQ
            --     if supportQQLogin() and not isQQLogin() then 
            --         debug_log('zero energy 5')
            --         return RequestMessageZeroEnergyWithQQLogin
            --     elseif supportQQLogin() and isQQLogin() then
            --         -- 成功登录QQ后，打开此tab，如仍无消息
            --         -- 如玩家当天还可继续接受免费精力，则显示如图7，玩家可索要精力或发送二维码加好友
            --         if FreegiftManager:sharedInstance():canReceiveMore() then
            --             debug_log('zero energy 6')
            --             return RequestMessageZeroEnergyTwoButtons -- 索要精力+发送二维码
            --         else -- 如玩家当天不可继续接受免费精力，则提示文案：request.message.panel.zero.energy.text2
            --             debug_log('zero energy 7')
            --             return RequestMessageZeroEnergy -- 一句文案
            --         end
            --     elseif not supportQQLogin() then -- 当前渠道不支持QQ登录，则图6按钮改为"发名片加好友"及对应文案，提醒玩家发送名片给好友。
            --         -- 玩家点击发送过一次二维码，回到游戏后，如此tab仍无消息
            --         if CCUserDefault:sharedUserDefault():getBoolForKey('message.center.qrcode.sent', false) then
            --             -- 如玩家当天还可继续接受免费精力，则显示如图7，玩家可索要精力或发送二维码加好友
            --             if FreegiftManager:sharedInstance():canReceiveMore() then
            --                 debug_log('zero energy 8')
            --                 return RequestMessageZeroEnergyTwoButtons
            --             else -- 如玩家当天不可继续接受免费精力，则提示文案：request.message.panel.zero.energy.text2
            --                 debug_log('zero energy 9')
            --                 return RequestMessageZeroEnergy
            --             end
            --         else
            --             debug_log('zero energy 10')
            --             return RequestMessageZeroEnergyWithQRCode
            --         end
            --     end
            -- end

        end
    },
    showWhenNotEmpty = function () 
    -- 好友达到上限，不能接受精力，不显示
        -- if FriendManager:getInstance():getAppFriendsCount() >= FriendManager:getInstance():getMaxFriendCount() 
        -- and not FreegiftManager:sharedInstance():canReceiveMore() 
        -- then
        --     debug_log('zero energy 11')
        --     return false
        -- end
        debug_log('zero energy 12')
        return true 
    end,
    hideWhenEmpty = function () 
        -- if FriendManager:getInstance():getFriendCount() >= FriendManager:getInstance():getMaxFriendCount() 
        -- and not FreegiftManager:sharedInstance():canReceiveMore() 
        -- then
        --     debug_log('zero energy 13')
        --     return true
        -- end

        if FriendManager:getInstance():isFriendCountReachedMax() and not FreegiftManager:sharedInstance():canSendMore() then
            return true
        else
            return false
        end
    end,
    alwaysHide = function ()
        if WXJPPackageUtil.getInstance():isGuestLogin() then
            return true
        else
            return false
        end
    end,
}

panelConfig[pages.unlock] = 
{
    msgType = {RequestType.kUnlockLevelArea},
    acceptAllType = {RequestType.kUnlockLevelArea},
    pageName = 'unlock',
    pageIndex = 4, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("request.message.panel.tab.unlock"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return true end, 
        rejectAll = function() return false end,
        class = function(msg) return UnlockCloudRequestItem end, 
        zero = 
        function() 
            return RequestMessageZeroWithAskFriend_Unlock
        end
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function ()
        if FriendManager:getInstance():isFriendCountReachedMax() then
            debug_log('zero unlock 4')
            return true 
        end
        debug_log('zero unlock 5')
        return false
    end,
    alwaysHide = function ()
        if WXJPPackageUtil.getInstance():isGuestLogin() then
            return true
        else
            return false
        end
    end,
}

panelConfig[pages.activity] = 
{ 
    msgType = {RequestType.kActivity},
    rejectAllType = {RequestType.kActivity},
    pageName = 'activity',
    pageIndex = 5, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("request.message.panel.tab.activity"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return false end, 
        rejectAll = function() return true end,
        class = function(msg) return ActivityRequestItem end, 
        zero = function() return RequestMessageZeroActivity end
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        -- if __WIN32 then return false end
        return true
    end,
}

panelConfig[pages.update] =
{ 
    msgType = {RequestType.kNeedUpdate},
    pageName = 'needUpdate',
    pageIndex = 6, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("request.message.panel.tab.version"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return NewVersionUtil:hasPackageUpdate() end, 
        rejectAll = function() return true end,
        class = function(msg) return UpdateNewVersionItem end, 
        zero = function() return RequestMessageZeroUpdate end
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () return true end,
}

panelConfig[pages.clover] = 
{ 
    msgType = {RequestType.kClover_AddFriend},
    rejectAllType = {RequestType.kClover_AddFriend},
    acceptAllType = {RequestType.kClover_AddFriend},
    pageName = 'clover',
    pageIndex = 7, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("xx2.invite.title"),
        number = 0,
    },
    pageConfig = 
    {
        pagePadding = {top=15,left=-2,bottom=30,right=0},
        pageBgType = RequestMessagePageBackgroundType.kClover_AddFriend,
        itemMargin = {top=8},
        acceptAll = function() return true end, 
        rejectAll = function() return true end,
        class = function(msg) return FriendRequestItemClover end, 
        zero = function() return RequestMessageZeroActivity end
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        -- if __WIN32 then return false end
        return true
    end,
}


panelConfig[pages.pushActivity] = 
{ 
    msgType = {
        RequestType.kPushActivity,
    },
    rejectAllType = {
        RequestType.kPushActivity,
    },
    pageName = 'pushActivity',
    pageIndex = 8, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("message.tab.activity.push.name"),
        number = 0,
    },
    pageConfig = 
    {
        acceptAll = function() return false end, 
        rejectAll = function() return true end,
        class = function(msg) if _G.isLocalDevelopMode then printx(0, msg.type) end return MessageOriginTypeClass[msg.type] end, 
        zero = function() return RequestMessageZeroNewsPushActivity end
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        -- if __WIN32 then return false end
        return true 
    end,
}

panelConfig[pages.askForHelp] = 
{ 
    msgType = {RequestType.kAskForHelp},
    rejectAllType = {RequestType.kAskForHelp},
    acceptAllType = {RequestType.kAskForHelp},
    pageName = 'askforhelp',
    pageIndex = 9, 
    tabConfig = 
    {
        key = Localization:getInstance():getText("message.panel.tab.askForHelp"),
        number = 0,
    },
    pageConfig = 
    {
        pagePadding = {top=15,left=-2,bottom=30,right=0},
        pageBgType = RequestMessagePageBackgroundType.kAskForHelp,
        itemMargin = {top=8},
        acceptAll = function() return false end, 
        rejectAll = function() return true end,
        class = function(msg) return AskForHelpItem end, 
        zero = function() return RequestMessageZeroActivity end,
        showCustomTip = true,
        getCustomTip = function()
            --[[local mgr = AskForHelpManager.getInstance()
            local cfg = mgr:getConfig()
            local helpData = mgr:getHelpData()
            local num = tonumber(helpData.dailyHelpOtherCount or 0)
            local key = "message.panel.askforhelp.customTip.1"
            if num >= cfg:getMaxDailyHelpOtherCount() then
                key = "message.panel.askforhelp.customTip.2"
                return Localization:getInstance():getText(key)
            end
            return Localization:getInstance():getText(key, {num=cfg:getMaxDailyHelpOtherCount() - num})]]
            return localize("message.panel.askforhelp.record")
        end,
    },
    showWhenNotEmpty = function () return true end,
    hideWhenEmpty = function () 
        return false
    end,
}

local function sortPagesByOrder(pages, order)
    local pageIdxs = {}
    for _, v in pairs(pages) do
        table.insert(pageIdxs, v)
    end
    table.sort(pageIdxs)
    if type(order) == "table" then
        local result = {}
        for _, v in ipairs(order) do
            if table.exist(pageIdxs, v) then
                table.insert(result, v)
            end
        end
        for _, v in ipairs(pageIdxs) do
            if not table.exist(result, v) then
                table.insert(result, v)
            end
        end
        return result
    else
        return pageIdxs
    end
end

panelConfig.getConfig = function ()
    local tabConfigRet = {}
    local pageConfigRet = {}
    -- for k, v in pairs(pages) do
    -- local count = table.size(pages)
    local pageOrder = MetaManager:getInstance().global.messagePagesOrder
    local sortedPages = sortPagesByOrder(pages, pageOrder)
    local index = 1
    -- for i = 1, count do
    for _, i in ipairs(sortedPages) do
        local msgNumber = FreegiftManager:sharedInstance():getMessageNumByType(panelConfig[i].msgType)
        if (msgNumber <= 0 and panelConfig[i].hideWhenEmpty() == true) or
           (msgNumber > 0 and panelConfig[i].showWhenNotEmpty() == false) or 
           (panelConfig[i].alwaysHide and type(panelConfig[i].alwaysHide) == "function" and panelConfig[i].alwaysHide()) then 
            --don't show the tab.
        else
            panelConfig[i].tabConfig.number = msgNumber
            panelConfig[i].tabConfig.msgType = panelConfig[i].msgType
            panelConfig[i].tabConfig.pageName = panelConfig[i].pageName
            panelConfig[i].pageConfig.msgType = panelConfig[i].msgType
            panelConfig[i].pageConfig.pageName = panelConfig[i].pageName
            panelConfig[i].tabConfig.pageIndex = index
            panelConfig[i].pageConfig.pageIndex = index
            panelConfig[i].pageConfig.rejectAllType = panelConfig[i].rejectAllType
            panelConfig[i].pageConfig.acceptAllType = panelConfig[i].acceptAllType
            table.insert(tabConfigRet, panelConfig[i].tabConfig)
            table.insert(pageConfigRet, panelConfig[i].pageConfig)
            index = index + 1
        end
    end
    return tabConfigRet, pageConfigRet
end




panelConfig.clearUpdateIgnoreType = function()
    panelConfig[pages.update].rejectAllType = nil
end

panelConfig.addUpdateIgnoreType = function(type)
    local updatePageRejectAllType = panelConfig[pages.update].rejectAllType
    if updatePageRejectAllType == nil then
        updatePageRejectAllType = {}
    end
    if table.indexOf(updatePageRejectAllType, type) == nil then
        updatePageRejectAllType[#updatePageRejectAllType + 1] = type
        panelConfig[pages.update].rejectAllType = updatePageRejectAllType
    end
end

return panelConfig