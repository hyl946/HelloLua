require "hecore.display.Director"

kFlowers = {
  flowerSeed = "flowerSeed",

  flowerStarGray = "normalFlowerAnimGray",
  flowerStar0 = "normalFlowerAnim0",
  flowerStar1 = "normalFlowerAnim1",
  flowerStar2 = "normalFlowerAnim2",
  flowerStar3 = "normalFlowerAnim3",
  flowerStar4 = "normalFlowerAnim4",

  hiddenFlowerGray = "hiddenFlowerAnimGray",
  hiddenFlower0 = "hiddenFlowerAnim0",
  hiddenFlower1 = "hiddenFlowerAnim1",
  hiddenFlower2 = "hiddenFlowerAnim2",
  hiddenFlower3 = "hiddenFlowerAnim3",

  jumpedFlower = 'jumpedFlower',
  askForHelpFlower = 'askForHelpFlower',
}

kFlowerStars = {
  normalStar1 = "flowerStar1",
  normalStar2 = "flowerStar2",
  normalStar3 = "flowerStar3",
  normalStar4 = "flowerStar4",

  hiddenStar1 = "hiddenFlowerStar1",
  hiddenStar2 = "hiddenFlowerStar2",
  hiddenStar3 = "hiddenFlowerStar3",
}

kFlowerShineCircleAdjust = {x = 0, y = 10}

Flowers = class()

function Flowers:buildGlowEffect(flower)
  local node = Layer:create()
	node.name = "glow flower"
  node:setTouchEnabled(true)

  local shadowSprite = Sprite:createWithSpriteFrameName("flowerShadow0000")
  shadowSprite:setAnchorPoint(ccp(0.5,1))
  shadowSprite:setPosition(ccp(4, -1))
  
  local flowerSprite = Sprite:createWithSpriteFrameName(flower.."0000")
  local flowerSize = flowerSprite:getContentSize()
  flowerSprite:setAnchorPoint(ccp(0.5,1))

  local offsety = 0
  if flower == kFlowers.flowerStar1 or flower == kFlowers.flowerStar0 then offsety = -10 end

  local shadowGlow = Sprite:createWithSpriteFrameName("flowerShineCircle0000")
  shadowGlow:setPosition(ccp(3, -flowerSize.height / 2 - 0 + offsety)) 
  shadowGlow:setScaleY(1.65)
  shadowGlow:setVisible(false)
  
  local glowSprite = Sprite:createWithSpriteFrameName("flowerShineCircle0000")
  glowSprite:setPosition(ccp(3, -flowerSize.height / 2 - 15 + offsety))  
  
  local animationTime = 1.2
  local fadeIn = CCEaseSineIn:create(CCFadeIn:create(animationTime))
  local fadeOut = CCEaseSineOut:create(CCFadeOut:create(animationTime))
  local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
  glowSprite:runAction(CCRepeatForever:create(seq))
  
  --hit area
  local hitArea = CocosObject:create()
  hitArea:setContentSize(CCSizeMake(flowerSize.width, flowerSize.height))
  hitArea.name = kHitAreaObjectName
  hitArea:setPosition(ccp(-flowerSize.width/2, -flowerSize.height)) --because of flowerSprite's AnchorPoint, we need to reset the position
  
  local backgroundLayer = CocosObject:create()
  backgroundLayer:setPosition(ccp(-4, -flowerSize.height/2 - 10))
  --back star
  local background = Sprite:createWithSpriteFrameName("flowerStarOpenBackground0000")
  background:setVisible(false)
  backgroundLayer:addChild(background)

  local foregroundLayer = CocosObject:create()
  foregroundLayer:setPosition(ccp(-4, -flowerSize.height/2 - 10))

  local openLayout = CocosObject:create()
  local container = CocosObject:create()

  node:addChild(hitArea)
  node:addChild(backgroundLayer)
  node:addChild(openLayout)
  node:addChild(container)
  node:addChild(foregroundLayer)

  container:addChild(shadowSprite)
  container:addChild(flowerSprite)
  container:addChild(shadowGlow)
  container:addChild(glowSprite)

  node.bloom = function( self )
    self.isBloomAnimating = true

    container:setScale(1)
    container:stopAllActions()

    local function onScaleFinished()
      backgroundLayer:stopAllActions()
      background:stopAllActions()
      background:setVisible(false)

      foregroundLayer:removeChildren(true)

      if self:hasEventListenerByName(Events.kComplete) then
          self:dispatchEvent(Event.new(Events.kComplete, self))
      end
    end
    
    local scaleAnimation = CCArray:create()
    scaleAnimation:addObject(CCScaleTo:create(0.125, 1.2, 0.8)) --scale begin
    scaleAnimation:addObject(CCEaseSineIn:create(CCScaleTo:create(0.125, 1.7, 1))) --big
    scaleAnimation:addObject(CCEaseSineOut:create(CCScaleTo:create(0.135, 0.92, 1))) --small
    scaleAnimation:addObject(CCEaseSineOut:create(CCScaleTo:create(0.135, 1))) --back to 1
    scaleAnimation:addObject(CCDelayTime:create(0.3))
    scaleAnimation:addObject(CCCallFunc:create(onScaleFinished))
    container:runAction(CCSequence:create(scaleAnimation))

    --open animation
    openLayout:removeChildren(true)

    local function onRepeatFinished()
      openLayout:removeChildren(true)
      background:stopAllActions()
      background:runAction(CCFadeOut:create(0.35))
    end

    local flowerOpenSprite = Sprite:createWithSpriteFrameName("flowerOpenStar0000")
    flowerOpenSprite:setAnchorPoint(ccp(0.5,1))
    flowerOpenSprite:setPosition(ccp(-4, 42-flowerSize.height))
    flowerOpenSprite:setOpacity(0)
    flowerOpenSprite:setScale(1.7)
    openLayout:addChild(flowerOpenSprite)

    local openAnimation = CCArray:create()
    openAnimation:addObject(CCFadeIn:create(0.125))
    openAnimation:addObject(CCRepeat:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("flowerOpenStar%04d", 0, 15), 1/30), 1))
    openAnimation:addObject(CCCallFunc:create(onRepeatFinished))
    flowerOpenSprite:runAction(CCSequence:create(openAnimation))

    --background
    background:setVisible(true)
    background:setOpacity(0)
    background:setScale(1.3)
    background:runAction(CCFadeIn:create(0.35))
    background:setPosition(ccp(2, 0))
    backgroundLayer:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 50)))

    --foreground
    foregroundLayer:removeChildren(true)
    local shiningStars = Sprite:createWithSpriteFrameName("shiningStars0000")
    shiningStars:setAnchorPoint(ccp(0.5,0.5))
    shiningStars:setPosition(ccp(13, -8))
    shiningStars:runAction(CCRepeatForever:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("shiningStars%04d", 0, 28), 1/30)))
    foregroundLayer:addChild(shiningStars)

    local arr = CCArray:create()
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -18)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 15)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -12)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 9)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, -4)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    arr:addObject(CCEaseSineOut:create(CCRotateTo:create(0.1, 2)))
    arr:addObject(CCEaseSineIn:create(CCRotateTo:create(0.1, 0)))
    if flower ~= kFlowers.flowerStar0 then self:runAction(CCSequence:create(arr)) end
  end 

  local function onTouchBegin( evt )
    if node.isBloomAnimating then return end

    shadowGlow:setVisible(true)
    shadowGlow:setOpacity(5)
    shadowGlow:stopAllActions()
    shadowGlow:runAction(CCFadeIn:create(0.3))
  end 
  local function onTouchEnd( evt )
    shadowGlow:setVisible(false)
  end 
  node:addEventListener(DisplayEvents.kTouchBegin, onTouchBegin)
  node:addEventListener(DisplayEvents.kTouchEnd, onTouchEnd)

  return node
end

local function buildSeedNode( isHidden )
  local node = Layer:create()
  node.name = "open flower"
  node:setTouchEnabled(false)

  local spriteName = "normalFlowerAnim0"
  -- if isHidden then spriteName = "hiddenFlower0" end
  local flowerSprite = Sprite:createWithSpriteFrameName(spriteName.."0000")
  local flowerSize = flowerSprite:getContentSize()
  flowerSprite:setAnchorPoint(ccp(0.5,1))
  flowerSprite:setOpacity(0)
  flowerSprite:runAction(CCFadeIn:create(0.3))

  local glowSprite = Sprite:createWithSpriteFrameName("flowerShineCircle0000")
  glowSprite:setPosition(ccp(-4, -flowerSize.height / 2 - 30))  
  glowSprite:setScaleY(1.5)
  glowSprite:setScaleX(1.2)
  
  local animationTime = 1
  local fadeIn = CCEaseSineIn:create(CCFadeIn:create(animationTime))
  local fadeOut = CCEaseSineOut:create(CCFadeOut:create(animationTime))
  local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
  glowSprite:runAction(CCRepeatForever:create(seq))

  node:addChild(flowerSprite)
  node:addChild(glowSprite)
  return node
end 

function Flowers:buildOpenEffect(isHidden)
  local node = Layer:create()
  node.name = "open flower"
  node:setTouchEnabled(false)

  --seed sprite
  local shadowSprite = Sprite:createWithSpriteFrameName("flowerShadow0000")
  shadowSprite:setAnchorPoint(ccp(0.5,1))
  shadowSprite:setPosition(ccp(4, -3))
  
  local flowerSprite = Sprite:createWithSpriteFrameName(kFlowers.flowerSeed.."0000")
  local flowerSize = flowerSprite:getContentSize()
  flowerSprite:setAnchorPoint(ccp(0.5,1))
  
  --hit area
  local hitArea = CocosObject:create()
  hitArea:setContentSize(CCSizeMake(flowerSize.width, flowerSize.height))
  hitArea.name = kHitAreaObjectName
  hitArea:setPosition(ccp(-flowerSize.width/2, -flowerSize.height)) --because of flowerSprite's AnchorPoint, we need to reset the position
  
  local foregroundLayer = CocosObject:create()
  foregroundLayer:setPosition(ccp(-4, -flowerSize.height/2 - 10))

  local openLayout = CocosObject:create()
  local container = CocosObject:create()

  node:addChild(hitArea)
  node:addChild(openLayout)
  node:addChild(container)
  node:addChild(foregroundLayer)

  local outTime = 0.2
  local spawnOut = CCSpawn:createWithTwoActions(CCScaleTo:create(outTime, 1), CCFadeOut:create(outTime))
  flowerSprite:runAction(CCSequence:createWithTwoActions(CCEaseSineIn:create(CCScaleTo:create(0.4, 1.52)), spawnOut))

  --grown-up sprite
  local up = buildSeedNode(isHidden)
  up:setPosition(ccp(-2, 0))
  up:setVisible(false)

  local function onUpFinished()
    if node:hasEventListenerByName(Events.kComplete) then
        node:dispatchEvent(Event.new(Events.kComplete, node))
    end
  end
    
  local upAnimation = CCArray:create()
  upAnimation:addObject(CCDelayTime:create(0.25))
  upAnimation:addObject(CCShow:create())
  upAnimation:addObject(CCScaleTo:create(0.125, 1.55, 1.4))
  upAnimation:addObject(CCEaseBounceOut:create(CCScaleTo:create(0.55, 1)))
  upAnimation:addObject(CCDelayTime:create(0.4))
  upAnimation:addObject(CCCallFunc:create(onUpFinished))
  up:runAction(CCSequence:create(upAnimation))

  --star
  local shiningStars = Sprite:createWithSpriteFrameName("shiningStars0000")
  shiningStars:setAnchorPoint(ccp(0.5,0.5))
  shiningStars:setPosition(ccp(5, -6))
  
  foregroundLayer:addChild(shiningStars)

  foregroundLayer:setVisible(false)
  local function onForegroundAnimation()
    foregroundLayer:setVisible(true)
    shiningStars:runAction(CCRepeatForever:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("shiningStars%04d", 0, 28), 1/30)))
  end
  foregroundLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.55), CCCallFunc:create(onForegroundAnimation)))

  container:addChild(shadowSprite)
  container:addChild(up)
  container:addChild(flowerSprite)

  return node
end