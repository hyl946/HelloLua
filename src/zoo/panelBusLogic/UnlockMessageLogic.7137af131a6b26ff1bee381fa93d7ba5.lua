UnlockMessageLogic = class()

function UnlockMessageLogic:start(para, close_cb)
    local senderUid = tostring(para.sender)
    local receivers = {}
    if para.receivers then
        receivers = string.split(para.receivers, 'a')
    end
    local cloudId = tonumber(para.cloudId)
    local platform = tostring(para.pf)
    local myUid =UserManager:getInstance().user.uid or "12345"
    local IamQQ = PlatformConfig:isQQPlatform()
    local heIsQQ = (platform == 'yingyongbao' or string.starts(platform, 'yyb'))

    if senderUid == myUid then
        AutoPopout:showNotifyPanel( "不能帮自己解锁哟，去找好友来帮忙吧~", close_cb)
        return
    end

    if heIsQQ and not IamQQ then
        AutoPopout:showNotifyPanel( "您的好友是应用宝版本玩家，与您的游戏版本不一致，不能帮忙哟~", close_cb)
        return
    elseif not heIsQQ and IamQQ then
        AutoPopout:showNotifyPanel( "您的好友不是应用宝版本玩家，与您的游戏版本不一致，不能帮忙哟~", close_cb)
        return
    end

    local IamReceiver = false
    for k, v in pairs(receivers) do
        if myUid == v then
            IamReceiver = true
            break
        end
    end

    local function handler()
        GlobalEventDispatcher:getInstance():removeEventListener(MessageCenterPushEvents.kFriendsSynced, handler)
        local isMyFriend = false
        local isMaxFriendCount = FriendManager:getInstance():isFriendCountReachedMax()
        local friends = FriendManager:getInstance().friends
        for k, v in pairs(friends) do
            if tostring(v.uid) == senderUid then
                isMyFriend = true
                break
            end
        end

        if _G.isLocalDevelopMode then printx(0, 'isMyFriend', isMyFriend) end
        -- debug.debug()

        if isMyFriend then
            local function messageCallback(result, evt)
                 if result == "success" then
                    local found = false
                    local messages = FreegiftManager:sharedInstance().requestInfos
                    for k, v in pairs(messages) do
                        if v.type == RequestType.kUnlockLevelArea then
                            if tonumber(v.itemId) == cloudId
                            and v.senderUid == senderUid then
                                found = true
                                break
                            end
                        end
                    end
                    if found then                        
                        local scene = MessageCenterScene:create()
                        Director:sharedDirector():pushScene(scene)
                        local panel = scene.panel
                        panel:gotoUnlockPage()
                    else
                        AutoPopout:showNotifyPanel( "您的好友不是应用宝版本玩家，与您的游戏版本不一致，不能帮忙哟~", close_cb)
                    end

                    if HomeScene:sharedInstance().messageButton then
                        HomeScene:sharedInstance().messageButton:updateView()
                    end
                else
                    local message = ''
                    local err_code = tonumber(evt.data)
                    if err_code then message = Localization:getInstance():getText("error.tip."..err_code) end
                    AutoPopout:showNotifyPanel( message, close_cb)
                end
            end
            FreegiftManager:sharedInstance():update(false, messageCallback)
        else
            if isMaxFriendCount then
                AutoPopout:showNotifyPanel( "他不是您的游戏好友，您无法帮助他哦~", close_cb)
                return
            else
                AutoPopout:showNotifyPanel( "您的好友没有给您发送游戏内解锁请求哦，他可能已经找别人帮忙啦~", close_cb)
                return
            end
        end
    end

    if HomeScene:sharedInstance().worldScene and HomeScene:sharedInstance().worldScene.friendsInitiated then
        handler()
    else
        if not GlobalEventDispatcher:getInstance():hasEventListener(MessageCenterPushEvents.kFriendsSynced, handler) then
            GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kFriendsSynced, handler)
        end
    end
end