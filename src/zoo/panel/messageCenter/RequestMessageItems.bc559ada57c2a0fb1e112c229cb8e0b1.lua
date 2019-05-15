require 'zoo.util.CloverUtil'
local function jsmaLog( ... )
    if _G.isLocalDevelopMode  then printx(103 ,...) end
end 
RequestMessageItemBase = class(ItemInClippingNode)
UnlockCloudRequestItem = class(RequestMessageItemBase)
FriendRequestItem = class(RequestMessageItemBase)
FriendWithEnergyItem = class(RequestMessageItemBase)
EnergyRequestItem = class(RequestMessageItemBase)
UpdateNewVersionItem = class(RequestMessageItemBase)
ActivityRequestItem = class(RequestMessageItemBase)
FriendRequestItemClover = class(RequestMessageItemBase)
RequestMessageGiftItem = class(RequestMessageItemBase)
FLGInboxItem = class(RequestMessageItemBase)
StartLevelMessageItemBase = class(RequestMessageItemBase)
NewVersionRewardItem = class(RequestMessageItemBase)

LevelSurpassMessageItem = class(StartLevelMessageItemBase)
PassLastLevelOfLevelAreaMessageItem = class(StartLevelMessageItemBase)
ScoreSurpassMessageItem = class(StartLevelMessageItemBase)
PassMaxNormalLevelMessageItem = class(RequestMessageItemBase)
WeeklyMessageItem = class(StartLevelMessageItemBase)
PushEnergyItem = class(RequestMessageItemBase)
DengchaoEnergyItem = class(PushEnergyItem)

ThanksMessageItem = class(RequestMessageItemBase)
OneThanksMessageItem = class(RequestMessageItemBase)
ThanksForYourFullGiftMessageItem = class(RequestMessageItemBase)
MergedRequestMessageItemBase = class(RequestMessageItemBase)
MergedThanksForYourFullGiftMessageItem = class(MergedRequestMessageItemBase)

PushBindingItem = class(RequestMessageItemBase)

LevelSurpassNationMessageItem = class(LevelSurpassMessageItem)
ScoreSurpassNationMessageItem = class(ScoreSurpassMessageItem)
WeeklySurpassNationMessageItem = class(WeeklyMessageItem)

PushActivityMessageItem = class(RequestMessageItemBase)
AskForHelpItem = class(RequestMessageItemBase)
AskForHelpTopItem = class(RequestMessageItemBase)
AskForHelpSuccessItem = class(RequestMessageItemBase)
ActRecallRemindItem = class(RequestMessageItemBase)

MessageOriginTypeClass = {
    [RequestType.kNeedUpdate]               = RequestMessageItemBase,
    [RequestType.kReceiveFreeGift]          = EnergyRequestItem,
    [RequestType.kSendFreeGift]             = EnergyRequestItem,
    [RequestType.kUnlockLevelArea]          = UnlockCloudRequestItem,
    [RequestType.kAddFriend]                = FriendRequestItem,
    [RequestType.kFriendWithEnergy]         = FriendWithEnergyItem,
    [RequestType.kActivity]                 = ActivityRequestItem,
    [RequestType.kLevelSurpass]             = LevelSurpassMessageItem,
    [RequestType.kLevelSurpassLimited]      = LevelSurpassMessageItem,
    [RequestType.kPassLastLevelOfLevelArea] = PassLastLevelOfLevelAreaMessageItem,
    [RequestType.kScoreSurpass]             = ScoreSurpassMessageItem,
    [RequestType.kPassMaxNormalLevel]       = PassMaxNormalLevelMessageItem,
    [RequestType.kThanks]                   = ThanksMessageItem,
    [RequestType.kPushEnergy]               = PushEnergyItem,
    [RequestType.kDengchaoEnergy]           = DengchaoEnergyItem,
    [RequestType.kWeeklyRace]               = WeeklyMessageItem,
    [RequestType.kClover_AddFriend]         = FriendRequestItemClover, -- TODO
    [RequestType.kLevelSurpassNation]       = LevelSurpassNationMessageItem,
    [RequestType.kScoreSurpassNation]       = ScoreSurpassNationMessageItem,
    [RequestType.kWeeklySurpassNation]      = WeeklySurpassNationMessageItem,
    [RequestType.kPushActivity]             = PushActivityMessageItem,
    [RequestType.kAskForHelpSuccess]        = AskForHelpSuccessItem,
    [RequestType.kAskForHelp]               = AskForHelpItem,  
    [RequestType.kActRecallRemind]          = ActRecallRemindItem,  
    [RequestType.kFCGift]                   = RequestMessageGiftItem,  
    [RequestType.kThanksForYourFullGift]    = ThanksForYourFullGiftMessageItem,
    [RequestType.KFLGInbox]                 = FLGInboxItem,  
    [RequestType.kMergedThanksForYourFullGift]    = MergedThanksForYourFullGiftMessageItem,
    [RequestType.kNewVersionRewardItem]     = NewVersionRewardItem,  
}


function RequestMessageItemBase:loadRequiredResource(panelConfigFile)
    self.panelConfigFile = panelConfigFile
    self.builder = InterfaceBuilder:create(panelConfigFile)
end

function RequestMessageItemBase:buildUi()
    return self.builder:buildGroup("friends_message_item")
end

-- call in subclasses
function RequestMessageItemBase:init()
    self._isInRequest = false
    self._hasCompleted = false

    local ui = self:buildUi()
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui
    self.avatar_ico = ui:getChildByName("avatar_ico")
    self.name_text = ui:getChildByName("name_text")
    self.msg_text = ui:getChildByName("msg_text")
    self.avatar_ico:setOpacity(0)

    self.cancel = ui:getChildByName("cancel")
    self.cancel:setButtonMode(true)
    self.cancel:setTouchEnabled(true)
    self.cancel.setEnabled = self.cancel.setTouchEnabled
    self.confirm = GroupButtonBase:create(ui:getChildByName("confirm_button"))
    self.confirm:setColorMode(kGroupButtonColorMode.green)

    self.selected = ui:getChildByName("selected")
    self.selected:setVisible(false)

    self.ignoredTxt = ui:getChildByName('ignoredTxt')
    self.ignoredTxt:setString(Localization:getInstance():getText('message.center.disagree.already.text'))
    self.ignoredTxt:setVisible(false)

    self.descTxt = ui:getChildByName('descTxt')
    self.descTxt:setVisible(false)

    self.itemPh = self.ui:getChildByName("itemPh")
    self.itemPhPos  = self.itemPh:getPosition()
    self.itemPhSize = self.itemPh:getGroupBounds().size
    self.itemPhSize = {width = self.itemPhSize.width, height = self.itemPhSize.height}
    self.itemPh:setVisible(false)

    self.numberLabel = self.ui:getChildByName("numberLabel")
    -- self:addChild(ui)
    local size = self.ui:getGroupBounds().size
    self:setHeight(size.height) 
    self:buildSyncAnimation()

    local function onTouchCancel(event) self:sendIgnore(false) end
    local function onTouchConfirm(event) if self.panel then self.panel:setFocusedItem(self) end self:sendAccept(false) end
    self.cancel:ad(DisplayEvents.kTouchTap, onTouchCancel)
    self.confirm:ad(DisplayEvents.kTouchTap, onTouchConfirm)

    self.ui:getChildByName('ph'):setVisible(false)
    self.ui:getChildByName('ph2'):setVisible(false)
end

function RequestMessageItemBase:setPageIndex(index)
    self.pageIndex = index
end

function RequestMessageItemBase:setParentLayout( layout )
    self.parentLayout = layout
end

function RequestMessageItemBase:showDescText(text, showTime, fadeOutTime)
    showTime = showTime or 3
    fadeOutTime = fadeOutTime or 0.1
    if self.descTxt then
        self.descTxt:setVisible(true)
        self.descTxt:stopAllActions()
        self.descTxt:setOpacity(255)
        self.descTxt:setString(text)
        self.descTxt:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(showTime), CCFadeOut:create(fadeOutTime)))
    end
end

function RequestMessageItemBase:fadeOut(fadeOutTime, onFinish)
    local childrenList = self.ui:getChildrenList()
    for i, v in ipairs(childrenList) do
        local fadeOut = CCFadeOut:create(fadeOutTime)
        v:setCascadeOpacityEnabled(true)
        v:runAction(fadeOut)
    end

    if self.avatar_ico then
        local imgLoader = self.avatar_ico:getChildByName('headImg')
        if imgLoader and imgLoader.headSprite and imgLoader.headSprite.refCocosObj then
            imgLoader.headSprite:runAction(CCFadeOut:create(fadeOutTime))
        end
    end

    if type(onFinish) == "function" then
        self.ui:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(fadeOutTime),
            CCCallFunc:create(function(...) onFinish(self) end)
            )
        )
    end
end

function RequestMessageItemBase:onRemoveItem(isBatch)

    if self.isDisposed then  return end


    function onMsgLifeFinished( ... )
        if self.panel then 
            self.panel:onMessageLifeFinished(self.pageIndex) 
        end
    end

    local fadeOutTime = 0.3
    if isBatch then
        if not self:isVisible() then
            onMsgLifeFinished()
            self.parentLayout:removeItemAt(self.arrayIndex)
        else
            self.ui:runAction(CCSequence:createWithTwoActions(
                CCDelayTime:create(0.15 * self.arrayIndex),
                CCCallFunc:create(function(...)
                    self:fadeOut(fadeOutTime, onMsgLifeFinished)
                    self.parentLayout:removeItemAt(self.arrayIndex, true)
                end)
                )
            )
        end
    else
        self.ui:runAction(CCSequence:createWithTwoActions(
            CCDelayTime:create(0.2),
            CCCallFunc:create(function(...)
                self:fadeOut(fadeOutTime, onMsgLifeFinished)
                self.parentLayout:removeItemAt(self.arrayIndex, true)
            end)
        ))
    end
end

function RequestMessageItemBase:canAcceptAll()
    return true
end

function RequestMessageItemBase:canIgnoreAll()
    return true
end

function RequestMessageItemBase:setPanelRef(ref)
    self.panel = ref
end
function RequestMessageItemBase:onRequestSent(isBatch)
    self.processing = true
    if self.panel then self.panel:onRequestSent(isBatch) end
end
function RequestMessageItemBase:onMessageLifeFinished(isBatch)
    if self.parentLayout and self.arrayIndex then
        self:onRemoveItem(isBatch)
    end
end
function RequestMessageItemBase:onRequestCompleted(isBatch)
    self.processing = nil
    if self.panel then self.panel:onRequestCompleted(isBatch) end
end
function RequestMessageItemBase:sendAccept(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        FreegiftManager:sharedInstance():removeMessageById(self.id) 
        self:onSendAcceptSuccess(event, isBatch)
    end
    local function _onFail(event) self:onSendAcceptFail(event, isBatch) end
    self:showSyncAnimation(true)
    self:showButtons(false)
    if not triggerByPanel then
        local action = 1
        local http = RespRequest.new()
        http:addEventListener(Events.kComplete, _onSuccess)
        http:addEventListener(Events.kError, _onFail)
        http:load(self.requestInfo.id, action)
    end
    self:onRequestSent(isBatch)
end
function RequestMessageItemBase:sendIgnore(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        FreegiftManager:sharedInstance():removeMessageById(self.id)
        self:onSendIgnoreSuccess(event, isBatch)
    end
    local function _onFail(event) self:onSendIgnoreFail(event, isBatch) end
    self:showSyncAnimation(true)
    self:showButtons(false)
    if not triggerByPanel then
        local action = 2
        local http = RespRequest.new()
        http:addEventListener(Events.kComplete, _onSuccess)
        http:addEventListener(Events.kError, _onFail)
        http:load(self.requestInfo.id, action)
    end
    self:onRequestSent(isBatch)
end
function RequestMessageItemBase:onSendAcceptSuccess(event, isBatch, triggerByPanel)
    if not triggerByPanel then
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
    end

    if self.isDisposed then return end
    self._isInRequest = false
    self._hasCompleted = true
    self:showSyncAnimation(false)
    self:showButtons(false)
    if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end -- show selected
    self:runAction(CCCallFunc:create(function( ... )
        if self.isDisposed then return end
        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)
    end))
end
function RequestMessageItemBase:onSendAcceptFail(event, isBatch)
    if self.isDisposed then return end
    self._isInRequest = false
    self:showSyncAnimation(false)
    self:showButtons(true)
    if event then 
        RequestMessageItemBase:alert(event.data)
    end
    self:onRequestCompleted(isBatch)
end
function RequestMessageItemBase:onSendIgnoreSuccess(event, isBatch, triggerByPanel)
    if not triggerByPanel then
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
    end
    
    if self.isDisposed then return end
    self._isInRequest = false
    self._hasCompleted = true
    self:showSyncAnimation(false)
    self:showButtons(false)
    if self.ignoredTxt ~= nil then
        self.ignoredTxt:setVisible(true) -- show ignore text
    end
    self:runAction(CCCallFunc:create(function( ... )
        if self.isDisposed then return end
        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)
    end))
   
end
function RequestMessageItemBase:onSendIgnoreFail(event, isBatch)
    if self.isDisposed then return end
    self._isInRequest = false
    self:showSyncAnimation(false)
    self:showButtons(true)
    if event then 
        RequestMessageItemBase:alert(event.data)
    end
    self:onRequestCompleted(isBatch)
end
function RequestMessageItemBase:buildSyncAnimation()
    if self.isDisposed then return end
    local winSize = CCDirector:sharedDirector():getWinSize()
    local container = Sprite:createEmpty()
    local back = Sprite:createWithSpriteFrameName("loading_ico_circle instance 10000")  
    local icon = Sprite:createWithSpriteFrameName("loading_ico_turn instance 10000")

    container:setCascadeOpacityEnabled(true)
    back:setCascadeOpacityEnabled(true)
    icon:setCascadeOpacityEnabled(true)

    container:setOpacity(0)
    container:addChild(back)
    container:addChild(icon)
    container:setPosition(ccp(winSize.width - 100, -100))
    container:setVisible(false)
    self.container = container
    self.icon = icon
    self:addChild(container)
end
function RequestMessageItemBase:showSyncAnimation(show)
    if self.isDisposed then return end
    local container = self.container
    local icon = self.icon
    if container.isDisposed or icon.isDisposed then return end
    container:setVisible(show)
    if show then
        container:runAction(CCFadeIn:create(0.2))
        icon:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 180)))
    else
        container:stopAllActions()
        icon:stopAllActions()
    end
end
function RequestMessageItemBase:showButtons(show)
    if self.isDisposed then return end
    self.confirm:setVisible(show)
    self.confirm:setEnabled(show)
    self.cancel:setVisible(show)
    self.cancel:setEnabled(show)
end
function RequestMessageItemBase:enableAcceptButton(enable)
    if self.isDisposed then return end
    if enable ~= true and enable ~= false then enable = false end
    self.enabled = enable
    self.confirm:setEnabled(enable)
end
local _isAlert = false
function RequestMessageItemBase:alert(err_code)
    local message
    if not tonumber(err_code) then 
        message = Localization:getInstance():getText("message.center.message.request.error") 
    else
        message = Localization:getInstance():getText("error.tip."..err_code)
    end
    local scene = Director:sharedDirector():getRunningScene()
    local function resetAlertFlag() _isAlert = false end
    if not _isAlert and scene then 
        _isAlert = true
        CommonTip:showTip(message, 'negative', nil, 2)
        setTimeOut(resetAlertFlag, 2)
    end
end
function RequestMessageItemBase:isInRequest()
    return self._isInRequest == true
end
function RequestMessageItemBase:hasCompleted()
    return self._hasCompleted == true
end
function RequestMessageItemBase:gainFocus()
end
function RequestMessageItemBase:looseFocus()
end
function RequestMessageItemBase:updateSelf()
end
function RequestMessageItemBase:dispose()
    CocosObject.dispose(self)
end
function RequestMessageItemBase:setData( requestInfo )
    self.requestInfo = requestInfo
    self.id = requestInfo.id
    self.type = requestInfo.type
    self.originType = requestInfo.originType
    local userName = requestInfo.name or ''
    local headUrl = requestInfo.headUrl
    local senderId = tonumber(requestInfo.senderUid)
    local friendRef = FriendManager.getInstance().friends[tostring(senderId)]
    if friendRef then
        if friendRef.name and friendRef.name ~= "" then userName = friendRef.name end
        if friendRef.headUrl and friendRef.headUrl ~= "" then headUrl = friendRef.headUrl end
    end
    if userName == nil or userName == "" then userName = "ID:"..tostring(senderId) end

    -- if headUrl then
    local framePos = self.avatar_ico:getPosition()
    local frameSize = self.avatar_ico:getContentSize()
    
    local head = HeadImageLoader:createWithFrame(requestInfo.senderUid, headUrl, nil, nil, friendRef or requestInfo.profile)
    local scale = frameSize.width/100
    head.name = "headImg"
    head:setScale(scale * 0.84)
    head:setPosition(ccp(frameSize.width/2-3, frameSize.height/2+2))
    self.avatar_ico:addChild(head)

    self.name_text:setString(nameDecode(userName))
    self.confirm:setString(Localization:getInstance():getText("message.center.agree.btn"))
    -- self.cancel:setString(Localization:getInstance():getText("message.center.disagree.btn"))
end

--------------------------------------
function UnlockCloudRequestItem:setData(requestInfo)
    -- call super
    RequestMessageItemBase.setData(self, requestInfo)

    self.requestInfo = requestInfo
    local level = (requestInfo.itemId - 40001) * 15

    self.msg_text:setString(Localization:getInstance():getText("message.center.text.unlock.area", {level = level}))
    self.confirm:setString(Localization:getInstance():getText("message.center.agree.btn.unlock"))
end

function FriendRequestItem:buildUi()
    return self.builder:buildGroup("friends_message_item_3")
end

function FriendRequestItem:init( ... )
    RequestMessageItemBase.init(self, ...)

    self.levelLabel = self.ui:getChildByPath('detailInfo/level')
    self.levelLabel:setScale(0.9)
    local color = ccc3(103, 59, 9)
    self.levelLabel:setColor(color)
    self.levelLabel:setAnchorPoint(ccp(0.5, 0.5))
    local pos = self.levelLabel:getPosition()
    self.levelLabel:setPosition(ccp(pos.x + 59, pos.y - 19))

    self.labelStar = self.ui:getChildByPath("detailInfo/starNum")
    self.labelStar:setAnchorPoint(ccp(0.5, 1))
    local xPos = self.labelStar:getPositionX()
    self.labelStar:setPositionX(xPos + 36)
    self.labelStar:setColor(color)

    self.rankDesc = self.ui:getChildByPath('detailInfo/rankDesc')
    self.personalInfo = self.ui:getChildByPath('detailInfo/personalInfo')
end

--------------------------------------
function FriendRequestItem:setData(requestInfo)
    -- call super
    RequestMessageItemBase.setData(self, requestInfo)

    self.requestInfo = requestInfo or {}

    local achievement = self.requestInfo.achievement or {}

    local user = self.requestInfo.user or {}

    local levelId = user.topLevelId or 1
    local star = (tonumber(user.star or 0) or 0) + (tonumber(user.hideStar or 0) or 0)

    local starGlobalRank = achievement.starGlobalRank or 0
    local pctRank = achievement.pctOfRank or 0

    if starGlobalRank and starGlobalRank == 1 then
        pctRank = 10000
    end

    if pctRank >= 10000 then
        pctRank = 9999
    end

    local rawProfile = self.requestInfo.profile or {}

    local profileRef = ProfileRef.new()
    profileRef:fromLua(rawProfile)

    local birth = profileRef.birthDate
    local age = profileRef.age
    local cons = profileRef.constellation
    local sex = profileRef.gender
    local ageText = ''
    local genderText = ''
    local constellationText = ''
    if tonumber(age) >= 100 then
        age = "99+"
    end
    ageText = age .."岁".." "

    if age == 0 and ((not birth) or (birth == '')) then
        ageText = ''
    end

    local genderTextGroup = {'', localize('my.card.edit.panel.content.male'), localize('my.card.edit.panel.content.female')}
    genderText = genderTextGroup[sex + 1]..' '

    if cons > 0 then
        constellationText = localize('my.card.edit.panel.content.constellation'..cons)
    end

    local address = nameDecode(profileRef.location)
    address = string.gsub(address, '#', ' ')

    local labelACGText = genderText .. ageText .. constellationText .. ' ' .. address
    if string.gsub(labelACGText, ' ', '') == '' or profileRef.secret == true then
        labelACGText = "暂无个人信息"
    end   

    self.levelLabel:setText(Localization:getInstance():getText('level.number.label.txt', {level_number = levelId}))
    self.labelStar:setText(tostring(star))

    local n = string.format("%.2f%%", (10000-pctRank) / 100)
    self.rankDesc:setString(string.format('总星级全国前%s', n))
    labelACGText = TextUtil:ensureTextWidth(labelACGText, self.personalInfo:getFontSize(), self.personalInfo:getDimensions() )
    self.personalInfo:setString(labelACGText)


    local userName = TextUtil:ensureTextWidth(nameDecode(requestInfo.name or '消消乐玩家'), self.name_text:getFontSize(), self.name_text:getDimensions() )
    self.name_text:setString(userName)

end

function FriendRequestItem:sendIgnore(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    
    DcUtil:UserTrack({
                        category='message',
                        sub_category='message_center_add_friend',
                        t1 = 0,
                        t2 = self.requestInfo.type,--itemId好友来源
                    })
    -- RequestMessageItemBase.sendAccept(self, isBatch, triggerByPanel )
    RequestMessageItemBase.sendIgnore(self, isBatch, triggerByPanel )


end

function FriendRequestItem:sendAccept(isBatch)
    local isFull,noZombie = FriendsFullPanel:checkFullZombieShow()
    if isFull then
        if noZombie then
            createFriendRankingPanel()
        end
        return
    else
        DcUtil:UserTrack({
                        category='message',
                        sub_category='message_center_add_friend',
                        t1 = 1,
                        t2 = self.requestInfo.type,--itemId好友来源
                    })
        RequestMessageItemBase.sendAccept(self, isBatch)
    end
end


function FriendWithEnergyItem:buildUi()
    return self.builder:buildGroup("friends_message_item_4")
end

--------------------------------------
function FriendWithEnergyItem:setData(requestInfo)
    -- call super
    RequestMessageItemBase.setData(self, requestInfo)

    self.requestInfo = requestInfo

    local key = "add.friend.grant"      --原本根据好友来源 显示不同文案 这种情况已经是好友了 直接写死

    self.msg_text:setString(localize(key, {n = '\n'}))
    self.confirm:setString(localize("add.friend.grant.energy"))
end
function FriendWithEnergyItem:sendAccept(isBatch)
    RequestMessageItemBase.sendAccept(self, isBatch)
end
--------------------------------------
function FriendRequestItemClover:setData(requestInfo)
    -- call super
    RequestMessageItemBase.setData(self, requestInfo)
    self.requestInfo = requestInfo
    self.msg_text:setString(Localization:getInstance():getText("xx2.invite.text"))
end
function FriendRequestItemClover:sendIgnore(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        FreegiftManager:sharedInstance():removeMessageById(self.id)
        self:onSendIgnoreSuccess(event, isBatch)
    end
    local function _onFail(event) self:onSendIgnoreFail(event, isBatch) end
    self:showSyncAnimation(true)
    self:showButtons(false)

    if not triggerByPanel then
        local action = 2
        local http = RespRequest.new()
        http:addEventListener(Events.kComplete, _onSuccess)
        http:addEventListener(Events.kError, _onFail)
        http:load(self.requestInfo.id, action)
    end
    self:onRequestSent(isBatch)
    if not isBatch then
        DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 1})
    end
end
function FriendRequestItemClover:sendAccept(isBatch, acceptCallback)
    -- RequestMessageItemBase.sendAccept(self, isBatch)
    if self:isInRequest() then return false end
    if self:hasCompleted() then return false end
    local function _onSuccess(event)
        FreegiftManager:sharedInstance():removeMessageById(self.id) 
        self:onSendAcceptSuccess(event, isBatch)
        if isBatch and acceptCallback then acceptCallback(true, self.requestInfo) end
    end
    local function _onFail(event) 
        self:onSendAcceptFail(event, isBatch) 
        if isBatch and acceptCallback then acceptCallback(false) end
    end
    self:showSyncAnimation(true)
    self:showButtons(false)
    local action = 1
    local http = RespRequest.new()
    http:addEventListener(Events.kComplete, _onSuccess)
    http:addEventListener(Events.kError, _onFail)
    http:load(self.requestInfo.id, action)
    self:onRequestSent(isBatch)
    if not isBatch then
        DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 2})
    end
    return true
end
function FriendRequestItemClover:onRequestCompleted(isBatch)
    RequestMessageItemBase.onRequestCompleted(self, isBatch)
    local msgNum = FreegiftManager:sharedInstance():getMessageNumByType(RequestType.kClover_AddFriend)
    GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kCloverAddFriendRequest, {num=msgNum}))
end
function FriendRequestItemClover:onSendAcceptSuccess(event, isBatch)
    RequestMessageItemBase.onSendAcceptSuccess(self, event, isBatch)
    -- try open clover
    if not isBatch then
        if CloverUtil:isAppInstall() then
            CloverUtil:openApp("accept_invite")
            DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 2, t2 = 1})
        else
            local pfName = StartupConfig:getInstance():getPlatformName()
            CloverUtil:downloadApk({platform=pfName,source=self.requestInfo.extra})
            DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = 2, t2 = 2})
        end
    else
        DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = (isBatch and 3 or 2)})
    end
end
function FriendRequestItemClover:buildUi()
    return self.builder:buildGroup("friends_message_item")
end
function FriendRequestItemClover:onSendIgnoreSuccess(event, isBatch)
    RequestMessageItemBase.onSendIgnoreSuccess(self, event, isBatch)
    DcUtil:UserTrack({category = "link_to_xx2", sub_category = "xx2_jump", t1 = (isBatch and 4 or 1)})
end
-- override super
function EnergyRequestItem:setData(requestInfo)
    -- call super
    RequestMessageItemBase.setData(self, requestInfo)

    self.requestInfo = requestInfo

    if requestInfo.type == 1 then -- send gift
        self:setToReceiveMode()
    elseif requestInfo.type == 2 then -- request for gift
        self:setToAcceptMode()
    end

end
-- override super
function EnergyRequestItem:sendIgnore(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        self:onSendIgnoreSuccess(event, isBatch)
    end
    local function _onFail(event) self:onSendIgnoreFail(event) end
    self:showSyncAnimation(true)
    self:showButtons(false)
    if not triggerByPanel then
        local mgr = FreegiftManager:sharedInstance()
        mgr:ignoreFreegift(self.requestInfo.id, _onSuccess, _onFail)
    end
    self:onRequestSent(isBatch)
end
-- override super
function EnergyRequestItem:sendAccept(isBatch)

    -- jsmaLog(" EnergyRequestItem:sendAccept isBatch = " , isBatch )
    jsmaLog(" EnergyRequestItem:sendAccept 11  self.mode = " , self.mode )
    if self:isInRequest() then return end
    jsmaLog(" EnergyRequestItem:sendAccept 22  self.mode = " , self.mode )
    if self:hasCompleted() then return end
    --   5: EnergyRequestItemMode = {kAcceptRequest = 1, kReceive = 2, kSendBack = 3}
    jsmaLog(" EnergyRequestItem:sendAccept 33  self.mode = " , self.mode )
    
    if self.mode == EnergyRequestItemMode.kAcceptRequest then
        self:confirmForAcceptRequest(isBatch)
    elseif self.mode == EnergyRequestItemMode.kSendBack then
        self:confirmForSendBack(isBatch)
    elseif self.mode == EnergyRequestItemMode.kReceive then
        self:confirmForReceive(isBatch)
    end
end

function EnergyRequestItem:isSend()
    return self.mode == EnergyRequestItemMode.kAcceptRequest or self.mode == EnergyRequestItemMode.kSendBack
end

function EnergyRequestItem:isReceive()
    return self.mode == EnergyRequestItemMode.kReceive
end

function EnergyRequestItem:confirmForAcceptRequest(isBatch)
    local function _onSuccess(event)
        self:onSendAcceptSuccess(event, isBatch)
        DcUtil:energyGive(self.requestInfo.senderUid,self.requestInfo.itemId)
    end
    local function _onFail(event) 
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount - 1
        end
        self:onSendAcceptFail(event, isBatch) 
    end

    if self:canSendMore() then -- confirm
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount + 1
        end
        self._isInRequest = true
        self:showSyncAnimation(true)
        self:showButtons(false)
        local mgr = FreegiftManager:sharedInstance()
        mgr:sendGift(self.requestInfo.id, _onSuccess, _onFail, isBatch)
        self:onRequestSent(isBatch)
    end
end

function EnergyRequestItem:confirmForReceive( isBatch )
    local function _onSuccess(event)
        --刷新上次收到精力瓶的时间
        FriendRecommendManager.getInstance():setReceiveFreeGiftTime(Localhost:time())

        self:onSendAcceptSuccess(event, isBatch)
        DcUtil:energy_receive(self.requestInfo.senderUid,self.requestInfo.itemId)
    end
    local function _onFail(event) 
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount - 1
        end
        self:onSendAcceptFail(event, isBatch)
    end

    if self:canReceiveMore() then -- confirm
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount + 1
        end
        self._isInRequest = true
        self:showSyncAnimation(true)
        self:showButtons(false)
        local mgr = FreegiftManager:sharedInstance()
        mgr:acceptFreegift(self.requestInfo.id, _onSuccess, _onFail)
        self:onRequestSent(isBatch)
    end
end

function EnergyRequestItem:confirmForSendBack( isBatch )
    local function _onSuccess(event)
        self:onSendAcceptSuccess(event, isBatch)
        DcUtil:energySendBack(self.requestInfo.senderUid,self.requestInfo.itemId)
    end
    local function _onFail(event) 
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount - 1
        end
        self:onSendAcceptFail(event, isBatch) 
    end

    if self:canSendMore() and self:canSendBackToReceiver() then -- confirm
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount + 1
        end
        local mgr = FreegiftManager:sharedInstance()
        self._isInRequest = true
        self:showSyncAnimation(true)
        self:showButtons(false)
        mgr:sendBackGift(self.requestInfo.id, _onSuccess, _onFail)
        self:onRequestSent(isBatch)
    end
end

function EnergyRequestItem:setToAcceptMode()
    if self.isDisposed then return end

    self.mode = EnergyRequestItemMode.kAcceptRequest
    self.msg_text:setString(Localization:getInstance():getText('message.center.message.requesting.energy'))
    
    self.confirm:setString(Localization:getInstance():getText('message.center.agree.btn'))
    if self:canSendMore() then 
        self.enabled = true
        self.confirm:setEnabled(true)
    else 
        self.enabled = false
        self.confirm:setEnabled(false)
        self.confirm:setString(Localization:getInstance():getText('message.center.panel.btn.sendtomorrow'))
    end
end

function EnergyRequestItem:setToSendBackMode()
    if self.isDisposed then return end
    
    self.mode = EnergyRequestItemMode.kSendBack
    self.msg_text:setString(Localization:getInstance():getText('message.center.message.sendingback.energy'))
    self.confirm:setString(Localization:getInstance():getText('message.center.button.sendback'))
    if self:canSendMore() and self:canSendBackToReceiver() then 
        self.confirm:setColorMode(kGroupButtonColorMode.blue)
        self.confirm:setEnabled(true)
    else 
        self.enabled = false
        self.confirm:setEnabled(false)
        self.confirm:setString(Localization:getInstance():getText('message.center.panel.btn.sendtomorrow'))
    end
    self.cancel:setEnabled(false)
    self.cancel:setVisible(false)
end

function EnergyRequestItem:setToReceiveMode()
    if self.isDisposed then return end

    self.mode = EnergyRequestItemMode.kReceive
    self.msg_text:setString(Localization:getInstance():getText('message.center.message.receiving.energy'))

    self.confirm:setString(Localization:getInstance():getText('beginner.panel.btn.get.text'))
    if self:canReceiveMore() then 
        self.enabled = true
        self.confirm:setColorMode(kGroupButtonColorMode.green)
        self.confirm:setEnabled(true)
    else 
        self.enabled = false
        self.confirm:setEnabled(false)
        self.confirm:setString(Localization:getInstance():getText('message.center.panel.btn.receivetomorrow'))
    end
end
-- override super
function EnergyRequestItem:onSendAcceptSuccess(event, isBatch)
    if self.isDisposed then return end
    self._isInRequest = false
    self:showSyncAnimation(false)
    local txt = ''
    if self.mode == EnergyRequestItemMode.kReceive then
        -- play animation
        local pos = self.confirm:getPosition()
        local rPos = {x = pos.x - 20, y = pos.y + 40}
        local worldPos = self.ui:convertToWorldSpace(ccp(rPos.x, rPos.y))

        local reward = {itemId = 10012, num = 1}
        local anim = FlyItemsAnimation:create({reward})
        anim:setWorldPosition(ccp(worldPos.x, worldPos.y))
        anim:play()

        -- change to send back mode
        if self:canSendBackToReceiver() then 
            self:setToSendBackMode()
            self:showButtons(true)
        else
            self._hasCompleted = true
            self:showButtons(false)
            FreegiftManager:sharedInstance():removeMessageById(self.id)
            if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end
        end

        if not isBatch then
            -- local __, num = FreegiftManager:sharedInstance():canReceiveMore()
            local num = FreegiftManager:sharedInstance():getReceivedNum()
            txt = Localization:getInstance():getText('message.center.panel.ruledesc.receive', {n = num})
        end


    else
        self._hasCompleted = true
        self:showButtons(false)
        if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end -- show selected

        if not isBatch then
            -- local __, num = FreegiftManager:sharedInstance():canSendMore()
            local num = FreegiftManager:sharedInstance():getSentNum()
            txt = Localization:getInstance():getText('message.center.panel.ruledesc.send', {n = num})
        end
    end
    if not isBatch then
        self.descTxt:setString(txt)
        self.descTxt:setVisible(true)
        self.descTxt:setOpacity(255)
        self.descTxt:stopAllActions()
        self.descTxt:runAction(
            CCSequence:createWithTwoActions(
            CCDelayTime:create(2), CCFadeOut:create(0.5)
                                            )
                               )
    end


    GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
    self:onRequestCompleted(isBatch)
    if self._hasCompleted then self:onMessageLifeFinished(isBatch) end
end

function EnergyRequestItem:looseFocus()
    self._isOnFocus = false

end
function EnergyRequestItem:gainFocus()
    self._isOnFocus = true
end
function EnergyRequestItem:updateSelf()
    if self:isInRequest() then return end
    if self.mode == EnergyRequestItemMode.kAcceptRequest then
        self:setToAcceptMode()
    elseif self.mode == EnergyRequestItemMode.kSendBack then
        self:setToSendBackMode()
    elseif self.mode == EnergyRequestItemMode.kReceive then 
        self:setToReceiveMode()
    end
end
function EnergyRequestItem:canSendBackToReceiver()
    return FreegiftManager:sharedInstance():canSendBackTo(self.requestInfo.senderUid)
end
function EnergyRequestItem:canSendMore()
    return FreegiftManager:sharedInstance():canSendMore()
end
function EnergyRequestItem:canReceiveMore()
    return FreegiftManager:sharedInstance():canReceiveMore()
end


--UpdateNewVersionItem
function UpdateNewVersionItem:ctor()
    self.requestInfos = nil
end

function UpdateNewVersionItem:setRequestInfos(requestInfos)
    self.requestInfos = requestInfos
end

function UpdateNewVersionItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)

    self.msg_text:setString("")
    self.msg_text:setFontSize(26)
    self.msg_text:setDimensions(CCSizeMake(
        450,
        self.msg_text:getDimensions().height
    ))
    --
    if NewVersionUtil:hasPackageUpdate() then
        self.msg_text:setString(Localization:getInstance():getText('message.center.message.need.update'))
    else
        self.msg_text:setString(Localization:getInstance():getText('new.version.tip.message.1'))
    end

    self.cancel:setVisible(false)
    self.confirm:setVisible(false)

    self.ignoredTxt:setPositionY(-130)
end

function UpdateNewVersionItem:sendIgnore(isBatch, triggerByPanel)--更新新包
    if not triggerByPanel then
        if MessageOriginTypeClass[self.originType] then
            MessageOriginTypeClass[self.originType].sendIgnore(self, isBatch)
        else
            FreegiftManager:sharedInstance():removeMessageById(self.id)
        end
    end
end

function UpdateNewVersionItem:sendAccept(isBatch)
    -- do nothing
end

function ActivityRequestItem:init()
    RequestMessageItemBase.init(self)
    self.iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
end

function ActivityRequestItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)

    self.requestInfo = requestInfo
    local message = requestInfo.message or ""
    self.msg_text:setString(message)
    self.confirm:setString(Localization:getInstance():getText('message.center.help.btn'))
    
end

local function addReward(rewards, source)
    rewards = rewards or {}
    source = source or DcSourceType.kPushEnergy
    if #rewards > 0 then
        UserManager:getInstance():addRewards(rewards, true)
        UserService:getInstance():addRewards(rewards)
        GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kMessageCenter, rewards, source)
        if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
            else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
    end
end

function ActivityRequestItem:onSendAcceptSuccess( event , isBatch)
    if self.isDisposed then return end
    local itemsData = event.data.rewards

    self._isInRequest = false
    self._hasCompleted = true
    self:showSyncAnimation(false)
    self:showButtons(false)

    local function flyEndCallback()
        if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end -- show selected
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)
    end  

    local function showResultMessage(text, time, fadeOutTime)
        if not isBatch then
            self:showDescText(text, time, fadeOutTime)
        end
    end

    local respState = event.data.helpResult
    if respState == 1 then              --1 帮助成功并可领奖
        self:showRewardIcon(itemsData, flyEndCallback)
    elseif respState == 2 then          --2 帮助成功没有奖
        flyEndCallback()
        showResultMessage(event.data.message, 3, 0.5)
    elseif respState == 3 then          --3 帮助自己
        flyEndCallback() 
        showResultMessage(Localization:getInstance():getText(event.data.message), 3, 0.5)
        -- CommonTip:showTip(Localization:getInstance():getText(event.data.message), "negative")
    elseif respState == 4 then          --4 活动结束
        flyEndCallback() 
        showResultMessage(Localization:getInstance():getText(event.data.message), 3, 0.5)
        -- CommonTip:showTip(Localization:getInstance():getText(event.data.message), "negative")
    elseif respState == 5 then          --5 重复帮助一个人无奖励
        flyEndCallback() 
        showResultMessage(Localization:getInstance():getText(event.data.message), 3, 0.5)
        -- CommonTip:showTip(Localization:getInstance():getText(event.data.message), "negative")
    else
        flyEndCallback()
    end
end

function ActivityRequestItem:showRewardIcon(itemsData, flyEndCallback)
    if not itemsData then return end 
    local itemId = itemsData[1].itemId
    local itemNum = itemsData[1].num 
    if not itemId or not itemNum then return end

    if ItemType:isTimeProp(itemId) then itemId = ItemType:getRealIdByTimePropId(itemId) end
    local itemRes   = ResourceManager:sharedInstance():buildItemGroup(itemId)
    self.itemRes    = itemRes
    self.ui:addChild(itemRes)

    local itemResSize   = itemRes:getGroupBounds().size
    local neededScaleX  = self.itemPhSize.width / itemResSize.width
    local neededScaleY  = self.itemPhSize.height / itemResSize.height

    local smallestScale = neededScaleX
    if neededScaleX > neededScaleY then
        smallestScale = neededScaleY
    end

    itemRes:setScaleX(smallestScale)
    itemRes:setScaleY(smallestScale)

    local itemResSize   = itemRes:getGroupBounds().size
    local deltaWidth    = self.itemPhSize.width - itemResSize.width
    local deltaHeight   = self.itemPhSize.height - itemResSize.height
    
    itemRes:setPosition(ccp( self.itemPhPos.x + deltaWidth/2, 
                self.itemPhPos.y - deltaHeight/2))
    self.numberLabel:setString("x" .. itemNum)

    self.numberLabel:stopAllActions()
    self.numberLabel:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function ()
        self:flyRewardIcon(itemsData, flyEndCallback)
    end)))
end

function ActivityRequestItem:flyRewardIcon(itemsData, endCallback)
    if self.itemRes then self.itemRes:setVisible(false) end 
    if self.numberLabel then self.numberLabel:setVisible(false) end

    local function onAnimFinished()
        if self.isDisposed then return end
        local delay = CCDelayTime:create(0.3)
        local function removeSelf()
            if endCallback then
                endCallback() 
            end             
        end
        local callAction = CCCallFunc:create(removeSelf)
        local seq = CCSequence:createWithTwoActions(delay, callAction)
        self:runAction(seq)
    end

    local anim = FlyItemsAnimation:create(itemsData)
    local bounds = self.itemRes:getGroupBounds()
    anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
    anim:setFinishCallback(onAnimFinished)
    anim:setScale(self.itemRes:getScale())
    anim:play()

    addReward(itemsData, DcSourceType.kActFreeGift)
end

function PushEnergyItem:init()
    self._isInRequest = false
    self._hasCompleted = false

    local ui = self.builder:buildGroup("push_energy_message_item")
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui

    self.bg = ui:getChildByName('sprite')
    self.confirm = GroupButtonBase:create(ui:getChildByName('btn'))
    self.confirm:setString(localize('接收'))
    self.confirm:ad(DisplayEvents.kTouchTap, function () self:sendAccept() end)

    self.selected = ui:getChildByName('selected')
    self.selected:setVisible(false)

    self:buildSyncAnimation()
end

-- override super
function PushEnergyItem:setData(requestInfo)
    self.requestInfo = requestInfo
end

-- override super
function PushEnergyItem:sendIgnore(isBatch)
    -- 不支持忽略
end

-- override super
function PushEnergyItem:sendAccept(isBatch)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        if self.isDisposed then return end
        local itemId = tonumber(self.requestInfo.itemId)
        local num = tonumber(self.requestInfo.itemNum)
        local pos = self.confirm:getPosition()
        local anim = FlyItemsAnimation:create({{itemId = itemId, num = num}})
        anim:setWorldPosition(self.ui:convertToWorldSpace(pos))
        anim:play()
        addReward({{itemId = itemId, num = num}}, DcSourceType.kPushEnergy)
        self._hasCompleted = true
        self:showButtons(false)
        FreegiftManager:sharedInstance():removeMessageById(self.id)
        if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end
        FreegiftManager:sharedInstance():removeMessageById(self.id) 
        self:onSendAcceptSuccess(event, isBatch)
    end
    local function _onFail(event) 
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount - 1
        end
        self:onSendAcceptFail(event, isBatch) 
    end

    if self.panel ~= nil then
        self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount + 1
    end
    self:showSyncAnimation(true)
    self:showButtons(false)
    local action = 1
    local http = RespRequest.new()
    http:addEventListener(Events.kComplete, _onSuccess)
    http:addEventListener(Events.kError, _onFail)
    http:load(self.requestInfo.id, action)
    self:onRequestSent(isBatch)
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_get_npc_energy'}, true)
end

function PushEnergyItem:canAcceptAll()
    return true
end

function PushEnergyItem:canIgnoreAll()
    return false
end

function PushEnergyItem:isReceive()
    return true
end

function PushEnergyItem:isSend()
    return false
end

function PushEnergyItem:showButtons(show)
    if self.isDisposed then return end
    self.confirm:setVisible(show)
    self.confirm:setEnabled(show)
end

--------------------------------------------------------
-- DengchaoEnergyItem
--------------------------------------------------------
function DengchaoEnergyItem:loadRequiredResource()
    self.panelConfigFile = 'ui/DengchaoPushEnergy.json'
    self.builder = InterfaceBuilder:createWithContentsOfFile(self.panelConfigFile)
end

function DengchaoEnergyItem:init()
    
    self._isInRequest = false
    self._hasCompleted = false

    local ui = self.builder:buildGroup("push_energy_message_item_dengchao")
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui

    self.bg = ui:getChildByName('sprite')
    self.confirm = GroupButtonBase:create(ui:getChildByName('btn'))
    self.confirm:setString('接收')
    self.confirm:ad(DisplayEvents.kTouchTap, function () self:sendAccept() end)

    self.selected = ui:getChildByName('selected')
    self.selected:setVisible(false)

    self:setHeight(252)

    self:buildSyncAnimation()
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_see_chenkun_energy'})
end

function DengchaoEnergyItem:sendAccept(isBatch)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        if self.isDisposed then return end
        local itemId = tonumber(self.requestInfo.itemId)
        local num = tonumber(self.requestInfo.itemNum)
        local pos = self.confirm:getPosition()
        local rPos = {x = pos.x - 20, y = pos.y + 40}
        local worldPos = self.ui:convertToWorldSpace(ccp(rPos.x, rPos.y))

        local reward = {itemId = itemId, num = num}
        local anim = FlyItemsAnimation:create({reward})
        anim:setWorldPosition(ccp(worldPos.x, worldPos.y))
        anim:play()

        addReward({reward}, DcSourceType.kActFreeGift)

        -- change to send back mode
        self._hasCompleted = true
        self:showButtons(false)
        FreegiftManager:sharedInstance():removeMessageById(self.id)
        if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end

        FreegiftManager:sharedInstance():removeMessageById(self.id) 
        HomeScene:sharedInstance():hideDengchaoEnergyAnim()
        self:onSendAcceptSuccess(event, isBatch)
    end
    local function _onFail(event) 
        if self.panel ~= nil then
            self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount - 1
        end
        self:onSendAcceptFail(event, isBatch) 
    end

    if self.panel ~= nil then
        self.panel.listAnimPlayItemCount = self.panel.listAnimPlayItemCount + 1
    end

    self:showSyncAnimation(true)
    self:showButtons(false)
    local action = 1
    local http = RespRequest.new()
    http:addEventListener(Events.kComplete, _onSuccess)
    http:addEventListener(Events.kError, _onFail)
    http:load(self.requestInfo.id, action)
    self:onRequestSent(isBatch)
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_get_chenkun_energy'})
end

function DengchaoEnergyItem:canAcceptAll()
    return false
end



-- LevelSurpassMessageItem = class(RequestMessageItemBase)
-- PassLastLevelOfLevelAreaMessageItem = class(RequestMessageItemBase)
-- ScoreSurpassMessageItem = class(RequestMessageItemBase)
-- PassMaxNormalLevelMessageItem = class(RequestMessageItemBase)

-------------------------------------------------
-- StartLevelMessageItemBase
-------------------------------------------------
function StartLevelMessageItemBase:init()
    RequestMessageItemBase.init(self)
end

function StartLevelMessageItemBase:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.confirm:setString(localize('request.message.panel.news.btn2')) 
end

function StartLevelMessageItemBase:canAcceptAll()
    return false
end

function StartLevelMessageItemBase:canIgnoreAll()
    return true
end

function StartLevelMessageItemBase:sendAccept(isBatch)
    self:sendIgnore(isBatch)
    self:startLevel(UserManager:getInstance().user:getTopLevelId())
end

function StartLevelMessageItemBase:startLevel(levelId)
    local function startLevel()
        if levelId then
            HomeScene:sharedInstance().worldScene:startLevel(levelId)
        end
    end
    self:onRequestSent(isBatch)
    self:onSendAcceptSuccess(nil, isBatch)
    Director:sharedDirector():popScene()
    HomeScene:sharedInstance():runAction(CCCallFunc:create(startLevel))
end





-------------------------------------------------
-- PushActivityMessageItem
-------------------------------------------------
function PushActivityMessageItem:init()
    RequestMessageItemBase.init(self)
end

function PushActivityMessageItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.confirm:setString(localize('message.panel.activity.push.btn2')) 
    self.msg_text:setString(localize('message.panel.activity.push.msg'))
    self.actId = requestInfo.itemId

    DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_message_push"})

end

function PushActivityMessageItem:canAcceptAll()
    return false
end

function PushActivityMessageItem:canIgnoreAll()
    return true
end

function PushActivityMessageItem:sendAccept(isBatch)


    DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_message_click"})


    local list = PushActivity:getActivityList()
    local info 
    for _, _info in pairs(list) do
        if tostring(_info.actId) == tostring(self.actId) then
            info = _info
            break
        end
    end
    if info then
        local source = info.source
        local version = info.version

        pcall(function ( ... )

            local config = require("activity/" .. source)

            if config.isSupport and config.isSupport() then 

                if config.setStartFrom then
                    config.setStartFrom('message')
                end

                ActivityData.new({source=source,version=version}):start(true, false, function ( ... )
                    if self.isDisposed then return end

                    Director:sharedDirector():popScene()

                    local function _onSuccess(event)
                        FreegiftManager:sharedInstance():removeMessageById(self.id)
                        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
                    end
                    local function _onFail(event)

                    end
                    local action = 2
                    local http = RespRequest.new()
                    http:addEventListener(Events.kComplete, _onSuccess)
                    http:addEventListener(Events.kError, _onFail)
                    http:load(self.requestInfo.id, action)

                end)

            else
                CommonTip:showTip('活动已过期~')
                self:sendIgnore(isBatch)
            end

        end)

    else
        CommonTip:showTip('活动已过期~')
        self:sendIgnore(isBatch)
    end
end

-------------------------------------------------
-- AskForHelpItem
-------------------------------------------------
function AskForHelpItem:init()
    RequestMessageItemBase.init(self)
end

function AskForHelpItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.levelId = tonumber(requestInfo.itemId) or 0    -- 求助关卡号
    self.senderUid = tonumber(requestInfo.senderUid) or 0    -- 求助者Id
    local levelString = tostring(self.levelId)

    self.msg_text:setString(localize('message.panel.askforhelp.text', {num = levelString}))
    self.confirm:setString(localize('message.panel.askforhelp.btn2'))
    if self:canSendMore() then 
        self.enabled = true
        self.confirm:setEnabled(true)
    else 
        self.enabled = false
        self.confirm:setEnabled(false)
        self.confirm:setString(Localization:getInstance():getText("message.center.panel.btn.helptomorrow"))
    end
end

function AskForHelpItem:canAcceptAll()
    return false
end

function AskForHelpItem:canIgnoreAll()
    return true
end

function AskForHelpItem:sendAccept(isBatch)
    self:startLevel(self.levelId)
    DcUtil:UserTrack({category = 'FriendLevel', sub_category = 'push_mail_help', t1=self.levelId, t2=self.senderUid})
end

function AskForHelpItem:canSendMore()
    local mgr = AskForHelpManager.getInstance()
    local cfg = mgr:getConfig()
    local helpData = mgr:getHelpData()
    local num = tonumber(helpData.dailyHelpOtherCount or 0)
    return num < cfg:getMaxDailyHelpOtherCount()
end

function AskForHelpItem:startLevel(levelId)
    assert(levelId>0, "startLevel")

    local function onCheckFinished(ret)
        if ret then
            -- 通过检测，开始代打
            local function startLevel()
                HomeScene:sharedInstance().worldScene:startLevel(levelId, StartLevelType.kAskForHelp)
                AskForHelpManager:getInstance():enterMode(self.senderUid)
            end

            --self:sendIgnore(isBatch)
            --self:onRequestSent(isBatch)
            --self:onSendAcceptSuccess(nil, isBatch)
            Director:sharedDirector():popScene()
            HomeScene:sharedInstance():runAction(CCCallFunc:create(startLevel))
        else
            -- 后端校验失败
            self:sendIgnore(isBatch)
        end
    end
    AskForHelpManager:getInstance():pocessDecision(true, self.senderUid, levelId, onCheckFinished)
end

-------------------------------------------------
-- AskForHelpTopItem
-------------------------------------------------
function AskForHelpTopItem:init()
    local ui = self.builder:buildGroup("ask_help_top_message_item")
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui

    self.bg = ui:getChildByName('sprite')
    self.help_btn = ui:getChildByName('help_btn')
    self.help_btn:setTouchEnabled(true)
    self.help_btn:ad(DisplayEvents.kTouchTap, function () 
        local panel = AskForHelpExplain:create()
        panel:popout()
    end)

    self:buildSyncAnimation()
end

function AskForHelpTopItem:canAcceptAll()
    return false
end

function AskForHelpTopItem:canIgnoreAll()
    return true
end

function AskForHelpTopItem:showButtons(show)
    if self.isDisposed then return end
    self.help_btn:setVisible(show)
    self.help_btn:setTouchEnabled(show)
end

-------------------------------------------------
-- AskForHelpSuccessItem
-------------------------------------------------
function AskForHelpSuccessItem:setData(requestInfo)
    WeeklyMessageItem.setData(self, requestInfo)

    self.levelId = tonumber(requestInfo.itemId) or 0    -- 求助关卡号
    local levelString = tostring(self.levelId)
    self.confirm:setString(localize('message.panel.news.btn5')) 
    self.msg_text:setString(localize('message.panel.news.text5', {num = levelString}))
end

-------------------------------------------------
-- LevelSurpassMessageItem
-------------------------------------------------
function LevelSurpassMessageItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.levelId = tonumber(self.requestInfo.itemId)
    local levelString = tostring(self.levelId)
    if self.levelId > LevelConstans.HIDE_LEVEL_ID_START then
        levelString = '+'..tostring(self.levelId - LevelConstans.HIDE_LEVEL_ID_START) 
    end
    self.confirm:setString(localize('request.message.panel.news.btn2'))
    self.msg_text:setString(localize('request.message.panel.news.text2', {num = levelString}))

end

function LevelSurpassMessageItem:sendAccept(isBatch)
    StartLevelMessageItemBase.sendAccept(self, isBatch)
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_challenge_high_level'}, true)
end

-------------------------------------------------
-- WeeklyMessageItem
-------------------------------------------------
function WeeklyMessageItem:setData(requestInfo)
    StartLevelMessageItemBase.setData(self, requestInfo)
    self.confirm:setString(localize('request.message.panel.news.btn2'))
    self.msg_text:setString(localize('weeklyrace.winter.rank.news'))
end

function WeeklyMessageItem:sendAccept(isBatch)
    self:sendIgnore(isBatch)
    -- DcUtil:UserTrack({category = 'message', sub_category = 'message_center_challenge_high_level'}, true)

    local function startLevel()
        --周赛处理逻辑
        if RankRaceMgr:getInstance():isEnabled() then
            RankRaceMgr:getInstance():openMainPanel()
        else
            SeasonWeeklyRaceManager:getInstance():pocessSeasonWeeklyDecision(true)
        end

    end
    self:onRequestSent(isBatch)
    self:onSendAcceptSuccess(nil, isBatch)
    Director:sharedDirector():popScene()
    HomeScene:sharedInstance():runAction(CCCallFunc:create(startLevel))
end


------------------------------------------------
-- PassLastLevelOfLevelAreaMessageItem
------------------------------------------------
function PassLastLevelOfLevelAreaMessageItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.levelId = tonumber(self.requestInfo.itemId)
    self.confirm:setString(localize('request.message.panel.news.btn2'))
    self.msg_text:setString(localize('request.message.panel.news.text3', {num = self.levelId}))
end

function PassLastLevelOfLevelAreaMessageItem:sendAccept(isBatch)
    StartLevelMessageItemBase.sendAccept(self, isBatch)
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_challenge_zone_level'}, true)
end

----------------------------------------------------
-- ScoreSurpassMessageItem
----------------------------------------------------
function ScoreSurpassMessageItem:init()
    RequestMessageItemBase.init(self)
end

function ScoreSurpassMessageItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.confirm:setString(localize('request.message.panel.news.btn1'))
    self.levelId = tonumber(requestInfo.itemId) or 0
    local levelString = tostring(self.levelId)
    if self.levelId > LevelConstans.HIDE_LEVEL_ID_START then
        levelString = '+'..tostring(self.levelId - LevelConstans.HIDE_LEVEL_ID_START) 
    end
    self.msg_text:setString(localize('request.message.panel.news.text1', {num = levelString}))
end

function ScoreSurpassMessageItem:canAcceptAll()
    return false
end

function ScoreSurpassMessageItem:canIgnoreAll()
    return true
end

function ScoreSurpassMessageItem:sendAccept(isBatch)
    if self.levelId and self.levelId > 0 then
        self:sendIgnore(isBatch)
        self:startLevel(self.levelId)
    end
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_challenge_high_score'}, true)
end

----------------------------------------------------
-- PushBindingItem
----------------------------------------------------
function PushBindingItem:init()
    local ui = self.builder:buildGroup("push_binding_message_item")
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui

    self.confirm = GroupButtonBase:create(ui:getChildByName('confirm_button'))
    self.confirm:setString(localize('添加好友')) -- text@wenkan
    self.confirm:ad(DisplayEvents.kTouchTap, function () self:sendAccept() end)

    self.text = self.ui:getChildByName('msg_text')
    self.text:setString('好友免费送精力，更多好友更多收获')-- text@wenkan
end

function PushBindingItem:setData()
end

function PushBindingItem:canAcceptAll()
    return false
end

function PushBindingItem:canIgnoreAll()
    return false
end

function PushBindingItem:sendAccept()
    PushBindingLogic:runPopAddFriendPanelLogic(1)
end

function PushBindingItem:gainFocus()
end

function PushBindingItem:looseFocus()
end

----------------------------------------------------
-- LevelSurpassNationMessageItem
----------------------------------------------------

function LevelSurpassNationMessageItem:setData(requestInfo)
    LevelSurpassMessageItem.setData(self, requestInfo)
    local levelString = tostring(self.levelId)
    if self.levelId > LevelConstans.HIDE_LEVEL_ID_START then
        levelString = '+'..tostring(self.levelId - LevelConstans.HIDE_LEVEL_ID_START) 
    end
    self.msg_text:setString(localize('request.message.panel.level.nation', {num = levelString}))
end

----------------------------------------------------
-- ScoreSurpassNationMessageItem
----------------------------------------------------

function ScoreSurpassNationMessageItem:setData(requestInfo)
    ScoreSurpassMessageItem.setData(self, requestInfo)
    local levelString = tostring(self.levelId)
    if self.levelId > LevelConstans.HIDE_LEVEL_ID_START then
        levelString = '+'..tostring(self.levelId - LevelConstans.HIDE_LEVEL_ID_START) 
    end
    self.msg_text:setString(localize('request.message.panel.score.nation', {num = levelString}))
end

----------------------------------------------------
-- WeeklySurpassNationMessageItem
----------------------------------------------------

function WeeklySurpassNationMessageItem:setData(requestInfo)
    WeeklyMessageItem.setData(self, requestInfo)
    self.msg_text:setString(localize('weeklyrace.winter.surpass.nation'))
end

-------------------------------------------------
-- LevelSurpassMessageItem
-------------------------------------------------
function ActRecallRemindItem:setData(requestInfo)
    RequestMessageItemBase.setData(self, requestInfo)
    self.confirm:setString(localize('request.message.panel.news.btn3')) --知道了
    self.msg_text:setString(localize('request.message.panel.news.text5'))
end


-------------------------------------------------
-- RequestMessageGiftItem
-------------------------------------------------
function RequestMessageGiftItem:buildUi()
    return self.builder:buildGroup("friends_message_item_gift")
end

function RequestMessageGiftItem:init( ... )
    RequestMessageItemBase.init(self, ...)
    -- "request.message.panel.news.btn3" = "知道了";
    self.confirm:setString(Localization:getInstance():getText("request.message.panel.news.btn3"))
    self.avatar_ico:setOpacity(255)
end

--------------------------------------
function RequestMessageGiftItem:setData(requestInfo)
    -- RequestMessageItemBase.setData(self, requestInfo)
    self.requestInfo = requestInfo or {}
    local data = self.requestInfo.extraData
    if not data then
        data = table.deserialize(self.requestInfo.extra or "") or {}
        if data.items then
            local r=string.split2(data.items,",")
            for i,v in pairs(r) do
                local l = string.split2(v,":")
                r[tonumber(i)]={id=tonumber(l[1]),num=tonumber(l[2])}
            end
            data.items=r
        end
    end

    -- print("-------------------extra",self.requestInfo.extra,table.tostring(data))

    self.name_text:setString(data.title or "")
    self.msg_text:setString(data.content or "")

    if #data.items>0 then
        local content = CocosObject:create()
        for i,v in ipairs(data.items) do
            local tx = 80 * (i-1)
            local item = self.builder:buildGroup("request_message_panel/giftItem")
            item:setPositionX(tx)

            content.totalLength = tx

            local imgPh = item:getChildByName("item")
            imgPh:setVisible(false)
            local phSize = imgPh:getGroupBounds().size

            local rewardIcon = ResourceManager:sharedInstance():buildItemSprite(v.id)
            rewardIcon:setAnchorPoint(ccp(0.5,0.5))
            rewardIcon:setPosition(ccp(tx+phSize.width*0.5,-phSize.height*0.5))
            local size = rewardIcon:getContentSize()
            local scale = math.min(phSize.width/size.width,phSize.height/size.height)
            rewardIcon:setScale(scale)
            -- item:addChild(rewardIcon,0,0)
            content:addChild(rewardIcon,0,0)


            local strNum = "" .. number_formatForm(v.num)
            local n=string.utf8len(strNum)
            local tw,th=13*n+13,22
            local bgNum = item:getChildByName("bgNum")
            bgNum:setContentSize(CCSizeMake(tw,th))
            bgNum:setAnchorPoint(ccp(0.5,0.5))
            content:addChild(item)
            local halfBgW=tw*0.5

            local txtNum = item:getChildByName("txtNum")
            txtNum:setString(strNum)
            txtNum:setPositionY(txtNum:getPositionY()-2)
            local tx,ty=txtNum:getPositionX(),txtNum:getPositionY()
            local tw,th=10*n,30
            -- txtNum:setDimensions(CCSizeMake(tw,th))
            -- txtNum:setPositionXY(tx+halfBgW+tw*0.5,ty-th*0.5)
            -- txtNum:setAnchorPoint(ccp(0.5,0.5))
        end

        --HorizontalScrollable
        local backBlocking = LayerColor:create()
        backBlocking:setColor(ccc3(0, 20, 0))
        backBlocking:setOpacity(0)
        backBlocking:setContentSize(CCSizeMake(self.itemPhSize.width, self.itemPhSize.height+30))
        backBlocking:setPosition(ccp(self.itemPhPos.x,self.itemPhPos.y-self.itemPhSize.height))
        backBlocking:setTouchEnabled(true, -1, true)
        backBlocking:ad(DisplayEvents.kTouchBegin, function(event) print("backBlocking TOUCH BEGIN") end)
        self:addChild(backBlocking)

        local scrollView = HorizontalScrollable:create(self.itemPhSize.width, self.itemPhSize.height, true, false,-2)
        scrollView:setPosition(ccp(self.itemPhPos.x,self.itemPhPos.y))
        scrollView:setScrollEnabled(true)
        scrollView:setContent(content)
        -- scrollView.touchLayer:setTouchEnabled(true,-2,false)
        -- scrollView.touchLayer:setSwallowsTouches(true)
        -- scrollView.touchLayer:setTouchEnabled(true, 0, true)
        self:addChild(scrollView)


        local moveTime = #data.items*0.4+1
        local con = content:getParent()
        local startAutoMove
        startAutoMove = function ()
            content.dir = content.dir and content.dir*-1 or 1

            local  pCallback = CCCallFunc:create(stopAction)
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(0.2+math.random()*0.3))
            arr:addObject(CCMoveTo:create(moveTime,ccp(content.dir==1 and -content.totalLength or 0,0)))
            arr:addObject(CCCallFunc:create(startAutoMove))
            arr:addObject(pCallback)
            con:runAction(CCSequence:create(arr))
        end

        local function stopAutoMove()
            con:stopAllActions()
        end

        local minMoveCount = 4
        if #data.items>=minMoveCount then
            content.totalLength=content.totalLength-50*minMoveCount

            scrollView.touchLayer:ad(DisplayEvents.kTouchBegin, function(event) stopAutoMove(event) end)
            scrollView.touchLayer:ad(DisplayEvents.kTouchMove, function(event) stopAutoMove(event) end)
            scrollView.touchLayer:ad(DisplayEvents.kTouchEnd, function(event) startAutoMove(event) end)

            startAutoMove()
        end
    end
end

function RequestMessageGiftItem:sendAccept(isBatch)
    RequestMessageItemBase.sendAccept(self, isBatch)
end

function RequestMessageGiftItem:getHeight( ... )
    return 189
end




-------------------------------------------------
-- FLGInboxItem
-------------------------------------------------
function FLGInboxItem:buildUi()
    return self.builder:buildGroup("friends_message_item_hongbao")
end

function FLGInboxItem:init( ... )
    RequestMessageItemBase.init(self, ...)
    -- "request.message.panel.news.btn3" = "知道了";
    self.confirm:setString(Localization:getInstance():getText("request.message.panel.news.btn3"))
    -- self.avatar_ico:setOpacity(255)
    -- self.avatar_ico:removeChildren(true)
end
function FLGInboxItem:onSendAcceptSuccess(event, isBatch, triggerByPanel)
    if self.isDisposed then return end
    if not triggerByPanel then
        GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
    end

    if self.isDisposed then return end
    self._isInRequest = false
    self._hasCompleted = true
    self:showSyncAnimation(false)
    self:showButtons(false)
    if self.selected and not self.selected.isDisposed then self.selected:setVisible(true) end -- show selected
    self:runAction(CCCallFunc:create(function( ... )
        if self.isDisposed then return end
        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)

        local rewardIds = {}
        local rewardAmounts = {}

        local data = self.requestInfo.extraData
        local itemsData = data.items

        if _G.isLocalDevelopMode then printx(101, "FLGInboxItem onSendAcceptSuccess itemsData = " , table.tostring( itemsData ) ) end 
        local indexNode = 1
        for key,v1 in pairs(itemsData) do
            local itemId        = v1.id
            local itemNumber    = v1.num
            table.insert(rewardIds, itemId)
            table.insert(rewardAmounts, itemNumber)
            if _G.isLocalDevelopMode then printx(101, "FLGInboxItem onSendAcceptSuccess itemId = " , itemId) end 
            if _G.isLocalDevelopMode then printx(101, "FLGInboxItem onSendAcceptSuccess itemNumber = " , itemNumber) end 

            local bounds = self.rewardsItemsNodes[indexNode]:getGroupBounds()
            local pos = ccp(bounds:getMidX(), bounds:getMidY())
            local anim = FlyItemsAnimation:create({ {itemId = itemId , num = itemNumber }  })
            anim:setWorldPosition(ccp(pos.x,pos.y))
            anim:setFinishCallback(nil)
            if _G.isLocalDevelopMode then printx(101, "FLGInboxItem onSendAcceptSuccess itemId 4 = " , itemId) end 
            anim:play()
            if _G.isLocalDevelopMode then printx(101, "FLGInboxItem onSendAcceptSuccess itemId 5 = " , itemId) end 
            addReward({{itemId = itemId, num = itemNumber}}, DcSourceType.kFullLevelReward)
            indexNode = indexNode + 1
        end
    end))


end

function FLGInboxItem:showRewardIcon( itemsData , flyEndCallback)

    
    -- if _G.isLocalDevelopMode then printx(101, "FLGInboxItem onSendAcceptSuccess self.requestInfo.extra = " , table.tostring( self.requestInfo.extra ) ) end 
    local data = self.requestInfo.extraData
    if not data then
        data = table.deserialize(self.requestInfo.extra or "") or {}
        if data.items then
            local r=string.split2(data.items,",")
            for i,v in pairs(r) do
                local l = string.split2(v,":")
                r[tonumber(i)]={id=tonumber(l[1]),num=tonumber(l[2])}
            end
            data.items=r
        end
    end

    if _G.isLocalDevelopMode then printx(101, "FLGInboxItem showRewardIcon data = " , table.tostring( data ) ) end 

    itemsData = data.items

    if not itemsData then return end 

    local itemId = itemsData[1].itemId
    local itemNum = itemsData[1].num 
    if not itemId or not itemNum then return end

    if ItemType:isTimeProp(itemId) then itemId = ItemType:getRealIdByTimePropId(itemId) end
    local itemRes   = ResourceManager:sharedInstance():buildItemGroup(itemId)
    self.itemRes    = itemRes
    self.ui:addChild(itemRes)

    local itemResSize   = itemRes:getGroupBounds().size
    local neededScaleX  = self.itemPhSize.width / itemResSize.width
    local neededScaleY  = self.itemPhSize.height / itemResSize.height

    local smallestScale = neededScaleX
    if neededScaleX > neededScaleY then
        smallestScale = neededScaleY
    end

    itemRes:setScaleX(smallestScale)
    itemRes:setScaleY(smallestScale)

    local itemResSize   = itemRes:getGroupBounds().size
    local deltaWidth    = self.itemPhSize.width - itemResSize.width
    local deltaHeight   = self.itemPhSize.height - itemResSize.height
    
    itemRes:setPosition(ccp( self.itemPhPos.x + deltaWidth/2, 
                self.itemPhPos.y - deltaHeight/2))
    self.numberLabel:setString("x" .. itemNum)

    self.numberLabel:stopAllActions()
    self.numberLabel:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function ()
        self:flyRewardIcon(itemsData, flyEndCallback)
    end)))

end

function FLGInboxItem:flyRewardIcon(itemsData, endCallback)
    if self.itemRes then self.itemRes:setVisible(false) end 
    if self.numberLabel then self.numberLabel:setVisible(false) end

    local function onAnimFinished()
        if self.isDisposed then return end
        local delay = CCDelayTime:create(0.3)
        local function removeSelf()
            if endCallback then
                endCallback() 
            end             
        end
        local callAction = CCCallFunc:create(removeSelf)
        local seq = CCSequence:createWithTwoActions(delay, callAction)
        self:runAction(seq)
    end

    local anim = FlyItemsAnimation:create(itemsData)
    local bounds = self.itemRes:getGroupBounds()
    anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
    anim:setFinishCallback(onAnimFinished)
    anim:setScale(self.itemRes:getScale())
    anim:play()

    addReward(itemsData, DcSourceType.kFullLevelReward)
end
--------------------------------------
function FLGInboxItem:setData(requestInfo)

    RequestMessageItemBase.setData( self , requestInfo )

    self.confirm:setString('接收')
    -- RequestMessageItemBase.setData(self, requestInfo)
    self.requestInfo = requestInfo or {}
    local data = self.requestInfo.extraData
    if not data then
        data = table.deserialize(self.requestInfo.extra or "") or {}
        if data.items then
            local r=string.split2(data.items,",")
            for i,v in pairs(r) do
                local l = string.split2(v,":")
                r[tonumber(i)]={id=tonumber(l[1]),num=tonumber(l[2])}
            end
            data.items=r
        end
    end

    -- print("-------------------extra",self.requestInfo.extra,table.tostring(data))

    self.name_text:setString( nameDecode(data.title or "") )
    self.msg_text:setString(data.content or "")

    self.rewardsItemsNodes = {}
    local indexNode = 1

    if #data.items>0 then
        local content = CocosObject:create()
        for i,v in ipairs(data.items) do
            local tx = 80 * (i-1)
            local item = self.builder:buildGroup("request_message_panel/giftItem")
            item:setPositionX(tx)

            content.totalLength = tx

            local imgPh = item:getChildByName("item")
            imgPh:setVisible(false)
            local phSize = imgPh:getGroupBounds().size

            local rewardIcon = ResourceManager:sharedInstance():buildItemSprite(v.id)
            rewardIcon:setAnchorPoint(ccp(0.5,0.5))
            rewardIcon:setPosition(ccp(tx+phSize.width*0.5,-phSize.height*0.5))
            local size = rewardIcon:getContentSize()
            local scale = math.min(phSize.width/size.width,phSize.height/size.height)
            rewardIcon:setScale(scale)
            -- item:addChild(rewardIcon,0,0)
            content:addChild(rewardIcon,0,0)


            local strNum = "" .. number_formatForm(v.num)
            local n=string.utf8len(strNum)
            local tw,th=13*n+13,22
            local bgNum = item:getChildByName("bgNum")
            bgNum:setContentSize(CCSizeMake(tw,th))
            bgNum:setAnchorPoint(ccp(0.5,0.5))
            content:addChild(item)
            local halfBgW=tw*0.5

            local txtNum = item:getChildByName("txtNum")
            txtNum:setString(strNum)
            txtNum:setPositionY(txtNum:getPositionY()-2)
            local tx,ty=txtNum:getPositionX(),txtNum:getPositionY()
            local tw,th=10*n,30


            self.rewardsItemsNodes[ indexNode ] = item

            indexNode = indexNode + 1
        end

        --HorizontalScrollable
        local backBlocking = LayerColor:create()
        backBlocking:setColor(ccc3(0, 20, 0))
        backBlocking:setOpacity(0)
        backBlocking:setContentSize(CCSizeMake(self.itemPhSize.width, self.itemPhSize.height+30))
        backBlocking:setPosition(ccp(self.itemPhPos.x,self.itemPhPos.y-self.itemPhSize.height))
        backBlocking:setTouchEnabled(true, -1, true)
        backBlocking:ad(DisplayEvents.kTouchBegin, function(event) print("backBlocking TOUCH BEGIN") end)
        self:addChild(backBlocking)

        local scrollView = HorizontalScrollable:create(self.itemPhSize.width, self.itemPhSize.height, true, false,-2)
        scrollView:setPosition(ccp(self.itemPhPos.x,self.itemPhPos.y))
        scrollView:setScrollEnabled(true)
        scrollView:setContent(content)
        -- scrollView.touchLayer:setTouchEnabled(true,-2,false)
        -- scrollView.touchLayer:setSwallowsTouches(true)
        -- scrollView.touchLayer:setTouchEnabled(true, 0, true)
        self:addChild(scrollView)


        local moveTime = #data.items*0.4+1
        local con = content:getParent()
        local startAutoMove
        startAutoMove = function ()
            content.dir = content.dir and content.dir*-1 or 1

            local  pCallback = CCCallFunc:create(stopAction)
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(0.2+math.random()*0.3))
            arr:addObject(CCMoveTo:create(moveTime,ccp(content.dir==1 and -content.totalLength or 0,0)))
            arr:addObject(CCCallFunc:create(startAutoMove))
            arr:addObject(pCallback)
            con:runAction(CCSequence:create(arr))
        end

        local function stopAutoMove()
            con:stopAllActions()
        end

        local minMoveCount = 4
        if #data.items>=minMoveCount then
            content.totalLength=content.totalLength-50*minMoveCount

            scrollView.touchLayer:ad(DisplayEvents.kTouchBegin, function(event) stopAutoMove(event) end)
            scrollView.touchLayer:ad(DisplayEvents.kTouchMove, function(event) stopAutoMove(event) end)
            scrollView.touchLayer:ad(DisplayEvents.kTouchEnd, function(event) startAutoMove(event) end)

            startAutoMove()
        end
    end




end

function FLGInboxItem:sendAccept(isBatch)
    RequestMessageItemBase.sendAccept(self, isBatch)
end

function FLGInboxItem:getHeight( ... )
    return 189
end



function ThanksForYourFullGiftMessageItem:setData( ... )
    RequestMessageItemBase.setData(self, ...)
    self.confirm:setString('知道了')
    self.msg_text:setString('领取了你的红包并向你表示感谢！')
end

function MergedRequestMessageItemBase:sendAccept(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end

    local firstRequestInfo = self.requestInfoGrp[1]

    local function _onSuccess(event)
        for _, requestInfo in ipairs(self.requestInfoGrp or {}) do
            FreegiftManager:sharedInstance():removeMessageById(requestInfo.id) 
        end
        self:onSendAcceptSuccess(event, isBatch)
    end
    local function _onFail(event) self:onSendAcceptFail(event, isBatch) end

    self:showSyncAnimation(true)
    self:showButtons(false)

    if not triggerByPanel then
        local action = 3
        local http = RespRequest.new()
        http:addEventListener(Events.kComplete, _onSuccess)
        http:addEventListener(Events.kError, _onFail)
        http:load(nil, action, {firstRequestInfo.type}, FreegiftManager:sharedInstance().maxMessageID)
    end

    self:onRequestSent(isBatch)
end

function MergedRequestMessageItemBase:setData( mergedRequestInfo )
    mergedRequestInfo = mergedRequestInfo or {}
    self.requestInfoGrp = mergedRequestInfo.requestInfoGrp or {}
    RequestMessageItemBase.setData(self, self.requestInfoGrp[1] or {})


    local userName = self.requestInfo.name or ''

    local friendRef = FriendManager.getInstance().friends[tostring(self.requestInfo.senderUid)]
    if friendRef then
        if friendRef.name and friendRef.name ~= "" then userName = friendRef.name end
    end
    
    if userName == nil or userName == "" then userName = "ID:"..tostring(self.requestInfo.senderUid) end
    self.name_text:setString(string.format('%s等%d人', nameDecode(userName), #self.requestInfoGrp))
end

function MergedRequestMessageItemBase:sendIgnore(isBatch, triggerByPanel)
    if self:isInRequest() then return end
    if self:hasCompleted() then return end

    local firstRequestInfo = self.requestInfoGrp[1]

    local function _onSuccess(event)
        for _, requestInfo in ipairs(self.requestInfoGrp or {}) do
            FreegiftManager:sharedInstance():removeMessageById(requestInfo.id)
        end
        self:onSendIgnoreSuccess(event, isBatch)
    end
    local function _onFail(event) self:onSendIgnoreFail(event, isBatch) end
    self:showSyncAnimation(true)
    self:showButtons(false)
    if not triggerByPanel then
        local action = 4
        local http = RespRequest.new()
        http:addEventListener(Events.kComplete, _onSuccess)
        http:addEventListener(Events.kError, _onFail)
        http:load(nil, action, {firstRequestInfo.type}, FreegiftManager:sharedInstance().maxMessageID)
    end
    self:onRequestSent(isBatch)
end

function MergedThanksForYourFullGiftMessageItem:setData( ... )
    MergedRequestMessageItemBase.setData(self, ...)
    self.confirm:setString('知道了')
    self.msg_text:setString('领取了你的红包并向你表示感谢！')
end


--------------------
--新版本奖励
--------------------
function NewVersionRewardItem:buildUi()
    return self.builder:buildGroup("newVersionReward_item")
end

function NewVersionRewardItem:init( ... )
    RequestMessageItemBase.init(self, ...)
    self.confirm:setString('领取')

    self.cancel:setVisible(false)
end

function NewVersionRewardItem:onSendAcceptSuccess(event, isBatch, triggerByPanel)
    if self.isDisposed then return end
	self.confirm:setEnabled(false)

	local function onSuccess( evt )
        if self.isDisposed then return end

        self._isInRequest = false
        self._hasCompleted = true
        self:showSyncAnimation(false)
        self:showButtons(false)

        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)
        
        -------
        DcUtil:UserTrack({ category='update', sub_category='get_update_reward' })
        DcUtil:UserTrack({ category='Update', sub_category='update_over', t1 = 0})


	    UserManager.getInstance().updateRewards = nil
	    UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    

	    UserManager:getInstance():addRewards(self.items, true)
	    UserService:getInstance():addRewards(self.items)
	    GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kTrunk, self.items, DcSourceType.kUpdate)

	    local function flyAction(  )
	    	local anim = OpenBoxAnimation:create( self.items )
			anim:play()
	    end 

	    setTimeOut(flyAction , 0.1)

	  	self.isCLickOk = false

        if not triggerByPanel then
            GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
        end

	end

	local function onFail( evt ) 
        DcUtil:UserTrack({ category='Update', sub_category='update_over', t1 = 1})

		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
	   	UserManager.getInstance().updateRewards = nil
	   	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end

        self._isInRequest = false
        self._hasCompleted = false
        self:showSyncAnimation(false)
        self:showButtons(true)
        self.cancel:setVisible(false)
        self.cancel:setEnabled(false)
	    self.isCLickOk = false

        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)
	end

	local function onCancel(evt)
	  	UserManager.getInstance().updateRewards = nil
	  	UserManager.getInstance().preRewards = nil
	    UserManager.getInstance().preRewardsFlag = true

	    if self.isDisposed then
	    	return
	    end
        self._isInRequest = false
        self._hasCompleted = false
        self:showSyncAnimation(false)
        self:showButtons(true)
        self.cancel:setVisible(false)
        self.cancel:setEnabled(false)
	    self.isCLickOk = false

        self:onRequestCompleted(isBatch)
        self:onMessageLifeFinished(isBatch)
	end

	local http = GetUpdateRewardHttp.new(true)
	http:ad(Events.kComplete, onSuccess)
	http:ad(Events.kError, onFail)
	http:ad(Events.kCancel, onCancel)
	http:load()
end

--------------------------------------
function NewVersionRewardItem:setData(requestInfo)

--    RequestMessageItemBase.setData( self , requestInfo )

    self.requestInfo = requestInfo or {}
    local items = self.requestInfo.rewards
    self.items = items
    -- print("-------------------extra",self.requestInfo.extra,table.tostring(data))
    self.avatar_ico:setOpacity(255)
    self.confirm:setString('领取')
    self.name_text:setString('恭喜成功更新!')
    self.msg_text:setString('送你更新礼物,祝游戏愉快!')

    self.rewardsItemsNodes = {}
    local indexNode = 1

    if #items>0 then
        local content = CocosObject:create()
        for i,v in ipairs(items) do
            local tx = 80 * (i-1)
            local item = self.builder:buildGroup("request_message_panel/giftItem")
            item:setPositionX(tx)

            content.totalLength = tx

            local bgNum = item:getChildByName("bgNum")
            bgNum:setVisible(false)
            
            local imgPh = item:getChildByName("item")
            imgPh:setVisible(false)
            local phSize = imgPh:getGroupBounds().size

            local rewardIcon = ResourceManager:sharedInstance():buildItemSprite(v.itemId)
            rewardIcon:setAnchorPoint(ccp(0.5,0.5))
            rewardIcon:setPosition(ccp(tx+phSize.width*0.5,-phSize.height*0.5))
            local size = rewardIcon:getContentSize()
            local scale = math.min(phSize.width/size.width,phSize.height/size.height)
            rewardIcon:setScale(scale)
            -- item:addChild(rewardIcon,0,0)
            content:addChild(rewardIcon,0,0)


            local strNum = "x" .. number_formatForm(v.num)
            local n=string.utf8len(strNum)
            local tw,th=13*n+13,22
            local bgNum = item:getChildByName("bgNum")
            bgNum:setContentSize(CCSizeMake(tw,th))
            bgNum:setAnchorPoint(ccp(0.5,0.5))
            content:addChild(item)
            local halfBgW=tw*0.5

            local txtNum = item:getChildByName("txtNum")
            txtNum:setString(strNum)
            txtNum:setColor(hex2ccc3('CD8310'))
            txtNum:setScale(1.3)
            txtNum:setPositionY(txtNum:getPositionY())
            txtNum:setPositionX(txtNum:getPositionX())
            local tx,ty=txtNum:getPositionX(),txtNum:getPositionY()
            local tw,th=10*n,30

            self.rewardsItemsNodes[ indexNode ] = item

            indexNode = indexNode + 1
        end

        --HorizontalScrollable
        local backBlocking = LayerColor:create()
        backBlocking:setColor(ccc3(0, 20, 0))
        backBlocking:setOpacity(0)
        backBlocking:setContentSize(CCSizeMake(self.itemPhSize.width, self.itemPhSize.height+30))
        backBlocking:setPosition(ccp(self.itemPhPos.x,self.itemPhPos.y-self.itemPhSize.height))
        backBlocking:setTouchEnabled(true, -1, true)
        backBlocking:ad(DisplayEvents.kTouchBegin, function(event) print("backBlocking TOUCH BEGIN") end)
        self:addChild(backBlocking)

        local scrollView = HorizontalScrollable:create(self.itemPhSize.width, self.itemPhSize.height, true, false,-2)
        scrollView:setPosition(ccp(self.itemPhPos.x,self.itemPhPos.y))
        scrollView:setScrollEnabled(true)
        scrollView:setContent(content)
        -- scrollView.touchLayer:setTouchEnabled(true,-2,false)
        -- scrollView.touchLayer:setSwallowsTouches(true)
        -- scrollView.touchLayer:setTouchEnabled(true, 0, true)
        self:addChild(scrollView)


        local moveTime = #items*0.4+1
        local con = content:getParent()
        local startAutoMove
        startAutoMove = function ()
            content.dir = content.dir and content.dir*-1 or 1

            local  pCallback = CCCallFunc:create(stopAction)
            local arr = CCArray:create()
            arr:addObject(CCDelayTime:create(0.2+math.random()*0.3))
            arr:addObject(CCMoveTo:create(moveTime,ccp(content.dir==1 and -content.totalLength or 0,0)))
            arr:addObject(CCCallFunc:create(startAutoMove))
            arr:addObject(pCallback)
            con:runAction(CCSequence:create(arr))
        end

        local function stopAutoMove()
            con:stopAllActions()
        end

        local minMoveCount = 4
        if #items>=minMoveCount then
            content.totalLength=content.totalLength-50*minMoveCount

            scrollView.touchLayer:ad(DisplayEvents.kTouchBegin, function(event) stopAutoMove(event) end)
            scrollView.touchLayer:ad(DisplayEvents.kTouchMove, function(event) stopAutoMove(event) end)
            scrollView.touchLayer:ad(DisplayEvents.kTouchEnd, function(event) startAutoMove(event) end)

            startAutoMove()
        end
    end
end

function NewVersionRewardItem:sendAccept(isBatch)

    if self.isCLickOk == true then
		return
	end
	self.isCLickOk = true

--    RequestMessageItemBase.sendAccept(self, isBatch)

    if self:isInRequest() then return end
    if self:hasCompleted() then return end
    local function _onSuccess(event)
        FreegiftManager:sharedInstance():removeMessageById(self.id) 
        self:onSendAcceptSuccess(event, isBatch)
    end
    self:showSyncAnimation(true)
    self:showButtons(false)

    _onSuccess()
end

function NewVersionRewardItem:getHeight( ... )
    return 189
end