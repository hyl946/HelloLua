require "hecore.display.Director"
require "hecore.display.TextField"
require "hecore.display.ArmatureNode"
require "hecore.ui.ControlButton"

require "zoo.animation.TileCharacter"
require "zoo.animation.TileBird"
require "zoo.animation.GamePropsAnimation"
require "zoo.animation.LinkedItemAnimation"
require "zoo.animation.TileCuteBall"
require "zoo.animation.CommonEffect"
require "zoo.animation.Flowers"
require "zoo.animation.Clouds"
require "zoo.animation.NewClouds"
require "zoo.animation.HiddenBranchAnimation"
require "zoo.scenes.component.gameplayScene.ScoreProgressAnimation"
require "zoo.animation.PropListAnimation"
require "zoo.animation.PrefixPropAnimation"
require "zoo.animation.WinAnimation"
require "zoo.animation.LadybugTaskAnimation"
require "zoo.animation.MaxEnergyAnimation"

require "zoo.data.ShareManager"
require "zoo.panel.ChooseFriendPanel"
require "zoo.panel.RequireNetworkAlert"
require "zoo.panel.DynamicUpdatePanel"
require "zoo.panel.ExceptionPanel"
require "zoo.panel.UserBanPanel"
require "zoo.scenes.MessageCenterScene"

require "zoo.net.Http"
require "zoo.util.HeadImageLoader"

AnimationScene = class(Scene)
function AnimationScene:ctor()
	self.backButton = nil
end
function AnimationScene:dispose()
	if self.backButton then self.backButton:removeAllEventListeners() end
	self.backButton = nil
	
	Scene.dispose(self)
end

function AnimationScene:create()
	local s = AnimationScene.new()
	s:initScene()
	return s
end

function AnimationScene:createWithFile(file)
	local s = AnimationScene.new()

	s.spriteFileName = file

	s:initScene()
	return s
end

function AnimationScene:onInit()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(winSize.width, winSize.height)
	colorLayer:setColor(ccc3(255, 255, 255))
	colorLayer:setOpacity(100)
	self:addChild(colorLayer)

	local function onTouchBackLabel(evt)
		Director:sharedDirector():popScene()
		--self:testAnimation()
		-- self:testJuice()
	end

	local function buildLabelButton( label, x, y, func )
		local width = 250
		local height = 80
		local labelLayer = LayerColor:create()
		labelLayer:changeWidthAndHeight(width, height)
		labelLayer:setColor(ccc3(255, 0, 0))
		labelLayer:setPosition(ccp(x - width / 2, y - height / 2))
		labelLayer:setTouchEnabled(true, p, true)
		labelLayer:addEventListener(DisplayEvents.kTouchTap, func)
		self:addChild(labelLayer)

		local textLabel = TextField:create(label, nil, 32)
		textLabel:setPosition(ccp(width/2, height/2))
		textLabel:setAnchorPoint(ccp(0,0))
		labelLayer:addChild(textLabel)

		return labelLayer
	end 
	
	local layer = Layer:create()
  	self:addChild(layer)
  	self.layer = layer

  	--self:testShaderSprite9()
  	--self:testGroup()
  	self:testShader()
  	--self:testScale9Sprite()
  	--self:testScale9Sprite2()
  	--self:testChoosePanel()
  	--self:testSharePanel()
  	--self:testMaxEnergyAnimation()
  	--self:testLadyBugTask()
  	--self:testArmature()
  	--self:testLoadFriends()
  	--self:testPrefixAnimation()
  	--self:testPropsList()
  	--self:testPath()
  	--self:testLevelTarget()
  	--self:testQuaiticBackOut()
  	--self:testFlowers()
  	--self:testClouds()
  	--self:testBranch()

	--self:testCommonEffect()
	--self:testFrosting()
	--self:testGameProps()
	--self:testCureBall()
	--self:testCharacters()
	--self:testBird()

	--self:testAnimation()

	self.backButton = buildLabelButton("Back", 0, winSize.height-100, onTouchBackLabel)
end

local function createJuiceBottleByStep2(step)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local builder = InterfaceBuilder:createWithContentsOfFile("flash/animation/juice/juice_bottle.json")
	local bottle0 = builder:buildGroup("bottle"..step)

	return bottle0
end

local PositionYOffsetAndScaleX = {{-32, 0.833}, {-22, 1.0},{-32, 1.0},{-32, 1.0} } 

local function createJuiceBottleByStep(step)
	local bottle_glow = Sprite:createWithSpriteFrameName("BottleGlow instance 10000")
	local bottle = Layer:create()
	bottle:changeWidthAndHeight(bottle_glow:getGroupBounds().size.width, bottle_glow:getGroupBounds().size.height)

	local juice_shake = Sprite:createWithSpriteFrameName("juice_shake_0000.png")
	if step == 0 then
		bottle_empty = Sprite:createWithSpriteFrameName("bottle instance 10000")
		bottle:addChild(bottle_empty)
		
		bottle_glow:setPositionXY(0, 4)
		bottle:addChild(bottle_glow)
	else
		local bottle_front = Sprite:createWithSpriteFrameName("bottle_front instance 10000")
		local bottle_back = Sprite:createWithSpriteFrameName("bottle_back"..step.." instance 10000")
		bottle:addChild(bottle_back)

		juice_shake:setPosition(ccp(8, PositionYOffsetAndScaleX[step][1]))
		juice_shake:setScaleX(PositionYOffsetAndScaleX[step][2])
		bottle:addChild(juice_shake)

		bottle_front:setPositionXY(0,8)
		bottle:addChild(bottle_front)

		bottle_glow:setPositionXY(0, 4)
		--bottle:addChild(bottle_glow)
	end

	return bottle, bottle_glow, juice_shake
end

function AnimationScene:juiceChangeAnimation(from, to)
	local winSize = CCDirector:sharedDirector():getWinSize()
	
	local bottleStart = createJuiceBottleByStep2(from)
	bottleStart:setPosition(ccp(winSize.width/2, bottleStart:getGroupBounds().size.height))
	self.layer:addChild(bottleStart)

	local juice_shake_start = bottleStart:getChildByName("juice_shake")
	if juice_shake_start then
		juice_shake_start:setVisible(false)
	end

	local glow_start = bottleStart:getChildByName("glow")
	glow_start:setAlpha(0.2)
	glow_start:runAction(CCFadeTo:create(8/30, 255))

	local bottleEnd = createJuiceBottleByStep2(to)
	local glow_end = bottleEnd:getChildByName("glow")

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(4/30, 1.13, 0.84))
	if juice_shake_start then
		actions:addObject(CCCallFunc:create(function() 
				local juice_surface_start = bottleStart:getChildByName("surface")
				if juice_surface_start then
					juice_surface_start:setVisible(false)
					juice_shake_start:setVisible(true)

					local juice_frames = SpriteUtil:buildFrames("juice_shake_%04d.png", 0, 27)
					local juice_animate = SpriteUtil:buildAnimate(juice_frames, 1/25)
					juice_shake_start:play(juice_animate, 0, 1, nil, false)
				end
			end))
	end
	actions:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(4/30, 1, 1.10), CCMoveBy:create(4/30, ccp(0,8))))
	actions:addObject(CCCallFunc:create(function() 

		bottleEnd:setPositionXY(bottleStart:getPositionX(), bottleStart:getPositionY())
		bottleEnd:setScaleX(bottleStart:getScaleX())
		bottleEnd:setScaleY(1.2)
		self.layer:addChild(bottleEnd)
		bottleStart:setVisible(false)

		local juice_surface = bottleEnd:getChildByName("surface")
		juice_surface:setVisible(false)

		local newJuice_shake = bottleEnd:getChildByName("juice_shake")
		newJuice_shake:setVisible(true)

		local juice_frames = SpriteUtil:buildFrames("juice_shake_%04d.png", 0, 27)
		local juice_animate = SpriteUtil:buildAnimate(juice_frames, 1/25)
		newJuice_shake:play(juice_animate, 0, 1, function()
				juice_surface:setVisible(true)
			end, true)

		local juice_splash = Sprite:createWithSpriteFrameName("juice_splash_0000.png")
		juice_splash:setPositionXY(bottleEnd:getPositionX(), bottleEnd:getPositionY() + juice_splash:getContentSize().height/2)
		self.layer:addChild(juice_splash)

		local splash_frames = SpriteUtil:buildFrames("juice_splash_%04d.png", 0, 8)
		local splash_animate = SpriteUtil:buildAnimate(splash_frames, 1/30)
		juice_splash:play(splash_animate, 0, 1, nil, true)

		local bubble =  Sprite:createWithSpriteFrameName("juice_bubble_0000.png")
		bubble:setPositionXY(bottleEnd:getPositionX(), bottleEnd:getPositionY() + bubble:getContentSize().height/2)

		local bubble_frames = SpriteUtil:buildFrames("juice_bubble_%04d.png", 0, 10)
		local bubble_animate = SpriteUtil:buildAnimate(bubble_frames, 1/20)
		bubble:play(bubble_animate, 0, 2, nil, true)
		self.layer:addChild(bubble)

		local actions2 = CCArray:create()
		actions2:addObject(CCScaleTo:create(3/30, 1,1))
		actions2:addObject(CCMoveBy:create(5/30, ccp(0, -8)))
		actions2:addObject(
			CCCallFunc:create(function()
					bottleEnd:removeFromParentAndCleanup(false)
					
					local bottle_wrapper = Layer:create()
	 				bottle_wrapper:changeWidthAndHeight(bottleEnd:getGroupBounds().size.width, bottleEnd:getGroupBounds().size.height)
	 				bottle_wrapper:addChild(bottleEnd)
	 				bottle_wrapper:setAnchorPoint(ccp(0, 0.3))
	 				bottle_wrapper:setPositionXY(bottleEnd:getPositionX(), bottleEnd:getPositionY())
	 				bottleEnd:setPositionXY(0, 0)

	 				local rotate =  CCRepeat:create(CCSequence:createWithTwoActions(CCRotateTo:create(8/15, 30), CCRotateTo:create(8/15, -30)), 6)
					bottle_wrapper:runAction(CCSequence:createWithTwoActions(rotate, CCRotateTo:create(4/15, 0)))
					self.layer:addChild(bottle_wrapper)
				end))
		bottleEnd:runAction(CCSequence:create(actions2))

		if to == 5 then
			glow_end:runAction(CCRepeat:create(
				 CCSequence:createWithTwoActions(CCFadeTo:create(8/15, 255), CCFadeTo:create(8/15, 255 * 0.2)),
				 6))
		else
			glow_end:runAction(  CCFadeTo:create(8/30, 255 * 0.2))
		end
	end))

	bottleStart:runAction(CCSequence:create(actions))

	return bottleStart, bottleEnd
end


local bottleStart, bottleEnd

local function clearBottle()

	if bottleStart then
		bottleStart:removeFromParentAndCleanup(true)
	end

	if bottleEnd then
		bottleEnd:removeFromParentAndCleanup(true)
	end
end

function AnimationScene:testJuice()
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/animation/juice/juice_animation.plist")
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/animation/juice/juice_bottle.plist")

	clearBottle()
	bottleStart, bottleEnd = self:juiceChangeAnimation(4, 5)

	 local bottle0 = createJuiceBottleByStep2(0)
	 if _G.isLocalDevelopMode then printx(0, "bounds height: ", bottle0:getGroupBounds().size.height) end
	 --bottle0:setPosition(ccp(winSize.width/2 - bottle0:getGroupBounds().size.width, bottle0:getGroupBounds().size.height))

	 --[[local bottle1 = createJuiceBottleByStep2(1)
	 bottle1:setScaleY(2)
	 bottle1:setPosition(ccp(winSize.width/2, bottle0:getGroupBounds().size.height))

	 local bottle_wrapper = Layer:create()
	 bottle_wrapper:changeWidthAndHeight(bottle0:getGroupBounds().size.width, bottle0:getGroupBounds().size.height)
	 bottle_wrapper:addChild(bottle0)
	 bottle_wrapper:setAnchorPoint(ccp(0, 0.3))
	 bottle_wrapper:setPositionXY(winSize.width/2, bottle0:getGroupBounds().size.height)

	 local action =  CCSequence:createWithTwoActions(
	 		CCRepeat:create(CCSequence:createWithTwoActions(CCRotateTo:create(8/15, 30), CCRotateTo:create(8/15, -30)), 6),
	 		CCRotateTo:create(4/15, 0))
	 bottle_wrapper:runAction(action)]]--

	-- local bottle2 = createJuiceBottleByStep2(2)
	-- bottle2:setPosition(ccp(winSize.width/2, bottle0:getGroupBounds().size.height*3))

	-- local bottle3 = createJuiceBottleByStep2(3)
	-- bottle3:setPosition(ccp(winSize.width/2, bottle0:getGroupBounds().size.height*4))

	-- local bottle4 = createJuiceBottleByStep2(4)
	-- bottle4:setPosition(ccp(winSize.width/2, bottle0:getGroupBounds().size.height*5))

	 --self.layer:addChild(bottle_wrapper)
	 --self.layer:addChild(bottle1)
	--self.layer:addChild(bottle2)
	--self.layer:addChild(bottle3)
	--self.layer:addChild(bottle4)
end


function AnimationScene:testAnimation()


	local winSize = CCDirector:sharedDirector():getWinSize()

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/animation/elephant/boss_elephant_use.plist")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/animation/water_splash.plist")

	if _G.isLocalDevelopMode then printx(0, "added!!!!!!!!!!!!!!!!") end
	local boss = Sprite:createWithSpriteFrameName("boss_elephant_use_0000.png")
	boss:setScale(0.1)
	boss:setPosition(ccp(winSize.width/2, winSize.height /2 - boss:getContentSize().height/2))
	self.layer:addChild(boss)

	local function playCloudAnimation()
		local cloud = Sprite:createWithSpriteFrameName("boss_elephant_cloud_0000.png")
		cloud:setScale(10/7)
		cloud:setPositionXY(boss:getPositionX(), boss:getPositionY())
		self.layer:addChild(cloud)

		local cloud_frames = SpriteUtil:buildFrames("boss_elephant_cloud_%04d.png", 0, 13)
		local cloud_animate = SpriteUtil:buildAnimate(cloud_frames, 1/30)
		cloud:play(cloud_animate, 0, 1, nil, true)
	end

	-- local juice = Sprite:createWithSpriteFrameName("juice.png")
	-- juice:setScale(10/7)
	-- juice:setPosition(ccp(winSize.width/2-5, juice:getContentSize().height + 10))
	-- self.layer:addChild(juice)

	local function createWaterSplash()
			local water_splash = Sprite:createWithSpriteFrameName("water_splash_0000.png")
			water_splash:setScale(3.2)
			water_splash:setPosition(ccp(winSize.width/2, (winSize.height) /2))
			self.layer:addChild(water_splash)

			local water_frames = SpriteUtil:buildFrames("water_splash_%04d.png", 0, 7)
			local water_animate = SpriteUtil:buildAnimate(water_frames, 1/30)
			water_splash:play(water_animate, 0, 1, function() 
					water_splash:removeFromParentAndCleanup(true)
				end)
	end

	local function playWaterAnimation()
		local water = Sprite:createWithSpriteFrameName("waterSplash.png")
		water:setPosition(ccp(winSize.width/2, winSize.height/2))
		water:setScale(0.1 * 1.25)
		self.layer:addChild(water)

		local scale = CCScaleTo:create(3/30, 1.25, 1.25)
		local complete = CCCallFunc:create(function()
				createWaterSplash()

				water:setScale(2*1.25)
				water:runAction(CCCallFunc:create(
					function()
						water:setScale(1.6 * 1.25)
						water:runAction(CCSequence:createWithTwoActions(
							CCFadeOut:create(12/30),
							CCCallFunc:create(function() water:removeFromParentAndCleanup(true) end)
						))
					end
					))
			end)

		water:runAction(CCSequence:createWithTwoActions(scale, complete))
	end

	local function animateComplete()
		--boss:removeFromParentAndCleanup(true)
	end

	local delay = CCDelayTime:create(60/30)
	boss:setAnchorPoint(ccp(0.5, 0.1))
	
	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(5/30, 10/6, 10/6))
	actions:addObject(	
		CCCallFunc:create(
			function()
				local frames = SpriteUtil:buildFrames("boss_elephant_use_%04d.png", 0, 76)
				local animate = SpriteUtil:buildAnimate(frames, 1/30)
				boss:play(animate, 0, 1, animateComplete, true)
			end
		))
	actions:addObject(delay)
	actions:addObject(CCCallFunc:create(function() playWaterAnimation() end ))
	boss:runAction(CCSequence:create(actions))
	playCloudAnimation()

	self.layer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(78/30), CCCallFunc:create(
			function()
				playCloudAnimation()
			end
		)))

	--playWaterAnimation()

	-- local action_delay = CCDelayTime:create(10/30)
	-- local height = boss:getPositionY() - juice:getPositionY() - juice:getContentSize().height - 37
	-- local action_move = CCMoveBy:create(7/30, ccp(0, height))

	-- local callbackAction = CCCallFunc:create(function() 
	-- 		juice:removeFromParentAndCleanup(true)
	-- end)

	-- local arrAction = CCArray:create()
	-- arrAction:addObject(action_delay)
	-- arrAction:addObject(action_move)
	-- arrAction:addObject(callbackAction)

	--juice:runAction(CCSequence:create(arrAction))
end

function AnimationScene:testShaderSprite9()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local sp = CocosObject.new(HEScale9Sprite:createWithSpriteFrameName("ui_scale9/ui_button_green_scale90000", CCRectMake(0,0,0,0))) 
	sp:setPosition(ccp(winSize.width/2, origin.y + winSize.height - sp:getContentSize().height - 150))
	self.layer:addChild(sp)

	local h, s, v = 80, 1, 1
	sp.refCocosObj:setHsv(h, s, v)
	sp.refCocosObj:applyAdjustColorShader()
	
end

function AnimationScene:testGroup()
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(800, 1100)
	colorLayer:setColor(ccc3(255, 255, 255))
	colorLayer:setPosition(ccp(0, 0))
	self.layer:addChild(colorLayer)

	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/common_ui.json")
	
	local function buildButton( x, y )
		local ui_button_label = builder:buildGroup("ui_buttons_new/btn_text")
		ui_button_label:setPosition(ccp(x, y))
		self.layer:addChild(ui_button_label)

		return GroupButtonBase:create(ui_button_label)
	end
	local button1 = buildButton(100, winSize.height/2)
	button1:setString(Localization:getInstance():getText("button.ok"))
	
	local button2 = buildButton(360, winSize.height/2)
	button2:setString(Localization:getInstance():getText("button.ok"))
	button2:setColorMode(kGroupButtonColorMode.blue)

	local button3 = buildButton(620, winSize.height/2)
	button3:setString(Localization:getInstance():getText("button.ok"))
	button3:setColorMode(kGroupButtonColorMode.orange)

	local button1 = buildButton(100, winSize.height/2 + 100)
	button1:setString(Localization:getInstance():getText("button.cancel"))
	button1:setScale(0.6)
	
	local button2 = buildButton(260, winSize.height/2 + 100)
	button2:setString(Localization:getInstance():getText("button.cancel"))
	button2:setColorMode(kGroupButtonColorMode.blue)
	button2:setScale(0.6)

	local enabledButton1
	local function onTouchButton3_0( evt )
		if enabledButton1 then enabledButton1:setEnabled(true) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(evt)) end
	end
	local function onTouchButton4_0( evt )
		if enabledButton1 then enabledButton1:setEnabled(false) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(evt)) end
	end

	local button3 = buildButton(420, winSize.height/2 + 100)
	button3:setString(Localization:getInstance():getText("button.cancel"))
	button3:setColorMode(kGroupButtonColorMode.orange)
	button3:setScale(0.6)
	button3:addEventListener(DisplayEvents.kTouchTap, onTouchButton3_0)
	
	local button4 = buildButton(580, winSize.height/2 + 100)
	button4:setString(Localization:getInstance():getText("button.cancel"))
	button4:setColorMode(kGroupButtonColorMode.orange)
	button4:setScale(0.6)
	button4:setEnabled(false)
	button4:addEventListener(DisplayEvents.kTouchTap, onTouchButton4_0)
	enabledButton1 = button4

	local function buildIconButton( x, y )
		local ui_button_label = builder:buildGroup("ui_buttons/ui_button_right_icon")
		ui_button_label:setPosition(ccp(x, y))
		self.layer:addChild(ui_button_label)

		local button = ButtonIconsetBase:create(ui_button_label)
		button:setString(Localization:getInstance():getText("button.ok"))
		button:setIconByFrameName("ui_images/ui_image_coin_icon_small0000", false)
		return button
	end

	local enabledButton2
	local function onTouchButton3_1( evt )
		if enabledButton2 then enabledButton2:setEnabled(true) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(evt)) end
	end
	local function onTouchButton4_1( evt )
		if enabledButton2 then enabledButton2:setEnabled(false) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(evt)) end
	end

	local button1 = buildIconButton(100, winSize.height/2 + 200)

	local button2 = buildIconButton(320, winSize.height/2 + 200)
	button2:setColorMode(kGroupButtonColorMode.blue)
	button2:setScale(0.6)

	local button3 = buildIconButton(480, winSize.height/2 + 200)
	button3:setColorMode(kGroupButtonColorMode.orange)
	button3:setScale(0.6)
	button3:addEventListener(DisplayEvents.kTouchTap, onTouchButton3_1)

	local button4 = buildIconButton(640, winSize.height/2 + 200)
	button4:setColorMode(kGroupButtonColorMode.orange)
	button4:setScale(0.6)
	button4:setEnabled(false)
	button4:addEventListener(DisplayEvents.kTouchTap, onTouchButton4_1)
	enabledButton2 = button4

	local function buildIconButtonLeft( x, y )
		local ui_button_label = builder:buildGroup("ui_buttons/ui_button_left_icon")
		ui_button_label:setPosition(ccp(x, y))
		self.layer:addChild(ui_button_label)

		local button = ButtonIconsetBase:create(ui_button_label)
		button:setString(Localization:getInstance():getText("button.cancel"))
		button:setIconByFrameName("ui_images/ui_image_coin_icon_small0000", false)
		return button
	end
	local button1 = buildIconButtonLeft(100, winSize.height/2 + 300)

	local button2 = buildIconButtonLeft(320, winSize.height/2 + 300)
	button2:setColorMode(kGroupButtonColorMode.blue)
	button2:setScale(0.6)

	local button3 = buildIconButtonLeft(480, winSize.height/2 + 300)
	button3:setColorMode(kGroupButtonColorMode.orange)
	button3:setScale(0.6)

	local button4 = buildIconButtonLeft(640, winSize.height/2 + 300)
	button4:setColorMode(kGroupButtonColorMode.orange)
	button4:setScale(0.6)
	button4:setEnabled(false)

	local function buildButtonIconNumberBase( x, y )
		local ui_button_label = builder:buildGroup("ui_buttons/ui_coin_button")
		ui_button_label:setPosition(ccp(x, y))
		self.layer:addChild(ui_button_label)

		local label = Localization:getInstance():getText("button.ok")..Localization:getInstance():getText("button.cancel")
		local button = ButtonIconNumberBase:create(ui_button_label)
		button:setString(label)
		button:setIconByFrameName("ui_images/ui_image_coin_icon_small0000", false)
		button:setNumber(10)
		return button
	end
	
	local enabledButton3
	local function onTouchButton3_2( evt )
		if enabledButton3 then enabledButton3:setEnabled(true) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(evt)) end
	end
	local function onTouchButton4_2( evt )
		if enabledButton3 then enabledButton3:setEnabled(false) end
		if _G.isLocalDevelopMode then printx(0, table.tostring(evt)) end
	end
	local button1 = buildButtonIconNumberBase(200, winSize.height/2 + 400)

	local button3 = buildButtonIconNumberBase(480, winSize.height/2 + 400)
	button3:setColorMode(kGroupButtonColorMode.blue)
	button3:setScale(0.4)
	button3:addEventListener(DisplayEvents.kTouchTap, onTouchButton3_2)

	local button4 = buildButtonIconNumberBase(640, winSize.height/2 + 400)
	button4:setColorMode(kGroupButtonColorMode.orange)
	button4:setScale(0.4)
	button4:setEnabled(false)
	button4:addEventListener(DisplayEvents.kTouchTap, onTouchButton4_2)
	enabledButton3 = button4

	local startGame1 = ButtonStartGame:create()
	startGame1:setPosition(ccp(winSize.width/2, 200))
	startGame1:setString(Localization:getInstance():getText("button.cancel"))
	startGame1:setNumber(8)
	self.layer:addChild(startGame1:getContainer())

	local startGame2 = ButtonStartGame:create()
	startGame2:setPosition(ccp(winSize.width/2, 360))
	startGame2:setString(Localization:getInstance():getText("button.cancel"))
	startGame2:setNumber(8)
	startGame2:enableInfiniteEnergy(true)
	self.layer:addChild(startGame2:getContainer())

	local ui_button_label = builder:buildGroup("ui_buttons/ui_number_button")
	ui_button_label:setPosition(ccp(winSize.width/2, 500))
	self.layer:addChild(ui_button_label)
	local numberButton = ButtonNumberBase:create(ui_button_label)
	numberButton:setString(Localization:getInstance():getText("button.cancel"))
	numberButton:setNumber(Localization:getInstance():getText("button.ok").."8")
end

function AnimationScene:createHsvSlider(min, max, def, prefix, callback, index)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local positionY = origin.y + 300 + 120 * index
	local textLabel = TextField:create(label, nil, 32)
	textLabel:setPosition(ccp(winSize.width/2, positionY - 40))
	textLabel:setAnchorPoint(ccp(0.5,0.5))
	textLabel:setString(prefix..def)
	self.layer:addChild(textLabel)

	local slider = ControlSlider:create()
	local function onControlEventValueChanged( evt )
		local val = slider:getValue()
		if callback ~= nil then callback(val) end
		textLabel:setString(prefix..tostring(val))
	end
	
	slider:addEventListener("ControlEventValueChanged", onControlEventValueChanged)
	slider:setPosition(ccp(winSize.width/2, positionY))
	slider:setValue(def)
	slider:setAnchorPoint(ccp(0.5, 0.5))
	slider:setMinimumValue(min)
	slider:setMaximumValue(max)
	self.layer:addChild(slider)
	return slider
end

function AnimationScene:testShader()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(800, 400)
	colorLayer:setColor(ccc3(0x4E, 0x4E, 0x4E))
	colorLayer:setPosition(ccp(0, 800))
	self.layer:addChild(colorLayer)

	self.builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.panel_register)

	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("materials/body.plist")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/crystal_stone.plist")
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/tile_totems.plist")
	--local sp = CocosObject.new(HESpriteColorAdjust:createWithSpriteFrameName("ui_scale9/ui_button_green_scale90000"))
	-- local sp = CocosObject.new(HESpriteColorAdjust:createWithSpriteFrameName("phone/ButtonBg0000")) 

	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/tile_totems.plist")
	-- local spriteFrameName = "totems_body_0000"
	-- local originHSBC = {
	-- 	[AnimalTypeConfig.kBlue] 	= {-0.9044, 0.0358, 0.1331, 0.1796},
	-- 	[AnimalTypeConfig.kGreen] 	= {0.5697, 0.3514, 0.1385, 0.0585},
	-- 	[AnimalTypeConfig.kOrange] 	= {0.1655, -0.1598, 0.1018, 0.0715},
	-- 	[AnimalTypeConfig.kPurple] 	= {-0.4840, -0.0852, 0.0693, 0.1385},
	-- 	[AnimalTypeConfig.kRed] 	= {0.0272, 0.0000, 0.0002, 0.0000},
	-- 	[AnimalTypeConfig.kYellow] 	= {0.2714, 0.6929, 0.4584, 0.1018},
	-- }

	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/bottle_blocker.plist")
	-- local spriteFrameName = "bottle_animal_idle_body_0000" 
	-- local originHSBC = {
	-- 	[AnimalTypeConfig.kRed] 	= {0.0000, 0.0000, 0.0000, 0.0000},
	-- 	[AnimalTypeConfig.kBlue] 	= {-0.9584, 0.3817, -0.0074, 1.0000},
	-- 	[AnimalTypeConfig.kGreen] 	= {0.5270, 0.5050, 0.1200, 0.1640},
	-- 	[AnimalTypeConfig.kPurple] 	= {-0.4786, 0.1558, 0.0002, -0.0117},
	-- 	[AnimalTypeConfig.kYellow] 	= {0.3071, 0.4670, 0.3817, 0.5622},
	-- 	[AnimalTypeConfig.kOrange] 	= {0.1796, 0.0229, 0.0899, -0.0301},
	-- }

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/crystal_stone.plist")
	-- --静止的身体
	-- local spriteFrameName = "crystal_stone_empty_body_0000" 
	-- local originHSBC = {
	-- 	[AnimalTypeConfig.kRed] = 		{-0.2711, -0.2073, -0.3457, 0.2401},
	-- 	[AnimalTypeConfig.kBlue] = 		{0.8712, -0.3273, -0.1166, 0.2952},
	-- 	[AnimalTypeConfig.kGreen] = 	{0.3568, -0.4094, -0.0744, 0.5319},
	-- 	[AnimalTypeConfig.kPurple] =	{-0.7185, -0.4040, -0.2495, 0.4346},
	-- 	[AnimalTypeConfig.kYellow] =	{0.0000, 0.0000, 0.0585, 0.2995},
	-- 	[AnimalTypeConfig.kOrange] =	{-0.0312, -0.2344, -0.2927, 0.1223},
	-- }
	--眼睛
	local spriteFrameName = "crystal_stone_eyes2_0000" 
	local originHSBC = {
		[AnimalTypeConfig.kRed] = {-0.2441, 0.4054, -0.1803, 0},
		[AnimalTypeConfig.kBlue] = {0.8259, 0, 0, 0},
		[AnimalTypeConfig.kGreen] = {0.2671, 0, -0.0420, 0},
		[AnimalTypeConfig.kPurple] = {-0.7661, 0.0164, -0.1014, 0},
		[AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
		[AnimalTypeConfig.kOrange] = {-0.1490, -0.2819, -0.2235, 0.0200},
	}

	-- [LUA-print] Color 6 locked: {-0.7661, 0.0164, -0.1014, 0.0000}
	-- [LUA-print] Color 6 locked: {0.2671, 0.0000, -0.0420, 0.0000}
	-- [LUA-print] Color 6 locked: {-0.2441, 0.4054, -0.1803, 0.0000}
	-- [LUA-print] Color 6 locked: {-0.1490, -0.2819, -0.2235, 0.0200}
	-- [LUA-print] Color 6 locked: {0.0000, 0.0000, 0.0000, 0.0000}
	-- [LUA-print] Color 6 locked: {0.8259, 0.0000, 0.0000, 0.0000}

	-- --里面的水
	-- local spriteFrameName = "crystal_stone_water" 
	-- local originHSBC = {
	-- 	[AnimalTypeConfig.kRed] = {-0.2073, -0.2289, -0.1014, 0.1655},
	-- 	[AnimalTypeConfig.kBlue] = {0.9426, -0.0960, 0.0000, 0.0000},
	-- 	[AnimalTypeConfig.kGreen] = {0.3622, 0.0002, 0.0423, 0.1082},
	-- 	[AnimalTypeConfig.kPurple] = {-0.6710, 0.1320, -0.0528, 0.0358},
	-- 	[AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
	-- 	[AnimalTypeConfig.kOrange] = {-0.0052, -0.0528, -0.0906, 0.0596},
	-- }
	-- --波浪
	-- local spriteFrameName = "crystal_stone_water_wave"
	-- local originHSBC = {
		-- [AnimalTypeConfig.kRed] = {-0.2235, -0.0052, -0.3565, -0.1166},
		-- [AnimalTypeConfig.kBlue] = {0.9750, 0.0000, -0.0582, 0.0000},
		-- [AnimalTypeConfig.kGreen] = {0.3784, 0.0002, -0.2019, 0.1082},
		-- [AnimalTypeConfig.kPurple] = {-0.6710, 0.1320, -0.2019, 0.0358},
		-- [AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
		-- [AnimalTypeConfig.kOrange] = {-0.0258, 0.0002, -0.3143, -0.3197},
	-- }


	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("flash/magic_lamp.plist")
	-- local spriteFrameName = "magic_lamp_level_3_0000"
	-- local originHSBC = {
	-- 	    [AnimalTypeConfig.kBlue]    = {-0.0366, 0.0910, 0.0477, 0.1115},
	-- 	    [AnimalTypeConfig.kGreen]   = {-0.4094, 0.1439, 0.0477, 0.2293},
	-- 	    [AnimalTypeConfig.kOrange]  = {-0.9152, 0.0801, -0.0106, 0.1763},
	-- 	    [AnimalTypeConfig.kPurple]  = {0.3784, 0.0380, -0.0798, 0.1861},
	-- 	    [AnimalTypeConfig.kRed]     = {0.9220, -0.0906, -0.0906, 0.1763},
	-- 	    [AnimalTypeConfig.kYellow]  = {-0.8677, 0.7351, 0.2876, 0.5481},
	-- }
	
	local useHSV = false
	local h, s, v, b = 0, 0, 0, 0
	local function createSprite()

		if self.spriteFileName then
			local sp = CocosObject.new(HESpriteColorAdjust:create(self.spriteFileName))
			return sp
		end
		return CocosObject.new(HESpriteColorAdjust:createWithSpriteFrameName(spriteFrameName))
	end
	
	local sprites = {}
	local sp = createSprite()
	-- local crystal = CCTextureCache:sharedTextureCache():addImage(SpriteUtil:getRealResourceName("crystal_stone_yellow.png"))
	-- local sp = CocosObject.new(HESpriteColorAdjust:createWithTexture(crystal)) 
	local scale = 2
	sp:setScale(scale)
	sp:setPosition(ccp(winSize.width/2, origin.y + winSize.height - 200))
	self.layer:addChild(sp)
	table.insert(sprites, sp)

	if self.spriteFileName then
		local size = sp:getContentSize()
		sp:setScale(500 / math.max(size.width, size.height))
	end

	-- local frames = SpriteUtil:buildFrames("bottle_animal_idle_eyes_%04d", 0, 9)
	-- local anim = SpriteUtil:buildAnimate(frames, 1/20)
	-- sp:runAction(CCRepeatForever:create(anim))
	local HSBCConfig = originHSBC
	local unlockColor = 0

	local function updateHue( val )
		h = tonumber(val)
		for _, sp in pairs(sprites) do
			if not sp.isLocked then 
				if useHSV then sp.refCocosObj:setHsv(h, s, b)
				else sp.refCocosObj:adjustHue(h)
				end
			end
		end
		if HSBCConfig[unlockColor] then
			HSBCConfig[unlockColor][1] = h
		end
	end
	local function updateSaturation( val )
		s = tonumber(val)
		for _, sp in pairs(sprites) do
			if not sp.isLocked then
				if useHSV then sp.refCocosObj:setHsv(h, s, b) 
				else sp.refCocosObj:adjustSaturation(s) end
			end
		end
		if HSBCConfig[unlockColor] then
			HSBCConfig[unlockColor][2] = s
		end
	end
	local function updateBrightness( val )
		b = tonumber(val)
		for _, sp in pairs(sprites) do
			if not sp.isLocked then
				if useHSV then sp.refCocosObj:setHsv(h, s, b)
				else sp.refCocosObj:adjustBrightness(b) end
			end
		end
		if HSBCConfig[unlockColor] then
			HSBCConfig[unlockColor][3] = b
		end
	end
	local function updateContrast( val )
		v = tonumber(val)
		for _, sp in pairs(sprites) do
			if not sp.isLocked then
				if useHSV then if _G.isLocalDevelopMode then printx(0, "not support") end
				else sp.refCocosObj:adjustContrast(v) end
			end
		end
		if HSBCConfig[unlockColor] then
			HSBCConfig[unlockColor][4] = v
		end
	end

	local HueSlider = nil
	local SaturationSlider = nil
	local BrightnessSlider = nil
	local ContrastSlider = nil

	if useHSV then
		for _, sp in pairs(sprites) do
			if not sp.isLocked then
				sp.refCocosObj:setHsv(h, s, b)
			end
		end
		HueSlider = self:createHsvSlider(0, 360, 0, "H:", updateHue, 0)
		SaturationSlider = self:createHsvSlider(0, 2, 1, "S:", updateSaturation, 1)
		BrightnessSlider = self:createHsvSlider(0, 2, 1, "V:", updateBrightness, 2)
	else
		HueSlider = self:createHsvSlider(-1, 1, 0, "Hue(色彩):", updateHue, 0)
		SaturationSlider = self:createHsvSlider(-1, 1, 0, "Saturation(饱和度):", updateSaturation, 1)
		BrightnessSlider = self:createHsvSlider(-1, 1, 0, "Brightness(亮度):", updateBrightness, 2)
		ContrastSlider = self:createHsvSlider(-1, 1, 0, "Contrast(对比度):", updateContrast, 3)
	end

	-- 添加6个动物以作参考
	local index = 0
	for color, hsbcData in pairs(HSBCConfig) do
		index = index + 1
		local item = ItemViewUtils:buildAnimalStatic(color)
		item:setPosition(ccp(50 + index * 90, 50))
		colorLayer:addChild(item)
	end
	-- 添加被调整的对象
	local i = 0
	for colorType, hsbcData in pairs(HSBCConfig) do
		i = i + 1
		local ssp = createSprite()
		local scale = 1
		ssp:setScale(scale)

		if self.spriteFileName then
			local size = ssp:getContentSize()
			ssp:setVisible(false)
		end


		ssp:setPosition(ccp(140 + 90 * (i - 1), 120))
		colorLayer:addChild(ssp)
		table.insert(sprites, ssp)
		ssp.isLocked = true

		local btn = LayerColor:create()
		btn:setColor(ccc3(255, 0, 0))
		btn:changeWidthAndHeight(60, 20)
		btn:setPosition(ccp(140 + 90 * (i - 1)-30, 170))
		btn:setTouchEnabled(true)
		btn:addEventListener(DisplayEvents.kTouchTap, function()
			ssp.isLocked = not ssp.isLocked
			local h, s, b, v = hsbcData[1],  hsbcData[2], hsbcData[3], hsbcData[4]
			if ssp.isLocked then
				btn:setColor(ccc3(255, 0, 0))
				btn.text:setString("Locked")
				if _G.isLocalDevelopMode then printx(0, string.format("Color %d locked: {%.4f, %.4f, %.4f, %.4f}", i, h, s, b, v)) end
			else
				unlockColor = colorType
				
				HueSlider:setValue(h)
				BrightnessSlider:setValue(b)
				SaturationSlider:setValue(s)
				if ContrastSlider then
					ContrastSlider:setValue(v)
				end
				ssp.refCocosObj:applyAdjustColorShader()

				btn:setColor(ccc3(0, 255, 0))
				btn.text:setString("Unlocked")
			end
			end)

		local text = TextField:create("Locked", nil, 16)
		text:setColor(ccc3(255, 255, 255))
		text:setPosition(ccp(30, 10))
		btn.text = text
		btn:addChild(text)

		colorLayer:addChild(btn)
	end

	local button = ControlButton:create("Use", nil, 42)
  	button.name = "use shader"
  	button:setPosition(ccp(winSize.width/2, origin.y + 50))
  	local isUseShader = false
  	local function onButtonEvent( evt )
  		if isUseShader then
  			isUseShader = false
			for _, sp in pairs(sprites) do
				if not sp.isLocked then
		  			sp.refCocosObj:clearAdjustColorShader()
		  		end
	  		end
  		else
  			isUseShader = true
			for _, sp in pairs(sprites) do
				if not sp.isLocked then
		  			sp.refCocosObj:applyAdjustColorShader()
		  		end
	  		end
  		end
    end
 	button:ad(kControlEvent.kControlEventTouchUpInside, onButtonEvent)
 	self.layer:addChild(button)
end

function AnimationScene:testScale9Sprite()
	if _G.isLocalDevelopMode then printx(0, "testScale9Sprite") end
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(100, 100)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setPosition(ccp(0, 0))
	self.layer:addChild(colorLayer)

	local root = Layer:create()
	root:setPosition(ccp(0, 100))
	root:setScale(0.5)
	self.layer:addChild(root)
	local function testClipp( x, y )
		local colorLayer = LayerColor:create()
		colorLayer:changeWidthAndHeight(100, 100)
		colorLayer:setColor(ccc3(255, 0, 0))
		colorLayer:setOpacity(30)
		colorLayer:setPosition(ccp(x, y))
		root:addChild(colorLayer)

		local clip = SimpleClippingNode:create()
		clip:setContentSize(CCSizeMake(70, 70))
		clip:setPosition(ccp(x,y))
		root:addChild(clip)

		local sp = Sprite:create("materials/game_bg.png")
		sp:setAnchorPoint(ccp(0,0))
		clip:addChild(sp)

		local sp = Sprite:create("materials/head_images.png")
		sp:setAnchorPoint(ccp(0,0))
		sp:setScale(0.5)
		sp:setRotation(45)
		sp:setPosition(ccp(50,20))
		sp:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 100)))

		local ls = Layer:create()
		ls:addChild(sp)
		clip:addChild(ls)
	end
	testClipp(0,300)
	testClipp(100,300)
	testClipp(200,300)
	testClipp(300,300)
	testClipp(400,300)
	testClipp(500,300)
end
function AnimationScene:testScale9Sprite2()
	if _G.isLocalDevelopMode then printx(0, "testScale9Sprite2") end
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setPosition(ccp(400, 200))
	self.layer:addChild(colorLayer)

	local clip = ClippingNode:create(CCRectMake(0,0,40,40))
	--clip:setContentSize(CCSizeMake(100, 100))
	clip:setPosition(ccp(400,200))
	self.layer:addChild(clip)

	local sp = Sprite:create("materials/game_bg.png")
	sp:setAnchorPoint(ccp(0,0))
	clip:addChild(sp)

	local sp = Sprite:create("materials/head_images.png")
	sp:setAnchorPoint(ccp(0,0))
	sp:setScale(0.5)
	sp:setRotation(45)
	sp:setPosition(ccp(50,20))
	sp:runAction(CCRepeatForever:create(CCRotateBy:create(0.5, 100)))

	local ls = Layer:create()
	ls:addChild(sp)
	clip:addChild(ls)
end

function AnimationScene:testScale9Sprite_()
	
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setPosition(ccp(0, 0))
	self.layer:addChild(colorLayer)

	local profile = UserManager.getInstance().profile

	local spriteA = HeadImageLoader:create(profile.uid, profile.headUrl)
	spriteA:setPosition(ccp(200,200))
	self.layer:addChild(spriteA)
end

function AnimationScene:testChoosePanel()
	local function onTouchTap( evt )
		

		local panel = ExceptionPanel:create() --ChooseFriendPanel:create() --DynamicUpdatePanel:create()
		panel:popout()
		--local panel = RequestMessagePanel:create()--RequestMessagePanel:create()--ChooseFriendPanel:create()
		--panel:popout()

		--Director:sharedDirector():pushScene(MessageCenterScene:create())
	end

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 100)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 400))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)
end

function AnimationScene:createLineStar(width, height)
	local textureSprite = Sprite:createWithSpriteFrameName("win_star_shine0000")
	local container = SpriteBatchNode:createWithTexture(textureSprite:getTexture())
	for i = 1, 15 do
		local sprite = Sprite:createWithSpriteFrameName("win_star_shine0000")
		sprite:setPosition(ccp(width*math.random(), height*math.random()))
		sprite:setOpacity(0)
		sprite:setScale(0)
		sprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.1 + math.random()*0.3, 150)))
		local scaleTo = 0.3 + math.random() * 0.8
		local fadeInTime, fadeOutTime = 0.4, 0.4
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(math.random()*0.5))
		array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(fadeInTime), CCScaleTo:create(fadeInTime, scaleTo)))
		array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(fadeOutTime), CCScaleTo:create(fadeOutTime, 0)))
		sprite:runAction(CCSequence:create(array))
		container:addChild(sprite)
	end
	local function onAnimationFinished() container:removeFromParentAndCleanup(true) end
	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.3), CCCallFunc:create(onAnimationFinished)))
	textureSprite:dispose()
	return container
end

function AnimationScene:testSharePanel( )
	-- local panel = SharePanel:create(10)
	-- self.layer:addChild(panel)
end
function AnimationScene:testMaxEnergyAnimation( )
	--local animation = CommonSkeletonAnimation:createFailAnimation()--MaxEnergyAnimation:create()
	--MaxEnergyAnimation:create()
	local animation = CommonSkeletonAnimation:creatTutorialAnimation(10001)
	animation:playAnimation()
	animation:stopAnimation()
	--animation:setPosition(ccp(200, 500))
	animation:setPosition(ccp(350,500))
	self.layer:addChild(animation)

	local flag = 1
	local function onTouchTap( evt )
		--SyncAnimation:getInstance():show()
		if flag == 1 then
			animation:playAnimation()
			flag = 0
		else
			animation:stopAnimation()
			flag = 1
		end
	end

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 100)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 400))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)

end
function AnimationScene:testLadyBugTask()
	local container = Layer:create()
	self.layer:addChild(container)
	local function onTouchTap( evt )
		container:removeChildren()
		local icon = LadybugTaskAnimation:create(true)
		container:addChild(icon)
		icon:setPosition(ccp(200, 500))
		icon:flyIn()
	end

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 100)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 400))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)
end
function AnimationScene:testBird( )

	
	local layer = self.layer

	local function createBirdEffect()
		local bird = TileBird:create()

		local function onAnimationFinish()
			bird:stop2BirdDestroyAnimation()
		end
		bird:setPosition(ccp(200,290))
		bird:play2BirdDestroyAnimation({ccp(200, 400), ccp(300, 700), ccp(480, 800)})
		--bird:stop2BirdDestroyAnimation()
		bird:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(onAnimationFinish)))
		layer:addChild(bird)
	end
	local function onTouchTap( evt )
		--createBirdEffect()
		local winSize = CCDirector:sharedDirector():getWinSize()
		local panel = CommonEffect:buildRequireSwipePanel()
		panel:setPosition(ccp(winSize.width/2, winSize.height/2))
		layer:addChild(panel)
	end

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 100)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 400))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)
end

function AnimationScene:testArmature()
	local winSize = CCDirector:sharedDirector():getWinSize()
  	
  	local function onAnimationFinish( )
  		if _G.isLocalDevelopMode then printx(0, "onAnimationFinish") end
  	end 
  	
  	local function onTouchTap( evt )
		local animation = self:createLineStar(200, 40) --CommonSkeletonAnimation:createTutorialMoveIn()--CommonSkeletonAnimation:createTutorialNormal() --AddEnergyAnimation:create()
		--animation:setPosition(ccp(250, 400))
		animation:setPosition(ccp(winSize.width/2, 400))
		self.layer:addChild(animation)
	end

	

  	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(winSize.width/2, 400)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)
end

function AnimationScene:testLoadFriends()
	local number = 1
	local function onItemLoad(userId, imageURL)
		if _G.isLocalDevelopMode then printx(0, userId, imageURL) end
		local sprite = Sprite:create(imageURL)
		sprite:setPosition(ccp(300, number * 300))
		sprite:setAnchorPoint(ccp(0,0))
		self.layer:addChild(sprite)
		number = number + 1
	end
	local loader = HeadImageLoader.new()
	loader.itemLoadCompleteCallback = onItemLoad
	loader:add(101, "http://www.bhcode.net/png/images/png-1558.png")
	loader:add(102, "http://www.baidu.com/img/shouye_b5486898c692066bd2cbaeda86d74448.gif") -- gif image will ignored.
	loader:add(103, "http://hdn.xnimg.cn/photos/hdn421/20100828/1650/h_tiny_RilU_19750000138a2f74.jpg") --not exist.
	loader:add(104, "http://himg.bdimg.com/sys/portrait/item/aecfe4b8bbe68c81e78ebae892995f37.jpg")
	loader:load()
end

function AnimationScene:testPrefixAnimation()
	local animation

	local function flyFinishedCallback()
		if _G.isLocalDevelopMode then printx(0, "TODO: change move on UI!") end
	end
	local function onAnimationFinish()
		if _G.isLocalDevelopMode then printx(0, "onAnimationFinish") end
	end 
		
	local index = 0
	local function onTouchTap( evt )
		if index == 0 then
			local icon = PropListAnimation:createIcon( 10018 )
			animation = PrefixPropAnimation:createAddMoveAnimation(icon, 0, flyFinishedCallback, onAnimationFinish)
			self.layer:addChild(animation)
		elseif index == 1 then
			local icon = PropListAnimation:createIcon( 10007 )
			local positionA = ccp(100, 200)
			local positionB = ccp(500, 300)
			animation = PrefixPropAnimation:createChangePropAnimation(icon, 0, positionA, positionB, flyFinishedCallback, onAnimationFinish)
			self.layer:addChild(animation)
		end
		
		index = index + 1
		if index > 1 then index = 0 end
	end

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 0))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)
end

function AnimationScene:testPropsList()
	local index = 1
	local items = {
		{
			{itemId=10001, itemNum=1, temporary=0},
			{itemId=10005, itemNum=1, temporary=0},
			{itemId=10010, itemNum=3, temporary=0},
			{itemId=10003, itemNum=22, temporary=0},
			{itemId=10004, itemNum=1, temporary=0},
			{itemId=10002, itemNum=10, temporary=0},
			--{itemId=10007, itemNum=0, temporary=0}
		},
		{
			{itemId=10001, itemNum=22, temporary=0},
			{itemId=10004, itemNum=22, temporary=2},
			{itemId=10005, itemNum=101, temporary=0}
		},
		{
			{itemId=10001, itemNum=22, temporary=0},
			{itemId=10005, itemNum=101, temporary=0}
		},
		{
			{itemId=10001, itemNum=1, temporary=0},
			{itemId=10004, itemNum=1, temporary=1},
			{itemId=10031, itemNum=2, temporary=0},
			{itemId=10032, itemNum=1, temporary=0},
			{itemId=10033, itemNum=2, temporary=0},
			{itemId=10005, itemNum=2, temporary=0},
			{itemId=10010, itemNum=3, temporary=0},
			{itemId=10003, itemNum=22, temporary=0},
			{itemId=10002, itemNum=10, temporary=0},
			{itemId=10007, itemNum=0, temporary=0}
		},
		{
			{itemId=10001, itemNum=1, temporary=0},
			{itemId=10004, itemNum=1, temporary=0},
			{itemId=10031, itemNum=2, temporary=0},
			{itemId=10032, itemNum=1, temporary=0},
			{itemId=10033, itemNum=2, temporary=0},
			{itemId=10005, itemNum=2, temporary=0},
			{itemId=10010, itemNum=3, temporary=0},
			{itemId=10003, itemNum=22, temporary=0},
			{itemId=10002, itemNum=10, temporary=0},
			{itemId=10007, itemNum=0, temporary=0}
		}
	}
	local listView = PropListAnimation:create()
	local function onTouchTap( evt )	
		listView:show(items[index])	
		index = index + 1
		if index > #items then index = 1 end
	end
	local function onDownTouch( evt )
		listView:showAddStepItem()
		listView:addTemporaryItem(10015, 1, ccp(math.random()*500, math.random()*700 + 200))
	end 

	local function onConfirmTouch( evt )
		listView:confirm()
	end 

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 402))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 200))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onDownTouch)
	self.layer:addChild(colorLayer)

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 600))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onConfirmTouch)
	self.layer:addChild(colorLayer)

	self.layer:addChild(listView.layer)	

	
end

function AnimationScene:testLevelTarget( )
	local index = 1
	local testTargets = { {{type="move", id=0, num=12345}},  
						  {{type="time", id=0, num=12345}},  
						  --{{type="drop", id=0, num=30}}, 
						  {{type="order1", id=1, num=30}, {type="order1", id=2, num=30},{type="order1", id=3, num=30},{type="order1", id=4, num=30}},
						  --{{type="order2", id=1, num=30}, {type="order2", id=2, num=30},{type="order2", id=3, num=30}},
						  --{{type="order3", id=1, num=30}, {type="order3", id=2, num=30},{type="order3", id=3, num=30}},
						  --{{type="order3", id=1, num=30}, {type="order4", id=2, num=30}},
						  {{type="order4", id=1, num=30}},
						  {{type="ice", id=1, num=30}}
						}
	local positionX = 200
	local leveltarget = LevelTargetAnimation:create(positionX)
	local debugLayer = Layer:create()
	local function onTimeModeStart()
		if _G.isLocalDevelopMode then printx(0, "Time Mode Game Start") end
	end 
	local function createDebugRect( position )
		local rect = LayerColor:create()
		rect:changeWidthAndHeight(100, 100)
		rect:setColor(ccc3(255, 0, 250))
		rect:setOpacity(100)
		rect:setPosition(ccp(position.x, position.y))
		if _G.isLocalDevelopMode then printx(0, "createDebugRect", position.x,"/" , position.y) end
		debugLayer:addChild(rect)
	end
	local function onTouchTap( evt )		
		if _G.isLocalDevelopMode then printx(0, "onTouchTap", evt and evt.name or "nil") end
		leveltarget:setTargets(testTargets[index], onTimeModeStart)
		debugLayer:removeChildren()
		local item = leveltarget:getLevelTileByIndex(1)
		local size = item:getGroupBounds().size
		local position = item:getPosition()
		local position = item:getParent():convertToWorldSpace(ccp(position.x, position.y-size.height))
		createDebugRect(position)

		index = index + 1
		if index > #testTargets then index = 1 end
	end
	self.layer:addChild(leveltarget.layer)	
	self.layer:addChild(debugLayer)

	onTouchTap(nil)

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 800)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	self.layer:addChild(colorLayer)

	
end
function AnimationScene:testPath()
	

	local ladybug = nil
	local function onTouchTap( evt )
		ladybug:reset()
		ladybug:moveTo(0)
		ladybug:animateTo(1, 2)

		ladybug:addScoreStar(evt.globalPosition)
--[[
		local star = ScoreProgressAnimation:createFinishStarAnimation(evt.globalPosition)
		self.layer:addChild(star)

		local explode = ScoreProgressAnimation:createFinsihExplodeStar(ccp(evt.globalPosition.x + 100, evt.globalPosition.y))
		self.layer:addChild(explode)

		local overlay = ScoreProgressAnimation:createFinsihShineStar(ccp(evt.globalPosition.x + 300, evt.globalPosition.y))
		self.layer:addChild(overlay)
		]]
	end
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 800)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	self.layer:addChild(colorLayer)

	ladybug = ScoreProgressAnimation:create()
	ladybug:setPosition(ccp(100,800))
	ladybug:setStarsPosition(0, 0.5, 1)
	self.layer:addChild(ladybug.layer)	
end

function AnimationScene:testBranch( )
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 800)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	self.layer:addChild(colorLayer)

	local branch = nil

	local function onTouchTap( evt )
		if branch then
			branch:removeFromParentAndCleanup(true)
		end
		branch = HiddenBranchAnimation:create()
		branch:setPosition(ccp(200, 800))
		self.layer:addChild(branch)

		if _G.isLocalDevelopMode then printx(0, "onTouchTap", evt) end
	end
	
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
end
function AnimationScene:testQuaiticBackOut( )
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(100, 100)
	colorLayer:setColor(ccc3(255, 250, 0))
	colorLayer:setOpacity(90)
	colorLayer:setPosition(ccp(100, 500))
	self.layer:addChild(colorLayer)

	local moveIn = CCEaseQuarticBackOut:create(CCMoveBy:create(1, ccp(300, 0)), 3, -7.4475, 10.095, -10.195, 5.5475)
	local moveOut = CCEaseQuarticBackOut:create(CCMoveBy:create(1, ccp(-300, 0)),3, -7.4475, 10.095, -10.195, 5.5475)
	
	colorLayer:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(moveIn, moveOut)))
end

function AnimationScene:testClouds()
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 600)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	self.layer:addChild(colorLayer)

	local winSize = CCDirector:sharedDirector():getWinSize()

	local lock = Clouds:buildLock()

	local wait = Clouds:buildWait()
	wait:setPosition(ccp(winSize.width/2, 600))
	wait:addChild(lock)
	self.layer:addChild(wait)

	local isFadeOut = false
	local function onTouchTap( evt )
		local target = evt.target
		if isFadeOut then
			isFadeOut = false
			target:wait()
			lock:wait()
		else 
			isFadeOut = true
			target:fadeOut() 
			lock:fadeOut()
		end
	end

	wait:addEventListener(DisplayEvents.kTouchTap, onTouchTap)

end
function AnimationScene:testFlowers()
	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 400)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	self.layer:addChild(colorLayer)

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 200)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	self.layer:addChild(colorLayer)

	local function onGlowAnimationFinsih( evt )
		if _G.isLocalDevelopMode then printx(0, "onGlowAnimationFinsih") end
	end 

	local open = nil
	local function onOpenAnimationFinish( evt )
		if open then
			open:removeAllEventListeners()
			open:removeFromParentAndCleanup(true)
		end
		open = nil
	end
	local function onTouchTap( evt )
		local target = evt.target
		target:bloom()

		if open then
			open:removeAllEventListeners()
			open:removeFromParentAndCleanup(true)
		end

		open = Flowers:buildOpenEffect(math.random() > 0.5)
		open:setPosition(ccp(500, 400))
		open:addEventListener(Events.kComplete, onOpenAnimationFinish)
		self.layer:addChild(open)
	end 

	for i=0,4 do
		local glow = Flowers:buildGlowEffect(kFlowers["flowerStar"..i])
		glow:setPosition(ccp(200 + 80*i, 200))
		glow:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
		glow:addEventListener(Events.kComplete, onGlowAnimationFinsih)
		self.layer:addChild(glow)
		if i > 0 then
			local glow = Flowers:buildGlowEffect(kFlowers["hiddenFlower"..i])
			glow:setPosition(ccp(200 + 80*i, 280))
			glow:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
			glow:addEventListener(Events.kComplete, onGlowAnimationFinsih)
			self.layer:addChild(glow)
		end
	end
	
end

function AnimationScene:testCommonEffect()
	local layer = self.layer

	local function onTouchTap( evt )
	    --local effect = CommonEffect:buildBonusEffect()
		--effect:setPosition(ccp(0, 200))
		layer:addChild(CommonEffect:buildSpecialEffectTitle(math.random(1, 6)))
		-- layer:addChild(CommonEffect:buildBonusEffect())
	end

	local colorLayer = LayerColor:create()
	colorLayer:changeWidthAndHeight(200, 100)
	colorLayer:setColor(ccc3(255, 0, 0))
	colorLayer:setOpacity(30)
	colorLayer:setTouchEnabled(true)
	colorLayer:setPosition(ccp(0, 400))
	colorLayer:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
	self.layer:addChild(colorLayer)
end

function AnimationScene:testFrosting()
	local layer = self.layer
	for i=1,3 do
		local item = LinkedItemAnimation:buildFrosting(i, true)
		item:setPosition(ccp(80*i, 120))
		layer:addChild(item)
	end

	for i=4,6 do
		local item = LinkedItemAnimation:buildFrosting(i, true)
		item:setPosition(ccp(80*(i-3), 210))
		layer:addChild(item)
	end
	
	for i=7,8 do
		local item = LinkedItemAnimation:buildFrosting(i, true)
		item:setPosition(ccp(80*(i-6), 300))
		layer:addChild(item)
	end

	local crystal = LinkedItemAnimation:buildCrystal(1)
	crystal:setPosition(ccp(80, 380))
	layer:addChild(crystal)

	local crystal = LinkedItemAnimation:buildCrystal(2, true)
	crystal:setPosition(ccp(170, 380))
	layer:addChild(crystal)

	local crystal = LinkedItemAnimation:buildCrystal(3, true, true)
	crystal:setPosition(ccp(260, 380))
	layer:addChild(crystal)

	local gift = LinkedItemAnimation:buildGift(1)
	gift:setPosition(ccp(80, 25))
	layer:addChild(gift)

	local gift = LinkedItemAnimation:buildGift(2, true)
	gift:setPosition(ccp(170, 25))
	layer:addChild(gift)

	local gift = LinkedItemAnimation:buildGift(3, true, true)
	gift:setPosition(ccp(260, 25))
	layer:addChild(gift)
end

function AnimationScene:testGameProps()
	local layer = self.layer
	local function onAnimationFinish(evt)
		local target = evt.target
	  	if target then 
	  		target:rma() 
	  		target:removeFromParentAndCleanup()
	  	end
  		if _G.isLocalDevelopMode then printx(0, "on GamePropsAnimation finish") end
	end 

	local hammer = GamePropsAnimation:buildHammer()
	hammer:setPosition(ccp(100, 200))
	layer:addChild(hammer)
	hammer:ad(Events.kComplete, onAnimationFinish)

	local magic = GamePropsAnimation:buildMagicWind()
	magic:setPosition(ccp(100, 350))
	layer:addChild(magic)
	magic:ad(Events.kComplete, onAnimationFinish)

	local enter = LinkedItemAnimation:buildPortalEnter()
	enter:setPosition(ccp(250, 200))
	layer:addChild(enter)

	local exit = LinkedItemAnimation:buildPortalExit()
	exit:setPosition(ccp(250, 250))
	layer:addChild(exit)

	local coinBomb = LinkedItemAnimation:buildCoinBomb()
	coinBomb:setPosition(ccp(250, 250))
	layer:addChild(coinBomb)

	local item = LinkedItemAnimation:buildWall(0)
	item:setPosition(ccp(50, 80))
	layer:addChild(item)

	item = LinkedItemAnimation:buildWall(1)
	item:setPosition(ccp(100, 80))
	layer:addChild(item)

	item = LinkedItemAnimation:buildCherry()
	item:setPosition(ccp(170, 80))
	layer:addChild(item)

	item = LinkedItemAnimation:buildRock()
	item:setPosition(ccp(250, 80))
	layer:addChild(item)

	item = LinkedItemAnimation:buildLocker()
	item:setPosition(ccp(50, 380))
	layer:addChild(item)

	item = LinkedItemAnimation:buildCoin()
	item:setPosition(ccp(50, 200))
	layer:addChild(item)
end

function AnimationScene:testCureBall(  )
	local layer = self.layer
  	layer:removeChildren()
	for i=1,3 do
		local sprite = TileCuteBall:create()
		self.layer:addChild(sprite)
		sprite:setPosition(ccp(70*i, 100))
		sprite:play(i)
	end
	for i=1,2 do
		local sprite = TileCuteBall:create()
		self.layer:addChild(sprite)
		sprite:setPosition(ccp(100*i, 300))
		sprite:play(i+3)
	end

	local sprite = TileCuteBall:create()
	self.layer:addChild(sprite)
	sprite:setPosition(ccp(240, 240))
	sprite:play(6)
end


function AnimationScene:testCharacters()
	self:buildCharacter("bear")

	local items = {"bear","fox", "horse", "frog", "cat", "chicken"}
	
	for i,v in ipairs(items) do
		local preloadSprite = TileCharacter:create(v)
	end

  	local button = ControlButton:create("next", nil, 42)
  	button.name = "next"
  	button:setPosition(ccp(200, 50))
  	local current = 1
  	local function onButtonEvent( evt )
    current = current + 1
    if current > #items then current = 1 end
  		self:buildCharacter(items[current])
  	end
 	button:ad(kControlEvent.kControlEventTouchUpInside, onButtonEvent)
 	self:addChild(button)
end

function AnimationScene:buildCharacter( characterName )
  local layer = self.layer
  layer:removeChildren()
  for i=2,5 do
  	  local sprite = TileCharacter:create(characterName)
	  layer:addChild(sprite)
	  sprite:setPosition(ccp(70*(i-1), 240))
	  sprite:play(i)
  end

  local sprite = TileCharacter:create(characterName)
  layer:addChild(sprite)
  sprite:setPosition(ccp(120, 320))
  sprite:play(kTileCharacterAnimation.kLineColumn)

  sprite = TileCharacter:create(characterName)
  layer:addChild(sprite)
  sprite:setPosition(ccp(50, 320))
  sprite:play(kTileCharacterAnimation.kLineRow)

  sprite = TileCharacter:create(characterName)
  layer:addChild(sprite)
  sprite:setPosition(ccp(190, 320))
  sprite:play(kTileCharacterAnimation.kWrap)

  sprite = TileCharacter:create(characterName)
  layer:addChild(sprite)
  sprite:setPosition(ccp(260, 320))
  sprite:play(kTileCharacterAnimation.kSelect)

  local function onTileCharacterDestroy( evt )
  	local target = evt.target
  	if target then target:rma() end
  	if _G.isLocalDevelopMode then printx(0, "CharacterAnimationFinished") end
  end

  sprite = TileCharacter:create(characterName)
  layer:addChild(sprite)
  sprite:setPosition(ccp(200, 400))
  sprite:play(kTileCharacterAnimation.kDestroy)
  sprite:ad(Events.kComplete, onTileCharacterDestroy)

  self:buildBird()
end

function AnimationScene:buildBird()
   local layer = self.layer

   local bird = TileBird:create()
   bird:setPosition(ccp(120, 120))
   bird:play(1)
   layer:addChild(bird)

   bird = TileBird:create()
   bird:setPosition(ccp(250, 120))
   bird:play(2)
   layer:addChild(bird)

   local function onTileBirdDestroy( evt )
  	local target = evt.target
  	if target then 
  		target:rma() 
  		target:removeFromParentAndCleanup()
  	end
  	if _G.isLocalDevelopMode then printx(0, "BirdAnimationFinished") end
  end
  bird = TileBird:create()
  bird:setPosition(ccp(200,290))
  bird:play(kTileBirdAnimation.kDestroy)
  bird:ad(Events.kComplete, onTileBirdDestroy)
  layer:addChild(bird)

  bird:buildAndRunDestroyAction(layer)
end
