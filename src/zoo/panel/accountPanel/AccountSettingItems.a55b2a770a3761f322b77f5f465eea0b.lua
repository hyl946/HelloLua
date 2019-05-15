require 'zoo.panel.component.common.LayoutItem'
BaseAccountSettingItem = class(ItemInLayout)
PhoneAccountItem = class(BaseAccountSettingItem)
ThirdPartyAccountItem = class(BaseAccountSettingItem)
WeiboAccountItem = class(ThirdPartyAccountItem)
QQAccountItem = class(ThirdPartyAccountItem)
QihooAccountItem = class(ThirdPartyAccountItem)
WdjAccountItem = class(ThirdPartyAccountItem)
MitalkAccountItem = class(ThirdPartyAccountItem)
WechatAccountItem = class(ThirdPartyAccountItem)
-- .....

local PlatformAccountIcons = {
    [PlatformAuthEnum.kQQ]    = "qq",
    [PlatformAuthEnum.kPhone] = "phone",
    [PlatformAuthEnum.kWeibo] = "weibo",
    [PlatformAuthEnum.k360]   = "360",
    [PlatformAuthEnum.kWDJ]   = "wdj",
    [PlatformAuthEnum.kMI]    = "mi",
    [PlatformAuthEnum.kWechat]= "wechat",
}

AccountItemHelper = {}
function AccountItemHelper:create(v)
    local item
    if v == PlatformAuthEnum.kPhone then
        item = PhoneAccountItem:create()
    elseif v == PlatformAuthEnum.kQQ then
        item = QQAccountItem:create()
    elseif v == PlatformAuthEnum.kWeibo then
        item = WeiboAccountItem:create()
    elseif v == PlatformAuthEnum.k360 then
        item = QihooAccountItem:create()
    elseif v == PlatformAuthEnum.kWDJ then
        item = WdjAccountItem:create()
    elseif v == PlatformAuthEnum.kMI then
        item = MitalkAccountItem:create()
    elseif v == PlatformAuthEnum.kWechat then
        item = WechatAccountItem:create()
    end
    return item
end

local AccountNameNode = class()

function AccountNameNode:create(ui)
    local node = AccountNameNode.new()
    node:init(ui)
    return node
end

function AccountNameNode:init(ui)
    self.ui = ui
    self.textLabel = self.ui:getChildByName("text")
    local textColor = self.textLabel:getColor()
    self._textOriginColor = {r = textColor.r, g = textColor.g, b = textColor.b}
    self.underLine = self.ui:getChildByName("under_line")
    self._underLineWidth = self.underLine:getGroupBounds(ui).size.width
    self.underLine:setPositionY(self.textLabel:getPositionY() - 35)
    self.underLine:setVisible(false)
end

function AccountNameNode:setTouchEnable(enable)
    if self.ui and not self.ui.isDisposed then
        self.ui:setTouchEnabled(enable)
        self.ui:setButtonMode(enable)
        if enable then
            self.textLabel:setColor(hex2ccc3("00A3FF"))
            self.underLine:setVisible(true)
        else
            self.textLabel:setColor(ccc3(self._textOriginColor.r, self._textOriginColor.g, self._textOriginColor.b))
            self.underLine:setVisible(false)
        end
    end
end

function AccountNameNode:setOnClickCallback(callback)
    if self.ui and not self.ui.isDisposed then
        self.ui:rma()
        local function onTapped(evt)
            if callback then callback(evt) end
        end
        self.ui:ad(DisplayEvents.kTouchTap, onTapped)
    end
end

function AccountNameNode:setString(text)
    if self.ui and not self.ui.isDisposed then
        if text then
            text = TextUtil:ensureTextWidth( tostring(text), self.textLabel:getFontSize(), self.textLabel:getDimensions() )
        end
        self.textLabel:setString(text or "")
        local size = self.textLabel:getContentSize()
        if self._underLineWidth > 0 then
            self.underLine:setScaleX(size.width / self._underLineWidth)
        end
    end
end

function AccountNameNode:setVisible(isVisible)
    if self.ui and not self.ui.isDisposed then
        self.ui:setVisible(isVisible)
    end
end

----------------------- BaseAccountSettingItem --------------------
function BaseAccountSettingItem:create()
    local instance = self.new()
    instance:loadRequiredResource()
    instance:init()
    return instance
end
function BaseAccountSettingItem:setMainPanel(panel)
    self.mainPanel = panel
end
function BaseAccountSettingItem:init(config)
    ItemInLayout.init(self)
    local ui = self.builder:buildGroup('accountSettingPanel/account_item')
    self.ui = ui
    self.icon = ui:getChildByName('icon')
    self.accountNameNode = AccountNameNode:create(ui:getChildByName('account'))
    self.desc = ui:getChildByName('desc')
    self.icon:getChildByName("resDot"):setVisible(false)
    self.accountIconNode = self.icon:getChildByName("sprite")
    self.accountIconNode:setChildrenVisible(false, true)

    local showAccIcon = config.accIcon or "setting"
    local accountIcon = self.accountIconNode:getChildByName(showAccIcon)
    if accountIcon then accountIcon:setVisible(true) end
    -- self.ph = ui:getChildByName('ph')
    -- self.ph:setVisible(false)
    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))

    self._btnOriginPosX = self.btn:getPositionX()
    self._accountOriginPosX = self.accountNameNode.ui:getPositionX()

    self:setContent(ui)
    if config then
        self.config = config
        if config.platformName then
            self.desc:setString(PlatformConfig:getPlatformNameLocalization(config.platformName))
            if self:getAccountAuthName(config.platformName) then
                self.accountNameNode:setString(self:getAccountAuthName(config.platformName))
                self.btn:setVisible(false)
            else
                self.accountNameNode:setVisible(false)
            end
        end
    end
    self:setButtonRedDotVisible(false)
end
function BaseAccountSettingItem:getAccountAuthName(platform)
    return UserManager:getInstance().profile:getSnsUsername(platform)
end

function BaseAccountSettingItem:loadRequiredResource()
    self.builder = InterfaceBuilder:createWithContentsOfFile("ui/panel_account_setting.json")
end
function BaseAccountSettingItem:update()
end

function BaseAccountSettingItem:setBtnAndAccountIndent(indent)
    indent = indent or -65
    if type(indent) == "number" then
        self.btn:setPositionX(self._btnOriginPosX + indent)
        self.accountNameNode.ui:setPositionX(self._accountOriginPosX + indent)
    end
end

function BaseAccountSettingItem:addRewardTip(rewardId, num)
    if rewardId then
        local rewardTip = self.builder:buildGroup("accountSettingPanel/account_reward_tip")
        rewardTip.name = "rewardTip"
        self.ui:addChild(rewardTip)
        local btnGb = self.btn:getGroupBounds(self.ui)
        rewardTip:setPosition(ccp(btnGb.origin.x + btnGb.size.width - 20, btnGb.origin.y + 20))

        local iconHolder = rewardTip:getChildByName("icon")
        local zOrder = iconHolder:getZOrder()
        local iconSize = iconHolder:getGroupBounds().size
        local iconPos = iconHolder:getPosition()

        local itemIcon = ResourceManager:sharedInstance():buildItemGroup(rewardId)
        local itemHeight = itemIcon:getGroupBounds().size.height
        itemIcon:setAnchorPoint(ccp(0.5, 0.5))
        itemIcon:ignoreAnchorPointForPosition(false)
        itemIcon:setScale(iconSize.height / itemHeight)
        itemIcon:setPosition(ccp(iconPos.x, iconPos.y))
        rewardTip:addChildAt(itemIcon, zOrder)
        iconHolder:removeFromParentAndCleanup(true)

        local fntFile = "fnt/target_amount.fnt"
        local numTf = BitmapText:create('', fntFile)
        numTf:setAnchorPoint(ccp(0.5, 0.5))
        numTf:setPreferredSize(90, 28)
        numTf:setPositionXY(76, 15)
        numTf:setText('x' .. num)
        rewardTip:addChild(numTf)

        self.rewardTip = rewardTip
        -- self:setBtnAndAccountIndent(-65)
    end
end

function BaseAccountSettingItem:removeRewardTip()
    if self.rewardTip then 
        self.rewardTip:removeFromParentAndCleanup(true)
        self.rewardTip = nil
    end
end

function BaseAccountSettingItem:setButtonRedDotVisible(isVisible)
    if self.btn and self.btn.groupNode then
        local redDot = self.btn.groupNode:getChildByName("redDot")
        if redDot then 
            redDot:setVisible(isVisible)
        end
    end
end

--------------------- PhoneAccountItem ------------------
function PhoneAccountItem:init()
    local config = {labelKey = 'setting.panel.intro.2', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.kPhone]}
    BaseAccountSettingItem.init(self, config)
    self.desc:setString(localize("platform.phone"))
    self.btn:ad(DisplayEvents.kTouchTap, function() self:onBtnTapped() end)
    self:update()
end

function PhoneAccountItem:update()
    local function secretPhone(phone)
        return string.sub(phone, 1, 3).. string.rep("*",4) ..string.sub(phone, -4)
    end
    if self:isPhoneBinded() then
        self.btn:setVisible(false)
        self.btn:setEnabled(false)
        self.accountNameNode:setVisible(true)

        local phone = self:getAccountAuthName(PlatformAuthEnum.kPhone)
        if #phone == 11 then
            phone = secretPhone(phone)
        end
        if self:isAllowChangePhoneBinding() then
            self.accountNameNode:setString(phone)
            self.accountNameNode:setTouchEnable(true)
            if self.accountNameNode.underLine then
                self.accountNameNode.underLine:setScaleX(0.94)
            end
            local function onBtnTapped( ... )
                if self.mainPanel and not self.mainPanel.isDisposed then
                    self.mainPanel:removeSelf()
                    self.mainPanel:changePhoneBinding()
                end
            end
            self.accountNameNode:setOnClickCallback(onBtnTapped)
        else
            self.accountNameNode:setString(phone)
            self.accountNameNode:setTouchEnable(false)
        end
    else
        self.accountNameNode:setVisible(false)
        self.btn:setString(localize('setting.panel.button.2'))
        self.btn:setEnabled(true)
        self.btn:setColorMode(kGroupButtonColorMode.blue)
        -- self.notBinded:setString(localize(self.config.nobindedKey))
    end
end

function PhoneAccountItem:onBtnTapped()
    if self:isPhoneBinded() then
        if self:isAllowChangePhoneBinding() then
            if self.mainPanel and not self.mainPanel.isDisposed then
                self.mainPanel:removeSelf()
                self.mainPanel:changePhoneBinding()
            end
        end
    else
        if self.mainPanel and not self.mainPanel.isDisposed then
            self.mainPanel:bindNewPhone()
        end
    end
end

function PhoneAccountItem:isPhoneBinded()
    if UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) ~= nil then
        return true
    end
    return false
end

function PhoneAccountItem:isAllowChangePhoneBinding()
    local val = UserManager:getInstance().userExtend:allowChangePhoneBinding()
    return val
end

----------------- ThirdPartyAccountItem ----------------------
function ThirdPartyAccountItem:init(config)
    BaseAccountSettingItem.init(self, config)
    self:update()
end

function ThirdPartyAccountItem:update()
    local account = self:getAccountAuthName(self.config.platformName)
    if _G.isLocalDevelopMode then printx(0, "platformName: ", self.config.platformName, " ,account: ", account) end
    if not account then
        self.btn:setVisible(true)
        self.btn:setEnabled(true)
        self.accountNameNode:setVisible(false)
        self.btn:setString(localize('setting.panel.button.2'))
        self.btn:setColorMode(kGroupButtonColorMode.blue)
        self.btn:removeEventListenerByName(DisplayEvents.kTouchTap)
        self.btn:ad(DisplayEvents.kTouchTap, function () self:onBtnTapped() end)
    else
        self.btn:setVisible(false)
        self.btn:setEnabled(false)
        self.accountNameNode:setVisible(true)
        self.accountNameNode:setString(account)
        -- self.notBinded:setString('')
    end
end

function ThirdPartyAccountItem:onBtnTapped()
    self.btn:setEnabled(false)
    if self.mainPanel and not self.mainPanel.isDisposed then
        self.mainPanel:bindNewSns(self.config.platformName, self.rewardTip ~= nil)
    end
end

------ QQAccountItem WeiboAccountItem QihooAccountItem ... ---------
function QQAccountItem:init()
    local config = {platformName = PlatformAuthEnum.kQQ, labelKey = 'setting.panel.intro.3', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.kQQ]}
    ThirdPartyAccountItem.init(self, config)
end

function WeiboAccountItem:init()
    local config = {platformName = PlatformAuthEnum.kWeibo, labelKey = 'setting.panel.intro.4', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.kWeibo]}
    ThirdPartyAccountItem.init(self, config)
end

function QihooAccountItem:init()
    local config = {platformName = PlatformAuthEnum.k360, labelKey = 'setting.panel.intro.5', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.k360]}
    ThirdPartyAccountItem.init(self, config)
end

function WdjAccountItem:init()
    local config = {platformName = PlatformAuthEnum.kWDJ, labelKey = 'setting.panel.intro.6', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.kWDJ]}
    ThirdPartyAccountItem.init(self, config)
end

function MitalkAccountItem:init()
    local config = {platformName = PlatformAuthEnum.kMI, labelKey = 'setting.panel.intro.7', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.kMI]}
    ThirdPartyAccountItem.init(self, config)
end

function WechatAccountItem:init()
    local config = {platformName = PlatformAuthEnum.kWechat, labelKey = 'setting.panel.intro.10', nobindedKey = 'setting.panel.intro.8', accIcon = PlatformAccountIcons[PlatformAuthEnum.kWechat]}
    ThirdPartyAccountItem.init(self, config)
end