
RequestMessageZeroItem = class(Layer)
RequestMessageZeroFriend = class(RequestMessageZeroItem)
RequestMessageZeroEnergy = class(RequestMessageZeroItem)
RequestMessageZeroUnlock = class(RequestMessageZeroItem)
RequestMessageZeroUpdate = class(RequestMessageZeroItem)
RequestMessageZeroActivity = class(RequestMessageZeroItem)



function RequestMessageZeroItem:create(width, height)
    local ret = self.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroItem:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.request_message_panel)
    local text = TextField:create("", nil, 36, CCSizeMake(600,400))
    text:setColor(ccc3(144, 89, 2))
    text:setAnchorPoint(ccp(0, 1))
    self.text = text
    self:addChild(text)
end

function RequestMessageZeroItem:showBottomCloseButton()
    return true
end

function RequestMessageZeroUnlock:create(width, height)
    local ret = RequestMessageZeroUnlock.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroUnlock:init(width, height)
    RequestMessageZeroItem.init(self, height)
    self.text:setString(Localization:getInstance():getText("request.message.panel.zero.unlock.text"))
    local size = self.text:getContentSize()
    self:setPositionX((width - size.width) / 2)
    self:setPositionY(-40)
end

function RequestMessageZeroUpdate:create(width, height)
    local ret = RequestMessageZeroUpdate.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroUpdate:init(width, height)
    RequestMessageZeroItem.init(self, height)
    self.text:setString(Localization:getInstance():getText("request.message.panel.zero.update.text"))
    local size = self.text:getContentSize()
    self:setPositionX((width - size.width) / 2)
    self:setPositionY(-40)
end

function RequestMessageZeroFriend:create(width, height)
    local ret = RequestMessageZeroFriend.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroFriend:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.request_message_panel)
    local ui = builder:buildGroup("request_message_panel_zero_friend")
    self:addChild(ui)
    local bg = ui:getChildByName("bg")
    local text1 = ui:getChildByName("text1")
    local text2 = ui:getChildByName("text2")
    local dscText1 = ui:getChildByName("dscText1")
    local dscText2 = ui:getChildByName("dscText2")
    local btn = ui:getChildByName("btn")
    btn = GroupButtonBase:create(btn)
    self.btn = btn


    local size = bg:getPreferredSize()
    local scale = width / (size.width + 40)
    if scale > height / (size.height + 40) then scale = height / (size.height + 40) end
    if scale < 1 then self:setScale(scale)
    else scale = 1 end
    self:setPositionX((width - size.width * scale) / 2)
    self:setPositionY(-(height - size.height * scale) / 2)

    text1:setString(Localization:getInstance():getText("request.message.panel.zero.friend.title"))
    text2:setString(Localization:getInstance():getText("request.message.panel.zero.friend.text"))
    dscText1:setString(Localization:getInstance():getText("request.message.panel.zero.friend.dsc1"))
    dscText2:setString(Localization:getInstance():getText("request.message.panel.zero.friend.dsc2"))
    btn:setString(Localization:getInstance():getText("request.message.panel.zero.friend.button"))

    local function onButton()
        createAddFriendPanel("recommend")
    end
    btn:addEventListener(DisplayEvents.kTouchTap, onButton)
end

function RequestMessageZeroFriend:setVisible(visible)
    RequestMessageZeroItem.setVisible(self, visible)
    self.btn:setEnabled(visible)
end

function RequestMessageZeroEnergy:create(width, height)
    local ret = RequestMessageZeroEnergy.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroEnergy:init(width, height)
    RequestMessageZeroItem.init(self, width, height)
    self.text:setString(localize('request.message.panel.zero.energy.text2'))
    local size = self.text:getContentSize()
    self:setPositionX((width - size.width) / 2)
    self:setPositionY(-40)
end




function RequestMessageZeroActivity:create(width, height)
    local ret = RequestMessageZeroActivity.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end


function RequestMessageZeroActivity:init(width, height)
    RequestMessageZeroItem.init(self, height)
    self.text:setString(Localization:getInstance():getText("request.message.panel.zero.activity.text"))
    local size = self.text:getContentSize()
    self:setPositionX((width - size.width) / 2)
    self:setPositionY(-40)
end

function RequestMessageZeroActivity:showBottomCloseButton()
    return false
end

RequestMessageZeroNews = class(RequestMessageZeroItem)


RequestMessageZeroWithAskFriend = class(RequestMessageZeroItem)
RequestMessageZeroWithQQLogin = class(RequestMessageZeroItem)
RequestMessageZeroFriendQQLogin = class(RequestMessageZeroWithQQLogin)
RequestMessageZeroEnergyQQLogin = class(RequestMessageZeroWithQQLogin)
RequestMessageZeroUnlockQQLogin = class(RequestMessageZeroWithQQLogin)
RequestMessageZeroNewsPushActivity = class(RequestMessageZeroItem)

--------------------------------------------------------
-- RequestMessageZeroNews
--------------------------------------------------------

function RequestMessageZeroNews:create(width, height)
    local instance = RequestMessageZeroNews.new()
    instance:initLayer()
    instance:init(width, height)
    return instance
end

function RequestMessageZeroNews:init(width, height)
    RequestMessageZeroItem.init(self, height)
    self.text:setString(localize('request.message.panel.news.empty'))
    local size = self.text:getContentSize()
    self:setPositionX((width - size.width) / 2)
    self:setPositionY(-40)
end


function RequestMessageZeroNewsPushActivity:create(width, height)
    local instance = RequestMessageZeroNewsPushActivity.new()
    instance:initLayer()
    instance:init(width, height)
    return instance
end

function RequestMessageZeroNewsPushActivity:init(width, height)
    RequestMessageZeroItem.init(self, height)
    self.text:setString(localize('message.panel.news.empty.activity'))
    local size = self.text:getContentSize()
    self:setPositionX((width - size.width) / 2)
    self:setPositionY(-40)
end

function RequestMessageZeroNewsPushActivity:showBottomCloseButton()
    return false
end



local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
local function buildItemIcon(itemId)
    if ItemType:isTimeProp(itemId) then itemId = ItemType:getRealIdByTimePropId(itemId) end
    local propName = 'Prop_'..itemId
    if itemId == 14 then
        propName = 'homeSceneGoldItem'
    elseif itemId == 2 then
        propName = 'stackIcon'
    end
    return iconBuilder:buildGroup(propName)
end


--------------------------------------------------------
-- RequestMessageZeroWithAskFriend
--------------------------------------------------------
function RequestMessageZeroWithAskFriend:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.request_message_panel)
    local ui = builder:buildGroup('request_message_panel_zero_energy_askFriend2')
    self.ui = ui
    self:addChild(ui)
    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.btn:setColorMode(kGroupButtonColorMode.green)
    self.btn:setString(localize('request.message.panel.energy.btn'))
    self.btn:ad(DisplayEvents.kTouchTap, function () 
        self:onBtnTapped() 
    end)

    self.energyIcon = self.ui:getChildByName('icon')
    self.msg = self.ui:getChildByName('msg')
    local todayWants = UserManager:getInstance():getWantIds()
    if #todayWants < 1 then
        self.energyIcon:setVisible(true)
        self.msg:setVisible(true)
    else
        self.energyIcon:setVisible(false)
        self.msg:setVisible(false)
    end
    

    local size = self:getGroupBounds().size
    local scale = width / (size.width + 40)
    if scale > height / (size.height + 40) then scale = height / (size.height + 40) end
    if scale < 1 then self:setScale(scale)
    else scale = 1 end
    self:setPositionX((width - size.width * scale) / 2)
    self:setPositionY(-(height - size.height * scale) / 2)
end

function RequestMessageZeroWithAskFriend:showBottomCloseButton()
    return false
end

function RequestMessageZeroWithAskFriend:onShow()
    self:setVisible(true)

    local bg = self.ui:getChildByName('bg')
	bg:runAction(CCFadeIn:create(1))
end

function RequestMessageZeroWithAskFriend:onBtnTapped_Ios()
    DcUtil:UserTrack({category = "messageCenter", sub_category = "message_center_ask_freegift"}, true)

    local function onUpdateFriend(result, evt)
        if result == "success" then
            local canGiveFriends = FreegiftManager:sharedInstance():getCanGiveFriends()
            if #canGiveFriends > 0 then
                local function chooseFriendFunc()
                    local function onRequestSuccess()
                        if self.isDisposed then return end
                        self.energyIcon:setVisible(false)
                        self.msg:setVisible(false)
                    end
                    AskForEnergyPanel:popoutPanel(onRequestSuccess)
                end
                PushBindingLogic:runChooseFriendLogic(chooseFriendFunc, 1)
            else
                PushBindingLogic:runPopAddFriendPanelLogic(1)
            end
        else
            local message = ''
            local err_code = tonumber(evt.data)
            if err_code then message = Localization:getInstance():getText("error.tip."..err_code) end
            CommonTip:showTip(message, "negative")
        end
    end
    FreegiftManager:sharedInstance():updateFriendInfos(true, onUpdateFriend)    
end

function RequestMessageZeroWithAskFriend:onBtnTapped()
    DcUtil:UserTrack({category = "messageCenter", sub_category = "message_center_ask_freegift"}, true)
    local function onGetSendListSuccess(isSuccess, askFriendsList, errCode)
        if not isSuccess then return end
        
        if askFriendsList == nil or #askFriendsList < 1 then
            if _G.sns_token then 
                if GoToAddFriendPanel:hasSharePlatform() then
                    GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SHARE}):popout()
                else
                    GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND}):popout()
                end
            else
                GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND}):popout()
            end
            return
        else
            local function onRequestSuccess()
                if self.isDisposed then return end
                self.energyIcon:setVisible(false)
                self.msg:setVisible(false)
            end
            AskForEnergyPanel:popoutPanel(onRequestSuccess, onRequestFail, askFriendsList)
        end
    end

    if not FreegiftManager:sharedInstance():getSendGiftList(onGetSendListSuccess) then
        CommonTip:showTip(localize("freegift.ask.gift.inhandle.warning"), "positive")
    end
end

-- 带索要精力和发送二维码
RequestMessageZeroEnergyTwoButtons = class(RequestMessageZeroItem)
--------------------------------------------------------
-- RequestMessageZeroEnergyTwoButtons
--------------------------------------------------------
function RequestMessageZeroEnergyTwoButtons:create(width, height)
    local ret = RequestMessageZeroEnergyTwoButtons.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroEnergyTwoButtons:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.request_message_panel)
    local ui = builder:buildGroup("request_message_panel_zero_energy")
    self.ui = ui
    self:addChild(ui)
    local bg = ui:getChildByName("bg")
    local text1 = ui:getChildByName("text1")
    local text2 = ui:getChildByName("text2")
    local text3 = ui:getChildByName("text3")
    local btn1UI = ui:getChildByName("btn1")
    local btn2UI = ui:getChildByName("btn2")
    btn1 = GroupButtonBase:create(btn1UI)
    btn2 = GroupButtonBase:create(btn2UI)

    self.energyBtn = btn1
    self.codeBtn = btn2
    self.jjBtn = GroupButtonBase:create(ui:getChildByName('jjBtn'))

    local size = bg:getPreferredSize()
    local scale = width / (size.width + 40)
    if scale > height / (size.height + 40) then scale = height / (size.height + 40) end
    if scale < 1 then self:setScale(scale)
    else scale = 1 end
    self:setPositionX((width - size.width * scale) / 2)
    self:setPositionY(-(height - size.height * scale) / 2)

    text1:setString(Localization:getInstance():getText("request.message.panel.zero.energy.title"))
    text2:setString(Localization:getInstance():getText("request.message.panel.zero.energy.text1"))
    text3:setString(Localization:getInstance():getText("request.message.panel.zero.energy.text3"))
    btn1:setString(Localization:getInstance():getText("request.message.panel.zero.energy.button1"))
   
    btn1:addEventListener(DisplayEvents.kTouchTap, function() self:popAskForEnergy() end)
    btn2:addEventListener(DisplayEvents.kTouchTap, function () self:popQRCode() end)
    if PlatformConfig:isPlatform(PlatformNameEnum.kJJ) then
        btn2:setVisible(false)
        btn2:setEnabled(false)
        self.jjBtn:setVisible(true)
        self.jjBtn:setEnabled(true)
        self.jjBtn:setString(localize('friend.ranking.panel.button.add'))
        self.jjBtn:addEventListener(DisplayEvents.kTouchTap, function () self:popQRCode() end)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then 
        btn2:setString(Localization:getInstance():getText("invite.friend.panel.button.text.mitalk"))
        btn2:setColorMode(kGroupButtonColorMode.blue)
        btn2:setIconByFrameName("common_icon/sns/icon_mi")

        self.jjBtn:setVisible(false)
        self.jjBtn:setEnabled(false)
    else
        btn2:setString(Localization:getInstance():getText("my.card.btn2"))
        btn2:setIconByFrameName("common_icon/sns/icon_wechat")

        self.jjBtn:setVisible(false)
        self.jjBtn:setEnabled(false)
    end
end

function RequestMessageZeroEnergyTwoButtons:popAskForEnergy()    
    local function chooseFriendFunc()
        local function onRequestSuccess()
            -- 没什么可做的
        end
        AskForEnergyPanel:popoutPanel(onRequestSuccess)
    end
    PushBindingLogic:runChooseFriendLogic(chooseFriendFunc)
end
function RequestMessageZeroEnergyTwoButtons:showBottomCloseButton()
    return false
end

function RequestMessageZeroEnergyTwoButtons:popQRCode()
    if PlatformConfig:isPlatform(PlatformNameEnum.kJJ) then
            createAddFriendPanel("recommend")
        return 
    end

    local function restoreBtn()
        if self.codeBtn.isDisposed then return end
        self.codeBtn:setEnabled(true)
    end
    local function onSuccess()
        restoreBtn()
        DcUtil:UserTrack({category = 'message', sub_category = 'message_center_send_qrcode', where = 4}, true)
    end
    local function onError(errCode, msg)
        restoreBtn()
    end
    local function onCancel()
        restoreBtn()
    end

    --just for mitalk
    local shareCallback = {
        onSuccess=function(result)
            CommonTip:showTip(Localization:getInstance():getText("share.feed.invite.success.tips"), "positive")
            restoreBtn()
            DcUtil:UserTrack({category = 'message', sub_category = 'message_center_send_qrcode', where = 4}, true)
        end,
        onError=function(errCode, msg)
            if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
                CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips.mitalk"), "negative")
            else
                CommonTip:showTip(Localization:getInstance():getText("share.feed.invite.code.faild.tips"), "negative")
            end
            restoreBtn()
        end,
        onCancel=function()
            CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips"), "positive")
            restoreBtn()
        end
    }

    self.codeBtn:setEnabled(false)
    setTimeOut(restoreBtn, 2)

    if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then        
        SnsUtil.sendInviteMessage(PlatformShareEnum.kMiTalk, shareCallback)
    else
        PersonalCenterManager:sendBusinessCard(onSuccess, onError, onCancel)
    end 
end

function RequestMessageZeroEnergyTwoButtons:setVisible(visible)
    RequestMessageZeroItem.setVisible(self, visible)
    self.energyBtn:setEnabled(visible)
    self.codeBtn:setEnabled(visible)
end

---------------------------------------new panels-------------------------------------------
RequestMessageZero_AddFriend = class(RequestMessageZeroItem)
--------------------------------------------------------
-- RequestMessageZero_AddFriend
--------------------------------------------------------
function RequestMessageZero_AddFriend:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.request_message_panel)
    local ui = builder:buildGroup('request_message_panel/zero/addFriend')
    self.ui = ui
    self:addChild(ui)

    ui:getChildByName('msg'):setVisible(false)

    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.btn:setColorMode(kGroupButtonColorMode.green)
    self.btn:setString(localize('message.center.panel.zero.friend.btn'))
    self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)

    local size = self:getGroupBounds().size
    local scale = width / (size.width + 40)
    if scale > height / (size.height + 40) then scale = height / (size.height + 40) end
    if scale < 1 then 
        self:setScale(scale)
    else 
        scale = 1 
    end
    self:setPositionX((width - size.width * scale) / 2)
    self:setPositionY(-(height - size.height * scale) / 2)
end

function RequestMessageZero_AddFriend:onShow()
    self:setVisible(true)

    local bg = self.ui:getChildByName('bg')
	bg:runAction(CCFadeIn:create(1))
end

function RequestMessageZero_AddFriend:showBottomCloseButton()
    return false
end

function RequestMessageZero_AddFriend:onBtnTapped()
    DcUtil:UserTrack({category = "messageCenter", sub_category = "message_center_add_friend", t1=1}, true)
 	if FriendManager:getInstance():isFriendCountReachedMax() then
		createAddFriendPanel("recommend")
	else
		PushBindingLogic:runPopAddFriendPanelLogic(10)
	end
end

-------------------------------------------------------------------
RequestMessageZeroWithAskFriend_Unlock = class(RequestMessageZeroItem)
function RequestMessageZeroWithAskFriend_Unlock:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.request_message_panel)
    local ui = builder:buildGroup('request_message_panel/zero/unlock')
    self.ui = ui
    self:addChild(ui)

    ui:getChildByName('msg'):setVisible(false)

    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.btn:setColorMode(kGroupButtonColorMode.green)
    self.btn:setString(localize('message.center.panel.zero.unlock.btn'))
    self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)

    local size = self:getGroupBounds().size
    local scale = width / (size.width + 40)
    if scale > height / (size.height + 40) then 
        scale = height / (size.height + 40) 
    end

    if scale < 1 then 
        self:setScale(scale)
    else 
        scale = 1 
    end
    self:setPositionX((width - size.width * scale) / 2)
    self:setPositionY(-(height - size.height * scale) / 2)
end

function RequestMessageZeroWithAskFriend_Unlock:onShow()
    self:setVisible(true)
    local bg = self.ui:getChildByName('bg')
	bg:runAction(CCFadeIn:create(1))
end

function RequestMessageZeroWithAskFriend_Unlock:showBottomCloseButton()
    return false
end

function RequestMessageZeroWithAskFriend_Unlock:onBtnTapped()
    DcUtil:UserTrack({category = "messageCenter", sub_category = "message_center_add_friend", t1=2}, true)
 	if FriendManager:getInstance():isFriendCountReachedMax() then
		createAddFriendPanel("recommend")
	else
		PushBindingLogic:runPopAddFriendPanelLogic(11)
	end
end