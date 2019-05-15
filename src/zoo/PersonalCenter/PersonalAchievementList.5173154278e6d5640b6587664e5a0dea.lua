local FriendInfoUtil = require 'zoo.PersonalCenter.FriendInfoUtil'

local SuperCls = BasePanel
local MainPanel = class(SuperCls)

local UIHelper = require 'zoo.panel.UIHelper'

function MainPanel:create(achievementData)
    local panel = MainPanel.new()
    panel.achievementData = achievementData
    panel:init()
    panel:popout()
    return panel
end

function MainPanel:init()
    self:initUI()
end

function MainPanel:initUI()
    -- local ui = UIHelper:createUI('ui/personal_center_panel.json', 'achi_list')
    local builder = InterfaceBuilder:createWithContentsOfFile('ui/personal_center_panel.json')
    local ui = builder:buildGroup('achi_list')
    self.ui = ui

    SuperCls.init(self,ui)

    local function formatChild(parent,childs,owner)
        owner = owner or parent
        for i,v in ipairs(childs) do
            owner[v] = parent:getChildByName(v)
            -- print(v,parent[v])
            -- assert(owner[v],"NO CHILD:"..tostring(v))
        end
    end

    local function setText(label,str)
        str = str or ""
        if not label or not label.setString then 
            print("NO LABEL:" .. debug.traceback())
            do return end
        end
        label:setString(tostring(str))
    end

    local function setBtnOnClick(key,callback)
        local item = self[key]
        if not item then
            printx(0,"ERR!Can not find ui by key:"..tostring(key).."---"..debug.traceback())
            return
        end
        item:setTouchEnabled(true,0, false)
        item:setButtonMode(true)
        item:addEventListener(DisplayEvents.kTouchTap, callback)
    end

    formatChild(self.ui,{
"hit_area",
"bg0",
"bg",
"btnOK",
"content",
"row",
"closeBtn",
"title",
},self)

    setBtnOnClick("closeBtn",handler(self,self.onClose))
    -- setBtnOnClick("btnOK",handler(self,self.onClose))

    self.btnOK = GroupButtonBase:create(self.btnOK)
    self.btnOK:setString("关闭")
    self.btnOK:ad(DisplayEvents.kTouchTap, function() 
        self:onClose()
    end)

    ---

    local row = ui:getChildByPath('row')
    row:setVisible(false)
    local rowSymbol = row.symbolName

    local page = CocosObject:create()
    local rowGrp = {}
    local context = self

    local function getItem( index )
        if context.isDisposed then return end
        local r = math.ceil(index / 4)
        local c = index - (r - 1) * 4
        if rowGrp[r] then
            local item = rowGrp[r]:getChildByPath(tostring(c))
            return item
        end
    end

    function page:getItemPosInWorld( index )
        local item = getItem(index)
        if item then
            local bounds = item:getGroupBounds()
            return ccp(bounds:getMidX(), bounds:getMidY())
        end
    end

    function page:select( index, caretNode)
        if context.isDisposed then return end

        caretNode = caretNode or cursor

        local item = getItem(index)
        if item then
            caretNode:removeFromParentAndCleanup(false)
            item:addChildAt(caretNode, 0)
            local size = item:getContentSize()
            caretNode:setPosition(ccp(size.width/2, size.height/2))
        end
    end

    function page:swapView( indexA, indexB )
        -- body
        -- 交换两个item的位置 但index不变
        -- 比如 indexA是头像0，在最左边，indexB是头像1 在最右边
        -- swap之后，头像0在右边，头像1在左边，但indexA仍然对应头像0 ....
        if self.isDisposed then return end

        local itemA = getItem(indexA)
        local itemB = getItem(indexB)

        local parentA = itemA:getParent()
        local parentB = itemB:getParent()

        local posA = ccp(itemA:getPositionX(), itemA:getPositionY())
        local posB = ccp(itemB:getPositionX(), itemB:getPositionY())

        itemA:setPosition(parentA:convertToNodeSpace(parentB:convertToWorldSpace(posB)))
        itemB:setPosition(parentB:convertToNodeSpace(parentA:convertToWorldSpace(posA)))
    end

    function page:setContent( index , content , hasIt )
        if not hasIt then
            hasIt = false
        end
        if context.isDisposed then return end
        local item = getItem(index)
        if item and item.content then
            item.content:removeFromParentAndCleanup(true)
            item.content = nil
        end
        if not item.hasBlack and not hasIt then
            item.hasBlack = true
            local blackSprite = Sprite:createWithSpriteFrameName( "assert_00/blackbg0000" )
            item:addChild( blackSprite )
            blackSprite:setPositionX( 125/2 )
            blackSprite:setPositionY( 125/2 )
        end

        item.content = content
        item:addChild(content)
        content:setPositionX(item:getContentSize().width/2)
        content:setPositionY(item:getContentSize().height/2)
    end


    local items = FriendInfoUtil:createAchievementItems(self.achievementData)

    local offsetY = 0
    local offsetX = 0
    local rowCounter = 0

    function page:addRow( ... )
        if context.isDisposed then return end

        -- local rowUI = UIHelper:createUI('ui/personal_center_panel.json', rowSymbol)
        
        local builder = InterfaceBuilder:createWithContentsOfFile('ui/personal_center_panel.json')
        local rowUI = builder:buildGroup(rowSymbol)
        self:addChild(rowUI)

        rowUI:setPositionX(offsetX)
        rowUI:setPositionY(offsetY)
        offsetY = offsetY - 142

        table.insert(rowGrp, rowUI)

        for i = 1, 4 do
            local col = i
            local row = rowCounter
            local tapIndex = row * 4 + col

            local thisItem = rowUI:getChildByPath(tostring(i))

            if tapIndex<=#items then
                local item = items[tapIndex]
                item:setPosition(ccp(12, 120))
                item:setScale(0.85)
                thisItem:addChild(item)
            else
                thisItem:setVisible(false)
            end
        end

        rowCounter = rowCounter + 1
    end
    
    local nRow = math.ceil(#items/4)
    for i = 1, nRow do
        page:addRow()
    end

    self.content:setVisible(false)
    local contentSize = self.content:getContentSize()
    local contentHolderWidth,contentHolderHeight = self.content:getScaleX() * contentSize.width,self.content:getScaleY() * contentSize.height

    page.container = scroll
    -- page:setPositionX(20)
    -- page:setPositionY(-10)
    
    local itemInLayout = ItemInLayout:create()
    itemInLayout:setContent(page)

    local scrollLayout = VerticalTileLayout:create(contentHolderWidth)
    scrollLayout:addItem(itemInLayout)
    scrollLayout.getHeight=function()
        return -offsetY
    end
    
    local scroll = VerticalScrollable:create(contentHolderWidth, contentHolderHeight, true, false)
    scroll:setIgnoreHorizontalMove(false)
    scroll:setContent(scrollLayout)
    scroll:setPositionXY(44,self.content:getPositionY())
    scroll.page = page
    scroll:setScrollEnabled(nRow > 4)
    scroll:updateScrollableHeight()
    self:addChild(scroll)


end

function MainPanel:checkIgnoreAchi( id )
    if __WP8 then
        return id == AchievementManager.shareId.COLLECT_ALL_61_EGGS
    end
    return false
end

function MainPanel:onKeyBackClicked( ... )
        -- SuperCls.onKeyBackClicked(self, ...)
    self:onClose()
end

function MainPanel:onClkCloseBtn()
    self:onClose()
end

function MainPanel:popout()
    PopoutManager:sharedInstance():add(self, true)

    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

    return self
end

function MainPanel:onClose()
    if self.isDisposed then return end
    PopoutManager:sharedInstance():remove(self)
end

function MainPanel:dispose()
    BasePanel.dispose(self)
end

return MainPanel