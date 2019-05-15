local IosCompFriendHelp = class()

local IOS_SHARE_OPTIONS = {
    NOTIFY = 1,
    P2P_IMAGE = 2,
    P2P_LINK = 3,
    TIMELINE_IMAGE = 4,
    TIMELINE_LINK = 5,
    SYS_IMAGE = 6,
    SYS_LINK = 7,
    P2P_LINK_N_SYS_LINK = 8,
}

function IosCompFriendHelp:create(parentPanel, ui)
    local comp = IosCompFriendHelp.new()
    comp:init(parentPanel, ui)
    return comp
end

local function getNpcName(index)
    if index == 1 then
        return "青蛙"
    elseif  index == 2 then
        return "小黄鸡"
    else
        return "河马"
    end
end

function IosCompFriendHelp:init(parentPanel, ui)
    self.askFriendUnlockSuccess = false
    self.parentPanel = parentPanel
    self.ui = ui
    self.curAreaFriendIds   = UserManager:getInstance():getUnlockFriendUidsWithNPC(self.parentPanel.lockedCloudId)
    self.friendItem1Res = self.ui:getChildByName("friendItem1")
    self.friendItem2Res = self.ui:getChildByName("friendItem2")
    self.friendItem3Res = self.ui:getChildByName("friendItem3")
    self.friendItem1 = FriendItem:create(self.friendItem1Res)
    self.friendItem2 = FriendItem:create(self.friendItem2Res)
    self.friendItem3 = FriendItem:create(self.friendItem3Res)
    self.npc1 = self.ui:getChildByName("little_frog")
    self.npc2 = self.ui:getChildByName("little_chiken")
    self.npc3 = self.ui:getChildByName("little_hippo")
    self.npc1:setVisible(false)
    self.npc2:setVisible(false)
    self.npc3:setVisible(false)
    self.friendItems = {self.friendItem1, self.friendItem2, self.friendItem3}
    for index,friendId in ipairs(self.curAreaFriendIds) do
        if self.friendItems[index] then
            if tostring(friendId) == "-1" then

                local npcname = getNpcName(index)
                self["npc" .. index]:setVisible(true)
                self.friendItems[index]:setFriend(tostring(friendId) , {name = npcname})
            else
                self.friendItems[index]:setFriend(tostring(friendId))
            end
        end
    end

    self.topFriendLabel = self.ui:getChildByName("label_top_friend")
    self.topFriendBtnRes = self.ui:getChildByName("btn_top_friend")
    self.topFriendBtn   = GroupButtonBase:create(self.topFriendBtnRes)
    local askFriendBtnLabelKey  = "unlock.cloud.desc11"
    local askFriendBtnLabelValue    = Localization:getInstance():getText(askFriendBtnLabelKey, {})
    self.topFriendBtn:setString(askFriendBtnLabelValue)
    local function onAskFriendBtnTapped()
        if PrepackageUtil:isPreNoNetWork() then
            PrepackageUtil:showInGameDialog()
        else
            self:onAskFriendBtnTapped()
        end
    end
    self.topFriendBtn:addEventListener(DisplayEvents.kTouchTap, onAskFriendBtnTapped)
    self.topFriendLabel:setString( Localization:getInstance():getText("unlock.cloud.desc10") ) 
    self.sendImgameLinkBtn = ButtonIconsetBase:create(self.ui:getChildByName('btn_send_link'))
    self.sendSysLinkBtn = ButtonIconsetBase:create(self.ui:getChildByName('btn_send_image'))
    self.sendImgameLinkBtn:setString(localize('unlock.btn.send.link.wechat'))
    self.sendSysLinkBtn:setString(localize('unlock.btn.send.image.system'))
    self:refreshBtns()
end

function IosCompFriendHelp:refreshBtns( ... )
    self.sendImgameLinkBtn:setVisible(false)
    self.sendSysLinkBtn:setVisible(false)
    local hasFriendsToSend = self:hasFriendsToSend()
    if not hasFriendsToSend then
        if self:getUserGroupShareOption() == IOS_SHARE_OPTIONS.P2P_LINK_N_SYS_LINK then
            self.topFriendBtn:setVisible(hasFriendsToSend)
            self.sendImgameLinkBtn:setVisible(not hasFriendsToSend)
            self.sendSysLinkBtn:setVisible(not hasFriendsToSend)
            self.sendImgameLinkBtn:removeAllEventListeners()
            self.sendSysLinkBtn:removeAllEventListeners()
            self.sendImgameLinkBtn:ad(DisplayEvents.kTouchTap, function() self:shareLink(IOS_SHARE_OPTIONS.P2P_LINK_N_SYS_LINK, false) end)
            self.sendSysLinkBtn:ad(DisplayEvents.kTouchTap, function () self:shareLink(IOS_SHARE_OPTIONS.P2P_LINK_N_SYS_LINK, true) end) 
        end
    end
end

function IosCompFriendHelp:hasFriendsToSend()
    local fixFriendIds = {}
    for i = 1 , #self.curAreaFriendIds do
        if tostring(self.curAreaFriendIds[i] ) ~= "-1" then
            table.insert( fixFriendIds , self.curAreaFriendIds[i] )
        end
    end
    return ChooseFriendPanel:hasFriendsToSend(self.parentPanel.lockedCloudId, fixFriendIds)
end

function IosCompFriendHelp:onAskFriendBtnTapped(...)
    if __IOS_FB and not SnsProxy:isShareAvailable() then 
        CommonTip:showTip(Localization:getInstance():getText("error.tip.facebook.login"), "negative",nil,2)
        return
    end
    self.parentPanel:tryRemoveGuide()

    local function onGetOption(option)
        if option == IOS_SHARE_OPTIONS.NOTIFY then
            -- RemoteDebug:uploadLog('onGetOption 1')
            self:shareAskHelp()
        elseif option == IOS_SHARE_OPTIONS.P2P_LINK 
            or option == IOS_SHARE_OPTIONS.TIMELINE_LINK
            or option == IOS_SHARE_OPTIONS.SYS_LINK then
            -- RemoteDebug:uploadLog('onGetOption 2')
            self:shareLink(option, option == IOS_SHARE_OPTIONS.SYS_LINK)
        elseif option == IOS_SHARE_OPTIONS.P2P_IMAGE 
            or option == IOS_SHARE_OPTIONS.TIMELINE_IMAGE
            or option == IOS_SHARE_OPTIONS.SYS_IMAGE then
            -- RemoteDebug:uploadLog('onGetOption 3')
            self:shareImage(option, option == IOS_SHARE_OPTIONS.SYS_IMAGE)
        end
    end
    if FriendManager:getInstance():getFriendCount() == 0 or not self:hasFriendsToSend() then
        self:getFinalShareOption(onGetOption)
    else
        DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=1})
        if #self.curAreaFriendIds >= 3 then
            if self.parentPanel.btnTappedState == self.parentPanel.BTN_TAPPED_STATE_NONE then
                self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_ASK_FRIEND_BTN_TAPPED
            else
                return
            end
            self:sendUnlockMsg()
        else
            if WXJPPackageUtil.getInstance():isGuestLogin() then 
                CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
                return 
            end
            self:chooseUnlockFriend(true)
        end
    end
end

function IosCompFriendHelp:shareAskHelp()
    -- RemoteDebug:uploadLog('shareAskHelp')
    DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=1})
    if #self.curAreaFriendIds >= 3 then
        if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
            self.btnTappedState = self.BTN_TAPPED_STATE_ASK_FRIEND_BTN_TAPPED
        else
            return
        end

        self:sendUnlockMsg()
    else
        if WXJPPackageUtil.getInstance():isGuestLogin() then 
            CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
            return 
        end
        
        self:chooseUnlockFriend()
    end
end

function IosCompFriendHelp:getFinalShareOption(callback)
    -- IOS暂时不需要考虑后端开关
    local groupOption = self:getUserGroupShareOption()
    callback(groupOption)
end

function IosCompFriendHelp:sendUnlockMsg()
    local function onSendUnlockMsgSuccess(event)
        if _G.isLocalDevelopMode then printx(0, "onSendUnlockMsgSuccess Called !") end

        local function onRemoveSelfFinish()
            self.parentPanel.unlockCloudSucessCallBack()
            if _G.isLocalDevelopMode then printx(0, "onRemoveSelfFinish Called !") end
        end
        self.parentPanel.isUnlockSuccess = true
        self.parentPanel:remove(onRemoveSelfFinish)
    end

    local function onSendUnlockMsgFailed(errorCode)
        self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_NONE
        CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
    end

    local function onSendUnlockMsgCanceled(event)
        self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_NONE
    end

    local fixIds = {}
    local npcNum = 0
    for i = 1 , #self.curAreaFriendIds do
        if tostring(self.curAreaFriendIds[i]) ~= "-1" then
            table.insert( fixIds , tonumber(self.curAreaFriendIds[i]) )
        elseif tostring(self.curAreaFriendIds[i]) ~= "-1" then
            npcNum = npcNum + 1
        end
    end

    local useType = nil
    local datas = nil
    if #fixIds < 3 then
        useType = UnlockLevelAreaLogicUnlockType.USE_SIM_FRIEND
        datas = {}
        datas.npc = npcNum
    else
        useType = UnlockLevelAreaLogicUnlockType.USE_FRIEND
    end

    local logic = UnlockLevelAreaLogic:create(self.parentPanel.lockedCloudId)
    logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
    logic:setOnFailCallback(onSendUnlockMsgFailed)
    logic:setOnCancelCallback(onSendUnlockMsgCanceled)
    logic:start( useType , fixIds , nil , datas)
end

function IosCompFriendHelp:getUserGroupShareOption()
    -- if __WIN32 or _G.isLocalDevelopMode then
    --     return IOS_SHARE_OPTIONS.P2P_IMAGE
    -- end
    local uid = UserManager:getInstance().user.uid or '12345'
    local defaultOption = IOS_SHARE_OPTIONS.NOTIFY
    for k, v in pairs(IOS_SHARE_OPTIONS) do
        print(string.lower(k), MaintenanceManager:getInstance():isEnabledInGroup('IosUnlockGroupConfig', string.lower(k), uid))
        if MaintenanceManager:getInstance():isEnabledInGroup('IosUnlockGroupConfig', string.lower(k), uid) then
            defaultOption = v
            break
        end
    end
    -- RemoteDebug:uploadLog('getUserGroupShareOption', defaultOption)
    return defaultOption
end

function IosCompFriendHelp:chooseUnlockFriend(isNewLogic)
    local function chooseFriendFunc()
        local function onSuccess(friendIds)
            if not self.friendIdsSent then
                self.friendIdsSent = {}
            end
            if friendIds then
                for k, v in pairs(friendIds) do
                    table.insert(self.friendIdsSent, v)
                end
            end
            self:refreshBtns()
            self.askFriendUnlockSuccess = true
        end
        local function onFail(evt) end
        local function allSentCallback()
            local option = self:getUserGroupShareOption()
            DcUtil:UserTrack({category='unlock', sub_category='push_help_all', id=option})
        end
        local fixFriendIds = {}
        for i = 1 , #self.curAreaFriendIds do
            if tostring(self.curAreaFriendIds[i] ) ~= "-1" then
                table.insert( fixFriendIds , self.curAreaFriendIds[i] )
            end
        end
        ChooseFriendPanel:popoutPanel(self.parentPanel.lockedCloudId, fixFriendIds , onSuccess, onFail, isNewLogic, allSentCallback)
    end
    PushBindingLogic:runChooseFriendLogic(chooseFriendFunc, 6)
end

function IosCompFriendHelp:getShareUrl(option, isSysLink)
    local url = "unlock_help_button.html"
    local sender = tostring(UserManager:getInstance().user.uid or '12345')
    local pf = PlatformConfig.name
    local cloudId = tostring(self.parentPanel.lockedCloudId)
    local plan = option
    local actId = '10009'
    local game_name = 'ios_unlock_help_'..tostring(plan)
    if option == IOS_SHARE_OPTIONS.P2P_LINK_N_SYS_LINK then
        if isSysLink then
            game_name = game_name .. '_2'
        else
            game_name = game_name .. '_1'
        end
    end
    local baseUrl = NetworkConfig.dynamicHost..url
    local url = string.format("%s?sender=%s&pf=%s&cloudId=%s&plan=%s&actId=%s&game_name=%s", baseUrl, sender, pf, cloudId, plan, actId, game_name)
    return url
end

function IosCompFriendHelp:shareLink(option, isSysLink)
    -- RemoteDebug:uploadLog('shareLink',option, isSysLink)
    if self.waitingShare then return end
    local dcId = option
    if dcId == 8 then
        if isSysLink then
            dcId = 8.2
        else
            dcId = 8.1
        end
    end
    DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=dcId})
    local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/unlock_share_icon.png")
    local title = localize('unlock.share.link.title')
    local message = localize('unlock.share.link.message')
    local shareUrl = self:getShareUrl(option, isSysLink)
    local isSendToFeeds = (option == IOS_SHARE_OPTIONS.TIMELINE_LINK or (option == IOS_SHARE_OPTIONS.P2P_LINK_N_SYS_LINK and isSysLink))
    if isSendToFeeds then
        title = localize('unlock.share.link.title.timeline')
        message = localize('unlock.share.link.message.timeline')
    end
    local shareCallback = {
        onSuccess = function(result)
            DcUtil:UserTrack({category='unlock', sub_category='push_help_success', id=dcId})
            -- if isSendToFeeds then
            --     local http = ShareMomentsSuccHttp.new(false)
            --     http:load(self:getAppId(), 2)
            -- end
            CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
        end,
        onError = function(errCode, errMsg)
            CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
        end,
        onCancel = function()
            CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
        end
    }
    local function notifySuccess()
        self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function() self.waitingShare = false end)))
        if __WIN32 then
            shareCallback.onSuccess()
            return
        end
        if isSysLink then
            -- -- RemoteDebug:uploadLog('2222222222', shareUrl, title, message, thumb)
            SystemShareUtil:shareLink_subject_thumb_callback(shareUrl, title, thumb, shareCallback)
        else
            local shareType, delayResume = SnsUtil.getShareType()
            -- -- RemoteDebug:uploadLog('111111111', shareType, title, message, thumb, shareUrl, isSendToFeeds)
            SnsUtil.sendLinkMessage( shareType, title, message, thumb, shareUrl, isSendToFeeds, shareCallback)
        end
    end
    local function failOrCancelCallback()
        self.waitingShare = false
    end
    self.waitingShare = true
    self:opNotify(notifySuccess, failOrCancelCallback)
end

function IosCompFriendHelp:shareImage(option, isSysLink)
    -- -- RemoteDebug:uploadLog('shareImage',option, isSysLink)
    if self.waitingShare then return end
    local dcId = option
    if dcId == 8 then
        if isSysLink then
            dcId = 8.2
        else
            dcId = 8.1
        end
    end
    DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=dcId})
    -- local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/unlock_share_icon.png")
    local title = localize('unlock.share.link.title')
    local message = localize('unlock.share.link.message')
    local shareUrl = self:getShareUrl(option)
    local isSendToFeeds = (option == IOS_SHARE_OPTIONS.TIMELINE_IMAGE)
    local dirBase = HeResPathUtils:getResCachePath()
    local shareImagePath = dirBase .. "/share_image.jpg"
    local thumb = dirBase .. '/share_image_small.jpg'
    local function renderImage()
        local bgPath = 'share/unlock_share.jpg'
        local bg = Sprite:create(bgPath)
        if _G.__use_small_res then
            bg:setScale(0.625)
        end
        local builder = InterfaceBuilder:create('ui/share_unlock.json')
        local group = builder:buildGroup('unlock_share_group')
        local codePh = group:getChildByName('codePh')
        local width = codePh:getContentSize().width*codePh:getScaleX() -- 正方形的
        local code = CocosObject.new(QRManager:generatorQRNode(shareUrl, width))
        local iconPath = 'materials/wechat_icon.png'
        local icon = Sprite:create(iconPath)
        local codeSize = code:getContentSize()
        icon:setScale(30/icon:getContentSize().width)
        code:addChild(icon)
        icon:setPositionXY(codeSize.width/2, codeSize.height/2)
        code:setAnchorPoint(ccp(0, 1))
        group:addChild(bg)
        bg:setAnchorPoint(ccp(0, 1))
        bg:setPosition(ccp(0, 0))
        code:setScaleX(width / codeSize.width)
        code:setScaleY(width / codeSize.height) 
        code:setRotation(codePh:getRotation())
        group:addChild(code)
        code:setPositionX(codePh:getPositionX())
        code:setPositionY(codePh:getPositionY())
        group:setPositionXY(0, 720)
        local renderTexture = CCRenderTexture:create(720, 720)
        renderTexture:begin()
        group:visit()
        renderTexture:endToLua()
        renderTexture:saveToFile(shareImagePath)

        local thumbScale = 256 / 720
        local renderTexture = CCRenderTexture:create(256, 256)
        renderTexture:begin()
        group:setPositionXY(0, 256)
        group:setScale(thumbScale)
        group:visit()
        renderTexture:endToLua()
        renderTexture:saveToFile(thumb)


        group:dispose()
        CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(bgPath))
        CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(iconPath))
    end
    local shareCallback = {
        onSuccess = function(result)
            DcUtil:UserTrack({category='unlock', sub_category='push_help_success', id=dcId})
            CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
        end,
        onError = function(errCode, errMsg)
            CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
        end,
        onCancel = function()
            CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
        end
    }
    local function notifySuccess()
        self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function() self.waitingShare = false end)))
        if __WIN32 then
            shareCallback.onSuccess()
            return
        end
        if isSysLink then
            SystemShareUtil:shareImage_subject_thumb_callback(shareImagePath, title, thumb, shareCallback)
        else
            local shareType, delayResume = SnsUtil.getShareType()
            SnsUtil.sendImageMessage( shareType, title, message, thumb, shareImagePath, shareCallback, isSendToFeeds)
        end
    end
    local function failOrCancelCallback()
        self.waitingShare = false
    end
    self.waitingShare = true
    renderImage()
    self:opNotify(notifySuccess, failOrCancelCallback)
end

function IosCompFriendHelp:opNotify(successCallback, failOrCancelCallback)
    local function onFailCancel(evt)
        if evt and evt.data then
            CommonTip:showTip(localize('error.tip.'..tostring(evt.data or -6)), 'negative')
        end
        if failOrCancelCallback then
            failOrCancelCallback()
        end
    end
    local function doHttp()
        local http = OpNotifyHttp.new(true)
        http:load(38, self.parentPanel.lockedCloudId)
        http:ad(Events.kComplete, successCallback)
        http:ad(Events.kError, onFailCancel)
        http:ad(Events.kCancel, onFailCancel)
    end
    RequireNetworkAlert:callFuncWithLogged(doHttp, onFailCancel)
end

return IosCompFriendHelp