local UIHelper = require 'zoo.panel.UIHelper'
local PrivateStrategy = require 'zoo.data.PrivateStrategy'
local AvatarSelectGroup = class()

-- local print = function ( str )
-- 	oldPrint("[AvatarSelectGroup] "..str)
-- end

-- local print = oldPrint
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
function AvatarSelectGroup:buildGroup(manager, moreAvatars, avatar, nameLabel, changePlayerCb, buildFunc)
    local group = AvatarSelectGroup.new()
    group:init(manager, moreAvatars, avatar, nameLabel, changePlayerCb, buildFunc)
    return group
end

function AvatarSelectGroup:init(manager, moreAvatars, avatar, nameLabel, changePlayerCb, buildFunc)

    self.kMaxHeadImages = UserManager.getInstance().kMaxHeadImages

    self.newHeadFrameNode = nil 

    self.buildFunc = buildFunc
	self.moreAvatarList = {}
    self.manager = manager
    self.changePlayerCb = changePlayerCb

    self.customAvatarIndex = 11
    local fileId = UserManager:getInstance().profile.fileId
    local function getCustomHeadUrl()
        if fileId and fileId ~= '' then
            return "http://animal-10001882.image.myqcloud.com/"..fileId
        elseif tonumber(UserManager:getInstance().profile.headUrl) == nil then
            return tostring(UserManager:getInstance().profile.headUrl)
        end
    end

    self.customHeadUrl = getCustomHeadUrl()
    

    local config = {
        [PlatformAuthEnum.kWeibo]  = "微博",
        [PlatformAuthEnum.kQQ]     = "QQ",
        [PlatformAuthEnum.kWDJ]    = "豌豆荚",
        [PlatformAuthEnum.kMI]     = "小米",
        [PlatformAuthEnum.k360]    = "360",
    }

    local function changeNameAndHeadTip(tipKey)
        if _G.sns_token then
            local authorizeType = SnsProxy:getAuthorizeType()
            local text = localize(tipKey, {platform = config[authorizeType]})
            CommonTip:showTip(text)
        end
    end

    if nameLabel then
        self.nameLabel = nameLabel
        local touch = self.nameLabel:getChildByName("touch")
        touch:setVisible(false)
        self.nameLabel:getChildByName("label"):setColor(hex2ccc3('A14A0E'))

        local label = self.nameLabel:getChildByName("label")
        label:setString(self:formatName(nameDecode(manager:getData(manager.NAME))))

        self.nameLabel:getChildByName("inputBegin"):setVisible(false)

        self.isNickNameUnModifiable = manager:getData(manager.NAME_MODIFIABLE)
        self.nameLabel:getChildByName("label"):setVisible(false)
        self:initInput()
    end

	self.moreAvatars = moreAvatars

    local winSize = Director:sharedDirector():ori_getVisibleSize()


    local shadow = LayerColor:createWithColor(ccc3(0, 0, 0), winSize.width, winSize.height)
    shadow:setOpacity(150)
    shadow:setPosition(ccp(0, 0))
    shadow:ignoreAnchorPointForPosition(false)
    shadow:setTag(HeDisplayUtil.kIgnoreGroupBounds)


    function shadow:onAddToStage() 
        if self.isDisposed then return end
        local leftBottom = moreAvatars:getChildByPath('bg0'):convertToNodeSpace(ccp(0, 0))
        local rightTop = moreAvatars:getChildByPath('bg0'):convertToNodeSpace(ccp(winSize.width, winSize.height))
        self:setContentSize(CCSizeMake(rightTop.x - leftBottom.x, rightTop.y - leftBottom.y + 1))
        self:setPosition(ccp(leftBottom.x, leftBottom.y))
    end

    UIUtils:setTouchHandler(shadow, function ( ... )
        self:closeMoreAvatars()
    end, function ( worldPos )
        if self.moreAvatars.isDisposed then return end
        if moreAvatars:getChildByPath('bg0'):hitTestPoint(worldPos, true) then
            return false
        end
        return shadow:hitTestPoint(worldPos, true)
    end)


    UIUtils:setTouchHandler(self.moreAvatars:getChildByPath('bg0'), function ( ... )
    end)


    self.moreAvatars:getChildByPath('bg0'):addChild(shadow)
    shadow.refCocosObj:setZOrder(-1)

    self.moreAvatars:setVisible(false)

    self.avatar = avatar
    self.playerAvatar = self:initAvatar(self.avatar)

    local newFlag = HeadFrameType:buildNewFlag()
    newFlag:setPosition(ccp(130, -20))
    newFlag:setVisible(false)
    self.newFlag = newFlag

    self.playerAvatar:addChild(self.newFlag)

    local refreshNewFlag = function ( ... )
        if newFlag.isDisposed then return end
        newFlag:setVisible(false)
        local showNewFlag = HeadFrameType:setProfileContext():hasNewHeadFrame()
        if showNewFlag then
            self.newFlag:setVisible(true)
            return
        end
    end

    HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kUpdateShowTime, function ( ... )
        refreshNewFlag()
    end)

    refreshNewFlag()

	local headUrl = self.manager:getData(self.manager.HEAD_URL)
    self.playerAvatar:changeImage(nil, headUrl, true)

    self.isHeadImageUnModifiable = manager:getData(manager.HEAD_MODIFIABLE)
    if self.isHeadImageUnModifiable then
        local arrow = self.avatar:getChildByName("text") 
        if arrow then arrow:setVisible(false) end
    end

    local function onAvatarTouch()
        self:onAvatarTouch()
    end

    -- self:initMoreAvatars(self.moreAvatars)

    self:initPages()

    self.avatar:setTouchEnabled2(true, true, true)
    self.avatar:addEventListener(DisplayEvents.kTouchTap, onAvatarTouch)

    if _G.isLocalDevelopMode then printx(0, "init >>>>>") end
end


function AvatarSelectGroup:doSelectedForGuide(  )
    if _G.isLocalDevelopMode then printx(100, " doSelectedForGuide unIndex 1= " , self.selectGuideID  ) end
    if self.isDisposed then return end
    if not self.selectGuideID then
        return
    end
    if _G.isLocalDevelopMode then printx(100, " doSelectedForGuide unIndex 2= " , self.selectGuideID  ) end
    if self.headFramePageForGuide then
        if _G.isLocalDevelopMode then printx(100, " doSelectedForGuide unIndex 3= " , self.selectGuideID  ) end
        self.headFramePageForGuide:onTapItem( self.selectGuideID )
    end


    -- self:select( self.selectGuideID )
end
function AvatarSelectGroup:initPages( ... )
    local userId
    if UserManager:getInstance().user then
        userId = UserManager:getInstance().user.uid or 0
    end

    local context = self

    if self.moreAvatars.isDisposed then return end


    local contentHolder = self.moreAvatars:getChildByPath('content')
    local contentHolderWidth = contentHolder:getScaleX() * contentHolder:getContentSize().width
    local contentHolderHeight = contentHolder:getScaleY() * contentHolder:getContentSize().height
    contentHolder:setVisible(false)


    UIUtils:setTouchHandler(self.moreAvatars:getChildByName('closeBtn'), function ( ... )
        self:closeMoreAvatars()
    end)

    if self.moreAvatars:getChildByName('black') then
        self.moreAvatars:getChildByName('black'):setVisible( false )
    end
    if self.moreAvatars:getChildByName('lockedicon') then
        self.moreAvatars:getChildByName('lockedicon'):setVisible( false )
    end



    local cursor = self.moreAvatars:getChildByPath('cursor')
    local addIcon = self.moreAvatars:getChildByPath('+')
    local row = self.moreAvatars:getChildByPath('row')

    local label_1 = self.moreAvatars:getChildByPath('label_1')
    local tab_f_1 = self.moreAvatars:getChildByPath('tab_f_1')
    local tab_b_1 = self.moreAvatars:getChildByPath('tag_b_1')

    -- cursor:setVisible(false)
    addIcon:setVisible(false)
    row:setVisible(false)
    label_1:setVisible(false)
    tab_f_1:setVisible(false)
    tab_b_1:setVisible(false)

    addIcon:setAnchorPoint(ccp(0.5, 0.5))
    cursor:setAnchorPoint(ccp(0.5, 0.5))

    local function addChildInPlace( parent, node, target )

        if self.moreAvatars.isDisposed then return end

        local index = parent:getChildIndex(target)
        parent:addChildAt(node, index)
    end

    local pages = {

    }

    local tabs_fg = {

    }

    local tabs_bg = {

    }

    local tabs_label = {

    }

    local bg_offset = tab_b_1:getPositionX()
    local fg_offset = tab_f_1:getPositionX()
    local label_offset = label_1:getPositionX()

    local delta = 150


    local function showPage( pageIndex )

        if pageIndex == 1 then
            DcUtil:UserTrack({category='UI', sub_category='open_head_frame_panel'}, false)
        end


        if self.moreAvatars.isDisposed then return end


        local function __do( v, index )
            v:setVisible(index == pageIndex)
            if v.page and v.page.onShow then
                v.page:onShow(index == pageIndex)
            end
        end
        local function __do2( v, index )
            v:setVisible(index ~= pageIndex)
        end

        table.walk(pages, __do)
        -- table.walk(tabs_label, __do)
        table.walk(tabs_fg, __do)
        table.walk(tabs_bg, __do2)

    end


    local function addPage( title, page )

        if self.moreAvatars.isDisposed then return end

        -- body
        local label = TextField:createCopy(label_1)
        label:setVisible(true)
        label:setString(title)

        addChildInPlace(self.moreAvatars, label, label_1)

        local fg = tab_f_1:clone()
        local bg = tab_b_1:clone()

        fg:setAnchorPoint(ccp(0, 1))
        bg:setAnchorPoint(ccp(0, 1))

        fg:getPositionY(tab_f_1:getPositionY())
        bg:getPositionY(tab_b_1:getPositionY())

        fg:setPositionX(fg_offset)
        bg:setPositionX(bg_offset)
        label:setPositionX(label_offset)

        fg_offset = fg_offset + delta
        bg_offset = bg_offset + delta
        label_offset = label_offset + delta


        addChildInPlace(self.moreAvatars, fg, tab_f_1)
        addChildInPlace(self.moreAvatars, bg, tab_b_1)

        table.insert(pages, page)
        table.insert(tabs_fg, fg)
        table.insert(tabs_bg, bg)
        table.insert(tabs_label, label)

        local myIndex = #pages

        UIUtils:setTouchHandler(bg, function ( ... )
            if self.moreAvatars.isDisposed then return end

            showPage(myIndex)
        end)

        self.moreAvatars:addChild(page)
        page:setPositionX(contentHolder:getPositionX())
        page:setPositionY(contentHolder:getPositionY())

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
                local blackSprite = Sprite:createWithSpriteFrameName( "assert_00/blackbg0000" )
                item:addChildAt( blackSprite , 29 )
                blackSprite:setPositionX( 125/2 )
                blackSprite:setPositionY( 125/2 )
                local lockIcon = Sprite:createWithSpriteFrameName( "assert_00/lockedicon0000" )
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

            local rowUI = context.buildFunc(row.symbolName)
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
                    if context.moreAvatars.isDisposed then return false end
                    if not thisItem:hitTestPoint(worldPos, true) then return false end

                    local pos = context.moreAvatars:convertToNodeSpace(worldPos)
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

        -- scroll:setScrollEnabled(nRow > 3)

        page:setPositionX(20)
        page:setPositionY(-10)
        return page

    end

    local function createHeadImagePage( ... )

        if self.moreAvatars.isDisposed then return end
        local profile_url = self.manager:getData(self.manager.HEAD_URL)
        local page = createPage(16)

        for index = 0 , self.kMaxHeadImages do
            local headUrl = tostring(index)
            local headImage = HeadImageLoader:create(userId, headUrl)
            headImage:setTag(HeDisplayUtil.kIgnoreGroupBounds)
            page:setContent(index + 2, headImage)
        end


        function page:refresh( ... )
            if self.isDisposed then return end
            for i = context.kMaxHeadImages + 2, 2, -1 do
                self:swapView(i, context.kMaxHeadImages + 3)
            end
        end

        
        if self.customHeadUrl then
            local headImage = HeadImageLoader:create(userId, self.customHeadUrl)
            headImage:setTag(HeDisplayUtil.kIgnoreGroupBounds)
            page:setContent(self.kMaxHeadImages + 3, headImage)
            page:refresh()
        end

        

        function page:onShow( bShow )
            if self.isDisposed then return end

            if bShow then
                addIcon:setVisible(true)
            else
                addIcon:setVisible(false)
            end

            if bShow then

                self:select(1, addIcon)

                local profile_url = context.manager:getData(context.manager.HEAD_URL)
                local isCustom = (tonumber(profile_url) == nil)

                local curIndex = 1

                if isCustom then
                    curIndex = context.kMaxHeadImages + 3
                else
                    curIndex = tonumber(profile_url) + 2
                end

                self:select(curIndex, cursor)
            end

        end

        function page:onTapItem( index )
            
            if self.isDisposed then return end

            DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t2=1}, true)

            local headUrl

            if index == 1 then

                local function editHeadURL( ... )
                    local canCustomHead = context.manager:getData(context.manager.ENABLE_CUSTOM_HEAD)
                    if not canCustomHead then
                        CommonTip:showTip('游客不能上传自定义头像哦~')
                    else
                        local dcData = {}
                        dcData.category = "edit_data"
                        dcData.sub_category = "edit_photo"
                        dcData.t2 = 2
                        DcUtil:log(AcType.kUserTrack, dcData, true)

                        PaymentNetworkCheck.getInstance():check(
                            function ()
                                -- local onButton1Click = function()
                                    context:buildPhotoView()
                                -- end
                                -- CommonAlertUtil:showPrePkgAlertPanel(onButton1Click, NotRemindFlag.PHOTO_ALLOW, Localization:getInstance():getText("pre.tips.photo"),nil,nil,nil,nil,nil,RequestConst.PHOTO_ALLOW)
                            end, 
                            function ()
                                CommonTip:showTip(localize("dis.connect.warning.tips"), "negative",nil, 2)
                            end)
                        end
                end 
                PrivateStrategy:sharedInstance():Alert_EditHead(editHeadURL)
            elseif index <= context.kMaxHeadImages + 2 then
                headUrl = tostring(index - 2)
            elseif index == context.kMaxHeadImages + 3 then
                if context.customHeadUrl then
                    headUrl = context.customHeadUrl
                end
            end

            if headUrl then
                context:changeAvatarImage(headUrl, true)
            end

        end

        return page.container 

    end


    local function createHeadFramePage( ... )

        -- body
        -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage ---------------- "  ) end

        local frames = HeadFrameType:setProfileContext(nil):getAvaiHeadFrame()

        local sortHeadFrameType = {}


        local meta = MetaManager:getInstance().headframe

        -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage --meta = " ,table.tostring(meta) ) end

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
                        -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage --timeout = " , timeout) end
                        -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage --endTime = " , endTime) end
                        -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage --now = " , now) end
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
    --    local page = createPage(math.max(#frames, 12))

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

        -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage frames = " , table.tostring(frames) ) end



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

                -- if _G.isLocalDevelopMode then printx(100, "createHeadFramePage k = valueNode = frameIsTimeLimit" , k , value ,frameIsTimeLimit ) end

                local timeLimitIcon =nil 
                if frameIsTimeLimit then
                    timeLimitIcon = ResourceManager:sharedInstance():buildGroup('jHeadUI/timeicon')
                    if timeLimitIcon then
                        -- frameUI:addChildAt(timeLimitIcon ,31)
                        
                    end
                end

                page:setContent( indexNode , frameUI ,hasIt ,true, timeLimitIcon )
                page.frameIdMapIndex[ value ] = indexNode

                -- if HeadFrameType:setProfileContext():isNew( value ) then
                --     if not self.newHeadFrameNode then
                --         self.newHeadFrameNode = frameUI
                --         self.selectGuideID = indexNode
                --         self.selectedFrameID = value
                --     end
                --     local newFlag = HeadFrameType:buildNewFlag()
                --     newFlag:setPosition(ccp(40, 40))
                --     newFlag:setVisible(false)
                --     frameUI:addChild(newFlag)
                --     local refreshNewFlag = function ( ... )
                --         if newFlag.isDisposed then return end
                --         newFlag:setVisible(false)
                --         local showNewFlag = HeadFrameType:setProfileContext():hasNewHeadFrame()
                --         if showNewFlag then
                --             newFlag:setVisible(true)
                --             return
                --         end
                --     end
                --     HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kUpdateShowTime, function ( ... )
                --         refreshNewFlag()
                --     end)
                --     refreshNewFlag()
                -- end

                -- if indexNode == 4 then
                --     if not self.newHeadFrameNode then
                --         self.newHeadFrameNode = frameUI
                --         self.selectGuideID = indexNode
                --     end
                -- end
                

                indexNode = indexNode + 1
            end

        end




        -- for i, v in ipairs(frames) do
        --     if _G.isLocalDevelopMode then printx(100, "for i, v in ipairs(frames) do v.id = i = " , v.id , i ) end
        --     local frameUI = HeadFrameType:buildUI(v.id, 1, userId)
        --     local holder = frameUI:getChildByName('head')
        --     local size = holder:getContentSize()
        --     local center = ccp(size.width/2, size.height/2)
        --     local posInFrameUI = frameUI:convertToNodeSpace(holder:convertToWorldSpace(center))
        --     frameUI:setScale(0.8*1.30)

        --     UIHelper:move(frameUI:getChildByPath('headFrame'), -posInFrameUI.x, -posInFrameUI.y)
        --     holder:removeFromParentAndCleanup(true)

        --     if HeadFrameType:setProfileContext():isTimeLimit(v.id) then
        --         local timeLimitIcon = ResourceManager:sharedInstance():buildGroup('jHeadUI/timeicon')
        --         if timeLimitIcon then
        --             frameUI:addChild(timeLimitIcon)
        --             timeLimitIcon:setPositionY(-40)
        --         end
        --     end

        --     page:setContent(i, frameUI)
        --     page.frameIdMapIndex[v.id] = i

        --     if HeadFrameType:setProfileContext():isNew(v.id) then
        --         local newFlag = HeadFrameType:buildNewFlag()
        --         newFlag:setPosition(ccp(40, 40))
        --         newFlag:setVisible(false)
        --         frameUI:addChild(newFlag)
        --         local refreshNewFlag = function ( ... )
        --             if newFlag.isDisposed then return end
        --             newFlag:setVisible(false)
        --             local showNewFlag = HeadFrameType:setProfileContext():hasNewHeadFrame()
        --             if showNewFlag then
        --                 newFlag:setVisible(true)
        --                 return
        --             end
        --         end
        --         HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kUpdateShowTime, function ( ... )
        --             refreshNewFlag()
        --         end)
        --         refreshNewFlag()
        --     end
        -- end

        local item = page.container:getContent():getItems()[1]
        item:setHeight(item:getHeight() + 15)
        UIHelper:move(item, 0, -0)
        
        function page:onShow( bShow )
            if self.isDisposed then return end
            if bShow then
                self:select(1, addIcon)
                local curFrameId = HeadFrameType:setProfileContext(nil):getCurHeadFrame()
                local index = self.frameIdMapIndex[curFrameId]
                if index then
                    self:select(index, cursor)
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
                    self:select(tapIndex, cursor)
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
                    descPanel:setPosition(context.moreAvatars:convertToNodeSpace(pos))
                    context.moreAvatars:addChild(descPanel)

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
                        descPanel:setPosition(context.moreAvatars:convertToNodeSpace(pos))
                    end

                end

                page.descPanel = descPanel

            end

        end

        HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kHeadFrameAutoChange, function ( ... )
            if page.isDisposed then
                return
            end
            if page:isRealVisible() then
                page:onShow(true)
            end
        end)

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


    local headImagePageContainer  = createHeadImagePage()


    self.headImagePage = headImagePageContainer.page
    self.headImagePageContainer = headImagePageContainer


    local headFramePageContainer , pageForGUide= createHeadFramePage()

    self.headFramePageForGuide = pageForGUide
    self.headFramePage = headFramePageContainer.page
    self.headFramePageContainer = headFramePageContainer

    addPage('头像框', headFramePageContainer)
    

    addPage('头像', headImagePageContainer)

    

    self.refreshPage = function ( ... )
        
        if #HeadFrameType:setProfileContext():getAvaiHeadFrame() <= 1 then
            showPage(2)
        else
            showPage(1)
        end
    end
end



function AvatarSelectGroup:closeMoreAvatars()
    if self.moreAvatars:isVisible() then
        self:onAvatarTouch()
        HeadFrameType:setProfileContext():updateShowTime()
        return true
    end
    return false
end

local function splitChars( text,maxCount,filterFunc )

    local charTab = {}
    local count = 0
    for uchar in string.gfind(text, "[%z\1-\127\194-\244][\128-\191]*") do
        if count >= maxCount then
            return charTab,count,true
        end
        if uchar ~= '\n' and uchar ~= '\r' then
            if not filterFunc or filterFunc(uchar) then 
                table.insert(charTab, uchar)
                count = count + 1
            end
        else
            table.insert(charTab, uchar)
        end
    end

    return charTab,count,false 
end

function AvatarSelectGroup:formatName(name)
    local label = self.nameLabel:getChildByName("label")
    local str = TextUtil:ensureTextWidth(tostring(name), label:getFontSize(),label:getDimensions())
    return str
end

function AvatarSelectGroup:initInput(onBeginCallback)
    local user = UserManager.getInstance().user
    local profile = UserManager.getInstance().profile   
    local inputSelect = self.nameLabel:getChildByName("inputBegin")
    local inputSize = inputSelect:getContentSize()
    local inputPos = inputSelect:getPosition()
    inputSelect:setVisible(true)
    inputSelect:removeFromParentAndCleanup(false)

    local function onTextBegin()
        local place = self.originalPlace or 1
        DcUtil:UserTrack({category='my_card', sub_category="my_card_click_edit_name", place = place}, true)
        if onBeginCallback then onBeginCallback() end
    end
    
    local function onTextEnd()
        if self.input then
            local profile = UserManager.getInstance().profile
            local text = self.input:getText() or ""
            if text ~= "" then
                -- 敏感词过滤
                local oldName = nameDecode(profile.name or "")
                if IllegalWordFilterUtil.getInstance():isIllegalWord(text) then
                    self.input:setText(self:formatName(oldName))
                    CommonTip:showTip(Localization:getInstance():getText("error.tip.illegal.word"), "negative")
                else
                    if oldName ~= text then
                        --profile:setDisplayName(text)
                        if self.originalPlace == 0 then
                            self.manager:setData(self.manager.NAME, text)
                            DcUtil:UserTrack({category='my_card', sub_category="my_card_profile_name"}, true)
                            self.manager:uploadUserProfile(true)
                        else
                            if self.changeName then
                                self.changeName(text)
                            end
                        end
                    end
                    self.input:setText(self:formatName(text))
                end
            else
                self.input:setText(self:formatName(profile:getDisplayName()))
                CommonTip:showTip(Localization:getInstance():getText("game.setting.panel.username.empty"), "negative")
            end
        end
    end

    local position = ccp(inputPos.x + inputSize.width/2, inputPos.y - inputSize.height/2)
    local input = TextInputIm:create(inputSize, Scale9Sprite:createWithSpriteFrameName("personal/ui_empty0000"), inputSelect.refCocosObj)

    if __IOS then
        local oldSetText = input.setText
        input.setText = function ( _, str )
            
            local displayName = str or ''
            if displayName and #displayName > 12 then
                local tbl = splitChars(displayName, 12)
                displayName = table.concat(tbl, '')
            end
            oldSetText(_, displayName)
        end
    end

    if __WP8 then
        self:clampWp8Input(input)
    end

    input.originalX_ = position.x
    input.originalY_ = position.y

    input:setText(self:formatName(profile:getDisplayName()))
    input:setPosition(position)
    input:setFontColor(hex2ccc3('A14A0E'))
    input:setMaxLength(12)
    input:ad(kTextInputEvents.kBegan, onTextBegin)
    input:ad(kTextInputEvents.kEnded, onTextEnd)
    self.nameLabel:addChild(input)
    self.input = input

    if not __IOS then
        self.input.refCocosObj:setTouchPriority(0)
    end

    inputSelect:dispose()
end

function AvatarSelectGroup:onAvatarTouch()
    if self.isHeadImageUnModifiable then
        self.moreAvatars:setVisible(false)
        if self.endEditCallback then
            self.endEditCallback()
        end
        return
    end

    if self.moreAvatars:isVisible() then 
        if self.oldID ~= UserManager:getInstance().profile.headFrame then
            HeadFrameType:requestSave()
        end

        self.moreAvatars:setVisible(false)
        if self.endEditCallback then
            self.endEditCallback()
        end

    else 
        self.oldID = UserManager:getInstance().profile.headFrame
        
        local place = self.originalPlace or 1
        DcUtil:UserTrack({category='my_card', sub_category="my_card_click_edit_photo", place = place}, true)
        DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t1 = 1}, true)
        self.moreAvatars:setVisible(true)

        if self.closeOtherPanel then
            self.closeOtherPanel()
        end

        if self.beginEditCallback then
            self.beginEditCallback()
        end

        if self.headFramePageContainer then
            self.headFramePageContainer:scrollToTop(0)
        end

        if self.headImagePageContainer then
            self.headImagePageContainer:scrollToTop(0)
        end

        if self.refreshPage then
            self.refreshPage()
        end
    end
end

function AvatarSelectGroup:clampWp8Input( input )
    input.setText = function ( _input, oriText )
        local width = 200
        local posX=0
        local posY=0
        local cacheWidths = {}
        local cacheLabels = {}
        local function createLabel(text)
            if cacheLabels[text] and cacheLabels[text]:getParent() then 
                 cacheLabels[text] = nil
            end
            if not cacheLabels[text] then 
                cacheLabels[text] = CCLabelTTF:create(text,"",30)
            end
            return cacheLabels[text]
        end
        local function measureWidth(text)
            if not cacheWidths[text] then 
                local label = createLabel(text)
                cacheWidths[text] = label:getContentSize().width
            end
            return cacheWidths[text]
        end

        local t = {}
        for uchar in string.gfind(oriText, "[%z\1-\127\194-\244][\128-\191]*") do
            t[#t + 1] = uchar
        end

        local function sub( s,e )
            local t2 = {}
            for i=s,e do
                t2[i-s+1] = t[i]
            end
            return table.concat(t2,"")
        end

        local start = 1
        local str = ""

        local len = #t - start + 1
        local _end = #t
        local i = 2
        local newLine = false
        while true do 
            newLine = false
            local str1 = sub(start,_end)
            if str1 == "" then
                str = ""
                _end = start - 1
                newLine = true
                break
            end

            local w1 = measureWidth(str1)
            if _end == #t and posX + w1 <= width then --or str1 == "" 
                str = str1
                break
            end
            local str2 = sub(start,math.min(#t,_end + 1))
            local w2 = measureWidth(str2)

            if posX + w1 <= width and posX + w2 > width then 
                str = str1
                newLine = true
                break
            end

            if posX + w1 > width then 
                _end = _end - math.ceil(len / i) 
            elseif posX + w2 <= width then 
                _end = _end + math.ceil(len / i)
            end
            i = i * 2
        end

         _input.refCocosObj:setText(str)
    end
end

local hasLogDC = false
local initLogDC = true

function AvatarSelectGroup:initAvatar( group, extraScale)
    if not group then return nil end
    local avatarPlaceholder = group:getChildByName("avatarPlaceholder")
    local frameworkChosen = group:getChildByName("frameworkChosen")
    if frameworkChosen then 
        frameworkChosen:setVisible(false) 
    end

    local hitArea = CocosObject:create()
    hitArea.name = kHitAreaObjectName
    hitArea:setContentSize(CCSizeMake(100,100))
    hitArea:setPosition(ccp(0, 0))
    avatarPlaceholder:addChild(hitArea)

    
    group.chooseIcon = frameworkChosen
    group.select = function ( avatar, val )
        if avatar.chooseIcon then 
            avatar.chooseIcon:setVisible(val)
            avatar.selected = val
        end
    end
    group.changeImage = function( avatar, userId, headUrl)
        if avatar == nil or headUrl == nil or headUrl == "nil" or headUrl == "" then return end

        if not userId then
            if UserManager:getInstance().user then
                userId = UserManager:getInstance().user.uid or 0
            end
        end

        local oldImageIndex = nil

        if avatar.isCustomAvatar == true then

        end

        if avatar.headImage then 
            oldImageIndex = avatar.headImage.headImageUrl
            avatar.headImage:removeFromParentAndCleanup(true)
            avatar.headImage = nil
        end

        local frameSize = avatarPlaceholder:getContentSize()
        local function onImageLoadFinishCallback(clipping)
            if avatar.isDisposed then return end
            local clippingSize = clipping:getContentSize()
            local scale = frameSize.width/clippingSize.width
            clipping:setScale(scale*(extraScale or 1) )
            clipping:setPosition(ccp( frameSize.width/2,frameSize.height/2))
            avatarPlaceholder:addChild(clipping)
            avatar.headImage = clipping
            
        end
        local head = HeadImageLoader:createWithFrame(userId, headUrl)
        onImageLoadFinishCallback(head)
        return oldImageIndex
    end
    return group
end

function AvatarSelectGroup:changeAvatarImage(headUrl, modify)

    if modify and self.changePlayerCb then 
        self.changePlayerCb(headUrl)
    end
    
    local isCustom = (tonumber(headUrl) == nil)

    if isCustom then

        if headUrl ~= self.customHeadUrl then
            local userId
            if UserManager:getInstance().user then
                userId = UserManager:getInstance().user.uid or 0
            end
            self.headImagePage:setContent(self.kMaxHeadImages + 3, HeadImageLoader:create(userId, headUrl))
        end

        if not self.customHeadUrl then
            self.headImagePage:refresh()
        end

        self.customHeadUrl = headUrl
    end

    if isCustom then
        self.headImagePage:select(self.kMaxHeadImages + 3)
    else
        self.headImagePage:select(tonumber(headUrl) + 2)
    end

    if self.playerAvatar then self.playerAvatar:changeImage(nil, tostring(headUrl)) end
end


local function buildPhotoBtn( name, width, height, tap )
    local btn = LayerColor:createWithColor(ccc3(255,255,255), width, height)
    btn:setTouchEnabled2(true, true, true)
    btn:ad(DisplayEvents.kTouchTap, tap)

    local text = TextField:create(name, nil, 40, nil, hAlignment, kCCVerticalTextAlignmentCenter)
    text:setColor(ccc3(208,159,82))
    text:setPosition(ccp(width / 2, height / 2))
    btn:addChild(text)
    return btn
end

function AvatarSelectGroup:closePhotoView()
    if self.photoView and not self.photoView.isDisposed then
        self.photoView:removeFromParentAndCleanup(true)
        self.photoView:dispose()
        self.photoView = nil
    end
end

function AvatarSelectGroup:buildPhotoView()
    if self.photoView then return end
    local size = Director:sharedDirector():getVisibleSize()
    local origin = Director:sharedDirector():getVisibleOrigin()
    local height = 76
    local bg = LayerColor:createWithColor(ccc3(0,0,0), size.width, size.height)
    bg.hitTestPoint = function ()
        return true
    end
    bg:setTouchEnabled2(true, true, true)
    bg:setOpacity(100)

    local colorBg = LayerColor:createWithColor(ccc3(255,207,128), size.width, 238)
    bg:addChild(colorBg)

    local function closeView()
        self:closePhotoView()
    end

    local photoBtn = buildPhotoBtn(localize("my.card.edit.panel.text2"), size.width, height, function ()
        closeView()
        self:takePhoto()
    end)

    local selectPictureBtn = buildPhotoBtn(localize("my.card.edit.panel.text3"), size.width, height, function ()
        closeView()
        self:selectPicture()
    end)

    local cancelBtn = buildPhotoBtn(localize("my.card.edit.panel.text4"), size.width, height, closeView)

    selectPictureBtn:setPositionY(height + 10)
    photoBtn:setPositionY(2 * height + 12)

    bg:addChild(cancelBtn)
    bg:addChild(selectPictureBtn)
    bg:addChild(photoBtn)

    self.photoView = bg
    local parent = self.moreAvatars:getParent()
    local pos = parent:convertToNodeSpace(origin)
    bg:setPosition(ccp(pos.x, pos.y))
    parent:addChild(bg)

    local pos1 = parent:convertToNodeSpace(ccp(0, 0))
    local pos2 = parent:convertToNodeSpace(ccp(1, 1))

    -- CommonTip:showTip(tostring(pos2.x - pos1.x))
    self.photoView:setScale(pos2.x - pos1.x)
end

function AvatarSelectGroup:takeImageSuccess( path )

    if __IOS and path then
        local oriSizePath = path .. '_oriSize'
        if HeFileUtils:exists(oriSizePath) then
            HeFileUtils:removeFile(oriSizePath)
        end
    end

    local fileId = UserManager:getInstance().profile.fileId
    local expired = Localhost:timeInSec() + 60

    local function onSuccess( evt )
        self:uploadImage(path, evt.data)
    end

    local function onFail( evt )
        
    end

    self:getSign(fileId, expired, onSuccess, onFail)
end

function AvatarSelectGroup:getSign(fileId, expired, onSuccess, onFail )
    local http = GetSignHttp.new()
    http:ad(Events.kComplete, onSuccess)
    http:ad(Events.kError, onFail)
    http:load(fileId, expired)
end

function AvatarSelectGroup:uploadImage( path, data )
    local function onSuccess(fileId, headUrl )
        if _G.isLocalDevelopMode then printx(0, "uploadImage success >>> ",fileId, headUrl) end

        --data.pornDetectSignCI
        self:pornDetect(headUrl, fileId)
        self:delImage(data.signOnceCI)
        UserManager:getInstance().profile.fileId = fileId
        
        if not self.moreAvatars.isDisposed then
            DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t3=1}, true)
            self:changeAvatarImage(headUrl, true)
        else
            self.manager:setData(self.manager.HEAD_URL, tostring(headUrl))
            self.manager:uploadUserProfile(true)
            if self.needUpdateHead then
                local avatarSelectGroup = nil
                if self.originalPlace == 0 then
                    if self.manager.panel then
                        avatarSelectGroup = self.manager.panel.avatarSelectGroup
                    end
                elseif self.manager.panel and self.manager.panel.editPanel then
                    avatarSelectGroup = self.manager.panel.editPanel.avatarSelectGroup
                end

                if avatarSelectGroup and not avatarSelectGroup.isDisposed then
                    avatarSelectGroup:changeAvatarImage(headUrl, true)
                end

                self.parent = nil
                DcUtil:UserTrack({category='edit_data', sub_category="edit_photo", t3=1}, true)
            end
        end

        DcUtil:UserTrack({category='my_card', sub_category="my_card_upload_photo"}, true)
    end

    local function onError( errCode, errMsg )
        if _G.isLocalDevelopMode then printx(0, "uploadImage error >>> ", errCode, errMsg) end
    end

    PhotoUpload:upload(path, data.signCI, onSuccess, onError)
end

function AvatarSelectGroup:pornDetect(headUrl, fileId )
    local function _pornDetect(evt)
        PhotoUpload:pornDetect(headUrl, evt.data.pornDetectSignCI, 
                                function ( msg )
                                    if _G.isLocalDevelopMode then printx(0, "pornDetect success >>> ", msg) end
                                end, 
                                function ( errCode, errMsg )
                                    if _G.isLocalDevelopMode then printx(0, "pornDetect error >>> ", errCode, errMsg) end
                                end
                                )
    end

    local selfPhotoCheckFeature = MaintenanceManager:getInstance():isEnabled("SelfPhotoCheckFeature")
    if selfPhotoCheckFeature then
        self:getSign(fileId, Localhost:timeInSec() + 60, _pornDetect,function (evt)--[[do nothing]]  end)
    end
end

function AvatarSelectGroup:delImage(sign )
    local function onSuccess( msg )
        if _G.isLocalDevelopMode then printx(0, "delImage success >>> ", msg) end
    end

    local function onError( errCode, errMsg )
        if _G.isLocalDevelopMode then printx(0, "delImage error >>> ", errCode, errMsg) end
    end

    local fileId = UserManager:getInstance().profile.fileId
    if _G.isLocalDevelopMode then printx(0, "fileId >>> ", fileId) end

    if fileId ~= nil and fileId ~= "" and type(fileId) == "string" and sign ~= nil then
        PhotoUpload:del(fileId, sign, onSuccess, onError)
    end
end

function AvatarSelectGroup:selectPicture()

    self.selectingPhoto = true

    local cb = {
        onSuccess = function ( path )

            self.selectingPhoto = false

            if path ~= nil then
                self:takeImageSuccess(path)
            end
            self.manager:setData(self.manager.IS_TAKE_PHOTO, false)
        end,
        onError = function ( code, errMsg )

            self.selectingPhoto = false

            if _G.isLocalDevelopMode then printx(0, "selectPicture error ", code, errMsg) end
            self.manager:setData(self.manager.IS_TAKE_PHOTO, false)
            CommonTip:showTip(localize("my.card.edit.panel.warning.photo"), nil, nil, 3)
        end,
        onCancel = function ()

            self.selectingPhoto = false

            if _G.isLocalDevelopMode then printx(0, "selectPicture cancel") end
            self.manager:setData(self.manager.IS_TAKE_PHOTO, false)
        end,
    }

    local isTakePhoto = self.manager:getData(self.manager.IS_TAKE_PHOTO)
    if not isTakePhoto then
        self.manager:setData(self.manager.IS_TAKE_PHOTO, true)
        HeadPhotoTaker:selectPicture(cb)
    end
end

function AvatarSelectGroup:closeNativePhotoView( ... )


    if (not self.selectingPhoto) and self.takingPhoto then
        self.manager:setData(self.manager.IS_TAKE_PHOTO, false)
        HeadPhotoTaker:close()
        self.takingPhoto = false
    end
    
end

function AvatarSelectGroup:takePhoto()


    local function PopPanel( ... )

        -- local avatarSelectGroupObj = nil
        self.manager:setData(self.manager.IS_TAKE_PHOTO, false)
        self.takingPhoto = false
        -- if self.originalPlace == 0 then
        --     self.manager:showPersonalCenterPanel()
        -- elseif self.parent and self.parent.parentPanel and self.parent.parentPanel.onTapEditBtn then
        --     self.parent.parentPanel.onTapEditBtn()
        -- end
    end

    local cb = {
        onSuccess = function ( path )
            if path ~= nil then
                self:takeImageSuccess(path)
            end

            PopPanel()
        end,
        onError = function ( code, errMsg )
            if _G.isLocalDevelopMode then printx(0, "takePhoto error ", code, errMsg) end

            PopPanel()
           
            CommonTip:showTip(localize("my.card.edit.panel.warning.camera"), nil, nil, 3)
        end,
        onCancel = function ()
            if _G.isLocalDevelopMode then printx(0, "takePhoto cancel") end

            PopPanel()
            
        end,
    }

    local isTakePhoto = self.manager:getData(self.manager.IS_TAKE_PHOTO)
    if not isTakePhoto then
        if self.parent then
            self.needUpdateHead = true

            -- self.parent:onCloseBtnTapped()

        end
        self.manager:setData(self.manager.IS_TAKE_PHOTO, true)
        HeadPhotoTaker:takePicture(cb)

        self.takingPhoto = true

    end
end

return AvatarSelectGroup