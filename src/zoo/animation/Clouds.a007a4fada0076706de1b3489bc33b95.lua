require "hecore.display.Director"

Clouds = class()

local function createCloudAnimation(w, h, time, move)
  local cloudSprite = Sprite:createWithSpriteFrameName("home_clouds0000")
  local cloudSize = cloudSprite:getContentSize()
  cloudSprite:setScaleX(w/cloudSize.width)
  cloudSprite:setScaleY(h/cloudSize.height)

  cloudSprite.savePos = function( self )
    if not self or self.isDisposed then return end
  	local p = self:getPosition()
  	self.ox = p.x
  	self.oy = p.y
  end
  cloudSprite.restorePos = function( self )
    if not self or self.isDisposed then return end
  	if self.ox ~= nil and self.oy ~= nil then
  		self:setPosition(ccp(self.ox, self.oy))
  	end
  end
  cloudSprite.wait = function ( self )
    if not self or self.isDisposed then return end
  	self:stopAllActions()
  	self:setOpacity(255)
  	self:restorePos()
  	local moveLeft = CCMoveBy:create(time, ccp(-move, 0))
  	local moveRight = CCMoveBy:create(time, ccp(move, 0))
  	self:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(moveLeft,moveRight)))
  end

  cloudSprite:wait()
  
  return cloudSprite
end

local function createFadeOutAnimation( sprite, fadeToLeft , animFinishCallback)
	assert(not animFinishCallback or type(animFinishCallback) == "function")
  if not (sprite and sprite.refCocosObj) then return end
  
	sprite:stopAllActions()
	local move = 1
	if fadeToLeft then move = -1 end
	local moveIn = CCMoveBy:create(0.3, ccp(move * 10, 0))
	local outAnimationTime = 1
	local moveOut = CCMoveBy:create(outAnimationTime, ccp(-1 * move * 100, 0))
	local fadeOut = CCSpawn:createWithTwoActions(moveOut, CCFadeOut:create(outAnimationTime))

	-- Anim Finish Callback
	local function callback()
		sprite:removeFromParentAndCleanup(true)

		if animFinishCallback then
			animFinishCallback()
		end
	end
	local callbackAction = CCCallFunc:create(callback)

	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(moveIn)
	actionArray:addObject(fadeOut)
	actionArray:addObject(callbackAction)

	local seq = CCSequence:create(actionArray)
	sprite:runAction(seq)

	--sprite:runAction(CCSequence:createWithTwoActions(moveIn, fadeOut))
end 

local function createCloud(w, h)
  local cloudSprite = Sprite:createWithSpriteFrameName("home_clouds0000")
  local cloudSize = cloudSprite:getContentSize()
  cloudSprite:setScaleX(w/cloudSize.width)
  cloudSprite:setScaleY(h/cloudSize.height)
  
  return cloudSprite
end

function Clouds:buildStatic()

  local cloudSprite1 = createCloudAnimation(500, 235, 2.7, 30)
  cloudSprite1:setPosition(ccp(-162, 36))
  cloudSprite1:savePos()

  local cloudSprite2 = createCloudAnimation(555, 262, 2.4, 29)
  cloudSprite2:setPosition(ccp(-20, 0))
  cloudSprite2:setScaleX(-1)
  cloudSprite2:savePos()

  local cloudSprite3 = createCloudAnimation(730, 345, 3, -32)
  cloudSprite3:setPosition(ccp(114, 20))
  cloudSprite3:savePos()

  -- Create The Node
  local texture = cloudSprite1:getTexture()
  local node = Sprite:createEmpty()
  node:setTexture(texture)
  
  node:addChild(cloudSprite1)
  node:addChild(cloudSprite2)
  node:addChild(cloudSprite3)

  node.stopFloatAnim = function(self)
    if not self or self.isDisposed then return end
    cloudSprite1:stopAllActions()
    cloudSprite2:stopAllActions()
    cloudSprite3:stopAllActions()
  end

  node.startFloatAnim = function(self)
    assert(not animFinishCallback or type(animFinishCallback) == "function")
    if not self or self.isDisposed then return end
    cloudSprite1:wait()
    cloudSprite2:wait()
    cloudSprite3:wait()
  end
  node:stopFloatAnim()

end

function Clouds:buildWait()
  local cloudSprite1 = createCloudAnimation(500, 235, 2.7, 30)
  cloudSprite1:setPosition(ccp(-162, 36))
  cloudSprite1:savePos()

  local cloudSprite2 = createCloudAnimation(555, 262, 2.4, 29)
  cloudSprite2:setPosition(ccp(-20, 0))
  cloudSprite2:setScaleX(-1)
  cloudSprite2:savePos()

  local cloudSprite3 = createCloudAnimation(730, 345, 3, -32)
  cloudSprite3:setPosition(ccp(114, 20))
  cloudSprite3:savePos()

  -- Create The Node
  local texture = cloudSprite1:getTexture()
  local node = Sprite:createEmpty()
  node:setTexture(texture)
  
  node:addChild(cloudSprite1)
  node:addChild(cloudSprite2)
  node:addChild(cloudSprite3)

  node.wait = function( self )
    if not self or self.isDisposed then return end
  	cloudSprite1:wait()
  	cloudSprite2:wait()
  	cloudSprite3:wait()
  end

  node.fadeOut = function( self , animFinishCallback)
	  assert(not animFinishCallback or type(animFinishCallback) == "function")
    if not self or self.isDisposed then return end
  	createFadeOutAnimation(cloudSprite1, false, animFinishCallback)
  	createFadeOutAnimation(cloudSprite2, false)
  	createFadeOutAnimation(cloudSprite3, true)
  end
  return node
end

function Clouds:buildLock( )
  local background = Sprite:createWithSpriteFrameName("lockedCloudOpenBackground0000")
  background:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 50)))

  local icon = Sprite:createWithSpriteFrameName("locked_cloud_ico0000")
  icon:setAnchorPoint(ccp(0.5,0.38))
  icon:setPosition(ccp(0, -20))

  local star = Sprite:createWithSpriteFrameName("home_lock_star0000")
  star:setOpacity(0)
  star:setPosition(ccp(-25, 10))

  local texture = background:getTexture()

  --local foregroundLayer = CocosObject:create()
  local foregroundLayer = Sprite:createEmpty()
  foregroundLayer:setTexture(texture)

  local node = Sprite:createEmpty()
  node:setTexture(texture)

  --node:addChild(backgroundLayer)
  node:addChild(background)
  node:addChild(icon)
  node:addChild(star)
  node:addChild(foregroundLayer)

  node.wait = function( self )
    if not self or self.isDisposed then return end
    if not background or background.isDisposed then return end
  	background:stopAllActions()
  	background:setOpacity(0)
  	background:setScale(0.1)
  	local animationTime = 1
    local fadeAnimation = CCArray:create()
    fadeAnimation:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(animationTime), CCScaleTo:create(animationTime, 1.5)))
    fadeAnimation:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(animationTime), CCScaleTo:create(animationTime, 0.1)))
    background:runAction(CCRepeatForever:create(CCSequence:create(fadeAnimation)))

    if not icon or icon.isDisposed then return end
    icon:stopAllActions()
    icon:setOpacity(255)
    icon:setScale(1)
    icon:setRotation(0)
    local rotateTime = 0.05
  	local rotateAngel = 22

  	local seq = CCSequence:createWithTwoActions(CCRotateTo:create(rotateTime, -rotateAngel), CCRotateTo:create(rotateTime*2, rotateAngel))
  	local rep = CCRepeat:create(seq, 3)
  	local shakeAnimation = CCArray:create()
  	shakeAnimation:addObject(CCDelayTime:create(1))
  	shakeAnimation:addObject(rep)
  	shakeAnimation:addObject(CCRotateTo:create(rotateTime, 0))
  	shakeAnimation:addObject(CCDelayTime:create(1))
  	icon:runAction(CCRepeatForever:create(CCSequence:create(shakeAnimation)))

    if not star or star.isDisposed then return end
  	star:stopAllActions()
  	star:setOpacity(0)
    local starTime = 0.5
    local starAnimation = CCArray:create()
    starAnimation:addObject(CCDelayTime:create(2 + rotateTime*2*3))

    local fadeInAnim = CCArray:create()
    fadeInAnim:addObject(CCFadeIn:create(starTime))
    fadeInAnim:addObject(CCRotateBy:create(starTime, 100))
    fadeInAnim:addObject(CCScaleTo:create(starTime, 2))
    starAnimation:addObject(CCSpawn:create(fadeInAnim))

    local fadeOutAnim = CCArray:create()
    fadeOutAnim:addObject(CCFadeOut:create(starTime))
    fadeOutAnim:addObject(CCRotateBy:create(starTime, 100))
    fadeOutAnim:addObject(CCScaleTo:create(starTime, 1))
    starAnimation:addObject(CCSpawn:create(fadeOutAnim))

    star:runAction(CCRepeatForever:create(CCSequence:create(starAnimation)))

    if not foregroundLayer or foregroundLayer.isDisposed then return end
    foregroundLayer:removeChildren(true)
  end

  node.fadeOut = function( self )
    if not self or self.isDisposed then return end
    if not background or not icon or not star or background.isDisposed or icon.isDisposed or star.isDisposed then return end
  	background:stopAllActions()
  	icon:stopAllActions()
  	star:stopAllActions()

  	local animationTime = 0.35
  	local backIn = CCSpawn:createWithTwoActions(CCFadeIn:create(animationTime), CCScaleTo:create(animationTime, 2))
  	local backOut = CCSpawn:createWithTwoActions(CCFadeOut:create(animationTime/2), CCScaleTo:create(animationTime/2, 2.3))
  	background:runAction(CCSequence:createWithTwoActions(backIn, backOut))

  	icon:setRotation(0)
  	local iconIn = CCSpawn:createWithTwoActions(CCFadeIn:create(animationTime), CCEaseBackIn:create(CCScaleTo:create(animationTime, 1.5)))
  	local iconOut = CCSpawn:createWithTwoActions(CCFadeOut:create(animationTime/1.5), CCScaleTo:create(animationTime/1.5, 1.6))
  	icon:runAction(CCSequence:createWithTwoActions(iconIn, iconOut))

  	local function onAnimationCompleted()
  		foregroundLayer:removeChildren(true)

  		if self:hasEventListenerByName(Events.kComplete) then
			self:dispatchEvent(Event.new(Events.kComplete, self))

		  end
  	end 
  	local starAnimation = CCArray:create()
  	starAnimation:addObject(CCFadeOut:create(0.3))
  	starAnimation:addObject(CCDelayTime:create(0.35))
  	starAnimation:addObject(CCCallFunc:create(onAnimationCompleted))
  	star:runAction(CCSequence:create(starAnimation))

  	foregroundLayer:removeChildren(true)
  	local shiningStars = Sprite:createWithSpriteFrameName("lockedCloudShiningStars0000")
    shiningStars:setAnchorPoint(ccp(0.5,0.5))
    shiningStars:runAction(CCRepeatForever:create(SpriteUtil:buildAnimate(SpriteUtil:buildFrames("lockedCloudShiningStars%04d", 0, 28), 1/30)))
    foregroundLayer:addChild(shiningStars)
  end

  node.stop = function( self )
    if not self or self.isDisposed then return end
    if not background or not icon or not star or background.isDisposed or icon.isDisposed or star.isDisposed then return end
    background:stopAllActions()
    icon:stopAllActions()
    star:stopAllActions()
  end

  node:wait()
  return node
end

local movableCloudsOfSpecial = {'fg_cloud1', 'fg_cloud2', 'fg_cloud3', 'fg_cloud4', 'fg_cloud5', 'bg_cloud1', 'bg_cloud2', 'bg_cloud3', 'bg_cloud4'}
function Clouds:initSpecialClouds(node)
      local function attachFunction(ui, time, move)
          ui.savePos = function( self )
              if not self or self.isDisposed then return end
              local p = self:getPosition()
              self.ox = p.x
              self.oy = p.y
          end
          ui.restorePos = function( self )
              if not self or self.isDisposed then return end
              if self.ox ~= nil and self.oy ~= nil then
                  self:setPosition(ccp(self.ox, self.oy))
              end
          end
          ui.wait = function ( self )
              if not self or self.isDisposed then return end
              self:stopAllActions()
              self:setOpacity(255)
              self:restorePos()
              local moveLeft = CCMoveBy:create(time, ccp(-move, 0))
              local moveRight = CCMoveBy:create(time, ccp(move, 0))
              self:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(moveLeft,moveRight)))
          end
      end
      for k, v in pairs(movableCloudsOfSpecial) do
          local ui = node:getChildByName(v)
          local time = 2.8+k*0.05
          local move = (30+k*5)*((k%2-0.5)*2)
          attachFunction(ui, time, move)
      end
end

function Clouds:initSpecialCloudsStaticState(node)
    node.stopFloatAnim = function(self)
        if not self or self.isDisposed then return end
        for k, v in pairs(movableCloudsOfSpecial) do
            local ui = node:getChildByName(v)
            ui:stopAllActions()
        end
    end

    node.startFloatAnim = function(self)
        if not self or self.isDisposed then return end
        for k, v in pairs(movableCloudsOfSpecial) do
            local ui = node:getChildByName(v)
            ui:wait()
        end
    end
end

function Clouds:initSpecialCloudsWaitState(node)
    node.wait = function( self )
      if not self or self.isDisposed then return end
      for k, v in pairs(movableCloudsOfSpecial) do
          local ui = self:getChildByName(v)
          ui:wait()
      end
    end
    local function createFadeOutAnimationPlanet(ui)
      ui:runAction(CCFadeOut:create(1))
    end

    node.fadeOut = function( self , animFinishCallback)
      assert(not animFinishCallback or type(animFinishCallback) == "function")
      if not self or self.isDisposed then return end
      for k, v in pairs(movableCloudsOfSpecial) do
          local ui = self:getChildByName(v)
          createFadeOutAnimationPlanet(ui)
      end
      self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function() if animFinishCallback then animFinishCallback() end end)))
    end
end

function Clouds:__getStaticPlanet()
  local node = ResourceManager:sharedInstance():buildBatchGroup('sprite', 'planet_unlock_cloud')
  Clouds:initSpecialClouds(node)
  return node
end

function Clouds:buildStaticPlanet()
    local node = Clouds:__getStaticPlanet()
    Clouds:initSpecialCloudsStaticState(node)
    return node
end

function Clouds:buildWaitPlanet()
  local node = Clouds:__getStaticPlanet()
  Clouds:initSpecialClouds(node)
  Clouds:initSpecialCloudsWaitState(node)
  return node
end


function Clouds:__getStaticStellar()
    local node = ResourceManager:sharedInstance():buildBatchGroup('sprite', 'stellar_unlock_cloud')
    Clouds:initSpecialClouds(node)
    return node
end

function Clouds:buildStaticStellar()
    local node = Clouds:__getStaticStellar()
    Clouds:initSpecialCloudsStaticState(node)
    return node
end

function Clouds:buildWaitStellar()
    local node = Clouds:__getStaticStellar()
    Clouds:initSpecialClouds(node)
    Clouds:initSpecialCloudsWaitState(node)
  return node
end

-------------------------------------------------------------------------------


function Clouds:buildNewCloudAnimation()
  local node = Layer:create()

  if not armatureHasLoaded then 
    armatureHasLoaded = true 
    FrameLoader:loadArmature("skeleton/world_scene_animation")
  end

  local lock_bg = ArmatureNode:create("worldSceneAreaCloud/CloudBG")
  local lock_fg = ArmatureNode:create("worldSceneAreaCloud/CloudFG")

  node.bg = lock_bg
  node.fg = lock_fg

  

  node:addChild(lock_bg)
  node:addChild(lock_fg)

  node.stopFloatAnim = function(self)
    node.bg:stop()
    node.fg:stop()
  end

  node.startFloatAnim = function(self)
    node.bg:play("normal" , 0)
    node.fg:play("normalWithLock" , 0)
  end

  return node
end
