require "hecore.display.Director"
require "hecore.display.ParticleSystem"

kTileBirdAnimation = { kNormal = 1, kSelect = 2, kDestroy = 3 }
TileBird = class(CocosObject)

local kCharacterAnimationTime = 1/30
local kBirdContentSize = 65

function TileBird:toString()
	return string.format("TileBird [%s]", self.name and self.name or "nil");
end

function TileBird:create()
  local node = TileBird.new(CCNode:create()) 
	node.name = "TileBird"

  local effectSprite = Sprite:createWithSpriteFrameName("bird_bg_effect_0000")
  node.effectSprite = effectSprite
  node:addChild(effectSprite)

  local frames = SpriteUtil:buildFrames("bird_bg_effect_%04d", 0, 20)
  local animate = SpriteUtil:buildAnimate(frames, 1/30)
  effectSprite:play(animate)

  local mainSprite = Sprite:createWithSpriteFrameName("bird_normal_0000")
  node.mainSprite = mainSprite
  node:addChild(mainSprite)

	return node
end

function TileBird:play(animation)
  if animation == kTileBirdAnimation.kNormal then self:playNormalAnimation()
  elseif animation == kTileBirdAnimation.kSelect then self:playSelectedAnimation()
  elseif animation == kTileBirdAnimation.kDestroy then self:playDestroyAnimation() end
end

function TileBird:playNormalAnimation()
  self.mainSprite:stopAllActions()
  self.mainSprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("bird_normal_0000"))
end

function TileBird:playSelectedAnimation()
  if not self.mainSprite.refCocosObj then return end 
  self.mainSprite:stopAllActions()

  local context = self
  local function playAnim()
    local frames = SpriteUtil:buildFrames("bird_selected_%04d", 0, 35)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    context.mainSprite:play(animate, 0, 1)
  end

  local sequenceAction = CCSequence:createWithTwoActions(CCCallFunc:create(playAnim), CCDelayTime:create(2))
  self.mainSprite:runAction(CCRepeatForever:create(sequenceAction))
end

local function createBirdDestroyEffect()  
  local node = CocosObject:create()
  local galaxy = ParticleSystemQuad:create("particle/fast_galaxy.plist")
  galaxy:setAutoRemoveOnFinish(true)
  galaxy:setPosition(ccp(0,0))
  node:addChild(galaxy)

  local backSprite = Sprite:createWithSpriteFrameName("bird_galaxy0000")
  backSprite:setScale(0.35)
  backSprite:runAction(CCScaleTo:create(0.5, 1.1))
  backSprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 50)))
  node:addChild(backSprite)

  local pop = ParticleSystemQuad:create("particle/star_pop.plist")
  pop:setAutoRemoveOnFinish(true)
  pop:setPosition(ccp(0,0))
  node:addChild(pop)

  local frontSprite = Sprite:createWithSpriteFrameName("bird_star0000")
  frontSprite:setScale(0.35)
  frontSprite:runAction(CCScaleTo:create(0.5, 1.3))
  frontSprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 150)))
  node:addChild(frontSprite)

  local pointEffectSprite = Sprite:createWithSpriteFrameName("bird_effect_point0000")
  pointEffectSprite:setScale(1.2)
  pointEffectSprite:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("bird_effect_point%04d", 0, 10), kCharacterAnimationTime))
  node:addChild(pointEffectSprite)

  local function onAnimationFinished()
    if backSprite then backSprite:runAction(CCFadeOut:create(0.5)) end
    if frontSprite then frontSprite:runAction(CCFadeOut:create(0.5)) end
    if pointEffectSprite then
      pointEffectSprite:stopAllActions()
      pointEffectSprite:runAction(CCFadeOut:create(0.5))
    end
  end

  node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCCallFunc:create(onAnimationFinished)))
  return node
end

local function create2BirdDestroyEffect()  
  local node = CocosObject:create()
  local galaxy = ParticleSystemQuad:create("particle/fast_galaxy.plist")
  galaxy:setPosition(ccp(0,0))
  galaxy:setDuration(-1)
  node:addChild(galaxy)

  local backSprite = Sprite:createWithSpriteFrameName("bird_galaxy0000")
  backSprite:setScale(0.35)
  backSprite:runAction(CCScaleTo:create(0.5, 1.1))
  backSprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 50)))
  node:addChild(backSprite)

  local pop = ParticleSystemQuad:create("particle/star_pop.plist")
  pop:setPosition(ccp(0,0))
  pop:setDuration(-1)
  node:addChild(pop)

  local frontSprite = Sprite:createWithSpriteFrameName("bird_star0000")
  frontSprite:setScale(0.35)
  frontSprite:runAction(CCScaleTo:create(0.5, 1.3))
  frontSprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 150)))
  node:addChild(frontSprite)

  local pointEffectSprite = Sprite:createWithSpriteFrameName("bird_effect_point0000")
  pointEffectSprite:setScale(1.2)
  pointEffectSprite:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("bird_effect_point%04d", 0, 10), kCharacterAnimationTime))
  node:addChild(pointEffectSprite)

  node.finish = function ()
    if backSprite then backSprite:runAction(CCFadeOut:create(0.5)) end
    if frontSprite then frontSprite:runAction(CCFadeOut:create(0.5)) end
    if pointEffectSprite then
      pointEffectSprite:stopAllActions()
      pointEffectSprite:runAction(CCFadeOut:create(0.5))
    end
    pop:stopSystem()
    galaxy:stopSystem()
  end
  --node:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCCallFunc:create(onAnimationFinished)))
  return node
end

function TileBird:stop2BirdDestroyAnimation()
end

function TileBird:play2BirdDestroyAnimation()
end

function TileBird:play2BirdExplodeAnimation(explodePositionList, onAnimationCallback)
  local effectLayer = CocosObject:create()
  
  local function onStartExplode()
    local animateNum = #explodePositionList
    local function onAnimationFinished()
      animateNum = animateNum - 1
      if animateNum == 0 then 
        effectLayer:removeFromParentAndCleanup(true)
        if type(onAnimationCallback) == "function" then onAnimationCallback() end
      end
    end
    for i, position in ipairs(explodePositionList) do
      position = effectLayer:convertToNodeSpace(position)
      effectLayer:addChild(Firebolt:create(ccp(0,0), position, 0.5, onAnimationFinished))
    end
  end
  local effectArray = CCArray:create()
  effectArray:addObject(CCDelayTime:create(0.0))
  effectArray:addObject(CCCallFunc:create(onStartExplode))
  effectLayer:runAction(CCSequence:create(effectArray))
  effectLayer:setScale(0.5)
  return effectLayer
end

function TileBird:buildAndRunDestroyAction(actionTarget)
  if actionTarget then
    local position = self:getPosition()
    local radius = kBirdContentSize*2 + kBirdContentSize * 0.5    ----去掉了随机函数，影响最后结果
    local action = CCEaseSineInOut:create(HELens3D:create(0.8, CCSizeMake(15,10), ccp(position.x, position.y), radius))

    local function onAnimationFinished()
      if actionTarget and actionTarget.refCocosObj then
        actionTarget:setGrid(nil)
      end
    end

    actionTarget:stopAllActions()
    actionTarget:runAction(CCSequence:createWithTwoActions(action, CCCallFunc:create(onAnimationFinished)))
  end
end

function TileBird:buildBirdBirdDestroyEffect(birdNode, toPos, isMasterBird, callback)
  local node = CocosObject:create()
  node:addChild(birdNode)

  local function onAnimationFinished()
    node:removeFromParentAndCleanup(true)
    if callback then callback() end
  end

  local function onBirdTogether()
    if isMasterBird then
      if birdNode.effectSprite then birdNode.effectSprite:setVisible(false) end
      if not birdNode.mainSprite then birdNode.mainSprite = Sprite:createEmpty() end --星星瓶会使用这个特效
      local mainSprite = birdNode.mainSprite

      local mainSpriteActSeq = CCArray:create()
      mainSpriteActSeq:addObject(CCDelayTime:create(22*kCharacterAnimationTime))
      mainSpriteActSeq:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(4*kCharacterAnimationTime, 255*0.34), CCScaleTo:create(4*kCharacterAnimationTime, 1.86)))
      mainSpriteActSeq:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(5*kCharacterAnimationTime, 0), CCScaleTo:create(5*kCharacterAnimationTime, 0.84)))
      mainSpriteActSeq:addObject(CCCallFunc:create(onAnimationFinished))

      mainSprite:runAction(CCSequence:create(mainSpriteActSeq))
    else
      onAnimationFinished()
    end
  end

  local actionSeq = CCArray:create()
  actionSeq:addObject(CCDelayTime:create(3*kCharacterAnimationTime))
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(5*kCharacterAnimationTime, toPos), CCScaleTo:create(5*kCharacterAnimationTime, 1.5)))
  actionSeq:addObject(CCCallFunc:create(onBirdTogether))

  birdNode:runAction(CCSequence:create(actionSeq))

  return node
end

function TileBird:createBirdBirdDestroyBackEffectForever()
  local node = CocosObject:create()

  local effectSprite, animate = SpriteUtil:buildAnimatedSprite(kCharacterAnimationTime, "bird_back_effect_%04d", 0, 30)
  effectSprite:play(animate)
  effectSprite:setVisible(false)

  effectSprite:setScale(1.04/1.5)
  effectSprite:setOpacity(0.64*255)

  local actionSeq = CCArray:create()
  -- actionSeq:addObject(CCDelayTime:create(5*kCharacterAnimationTime))
  actionSeq:addObject(CCShow:create())
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(2*kCharacterAnimationTime, 1.48/1.5), CCFadeTo:create(2*kCharacterAnimationTime, 255*0.78)))
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(2*kCharacterAnimationTime, 2.19/1.5), CCFadeTo:create(2*kCharacterAnimationTime, 255)))
  actionSeq:addObject(CCScaleTo:create(9*kCharacterAnimationTime, 3.24/1.5))
  -- actionSeq:addObject(CCScaleTo:create(5*kCharacterAnimationTime, 3.72/1.5))

  effectSprite:runAction(CCSequence:create(actionSeq))

  node.effectSprite = effectSprite
  node:addChild(effectSprite)

  node.playDisappear = function()
    TileBird:deleteBirdBirdDestroyBackEffectForever(node)
  end

  return node
end

function TileBird:deleteBirdBirdDestroyBackEffectForever(node)
  if not node or not node.effectSprite then return end

  local effectSprite = node.effectSprite

  local function onAnimationFinished()
    node:removeFromParentAndCleanup(true)
  end

  local actionSeq = CCArray:create()
  actionSeq:addObject(CCScaleTo:create(5*kCharacterAnimationTime, 3.72/1.5))
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(6*kCharacterAnimationTime, 2.24/1.5), CCFadeTo:create(6*kCharacterAnimationTime, 255*0.86)))
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(6*kCharacterAnimationTime, 0.15/1.5), CCFadeTo:create(6*kCharacterAnimationTime, 0)))
  actionSeq:addObject(CCCallFunc:create(onAnimationFinished))
 
  effectSprite:runAction(CCSequence:create(actionSeq))
end

-----创建永久的鸟爆炸背景特效-----
function TileBird:createBirdDestroyEffectForever(scaleTo)
  scaleTo = scaleTo or 1.47

  local node = CocosObject:create()
  node.name = "TileBird"

  local effectSprite, animate = SpriteUtil:buildAnimatedSprite(kCharacterAnimationTime, "bird_back_effect_%04d", 0, 30)
  effectSprite:setScale(1/1.5)
  effectSprite:play(animate)

  local actionSeq = CCArray:create()
  actionSeq:addObject(CCScaleTo:create(4*kCharacterAnimationTime, 1.32/1.5))
  actionSeq:addObject(CCScaleTo:create(2*kCharacterAnimationTime, 1.44/1.5))
  actionSeq:addObject(CCScaleTo:create(20*kCharacterAnimationTime, 2/1.5))
  actionSeq:addObject(CCScaleTo:create(6*kCharacterAnimationTime, 2.2/1.5))
  effectSprite:runAction(CCSequence:create(actionSeq))

  node.effectSprite = effectSprite
  node:addChild(effectSprite)

  node.playDisappear = function()
    TileBird:deleteBirdDestroyEffect(node)
  end

  return node
end

-----消除永久的鸟爆炸特效-------
function TileBird:deleteBirdDestroyEffect(effectnode)
    local theNode = effectnode

    local function onAnimationFinished()
      theNode:removeFromParentAndCleanup(true);        ----将自己从父节点删除
    end

    local effectSprite = effectnode.effectSprite

    local actionSeq = CCArray:create()
    actionSeq:addObject(CCScaleTo:create(7*kCharacterAnimationTime, 1.9/1.5))
    actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(9*kCharacterAnimationTime, 0.2), CCFadeTo:create(9*kCharacterAnimationTime, 50)))
    
    actionSeq:addObject(CCCallFunc:create(onAnimationFinished))

    effectSprite:runAction(CCSequence:create(actionSeq))
end

--------消除鸟的动画------------
function TileBird:playDestroyAnimation()
  self.effectSprite:stopAllActions()
  self.effectSprite:setVisible(false)

  self.mainSprite:stopAllActions()
  -- self.mainSprite:setVisible(false)
  self.mainSprite:runAction(CCHide:create())

  local function onAnimationFinished()
    self:stopAllActions()
    self:dp(Event.new(Events.kComplete, kTileBirdAnimation.kDestroy, self))
    self:removeFromParentAndCleanup(true)
  end
  self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(onAnimationFinished)))
end

function TileBird:buildBirdNormalDestroyAnimation(notRemove, callback)
  local sprite = Sprite:createWithSpriteFrameName("bird_selected_0000")
  local frames = SpriteUtil:buildFrames("bird_selected_%04d", 0, 35)
  local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

  local actionCount = 0
  local function onBirdAnimationFinished()
    actionCount = actionCount - 1
    if actionCount < 1 then
      if not notRemove then
        sprite:removeFromParentAndCleanup(true)
      end
      if callback then callback() end
    end
  end
 
  actionCount = actionCount + 1
  sprite:play(CCSequence:createWithTwoActions(CCDelayTime:create(6*kCharacterAnimationTime), animate), 0, 1, onBirdAnimationFinished)
  
  local actionSeq = CCArray:create()
  actionSeq:addObject(CCDelayTime:create(6*kCharacterAnimationTime))
  actionSeq:addObject(CCScaleTo:create(4*kCharacterAnimationTime, 1.41))
  actionSeq:addObject(CCDelayTime:create(20*kCharacterAnimationTime))
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(6*kCharacterAnimationTime, 1.77), CCFadeTo:create(6*kCharacterAnimationTime, 255*0.34)))
  actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(5*kCharacterAnimationTime, 0.97), CCFadeTo:create(5*kCharacterAnimationTime, 0)))
  actionSeq:addObject(CCCallFunc:create(onBirdAnimationFinished))

  actionCount = actionCount + 1
  sprite:runAction(CCSequence:create(actionSeq))

  return sprite
end

function TileBird:buildBirdSpecialDestroyAnimation(notRemove, callback)
  local node = Sprite:createEmpty()

  local function onAnimationFinished()
    if not notRemove then
      node:removeFromParentAndCleanup(true)
    end
    if callback then callback() end
  end

  local birdSprite, animate = SpriteUtil:buildAnimatedSprite(kCharacterAnimationTime, "bird_selected_%04d", 0, 35)
  birdSprite:play(animate, 0, 1)

  local birdActionSeq = CCArray:create()
  birdActionSeq:addObject(CCDelayTime:create(3*kCharacterAnimationTime))
  birdActionSeq:addObject(CCScaleTo:create(15 * kCharacterAnimationTime, 1.69))
  birdActionSeq:addObject(CCFadeOut:create(0))
  birdSprite:runAction(CCSequence:create(birdActionSeq))

  node:addChild(birdSprite)

  local oriScale = 0.6
  local whiteSprite = Sprite:createWithSpriteFrameName("bird_white_effect_0000")
  whiteSprite:setOpacity(0)
  whiteSprite:setScale(oriScale)
  
  local whiteActionSeq = CCArray:create()
  local scaleAct = CCScaleTo:create(15 * kCharacterAnimationTime, oriScale*1.69)
  local fadeInAct = CCEaseSineIn:create(CCFadeIn:create(15 * kCharacterAnimationTime))
  whiteActionSeq:addObject(CCDelayTime:create(3*kCharacterAnimationTime))
  whiteActionSeq:addObject(CCSpawn:createWithTwoActions(scaleAct, fadeInAct))
  whiteActionSeq:addObject(CCScaleTo:create(3*kCharacterAnimationTime, oriScale*1.38))
  whiteActionSeq:addObject(CCScaleTo:create(8*kCharacterAnimationTime, oriScale*0.56))
  whiteActionSeq:addObject(CCCallFunc:create(onAnimationFinished))
  whiteSprite:runAction(CCSequence:create(whiteActionSeq))

  node:addChild(whiteSprite)

  return node
end
