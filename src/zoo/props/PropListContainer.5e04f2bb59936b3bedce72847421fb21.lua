PropListContainer = class(CocosObject)

function PropListContainer:ctor()
	self.touchLayer = nil
	self.viewLayer = nil
	self.contentClipping = nil
	self.content = nil
	self.size = nil
	self.controller = nil
	self.isTouchEnabled = false
	self.kPropListScaleFactor = 1
end

function PropListContainer:create(propListAnimation, size)
	local node = PropListContainer.new(CCNode:create())
	node:init(propListAnimation, size)
	return node
end

function PropListContainer:init(propListAnimation, size)
	self.propListAnimation = propListAnimation
  	if __isWildScreen then self.kPropListScaleFactor = 0.9 end

	if size then
		self.size = size
	else
  		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		self.size = CCSizeMake(visibleSize.width, 170 * self.kPropListScaleFactor) -- default
	end

	self.width = self.size.width
	self.height = self.size.height

  	self.content = Layer:create()
  	self.content.name = "content"

  	-- local debugLayer = LayerColor:create()
  	-- debugLayer:setColor(ccc3(255, 0, 0))
  	-- debugLayer:changeWidthAndHeight(self.width, self.height)
  	-- self:addChild(debugLayer)

  	-- self.contentClipping = SimpleClippingNode:create()
  	-- self.contentClipping:setContentSize(CCSizeMake(size.width, size.height))	
  	-- self.contentClipping:addChild(self.content)

	self.touchLayer = Layer:create()
	-- self.touchLayer:changeWidthAndHeight(size.width, size.height)
	self.touchLayer:setTouchEnabled(true,0,false)

	self.touchRect = CCRectMake(0,0,size.width,size.height)
	local context = self
	self.touchLayer.hitTestPoint = function( self, worldPosition, useGroupTest )
		if not context.touchLayer2:hitTestPoint(worldPosition,useGroupTest) then
		    local localPosition = self:convertToNodeSpace(worldPosition)
		    local touchOrigin = context.touchRect.origin
		    local touchSize = context.touchRect.size
		    local localX = localPosition.x - touchOrigin.x
		    local localY = localPosition.y - touchOrigin.y
		    return localX >= 0 and localX <= touchSize.width 
		    	and localY >= 0 and localY <= touchSize.height
	    end
  	end

  	-- 全屏点击取消有问题，单独加一个优选级高的layer处理
  	self.touchLayer2 = Layer:create()
  	self.touchLayer2:setTouchEnabled(true,-1,false)
  	function self.touchLayer2:hitTestPoint( worldPosition,useGroupTest )
  		-- 有引导，走原来的取消
  		if GameGuide then
			local action = GameGuideData:sharedInstance():getRunningAction()
			if action and action.type ~= "usePropTip" then
				return false
			end
  		end

  		if context.propListAnimation.focusItem then
  			return 	context.controller and 
				context.controller.hitTestPoint and 
				context.controller:hitTestPoint(worldPosition,useGroupTest)
  		end
  	end
  	self:addChild(self.touchLayer2)


	self.viewLayer = Layer:create()
	-- self.viewLayer:changeWidthAndHeight(size.width, size.height)

	self:addChild(self.content)
	self:addChild(self.viewLayer)
	self:addChild(self.touchLayer)

	self:initTouchListeners()
end

function PropListContainer:dispose()
	CocosObject.dispose(self)
	if self.touchLayer then
		self.touchLayer:rma()
		self.touchLayer = nil
	end
end

function PropListContainer:setTouchRect(rect)
	self.touchRect = rect
end

function PropListContainer:initTouchListeners()
	local function onTouchBegin(evt) 
		if self.isTouchEnabled then 
			self:onTouchBegin(evt) 
		end 
	end
  	local function onTouchMove(evt)
		if self.isTouchEnabled then 
			self:onTouchMove(evt) 
		end
	end
  	local function onTouchEnd(evt)
  		if self.isTouchEnabled then 
			self:onTouchEnd(evt) 
		end
  	end

	self.touchLayer:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	self.touchLayer:ad(DisplayEvents.kTouchMove, onTouchMove)
	self.touchLayer:ad(DisplayEvents.kTouchEnd, onTouchEnd)
	self.touchLayer2:ad(DisplayEvents.kTouchBegin, onTouchBegin)
	self.touchLayer2:ad(DisplayEvents.kTouchMove, onTouchMove)
	self.touchLayer2:ad(DisplayEvents.kTouchEnd, onTouchEnd)

	self.isTouchEnabled = true
end

function PropListContainer:setItemTouchEnabled(enable)
  self.isTouchEnabled = enable
end

function PropListContainer:setContent(content)
	if content then
		-- self.contentClipping:addChild(content)
		self.content:addChild(content)
	end
end

function PropListContainer:setController(controller)
	self.controller = controller
end

function PropListContainer:onTouchBegin(evt)
	-- if _G.isLocalDevelopMode then printx(0, "PropListContainer:onTouchBegin") end
	if self.controller and self.controller.onTouchBegin then
		self.controller:onTouchBegin(evt)
	end
end

function PropListContainer:onTouchMove(evt)
	-- if _G.isLocalDevelopMode then printx(0, "PropListContainer:onTouchMove") end
	if self.controller and self.controller.onTouchMove then
		self.controller:onTouchMove(evt)
	end
end

function PropListContainer:onTouchEnd(evt)
	-- if _G.isLocalDevelopMode then printx(0, "PropListContainer:onTouchEnd") end
	if self.controller and self.controller.onTouchEnd then
		self.controller:onTouchEnd(evt)
	end
end

function PropListContainer:windover(direction)
end

function PropListContainer:show( propItems, delayTime )

end