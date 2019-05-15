
local OldRewardPanel = class(BasePanel)

function OldRewardPanel:create(rewards)
    local panel = OldRewardPanel.new()
    panel:loadRequiredResource("ui/newLadybug.json")
    panel:init(rewards)
    return panel
end

function OldRewardPanel:init(rewards)
    local ui = self:buildInterfaceGroup("ladybug.new/old")
	BasePanel.init(self, ui)

    self.btn = self.ui:getChildByName('btn')
    self.btn = GroupButtonBase:create(self.btn)
    self.btn:ad(DisplayEvents.kTouchTap, function ( ... )

        local bounds = self:getGroupBounds()
        local centerPos = ccp(bounds:getMidX(), bounds:getMidY())

        self:onCloseBtnTapped()
        self:playAnim(centerPos, rewards)
    end)
    self.btn:setString('知道啦')

    self.content = self.ui:getChildByName('content')

    self:buildRewards(rewards) 
end

function OldRewardPanel:buildRewards( rewards )

    local itemUIs = {}

    local totalWidth = 0

    for index, rewardItem in ipairs(rewards) do
        local itemUI = self:buildItemUI(rewardItem)
        table.insert(itemUIs, itemUI)
        totalWidth = totalWidth + itemUI:getGroupBounds(self.ui).size.width
    end

    local size = self.content:getGroupBounds(self.ui).size
    size = CCSizeMake(size.width, size.height)

    local realSize = CCSizeMake(size.width, size.height)

    if totalWidth < size.width then
        realSize.width = totalWidth
    end

    local pos = self.content:getPosition()

    local posX = 0

    local itemWidth = 0


    self.scrollable = HorizontalScrollable:create(realSize.width, realSize.height, true, false)
    self.layout = HorizontalTileLayout:create(realSize.height)

    for index, itemUI in ipairs(itemUIs) do

        local itemContainer =  ItemInLayout:create()
        itemContainer:setContent(itemUI)
        self.layout:addItem(itemContainer)
    end


    self.content:setVisible(false)


    self.scrollable:setContent(self.layout)
    self.ui:addChild(self.scrollable)

    if size.width > realSize.width then
        self.scrollable:setPosition(ccp(pos.x + (size.width - realSize.width)/2, pos.y))
        self.scrollable:setScrollEnabled(false)
    else
        self.scrollable:setPosition(ccp(pos.x, pos.y))
    end


end

function OldRewardPanel:buildItemUI( rewardItem )
    self:loadRequiredResource("ui/newLadybug.json")

    local itemUI = self:buildInterfaceGroup('ladybug.new/ladybug.new.item/item')

    local holder = itemUI:getChildByName('holder')
    local num = itemUI:getChildByName('num')
    num:changeFntFile('fnt/target_amount.fnt')
    num:setScale(num:getScale()*1.3)

    local rewardSP = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
    rewardSP:setAnchorPoint(ccp(0.5, 0.5))

    holder:setAnchorPointCenterWhileStayOrigianlPosition()
    local pos = holder:getPosition()
    rewardSP:setPosition(ccp(pos.x, pos.y))

    local holderIndex = itemUI:getChildIndex(holder)
    itemUI:addChildAt(rewardSP, holderIndex)


    local text = tostring('x'..rewardItem.num)

    num:setText(text)

    num:setPositionX(num:getPositionX() + 135 - num:getContentSize().width)

    holder:removeFromParentAndCleanup(true)

    return itemUI
end

function OldRewardPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function OldRewardPanel:popout()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function OldRewardPanel:onCloseBtnTapped( ... )
    self:_close()
end

function OldRewardPanel:playAnim(startPos, rewards )
    local anim = FlyItemsAnimation:create(rewards)
    anim:setWorldPosition(startPos)
    anim:play()
    local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
    LadybugDataManager:getInstance():refreshGoldCoinButton()
end

return OldRewardPanel
