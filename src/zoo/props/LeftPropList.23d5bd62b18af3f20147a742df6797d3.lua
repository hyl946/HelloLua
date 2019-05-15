require "zoo.props.PropListItem"
require "zoo.panel.PropInfoPanel"
require 'zoo.props.SpringPropListItem'
require "zoo.props.PropListContainer"
require "zoo.props.LeftPropListController"

local kCurrentMaxItemInListView = 18
local kItemGapInListView = 12
local kItemGapInListViewTight = 21
local kPropListItemWidth = 130
local kPropItemDirections = {2, 3, 5}

LeftPropList = class(PropListContainer)

function LeftPropList:create(propListAnimation, size, levelId, gameBoardView, levelType)
	local node = LeftPropList.new(CCNode:create())
	PropListContainer.init(node, propListAnimation, size)
	node:_init(gameBoardView)
	node:_buildUI(levelId, levelType)
	return node
end

function LeftPropList:dispose()
	PropListContainer.dispose(self)
  	for i = 1, kCurrentMaxItemInListView do
      self["item"..i]:dispose()
    end
end

function LeftPropList:_init(gameBoardView)
  --[[
  if kWindowFrameRatio.iPad.name == __frame_key then
    kPropListScaleFactor = 0.9
  end
  if kWindowFrameRatio.iPhone4.name == __frame_key then
    kPropListScaleFactor = 0.9
  end
  ]]
  self.propListItemWidth = kPropListItemWidth
  self.propListMaxItemPerPage = math.floor(self.width / self.propListItemWidth)
  self:setController(LeftPropListController:create(self,gameBoardView))
end

function LeftPropList:_buildUI(levelId, levelType)
    self.levelId = levelId
    self.levelType = levelType

    self.isTightLayout = true --默认树枝布局调整，新版采用紧凑的配列布局
    if self.levelType == GameLevelType.kMoleWeekly or self.levelType == GameLevelType.kJamSperadLevel then
      self.isTightLayout = false
    end

    local winSize = CCDirector:sharedDirector():getWinSize()
  	local vSize = CCDirector:sharedDirector():getVisibleSize()
    self.levelSkinConfig = GamePlaySceneSkinManager:getConfig(GamePlaySceneSkinManager:getCurrLevelType())
  	local propsListView = ResourceManager:sharedInstance():buildGroup(self.levelSkinConfig.propsListView)

  	local targetSize = propsListView:getGroupBounds().size
  	propsListView:setContentSize(CCSizeMake(targetSize.width, targetSize.height))
  	propsListView:setPosition(ccp(0, 215))
  	self.propsListView = propsListView
  	self.content:addChild(propsListView)

    local bgIndex = propsListView:getChildByName("background"):getZOrder()
    local bgGb = propsListView:getChildByName("background"):getGroupBounds(propsListView)
    local fgGb = propsListView:getChildByName("foreground"):getGroupBounds(self.content)

    local bgSymbolName = propsListView:getChildByName("background").symbolName
    local fgSymbolName = propsListView:getChildByName("foreground").symbolName

    propsListView:getChildByName("foreground"):removeFromParentAndCleanup(true)
    propsListView:getChildByName("background"):removeFromParentAndCleanup(true)

    local foreground = ResourceManager:sharedInstance():buildBatchGroup("batch", fgSymbolName)
    foreground.name = "foreground"
    foreground:setAnchorPoint(ccp(0, 0))
    foreground:ignoreAnchorPointForPosition(false)
    foreground:setPosition(ccp(fgGb.origin.x, fgGb.origin.y + fgGb.size.height))
    self.viewLayer:addChild(foreground)

    local rightCorner = foreground:getChildByName("leaf_l_4")
    if rightCorner then 
      rightCorner:setPositionX(vSize.width - fgGb.origin.x - 160)
    end

    local helpButton = foreground:getChildByName("help_button")
      self.helpButton = PropHelpButton.new(helpButton, self.propListAnimation)
    if self.propListAnimation and LevelType.isActivityLevelType(self.propListAnimation.levelType) then
      helpButton:setVisible(false)
      self.helpButton.onTouchBegin = function (self, evt) end
      self.helpButton.onTouchEnd = function (self, evt) end
      self.helpButton.hitTest = function (self, position) return false end
    end

    local background = ResourceManager:sharedInstance():buildBatchGroup("batch", bgSymbolName)
    background.name = "background"
    background:setAnchorPoint(ccp(0, 0))
    background:ignoreAnchorPointForPosition(false)
    background:setPosition(ccp(bgGb.origin.x, bgGb.origin.y + bgGb.size.height))
    propsListView:addChildAt(background, bgIndex)

    local backgroundSize = background:getGroupBounds().size

    self.minX = self.width - backgroundSize.width + 40
    self.maxX = 0
    self.visibleMinX = self.minX

    self:createItems()

    self:recItemSize()

    -- bug fix 
    -- 重新计算kPropListItemWidth并重新计算propListMaxItemPerPage
    kPropListItemWidth = self.item1.item:getContentSize().width
    self.propListItemWidth = kPropListItemWidth
    self.propListMaxItemPerPage = math.floor(self.width / self.propListItemWidth)
end

function LeftPropList:show( propItems, delayTime )
    self.content:setPosition(ccp(0,0))
    delayTime = delayTime or 0 --1.35

    local propsListView = self.propsListView
    local background = propsListView:getChildByName("background")
  
  	local backgroundPos = background:getPosition()
  	local bgX, bgY = backgroundPos.x, backgroundPos.y
  	background:setVisible(true)
    --local function onTestTemporary() self:flushTemporaryProps() end
    --background:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5),CCCallFunc:create(onTestTemporary)))
    local function onUpdateContent()
      if math.random() > 0.6 then self:windover() end
      --self:windover()
    end
    background:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(10), CCCallFunc:create(onUpdateContent))))

    local currItems = #self.fixedPopItems

    local frobidScrollToEnd = true
    local springItem = self:findSpringItem()
    if springItem or self.levelType == GameLevelType.kMoleWeekly then
        frobidScrollToEnd = false
    end

  	for i = 1, kCurrentMaxItemInListView do
      local item = self["item"..i]

      if i <= currItems then

        local propItem = self.fixedPopItems[i]

        if self:shouldHideItem(propItem.itemId) then
          item:hide(frobidScrollToEnd)
        else
          local initDisable = propItem.itemId ~= kSpringPropItemID and propItem.itemId == GamePropsType.kBack
          item:show(0, true, initDisable)
        end
        
      else
        item:hide(frobidScrollToEnd) 
      end
    end

    if springItem then
        self:moveToFirstItem(1)
    end
    self:updateVisibleMinX()

    self:getPropPositions()
end

function LeftPropList:moveToFirstItem(delayTime)
    setTimeOut(function()
         if self.content and self.content.refCocosObj then
           self.content:runAction(CCMoveTo:create(0.2, ccp(0,0)))
         end
      end, delayTime)
end

function LeftPropList:createItems()
    local fixedPopItems = {}

    for i = 1 , #PropsModel.instance().propItems do
      local propItem = PropsModel:instance().propItems[i]
      if propItem.itemId == ItemType.RANDOM_BIRD or propItem.itemId == ItemType.TIMELIMIT_RANDOM_BIRD then
        if UserManager:getInstance():getUserPropNumberWithAllType(propItem.itemId) > 0 then
          table.insert(fixedPopItems , propItem)
        end
      else
        table.insert(fixedPopItems , propItem)
      end
    end
    local currItems = #fixedPopItems

    self.fixedPopItems = fixedPopItems

    for i = 1, kCurrentMaxItemInListView do

      if i <= currItems then
        local propItem = fixedPopItems[i]

        
        local item  = self:createPropListItem(i, propItem.itemId)
        local isUnlimited, maxUseTime = self.propListAnimation:getPropUnlimitable(propItem.itemId)
        item:setPropItemData(propItem, isUnlimited, maxUseTime) --setup the item's data
      else
         self:createPropListItem(i, nil)
      end
    end

end

function LeftPropList:shouldHideItem( itemId )
  if itemId == ItemType.ADD_15_STEP then
    return UserManager:getInstance():getUserPropNumber(itemId) <= 0
  elseif itemId == ItemType.RANDOM_BIRD or itemId == ItemType.TIMELIMIT_RANDOM_BIRD then
    --return UserManager:getInstance():getUserPropNumberWithAllType(itemId) <= 0
  else
    return false
  end
end

function LeftPropList:checkCanNotBuyItems( ... )
  local canNotBuyItemIds = {ItemType.ADD_15_STEP , ItemType.RANDOM_BIRD , ItemType.TIMELIMIT_RANDOM_BIRD }
  for index, itemId in ipairs(canNotBuyItemIds) do
    local item = self:findItemByItemID(itemId)
    --printx( 1 , "LeftPropList:checkCanNotBuyItems  itemId =" , itemId , item)
    if item then
      if self:shouldHideItem(itemId) then
        item:hide()
      else
        item:show(0)
      end
    end
  end
end

function LeftPropList:addItemWithAnimation( item, delayTime, useHint )
  if item then
    PropsModel:instance():addItem(item)
    local itemIndex = self:findEmptySlot()
    if itemIndex >= kCurrentMaxItemInListView then return end
    --self["item"..itemIndex]:enableUnlimited(self.isUnlimited)
    local isUnlimited, maxUseTime = self.propListAnimation:getPropUnlimitable(item.itemId)
    self["item"..itemIndex]:setPropItemData(item, isUnlimited, maxUseTime)
    self["item"..itemIndex]:show(delayTime, true) 
    if useHint then self["item"..itemIndex].animator:pushPropAnimation(2) end
    
    self:updateVisibleMinX()
    self.content:stopAllActions()
    self.content:runAction(CCEaseSineOut:create(CCMoveTo:create(0.6, ccp(self:getItemOffset(itemIndex), 0)))) 
    return itemIndex
  end
  return -1
end

function LeftPropList:flushTemporaryProps(positionSrc, animationCallback, isPre)
  if PropsModel:instance():temporaryPopsExist() then 
    for i,v in ipairs(PropsModel:instance().temporaryPops) do 

      local mappingItemId = PropsModel.kTempPropMapping[tostring(v.itemId)]
      if mappingItemId then itemFound, itemIndex = self:findItemByItemID(mappingItemId) end
      
      if itemFound then
          itemFound:increaseTemporaryItemNumber(v.itemId, v.itemNum)
      end
    end

    -- 飞动画统一在外面

    -- local fromGlobalPosition = ccp(positionSrc.x - 5, positionSrc.y + 4)--ccp(winSize.width/2, winSize.height/2)
    -- local maxItemNum = 0
    -- local item_count = 0
    -- for i,v in ipairs(PropsModel:instance().temporaryPops) do 
    --   local function onAnimationFinished()
    --     self:addTemporaryItem(v.itemId, v.itemNum, fromGlobalPosition, false)
    --     item_count = item_count + 1
    --     if item_count >= maxItemNum and animationCallback then
    --       animationCallback() 
    --     end
    --   end
    --   maxItemNum = maxItemNum + 1
    --   local icon = PropListAnimation:createIcon( v.itemId )
    --   local sprite = PrefixPropAnimation:createPropAnimation(icon, self.propListAnimation.layer:convertToNodeSpace(fromGlobalPosition), onAnimationFinished,isPre)
    --   self.propListAnimation.layer:addChild(sprite)
    -- end
    PropsModel:instance():clearTemporaryPops()
  else
    animationCallback()
  end
end

function LeftPropList:flushFakeProps(animationCallback)
  if PropsModel:instance():fakePropsExist() then 
    for i,v in ipairs(PropsModel:instance().fakeProps) do 

      local mappingItemId = PropsModel.kTempPropMapping[tostring(v.itemId)]
      if mappingItemId then itemFound, itemIndex = self:findItemByItemID(mappingItemId) end
      if itemFound then
          itemFound:increaseFakeItemNumber(v.itemId, v.itemNum)
      end
    end
    PropsModel:instance():clearFakeProps()
  else
    if animationCallback then animationCallback() end
  end
end


function LeftPropList:playAddGetPropAnimationStepOne(item, index, fromGlobalPosition, flyFinishedCallback, propID, text)
  assert(propID, "propID cannot be nil")

  if not item then return end

  local bglight = nil

  local finalPos = self:ensureItemInSight(item, 0.3)
  if not fromGlobalPosition then
    fromGlobalPosition = ccp( finalPos.x , finalPos.y )
  end
  local from = self.propListAnimation.layer:convertToNodeSpace(fromGlobalPosition)
  local to = self.propListAnimation.layer:convertToNodeSpace(finalPos) --item:getItemCenterPosition()
  local winSize = CCDirector:sharedDirector():getWinSize()

  local centerPos = self.propListAnimation.layer:convertToNodeSpace(ccp(winSize.width / 2, winSize.height / 2))

  local timeScale = 1

  local propIcon = nil
  if propID then propIcon = PropListAnimation:createIcon( propID ) end
  if propIcon then
    local offsetX = 0
    -- if index > self.propListMaxItemPerPage then offsetX = self:getItemOffset(index) end 

    self.propListAnimation.layer:addChild(propIcon)  
    propIcon:setPosition(ccp(from.x, from.y))
    local seq = CCArray:create()
    seq:addObject(CCMoveTo:create(0.3 * timeScale, centerPos))
    local function addBgAnimation()
      bglight = CommonEffect:buildGetPropLightAnim(text , true)
      bglight:setPosition(centerPos)
      self.propListAnimation.layer:addChildAt(bglight, -1)
    end
    seq:addObject(CCCallFunc:create(addBgAnimation))
    seq:addObject(CCScaleTo:create(0.5, 1.8))
    seq:addObject(CCDelayTime:create(2))
    seq:addObject(CCCallFunc:create(flyFinishedCallback))
    
    propIcon:runAction(CCSequence:create(seq))

    local function bglightCallback()
      if bglight then
        local sequenceArr3 = CCArray:create()
        sequenceArr3:addObject(CCFadeTo:create(0.3, 0))
        local function onRemoveBglight()
          bglight:removeFromParentAndCleanup(true)
        end
        sequenceArr3:addObject(CCCallFunc:create(onRemoveBglight))

        bglight:runAction(CCSequence:create(sequenceArr3))
      end
    end

    return propIcon , centerPos , to , bglightCallback
  end
end

function LeftPropList:playAddGetPropAnimationStepTwo( propIcon, centerPos , to, bglightCallback , flyFinishedCallback )
  
  if bglightCallback then
    bglightCallback()
  end  

  local seq = CCArray:create()
  seq:addObject(CCScaleTo:create(0.3, 1))
  
  local function addFallingtar()
    local fallingStar = FallingStar:create(centerPos, ccp(to.x + 0, to.y), nil, flyFinishedCallback)
    self.propListAnimation.layer:addChild(fallingStar)
  end

  seq:addObject(CCCallFunc:create(addFallingtar))
  seq:addObject(CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(to.x + 0, to.y))))
  local function onAnimationFinished() propIcon:removeFromParentAndCleanup(true) end
  seq:addObject(CCCallFunc:create(onAnimationFinished))
  
  propIcon:runAction(CCSequence:create(seq))

  return propIcon
end



-- 出现的位置->飞到屏幕中心->变大+发光->变小->飞到道具栏
function LeftPropList:addGetPropAnimation(item, index, fromGlobalPosition, flyFinishedCallback, propID, text)
  assert(propID, "propID cannot be nil =========== ")
  if _G.isLocalDevelopMode then printx(0, propID,"================",text) end

  if not item or not fromGlobalPosition then return end

  local from = self.propListAnimation.layer:convertToNodeSpace(fromGlobalPosition)
  local finalPos = self:ensureItemInSight(item, 0.3)
  local to = self.propListAnimation.layer:convertToNodeSpace(finalPos) --item:getItemCenterPosition()
  local vSize = CCDirector:sharedDirector():getVisibleSize()
  local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

  local gCenterPos = ccp(vOrigin.x + vSize.width / 2, vOrigin.y + vSize.height / 2)
  local centerPos = self.propListAnimation.layer:convertToNodeSpace(gCenterPos)

  local timeScale = 1

  local propIcon = nil
  if propID then propIcon = PropListAnimation:createIcon( propID ) end
  if propIcon then
    local offsetX = 0
    -- if index > self.propListMaxItemPerPage then offsetX = self:getItemOffset(index) end 

    self.propListAnimation.layer:addChild(propIcon)  
    propIcon:setPosition(ccp(from.x, from.y))
    local seq = CCArray:create()
    seq:addObject(CCMoveTo:create(0.3 * timeScale, centerPos))
    local function addBgAnimation()
      local anim = CommonEffect:buildGetPropLightAnim(text)
      anim:setPosition(centerPos)
      self.propListAnimation.layer:addChildAt(anim, -1)
    end
    local function addFallingtar()
      local fallingStar = FallingStar:create(centerPos, ccp(to.x + offsetX, to.y), nil, flyFinishedCallback)
      self.propListAnimation.layer:addChild(fallingStar)
    end
    
    local function onAnimationFinished() propIcon:removeFromParentAndCleanup(true) end


    seq:addObject(CCCallFunc:create(addBgAnimation))
    seq:addObject(CCScaleTo:create(0.5, 1.8))
    seq:addObject(CCDelayTime:create(2))
    seq:addObject(CCScaleTo:create(0.3, 1))
    


    seq:addObject(CCCallFunc:create(addFallingtar))
    seq:addObject(CCEaseSineInOut:create(CCMoveTo:create(0.5, ccp(to.x + offsetX, to.y))))
    
    seq:addObject(CCCallFunc:create(onAnimationFinished))
    propIcon:runAction(CCSequence:create(seq))
  end
end

function LeftPropList:addFallingtar( item, index, fromGlobalPosition, flyFinishedCallback, propID )
  if not item or not fromGlobalPosition then return end

  --local itemTo = item.item
  local finalPos = self:ensureItemInSight(item, 0.3)
  local to = self.propListAnimation.layer:convertToNodeSpace(finalPos) --item:getItemCenterPosition()
  local from = self.propListAnimation.layer:convertToNodeSpace(fromGlobalPosition) 
  local offsetX = 0
  -- if index > self.propListMaxItemPerPage then offsetX = self:getItemOffset(index) end  
  local fallingStar = BezierFallingStar:create(from, ccp(to.x + offsetX, to.y), nil, flyFinishedCallback)
  self.propListAnimation.layer:addChild(fallingStar)

  local propIcon = nil
  if propID then propIcon = PropListAnimation:createIcon( propID ) end
  if propIcon then
    self.propListAnimation.layer:addChild(propIcon)
    -- local time = fallingStar.time or 0.5
    local array = CCArray:create()
    local function onAnimationFinished() propIcon:removeFromParentAndCleanup(true) end
    -- array:addObject(CCEaseSineInOut:create(CCMoveTo:create(time, ccp(to.x + offsetX, to.y))))
    array:addObject(fallingStar:createMoveAction(from, ccp(to.x + offsetX, to.y)))
    array:addObject(CCCallFunc:create(onAnimationFinished))
    propIcon:setPosition(ccp(from.x, from.y))
    propIcon:runAction(CCSequence:create(array))

  end
end

function LeftPropList:addTemporaryItem( itemId, itemNum, fromGlobalPosition, showIcon)
  if _G.isLocalDevelopMode then printx(0, "added temporary item: ", itemId, itemNum) end

  itemNum = itemNum or 0
  local itemFound, itemIndex = self:findItemByItemID(itemId)

  local animateFallingIcon = true
  local animatedItemID = nil
  if showIcon ~= nil then animateFallingIcon = showIcon end
  if animateFallingIcon then animatedItemID = itemId end

  if itemFound then
    local function onTempFlyFinishedCallback()
      itemFound:increaseItemNumber(itemId, itemNum)
    end    
    self:addFallingtar(itemFound, itemIndex, fromGlobalPosition, onTempFlyFinishedCallback, animatedItemID)
    return
  else
    local mappingItemId = PropsModel.kTempPropMapping[tostring(itemId)]
    if mappingItemId then itemFound, itemIndex = self:findItemByItemID(mappingItemId) end
    
    if itemFound then
      local function onNormalFlyFinishedCallback()
        itemFound:increaseTemporaryItemNumber(itemId, itemNum)
      end    
      self:addFallingtar(itemFound, itemIndex, fromGlobalPosition, onNormalFlyFinishedCallback, animatedItemID)
      return
    end
  end

  local itemData = PropItemData:createWithData({itemId=itemId, itemNum=itemNum, temporary=1})
  local index = self:addItemWithAnimation(itemData, 0)
  if index < 1 then 
    return 
  end

  local onTemporaryItemUsed = function( removedItem )
    local maxIndex = self:findMaxSlotIndex()
    local removedIndex = removedItem.index
    PropsModel:instance():removeItem(removedItem)
    if maxIndex < removedIndex and removedIndex > self.propListMaxItemPerPage then
      local position = self.content:getPosition()
      local visibleX = self:getItemOffset(maxIndex)
      self.content:runAction(CCEaseSineOut:create(CCMoveTo:create(0.3, ccp(visibleX, position.y))))
    end
  end
  self:addFallingtar(self["item"..index], index, fromGlobalPosition, nil, animatedItemID)
  self["item"..index].onTemporaryItemUsed = onTemporaryItemUsed
end

function LeftPropList:addFakeItemForReplay( itemId , itemNum , usedTimesFix)
  --printx( 1 , "LeftPropList:addFakeItemForReplay  itemId:" , itemId , "itemNum:" , itemNum)
  itemNum = itemNum or 0

  ----[[
  local itemFound, itemIndex = self:findItemByItemID(itemId)

  local animateFallingIcon = true
  local animatedItemID = nil
  if showIcon ~= nil then animateFallingIcon = showIcon end
  if animateFallingIcon then animatedItemID = itemId end

  if not itemFound then
    local mappingItemId = PropsModel.kTempPropMapping[tostring(itemId)]
    if mappingItemId then 
      itemFound, itemIndex = self:findItemByItemID(mappingItemId) 
    end
  end

  if itemFound then
    itemFound:increaseFakeItemNumber(itemId, itemNum , usedTimesFix)
    return
  end

  --printx( 1 , "LeftPropList:addFakeItemForReplay  Has Not Found !!!!!! itemId:" , itemId , "itemNum:" , itemNum)
  --]]
end


function LeftPropList:getBasePosition(x, y)
  local tempX = (x - 0.5 ) * 65
  local tempY = (GamePlayConfig_Max_Item_Y - y - 0.5 ) * 65
  return ccp(tempX, tempY)
end

function LeftPropList:addTimeProp(propId, itemNum, expireTime, fromGlobalPosition, showIcon, text, useFlyBag, noAnim)

  itemNum = itemNum or 0
  useFlyBag = useFlyBag or false -- 是否启用飞入到背包的动画

  local itemId = ItemType:getRealIdByTimePropId(propId)
  local itemFound, itemIndex = self:findItemByItemID(itemId)

  -- if _G.isLocalDevelopMode then printx(0, "propId",propId,itemNum,"itemId",itemId,"itemFound",itemFound,"useFlyBag",useFlyBag) end
  -- debug.debug()

  local animateFallingIcon = true
  local animatedItemID = nil
  if showIcon ~= nil then animateFallingIcon = showIcon end
  if animateFallingIcon then animatedItemID = itemId end

  if itemFound then
    local function onAnimationFinishedCallback()
      itemFound:increaseTimePropNumber(propId, itemNum, expireTime)
      self.isPlayingTimePropAnim = false
    end    
    self.isPlayingTimePropAnim = true
    if not noAnim then
        self:addGetPropAnimation(itemFound, itemIndex, fromGlobalPosition, onAnimationFinishedCallback, animatedItemID, text)
    else
      onAnimationFinishedCallback()
    end

  else
    -- 精力瓶进背包，不要进道具栏

    if (tonumber(itemId) == 10012 or tonumber(itemId) == 10013 
      -- 后退不显示周赛中
      or (useFlyBag  and (tonumber(itemId) == 10065 or
       tonumber(itemId) == 10058 or
       tonumber(itemId) == ItemType.TIMELIMIT_48_BACK or
        tonumber(itemId) == 10002) )
      ) then


        local fromCCP = self:getBasePosition( _G.random_prop_destory_c,_G.random_prop_destory_r)

        if _G.isLocalDevelopMode then printx(0, "fromCCP",fromCCP.x,fromCCP.y,_G.random_prop_destory_c,_G.random_prop_destory_r) end

        if not noAnim then
          local anim = FlyItemsAnimation:create({{itemId=itemId,num = 1}},{flyDuration=1.5})
          anim:setScale(1.8)
          -- anim:setWorldPosition(ccp(360,720))
          anim:setWorldPosition(ccp(fromCCP.x,fromCCP.y + 250 ))
          
          anim:play()   
        end

        UserManager:getInstance():addUserPropNumber(tonumber(itemId),1)
        UserService:getInstance():addUserPropNumber(tonumber(itemId),1)
    else
        PropsModel:instance():addTimeProp(propId, itemNum, expireTime)
        local itemData = PropItemData:create(itemId)
        local index = self:addItemWithAnimation(itemData, 0)
        if index < 1 then return end

        if not noAnim then
          self:addGetPropAnimation(self["item"..index], index, fromGlobalPosition, nil, animatedItemID, text)
        end
    end
  end
end

function LeftPropList:isPlayingAddTimePropAnim()
  return self.isPlayingTimePropAnim
end

function LeftPropList:ensureItemInSight(item, duration)
	assert(item)

	local localPos = self.content:getParent():convertToNodeSpace(item:getItemCenterPosition())
	local posX = localPos.x
	local posY = localPos.y
	local originX = 0
	local firstItemX = originX + kPropListItemWidth / 2 + 20
	local lastItemX = originX + self.width - (kPropListItemWidth / 2)
	if localPos.x < firstItemX then
		posX = firstItemX
		self:updateContentWithDeltaX(firstItemX - localPos.x, duration)
	elseif localPos.x > lastItemX then
		posX = lastItemX
		self:updateContentWithDeltaX(lastItemX - localPos.x, duration)
	end
	local finalPosInWorld = self.content:getParent():convertToWorldSpace(ccp(posX, posY))

  -- printx(11, "++++++++++++  LeftPropList:addGetPropAnimation", finalPosInWorld.x, finalPosInWorld.y)
  -- printx(11, debug.traceback())
	return finalPosInWorld
end

function LeftPropList:showAddStepItem(noAni)
  local useAni = not noAni
  if not PropsModel:instance():addStepItemExist() or self:findAddMoveItem() then return end
  if not PropsModel:instance():isAddStepItemMaxUsed() then
    self:addItemWithAnimation(PropsModel:instance().addStepItems[1], 0.3, useAni)
  end
  --self:addItemWithAnimation(table.remove(self.addStepItems), 0.3, true)
end

function LeftPropList:hideAddMoveItem()
  local item = self:findAddMoveItem()
  if item and not item.isExplodeing then 
  	item:hide() 
  	self:updateVisibleMinX()
  end
end

function LeftPropList:findAddMoveItem()
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible and item:isAddMoveProp() then 
      return item 
    end
  end

  return nil
end

function LeftPropList:setItemDark( hitItemID, darked )
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible and i ~= hitItemID then item:dark(darked) end
  end
end

function LeftPropList:addFakeAllProp( value )
  -- body
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible then 
      if _G.PRODUCER_RECORD_MODE then
        item:setNumber(0)
      else
        item:setNumber(value)
      end
    end
  end
end

function LeftPropList:findOneTimeProp()
  local items = {}

  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible and item.prop:getRecentTimePropLeftTime() > 0 and item.prop:getRecentTimePropLeftTime() < 3600*4 then
        table.insert(items,{ item=item,i = i })
    end
  end

  local Priority = {
    [ItemType.ADD_FIVE_STEP] = 1,
    [ItemType.INGAME_HAMMER] = 2,
    [ItemType.INGAME_BRUSH]  = 3,
    [ItemType.INGAME_SWAP]  = 4,
    [ItemType.RANDOM_BIRD] = 5,
    [ItemType.BROOM] = 6,
    [ItemType.INGAME_REFRESH] = 7,
    [ItemType.INGAME_BACK] = 8,
    [ItemType.OCTOPUS_FORBID] = 9,
  }
  table.sort(items,function(a,b)

    if a.i == ItemType.OCTOPUS_FORBID then
      return false--章鱼冰永远最后
    end
    local aLeftTime = a.item.prop:getRecentTimePropLeftTime()
    local bLeftTime = b.item.prop:getRecentTimePropLeftTime()

    local aPropItem = PropsModel:instance().propItems[a.i]
    local bPropItem = PropsModel:instance().propItems[b.i]

    if aLeftTime == bLeftTime then
      if Priority[aPropItem.itemId] and Priority[bPropItem.itemId] then
        return Priority[aPropItem.itemId] < Priority[bPropItem.itemId]
      else
        return a.i < b.i
      end
    end

    return aLeftTime < bLeftTime
  end)

  if #items > 0 then
    return items[1].item, items[1].i
  else
    return nil, -1
  end
end

function LeftPropList:findItemByItemID( itemId )
  -- printx(11, "== LeftPropList:findItemByItemID", itemId)
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible and item:verifyItemId(itemId) then return item, i end
  end
  return nil, -1
end

function LeftPropList:recItemSize()
  local item = self.propsListView:getChildByName("i1")
  local size = item:getGroupBounds().size
  self.itemSizeRec = {width = size.width, height = size.height}
end

function LeftPropList:getPropPositions()
  self.propPositions = {}
  for i = 1, 5 do
    local item = self.propsListView:getChildByName("i"..i)
    local pos = item:getPosition()
    pos = item:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
    if i == 2 or i == 3 or i == 5 then
      pos.x = pos.x - self.itemSizeRec.width / 5
    else
      pos.x = pos.x + self.itemSizeRec.width / 5
    end
    pos.y = pos.y + self.itemSizeRec.height * 2 / 5
    table.insert(self.propPositions, pos)
  end
end

function LeftPropList:getPositionByIndex(index)
  local pos = self.propPositions[index]
  if self.content then pos.x = pos.x + self.content:getPosition().x end
  return pos
end

function LeftPropList:createPropListItem(index, itemId)
    local function onHideCallback(item)
      -- printx(11, "=========== hide call back!!!", debug.traceback())
      local moveActionTag = 1006

      local maxIndex = self:findMaxSlotIndex()
      local removedIndex = item.index

      -- printx(11, "=========== hide call back!!!", item.index, itemId, maxIndex, removedIndex)
      if maxIndex < removedIndex and removedIndex > self.propListMaxItemPerPage then
        local position = self.content:getPosition()
        local visibleX = self:getItemOffset(maxIndex)

        self.content:stopActionByTag(moveActionTag)
        local moveAction = CCEaseSineOut:create(CCMoveTo:create(0.3, ccp(visibleX, position.y)))
        moveAction:setTag(moveActionTag)
        self.content:runAction(moveAction)
      end
    end

    local function onUsedCallback( ... )
      self:checkCanNotBuyItems()
    end

    local item = nil
    local background = self.propsListView:getChildByName("background")
    if itemId == kSpringPropItemID then
      if _G.isLocalDevelopMode then printx(0, "spring: ", index, self["item"..index]) end
      item = SpringPropListItem:create(index, background:getChildByName("p"..index), self.propsListView:getChildByName("i"..index), self.propListAnimation) 
    else
      item = PropListItem:create(index, background:getChildByName("p"..index), self.propsListView:getChildByName("i"..index), self.propListAnimation)
    end

    item.onHideCallback = onHideCallback
    item.onUsedCallback = onUsedCallback

    self["item"..index] = item
    if table.exist(kPropItemDirections, index) then
       item.direction = -1
    end

    return item
end

function LeftPropList:windover(direction)
  local pt = 0
  local begin, ended, step = 1, kCurrentMaxItemInListView, 1
  if direction == -1 then begin, ended, step = kCurrentMaxItemInListView, 1, -1 end
  for i = begin, ended, step do
    local item = self["item"..i]
    if item and item.visible then       
      local delayTime = pt * 0.3
      item.animator:windover(delayTime)
      pt = pt + 1
    end
  end 
end

function LeftPropList:hasAllItemAnimationFinished()
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item:isPlayingAnimation() then return false end
  end
  return true
end

function LeftPropList:findHitItemIndex( evt )
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible and item:hitTest(evt.globalPosition) then return i end
  end
  return 0
end

function LeftPropList:findMaxSlotIndex()
  for i = kCurrentMaxItemInListView, 1, -1 do
    local item = self["item"..i]
    if item and item.visible then return i end
  end
  return 1
end

function LeftPropList:findEmptySlot()
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and not item.visible then return i end
  end
  return -1
end

function LeftPropList:getItemOffset( index )
  local itemGap = kItemGapInListView
  if self.isTightLayout then
    -- itemGap = kItemGapInListViewTight
  end
  local contentWidth = (self["item"..1].item:getContentSize().width - itemGap)
  -- 每6个道具会出现一个树枝，因此加上一个40的offset作调整, -- 现在没了（since 1.63）
  local contentMinX = self.width - contentWidth * index -- - math.ceil((index - 6) / 6) * 40
  if contentMinX > 0 then contentMinX = 0 end
  return math.max(self.minX, contentMinX)
end

function LeftPropList:updateVisibleMinX()
  self.visibleMinX = self:getItemOffset(self:findMaxSlotIndex())
end

function LeftPropList:updateContentWithDeltaX(dx, duration)
  local position = self.content:getPosition()
  local fx = position.x + dx
  if fx > self.maxX then fx = self.maxX end
  if fx < self.visibleMinX then fx = self.visibleMinX end

  self.content:stopAllActions()
  if duration and duration > 0 then
  	self.content:runAction(CCEaseSineOut:create(CCMoveTo:create(duration, ccp(fx, position.y))))
  else
    self.content:setPositionX(fx)
  end
end

function LeftPropList:updateContentPosition( evt )
  if PropsModel:instance().propItems and self:findMaxSlotIndex() > self.propListMaxItemPerPage then
    if evt.globalPosition and self.prev_position then
      local dx = evt.globalPosition.x - self.prev_position.x
      self:updateContentWithDeltaX(dx)
    end
    self.prev_position = evt.globalPosition
  end  
end

function LeftPropList:findSpringItem()
  local item = self.item3
  if item and item:is(SpringPropListItem) then
    return item
  end
  return nil
end

function LeftPropList:getSectionRevertData()

  local revertData = {}
  for i = 1, kCurrentMaxItemInListView do
    local item = self["item"..i]
    if item and item.visible and item.prop then
      table.insert( revertData , { item = item:getSectionData() , prop = item.prop:getCopy() } )
    end
  end

  return revertData
end

local ignoreRevertPropDatas = {timePropList=true,timePropNum=true,itemNum=true}
function LeftPropList:revertBySectionData(propListData)
  --printx( 1 , "LeftPropList:revertBySectionData !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
  if propListData then
    for k,v in ipairs( propListData ) do
       local item = self["item"..k]

       if item and item.prop then

        local propData = v.prop
        for k1,v1 in pairs(propData) do
          if not ignoreRevertPropDatas[k1] then
            if type(v1) == "table" then

              if not item.prop[k1] then
                item.prop[k1] = {}
              end

              for k2,v2 in pairs(v1) do

                if type(v2) == "table" then

                  if not item.prop[k1][k2] then
                    item.prop[k1][k2] = {}
                  end

                  for k3,v3 in pairs(v2) do
                    item.prop[k1][k2][k3] = v3
                  end
                else
                  item.prop[k1][k2] = v2
                end
                
              end 
              
            else
              item.prop[k1] = v1
            end
          end
        end

        local itemData = v.item
        item:revertBySectionData(itemData)
        --printx(1 , "++++++++++++++++++++++++++++++REVERT++++++++++++++++++++++++++++++" , k)
        --printx( 1 , table.tostring(v))
        item:updateItemNumber()
       end
    end
  end
end

function LeftPropList:revertItem(itemId,expireTime,useType)
  if useType == UsePropsType.EXPIRE and not expireTime then
    return
  end

  local propId = itemId
  if useType == UsePropsType.EXPIRE then
    propId = ItemType:getRealIdByTimePropId(itemId)
  end
  local itemFound, itemIndex = self:findItemByItemID(propId)
  if not itemFound and useType == UsePropsType.TEMP then
    local mappingItemId = PropsModel.kTempPropMapping[tostring(itemId)]
    if mappingItemId then itemFound, itemIndex = self:findItemByItemID(mappingItemId) end
  end

  if not itemFound then
    return
  end

  local visibleSize  = CCDirector:sharedDirector():getVisibleSize()
  local visibleOrigin  = CCDirector:sharedDirector():getVisibleOrigin()

  local centerPos = ccp(visibleOrigin.x + visibleSize.width/2,visibleOrigin.y + visibleSize.height/2)
  local itemPos = self:ensureItemInSight(itemFound, 0.3)
  centerPos = self.propListAnimation.layer:convertToNodeSpace(centerPos)
  itemPos = self.propListAnimation.layer:convertToNodeSpace(itemPos)

  local propIcon = PropListAnimation:createIcon( propId )
  propIcon:setPosition(centerPos)
  self.propListAnimation.layer:addChild(propIcon)  
  
  local seq = CCArray:create()
  seq:addObject(CCScaleTo:create(0.5, 1.8))
  -- seq:addObject(CCDelayTime:create(2))
  seq:addObject(CCScaleTo:create(0.3, 1))
    
  local function addFallingtar()
    local fallingStar = FallingStar:create(centerPos,itemPos, nil, flyFinishedCallback)
    self.propListAnimation.layer:addChild(fallingStar)
  end

  seq:addObject(CCCallFunc:create(addFallingtar))
  seq:addObject(CCEaseSineInOut:create(CCMoveTo:create(0.5, itemPos)))
  seq:addObject(CCCallFunc:create(function( ... )
    if useType == UsePropsType.NORMAL then
      itemFound:addNumber(1)
    elseif useType == UsePropsType.EXPIRE then
      itemFound:increaseTimePropNumber(itemId, 1, expireTime)
    elseif useType == UsePropsType.TEMP then
      itemFound:increaseTemporaryItemNumber(itemId, 1)
    end
    itemFound:revertUsedTimes()
    --延迟1秒退还道具使用次数后 再检测是否引导小木槌
    TimelyHammerGuideMgr.getInstance():handleGuide()
    propIcon:removeFromParentAndCleanup(true)
  end))
  
  propIcon:runAction(CCSequence:create(seq))
  
end

function LeftPropList:revertGiftItem( itemId,toGlobalPosition )
    local itemFound, itemIndex = self:findItemByItemID(itemId)
    if not itemFound then
      return
    end
    itemFound:increaseTemporaryItemNumber(itemId, -1)

    if not toGlobalPosition then
      return
    end

    local itemPos = self:ensureItemInSight(itemFound, 0.3)
    local fromPos = self.propListAnimation.layer:convertToNodeSpace(itemPos)
    local toPos = self.propListAnimation.layer:convertToNodeSpace(toGlobalPosition)

    self.propListAnimation.layer:addChild(FallingStar:create(fromPos,toPos))
end