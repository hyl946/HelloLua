-- 成就排行
local listWidth = 645
local listHeight 

local AchiRankRender = class(ItemInClippingNode)
function AchiRankRender:create(renderType, builder)
    local render = AchiRankRender.new()
    render:init(renderType, builder)
    return render
end

function AchiRankRender:init(renderType, builder)
    self.renderType = renderType
    ItemInClippingNode.init(self)
    local ui = builder:buildGroup('achievement/achi_rank_render'..renderType)
    self:setContent(ui)

    self.ui = ui
    self.bg1 = ui:getChildByName('bg1')
    self.bg = ui:getChildByName('bg')
    self.name = ui:getChildByName('name')
    self.info = ui:getChildByName('info')
    self.userIcon = ui:getChildByName('userIcon')
    self.head = ui:getChildByName('head')
    self.head:setOpacity(0)
    self.crown = ui:getChildByName('crown')
    self.crownNum = self.crown:getChildByName('num')

    ui:setTouchEnabled(true, 0, false)
    ui:ad(DisplayEvents.kTouchBegin, function(event)
        self.lastTouchPos = event.globalPosition
    end)

    ui:ad(DisplayEvents.kTouchEnd, function(event,x,y)
        if self.lastTouchPos then
            local distance = ccpDistance(self.lastTouchPos, event.globalPosition)
            if distance<10 then
                local pos = self.owner.ui:convertToNodeSpace(event.globalPosition)
                if pos.y<self.owner.tabbarY-60 then
                    require("zoo.PersonalCenter.FriendInfoPanel"):create(self.uid,{isFromAchiRank = true})
                    local dcKey = self.uid==UserManager:getInstance().uid and 0 or FriendManager.getInstance():getFriendInfo(self.uid) and 1 or 2
                    DcUtil:UserTrack({category='ui', sub_category="G_my_card_click ",t1="5",t2=dcKey}, true)
                end
            end
        end
    end)
end

function AchiRankRender:setData(data)
    self.uid = data.profile and data.profile.uid
    
    self.name:setString('消消乐玩家')
    self.info:setString(data.rank.score)
    if self.crownNum then 
        local rankNum = BitmapText:create(data.rank.rank, 'fnt/hud.fnt', -1, kCCTextAlignmentCenter)
        rankNum:setScale(1.1)
        rankNum:setPosition(ccp(32, -35)) 
        self.crown:addChild(rankNum)
    end

    -- if data.profile and data.profile.headUrl then

        local profile = data.profile or {}

        self.name:setString(TextUtil:ensureTextWidth(nameDecode(profile.name or '消消乐玩家'), self.name:getFontSize(), self.name:getDimensions()))
        local function onImageLoadFinishCallback(clipping)
            if self.isDisposed then return end
            local clippingSize = clipping:getContentSize()
            if self.renderType == 4 then 
                clipping:setScale(106 / clippingSize.width)
                clipping:setPosition(ccp(62, 65))
            elseif self.renderType == 5 then 
                clipping:setScale(94 / clippingSize.width)
                clipping:setPosition(ccp(59, 62))
            elseif self.renderType == 6 then
                clipping:setScale(96 / clippingSize.width)
                clipping:setPosition(ccp(57, 62))
            else
                clipping:setScale(74 / clippingSize.width)
                clipping:setPosition(ccp(44.5, 46))
            end
            self.head:addChild(clipping)
            self.userIcon:setVisible(false)
        end
        local head = HeadImageLoader:createWithFrame(profile.uid, profile.headUrl)
        onImageLoadFinishCallback(head)

        if profile.uid == UserManager:getInstance():getUID() and self.renderType == 7 then
            self.bg:setVisible(false)
        else
            if self.bg1 then self.bg1:setVisible(false) end
        end
    -- end

    local grade = Achievement:getLevelByScore(data.rank.score)
    if grade > 1 then
        local bgSize = self.bg:getContentSize()
        local gradeIcon = Sprite:createWithSpriteFrameName('achievement/achi_grade_' .. grade .. '_mc0000')
        gradeIcon:setAnchorPoint(ccp(0.5, 0.5))
        
       
        if self.renderType < 4 then 
            gradeIcon:setScale(0.96)
            gradeIcon:setPosition(ccp(410 + 52, -bgSize.height/2 - 8))
        elseif self.renderType == 4 then
            gradeIcon:setScale(1)
            gradeIcon:setPosition(ccp(410 + 52, -bgSize.height/2 - 8))
        elseif self.renderType == 5 then
            gradeIcon:setScale(0.96)
            gradeIcon:setPosition(ccp(410 + 52, -bgSize.height/2 - 15))
        elseif self.renderType == 6 then
            gradeIcon:setScale(0.96)
            gradeIcon:setPosition(ccp(410 + 52, -bgSize.height/2 - 8))
        else
            gradeIcon:setScale(0.93)
            gradeIcon:setPosition(ccp(410 + 52, -bgSize.height/2))
        end
        self.ui:addChild(gradeIcon) 
    end
end

local AchiRankPanel = class(LayerGradient)
function AchiRankPanel:create(parentUI)
    local winSize = CCDirector:sharedDirector():getWinSize()
	local panel = AchiRankPanel.new()
    panel:initLayer()
    panel:changeWidthAndHeight(winSize.width, winSize.height)
    panel:setStartColor(ccc3(255, 216, 119))
    panel:setEndColor(ccc3(247, 187, 129))
    panel:setStartOpacity(255)
    panel:setEndOpacity(255)
    panel:setTouchEnabled(true, 0, true)
    panel:init(parentUI)
    return panel
end

function AchiRankPanel:dispose()
    self.synchronizer = nil
    LayerColor.dispose(self)
    if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
end

function AchiRankPanel:init(parentUI)
    self.parentUI = parentUI
    local winSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()
    local realSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local realOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
    local topHeight = 120
    local bottomHeight = 40
    self:setPosition(ccp(realOrigin.x, realOrigin.y))

	self.ui = parentUI.builder:buildGroup('achievement/achi_rank_panel')
    self:addChild(self.ui)

    self.top = self.ui:getChildByName('top')
    self.top:setPositionY(realSize.height)
    self.title = self.top:getChildByName('title')
    self.title:changeFntFile('fnt/caption.fnt')
    self.title:setText(localize('achievement.new.panel.title2'))
    local titleSize = self.title:getContentSize()
    local titleScale = 66 / titleSize.height
    self.title:setScale(titleScale)
    self.title:setPositionX((realSize.width - titleSize.width * titleScale) / 2)
    self.title:setPositionY(self.title:getPositionY() - _G.__EDGE_INSETS.top * 0.4)
    self.achi_btn = self.top:getChildByName('achi_btn')
    self.achi_btn:setPositionY(self.achi_btn:getPositionY() - _G.__EDGE_INSETS.top * 0.6)
    self.achi_btn:setTouchEnabled(true, 0, true)
    self.achi_btn:setButtonMode(true)
    self.achi_btn:addEventListener(DisplayEvents.kTouchTap, function() 
        DcUtil:UserTrack({ category='ui', sub_category='G_achievement_click_button', other='t3'})
        self:onCloseBtnTapped()
        self.parentUI:setVisible(true)
    end)
    self.close_btn = self.top:getChildByName('close_btn')
    self.close_btn:setPositionY(self.close_btn:getPositionY() - _G.__EDGE_INSETS.top * 0.6)
    self.close_btn:setTouchEnabled(true, 0, true)
    self.close_btn:setButtonMode(true)
    self.close_btn:addEventListener(DisplayEvents.kTouchTap, function() 
        self:onCloseBtnTapped() 
    end)

    local bg2 = self.ui:getChildByName("bg2")
    local size = bg2:getPreferredSize()
    bg2:setPreferredSize(CCSizeMake(size.width, winSize.height - bottomHeight - topHeight))
    bg2:setPositionY(bg2:getPositionY() + winSize.height + _G.__EDGE_INSETS.bottom)
    listHeight = winSize.height - bottomHeight - topHeight - 145
    local pagedViewY = bg2:getPositionY() - bg2:getGroupBounds().size.height + 75

    self.info = self.ui:getChildByName('rankInfo')
    self.info:setTouchEnabled(true, 0, true)
    self.info:setPositionY(pagedViewY - 35)
    self.info:addEventListener(DisplayEvents.kTouchTap, function() 
        local defaultCount = 3
        local maxCountryRank = 100
        local rank, posY
        if self.pagedView:getPageIndex() == 1 then
            if self.friendsRank then
                rank = self.friendsRank.rank
                if rank == 0 then return end
                if rank > defaultCount then
                    posY = 378 + (rank - defaultCount - 1) * 120 + (rank - 1) * 10
                    self.page1:gotoPositionY(posY)
                else
                    self.page1:gotoPositionY(0)
                end
            end
        else
            if self.countryRank then 
                rank = self.countryRank.rank
                if rank == 0 or rank > maxCountryRank then return end
                if rank > defaultCount and rank <= maxCountryRank then
                    posY = 495 + (rank - defaultCount - 1) * 120 + (rank - 1) * 10
                    self.page2:gotoPositionY(posY)
                else
                    self.page2:gotoPositionY(0)
                end
            end
        end
    end)

    self.pagedView = PagedView:create(listWidth, listHeight, 2, nil, true, false)
    self.pagedView:setIgnoreVerticalMove(false)
    self.pagedView:setPosition(ccp(35, pagedViewY))
    local function switchCallback() self:switchPage() end
    local function switchFinishCallback() self:switchPageFinish() end
    self.pagedView:setSwitchPageCallback(switchCallback)
    self.pagedView:setSwitchPageFinishCallback(switchFinishCallback)
    self:addChild(self.pagedView)

    self.synchronizer = Synchronizer.new(self)
    for i = 1, 2 do 
        self['page'..i] = VerticalScrollable:create(listWidth, listHeight, false)
        self['page'..i].name = "AchiRankPage"..i
        self['page'..i]:setIgnoreHorizontalMove(false)
        self['layout'..i] = self:buildLayout()
        -- self['layout'..i]:setItemVerticalMargin(10)
        self['page'..i]:setContent(self['layout'..i])
        self.pagedView:addPageAt(self['page'..i], i)
    end

    local colorConfig = {
        normal = ccc3(134, 64, 1),
        focus = ccc3(243, 124, 27)
    }
    local tabTxts = {}
    for i = 1, 2 do
        table.insert(tabTxts, localize('achievement.rank.tab'..i))
    end
    local AchiTabBar = require "zoo.PersonalCenter.achi.panel.AchiTabBar"
    local tabbar = self.ui:getChildByName('tabbar')
    self.tabbarY = tabbar:getPositionY() + winSize.height + _G.__EDGE_INSETS.bottom
    tabbar:setPositionY(self.tabbarY)
    self.tabbar = AchiTabBar:create(tabbar, tabTxts, colorConfig)
    self.tabbar:setView(self.pagedView)
    tabbar:removeFromParentAndCleanup(false)
    self:addChild(tabbar)

    self.tabbar:onTabClicked(1)
    self:getRankList(0)
end

function AchiRankPanel:buildLayout()
    local context = self
    local renderType, height = 7, 130

    local LayoutRender = class(DynamicLoadLayoutRender)
    local layout = nil
    function LayoutRender:getColumnNum()
        return 1
    end
    function LayoutRender:getItemSize()
        return {width = listWidth, height = 130}
    end
    function LayoutRender:getVisibleHeight()
        return listHeight
    end
    function LayoutRender:buildItemView(itemData)
        --printx(5, table.tostring(itemData.data))
        local data = itemData.data
        if data.rank then
            if data.type == 0 then 
                if data.rank.rank == 1 then 
                    renderType = 1
                    height = 138
                    layout:onItemHeightChange(itemData, height)
                elseif data.rank.rank == 2 then
                    renderType = 2
                    height = 130
                    layout:onItemHeightChange(itemData, height)
                elseif data.rank.rank == 3 then
                    renderType = 3
                    height = 140
                    layout:onItemHeightChange(itemData, height)
                else
                    renderType = 7
                    height = 130
                end    
            else
                if data.rank.rank == 1 then 
                    renderType = 4
                    height = 185
                    layout:onItemHeightChange(itemData, height)
                elseif data.rank.rank == 2 then
                    renderType = 5
                    height = 165
                    layout:onItemHeightChange(itemData, height)
                elseif data.rank.rank == 3 then
                    renderType = 6
                    height = 175
                    layout:onItemHeightChange(itemData, height)
                else
                    renderType = 7
                    height = 120
                end
            end
        end

        local item = AchiRankRender:create(renderType, context.parentUI.builder)
        item.owner = context
        item:setData(data)
        -- item:setHeight(height)


        -- add item to synchronizer
        context.synchronizer:register(item)
        return item
    end

    layout = DynamicLoadLayout:create(LayoutRender.new())
    layout:setPosition(ccp(0, 0))
    return layout
end

function AchiRankPanel:addNoFriend()
    if self.isDisposed then return end
    local noFriend = self.parentUI.builder:buildGroup('achievement/no_friend')
    noFriend:setPosition(ccp(96, -30))
    -- noFriend:setScale(1.3)
    local friend_btn = GroupButtonBase:create(noFriend:getChildByName("button"))
    friend_btn:setColorMode(kGroupButtonColorMode.green)
    friend_btn:setString("添加好友")
    friend_btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
        createAddFriendPanel("recommend")
    end, 1))
    local info = noFriend:getChildByName('info')
    if FriendManager:getInstance():getFriendCount() == FriendManager:getInstance():getMaxFriendCount() then 
        info:setString(localize('achievement.new.panel.content3'))
        friend_btn:setVisible(false)
    else
        info:setString(localize('achievement.new.panel.content5'))
    end
    -- local layoutItem = ItemInClippingNode:create()
    -- layoutItem:setContent(noFriend)
    self.layout1:addChild(noFriend)
end

function AchiRankPanel:getRankList(type, startIndex, endIndex)
    if type == 0 then
        if self.friendsRankLoading then return end
        self.friendsRankLoading = true
    else
        if self.countryRankLoading then return end
        self.countryRankLoading = true
    end
    local function onSuccess( evt )
        if self.isDisposed then return end
        self:cancelLoading()
        if type == 0 then
            self.friendsRankLoading = nil
            self.friendsRank = evt.data
            if not self.friendsRank then return end
            if #self.friendsRank.rankList == 0 then
                self:addNoFriend() 
            else
                local function sort(a, b)
                    if a.score == b.score then
                        local atime = tonumber(a.updateTime) or 0 
                        local btime = tonumber(b.updateTime) or 0
                        return atime < btime
                    else
                        return a.score > b.score
                    end
                end
               
                --过滤大于60级的用户
                local rankList = {}
                local selfData
                for _, v in pairs(self.friendsRank.rankList) do 
                    local profile = FriendManager:getInstance():getFriendInfo(v.uid)
                    if v.uid == UserManager:getInstance():getUID() then 
                        selfData = v
                        table.insert(rankList, v) 
                    elseif profile then
                        if profile.topLevelId >= 60 then table.insert(rankList, v) end
                    end
                end
                
                if #rankList <= 1 then 
                    self:addNoFriend()
                    return
                end

                self.friendsRank.rankList = rankList
                table.sort(self.friendsRank.rankList, sort)
                local list = {}
                for i = 1, #self.friendsRank.rankList do
                    local rank = self.friendsRank.rankList[i]
                    rank.rank = i
                    local profile = FriendManager:getInstance():getFriendInfo(rank.uid)
                    if rank.uid == UserManager:getInstance():getUID() then profile = UserManager.getInstance().profile end
                    local data = {rank = rank, profile = profile, type = 0}
                    table.insert(list, data)
                end

                self.friendsRank.rankList = list
                self.layout1:initWithDatas(list)
                self.page1:updateScrollableHeight()
                
                local rank = (selfData and selfData.rank or 0)
                self.friendsRank.rank = rank
                self:setRankInfo(rank)
            end 
        else
            self.countryRankLoading = nil
            self.countryRank = evt.data
            if not self.countryRank then return end
            local function findProfile(uid)
                for _, v in pairs(self.countryRank.profiles) do
                    if v.uid == uid then 
                        return v
                    end
                end
                return nil
            end

            local list = {}
            for i = 1, #self.countryRank.rankList do
                local rank = self.countryRank.rankList[i]
                local profile = findProfile(rank.uid)
               
                table.insert(list, {rank = rank, profile = profile, type = 1})
            end

            self.countryRank.rankList = list
            self.layout2:initWithDatas(list)
            self.page2:updateScrollableHeight()

            local rank = self.countryRank and self.countryRank.rank or 0
            self:setRankInfo(rank)
        end
    end

    local function onFail(err)
       self:cancelLoading()
    end

    local http = AchievementRank.new()
    http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
    http:syncLoad({type = type, startIndex = startIndex, endIndex = endIndex})

    self:cancelLoading()
    self.cdScheduleId = setTimeOut(function()
        self.cdAnimation = CountDownAnimation:createNetworkAnimation(
            Director:sharedDirector():getRunningScene(),
            function() 
                syncCanceled = true
                self.cdAnimation:removeFromParentAndCleanup(true)
            end,
            "正在为您加载排行榜数据，请稍候")
    end, 1)
end

function AchiRankPanel:cancelLoading( ... )
    cancelTimeOut(self.cdScheduleId)
    if self.cdAnimation then self.cdAnimation:removeFromParentAndCleanup(true) end
end

function AchiRankPanel:switchPage()

end

function AchiRankPanel:switchPageFinish( ... )
     if self.pagedView:getPageIndex() == 2 then 
        if not self.countryRank then 
            self:getRankList(1, 1, 100)
        end
        local rank = self.countryRank and self.countryRank.rank or 0
        self:setRankInfo(rank)
    else
        local rank = self.friendsRank and self.friendsRank.rank or 0
        self:setRankInfo(rank)
    end

    self.tabbar:onTabClicked(self.pagedView:getPageIndex())
end

function AchiRankPanel:setRankInfo(rank)
    local strRank
    if not rank or rank == 0 then
        strRank = localize('achievement.my.rank3')
    else
        strRank = localize('achievement.my.rank2', {num = rank})
    end
    self.info:getChildByName('info'):setString(localize('achievement.my.rank1')..strRank) 
end

function AchiRankPanel:popout()
	local curScene = Director:sharedDirector():getRunningSceneLua()
    curScene:addChild(self)
end

function AchiRankPanel:onCloseBtnTapped()
    if not self.parentUI.isDisposed then
        self.parentUI:setVisible(true)
    end
    if self.isDisposed then return end
    self:cancelLoading()
	self:removeFromParentAndCleanup(true)
end

function AchiRankPanel:onKeyBackClicked()
    self:onCloseBtnTapped()
end
return AchiRankPanel