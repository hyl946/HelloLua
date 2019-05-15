require 'zoo.panel.component.common.LayoutItem'
require 'zoo.panel.component.common.VerticalTileLayout'

FreeCashTaskPanel = class(BasePanel)

function FreeCashTaskPanel:create()
    local instance = FreeCashTaskPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.panel_buy_gold)
    instance:init()
    return instance
end

function FreeCashTaskPanel:init()
    local ui = self:buildInterfaceGroup('get_free_cash_panel')
    BasePanel.init(self, ui)
    local title = ui:getChildByName('title')
    local desc = ui:getChildByName('desc')
    local duomengBtn = ui:getChildByName('btn1')
    local MBiBtn = ui:getChildByName('btn2')
    local closeBtn = ui:getChildByName('closeBtn')
    local bg = ui:getChildByName('bg')

    title:setString(Localization:getInstance():getText('free.cash.task.panel.title'))
    desc:setString(Localization:getInstance():getText('free.cash.task.panel.desc', {n = '\n'}))
    closeBtn:setTouchEnabled(true)
    closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)  local holder = ui:getChildByName('holder')

    bg:setVisible(false)
    local lc = LayerColor:create()
    lc:ignoreAnchorPointForPosition(false)
    lc:setAnchorPoint(ccp(0, 1))
    lc:setColor(ccc3(0,0,0))
    lc:setOpacity(200)
    -- lc:setContentSize(ui:getGroupBounds().size)
    lc:setContentSize(CCSizeMake(720, 900))
    lc:setPositionX(bg:getPositionX())
    lc:setPositionY(bg:getPositionY())
    bg:getParent():addChildAt(lc, bg:getZOrder())

    holder:setVisible(false)
    local layout = VerticalTileLayout:create(holder:getGroupBounds().size.width)
    layout:setPositionX(holder:getPositionX())
    layout:setPositionY(holder:getPositionY())
    holder:getParent():addChildAt(layout, holder:getZOrder())

    if MaintenanceManager:getInstance():isEnabled("FreeCash_1") then
        local domobItem = self:buildInterfaceGroup('DomobItem')
        domobItem:getChildByName('bg'):setVisible(false)
        local btn = domobItem:getChildByName('btn')
        btn:setButtonMode(true)
        btn:setTouchEnabled(true)
        btn:ad(DisplayEvents.kTouchTap, function () self:onDuoMengBtnTapped() end)
        local item = ItemInLayout:create()
        item:setContent(domobItem)
        layout:addItem(item)
    end

    if MaintenanceManager:getInstance():isEnabled("FreeCash_2") then
        local MBiItem = self:buildInterfaceGroup('MBiItem')
        MBiItem:getChildByName('bg'):setVisible(false)
        local btn = MBiItem:getChildByName('btn')
        btn:setButtonMode(true)
        btn:setTouchEnabled(true)
        btn:ad(DisplayEvents.kTouchTap, function () self:onMBiBtnTapped() end)
        local item = ItemInLayout:create()
        item:setContent(MBiItem)
        layout:addItem(item)
    end

    if MaintenanceManager:getInstance():isEnabled("FreeCash_3") then
        local AdwoItem = self:buildInterfaceGroup('AdwoItem')
        AdwoItem:getChildByName('bg'):setVisible(false)
        local btn = AdwoItem:getChildByName('btn')
        btn:setButtonMode(true)
        btn:setTouchEnabled(true)
        btn:ad(DisplayEvents.kTouchTap, function () self:onAdwoBtnTapped() end)
        local item = ItemInLayout:create()
        item:setContent(AdwoItem)
        layout:addItem(item)
    end


end

function FreeCashTaskPanel:onDuoMengBtnTapped()
    if _G.isLocalDevelopMode then printx(0, 'FreeCashTaskPanel onDuoMengBtnTapped') end
    self:onCloseBtnTapped()
    local advertiseSDK = AdvertiseSDK.new()
    advertiseSDK:presentDomobListOfferWall()
end

function FreeCashTaskPanel:onMBiBtnTapped()
    if _G.isLocalDevelopMode then printx(0, 'FreeCashTaskPanel:onMBiBtnTapped') end
    self:onCloseBtnTapped()
    local advertiseSDK = AdvertiseSDK.new()
    advertiseSDK:presentLimeiListOfferWall()
end

function FreeCashTaskPanel:onAdwoBtnTapped()
    if _G.isLocalDevelopMode then printx(0, 'FreeCashTaskPanel:onMBiBtnTapped') end
    self:onCloseBtnTapped()
    local advertiseSDK = AdvertiseSDK.new()
    advertiseSDK:presentAdwoListOfferWall()
end

function FreeCashTaskPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self, true)
    self.allowBackKeyTap = false
end

function FreeCashTaskPanel:popout()
    self:setPositionForPopoutManager()
    self:setPositionY(self:getPositionY() - 43)
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
    self.allowBackKeyTap = true 
end

