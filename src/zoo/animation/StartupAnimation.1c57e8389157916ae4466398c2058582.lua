
local winSize = CCDirector:sharedDirector():getVisibleSize()
local vSize = CCDirector:sharedDirector():getWinSize()
local origin = CCDirector:sharedDirector():getVisibleOrigin()
local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()


local function createBottomText()

	local str = Localization:getInstance():getText('game.guide.panel.skip.text')
	local label = CCLabelTTF:create(str, "Helvetica", 24)
	label:setAnchorPoint(ccp(0, 0))
	label:setPosition(ccp(10, 10))
	local imagePath = "cg/tap_arrow.png"
	local image = CCSprite:create(imagePath)
	image:setAnchorPoint(ccp(0, 0))
	local x = label:getContentSize().width
	image:setPosition(ccp(x + 25, 13))
	image:setScale(1)
	local node = CCNode:create()
	node:setAnchorPoint(ccp(0, 0))
	node:addChild(label)
	node:addChild(image)
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(imagePath))
	return node
end

local function createComic( index, parent )
	local imagePath = "cg/"..index..".png"
	if _G.useTraditionalChineseRes then imagePath = "cg/" .. index .. "_zh_tw.png" end
	local logo = CCSprite:create(imagePath)
	local logoSize = logo:getContentSize()
	local scale = winSize.width/logoSize.width
	logo:setScale(scale)
	logo:setPosition(ccp(winSize.width/2, winSize.height/2))
	logo:setOpacity(0)
	logo:runAction(CCFadeIn:create(0.1))
	parent:addChild(logo)
	parent:addChild(createBottomText())
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(imagePath))
	return logo
end


local function play(onAnimationFinish)
	local layer = CCLayerColor:create(ccc4(0,0,0,255), vSize.width, vSize.height)--CCLayer:create()
	local scene = Scene:create()
	local index = 1
	local images = {}
	images[index] = createComic(index, layer)
	
	local function hideSelectedImage( index )
		local hideIndex = index
		local currentImage = images[index]
		local function onHideAnimationFinish()
			if currentImage then currentImage:removeFromParentAndCleanup(true) end
		end
		if currentImage then currentImage:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(0.1), CCCallFunc:create(onHideAnimationFinish))) end
	end

	local function onTouchCurrentLayer( eventType, x, y )
		hideSelectedImage(index)
		if index < 3 then 
			index = index + 1
			images[index] = createComic(index, layer)
		else
			if onAnimationFinish ~= nil then onAnimationFinish() end
		end
	end	
	layer:registerScriptTouchHandler(onTouchCurrentLayer, false, 0, true)
	layer:setTouchEnabled(true) 
	layer:setPosition(ccp(origin.x, origin.y))
	
	local cocos = CocosObject.new(layer)
	scene:addChild(cocos)
	Director:sharedDirector():replaceScene(scene)
end

local StartupAnimation = {}
function StartupAnimation:play(onAnimationFinish)
	play(onAnimationFinish)
end
return StartupAnimation