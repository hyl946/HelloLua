require 'zoo.animation.FlowerNode'

local flowerNodeLabelPosY = 70
local Scrollable = class(HorizontalScrollable)
function Scrollable:create(width, height, useClipping, useBlockingLayers)
    local instance = Scrollable.new()
    instance:init(width, height, useClipping, useBlockingLayers)
    return instance
end
function Scrollable:setTouchEndHandler(func)
    self.touchEndHandler = func
end
function Scrollable:onTouchEnd(event)
    -- print 'on touch end'
    -- top out of border
    self.last_y = event.globalPosition.y
    self.last_x = event.globalPosition.x

    if not self:isIgnoreHorizontalMove() then
        -- if move not started, or if horizontal move, then return
        if not self:checkMoveStarted(self.last_x, self.last_y) 
            or self:getScrollDirection() ~= ScrollDirection.kHorizontal 
        then 
            return 
        end
    end

    -- self.speedwatch:onTouchEnd(0, self.last_y)
    for i, v in ipairs(self.speedometers) do
        v:stopMeasure()
    end

    self.xOffset = self.container:getPositionX()


    local speed = self:getSwipeSpeed()
    local dirRight = (speed > 0)
    
    if self.xOffset < self.leftMostOffset then
        self:__moveTo(self.leftMostOffset, 0.3)
        if self.touchEndHandler then
            self.touchEndHandler(self.xOffset, false)
        end
    --bottom out of border
    elseif self.xOffset > self.rightMostOffset then 
        self:__moveTo(self.rightMostOffset, 0.3)
        if self.touchEndHandler then
            self.touchEndHandler(self.xOffset, true)
        end
    elseif speed ~= 0 then
        if self.touchEndHandler then
            self.touchEndHandler(self.xOffset, dirRight)
        end
    end
end

local Container = class()
function Container:create(width, height, items, leftNormalBtn, leftGreyBtn, rightNormalBtn, rightGreyBtn)
    local instance = Container.new()
    instance:init(width, height, items, leftNormalBtn, leftGreyBtn, rightNormalBtn, rightGreyBtn)
    return instance
end
function Container:init(width, height, items, leftNormalBtn, leftGreyBtn, rightNormalBtn, rightGreyBtn)
    self.height = height
    self.curIndex = 1
    self.leftNormalBtn = leftNormalBtn
    self.rightNormalBtn = rightNormalBtn
    self.leftGreyBtn = leftGreyBtn
    self.rightGreyBtn = rightGreyBtn
    self.maxIndex = #items
    self.items = {}
    if self.maxIndex > 4 then
        self.scrollable = Scrollable:create(width, height, true, false)
        self.scrollable:setTouchEndHandler(function (offset, dirRight) self:onTouchEnd(offset, dirRight) end)
        self.scrollable:setScrollStopCallback(function() self:updateButtons() end)
        self.layout = HorizontalTileLayout:create(height)
        -- self.layout:setItemHorizontalMargin(-10)  --关卡花换素材后根据素材调整
        for k, v in pairs(items) do
            table.insert(self.items, v)
            v:setParentView(self.scrollable)
            self.layout:addItem(v)
        end
        self.scrollable:setContent(self.layout)

        self.itemWidth = 0
        if items[1] then
            self.itemWidth = items[1]:getGroupBounds().size.width
        end
        
        self.leftNormalBtn:ad(DisplayEvents.kTouchTap, function () self:onLeftBtnTapped() end)
        self.rightNormalBtn:ad(DisplayEvents.kTouchTap, function () self:onRightBtnTapped() end)
        self.leftNormalBtn:setTouchEnabled(true, 0, true)
        self.rightNormalBtn:setTouchEnabled(true, 0, true)
        self:updateButtons()
    else
        self.layout = HorizontalTileLayoutWithAlignment:create(width, height)
        self.layout:setAlignment(HorizontalAlignments.kCenter)
        -- self.layout:setItemHorizontalMargin(-28)  --关卡花换素材后根据素材调整
        for k, v in pairs(items) do
            table.insert(self.items, v)
            self.layout:addItem(v)
        end
        self.leftNormalBtn:setVisible(false)
        self.leftGreyBtn:setVisible(true)
        self.rightNormalBtn:setVisible(false)
        self.rightGreyBtn:setVisible(true)
        self.scrollable = self.layout
    end
end

function Container:onTouchEnd(offset, dirRight)
    local index = 1
    local add = 2
    if dirRight then
        add = -2
    end
    index = math.floor(-offset / self.itemWidth) + add
    if index < 1 then index = 1 end
    if index > self.maxIndex then index = self.maxIndex end
    self:goto(index)
end

function Container:onLeftBtnTapped()
    if self.curIndex <= 1 then return end
    local index = self.curIndex - 2
    if index < 1 then index = 1 end
    self:goto(index)
end

function Container:onRightBtnTapped()
    if self.curIndex >= self.maxIndex then return end
    local index = self.curIndex + 2
    if index > self.maxIndex then index = self.maxIndex end
    self:goto(index)
end

function Container:updateButtons()
    if self.curIndex <= 1 then
        self.leftNormalBtn:setVisible(false)
        self.leftGreyBtn:setVisible(true)
    else
        self.leftNormalBtn:setVisible(true)
        self.leftGreyBtn:setVisible(false)
    end
    if self.curIndex >= math.max(self.maxIndex - 3, 1) then
        self.rightNormalBtn:setVisible(false)
        self.rightGreyBtn:setVisible(true)
    else
        self.rightNormalBtn:setVisible(true)
        self.rightGreyBtn:setVisible(false)
    end
end

function Container:goto(index)
    if index < 1 then index = 1 end
    if index > self.maxIndex then index = self.maxIndex end
    local offset = (index - 1) * self.itemWidth
    self.scrollable:scrollToOffset(offset)
    self.curIndex = index
end

MoreIngredientPanel = class(BasePanel)

function MoreIngredientPanel:create(levelId, levelType)
    local instance = MoreIngredientPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.more_ingredient_panel)
    instance:init(levelId, levelType)
    return instance
end

function MoreIngredientPanel:init(levelId, levelType)
    self.levelId = levelId
    self.levelType = levelType

    local jumpedLevels = JumpLevelManager:getInstance():getJumpedLevels()
    local moreIngredientLevels = JumpLevelManager:getMoreIngredientLevels()

    table.sort(jumpedLevels, function (v1, v2) return v1.levelId < v2.levelId end)
    table.sort(moreIngredientLevels, function (v1, v2) return v1.levelId < v2.levelId end)

    if #jumpedLevels > 0 and #moreIngredientLevels == 0 
    or #jumpedLevels == 0 and #moreIngredientLevels > 0 then
        self:initSmall(levelId, levelType, jumpedLevels, moreIngredientLevels)
    else
        self:initLarge(levelId, levelType, jumpedLevels, moreIngredientLevels)
    end

    

end

function MoreIngredientPanel:initSmall(levelId, levelType, jumpedLevels, moreIngredientLevels)
    local ui = self.builder:buildGroup('IngredientPanelSmall')
    BasePanel.init(self, ui)
    self.levels                     = ui:getChildByName('levels')
    self.levels.jumpedText          = self.levels:getChildByName('jumpedText')
    self.levels.moreIngredientText  = self.levels:getChildByName('moreIngredientText')
    self.levels.moreIngredientText.text  = self.levels.moreIngredientText:getChildByName('text')
    self.levels.leftArrow           = self.levels:getChildByName('leftArrow')
    self.levels.leftArrowGrey       = self.levels:getChildByName('leftArrowGrey')
    self.levels.rightArrow          = self.levels:getChildByName('rightArrow')
    self.levels.rightArrowGrey      = self.levels:getChildByName('rightArrowGrey')
    self.levels.ph                  = self.levels:getChildByName('ph')
    self.bg                         = ui:getChildByName('bg')


    self:initLevels(jumpedLevels, moreIngredientLevels)

    self.closeBtn = ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)
end

function MoreIngredientPanel:initLarge(levelId, levelType, jumpedLevels, moreIngredientLevels)
    local ui = self.builder:buildGroup('IngredientPanel')
    BasePanel.init(self, ui)
    self.recommendedLevels                  = ui:getChildByName('recommendedLevels')
    self.recommendedLevels.text             = self.recommendedLevels:getChildByName('text')
    self.recommendedLevels.leftArrow        = self.recommendedLevels:getChildByName('leftArrow')
    self.recommendedLevels.leftArrowGrey    = self.recommendedLevels:getChildByName('leftArrowGrey')
    self.recommendedLevels.rightArrow       = self.recommendedLevels:getChildByName('rightArrow')
    self.recommendedLevels.rightArrowGrey   = self.recommendedLevels:getChildByName('rightArrowGrey')
    self.recommendedLevels.ph               = self.recommendedLevels:getChildByName('ph')
    self.jumpedLevels                       = ui:getChildByName('jumpedLevels')
    self.jumpedLevels.text                  = self.jumpedLevels:getChildByName('text')
    self.jumpedLevels.leftArrow             = self.jumpedLevels:getChildByName('leftArrow')
    self.jumpedLevels.leftArrowGrey         = self.jumpedLevels:getChildByName('leftArrowGrey')
    self.jumpedLevels.rightArrow            = self.jumpedLevels:getChildByName('rightArrow')
    self.jumpedLevels.rightArrowGrey        = self.jumpedLevels:getChildByName('rightArrowGrey')
    self.jumpedLevels.ph                    = self.jumpedLevels:getChildByName('ph')
    self.bg                                 = ui:getChildByName('bg')


    self:initMoreIngredientLevels(moreIngredientLevels)
    self:initJumpedLevels(jumpedLevels)

    self.closeBtn = ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)
end

function MoreIngredientPanel:initLevels(jumpedLevels, moreIngredientLevels)
    local ph = self.levels.ph
    ph:setVisible(false)
    local leftArrow = self.levels.leftArrow
    local leftArrowGrey = self.levels.leftArrowGrey
    local rightArrow = self.levels.rightArrow
    local rightArrowGrey = self.levels.rightArrowGrey
    local pos = ccp(ph:getPositionX(), ph:getPositionY())
    local size = CCSizeMake(ph:getContentSize().width*ph:getScaleX(), ph:getContentSize().height*ph:getScaleY())

    if #jumpedLevels > 0 then
        self.levels.jumpedText:setText(localize('skipLevel.tips5', {n = '\n', s = ' '}))
        self.levels.moreIngredientText:setVisible(false)
        local levels = jumpedLevels
        local items = {}
        for k, v in pairs(levels) do
            local node = FlowerNodeUtil:createJumpedFlowerWithIngredientCount(kFlowerType.kJumped, v.levelId, v.star, CCSizeMake(123, 185), JumpLevelManager:getJumpLevelCost(v.levelId))
            node.flowerNode.label:setPositionY(node.flowerNode.label:getPositionY() + flowerNodeLabelPosY)
            node.flowerNode:setPositionY(node.flowerNode:getPositionY() + 20)
            local item = ItemInClippingNode:create()
            item:setContent(node)
            node:setTouchEnabled(true)
            node:ad(DisplayEvents.kTouchTap, function () self:onJumpedLevelTapped(v.levelId) end)
            table.insert(items, item)
        end

        if self.jumpedLevelsContainer then
            self.jumpedLevelsContainer.scrollable:removeFromParentAndCleanup(true)
            self.jumpedLevelsContainer = nil
        end

        self.jumpedLevelsContainer = Container:create(size.width, size.height, items, leftArrow, leftArrowGrey, rightArrow, rightArrowGrey)
        ph:getParent():addChildAt(self.jumpedLevelsContainer.scrollable, ph:getZOrder())
        self.jumpedLevelsContainer.scrollable:setPosition(pos)
    else
        self.levels.moreIngredientText.text:setText(localize('skipLevel.tips6', {n = '\n', s = ' '}))
        self.levels.jumpedText:setVisible(false)
        local items = {}
        local levels = moreIngredientLevels
        for k, v in pairs(levels) do
            local flowerType = kFlowerType.kNormal
            if UserManager:getInstance():hasAskForHelpInfo(v.levelId) then
                flowerType = kFlowerType.kAskForHelp
            end
            local node = FlowerNodeUtil:createWithSize(flowerType, v.levelId, v.star, CCSizeMake(123, 185))
            node.flowerNode.label:setPositionY(node.flowerNode.label:getPositionY() + flowerNodeLabelPosY)
            node.flowerNode:setPositionY(node.flowerNode:getPositionY() + 20)
            local item = ItemInClippingNode:create()
            item:setContent(node)
            node:setTouchEnabled(true)
            node:ad(DisplayEvents.kTouchTap, function () self:onRecommendedLevelTapped(v.levelId) end)
            table.insert(items, item)
        end
        if self.moreIngredientLevelsContainer then
            self.moreIngredientLevelsContainer.scrollable:removeFromParentAndCleanup(true)
            self.moreIngredientLevelsContainer = nil
        end

        self.moreIngredientLevelsContainer = Container:create(size.width, size.height, items, leftArrow, leftArrowGrey, rightArrow, rightArrowGrey)
        ph:getParent():addChildAt(self.moreIngredientLevelsContainer.scrollable, ph:getZOrder())
        self.moreIngredientLevelsContainer.scrollable:setPosition(pos)
    end
end

function MoreIngredientPanel:initMoreIngredientLevels(moreIngredientLevels)

    local levels = moreIngredientLevels

    self.recommendedLevels.text:setText(localize('skipLevel.tips6', {n = '\n', s = ' '}))

    local ph = self.recommendedLevels.ph
    ph:setVisible(false)
    local leftArrow = self.recommendedLevels.leftArrow
    local leftArrowGrey = self.recommendedLevels.leftArrowGrey
    local rightArrow = self.recommendedLevels.rightArrow
    local rightArrowGrey = self.recommendedLevels.rightArrowGrey
    local pos = ccp(ph:getPositionX(), ph:getPositionY())
    local size = CCSizeMake(ph:getContentSize().width*ph:getScaleX(), ph:getContentSize().height*ph:getScaleY())
    
    local items = {}
    for k, v in pairs(levels) do
        local flowerType = kFlowerType.kNormal
        if UserManager:getInstance():hasAskForHelpInfo(v.levelId) then
            flowerType = kFlowerType.kAskForHelp
        end
        local node = FlowerNodeUtil:createWithSize(flowerType, v.levelId, v.star, CCSizeMake(123, 185))
        node.flowerNode.label:setPositionY(node.flowerNode.label:getPositionY() + flowerNodeLabelPosY)
        node.flowerNode:setPositionY(node.flowerNode:getPositionY() + 20)
        local item = ItemInClippingNode:create()
        item:setContent(node)
        node:setTouchEnabled(true)
        node:ad(DisplayEvents.kTouchTap, function () self:onRecommendedLevelTapped(v.levelId) end)
        table.insert(items, item)
    end

    if self.moreIngredientLevelsContainer then
        self.moreIngredientLevelsContainer.scrollable:removeFromParentAndCleanup(true)
        self.moreIngredientLevelsContainer = nil
    end

    self.moreIngredientLevelsContainer = Container:create(size.width, size.height, items, leftArrow, leftArrowGrey, rightArrow, rightArrowGrey)
    ph:getParent():addChildAt(self.moreIngredientLevelsContainer.scrollable, ph:getZOrder())
    -- if items and (#items <= 4) then
    --     pos.x = pos.x + 30  --关卡花换素材后根据素材调整
    -- end
    self.moreIngredientLevelsContainer.scrollable:setPosition(pos)
end

function MoreIngredientPanel:initJumpedLevels(jumpedLevels)

    self.jumpedLevels.text:setText(localize('skipLevel.tips5', {n = '\n', s = ' '}))

    local ph = self.jumpedLevels.ph
    ph:setVisible(false)
    local leftArrow = self.jumpedLevels.leftArrow
    local leftArrowGrey = self.jumpedLevels.leftArrowGrey
    local rightArrow = self.jumpedLevels.rightArrow
    local rightArrowGrey = self.jumpedLevels.rightArrowGrey
    local pos = ccp(ph:getPositionX(), ph:getPositionY())
    local size = CCSizeMake(ph:getContentSize().width*ph:getScaleX(), ph:getContentSize().height*ph:getScaleY())
    local levels = jumpedLevels
    local items = {}
    for k, v in pairs(levels) do
        local node = FlowerNodeUtil:createJumpedFlowerWithIngredientCount(kFlowerType.kJumped, v.levelId, v.star, CCSizeMake(123, 185), JumpLevelManager:getJumpLevelCost(v.levelId))
        node.flowerNode.label:setPositionY(node.flowerNode.label:getPositionY() + flowerNodeLabelPosY)
        node.flowerNode:setPositionY(node.flowerNode:getPositionY() + 20)
        local item = ItemInClippingNode:create()
        item:setContent(node)
        node:setTouchEnabled(true)
        node:ad(DisplayEvents.kTouchTap, function () self:onJumpedLevelTapped(v.levelId) end)
        table.insert(items, item)
    end

    if self.jumpedLevelsContainer then
        self.jumpedLevelsContainer.scrollable:removeFromParentAndCleanup(true)
        self.jumpedLevelsContainer = nil
    end

    self.jumpedLevelsContainer = Container:create(size.width, size.height, items, leftArrow, leftArrowGrey, rightArrow, rightArrowGrey)
    ph:getParent():addChildAt(self.jumpedLevelsContainer.scrollable, ph:getZOrder())
    -- if items and (#items <= 4) then
    --     pos.x = pos.x + 20  --关卡花换素材后根据素材调整
    -- end
    self.jumpedLevelsContainer.scrollable:setPosition(pos)
end

function MoreIngredientPanel:onRecommendedLevelTapped(levelId)
    self:removeSelf()
    DcUtil:UserTrack({category = 'skipLevel', sub_category = 'start_pod_level', t1 = JumpLevelManager:getInstance():getOwndIngredientNum()})
    local levelType = LevelType:getLevelTypeByLevelId(levelId)
    local startGamePanel = StartGamePanel:create(levelId, levelType)
    startGamePanel:popout(false)
end

function MoreIngredientPanel:onJumpedLevelTapped(levelId)
    self:removeSelf()
    DcUtil:UserTrack({category = 'skipLevel', sub_category = 'start_pod_level', t1 = JumpLevelManager:getInstance():getOwndIngredientNum()})
    local levelType = LevelType:getLevelTypeByLevelId(levelId)
    local startGamePanel = StartGamePanel:create(levelId, levelType)
    startGamePanel:popout(false)
end

function MoreIngredientPanel:popout(closeCallback)
    self.closeCallback = closeCallback
    self:setPositionForPopoutManager()
    PopoutQueue.sharedInstance():push(self, true)
    self.allowBackKeyTap = true
end

function MoreIngredientPanel:onCloseBtnTapped()
    self:removeSelf()
    if self.closeCallback then
        self.closeCallback()
    end
end

function MoreIngredientPanel:removeSelf()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self, true)
end

function MoreIngredientPanel:getHCenterInScreenX()
    local visibleSize   = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local selfWidth     = self.bg:getGroupBounds().size.width
    local deltaWidth    = visibleSize.width - selfWidth
    local halfDeltaWidth    = deltaWidth / 2
    return visibleOrigin.x + halfDeltaWidth
end

function MoreIngredientPanel:getVCenterInScreenY()
    local visibleSize   = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local selfHeight    = self.bg:getGroupBounds().size.height
    local deltaHeight   = visibleSize.height - selfHeight
    local halfDeltaHeight   = deltaHeight / 2
    return visibleOrigin.y + halfDeltaHeight + selfHeight
end

function MoreIngredientPanel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local wSize = CCDirector:sharedDirector():getWinSize()
    local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
    local posAdd = wSize.height - vSize.height - vOrigin.y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end