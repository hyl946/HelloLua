require "hecore.display.Layer"
require "zoo.panel.broadcast.BroadcastManager"
--
-- Scene ---------------------------------------------------------
--

-- NOTICE! DO remember call initScene after ctor;
-- because we can not call member functions in ctor.

Scene = class(CocosObject);
function Scene:ctor()
	self.nodeType = kCocosObjectType.kScene;

	--only CClayer can handle touch via registerScriptTouchHandler. we add all display object to this layer instead of scene self.
	self.rootLayer = nil;
	self.isSceneInitialized = false;
	self.touchEnabled = false;
	
	local winSize = CCDirector:sharedDirector():getWinSize();
	self.screenWidth = winSize.width;
	self.screenHeight = winSize.height;
	
	self:setRefCocosObj(CCScene:create());
	
	if self.refCocosObj then
		self.refCocosObj:setAnchorPoint(CCPointMake(0,0));
		self.refCocosObj:ignoreAnchorPointForPosition(true);
	end

    if(forceGcMemory) then forceGcMemory(true) end
    Director:purgeCachedData()
end

function Scene:initScene()
  if not self.isSceneInitialized then
    self.isSceneInitialized = true;
    self.rootLayer = RootLayer.new(); --scene's root layer is a RootLayer class
    self.rootLayer:initLayer();
    self:superAddChild(self.rootLayer);
  end
  
  self:setTouchEnabled(true);
  self:onInit();
end

------------------------------------------------
-- cache scene mask

function Scene:cacheHomeScene()
    print("cache home scene")

    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local GL_DEPTH24_STENCIL8 = 0x88F0  --c++中定义的
--  local renderTexture = CCRenderTexture:create(visibleSize.width/4, visibleSize.height/4, kCCTexture2DPixelFormat_RGBA8888, GL_DEPTH24_STENCIL8)
    local renderTexture = CCRenderTexture:create(visibleSize.width/4, visibleSize.height/4, kCCTexture2DPixelFormat_RGBA8888)
    renderTexture:setPosition(ccp(visibleSize.width/8, visibleSize.height/8))
--  renderTexture:beginWithClear(255, 255, 255, 0)
    renderTexture:begin()
    local sceneScaleX = CCDirector:sharedDirector():getRunningScene():getScaleX()
    local sceneScaleY = CCDirector:sharedDirector():getRunningScene():getScaleY()
    CCDirector:sharedDirector():getRunningScene():setScaleX(sceneScaleX / 4);
    CCDirector:sharedDirector():getRunningScene():setScaleY(sceneScaleY / 4);
    CCDirector:sharedDirector():getRunningScene():visit()
    renderTexture:endToLua()
    CCDirector:sharedDirector():getRunningScene():setScaleX(sceneScaleX);
    CCDirector:sharedDirector():getRunningScene():setScaleY(sceneScaleY);

    if(__WIN32 and true) then
        local filePath = HeResPathUtils:getUserDataPath() .. "/_screenShot.png"
        renderTexture:saveToFile(filePath)
    end

    local texture = renderTexture:getSprite():getTexture()
    local sprite = Sprite:createWithTexture(texture)
--  sprite:adjustColor(0, -0.5, 0, 0)
--  sprite:applyAdjustColorShader()
    sprite:setScaleX(4)
    sprite:setScaleY(-4)
    sprite:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))

    self:addCacheMaskToScene(sprite)

    local mask = LayerColor:create()
    mask:changeWidthAndHeight(visibleSize.width, visibleSize.height)
    mask:setColor(ccc3(0, 0, 0))
    mask:setOpacity(200)
    mask:setPosition(ccp(0, 0))
    self._leaveScreenMaskLayer:addChild(mask)

    local loading = CountDownAnimation:createNetworkAnimation(nil)
    self._leaveScreenMaskLayer:addChild(loading)

end

function Scene:cacheHomeSceneGeneralMask()
    print("cache home scene general mask")

    local visibleSize = CCDirector:sharedDirector():getVisibleSize()

    local loading = CountDownAnimation:createBackToHomeSceneAnimation(nil)
    
    local text = Sprite:create("ui/backToHomeScene/loading.png")
--  local text = TextField:create("加载中...", nil, 36, CCSizeMake(300, 200), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    text:setPosition(ccp(visibleSize.width/2,visibleSize.height*0.1))
    loading:addChild(text)

    self:addCacheMaskToScene(loading)
end

function Scene:freeLeaveScreenMask()
    if(self._leaveScreenMaskLayer) then
        self._leaveScreenMaskLayer:removeFromParentAndCleanup(true)
        self._leaveScreenMaskLayer = nil
    end
end


function Scene:addCacheMaskToScene(sprite)
    self:freeLeaveScreenMask()

    local visibleSize = CCDirector:sharedDirector():getVisibleSize()

    self._leaveScreenMaskLayer = Layer:create()
    self:addChild(self._leaveScreenMaskLayer, SceneLayerShowKey.TOP_LAYER)
    self._leaveScreenMaskLayer:setTouchEnabled(true, 0, true)
    self._leaveScreenMaskLayer.hitTestPoint = function(self, worldPosition, useGroupTest)
        return true
    end

    self._leaveScreenMaskLayer:addChild(sprite)
end



--static create function
function Scene:create()
  local s = Scene.new()
  s:initScene()
  return s
end

function Scene:onInit()end
function Scene:onEnter(params)
    BroadcastManager:getInstance():onEnterIgnoreScene(self)
end
function Scene:onExit()end
function Scene:onKeyBackClicked() end
function Scene:onUpdate(dt)
end

function Scene:toString()
	return string.format("Scene [%s]", self.name and self.name or "nil");
end
function Scene:dispose()
	if self.rootLayer then self.rootLayer:dispose() end;
    self.rootLayer = nil;
	CocosObject.dispose(self);
end

local function indexOf(tb, item)
    local idx = -1;
    if tb and item then
        for i, v in ipairs(tb) do
            if v == item then 
                idx= i;
                break;
            end
        end
    end
    return idx;
end

--
-- public control -------------------
--

function Scene:refreshSuperIndex()
	local dp = self.refCocosObj;
	for i, v in ipairs(self.list) do
		--this is a very ligng function call, just setup it's globalOrderOfArrival and zOrder.
		if v.refCocosObj then dp:reorderChild(v.refCocosObj, v.index) end; 
	end
end
function Scene:superAddChild(child)
	self:superAddChildAt(child, #self.list);
end
function Scene:superAddChildAt(child, index)
    if not child or not child.refCocosObj then return end;
	local i = indexOf(self.list, child);
	if i == -1 then
	    local compare = child.refCocosObj;
        self.refCocosObj:addChild(compare, index); --ccScene

        table.insert(self.list, index+1, child);
        child.parent = self;

        --update index
        for i, v in ipairs(self.list) do v.index = i-1 end;
		self:refreshSuperIndex();
	end
end

function Scene:superRemoveChild(child, cleanup)
	if not child then return end;
	local isCleanup = true;
	if cleanup ~= nil then isCleanup = cleanup end;

	--clean cocos2d
	local compare = child.refCocosObj;
	if not compare then return end;
	self.refCocosObj:removeChild(compare, isCleanup);

	local cd = 0;
	for i, v in ipairs(self.list) do if v == child then cd = i end end

	--clean self list
	if cd > 0 then
		table.remove(self.list, cd);
		child.parent = nil;
		for i, v in ipairs(self.list) do v.index = i-1 end;
	end
	if(isCleanup) then child:dispose() end;
end

function Scene:getNumOfChildren() return self.rootLayer:getNumOfChildren() end
function Scene:addChild(child) self.rootLayer:addChild(child) end
function Scene:addChildAt(child, index) self.rootLayer:addChildAt(child, index) end
function Scene:contains(child) return self.rootLayer:contains(child) end  
function Scene:getChildAt(index) return self.rootLayer:getChildAt(index) end
function Scene:getChildIndex(child) return self.rootLayer:getChildIndex(child) end
function Scene:removeFromParentAndCleanup(cleanup) end
function Scene:removeChild(child, cleanup) self.rootLayer:removeChild(child, cleanup) end
function Scene:removeChildren(cleanup) self.rootLayer:removeChildren(cleanup) end
function Scene:refreshIndex() self.rootLayer:refreshIndex() end
function Scene:setChildIndex(child, index) self.rootLayer:setChildIndex(child, index) end
function Scene:swapChildren(child1, child2) end
function Scene:swapChildrenAt(child1, child2) end
function Scene:isTouchEnabled() return self.touchEnabled end
 
function Scene:setTouchEnabled(v)
    local scene = self
    local function onTouchRootLayer( eventType, x, y )
        local worldPosition = ccp(x, y);
        if eventType == CCTOUCHBEGAN then
            if scene:hasEventListenerByName(DisplayEvents.kTouchBegin) then
                scene:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchBegin, scene, worldPosition))
            end
            return true
        elseif eventType == CCTOUCHMOVED then
            if scene:hasEventListenerByName(DisplayEvents.kTouchMove) then
                scene:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchMove, scene, worldPosition))
            end
        elseif eventType == CCTOUCHENDED then
            if scene:hasEventListenerByName(DisplayEvents.kTouchEnd) then
                scene:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchEnd, scene, worldPosition))
            end

            if scene:hasEventListenerByName(DisplayEvents.kTouchTap) then
              scene:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, scene, worldPosition))
            end

        elseif eventType == CCTOUCHCANCELLED then
            if scene:hasEventListenerByName(DisplayEvents.kTouchEnd) then
                scene:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchEnd, scene, worldPosition))
            end
        end
    end

    if self.touchEnabled ~= v then
        if self.touchEnabled then self.rootLayer:unregisterScriptTouchHandler() end;
        self.touchEnabled = v;
        self.rootLayer:setTouchEnabled(v);

        if self.touchEnabled then self.rootLayer:registerScriptTouchHandler(onTouchRootLayer, false, -1, false) end
    end
end
