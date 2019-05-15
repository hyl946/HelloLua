-------------------------------------------------------------------------
--  Class include: DisplayBounds, CocosObject, ClippingNode, TouchResult[internal use only]
-------------------------------------------------------------------------

require "hecore.class"
require "hecore.EventDispatcher"

kCocosObjectType = {kLayer = 1, kScene = 2, kRootLayer = 3, kOthers = 4}
kHitAreaObjectName = "hit_area";
kHitAreaObjectTag = -100;
--
-- DisplayBounds ---------------------------------------------------------
--
DisplayBounds = class();

function table.safeInsert(t, idx, v)
	if type(idx) == "number" then
		if t[idx] then
			local t2 = {}
			for k1, v1 in pairs(t) do
				if k1 >= idx then t2[k1] = t[k1] end -- store values >= idx
			end
			for k2, v2 in pairs(t2) do
				t[k2+1] = t2[k2] -- move values
			end
		end
	else
		idx = #t + 1
	end
	t[idx] = v
end

function DisplayBounds:ctor(x,y,w,h)
    self.x = x or 0;
    self.y = y or 0;
    self.width = w or 0;
    self.height = h or 0;    
    
    self.origin = {x= x, y=y}
    self.size = {width=w,height=h}
end

function DisplayBounds:getPosition()
  return ccp(self.x, self.y)
end

function DisplayBounds:getSize()
  return CCSizeMake(self.width, self.height);
end

function DisplayBounds:toRect()
    return CCRectMake(self.x,self.y, self.width, self.height);
end

function DisplayBounds:toString()
	return string.format("DisplayBounds [x=%d,y=%d,w=%d,h=%d]", self.x, self.y, self.width, self.height);
end

function DisplayBounds:mergeBound(b)
	local minX, minY, maxX, maxY = self.x, self.y, self.x + self.width, self.y + self.height;
    local vx, vy, vw, vh = b.x, b.y, b.x + b.width, b.y + b.height;           
    if vx < minX then minX = vx end;
    if vy < minY then minY = vy end;
    if vw > maxX then maxX = vw end;
    if vh > maxY then maxY = vh end;
    self.x, self.y, self.width, self.height = minX, minY, maxX - minX, maxY - minY;
end

function DisplayBounds:mergeBounds(list)
	local minX, minY, maxX, maxY = self.x, self.y, self.x + self.width, self.y + self.height;
    for i, v in ipairs(list) do
        local vx, vy, vw, vh = v.x, v.y, v.x + v.width, v.y + v.height;       
        if vx < minX then minX = vx end;
        if vy < minY then minY = vy end;
        if vw > maxX then maxX = vw end;
        if vh > maxY then maxY = vh end;
    end
    self.x, self.y, self.width, self.height = minX, minY, maxX - minX, maxY - minY;
end

--
-- kZeroDisplayBound ---------------------------------------------------------
--
kZeroDisplayBound = DisplayBounds.new(0,0,1,1);

--
-- CocosObject ---------------------------------------------------------
--

CocosObject = class(EventDispatcher);
function CocosObject:ctor(refCocosObj)
    self.parent = nil;
	self.nodeType = kCocosObjectType.kOthers; --for faster compare then class:is();

    self.anchorX = 0;
	self.anchorY = 0;
	
    self.touchEnabled = true;
    self.touchChildren = true;
    
	self.index = 0; -- [0 - getNumOfChildren]
	self.list = {};
	self.name = nil;
	
    self:setRefCocosObj(refCocosObj)
    self.isDisposed = false;

    self.className = "CocosObject"

    if _G.useMemoryTable then
	   putOneObjectInMemoryTable(self)
	end
end

function CocosObject:toString()
	return string.format("CocosObject [%s]", self.name and self.name or "nil");
end

function CocosObject:dispose()
    myLayoutCtrl:del(self)

  --if _G.isLocalDevelopMode then printx(0, "dispose", self:toString()) end;
  	self:rma()
    if self.refCocosObj and not self.isRefCocosObjReleased then
        self.refCocosObj:stopAllActions(); -- stop all actions? nor sure if it needed.
        self.refCocosObj:release();
        self.refCocosObj = nil;
        -- if self.debugTag == 1 then if _G.isLocalDevelopMode then printx(0, "dispose" .. self:toString()) end end
    end
    if self.list then for k, v in pairs(self.list) do v:dispose() end end;
    self.list = nil;
    self.refCocosObj = nil;
    self.name = nil;
    self.parent = nil;
    
    self.isDisposed = true;
end

function CocosObject:releaseCocosObj()
    if not self.isRefCocosObjReleased then
        self.isRefCocosObjReleased = true
        --if _G.isLocalDevelopMode then printx(0, "releaseCocosObj") end
        if self.refCocosObj then self.refCocosObj:release() end
        if self.list then for k, v in pairs(self.list) do v:releaseCocosObj() end end
    end
end
-- static object creation
function CocosObject:create()
  return CocosObject.new(CCNode:create())
  
end

function CocosObject:updatePivot()
    if self.refCocosObj then self.refCocosObj:setAnchorPoint(ccp(self.anchorX,self.anchorY)) end;
end

function CocosObject:setRefCocosObj(refCocosObj)
    if self.refCocosObj == refCocosObj then return end;

    if self.refCocosObj then
        self.refCocosObj:release();
        self.refCocosObj = nil;
    end
    self.refCocosObj = refCocosObj;

    local context = self
    local function sceneEventHandler( eventType )
        if eventType == "enter" then 
            if self:hn(Events.kAddToStage) then self:dp(Event.new(Events.kAddToStage, nil, self)) end
            context:onAddToStage()
        elseif eventType == "exit" then 
            if self:hn(Events.kRemoveFromStage) then self:dp(Event.new(Events.kRemoveFromStage, nil, self)) end
            context:onRemoveFromStage()
        elseif eventType == "cleanup" then 
            if self:hn(Events.kDispose) then self:dp(Event.new(Events.kDispose, nil, self)) end
            context:onCocosDispose() 
        end
    end 

    if self.refCocosObj then
        self.refCocosObj:registerScriptHandler(sceneEventHandler) 
        self.refCocosObj:retain();
    end
end

function CocosObject:onAddToStage() end
function CocosObject:onRemoveFromStage() end
function CocosObject:onCocosDispose() end

--
-- public props ---------------------------------------------------------
--
function CocosObject:getParent() return self.parent end
function CocosObject:getCocosRefParent() return self.refCocosObj:getParent() end

function CocosObject:isRunning() return self.refCocosObj:isRunning() end
function CocosObject:getZOrder() return self.refCocosObj:getZOrder() end
function CocosObject:getNumOfChildren() return table.getn(self.list) end --self.refCocosObj:getChildrenCount() end

function CocosObject:getRotation() return self.refCocosObj:getRotation() end
function CocosObject:setRotation(v) self.refCocosObj:setRotation(v) end

function CocosObject:getRotationX() return HeDisplayUtil:getRotationX(self.refCocosObj) end
function CocosObject:setRotationX(v) HeDisplayUtil:setRotationX(self.refCocosObj,v) end

function CocosObject:getRotationY() return HeDisplayUtil:getRotationY(self.refCocosObj) end
function CocosObject:setRotationY(v) HeDisplayUtil:setRotationY(self.refCocosObj,v) end

function CocosObject:getScale() return self.refCocosObj:getScale() end
function CocosObject:setScale(v) self.refCocosObj:setScale(v) end

function CocosObject:getScaleX() return self.refCocosObj:getScaleX() end
function CocosObject:setScaleX(v) self.refCocosObj:setScaleX(v) end

function CocosObject:getScaleY() return self.refCocosObj:getScaleY() end
function CocosObject:setScaleY(v) self.refCocosObj:setScaleY(v) end

------------------------------------------------
--
--	setScaleBy* 在已有的scale基础上，再scale
--
------------------------------------------------
function CocosObject:setScaleXBy(scale, ...)
	assert(scale)
	assert(#{...} == 0)

	local originalScaleX	= self:getScaleX()
	local newScaleX		= originalScaleX * scale

	self:setScaleX(newScaleX)
end

function CocosObject:setScaleYBy(scale, ...)
	assert(scale)
	assert(#{...} == 0)

	local originalScaleY	= self:getScaleY()
	local newScaleY		= originalScaleY * scale

	self:setScaleY(newScaleY)
end

function CocosObject:getNodePosInSelfSpace(node, ...)
	assert(#{...} == 0)

	local nodeParent 	= node:getParent()
	assert(nodeParent)

	local nodePos		= node:getPosition()

	-- Convert Pos To World Space
	local posInWorld	= nodeParent:convertToWorldSpace(ccp(nodePos.x, nodePos.y))

	-- Convert To Self Space
	local posInSelfSpace	= self:convertToNodeSpace(ccp(posInWorld.x, posInWorld.y))

	return posInSelfSpace
end

function CocosObject:setScaleBy(scale, ...)
	assert(#{...} == 0)
	self:setScaleXBy(scale)
	self:setScaleYBy(scale)
end

function CocosObject:getPositionInWorldSpace(...)
	assert(#{...} == 0)

	-- Self Parent
	local parent = self:getParent()
	assert(parent)

	-- Self Position
	local position = self:getPosition()

	-- COnvert To Wrold Space
	local posInWorldSpace = parent:convertToWorldSpace(ccp(position.x, position.y))
	return posInWorldSpace
end

--CCPoint
local _DEFAULT_CCP = ccp(0, 0)
function CocosObject:getPosition() 
	if self.isDisposed then 
		he_log_error("CocosObject disposed!!!") 
		return _DEFAULT_CCP
	end
	if self.refCocosObj then
		return HeDisplayUtil:getNodePosition(self.refCocosObj) 
	else
		return _DEFAULT_CCP
	end
end
function CocosObject:setPosition(v) if self.refCocosObj then self.refCocosObj:setPosition(v) end end
function CocosObject:setPositionXY(x, y) self.refCocosObj:setPosition(x, y) end

function CocosObject:getPositionX() return self.refCocosObj:getPositionX() end
function CocosObject:setPositionX(v) self.refCocosObj:setPositionX(v) end

function CocosObject:getPositionY() return self.refCocosObj:getPositionY() end
function CocosObject:setPositionY(v) self.refCocosObj:setPositionY(v) end

function CocosObject:setPositionY_(v) self.refCocosObj:setPositionY_(v) end
function CocosObject:setScaleX_(v) self.refCocosObj:setScaleX_(v) end
function CocosObject:setScaleY_(v) self.refCocosObj:setScaleY_(v) end
function CocosObject:clearPositionY_() self.refCocosObj:clearPositionY_() end
function CocosObject:clearScaleX_() self.refCocosObj:clearScaleX_() end
function CocosObject:clearScaleY_() self.refCocosObj:clearScaleY_() end

function CocosObject:getSkewX() return self.refCocosObj:getSkewX() end
function CocosObject:setSkewX(v) self.refCocosObj:setSkewX(v) end

function CocosObject:getSkewY() return self.refCocosObj:getSkewY() end
function CocosObject:setSkewY(v) self.refCocosObj:setSkewY(v) end

function CocosObject:getOpacity() return self.refCocosObj:getOpacity() end
function CocosObject:setOpacity(v) self.refCocosObj:setOpacity(v) end

function CocosObject:getAlpha() return self.refCocosObj:getOpacity()/255 end
function CocosObject:setAlpha(v)  
    local v_ = math.floor(v * 255 + 0.5); --round
    self.refCocosObj:setOpacity(v_);
end

function CocosObject:isVisible() 
	if self.refCocosObj then  return self.refCocosObj:isVisible() 
	else  return false  end
end

function CocosObject:isRealVisible( ... )
	if self.isDisposed then return false end
	local parent = self:getParent()
	while parent do
		if parent.isDisposed then return false end
		if not parent:isVisible() then return false end
		parent = parent:getParent()
	end
	return self:isVisible()
end

function CocosObject:setVisible(v) if self.refCocosObj then self.refCocosObj:setVisible(v) end end

function CocosObject:setCascadeOpacityEnabled(v) end
function CocosObject:setCascadeColorEnabled(v) end

function CocosObject:setChildrenVisible(isVisible, isDescentToGrandChildren, ...)
	assert(type(isVisible) == "boolean")
	assert(type(isDescentToGrandChildren) == "boolean")
	assert(#{...} == 0)

	local children = self:getChildrenList()

	for k,child in pairs(children) do
		child:setVisible(isVisible)

		if isDescentToGrandChildren then
			child:setChildrenVisible(isVisible, true)
		end
	end
end

--void*
function CocosObject:getUserData() return self.refCocosObj:getUserData() end
function CocosObject:setUserData(v) self.refCocosObj:setUserData(v) end

--CCPoint
function CocosObject:getAnchorPoint() return self.refCocosObj:getAnchorPoint() end
function CocosObject:setAnchorPoint(v) self.refCocosObj:setAnchorPoint(v) end


function CocosObject:setAnchorPointCenterWhileStayOrigianlPosition(posAdjust)
	-- unused parameter posAdjust.
	self:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
end

function CocosObject:setToParentCenterHorizontal(...)
	assert(#{...} == 0)

	-- Get Parent Size
	-- he_log_warning("this method to get group bounds, is the size in parent space !")
	local parent = self:getParent()
	assert(parent)
	local parentSize = parent:getGroupBounds().size

	-- Get Self Size
	local selfSize = self:getGroupBounds().size

	-- Center Pos
	local deltaWidth = parentSize.width - selfSize.width
	local halfDeltaWidth = deltaWidth / 2

	-- Set Self Posiiton
	local oldAnchorPoint = self:getAnchorPoint()
	self:setAnchorPointWhileStayOriginalPosition(ccp(0,0))
	self:setPositionX(halfDeltaWidth)
	self:setAnchorPointWhileStayOriginalPosition(ccp(oldAnchorPoint.x, oldAnchorPoint.y))
end

function CocosObject:setToParentCenterVertical(...)
	assert(#{...} == 0)

	-- Get Parent Size
	he_log_warning("this method to get group bounds, is the size in parent space !")
	local parent = self:getParent()
	assert(parent)
	local parentSize = parent:getGroupBounds().size

	-- Get Self Size
	local selfSize = self:getGroupBounds().size

	-- Center Pos
	local deltaHeight = parentSize.height - selfSize.height
	local halfDeltaHeight = deltaHeight / 2
	
	-- Set Self Posiiton
	local oldAnchorPoint = self:getAnchorPoint()
	self:setAnchorPointWhileStayOriginalPosition(ccp(0,1))
	self:setPositionY(-halfDeltaHeight)

	self:setAnchorPointWhileStayOriginalPosition(ccp(oldAnchorPoint.x, oldAnchorPoint.y))
end

function CocosObject:setAnchorPointWhileStayOriginalPosition(newAnchorPoint, posAdjust)
	assert(newAnchorPoint)
	-- unused parameter posAdjust.

	local contentSize = self:getContentSize()
	local scale = self:getScaleX()
	local rotation = self:getRotation()
	local position = self:getPosition()
	local skewX = self:getSkewX()
	local skewY = self:getSkewY()

	-- process scale
	local tmpAnchor = {}
	tmpAnchor.x = (newAnchorPoint.x - self:getAnchorPoint().x) * contentSize.width * scale
	tmpAnchor.y = (newAnchorPoint.y - self:getAnchorPoint().y) * contentSize.height * scale

	-- process rotation
	local cosRotation, sinRotation = math.cos(rotation * math.pi / 180), math.sin(rotation * math.pi / 180)
	local deltaAnchor = {}
	deltaAnchor.x = tmpAnchor.x * cosRotation + tmpAnchor.y * sinRotation
	deltaAnchor.y = tmpAnchor.y * cosRotation - tmpAnchor.x * sinRotation

	-- process skew
	deltaAnchor.x = deltaAnchor.x + contentSize.height * math.tan(skewX * math.pi / 180) / 2
	deltaAnchor.y = deltaAnchor.y + contentSize.width * math.tan(skewY * math.pi / 180) / 2

	self:setAnchorPoint(ccp(newAnchorPoint.x, newAnchorPoint.y))
	self:setPositionXY(position.x + deltaAnchor.x, position.y + deltaAnchor.y)
end

function CocosObject:isIgnoreAnchorPointForPosition() return self.refCocosObj:isIgnoreAnchorPointForPosition() end
function CocosObject:ignoreAnchorPointForPosition(v) self.refCocosObj:ignoreAnchorPointForPosition(v) end

-- [CCSize]The untransformed size of the node.
-- The contentSize remains the same no matter the node is scaled or rotated.
-- All nodes has a size. Layer and Scene has the same size of the screen.
function CocosObject:getContentSize() return self.refCocosObj:getContentSize() end
function CocosObject:setContentSize(v) self.refCocosObj:setContentSize(v) end

--int
function CocosObject:getTag() return self.refCocosObj:getTag() end
function CocosObject:setTag(v) self.refCocosObj:setTag(v) end

--return a raw c++ cocos object by tag
--[[
function CocosObject:getChildByTag(tag)
    return self.refCocosObj:getChildByTag(v)
end
]]
--CCRect
function CocosObject:boundingBox() return self.refCocosObj:boundingBox() end






function CocosObject:convertNodePosToSelfSpace(node, ...)
	assert(#{...} == 0)

	local nodePos		= node:getPosition()
	local noeeParent	= node:getParent()

	-- Convert To World Space
	

	--local nodePos




	

end







--
-- public methods of actions ---------------------------------------------------------
--

function CocosObject:cleanup() self.refCocosObj:cleanup() end
function CocosObject:draw() self.refCocosObj:draw() end
function CocosObject:visit() self.refCocosObj:visit() end
function CocosObject:transform() self.refCocosObj:transform() end
function CocosObject:scheduleUpdate() self.refCocosObj:scheduleUpdate() end
function CocosObject:unscheduleUpdate() self.refCocosObj:unscheduleUpdate() end
function CocosObject:scheduleUpdateWithPriority(func, priority) self.refCocosObj:scheduleUpdateWithPriorityLua(func, priority) end

--CCAction
if __PURE_LUA__ then
	function CocosObject:runAction(v) if self.refCocosObj then return self.refCocosObj:runAction(v) end end
else
	function CocosObject:runAction(v) return self.refCocosObj:runAction(v) end
end
function CocosObject:stopAllActions() self.refCocosObj:stopAllActions() end
function CocosObject:stopAction(v) self.refCocosObj:stopAction(v) end
function CocosObject:stopActionByTag(v) 
	if self.refCocosObj then self.refCocosObj:stopActionByTag(v) end
end
function CocosObject:getActionByTag(v) return self.refCocosObj:getActionByTag(v) end
function CocosObject:numberOfRunningActions() return self.refCocosObj:numberOfRunningActions() end

--CCGridBase
function CocosObject:setGrid(v) self.refCocosObj:setGrid(v) end

--CCAffineTransform
function CocosObject:nodeToParentTransform() return self.refCocosObj:nodeToParentTransform() end
function CocosObject:parentToNodeTransform() return self.refCocosObj:parentToNodeTransform() end
function CocosObject:nodeToWorldTransform() return self.refCocosObj:nodeToWorldTransform() end
function CocosObject:worldToNodeTransform() return self.refCocosObj:worldToNodeTransform() end

--CCPoint
function CocosObject:convertToNodeSpace(v) return self.refCocosObj:convertToNodeSpace(v) end
function CocosObject:convertToWorldSpace(v) return self.refCocosObj:convertToWorldSpace(v) end
function CocosObject:convertToNodeSpaceAR(v) return self.refCocosObj:convertToNodeSpaceAR(v) end
function CocosObject:convertToWorldSpaceAR(v) return self.refCocosObj:convertToWorldSpaceAR(v) end
function CocosObject:convertTouchToNodeSpace(v) return self.refCocosObj:convertTouchToNodeSpace(v) end
function CocosObject:convertTouchToNodeSpaceAR(v) return self.refCocosObj:convertTouchToNodeSpaceAR(v) end

--
-- public methods of display ---------------------------------------------------------
--
function CocosObject:getVisibleChildrenList(dst, excluce)
end

function CocosObject:refreshIndex()
	local dp = self.refCocosObj;
	for i, v in ipairs(self.list) do
		--this is a very ligng function call, just setup it's globalOrderOfArrival and zOrder.
		if v.refCocosObj then dp:reorderChild(v.refCocosObj, v.index) end; 
	end
end

function CocosObject:contains(child)
    if not child then return false end;
	for k, v in pairs(self.list) do if v == child then return true end end;
	return false;
end
function CocosObject:addChild(child)
	assert(child)
	self:addChildAt(child, #self.list);
end
-- index: [0 - getNumOfChildren]
function CocosObject:addChildAt(child, index)
	assert(child)
	--assert(child.refCocosObj)

    if not child or not child.refCocosObj then return end;
	local added = self:contains(child);
	if added then
		--assert(false)
		return
	end;

	local compare = child.refCocosObj;
	
	if kHitAreaObjectName == child.name then 
        self.refCocosObj:addChild(compare, index, kHitAreaObjectTag);
    else
        self.refCocosObj:addChild(compare, index);
    end
		
    local oldIndex = table.getn(self.list);
	table.safeInsert(self.list, index+1, child);
	child.parent = self;

	if self._gHitTest and self._gHitTestCascade then
		child:setGlobalHitTestPoint(self._gHitTest, true)
	end

	--update index
	for i, v in ipairs(self.list) do v.index = i-1 end;
    if index ~= oldIndex then self:refreshIndex() end;

    if(child.__anchor) then
    	child.__anchor:adjust()
    end

end

function CocosObject:setAnchor(anchor)
	self.__anchor = anchor
end

function CocosObject:getChildByName(childName)
	for i, v in ipairs(self.list) do
		if childName == v.name then return v end;
	end
	return nil;
end

-- index: [0 - getNumOfChildren]
function CocosObject:getChildAt(index)
	if index < 0 or index >= #self.list then return nil end;
	return self.list[index+1];
end
-- index: [0 - getNumOfChildren], -1 means not found.
function CocosObject:getChildIndex(child)
	if not child then return -1 end;

	for i, v in ipairs(self.list) do
		if v == child then return i - 1 end;
	end

	return -1;
end

function CocosObject:getChildrenList(...)
	assert(#{...} == 0)

	return self.list
end

function CocosObject:removeFromParentAndCleanup(cleanup)
  	if self.parent then
    	self.parent:removeChild(self, cleanup);
	elseif cleanup then
		self:dispose()
  	end
end

-- default: cleanup = true;
function CocosObject:removeChild(child, cleanup, __not_remove_cocos_child__)
	if not child then return end;


	if child._poolObj and cleanup then 
		self:removeChild(child, false)
		-- 池对象的dispose已被覆写 该操作会把child放回池里
		child:dispose()
		return
	end

	local isCleanup = true;
	if cleanup ~= nil then isCleanup = cleanup end;

	--clean cocos2d
	local compare = child.refCocosObj;
	if not compare then return end;
	if not __not_remove_cocos_child__ then self.refCocosObj:removeChild(compare, isCleanup) end;
	
	local cd = 0;
	for i, v in ipairs(self.list) do
		if v == child then cd = i end;
	end

	--clean self list
	if cd > 0 then
		table.remove(self.list, cd);
		child.parent = nil;
		for i, v in ipairs(self.list) do v.index = i-1 end;
		self:refreshIndex()
	end

	if(isCleanup) then child:dispose() end;
end

-- index: [0 - getNumOfChildren]
function CocosObject:removeChildAt(index, cleanup)
	local child = self:getChildAt(index);
	local isCleanup = true;
	if cleanup ~= nil then isCleanup = cleanup end;

	if child then self:removeChild(child, isCleanup) end;
end

function CocosObject:removeChildren(cleanup)
    local isCleanup = true;
	if cleanup ~= nil then isCleanup = cleanup end;

	self.refCocosObj:removeAllChildrenWithCleanup(isCleanup);
    if isCleanup then
        for k, v in pairs(self.list) do v:dispose() end;
    end
    self.list = {};
end

local function sortOnIndex(a, b) return a.index < b.index end
function CocosObject:setChildIndex(child, index)
	local added = self:contains(child);
	if (not added) or (child.index == index) then return end;

	for i, v in ipairs(self.list) do
		local cd = i - 1;
		if (cd >= index) and (v ~= child) then
			v.index = v.index + 1;
		end
	end
	child.index = index;

	table.sort(self.list, sortOnIndex)
	self:refreshIndex();
end

function CocosObject:swapChildren(child1, child2)
	local child1Index = self:getChildIndex(child1);
	local child2Index = self:getChildIndex(child2);
	if child1Index >= 0 and child2Index >= 0 then
		child1.index = child2Index;
		child2.index = child1Index;

		local sp = self.refCocosObj;
		if child1.refCocosObj then sp:reorderChild(child1.refCocosObj, child1.index) end;
		if child2.refCocosObj then sp:reorderChild(child2.refCocosObj, child2.index) end;
	end
end

function CocosObject:swapChildrenAt(child1, child2)
	local c1 = self:getChildAt(child1);
	local c2 = self:getChildAt(child2);
	if c1 and c2 then self:swapChildren(c1, c2) end;
end

--
-- public methods of display ---------------------------------------------------------
--

--Returns a rectangle that defines the area of the display object relative to the coordinate system of the targetCoordinateSpace object. 
function CocosObject:getBounds(targetCoordinateSpace)
    local targetSpace = nil;
    if targetCoordinateSpace then targetSpace = targetCoordinateSpace.refCocosObj end
    return HeDisplayUtil:getNodeBounds(self.refCocosObj, targetSpace);
end

--Returns a rectangle that defines the area of the display object relative to the coordinate system of the targetCoordinateSpace object.  
--Including all it's children.
function CocosObject:getGroupBounds(targetCoordinateSpace)
    local targetSpace = nil;
    if targetCoordinateSpace then targetSpace = targetCoordinateSpace.refCocosObj end
    return HeDisplayUtil:getNodeGroupBounds(self.refCocosObj, targetSpace, kHitAreaObjectTag);
end

function CocosObject:setGlobalHitTestPoint(gHitTest, cascade)
	self._gHitTest = gHitTest
	self._gHitTestCascade = cascade
	if self.list and cascade then
		for _, v in pairs(self.list) do
			v:setGlobalHitTestPoint(gHitTest, true)
		end
	end
end

--Evaluates the display object to see if it overlaps or intersects with the point specified by the worldPosition parameters.
--if useGroupTest, we will check all it's children's bounds.
function CocosObject:hitTestPoint(worldPosition, useGroupTest)
    local isUseGroupTest = false;
    if useGroupTest ~= nil then isUseGroupTest = useGroupTest end;

    --if _G.isLocalDevelopMode then printx(0, "self.refCocosObj: " .. tostring(self.refCocosObj)) end
    --if _G.isLocalDevelopMode then printx(0, "worldPosition: " .. tostring(worldPosition)) end

    --if not self.refCocosObj then
    --        if _G.isLocalDevelopMode then printx(0, "!!!!!!!!!!! self.refCocosObj == nil !!!!!!!!!") end
    --        if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
    --        debug.debug()
    --end
    
    local offsetY = _G.clickOffsetY or 0
    local worldPosition = ccp(worldPosition.x,worldPosition.y + offsetY)

    if not self:hitTestSafeArea(worldPosition) then
    	return false
    end
    
    if not self.refCocosObj then
	    he_log_warning("a layer's refCocosObj become nil when responds to touchend event !!")
	    return false
    end

    return HeDisplayUtil:hitTestPoint(self.refCocosObj, worldPosition, isUseGroupTest, kHitAreaObjectTag);
end

function CocosObject:hitTestSafeArea(worldPosition)
	-- if worldPosition and _G.__HAS_SAFE_AREA then
	-- 	return worldPosition.x >= _G.__SAFE_AREA.x and worldPosition.x <= _G.__SAFE_AREA.x + _G.__SAFE_AREA.width
	-- 		and worldPosition.y >= _G.__SAFE_AREA.y and worldPosition.y <= _G.__SAFE_AREA.y + _G.__SAFE_AREA.height
	-- end
	return true
end

function CocosObject:debugPrintAllChildren()

	if _G.isLocalDevelopMode then printx(0, "================ Debug Output All Children =================") end
	if _G.isLocalDevelopMode then printx(0, tostring(self.name) .. " 's All Child:") end

	for i,v in pairs(self.list) do

		if _G.isLocalDevelopMode then printx(0, "i: "..i .. " , " .. "name: " .. (tostring(v.name) or "NO NAME")) end
	end
end

function CocosObject:debugGroupBounds(descentToChildren, ...)
	assert(type(descentToChildren) == "boolean")
	assert(#{...} == 0)

	if self.debugBoundsLayer then
		self.debugBoundsLayer:setVisible(true)
	end

	if descentToChildren then
		for i,v in pairs(self.list) do
			v:debugGroupBounds(descentToChildren)
		end
	end
end

function CocosObject:registerScriptHandler(handler, ...)
	assert(handler)
	assert(#{...} == 0)

	self.refCocosObj:registerScriptHandler(handler)
end

----------------------不能是HE UI系统资源 AnchorPoint需要在(0, 0)才能正常绘制！！！！
--take a photograph
--filePtah  保存路径
--size     截取的rect为,左下角开始（0,0,size.width, size.height）
--isContainClippingNode 是否有child为clippingnode
--ps:version > 1.27可以直接使用 如果小于1.27需新加
--因为要适配所有机型，所以最终截图size 会 100<= size <= 1024
------------------------------------------------------------
function CocosObject:screenShot(filePath, size, isContainClippingNode)
	local groupBounds = self:getGroupBounds()
	if groupBounds.size.width <= 0 or groupBounds.size.height <= 0 then
		return 
	end
	--限制size的最大，最小值
	local min_size = 32
	local max_size = 1024
	
	--设置
	local o_scaleX = self:getScaleX()
	local o_scaleY = self:getScaleX()

	if groupBounds.size.width > max_size or groupBounds.size.height > max_size then
		if _G.isLocalDevelopMode then printx(0, "scale small "..groupBounds.size.width, groupBounds.size.height) end
		local scale_1 = max_size/groupBounds.size.width
		local scale_2 = max_size/groupBounds.size.height
		local scale_factor = scale_1 <= scale_2 and scale_1 or scale_2
		self:setScaleX(scale_factor * o_scaleX)
		self:setScaleY(scale_factor * o_scaleY)
		if _G.isLocalDevelopMode then printx(0, "111-----------------------") end
	elseif groupBounds.size.width < min_size or groupBounds.size.height < min_size then
		if _G.isLocalDevelopMode then printx(0, "scale big "..groupBounds.size.width, groupBounds.size.height) end
		local scale_1 = min_size/groupBounds.size.width
		local scale_2 = min_size/groupBounds.size.height
		local scale_factor = scale_1 >= scale_2 and scale_1 or scale_2
		self:setScaleX(scale_factor * o_scaleX)
		self:setScaleY(scale_factor * o_scaleY)
		if _G.isLocalDevelopMode then printx(0, "222-----------------------") end
	end
	
	local groupBounds = self:getGroupBounds()
	local gSize = groupBounds.size
	local gOrigin = groupBounds.origin
	if _G.isLocalDevelopMode then printx(0, gOrigin.x, gOrigin.y, gSize.width, gSize.height, "oooooooooooooooooooooooo") end
	if self:getParent() then
		gOrigin = self:getParent():convertToNodeSpace(ccp(gOrigin.x, gOrigin.y))
	end
	size = size or gSize

	if size.width < min_size then
		size.width = min_size
	elseif size.width > max_size then
		size.width = max_size
	end

	if size.height < min_size then
		size.height = min_size
	elseif size.height > max_size then
		size.height = max_size
	end

	local o_x, o_y = self:getPositionX(), self:getPositionY()
	self:setPositionXY(o_x - gOrigin.x, o_y - gOrigin.y)
	if _G.isLocalDevelopMode then printx(0, self:getPositionX(), self:getPositionY(), "iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii") end
	--截图
	local renderTexture
	if isContainClippingNode then
		local GL_DEPTH24_STENCIL8 = 0x88F0  --c++中定义的
		renderTexture = CCRenderTexture:create(size.width, size.height, kCCTexture2DPixelFormat_RGBA8888, GL_DEPTH24_STENCIL8)
		renderTexture:beginWithClear(0, 0, 0, 0, 0)
	else
		renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
	end
	self:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(filePath)

	if _G.isLocalDevelopMode then printx(0, "save texture to "..filePath) end
	--恢复
	self:setPositionXY(o_x, o_y)
	self:setScaleX(o_scaleX)
	self:setScaleY(o_scaleY)
end

function CocosObject:getChildByPath(path)
	local names = string.split(path, '/')
	local node = self
	for _, name in ipairs(names) do
		if (not node) or node.isDisposed then
			return
		end

		if name == '.' then
		elseif name == '..' then
			node = node:getParent()
		else
			node = node:getChildByName(name)
		end
	end
	return node
end

function CocosObject:findChildByName( name )

	local nodeList = self:getChildrenList()

	while #nodeList > 0 do

		local nextNodeList = {}

		for i, v in ipairs(nodeList) do
			if v.name == name then
				return v
			end

			for ii, vv in ipairs(v:getChildrenList()) do
				table.insert(nextNodeList, vv)
			end
		end

		nodeList = nextNodeList
	end
end

function CocosObject:clone( ... )
	return CocosObject.new(CCNode:create())
end

function CocosObject:getUniqNameCascade()
	local uniqName = nil
	local node = self
	while (uniqName == nil and node) do
		uniqName = node.uiNodeUniqName
		node = node:getParent()
	end
	return uniqName
end
--
-- ClippingNode ---------------------------------------------------------
--
ClippingNode = class(CocosObject)
--倍儿蛋疼的bug，改得也是莫名其妙，中间加个node居然好了(wp8 上，叠加的clipping node出现部分遮挡不了)
---------------------------wp8------------------------------------------------------------
if __WP8 then
function ClippingNode:setRefCocosObj(clippingNode)
	if clippingNode == nil or clippingNode == self.clippingNode then return end

	self.clippingNode = clippingNode

	local refCocosObj = CCNode:create()
	self.clippingNode:setPosition(0,0)
	refCocosObj:addChild(self.clippingNode)

	CocosObject.setRefCocosObj(self, refCocosObj)
end

function ClippingNode:addChild(child)
	self:addChildAt(child, #self.list);
end

-- index: [0 - getNumOfChildren]
function ClippingNode:addChildAt(child, index)

    if not child or not child.refCocosObj then return end;
	local added = self:contains(child);
	if added then
		--assert(false)
		return
	end;

	local compare = child.refCocosObj;
	
	if kHitAreaObjectName == child.name then 
        self.clippingNode:addChild(compare, index, kHitAreaObjectTag);
    else
        self.clippingNode:addChild(compare, index);
    end
		
    local oldIndex = table.getn(self.list);
	table.safeInsert(self.list, index+1, child);
	child.parent = self;

	if self._gHitTest and self._gHitTestCascade then
		child:setGlobalHitTestPoint(self._gHitTest, true)
	end

	--update index
	for i, v in ipairs(self.list) do v.index = i-1 end;
    if index ~= oldIndex then self:refreshIndex() end;
end

--CCNode
function ClippingNode:getStencil() return self.clippingNode:getStencil() end
function ClippingNode:setStencil(v) self.clippingNode:setStencil(v) end

--GLfloat, 1.0f by default
function ClippingNode:getAlphaThreshold() return self.clippingNode:getAlphaThreshold() end
function ClippingNode:setAlphaThreshold(v) self.clippingNode:setAlphaThreshold(v) end

function ClippingNode:isInverted() return self.clippingNode:isInverted() end
function ClippingNode:setInverted(v) self.clippingNode:setInverted(v) end

--update size, call before getGroupBounds()
-- NOT TESTED YET
function ClippingNode:updateGroupBounds()
	local hitArea = self.clippingNode:getChildByTag(kHitAreaObjectTag)
	local stencil = self.clippingNode:getStencil()
	hitArea:setCotnentSize(stencil:getContentSize())
end

---------------------------wp8------------------------------------------------------------
else

--CCNode
function ClippingNode:getStencil() return self.refCocosObj:getStencil() end
function ClippingNode:setStencil(v) self.refCocosObj:setStencil(v) end

--GLfloat, 1.0f by default
function ClippingNode:getAlphaThreshold() return self.refCocosObj:getAlphaThreshold() end
function ClippingNode:setAlphaThreshold(v) self.refCocosObj:setAlphaThreshold(v) end

function ClippingNode:isInverted() return self.refCocosObj:isInverted() end
function ClippingNode:setInverted(v) self.refCocosObj:setInverted(v) end

--update size, call before getGroupBounds()
-- NOT TESTED YET
function ClippingNode:updateGroupBounds()
	local hitArea = self.refCocosObj:getChildByTag(kHitAreaObjectTag)
	local stencil = self.refCocosObj:getStencil()
	hitArea:setCotnentSize(stencil:getContentSize())
end

end
--static creation function
function ClippingNode:create (clipRect, target)
	if not clipRect then
		if _G.isLocalDevelopMode then printx(0, "invalid params for buildClippingNode") end
		return 
	end
	local stencilNode = CCLayerColor:create(ccc4(255,255,255,255), clipRect.size.width, clipRect.size.height)
	local node = ClippingNode.new(CCClippingNode:create(stencilNode))
	
	node.className = "ClippingNode"
	if target then node:addChild(target) end
	return node
end

--override ctor
function ClippingNode:ctor(refCocosObj)
	CocosObject.ctor(self, refCocosObj)
	local size = self:getGroupBounds().size
	local groupBounds = CCLayerColor:create(ccc4(255,255,255,255), size.width, size.height)
	groupBounds:setTag(kHitAreaObjectTag)
	groupBounds:setOpacity(0)
	self.refCocosObj:addChild(groupBounds)
end

--
-- SimpleClippingNode ---------------------------------------------------------
--
SimpleClippingNode = class(CocosObject)

function SimpleClippingNode:create()
	return SimpleClippingNode.new(HEClippingNode:create())
end

function SimpleClippingNode:doRecalcPosition()
	self.refCocosObj:doRecalcPosition()
end

function SimpleClippingNode:setRecalcPosition(value)
	self.refCocosObj:setRecalcPosition(value)
end

-- override setContentSize
function SimpleClippingNode:setContentSize(v)
	CocosObject.setContentSize(self, v)
	if not self.groupBoundsCocosObj then
		local groupBounds = CCLayerColor:create(ccc4(255,255,255,255), v.width, v.height)
		groupBounds:setTag(kHitAreaObjectTag)
		groupBounds:setOpacity(0)
		self.refCocosObj:addChild(groupBounds)
		self.groupBoundsCocosObj = groupBounds
	end
end

---------------------------------
---- Sprite Batch Node
--------------------------------

assert(not SpriteBatchNode)
SpriteBatchNode = class(CocosObject)

function SpriteBatchNode:createWithTexture(texture, ...)
	assert(texture)
	assert(#{...} == 0)

	local batchNode = SpriteBatchNode.new(CCSpriteBatchNode:createWithTexture(texture))
	return batchNode
end

function SpriteBatchNode:create(fileImage, capacity, ...)
	assert(fileImage)
	assert(capacity)
	assert(#{...} == 0)

	local BatchNode = SpriteBatchNode.new(CCSpriteBatchNode:create(fileImage, capacity))
	BatchNode.className = "SpriteBatchNode"
	return BatchNode
end

function SpriteBatchNode:addChild(child, ...)
	assert(child)
	assert(#{...} == 0)

	--return  self.refCocosObj:addChild(child.refCocosObj)
	return CocosObject.addChild(self, child)
end

---------------------------------------------------------------------------------
---- Parallax Node
---------------------------------------------------------------------------------

ParallaxNode	= class(CocosObject)

function ParallaxNode:create(...)
	assert(#{...} == 0)

	local parallax = ParallaxNode.new(CCParallaxNode:create())
	parallax.className = "ParallaxNode"
	return parallax
end

function ParallaxNode:addParallaxChild(child, z, parallaxRatio, positionOffset, ...)
	assert(child)
	assert(child.refCocosObj)
	-- assert(z)
	assert(parallaxRatio)
	assert(positionOffset)
	assert(#{...} == 0)

	local added = self:contains(child);
	if added then
		assert(false)
		return
	end;

	if z == nil then
		z = table.getn(self.list) or 0
	end

	local compare = child.refCocosObj;
	
	if kHitAreaObjectName == child.name then 
		--assert(false, "Unknown What To Do Yet :(")
		self.refCocosObj:addChild(compare, z, kHitAreaObjectTag)
	else
		self.refCocosObj:addChild(compare, z, parallaxRatio, positionOffset)
	end
	
	local needReorder = (self.list[z+1] ~= nil)
	local oldIndex = table.getn(self.list);
	-- table.insert(self.list, z+1, child);
	table.safeInsert(self.list, z+1, child);
	child.parent = self;

	--update index
	for i, v in pairs(self.list) do
		if type(i) == "number" then
			v.index = i-1 
		end
	end
	-- if z ~= oldIndex then self:refreshIndex() end;
	if needReorder then self:refreshIndex() end
end


function CocosObject:callAncestors( methodName, ... )
	if self.isDisposed then return end
	local node = self:getParent()
	while node do
		if node[methodName] then
			if node[methodName](node, ...) then
				return true
			end
		end
		node = node:getParent()
	end
	return false
end

function CocosObject:getAncestorByClass( classObj )
	local node = self:getParent()
	while node do
		if node:is(classObj) then
			break
		end
		node = node:getParent()
	end
	return node
end

-- require 'zoo.debug.MemCheckUtils'