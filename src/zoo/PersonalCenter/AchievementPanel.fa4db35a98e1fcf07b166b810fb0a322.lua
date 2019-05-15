local AchievementPanel = class(BasePanel)

-- local print = function ( str )
-- 	oldPrint("[AchievementPanel] "..str)
-- end

local tipInstance = nil

local function disposeTip()
    if tipInstance then 
        tipInstance:hide()
        tipInstance:dispose()
        tipInstance = nil
    end
end

local function showTip(rect, content, propsId)
    disposeTip()
    tipInstance = BubbleTip:create(content, propsId)
    tipInstance:show(rect)
end

local AchiDescPanel = class(BasePanel)
function AchiDescPanel:create(manager)
    local panel = AchiDescPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.personal_center_panel)
    panel:init(manager)
    return panel
end

function AchiDescPanel:init(manager)
    self.manager = manager
    self.ui = self:buildInterfaceGroup("personal_center_achi_desc_panel")
    BasePanel.init(self, self.ui)

    self.closeBtn = GroupButtonBase:create(self.ui:getChildByName('closeBtn'))
    self.closeBtn:setString(localize("prop.info.panel.close.txt"))
    self.closeBtn:ad(DisplayEvents.kTouchTap, function() 
        self:onCloseBtnTapped()
    end)

    self.ui:getChildByName("title"):setText(localize("achievement.my.medal.panel.title"))
    self.ui:getChildByName("descTitle"):setString(localize("achievement.my.medal.panel.text1"))
    self.ui:getChildByName("desc1"):setString(localize("achievement.my.medal.panel.text2"))
    self.ui:getChildByName("desc2"):setString(localize("achievement.my.medal.panel.text3"))

    local posList = self.ui:getChildByName("posList")
    posList:setVisible(false)
    local size = posList:getGroupBounds().size
    local pos = posList:getPosition()

    self.scrollable = VerticalScrollable:create(size.width, size.height, true, false)
    local layout = VerticalTileLayout:create(size.width)
    self.scrollable:setPosition(ccp(pos.x, pos.y))
    self:addChild(self.scrollable)

    for index, config in ipairs(manager.medalConfig) do
        local item_ui = self:buildInterfaceGroup("personal_center_achi_desc_item")
        item_ui:getChildByName("name"):setString(localize("achievement.my.medal.title"..config.id))
        item_ui:getChildByName("desc"):setString(localize("achievement.my.medal.panel.content1", {num = config.score}))
        local level_pos = item_ui:getChildByName("level")
        level_pos:setVisible(false)

        local isCopper = index >= 1 and index <= 5
        local isSilver = index >= 6 and index <= 10
        local isGolden = index >= 11 and index <= 15

        local fntFile
        if isGolden then
            fntFile = 'fnt/race_rank.fnt'
        elseif isSilver then
            fntFile = 'fnt/race_rank_silver.fnt'
        elseif isCopper then
            fntFile = 'fnt/race_rank_copper.fnt'
        end

        local achiLevelLabel  = LabelBMMonospaceFont:create(30, 30, 15, fntFile)
        local textSize = level_pos:getGroupBounds().size
        local textPos = level_pos:getPosition()

        achiLevelLabel:setString(tostring(index))
        achiLevelLabel:setAnchorPoint(ccp(0.5, 0.5))
        if index < 10 then
            achiLevelLabel:setPositionXY(textSize.width / 2 + textPos.x - 1, textPos.y - textSize.height / 2)
        else
            achiLevelLabel:setPositionXY(textSize.width / 2 + textPos.x - 3, textPos.y - textSize.height / 2)
        end

        item_ui:addChild(achiLevelLabel)

        item_ui:getChildByName("golden"):setVisible(isGolden)
        item_ui:getChildByName("copper"):setVisible(isCopper)
        item_ui:getChildByName("silver"):setVisible(isSilver)

        local item = ItemInClippingNode:create()
        item:setContent(item_ui)
        layout:addItem(item)
    end

    self.scrollable:setContent(layout)
end

function AchiDescPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)

    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
    self:setPosition(ccp(centerPosX, centerPosY))
    self.allowBackKeyTap = true
end

function AchiDescPanel:onCloseBtnTapped(  )
    PopoutManager:sharedInstance():remove(self, true)
    self.allowBackKeyTap = false
end

function AchievementPanel:create(manager)
    local panel = AchievementPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.personal_center_panel)
    panel:init(manager)
    return panel
end

function AchievementPanel:init(manager)
	self.manager = manager
    self.ui = self:buildInterfaceGroup("personal_center_achievement_panel")
    BasePanel.init(self, self.ui)
    FrameLoader:loadImageWithPlist("flash/quick_select_level.plist")

    self.closeBtn = GroupButtonBase:create(self.ui:getChildByName('closeBtn'))
    self.closeBtn:setString(localize("prop.info.panel.close.txt"))
    self.closeBtn:ad(DisplayEvents.kTouchTap, function() 
        self:onCloseBtnTapped()
    end)

    self.achiManager = AchievementManager

    self:adapation()

    self:buildAllAchi()
    self:buildProgressAchi()

    self.ui:getChildByName("score"):setString(self.achiManager:getTotalScore().."分")

    self.question = self.ui:getChildByName("question")
    self.question:setTouchEnabled(true)
    self.question:ad(DisplayEvents.kTouchTap, function() 
        local achiDescPabel = AchiDescPanel:create(manager)
        achiDescPabel:popout()
        DcUtil:UserTrack({category='achievement', sub_category="my_achievement_click_detail"}, true)
    end)
end

function AchievementPanel:adapation()
    local allAchiList = self.ui:getChildByName("uplist")
    local allAchiListSize = allAchiList:getGroupBounds().size

    local progAchiList = self.ui:getChildByName("list")
    local progAchiListSize = progAchiList:getGroupBounds().size

    local btnSize = self.closeBtn:getGroupBounds().size
    local size = Director:sharedDirector():getVisibleSize()

    local titleImg = self.ui:getChildByName("titleImg")
    local titleImgSize = titleImg:getGroupBounds().size
    titleImg:setPositionY(titleImg:getPositionY() + _G.__EDGE_INSETS.top / 5)

    local bg0 = self.ui:getChildByName("bg")
    local bg0Size = bg0:getContentSize()
    local bgHeight = size.height + _G.__EDGE_INSETS.top + _G.__EDGE_INSETS.bottom
    bg0:setScaleY(math.max(bgHeight / bg0Size.height, 1))
    bg0:setPositionY(bg0:getPositionY() + _G.__EDGE_INSETS.top)

    local bg1 = self.ui:getChildByName("bg1")
    local bg1Size = bg1:getContentSize()

    local bg1Height = size.height - titleImgSize.height - btnSize.height
    bg1:setContentSize(CCSizeMake(bg1Size.width, bg1Height))

    local y1 = size.height - titleImgSize.height - bg1Height
    local y = y1 / 2 + titleImgSize.height + bg1Height
    self.closeBtn:setPositionY(-y + 6)

    self.allAchisHeight = allAchiListSize.height
    
    if size.width / size.height > 0.6 then
        self.allAchisHeight = allAchiListSize.height * 2 / 3 + 20
    end
    self.progAchiHeight = bg1Height - self.allAchisHeight - 120
    self.progAchiPosY = allAchiList:getPositionY() - self.allAchisHeight - 10

    local bg2 = self.ui:getChildByName("bg2")
    local bg2Size = bg2:getContentSize()
    bg2:setContentSize(CCSizeMake(bg2Size.width, self.allAchisHeight))
end

function AchievementPanel:buildProgressAchi()
    local posList = self.ui:getChildByName("list")
    posList:setVisible(false)
    local size = posList:getGroupBounds().size
    local pos = posList:getPosition()
    local scrollablePos = ccp(pos.x, self.progAchiPosY)

    self.scrollable = VerticalScrollable:create(size.width, self.progAchiHeight, true, false)
    local layout = VerticalTileLayout:create(size.width)
    self.scrollable:setPosition(scrollablePos)
    self:addChild(self.scrollable)

    local progressType = self.achiManager.achievementType.PROGRESS
    local progressConfigs = self.achiManager:getConfigWithType(progressType)
    local progressAchis = self.achiManager:getAchievementsWithType(progressType)

    for index,config in ipairs(progressConfigs) do
        local achi = progressAchis[config.id]
        local item = self:buildProgressAchiItem(config, achi)
        layout:addItem(item)
    end

    self.scrollable:setContent(layout)
end

function AchievementPanel:buildIconWithConfig( config, isNext, isUnReached )
    local icon
    if isUnReached then
        icon = SpriteColorAdjust:createWithSpriteFrameName("achi_icon/cell/"..config.id.."0000")
        icon:adjustColor(0, -0.64,-0.15,-0.38)
        icon:applyAdjustColorShader()
    else
        icon = self.builder:buildGroup("pc_achi_icon_"..config.id)
    end

    if config.achievementType == self.achiManager.achievementType.PROGRESS and not config.notShowLevel then
        local achi = self.achiManager:getAchievementWithId(config.id)
        local charWidth     = 30
        local charHeight    = 30
        local charInterval  = 15
        local fntFile       = "fnt/energy_cd.fnt"
        if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/energy_cd.fnt" end
        local achiLevel = achi.achiLevel
        if (isNext and not achi.isMaxLevel) or achiLevel == 0 then achiLevel = achiLevel + 1 end

        -- local levelText  = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
        local levelText = BitmapText:create(localize('fruit.tree.scene.level', {level = achiLevel}), fntFile, -1, hAlignment)
        levelText:setAnchorPoint(ccp(0.5,0.5))
        if isUnReached then
            levelText:setVisible(false)
        else
            levelText:setPosition(ccp(62, - 104))
        end

        if config.id == 220 then
            levelText:setPosition(ccp(60, - 104))
        elseif config.id == 230 then
            levelText:setPosition(ccp(53, - 110))
        end

        icon:addChild(levelText)

        if config.id == self.achiManager.shareId.UNLOCK_NEW_OBSTACLE then
            local firstNewObstacleLevels = MetaManager:getInstance().global.firstNewObstacleLevels
            local level = firstNewObstacleLevels[achiLevel]
            if achi.isMaxLevel then
                level = firstNewObstacleLevels[achi.achiLevel]
                levelText:setText(localize('fruit.tree.scene.level', {level = achi.achiLevel}))
            end

            local obstacleConfig = require "zoo.PersonalCenter.ObstacleIconConfig"
            local index = obstacleConfig[level]

            local name = "area_icon_"..index.."0000"
            if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name) then
                local obstacle
                if isUnReached then
                    obstacle = SpriteColorAdjust:createWithSpriteFrameName(name)
                    obstacle:adjustColor(0, -0.64,-0.15,-0.38)
                    obstacle:applyAdjustColorShader()
                    obstacle:setPosition(ccp(62, 93))
                else
                    obstacle = Sprite:createWithSpriteFrameName(name)
                    obstacle:setPosition(ccp(62, - 50))
                end
                obstacle:setScale(0.51)
                icon:addChild(obstacle)
            end
        end
    end

    return icon
end

function AchievementPanel:buildProgressAchiItem(config, achiInfo)
    local item_ui = self:buildInterfaceGroup("personal/personal_center_achi_item")
    local item = ItemInClippingNode:create()
    local keyName = item_ui:getChildByName("name")

    local icon = self:buildIconWithConfig(config, true)

    icon:setScale(0.85)
    if config.id == 230 then
        icon:setPosition(ccp(20, -8))
    elseif config.id == 240 then
        icon:setPosition(ccp(16, -8))
    elseif config.id == 220 then
        icon:setPosition(ccp(15, -8))
    else
        icon:setPosition(ccp(10, -8))
    end
    item_ui:addChild(icon)

    if config.unlockCondition and config.unlockCondition() == false then
        local lock = self.builder:buildGroup("pc_achi_icon_lock")
        lock:setPosition(ccp(90, -80))
        lock:setScale(0.9)
        item_ui:addChild(lock)
    end

    local fntFile = "fnt/caption.fnt"
    if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/caption.fnt" end
    local position = keyName:getPosition()
    local newName = LabelBMMonospaceFont:create(42, 42, 34, fntFile)
    newName:setAnchorPoint(ccp(0,1))
    newName:setString(localize(config.keyName))
    newName:setPosition(ccp(position.x, position.y))
    item_ui:addChild(newName)

    local proNum = item_ui:getChildByName("proNum")

    local numLabel = LabelBMMonospaceFont:create(20, 35, 15, "fnt/event_default_digits.fnt")
    numLabel:setAnchorPoint(ccp(1.0, 0.5))
    local size = item_ui:getGroupBounds().size
    numLabel:setPositionX(size.width - 10)
    numLabel:setPositionY(- size.height / 2 - 8)
    item_ui:addChild(numLabel)

    if config.id == self.achiManager.shareId.UNLOCK_NEW_OBSTACLE then
        local name = localize("achievement.blocker.name."..achiInfo.num)
        if achiInfo.isMaxLevel then
            numLabel:setString("1/1")
            item_ui:getChildByName("progress"):setScaleX(1)
            local firstNewObstacleLevels = MetaManager:getInstance().global.firstNewObstacleLevels
            local num = firstNewObstacleLevels[achiInfo.achiLevel]
            name = localize("achievement.blocker.name."..num)
            item_ui:getChildByName("desc"):setString(localize(config.keyDesc, {num = num, name = name}))
        else
            numLabel:setString("0/1")
            item_ui:getChildByName("progress"):setScaleX(0)
            item_ui:getChildByName("desc"):setString(localize(config.keyDesc, {num = achiInfo.num, name = name}))
        end
    else
        numLabel:setString(achiInfo.num.."/"..achiInfo.totalNum)
        item_ui:getChildByName("progress"):setScaleX(achiInfo.num/achiInfo.totalNum)
        local keyDesc = config.keyDesc1 or config.keyDesc
        item_ui:getChildByName("desc"):setString(localize(keyDesc, {num = achiInfo.totalNum}))
    end

    item_ui:setTouchEnabled(true)
    item_ui:ad(DisplayEvents.kTouchTap, function() 
        self:onTapProgressAchi(item, config, achiInfo)
        DcUtil:UserTrack({category='achievement', sub_category="my_achievement_click_"..achiInfo.id}, true)
    end)
    item:setParentView(self.scrollable)
    item:setContent(item_ui)

    return item
end

function AchievementPanel:onTapProgressAchi( item, config, achiInfo )
    local shareid = self.achiManager.shareId
    if config.id == shareid.UNLOCK_NEW_OBSTACLE then
        if achiInfo.isMaxLevel then
            CommonTip:showTip(localize("achievement.panel.tip7"))
        else
            CommonTip:showTip(localize("achievement.panel.tip2", {num = achiInfo.num}))
        end
    elseif config.id == shareid.GET_POPULARITY
           or config.id == shareid.AREA_FULL_STAR
           or config.id == shareid.NW_SILVER_CONSUMER
           or config.id == shareid.COLLECTED_N_FRUIT
           or config.id == shareid.FIVE_TIMES_FOUR_STAR
    then
        if achiInfo.isMaxLevel then
            CommonTip:showTip(localize("achievement.panel.tip7"))
        end 
    else
        local AchiProgressPanel = require "zoo.PersonalCenter.AchiProgressPanel"
        local panel = AchiProgressPanel:create(config, achiInfo)
        if panel then
            panel.parentPanel = self
            panel:popout()
        end
    end
    
end

function AchievementPanel:checkIgnoreAchi( id )
    if __WP8 then
        return id == self.achiManager.shareId.COLLECT_ALL_61_EGGS
    end
    return false
end

--全部成就
function AchievementPanel:buildAllAchi()
    local posList = self.ui:getChildByName("uplist")
    posList:setVisible(false)
    local size = posList:getGroupBounds().size
    local pos = posList:getPosition()

    self.scrollableAll = VerticalScrollable:create(size.width, self.allAchisHeight - 20, true, false)
    local layout = VerticalTileLayout:create(size.width)
    self.scrollableAll:setPosition(ccp(pos.x, pos.y))

    local triggerType = self.achiManager.achievementType.TRIGGER
    local triggerConfigs = self.achiManager:getConfigWithType(triggerType)

    local progressType = self.achiManager.achievementType.PROGRESS
    local progressConfigs = self.achiManager:getConfigWithType(progressType)

    local allAchis = table.append(triggerConfigs, progressConfigs)

    local achis = self.achiManager:getAchievements()

    local function less( p, n )
        return p.priority < n.priority
    end

    local function lessid( p, n )
        local p_c = self.achiManager:getConfig(p)
        local n_c = self.achiManager:getConfig(n)
        return p_c.priority < n_c.priority
    end
    local notSupportAchis = {}
    local sortAchis = {}
    for id,achi in pairs(achis) do
        if not self:checkIgnoreAchi(id) then
            local config = self.achiManager:getConfig(id)
            if achi.achiLevel > 0 and config and config.isNotSupport ~= true then
                table.insert(sortAchis, achi.id)
            end

            if achi.achiLevel > 0 and config and config.isNotSupport == true then
                table.insert(notSupportAchis, achi.id)
            end
        end
    end
    table.sort(sortAchis, lessid)
    table.sort(allAchis, less)

    local unreachAchis = {}
    for index,config in ipairs(allAchis) do
        if not self:checkIgnoreAchi(config.id) then
            unreachAchis[config.id] = config.id
        end
    end

    local lastIndex = 0
    local data
    for index,id in ipairs(sortAchis) do
        local config = self.achiManager:getConfig(id)
        if index % 3 == 1 then
            data = {}
        end

        table.insert(data, {config = config, isReached = true})

        if index % 3 == 0 then
            local item = self:buildAllAchiItem(data)
            layout:addItem(item)
            data = nil
        end

        unreachAchis[id] = nil

        lastIndex = index
    end

    local sortUnreachAchis = {}
    for _,id in pairs(unreachAchis) do
        table.insert(sortUnreachAchis, id)
    end

    table.sort(sortUnreachAchis, lessid)

    lastIndex = lastIndex + 1

    for _,id in ipairs(sortUnreachAchis) do
        local config = self.achiManager:getConfig(id)
        if data == nil then
            data = {}
        end

        table.insert(data, {config = config, isReached = false})

        if #data == 3 then
            local item = self:buildAllAchiItem(data)
            layout:addItem(item)
            data = {}
        end

        lastIndex = lastIndex + 1
    end

    for _,id in ipairs(notSupportAchis) do
        local config = self.achiManager:getConfig(id)
        if data == nil then
            data = {}
        end

        table.insert(data, {config = config, isReached = true})

        if #data == 3 then
            local item = self:buildAllAchiItem(data)
            layout:addItem(item)
            data = {}
        end
    end
  
    if data and #data > 0 then
        local item = self:buildAllAchiItem(data)
        layout:addItem(item)
    end

    self.scrollableAll:setContent(layout)
    self:addChild(self.scrollableAll)
end

function AchievementPanel:buildAllAchiItem(data)
    local item_ui = self:buildInterfaceGroup("personal_center_achi_all_item")
    local itemHeight = item_ui:getGroupBounds().size.height
    local item = ItemInClippingNode:create()

    local function buildItem( cdata, index )
        local config = cdata.config
        local achi = item_ui:getChildByName("item"..index)

        achi:setTouchEnabled(true, 0, true)
        achi:setButtonMode(true)

        if config then
            if cdata.isReached == true then
                local icon = self:buildIconWithConfig(config)
                icon:setScale(1.1)
                icon:setPosition(ccp(20, -8))
                achi:addChild(icon)
            else
                local sprite = self:buildIconWithConfig(config, nil, true)
                sprite:setScale(1.1)
                local size = achi:getGroupBounds().size

                local pos = ccp(size.width / 2, -size.height / 2)
                if config.id == 70 then
                    sprite:setPosition(ccp(pos.x, pos.y + 6))
                elseif config.id == 60 then
                    sprite:setPosition(ccp(pos.x + 8, pos.y + 2))
                elseif config.id == 90 then
                    sprite:setPosition(ccp(pos.x + 8, pos.y + 14))
                elseif config.id == 100 then
                    sprite:setPosition(ccp(pos.x, pos.y + 2))
                else
                    sprite:setPosition(ccp(pos.x, pos.y))
                end

                achi:addChild(sprite)
            end
        end

        if config and config.unlockCondition and config.unlockCondition() == false then
            local lock = self.builder:buildGroup("pc_achi_icon_lock")
            lock:setPosition(ccp(130, -115))
            achi:addChild(lock)
        end

        local function touchTap( event )
            local tip = self:buildInterfaceGroup("personal_center_achi_tip")
            if config then
                tip:getChildByName("title"):setString(localize(config.keyName))

                local achiScore = config.score

                local keyDesc
                if config.achievementType == self.achiManager.achievementType.PROGRESS then
                    local achiInfo = self.achiManager:getAchievementWithId(config.id)
                    if config.id == self.achiManager.shareId.UNLOCK_NEW_OBSTACLE then
                        local firstNewObstacleLevels = MetaManager:getInstance().global.firstNewObstacleLevels
                        local num = firstNewObstacleLevels[achiInfo.achiLevel]
                        if achiInfo.achiLevel <= 0 then num = firstNewObstacleLevels[achiInfo.achiLevel + 1] end

                        name = localize("achievement.blocker.name."..num)
                        keyDesc = localize(config.keyDesc, {num = num, name = name})

                        if num > 400 then
                            achiScore = 50
                        end
                    else
                        if achiInfo.achiLevel == 0 then
                            keyDesc = localize(config.keyDesc, {num = achiInfo.totalNum})
                        else
                            keyDesc = localize(config.keyDesc, {num = achiInfo.curNum})
                        end
                    end
                else
                    keyDesc = localize(config.keyDesc)
                end

                if achiScore ~= 0 then
                   keyDesc = keyDesc..localize("achievement_desc_default1",{num = achiScore})
                end

                tip:getChildByName("desc"):setString(keyDesc)

                local oldRect = tip:getGroupBounds()
                local size = oldRect.size
                local origin = oldRect.origin
                local rect = {size = {width = size.width, height = size.height}, origin = {x = origin.x, y = origin.y}}
                local textNum = string.len(keyDesc) / 3
            
                if textNum / 13 < 3 then
                    rect.size.height = textNum * 40 / 13 + 100
                end

                tip.getGroupBounds = function ()
                    return rect
                end
                showTip(achi:getGroupBounds(), tip)
                tipInstance.ui.hitTestPoint = function(context, worldPosition, useGroupTest)
                    local isUseGroupTest = false
                    if useGroupTest ~= nil then isUseGroupTest = useGroupTest end

                    if not context.refCocosObj then
                        return false
                    end

                    local panel = context:getChildByName("panel")
                    local nodePoint = context:getParent():convertToNodeSpace(worldPosition)
                    local a = context:getAnchorPoint()
                    local contentSize = panel:getContentSize()
                    local point = context:getPosition()

                    local panel_rect = CCRectMake(point.x - a.x * contentSize.width, point.y - a.y * contentSize.height, contentSize.width, contentSize.height)
                    if panel_rect:containsPoint(ccp(nodePoint.x, nodePoint.y)) then
                        return true
                    else
                        return false
                    end
                end
            elseif not cdata.isReached then
                CommonTip:showTip(localize("achievement.panel.tip5"))
            end
        end

        if config then
            achi:addEventListener(DisplayEvents.kTouchTap, touchTap)
        end
    end

    local lastIndex = 0
    for index,cdata in ipairs(data) do
        buildItem(cdata, index)
        lastIndex = index
    end

    for index = lastIndex + 1, 3 do
        buildItem({}, index)
    end

    item:setParentView(self.scrollableAll)
    item:setContent(item_ui)
    item:setHeight(itemHeight)

    return item

end

-- function AchievementPanel:dispose()
--     FrameLoader:unloadImageWithPlists(
--         {
--         "flash/quick_select_level.plist"
--         }, true)
-- end

function AchievementPanel:onEnterAnimationFinished()
   
end

function AchievementPanel:popout()
    PopoutManager:sharedInstance():add(self, true, false)
    self.allowBackKeyTap = true
end

function AchievementPanel:onCloseBtnTapped(  )
    self.scrollable:removeContent()
    self.scrollableAll:removeContent()
    
	PopoutManager:sharedInstance():remove(self, true)
    disposeTip()
	self.allowBackKeyTap = false
end

return AchievementPanel