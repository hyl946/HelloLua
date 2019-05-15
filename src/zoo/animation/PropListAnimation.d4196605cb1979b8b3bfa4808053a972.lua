-------------------------------------------------------------------------
--  Class include: PropListAnimation, PropListItem, PropHelpButton
-------------------------------------------------------------------------

require "hecore.display.Director"
require "zoo.props.PropListItem"
require "zoo.panel.PropInfoPanel"
require 'zoo.props.SpringPropListItem'
require "zoo.props.PropListAnimationController"
require "zoo.props.LeftPropList"
require "zoo.props.RightPropList"
require "zoo.props.SpringFestival2019RightPropList"
require "zoo.common.ItemType"

local kCurrentMaxItemInListView = 18
local kItemGapInListView = 12

PropHelpButton = class()
function PropHelpButton:ctor( sprite, propListAnimation )
  self.sprite = sprite
  self.controller = propListAnimation.controller
  -- self.levelId = levelId
  -- if not self.levelId then self.levelId = 12 end
end

function PropHelpButton:onTouchBegin(evt)
  if self:hitTest(evt.globalPosition) then
    -- self.onTouchBeginTime = os.time()
    self.sprite:setOpacity(150)
  end
end
function PropHelpButton:onTouchEnd(evt)
  self.sprite:setOpacity(255)

  --[[
  local nowTime = os.time()
  if nowTime - self.onTouchBeginTime > 1 then
    if MaintenanceManager:getInstance():isEnabled("QAInLevelTools") then
      local testui = DiffAdjustQAToolPanel:create()
      testui:popout()
      self.passUseLogic = true
    end
  end
  ]]

end

function PropHelpButton:use(position)
  if self:hitTest(position) then
    --[[
    if self.passUseLogic then
      self.passUseLogic = false
      return
    end
    ]]
    self.controller:callHelpCallback()

    if __WP8 and not self.angleReloaded then
      self.angleReloaded = true
      Wp8Utils:reloadAngle()
    end
    return true
  end
end
function PropHelpButton:hitTest( position )
  local sprite = self.sprite
  local center = sprite:getPosition()
  local r = 25
  
  local offsetY = _G.clickOffsetY or 0
  position = ccp(position.x,position.y  + offsetY / 2)  
  position = sprite:getParent():convertToNodeSpace(position)

  local dx = position.x - center.x - 23
  local dy = position.y - center.y + 23
  return (dx * dx + dy * dy) < r * r
end

--
-- PropListAnimation ---------------------------------------------------------
--
PropListAnimation = class()

local kPropListItemWidth = 130
local kPropItemDirections = {2, 3, 5}

function PropListAnimation:ctor()
  local origin = Director:sharedDirector():getVisibleOrigin()
  local layer = Layer:create()
  -- layer:setTouchEnabled(true)
  self.layer = layer
  self.propLists = {}

  local kPropListScaleFactor = 1
  if __isWildScreen then kPropListScaleFactor = 0.9 end
  self.kPropListScaleFactor = kPropListScaleFactor

  self.layer:setPosition(ccp(origin.x, origin.y + _G.__EDGE_INSETS.bottom / 5))
  self.layer:setScale(self.kPropListScaleFactor)

  local content = Layer:create()
  content.name = "content"
  self.content = content
  self.layer:addChild(content)

  self.controller = PropListAnimationController:create(self)
end

function PropListAnimation:create(levelId, levelModeType, levelType, gameBoardView, replayMode)
	local ret = PropListAnimation.new()
  ret:setLevelModeType(levelModeType, levelType)
  ret:buildUI(levelId, gameBoardView, replayMode)
	return ret
end

function PropListAnimation:buildUI(levelId, gameBoardView, replayMode)
    self.levelId = levelId
    self.replayMode = replayMode
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local width = visibleSize.width / self.kPropListScaleFactor

    self.springItemInRightList = false
    if self.levelType == GameLevelType.kSummerWeekly or self.levelType == GameLevelType.kMayDay 
        or self.levelType == GameLevelType.kMoleWeekly then
    
        local leftPropList = LeftPropList:create(self, CCSizeMake(width-170, 170), levelId, gameBoardView, self.levelType)
        leftPropList:setPosition(ccp(0, 0))
        self.content:addChild(leftPropList)
        self.leftPropList = leftPropList
        table.insert(self.propLists, leftPropList)

        local rightPropList = RightPropList:create(self, CCSizeMake(200, 170), self.levelType)
        rightPropList:setPosition(ccp(width-180,0))
        self.content:addChild(rightPropList)
        self.rightPropList = rightPropList
        self.springItemInRightList = true
        table.insert(self.propLists, rightPropList)

        self.leftPropList:moveToFirstItem(1)
    else
        local bCurIsActSkill = SpringFestival2019Manager.getInstance():getCurIsActSkill()
        if bCurIsActSkill and ( self.levelType == GameLevelType.kMainLevel or self.levelType == GameLevelType.kHiddenLevel or self.levelType == GameLevelType.kSpring2019 ) then
            local leftPropList = LeftPropList:create(self, CCSizeMake(width-170, 170), levelId, gameBoardView, self.levelType)
            leftPropList:setPosition(ccp(0, 0))
            self.content:addChild(leftPropList)
            self.leftPropList = leftPropList
            table.insert(self.propLists, leftPropList)

            local rightPropList = SpringFestival2019RightPropList:create(self, CCSizeMake(200, 170))
            rightPropList:setPosition(ccp(width-180,0+25/0.7))
            self.content:addChild(rightPropList)
            self.rightPropList = rightPropList
            self.springItemInRightList = true
            table.insert(self.propLists, rightPropList)

            self.leftPropList:moveToFirstItem(1)

            SpringFestival2019Manager.getInstance():setCurLevelCreateRightPropList()
        else
            local leftPropList = LeftPropList:create(self, CCSizeMake(width, 170), levelId, gameBoardView, self.levelType)
            leftPropList:setPosition(ccp(0, 0))
            self.content:addChild(leftPropList)
            self.leftPropList = leftPropList
            table.insert(self.propLists, leftPropList)
        end
    end
end

--function PropListAnimation:confirmPropItemUsed(...)
--	assert(#{...} == 0)
--	assert(self.propItemUsed)
--	self.propItemUsed:confirm()
--end

function PropListAnimation:createIcon( itemId )
  local sprite = ResourceManager:sharedInstance():buildItemSprite(itemId) --Sprite:createWithSpriteFrameName("Prop_"..itemId.." instance 10000")
  sprite.name = "icon"
  sprite:setAnchorPoint(ccp(0.5, 0.5))
  sprite:setScale(0.85)
  return sprite
end

function PropListAnimation:dispose()
  self.propLists = nil
  for _, v in pairs(self.propLists) do
    v:dispose()
  end
end

kSummerWeeklyPropUseLimit = {
  -- [ItemType.ADD_FIVE_STEP] = 3,
  [ItemType.BROOM] = 1,
  [ItemType.INGAME_HAMMER] = 3,
  [ItemType.INGAME_BRUSH] = 1,
  [ItemType.INGAME_SWAP] = 2,
  [ItemType.INGAME_REFRESH] = 3,
  [ItemType.RANDOM_BIRD] = 1,
}
function PropListAnimation:getPropUnlimitable(itemId)
    -- local summerWeeklyLimitPropList = {GamePropsType.kRandomBird, GamePropsType.kBroom, GamePropsType.kBroom_l}
    if self.isUnlimited then
      if self.levelType == GameLevelType.kSummerWeekly then
        local maxUseTime = kSummerWeeklyPropUseLimit[itemId]
        return false, maxUseTime
      else
        return true
      end
    else
      return false
    end
end

function PropListAnimation:moveBackPropToCenter()
  if self.leftPropList.controller then
    self.leftPropList.controller:onTouchMove({globalPosition = ccp(400, 0)})
  end
end

function PropListAnimation:flushTemporaryProps(positionSrc, animationCallback,isPre)
  self.leftPropList:flushTemporaryProps(positionSrc, animationCallback,isPre)
end

function PropListAnimation:flushFakeProps(positionSrc, animationCallback,isPre)
  self.leftPropList:flushFakeProps(animationCallback)
end

function PropListAnimation:show( propItems, delayTime )
    self.leftPropList:show(propItems, delayTime)
end

function PropListAnimation:onGameMoveChange(number, animated)
  if self.levelModeType == GameModeType.CLASSIC or 
    self.levelModeType == GameModeType.RABBIT_WEEKLY or 
    self.levelModeType == GameModeType.MAYDAY_ENDLESS then
    --time mode
  else
    if number <= 5 and not animated then 
      self:showAddStepItem()
    else
      self:hideAddMoveItem()
    end
  end
end

function PropListAnimation:showAddStepItem(noAni)
  self.leftPropList:showAddStepItem(noAni)
end

function PropListAnimation:hideAddMoveItem()
  self.leftPropList:hideAddMoveItem()
end

function PropListAnimation:findAddMoveItem()
  return self.leftPropList:findAddMoveItem()
end

function PropListAnimation:addTemporaryItem( itemId, itemNum, fromGlobalPosition, showIcon )
  self.leftPropList:addTemporaryItem( itemId, itemNum, fromGlobalPosition, showIcon )
end

function PropListAnimation:addFakeItemForReplay( itemId, itemNum , usedTimesFix)
  self.leftPropList:addFakeItemForReplay( itemId, itemNum , usedTimesFix)
end

function PropListAnimation:addTimeProp(propId, itemNum, expireTime, fromGlobalPosition, showIcon, text,useFlyBag, noAnim)
  self.leftPropList:addTimeProp(propId, itemNum, expireTime, fromGlobalPosition, showIcon, text,useFlyBag, noAnim)
end

function PropListAnimation:setItemDark( hitItemID, darked )
  self.leftPropList:setItemDark( hitItemID, darked )
end

function PropListAnimation:findItemByItemID( itemId )
  -- todo other propList
  return self.leftPropList:findItemByItemID(itemId)
end

function PropListAnimation:addFakeAllProp( value )
  self.leftPropList:addFakeAllProp( value )
end

function PropListAnimation:useItemWithType(itemId, propType)
  local item = self:findItemByItemID(itemId)
  if item then 
    item:useWithType(itemId, propType)
  end
end

function PropListAnimation:setItemNumber( itemId, itemNum )
  local item = self:findItemByItemID(itemId)
  if item then
      item:setNumber(itemNum)
  end
end

function PropListAnimation:addItemNumber( itemId, itemNum )
  local item = self:findItemByItemID(itemId)
  if item then 
    item:addNumber(itemNum)
  end
end

function PropListAnimation:confirm(itemId, usedPositionGlobal)
  if self.focusItem then
    self.focusItem:focus(false, true)
    self.focusItem:confirm(itemId, usedPositionGlobal)
    self:setItemDark(-1, false)
    self.focusItem = nil
  else
    local hitItem, hitIndex = self:findItemByItemID(itemId)
    if hitItem then 
      hitItem:confirm(itemId, usedPositionGlobal)
    end
  end
end

function PropListAnimation:cancelFocus()
  if self.focusItem then
    self.focusItem:focus(false, true)
    self:setItemDark(-1, false)
    self.focusItem = nil
  end
end

function PropListAnimation:setItemTouchEnabled(enable)
  for _, v in pairs(self.propLists) do
    v:setItemTouchEnabled(enable)
  end
end

function PropListAnimation:setPropState(itemId, reasonType, enable)
  if itemId ~= nil then 
    local item = self:findItemByItemID(itemId)
    if item then
      if enable then
          item:setEnable()
      else
          item:setDisableReason(reasonType) 
      end
    end
  end
end

function PropListAnimation:getPositionByIndex(index)
  return self.leftPropList:getPositionByIndex(index)
end

function PropListAnimation:setLevelModeType(levelModeType, levelType)
    self.levelModeType = levelModeType
    self.levelType = levelType

    if self.levelModeType == GameModeType.MAYDAY_ENDLESS 
      or self.levelModeType == GameModeType.HALLOWEEN 
      or self.levelModeType == GameModeType.HEDGEHOG_DIG_ENDLESS
      or self.levelModeType == GameModeType.OLYMPIC_HORIZONTAL_ENDLESS
      or self.levelModeType == GameModeType.SPRING_HORIZONTAL_ENDLESS
      or self.levelModeType == GameModeType.WUKONG_DIG_ENDLESS 
      then
        self.isUnlimited = true
    end
end

function PropListAnimation:setSpringItemPercent(percent)
  local item = self:findSpringItem()
  if item then item:setPercent(percent, true) end
end

function PropListAnimation:findSpringItem()
  if self.springItemInRightList then
    return self.rightPropList:findSpringItem()
  end
  return self.leftPropList:findSpringItem()
end

function PropListAnimation:findSpringItemIcon()
  local springItem = self:findSpringItem()
  if springItem then 
    return springItem.icon 
  end
  return nil
end

function PropListAnimation:forceUseSpringItem(forceUsedCallback)
  local springItem = self:findSpringItem()
  if springItem then 
    springItem:use(forceUsedCallback, true, true)
  else
    if forceUsedCallback then forceUsedCallback() end
  end
end

function PropListAnimation:setSpringItemEnergy(energy, theCurMoves)
  local item = self:findSpringItem()
  if item then item:setEnergy(energy, true, theCurMoves) end
end

function PropListAnimation:getSpringItemGlobalPosition()
  local itemPos = self:getItemCenterPositionById(kSpringPropItemID)
  if itemPos then return itemPos end
  return ccp(0,0)
end

function PropListAnimation:getItemCenterPositionById(itemId)
  local item = nil
  if itemId == kSpringPropItemID then
    item = self:findSpringItem()
  else
    item = self:findItemByItemID(itemId)
  end
  if not item then return nil end

  return item:getItemCenterPosition()
end


function PropListAnimation:revertItem(itemId,expireTime,useType)
  self.leftPropList:revertItem(itemId,expireTime,useType)
end

function PropListAnimation:revertGiftItem( itemId,toGlobalPosition )
  self.leftPropList:revertGiftItem( itemId,toGlobalPosition )
end