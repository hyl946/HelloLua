
require "hecore.display.Director"

LadybugTaskAnimation = class(CocosObject)
function LadybugTaskAnimation:create()
	local ret = LadybugTaskAnimation.new(CCNode:create())
	ret:initialize()
	return ret
end

local function createCardinalSpline( group, pathName )
	local pathNode = group:getChildByName(pathName)
  	local offset = pathNode:getPosition()
  	local path = {}
  	for i,v in ipairs(pathNode.list) do
  		local p = v:getPosition()
  		path[i] = ccp(offset.x + p.x, offset.y + p.y)
  	end

  	local spine = CardinalSpline.new(path, 0.15)
  	pathNode:removeFromParentAndCleanup(true)
  	return spine
end
function LadybugTaskAnimation:initialize()
	self.scriptID = -1
	self:initializeAnimated()
end

function LadybugTaskAnimation:initializeAnimated()
	local staticAnimal = Sprite:createWithSpriteFrameName("ladybug_task/ladybug_task_icon0000")
	staticAnimal:setVisible(false)
	self.staticAnimal = staticAnimal
	
	local animal = Sprite:createWithSpriteFrameName("ladybug_task/ladybug_task_10000")
	animal:setVisible(false)
	animal:setPositionX(-200)	
	self.animal = animal

	local ladybug = ResourceManager:sharedInstance():buildGroup("ladybug_task/ladybug_task_animation")
	self.pathIn = createCardinalSpline(ladybug, "path_in")
	self.pathOut = createCardinalSpline(ladybug, "path_out")

	local panel = ladybug:getChildByName("intro")
	panel:removeFromParentAndCleanup(false)
	panel:setVisible(false)	
	self.panel = panel

	local text = Localization:getInstance():getText("lady.bug.star.announce", {n="\n"})
	local label = panel:getChildByName("label")
	label:setString(text)
	if __ANDROID then
		local size = label:getDimensions()
		label:setPositionY(label:getPositionY() + size.height * 0.1)
	end

	local function onTouchTap(evt) self:flyOut() end
	panel.hitTestPoint = function(worldPosition, useGroupTest) return true end
	panel:setTouchEnabled(true)
	panel:ad(DisplayEvents.kTouchTap, onTouchTap)
	
	self:addChild(staticAnimal)
	self:addChild(animal)
	self:addChild(panel)
end

function LadybugTaskAnimation:playCardinalSpline( path, time, onAnimationFinish )
	local spline = path
	if not spline then return end

	if self.scriptID >= 0 then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scriptID) 
		self.scriptID = -1
	end

	local beginValue, deltaValue = 0, 1

	local duration = time or 0.5
	local totalTime = 0
	local context = self
	local function onUpdateAnimation( dt )
		if context.isDisposed then 
			if context.scriptID >= 0 then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(context.scriptID) end
			return 
		end

		totalTime = totalTime + dt
		local timePercent = totalTime / duration
		local animal = context.animal

		if timePercent > 1 then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(context.scriptID) 
			context.scriptID = -1

			local finalValue = beginValue + deltaValue
			local position = spline:calculatePosition(finalValue)
			local angle = spline:calculateAngle(finalValue)
			animal:setPosition(position)
			animal:setRotation(angle + 90)
			if onAnimationFinish ~= nil then onAnimationFinish() end
		else
			local currentValue = beginValue + deltaValue * timePercent
			local position = spline:calculatePosition(currentValue)
			local angle = spline:calculateAngle(currentValue)
			animal:setPosition(position)
			animal:setRotation(angle + 90)
		end	
	end 
	self.scriptID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onUpdateAnimation,0.01,false)
end

function LadybugTaskAnimation:playFlyAnimation()
	local sharedSpriteFrameCache = CCSpriteFrameCache:sharedSpriteFrameCache()
  	local frames = {}
  	frames[1] = sharedSpriteFrameCache:spriteFrameByName("ladybug_task/ladybug_task_10000")
  	frames[2] = sharedSpriteFrameCache:spriteFrameByName("ladybug_task/ladybug_task_20000")
	self.animal:play(SpriteUtil:buildAnimate(frames, 1/18))
end

function LadybugTaskAnimation:flyIn( time , animFinishCallback)
	local duration = time or 1.5
	local function onAnimationFinish()
		self.animal:stopAllActions()
		self.animal:setRotation(6)
		self.animal:runAction(CCFadeOut:create(0.15))

		local position = self.animal:getPosition()
		self.staticAnimal:setPosition(ccp(position.x + 1, position.y))
		self.staticAnimal:setVisible(true)

		self.panel:setScale(0)
		self.panel:setVisible(true)
		self.panel:runAction(CCEaseBackOut:create(CCScaleTo:create(0.5, 1)))

		if GameGuide then GameGuide:sharedInstance():forceStopGuide() end

		if animFinishCallback then
			animFinishCallback()
		end
	end
	self:playCardinalSpline(self.pathIn, duration, onAnimationFinish)
	self:playFlyAnimation()

	self.animal:setVisible(true)
	self.animal:setScale(1.4)
	self.animal:runAction(CCScaleTo:create(duration, 1))
end

function LadybugTaskAnimation:setFlyOutFinishCallback(animFinishCallback, ...)
	assert(type(animFinishCallback) == "function")
	assert(#{...} == 0)

	self.flyOutFinishCallback = animFinishCallback
end

function LadybugTaskAnimation:flyOut()
	local duration = 1

	if GameGuide then GameGuide:sharedInstance():tryStartGuide() end
	
	local function onFlyFinish() self:removeFromParentAndCleanup(true) end
	local function onAnimationFinish()
		self.animal:stopAllActions()
		self.animal:setRotation(6)
		self.animal:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.15), CCCallFunc:create(onFlyFinish)))
		
		if self.flyOutFinishCallback then self.flyOutFinishCallback() end
	end
	self:playCardinalSpline(self.pathOut, duration, onAnimationFinish)
	self:playFlyAnimation()

	self.animal:setScale(0.85)
	self.animal:setVisible(true)
	self.animal:setOpacity(255)
	self.animal:runAction(CCScaleTo:create(duration, 1.5))
	self.staticAnimal:removeFromParentAndCleanup(true)
	self.panel:rma()
	self.panel:setTouchEnabled(false)

	local function onPanelClose() self.panel:removeFromParentAndCleanup(true) end
	self.panel:runAction(CCSequence:createWithTwoActions(CCEaseBackIn:create(CCScaleTo:create(0.2, 0)), CCCallFunc:create(onPanelClose)))
end
