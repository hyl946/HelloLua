require 'zoo.panel.accountPanel.AccountSettingItems'
require 'zoo.panel.accountPanel.AccountSettingSubPanels'
require 'zoo.account.AccountBindingLogic'

AccountSettingPanel = class(BasePanel)
function AccountSettingPanel:create()
    local instance = AccountSettingPanel.new()
    instance:loadRequiredResource("ui/panel_account_setting.json") -- PanelConfigFiles.panel_game_setting
    instance:init()
    return instance
end

function AccountSettingPanel:init()
    local ui = self.builder:buildGroup('accountSettingPanel/settingPanel')
    BasePanel.init(self, ui)
    self.panelBg1 = ui:getChildByName('bg1')
    self.panelBg2 = ui:getChildByName('bg2')
    self.panelTitle = ui:getChildByName('title')
    self.panelTitle:setText('账号设置')

    local size = self.panelTitle:getContentSize()
    local scale = 65 / size.height
    self.panelTitle:setScale(scale)
    self.panelTitle:setPositionX((self.panelBg1:getGroupBounds().size.width - size.width * scale) / 2)

    self.closeBtn = ui:getChildByName('close_btn')
    self.closeBtn:setButtonMode(true)
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)
    self:initAccountItems()
end

function AccountSettingPanel:onEnterHandler(event, ...)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:runAction(self:createShowAnim())
        if not CCUserDefault:sharedUserDefault():getBoolForKey("game.account.bind.rcmd.redDot") then
            CCUserDefault:sharedUserDefault():setBoolForKey("game.account.bind.rcmd.redDot", true)
            CCUserDefault:sharedUserDefault():flush()
            
            if HomeScene:sharedInstance().settingButton then
                HomeScene:sharedInstance().settingButton:updateDotTipStatus()
            end
        end
    end
end

function AccountSettingPanel:createShowAnim()
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

    local function onEnterAnimationFinished() self:onEnterAnimationFinished() end
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)
    actionArray:addObject(CCCallFunc:create(onEnterAnimationFinished))
    return CCSequence:create(actionArray)
end

function AccountSettingPanel:onEnterAnimationFinished()

end

function AccountSettingPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)
    self.allowBackKeyTap = true
end

function AccountSettingPanel:removeSelf()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)

    if self.bindCallBack then
        self.bindCallBack()
    end
end

function AccountSettingPanel:onCloseBtnTapped()
    self:removeSelf()
    --AccountPanel:create():popout()
end

function AccountSettingPanel:initAccountItems()
    local otherAccounts = {}
    local authConfig = PlatformConfig.authConfig

    if type(authConfig) == 'table' then
        for k, v in pairs(authConfig) do
            if v ~= PlatformAuthEnum.kGuest then
                table.insert(otherAccounts, v)
            end
        end
    else
        if authConfig ~= PlatformAuthEnum.kGuest then
            table.insert(otherAccounts, authConfig)
        end
    end

    table.sort(otherAccounts,function(a,b) return PlatformAuthPriority[a] < PlatformAuthPriority[b] end)

    local qqIndex = table.indexOf(otherAccounts, PlatformAuthEnum.kQQ)
    if qqIndex and AccountBindingLogic:isQQNotRecommand() and not UserManager.getInstance().profile:isQQBound() then
        table.remove(otherAccounts, qqIndex)
    end

    local ph = self.ui:getChildByName('ph')
    local pos = ph:getPosition()
    ph:setVisible(false)
    local layoutWidth = ph:getContentSize().width * ph:getScaleX()
    local layout = VerticalTileLayout:create(layoutWidth)
    layout:setItemVerticalMargin(0)
    self.otherAccountItems = {}

    for k, v in pairs(otherAccounts) do
        local item = AccountItemHelper:create(v)
        if not item then 
            assert(false, 'AccountSettingPanel:initAccountItems error')
            return 
        end
        self.otherAccountItems[v] = item
        item:setMainPanel(self)
        layout:addItem(item)

        if k ~= #otherAccounts then
            local decoItem = ItemInLayout:create()
            local res = self:buildInterfaceGroup('accountSettingPanel/separator_line')
            decoItem:setContent(res)
            layout:addItem(decoItem)
        end
    end

    self:updateAccountItems()

    self.layout = layout
    layout:setPosition(ccp(pos.x, pos.y))
    ph:getParent():addChildAt(layout, ph:getZOrder())

    local deltaHeight = layout:getHeight()
    self.panelBg2:setPreferredSize(CCSizeMake(self.panelBg2:getContentSize().width, self.panelBg2:getContentSize().height+deltaHeight))
    self.panelBg1:setPreferredSize(CCSizeMake(self.panelBg1:getContentSize().width, self.panelBg1:getContentSize().height+deltaHeight))
end

function AccountSettingPanel:updateAccountItems()
    local rcmdAccountType = AccountBindingLogic:getRcmdAccountType()
    --rcmdAccountType 其它包依赖这个字段选择 QQ或phone
    --360包固定是 360登录，不依赖这个字段

    local isShowRewardTip = BindQQBonus:loginRewardEnabled() or BindPhoneBonus:loginRewardEnabled() or BindQihooBonus:loginRewardEnabled()
    if _G.sns_token then
        isShowRewardTip = false
    end

    for k, item in pairs(self.otherAccountItems) do
        if isShowRewardTip then
            item:setBtnAndAccountIndent(-70)
        else
            item:setBtnAndAccountIndent(0)
        end
        self.rewardId = nil
        item:removeRewardTip()
        item:setButtonRedDotVisible(false)
        if k == rcmdAccountType then
            if isShowRewardTip then
                local itemID, num, rewardId = PushBindingLogic:getPushBindAward(k)
                if itemID == nil then
                    if rcmdAccountType == PlatformAuthEnum.kQQ then
                        itemID, num, rewardId = BindQQBonus:getBindRewards()
                    elseif rcmdAccountType == PlatformAuthEnum.kPhone then
                        itemID, num, rewardId = BindPhoneBonus:getBindRewards()
                    elseif rcmdAccountType == PlatformAuthEnum.k360 then
                        itemID, num, rewardId = BindQihooBonus:getBindRewards()
                    end
                end
                if itemID ~= nil then 
                    item:addRewardTip(itemID, num) 
                    self.rewardId = rewardId
                end
            else
                item:setButtonRedDotVisible(true)
            end
        end
    end
end

function AccountSettingPanel:changePhoneBinding()
    local function onReturnCallback()
        AccountSettingPanel:create():popout()
    end

    local function onConfirmCallback()
        self:removeSelf()
    end

    AccountBindingLogic:changePhoneBinding(onConfirmCallback, onReturnCallback)
end

function AccountSettingPanel:bindNewPhone()
    local function onReturnCallback()
        -- AccountPanel:create():popout()
        AccountSettingPanel:create():popout()
    end

    local function onSuccess()
        AccountSettingPanel:create():popout()

        

        if BindPhoneBonus:shouldGetReward() then 
            BindPhoneBonus:receiveReward(false, self.rewardId) 
        end

        if self.bindCallBack then
            self.bindCallBack()
        end
    end

    self:removeSelf()
    AccountBindingLogic:bindNewPhone(onReturnCallback, onSuccess, AccountBindingSource.ACCOUNT_SETTING)
end

function AccountSettingPanel:bindConnect( authorizeType,snsInfo,sns_token )
    if not snsInfo then
        snsInfo = { snsName = Localization:getInstance():getText("game.setting.panel.use.device.name.default") }
    end
    local function callback()
        if self.isDisposed then return end
        if authorizeType ~= PlatformAuthEnum.kPhone then
            self:updateOtherAccount(authorizeType) 
        else
            AccountSettingPanel:create():popout()
        end
    end
    -- 三个callback做的事都一样，但留下三个函数方便以后修改
    local function onConnectFinish()
        callback()
    end
    local function onConnectError()
        callback()
    end
    local function onConnectCancel()
        callback()
    end
    AccountBindingLogic:bindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.ACCOUNT_SETTING)
end

function AccountSettingPanel:updateOtherAccount( authorizeType )
    if self.isDisposed then 
        return
    end

    self:updateAccountItems()

    local v = authorizeType
    local res = self.otherAccountItems[v]
    if not res then 
        return
    end

    res:update()
end

function AccountSettingPanel:hasRewardTip( authorizeType  )
    if self.otherAccountItems and self.otherAccountItems[authorizeType] then
        return self.otherAccountItems[authorizeType].rewardTip ~= nil
    end
end

function AccountSettingPanel:bindNewSns( authorizeType, hasReward )


    local function callback()
        if not self.isDisposed then
            self:updateOtherAccount(authorizeType) 
        end
    end
    -- 三个callback做的事都一样，但留下三个函数方便以后修改
    local function onConnectFinish()
        if authorizeType == PlatformAuthEnum.kQQ and BindQQBonus:shouldGetReward() then 
            BindQQBonus:receiveReward(false, self.rewardId) 
        end

        if authorizeType == PlatformAuthEnum.k360 and BindQihooBonus:shouldGetReward() then 
            BindQihooBonus:receiveReward(false, self.rewardId) 
        end
        callback()
    end
    local function onConnectError()
        callback()
    end
    local function onConnectCancel()
        callback()
    end
    AccountBindingLogic:bindNewSns(authorizeType, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.ACCOUNT_SETTING, hasReward)
    
end


function AccountSettingPanel:getAccountAuthName(accountKey)
    return UserManager:getInstance().profile:getSnsUsername(accountKey)
end
