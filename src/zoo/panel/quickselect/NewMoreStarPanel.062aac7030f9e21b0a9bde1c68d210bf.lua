require  'zoo.panel.component.common.GridLayout'
require "zoo.animation.FlowerNode"
-- short hand function
local function _text(key, replace)
    return Localization:getInstance():getText(key, replace)
end



NewMoreStarPanel = class(BasePanel)

NewMoreStarPanel.Mode = {
    kOnlyTopAreaLevels = 1,
    kDefault = 2,
}

function NewMoreStarPanel:create(mode)
    local instance = NewMoreStarPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.more_star_panel)
    instance:init(mode)
    return instance
end

function NewMoreStarPanel:init(mode)
    self.mode = mode or NewMoreStarPanel.Mode.kDefault
	self.group1 = {}
	self.group2 = {}
	self.group3 = {}
	self.group4 = {}
    local ui = self:buildInterfaceGroup('NewMoreStarPanel')
    BasePanel.init(self, ui)

    local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTapped()
	end)

    self.btn = GroupButtonBase:create(ui:getChildByName('btn'))
    self.btn:ad(DisplayEvents.kTouchTap, function () self:changeFlowerNode() end)
    self.btn:setString(_text('更换推荐'))

    self.desc = ui:getChildByName('desc')
    self.desc:setString(_text('more.star.panel.desc'))

    self.gridViewSizeUI = ui:getChildByName('gridView')
    self.gridViewSize = self.gridViewSizeUI:getGroupBounds().size
    self.gridViewSize = CCSizeMake(self.gridViewSize.width, self.gridViewSize.height)
    self.gridViewSizeUI:setVisible(false)
    self.bg = ui:getChildByName('bg')

    self:updateData()
    self:setData(self.group1)

    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self.ui:setPositionY(self.ui:getPositionY() + _G.__EDGE_INSETS.top)
end

function NewMoreStarPanel:getDifficultyInfo(levelId)
    local diffInfo = {}
    diffInfo.difficultyDegree = 100
    diffInfo.difStar1 = 1
    diffInfo.difStar2 = 1
    diffInfo.difStar3 = 1
    diffInfo.difStar4 = 1
    local levelDifficultyInfo = MetaManager.getInstance():getLevelDifficultyByLevelId(levelId)
    if levelDifficultyInfo then 
        diffInfo.difficultyDegree = levelDifficultyInfo.d
        diffInfo.difStar1 = levelDifficultyInfo.d1
        diffInfo.difStar2 = levelDifficultyInfo.d2 or 0
        diffInfo.difStar3 = levelDifficultyInfo.d3 or 0
        diffInfo.difStar4 = levelDifficultyInfo.d4 or 0
    end
    return diffInfo
end

function NewMoreStarPanel:updateData(levelId)
    local allLevelScoreTable = {}
    for levelId = LevelConstans.MAIN_LEVEL_ID_START, LevelConstans.MAIN_LEVEL_ID_END do 
        local levelScore = UserManager:getInstance():getUserScore(levelId)
        if levelScore and levelScore.star > 0 and levelScore.star < 3 then
            local diffInfo = self:getDifficultyInfo(levelId)
            if levelScore.star == 1 then 
                levelScore.difficultyDegree = diffInfo.difficultyDegree / (diffInfo.difStar2 + diffInfo.difStar3 + diffInfo.difStar4) 
            elseif levelScore.star == 2 then 
                levelScore.difficultyDegree = diffInfo.difficultyDegree / (diffInfo.difStar3 + diffInfo.difStar4) 
            end
            table.insert(allLevelScoreTable, levelScore)
        elseif UserManager:getInstance():hasPassedByTrick(levelId) then
            local diffInfo = self:getDifficultyInfo(levelId)
            if not levelScore then 
                levelScore = ScoreRef.new()
                levelScore.uid = UserManager:getInstance().uid
                levelScore.levelId = levelId
            end
            levelScore.difficultyDegree = diffInfo.difficultyDegree
            table.insert(allLevelScoreTable, levelScore)
        end
    end
    if #allLevelScoreTable == 0 then 
        local topLevelId = UserManager:getInstance().user:getTopLevelId()
        if topLevelId then 
            levelScore = ScoreRef.new()
            levelScore.uid = UserManager:getInstance().uid
            levelScore.levelId = topLevelId
            levelScore.notPassButShow = true
            self:insertData(1, levelScore)
        end
    else
        table.sort(allLevelScoreTable, function (a, b)
            if a and b and a.difficultyDegree and b.difficultyDegree then
                local aDifficultyDegree = tonumber(a.difficultyDegree)
                local bDifficultyDegree = tonumber(b.difficultyDegree)
                if aDifficultyDegree ~= nil and 
                   bDifficultyDegree ~= nil then
                   if aDifficultyDegree < bDifficultyDegree then 
                        return true 
                   elseif aDifficultyDegree == bDifficultyDegree then
                        if a.levelId ~= nil and b.levelId ~= nil then
                            local aLevelID = tonumber(a.levelId)
                            local bLevelID = tonumber(b.levelId)
                            return aLevelID < bLevelID
                        end
                   end
                end
            end
        end)

        if self.mode == NewMoreStarPanel.Mode.kOnlyTopAreaLevels then
            allLevelScoreTable = self:filterTopAreaLevelTable(allLevelScoreTable)
        end

        for i=1, 36 do
            if allLevelScoreTable[i] then 
                self:insertData(i, allLevelScoreTable[i])
            end
        end
    end

    if #self.group2 == 0 then 
        self.btn:setEnabled(false)
    end
end

function NewMoreStarPanel:filterTopAreaLevelTable(allLevelScoreTable )
    -- body
    local topLevelId = 1
    if UserManager:getInstance().user then
        topLevelId = UserManager:getInstance().user:getTopLevelId()
    end

    local levelRangeStart ,levelRangeEnd = UnlockLevelAreaLogic:getLevelRangeContainsLevelId(topLevelId)

    allLevelScoreTable = table.filter(allLevelScoreTable, function ( item )
        local levelId = item.levelId
        return levelId >= levelRangeStart and levelId <= levelRangeEnd
    end)

    -- table.sort(allLevelScoreTable, function ( a, b )
    --     local p1 = 0
    --     local p2 = 0
    --     if a and b then
    --         p1 = a.levelId or 0
    --         p2 = b.levelId or 0
    --     end
    --     return p1 > p2
    -- end)

    return allLevelScoreTable

end

function NewMoreStarPanel:setData(data)
	self.currentGroup = data

	if self.gridView then 
		self.gridView:removeFromParentAndCleanup(cleanup)
	end
	local gridView = GridLayout:create()
    gridView:setColumn(3)
    gridView:setItemSize(CCSizeMake(203, 211))

    gridView:setWidth(self.gridViewSize.width)
    gridView:setHeight(self.gridViewSize.height)
    gridView:setPosition(ccp(self.gridViewSizeUI:getPositionX() - 7, self.gridViewSizeUI:getPositionY() + 35))
    self.gridViewSizeUI:getParent():addChildAt(gridView, self.gridViewSizeUI:getZOrder())
    self.gridView = gridView

    for k, v in pairs(data) do
        local flowerType = kFlowerType.kNormal
        if v.star == 0 and not v.notPassButShow then 
            flowerType = kFlowerType.kJumped
            if UserManager:getInstance():hasAskForHelpInfo(v.levelId) then
                flowerType = kFlowerType.kAskForHelp
            end
        end
        local node = FlowerNodeUtil:createWithSize(flowerType, v.levelId, v.star, CCSizeMake(193, 200))
        node:setAnchorPoint(ccp(0, 1))
        node:ignoreAnchorPointForPosition(false)
        node:setScale(1.2)
        local item = ItemInLayout:create()
        item:setContent(node)
        self.gridView:addItem(item)

        node:setTouchEnabled(true)
        node:ad(DisplayEvents.kTouchTap, function () self:onItemTouched(v.levelId) end)
    end
end

function NewMoreStarPanel:onItemTouched(levelId)
    if _G.isLocalDevelopMode then printx(0, 'NewMoreStarPanel:onItemTouched', levelId) end
    self:onCloseBtnTapped()

    if not PopoutManager:sharedInstance():haveWindowOnScreen() and not HomeScene:sharedInstance().ladyBugOnScreen then
        local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
        startGamePanel:popout(false)
    end
end

function NewMoreStarPanel:insertData(flowerIndex, data)
	if flowerIndex < 10 then 
		table.insert(self.group1, data)
	elseif flowerIndex >=10 and flowerIndex < 19 then 
		table.insert(self.group2, data)
	elseif flowerIndex >=19 and flowerIndex < 28 then 
		table.insert(self.group3, data)
	elseif flowerIndex >=28 and flowerIndex < 37 then 
		table.insert(self.group4, data)
	end
end

function NewMoreStarPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self, true)
    self.allowBackKeyTap = false
    if self.closeCallback then self.closeCallback() end
end

function NewMoreStarPanel:changeFlowerNode()
	if self.currentGroup == self.group1 then 
		if #self.group2 > 0 then 
			self:setData(self.group2)
		else
		end
	elseif self.currentGroup == self.group2 then 
		if #self.group3 > 0 then 
			self:setData(self.group3)
		else
			self:setData(self.group1)
		end
	elseif self.currentGroup == self.group3 then 
		if #self.group4 > 0 then 
			self:setData(self.group4)
		else
			self:setData(self.group1)
		end
	elseif self.currentGroup == self.group4 then 
		self:setData(self.group1)
	end
end

function NewMoreStarPanel:popout()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
    self.allowBackKeyTap = true 
end

