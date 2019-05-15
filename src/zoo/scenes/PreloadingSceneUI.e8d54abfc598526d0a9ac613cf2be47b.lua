require "zoo.scenes.AnimationScene"
require "zoo.scenes.PanelsScene"
require "zoo.scenes.GameChoiceScene"
require "zoo.editor.EditorGameScene"
require "zoo.editor.KeyboardTestScene"
require "zoo.scenes.ReplayChoiceScene"
require "zoo.scenes.component.loadingScene.LoginButton"
require "zoo.util.AdvertiseSDK"
require "zoo.panel.component.common.VerticalScrollable"
require "zoo.util.TextUtil"

local showAntiAddict = true

PreloadingSceneUI = class()

local function addSpriteFramesWithFile( plistFilename, textureFileName )
	local prefix = string.split(plistFilename, ".")[1]
	local realPlistPath = plistFilename
  	local realPngPath = textureFileName
  	if __use_small_res then  
	    realPlistPath = prefix .. "@2x.plist"
	    realPngPath = prefix .. "@2x.png"
  	end
  	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(realPlistPath, realPngPath)
  	return realPngPath, realPlistPath
end

function PreloadingSceneUI.openAgreement(title, prefixContent)
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local scene = Director:sharedDirector():getRunningScene()
	if not scene or scene.isDisposed then return end

	local layer = LayerColor:create()
	layer:changeWidthAndHeight(vSize.width, vSize.height)
	layer:setColor(ccc3(255, 255, 255))
	layer:setPositionXY(vOrigin.x, vOrigin.y)
	layer:setTouchEnabled(true, 0, true)
	local title = TextField:create(Localization:getInstance():getText(title), nil, 36)
	title:setColor(ccc3(0, 0, 0))
	title:setPositionXY(vSize.width / 2, vSize.height - 60)
	layer:addChild(title)
	local scrollable = VerticalScrollable:create(vSize.width - 120, vSize.height - 260)
	local layout = VerticalTileLayout:create(vSize.width - 120)
	local platform = "win32"
	if __ANDROID then platform = "android"
	elseif __IOS then platform = "ios" 
	elseif __WP8 then platform = "wp" end
	local counter = 1
	local function onTimeOut()
		local key = prefixContent..platform..tostring(counter)
		local value = Localization:getInstance():getText(key, {n = '\n', s = '　'})
		if key == value or layer.isDisposed then return end
		local text = TextField:create(nil, nil, 28)
		text:setColor(ccc3(0, 0, 0))
		text:setDimensions(CCSizeMake(vSize.width - 120, 0))
		text:setString(value)
		text:setAnchorPoint(ccp(0, 1))
		local item = ItemInClippingNode:create()
		item:setParentView(scrollable)
		item:setContent(text)
		item:setHeight(text:getContentSize().height)
		layout:addItem(item)
		layout:__layout()
		scrollable:updateScrollableHeight()
		counter = counter + 1
		setTimeOut(onTimeOut, 1 / 120)
	end
	setTimeOut(onTimeOut, 1 / 120)
	scrollable:setContent(layout)
	scrollable:updateScrollableHeight()
	scrollable:setIgnoreHorizontalMove(true)
	scrollable:setPositionXY(60, vSize.height - 120)
	local scrollBounding = scrollable:getGroupBounds()
	layer:addChild(scrollable)
	local button = Layer:create()
	local pngPath, plistPath = addSpriteFramesWithFile( "flash/loading.plist", "flash/loading.png" )
	local buttonImg = Sprite:createWithSpriteFrameName("preloadingscene_greenbuttonline0000") 
	local buttonImgSize = buttonImg:getContentSize()
	button:addChild(buttonImg)
	local buttonText = TextField:create(Localization:getInstance():getText("loading.agreement.layer.button"), nil, 40)
	buttonText:setColor(ccc3(37, 184, 82))
	button:addChild(buttonText)
	button:setPositionXY(vSize.width / 2, 70)
	layer:addChild(button)
	local function onButton()
		layer:dispatchEvent(Event.new(Events.kComplete, nil, layer))
		--layer:removeFromParentAndCleanup(true)
		PopoutManager:sharedInstance():remove(layer, true)
		-- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistPath)
	end
	button:setTouchEnabled(true)
	button:setButtonMode(true)
	button:addEventListener(DisplayEvents.kTouchTap, onButton)
	--scene:addChild(layer)
	-- layer:runAction(CCMoveTo:create(0.2, ccp(vOrigin.x,  - vSize.height)))
	layer:setPosition(ccp(vOrigin.x,  - vSize.height))
	layer.onKeyBackClicked = function()
		onButton()
	end
	--if _G.isLocalDevelopMode then printx(0, "layer parent: ",layer:getParent()) end
	PopoutManager:sharedInstance():add(layer, false, false)

	return layer
end

function PreloadingSceneUI.showAliQuickPayAgreement()
	return PreloadingSceneUI.openAgreement("alipay.agreement.kuaifu.title", "alipay.agreement.kuaifu.text.")
end

function PreloadingSceneUI.showUserAgreement()
	require('zoo.webview.WebView'):openUserArgument()
end

local function userAgreementTexts()
	local checked = CCUserDefault:sharedUserDefault():getBoolForKey("game.user.agreement.checked")
	-- if checked then return end
	local userAgreementLayer = Layer:create()
	-- local box = Sprite:createWithSpriteFrameName("preloadingscene_box0000")
	-- box:setAnchorPoint(ccp(0, 1))
	-- box:setVisible(false)
	-- local check = Sprite:createWithSpriteFrameName("preloadingscene_check0000")
	-- check:setAnchorPoint(ccp(0, 0))
	-- check:setVisible(false)

	local platformName = StartupConfig:getInstance():getPlatformName()
	local textStr = "login.panel.intro.new2"
	if platformName == "uc" then
		textStr = "login.panel.intro.new1"
	end

	-- local boxSize = box:getContentSize()
	local posX = 10

	local userAgreementText = TextField:create(Localization:getInstance():getText(textStr), nil, 28)
	userAgreementText:setAnchorPoint(ccp(0, 1))
	userAgreementText:setColor(ccc3(255, 255, 255))
	userAgreementText:enableShadow(CCSizeMake(2, -2), 1, 1)

	-- userAgreementLayer:addChild(box)
	userAgreementText:setPositionXY(posX, -2)
	userAgreementLayer:addChild(userAgreementText)
	local textSize = userAgreementText:getContentSize()
	posX = posX + textSize.width

	-- check:setPositionXY(box:getPositionX(), box:getPositionY() - boxSize.height + 3)
	-- userAgreementLayer:addChild(check)
	userAgreementLayer.checked = true
	-- local boxTouchLayer = LayerColor:create()
	-- boxTouchLayer:changeWidthAndHeight(boxSize.width + 20, boxSize.height + 20)
	-- boxTouchLayer:setPositionX(box:getPositionX() - 10)
	-- boxTouchLayer:setPositionY(box:getPositionY() - boxSize.height - 10)
	-- boxTouchLayer:setOpacity(0)
	-- local function onBoxTapped()
	-- 	check:setVisible(not check:isVisible())
	-- 	userAgreementLayer.checked = check:isVisible()
	-- end
	-- boxTouchLayer:setTouchEnabled(true)
	-- boxTouchLayer:addEventListener(DisplayEvents.kTouchTap, onBoxTapped)
	-- userAgreementLayer:addChild(boxTouchLayer)
	-- userAgreementLayer.touchLayer = boxTouchLayer

	local function onAgreementLinkTapped()
		if __WIN32 then
			require "zoo.scenes.component.loadingScene.UserAgreementAlertPanel"
			UserAgreementAlertPanel:create():popout()
		end
		require('zoo.webview.WebView'):openUserArgument()
	end
	local agreementLink = TextUtil:buildTextLink(Localization:getInstance():getText("loading.agreement.box.link"), onAgreementLinkTapped, 28, ccc3(4, 170, 255), -20)
	local agreementLinkSize = agreementLink:getContentSize()
	agreementLink:setPosition(ccp(posX, -2 - agreementLinkSize.height))
	userAgreementLayer:addChild(agreementLink)
	posX = posX + agreementLinkSize.width

	local userAgreementText2 = TextField:create("和", nil, 28)
	userAgreementText2:setAnchorPoint(ccp(0, 1))
	userAgreementText2:setColor(ccc3(255, 255, 255))
	userAgreementText2:enableShadow(CCSizeMake(2, -2), 1, 1)
	userAgreementText2:setPositionXY(posX, -2)
	userAgreementLayer:addChild(userAgreementText2)
	posX = posX + userAgreementText2:getContentSize().width

	local function onPrivacyLinkTapped()
		if __WIN32 then
			CommonTip:showTip("隐私政策")
		end
		require('zoo.webview.WebView'):openPrivacyArgument()
	end
	local privacyLink = TextUtil:buildTextLink("《隐私政策》", onPrivacyLinkTapped, 28, ccc3(4, 170, 255), -20)
	local privacyLinkSize = privacyLink:getContentSize()
	privacyLink:setPosition(ccp(posX, - 2 - privacyLinkSize.height))
	userAgreementLayer:addChild(privacyLink)
	posX = posX + privacyLinkSize.width

	-- 计算位置
	local bounding = userAgreementLayer:getGroupBounds().size
	userAgreementLayer:setContentSize(CCSizeMake(bounding.width, bounding.height))

	local copyrightLayer = Layer:create()
	local copyright = TextField:create(Localization:getInstance():getText("loading.agreement.copyright", {s = ' '}), nil, 20)
	copyright:setAnchorPoint(ccp(0, 1))
	copyright:setColor(ccc3(255, 255, 255))
	copyright:enableShadow(CCSizeMake(2, -2), 1, 1)
	local copyrightSize = copyright:getContentSize()
	copyrightLayer:addChild(copyright)
	copyrightLayer:setContentSize(CCSizeMake(copyrightSize.width, copyrightSize.height))

	return userAgreementLayer, copyrightLayer
end

local function antiAddictionText()
	local text = TextField:create("", nil, 18, nil, kCCTextAlignmentCenter)
	text:setString(Localization:getInstance():getText("loading.agreement.antiaddiction", {n = '\n'}))
	text:setColor(ccc3(255, 255, 255))
	text:enableShadow(CCSizeMake(2, -2), 1, 1)
	text:setVisible(showAntiAddict)
	return text
end


---------------------------------------------------------------------

function PreloadingSceneUI:setFBIconVisible(scene,visible)
	scene.startButton.fbIcon:setVisible(visible)
	if visible then 
		scene.startButton.textLabel:setPositionX(30)
	else
		scene.startButton.textLabel:setPositionX(0)
	end
end

function PreloadingSceneUI:addForCuccwo(parent)
	if StartupConfig:getInstance():getPlatformName() == "cuccwo" then 
		self.cuccwoPng = addSpriteFramesWithFile( "materials/cuccwo.plist", "materials/cuccwo.png" )
		local cuccwo = Sprite:createWithSpriteFrameName("cuccwo10000")
		cuccwo:setPosition(ccp(720,920))
		parent:addChild(cuccwo)
	end
end

function PreloadingSceneUI:removeForCuccwo()
	if StartupConfig:getInstance():getPlatformName() == "cuccwo" then
		if self.cuccwoPng then 
			CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(self.cuccwoPng))
		end
	end
end

function PreloadingSceneUI:hideAntiAddiction( scene )
	if scene and scene.antiAddictionSp and (not scene.antiAddictionSp.isDisposed) then
		scene.antiAddictionSp:setVisible(false)
	end
end

function PreloadingSceneUI:initUI( scene )
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local processor = require 'zoo.loader.DynamicUpdateProcessor'
	local logoPng, logo = processor:getLogo()
	logo = Sprite.new(logo)
	local loadingPng = addSpriteFramesWithFile( "flash/loading.plist", "flash/loading.png" )
	-- self:addForCuccwo(logo)
	if _G.useTraditionalChineseRes then logo = Sprite:createWithSpriteFrameName("logo_zh_tw0000") end
	local realvSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local realvOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	local scale = realvSize.height/1280
    if winSize.height / winSize.width > 1.8 then
        scale = realvSize.height/1440
    end
	if winSize.height < realvSize.height then
        local logoSize = logo:getContentSize()
        scale = realvSize.height/logoSize.height
    end
    scale = math.max(scale, realvSize.width/960)
	logo:setScale(scale)
	logo:setPosition(ccp(realvSize.width/2, realvSize.height/2 + realvOrigin.y))
	scene:addChild(logo)


	local antiAddictionSp = Sprite:create(SpriteUtil:getRealResourceName("materials/anti_addiction.png"))
	antiAddictionSp:setAnchorPoint(ccp(0.5, 0))
	antiAddictionSp:setPosition(ccp(winSize.width/2, origin.y))
	local antiSpSize = antiAddictionSp:getContentSize()
	antiAddictionSp:setScale(math.min(math.min(winSize.width/antiSpSize.width, 1), scale))
	scene.antiAddictionSp = antiAddictionSp
	scene:addChild(antiAddictionSp)

	if(false) then
		local test = require("zoo/testGaf")
		test:addObjectsToScene(scene)
	end

	local progressContainer = CocosObject:create()
	local background = Sprite:createWithSpriteFrameName("loading_progress_background0000")
	local bar = Sprite:createWithSpriteFrameName("loading_progress_bar0000")
	local progressBar = ProgressBar:create(bar)
	local contentSize = bar:getContentSize()
	bar:setAnchorPoint(ccp(0, 0))
	bar:setPosition(ccp((-contentSize.width)/2, (-contentSize.height)/2))
	progressBar:setPercentage(0)
	background:setPosition(ccp(1, 0))

	local textureStar = Sprite:createWithSpriteFrameName("loading_star_icon0000")
	local starLayer = SpriteBatchNode:createWithTexture(textureStar:getTexture())
	starLayer:setPosition(ccp(0, -20))

	for i=0,4 do
		local staticStar = Sprite:createWithSpriteFrameName("loading_star_icon0000")
		staticStar:setPosition(ccp(math.random()*10, 10 * i))
		staticStar:setScale(1 + math.random()*0.6)
		staticStar:runAction(CCRepeatForever:create(CCRotateBy:create(0.3, math.floor(120 + math.random()*40))))
		starLayer:addChild(staticStar)
	end
	local function onCreateStarEmitter()
		local hideTime = 1 + math.random() * 0.5
		local staticStar = Sprite:createWithSpriteFrameName("loading_star_icon0000")
		staticStar:setPosition(ccp(math.random()*10, math.random()*50))
		staticStar:setScale(0.25 + math.random()*0.2)
		staticStar:runAction(CCSpawn:createWithTwoActions(CCMoveBy:create(hideTime, ccp(-140 - math.random()*30, 0)), CCFadeOut:create(hideTime)))
		starLayer:addChild(staticStar)
	end
	starLayer:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(onCreateStarEmitter))))

	textureStar:dispose()

	local progressOffsetY = 0
	if __isWildScreen then  progressOffsetY = -60 end
	-- if __isWildScreen then  progressOffsetY = -100 end

	progressContainer.contentSize = {width=contentSize.width, height=contentSize.height}
	progressContainer.starLayer = starLayer
	progressContainer.progressBar = progressBar
	progressContainer:setPosition(ccp(winSize.width/2, origin.y + 270 + progressOffsetY))
	progressContainer:addChild(background)
	progressContainer:addChild(progressBar.display)
	progressContainer:addChild(starLayer)
	progressContainer.setPercentage = function ( scene, value ) 
		if value > 1 then value = 1 end
		if value < 0 then value = 0 end
		local contentSize = scene.contentSize
		local transformedWidth = contentSize.width * value
		scene.progressBar:setPercentage(value * 100) 
		scene.starLayer:setPositionX(-contentSize.width/2 + transformedWidth)
	end
	scene:addChild(progressContainer)
	scene.progressBar = progressContainer

	local statusLabelShadow = TextField:create("", "Helvetica", 26, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	statusLabelShadow:setPosition(ccp(winSize.width/2, origin.y + 169 + progressOffsetY))
	statusLabelShadow:setColor(ccc3(46, 76, 38))
	scene:addChild(statusLabelShadow)
	scene.statusLabelShadow = statusLabelShadow

	local statusLabel = TextField:create("", "Helvetica", 26, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	statusLabel:setPosition(ccp(winSize.width/2, origin.y + 170 + progressOffsetY))
	scene:addChild(statusLabel)
	scene.statusLabel = statusLabel

	--防沉迷临时加
	-- local preventWallowShadow = TextField:create("", "Helvetica", 26, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	-- preventWallowShadow:setPosition(ccp(winSize.width/2, origin.y + 119 + progressOffsetY))
	-- preventWallowShadow:setColor(ccc3(46, 76, 38))
	-- scene:addChild(preventWallowShadow)
	-- scene.preventWallowShadow = preventWallowShadow

	-- local preventWallowLabel = TextField:create("抵制不良游戏  拒绝盗版游戏  注意自我保护  谨防上当受骗\n适度游戏益脑  沉迷游戏伤身  合理安排时间  享受健康生活", "Helvetica", 24, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	local preventWallowLabel = TextField:create("", "Helvetica", 24, CCSizeMake(winSize.width - 50, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	preventWallowLabel:setPosition(ccp(winSize.width/2, origin.y + 3 + progressOffsetY))
	preventWallowLabel:setColor(ccc3(0,0,255));
	scene:addChild(preventWallowLabel)
	scene.preventWallowLabel = preventWallowLabel

	if not showAntiAddict then
		local loginTipsLabel = TextField:create(Localization:getInstance():getText("loading.tips.signup"), "Helvetica", 26, CCSizeMake(winSize.width - 100, 40), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
		loginTipsLabel:setColor(ccc3(255, 255, 255))
		loginTipsLabel:setPosition(ccp(winSize.width/2, 110))
		loginTipsLabel:enableShadow(CCSizeMake(2, -2), 1, 1)
		scene:addChild(loginTipsLabel)
		scene.loginTipsLabel = loginTipsLabel
		scene.loginTipsLabel:setVisible(false) -- default hide
	end

if not __WP8 then
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(logoPng))
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(loadingPng))
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename('materials/anti_addiction.png'))
	-- self:removeForCuccwo()
end
  
	local warning = ""
	if __use_small_res and __IOS and not showAntiAddict then warning = "  "..Localization:getInstance():getText("loading.tips.low.ram") end
	local md5 = ""..warning --"."..tostring(ResourceLoader.getCurVersion())
	-- local versionLabel = TextField:create("V"..tostring(_G.bundleVersion) .. md5, "Helvetica", 24, CCSizeMake(0,0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	local versionLabel = TextField:create(md5, "Helvetica", 24, CCSizeMake(0,0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
	versionLabel:setPosition(ccp(winSize.width/2, origin.y + 30))
	scene:addChild(versionLabel)
	scene.versionLabel = versionLabel
	versionLabel:setVisible(CCUserDefault:sharedUserDefault():getBoolForKey("game.user.agreement.checked"))

	progressContainer:setPercentage(0)




end

function PreloadingSceneUI:buildGuestLoginButton(scene, onTouchCallback)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local progressOffsetY = 0
	if __isWildScreen then  progressOffsetY = -50 end
	if __isWildScreen then  progressOffsetY = -90 end

	local basePosY = origin.y

	-- local text = antiAddictionText()
	-- scene.antiAddictionText = text
	-- scene:addChild(text)

	local agreement, copyright = userAgreementTexts()
	if agreement and copyright then
		copyright:setPositionXY((winSize.width - copyright:getContentSize().width) / 2, basePosY + 50)
		scene:addChild(copyright)
		agreement:setPositionXY((winSize.width - agreement:getContentSize().width) / 2, basePosY + 100)
		scene:addChild(agreement)
		-- text:setPositionXY(winSize.width / 2, basePosY + 130)
		basePosY = basePosY + 130
	else
		-- text:setPositionXY(winSize.width / 2, basePosY + 60)
		basePosY = basePosY + 70
	end

	local startButton = LoginButton:create(1, Localization:getInstance():getText("button.start.game.loading"))
	startButton:setColorMode( kGroupButtonColorMode.blue )
	startButton:setEnabled(true)
	scene.startButton = startButton

	scene:addChild(startButton.groupNode)

	local agreement, copyright = userAgreementTexts()
	local function onTouchConnectButton( evt )
		if agreement and not agreement.isDisposed then
			if not agreement.checked then
				CommonTip:showTip(Localization:getInstance():getText("loading.agreement.button.reject"))
			else
				if agreement.touchLayer and not agreement.touchLayer.isDisposed then
					agreement.touchLayer:setTouchEnabled(false)
				end
				if onTouchCallback ~= nil then onTouchCallback() end
				CCUserDefault:sharedUserDefault():setBoolForKey("game.user.agreement.checked", agreement.checked)
			end 
		else
			if onTouchCallback ~= nil then onTouchCallback() end
		end
	end 
	startButton:addEventListener(DisplayEvents.kTouchTap, onTouchConnectButton)

	local startButtonSize = startButton:getGroupBounds().size
	startButton:setPosition(ccp(winSize.width/2, basePosY + 70 + startButtonSize.height / 2))
	startButton:useBubbleAnimation()
end

function PreloadingSceneUI:buildOAuthLoginButtons(scene)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local marginScale = 1
	local buttonScale = 1.35
	if __isWildScreen then  marginScale = 0.8 end
	if __isWildScreen then  
		marginScale = 0.7 
		buttonScale = 0.8*1.35
	end

	local basePosY = origin.y

	-- local text = antiAddictionText()
	-- scene.antiAddictionText = text
	-- scene:addChild(text)

	local agreement, copyright = userAgreementTexts()
	if agreement and copyright then
		copyright:setPositionXY((winSize.width - copyright:getContentSize().width) / 2, basePosY + 50)
		scene:addChild(copyright)
		agreement:setPositionXY((winSize.width - agreement:getContentSize().width) / 2, basePosY + 100)
		scene:addChild(agreement)
		-- text:setPositionXY(winSize.width / 2, basePosY + 130)
		basePosY = basePosY + 110 * marginScale
	else
		-- text:setPositionXY(winSize.width / 2, basePosY + 60)
		basePosY = basePosY + 50 * marginScale
	end

	local guestButton = LoginButton:create(2, Localization:getInstance():getText("button.start.game.loading"))
	guestButton:setColorMode( kGroupButtonColorMode.blue ,nil , true )
	guestButton:setEnabled(true)
	scene:addChild(guestButton.groupNode)
	local guestButtonHeight = guestButton:getGroupBounds().size.height
	guestButton:setPosition(ccp(winSize.width/2, basePosY + 30 * marginScale + guestButtonHeight / 2))

	guestButton:setScale(0.65)
	guestButton:useBubbleAnimation()

	basePosY = guestButton:getPositionY() + guestButtonHeight / 2

	local authButton = LoginButton:create(1, Localization:getInstance():getText("button.start.game.loading"))
	authButton:setColorMode( kGroupButtonColorMode.orange )
	scene:addChild(authButton.groupNode)
	local authButtonSize = authButton:getGroupBounds().size
	authButton:setPosition(ccp(winSize.width/2, basePosY + 10 * marginScale + authButtonSize.height / 2 * buttonScale))
	authButton:setEnabled(true)
	authButton:setScale(buttonScale)

	-- authButton:setScale(1.35*buttonScale)
	authButton:useBubbleAnimation()

	authButton.agreement = agreement
	guestButton.agreement = agreement


	
	return authButton, guestButton
end

function PreloadingSceneUI:buildJPOAuthLoginButtons(scene)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local marginScale = 1
	local buttonScale = 1
	if __isWildScreen then  marginScale = 0.8 end
	if __isWildScreen then  
		marginScale = 0.7 
		buttonScale = 0.8
	end

	local basePosY = origin.y

	-- local text = antiAddictionText()
	-- scene.antiAddictionText = text

	local agreement, copyright = userAgreementTexts()
	if agreement and copyright then
		copyright:setPositionXY((winSize.width - copyright:getContentSize().width) / 2, basePosY + 50)
		scene:addChild(copyright)
		agreement:setPositionXY((winSize.width - agreement:getContentSize().width) / 2, basePosY + 100)
		scene:addChild(agreement)
		-- text:setPositionXY(winSize.width / 2, basePosY + 130)
		basePosY = basePosY + 110 * marginScale
	else
		-- text:setPositionXY(winSize.width / 2, basePosY + 60)
		basePosY = basePosY + 50 * marginScale
	end

	local guestText = Localization:getInstance():getText("loading.tips.start.btn.guest")
	local guestButton = LoginButton:create(PlatformAuthEnum.kGuest, guestText)
	guestButton:setColorMode(kGroupButtonColorMode.orange, nil, true)
	guestButton:setEnabled(true)
	local guestButtonScale = 0.7 * buttonScale
	guestButton:setScale(guestButtonScale)
	scene:addChild(guestButton.groupNode)
	local guestButtonHeight = guestButton:getGroupBounds().size.height
	guestButton:setPosition(ccp(winSize.width/2, basePosY + 30 * marginScale + guestButtonHeight / 2 * guestButtonScale))
	guestButton:useBubbleAnimation()

	basePosY = guestButton:getPositionY() + guestButtonHeight / 2

	local authButton1 = LoginButton:create(PlatformAuthEnum.kJPWX, Localization:getInstance():getText("与微信好友玩"))
	authButton1:setColorMode(kGroupButtonColorMode.green, nil, true)
	scene:addChild(authButton1.groupNode)
	authButton1.groupNode:getChildByName("_shadow"):setVisible(false)
	local authButtonSize1 = authButton1:getGroupBounds().size
	authButton1:setPosition(ccp(winSize.width/2, basePosY + 10 * marginScale + authButtonSize1.height / 2 * buttonScale))
	authButton1:setEnabled(true)
	authButton1:setScale(buttonScale)
	authButton1:useBubbleAnimation()

	basePosY = authButton1:getPositionY() + authButtonSize1.height / 2

	local authButton2 = LoginButton:create(PlatformAuthEnum.kJPQQ, Localization:getInstance():getText("与QQ好友玩"))
	-- authButton2.btnType = PlatformAuthEnum.kQQ --创建JPQQ的登录按钮 实际登录还是用QQ
	authButton2:setColorMode(kGroupButtonColorMode.blue, nil, true)
	scene:addChild(authButton2.groupNode)
	authButton2.groupNode:getChildByName("_shadow"):setVisible(false)
	local authButtonSize = authButton2:getGroupBounds().size
	authButton2:setPosition(ccp(winSize.width/2, basePosY + 10 * marginScale + authButtonSize.height / 2 * buttonScale))
	authButton2:setEnabled(true)
	authButton2:setScale(buttonScale)
	authButton2:useBubbleAnimation()

	return authButton1, authButton2, guestButton, agreement
end


function PreloadingSceneUI:createAnimation(startButton)
	startButton:setButtonMode(false)
	local deltaTime = 0.9
	local animations = CCArray:create()
	local originScale = startButton:getScale()
	animations:addObject(CCScaleTo:create(deltaTime, originScale * 0.98, originScale * 1.03))
	animations:addObject(CCScaleTo:create(deltaTime, originScale * 1.01, originScale * 0.96))
	animations:addObject(CCScaleTo:create(deltaTime, originScale * 0.98, originScale * 1.03))
	animations:addObject(CCScaleTo:create(deltaTime, originScale,originScale))
	startButton:runAction(CCRepeatForever:create(CCSequence:create(animations)))

	local btnWithoutShadow = startButton:getChildByName("background")
	local function __onButtonTouchBegin( evt )
		if btnWithoutShadow and not btnWithoutShadow.isDisposed then
			btnWithoutShadow:setOpacity(220)
		end
	end
	local function __onButtonTouchEnd( evt )
		if btnWithoutShadow and not btnWithoutShadow.isDisposed then
			btnWithoutShadow:setOpacity(255)
		end
	end
	startButton:addEventListener(DisplayEvents.kTouchBegin, __onButtonTouchBegin)
	startButton:addEventListener(DisplayEvents.kTouchEnd, __onButtonTouchEnd)
end

function PreloadingSceneUI:removeDebugButtons()
	if (self.buttonLayer) then
		self.buttonLayer:removeFromParentAndCleanup()
	end
end

function PreloadingSceneUI:buildDebugButton(scene, onTouchStartGame)
	local origin = Director:sharedDirector():getVisibleOrigin()
	local size = Director:sharedDirector():getVisibleSize()

	self.buttonLayer = Layer:create()
	self.buttonLayer:setPosition(ccp(origin.x, origin.y))
	scene:addChild(self.buttonLayer)

	local function buildLabelButton( label, x, y, func, width, height, fontSize)
		width = width or 250
		height = height or 80
		local labelLayer = LayerColor:create()
		labelLayer:changeWidthAndHeight(width, height)
		labelLayer:setColor(ccc3(255, 0, 0))
		labelLayer:setPosition(ccp(x - width / 2, y - height / 2))
		labelLayer:setTouchEnabled(true, p, true)
		labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
		self.buttonLayer:addChild(labelLayer)
		local textLabel = TextField:create(label, nil, fontSize or 32)
		textLabel:setPosition(ccp(width/2, height/2))
		labelLayer:addChild(textLabel)
		return labelLayer
	end 

	local function onTouchFcLabel(evt) Director:sharedDirector():pushScene(AnimationScene:create()) end
	local function onTouchReplayLabel(evt) Director:sharedDirector():pushScene(ReplayChoiceScene:create()) end
	local function onTouchGamePlayLabel(evt) Director:sharedDirector():pushScene(GameChoiceScene:create()) end
	local function onTouchUserInterfaceLabel( evt ) onTouchStartGame() end
	local function onTouchAnimationLabel(evt)
		--ProFi:stop()
		--ProFi:writeReport( 'MyProfilingReport.txt' )
		--local sdk = WeChatSDK.new() --AdvertiseSDK.new()
		--sdk:sendLevelMessage(10)
		--sdk:presentLimeiListOfferWall()
		--sdk:presentDomobListOfferWall()
		
		-- Director:sharedDirector():pushScene(PanelsScene:create())
		package.loaded["zoo.test.TestCCParabolaMoveTo"] = nil
		require("zoo.test.TestCCParabolaMoveTo"):createSence()
	end

	if __WIN32 then
		require "zoo.gameTools.GameToolsScene"
		local function onTouchToolsLabel(evt) Director:sharedDirector():pushScene(GameToolsScene:create()) end
		local toolsButton = buildLabelButton("Tools", size.width/2, origin.y + 700, onTouchToolsLabel)
	end
	local fcButton = buildLabelButton("客服工具", size.width/2, origin.y + 580, onTouchFcLabel)
	local animalButton = buildLabelButton("Play Animation", size.width/2, origin.y + 460, onTouchAnimationLabel)
	local gamePlayButton = buildLabelButton("Play Demo", size.width/2, origin.y + 340, onTouchGamePlayLabel)
	local userInterfaceButton = buildLabelButton("Home", size.width/2, origin.y + 220, onTouchUserInterfaceLabel)
	local replayButton = buildLabelButton("Replay", size.width/2, origin.y + 100, onTouchReplayLabel)

	if _G.isCheckPlayNoViewModeActive then
		local replayerScene = ReplayChoiceScene:create()
		Director:sharedDirector():pushScene(replayerScene)
	end
end