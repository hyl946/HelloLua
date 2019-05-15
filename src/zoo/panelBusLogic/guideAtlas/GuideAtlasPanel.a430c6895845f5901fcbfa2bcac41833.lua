GuideAtlasPanel = class(BasePanel)

function GuideAtlasPanel:create(atlasLogic, levelId)
    local instance = GuideAtlasPanel.new()
    instance:loadRequiredResource('ui/guide_atlas.json')
    instance:init(atlasLogic, levelId)
    return instance
end

function GuideAtlasPanel:init(atlasLogic, levelId)

    self.levelId = levelId
    local ui = self.builder:buildGroup('guide_atlas_panel')
    BasePanel.init(self, ui)

    self.bg1 = self.ui:getChildByName('bg1')
    self.bg2 = self.ui:getChildByName('bg2')
    self.ph = self.ui:getChildByName('ph')
    self.ph:setVisible(false)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped()  end)


    local ITEM_MARGIN = 45

    local items = {}
    local itemHeight = 0

    local config = atlasLogic:getConfig()


    self:deletaCloudInMoleWeek( config )
    local configExtra = self:addMileWeekItem()

    for k, v in pairs(config) do
        local item = self:buildAtlasItem(v)
        table.insert(items, item)
        itemHeight = itemHeight + item:getHeight() + ITEM_MARGIN
    end

    if configExtra and #configExtra > 0 then
        for k, v in pairs(configExtra) do
            local item = self:buildAtlasItem(v)
            table.insert(items, item)
            itemHeight = itemHeight + item:getHeight() + ITEM_MARGIN
        end
    end

    

    itemHeight = itemHeight - ITEM_MARGIN

    local screenHeight = Director:sharedDirector():getVisibleSize().height
    local width = self.ph:getContentSize().width*self.ph:getScaleX()
    local bg1_height = screenHeight - 30
    local bg2_height = bg1_height - 100
    local scrollable_height = bg2_height - 60
    local bg1_width = self.bg1:getContentSize().width * self.bg1:getScaleX()
    local bg2_width = self.bg2:getContentSize().width * self.bg2:getScaleX()

    if #items <= 2 and itemHeight < scrollable_height then
        scrollable_height = itemHeight
        bg2_height = scrollable_height + 60
        bg1_height = bg2_height + 100
    end

    local scrollable = VerticalScrollable:create(width, scrollable_height)
    local layout = VerticalTileLayout:create(width)
    layout:setItemVerticalMargin(ITEM_MARGIN)

    for i=1, #items do
        layout:addItem(items[i])
    end

    scrollable:setContent(layout)
    self.ph:getParent():addChildAt(scrollable, self.ph:getZOrder())
    self.scrollable = scrollable
    self.scrollable:setPosition(ccp(self.ph:getPositionX(), self.ph:getPositionY()))

    self.bg1:setPreferredSize(CCSizeMake(bg1_width, bg1_height))
    self.bg2:setPreferredSize(CCSizeMake(bg2_width, bg2_height))
end

function GuideAtlasPanel:deletaCloudInMoleWeek( config )
    --删除云块介绍 在周赛关
    for i,v in pairs(config) do
        if v == AnimalGuideAtlasType.kDigGround or v == AnimalGuideAtlasType.kCloud then
            table.remove( config, i )
        end
    end
end

function GuideAtlasPanel:addMileWeekItem()
     --如果关卡是地鼠周赛 强制加入52-57

    local configExtra = {}
    if LevelType:isMoleWeeklyRaceLevel(self.levelId) then

        local currBossSkillList = {}
        local config = MoleWeeklyRaceConfig:getConfigData()
        if config and config.bossConfig then

            local groupID = MoleWeeklyRaceConfig:getCurrGroupID()
            currBossSkillList = MoleWeeklyRaceConfig:getCurrSkillTypeArr(groupID)
        end
 
        for i,v in pairs(currBossSkillList) do
            local configindex = 0
            if v == MoleWeeklyBossSkillType.THICK_HONEY then
                configindex = 54
            elseif v == MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL then
                configindex = 55
            elseif v == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then
                configindex = 56
            elseif v == MoleWeeklyBossSkillType.SEED then
                configindex = 57
            elseif v == MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK then
                configindex = 53
            end

            if configindex ~= 0 then
                configExtra[#configExtra+1] = configindex
            end
        end

        configExtra[#configExtra+1] = 52
        configExtra[#configExtra+1] = 58
        configExtra[#configExtra+1] = 59
    end

    return configExtra
end

function GuideAtlasPanel:buildAtlasItem(index)


    local panelName = ''
    if index == 59 then
        local SaijiIndex = RankRaceMgr.getInstance():getCurSaijiIndex()
        if SaijiIndex == 1 then
            panelName = 'guide_atlas_' .. index
        else
            panelName = 'guide_atlas_' .. index.."_s2"
        end
    else
        panelName = 'guide_atlas_' .. index
    end

--    local panelName = 'guide_atlas_' .. index
    local item
    item = self.builder:buildGroup(panelName)

    if not item then return nil end
    for i =1, 5 do 
        local textName = 'text_'..i
        local key = panelName..'.'..textName
        local text = item:getChildByName(textName)
        if text then
            if text.width and text.height then
                text:setPreferredSize(text.width, text.height)
            end
            text:setRichTextWithWidth(localize(key, {n = '\n', s = ' '}), 17, '9A5009', 0.7)
            if i == 1 then
                text:setAnchorPoint(ccp(0, 0.5))
                text:setPositionXY(114, -58)
            end
        end
    end
    local wrapper = ItemInClippingNode:create()
    wrapper:setContent(item)
    return wrapper
end

function GuideAtlasPanel:popout()
    PopoutManager:sharedInstance():add(self, true)
    self:setToScreenCenterVertical()
    self:setToScreenCenterHorizontal()
    self.allowBackKeyTap = true
end

function GuideAtlasPanel:removeSelf()

    PopoutManager:sharedInstance():remove(self)
    self.allowBackKeyTap = false
end

function GuideAtlasPanel:onCloseBtnTapped()
    DcUtil:UserTrack({category = 'newplayer', sub_category = 'book_exit'})
    self:removeSelf()
end
