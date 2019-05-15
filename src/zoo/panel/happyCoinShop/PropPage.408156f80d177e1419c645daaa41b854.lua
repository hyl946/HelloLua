local PropPage = class(Layer)

local TOP_MARGIN = 10
local TOP_PART_HEIGHT = 263
local VIEW_WIDTH = 660
local ITEM_HIGHT = 210

local CustomizedPV = class(PagedView)
function CustomizedPV:create(width, height, numOfPages, pager, useClipping, useBlockingLayers, main_panel)
    local instance = CustomizedPV.new()
    instance.main_panel = main_panel
    instance:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)
    return instance
end
function CustomizedPV:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)
    PagedView.init(self, width, height, numOfPages, pager, useClipping, useBlockingLayers)
    self:initAutoScroll()
end
function CustomizedPV:startTimer()
    -- print('startTimer')
    if not self.schedId then
        local function onCD()
            if self.isDisposed then
                self:stopTimer()
                return
            end
            self:autoNextPage()
            self.schedId = nil
            self:startTimer()
        end
        self.schedId = setTimeOut(onCD, 5)
    end
end
function CustomizedPV:autoNextPage()
    if self:canNextPage() then
        PagedView.nextPage(self)
    else
        self:gotoPage(1)
    end
end
function CustomizedPV:nextPage()
    if self:canNextPage() then
        PagedView.nextPage(self)
    else
        self:gotoPage(1)
    end
end
function CustomizedPV:stopTimer()
    -- print('stopTimer')
    if self.schedId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end
function CustomizedPV:initAutoScroll()
    self:startTimer()
end
function CustomizedPV:onPageTouchBegin(event)
    if self.main_panel and not self.main_panel.isDisposed then
        self.main_panel.pagedView.ignore = true
    end
    self:stopTimer()
    PagedView.onPageTouchBegin(self, event)
end
function CustomizedPV:onPageTouchMove(event)
    if self.main_panel and not self.main_panel.isDisposed then
        self.main_panel.pagedView.ignore = true
    end
    self:stopTimer()
    PagedView.onPageTouchMove(self, event)
end
function CustomizedPV:onPageTouchEnd(event)
    if self.main_panel and not self.main_panel.isDisposed then
        self.main_panel.pagedView.ignore = false
    end
    self:startTimer()
    PagedView.onPageTouchEnd(self, event)
end

local Pager = class(BaseUI)
function Pager:create(ui)
    local instance = Pager.new()
    instance:init(ui)
    return instance
end
function Pager:init(ui)
    BaseUI.init(self, ui)
    self.curIndex = 1
end
function Pager:next()
    if self.curIndex == 3 then return end
    self:goto(self.curIndex + 1)
end

function Pager:prev()
    if self.curIndex == 1 then return end
    self:goto(self.curIndex - 1)
end

function Pager:goto(index)
    local count = 3
    if not index or type(index) ~= 'number' or index > count or index < 1 then
        return 
    end
    for i=1, 3 do
        self.ui:getChildByName(tostring(i)):getChildByName('selected'):setVisible(i == index)
        self.ui:getChildByName(tostring(i)):getChildByName('not_selected'):setVisible(i ~= index)
    end
    self.curIndex = index
end

function PropPage:create(config, main_panel)
    local instance = PropPage.new()
    instance.builder = InterfaceBuilder:create('ui/market_panel.json')
    instance.config = config
    instance.main_panel = main_panel
    instance:init()
    return instance
end

function PropPage:init()

    Layer.initLayer(self)
    
    self:initTopPart()
    self:initMiddlePart()
    self:initBottomPart()
    self:initGoodsItems()
    self:layout()
end

function PropPage:initGoodsItems()

    local function isPackageGoods( goodsId )
        return table.exist({
            65, 66, 67,
            469, 470, 471,
        }, goodsId)
    end

    local goods = self:getGoodsByTabId(1)
    for i, v in ipairs(goods) do
        if isPackageGoods(v) then
            local item = MarketPackItem:create(v)
            item:setScale(0.965)
            item:setParentView(self.top_part)
            self.top_part:addPageAt(item, i)
        elseif v ~= 2 then -- 代码过滤后退一步，因为要考虑版本兼容，不能在配置里面删除
            local item = MarketPropsItem:create(v)
            item:setScale(0.9)
            print(v)
            if item:isLimitedItem() or v == 17 then
                self.bottom_part:addItem(item)
            else
                self.middle_part:addItem(item)
            end
        end
    end
end


function PropPage:getGoodsByTabId(tabId)
    local v_tab = {}
    for k, v in pairs(self.config.tabs) do 
        if v.tabId == tabId then
            v_tab = v
            break
        end
    end
    return v_tab.goodsIds or {}
end

function PropPage:initTopPart()

    local pager = Pager:create(self.builder:buildGroup('market_panel_top_pager'))

    local width = 674
    local height = TOP_PART_HEIGHT
    local numOfPages = 3
    local useClipping = true
    local useBlockingLayers = false
    self.top_part = CustomizedPV:create(width, height, numOfPages, pager, useClipping, useBlockingLayers, self.main_panel)
    -- self.top_part.touchReceiveLayer:setTouchEnabled(true, -1, true)
    self:addChild(self.top_part)
    self.top_part:setPositionY(TOP_MARGIN-TOP_PART_HEIGHT)
    self.top_part:setPositionX(0)

    self:addChild(pager)
    pager:setPositionX(VIEW_WIDTH/2+10)
    pager:setPositionY(0-TOP_PART_HEIGHT+35)
    self.pager = pager
    pager:goto(1)
end

function PropPage:initMiddlePart()

    local middle_part_bg = Scale9SpriteColorAdjust:createWithSpriteFrameName('market_panel_part_bg0000')
    middle_part_bg:setAnchorPoint(ccp(0, 1))
    self:addChild(middle_part_bg)
    self.middle_part_bg = middle_part_bg

    self.middle_part = GridLayout:create()
    self.middle_part:setColumn(4)
    self.middle_part:setWidth(VIEW_WIDTH-35)
    self.middle_part:setItemSize(CCSizeMake(0, ITEM_HIGHT))
    self.middle_part:setColumnMargin(0)
    self.middle_part:setRowMargin(30)
    self.middle_part:setPositionX(28)
    self:addChild(self.middle_part)
    self.middle_part:setPositionY(-265)

    local corner = Sprite:createWithSpriteFrameName('market_panel_discount_corner0000')
    corner:setAnchorPoint(ccp(0, 1))
    self:addChild(corner)
    self.limited_corner = corner


end

function PropPage:initBottomPart()
    local bottom_part_bg = Scale9SpriteColorAdjust:createWithSpriteFrameName('market_panel_part_bg0000')
    bottom_part_bg:setAnchorPoint(ccp(0, 1))
    self:addChild(bottom_part_bg)
    self.bottom_part_bg = bottom_part_bg


    self.bottom_part = GridLayout:create()
    self.bottom_part:setColumn(4)
    self.bottom_part:setWidth(VIEW_WIDTH-35)
    self.bottom_part:setItemSize(CCSizeMake(0, ITEM_HIGHT))
    self.bottom_part:setColumnMargin(0)
    self.bottom_part:setRowMargin(30)
    self.bottom_part:setPositionX(28)
    self:addChild(self.bottom_part)
    self.bottom_part:setPositionY(-940)

    local corner = Sprite:createWithSpriteFrameName('market_panel_limited_corner0000')
    corner:setAnchorPoint(ccp(0, 1))
    self:addChild(corner)
    self.discount_corner = corner

end

function PropPage:layout()
    self.middle_part:setPositionY(TOP_MARGIN-TOP_PART_HEIGHT-0 )
    self.bottom_part:setPositionY(TOP_MARGIN-TOP_PART_HEIGHT-self.middle_part:getHeight() - 20)

    self.limited_corner:setPositionXY(self.middle_part:getPositionX()-13+6, self.middle_part:getPositionY()-8-5)
    self.middle_part_bg:setPreferredSize(CCSizeMake(self.middle_part:getWidth()+5, self.middle_part:getHeight()))
    self.middle_part_bg:setPositionXY(self.middle_part:getPositionX()-5, self.middle_part:getPositionY()-18)

    self.discount_corner:setPositionXY(self.bottom_part:getPositionX()-15+7, self.bottom_part:getPositionY()-5-5)
    self.bottom_part_bg:setPreferredSize(CCSizeMake(self.bottom_part:getWidth()+5, self.bottom_part:getHeight()))
    self.bottom_part_bg:setPositionXY(self.bottom_part:getPositionX()-5, self.bottom_part:getPositionY()-12)
end

function PropPage:getHeight()
    return -self.bottom_part:getPositionY()+self.bottom_part:getHeight() + 20
end

-- function PropPage:dispose()

-- end

return PropPage