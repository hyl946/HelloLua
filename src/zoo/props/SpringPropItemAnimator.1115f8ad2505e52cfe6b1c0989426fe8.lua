require "zoo.props.PropItemAnimator"

SpringPropItemAnimator = class(PropItemAnimator)

function SpringPropItemAnimator:shake()
  local animationTimeA, animationTimeB = 0.05, 0.02
  local array = CCArray:create()
  array:addObject(CCRotateBy:create(animationTimeA, -4))
  array:addObject(CCRotateBy:create(animationTimeA*2, 8))
  array:addObject(CCRotateBy:create(animationTimeA, -4))
  array:addObject(CCRotateBy:create(animationTimeB, -2))
  array:addObject(CCRotateBy:create(animationTimeB, 2))
  self.propItem.item:setRotation(self.propItem.startAngle)
  self.propItem.item:runAction(CCSequence:create(array))
end

function SpringPropItemAnimator:windover(delayTime)
  local item = self.self.propItem
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
  
  self.propItem.item:setRotation(self.propItem.startAngle)
  self.propItem.item:stopActionByTag(10250)

  local windAction = CCSequence:create(array)
  windAction:setTag(10250)
  self.propItem.item:runAction(windAction)
end

function SpringPropItemAnimator:pushPropAnimation(delayTime)
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

function SpringPropItemAnimator:hint(delayTime)
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