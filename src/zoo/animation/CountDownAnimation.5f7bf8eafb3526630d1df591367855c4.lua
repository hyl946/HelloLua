-------------------------------------------------------------------------
--  Class include: CountDownAnimation
-------------------------------------------------------------------------

require "hecore.display.Director"

--
-- CountDownAnimation ---------------------------------------------------------
--
CountDownAnimation = class()

local function buildTimeCountDownAnimation( sprite, delay )
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay))
	array:addObject(CCSpawn:createWithTwoActions(CCEaseElasticOut:create(CCScaleTo:create(1, 1.3)), CCFadeIn:create(1)))
	array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5), CCScaleTo:create(0.5, 1.6)))
	
	sprite:setOpacity(0)
	sprite:setScale(2.2)
	sprite:runAction(CCSequence:create(array))
end 

function CountDownAnimation:create(delay, animationCallbackFunc)
	delay = delay or 0
	local batch = SpriteBatchNode:createWithTexture(CCSprite:createWithSpriteFrameName("countdown_10000"):getTexture())
	batch.name = "CountDownAnimation"

	local items = {"3", "2", "1"}
	for i,v in ipairs(items) do
		local sprite = Sprite:createWithSpriteFrameName("countdown_"..v.."0000")		
		batch:addChild(sprite)
		buildTimeCountDownAnimation(sprite, delay + (i-1) * 1)
	end

	local sprite = Sprite:createWithSpriteFrameName("countdown_go0000")
	sprite:setOpacity(0)
	sprite:setScale(4)
	batch:addChild(sprite)

	local function onAnimationFinished()
		batch:removeFromParentAndCleanup(true)
	end 
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(delay + 3))
	array:addObject(CCSpawn:createWithTwoActions(CCEaseElasticOut:create(CCScaleTo:create(1, 1.5)), CCFadeIn:create(1)))
	
	if animationCallbackFunc ~= nil then array:addObject(CCCallFunc:create(animationCallbackFunc)) end

	array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.3), CCScaleTo:create(0.3, 1.7)))
	array:addObject(CCCallFunc:create(onAnimationFinished))
	sprite:runAction(CCSequence:create(array))
  	
	return batch
end

function CountDownAnimation:createLoadingAnimation(labelText, useSystemFnt)
	-- RemoteDebug:uploadLogWithTag("loading" , debug.traceback())
	-- printx(11, "loading" , debug.traceback())

	local container	= Layer:create()
	local back = Scale9Sprite:createWithSpriteFrameName("loading_ico_rect instance 10000")
	local animaWidth = 500
	local animaHeight = 170
	back:setPreferredSize(CCSizeMake(animaWidth, animaHeight))
	container:addChild(back)
	local batch = SpriteBatchNode:createWithTexture(CCSprite:createWithSpriteFrameName("loading_ico_1 instance 10000"):getTexture())
	container:addChild(batch)

	local kAnimationTime = 1/30
	local scaleY = 0.97
	local moveY = 13
	local currentPosition = 0
	local oriPosY = 8
	local animalWidth = 80
	for i = 1, 6 do
		local animal = Sprite:createWithSpriteFrameName("loading_ico_"..i.." instance 10000")
		-- local contentSize = animal:getContentSize() // 2x素材没转位图导致导出的contentSize比1x的大~ 索性写死为80
		-- animal:setAnchorPoint(ccp(0.5, 0))
		animal:setPosition(ccp(currentPosition, oriPosY))
		animal.oriX = currentPosition
		animal.oriY	= oriPosY
		animal.move = function( self, delay )
			self:stopAllActions()
			self:setPosition(ccp(self.oriX, self.oriY))
			self:setScale(1)
			local actSeq = CCArray:create()
			actSeq:addObject(CCDelayTime:create(delay))
			actSeq:addObject(CCScaleTo:create(kAnimationTime*3, 1, scaleY))
			actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(kAnimationTime*4, ccp(self.oriX, self.oriY + moveY)), CCScaleTo:create(kAnimationTime*4, 1, 1)))
			actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(kAnimationTime*2, ccp(self.oriX, self.oriY)), CCScaleTo:create(kAnimationTime*2, 1, scaleY)))
			actSeq:addObject(CCScaleTo:create(kAnimationTime*2, 1, 1))

			self:runAction(CCSequence:create(actSeq))
		end
		currentPosition = currentPosition + animalWidth
		batch:addChild(animal)
		if i == 6 then currentPosition = currentPosition - animalWidth end
	end
	local function onStartAnimation()
		for i = 0, 5 do
			local animal = batch:getChildAt(i)
			if animal then animal:move(i * 0.1) end
		end
	end
	batch:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(onStartAnimation), CCDelayTime:create(1.3))))
	batch:setPositionX(-currentPosition/2 + 3)

	local function addLoadingTextAnimation()
		local textSprite = Sprite:createWithSpriteFrameName("loading_progress_text instance 10000")
		textSprite:setPosition(ccp(animaWidth/2 - 80, 30 - animaHeight/2))
		batch:addChild(textSprite)
		for i = 1, 3 do
			local dotSprite = Sprite:createWithSpriteFrameName("loading_progress_dot instance 10000")
			dotSprite:setPosition(ccp(animaWidth/2 - 25 + 16 * i, 30 - animaHeight/2))
			dotSprite:setOpacity(0)
			batch:addChild(dotSprite)
			local function startRepeatAnim()
				local actSeq = CCArray:create()
				actSeq:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(0.1), CCScaleTo:create(0.1, 1)))
				actSeq:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(0.5), CCScaleTo:create(0.5, 0.5)))
				dotSprite:runAction(CCRepeatForever:create(CCSequence:create(actSeq)))
			end
			dotSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.15*(i-1)), CCCallFunc:create(startRepeatAnim)))
		end
	end

	if not useSystemFnt then
		addLoadingTextAnimation()
	else
		labelText = labelText or Localization:getInstance():getText("dis.connect.connecting.date.tips")
		local label = TextField:create(labelText, nil, 24)
		label:setPositionY(-44)
		container:addChild(label)
	end

	return container
end

--!!!经过1.42修改labelText参数已经无效
function CountDownAnimation:createLoadingAnimation2(labelText)
	FrameLoader:loadArmature("skeleton/loading_animation")
	local container	= Layer:create()
--	container:changeWidthAndHeight(380, 410)
	local bubble = ArmatureNode:create("bubble")
	bubble:setPosition(ccp(-108, 200))
	bubble:playByIndex(0)
	bubble:update(0.001)

	local font = ArmatureNode:create("font")
	font:setPosition(ccp(-60, -100))
	font:playByIndex(0)
	font:update(0.001)

	container:addChild(bubble)
	container:addChild(font)
	return container
end

function CountDownAnimation:_createNetworkAnimationLayer(scene, onCloseButtonTap, labelText, useSystemFnt)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local origin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	local layer = LayerColor:create()
	layer:changeWidthAndHeight(visibleSize.width, visibleSize.height)
	layer:setColor(ccc3(0, 0, 0))
	layer:setPosition(ccp(origin.x, origin.y))
	layer:setTouchEnabled(true, 0, true)
	layer:setOpacity(255*0.35)
	layer.hitTestPoint = function(self, worldPosition, useGroupTest)
		return true
	end

	local loadingAnimation = CountDownAnimation:createLoadingAnimation(labelText, useSystemFnt)
	local size = loadingAnimation:getGroupBounds().size
	loadingAnimation:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
	layer:addChild(loadingAnimation)
	if onCloseButtonTap then 
		-- 3s之后才显示x,
		loadingAnimation:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(3),
			CCCallFunc:create(function( ... )
				local closeButton = CountDownAnimation:buildCloseBtn(onCloseButtonTap)
				local size = loadingAnimation:getGroupBounds().size
				closeButton:setPosition(ccp(size.width / 2 - 20, size.height / 2 - 20))
				loadingAnimation:addChild(closeButton)
			end)
		))
	end

	return layer
end

function CountDownAnimation:createNetworkAnimationInHttp(scene, onCloseButtonTap)
	local layer = CountDownAnimation:_createNetworkAnimationLayer(scene, onCloseButtonTap)
	local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local origin = CCDirector:sharedDirector():ori_getVisibleOrigin()
	layer:setPositionY(layer:getPositionY() - visibleSize.height + _G.__EDGE_INSETS.top)
	layer.panelLuaName = "createNetworkAnimationInHttp"
	PopoutManager:sharedInstance():add(layer, false, false)
	
	return layer
end

function CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap, labelText, useSystemFnt)
	local layer = CountDownAnimation:_createNetworkAnimationLayer(scene, onCloseButtonTap, labelText, useSystemFnt)
	if(scene) then
		scene:addChild(layer, SceneLayerShowKey.TOP_LAYER)
	end

	return layer
end

local backToHomeSceneAnimationCount = 3
local backToHomeSceneAnimationList = nil
local backToHomeSceneAnimationIndex = 0

local function getBackToHomeSceneAnimationList()
	if(backToHomeSceneAnimationList ~= nil) then
		return backToHomeSceneAnimationList
	end

	backToHomeSceneAnimationList = {}
	for i = 1, backToHomeSceneAnimationCount do
		backToHomeSceneAnimationList[i] = i
	end

	for i = 1, 7 do
		local a = math.random(backToHomeSceneAnimationCount)
		local b = math.random(backToHomeSceneAnimationCount)
		local t = backToHomeSceneAnimationList[a]
		backToHomeSceneAnimationList[a] = backToHomeSceneAnimationList[b]
		backToHomeSceneAnimationList[b] = t
	end

	return backToHomeSceneAnimationList
end

local function getBackToHomeSceneAnimationName()
	local list = getBackToHomeSceneAnimationList()
	local name = "ui/backToHomeScene/image" .. list[backToHomeSceneAnimationIndex + 1] .. ".png"
	backToHomeSceneAnimationIndex = (backToHomeSceneAnimationIndex + 1) % backToHomeSceneAnimationCount
	return name
end

function CountDownAnimation:createBackToHomeSceneAnimation(scene)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local origin = CCDirector:sharedDirector():ori_getVisibleOrigin()


	local layer = Layer:create()
	layer:changeWidthAndHeight(winSize.width, winSize.height)
--	layer:setColor(ccc3(0, 0, 0))
	layer:setPosition(ccp(origin.x, origin.y))
	layer:setTouchEnabled(false, 0, false)
--	layer:setOpacity(255*0.35)

	if(scene) then
		scene:addChild(layer, SceneLayerShowKey.TOP_LAYER)
	end


	local sprite = Sprite:create("ui/backToHomeScene/bcgd.png")
--	local sprite = Sprite:createWithSpriteFrameName("thunder_effect20000")
	local container = SpriteBatchNode:createWithTexture(sprite:getTexture())
	layer:addChild(container)

	local bcgdW = sprite:getTexture():getPixelsWide()
	local bcgdH = sprite:getTexture():getPixelsHigh()
	local m = math.ceil(visibleSize.width / bcgdW)
	local n = math.ceil(visibleSize.height / bcgdH)

	for i=1,m do
		for j=1,n do
			local bcgdSprite = Sprite:create("ui/backToHomeScene/bcgd.png")
			bcgdSprite:setAnchorPoint(ccp(0,0))
			bcgdSprite:setPosition(ccp((i-1)*bcgdW, (j-1)*bcgdH))
			container:addChild(bcgdSprite)
		end
	end

	local imageName = getBackToHomeSceneAnimationName()
	local infoSprite = Sprite:create(imageName)
	local infoW = infoSprite:getTexture():getPixelsWide()
	local infoH = infoSprite:getTexture():getPixelsHigh()
	infoSprite:setAnchorPoint(ccp(0,0))
	infoSprite:setPosition(ccp((visibleSize.width-infoW)*0.5,(visibleSize.height-infoH)*0.5))
	layer:addChild(infoSprite)


	sprite:dispose()
	--[[
	layer.hitTestPoint = function(self, worldPosition, useGroupTest)
		return true
	end

	local loadingAnimation = CountDownAnimation:createLoadingAnimation(labelText)
	local size = loadingAnimation:getGroupBounds().size
	loadingAnimation:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
	layer:addChild(loadingAnimation)

	if onCloseButtonTap then 
		-- 3s之后才显示x,
		loadingAnimation:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(3),
			CCCallFunc:create(function( ... )
				local closeButton = CountDownAnimation:buildCloseBtn(onCloseButtonTap)
				local size = loadingAnimation:getGroupBounds().size
				closeButton:setPosition(ccp(size.width / 2 - 20, size.height / 2 - 20))
				loadingAnimation:addChild(closeButton)
			end)
		))
	end

	return layer
	]]


	return layer
end

function CountDownAnimation:createBindAnimation(scene, onCloseButtonTap)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local origin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	local layer = LayerColor:create()
	layer:changeWidthAndHeight(winSize.width, winSize.height)
	layer:setColor(ccc3(0, 0, 0))
	layer:setPosition(ccp(origin.x, origin.y))
	layer:setTouchEnabled(true, 0, true)
	layer:setOpacity(255*0.35)
	layer.hitTestPoint = function(self, worldPosition, useGroupTest)
		return true
	end
	scene:addChild(layer, SceneLayerShowKey.TOP_LAYER)

	local loadingAnimation = CountDownAnimation:createLoadingAnimation(Localization:getInstance():getText("loading.tips.binding.account"))
	local size = loadingAnimation:getGroupBounds().size
	loadingAnimation:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
	layer:addChild(loadingAnimation)
	
	local closeButton = CountDownAnimation:buildCloseBtn(onCloseButtonTap)
	local size = loadingAnimation:getGroupBounds().size
	closeButton:setPosition(ccp(size.width / 2 - 20, size.height / 2 - 20))
	loadingAnimation:addChild(closeButton)

	return layer
end

function CountDownAnimation:createSyncAnimation(parent)
	local winSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local winOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	local container = Sprite:createEmpty()
	local back = Sprite:createWithSpriteFrameName("loading_ico_circle instance 10000")	
	local icon = Sprite:createWithSpriteFrameName("loading_ico_turn instance 10000")

	container:setCascadeOpacityEnabled(true)
	back:setCascadeOpacityEnabled(true)
	icon:setCascadeOpacityEnabled(true)

	container:setOpacity(0)
	container:addChild(back)
	container:addChild(icon)
	
	local contentSize = back:getContentSize()
	local x = winSize.width - contentSize.width
	local y = winOrigin.y + contentSize.height
	container:setPosition(ccp(x, y))

	local addedTo = parent
	if addedTo == nil then addedTo = Director:sharedDirector():getRunningScene() end
	if addedTo then
		container:runAction(CCFadeIn:create(0.2))
		icon:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 180)))
		addedTo:addChild(container, SceneLayerShowKey.POP_OUT_LAYER)
	end

	container.hide = function( self, delayTime )
		local function onSyncAnimationFinished()  
			if self and not self.isDisposed then self:removeFromParentAndCleanup(true)  end
		end
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(delayTime))
		array:addObject(CCFadeOut:create(0.1))
		array:addObject(CCCallFunc:create(onSyncAnimationFinished))
		if self and not self.isDisposed then self:runAction(CCSequence:create(array)) end
	end

	return container
end

function CountDownAnimation:createShareProcessingAnimation(scene)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local origin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	local layer = LayerColor:create()
	layer:changeWidthAndHeight(winSize.width, winSize.height)
	layer:setColor(ccc3(0, 0, 0))
	layer:setPosition(ccp(origin.x, origin.y))
	layer:setTouchEnabled(true, 0, true)
	layer:setOpacity(255*0.35)
	layer.hitTestPoint = function(self, worldPosition, useGroupTest)
		return true
	end
	scene:addChild(layer, SceneLayerShowKey.TOP_LAYER)

	local loadingAnimation = CountDownAnimation:createLoadingAnimation(Localization:getInstance():getText("share.feed.sending.tips"))
	local size = loadingAnimation:getGroupBounds().size
	loadingAnimation:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
	layer:addChild(loadingAnimation)

	return layer
end

function CountDownAnimation:buildCloseBtn(onCloseButtonTap)
	local closeButtonSprite = Sprite:createWithSpriteFrameName("commonloadingclose instance 10000")
	local closeButton = Layer:create()
	closeButtonSprite:setOpacity(160)
	closeButton:addChild(closeButtonSprite)
	closeButton:setTouchEnabled(true)
	closeButton:setButtonMode(true)
	closeButton:addEventListener(DisplayEvents.kTouchTap, onCloseButtonTap)
	closeButton.name = "close"
	return closeButton
end

function CountDownAnimation:buildBubbleCloseBtn(onCloseButtonTap)
	
	local closeBtn = ResourceManager:sharedInstance():buildGroup("ui_buttons/ui_button_close_cloud")
	closeBtn:setScale(0.75)
	closeBtn:setPositionX(125)
	closeBtn:setPositionY(190)
	closeBtn.name = "close"
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,onCloseButtonTap)

	return closeBtn
end

function CountDownAnimation:createActivityAnimation(scene,onCloseButtonTap,actSource)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local visibleSize = CCDirector:sharedDirector():ori_getVisibleSize()
	local origin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	local loadingAnimation = CountDownAnimation:createLoadingAnimation(
		Localization:getInstance():getText("activity.center.loading.tip") --"精彩内容加载中，请稍候~"
	)
	-- local size = loadingAnimation:getGroupBounds().size
	-- loadingAnimation:setPosition(ccp(visibleSize.width/2,visibleSize.height/2))
	-- layer:addChild(loadingAnimation)
	if onCloseButtonTap then
		local animBeginTime = os.time()
		local function onCloseButtonTapWrapper()
			local liveTime = os.time() - animBeginTime
			DcUtil:UserTrack({
				category = 'activity',
				sub_category = 'close_countdown_animation',
				act_source = actSource,
				total_time = liveTime,
			})
			if onCloseButtonTap then onCloseButtonTap() end
		end
		local closeButton = CountDownAnimation:buildCloseBtn(onCloseButtonTapWrapper)
		local size = loadingAnimation:getGroupBounds().size
		closeButton:setPosition(ccp(size.width / 2 - 20, size.height / 2 - 20))
		loadingAnimation:addChild(closeButton)
	end

	if not scene then 
		loadingAnimation:dispose()
		-- layer:dispose()
	else
		loadingAnimation:setPosition(ccp(visibleSize.width/2,-visibleSize.height/2))

		loadingAnimation.panelLuaName = "createActivityAnimation"
		PopoutManager:sharedInstance():add(loadingAnimation,true,false)

		local oldRemoveFromParentAndCleanup = loadingAnimation.removeFromParentAndCleanup
		loadingAnimation.removeFromParentAndCleanup = function(s,cleanup)
			loadingAnimation.removeFromParentAndCleanup = oldRemoveFromParentAndCleanup
			PopoutManager:sharedInstance():remove(loadingAnimation,cleanup)
		end
	end

	return loadingAnimation
end

local _EnterBackgroundEvents = {}
function CountDownAnimation:addEnterBackgroundListener(animation, onEnterBackground)
	if not animation then return end

	local function listener()
		if onEnterBackground then onEnterBackground() end
	end
	_EnterBackgroundEvents[animation] = listener
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterBackground, listener)
end

function CountDownAnimation:removeEnterBackgroundListener(animation)
	if not animation then return end

	local listener = _EnterBackgroundEvents[animation]
	if listener then
		GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterBackground, listener)
		_EnterBackgroundEvents[animation] = nil
	end
end

local _EnterForegroundEvents = {}
function CountDownAnimation:addEnterForegroundListener(animation, onEnterForeground)
	if not animation then return end

	local function listener()
		if onEnterForeground then onEnterForeground() end
	end
	_EnterForegroundEvents[animation] = listener
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterForeground, listener)
end

function CountDownAnimation:removeEnterForegroundListener(animation)
	if not animation then return end

	local listener = _EnterForegroundEvents[animation]
	if listener then
		GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterForeground, listener)
		_EnterForegroundEvents[animation] = nil
	end
end