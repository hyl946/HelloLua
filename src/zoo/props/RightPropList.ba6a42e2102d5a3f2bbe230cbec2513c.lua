require "zoo.props.PropListContainer"
require "zoo.props.RightPropListController"
require "zoo.props.AutumnPropListItem"
require "zoo.props.MoleWeeklyRacePropItem"

RightPropList = class(PropListContainer)

function RightPropList:create(propListAnimation, size, levelType)
	local node = RightPropList.new(CCNode:create())
	PropListContainer.init(node, propListAnimation, size)
	node:_init()
	node:_buildUI(levelType)
	return node
end

function RightPropList:_init()
  	self:setController(RightPropListController:create(self))
end

function RightPropList:dispose()
	PropListContainer.dispose(self)
end

function RightPropList:_buildUI(levelType)
	self.levelType = levelType

	local levelSkinConfig = GamePlaySceneSkinManager:getConfig(GamePlaySceneSkinManager:getCurrLevelType())
	local groupName = levelSkinConfig.weeklyItemContainer or "spring_item_container"
	local propsListView = ResourceManager:sharedInstance():buildGroup(groupName)
  	local targetSize = propsListView:getGroupBounds().size
  	propsListView:setContentSize(CCSizeMake(targetSize.width, targetSize.height))
  	propsListView:setPosition(ccp(0, targetSize.height-80))
	self.propsListView = propsListView

	local itemHolder = self.propsListView:getChildByName("item")
	local size = itemHolder:getGroupBounds().size
	local pos = itemHolder:getPosition()
	local zOrder = itemHolder:getZOrder()
	local centerPos = ccp(pos.x + size.width / 2 + 1, pos.y - size.height / 2 + 2)
	itemHolder:removeFromParentAndCleanup(true)

	self.itemCenter = centerPos
	self.itemRadius = math.max(size.width/2, size.height/2)

	self.content:addChild(propsListView)

	self.flagFree = nil
	self.flagSupply = nil

	if GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kSummerWeekly 
        or GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kMoleWeekly  then 
		self.flagFree = self.propsListView:getChildByName("free_flag")
		self.flagFree:setVisible(false)
		self.flagSupply = self.propsListView:getChildByName("free_supply")
	end

	local function update(percent)
		-- printx(11, "////////////////// UPDATE MAGIC SKLL NUM //////////////////, percent:", percent)
		if GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kSummerWeekly 
            or GamePlaySceneSkinManager:getCurrLevelType() == GameLevelType.kMoleWeekly then
			if percent >= 1 then 
				self.flagFree:setVisible(true)
				self.flagSupply:setVisible(false)
			else
				self.flagFree:setVisible(false)
				self.flagSupply:setVisible(true)
			end
		end
	end

	local springItem
	if self.levelType == GameLevelType.kMoleWeekly then
		springItem = MoleWeeklyRacePropItem:create(self.propListAnimation)
	else	--self.levelType == GameLevelType.kSummerWeekly
		springItem = AutumnPropListItem:create(self.propListAnimation)
	end
	springItem:setPercentChangeCallback(update)
	self.springItem = springItem
	springItem:setPosition(centerPos)
	propsListView:addChildAt(springItem, zOrder)
end

function RightPropList:findSpringItem()
	return self.springItem
end

function RightPropList:foundHitItem(evt)
	local localPos = self.propsListView:convertToNodeSpace(evt.globalPosition)
	local dx = localPos.x - self.itemCenter.x
	local dy = localPos.y - self.itemCenter.y
	if (dx * dx + dy * dy) < self.itemRadius * self.itemRadius then
		return self.springItem
	end
	return nil
end
