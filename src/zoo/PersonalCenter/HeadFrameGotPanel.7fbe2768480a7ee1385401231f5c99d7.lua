local UIHelper = require 'zoo.panel.UIHelper'
HeadFrameGotPanel = class(BasePanel)

local headPos = ccp(300,300)

local function parseTime(str, default)
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str, pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end
function HeadFrameGotPanel:create(closeCallback)
    local ret = HeadFrameGotPanel.new()
    ret.closeCallback = closeCallback
    ret:init()
    ret:popout()

     --这个板子出来了 就算你做完引导了
    if UserManager:getInstance():hasGuideFlag( kGuideFlags.NewHeadFrame ) == false then
        UserLocalLogic:setGuideFlag( kGuideFlags.NewHeadFrame )
    end
    
    return ret
end

function HeadFrameGotPanel:onClose()
    local _ = self.closeCallback and self.closeCallback()
    PopoutManager:sharedInstance():remove(self)
end

function HeadFrameGotPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

    PopoutManager:sharedInstance():add(self, true)
end

function HeadFrameGotPanel:onKeyBackClicked( ... )
    self:onClose()
end

function HeadFrameGotPanel:init()
    self.oldID = UserManager:getInstance().profile.headFrame

 --    self.kMaxHeadImages = UserManager.getInstance().kMaxHeadImages

 --    self.newHeadFrameNode = nil 

    -- self.moreAvatarList = {}
 --    self.changePlayerCb = changePlayerCb


    self:loadRequiredResource("ui/HeadFrameGotPanel.json")
    self.ui = self:buildInterfaceGroup("HeadFrameGotPanel")
    BasePanel.init(self, self.ui)

    self.childs = {
        "bg",
        "light",
        "bg0",
        "content",
        "row",
        "black",
        "lockedicon",
        "cursor",
        "closeBtn",
        "title",
        "avatarPlaceholder",
        "btnOK",
    }
    for i,v in ipairs(self.childs) do
        self[v] = self.ui:getChildByName(v)
    end

    local tmpBtn = GroupButtonBase:create(self.btnOK)
    tmpBtn:setString("保存")
    tmpBtn:ad(DisplayEvents.kTouchTap, function () 
        if self.oldID ~= UserManager:getInstance().profile.headFrame then
            HeadFrameType:requestSave()
        end

        self:onClose()
    end)

    self.buildFunc = function(groupName)
        return self:buildInterfaceGroup(groupName)
    end

    local fileId = UserManager:getInstance().profile.fileId
    local function getCustomHeadUrl()
        if fileId and fileId ~= '' then
            return "http://animal-10001882.image.myqcloud.com/"..fileId
        elseif tonumber(UserManager:getInstance().profile.headUrl) == nil then
            return tostring(UserManager:getInstance().profile.headUrl)
        end
    end

    self.customHeadUrl = getCustomHeadUrl()
    
    local function changeImage(headUrl)
        local userId = UserManager:getInstance().user.uid or 0
        local oldImageIndex = nil
        if self.headImage then 
            oldImageIndex = self.headImage.headImageUrl
            self.headImage:removeFromParentAndCleanup(true)
            self.headImage = nil
        end

        local frameSize = self.avatarPlaceholder:getContentSize()
        local head = HeadImageLoader:createWithFrame(userId, headUrl)
        local clippingSize = head:getContentSize()
        local scale = frameSize.width/clippingSize.width
        head:setScale(scale*(extraScale or 1) )
        head:setPosition(ccp( frameSize.width/2+0.1,frameSize.height/2))
        self.avatarPlaceholder:addChild(head)
        self.headImage = head
        return oldImageIndex
    end

	local headUrl = PersonalCenterManager:getData(PersonalCenterManager.HEAD_URL)
    changeImage( headUrl)

    self:initPages()

    UIUtils:setTouchHandler(self.closeBtn, function ( ... )
        if self.oldID ~= UserManager:getInstance().profile.headFrame then
            HeadFrameType:setCurHeadFrame(self.oldID)
        end
        self:onClose()
    end)
end

function HeadFrameGotPanel:initPages( ... )
    local userId = UserManager:getInstance().user.uid or 0
    local context = self

    local newFrameID = 0
    local newFrameGotTime = 0

    local contentHolder = self.content
    local contentHolderWidth = contentHolder:getScaleX() * contentHolder:getContentSize().width
    local contentHolderHeight = contentHolder:getScaleY() * contentHolder:getContentSize().height
    contentHolder:setVisible(false)

    self.black:setVisible(false)
    self.lockedicon:setVisible(false)
    self.row:setVisible(false)

    self.cursor:setAnchorPoint(ccp(0.5, 0.5))

    local function addChildInPlace( parent, node, target )
        if self.isDisposed then return end

        local index = parent:getChildIndex(target)
        parent:addChildAt(node, index)
    end

    local function createPage( number , isHeadFrame )
        -- body
        if not isHeadFrame then
            isHeadFrame = false
        end

        local page = CocosObject:create()

        local rowGrp = {}

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


        function page:getItem( index )
            local item = getItem(index)
            return item
        end
        function page:select( index)
            if context.isDisposed then return end

            local caretNode = context.cursor
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

        function page:setContent( index , content , hasIt ,isHeadFrame, timeLimitIcon )
            if not hasIt then
                hasIt = false
            end
            if context.isDisposed then return end
            local item = getItem(index)
            if item and item.content then
                item.content:removeFromParentAndCleanup(true)
                item.content = nil
            end

            if not item.hasBlack and not hasIt and isHeadFrame then
                item.hasBlack = true
                local blackSprite = Sprite:createWithSpriteFrameName( "res.HeadFrameGotPanel/blackbg0000" )
                item:addChildAt( blackSprite , 29 )
                blackSprite:setPositionX( 125/2 )
                blackSprite:setPositionY( 125/2 )
                local lockIcon = Sprite:createWithSpriteFrameName( "res.HeadFrameGotPanel/lockedicon0000" )
                item:addChildAt( lockIcon , 30 )
                lockIcon:setPositionX( 125/2 + 5 )
                lockIcon:setPositionY( 125/2 - 5 )
            end
            if timeLimitIcon and isHeadFrame then
                item:addChildAt( timeLimitIcon , 31 )
                timeLimitIcon:setPositionX( 125/2 + 3  )
                timeLimitIcon:setPositionY( 125/2 - 45 )
            end

            item.content = content
            item:addChild(content)
            content:setPositionX(item:getContentSize().width/2)
            content:setPositionY(item:getContentSize().height/2)
        end

        local offsetY = 0
        local offsetX = 0
        local rowCounter = 0

        function page:addRow( ... )
            if context.isDisposed then return end

            local rowUI = context.buildFunc(context.row.symbolName)
            self:addChild(rowUI)

            rowUI:setPositionX(offsetX)
            rowUI:setPositionY(offsetY)
            offsetY = offsetY - 142

            table.insert(rowGrp, rowUI)

            for i = 1, 4 do
                local col = i
                local row = rowCounter

                local thisItem = rowUI:getChildByPath(tostring(i))

                UIUtils:setTouchHandler(thisItem, function ( ... )
                    local tapIndex = row * 4 + col
                    if page.onTapItem then
                        page:onTapItem(tapIndex)
                    end
                end, function ( worldPos )
                    if context.isDisposed then return false end
                    if not thisItem:hitTestPoint(worldPos, true) then return false end

                    local pos = context:convertToNodeSpace(worldPos)
                    if pos.y >= contentHolder:getPositionY() then
                        return false
                    end
                    if pos.y <= contentHolder:getPositionY() - contentHolderHeight then
                        return false
                    end
                    return true
                end)
            end

            rowCounter = rowCounter + 1

        end

        local nRow = math.ceil(number/4)
        --最少创建3行
        if nRow<3 then
            nRow = 3
        end

        for i = 1, nRow do
            page:addRow()
        end

        local scroll = VerticalScrollable:create(contentHolderWidth, contentHolderHeight, true, false)
        scroll:setIgnoreHorizontalMove(false)
        local scrollLayout = VerticalTileLayout:create(contentHolderWidth)
        scroll:setContent(scrollLayout)
        local itemInLayout = ItemInLayout:create()
        itemInLayout:setContent(page)
        scrollLayout:addItem(itemInLayout)
        scroll:updateScrollableHeight()
        page.container = scroll
        scroll.page = page

        page:setPositionX(20)
        page:setPositionY(-10)
        return page

    end

    local function createHeadFramePage( ... )
        local frames = HeadFrameType:setProfileContext(nil):getAvaiHeadFrame()

        local sortHeadFrameType = {}


        local meta = MetaManager:getInstance().headframe

        local function getHeadFrameNum(  )
            local number = 1
            for k, value in pairs( HeadFrameType ) do
                if type( value ) == "number" then
                    local hasMetaData = table.find( meta ,function ( metaNode )
                        return metaNode.id == value
                    end)

                   local isMine = table.find( frames ,function ( frameNode )
                        return frameNode.id == value
                    end)
                   
                    if isMine then
                        number = number +1 
                        table.insert(sortHeadFrameType , value)

                    elseif hasMetaData then
                        
                        local endTime = os.time2( parseTime(hasMetaData.endTime) )
                        local now = Localhost:timeInSec()
                        local timeout = endTime - now
                        if timeout >0 then
                            number = number +1 
                            table.insert(sortHeadFrameType , value)
                        end
                    else
                        number = number +1 
                        table.insert(sortHeadFrameType , value)
                    end

                end
            end
            return number
        end 
        local maxNum = getHeadFrameNum()
        local page = createPage( maxNum ,true)

        table.sort( sortHeadFrameType, function ( a , b  )
            --系统头像框 强制显示第一个
            if a == HeadFrameType.kNormal then
                return true
            end
            if b == HeadFrameType.kNormal then
                return false
            end

            local hasIt_a = table.find( frames ,function ( frameNode )
                return frameNode.id == a
            end)
            local hasIt_b = table.find( frames ,function ( frameNode )
                return frameNode.id == b
            end)
            if hasIt_a and not hasIt_b then
                return true
            end
            if not hasIt_a and  hasIt_b then
                return false
            end
            if hasIt_a and hasIt_b then
                return a < b
            end 
            return a < b
        end )

        page.frameIdMapIndex = {}

        local indexNode = 1

        for k, value in pairs( sortHeadFrameType ) do
            if type( value ) == "number" then

                local hasIt = table.find( frames ,function ( frameNode )
                    return frameNode.id == value
                end)

                local frameUI = HeadFrameType:buildUI( value , 1, userId )
                local holder = frameUI:getChildByName('head')
                local size = holder:getContentSize()
                local center = ccp(size.width/2, size.height/2)
                local posInFrameUI = frameUI:convertToNodeSpace(holder:convertToWorldSpace(center))
                frameUI:setScale(0.8*1.10)

                UIHelper:move(frameUI:getChildByPath('headFrame'), -posInFrameUI.x, -posInFrameUI.y)
                holder:removeFromParentAndCleanup(true)

                local frameIsTimeLimit = false
                if hasIt then
                    frameIsTimeLimit = HeadFrameType:setProfileContext():isTimeLimit( value )
                else
                    frameIsTimeLimit = HeadFrameType:setProfileContext():isTimeLimitForShow( value )
                end

                local timeLimitIcon =nil 
                if frameIsTimeLimit then
                    timeLimitIcon = ResourceManager:sharedInstance():buildGroup('jHeadUI/timeicon')
                    if timeLimitIcon then
                    end
                end

                page:setContent( indexNode , frameUI ,hasIt ,true, timeLimitIcon )
                page.frameIdMapIndex[ value ] = indexNode

                if HeadFrameType:setProfileContext():isNew( value ) then
                    if not self.newHeadFrameNode then
                        self.newHeadFrameNode = frameUI
                        self.selectGuideID = indexNode
                        self.selectedFrameID = value
                    end
                    local newFlag = HeadFrameType:buildNewFlag()
                    newFlag:setPosition(ccp(40, 40))
                    newFlag:setVisible(false)
                    frameUI:addChild(newFlag)
                    local refreshNewFlag = function ( ... )
                        if newFlag.isDisposed then return end
                        newFlag:setVisible(false)
                        local showNewFlag = HeadFrameType:setProfileContext():hasNewHeadFrame()
                        if showNewFlag then
                            newFlag:setVisible(true)
                            return
                        end
                    end
                    HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kUpdateShowTime, function ( ... )
                        refreshNewFlag()
                    end)
                    refreshNewFlag()

                    local data = HeadFrameType:find(value)
                    local t = data and data.obtainTime or 0
                    print("------newFrameID",newFrameID,newFrameGotTime,value,t)
                    if t > newFrameGotTime then
                        newFrameID = value
                        newFrameGotTime = t
                    end
                end

                indexNode = indexNode + 1
            end
        end

        local item = page.container:getContent():getItems()[1]
        item:setHeight(item:getHeight() + 15)
        UIHelper:move(item, 0, -0)
        
        function page:onShow( bShow )
            if self.isDisposed then return end
            if bShow then
                self:select(1)
                local curFrameId = HeadFrameType:setProfileContext(nil):getCurHeadFrame()
                local index = self.frameIdMapIndex[curFrameId]
                if index then
                    self:select(index)
                end
            end
        end
        
        function page:onTapItem( tapIndex )
            if self.isDisposed then return end
            if _G.isLocalDevelopMode then printx(100, " onTapItem ---tapIndex  = " ,tapIndex ) end
            local tapId = nil
            for id, index in pairs(self.frameIdMapIndex) do
                if index == tapIndex then
                    tapId = id
                    break
                end
            end

            local frames = HeadFrameType:setProfileContext(nil):getAvaiHeadFrame()
            local isMine = table.find( frames ,function ( frameNode )
                return frameNode.id == tapId
            end)

            if tapId then

                local canUse = true
                if not HeadFrameType:setProfileContext(nil):setCurHeadFrame(tapId) then
                --    "head.frame.invalid" = "该头像框已过期~";
                    -- CommonTip:showTip(localize('head.frame.invalid'))
                    -- return
                    canUse = false
                end

                if isMine and canUse then
                    self:select(tapIndex)
                    DcUtil:UserTrack({category='UI', sub_category='change_head_frame', t1 = tapId}, false)
                end
                
                if page.descPanel then
                    if not page.descPanel.isDisposed then
                        page.descPanel:removeFromParentAndCleanup(true)
                    end
                end

                local hasLockIcon = false
                local itemNode = self:getItem( tapIndex )
                if itemNode and itemNode.hasBlack ~=nil then
                    hasLockIcon = itemNode.hasBlack 
                end

                local descPanel = HeadFrameType:setProfileContext():buildDescUI( tapId ,hasLockIcon )
                descPanel:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(function ( ... )
                    if descPanel.isDisposed then return end
                    descPanel:removeFromParentAndCleanup(true)
                end)))

                local descPanelInputLayer = Layer:create()

                descPanelInputLayer:setTouchEnabled(true, nil, false, function ( ... )
                    return true
                end, true, true)

                descPanelInputLayer:ad(DisplayEvents.kTouchTap, function ( ... )
                    if descPanel.isDisposed then return end
                    descPanel:removeFromParentAndCleanup(true)
                end)

                descPanel:addChild(descPanelInputLayer)

                local pos = self:getItemPosInWorld(tapIndex)
                if pos then
                    pos = ccp(pos.x, pos.y - 50)
                    descPanel:setPosition(context:convertToNodeSpace(pos))
                    context:addChild(descPanel)

                    if descPanel:getGroupBounds().origin.y < 0 then
                        --  旋转箭头术
                        local arrow = descPanel:getChildByName('arrow')
                        arrow:setRotation(180)

                        for _, v in ipairs(descPanel:getChildrenList() or {}) do
                            if v.name ~= 'arrow' then
                                v:setPositionY(v:getPositionY() + 200 + 25)
                            end
                        end

                        pos = ccp(pos.x, pos.y + 100)
                        descPanel:setPosition(context:convertToNodeSpace(pos))
                    end

                end

                page.descPanel = descPanel
            end
        end


        return page.container , page
    end

    local function createZeroHeadFramePage( ... )
        local page = context.buildFunc('edit_hf_zero')
        page:setPositionX(20)
        page:getChildByPath('label0'):setString('您当前还没有头像框')
        page:getChildByPath('label1'):setString('帮助10个好友代打过关获得')
        page:getChildByPath('label2'):setString('参与周赛并升至初级士兵获得')
        return page
    end


    local headFramePageContainer , pageForGUide= createHeadFramePage()

    self.headFramePageForGuide = pageForGUide
    self.headFramePage = headFramePageContainer.page
    self.headFramePageContainer = headFramePageContainer

    self:addChild(headFramePageContainer)
    headFramePageContainer:setPositionX(contentHolder:getPositionX())
    headFramePageContainer:setPositionY(contentHolder:getPositionY())
    self.headFramePage:onShow(true)

    if newFrameID > 0 then
        local index = self.headFramePage.frameIdMapIndex[newFrameID]
        print("---------newFrameID",newFrameID,index,HeadFrameType:getCurHeadFrame())
        self.headFramePage:select(index)
        HeadFrameType:setProfileContext(nil):setCurHeadFrame(newFrameID)
        -- HeadFrameType:setProfileContext(nil):updateAll()
        -- self.headFramePage:onTapItem(index)
    end

end

