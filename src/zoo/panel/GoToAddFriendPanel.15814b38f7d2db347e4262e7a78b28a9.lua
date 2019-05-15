GoToAddFriendPanel = class(BasePanel)

GoToAddFriendPanel.FUNC_TYPE = {ENERGY = "energy", UNLOCK = "unlock"}
GoToAddFriendPanel.ACTION_TYPE = {ADD = "add", SEND = "sent", SHARE = "share"}
function GoToAddFriendPanel:create(para)
    local instance = GoToAddFriendPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.AskForEnergyPanel)
    instance:init(para)
    return instance
end

function GoToAddFriendPanel:init(para)
    self.state = para[1] or GoToAddFriendPanel.FUNC_TYPE.ENERGY
    self.action = para[2] or GoToAddFriendPanel.ACTION_TYPE.ADD
    if self.state == GoToAddFriendPanel.FUNC_TYPE.ENERGY and 
        self.action == GoToAddFriendPanel.ACTION_TYPE.SEND and 
        self:hasSharePlatform() then
       self.action = GoToAddFriendPanel.ACTION_TYPE.SHARE
    end
    local ui = self.builder:buildGroup('go_to_add_friend_panel')
    BasePanel.init(self, ui)
    for k, v in pairs(ui.list) do
        if v.name:starts('msg_') then
            if v.name == 'msg_'..self.state..'_'..self.action then
                v:setVisible(true)
            else
                v:setVisible(false)
            end
        end
    end

    self.ui:getChildByName('msg_energy_share_ios'):setVisible(false)
    self.ui:getChildByName('bubble_share_ios'):setVisible(false)

    self.title = self.ui:getChildByName('title')
    if self.state == GoToAddFriendPanel.FUNC_TYPE.ENERGY and 
        self.action == GoToAddFriendPanel.ACTION_TYPE.SHARE and 
        self:hasSharePlatform() then
        DcUtil:UserTrack({category = "energy", sub_category = "push_help_energy_trigger"})
        self.ui:getChildByName('btn'):setVisible(false)
        self.p2pShareBtn = ButtonIconsetBase:create(self.ui:getChildByName('p2pShareBtn'))
        self.momentsShareBtn = ButtonIconsetBase:create(self.ui:getChildByName('momentsShareBtn'))
        self.p2pShareBtn:setString(localize('unlock.btn.send.link.wechat'))
        self.p2pShareBtn:setIconByFrameName("common_icon/sns/icon_wechat0000")

        self.momentsShareBtn:setString(localize('unlock.btn.send.image.system'))
        self.momentsShareBtn:setIconByFrameName("common_icon/sns/icon_timeline0000")
        self.p2pShareBtn:ad(DisplayEvents.kTouchTap, function() self:preShareP2PLink() end)
        self.momentsShareBtn:ad(DisplayEvents.kTouchTap, function () self:preShareMomentsImage() end) 
        self.title:setText(localize("wechat.share.for.free.gfit"))
        self.ui:getChildByName("shareTip"):setString(localize("wechat.share.for.free.gfit.desc"))

        --ios 不要朋友圈分享
        if __IOS then
            self.momentsShareBtn:setVisible(false)
            local midX = (self.p2pShareBtn:getPositionX() + self.momentsShareBtn:getPositionX())/2
            self.p2pShareBtn:setPositionX(midX)

            self.ui:getChildByName('msg_energy_share_ios'):setVisible(true)
            self.ui:getChildByName('bubble_share_ios'):setVisible(true)
            self.ui:getChildByName('msg_energy_share'):setVisible(false)
            self.ui:getChildByName('bubble'):setVisible(false) 

        end
    else
        self.ui:getChildByName("p2pShareBtn"):setVisible(false)
        self.ui:getChildByName("momentsShareBtn"):setVisible(false)
        self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
        self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)
        if self.action == GoToAddFriendPanel.ACTION_TYPE.ADD then
            self.btn:setString(localize('friend.ranking.panel.button.add'))
        else
            self.btn:setString('确定')
        end
        self.title:setText('选择好友') -- text@wenkan
    end

    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPositionXY(305, -49)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function ()
            self:onCloseBtnTapped()
    end)
end

function GoToAddFriendPanel:preShareP2PLink()
    if self.p2pShareBtn.inClk then return end
    self.p2pShareBtn.inClk = true
    local function onSuccess(evt)
        self.p2pShareBtn.inClk = false
        if evt.data and evt.data.pageId then
            self:shareP2PLink(evt.data.pageId)
        end
    end
    local function onFail(evt)
        self.p2pShareBtn.inClk = false
        local errcode = evt and evt.data or nil
        if errcode then
            local scene = Director:sharedDirector():run()
            if  scene ~= nil then
                CommonTip:showTip(localize("error.tip."..tostring(errcode)), "negative")
            end
        end
    end
    local http = AskEnergyShareHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load()
    DcUtil:UserTrack({category = "energy", sub_category = "push_help_energy_wx"})
end

function GoToAddFriendPanel:preShareMomentsImage()
    if self.momentsShareBtn.inClk then return end
    self.momentsShareBtn.inClk = true
    local function onSuccess(evt)
        self.momentsShareBtn.inClk = false
        if evt.data and evt.data.pageId then
            self:shareMomentsImage(evt.data.pageId)
        end
    end
    local function onFail(evt)
        self.momentsShareBtn.inClk = false
        local errcode = evt and evt.data or nil
        if errcode then
            local scene = Director:sharedDirector():run()
            if  scene ~= nil then
                CommonTip:showTip(localize("error.tip."..tostring(errcode)), "negative")
            end
        end
    end
    local http = AskEnergyShareHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load()
    DcUtil:UserTrack({category = "energy", sub_category = "push_help_energy_pyq"})
end

function GoToAddFriendPanel:hasSharePlatform()
    if __WIN32 then return true end

    if PlatformConfig:isJJPlatform() or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) or WXJPPackageUtil.getInstance():isWXJPPackage() then
        return false
    end

    return true
end

function GoToAddFriendPanel:shareP2PLink(pageId)
    if self.inP2PShare then return end
    local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/ask_energy_share_icon.png")--to do lhl
    local title = localize('ask.energy.share.link.title')
    local message = localize('ask.energy.share.link.message')
    local shareUrl = self:getShareUrl(true, pageId)
    local shareCallback = {
        onSuccess = function(result)
            CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
            DcUtil:UserTrack({category = "energy", sub_category = "push_help_energy_success_wx"})
        end,
        onError = function(errCode, errMsg)
            CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
        end,
        onCancel = function()
            CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
        end
    }
    local function notifySuccess()
        if self.ui == nil or self.ui.isDisposed then return end

        self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function() self.inP2PShare = false end)))
        if __WIN32 then
            shareCallback.onSuccess()
            return
        end
        local shareType = SnsUtil.getShareType()
        if __ANDROID then 
            AndroidShare.getInstance():registerShare(shareType)
        end
        SnsUtil.sendLinkMessage( shareType, title, message, thumb, shareUrl, false, shareCallback)
    end
    local function failOrCancelCallback()
        self.inP2PShare = false
    end
    self.inP2PShare = true
    self:opNotify(notifySuccess, failOrCancelCallback)
end

function GoToAddFriendPanel:getShareUrl(isLink, pageId)
    local sender = tostring(UserManager:getInstance().user.uid or '12345')
    local dcPre = "push_help_energy_ewm_" -- 朋友圈
    if isLink then dcPre = "push_help_energy_link_" end -- 点对点
    local dcTag = 2
    -- if tonumber(sender) % 100 < 50 then dcTag = 1 end
    local game_name = dcPre .. dcTag
    local pid = PlatformConfig.name
    local hostUrl = NetworkConfig:getShareHost()
    -- local hostUrl = "http://10.130.137.118:8082/Webstorm/"
    local baseUrl = hostUrl .. "ask_energy.html"
    local url = string.format("%s?pid=%s&game_name=%s&pageId=%s&", baseUrl, pid, game_name, pageId)
    return url
end

function GoToAddFriendPanel:shareMomentsImage(pageId)
    if self.inMomentsShare then return end
    local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/ask_energy_share_icon.png")--to do lhl
    local title = localize('ask.energy.share.link.title')
    local message = localize('ask.energy.share.link.message')
    local shareUrl = self:getShareUrl(false, pageId)
    local dirBase = HeResPathUtils:getResCachePath()
    if __ANDROID then
        dirBase = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
    end
    local shareImagePath = dirBase .. "/share_image.jpg"
    local function renderImage()
        local bgPath = 'share/ask_energy_share.jpg'
        local bg = Sprite:create(bgPath)
        if _G.__use_small_res then
            bg:setScale(0.625)
        end
        local builder = InterfaceBuilder:create('ui/share_ask_energy.json')
        local group = builder:buildGroup('ask_energy_share_group')
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
        group:dispose()
        CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(bgPath))
        CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(iconPath))
    end
    local shareCallback = { 
        onSuccess = function(result) 
            DcUtil:UserTrack({category = "energy", sub_category = "push_help_energy_success_pyq"})
        end,
        onError = function(errCode, errMsg) end,
        onCancel = function() end}
    local function notifySuccess()
        if self.ui == nil or self.ui.isDisposed then return end

        self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function() self.inMomentsShare = false end)))
        if __WIN32 then
            shareCallback.onSuccess()
            return
        end

        local function shareToAndroid(title, message, thumbUrl, imageURL, shareCallback)
            local shareType = PlatformShareEnum.kSYS_WECHAT
            AndroidShare.getInstance():registerShare(shareType)
            SnsUtil.sendImageMessage(shareType, title, message, thumbUrl, imageURL, shareCallback, true)
        end

        local function shareToiOS(title, message, thumbUrl, imageURL, shareCallback)
            SnsUtil.sendImageMessage(PlatformShareEnum.kWechat, title, message, thumbUrl, imageURL, shareCallback, true)
        end
        if __ANDROID then
            shareToAndroid(title, message, thumb, shareImagePath, shareCallback)
        elseif __IOS then
            shareToiOS(title, message, thumb, shareImagePath, shareCallback)
        end
    end
    local function failOrCancelCallback()
        self.inMomentsShare = false
    end
    self.inMomentsShare = true
    renderImage()
    self:opNotify(notifySuccess, failOrCancelCallback)
end

function GoToAddFriendPanel:opNotify(successCallback, failOrCancelCallback)
    local function onFailCancel(evt)
        if evt and evt.data then
            CommonTip:showTip(localize('error.tip.'..tostring(evt.data or -6)), 'negative')
        end
        if failOrCancelCallback then
            failOrCancelCallback()
        end
    end
    
    RequireNetworkAlert:callFuncWithLogged(successCallback, onFailCancel)
end

function GoToAddFriendPanel:onBtnTapped()
    if self.action == GoToAddFriendPanel.ACTION_TYPE.ADD then
        if WXJPPackageUtil.getInstance():isWXJPPackage() then 
            self:onWXJPAddFriends()
        else
            -- if self.state == GoToAddFriendPanel.FUNC_TYPE.ENERGY and 
            --    not _G.sns_token and 
            --    PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true) then
            --     AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, onSuccess, onFail, onCancel, AccountBindingSource.ASK_ENERGY)
            -- else
                PushBindingLogic:runPopAddFriendPanelLogic()
            -- end
        end
    else
        self:onCloseBtnTapped()
    end
end

function GoToAddFriendPanel:onWXJPAddFriends()
    self.btn:setEnabled(false)

    local shareCallback = {
        onSuccess=function(result)
            if self.isDisposed then return end
            self.btn:setEnabled(true)
        end,
        onError=function(errCode, msg) 
            if self.isDisposed then return end
            self.btn:setEnabled(true)
        end,
        onCancel=function()
            if self.isDisposed then return end
            self.btn:setEnabled(true)
        end
    }

    local shareType, delayResume = SnsUtil.getShareType()
    SnsUtil.sendInviteMessage(shareType, shareCallback)
end

function GoToAddFriendPanel:popout()
    self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)
    self:setPositionForPopoutManager()
end

function GoToAddFriendPanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
end