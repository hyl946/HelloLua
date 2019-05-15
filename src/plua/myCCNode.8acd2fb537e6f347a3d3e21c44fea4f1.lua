require "hecore.class"
myCCNode = class()

function myCCNode:ctor()
	self.children = {}
	self.x = 0
	self.y = 0
	self.scaleX  = 0
	self.scaleY  = 0
	self.skewx = 0
	self.skewY = 0
	self.refCount = 0
end

function myCCNode:getTextureRect()
	return CCRectMake(0,0,1,1)
end

function myCCNode:addChild(child, zOrder)
	child:setParent(self);
	self.children[#self.children] = child
	child:onEnter()
	child:onEnterTransitionDidFinish();
end

function myCCNode:removeFromParentAndCleanup(cleanup)
	self.parent:removeChild(self)
end

function myCCNode:removeChildByTag(tag, cleanup)
	
end

function myCCNode:getOpacity()
	return self.Opacity or 1
end

function myCCNode:setOpacity(v)
	self.Opacity = v
end

function myCCNode:removeChild(child)
	for k,v in pairs(self.children) do
		if v == child then
			self.children[k] = nil
		end
	end
end

function myCCNode:onEnter()
	if self.scriptHandler then
		self.scriptHandler("enter")
	end
	for k, child in pairs(self.children) do
		child:onEnter()
	end
end

function myCCNode:setPosition(x, y)
	if type(x)  == "table" then
		self.x = x.x
		self.y = x.y
	else
		self.x = x
		self.y = y
	end
end

function myCCNode:getPosition()
	return ccp(self.x, self.y)
end

function myCCNode:setScale(v) 
	self.scale = v
end

function myCCNode:getScale() 
	return self.scale or 1
end

function myCCNode:onEnterTransitionDidFinish()
	if self.scriptHandler then
		self.scriptHandler("enterTransitionFinish")
	end
	
    for k, child in pairs(self.children) do
		child:onEnterTransitionDidFinish()
	end
end

function myCCNode:onExitTransitionDidStart()
	if self.scriptHandler then
		self.scriptHandler("exitTransitionStart")
	end
    for k, child in pairs(self.children) do
		child:onExitTransitionDidStart()
	end
end

function myCCNode:onExit()
	if self.scriptHandler then
		self.scriptHandler("exit")
	end
	
    for k, child in pairs(self.children) do
		child:onExit()
	end
end

function myCCNode:cleanup()
	if self.scriptHandler then
		self.scriptHandler("cleanup")
	end
	for k, child in pairs(self.children) do
		child:cleanup()
	end
	self.scriptHandler = nil
end

function myCCNode:draw()
	
end

function myCCNode:visit()
	
end

function myCCNode:convertToWorldSpace()
	return ccp(0,0)
end

function myCCNode:convertToNodeSpace()
	return ccp(0,0)
end

function myCCNode.create()
	local node = myCCNode.new()
	return node
end

function myCCNode:getZOrder()
	return self.zOrder or 1
end

function myCCNode:setZOrder(zOrder)
	self.zOrder = zOrder
end

function myCCNode:getVertexZ()
	return self.vertexZ or 1
end

function myCCNode:setVertexZ(var)
	self.vertexZ = var
end

function myCCNode:getRotation()
	return self.rotation or 1
end

function myCCNode:setRotation(newRotation)
	self.rotation = newRotation
end


function myCCNode:getScaleX()
	return self.scaleX
end

function myCCNode:setScaleX(newScaleX)
	self.scaleX = newScaleX
end

function myCCNode:getScaleY()
	return self.scaleY
end

function myCCNode:setScaleY(newScaleY)
	self.scaleY = newScaleY
end


function myCCNode:getPositionX()
	return self.x
end

function myCCNode:getPositionY()
	return self.y
end


function myCCNode:setPositionX(x)
	self.x = x
end

function myCCNode:setPositionY(y)
	self.y = y
end

function myCCNode:getSkewX()
	return self.skewx
end

function myCCNode:setSkewX(skewX)
	self.skewX = skewX
end

function myCCNode:getSkewY()
	return self.skewY
end

function myCCNode:setSkewY(skewY)
	self.skewY = skewY
end

function myCCNode:isVisible()
	return true
end

function myCCNode:setVisible(var)
	
end

function myCCNode:getAnchorPoint()
	return ccp(0, 0)
end

function myCCNode:setAnchorPoint(point)
	
end

function myCCNode:getContentSize()
	return self.contentSize or CCSizeMake(10, 10)
end

function myCCNode:setContentSize(size)
	self.contentSize = size
end

function myCCNode:setTag(var)
	self.tag = var
end

function myCCNode:getChildren()
	return self.children
end

function myCCNode:getChildrenCount()
	return #self.children
end

function myCCNode:getCamera()
	
end

function myCCNode:getGrid()
	
end

function myCCNode:setGrid(pGrid)
	
end

function myCCNode:getAnchorPointInPoints()
	return ccp(0,0)
end

function myCCNode:isRunning()
	return true
end

function myCCNode:getParent()
	return self.parent
end

function myCCNode:setParent(var)
	self.parent = var
end

function myCCNode:isIgnoreAnchorPointForPosition()
	
end

function myCCNode:ignoreAnchorPointForPosition(newValue)
	
end

function myCCNode:getUserData()
	
end

function myCCNode:setUserData(var)
	
end

function myCCNode:getUserObject()
	
end

function myCCNode:setUserObject(pObject)
	
end

function myCCNode:getShaderProgram()
	
end

function myCCNode:setShaderProgram(pShaderProgram)
	
end

function myCCNode:getOrderOfArrival()
	
end

function myCCNode:setOrderOfArrival(order)
	
end


function myCCNode:setGLServerState(state)
	
end

function myCCNode:getActionManager()
	
end

function myCCNode:setActionManager(pActionMgr)
	
end

function myCCNode:getGLServerState()
	
end


function myCCNode:getScheduler()
	
end

function myCCNode:setScheduler(pScheduler)
	
end


function myCCNode:removeAllChildrenWithCleanup(cleanup)
	for k, child in pairs(self.children) do
		child:onExitTransitionDidStart();
        child:onExit();
		child:setParent(nil)
		self.children[k] = nil
	end
end

function myCCNode:reorderChild(child, zOrder)
	for k, v in pairs(self.children) do
		if v == child then
			child:onExitTransitionDidStart()
			child:onExit()
			child:setParent(nil)
			self.children[k] = nil
			break
		end
	end
end


function myCCNode:transform()
	
end

function myCCNode:transformAncestors()
	
end

function myCCNode:boundingBox()
	return CCRectMake(0, 0, 1, 1)
end

function myCCNode:retain() 
	self.refCount = self.refCount + 1
end

function myCCNode:release() 
	self.refCount = self.refCount -1
	if self.refCount <= 0 then
		myCCDirect:sharedDirector():unscheduleUpdateForTarget(self)
	end
end

function myCCNode:runAction(action)
	action.node = self
	myActionManager.getInstance():addAction(action)
end

function myCCNode:stopAllActions()
	myActionManager.getInstance():removeAllActionsFromTarget(self)
end

function myCCNode:stopAction(action)
	myActionManager.getInstance():removeAction(action)
end

function myCCNode:stopActionByTag(tag)
    myActionManager.getInstance():removeActionByTag(tag, self)
end

function myCCNode:getActionByTag(tag)
    return myActionManager.getInstance():getActionByTag(tag, self)
end

function myCCNode:numberOfRunningActions()
	return myActionManager.getInstance():numberOfRunningActionsInTarget(self)
end


function myCCNode:description()
	
end

function myCCNode:getChildByTag(tag)
	
end



function myCCNode:scheduleUpdateWithPriorityLua(nHandler, priority)
	self.scheduleUpdateIndex = myCCDirect:sharedDirector():scheduleUpdateForTarget(self, nHandler, 0)
end

function myCCNode:unscheduleUpdate()
	myCCDirect:sharedDirector():unscheduleScriptEntry(self.scheduleUpdateIndex)
end


function myCCNode:registerScriptHandler(funcID)
	self.scriptHandler = funcID
end

function myCCNode:unregisterScriptHandler()
	self.scriptHandler = nil
end


function myCCNode:getComponent(pName)
	
end
function myCCNode:setColor() end
function myCCNode:getColor() return nil end

CCNode = myCCNode

CCClippingNode = class(myCCNode)

function CCClippingNode:create()
	return CCClippingNode.new()
end

function CCClippingNode:getStencil()
	return self.Stencil or self
end

function CCClippingNode:setStencil(node)
	self.Stencil = node
end

function CCClippingNode:getAlphaThreshold()
	return self.AlphaThreshold or 1
end

function CCClippingNode:setAlphaThreshold(v)
	self.AlphaThreshold = v
end

function CCClippingNode:isInverted()

end

function CCClippingNode:setInverted(v)

end

HEClippingNode = class(CCClippingNode)

function HEClippingNode:create()
	return HEClippingNode.new()
end

function HEClippingNode:doRecalcPosition() end
function HEClippingNode:setRecalcPosition() end

CCParallaxNode = class(myCCNode)

function CCParallaxNode:create()
	return CCParallaxNode.new()
end

