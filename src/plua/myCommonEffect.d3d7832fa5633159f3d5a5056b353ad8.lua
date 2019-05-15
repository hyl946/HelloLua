
require "plua.myAction"
--
myCommonEffect = class()
function myCommonEffect:reset()
	
end

function myCommonEffect:buildRainbowLineEffect(batchNode)
	local node = Sprite:createEmpty()
	
	local function remove()
		if node then 
			node:removeFromParentAndCleanup(true)
			node = nil
		end
	end
	
	local action = myAction.myCreate(node, remove)
	myActionManager.getInstance():addAction(action)
	return node
end

function myCommonEffect:buildWrapLineEffect(batchNode)
 	return self:buildRainbowLineEffect(batchNode)
end

function myCommonEffect:buildWrapEffect(batchNode, delayTime)
	return self:buildRainbowLineEffect(batchNode)
end

function myCommonEffect:buildLineEffect(batchNode)
	return self:buildRainbowLineEffect(batchNode)
end


function myCommonEffect:buildBonusLineEffect()
	return self:buildRainbowLineEffect()
end

function myCommonEffect:buildRequireSwipePanel()
	return self:buildRainbowLineEffect()
end


function myCommonEffect:buildSpecialEffectTitle( effectType )
	return self:buildRainbowLineEffect()
end

function myCommonEffect:buildBonusEffectXXL(onAnimationFinished)
	local node = Sprite:createEmpty()
	
	local function remove()
		if onAnimationFinished then
			onAnimationFinished()
		end
		
		if node then 
			node:removeFromParentAndCleanup(true)
			node = nil
		end
	end
	
	local action = myAction.myCreate(node, remove)
	myActionManager.getInstance():addAction(action)
	return node
end

function myCommonEffect:buildBonusEffect(onAnimationFinished)
	local node = Sprite:createEmpty()
	
	local function remove()
		if onAnimationFinished then
			onAnimationFinished()
		end
		
		if node then 
			node:removeFromParentAndCleanup(true)
			node = nil
		end
	end
	
	local action = myAction.myCreate(node, remove)
	myActionManager.getInstance():addAction(action)
	return node
end

function myCommonEffect:buildGetPropLightAnimWithoutBg(showForever)
	return self:buildRainbowLineEffect()
end

function myCommonEffect:buildBirdEffectFlyAnim(specialType, fromPos, toPos, duration, arriveCallback, finishCallback)
	local node = Sprite:createEmpty()
	
	local function remove()
		if arriveCallback then
			arriveCallback()
		end
		
		if finishCallback then
			finishCallback()
		end
		
		if node then 
			node:removeFromParentAndCleanup(true)
			node = nil
		end
	end
	
	local action = myAction.myCreate(node, remove)
	myActionManager.getInstance():addAction(action)
	return node
end

function myCommonEffect:buildMixSpecialAnim(specialType, targetPos, mixPosList, callback)
	local node = Sprite:createEmpty()
	
	local function remove()
		if callback then
			callback()
		end
		
		if node then 
			node:removeFromParentAndCleanup(true)
			node = nil
		end
	end
	
	local action = myAction.myCreate(node, remove)
	myActionManager.getInstance():addAction(action)
	return node
end

function myCommonEffect:buildGetPropLightAnim( text , showForever )
	return self:buildRainbowLineEffect()
end

--
-- FallingStar ---------------------------------------------------------
--
myFallingStar = class(Layer)

function myFallingStar:buildUI(useWhiteColor, noParticle)
  local sprite = Sprite:createWithSpriteFrameName(textureKey)
  self:addChild(sprite)
  self.sprite = sprite
end

function myFallingStar:create(from, to, animationCallbackFunc, flyFinishedCallback, useWhiteColor, isHalloween, noParticle)
  local ret = myFallingStar.new()
  ret:initLayer()
  ret:buildUI(useWhiteColor, noParticle)
  ret:fly(from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, noParticle)
  return ret
end

function myFallingStar:fly( from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, noParticle)
  
	local function onActionFinished()
		if animationCallbackFunc ~= nil then 
			animationCallbackFunc() 
		end
		
		if flyFinishedCallback then
			flyFinishedCallback()
		end
		
		self:removeFromParentAndCleanup(true)
	end

	local action = myAction.myCreate(self, onActionFinished)
	myActionManager.getInstance():addAction(action)
end


--
-- Firebolt ---------------------------------------------------------
--
myFirebolt = class(Layer)

function myFirebolt:buildUI()
	local sprite = Sprite:createWithSpriteFrameName(textureKey)
	self:addChild(sprite)
	self.sprite = sprite
end

function myFirebolt:create(from, to, duration, animationCallbackFunc)
  local ret = myFirebolt.new()
  ret:initLayer()
  ret:buildUI()
  ret:fly(from, to, duration, animationCallbackFunc)
  return ret
end

function myFirebolt:fly( from, to, duration, animationCallbackFunc )
	local function onActionFinished()
		if animationCallbackFunc ~= nil then 
			animationCallbackFunc() 
		end
		
		self:removeFromParentAndCleanup(true)
	end

	local action = myAction.myCreate(self, onActionFinished)
	myActionManager.getInstance():addAction(action)
end


myBonusFallingStar = class(Layer)

function myBonusFallingStar:create(from, to, animationCallbackFunc, flyFinishedCallback)
	-- FrameLoader:loadImageWithPlist("flash/bonus_effects.plist")
	local node = myBonusFallingStar.new()
	node:init(from, to, animationCallbackFunc, flyFinishedCallback)
	return node
end

function myBonusFallingStar:init(from, to, animationCallbackFunc, flyFinishedCallback)
	local function onActionFinished()
		if animationCallbackFunc ~= nil then 
			animationCallbackFunc() 
		end
		
		if flyFinishedCallback then
			flyFinishedCallback()
		end
		
		self:removeFromParentAndCleanup(true)
	end

	local action = myAction.myCreate(self, onActionFinished)
	myActionManager.getInstance():addAction(action)
end


--[[function myBonusFallingStar:buildLightAnime(time)
	local light = Sprite:createWithSpriteFrameName("bonus_effects_light") 
	return light
end

function myBonusFallingStar:buildStarAnime(type, time, moveBy)
	local star = Sprite:createWithSpriteFrameName(string.format("bonus_effects_star%02d", type))
	return star
end--]]


function myBonusFallingStar:dispose()
	Layer.dispose(self)
end

--
-- BezierFallingStar 贝塞尔曲线飞星星 ---------------------------------------------------------
--
myBezierFallingStar = class(myFallingStar)

function myBezierFallingStar:create(from, to, animationCallbackFunc, flyFinishedCallback, useWhiteColor, isHalloween, direction)
	local ret = myBezierFallingStar.new()
	ret:initLayer()
	ret:buildUI(useWhiteColor)
	ret:fly(from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, direction)
	return ret
end

function myBezierFallingStar:fly( from, to, animationCallbackFunc, flyFinishedCallback, isHalloween, direction)
	local function onActionFinished()
		if animationCallbackFunc ~= nil then 
			animationCallbackFunc() 
		end
		
		if flyFinishedCallback then
			flyFinishedCallback()
		end
		
		self:removeFromParentAndCleanup(true)
	end

	local action = myAction.myCreate(self, onActionFinished)
	myActionManager.getInstance():addAction(action)
end

CommonEffect = myCommonEffect
BonusFallingStar = myBonusFallingStar
BezierFallingStar = myBezierFallingStar
Firebolt = myFirebolt
FallingStar = myFallingStar