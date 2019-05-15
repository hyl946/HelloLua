
-------------------------------------------------------------------------
--  Class include: Layer, RootLayer, LayerColor, LayerGradient
-------------------------------------------------------------------------

require "hecore.display.Sprite"

--
-- Layer ---------------------------------------------------------
--
-- NOTICE! DO remember call initLayer after ctor;
-- because sub-class need to override layer initialization but we can not call member functions in ctor.

kTouchesMode = {kCCTouchesAllAtOnce, kCCTouchesOneByOne}
kKeypadMSGType = {kTypeBackClicked, kTypeMenuClicked}

Layer = class(CocosObject);
function Layer:ctor()
	self.nodeType = kCocosObjectType.kLayer;
	self.isLayerInitialized = false;
	self.refCocosObj = nil;
    self.touchEnabled = false
    self.buttomMode = false

    self.className = "Layer"
end

function Layer:initLayer()
    if not self.isLayerInitialized then
        self.isLayerInitialized = true;
		self:setRefCocosObj(CCLayer:create());
        
        if self.refCocosObj then
            self.refCocosObj:setAnchorPoint(CCPointMake(0,0));
            self.refCocosObj:setContentSize(CCSizeMake(1,1));
        end

	self.className = "Layer"
    end
end

function Layer:toString()
	return string.format("Layer [%s]", self.name and self.name or "nil");
end
function Layer:getVisibleChildrenList(dst, excluce)
	if (not self.isDisposed) and self:isVisible() then
        for i, v in ipairs(self.list) do
            v:getVisibleChildrenList(dst, excluce)
        end
    end
end
function Layer:changeWidthAndHeight(w, h) 
	self:setContentSize(CCSizeMake(w, h)) 
end

function Layer:isTouchEnabled() 
    return self.refCocosObj:isTouchEnabled() 
end

function Layer:setBubbleMode(enable)
	if self.bubbleMode ~= enable then
		if enable then
			local action = nil
			if self.buttonAnimationFunc ~= nil then
				action = self.buttonAnimationFunc()
			else
				local scaleX = self.transformData.scaleX
				local scaleY = self.transformData.scaleY
				local deltaX = 4 / self.transformData.width
				local deltaY = 3 / self.transformData.height
				local animationTime = 1.2
				local sequence = CCArray:create()
				sequence:addObject(CCScaleTo:create(animationTime, scaleX + deltaX, scaleY-deltaY))
				sequence:addObject(CCScaleTo:create(animationTime, scaleX, scaleY))
				action = CCRepeatForever:create(CCSequence:create(sequence))
			end
			action:setTag(123654)
			self:runAction(action)
		else
			self:stopActionByTag(123654)
		end
		self.bubbleMode = enable
	end
end
function Layer:setButtonMode( v , donotScaleOnTouch )
	self.buttomMode = v
	
	self.__isGroupButtonBase__ = true

	if nil == self.transformData and not self.isDisposed then
		local transformData = {}
		local position = self:getPosition()
		local size = self:getGroupBounds().size
		transformData.x = position.x
		transformData.y = position.y
		transformData.scaleX = self:getScaleX()
		transformData.scaleY = self:getScaleY()
		transformData.width = size.width
		transformData.height = size.height
		
		self.transformData = transformData
	end

	if self.transformData then self.transformData.donotScaleOnTouch = donotScaleOnTouch end
end
function Layer:__onButtonTouchBegin( x, y )
	self:stopActionByTag(123654)
	if self.transformData and not self.transformData.donotScaleOnTouch and not self.isDisposed then
		local scaleX = self.transformData.scaleX
		local scaleY = self.transformData.scaleY
		local deltaX = 4 / self.transformData.width
		local deltaY = 4 / self.transformData.height
		self:setScaleX(scaleX + deltaX)
		self:setScaleY(scaleY + deltaY)
	end
end
function Layer:__onButtonTouchEnd( x, y )
	if self.transformData and not self.transformData.donotScaleOnTouch and not self.isDisposed then
		local scaleX = self.transformData.scaleX
		local scaleY = self.transformData.scaleY
		self:setScaleX(scaleX)
		self:setScaleY(scaleY)
	end
	if self.bubbleMode then
		self.bubbleMode = false
		self:setBubbleMode(true)
	end
end

function Layer:setTouchEnabledWithMoveInOut(isTouchEnable, priority, isSwallowsTouches, ...)
	assert(#{...} == 0)

	self.isTouched = false
	self.STATE_OUT	= 1
	self.STATE_IN	= 2
	self.moveInOutState = false

	local context = self

	self.debugInfo = ""--debug.traceback() or ""

	local function onTouchCurrentLayer(eventType, x, y )
		local worldPosition = ccp(x, y)

		if eventType == CCTOUCHBEGAN then

			local hit = context:hitTestPoint(worldPosition, true) -- override hitTestPoint function for some special usage.

			if hit then 
				self.isTouched	= true
				self.moveInOutState = self.STATE_IN
				context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchBegin, context, worldPosition))
			else
				self.isTouched = false
				self.moveInOutState = self.STATE_OUT
				context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchBeginOutSide, context, worldPosition))
			end

			return true

		elseif eventType == CCTOUCHMOVED then

			--if self.isTouched then
				if context:hasEventListenerByName(DisplayEvents.kTouchMove) then
					context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchMove, context, worldPosition))
				end
			--end

			local hit = context:hitTestPoint(worldPosition, true) -- override hitTestPoint function for some special usage.
			if self.moveInOutState == self.STATE_OUT then
				if hit then
					self.moveInOutState = self.STATE_IN
					if self:hasEventListenerByName(DisplayEvents.kTouchMoveIn) then
						context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchMoveIn, context, worldPosition))
					end
				end
			elseif self.moveInOutState == self.STATE_IN then
				if not hit then
					self.moveInOutState = self.STATE_OUT
					if self:hasEventListenerByName(DisplayEvents.kTouchMoveOut) then
						context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchMoveOut, context, worldPosition))
					end
				end
			else 
				assert(false)
			end

		elseif eventType == CCTOUCHENDED or
			eventType == CCTOUCHCANCELLED then

			if context:hasEventListenerByName(DisplayEvents.kTouchEnd) then
				context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchEnd, context, worldPosition))
			end

			if self.isTouched == true and
				context:hasEventListenerByName(DisplayEvents.kTouchTap) and
				context:hitTestPoint(worldPosition, true) then
					context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, context, worldPosition))
			end
		end
	end
	if self.touchEnabled ~= isTouchEnable then
		if self.touchEnabled then self:unregisterScriptTouchHandler() end;
		self.touchEnabled = isTouchEnable;

		if self.touchEnabled then self:registerScriptTouchHandler(onTouchCurrentLayer, false, priority, isSwallowsTouches) end
		self.refCocosObj:setTouchEnabled(isTouchEnable) 
	end
end

function Layer:setTouchEnabled2( isTouchEnable, careParent, isSwallowsTouches, hitTestFunc, priority)
	self:setTouchEnabled(isTouchEnable, priority, isSwallowsTouches, hitTestFunc, careParent)
end

function Layer:setTouchEnabled(isTouchEnable, priority, isSwallowsTouches, hitTestFunc, careParent, alwaysUseHitTestFunc)

	self.isTouched	= false

	self.debugInfo	= ""--debug.traceback() or ""

    local context = self
    local function onTouchCurrentLayer( eventType, x, y)
        local worldPosition = ccp(x, y)
        if eventType == CCTOUCHBEGAN then

			if self.isDisposed or not self:isVisible() then 
				return false 
			end

			if careParent then
				if not self:isRealVisible() then
					return false
				end
			end

			if self._gHitTest and not self._gHitTest(worldPosition) then
				return false
			end

			if not self:hitTestSafeArea(worldPosition) then
		    	return false
		    end

			-- If Already Touched , Return Flase
			-- if self.isTouched then 
			-- 	return false 
			-- end

			local hit = false
			if hitTestFunc then
				hit = hitTestFunc(worldPosition)
			else
				hit = context:hitTestPoint(worldPosition, true) -- override hitTestPoint function for some special usage.
			end
            
            if hit then
            	if context.buttomMode then context:__onButtonTouchBegin(x, y) end
                if context:hasEventListenerByName(DisplayEvents.kTouchBegin) then 
					context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchBegin, context, worldPosition)) 
				end
				self.isTouched		= true
				self.canTriggerTapEvent	= true
				self.touchedPos	= ccp(worldPosition.x, worldPosition.y)
                return true
            else 
			    return false 
		    end
        else
            if eventType == CCTOUCHMOVED then
			    local deltaDistance = ccpDistance(self.touchedPos, worldPosition)
			    if deltaDistance >= 30 then self.canTriggerTapEvent = false end
				if context:hasEventListenerByName(DisplayEvents.kTouchMove) then context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchMove, context, worldPosition)) end
            elseif eventType == CCTOUCHENDED or eventType == CCTOUCHCANCELLED then		    
                if self.buttomMode then self:__onButtonTouchEnd(x, y) end
                if context:hasEventListenerByName(DisplayEvents.kTouchEnd) then context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchEnd, context, worldPosition)) end

				if self.isTouched == true and self.canTriggerTapEvent and (context:hitTestPoint(worldPosition, true) or (alwaysUseHitTestFunc and hitTestFunc and hitTestFunc(worldPosition))) then
					if context:hasEventListenerByName(DisplayEvents.kTouchTap) then 
						context:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, context, worldPosition)) 
					end
				end				
				self.isTouched = false
            end
        end
    end

    if self.touchEnabled ~= isTouchEnable then
        if self.touchEnabled then self:unregisterScriptTouchHandler() end
        self.touchEnabled = isTouchEnable

        if self.touchEnabled then self:registerScriptTouchHandler(onTouchCurrentLayer, false, priority, isSwallowsTouches) end
        self.refCocosObj:setTouchEnabled(isTouchEnable) 
    end
end


--kTouchesMode
function Layer:getTouchMode() return self.refCocosObj:getTouchMode() end;
function Layer:setTouchMode(v) self.refCocosObj:setTouchMode(v) end;

function Layer:isAccelerometerEnabled() return self.refCocosObj:isAccelerometerEnabled() end;
function Layer:setAccelerometerEnabled(v) self.refCocosObj:setAccelerometerEnabled(v) end;

function Layer:registerScriptAccelerateHandler(func) self.refCocosObj:registerScriptAccelerateHandler(func) end;
function Layer:unregisterScriptAccelerateHandler() self.refCocosObj:unregisterScriptAccelerateHandler() end;

function Layer:isKeypadEnabled() return self.refCocosObj:isKeypadEnabled() end;
function Layer:setKeypadEnabled(v) self.refCocosObj:setKeypadEnabled(v) end;

function Layer:registerScriptKeypadHandler(func) self.refCocosObj:registerScriptKeypadHandler(func) end;
function Layer:unregisterScriptKeypadHandler() self.refCocosObj:unregisterScriptKeypadHandler() end;
	
--[[
func(eventType, x, y) where eventType = 
    CCTOUCHBEGAN,
    CCTOUCHMOVED,
    CCTOUCHENDED,
    CCTOUCHCANCELLED,
]]
-- WARNING: use touch events by scene 1st. use unregisterScriptTouchHandler/registerScriptTouchHandler carefully.
function Layer:unregisterScriptTouchHandler() return self.refCocosObj:unregisterScriptTouchHandler() end;
function Layer:registerScriptTouchHandler(func, bIsMultiTouches, nPriority, bSwallowsTouches)
    local isMultiTouches = false;
    local priority = nPriority or 0;
    local swallowsTouches = false;
    if bIsMultiTouches ~= nil then isMultiTouches = bIsMultiTouches end;
    if bSwallowsTouches ~= nil then swallowsTouches = bSwallowsTouches end;
    self.refCocosObj:registerScriptTouchHandler(func, isMultiTouches, priority, swallowsTouches) 
end

--static create function
function Layer:create()
  local layer = Layer.new()
  layer:initLayer()
  return layer
end

function Layer:clone( ... )
	local layer = Layer.new()
	layer:initLayer()

	local size = self:getContentSize()
	local isIgnore = self:isIgnoreAnchorPointForPosition()
	layer:setContentSize(CCSizeMake(size.width, size.height))
	layer:ignoreAnchorPointForPosition(false)

	return layer
end
--
-- LayerColor ---------------------------------------------------------
--

LayerColor = class(Layer);
function LayerColor:initLayer()
    if not self.isLayerInitialized then
        self.isLayerInitialized = true;
        self:setRefCocosObj(CCLayerColor:create(ccc4(0,0,0,255))); --black

        if self.refCocosObj then
            self.refCocosObj:setAnchorPoint(CCPointMake(0,0));
            self.refCocosObj:setContentSize(CCSizeMake(1,1));
        end

	self.className = "LayerColor"
    end
end

--ccColor3B
function LayerColor:getColor() return self.refCocosObj:getColor() end
function LayerColor:setColor(v) self.refCocosObj:setColor(v) end
--ccBlendFunc
function LayerColor:getBlendFunc() return self.refCocosObj:getBlendFunc() end;
function LayerColor:setBlendFunc(v) self.refCocosObj:setBlendFunc(v) end;

function LayerColor:isOpacityModifyRGB() return self.refCocosObj:isOpacityModifyRGB() end;
function LayerColor:setOpacityModifyRGB(v) self.refCocosObj:setOpacityModifyRGB(v) end;

function LayerColor:changeWidth(v) self.refCocosObj:changeWidth(v) end
function LayerColor:changeHeight(v) self.refCocosObj:changeHeight(v) end
function LayerColor:changeWidthAndHeight(w, h) self.refCocosObj:changeWidthAndHeight(w, h) end

function LayerColor:setCascadeOpacityEnabled(v) self.refCocosObj:setCascadeOpacityEnabled(v) end
function LayerColor:setCascadeColorEnabled(v) self.refCocosObj:setCascadeColorEnabled(v) end

--static create function
function LayerColor:create()
  local layer = LayerColor.new()
  layer:initLayer()
  return layer
end

function LayerColor:createWithColor(color, width, height)
	local layer = LayerColor:create()
	layer:setColor(color)
	if type(width) == "number" then layer:changeWidth(width) end
	if type(height) == "number" then layer:changeHeight(height) end
	return layer
end
--
-- LayerGradient ---------------------------------------------------------
--

LayerGradient = class(LayerColor);
function LayerGradient:initLayer()
    if not self.isLayerInitialized then
        self.isLayerInitialized = true;
        self:setRefCocosObj(CCLayerGradient:create(ccc4(0,0,0,0),ccc4(0,0,0,0)));

        if self.refCocosObj then
            self.refCocosObj:setAnchorPoint(CCPointMake(0,0));
            self.refCocosObj:setContentSize(CCSizeMake(1,1));
        end

	self.className = "LayerGradient"
    end
end
--ccColor3B
function LayerGradient:getStartColor() return self.refCocosObj:getStartColor() end;
function LayerGradient:setStartColor(v) self.refCocosObj:setStartColor(v) end;
--ccColor3B
function LayerGradient:getEndColor() return self.refCocosObj:getEndColor() end;
function LayerGradient:setEndColor(v) self.refCocosObj:setEndColor(v) end;
--GLubyte
function LayerGradient:getStartOpacity() return self.refCocosObj:getStartOpacity() end;
function LayerGradient:setStartOpacity(v) self.refCocosObj:setStartOpacity(v) end;
--GLubyte
function LayerGradient:getEndOpacity() return self.refCocosObj:getEndOpacity() end;
function LayerGradient:setEndOpacity(v) self.refCocosObj:setEndOpacity(v) end;
--CCPoint
function LayerGradient:getVector() return self.refCocosObj:getVector() end;
function LayerGradient:setVector(v) self.refCocosObj:setVector(v) end;

function LayerGradient:isCompressedInterpolation() return self.refCocosObj:isCompressedInterpolation() end;
function LayerGradient:setCompressedInterpolation(v) self.refCocosObj:setCompressedInterpolation(v) end;

--static create function
function LayerGradient:create()
  local layer = LayerGradient.new()
  layer:initLayer()
  return layer
end

function LayerGradient:createWithColor(startColor, endColor)
  	local layer = LayerGradient:create()
  	layer:setStartColor(startColor)
  	layer:setEndColor(endColor)
  	layer:setStartOpacity(255)
  	layer:setEndOpacity(255)
  	return layer
end

--
-- RootLayer ---------------------------------------------------------
--

RootLayer = class(Layer);
function RootLayer:ctor()
	self.name = "root";
end

--static create function
function RootLayer:create()
  local layer = RootLayer.new()
  layer:initLayer()
  return layer
end
