require "zoo.panel.component.friendsPanel.FriendsPageBackground"

AddFriendPage = class(Layer)
function AddFriendPage:create(mainPanel, config, content, width, height)
    local instance = AddFriendPage.new()
    instance:init(mainPanel, config, content, width, height)
    return instance
end

function AddFriendPage:init(mainPanel, config, content, width, height)
    self.width = width
    self.height = height

    Layer.initLayer(self)
    self:setTouchEnabled(true, 0, true)

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

    -- empty layer
    local zero = config.zero():create(width, height)
    zero.name = 'zero'
    self:addChild(zero)

    local listWidth = width - pagePadding.left - pagePadding.right
    local listHeight = height - pagePadding.top - pagePadding.bottom

    -- VerticalScrollable
    local list = VerticalScrollable:create(listWidth, listHeight, listUseClipping)
    list.name = "list"
    list:setIgnoreHorizontalMove(false)
    list:setPosition(ccp(pagePadding.left, 0-pagePadding.top))
    self:addChild(list)

    local layout = VerticalTileLayout:create(width)
    list:setContent(layout)

    zero:setVisible(false)
    list:setVisible(true)

    local elems = {}
    local existThanks = false -- 答谢一条统一显示
    local candidates = {1, 2}

    for k2, v2 in pairs(candidates) do
        local class = config.class()

        local elem = class.new()
        elem:loadRequiredResource(PanelConfigFiles.friends_panel)
        elem:init()
        elem:setPanelRef(mainPanel)
        elem:setParentView(list)

        elem:setData(v2)
        elem:setHeight(126)

        elem:setPageIndex(self.pageIndex)
        elem:setParentLayout(layout)
        table.insert(elems, elem)
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
end

function AddFriendPage:initBottom(bottom)
end

function AddFriendPage:getTopStickyItems()
    return self.topStickyItems
end

function AddFriendPage:getItems()
    return self.items
end

function AddFriendPage:getGroupBounds( ... )
    local bounds = Layer.getGroupBounds(self)  
    bounds.size = CCSizeMake(self.width,self.height)
    return bounds
end