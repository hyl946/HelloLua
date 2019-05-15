require 'zoo.props.PropListItem'
require 'zoo.animation.SpringFestivalEffect'
require 'zoo.animation.LaborCatEffect'
require "zoo.animation.ElephantAnimation"
require "zoo.props.SpringPropItemAnimator"

SpringPropListItem = class(PropListItem)

function SpringPropListItem:ctor()
  self.direction = 1
  self.visible = true
  self.disabled = false
  self.usedTimes = 0
  self.maxUsetime = 0
  self.onTemporaryItemUsed = nil --function
  self.isTouchEnabled = true
  self.isExplodeing = false --正在播放使用动画
  self.timePropNum = 0 -- 限时道具数量
  self.timePropList = nil
  self.energy = 0
  self.step = 0

  self.isOnceUsed =  false
  self.animator = SpringPropItemAnimator:create(self)
end

function SpringPropListItem:create(index, pedicle, item, propListAnimation, iconSize)
    local ret = SpringPropListItem.new()
    ret:buildUI(index, pedicle, item, iconSize)
    ret.propListAnimation = propListAnimation
    ret.controller = propListAnimation.controller
    return ret
end

function SpringPropListItem:setItemTouchEnabled( v )
  self.isTouchEnabled = v
end

function SpringPropListItem:dispose()
  if self.animateID then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.animateID) end
  self.animateID = nil
  self.propListAnimation = nil
end

function SpringPropListItem:buildUI(index, pedicle, item, iconSize)
  self.index = index
  self.pedicle = pedicle
  self.item = item

  local contentSize = item:getGroupBounds().size
  item:setContentSize(CCSizeMake(contentSize.width, contentSize.height))
  
  local item_number = item:getChildByName("item_number")
  local item_numberPos = item_number:getPosition()
  self.labelOffsetX = item_numberPos.x
  self.labelOffsetY = item_numberPos.y
  item_number.offsetX = item_numberPos.x
  item_number:setAlignment(kCCTextAlignmentCenter)
  self.item_number = item_number

  self.beginRotation = item:getRotation()
  local itemPosition = item:getPosition()
  self.beginPosition = {x=itemPosition.x, y=itemPosition.y}

  pedicle:setVisible(false)
  item:setVisible(false)

  local bg_normal = item:getChildByName("bg_normal")
  local bg_selected = item:getChildByName("bg_selected")
  local icon_add = item:getChildByName("icon_add")
  local prop_disable_icon = item:getChildByName("prop_disable_icon")

  bg_normal:setVisible(false)

  local prop_disable_size = prop_disable_icon:getContentSize()
  local prop_disable_pos = prop_disable_icon:getPosition()
  prop_disable_icon:setVisible(false)
  prop_disable_icon:setCascadeOpacityEnabled(false)
  prop_disable_icon:setAnchorPoint(ccp(0.5, 0.5))

  item:getChildByName("t_bg_label"):setVisible(false)
  item:getChildByName("name_label"):setVisible(false)
  item:getChildByName("red_bg_label"):setVisible(false)
  item:getChildByName("time_limit_flag"):setVisible(false)

  local normalSize = bg_normal:getContentSize()
  local normalPos = bg_normal:getPosition()

  bg_selected:setVisible(false)
  icon_add:setVisible(false)

  --self.iconSize = iconSize
  self:initIconSize()

  self.center = {x = self.iconSize.x + self.iconSize.width/2, y = self.iconSize.y - self.iconSize.height /2, r = normalSize.width/2}
end

function SpringPropListItem:getItemCenterPosition()
  local item = self.item
  local iconSize = self.iconSize
  local x = iconSize.x + iconSize.width/2
  local y = iconSize.y - iconSize.height/2
  local position = ccp(x, y)
  position = item:convertToWorldSpace(position)
  return position
  -- return item:getParent():convertToNodeSpace(position)
end

function SpringPropListItem:hide()
  self.visible = false
  
  self.pedicle:setVisible(false)

  self.item:setVisible(false)
  self.item:stopAllActions()
    
  self.prop = nil
  
  if self.icon then self.icon:removeFromParentAndCleanup(true) end
  self.icon = nil
  
  self.isAnimateHint = false
  self.isAnimating = false
  self.isHintMode = false
  self.isPlayShowAnimation = false
  self.darked = false
  self.focused = false
  if self.animateID then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.animateID) end
  self.animateID = nil

  if self.onHideCallback ~= nil then self.onHideCallback(self) end
end

function SpringPropListItem:updateItemNumber()

  local item = self.item
  local icon_add = item:getChildByName("icon_add")
  local bg_label = item:getChildByName("bg_label")  
  local t_bg_label = item:getChildByName("t_bg_label")
  local red_bg_label = item:getChildByName("red_bg_label")
  local timeLimitFlag = item:getChildByName("time_limit_flag")

  icon_add:setVisible(false)
  bg_label:setVisible(false)
  red_bg_label:setVisible(false)
  t_bg_label:setVisible(false)
  self.item_number:setVisible(false)
  timeLimitFlag:setVisible(false)

end

function SpringPropListItem:isAddMoveProp()
  return false
end

function SpringPropListItem:setTemporaryMode(v)
end

function SpringPropListItem:hintTemporaryMode()
end

function SpringPropListItem:useWithType(itemId, propType)
end

function SpringPropListItem:show(delayTime, newIcon, initDisable)
  self.visible = true
  self.isPlayShowAnimation = true
  
    local delay = delayTime + self.index * 0.1
    local pedicle = self.pedicle
    local item = self.item
  local bg_normal = item:getChildByName("bg_normal")
  local bg_label = item:getChildByName("bg_label")
  local icon_add = item:getChildByName("icon_add")

  local itemId = self.prop and self.prop.itemId or 0
  self.itemName = Localization:getInstance():getText("prop.name."..itemId)
  item:getChildByName("name_label"):setString(self.itemName)

  self:setTemporaryMode(false)
  self:updateItemNumber()

  self.item_number:stopAllActions()
  self.item_number:setOpacity(255)

  bg_label:stopAllActions()
  bg_label:setOpacity(255)

  icon_add:stopAllActions()
  icon_add:setOpacity(255)

  bg_normal:stopAllActions()
  bg_normal:setScale(1)
  bg_normal:setRotation(0)
  bg_normal:setOpacity(255)

  if newIcon then
    pedicle:stopAllActions()
    pedicle:setOpacity(0)
    pedicle:setVisible(true)
    pedicle:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCFadeIn:create(0.1)))
  end

  local function onAnimationFinished()
    self.isPlayShowAnimation = false
  end
  local animationTime = 0.15 + math.random()*0.15
  local startAngle = (30 + math.random()*30) * -self.direction
  local scaleTo = CCScaleTo:create(animationTime, 1.1)
  local rotatTo = CCRotateTo:create(animationTime * 10, self.beginRotation)
  local array = CCArray:create()
  array:addObject(CCDelayTime:create(delay))
  array:addObject(CCShow:create())
  array:addObject(CCEaseSineOut:create(scaleTo))
  array:addObject(CCEaseQuarticBackOut:create(CCScaleTo:create(animationTime, 1), 33, -106, 126, -67, 15))
  array:addObject(CCCallFunc:create(onAnimationFinished))

  item:stopAllActions()
  item:setVisible(false)
  item:setScale(0)
  item:setRotation(startAngle)
  item:setPosition(ccp(self.beginPosition.x, self.beginPosition.y))
  item:runAction(CCSequence:create(array))
  item:runAction(CCEaseElasticOut:create(rotatTo))

  self.startAngle = self.beginRotation

  if newIcon then
    if self.icon then self.icon:removeFromParentAndCleanup(true) end
    local icon = self:buildItemIcon()
    if icon then
        icon:setCascadeOpacityEnabled(true)
        icon:setCascadeColorEnabled(true)
        icon:setPosition(ccp(self.iconSize.x + 40,  5))-- self.iconSize.y))-- - 37))
        item:addChildAt(icon, 4)
      if initDisable then
        item:setOpacity(130)
        self.disabled = true
        self.reasonType = 1
      end
    end
    self.icon = icon
  else
    local icon = self.icon
    if icon then
      icon:stopAllActions() -- If some times icon hide, can fix by stopAllActions
      icon:setVisible(true)
      icon:setOpacity(255)
      icon:setPosition(ccp(self.iconSize.x + self.iconSize.width/2, 0))--self.iconSize.y))-- - self.iconSize.height/2))
    end    
  end
end

function SpringPropListItem:confirm(itemId, usedPositionGlobal)
end

function SpringPropListItem:playMaxUsedAnimation(tipDesc)
end
function SpringPropListItem:use(forceUsedCallback, dontCallback, forceUse)

    local function localCallback()
        if forceUsedCallback then forceUsedCallback() end
        
        if not dontCallback and self.controller and self.controller.springItemCallback then
            self.controller.springItemCallback()
        end

        self.usedTimes = self.usedTimes + 1
    end

    local function playMusic()
      GamePlayMusicPlayer:playEffect(GameMusicType.kElephantBoss)
    end

    local percentage = self.percent or 0
    if percentage >= 1 then
        setTimeOut(function() playMusic() end, 0.25)
        -- （五一)使用技能
        -- DcUtil:UserTrack({ category='activity', sub_category='labourday_click_skill' })
        local operator = 1
        if forceUse then operator = 2 end
        DcUtil:UserTrack({ category='activity', sub_category='weeklyrace_winter_2016_use_skill' , level_id = self.propListAnimation.levelId, operator = operator}, true)
        
        --LaborCatEffect:playItemUseAnimation(localCallback)
        -- SpringFestivalEffect:playFireworkAnimation(localCallback)
        ElephantAnimation:playUseAnimation(localCallback)
        self:setEnergy(0, true)
        self:stopHint()
        --self:playGolden(false)
        return true
    end

    local content = ResourceManager:sharedInstance():buildGroup('bagItemTipContent_ingame')
    local desc = content:getChildByName('desc')
    local title = content:getChildByName('title')

    title:setString(Localization:getInstance():getText("weeklyrace.summer.drink.title"))
    local originSize = desc:getDimensions()
    desc:setDimensions(CCSizeMake(originSize.width, 0))
    desc:setString(Localization:getInstance():getText("weeklyrace.summer.drink.desc", {n1 = self:getTotalEnergy() -self.energy, br = '\n'}))

    local tip = BubbleTip:create(content, kSpringPropItemID, 5)
    tip:show(self.icon:getGroupBounds())

    -- CommonTip:showTip(Localization:getInstance():getText("activity.GuoQing.mainPanel.tip.13"), "negative")
    return false
end

function SpringPropListItem:getTotalEnergy()
    if self.usedTimes + 1< #SpringFireworkTotal then
        return SpringFireworkTotal[self.usedTimes + 1]
    else
        return SpringFireworkTotal[#SpringFireworkTotal]
    end
end

function SpringPropListItem:shake()
  local animationTimeA, animationTimeB = 0.05, 0.02
  local array = CCArray:create()
  array:addObject(CCRotateBy:create(animationTimeA, -4))
  array:addObject(CCRotateBy:create(animationTimeA*2, 8))
  array:addObject(CCRotateBy:create(animationTimeA, -4))
  array:addObject(CCRotateBy:create(animationTimeB, -2))
  array:addObject(CCRotateBy:create(animationTimeB, 2))
  self.item:setRotation(self.startAngle)
  self.item:runAction(CCSequence:create(array))
end

function SpringPropListItem:windover(delayTime)
  local item = self.item
  if not item or item.isDisposed then return end

  delayTime = delayTime or 0
  local animationTimeA, animationTimeB = 0.2, 0.3
  local array = CCArray:create()
  array:addObject(CCDelayTime:create(delayTime))
  array:addObject(CCRotateTo:create(animationTimeA, -3))
  array:addObject(CCRotateTo:create(animationTimeA * 2, 3))
  array:addObject(CCRotateTo:create(animationTimeA * 1.5, -2))
  array:addObject(CCRotateTo:create(animationTimeA, 2))
  array:addObject(CCRotateTo:create(animationTimeB, -1))
  array:addObject(CCRotateTo:create(animationTimeB, 1))
  array:addObject(CCRotateTo:create(animationTimeB, 0))
  
  self.item:setRotation(self.startAngle)
  self.item:stopActionByTag(10250)

  local windAction = CCSequence:create(array)
  windAction:setTag(10250)
  self.item:runAction(windAction)
end

function SpringPropListItem:focus( enabled, confirm )
end

function SpringPropListItem:lock(v)

end

function SpringPropListItem:stopHint()
    self.isAnimateHint = false
    self.isHintMode = false
  self.item:stopAllActions()
  self.item:setScale(1)
end

function SpringPropListItem:hint(delayTime)
  local context = self
  local item = context.item
  if context.isAnimateHint then 
    if _G.isLocalDevelopMode then printx(0, "warning: hint animation is already playing.") end
    return 
  end
  context.isAnimateHint = true
  context.isHintMode = true

  local function onHintCallback()
    if not PublishActUtil:isGroundPublish() then 
      local item = context.item
      if item and item.refCocosObj then
        local sequence = CCArray:create()
        sequence:addObject(CCScaleTo:create(0.12, 1.05, 0.6))
        sequence:addObject(CCScaleTo:create(0.24, 0.7, 1.05))
        sequence:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.25, 1), CCEaseBackOut:create(CCMoveBy:create(0.25, ccp(0, 10)))))
        sequence:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.25, 1.05, 1), CCMoveBy:create(0.25, ccp(0, -10))))
        sequence:addObject(CCScaleTo:create(0.1, 1.05, 0.7))
        sequence:addObject(CCScaleTo:create(0.1, 1))
        sequence:addObject(CCDelayTime:create(0.5))
        --item:stopAllActions()
        item:setPosition(ccp(context.beginPosition.x, context.beginPosition.y))
        item:runAction(CCRepeatForever:create(CCSequence:create(sequence)))
      end
    end
  end

  item:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(onHintCallback)))
end

function SpringPropListItem:tmpAnimation(delayTime)
end

function SpringPropListItem:pushPropAnimation(delayTime)
  local context = self
  local item = context.item
  if context.isAnimateHint then 
    if _G.isLocalDevelopMode then printx(0, "warning: hint animation is already playing.") end
    return 
  end
  context.isAnimateHint = true
  context.isHintMode = true

  local function onHintCallback()
    if not PublishActUtil:isGroundPublish() then 
      local item = context.item
      if item and item.refCocosObj then
        local arr = CCArray:create()
        arr:addObject(CCScaleTo:create(0.6, 0.96, 1.1))
        arr:addObject(CCScaleTo:create(0.6, 0.98, 0.85))
        arr:addObject(CCScaleTo:create(0.6, 0.99, 1.1))
        arr:addObject(CCScaleTo:create(0.6, 1, 0.85))
        arr:addObject(CCScaleTo:create(0.6, 0.99, 1.1))
        arr:addObject(CCScaleTo:create(0.6, 0.98, 0.85))

        local action = CCRepeatForever:create(CCSequence:create(arr))
        item:setPosition(ccp(context.beginPosition.x, context.beginPosition.y))
        item:runAction(action)
      end
    end
  end
  self.hint = self.pushPropAnimation
  item:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(onHintCallback)))
end

function SpringPropListItem:isItemRequireConfirm()
    return false
end

function SpringPropListItem:verifyItemId( itemId )
     return false
end

function SpringPropListItem:playIncreaseAnimation()
end

function SpringPropListItem:increaseItemNumber( itemId, itemNum )
end

function SpringPropListItem:_updateTemporaryMode()
end

function SpringPropListItem:increateTemporaryItemNumber( itemId, itemNum )
end

function SpringPropListItem:explode( animationTime, usedPositionGlobal )
end

function SpringPropListItem:bubble(delayTime)
end

function SpringPropListItem:hitTest( position )
  local isTouchDisaable = self.darked or self.isPlayShowAnimation or not self.isTouchEnabled 
    if isTouchDisaable then return false end

    local center = self.center
    position = self.item:convertToNodeSpace(position)
    local dx = position.x - center.x
    local dy = position.y - center.y
    return (dx * dx + dy * dy) < center.r * center.r
end

function SpringPropListItem:setDisableReason(reasonType)
end

function SpringPropListItem:setEnable()
end

function SpringPropListItem:enableUnlimited(enable)
    self.isUnlimited = true
end

function SpringPropListItem:buildItemIcon()
    local juice_bottle = ElephantAnimation:createJuiceBottle(0)
    juice_bottle:getChildByName("glow"):setVisible(false)
    self:setEnergy(0, false)

    return juice_bottle
end

function SpringPropListItem:buildItemIconByStep(step)
    local juice_bottle = ElephantAnimation:createJuiceBottle(step)
    juice_bottle:getChildByName("glow"):setVisible(false)

    return juice_bottle
end

function SpringPropListItem:setEnergy(energy, playAnim, theCurMoves)
  self.energy = energy
  if _G.isLocalDevelopMode then printx(0, "usedTimes: ", self.usedTimes) end
  if _G.isLocalDevelopMode then printx(0, "total energy: ", self:getTotalEnergy()) end
  self:setPercent(self.energy / self:getTotalEnergy(), playAnim, theCurMoves)
end

local percentages = {0.2, 0.4, 0.6, 0.8, 1.0}
local function getStepByPercentage(percentage)
    local p = percentage or 0
    for i,v in ipairs(percentages) do
        if p < v then
            return i-1
        end
    end

    return #percentages
end

function SpringPropListItem:moveToCenter()
        --[[local winSize = Director:sharedDirector():getWinSize()

        local worldPoint = self.icon:convertToWorldSpace(ccp(self.icon:getGroupBounds().size.width, self.icon:getGroupBounds().size.height))

        if _G.isLocalDevelopMode then printx(0, "offset: ", worldPoint.x - winSize.width/2) end
        --move the icon to the center of the screen
        local moveAct = CCMoveBy:create(0.3, ccp(winSize.width/2-worldPoint.x, 0))
        local complete = CCCallFunc:create(function() end)]]--

        self.propListAnimation.content:runAction(CCMoveTo:create(0.2, ccp(0,0)))
end

function SpringPropListItem:setPercent(percent, playAnim, theCurMoves)
    if percent > 1 then percent = 1 end
    if percent < 0 then percent = 0 end

    if _G.isLocalDevelopMode then printx(0, "@@@@@@@@@@@@@@@@@@@@@@percentage: ", percent) end

    local new_step = getStepByPercentage(percent)
    local cur_step = getStepByPercentage(self.percent)
    if new_step > cur_step then
        self.icon = ElephantAnimation:juiceChangeAnimation(self.item, self.icon, new_step)
        if percent >= 1 and theCurMoves~=5 then
            --move to the center
            self:moveToCenter()
        end
    end

    self.percent = percent

    if self.percent >= 1 then
      --self:pushPropAnimation(0)
    else
      self.animator:windover(0)
    end
end

function SpringPropListItem:playGolden(enable)
  if enable then
    -- local action = CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.6), CCFadeOut:create(0.6)))
    -- self.item_gold:runAction(action)
    self.item_gold:setVisible(true)
    self.item_full:setVisible(false)
  else
    self.item_full:setVisible(true)
    self.item_gold:setVisible(false)
    -- self.item_gold:stopAllActions()
    -- self.item_gold:runAction(CCFadeOut:create(0.3))
  end
end
