local AchiProgressPanel = class(BasePanel)

-- local print = function ( str )
-- 	oldPrint("[AchiProgressPanel] "..str)
-- end

function AchiProgressPanel:create(config, achiInfo)
    local panel = AchiProgressPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.personal_center_panel)
    if panel:init(config, achiInfo) then
        return panel
    end
end

function AchiProgressPanel:init(config, achiInfo)
	self.manager = PersonalCenterManager
    self.achiManager = AchievementManager

    self.config = config
    self.achiInfo = achiInfo

    local shareid = self.achiManager.shareId

    --[[
        --num 关卡花个数
        --flowerData = {
            --level
            --star
            --type
        --}
        --title 
        --desc
    --]]
    self.data = {}
    
    local isNeedShow = false
    if config.id == shareid.PASS_N_HIDEN_LEVEL then
        isNeedShow = self:initPassHideAreaAchi()
    elseif config.id == shareid.FIVE_TIMES_FOUR_STAR then
        isNeedShow = self:initFiveTime4StarAchi()
    elseif config.id == shareid.N_STAR_REWARD then
        isNeedShow = self:initNStarRewardAchi()
    end

    if not isNeedShow then return false end

    local data = self.data

    local maxItemNum = 0

    if data.num <= 4 then
        maxItemNum = 4 
    elseif data.num <= 8 then
        maxItemNum = 8
    elseif data.num <= 12 then
        maxItemNum = 12
    else
        maxItemNum = 12
    end

    self.ui = self:buildInterfaceGroup("personal_center_achi_hide_panel"..maxItemNum)
    BasePanel.init(self, self.ui)

    if data.num >= 9 then
        self.ui:getChildByName("posList"):setVisible(false)
    end

    local function gotoLevel( level )
        local pp = self.parentPanel.parentPanel
        self:onCloseBtnTapped()

        if self.parentPanel then
            self.parentPanel:onCloseBtnTapped()
        end
        if pp then
            pp:onCloseBtnTapped()
        end
        --兼容其他scene启动关卡
        local function timeout()
            local startGamePanel = StartGamePanel:create(level, LevelType:getLevelTypeByLevelId( level ))
            startGamePanel:popout(false)
        end
        
        setTimeOut(timeout, 0.01)
    end

    if data.num <= 12 then
        local lastIndex = 1
        for index,c_data in ipairs(data.flowerData) do
            local item = self.ui:getChildByName("item"..index)
            if item == nil then break end
            item:setVisible(false)
            local size = item:getGroupBounds().size
            local pos = item:getPosition()
            local node = FlowerNodeUtil:createWithSize(c_data.type, c_data.level, c_data.star, size)
            node:setPosition(ccp(pos.x, pos.y))
            self:addChild(node)

            node:setTouchEnabled(true)
            node:ad(DisplayEvents.kTouchTap, function() 
                if c_data.unlock == false then
                    CommonTip:showTip(localize("achievement.panel.tip3"))
                else
                    gotoLevel(c_data.level)
                end
            end)

            lastIndex = index
        end

        for index = lastIndex + 1,maxItemNum do
            local item = self.ui:getChildByName("item"..index)
            item:setVisible(false)
        end
    else
        for index=1,12 do
            self.ui:getChildByName("item"..index):setVisible(false)
        end

        local posList = self.ui:getChildByName("posList")
        local size = posList:getGroupBounds().size
        local pos = posList:getPosition()

        self.scrollable = VerticalScrollable:create(size.width, size.height, true, false)
        local layout = VerticalTileLayout:create(size.width)
        self.scrollable:setPosition(ccp(pos.x, pos.y))
        self:addChild(self.scrollable)

        local listData = {}
        local listItemData = {}

        local count = 1
        local lastIndex = 1
        for index,c_data in ipairs(data.flowerData) do
            if index / 4 <= count then
                table.insert(listItemData, c_data)
            end

            if index % 4 == 0 then
                lastIndex = index
                table.insert(listData, listItemData)
                listItemData = {}
                count = count + 1
            end
        end

        listItemData = {}
        for index = lastIndex + 1, #data.flowerData do
            table.insert(listItemData, data.flowerData[index])
        end

        if #listItemData > 0 then
            table.insert(listData, listItemData)
        end

        for _,datas in ipairs(listData) do
            local item_ui = self:buildInterfaceGroup("personal_center_achi_hide_item")

            local lastIndex = 1
            for index,c_data in ipairs(datas) do
                local _item = item_ui:getChildByName("item"..index)
                _item:setVisible(false)
                local size = _item:getGroupBounds().size
                local pos = _item:getPosition()
                local node = FlowerNodeUtil:createWithSize(c_data.type, c_data.level, c_data.star, size)
                node:setPosition(ccp(pos.x, pos.y))
                item_ui:addChild(node)

                node:setTouchEnabled(true)
                node:ad(DisplayEvents.kTouchTap, function() 
                    if c_data.unlock == false then
                        CommonTip:showTip(localize("achievement.panel.tip3"))
                    else
                        gotoLevel(c_data.level)
                    end
                end)

                lastIndex = index
            end

            for i = lastIndex, 4 do
                local _item = item_ui:getChildByName("item"..i)
                _item:setVisible(false)
            end

            local item = ItemInClippingNode:create()
            item:setParentView(self.scrollable)
            item:setContent(item_ui)

            layout:addItem(item)
        end

        self.scrollable:setContent(layout)
    end


    self.closeBtn = GroupButtonBase:create(self.ui:getChildByName('closeBtn'))
    self.closeBtn:setString(localize("prop.info.panel.close.txt"))
    self.closeBtn:ad(DisplayEvents.kTouchTap, function() 
        self:onCloseBtnTapped()
    end)

    local s_size = self.ui:getGroupBounds().size
    local title = self.ui:getChildByName("title")
    title:setAnchorPoint(ccp(0.5, 0.5))
    title:setPosition(ccp(s_size.width / 2, -50))
    title:setText(data.title)

    local tip = self.ui:getChildByName("tip")
    tip:setString(data.desc)
    tip:setPositionY(tip:getPositionY() + (self.tipOffsetY or 0))


    return true
end

function AchiProgressPanel:initPassHideAreaAchi()
    local achi = self.achiManager:getAchievementWithId(self.achiManager.shareId.PASS_N_HIDEN_LEVEL)
    if achi.isMaxLevel == true then
        CommonTip:showTip(localize("achievement.panel.tip7"))
        return false
    end

    local hide_areas = MetaManager.getInstance().hide_area
    local topLevelId = UserManager:getInstance().user:getTopLevelId()
    local HIDE_LEVEL_ID_START = 10000
    local topLevelScore = UserManager.getInstance():getUserScore(topLevelId)
    if topLevelScore then
        topLevelId = topLevelId + 1
    end

    local version_highest_level =  MetaManager.getInstance():getMaxNormalLevelByLevelArea()

    local flowerData = {}
    local isPassAll = true
    local isFinishAll = false
    local isCanPass = false

    for k,hideArea in pairs(hide_areas) do
        local continueLevels = hideArea.continueLevels
        if continueLevels[#continueLevels] < topLevelId then
            local hideLevels = hideArea.hideLevelRange
            local isUnlock = true
            for i,v in ipairs(hideLevels) do
                local _level = HIDE_LEVEL_ID_START + v
                if i == 1 then
                    isUnlock = MetaModel:sharedInstance():isHiddenBranchCanOpen(k)
                end

                local score = UserManager.getInstance():getUserScore(_level)
                if score == nil or (score and score.star < 1) then
                    local data = {}
                    data.level = _level
                    data.star = score and score.star or 0
                    data.type = kFlowerType.kHidden
                    isPassAll = false
                    data.unlock = isUnlock
                    
                    if score == nil or (score and score.star <= 0) then
                        isUnlock = false
                    end

                    if isUnlock then
                        table.insert(flowerData, data)
                    end
                end
            end
        elseif continueLevels[#continueLevels] <= version_highest_level then
            --还可闯关解锁隐藏区
            if isPassAll then
                isCanPass = true
            end
        elseif continueLevels[#continueLevels] > version_highest_level then
            --不可闯关解锁隐藏区，未开启区域,达到满级
            if isPassAll then
                isFinishAll = true
            end
        end
    end

    if #flowerData > 0 then
        self.data.num = #flowerData
        self.data.title = localize("achievement.panel.title1")
        self.data.flowerData = flowerData
        self.data.desc = localize("achievement.panel.alert1")
        self.tipOffsetY = -25
        return true
    end

    --显示未满3星的关卡
    for levelId = 1, topLevelId do
        local score = UserManager.getInstance():getUserScore(levelId)
        local isJumpLevel = JumpLevelManager:getInstance():hasJumpedLevel( levelId )
        local isHelpedLevel = UserManager.getInstance():hasAskForHelpInfo(levelId)
        if isJumpLevel then
            local data = {}
            data.level = levelId
            data.star = 0
            data.type = kFlowerType.kJumped
            table.insert(flowerData, data)
        elseif isHelpedLevel then
            local data = {}
            data.level = levelId
            data.star = 0
            data.type = kFlowerType.kAskForHelp
            table.insert(flowerData, data)
        elseif score and score.star > 0 and score.star < 3  then
            local data = {}
            data.level = score.levelId
            data.star = score.star
            data.type = kFlowerType.kNormal
            table.insert(flowerData, data)
        end
    end

    if #flowerData > 0 then
        self.data.num = #flowerData
        self.data.title = localize("hide.area.panel.title")
        self.data.flowerData = flowerData
        self.data.desc = localize("achievement.panel.alert2")
        self.tipOffsetY = -38
        return true
    end
    --还可闯关解锁隐藏区
    if isCanPass then
        CommonTip:showTip(localize("achievement.panel.tip6"))
        return false
    end 

    --达到满级成就
    CommonTip:showTip(localize("achievement.panel.tip7"))

    return false
end

function AchiProgressPanel:initFiveTime4StarAchi()
    local achi = self.achiManager:getAchievementWithId(self.achiManager.shareId.FIVE_TIMES_FOUR_STAR)
    if achi.isMaxLevel == true then
        CommonTip:showTip(localize("achievement.panel.tip7"))
        return false
    end

    local list = FourStarManager:getInstance():getAllFourStarLevels()
    local flowerData = {}
    for _,data in ipairs(list) do
        local score = UserManager.getInstance():getUserScore(data.level)
        if score and score.star < 4 then
            local d = {}
            d.level = score.levelId
            d.star = score.star
            d.unlock = true
            d.type = kFlowerType.kNormal
            if JumpLevelManager:getInstance():hasJumpedLevel( d.level ) then
                d.type = kFlowerType.kJumped
            elseif UserManager.getInstance():hasAskForHelpInfo(d.level ) then
                d.type = kFlowerType.kAskForHelp
            end
            table.insert(flowerData, d)
        elseif score == nil then
            local d = {}
            d.level = data.level
            d.star = 0
            d.type = kFlowerType.kNormal
            d.unlock = false
            local topLevel = UserManager.getInstance().user:getTopLevelId()
            if topLevel == d.level then
                d.unlock = true
            end

            table.insert(flowerData, d)
        end
    end

    if #flowerData > 0 then
        self.data.num = #flowerData
        self.data.title = localize("achievement.panel.title2")
        self.data.flowerData = flowerData
        self.data.desc = localize("achievement.panel.alert3")
        self.tipOffsetY = -35
        return true
    end

    CommonTip:showTip(localize("achievement.panel.tip7"))
    return false
end

function AchiProgressPanel:initNStarRewardAchi()
    local achi = self.achiManager:getAchievementWithId(self.achiManager.shareId.N_STAR_REWARD)
    if achi.isMaxLevel == true then
        CommonTip:showTip(localize("achievement.panel.tip7"))
        return false
    end

    local flowerData = {}

    local topLevelId = UserManager:getInstance().user:getTopLevelId()
    for levelId = 1, topLevelId do
        local score = UserManager.getInstance():getUserScore(levelId)
        local isJumpLevel = JumpLevelManager:getInstance():hasJumpedLevel( levelId )
        local isHelpedLevel = UserManager.getInstance():hasAskForHelpInfo(levelId)
        if isJumpLevel then
            local data = {}
            data.level = levelId
            data.star = 0
            data.type = kFlowerType.kJumped
            table.insert(flowerData, data)
        elseif isHelpedLevel then
            local data = {}
            data.level = levelId
            data.star = 0
            data.type = kFlowerType.kAskForHelp
            table.insert(flowerData, data)
        elseif score and score.star > 0 and score.star < 3  then
            local data = {}
            data.level = score.levelId
            data.star = score.star
            data.type = kFlowerType.kNormal
            table.insert(flowerData, data)
        end
    end

    local scores = UserManager.getInstance():getScoreRef() 
    for _,score in ipairs(scores) do
        if score and score.star > 0 and score.star < 3 and LevelType:isHideLevel( score.levelId ) then
            local data = {}
            data.level = score.levelId
            data.star = score.star
            data.type = kFlowerType.kHidden
            table.insert(flowerData, data)    
        end
    end

    if #flowerData > 4 then
        self.data.num = #flowerData
        self.data.title = localize("recall_text_10")
        self.data.flowerData = flowerData
        self.data.desc = localize("achievement.panel.alert4")
        self.tipOffsetY = -25
        return true
    elseif #flowerData < 5 and #flowerData >= 0 then
        CommonTip:showTip(localize("achievement.panel.tip4"))
        return false
    end

    CommonTip:showTip(localize("achievement.panel.tip7"))
    return false
end

function AchiProgressPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)

    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
    self:setPosition(ccp(centerPosX, centerPosY))

    self.allowBackKeyTap = true
end

function AchiProgressPanel:onCloseBtnTapped(  )
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

return AchiProgressPanel