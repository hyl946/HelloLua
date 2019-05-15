require "zoo.util.IllegalWordFilterUtil"
require "zoo.config.PlatformConfig"
require "zoo.panel.QRCodePanel"
require "zoo.net.QzoneSyncLogic"
require "zoo.panel.RequireNetworkAlert"
require 'zoo.panel.accountPanel.AccountSettingPanel'


AccountPanel = class(BasePanel)

function AccountPanel:create()
    local newQuitPanel = AccountPanel.new()
    newQuitPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
    newQuitPanel:init()
    return newQuitPanel
end

function AccountPanel:initAvatar( group )
    if not group then return nil end
    local avatarPlaceholder = group:getChildByName("avatarPlaceholder")
    local frameworkChosen = group:getChildByName("frameworkChosen")
    if frameworkChosen then frameworkChosen:setVisible(false) end

    local hitArea = CocosObject:create()
    hitArea.name = kHitAreaObjectName
    hitArea:setContentSize(CCSizeMake(100,100))
    hitArea:setPosition(ccp(-50,-50))
    group:addChild(hitArea)

    group.chooseIcon = frameworkChosen
    group.select = function ( self, val )
        self.selected = val
        if self.chooseIcon then self.chooseIcon:setVisible(val) end
    end
    group.changeImage = function( self, userId, headUrl )
        local oldImageIndex = nil
        if self.headImage then 
            oldImageIndex = self.headImage.headImageUrl 
            self.headImage:removeFromParentAndCleanup(true) 
        end

        local framePos = avatarPlaceholder:getPosition()
        local frameSize = avatarPlaceholder:getContentSize()
        local function onImageLoadFinishCallback(clipping)
            if self.isDisposed then return end
            local clippingSize = clipping:getContentSize()
            local scale = frameSize.width/clippingSize.width
            clipping:setScale(scale*0.83)
            clipping:setPosition(ccp(frameSize.width/2-2,frameSize.height/2))
            avatarPlaceholder:addChild(clipping)
            self.headImage = clipping   
        end
        HeadImageLoader:create(userId, headUrl, onImageLoadFinishCallback)

        return oldImageIndex
    end
    group.getProfileURL = function( self )
        if self.headImage then return self.headImage.headImageUrl end
        return nil
    end
    return group
end
function AccountPanel:initMoreAvatars( group )
    local kDefaultUserIndex = 10
    local profile = UserManager.getInstance().profile
    local kMaxHeadImages = UserManager.getInstance().kMaxHeadImages
    local moreAvatarList = {}
    local function getAvatarByHeadImage(headUrl)
        for i=0 , 10 do
            local v = moreAvatarList[i]
            if v:getProfileURL() == headUrl then return v end
        end
        return nil
    end
    local function changeDefaultAvatarImage()
        local oldHeadAvatar = getAvatarByHeadImage(profile.headUrl)
        local oldImageIndex = moreAvatarList[kDefaultUserIndex]:changeImage(profile.uid, profile.headUrl)
        if self.playerAvatar then self.playerAvatar:changeImage(profile.ui, profile.headUrl) end
        if oldHeadAvatar then oldHeadAvatar:changeImage("exp."..tostring(oldImageIndex), oldImageIndex) end
    end
    local function onAvatarItemTouch( evt )
        for i=0 , 10 do
            local v = moreAvatarList[i]
            if v:hitTestPoint(evt.globalPosition, true) then
                self:onAvatarTouch() 
                local headUrl = v:getProfileURL()
                if profile.headUrl ~= headUrl then
                    profile.headUrl = headUrl
                    AccountPanel:updateUserProfile()
                    changeDefaultAvatarImage()
                end
            end
        end
    end
    for i=0 , 10 do
        local avatar = self:initAvatar(group:getChildByName("p"..(i+1)))
        if avatar then
            avatar.index = i
            moreAvatarList[i] = avatar
            avatar:changeImage("exp."..i, i)
        end
    end
    changeDefaultAvatarImage()
    moreAvatarList[kDefaultUserIndex]:select(true)  
    self.moreAvatarList = moreAvatarList
    group:setTouchEnabled(true, -1, true)
    group:ad(DisplayEvents.kTouchTap, onAvatarItemTouch)
end
function AccountPanel:initInput(onBeginCallback)
    local user = UserManager.getInstance().user
    local profile = UserManager.getInstance().profile   
    local inputSelect = self.nameLabel:getChildByName("inputBegin")
    local inputSize = inputSelect:getContentSize()
    local inputPos = inputSelect:getPosition()
    inputSelect:setVisible(true)
    inputSelect:removeFromParentAndCleanup(false)

    local function onTextBegin()
        if onBeginCallback then onBeginCallback() end
    end
    
    local function onTextEnd()
        if self.input then
            local profile = UserManager.getInstance().profile
            local text = self.input:getText() or ""
            if text ~= "" then
                -- 敏感词过滤
                if IllegalWordFilterUtil.getInstance():isIllegalWord(text) then
                    local oldName = nameDecode(profile.name or "")
                    self.input:setText(oldName)
                    CommonTip:showTip(Localization:getInstance():getText("error.tip.illegal.word"), "negative")
                else
                    if profile.name ~= text then
                        profile:setDisplayName(text)
                        AccountPanel:updateUserProfile()
                    end
                end
            else
                CommonTip:showTip(Localization:getInstance():getText("game.setting.panel.username.empty"), "negative")
            end
        end
    end

    local position = ccp(inputPos.x + inputSize.width/2, inputPos.y - inputSize.height/2)
    local input = TextInputIm:create(inputSize, Scale9Sprite:createWithSpriteFrameName("ui_empty0000"), inputSelect.refCocosObj)
    input.originalX_ = position.x
    input.originalY_ = position.y
    input:setText(profile:getDisplayName())
    input:setPosition(position)
    input:setFontColor(ccc3(0,0,0))
    input:setMaxLength(15)
    input:ad(kTextInputEvents.kBegan, onTextBegin)
    input:ad(kTextInputEvents.kEnded, onTextEnd)
    self.nameLabel:addChild(input)
    self.input = input
    inputSelect:dispose()
end

function AccountPanel:isNicknameUnmodifiable()
    if not _G.sns_token then
        return false
    end

    if __IOS then
        local authType = SnsProxy:getAuthorizeType()
        return authType == PlatformAuthEnum.kQQ
    elseif __ANDROID then
        local authType = SnsProxy:getAuthorizeType()
        return authType == PlatformAuthEnum.kQQ
            or authType == PlatformAuthEnum.kWeibo
            or authType == PlatformAuthEnum.kMI
            or authType == PlatformAuthEnum.kWDJ
            or authType == PlatformAuthEnum.k360
    end

    return false
end

function AccountPanel:isAvatarUnmodifiable()
    if not _G.sns_token then
        return false
    end

    if __IOS then
        local authType = SnsProxy:getAuthorizeType()
        return authType == PlatformAuthEnum.kQQ
    elseif __ANDROID then
        local authType = SnsProxy:getAuthorizeType()
        return authType == PlatformAuthEnum.kQQ
            or authType == PlatformAuthEnum.kWeibo
            or authType == PlatformAuthEnum.kMI
    end

    return false
end

function AccountPanel:init()
    self.ui = self:buildInterfaceGroup("accountPanel")
    
    BasePanel.init(self, self.ui)
    local user = UserManager.getInstance().user
    local profile = UserManager.getInstance().profile

    -- 是否允许修改头像和昵称
    self.headImageModifiable = true
    self.nickNameModifiable = true
    
    if (__ANDROID or __IOS) then
        if self:isNicknameUnmodifiable() then
            self.nickNameModifiable = false
        end
        if self:isAvatarUnmodifiable() then
            self.headImageModifiable = false
        end
    end

    if not kUserLogin then
        self.headImageModifiable = false
        self.nickNameModifiable = false
    end

    self.panelTitle     = self.ui:getChildByName("panelTitle")
    self.closeBtn       = self.ui:getChildByName("closeBtn")
    self.nameLabel      = self.ui:getChildByName("touch")
    self.moreAvatars    = self.ui:getChildByName("moreAvatars")
    self.avatar         = self.ui:getChildByName("avatar")
    self.bg = self.ui:getChildByName("_newBg")
    self.innerBg = self.ui:getChildByName('_newBg2')

    self.moreAvatars:setVisible(false)

    self.playerAvatar = self:initAvatar(self.avatar:getChildByName("settingavatarframework"))
    self.playerAvatar:changeImage(profile.ui, profile.headUrl)

    self.panelTitle:setText('我的账号')
    local size = self.panelTitle:getContentSize()
    local scale = 65 / size.height
    self.panelTitle:setScale(scale)
    self.panelTitle:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)

    if not self.headImageModifiable then 
        local arrow = self.avatar:getChildByName("avatarArrow") 
        if arrow then arrow:setVisible(false) end
    end

    self.nameLabel:getChildByName("touch"):removeFromParentAndCleanup(true) 
    self.nameLabel:getChildByName("label"):setString(profile:getDisplayName())
    self.nameLabel:getChildByName("inputBegin"):setVisible(false)
    self:initMoreAvatars(self.moreAvatars)

    self.qrCodeBtn = self.ui:getChildByName('qrCodeBtn')
    self.qrCodeBtn:setTouchEnabled(true)
    self.qrCodeBtn:ad(DisplayEvents.kTouchTap, function() self:onCodeBtnTapped() end)
    self.qrCodeBtn:getChildByName('text'):setString(localize('setting.panel.button.1'))

    self.accountBtn = self.ui:getChildByName('accountBtn')
    self.accountBtn.redDot = self.accountBtn:getChildByName('redDot')
    self.accountBtn:getChildByName('text'):setString(localize('setting.panel.button.7'))

    if self:shouldShowAccountBtn() then
        self.accountBtn:setPositionX(129)
        self.accountBtn:setTouchEnabled(true)
        self.accountBtn:ad(DisplayEvents.kTouchTap, function () self:onAccountBtnTapped() end)
        self.qrCodeBtn:setPositionX(361)
        if self:hasAccountBinded() then
            self.accountBtn.redDot:setVisible(false)
        else
            self.accountBtn.redDot:setVisible(true)
        end
    else
        self.accountBtn:setVisible(false)
        self.qrCodeBtn:setPositionX(242)
    end

    

    -- 需求：做任何操作都会取消5秒后仅一次的邀请码放大缩小
    local schedule = nil
    local function stopSchedule()
        if schedule then
            Director:sharedDirector():getScheduler():unscheduleScriptEntry(schedule)
            schedule = nil
        end
    end

    --昵称可修改时 TextField隐藏 创建TextInput 否则不创建TextInput
    if self.nickNameModifiable then 
        self.nameLabel:getChildByName("label"):setVisible(false)
        self:initInput(stopSchedule)
    end

    local inviteCode = UserManager.getInstance().inviteCode
    if __IOS_FB then inviteCode = UserManager.getInstance().user.uid end
    if inviteCode and inviteCode ~= "" then
        if __IOS_FB then 
            self.ui:getChildByName("idLabelPrefix"):setString("uid:") 
            self.ui:getChildByName("idLabelNum"):setText(tostring(inviteCode))
        else
            local prefix = self.ui:getChildByName("idLabelPrefix")
            prefix:setString(Localization:getInstance():getText("setting.panel.intro.1"))

            local text = self.ui:getChildByName("idLabelNum")
            local newTxt = LabelBMMonospaceFont:create(36, 36, 19, "fnt/target_amount.fnt")
            newTxt:setAnchorPoint(ccp(0.5, 0.5))
            newTxt:setString(tostring(inviteCode))
            newTxt.name = "idLabelNum"

            prefix:setDimensions(CCSizeMake(0,0))
            newTxt:setPositionX(text:getPositionX() + newTxt:getContentSize().width/2)
            newTxt:setPositionY(prefix:boundingBox():getMidY() - 2)

            self.ui:addChildAt(newTxt, self.ui:getChildIndex(text))
            text:removeFromParentAndCleanup(true)

            if PlatformConfig:isAuthConfig(PlatformAuthEnum.kGuest) then
                for k,v in pairs({ prefix,newTxt,self.codeBtn }) do
                    v:setPositionY(v:getPositionY() - 28)
                end
            end
        end
    else
        self.ui:getChildByName("idLabelPrefix"):setVisible(false)
    end


    -------------------
    -- Add Event Listener
    -- ----------------
    if self.headImageModifiable then
        local function onAvatarTouch()
            stopSchedule()
            self:onAvatarTouch()
        end
        self.avatar:setTouchEnabled(true)
        self.avatar:setButtonMode(true)
        self.avatar:addEventListener(DisplayEvents.kTouchTap, onAvatarTouch)
    end


    local function onCloseBtnTapped(event)
        stopSchedule()
        self:onCloseBtnTapped(event)
    end
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

    local function onTimeOut()
        stopSchedule()
        if self.isDisposed then return end
        local text = self.ui:getChildByName("idLabelNum")
        if not text or text.isDisposed then return end
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.1, 1.35))
        arr:addObject(CCScaleTo:create(0.1, 0.85))
        arr:addObject(CCScaleTo:create(0.1, 1.1))
        arr:addObject(CCScaleTo:create(0.1, 1))
        text:runAction(CCSequence:create(arr))
    end
    schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeOut, 5, false)
end

function AccountPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)
end

function AccountPanel:onAvatarTouch()
    if self.moreAvatars:isVisible() then 
        self.moreAvatars:setVisible(false)
        if self.input then self.input:setPosition(ccp(self.input.originalX_, self.input.originalY_)) end
    else 
        self.moreAvatars:setVisible(true)  
        if self.input then self.input:setPosition(ccp(9999,9999)) end
    end
end

if __ANDROID then
require "hecore.gsp.GspProxy"
end

function AccountPanel:onCloseBtnTapped(event, ...)
    BindPhoneGuideLogic:get():removeGuide()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
end

function AccountPanel:onEnterAnimationFinished()
    if self.nickNameModifiable then
        if self.nameLabel and not self.nameLabel.isDisposed then
            local label = self.nameLabel:getChildByName("label")
            if label and not label.isDisposed then
                label:removeFromParentAndCleanup(true)
            end
        end
    end
    if self.input then self.input:setPosition(ccp(self.input.originalX_, self.input.originalY_)) end
    if self.accountBtn then
        BindPhoneGuideLogic:get():onShowAccountPanel(self.accountBtn)
    end
end

function AccountPanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
    end
end

function AccountPanel:createShowAnim()
    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()
        local initPosX  = centerPosX
        local initPosY  = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)
    local moveToCenter      = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut           = CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter  = CCTargetedAction:create(self.refCocosObj, backOut)

    local function onEnterAnimationFinished( )self:onEnterAnimationFinished() end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function AccountPanel:playShowHideLabelAnim(labelToControl, ...)

    local delayTime = 3

    labelToControl:stopAllActions()

    local function showFunc()
        -- Hide All Tip
        for k,v in pairs(self.tips) do
            v:setVisible(false)
        end

        labelToControl:setVisible(true)
    end
    local showAction = CCCallFunc:create(showFunc)


    local delay = CCDelayTime:create(delayTime)


    local function hideFunc()
        labelToControl:setVisible(false)
    end
    local hideAction = CCCallFunc:create(hideFunc)

    local actionArray = CCArray:create()
    actionArray:addObject(showAction)
    actionArray:addObject(delay)
    actionArray:addObject(hideAction)

    local seq = CCSequence:create(actionArray)
    --return seq
    
    labelToControl:runAction(seq)
end

function AccountPanel:updateUserProfile()
    local profile = UserManager.getInstance().profile
    local http = UpdateProfileHttp.new()

    if _G.sns_token then 
        local authorizeType = SnsProxy:getAuthorizeType()
        local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
        local snsName = profile:getSnsUsername(authorizeType)

        profile:setSnsInfo(authorizeType,snsName,profile:getDisplayName(),profile.headUrl)

        http:load(profile.name, profile.headUrl,snsPlatform,HeDisplayUtil:urlEncode(snsName))
    else
        http:load(profile.name, profile.headUrl)
    end
end

function AccountPanel:updateSnsUserProfile( authorizeType,snsName,name,headUrl )
    local profile = UserManager.getInstance().profile
    local http = UpdateProfileHttp.new()

    profile:setSnsInfo(authorizeType,snsName,name,headUrl)

    local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
    snsName = HeDisplayUtil:urlEncode(snsName)
    if name then
        name = HeDisplayUtil:urlEncode(name)
    end

    http:load(name, headUrl,snsPlatform,snsName)
end

function AccountPanel:onCodeBtnTapped()
    if not RequireNetworkAlert:popout() then 
        --- 玩家未联网首次登入游戏，点击"二维码"提示玩家"请联网后重进游戏，以获取您的消消乐二维码哟~"3秒后tip消失。
        if not CCUserDefault:sharedUserDefault():getBoolForKey("account.panel.on.qrcode.tapped") then
            CommonTip:showTip('请联网后重进游戏，以获取您的消消乐二维码哟~', 'positive', nil, 3)
            CCUserDefault:sharedUserDefault():setBoolForKey("account.panel.on.qrcode.tapped", true)
        end
        return 
    end
    DcUtil:UserTrack({ category='setting', sub_category="setting_click", action = 'qrcode'})
    self:onCloseBtnTapped()
    local function onClose()
        AccountPanel:create():popout()
    end
    QRCodePostPanel:create():popout(onClose)
end

function AccountPanel:onAccountBtnTapped()
    self:onCloseBtnTapped()
    local panel = AccountSettingPanel:create()
    panel:popout()
    
    DcUtil:UserTrack({ category='setting', sub_category="setting_click_my_account"})

    if __WIN32 then return end
    if self:hasAccountBinded() then return end

    local authConfig = PlatformConfig.authConfig
    if _G.isLocalDevelopMode then printx(0, 'xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX') end
    if _G.isLocalDevelopMode then printx(0, table.tostring(authConfig)) end
    local singleAuth
    if type(authConfig) == 'table' and #authConfig == 1 and authConfig[1] ~= PlatformAuthEnum.kGuest
    then
        singleAuth = authConfig[1]
    elseif type(authConfig) ~= 'table' and authConfig ~= PlatformAuthEnum.kGuest then
        singleAuth = authConfig
    end
    if singleAuth then
        if singleAuth == PlatformAuthEnum.kPhone then
            panel:bindNewPhone()
        else
            panel:bindNewSns(singleAuth)
        end
    end
end

function AccountPanel:shouldShowAccountBtn()
    -- if __WIN32 then return true end
    if PlatformConfig.authConfig == PlatformAuthEnum.kGuest then
        return false
    end
    return true
end

function AccountPanel:hasAccountBinded()
    -- if __WIN32 then return true end
    return UserManager.getInstance().profile:isPhoneBound() or UserManager.getInstance().profile:isSNSBound()
end
