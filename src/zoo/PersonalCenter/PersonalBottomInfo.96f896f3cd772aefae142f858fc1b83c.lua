local FriendInfoUtil = require 'zoo.PersonalCenter.FriendInfoUtil'

local BottomInfo = class()

local ITEM_COUNT = 5

function BottomInfo:create(ui)
    local panel = BottomInfo.new()
    panel:init(ui)
    return panel
end

function BottomInfo:init(ui)
    self.ui = ui

    local function onAchiList()
        local Panel = require 'zoo.PersonalCenter.PersonalAchievementList'
        Panel:create(self.achievementData)

        local params = {}
        params.category = "ui"
        params.subcategory = "G_my_card_panel_click"
        params.other = "t2"
        DcUtil:UserTrack(params)
    end

    local btnAchiList = ui:getChildByName("btnAchiList")
    btnAchiList:setTouchEnabled(true,0, false)
    btnAchiList:setButtonMode(true)
    btnAchiList:addEventListener(DisplayEvents.kTouchTap, onAchiList)
    btnAchiList:setVisible(false)
    self.btnAchiList = btnAchiList

    self.txtAchiList = ui:getChildByName("txtAchiList")
    self.txtAchiList:setVisible(false)

    self.items = {}
    for i=1,ITEM_COUNT do
        self.items[i] = ui:getChildByName("bottom_" .. i)
        self.items[i]:setVisible(false)
    end

    -- self:onPersonalInfoChange()
end

function BottomInfo:onPersonalInfoChange( friendData )
    if self.isDisposed then return end

    local maxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()

    local totalStar = LevelMapManager.getInstance():getTotalStar(maxLevel)
    local totalHiddenStar = MetaModel.sharedInstance():getFullStarInHiddenRegion(true)
    
    local areaInfo,numFullStar = UserManager:getInstance():getAreaStarInfo()
    -- local topLevel = UserManager:getInstance():getUserRef():getRealTopLevelId()
    local topLevel = UserManager:getInstance():getUserRef():getTopLevelId()
    local curStar = UserManager:getInstance().user:getStar()
    local curHiddenStar = UserManager:getInstance().user:getHideStar()


    if friendData then
        numFullStar = friendData.fullStarArea
        topLevel = friendData.topLevel
        curStar = friendData.mainStar
        curHiddenStar = friendData.hideStar

        -- self.achievementData = friendData.achievementList
        self.achievementData = {}
        for i,v in ipairs(friendData.achievementList) do
            if v.level > 0 then
                table.insert(self.achievementData,v)
            end
        end
    else
        self.achievementData = Achievement:getAchis()
    end

    local isAchiEnabled = topLevel >= 60

    if not isAchiEnabled then
        self.achievementData = {}
    end
    local achiCount = #table.keys(self.achievementData or {})

    local showAchi = isAchiEnabled and achiCount>0 
    self.btnAchiList:setVisible(showAchi)
    self.txtAchiList:setVisible(showAchi)

    for i,v in ipairs(self.items) do
        v:setVisible(true)
    end

    --星星 关卡 etc
    
    -------最高关
    local nodeKey = 1

    local sp = self:createNodePic(nodeKey,'personinfopic/flower')


    self:setProgress(nodeKey, topLevel / maxLevel )

    if topLevel >= maxLevel then
        self:setNodeLabel(nodeKey,localize('my.card.content3') .. localize('my.card.content7'))
    else
        self:setNodeLabel(nodeKey,localize('my.card.content3') .. string.format("(%s/%s)", topLevel, maxLevel))
    end

    --------主线关星星数
    local nodeKey = 2
    self:setProgress(nodeKey, curStar / totalStar)
    local sp = self:createNodePic(nodeKey,'personinfopic/main_star')

    if curStar >= totalStar then
        self:setNodeLabel(nodeKey,localize('my.card.content4') .. localize('my.card.content8'))
    else
        self:setNodeLabel(nodeKey,localize('my.card.content4') .. string.format("(%s/%s)", curStar, totalStar))
    end 

    --------隐藏关星星数
    local nodeKey = 3
    self:setProgress(nodeKey, curHiddenStar / totalHiddenStar)
    local sp = self:createNodePic(nodeKey,'personinfopic/hide_star')
    if curHiddenStar >= totalHiddenStar then
        self:setNodeLabel(nodeKey,localize('my.card.content5') .. localize('my.card.content8'))
    else
        self:setNodeLabel(nodeKey,localize('my.card.content5') .. string.format("(%s/%s)", curHiddenStar, totalHiddenStar))
    end

    --- 全满星区域
    local nodeKey = 4
    local numAllArea = #areaInfo
    self:setProgress(nodeKey, numFullStar / numAllArea)
    local sp = self:createNodePic(nodeKey,'personinfopic/clouds')
    self:setNodeLabel(nodeKey,localize('全满星区域（主线及精英）') .. string.format("(%s/%s)", numFullStar , numAllArea))
    --self:setNodeLabel(nodeKey,localize('全满星区域（主线及隐藏）') .. string.format("(%s/%s)", numFullStar , numAllArea))

    --勋章 成就
    local nodeKey = 5
    local isNetworkTrigger = true

    if not friendData then
        isNetworkTrigger = Achievement:isNetworkTrigger()
    end

    local state = FriendInfoUtil:getAchiState(self.achievementData)
    local score = state.score
    local full_score = state.nextLevelScore
    score = math.clamp(score, 0, full_score)

    local level =  state.level or state.maxLevel
    level = math.clamp(level, 0, state.maxLevel)

    if not isAchiEnabled or not isNetworkTrigger then
        score = 0
        level = 1
    end

    self:setProgress(nodeKey, score / full_score)

    -------------

    local networktip = localize('my.card.content11')
    local notenabled = localize('my.card.content10')
    local normal = localize('achievement.medal.title' .. level)..string.format("：(%d/%d)", state.score, full_score)
    local text = normal

    if not isAchiEnabled then
        text = notenabled
    elseif not isNetworkTrigger then
        text = networktip
    end

    self:setNodeLabel(nodeKey, text)

    ---------
    local medalType = level
    local pic = 'personinfopic/0' --..(medalType - 1)
    if level > 1 then
        pic = 'achievement/achi_grade_'..medalType..'_mc'
    end
    local sp = self:createNodePic(nodeKey,pic)
    sp:setScale(0.8)
    
    if not self.notSelf then
        local touchLayer = Layer:create()
        touchLayer:setContentSize(CCSize(100, 100))
        sp:setPositionY(-30)
        sp:addChild(touchLayer)
        touchLayer:setTouchEnabled(true, nil, nil, function (pos)
            if self.isDisposed then return end
            return sp:hitTestPoint(pos, true)
        end)
        touchLayer:ad(DisplayEvents.kTouchTap, function (    )
            if isAchiEnabled and isNetworkTrigger then
                AchiUIManager:openMainPanel()
                DcUtil:UserTrack({category='my_card', sub_category="my_card_click_achievement"}, true)
            end
        end)
    end
end

function BottomInfo:createNodePic( nodeKey, itemName )
    local sp = Sprite:createWithSpriteFrameName(itemName .. '0000')
    UIUtils:positionNode(self.ui:getChildByPath('bottom_' .. nodeKey .. '/pic'), sp, true)
    return sp
end

function BottomInfo:setNodeLabel( nodeKey, text )
    self.ui:getChildByPath('bottom_' .. nodeKey .. '/label'):setString(text)
end

function BottomInfo:setProgress( nodeKey, percent )
    local progressUI = self.ui:getChildByPath('bottom_'..nodeKey)
    -- body
    if not progressUI then return end
    if progressUI.isDisposed then return end

    local fore = progressUI:getChildByPath('fore')

    if not progressUI.inited then
        progressUI.inited = true
        local pos = ccp(fore:getPositionX(), fore:getPositionY())

        fore:removeFromParentAndCleanup(false)
        progressUI.progress = CCProgressTimer:create(fore.refCocosObj)
        progressUI.progress:setType(kCCProgressTimerTypeBar)
        progressUI.progress:setMidpoint(ccp(0, 0))
        progressUI.progress:setBarChangeRate(ccp(1, 0))
        local luaProgress = CocosObject.new(progressUI.progress)
        progressUI:addChild(luaProgress)
        luaProgress:setPosition(pos)
        luaProgress:setAnchorPoint(ccp(0, 1))
        fore:dispose()
    end
    percent = math.clamp(percent, 0, 1)
    progressUI.progress:setPercentage(percent * 100)
end

function BottomInfo:refreshAchi( )
    if self.isDisposed then return end

	-- body
    -- self:loadRequiredResource("ui/personal_center_panel.json")

end


return BottomInfo
