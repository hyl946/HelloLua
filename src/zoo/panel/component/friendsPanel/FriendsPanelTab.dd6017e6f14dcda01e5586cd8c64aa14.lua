require 'zoo.panel.component.common.HorizontalScrollable'
require 'zoo.panel.component.common.VerticalTileLayout'

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
    local tx,ty = tab.txt:getPositionX(),tab.txt:getPositionY()
    tx = tx+dimension.width*0.5
    tab.txt:setDimensions(CCSizeMake(0, 0))
    tab.txt:setString(Localization:getInstance():getText(config.key))
    tab.txt:setAnchorPoint(ccp(0.5,0.3))
    local size = tab.txt:getContentSize()
    tab.txt:setPositionXY(tx , ty-25)
    tab.locator:setPositionX(tab.txt:getPositionX()+size.width/2-5)
    tab:setTouchEnabled(true, 0, true)
    tab:setButtonMode(false)
    tab.normalPos = ccp(tab.txt:getPositionX(), tab.txt:getPositionY())
    tab.focusPos = ccp(tab.txt:getPositionX() , tab.txt:getPositionY() + 15)
    local tabSize = tab:getGroupBounds().size
    tab:setPositionY(tabSize.height)
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

FriendsPanelTab = class(BaseUI)
function FriendsPanelTab:create(config,ui,tabHover)
    local instance = FriendsPanelTab.new()
    instance:loadRequiredResource(PanelConfigFiles.friends_panel)
    instance:init(config,ui,tabHover)
    return instance
end

function FriendsPanelTab:loadRequiredResource(config)
    self.builder = InterfaceBuilder:create(config)
end

function FriendsPanelTab:unloadRequiredResource()
end

function FriendsPanelTab:init(config,ui,tabHover)
    ui = ui or self.builder:buildGroup('interface/request_message_tabs_long')
    BaseUI.init(self, ui)

    self.tabHover = tabHover

    self.animDuration = 0.25

    self.config = config
    self.colorConfig = {
        normal = ccc3(204, 255, 255),
        focus = ccc3(255, 255, 255)
    }

    self.curIndex = 1

    -- self.arrow = ui:getChildByName('market_tabArrow')
    -- self.arrow:removeFromParentAndCleanup(false)

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
    -- self.layoutContainer:addChild(self.arrow)
    self.layoutContainer:setPosition(ccp(0, -tabHeight))

    self.ui:addChild(self.scrollable)
    self.scrollable:setPositionX(ph:getPositionX())
    self.scrollable:setPositionY(ph:getPositionY())

    for i=1, count do
        local tab = self.builder:buildGroup('interface/message_tabButton')
        tab.controller = TabButtonController:create(tab)

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
    --self.layout:setPositionX((size.width - self.layout:getWidth())/2)
    local offsets = {220, 130, 50}
    self.layout:setPositionX(offsets[count])

    self.scrollable:setContent(self.layoutContainer)

    self:goto(1)
end

function FriendsPanelTab:setNumber(index, number)
    local tab = self.tabs[index].tab
    if not tab then return end
    local size = tab.txt:getContentSize()
    tab.number = number
    self:updateNumberDisplay()
end

function FriendsPanelTab:updateNumberDisplay()
    for k, item in pairs(self.tabs) do
        local tab = item.tab
        if k == self.curIndex then
            tab.controller:hideNumberDisplay(tab)
        else
            tab.controller:updateNumberDisplay(tab)
        end
    end
end

function FriendsPanelTab:setView(view)
    self.view = view
end

function FriendsPanelTab:next()
    if self.curIndex == #self.config then return end
    self:goto(self.curIndex + 1)
end

function FriendsPanelTab:prev()
    if self.curIndex == 1 then return end
    self:goto(self.curIndex - 1)
end

function FriendsPanelTab:goto(index)
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
        local anim = self:_getArrowAnim(index)
        if anim then
            self.arrow:runAction(anim)
        end
    end
    self.curIndex = index
    self:updateNumberDisplay()

    for i,v in ipairs(self.tabs) do
        v.tab:getChildByName("tabBlue"):setVisible(i==index)
        v.tab:getChildByName("tabPurple"):setVisible(i~=index)
    end

    local tab = self.tabs[index].tab
    local worldPos = tab:getParent():convertToWorldSpace(ccp(tab:getPositionX(), tab:getPositionY()))
    local realPos = self.tabHover:getParent():convertToNodeSpace(ccp(worldPos.x, worldPos.y))
    self.tabHover:setPositionX(realPos.x)
end

function FriendsPanelTab:onTabClicked(index)
    self:goto(index)
    if self.view then self.view:gotoPage(index) end
end

function FriendsPanelTab:_getArrowAnim(index)
    local tab = self.tabs[index].tab
    if tab then 
        local pos = tab.locator:getPosition()
        local worldPos = tab.locator:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
        local realPos = self.arrow:getParent():convertToNodeSpace(ccp(worldPos.x, worldPos.y))
        if not self.arrow.hasInitedPos then
            self.arrow.hasInitedPos = true
            self.arrow:setPosition(realPos)
            return nil
        else
            local move = CCMoveTo:create(self.animDuration, ccp(realPos.x, realPos.y))
            local ease = CCEaseSineOut:create(move)
            return ease
        end
    end
    return nil
end

function FriendsPanelTab:_getTabOnFocusAnim(tab)
    if not tab then return nil end
    local tint = CCTintTo:create(self.animDuration, self.colorConfig.focus.r, self.colorConfig.focus.g, self.colorConfig.focus.b)
    local scale = CCScaleTo:create(self.animDuration, 1.1)
    -- local move = CCMoveTo:create(self.animDuration, tab.focusPos)
    local array = CCArray:create()
    array:addObject(tint)
    array:addObject(scale)
    -- array:addObject(move)
    local spawn = CCEaseSineOut:create(CCSpawn:create(array))
    return spawn
end

function FriendsPanelTab:_getTabLooseFocusAnim(tab)
    if not tab then return nil end
    local tint = CCTintTo:create(self.animDuration, self.colorConfig.normal.r, self.colorConfig.normal.g, self.colorConfig.normal.b)
    local scale = CCScaleTo:create(self.animDuration, 1)
    -- local move = CCMoveTo:create(self.animDuration, tab.normalPos)
    local array = CCArray:create()
    array:addObject(tint)
    array:addObject(scale)
    -- array:addObject(move)
    local spawn = CCEaseSineOut:create(CCSpawn:create(array))
    return spawn
end
