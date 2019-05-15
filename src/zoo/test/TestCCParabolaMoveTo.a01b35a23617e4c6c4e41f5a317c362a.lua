


-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月 6日 17:46:14
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- TestScene
---------------------------------------------------


require "hecore.display.Director"
require "hecore.display.TextField"
require 'zoo.animation.LaborCatEffect'
require 'zoo.animation.TileMagicStone'
require "zoo.config.TileConfig"
require 'zoo.animation.TileMove'
require 'zoo.animation.CommonEffect'
require 'zoo.animation.TileMagicTile'
require 'zoo.animation.TileDragonBoss'
require 'zoo.animation.TileBottleBlocker'
require 'zoo.animation.TileQiXiBoss'
require 'zoo.animation.TileRocket'
require 'zoo.animation.TileTotems'
require 'zoo.animation.UFOAnimation'
require 'zoo.animation.SquirrelAnimation'
require 'zoo.animation.TileCrystalStone'
require 'zoo.itemView.ItemViewUtils'
require 'zoo.gameTools.GameMapSnapshot'

assert(not TestScene)
assert(Scene)
TestScene = class(Scene)

function TestScene:ctor()
end

local fps = 30

function TestScene:preloadRes()
	FrameLoader:loadImageWithPlist("flash/ice_chain.plist")
	FrameLoader:loadImageWithPlist("flash/ufo_rocket.plist")
	FrameLoader:loadImageWithPlist("flash/scenes/homeScene/home.plist")
	FrameLoader:loadImageWithPlist("flash/crystal_stone.plist")
	FrameLoader:loadImageWithPlist("flash/tile_totems.plist")
	-- FrameLoader:loadImageWithPlist("editorRes/flash/level_snapshot.plist")
	FrameLoader:loadPngOnly("editorRes/flash/level_snapshot_game_bg.png")
	-- FrameLoader:loadImageWithPlist("flash/animation/boss_cat_item_use.plist")
	-- FrameLoader:loadImageWithPlist("flash/map_move_tile.plist")
	-- FrameLoader:loadImageWithPlist("flash/get_prop_bganim.plist")
	-- FrameLoader:loadImageWithPlist("flash/dragonboat_boss3.plist")
	-- FrameLoader:loadImageWithPlist("flash/scenes/flowers/target_icon.plist")
	-- FrameLoader:loadImageWithPlist("flash/bottle_blocker.plist")
end

local TestPlayScene = class(GamePlaySceneUI)
function TestPlayScene:create(levelId, levelType)
	local scene = TestPlayScene.new()
	GamePlaySceneUI.init(scene, levelId, levelType, {}, GamePlaySceneUIType.kDev)
	return scene
end

function TestPlayScene:loadExtraResource( levelId, levelType, callback )
	-- body
	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID(levelId)
	local fileList = levelConfig:getDependingSpecialAssetsList()
	local loader = FrameLoader.new()
	local function callback_afterResourceLoader()
		loader:removeAllEventListeners()
		if callback then callback() end
	end
	for i,v in ipairs(fileList) do loader:add(v, kFrameLoaderType.plist) end
	loader:addEventListener(Events.kComplete, callback_afterResourceLoader)
	loader:load()
end

function TestScene:init(...)
	assert(#{...} == 0)

	Scene.initScene(self)

	self:preloadRes()

	local stageSize = Director:sharedDirector():getVisibleSize()
	local origin = CCDirector:sharedDirector():getVisibleOrigin()
	local bg = LayerColor:create()
	bg:setColor(ccc3(0, 0, 0))
	bg:changeWidthAndHeight(stageSize.width, stageSize.height)
	self:addChild(bg)

	local colorObj = LayerColor:create()
	colorObj:setColor(ccc3(255, 0, 0))
	colorObj:changeWidthAndHeight(10, 10)

	-- 720 * 1280
	colorObj:setPosition(ccp(0, 400))
	self:addChild(colorObj)
	--local parabolaMoveto = CCParabolaMoveTo:create(2.0, 0, 0, -400)
	--colorObj:runAction(parabolaMoveto)

	-- Test Label
	local startLabel = TextField:create("Start" , Helvetica, 40)
	startLabel:setColor(ccp(66, 66, 66))
	local labelWrapper = Layer:create()
	labelWrapper:addChild(startLabel)

	labelWrapper:setPosition(ccp(origin.x + 80, origin.y + stageSize.height - 200))
	self:addChild(labelWrapper)
	labelWrapper:setTouchEnabled(true)

	local function onLabelTapped()

		colorObj:setPosition(ccp(0, 400))
		-- time = 1, moveToX = 400, moveToY = 0, acceleration of gravity = -4000
		local parabolaMoveto = CCParabolaMoveTo:create(1, 400, 0, -4000)
		
		-- Parabola Action Callback 
		local function parabolaCallback(newX, newY, vXInitial, vYInitial, vX, vY, duration, actionPercent)

			if _G.isLocalDevelopMode then printx(0, "========================================") end
			if _G.isLocalDevelopMode then printx(0, "===== parabolaCallback Called ==========") end
			if _G.isLocalDevelopMode then printx(0, "========================================") end

			if _G.isLocalDevelopMode then printx(0, "newX: " .. newX) end
			if _G.isLocalDevelopMode then printx(0, "newY: " .. newY) end
			if _G.isLocalDevelopMode then printx(0, "vXInitial: " .. vXInitial) end
			if _G.isLocalDevelopMode then printx(0, "vYInitial: " .. vYInitial) end
			if _G.isLocalDevelopMode then printx(0, "vX: " .. vX) end
			if _G.isLocalDevelopMode then printx(0, "vY: " .. vY) end
			if _G.isLocalDevelopMode then printx(0, "duration: " .. duration) end
			if _G.isLocalDevelopMode then printx(0, "actionPercent: " .. actionPercent) end
		end

		parabolaMoveto:registerScriptHandler(parabolaCallback)

		colorObj:runAction(parabolaMoveto)
	end


	local function testHeBezierTo()
		if self.testAnimsContainer then
			self.testAnimsContainer:removeFromParentAndCleanup(true)
			self.testAnimsContainer = nil
		else
			local opacity = 0.8
			local bg = LayerColor:create()
			bg:setColor(ccc3(80, 80, 80))
			bg:changeWidthAndHeight(stageSize.width, stageSize.height)
			bg:setPosition(ccp(0, 0))
			bg:setOpacity(255 * opacity)
			self:addChild(bg)
			self.testAnimsContainer = bg

			local function runTask(levelId, levelIdEnd)
				if levelId <= levelIdEnd then
					local function callback(levelId, shareGroup)
						levelId = levelId + 1
						runTask(levelId, levelIdEnd)
					end
					GameMapSnapshot.getInstance():genSnapShot(levelId, "D:/level_share", callback)
				end
			end
			runTask(730, 739)
		end
	end

	-- labelWrapper:addEventListener(DisplayEvents.kTouchTap, onLabelTapped)
	local function testClipping()
		--[[local sprite = Sprite:createEmpty()
		sprite:setPosition(ccp(200, 700))
		local sp1 = Sprite:createWithSpriteFrameName("blocker199_shell1")
		sp1:setScale(0.9)
		sp1:setRotation(90)
		sp1:setPosition(ccp(2, 1))
		sprite:addChild(sp1)
		local sp2 = Sprite:createWithSpriteFrameName("blocker199_shell1")
		sp2:setScale(0.9)
		sp2:setRotation(180)
		sp2:setPosition(ccp(2, -2))
		--sprite:addChild(sp2)
		local sp1 = Sprite:createWithSpriteFrameName("blocker199_shell1")
		sp1:setScale(0.9)
		sp1:setRotation(270)
		sp1:setPosition(ccp(-2, -2))
		--sprite:addChild(sp1)
		local sp1 = Sprite:createWithSpriteFrameName("blocker199_shell1")
		sp1:setScale(0.9)
		sp1:setRotation(0)
		sp1:setPosition(ccp(-2, 1))
		sprite:addChild(sp1)
		self:addChild(sprite)]]--

		local sprite = Sprite:createEmpty()
		sprite:setPosition(ccp(200, 700))
		self:addChild(sprite)

		local sp1 = Sprite:createWithSpriteFrameName("blocker199_shell1")
		sp1:setScale(0.9)
		sp1:setRotation(90)
		sp1:setPosition(ccp(2, 1))
		sprite:addChild(sp1)

		local data = {
			[1]={{startFrame=0,duration=4,x=0.90,y=1.90,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00}}
			
		}

		local hd = Sprite:createWithSpriteFrameName("blocker199_shell1")
		hd:setScale(0.9)
		hd:setRotation(0)
		hd:setPosition(ccp(-2, 2.1))
		sprite:addChild(hd)
	end

	-- labelWrapper:addEventListener(DisplayEvents.kTouchTap, testHeBezierTo)
	labelWrapper:addEventListener(DisplayEvents.kTouchTap, testClipping)

	local redOne = LayerColor:create()
	local blueOne = LayerColor:create()
	local greenOne = LayerColor:create()

	local function onRedTouchBegan(event)
		if _G.isLocalDevelopMode then printx(0, "onRedTouchBegan") end
	end
	local function onBlueTouchBegan(event)
		if _G.isLocalDevelopMode then printx(0, "onBlueTouchBegan") end
	end
	local function onGreenTouchBegan(event)
		if _G.isLocalDevelopMode then printx(0, "onGreenTouchBegan") end
	end

	redOne:setColor(ccc3(255, 0, 0))
	redOne:changeWidthAndHeight(300, 300)
	redOne:setPosition(ccp(100, 100))
	redOne:setTouchEnabled(true, 10, false)
	redOne:addEventListener(DisplayEvents.kTouchBegin, onRedTouchBegan)
	self:addChild(redOne)

	blueOne:setColor(ccc3(0, 0, 255))
	blueOne:changeWidthAndHeight(200, 200)
	blueOne:setPosition(ccp(120, 120))
	blueOne:setTouchEnabled(true, 1, false)
	blueOne:addEventListener(DisplayEvents.kTouchBegin, onBlueTouchBegan)
	self:addChild(blueOne)

	greenOne:setColor(ccc3(0, 255, 0))
	greenOne:changeWidthAndHeight(100, 100)
	greenOne:setPosition(ccp(150, 150))
	greenOne:setTouchEnabled(true, 10, false)
	greenOne:addEventListener(DisplayEvents.kTouchBegin, onGreenTouchBegan)
	self:addChild(greenOne)

	for i=1,3 do
		local testFlower = Sprite:createWithSpriteFrameName("hiddenFlowerAnim" .. i .. "0000")
		testFlower:setPosition(ccp(200 + i * 100, 600))
		self:addChild(testFlower)
	end

	local function onTouchBackLabel(evt)
		Director:sharedDirector():popScene()
	end

	local backBtn = LayerColor:create()
	self:addChildAt(backBtn, 9999)
	backBtn:setColor(ccc3(255, 0, 0))
	backBtn:changeWidthAndHeight(80, 40)
	backBtn:setPosition(ccp(origin.x + 20, origin.y + stageSize.height - 100))
	backBtn:setTouchEnabled(true)
	backBtn:addEventListener(DisplayEvents.kTouchTap, onTouchBackLabel)

	local backLabel = TextField:create("Back", nil, 30)
	backLabel:setPosition(ccp(40, 20))
	backBtn:addChild(backLabel)
end

function TestScene:_initScriptActions(sprite, data, spriteCallback)
	local actions = CCArray:create()
	for k, v in ipairs(data) do
		local part = spriteCallback(k)
		sprite:addChild(part)

		local partActions = CCArray:create()
		partActions:addObject(ResUtils:getAnimationActions(part, v))
		partActions:addObject(CCCallFunc:create(function()
			part:removeFromParentAndCleanup(true)
		end))
	
		actions:addObject(CCTargetedAction:create(
			part.refCocosObj,
			CCSequence:create(partActions)
		))
	end
	
	return actions
end

function TestScene:testMoveTile()
	if self.moveTileContainer then
		self.moveTileContainer:removeFromParentAndCleanup(true)
	end

	local item = LayerColor:create()
	self:addChild(item)
	self.moveTileContainer = item

	item:setColor(ccc3(0, 255, 255))
	item:changeWidthAndHeight(200, 200) 
	item:setPosition(ccp(200, 700))

	for d = 1, 4 do
		local pos = ccp(70 * math.ceil(d / 2), 70 * (d % 2))
		local tile = TileMove:createTile(nil, false)
		tile:setPosition(pos)
		item:addChild(tile)

		local anim = TileMove:createArrowAnimation(d)
		anim:setPosition(pos)
		item:addChild(anim)
	end
end

function TestScene:addChains()
	if self.chainsLayer then self.chainsLayer:removeFromParentAndCleanup(true) end
	self.chainsLayer = Layer:create()
	self:addChild(self.chainsLayer)

	local textureObj = CCSpriteBatchNode:create(SpriteUtil:getRealResourceName("flash/ice_chain.png"), 100)
	local texture = textureObj:getTexture()
	for i = 1, 5 do
		-- local ccl = LayerColor:create()
		-- ccl:setColor(ccc3(255, 255, 255))
		-- ccl:changeWidthAndHeight(70, 70)
		-- ccl:setPosition(ccp(50 + 100 * (i - 1), 800))
		-- self:addChild(ccl)

		local chainsData = {}
		for dir = 1, 4 do
			chainsData[dir] = {level = i, direction = dir}
		end
		local chain = TileChain:createWithChains(chainsData, texture)
		local scale = 1
		chain:setScale(scale)
		chain:setPosition(ccp(200 + 90 * (i - 1) , 700))
		self.chainsLayer:addChild(chain)
		-- for j = 1, 4 do
		-- 	local iceChain = TileChain:create(i, j)
		-- 	iceChain:setPosition(ccp(35, 35))
		-- 	ccl:addChild(iceChain)
		-- 	table.insert(chains, iceChain)
		-- end

		local function playBreak()
			local breakLevels = {}
			breakLevels[1] = chain.chainsData[1]
			-- breakLevels[2] = chain.chainsData[2]
			breakLevels[3] = chain.chainsData[3]
			breakLevels[4] = chain.chainsData[4]
			local function onEnd() chain:removeFromParentAndCleanup(true) end
			chain:playBreakAnimation(breakLevels)
		end
		setTimeOut(playBreak, 1)
	end
end

function TestScene:create(...)
	assert(#{...} == 0)

	local newTestScene = TestScene.new()
	newTestScene:init()
	return newTestScene
end

function TestScene:testClippingNode()
	if self.clipTestLayer then 
		self.clipTestLayer:removeFromParentAndCleanup(true)
		self.clipTestLayer = nil
	end
	self.clipTestLayer = Layer:create() 
	-- self.clipTestLayer:setColor(ccc3(0, 0, 255))
	-- self.clipTestLayer:changeWidthAndHeight(300, 300)
	self.clipTestLayer:setPosition(ccp(200, 800))
	self:addChild(self.clipTestLayer)
	
	local node1 = Sprite:createWithSpriteFrameName("hiddenFlowerAnim10000").refCocosObj
	local color = 0.8 * 255
	local node2 = CCLayerColor:create(ccc4(color, color, color, 255), 200, 200)
	local clipNode = CCClippingNode:create(node1)
	clipNode:setPosition(ccp(150, 150))
	clipNode:setAlphaThreshold(0.75)
	self.clipTestLayer.refCocosObj:addChild(clipNode)
	clipNode:addChild(node2)
	node2:setPosition(-100, -100)
	clipNode:setInverted(false)
end

function TestScene:testMagicStone()
	local scale = 1

	if self.magicStoneLayer then
		self.magicStoneLayer:removeFromParentAndCleanup(true)
	end

	self.magicStoneLayer = LayerColor:create()
	self.magicStoneLayer:setColor(ccc3(64, 64, 64))
	self.magicStoneLayer:changeWidthAndHeight(720, 1280)
	self.magicStoneLayer:setOpacity(128)
	self:addChild(self.magicStoneLayer)

	local dirs = {1, 3, 2, 4}
	local x = {200, 200, 400, 400}
	local y = {700, 840, 840, 700}
	for i = 0, 3 do
		local item = LayerColor:create()
		item:setColor(ccc3(255, 0, 0))
		item:changeWidthAndHeight(70, 70)
		item:setPosition(ccp(x[i+1], y[i+1]))
		self.magicStoneLayer:addChild(item)

		local level = 0
		local dir = dirs[i + 1]
		local stone = TileMagicStone:create(level, dir)
		stone:setPosition(ccp(35, 35))
		stone:setScale(scale)
		item:addChild(stone)
		local pos = {}
		if level == 2 then
			pos = TileMagicStone:calcEffectPositions(dir)
		end

		local function onAnimFinish()
			if stone and not stone.isDisposed then
				stone:updateStoneSprite()
				stone:idle()
			end
			if callback then callback() end
		end

		local function delayFunc()
			local anim = TileMagicStone:createActiveAnim(nil, level, dir, onAnimFinish, pos)
			anim:setPosition(ccp(35, 35))
			item:addChild(anim)

			stone:removeStoneSprite()
			stone.level = level + 1
			if stone.level > 2 then stone.level = 2 end
		end
		setTimeOut(delayFunc, 2)
	end
end

function TestScene:createSence()
	local testScene = TestScene:create()
	Director:sharedDirector():pushScene(testScene)
end

return TestScene
