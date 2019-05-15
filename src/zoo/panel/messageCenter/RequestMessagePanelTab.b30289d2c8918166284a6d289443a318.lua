require 'zoo.panel.component.common.HorizontalScrollable'
require 'zoo.panel.component.common.VerticalTileLayout'
-----------------------------------------------------
-- RequestMessagePanelTab
-----------------------------------------------------

local TabButtonController = class()

function TabButtonController:create()
    local ctrl = TabButtonController.new()
    ctrl:init()
    return ctrl
end

function TabButtonController:init()
end

function TabButtonController:initTab(tab, config)
    assert(tab)
    assert(config)

    self.tabUi = tab
    tab.txt = tab:getChildByName('txt')
    tab.numTip = getRedNumTip()
    tab.numTip:setPositionXY(93, -17)
    tab:addChild(tab.numTip)
    tab.number = config.number
    tab.locator = tab:getChildByName('arrowLocator')
    tab.locator:setVisible(false)
    tab.rect = tab:getChildByName('rect')
    tab.rect:setVisible(false)
    local dimension = tab.txt:getDimensions()
    local txtPos = tab.txt:getPosition()
    tab.txt:setDimensions(CCSizeMake(0, 0))
    tab.txt:setString(Localization:getInstance():getText(config.key))
    local size = tab.txt:getContentSize()
    -- tab.txt:setPositionX(txtPos.x+(size.width-dimension.width)/2)
    tab.locator:setPositionX(tab.txt:getPositionX()+size.width/2-5)
    tab:setTouchEnabled(true, 0, true)
    tab:setButtonMode(false)
    tab.normalPos = ccp(tab.txt:getPositionX(), tab.txt:getPositionY())
    tab.focusPos = ccp(tab.txt:getPositionX() , tab.txt:getPositionY() + 15)
    local tabSize = tab:getGroupBounds().size
    -- tab:setPositionX(rectGb.size.width/2)
    tab:setPositionY(tabSize.height+2)
end

function TabButtonController:hideNumberDisplay(tab)
    if not tab then return end
    tab.numTip:setNum(0)
end

function TabButtonController:updateNumberDisplay(tab)
    if not tab then return end
    local size = tab.txt:getContentSize()
    if not tab.number then
        tab.numTip:setNum(0)
    else
        tab.numTip:setNum(tab.number)
        if tab.number > 99 then
            tab.numTip:setPositionX(tab.txt:getPositionX() + size.width + 13)
        else
            local offset = 12
            if tab.number >= 10 then offset = 6 end
            tab.numTip:setPositionX(tab.txt:getPositionX() + size.width + 13)
        end
    end
end

local IconTabButtonController = class(TabButtonController)

function IconTabButtonController:create()
    local ctrl = IconTabButtonController.new()
    ctrl:init()
    return ctrl
end

function IconTabButtonController:init()
    TabButtonController.init(self)
end

function IconTabButtonController:updateNumberDisplay(tab)
    if not tab then return end
    local size = tab.txt:getContentSize()
    if not tab.number then
        self:hideNumberDisplay(tab)
    else
        tab.numTip:setNum(tab.number)
    end
end

RequestMessagePanelTab = class(BaseUI)

function RequestMessagePanelTab:create(config)
    local instance = RequestMessagePanelTab.new()
    instance:loadRequiredResource(PanelConfigFiles.request_message_panel)
    instance:init(config)
    return instance
end

function RequestMessagePanelTab:loadRequiredResource(config)
    self.builder = InterfaceBuilder:create(config)
end

function RequestMessagePanelTab:init(config)
    local ui = self.builder:buildGroup('request_message_tabs_long')
    BaseUI.init(self, ui)

    self.animDuration = 0.25

    self.config = config
    self.colorConfig = {
        normal = ccc3(157, 116, 75),
        focus = ccc3(243, 93, 99)
    }

    self.curIndex = 1

    self.arrow = ui:getChildByName('market_tabArrow')
    self.arrow:removeFromParentAndCleanup(false)

    self.tabs = {}
    local count = #config

    local function _tapHandler(event)
        local index = tonumber(event.context)
        self:onTabClicked(index)
    end

    local ph = self.ui:getChildByName('ph')
    ph:setVisible(false)
    local phGb = ph:getGroupBounds(self.ui)
    local tabWidth = phGb.size.width
    local tabHeight = phGb.size.height
    local size = CCSizeMake(tabWidth, tabHeight)
    -- self.v_layout = VerticalTileLayout:create(size.width)
    self.scrollable = HorizontalScrollable:create(size.width, size.height, true, false)
    self.layout = HorizontalTileLayout:create(size.height)
    self.layoutContainer = Layer:create()
    self.layoutContainer:addChild(self.layout)
    self.layoutContainer:addChild(self.arrow)
    self.layoutContainer:setPosition(ccp(0, -tabHeight))

    self.ui:addChild(self.scrollable)
    self.scrollable:setPositionX(ph:getPositionX())
    self.scrollable:setPositionY(ph:getPositionY())

    for i=1, count do
        local tab = nil
        if table.exist(config[i].msgType, RequestType.kClover_AddFriend) then
            tab = self.builder:buildGroup('request_message_tabButton_with_icon')
            tab.controller = IconTabButtonController:create(tab)
        else
            tab = self.builder:buildGroup('message_tabButton')
            tab.controller = TabButtonController:create(tab)
        end

        tab.controller:initTab(tab, config[i])
        tab:ad(DisplayEvents.kTouchTap, _tapHandler, config[i].pageIndex)

        local item = ItemInClippingNode:create()
        -- local tabWrapper = CocosObject:create()
        item:setContent(tab)
        item:setParentView(self.scrollable)
        item.tab = tab
        self.layout:addItem(item, false)
        table.insert(self.tabs, item)
    end
    self.scrollable:setContent(self.layoutContainer)


    self:goto(1)

end

function RequestMessagePanelTab:setNumber(index, number)
    -- if _G.isLocalDevelopMode then printx(0, 'aaa--------------------setNumber', index, number) end
    local tab = self.tabs[index].tab
    if not tab then return end
    local size = tab.txt:getContentSize()
    tab.number = number
    self:updateNumberDisplay()
end

function RequestMessagePanelTab:updateNumberDisplay()
    -- if _G.isLocalDevelopMode then printx(0, 'updateNumberDisplay', index) end
    for k, item in pairs(self.tabs) do
        local tab = item.tab
        if k == self.curIndex then
            tab.controller:hideNumberDisplay(tab)
        else
            tab.controller:updateNumberDisplay(tab)
        end
    end
end

function RequestMessagePanelTab:setView(view)
    self.view = view
end

function RequestMessagePanelTab:next()
    if self.curIndex == #self.config then return end
    self:goto(self.curIndex + 1)
end

function RequestMessagePanelTab:prev()
    if self.curIndex == 1 then return end
    self:goto(self.curIndex - 1)
end

function RequestMessagePanelTab:goto(index)
    local count = #self.config
    if not index or type(index) ~= 'number' or index > count or index < 1 then
        return 
    end
    local curTab = self.tabs[self.curIndex].tab
    local nextTab = self.tabs[index].tab
    if curTab then
        curTab.txt:stopAllActions()
        curTab.txt:runAction(self:_getTabLooseFocusAnim(curTab))
    end
    if nextTab then 
        local pos = nextTab:getParent():convertToWorldSpace(nextTab:getPosition())
        local wPos = self.layout:convertToNodeSpace(pos)
        self.scrollable:scrollOffsetToCenter(wPos.x)
        nextTab.txt:stopAllActions()
        nextTab.txt:runAction(self:_getTabOnFocusAnim(nextTab))
    end
    if self.arrow then
        self.arrow:stopAllActions()
        self.arrow:runAction(self:_getArrowAnim(index))
    end
    self.curIndex = index
    self:updateNumberDisplay()

end

function RequestMessagePanelTab:onTabClicked(index)
    self:goto(index)
    if self.view then self.view:gotoPage(index) end
end

function RequestMessagePanelTab:_getArrowAnim(index)
    local tab = self.tabs[index].tab
    if tab then 
        local pos = tab.locator:getPosition()
        local worldPos = tab.locator:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
        local realPos = self.arrow:getParent():convertToNodeSpace(ccp(worldPos.x, worldPos.y))
        local move = CCMoveTo:create(self.animDuration, ccp(realPos.x, realPos.y))
        local ease = CCEaseSineOut:create(move)
        return ease
    end
    return nil
end

function RequestMessagePanelTab:_getTabOnFocusAnim(tab)
    if not tab then return nil end
    local tint = CCTintTo:create(self.animDuration, self.colorConfig.focus.r, self.colorConfig.focus.g, self.colorConfig.focus.b)
    local scale = CCScaleTo:create(self.animDuration, 34/28)
    local move = CCMoveTo:create(self.animDuration, tab.focusPos)
    local array = CCArray:create()
    array:addObject(tint)
    array:addObject(scale)
    array:addObject(move)
    local spawn = CCEaseSineOut:create(CCSpawn:create(array))
    return spawn
end

function RequestMessagePanelTab:_getTabLooseFocusAnim(tab)
    if not tab then return nil end
    local tint = CCTintTo:create(self.animDuration, self.colorConfig.normal.r, self.colorConfig.normal.g, self.colorConfig.normal.b)
    local scale = CCScaleTo:create(self.animDuration, 1)
    local move = CCMoveTo:create(self.animDuration, tab.normalPos)
    local array = CCArray:create()
    array:addObject(tint)
    array:addObject(scale)
    array:addObject(move)
    local spawn = CCEaseSineOut:create(CCSpawn:create(array))
    return spawn
end

