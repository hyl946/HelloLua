
PanelsScene = class(Scene)
function PanelsScene:ctor()
	self.backButton = nil
end
function PanelsScene:dispose()
	if self.backButton then self.backButton:removeAllEventListeners() end
	self.backButton = nil
	
	Scene.dispose(self)
end

function PanelsScene:create()
	local s = PanelsScene.new()
	s:initScene()
	return s
end

function PanelsScene:onInit()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local layer = Layer:create()
	layer:setPosition(ccp(origin.x, origin.y))
  	self:addChild(layer)
  	self.layer = layer

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(winSize.width, winSize.height)
	colorLayer:setColor(ccc3(255, 255, 255))
	colorLayer:setOpacity(100)
	--layer:addChild(colorLayer)

	local function onTouchBackLabel(evt)
		Director:sharedDirector():popScene()
	end

	local function onTouchInfoLabel( evt )
		CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	end

	self.backButton = self:buildLabelButton("Back", 0, winSize.height-100, onTouchBackLabel)
	self.memoButton = self:buildLabelButton("Memory", winSize.width-200, winSize.height-100, onTouchInfoLabel)

	self:tests()
end

function PanelsScene:buildLabelButton( label, x, y, func )
	local width = 250
	local height = 80
	local layer = self.layer
	local labelLayer = LayerColor:create()
	labelLayer:changeWidthAndHeight(width, height)
	labelLayer:setColor(ccc3(255, 0, 0))
	labelLayer:setPosition(ccp(x - width / 2, y - height / 2))
	labelLayer:setTouchEnabled(true, p, true)
	labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
	layer:addChild(labelLayer)

	local textLabel = TextField:create(label, nil, 32)
	textLabel:setPosition(ccp(width/2, height/2))
	textLabel:setAnchorPoint(ccp(0,0))
	labelLayer:addChild(textLabel)

	return labelLayer
end

function PanelsScene:tests()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local function onSettingButtonTouch( evt )
		local p = ExceptionPanel:create()
		--p:popout()
	end
	
	local function onQuitButtonTouch( evt )
		
	end
	self:buildLabelButton("GameSetting", winSize.width/2, winSize.height/2, onSettingButtonTouch)
	self:buildLabelButton("GameQuit", winSize.width/2, winSize.height/2 - 100, onQuitButtonTouch)
end

function PanelsScene:testGameSettingPanel()
	
end