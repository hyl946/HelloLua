require "hecore.display.Director"

MaxEnergyAnimation = class(CocosObject)
function MaxEnergyAnimation:create()
	local ret = MaxEnergyAnimation.new(CCNode:create())
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
function MaxEnergyAnimation:initialize()
	self.scriptID = -1

	local animation = ResourceManager:sharedInstance():buildGroup("max_energy_animation")
	self:addChild(animation)

	local mask = animation:getChildByName("mask")
	local maskIndex = animation:getChildIndex(mask)
	local colors = animation:getChildByName("max_energy_colors")

	mask:removeFromParentAndCleanup(false)
	colors:removeFromParentAndCleanup(false)

	local clipping		= ClippingNode.new(CCClippingNode:create(mask.refCocosObj))
	clipping:setAlphaThreshold(0.5)
	clipping:addChild(colors)
	self:addChildAt(clipping, 0)

	local maskSize = mask:getContentSize()
	local colorSize = colors:getContentSize()
	local scaleX = colors:getScaleX()
	local width = colorSize.width*scaleX
	local moveX = width - maskSize.width
	local colorY = colors:getPositionY()
	local colorX = colors:getPositionX()
	if __use_small_res then colorY = colorY - 4 end
	local seq = CCSequence:createWithTwoActions(CCMoveTo:create(1, ccp(0, colorY)), CCMoveTo:create(0, ccp(-moveX,colorY)))
	colors:setPosition(ccp(-moveX, colorY))
	colors:runAction(CCRepeatForever:create(seq))

	local path = createCardinalSpline(animation, "path")
	local star = animation:getChildByName("star")
	local starSize = star:getContentSize()
	local starPos = star:getPosition()
	star:setAnchorPoint(ccp(0.5, 0.5))
	star:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 100)))
	star:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleTo:create(0.3, 0.6), CCScaleTo:create(0.3, 1))))
	self.star = star
	mask:dispose()

	local duration = 3
	self:playCardinalSpline(path, duration)
end

function MaxEnergyAnimation:playCardinalSpline( path, time )
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
		local currentValue = beginValue + deltaValue * timePercent
		local position = spline:calculatePosition(currentValue)
		context.star:setPosition(position)
		if timePercent > 1 then totalTime = 0 end
	end 
	self.scriptID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onUpdateAnimation,0.01,false)
end
