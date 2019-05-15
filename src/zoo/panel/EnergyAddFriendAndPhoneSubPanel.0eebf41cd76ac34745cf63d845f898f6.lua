EnergyAddFriendAndPhoneSubPanel = class(BaseUI)

function EnergyAddFriendAndPhoneSubPanel:create()
    local instance = EnergyAddFriendAndPhoneSubPanel.new()
    instance:init()
    instance.panelPluginType = "Pendant"
    return instance
end

function EnergyAddFriendAndPhoneSubPanel:init()
    local ui = ResourceManager:sharedInstance():buildGroup("energy_AddFriend_phone_panel")
    BaseUI.init(self, ui)

    self.phoneDesc = self.ui:getChildByName('desc_phone')
    self.qqDesc = self.ui:getChildByName('desc_qq')
    self.btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
    self.btn:ad(DisplayEvents.kTouchTap, function() self:onBtnTapped() end)
end

function EnergyAddFriendAndPhoneSubPanel:showPhone()
    self.qqDesc:setVisible(false)
    self.phoneDesc:setVisible(true)
    self.btn:setString('手机登录')
    self.isPhone = true
end

function EnergyAddFriendAndPhoneSubPanel:showQQ()
    self.qqDesc:setVisible(true)
    self.phoneDesc:setVisible(false)
    self.btn:setString(localize('friend.ranking.panel.button.add'))
    self.isPhone = false
end

function EnergyAddFriendAndPhoneSubPanel:onQQBtnTapped()
    DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_add_friend"}, true)
    PushBindingLogic:runPopAddFriendPanelLogic(5)
end

function EnergyAddFriendAndPhoneSubPanel:onPhoneBtnTapped()
    local function onReturnCallback()
        CommonTip:showTip(localize('add.friend.panel.cancel.login.phone'))
    end
    local function onBindSuccessCallback()
        DcUtil:UserTrack({category = 'login', sub_category = 'login_phone_success_source', t1 = 1})
        CommonTip:showTip(localize('手机绑定成功'), 'positive') -- text@wenkan
    end
    AccountBindingLogic:bindNewPhone(onReturnCallback, onBindSuccessCallback, source)
end

function EnergyAddFriendAndPhoneSubPanel:onBtnTapped()
    if self.isPhone then
       self:onPhoneBtnTapped()
    else
        self:onQQBtnTapped()
    end
end