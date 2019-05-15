require "zoo.panel.messageCenter.RequestMessagePageBackground"

RequestMessagePage = class(Layer)

function RequestMessagePage:create(mainPanel, config, content, width, height)
    local instance = RequestMessagePage.new()
    instance:init(mainPanel, config, content, width, height)
    return instance
end

function RequestMessagePage:init(mainPanel, config, content, width, height)
    self.width = width
    self.height = height

    Layer.initLayer(self)

    RequestMessagePageBackground:addPageBackground(self, config.pageBgType, width, height)

    self.pageIndex = config.pageIndex

    local listUseClipping = false
    local pagePadding = {top=0,left=0,bottom=0,right=0}
    if type(config.pagePadding) == "table" then
        pagePadding.top     = config.pagePadding.top or 0
        pagePadding.left    = config.pagePadding.left or 0
        pagePadding.bottom  = config.pagePadding.bottom or 0
        pagePadding.right   = config.pagePadding.right or 0
        listUseClipping = true
    end

    local zero = config.zero():create(width, height)
    zero.name = 'zero'
    self:addChild(zero)
    local listWidth = width - pagePadding.left - pagePadding.right
    local listHeight = height - pagePadding.top - pagePadding.bottom
    local list = VerticalScrollable:create(listWidth, listHeight, listUseClipping)
    list.name = "list"
    list:setIgnoreHorizontalMove(false)
    list:setPosition(ccp(pagePadding.left, 0-pagePadding.top))
    self:addChild(list)
    local layout = VerticalTileLayout:create(width)
    list:setContent(layout)
    local normalMsgs = content.normalMessages
    local pushMsgs = content.pushMessages

    local allMsgNumber = FreegiftManager:sharedInstance():getMessageNumByType(config.msgType)
    -- local showAddFriendItem = (not FriendManager:getInstance():isFriendCountReachedMax() and config.pageName == 'energy')
    if allMsgNumber <= 0 then
        list:setVisible(false)
        zero:setVisible(true)
    else
        zero:setVisible(false)
        list:setVisible(true)
    end
    local elems = {}
    local existThanks = false -- 答谢一条统一显示
    local thanksMsgs = table.filter(normalMsgs,function(v) return v.type == RequestType.kThanks end)

    for k2, v2 in pairs(normalMsgs) do
        local class = config.class(v2)
        if v2.type == RequestType.kThanks and #thanksMsgs <= 3 then
            class = OneThanksMessageItem
        end 
        if v2.type == RequestType.kAskForHelp and k2 == 1 then
            local topItem = AskForHelpTopItem.new()
            topItem:loadRequiredResource(PanelConfigFiles.request_message_panel)
            topItem:init()
            topItem:setPanelRef(mainPanel)
            topItem:setParentView(list)
            topItem:setHeight(180)
            topItem:setPageIndex(self.pageIndex)
            topItem:setParentLayout(layout)
            table.insert(elems, topItem)
        end
        if class and (v2.type ~= RequestType.kThanks or not existThanks) then
            local elem = class.new()
            elem:loadRequiredResource(PanelConfigFiles.request_message_panel)
            elem:init()
            elem:setPanelRef(mainPanel)
            elem:setParentView(list)
            if v2.type == RequestType.kThanks then
                if #thanksMsgs > 3 then
                    elem:setData(thanksMsgs)
                    existThanks = true
                else
                    elem:setData(v2)
                end
            elseif v2.type == RequestType.kPassMaxNormalLevel then
                elem:setData(v2)
                elem:setHeight(180)
            else    
                elem:setData(v2)
                elem:setHeight(173)
            end
            elem:setPageIndex(self.pageIndex)
            elem:setParentLayout(layout)
            table.insert(elems, elem)
        end
    end

    local itemVerticalMargin = 5
    if type(config.itemMargin) == "table" then
        local marginTop = config.itemMargin.top or 0
        local marginBottom = config.itemMargin.bottom or 0
        itemVerticalMargin = marginTop + marginBottom
    end
    layout:setItemVerticalMargin(itemVerticalMargin)
    layout:addItemBatch(elems)
    list:updateScrollableHeight()
    layout:__layout()

    self.layout = layout
    self.layer = layer
    self.items = elems
    self.zero = zero
    self.scrollable = list
    self.panel = mainPanel

    self.topStickyItems = {}
    -- self.bottomStickyItems = {}
    table.sort(pushMsgs, function (v1, v2) return v1.type < v2.type end)
    for k, v in pairs(pushMsgs) do
        self:addTopStickyItem(v, false)
    end

    -- if showAddFriendItem then
    --     self:addBottomStickyItem()
    -- end
end

function RequestMessagePage:getTopStickyItems()
    return self.topStickyItems
end

-- function RequestMessagePage:getBottomStickyItems()
--     return self.bottomStickyItems
-- end

function RequestMessagePage:getItems()
    return self.items
end

-- function RequestMessagePage:addBottomStickyItem()
--     local item = PushBindingItem.new()
--     item:loadRequiredResource(PanelConfigFiles.request_message_panel)
--     item:init()
--     item:setPanelRef(self.panel)
--     item:setParentView(self.scrollable)
--     item:setPageIndex(self.pageIndex)
--     self.layout:addItem(item, playAnimation)
--     table.insert(self.bottomStickyItems, item)
--     self.layout:__layout()
--     self.scrollable:updateScrollableHeight()
-- end

function RequestMessagePage:addTopStickyItem(data, playAnimation)


    if data.type == RequestType.kPushEnergy or data.type == RequestType.kDengchaoEnergy then
        local item
        if data.type == RequestType.kPushEnergy then
            item = PushEnergyItem.new()
        elseif data.type == RequestType.kDengchaoEnergy then
            item = DengchaoEnergyItem.new()
        end
        item:loadRequiredResource(PanelConfigFiles.request_message_panel)
        item:init()
        item:setPanelRef(self.panel)
        item:setParentView(self.scrollable)
        item:setData(data)
        item:setParentLayout(self.layout)
        item:setPageIndex(self.pageIndex)
        self.layout:addItemAt(item, 1, playAnimation)
        table.insert(self.topStickyItems, item)
    end
    self.layout:__layout()
    self.scrollable:updateScrollableHeight()
end


function RequestMessagePage:getGroupBounds( ... )
    local bounds = Layer.getGroupBounds(self)  
    bounds.size = CCSizeMake(self.width,self.height)
    return bounds
end