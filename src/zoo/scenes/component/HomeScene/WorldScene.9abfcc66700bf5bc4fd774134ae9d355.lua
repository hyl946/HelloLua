
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月14日 13:45:54
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.scenes.component.HomeScene.Trunks"
require "zoo.scenes.component.HomeScene.WorldSceneLockedCloudLayer"
require "zoo.scenes.component.HomeScene.UserPicture"
require "zoo.scenes.component.HomeScene.FriendPicStack"
require "zoo.scenes.component.HomeScene.TreeTopLockedCloud"
require "zoo.scenes.component.HomeScene.interaction.WorldSceneBranchInteractionController"
require "zoo.scenes.component.HomeScene.interaction.WorldSceneTrunkInteractionController"
require "zoo.scenes.component.HomeScene.interaction.TrunkScrollInteractionController"
require "zoo.scenes.component.HomeScene.WorldMapOptimizer"
require "zoo.scenes.component.HomeSceneFlyToAnimation"
require "zoo.mission.panels.MissionTrunkLevelNodeBubble"


require "zoo.events.GamePlayEvents"

require "zoo.scenes.component.HomeScene.AnniversaryFloatButton"
--require "zoo.scenes.component.HomeScene.animation.AnniversaryTwoYearsAnimation"

require "zoo.panel.NotificationGuidePanel"
require "zoo.panel.TopRankPanel"
require "zoo.panel.WorldSceneUnlockInfoPanel"
require "zoo.animation.AreaBlockerShow"
require "zoo.data.ActivityLevelFlourManager"
require 'zoo.util.FriendUtil'
require "zoo.animation.SpringFireworkAnimation"

StartLevelType = table.const {
	kCommon = 1,
	kAskForHelp = 2,
}

StartLevelSource = {
	kDefault = 0,
	kPrePropExpire = 1,
	kFailPanel = 2,
	kSuccessPanel = 3,
	kReplayPanel = 4,
	kFindTheWay = 5,
}

---------------------------------------------------
-------------- WorldScene
---------------------------------------------------

assert(not WorldScene)
assert(WorldSceneScroller)
WorldScene = class(WorldSceneScroller)


function WorldScene:init(homeScene, ...)
	assert(homeScene)
	assert(#{...} == 0)

	
	WorldSceneShowManager:getInstance()
	-----------------
	-- Init Base Class
	-- --------------
	WorldSceneScroller.init(self)
	WorldMapOptimizer:getInstance():init(self)

	-- Data
	self.metaModel = MetaModel:sharedInstance()

	-- System State
	self.homeScene = homeScene
	self.winSize = CCDirector:sharedDirector():getWinSize()
	self.visibleSize = CCDirector:sharedDirector():getVisibleSize()
	self.visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	self.contentScaleFactor = CCDirector:sharedDirector():getContentScaleFactor()

	-- 自动滑动，方向向下的时候设置为true，其他时候应重置为false
	self.ignoreHitCloudCheck = false

	-- Parallax Config
	local config = UIConfigManager:sharedInstance():getConfig()

	-- ---------------
	-- Create Layer
	-- ---------------
	-- maskedLayer Is The Parent Layer For All 
	-- Other Layer Used To Scroll All 
	self.maskedLayer = ParallaxNode:create()
	self:addChild(self.maskedLayer)
	self.maskedLayer:setPositionY(self.visibleOrigin.y)

	-- self.maskedLayer.stopAllActions = function()
	-- 	if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
	-- 	self.maskedLayer.refCocosObj:stopAllActions()
	-- end


	-- ------------------
	-- Gradient Background
	-- --------------------
	local backgroundParallax = config.worldScene_backgroundParallax
	assert(backgroundParallax)
	self.gradientBackgroundParallaxRatio = ccp(backgroundParallax, backgroundParallax)
	self.gradientBackgroundLayer = Layer:create()
	self.maskedLayer:addParallaxChild(self.gradientBackgroundLayer, 0, self.gradientBackgroundParallaxRatio, ccp(0,0))

	local backItemLayerParallax = config.worldScene_backItemParallax
	self.backItemLayerParallaxRatio = ccp(backItemLayerParallax, backItemLayerParallax)
	self.backItemLayer = Layer:create()
	self.maskedLayer:addParallaxChild(self.backItemLayer, nil, self.backItemLayerParallaxRatio, ccp(0,0))

	--------------2016春节星星----------------
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
		local star1Parallax = 0.007
		self.star1Parallax = ccp(star1Parallax, star1Parallax)
		local plistPath = "flash/scenes/flowers/spring/home_scene_star.plist"
		if __use_small_res then  
			plistPath = table.concat(plistPath:split("."),"@2x.")
		end
		CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistPath)
		local texture = CCSprite:createWithSpriteFrameName("home_scene_star.png"):getTexture()
		self.star1Layer = SpriteBatchNode:createWithTexture(texture)
		self.maskedLayer:addParallaxChild(self.star1Layer, nil, self.star1Parallax, ccp(0,0))
		if WorldSceneShowManager:getInstance():getShowType() == 2 then 
			self.star1Layer:setVisible(true)
		else
			self.star1Layer:setVisible(false)
		end
	end

	local worldScene_cosmosParallax = config.worldScene_cosmosParallax
	assert(worldScene_cosmosParallax)
	self.cosmosBackgroundParallaxRatio = ccp(worldScene_cosmosParallax, worldScene_cosmosParallax)
	self.cosmosBackgroundLayer = Layer:create()
	self.maskedLayer:addParallaxChild(self.cosmosBackgroundLayer, nil, self.cosmosBackgroundParallaxRatio, ccp(0,0))
	------------------------------
	-- Some Cloud 1 Change Layer
	-- ---------------------------
	local cloudLayer1Parallax = config.worldScene_cloudLayer1Parallax
	self.cloudLayer1Parallax = ccp(cloudLayer1Parallax, cloudLayer1Parallax)
	self.cloudLayer_1 = Layer:create()
	self.maskedLayer:addParallaxChild(self.cloudLayer_1, nil, self.cloudLayer1Parallax, ccp(0,0))

	----------------------
	---- Cloud 2 Layer
	-------------------
	local cloudLayer2Parallax = config.worldScene_cloudLayer2Parallax
	assert(cloudLayer2Parallax)
	self.cloudLayer2Parallax = ccp(cloudLayer2Parallax, cloudLayer2Parallax)
	self.cloudLayer_2 = Layer:create()
	self.maskedLayer:addParallaxChild(self.cloudLayer_2, nil, self.cloudLayer2Parallax, ccp(0,0))

	-----------------------------
	----- Cloud Layer 
	----- Parallax Layer
	----- Used To Contain The Background Cloud
	--------------------------
	local cloudParallax = config.worldScene_cloudParallax
	self.cloudLayer3Parallax = ccp(cloudParallax, cloudParallax)
	self.cloudLayer_3 = Layer:create()
	self.maskedLayer:addParallaxChild(self.cloudLayer_3, nil, self.cloudLayer3Parallax, ccp(0,0))

	-----------------------
	-- Scale Small Layers
	-- ---------------------
	self.scaleOutButPreserveInnerLayers = {}

	--------------2016春节烟花----------------
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
		local fireworkParallax = 0.001
		self.fireworkParallax = ccp(fireworkParallax, fireworkParallax)
		self.worldSceneFireworkLayer = SpringFireworkAnimation:create()
		self.maskedLayer:addParallaxChild(self.worldSceneFireworkLayer, nil, self.fireworkParallax, ccp(0,0))
	end
	------------------------------------------

	------------两周年活动浮空岛---------------
	--[[
	self.floatIcons = {}
	local floatIconsLayer = Layer:create()
	self.floatIconsLayer = floatIconsLayer
	self.maskedLayer:addParallaxChild(floatIconsLayer, 5, ccp(1, 1), ccp(0, 0))
	]]
	-------------------------------------------

	-------------------------------
	--	Scale Small Layer 1
	-- --------------------------
	self.scaleTreeLayer1 = Layer:create()--藤蔓树（包含树干，分支树枝，关卡点，特效等）
	self.maskedLayer:addParallaxChild(self.scaleTreeLayer1, nil, ccp(1,1), ccp(0,0))

	---------------------
	--- Hidden Branch Layer 1
	------------------------
	self.hiddenBranchArray = {}

	local hiddenBranchSpriteFrame = Sprite:createWithSpriteFrameName("hide_branch10000")
	local hiddenBranchTexture = hiddenBranchSpriteFrame:getTexture()
	self.hiddenBranchLayer = SpriteBatchNode:createWithTexture(hiddenBranchTexture)
--    self.hiddenBranchLayer = Sprite:createEmpty()
	hiddenBranchSpriteFrame:dispose()
	self.scaleTreeLayer1:addChild(self.hiddenBranchLayer)

	self.hiddenBranchAnimLayer = Layer:create()
	self.scaleTreeLayer1:addChild(self.hiddenBranchAnimLayer)

	-- ---------
	-- Tree Layer
	-- -----------
	self.treeContainer = Layer:create()
	self.trunks = false
	self.scaleTreeLayer1:addChild(self.treeContainer)

    ---------------------
	--- Hidden Branch Layer 2
	------------------------
    FrameLoader:loadArmature( 'skeleton/HiddenBranchAnim' )
    local AnimName = "HiddenBranchAnim/animationxxx"
    local bubble = ArmatureNode:create(AnimName) --UIHelper:createArmature2('skeleton/HiddenBranchAnim','HiddenBranchAnim/animationxxx')
    local texture = bubble:getArmatureTexture()
    self.hiddenBranchBubbleAnimLayer = SpriteBatchNode:createWithTexture(texture)
	bubble:dispose()
	self.scaleTreeLayer1:addChild(self.hiddenBranchBubbleAnimLayer)

    local hiddenBranch2SpriteFrame = Sprite:createWithSpriteFrameName("arrow0000")
	local hiddenBranch2Texture = hiddenBranch2SpriteFrame:getTexture()
	self.hiddenBranchBoxAnimLayer = SpriteBatchNode:createWithTexture(hiddenBranch2Texture)
	hiddenBranch2SpriteFrame:dispose()
	self.scaleTreeLayer1:addChild(self.hiddenBranchBoxAnimLayer)

    self.hiddenBranchTipLayer = Layer:create()
	self.scaleTreeLayer1:addChild(self.hiddenBranchTipLayer)

	------------------------------
	---- Fower Play Anim Layer 
	------------------------------
	-- Because Animation Texture Add Different, So Can't Add To CCSpriteBatchNode
	-- So, Dedicate A Layer For This
	self.playFlowerAnimLayer = Layer:create()
	self.scaleTreeLayer1:addChild(self.playFlowerAnimLayer)

	---------------------------------
	---- Tree Flower Layer (Tree Node Layer) , Batch Node
	---------------------------------
	local flowerSpriteFrame = Sprite:createWithSpriteFrameName("normalFlowerAnim00000")
	local texture = flowerSpriteFrame:getTexture()
	self.treeNodeLayer = SpriteBatchNode:createWithTexture(texture)--关卡点所在的层
	flowerSpriteFrame:dispose()
	self.treeNodeLayer.touchEnabled = false
	self.scaleTreeLayer1:addChild(self.treeNodeLayer)

	self.levelToNode = {}

	---------------------------------------------------
	-- 宝箱（在关卡花和关卡号之间）
	---------------------------------------------------
	self.chestLayer = Layer:create()
	self.scaleTreeLayer1:addChild(self.chestLayer)

	---------------------------------------
	-- Flower Level Number Batch Layer
	-- --------------------------------------------
	self.flowerLevelNumberBatchLayer = BMFontLabelBatch:create("fnt/level_seq_n_energy_cd.png", "fnt/level_seq_n_energy_cd.fnt", 100)
	self.flowerLevelNumberBatchLayer.name = "flowerLevelNumberBatchLayer"
	self.scaleTreeLayer1:addChild(self.flowerLevelNumberBatchLayer)
	table.insert(self.scaleOutButPreserveInnerLayers, self.flowerLevelNumberBatchLayer)

	------------------------------
	--- Explore Cloud Button Layer
	-----------------------------
	self.currentStayBranchIndex = false

	----------------------------
	-- Scale Small Layer 2
	-- ------------------------
	self.scaleTreeLayer2 = Layer:create()--藤蔓树的同步上层（包含解锁云，解锁云动画，好友头像，引导等）
	self.maskedLayer:addParallaxChild(self.scaleTreeLayer2, nil, ccp(1,1), ccp(0,0))

	-- ------------------
	-- Locked Cloud Layer
	-- ------------------
	--self.lockedCloudLayer = Layer:create()
	self.lockedCloudLayer = WorldSceneLockedCloudLayer:create()
	--[[
	function self.lockedCloudLayer:getBlockerShowBatchNode( ... )
		if not self.blockerShowBatchNode then
			local blockerFrame = Sprite:createWithSpriteFrameName("area_blocker_fg0000")
			local texture = blockerFrame:getTexture()
			self.blockerShowBatchNode = SpriteBatchNode:createWithTexture(texture)
			blockerFrame:dispose()

			self:addChild(self.blockerShowBatchNode)
		end

		return self.blockerShowBatchNode
	end

	function self.lockedCloudLayer:getBatchNode( ... )
		if not self.batchNode then
			local cloudSpriteFrame = Sprite:createWithSpriteFrameName("home_clouds0000")
			local texture = cloudSpriteFrame:getTexture()
			self.batchNode = SpriteBatchNode:createWithTexture(texture)
			cloudSpriteFrame:dispose()

			self:addChild(self.batchNode)
		end

		return self.batchNode
	end

	-- 掩藏关卡显示 15-30关全3星开启 文案
	function self.lockedCloudLayer:getHiddenBranchTextBatchNode( ... )
		if not self.hiddenTextBatchNode then
			self.hiddenTextBatchNode = BMFontLabelBatch:create(
				"fnt/tutorial_white.png",
				"fnt/tutorial_white.fnt",
				10
			)
			self:addChild(self.hiddenTextBatchNode)
		end

		return self.hiddenTextBatchNode
	end

	function self.lockedCloudLayer:getHiddenBranchNumberBatchNode( ... )
		if not self.hiddenNumberBatchNode then
			self.hiddenNumberBatchNode = BMFontLabelBatch:create(
				"fnt/event_default_digits.png",
				"fnt/event_default_digits.fnt",
				10
			)
			self:addChild(self.hiddenNumberBatchNode)
		end

		return self.hiddenNumberBatchNode
	end
	]]
	----------------------
	-- Friend Picture Layer
	-- ----------------------
	self.friendPictureLayer = Layer:create()
	self.scaleTreeLayer2:addChild(self.friendPictureLayer)

	self.scaleTreeLayer2:addChild(self.lockedCloudLayer)

	self.lockedCloudAnimLayer = Layer:create()
	self.scaleTreeLayer2:addChild(self.lockedCloudAnimLayer)
	self.lockedCloudAnimLayer:setVisible(false)
	self.lockedClouds = {}
	self.lockedCloudCacheDatas = {}

	self.regionCloudLayer = Layer:create() --每隔120关的阻隔动画
	self.scaleTreeLayer2:addChild(self.regionCloudLayer)
	--self.regionCloudLayer:setVisible(false)

	----------------------
	-- Icon Button Layer
	-- ----------------------
	self.iconButtonLayer = Layer:create()
	self.scaleTreeLayer2:addChild(self.iconButtonLayer)


	self.levelFriendPicStacksByLevelId = {}
	self.levelFriendPicStacks = {}

	self.guideLayer = Layer:create()
	self.scaleTreeLayer2:addChild(self.guideLayer)

	----------------------
	-- Foreground Layer
	-- --------------------
	local foregroundParallax = config.worldScene_foregroundParallax
	assert(foregroundParallax)
	self.foregroundParallax = ccp(foregroundParallax, foregroundParallax)
	self.foregroundLayer = Layer:create()
	self.maskedLayer:addParallaxChild(self.foregroundLayer, nil, self.foregroundParallax, ccp(0,0))


	local frontItemLayerParallax = config.worldScene_frontItemParallax
	self.frontItemLayerParallaxRatio = ccp(frontItemLayerParallax, frontItemLayerParallax)
	self.frontItemLayer = Layer:create()
	self.maskedLayer:addParallaxChild(self.frontItemLayer, nil, self.frontItemLayerParallaxRatio, ccp(0,0))

	--AnniversaryTwoYearsAnimation:init(self)
	------------
	-- Init Layer
	-- ----------------
	WorldSceneShowManager:getInstance():changeCloudColor()
	local parallaxLayer = ResourceManager:sharedInstance():buildGroup("parallax")
	self.parallaxLayer = parallaxLayer

	self:buildTreeContainer() --trunk
	self:buildGradientBackground() --渐变背景
	
	self:buildStarLayer() --春节星星
	self:buildcloudLayer1()
	self:buildcloudLayer2()
	self:buildCloudLayer3()
	self:buildCosmos() --宇宙
	self:buildHiddenBranch() --隐藏关
	self:buildNodeView() --关卡花（和trunk同步）
	self:buildLockedCloudLayer()
	self:buildRegionCloudLayer()
	self:buildForegroundLayer() --前景装饰层（和trunk不同步）
	self:buildBackItemLayer() --背景装饰层（和trunk不同步）
	self:buildFrontItemLayer() --前景Item层（和trunk同步）

	
	---------------------------------
	-- Scale The scaleTreeLayers
	-- ------------------------------
	local config = UIConfigManager:sharedInstance():getConfig()
	local scaleRate = config.homeScene_treeScale
	
	-- -----------------------------------------------------------
	-- Set top Scrollable Range For Base Class WorldSceneScroller
	-- -----------------------------------------------------------
	self:updateTopScrollRange(NewAreaOpenMgr.getInstance():isCurCountdownAreaOver())

	self.maskedLayer:setPositionY(self.visibleOrigin.y - self.belowScrollRangeY)

	-- ---------------
	-- User Picture
	-- ---------------
	local profile = UserManager.getInstance().profile
	self.userIcon = UserPicture:create(self)
	assert(self.userIcon)

	self.userIconDeltaPosY = 0
	self.userIconMovingSpeed = 300	-- pixels per second

	-- Get User Top Level
	local topLevelId = UserManager.getInstance().user:getTopLevelId()
	if _G.isLocalDevelopMode then
		he_log_error("topLevelId==" .. tostring(topLevelId) .. ", kMaxLevels=" .. tostring(kMaxLevels))
	end
	self.topLevelId = topLevelId
	if topLevelId == 0 then topLevelId = 1 end;

	self.levelAreaOpenedId	= UserManager.getInstance().levelAreaOpenedId

	local topLevelNode = self.levelToNode[topLevelId]
	assert(topLevelNode)
	self.userIconLevelId = self.topLevelId

	-- Set User Pic To Top Level Node Postion
	local topLevelNodePos = topLevelNode:getPosition()
	self.userIcon:setPosition(ccp(topLevelNodePos.x, topLevelNodePos.y + self.userIconDeltaPosY))
	self.userIconLayer = Layer:create()
	self.userIconLayer:addChild(self.userIcon)
	self.scaleTreeLayer2:addChild(self.userIconLayer)
	-- self.friendPictureLayer:addChild(self.userIcon)

	--------------------
	-- Friend Pictures
	-- -----------------
	local friendIds = UserManager:getInstance().friendIds
	local friends = FriendManager.getInstance().friends

	-----------------------------
	---- Add Event Listener To Update View When Data Change 
	-----------------------------------------------
	-- self.homeScene:addEventListener(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE, self.onTopLevelChange, self)
	-- self.homeScene:addEventListener(HomeSceneEvents.USERMANAGER_LEVEL_AREA_OPENED_ID_CHANGE, self.onLevelAreaOpenedIdChange, self)

	-- 
	local function passLevelCallback(evt)
		assert(evt, "evt cannot be nil")
		if _G.isLocalDevelopMode then printx(0, "passLevelCallback",table.tostring(evt)) end
		self:onLevelPassed(evt.data)
	end
	GamePlayEvents.addPassLevelEvent(passLevelCallback)

	local function onTopLevelChange(evt)
		self:onTopLevelChange(evt.data)
	end
	GamePlayEvents.addTopLevelChangeEvent(onTopLevelChange)

	local function onAreaOpenIdChange(evt)
		if _G.isLocalDevelopMode then printx(0, "onAreaOpenIdChange",table.tostring(evt)) end
		local newAreaId = evt.data
		self:onAreaOpenIdChange(newAreaId)
	end
	GamePlayEvents.addAreaOpenIdChangeEvent(onAreaOpenIdChange)

	------------------------------------------
	--- Used To Check Which Flower Is Tapped
	------------------------------------------
	self:setTouchEnabled(true, 0 , true)

	self.touchState = false
	self.touchedNode = false
	self.touchedLockedCloud = false

	parallaxLayer:dispose()

	----------------------------------------
	-- Add Event Listener To Update The Flower Stars, 
	-- After Local Synced With Server
	---------------------------------------
	self.trunkInteractionController = WorldSceneTrunkInteractionController:create(self)
	self.branchInteractionController = WorldSceneBranchInteractionController:create(self)
	self:setInteractionController(self.trunkInteractionController)
	if _G.isLocalDevelopMode then
		self.trunkScrollInteractionController = TrunkScrollInteractionController:create(self, 1, self.topLevelId, 1)
		self:updateQuickScrollRange(topLevelId)
	end
	
	local function onSyncFinished(evt)
		if _G.isLocalDevelopMode then printx(0, "WorldScene onSyncFinished Called !") end
		if evt.data == SyncFinishReason.kRestoreData then
			self:onSyncFinished()
		end
	end

	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSyncFinished, onSyncFinished)

	-- ----------------------
	-- Register Script Handler
	-- ----------------------
	local function onEnterHandler(event)
		self:onEnterHandler(event)
	end
	self:registerScriptHandler(onEnterHandler)
	self.missionBubbles = {}

	-- 六一彩蛋
	EggsManager:showIfNecessary(self)


	self:addEventListener(WorldSceneScrollerEvents.HIT_REGION_CLOUD, function(event) self:onHitRegionCloud(event) end)

	ActivityLevelFlourManager:initData(self)
end


function WorldScene:updateTopScrollRange(isCountdownOver)
	local showTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getShowTopLevel(isCountdownOver)
	local topestNormalNode = self.levelToNode[showTopLevel]
	local topestNormalNodePosY = topestNormalNode:getPositionY() + topAdjustY

	-- printx(0, "updateTopScrollRange", isCountdownOver, showTopLevel, topAdjustY)
	self:setTopScrollRange(topestNormalNodePosY, topAdjustY)
end

function WorldScene:updateQuickScrollRange(topLevelId)
	topLevelId = topLevelId or UserManager.getInstance().user:getTopLevelId()
	local topLevelNode = self.levelToNode[topLevelId]
	if topLevelNode then
		self:setQuickScrollRange(topLevelNode:getPositionY())
	end
	if self.trunkScrollInteractionController then
		self.trunkScrollInteractionController:updateScrollData(1, topLevelId)
	end
end

function WorldScene:restoreDisplayLayers()
	self:buildCosmos()
end

function WorldScene:freeDisplayLayers()
	printx(0, "<<\tfree resource from home scene\t>>")


	self.planetLayer:removeFromParentAndCleanup(true)
	self.planetLayer = nil
	printx(0, "free cosmos from world scene")

	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end



function WorldScene:buildCosmos()
	-- local time = os.clock()
	local fileName = 'cosmos'
	-- SpriteUtil:addSpriteFramesWithFile('flash/scenes/homeScene/'..fileName..'.plist', 'flash/scenes/homeScene/'..fileName..'.png')
	self.planetLayer = Layer:create()
	local planet = Sprite:createWithSpriteFrameName("world_bg_planet/lunar0000")
	planet:setAnchorPoint(ccp(0, 0))
	self.planetLayer:addChild(planet)
	local stellar = Sprite:createWithSpriteFrameName("world_bg_planet/solar0000")
	stellar:setAnchorPoint(ccp(0, 0))
	self.planetLayer:addChild(stellar)
	-- local posY = self.trunks:getFlowerPos(1007).y
	-- 这些数字是使用levelId根据关卡花的坐标算出
	local posY = 104944.8
	-- planet:setPositionY(posY)
	-- self.maskedLayer:addParallaxChild(self.planetLayer, 3, ccp(1, 1), ccp(0, 0))
	-- stellar:setPositionY(self.trunks:getFlowerPos(1501).y)
	-- if _G.isLocalDevelopMode then printx(0, '2222222', self.trunks:getFlowerPos(1501).y) end

	-- local planetDustDistance = self.trunks:getFlowerPos(1030).y - self.trunks:getFlowerPos(1005).y
	-- 这是屏幕的滑动距离，大约25个关卡花
	local planetDustDistance = 2623.4

	-- 比例ratio由屏幕滑动的距离和图片真实滑动距离算出
	-- local planet_ratio = planet:getContentSize().height * planet:getScaleY() / planetDustDistance
	local planet_ratio = 0.8
	self.maskedLayer:addParallaxChild(self.planetLayer, 3, ccp(planet_ratio, planet_ratio), ccp(0, 0))
	-- local planetPosY = (posY + self.trunks:getFlowerPos(1008).y - self.trunks:getFlowerPos(1005).y) * planet_ratio
	local planetPosY = (posY + 272.2) * planet_ratio
	planet:setPositionY(planetPosY - 180)
	-- stellar:setPositionY((self.trunks:getFlowerPos(1508).y) * planet_ratio)
	stellar:setPositionY(156042.4 * planet_ratio)
	-- 156842.4
	-- scale根据图片大小以及屏幕尺寸算出
	planet:setPositionX(0)
	planet:setScale(720/960*2)

	stellar:setPositionX(0)
	stellar:setScale(720/960*2)

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local visibleWidth = visibleSize.width
	local centerY = visibleOrigin.y + visibleSize.height / 2
	local centerX = visibleOrigin.x + visibleSize.width / 2

	local constellationGroup = ResourceManager:sharedInstance():buildBatchGroup("sprite", 'constellations')
	local planetsGroup = ResourceManager:sharedInstance():buildBatchGroup("sprite", 'world_bg_planet/planets')
	local batchNode = SpriteBatchNode:createWithTexture(constellationGroup:getTexture())
	batchNode:addChild(constellationGroup)
	batchNode:addChild(planetsGroup)
	self.cosmosBackgroundLayer:addChild(batchNode)

	local nebula1 = constellationGroup:getChildByName("nebula1")
	if nebula1 then
		local moveX = 2000
		local moveY = -(2000/1.732)
		for i = 1, 3 do
			local meteo = nebula1:getChildByName("meteo"..i)
			if meteo then
				local posX = meteo:getPositionX() - 960
				local function resetMeteo()
					local posCenterY = constellationGroup:convertToNodeSpace(ccp(0, centerY)).y
					posCenterY = posCenterY + (i - 2) * 640 + math.random(-300, 300)
					meteo:setScale(math.random(7, 10) / 10)
					meteo:setPositionXY(posX, posCenterY)
					if posCenterY > 600 then
						meteo:setOpacity(math.random(180, 255))
					else
						meteo:setOpacity(0)
					end
				end
				local duration = math.random(20, 40) / 10
				local actArray = CCArray:create()
				actArray:addObject(CCCallFunc:create(resetMeteo))
				actArray:addObject(CCMoveBy:create(duration, ccp(moveX, moveY)))
				actArray:addObject(CCDelayTime:create(math.random(5, 30)))
				meteo:runAction(CCRepeatForever:create(CCSequence:create(actArray)))
			end
		end
	end

	local posY = self.trunks:getFlowerPos(1020).y * self.cosmosBackgroundParallaxRatio.y
	constellationGroup:setPositionX((720-968)/2)
	constellationGroup:setPositionY(posY)

	planetsGroup:setPositionX((720-968)/2)
	planetsGroup:setPositionY(posY + 8100)

	-- self.constellationLayer = Layer:create()
	-- self.constellationLayer:addChild(constellationGroup)
	-- local constellationDistance = 51321.6
	-- local constellation_ratio = constellationGroup:getGroupBounds().size.height / constellationDistance
	-- local pos = (posY + 3597.4) * constellation_ratio + 400
	-- constellationGroup:setPositionY(pos)
	-- self.maskedLayer:addParallaxChild(self.constellationLayer, 2, ccp(constellation_ratio, constellation_ratio), ccp(0, 0))
end

function WorldScene:onHitRegionCloud(event)

	if self.isPlayingRegionCloudAnim then return end

	self.isPlayingRegionCloudAnim = true
	
	local regionCloudY = event.data.y or 0
	local index = event.data.index or 1

	local userTopLevel = UserManager:getInstance().user:getTopLevelId()
	if userTopLevel > index * 120 - 30 then
		if self.regionCloud then
			self.regionCloud:setVisible(false)
		end
	end

	self.regionCloud:setPositionY(regionCloudY + self:getRegionCloudUiOffset())
	self.regionCloud:setPositionX(300)

	local function onFinish()
		self.isPlayingRegionCloudAnim = false
		self.regionCloud:removeFromParentAndCleanup(true)
		self:buildRegionCloudArmature()

		self.regionCloud:playByIndex(0, 1)
		self.regionCloud:update(0.1)
		self.regionCloud:stop()
		self:resumeFromAnimation()
		for k, v in pairs(self.regionCloudYValues) do
			if k == index then
				v.played = true
			end
		end
	end

	setTimeOut(function () self:resumeFromAnimation() end, 3)
	self.regionCloud:removeEventListenerByName(ArmatureEvents.COMPLETE)
	self.regionCloud:addEventListener(ArmatureEvents.COMPLETE, onFinish)
	self.regionCloud:playByIndex(0, 1)
	self.regionCloud:update(0.001)
	self.regionCloud:stop()
	self.regionCloud:playByIndex(0, 1)

	self.regionCloudLayer:addChild(self.regionCloud)
	self.regionCloud:setVisible(true)
end

function WorldScene:setEnterFromGamePlay(levelId, replayMode)
	self.sourceLevelId = levelId
	self.sourceReplayMode = replayMode
end

function WorldScene:buildRegionCloudArmature()
	FrameLoader:loadArmature('skeleton/region_cloud_animation', 'region_cloud', 'region_cloud')
	self.regionCloud = ArmatureNode:create('region_cloud')
	self.regionCloud:setVisible(false)
	self.regionCloud:playByIndex(0, 1)
	self.regionCloud:update(0.001)
	self.regionCloud:stop()
end

function WorldScene:buildRegionCloudLayer()
	self:buildRegionCloudArmature()
	self.regionCloudYValues = {}
	local maxNormalLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	if maxNormalLevelId % 120 == 0 then -- 版本最高关卡不应该显示区域云
		maxNormalLevelId = maxNormalLevelId - 1
	end
	local count = math.floor(maxNormalLevelId / 120)
	for i = 1, count do
		local levelId = i * 120
		local pos = self.trunks:getFlowerPos(tonumber(levelId))
		self.regionCloudYValues[i] = {y = pos.y, played = false}
	end

	-- for k, v in pairs(self.regionCloudYValues) do
	-- 	if _G.isLocalDevelopMode then printx(0, k, v.y, v.played ) end
	-- end
	-- debug.debug()
end

function WorldScene:onEnterHandler(event)
	if _G.isLocalDevelopMode then printx(0, ">>>>> self.levelPassedInfo", table.tostring(self.levelPassedInfo)) end
	if event == "enter" then
		self.isTouched = false
		local levelType = nil
		if self.sourceLevelId then
			local levelId = self.sourceLevelId
			self:moveNodeToCenter(levelId, function()
				if self.sourceReplayMode and self.sourceReplayMode == ReplayMode.kStrategy then 
					self:startLevel(levelId)
				elseif self.levelPassedInfo then
					self:playLevelPassed(self.levelPassedInfo.passedLevelId, self.levelPassedInfo.rewardsIdAndPos, self.levelPassedInfo.isPlayNextLevel, self.levelPassedInfo.jumpLevelPawn, self.levelPassedInfo.userLevelState)
				else
					local node = self.levelToNode[levelId]
					if _G.isLocalDevelopMode then printx(0, "node", node, levelId) end
					if node and not node.isDisposed then node:playParticle() end
				end
				self.sourceReplayMode = nil
				self.levelPassedInfo = nil
			end, true)
			if __IOS or __WIN32 then
				local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
				IosPayGuideProxy:onSuccessiveLevelFailure(self.sourceLevelId)
			end
		end
		self.sourceLevelId = nil
		
		-- 设置完星星数需要解锁隐藏关
		if self.unlockHiddenBranchCloudBranchId then
			self:unlockHiddenBranchCloud(self.unlockHiddenBranchCloudBranchId)
			self.unlockHiddenBranchCloudBranchId = nil
		end
		--self:updateAnniversaryFloatButton()

		self.handFlowerTime = Localhost:timeInSec()--记录关卡花小手开始时间
		if UserManager:getInstance():getUserRef():getTopLevelId() <= 30 then 
			self.handScheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
				local existWindow = PopoutManager:sharedInstance():haveWindowOnScreen() or GameGuide:sharedInstance():getHasCurrentGuide()
				local topLevel = UserManager:getInstance():getUserRef():getTopLevelId()

				local function clearHandFlower()
					self.handFlowerTime = Localhost:timeInSec()
					if self.handFlower then
						self.handFlower:removeFromParentAndCleanup(true)
						self.handFlower = nil
					end
				end

				if topLevel > 30 then
					clearHandFlower()
					self:clearHandFlowerSchedule()
					return
				end
				
				if (not UserManager:getInstance():hasPassedLevelEx(topLevel)) and (Localhost:timeInSec() - self.handFlowerTime >= 5) then
					if not self.handFlower and not existWindow then
						self.handFlower = GameGuideAnims:handclickAnim(0, 0)
						self.handFlower:setAnchorPoint(ccp(0, 1))
						self.guideLayer:addChild(self.handFlower)
					end

					if self.handFlower then
						local pos = self.homeScene:getPositionByLevel(topLevel)
						if pos == nil then 
							clearHandFlower()
						else
							self.handFlower:setPosition(ccp(pos.x + 10, pos.y - 80))
						end
					end
				end

				if self.handFlower and existWindow then
					clearHandFlower()
				end
			end, 1, false)
		end
	elseif event == 'exit' then
		self:clearHandFlowerSchedule()
	end
end

function WorldScene:clearHandFlowerSchedule()
	if self.handScheduleScriptFuncID then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.handScheduleScriptFuncID) 
		self.handScheduleScriptFuncID = nil
	end
end

function WorldScene:setIsTouched(isTouched)
	self.isTouched = isTouched
end

function WorldScene:onSyncFinished(...)
	assert(#{...} == 0)

    AreaUnlockPanelPopoutLogic:localDataCorrect()
	self:onSyncRefreshHiddenBranch()
	self:onSyncRefreshLevelNode()
	self:onSyncRefreshUnlockCloud()
	self:onSyncRefreshHomeSceneAndGuide()
end

function WorldScene:onSyncRefreshLevelNode()
	local metaModel = MetaModel:sharedInstance()
	local scores = UserManager:getInstance().scores
	local hiddenLevelIdList = MetaManager:getInstance():getHideAreaLevelIds()
	local waitToAddHiddenNodes = {}
	for i,v in ipairs(hiddenLevelIdList) do
		waitToAddHiddenNodes[v] = true
	end
	local shouldRemoveList = {}

	local isOrigin = self.scrollHorizontalState == WorldSceneScrollerHorizontalState.SCROLLING_TO_ORIGIN
	
	for k, v in pairs(self.levelToNode) do
		local levelId = v.levelId
		local isHelpedNode = UserManager:getInstance():hasAskForHelpInfo(levelId)
		local ingredientCount = JumpLevelManager:getInstance():getLevelPawnNum(levelId) or 0
		local score = UserManager:getInstance():getUserScore(levelId)
		local isHiddenNode = LevelType:isHideLevel(levelId)
		local shouldRemove = isHiddenNode and not metaModel:isHiddenBranchCanShow(metaModel:getHiddenBranchIdByHiddenLevelId(levelId))
		

		if shouldRemove then
			v:removeFromParentAndCleanup(true)
			table.insert(shouldRemoveList, k)
			waitToAddHiddenNodes[levelId] = nil
		else
			if isHiddenNode then
				local hiddenBranchId = MetaModel:sharedInstance():getHiddenBranchIdByHiddenLevelId(levelId)
				local preHiddenLevelScore = UserManager.getInstance():getUserScore(levelId - 1)
				local isFirstFlowerInHiddenBranch = (MetaModel:sharedInstance():getHiddenBranchDataByHiddenLevelId(levelId) or {}).startHiddenLevel == levelId
				

				local star = -1
				if MetaModel:sharedInstance():isHiddenBranchCanOpen(hiddenBranchId) then
					if score and score.star > 0 then
						star = score.star
					elseif isFirstFlowerInHiddenBranch or (preHiddenLevelScore and preHiddenLevelScore.star > 0) then				
						star = 0
					end

					if star >= 0 then
						local function onNodeTouched(evt)
							self:onNodeViewTapped(evt)
						end
						if not v:hasEventListenerByName(DisplayEvents.kTouchTap) then
							v:addEventListener(DisplayEvents.kTouchTap, onNodeTouched, v)
						end
					else
						if v:hasEventListenerByName(DisplayEvents.kTouchTap) then
							v:removeEventListenerByName(DisplayEvents.kTouchTap)
						end
					end
				end
				v:setStar(star, 0, not isOrigin, false, false)


				waitToAddHiddenNodes[levelId] = nil
			else
				if score or v.levelId == UserManager:getInstance():getUserRef():getTopLevelId() then
					v:setStar(score and score.star or 0, ingredientCount, true, false, false)
					local function onNodeTouched(evt)
						self:onNodeViewTapped(evt)
					end
					if not v:hasEventListenerByName(DisplayEvents.kTouchTap) then
						v:addEventListener(DisplayEvents.kTouchTap, onNodeTouched, v)
					end
				elseif ingredientCount > 0 or isHelpedNode then
					if _G.isLocalDevelopMode then printx(0, "hit no score and jump level", levelId) end
					v:setStar(0, ingredientCount, true, false, false)
					local function onNodeTouched(evt)
						self:onNodeViewTapped(evt)
					end
					if not v:hasEventListenerByName(DisplayEvents.kTouchTap) then
						v:addEventListener(DisplayEvents.kTouchTap, onNodeTouched, v)
					end
				else
					v:setStar(-1, ingredientCount, true, false, false)
					if v:hasEventListenerByName(DisplayEvents.kTouchTap) then
						v:removeEventListenerByName(DisplayEvents.kTouchTap)
					end
				end
			end
		end
	end

	for k, v in pairs(waitToAddHiddenNodes) do
		self:buildHiddenNode(k)
	end

	for i, v in ipairs(shouldRemoveList) do
		self.levelToNode[v] = nil
	end
end

function WorldScene:RefreshHiddenBranchCloud( branchId )
    if self.hiddenBranchArray[branchId] and self.hiddenBranchArray[branchId].cloud then
        self.hiddenBranchArray[branchId].cloud:updateShow()
    end
end

function WorldScene:onSyncRefreshHiddenBranch()
	local metaModel = MetaModel:sharedInstance()
	local branchList = metaModel:getHiddenBranchDataList()

	for index = 1, #branchList do
		if metaModel:isHiddenBranchCanShow(index) then
			if not self.hiddenBranchArray[index] then
				local branch = HiddenBranch:create(index, true, self.hiddenBranchLayer.refCocosObj:getTexture())
				self.hiddenBranchArray[index] = branch
				self.hiddenBranchLayer:addChild(branch)
				metaModel:markHiddenBranchOpen(index)
                
                local branchBox = HiddenBranchBox:create(index, branch, self.hiddenBranchBubbleAnimLayer, self.hiddenBranchTipLayer, self.hiddenBranchBoxAnimLayer.refCocosObj:getTexture() )
	            self.hiddenBranchBoxAnimLayer:addChild(branchBox)
                branch.branchBox = branchBox

				if not metaModel:isHiddenBranchCanOpen(index) then
					branch:showCloud(
						self.lockedCloudLayer:getBatchNode(),
						self.lockedCloudLayer:getHiddenBranchTextBatchNode(),
						self.lockedCloudLayer:getHiddenBranchNumberBatchNode(),
						self.lockedCloudLayer:getHiddenBranchExtraTextNode()
					)
				end

				branch:updateState()

				local function onHiddenBranchTapped(event)
					self:onHiddenBranchTapped(event)
				end

				branch:addEventListener(DisplayEvents.kTouchTap, onHiddenBranchTapped, index)
			end
		else
			if self.hiddenBranchArray[index] then
				self.hiddenBranchArray[index]:removeFromParentAndCleanup(true)
				self.hiddenBranchArray[index] = nil
				metaModel:markHiddenBranchClose(index)
			end
		end
	end
end

function WorldScene:onSyncRefreshUnlockCloud()
	local levelAreaDataArray = MetaModel:sharedInstance():getLevelAreaDataArray()
	local usrCurTopLevel = UserManager.getInstance():getUserRef():getTopLevelId()
	local batchNode = self.lockedCloudLayer:getBatchNode()
	local newCloudLockNode = self.lockedCloudLayer:getNewCloudLockNode()
	local blockerShowNode = self.lockedCloudLayer:getNewBlockerShowNode()

	self:__buildLockedCloudLayer()
	WorldMapOptimizer:getInstance():update(true)

	if dirtyCloud then
		if self.levelAreaOpenedId ~= false then
			self.levelAreaOpenedId = (MetaManager:getInstance():getLevelAreaRefByLevelId(usrCurTopLevel) or {}).id or false
		end
		UserManager:getInstance().levelAreaOpenedId = false
	end

	local logic = AdvanceTopLevelLogic:create(usrCurTopLevel)
	logic:start()

	self:updateLevelData()
	self:checkAndUpdateUnlockTipView()
end

function WorldScene:onSyncRefreshHomeSceneAndGuide()
	if _G.isLocalDevelopMode then printx(0, "WorldScene:onSyncFinished") end
	GameLauncherContext:getInstance():onHomeSceneInitMoveToTop()
	self:updateUserIconPos( function () GameLauncherContext:getInstance():onHomeSceneInitMoveToTopFinish() end )

	local scene = Director:sharedDirector():getRunningScene()
	if scene == HomeScene:sharedInstance() then
		self:refreshTopAreaCloudState()
		if GameGuide then
			GameGuide:sharedInstance():forceStopGuide()
			GameGuide:sharedInstance():tryStartGuide()
		end
	end
end

function WorldScene:getTouchedNode(worldPos, ...)
	assert(worldPos)
	assert(type(worldPos.x) == "number")
	assert(type(worldPos.y) == "number")
	assert(#{...} == 0)

	local childrenList = WorldMapOptimizer:getInstance().itemsMap
	for k,v in pairs(childrenList) do
		if v:hasEventListenerByName(DisplayEvents.kTouchTap) then
			if type(v.getFlowerRes) == "function" then
				local flowerRes = v:getFlowerRes()
				if flowerRes then
					if flowerRes:hitTestPoint(worldPos, true) then
						return v
					end
				end
			end
		end
	end
end

--[[
function WorldScene:getTouchedNode(worldPos, ...)
	assert(worldPos)
	assert(type(worldPos.x) == "number")
	assert(type(worldPos.y) == "number")
	assert(#{...} == 0)

	------ Convert Global Position To Self Space
	--local nodeSpacePoint = self:convertToNodeSpace(ccp(worldPos.x, worldPos.y))

	-- Get Node Layer's Children
	local childrenList = self.treeNodeLayer:getChildrenList()

	for k,v in pairs(childrenList) do

		if v:hasEventListenerByName(DisplayEvents.kTouchTap) then

			local flowerRes = v:getFlowerRes()
			
			if flowerRes then
				if flowerRes:hitTestPoint(worldPos, true) then
					return v
				end
			end
		end
	end
end
--]]

function WorldScene:getTouchedLockedCloud(worldPos, ...)
	assert(#{...} == 0)

	------ Convert Global Position To Self Space
	--local nodeSpacePoint = self:convertToNodeSpace(ccp(worldPos.x, worldPos.y))
	for k,v in pairs(self.lockedClouds) do
		if v:hitTestPoint(worldPos, true) then

			local touchPos = v:convertToNodeSpace(worldPos)

			if v:isCountdownCloud() then 
				if touchPos.x >= 545 and touchPos.x <= 960 and touchPos.y >= -300  then
					return v
				end
			elseif v.id == PLANET_CLOUD_ID_1 or v.id == PLANET_CLOUD_ID_2 then
				if touchPos.x >= 370 and touchPos.x <= 770 and touchPos.y >= -440  then
					return v
				end
			else
				--printx(1 , "WTFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   " , touchPos.x , touchPos.y)
				if touchPos.x >= 300 and touchPos.x <= 700 and touchPos.y >= -250  then
					return v
				end
			end

			--v.canHandleTouchEvt = v:hasEventListenerByName(DisplayEvents.kTouchTap)
		end
	end
end

function WorldScene:getTouchedFriendStack(worldPos, ...)
	assert(#{...} == 0)

	for k,v in pairs(self.levelFriendPicStacks) do
		--if v.stack:hitTestPoint(worldPos, true) then
		if v.stack:isHitted(worldPos) then
			-- 
			if v.levelId ~= kMaxLevels then
				return v.stack
			end
		end
	end
end

function WorldScene:getTouchedBranch(worldPos)
	for k,v in pairs(self.hiddenBranchArray) do
		if v:hasEventListenerByName(DisplayEvents.kTouchTap) then
			if v:hitTestPoint(worldPos, true) then
				return v
			end
		end
	end
end

function WorldScene:getTouchedReward( worldPos )
	for k,v in pairs(self.hiddenBranchArray) do
		local reward = v:getRewardNode()
		if reward then
			if reward:hitTestPoint(worldPos, true) then
				return reward
			end
		end
	end
end

function WorldScene:getTouchedFloatIcon(worldPos)
	for _, floatIcon in pairs(self.floatIcons) do
		if floatIcon:hitTestPoint(worldPos, true) then
			return floatIcon
		end
	end
	return nil
end

--------------------------
--- Touch Event Handler
---------------------------

function WorldScene:onScrolledToLeftOrRight(event, ...)
	assert(event)
	assert(event.name == WorldSceneScrollerEvents.SCROLLED_TO_LEFT or event.name == WorldSceneScrollerEvents.SCROLLED_TO_RIGHT)
	assert(#{...} == 0)

	self:checkInteractionStateChange()
end

function WorldScene:onScrolledToOrigin(event, ...)
	assert(event)
	assert(event.name == WorldSceneScrollerEvents.SCROLLED_TO_ORIGIN)
	assert(#{...} == 0)

	-- assert(self.currentStayBranchIndex)
	self.currentStayBranchIndex = false

	self:checkInteractionStateChange()
	GameGuide:sharedInstance():tryStartGuide()
end

-- check interaction controller state change 
function WorldScene:checkInteractionStateChange( )
	if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT or  
		self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT 
		then
		self:setInteractionController(self.branchInteractionController)
	elseif self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
		self:setInteractionController(self.trunkInteractionController)
	end
end

function WorldScene:setInteractionController(targetController)
	if self.currentController ~= targetController then
		if self.currentController then
			self.currentController:unregister()
		end
		self.currentController = targetController
		self.currentController:register()
	end
end

function WorldScene:setTouchEnabled(flag)
	if flag then
		Layer.setTouchEnabled(self, true, 1, true)
	else
		Layer.setTouchEnabled(self, false)
	end
end

function WorldScene:getLockedCloud(cloudId)
	for i,v in ipairs(self.lockedClouds) do
		if v.id == cloudId and not v.isDisposed then 
			return v
		end
	end
end

function WorldScene:__buildLockedCloudLayer(...)
	-- Get Data
	local metaModel = MetaModel:sharedInstance()
	local levelAreaDataArray = metaModel:getLevelAreaDataArray()
	assert(levelAreaDataArray)

	local lockedCloudNumber = #levelAreaDataArray
	local batchNode = self.lockedCloudLayer:getBatchNode()
	local newCloudLockNode = self.lockedCloudLayer:getNewCloudLockNode()
	local blockerShowBatchNode = self.lockedCloudLayer:getNewBlockerShowNode()

	local function createLockedCloud(datas)
		local id , index , pos = datas.areaId , datas.areaIndex , ccp( datas.cloudX , datas.cloudY ) 
		local lockedCloud = NewLockedCloud:create(id, self.lockedCloudAnimLayer, batchNode.refCocosObj:getTexture(), index)
		lockedCloud:setPositionXY(pos.x, pos.y)
		local blockerShowXDelta = self:getAreaBlockerShowDeltaX(datas.areaId)
		lockedCloud:setAreaBlockerShow( AreaBlockerShow:create(index , pos.x + blockerShowXDelta , pos.y) )
		if lockedCloud.blockerShow.hasBlocker then 
			blockerShowBatchNode:addChild(lockedCloud.blockerShow.ui)
		end
		table.insert(self.lockedClouds, lockedCloud)
		newCloudLockNode:addChildAt(lockedCloud,0)
		HomeScene:sharedInstance():onLockedCloudCreateFinish()
		return lockedCloud
	end

	local function updateLockedCloud(lockedCloud , datas)
		if datas.deleteMode == "remove" then
			newCloudLockNode:addChildAt(lockedCloud,0)
		elseif datas.deleteMode == "reposition" then
			lockedCloud:setPositionXY( datas.cloudX , datas.cloudY ) 
		else
			newCloudLockNode:addChildAt(lockedCloud,0)
		end
		local blockerShowXDelta = self:getAreaBlockerShowDeltaX(datas.areaId)
		lockedCloud.blockerShow:reinit( datas.areaIndex , datas.cloudX + blockerShowXDelta , datas.cloudY )
		lockedCloud:reinit( datas.areaId , datas.areaIndex )

		local lockedCloudSize = lockedCloud:getGroupBounds().size
	
		if lockedCloud.blockerShow.hasBlocker then 
			blockerShowBatchNode:addChild(lockedCloud.blockerShow.ui)

		end
	end

	local function cacheCloudCallback( instance )
		if instance.blockerShow 
			and instance.blockerShow.ui
			and instance.blockerShow.ui:getParent()
			and not instance.blockerShow.ui.isDisposed then
				instance.blockerShow:stopFloat()
				instance.blockerShow.ui:setVisible(false)
		end
	end

	local function deleteCloudCallback( instance ) 
		if instance.blockerShow 
			and instance.blockerShow.ui 
			and instance.blockerShow.ui:getParent() 
			and not instance.blockerShow.ui.isDisposed then
				instance.blockerShow:stopFloat()
				instance.blockerShow.ui:removeFromParentAndCleanup(true)
				instance.blockerShow = nil
		end

		local removeIndex = table.indexOf( self.lockedClouds , instance )
		if removeIndex then
			table.remove(self.lockedClouds, removeIndex)
		end
	end

	if self.lockedClouds ~= nil and #self.lockedClouds > 0 then
		for index = #self.lockedClouds, 1, -1 do
			local lockedCloud = self.lockedClouds[index]
			if lockedCloud ~= nil then
				local cloudContainer = lockedCloud:getParent()
				if cloudContainer ~= nil then
					lockedCloud:removeFromParentAndCleanup(true)
				else
					lockedCloud:dispose()
				end
				deleteCloudCallback(lockedCloud)
			end
		end
	end
	WorldMapOptimizer:getInstance():removeAllClouds()

	local usrCurTopLevel = UserManager.getInstance().user:getTopLevelId()
	self.lockedCloudCacheDatas = {}
	WorldMapOptimizer:getInstance():clearCacheAll()
 
	for index = 1,lockedCloudNumber do
		-- Get Locked Cloud Info
		local lockedCloudInfo = levelAreaDataArray[index]
		assert(lockedCloudInfo)
		assert(lockedCloudInfo.minLevel)
		assert(lockedCloudInfo.star)
		local lockedCloudLevel = tonumber(lockedCloudInfo.minLevel)
		local lockedCloudNeedStar = tonumber(lockedCloudInfo.star)
		local startLevelNode = self.levelToNode[lockedCloudLevel]
		assert(usrCurTopLevel)
		if startLevelNode ~= nil  and 
			lockedCloudNeedStar ~= 0 and 
			lockedCloudLevel > usrCurTopLevel then
				local lockedCloudId = tonumber(levelAreaDataArray[index].id)
				local curLevelAreaData = MetaModel:sharedInstance():getLevelAreaDataById(lockedCloudId)
				local startNodeId = tonumber(curLevelAreaData.minLevel)
				local startNodePos = self.trunks:getFlowerPos(startNodeId)
		
				local lockedCloudSizeWidth, lockedCloudSizeHeight = self:getCloudPosByAreaId(lockedCloudId)
				
				local deltaWidth = self.visibleSize.width - lockedCloudSizeWidth
				local halfDeltaWidth = deltaWidth / 2
				local manualAdjust = -180
				local cloudX, cloudY = self.visibleOrigin.x + halfDeltaWidth, startNodePos.y + lockedCloudSizeHeight + manualAdjust
				local cacheData = {}
				cacheData.id = "NewLockedCloud"
				cacheData.maxInstance = 3
				cacheData.areaId = lockedCloudId
				cacheData.areaIndex = index
				cacheData.cloudX = cloudX
				cacheData.cloudY = cloudY
				cacheData.cloudWidth = lockedCloudSizeWidth
				cacheData.cloudHeight = lockedCloudSizeHeight
				cacheData.minLevel = lockedCloudLevel
				cacheData.deleteMode = "reposition"
				cacheData.createInstanceCallback = createLockedCloud
				cacheData.updateInstanceCallback = updateLockedCloud
				cacheData.cacheInstanceCallback = cacheCloudCallback
				cacheData.deleteInstanceCallback = deleteCloudCallback
				WorldMapOptimizer:getInstance():buildCacheByPosition( ccp( cloudX , cloudY ) , cacheData )
				table.insert(self.lockedCloudCacheDatas, cacheData)
		end
	end
end

function WorldScene:getCloudPosByAreaId(lockedCloudId)
	local lockedCloudSizeWidth = 1010
	local lockedCloudSizeHeight = 309.8
	if lockedCloudId == PLANET_CLOUD_ID_1 or lockedCloudId == PLANET_CLOUD_ID_2 then
		lockedCloudSizeWidth = 1085
		lockedCloudSizeHeight = 575
	end

	local countdownCloudId = NewAreaOpenMgr.getInstance():getCurCountdownArea() 
	if countdownCloudId and countdownCloudId == lockedCloudId then 
		NewAreaOpenMgr.getInstance():insertCountdownAreaId(countdownCloudId)
		lockedCloudSizeWidth = 1509
		lockedCloudSizeHeight = 428
	end
	return lockedCloudSizeWidth, lockedCloudSizeHeight
end

function WorldScene:getAreaBlockerShowDeltaX(lockedCloudId)
	if NewAreaOpenMgr.getInstance():isCountdownArea(lockedCloudId) then 
		return 300
	else
		return 45
	end
end

function WorldScene:buildLockedCloudLayer(...)
	assert(#{...} == 0)

	self:__buildLockedCloudLayer()
	-- -----------------------
	-- Build Top Tree Cloud
	-- -----------------------
	local topestNormalNode = self.levelToNode[self.maxNormalLevelId]
	local cloud = TreeTopLockedCloud:create()
	-- local cloudSize = cloud:getGroupBounds().size
	cloud:setPositionY(topestNormalNode:getPositionY() + 540)
	cloud:setPositionX(self.visibleOrigin.x - self.visibleSize.width/2)
	self.lockedCloudLayer:addChild(cloud)
	self.topAreaCloud = cloud
	self:refreshTopAreaCloudState()
end

function WorldScene:refreshTopAreaCloudState()
	if UserManager.getInstance().user:getTopLevelId() == self.maxNormalLevelId 
		and UserManager:getInstance():hasPassedLevelEx(self.maxNormalLevelId) then
		self.topAreaCloud:playAnim()
		return true
	end
	return false
end

function WorldScene:getLockedCloudById(lockedCloudId, ...)
	assert(type(lockedCloudId) == "number")
	assert(#{...} == 0)


	for index,v in pairs(self.lockedClouds) do
		if v.id == lockedCloudId and not v.isCachedInPool then
			return v
		end
	end
end

function WorldScene:buildGradientBackground()
	local background = self.parallaxLayer:getChildByName("background")
	local winSize = CCDirector:sharedDirector():getWinSize()
	local posX = winSize.width / 2
	-- new bg
	local gradients = {
		{startColor="3d0378", endColor="3d0378", height=0},
		{startColor="3d0378", endColor="420ab4", height=19},
		{startColor="420ab4", endColor="106dcf", height=10},
		{startColor="106dcf", endColor="3930eb", height=21},
		{startColor="3930eb", endColor="2572ff", height=23},
		{startColor="2572ff", endColor="13b1fc", height=22},
		{startColor="13b1fc", endColor="83dfef", height=15},
	}
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
		gradients = {
			{startColor="3d0378", endColor="3d0378", height=0},
			{startColor="3d0378", endColor="420ab4", height=19},
			{startColor="420ab4", endColor="106dcf", height=10},
			{startColor="106dcf", endColor="3930eb", height=21},
			{startColor="3930eb", endColor="2572ff", height=23},
			{startColor="2572ff", endColor="13b1fc", height=22},
			{startColor="13b1fc", endColor="83dfef", height=15},
		}
	end
	if WorldSceneShowManager:getInstance().showType == 2 then
		gradients = {
			{startColor="3d0378", endColor="3d0378", height=0},
			{startColor="3d0378", endColor="420ab4", height=19},
			{startColor="420ab4", endColor="4b43cc", height=10},
			{startColor="4b43cc", endColor="4e3bbe", height=21},
			{startColor="4e3bbe", endColor="5133b2", height=23},
			{startColor="5133b2", endColor="542ba6", height=22},
			{startColor="542ba6", endColor="591f93", height=15},
		}
	end
	local bgColor = self:buildBackgroundLayer(gradients)
	
	bgColor:setAnchorPoint(ccp(0.5, 0))
	bgColor:ignoreAnchorPointForPosition(false)
	bgColor:setPositionX(posX)
	bgColor.name = "background"
	self.gradientBackgroundLayer:addChild(bgColor)
end

-- 创建多重渐变色的天空背F景
function WorldScene:buildBackgroundLayer(gradients)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local topLevel = MetaManager:getInstance():getMaxNormalLevelByLevelArea()
	local topLevelPos = self.trunks:getFlowerPos(topLevel)
	local config = UIConfigManager:sharedInstance():getConfig()

	local width = winSize.width + self:getHorizontalScrollRange() * self.gradientBackgroundParallaxRatio.x + 10
	local height = topLevelPos.y * config.worldScene_foregroundParallax * config.worldScene_backgroundParallax + 650

	local originHeight = 0
	for _, v in pairs(gradients) do
		originHeight = originHeight + v.height
	end
	local heightScale = 30 --height / originHeight
	if height > originHeight * heightScale then
		-- 将最上面的一个渐变(纯色)拉伸
		gradients[1].height = gradients[1].height + height - originHeight * heightScale
	end
	local bgLayer = Layer:create()
	bgLayer:setContentSize(CCSizeMake(width, height))

	local offsetPosY = 0
	for index = #gradients, 1, -1 do
		local gradient = gradients[index]
		local layerHeight = gradient.height * heightScale
		if layerHeight > 0 then
			local lg = LayerGradient:createWithColor(hex2ccc3(gradient.startColor), hex2ccc3(gradient.endColor))
			lg:changeWidthAndHeight(width, layerHeight+1) -- +1让最后一个像数与下一个渐变的第一个像数重合
			lg:setPosition(ccp(0, offsetPosY))
			bgLayer:addChild(lg)

			offsetPosY = offsetPosY + layerHeight
		end
	end
	return bgLayer
end



function WorldScene:buildBackItemLayer()

	--local balloon = AnniversaryTwoYearsAnimation:buildBalloon()
	--self.backItemLayer:addChild(  balloon  )

end

-- 主界面星星先关（春节用 已过期）
function WorldScene:buildStarLayer()
	local star1Layer = self.parallaxLayer:getChildByName("star1")
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() then
		local groupBounds = star1Layer:getGroupBounds().size
		assert(star1Layer)
		for i=1,80 do
			local star = star1Layer:getChildByName("star"..i)
			if star then 		
				local scale = star:getScaleX()
				local pos = star:getPosition()
				local alpha = math.random(5, 10)/10
				local realStar = Sprite:createWithSpriteFrameName("home_scene_star.png")
				realStar:setScale(scale)
				realStar:setPosition(ccp(pos.x,pos.y+groupBounds.height+200))
				realStar:setAlpha(alpha)
				self.star1Layer:addChild(realStar)
			end
		end
		star1Layer:removeFromParentAndCleanup(true)
	else
		star1Layer:removeFromParentAndCleanup(true)
	end
end

function WorldScene:buildcloudLayer1(...)
	assert(#{...} == 0)

	local cloudLayer1 = self.parallaxLayer:getChildByName("cloud1")
	assert(cloudLayer1)
	if WorldSceneShowManager:getInstance():getShowType() == 2 then
		for i=1, 4 do
			local cloud = cloudLayer1:getChildByName("cloud"..i)
			if i == 3 then 
				cloud:setAlpha(0.7)
			else
				cloud:setAlpha(0.5)
			end
		end
	end
	
	cloudLayer1:removeFromParentAndCleanup(false)
	self.cloudLayer_1:addChild(cloudLayer1)
end

function WorldScene:buildcloudLayer2(...)
	assert(#{...} == 0)

	local cloudLayer2 = self.parallaxLayer:getChildByName("cloud2")
	assert(cloudLayer2)
	if WorldSceneShowManager:getInstance():getShowType() == 2 then
		for i=1, 6 do
			local cloud = cloudLayer2:getChildByName("cloud"..i)
			cloud:setAlpha(0.7)
		end
	end

	cloudLayer2:removeFromParentAndCleanup(false)
	self.cloudLayer_2:addChild(cloudLayer2)
end

function WorldScene:buildCloudLayer3(...)
	assert(#{...} == 0)

	local cloudLayer3 = self.parallaxLayer:getChildByName("cloud3")
	assert(cloudLayer3)
	if WorldSceneShowManager:getInstance():getShowType() == 2 then
		for i=1, 7 do
			local cloud = cloudLayer3:getChildByName("cloud"..i)
			cloud:setAlpha(0.9)
		end
	end

	cloudLayer3:removeFromParentAndCleanup(false)
	self.cloudLayer_3:addChild(cloudLayer3)
end

function WorldScene:buildForegroundLayer(...)
	assert(#{...} == 0)
	
	local foreground = self.parallaxLayer:getChildByName("foreground")
	foreground:removeFromParentAndCleanup(false)

	self.foregroundLayer:addChild(foreground)
end

function WorldScene:checkAndUpdateUnlockTipView()
	local topLevel = UserManager:getInstance().user:getTopLevelId()
	if not MetaManager.getInstance():getNextLevelAreaRefByLevelId(topLevel) then
		return
	end

	local unlockAreaId = MetaManager.getInstance():getNextLevelAreaRefByLevelId(topLevel).id
	local scores = UserManager:getInstance().scores
	local maxLevel = UserManager:getInstance():getMaxLevelInOpenedRegion()
	self:removeUnlockCloudTipHand()

	if topLevel ~= maxLevel then return end
	if not UserManager:getInstance():hasPassedLevelEx(topLevel) then return end
		
	local cloudData = self.lockedCloudCacheDatas[1]
	if not cloudData then
		return --已位于最高区域，没有任何能解锁的区域了
	end
	local tarPos = ccp( cloudData.cloudX , cloudData.cloudY )

	local unLockFriendInfos = UserManager:getInstance().unLockFriendInfos
	local friendList = {}
	for k,v in pairs(unLockFriendInfos) do
		if tonumber(v.id) == tonumber(unlockAreaId) then
			
			for i = 1 , #v.friendUids do
				table.insert( friendList , v.friendUids[i] )
			end
			break
		end
	end

	local npcNum = UserManager:getInstance():getUnlockNPCFriendNumber( unlockAreaId )
	if npcNum > 0 then
		for i = 1 , npcNum do
			table.insert( friendList , -1 )
		end
	end

	local canFriendUnlock = false
	local canTimeUnlock = false
	local leftSecUnlock = nil
	if friendList and #friendList >= 3 then
		canFriendUnlock = true
	end

	if self.areaUnlockCountDownID ~= nil then
		cancelTimeOut(self.areaUnlockCountDownID)
	end

	if not canFriendUnlock then 
		canTimeUnlock, leftSecUnlock = UserManager:getInstance():canUnlockAreaByTime( unlockAreaId )
		if canTimeUnlock then

		elseif leftSecUnlock ~= nil then
			self.areaUnlockCountDownID = setTimeOut(function()
				self:checkAndUpdateUnlockTipView()
			end, leftSecUnlock)
		end
	end

	-- 有了别的小手了，这段就不要了	
	-- local unlockdata = Localhost:readUnlockLocalInfo()
	-- if topLevel == 45 and not unlockdata.guideHandOn45 then
	-- 	local hand = GameGuideAnims:handclickAnim(0.5, 0.3)
	-- 	hand:setAnchorPoint(ccp(0, 1))
	-- 	hand:setPosition( ccp( tarPos.x + 510 , tarPos.y - 180 ) )
	-- 	self.frontItemLayer:addChild( hand )
	-- 	self.unlockCloudTipHand = hand
	-- 	unlockdata.guideHandOn45 = true
	-- 	Localhost:saveUnlockLocalInfo(unlockdata)
	-- end
end

function WorldScene:buildFrontItemLayer(...)
	
	self:checkAndUpdateUnlockTipView()

	--local plane = AnniversaryTwoYearsAnimation:buildPlane()

	--self.frontItemLayer:addChild( plane )
end

function WorldScene:removeUnlockCloudTipHand()
	if self.unlockCloudTipHand then
		self.unlockCloudTipHand:stopAllActions()
		self.unlockCloudTipHand:removeFromParentAndCleanup(true)
		self.unlockCloudTipHand = nil
	end
end

function WorldScene:buildFriendPicture(bForceUpdate)
	GameLauncherContext:getInstance():onBuildFriendPic()
	local start = os.clock()

	if _G.isLocalDevelopMode then printx(0, "WorldScene:buildFriendPicture Called !") end

	local friendIds = UserManager:getInstance().friendIds
	local friends = FriendManager.getInstance().friends

	-- 当自己的头像 和 被点击的 friend stack 处在同一关的时候。
	-- friend stack 展开和收缩的时候，自己头像上的 “你” 的字样要 相应的消失和展现
	local function onFriendPicStackStateChange(friendPicStack, newState, ...)
		assert(type(friendPicStack) == "table")
		checkFriendPicStackState(newState)
		assert(#{...} == 0)

		local friendPicStackLevelId = friendPicStack:getLevelId()
		local topLevel = UserManager:getInstance().user:getTopLevelId()

		if topLevel == friendPicStackLevelId then
			
			if newState == FriendPicStackState.FRIEND_PIC_SHOW_STATE_EXPANDED then
				if self.userIcon then
					self.userIcon:setLabelVisible(false)
				end
			elseif newState == FriendPicStackState.FRIEND_PIC_SHOW_STATE_HIDEED then
				if self.userIcon then
					self.userIcon:setLabelVisible(true)
				end
			end
		end
	end

	local function onFriendPicTappedCallback( evt )
		if UserManager.getInstance():hasPassedLevel(kMaxLevels) then
			return
		end
		local friendPicStack = evt.target
		if friendPicStack:getLevelId() == kMaxLevels then
			self:onTopPictureClicked()
		end
	end

	if bForceUpdate then--强制刷新大藤蔓上的
		self.friendPictureLayer:removeChildren()
		self.levelFriendPicStacksByLevelId = {}
	end

	----------------------------------
	-- Set The Friend Stack Clean Flag
	------------------------------------
	for k,v in pairs(self.levelFriendPicStacksByLevelId) do
		v:setFriendPicsCleanFlag()
	end

	local picStackIds = {}
	local trimmedFriendIDs = FriendUtil:getTrimmedFriendsForWorldScene()
	for k,v in pairs(trimmedFriendIDs) do
		assert(type(v) == "string")
		-- assert(friends[v])
		if friends[v] then
			local friendLevel = friends[v].topLevelId
			local levelNode = false
		
			--assert(type(friendLevel) == "number")
			if friendLevel then
				levelNode = self.levelToNode[friendLevel]
			end

			if levelNode and friendLevel > 20 and not ModuleNoticeConfig.hasNoticeInLevel(friendLevel) then

				if not self.levelFriendPicStacksByLevelId[friendLevel] then
					local friendPicStack = FriendPicStack:create(friendLevel, self.userIcon)
					-- friendPicStack:setExpanHideCallback(onFriendPicStackStateChange)
					friendPicStack:setTouchEnabled(false)
					-- friendPicStack:addEventListener(DisplayEvents.kTouchTap,onFriendPicTappedCallback)

					self.levelFriendPicStacksByLevelId[friendLevel] = friendPicStack
					-- if _G.isLocalDevelopMode then printx(0, "friendLevel",friendLevel) end
					table.insert(self.levelFriendPicStacks, {stack = friendPicStack, levelId = friendLevel})

					local nodePos = levelNode:getPosition()

					local manualAdjustPosY = self.userIconDeltaPosY + 2
					friendPicStack:setPosition(ccp(nodePos.x-2, nodePos.y + manualAdjustPosY))
					self.friendPictureLayer:addChild(friendPicStack)
					WorldMapOptimizer:getInstance():buildCache(friendPicStack , 2)
					if __WP8 and self.visibleSize and self.visibleOrigin and self.maskedLayer then
						local childPositionY = self.maskedLayer:getPositionY() + friendPicStack:getPositionY()
						local canShow = childPositionY > self.visibleOrigin.y and childPositionY < self.visibleOrigin.y + self.visibleSize.height
						if canShow and not friendPicStack:isVisible() then
							friendPicStack:setVisible(true)
						elseif not canShow and friendPicStack:isVisible() then
							friendPicStack:setVisible(false)
						end
					end
				end

				if not picStackIds[friendLevel] then
					picStackIds[friendLevel] = {}
				end
				table.insert(picStackIds[friendLevel], tonumber(friends[v].uid))
			end
		end
	end

	---------------------------
	-- 向每个关卡stack内添加好友信息
	---------------------------
	local function sort(p1, p2)
		local f1 = FriendManager:getInstance():getFriendInfo(tostring(p1))
		local f2 = FriendManager:getInstance():getFriendInfo(tostring(p2))
		if f1 and f2 then
			if f1.customProfile and f2.customProfile or (not f1.customProfile and not f2.customProfile) then
				return tonumber(f1.uid) > tonumber(f2.uid)
			else
				return f2.customProfile
			end
		else
			if f1 then
				return false
			elseif f2 then
				return true
			else
				return false
			end
		end
	end

	-- for k, v in pairs(picStackIds) do
	-- 	if #v > 0 then
	-- 		table.sort(v, sort)
	-- 		-- 整多了太卡，限制个数目
	-- 		-- local limit = math.min(#v,5)
	-- 		local limit = #v
	-- 		for i = 1, limit do
	-- 			-- if _G.isLocalDevelopMode then printx(0, v[i], FriendManager:getInstance():getFriendInfo(tostring(v[i])).customProfile, k) end
	-- 			self.levelFriendPicStacksByLevelId[k]:addFriendId(v[i])
	-- 		end
	-- 	end
	-- end
	-- ============ 以下代码等价于上面注释中的代码，性能原因改成逐帧创建，看不懂别怪我 ============
	-- ============ 晦涩难懂 start ============
	local totalFriendPicRenderCount = 0
	local currentFriendPicRenderCount = 0
	for k, v in pairs(picStackIds) do
		if #v > 0 then
			table.sort(v, sort)
			totalFriendPicRenderCount = totalFriendPicRenderCount + (#v)
		end
	end

	local function unscheduleScript()
		if self.scheduleScriptFuncID then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID) 
			self.scheduleScriptFuncID = nil
		end
	end

	local function checkFriendPicForStackComplete()
		if (currentFriendPicRenderCount == totalFriendPicRenderCount) then
			unscheduleScript()
			GameLauncherContext:getInstance():onBuildFriendPicFinished()
		end
	end

	--添加好友代打图标
	local successRecords = UserManager:getInstance().successRecords
	if not successRecords then successRecords = {} end
	local helpPicStackIds = {}
	for _, v in pairs(successRecords) do
		local helpLevelId = v.levelId
		local levelNode = self.levelToNode[helpLevelId]
		if (not UserManager:getInstance():hasPassedLevel(helpLevelId)) and levelNode then 
			if self.levelFriendPicStacksByLevelId[helpLevelId] and picStackIds[helpLevelId] then
				table.insert(picStackIds[helpLevelId], 1, v)
			else
				if not helpPicStackIds[helpLevelId] then
					local helpPicStack = FriendPicStack:create(helpLevelId, self.userIcon)
					helpPicStack:setTouchEnabled(false)
					self.levelFriendPicStacksByLevelId[helpLevelId] = helpPicStack
					table.insert(self.levelFriendPicStacks, {stack = helpPicStack, levelId = helpLevelId})

					local nodePos = levelNode:getPosition()
					local manualAdjustPosY = self.userIconDeltaPosY + 2
					helpPicStack:setPosition(ccp(nodePos.x-2, nodePos.y + manualAdjustPosY))
					self.friendPictureLayer:addChild(helpPicStack)
					WorldMapOptimizer:getInstance():buildCache(helpPicStack , 2)

					helpPicStackIds[helpLevelId] = v
				end
			end
			totalFriendPicRenderCount = totalFriendPicRenderCount + 1
		end
	end

	-- 切换场景会如何。。。
	unscheduleScript()
	self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() 
		-- if _G.isLocalDevelopMode then printx(0, "in ssssssssss===========") end
		for k, v in pairs(helpPicStackIds) do 
			currentFriendPicRenderCount = currentFriendPicRenderCount+1
			helpPicStackIds[k] = nil
			self.levelFriendPicStacksByLevelId[k]:addHelpId(v.profile)
			self.levelFriendPicStacksByLevelId[k]:getLayerList().head:setVisible(true)
			self.levelFriendPicStacksByLevelId[k]:setExpanHideCallback(onFriendPicStackStateChange)
			self.levelFriendPicStacksByLevelId[k]:setTouchEnabled(true)
			self.levelFriendPicStacksByLevelId[k]:addEventListener(DisplayEvents.kTouchTap,onFriendPicTappedCallback)
			break
		end

		for k, v in pairs(picStackIds) do
			if #v > 0 then
				currentFriendPicRenderCount=currentFriendPicRenderCount+1
				local lenV = #v
				local friendInfo = v[lenV]
				table.remove(v,lenV)
				
				if friendInfo then
					if type(friendInfo) == "number" then
						if FriendManager.getInstance().friends[tostring(friendInfo)] then
							self.levelFriendPicStacksByLevelId[k]:addFriendId(friendInfo)
						end
					else
						self.levelFriendPicStacksByLevelId[k]:addHelpId(friendInfo.profile)
					end
				end

				-- 当前stack完成添加
				if (lenV == 1 ) then
					self.levelFriendPicStacksByLevelId[k]:getLayerList().head:setVisible(true)
					self.levelFriendPicStacksByLevelId[k]:setExpanHideCallback(onFriendPicStackStateChange)
					self.levelFriendPicStacksByLevelId[k]:setTouchEnabled(true)
					self.levelFriendPicStacksByLevelId[k]:addEventListener(DisplayEvents.kTouchTap,onFriendPicTappedCallback)
				end

				checkFriendPicForStackComplete()
				break
			end
		end
	end,0.15,false)
	-- ============ 晦涩难懂 end ============

	---------------------------
	-- Clean Friend Stack By Clean Flag
	-- -----------------------------
	for k,v in pairs(self.levelFriendPicStacksByLevelId) do
		v:cleanFriendPicsBasedOnCleanFlag()
	end

	-- --------------------------------
	-- Sort FriendPicStack's By Level Id
	-- --------------------------------
	local function sortByLevelId(para1, para2)
		if para1.levelId < para2.levelId then
			return true
		end
		return false
	end
	table.sort(self.levelFriendPicStacks, sortByLevelId)

	---------------------------
	-- 将FriendPicStack添加到layer上
	---------------------------
	for index = #self.levelFriendPicStacks,1,-1 do
		self.levelFriendPicStacks[index].stack:removeFromParentAndCleanup(false)
		self.friendPictureLayer:addChild(self.levelFriendPicStacks[index].stack)
	end

	----------------------------
	-- Set User Picture To Top
	-- -----------------------
	local userIconParent = self.userIcon:getParent()
	self.userIcon:removeFromParentAndCleanup(false)
	userIconParent:addChild(self.userIcon)
	local button = HomeScene:sharedInstance().starRewardButton
	if button then
		local layer = button:getParent()
		button:removeFromParentAndCleanup(false)
		layer:addChild(button)
	end
	local button = HomeScene:sharedInstance().inviteFriendBtn
	if button then
		local layer = button:getParent()
		button:removeFromParentAndCleanup(false)
		layer:addChild(button)
	end

	WorldMapOptimizer:getInstance():update(bForceUpdate)

	if _G.isLocalDevelopMode then printx(0, "=======================================================") end
	if _G.isLocalDevelopMode then printx(0, "=======================================================") end
	if _G.isLocalDevelopMode then printx(0, " =========== buildFriendPicture use: ================ ",(os.clock() - start)) end
	if _G.isLocalDevelopMode then printx(0, "=======================================================") end
	if _G.isLocalDevelopMode then printx(0, "=======================================================") end
end

function WorldScene:buildTreeContainer(...)
	assert(#{...} == 0)

	local numNormalLevel = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	local trunks = Trunks:create(numNormalLevel)
	self.trunks = trunks

	--self.trunks:setVisible(false)
	self.treeContainer:addChild(trunks)
end

function WorldScene:buildHiddenBranch(...)
	assert(#{...} == 0)
	
	local metaModel = MetaModel:sharedInstance()
	local branchList = metaModel:getHiddenBranchDataList()
	for index = 1, #branchList do
		-- if metaModel:isHiddenBranchCanOpen(index) then
		if metaModel:isHiddenBranchCanShow(index) then
			local branch = HiddenBranch:create(index, true, self.hiddenBranchLayer.refCocosObj:getTexture())
			self.hiddenBranchArray[index] = branch
			self.hiddenBranchLayer:addChild(branch)
			metaModel:markHiddenBranchOpen(index)

            local branchBox = HiddenBranchBox:create(index, branch, self.hiddenBranchBubbleAnimLayer, self.hiddenBranchTipLayer, self.hiddenBranchBoxAnimLayer.refCocosObj:getTexture())
	        self.hiddenBranchBoxAnimLayer:addChild(branchBox)
            branch.branchBox = branchBox

			if not metaModel:isHiddenBranchCanOpen(index) then
				branch:showCloud(
					self.lockedCloudLayer:getBatchNode(),
					self.lockedCloudLayer:getHiddenBranchTextBatchNode(),
					self.lockedCloudLayer:getHiddenBranchNumberBatchNode(),
					self.lockedCloudLayer:getHiddenBranchExtraTextNode()
				)
			end

			branch:updateState()

			local function onHiddenBranchTapped(event)
				self:onHiddenBranchTapped(event)
			end

			branch:addEventListener(DisplayEvents.kTouchTap, onHiddenBranchTapped, index)
		end
	end

	local function showCloudLabel( ... )
		for k,v in pairs(self.hiddenBranchArray) do
			v:showCloudLabel()
		end
	end
	local function hideCloudLabel( ... )
		for k,v in pairs(self.hiddenBranchArray) do
			v:hideCloudLabel()
		end
	end

	local cloudLabelIsShow = false
	self:addEventListener(WorldSceneScrollerEvents.BRANCH_MOVING_STARTED,function( ... )
		if not cloudLabelIsShow and self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
			showCloudLabel()
			cloudLabelIsShow = true
		end
	end)
	self:addEventListener(WorldSceneScrollerEvents.START_SCROLLED_TO_RIGHT,function( ... )
		if not cloudLabelIsShow then
			showCloudLabel()
			cloudLabelIsShow = true
		end
	end)
	self:addEventListener(WorldSceneScrollerEvents.START_SCROLLED_TO_LEFT,function( ... )
		if not cloudLabelIsShow then
			showCloudLabel()
			cloudLabelIsShow = true
		end
	end)
	self:addEventListener(WorldSceneScrollerEvents.SCROLLED_TO_ORIGIN, function( ... )
		if cloudLabelIsShow then
			hideCloudLabel()
			cloudLabelIsShow = false
		end
	end)


end

function WorldScene:buildNodeView(...)
	assert(#{...} == 0)

	self.maxNormalLevelId = MetaManager.getInstance():getMaxNormalLevelByLevelArea()
	if (_G.isPrePackage) then
		self.maxNormalLevelId = _G.prePackageMaxLevel
	end
	
	for normalLevelId = 1, self.maxNormalLevelId do
		self:buildNormalNode(normalLevelId)
	end

	local hiddenLevelIdList = MetaManager.getInstance():getHideAreaLevelIds()
	for i, hiddenLevelId in ipairs(hiddenLevelIdList) do
		self:buildHiddenNode(hiddenLevelId)
	end
end

function WorldScene:buildNormalNode(levelId)
	local userTopLevelId = tonumber(UserManager.getInstance().user:getTopLevelId())
	if userTopLevelId == nil or userTopLevelId < 1 then userTopLevelId = 1 end

	local nodeView

	local id = levelId
	if not LevelType:isMainLevel(levelId) then return end

	nodeView = WorldMapNodeView:create(true, id, self.playFlowerAnimLayer, self.flowerLevelNumberBatchLayer, self.treeNodeLayer.refCocosObj:getTexture())

	self.levelToNode[id] = nodeView

	local pos = self.trunks:getFlowerPos(tonumber(levelId))
	nodeView:setPositionXY(pos.x, pos.y)

	if id <= userTopLevelId then
		local curLevelScore = UserManager.getInstance():getUserScore(id)
		if curLevelScore and curLevelScore.star > 0 then
			nodeView:setStar(curLevelScore.star, 0, false, false, false)
		else
			local ingredientCount = JumpLevelManager:getInstance():getLevelPawnNum(id)
			nodeView:setStar(0, ingredientCount, false, false, false)
		end
	end

	if nodeView then
		self.treeNodeLayer:addChild(nodeView)
		nodeView:updateView(false, false)
		WorldMapOptimizer:getInstance():buildCache(nodeView , 1)

		local context_self_nodeview = self
		local function onNodeViewTapped_inner(event)
			context_self_nodeview:onNodeViewTapped(event)
		end

		local function onLevelCanPlay(event, ...)
			assert(event)
			assert(event.name == WorldMapNodeViewEvents.FLOWER_OPENED_WITH_NO_STAR)
			assert(event.data)
			assert(#{...} == 0)

			local levelId = event.data
			local node = self.levelToNode[levelId]
			if node then
				node:addEventListener(DisplayEvents.kTouchTap, onNodeViewTapped_inner, node)
			end
		end

		local function onGetNewStarLevel(event)
			self:onGetNewStarLevel(event)
		end

		nodeView:addEventListener(WorldMapNodeViewEvents.FLOWER_OPENED_WITH_NO_STAR, onLevelCanPlay)
		nodeView:addEventListener(WorldMapNodeViewEvents.OPENED_WITH_NEW_STAR, onGetNewStarLevel)
		nodeView:addEventListener(WorldMapNodeViewEvents.OPENED_WITH_JUMP, onGetNewStarLevel)
		
		if id <= userTopLevelId then
			nodeView:addEventListener(DisplayEvents.kTouchTap, onNodeViewTapped_inner, nodeView)
		end
	end
end

function WorldScene:buildHiddenNode(levelId)
	local nodeView
	local id = levelId
	if not LevelType:isHideLevel(levelId) then return end

	local hiddenLevelScore = UserManager.getInstance():getUserScore(id)
	local preHiddenLevelScore = UserManager.getInstance():getUserScore(id - 1)

	local hiddenBranchId = MetaModel:sharedInstance():getHiddenBranchIdByHiddenLevelId(id)
	assert(hiddenBranchId)

	local isFirstFlowerInHiddenBranch = false
	local hiddenBranchData = MetaModel:sharedInstance():getHiddenBranchDataByHiddenLevelId(id)
	assert(hiddenBranchData)
	if hiddenBranchData.startHiddenLevel == id then
		isFirstFlowerInHiddenBranch = true
	end

	if not MetaModel:sharedInstance():isHiddenBranchCanShow(hiddenBranchId) then
		return
	end

	if MetaModel:sharedInstance():isHiddenBranchDesign(hiddenBranchId) then
		return
	end

	nodeView = WorldMapNodeView:create(false, id, self.playFlowerAnimLayer, self.flowerLevelNumberBatchLayer, self.treeNodeLayer.refCocosObj:getTexture())
	self.levelToNode[id] = nodeView

	local indexInBranch = id - hiddenBranchData.startHiddenLevel + 1
	local posX = 0
	local posY = 0
	local rightBranchOffsetX = {150, 300, 450}
	local rightBranchOffsetY = {80, 150, 160}
	local leftBranchOffsetX = {-150, -300, -450}
	local leftBranchOffsetY = {80, 150, 160}
	if hiddenBranchData.type == "1" then
		posX = hiddenBranchData.x + rightBranchOffsetX[indexInBranch]
		posY = hiddenBranchData.y + rightBranchOffsetY[indexInBranch]
	elseif hiddenBranchData.type == "2" then
		posX = hiddenBranchData.x + leftBranchOffsetX[indexInBranch]
		posY = hiddenBranchData.y + leftBranchOffsetY[indexInBranch]
	end
	nodeView:setPosition(ccp(posX, posY))

	local star = -1
	if MetaModel:sharedInstance():isHiddenBranchCanOpen(hiddenBranchId) then
		if hiddenLevelScore and hiddenLevelScore.star > 0 then
			star = hiddenLevelScore.star
		elseif isFirstFlowerInHiddenBranch or (preHiddenLevelScore and preHiddenLevelScore.star > 0) then				
			star = 0
		end

		if star >= 0 then
			local function onNodeViewTapped_inner(event)
				self:onNodeViewTapped(event)
			end
			nodeView:addEventListener(DisplayEvents.kTouchTap, onNodeViewTapped_inner, nodeView)
		end
	end

	local function onGetNewStarLevel(event)
		self:onGetNewStarLevel(event)
	end
	nodeView:addEventListener(WorldMapNodeViewEvents.OPENED_WITH_NEW_STAR, onGetNewStarLevel)


	self.treeNodeLayer:addChild(nodeView)
	nodeView:setStar(star, 0, false, false, false)
	nodeView:updateView(false, false)
	WorldMapOptimizer:getInstance():buildCache(nodeView , 1)

	return nodeView

	-- nodeView:setStar(0, 0, false, false, false)

	-- local hiddenBranchCanOpen = MetaModel:sharedInstance():isHiddenBranchCanOpen(hiddenBranchId)
	-- if hiddenBranchCanOpen then
	-- 	if isFirstFlowerInHiddenBranch or (preHiddenLevelScore and preHiddenLevelScore.star > 0) then
	-- 		nodeView = WorldMapNodeView:create(false, id, self.playFlowerAnimLayer, self.flowerLevelNumberBatchLayer, self.treeNodeLayer.refCocosObj:getTexture())
	-- 		self.levelToNode[id] = nodeView

	-- 		local indexInBranch = id - hiddenBranchData.startHiddenLevel + 1
	-- 		local posX = 0
	-- 		local posY = 0
	-- 		local rightBranchOffsetX = {150, 300, 450}
	-- 		local rightBranchOffsetY = {80, 150, 160}
	-- 		local leftBranchOffsetX = {-150, -300, -450}
	-- 		local leftBranchOffsetY = {80, 150, 160}
	-- 		if hiddenBranchData.type == "1" then
	-- 			posX = hiddenBranchData.x + rightBranchOffsetX[indexInBranch]
	-- 			posY = hiddenBranchData.y + rightBranchOffsetY[indexInBranch]
	-- 		elseif hiddenBranchData.type == "2" then
	-- 			posX = hiddenBranchData.x + leftBranchOffsetX[indexInBranch]
	-- 			posY = hiddenBranchData.y + leftBranchOffsetY[indexInBranch]
	-- 		end
	-- 		nodeView:setPosition(ccp(posX, posY))

	-- 		-- Init Hidden Node View Star State
	-- 		if hiddenLevelScore and hiddenLevelScore.star > 0 then
	-- 			nodeView:setStar(hiddenLevelScore.star, 0, false, false, false)
	-- 		else
	-- 			-- Is The Top Hidden Level
	-- 			nodeView:setStar(0, 0, false, false, false)
	-- 		end
	-- 	end
	-- end

	-- if nodeView then
	-- 	self.treeNodeLayer:addChild(nodeView)
	-- 	nodeView:updateView(false, false)

	-- 	-- --------------------
	-- 	-- Add Event Listener
	-- 	-- ---------------------
	-- 	local context = self
	-- 	local function onNodeViewTapped_inner(event)
	-- 		context:onNodeViewTapped(event)
	-- 	end

	-- 	local function onGetNewStarLevel(event)
	-- 		context:onGetNewStarLevel(event)
	-- 	end

	-- 	nodeView:addEventListener(WorldMapNodeViewEvents.OPENED_WITH_NEW_STAR, onGetNewStarLevel)
	-- 	nodeView:addEventListener(DisplayEvents.kTouchTap, onNodeViewTapped_inner, nodeView)

	-- 	return nodeView
	-- end
end

----------------------------------------------------------
------- Event Listener About Data Change
--------------------------------------------------------

function WorldScene:onLevelPassed(gameResult)
	assert(gameResult, "gameResult cannot be nil")
	self.levelPassedInfo = nil
	if gameResult then
		if gameResult.levelType == GameLevelType.kMainLevel 
				or gameResult.levelType == GameLevelType.kHiddenLevel then
			self.levelPassedInfo = {
				passedLevelId = gameResult.levelId,
				rewardsIdAndPos = gameResult.rewardsIdAndPos,
				isPlayNextLevel = gameResult.isPlayNextLevel,
				jumpLevelPawn = gameResult.jumpLevelPawn,
--				userLevelState =  Qixi2018CollectManager.getInstance():getUserState(), --区分用户是满级，满级满星，和其它
                userLevelState =  Thanksgiving2018CollectManager.getInstance():getUserState(), --区分用户是满级，满级满星，和其它
			}
			CountdownPartyManager.getInstance():updateUserState()
--            DragonBuffManager.getInstance():updateUserState()
--            Qixi2018CollectManager.getInstance():updateUserState()
            Thanksgiving2018CollectManager.getInstance():updateUserState()
			self:updateLevelData()
			self:checkAndUpdateUnlockTipView()
		elseif gameResult.levelType == GameLevelType.kTaskForRecall then
			self:recallTaskLevelUnlock()
			self.homeScene:updateCoin()
		elseif gameResult.levelType == GameLevelType.kTaskForUnlockArea then 
			self:unlockAreaByTask(gameResult.levelId)
			self.homeScene:updateCoin()
		else -- 其他关卡结束后需要更新银币数量
			self.homeScene:updateCoin()
		end

		if gameResult.levelType == GameLevelType.kMainLevel and gameResult.levelId == kMaxLevels then
			local recordHttp = recordTopLevelRank.new()
			recordHttp:load(kMaxLevels)
		end

		

	end



end

function WorldScene:removeWorldSceneUnlockInfoPanel()
	if self.worldSceneUnlockInfoPanel then
		self.worldSceneUnlockInfoPanel:removeFromParentAndCleanup(true)
		self.worldSceneUnlockInfoPanel = nil
	end
end


function WorldScene:unlockAreaByTask( levelId )
	-- body
	local areaId = MetaManager:getInstance():getAreaIdByTaskLevelId(levelId)
	local function onSendUnlockMsgSuccess( ... )
		-- body
		local user =  UserService:getInstance().user
		local minLevelId = user:getTopLevelId() + 1
		user:setTopLevelId(minLevelId)
		local lockedClouds = HomeScene:sharedInstance().worldScene.lockedClouds
		for k, v in pairs(lockedClouds) do 
			local hasCloudView = false
			if v.id == areaId and not v.isCachedInPool then
				v:unlockCloud()
				hasCloudView = true
			end

			if not hasCloudView then
				local runningScene = HomeScene:sharedInstance()
				runningScene:checkDataChange()
				runningScene.starButton:updateView()
				runningScene.goldButton:updateView()
				runningScene.worldScene:onAreaUnlocked(v.id)
			end
		end

		if NetworkConfig.writeLocalDataStorage then 
	        Localhost:getInstance():flushCurrentUserData() 
	    end
	end
	local logic = UnlockLevelAreaLogic:create(areaId)
	logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
	logic:start(UnlockLevelAreaLogicUnlockType.USE_UNLOCK_AREA_LEVEL, {})
end

function WorldScene:recallTaskLevelUnlock()
	local lockedCloudId = RecallManager.getInstance():getNeedUnlockAreaId()

	if not lockedCloudId then
		if _G.isLocalDevelopMode then printx(0, "recallTaskLevelUnlock *** lockedCloudId is not exist !!!") end 
		return 
	end 

	local function onSendUnlockMsgSuccess(event) 
		if _G.isLocalDevelopMode then printx(0, "recallTaskLevelUnlock *** onSendUnlockMsgSuccess Called !") end

		local function onOpeningAnimFinished()
			local runningScene = HomeScene:sharedInstance()
			runningScene:checkDataChange()
			runningScene.starButton:updateView()
			runningScene.goldButton:updateView()
			runningScene.worldScene:onAreaUnlocked(lockedCloudId)
		end
		local currentCloud = self:getLockedCloudById(lockedCloudId)
		if currentCloud then 
			currentCloud:removeAllEventListeners()
			currentCloud:changeState(LockedCloudState.OPENING, onOpeningAnimFinished)

			if self.lockedCloudCacheDatas then
				table.remove( self.lockedCloudCacheDatas , 1 )
			end

			--解锁成功 重置下推送召回功能的流失状态
			RecallManager.getInstance():resetRecallRewardState()
		end
	end

	local function onSendUnlockMsgFailed(errorCode)
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
	end

	local function onSendUnlockMsgCanceled(event)
		if _G.isLocalDevelopMode then printx(0, "recallTaskLevelUnlock *** onSendUnlockMsgCanceled Called !") end
	end

	local logic = UnlockLevelAreaLogic:create(lockedCloudId)
	logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
	logic:setOnFailCallback(onSendUnlockMsgFailed)
	logic:setOnCancelCallback(onSendUnlockMsgCanceled)
	logic:start(UnlockLevelAreaLogicUnlockType.USE_TASK_LEVEL, {})	
end

function WorldScene:onTopLevelChange( topLevelId )
	-- self.topLevelId = topLevelId
	self:updateQuickScrollRange(topLevelId)

	if _G.isLocalDevelopMode then printx(0, "dispatchEvent USERMANAGER_TOP_LEVEL_ID_CHANGE") end
	self.homeScene:dispatchEvent(Event.new(HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE))

	_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kAfterLevelUp, {}))
end

function WorldScene:updateLevelData( ... )
	-- Check  topLevelId

	local newTopLevelId = UserManager.getInstance().user:getTopLevelId()
	if self.topLevelId ~= newTopLevelId then
		self.topLevelId = newTopLevelId
		GamePlayEvents.dispatchTopLevelChangeEvent(newTopLevelId)
	end

	local newLevelAreaOpenedId = UserManager.getInstance().levelAreaOpenedId
	if self.levelAreaOpenedId ~= newLevelAreaOpenedId and newLevelAreaOpenedId ~= false then
		self.levelAreaOpenedId = newLevelAreaOpenedId
		GamePlayEvents.dispatchAreaOpenIdChangeEvent(newLevelAreaOpenedId)
	end
end

function WorldScene:onAreaUnlocked( areaId )
	self:updateLevelData()
	self:updateUserIconPos(function ()  
		local currentScene = Director:sharedDirector():getRunningSceneLua()
		if currentScene:is(HomeScene) then
			-- if areaId >= 40006 then
			-- end
			--优化下一关 
		--	local isStartPanelAutoPopout = true
			local isStartPanelAutoPopout = _G.isStartPanelAutoPopoutForWorldScene
			if _G.isLocalDevelopMode then print("isStartPanelAutoPopout ===== " , isStartPanelAutoPopout ) end
			local topLevel = UserManager:getInstance().user:getTopLevelId()
			for i=1, #ModuleNoticeConfig do
				if ModuleNoticeConfig[i].unLockLevel == topLevel and ModuleNoticeConfig[i].id ~= ModuleNoticeID.JUMP_LEVEL then
				--	ModuleNoticeButton:setPlayNext(isStartPanelAutoPopout)
					ModuleNoticeButton:setPlayNext( true )
				--	isStartPanelAutoPopout = false
					break
				end
			end
			if _G.isLocalDevelopMode then print("isStartPanelAutoPopout ===== " , isStartPanelAutoPopout ) end
			
			--[[
			PreBuffLogic:playBuffUpgradeAnimation( function () 
					--马俊松修改 连续通关模式中 解锁了周赛以后 需要弹出来让玩家继续玩
					if isStartPanelAutoPopout then
						self:startLevel(UserManager:getInstance().user:getTopLevelId())
					end
				end )
				]]
			--马俊松修改 连续通关模式中 解锁了周赛以后 需要弹出来让玩家继续玩
			if isStartPanelAutoPopout then
				self:startLevel(UserManager:getInstance().user:getTopLevelId())
			end

		end

	end)
	local cloud, index = table.find(self.lockedClouds, function(v)
			return v.id == areaId
		end)

	if index then
		--table.remove(self.lockedClouds, index)
	end
end

function WorldScene:onAreaOpenIdChange( areaId )
	if _G.isLocalDevelopMode then printx(0, ">>>> WorldScene:onAreaOpenIdChange") end

	local lockedCloudToControl = self:getLockedCloudById(areaId)
	--assert(lockedCloudToControl)
	if lockedCloudToControl and not lockedCloudToControl.isDisposed then
		lockedCloudToControl:changeState(LockedCloudState.WAIT_TO_OPEN, false)
		lockedCloudToControl.blockerShow:startFloat()
	end

	--self:dispatchEvent(Event.new(HomeSceneEvents.USERMANAGER_LEVEL_AREA_OPENED_ID_CHANGE, areaId))
end

-- function WorldScene.onTopLevelChange(event, ...)
-- 	assert(event)
-- 	assert(event.name == HomeSceneEvents.USERMANAGER_TOP_LEVEL_ID_CHANGE)
-- 	assert(event.context)
-- 	assert(#{...} == 0)

-- 	local self = event.context
-- end

function WorldScene:updateUserIconPos(finishCallback, ...)
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "WorldScene:updateUserIconPos Called !") end
	if self.userIconLevelId ~= self.topLevelId then
		self.userIconLevelId = self.topLevelId
		
		local topLevelNode = self.levelToNode[self.topLevelId]
		assert(topLevelNode)
		
		-- Set Top Level Open
		local function setTopLevelNodeStarWrapper(callback)
			if topLevelNode:getStar() < 1 then
				topLevelNode:setStar(0, 0, true, true, callback)
			else
				callback()
			end
		end

		-- ----------------------------------
		-- Move User Icon To Top Level Node
		-- ----------------------------------
		local function moveUserIconToNodeWrapper()
			self:moveUserIconToNode(self.topLevelId, finishCallback)
		end

		local function showMissionTrunkLevelNodeBubble()
			--self:buildMissionBubble(self.topLevelId)
		end

		local chain = CallbackChain:create()
		chain:appendFunc(setTopLevelNodeStarWrapper)
		chain:appendFunc(moveUserIconToNodeWrapper)
		chain:appendFunc(showMissionTrunkLevelNodeBubble)
		chain:call()

		--self:updateAllFloatIconPos()
    else
        --刷新回流活动动画
        if UserCallbackManager.getInstance():isActivitySupport() then 
			UserCallbackManager.getInstance():updateBuffCountdownIcon()
		end

		if finishCallback then finishCallback() end
	end
end

----------------------------------------------------------
------ 		Node View Event Listener
----------------------------------------------------------

function WorldScene:playLevelPassed(passedLevelId, rewardsIdAndPos, isPlayNextLevel, jumpLevelPawn, userLevelState, ...)
	assert(type(passedLevelId) 	== "number")
	assert(type(rewardsIdAndPos)	== "table")
	assert(type(isPlayNextLevel) 	== "boolean")
	assert(#{...} == 0)
	isPlayNextLevel = _G.isStartPanelAutoPopoutForWorldScene
	if not jumpLevelPawn  then
		jumpLevelPawn = 0
	end

	-- fix
	self:setTouchEnabled(true, 0, true)

	-- end fix

	if _G.isLocalDevelopMode then printx(0, "WorldScene:levelPassedCallback Called !") end

	self.homeScene:onLevelPassed(passedLevelId)

	-- Get Correspond Node View , And Star Level
	local node = self.levelToNode[passedLevelId]
	if not node then
		return
	end
	local oldStar = node:getStar()
	assert(oldStar >= 0)

	local starIncreaseNum = false      --2018跨年活动 收集物图标显示在关卡花上

	local function playRewardAnimation(callback)
		------------------------------
		-- Play The Reward Item Anim
		-- ---------------------------
		if not node or node.isDisposed then return end
		local pos = node:getAnimationCenter()
		local parent = node:getParent()
		pos = parent:convertToWorldSpace(ccp(pos.x, pos.y))
		local itemTable = {}

		for k, v in pairs(rewardsIdAndPos) do
			if ItemType.COLLECT_STAR_2019 == v.itemId  then
				if CollectStarsManager.getInstance():getActivityIcon() then
					CollectStarsManager.getInstance():updateIconNumOnly( CollectStarsManager.getInstance():getLeftBuffNum() - v.num )
				end
				break
			end
		end

		local onFinishTimes = 1
		local function onCollectStarsReach()
			local nowNum = CollectStarsManager.getInstance():getLeftBuffNum()- CollectStarsManager.getInstance():getAutoAddBuffNum() + onFinishTimes
			CollectStarsManager.getInstance():updateIconNumOnly( nowNum )
			if onFinishTimes == 1 then
				CollectStarsManager.getInstance():playAddNumberAni()
			end
			onFinishTimes = onFinishTimes + 1
		end
		local function onCollectStarsFinish()
			-- CollectStarsManager.getInstance():playAddNumberAni()
		end

		for k, v in pairs(rewardsIdAndPos) do
			if v.itemId == ItemType.COIN then
				local function onFinish()
					local scene = HomeScene:sharedInstance()
					if not scene or scene.isDisposed then return end
					scene:checkDataChange()
					local button = scene.coinButton
					if not button or button.isDisposed then return end
					button:updateView()
				end
				local anim = FlyTopCoinAni:create(v.num)
				anim:setWorldPosition(pos)
				anim:setFinishCallback(onFinish)
				anim:play()
			elseif v.itemId == ItemType.ENERGY_LIGHTNING then
				local function onFinish()
					local scene = HomeScene:sharedInstance()
					if not scene or scene.isDisposed then return end
					scene:checkDataChange()
					local button = scene.energyButton
					if not button or button.isDisposed then return end
					button:updateView()
				end
				local anim = FlyTopEnergyAni:create(v.num)
				anim:setWorldPosition(pos)
				anim:setFinishCallback(onFinish)
				anim:play()
			elseif ItemType.COLLECT_STAR_2019 == v.itemId then
				if not CollectStarsManager.getInstance():getActivityIcon() then
					--没有icon的时候 就不飞了
					-- for i=1,v.num do
					-- 	table.insert(itemTable, v.itemId)
					-- end
				else
		   			local bounds = CollectStarsManager.getInstance():getActivityIcon() :getGroupBounds()
					local anim = FlySpecialItemAnimation:create(v, "Prop_10113sprite0000", ccp(bounds:getMidX(),bounds:getMidY()))
					anim:setWorldPosition( pos )
					anim:setReachCallback(onCollectStarsReach)
					anim:setFinishCallback(onCollectStarsFinish)
					anim:play()
				end
			else
				table.insert(itemTable, v.itemId)
			end
		end

		if CountdownPartyManager.getInstance():isActivitySupport() then 
			if starIncreaseNum and type(starIncreaseNum) == "number" then 
				starIncreaseNum = math.floor(starIncreaseNum)
				if starIncreaseNum >= 1 and starIncreaseNum <= 4 then
					CountdownPartyManager.getInstance():handleStarIncrease(passedLevelId, starIncreaseNum, pos)
				end 
			end
		end

--        if Qixi2018CollectManager.getInstance():isActivitySupport() 
--            or Qixi2018CollectManager.getInstance():isActivityOppoRankSupport() then 
--			if starIncreaseNum and type(starIncreaseNum) == "number" then 
--				starIncreaseNum = math.floor(starIncreaseNum)
--				if starIncreaseNum >= 1 and starIncreaseNum <= 4 then
--					Qixi2018CollectManager.getInstance():handleStarIncrease(passedLevelId, starIncreaseNum, pos)
--				end 
--			end
--		end

-- 感恩关卡没有补星给道具一说
--        if Thanksgiving2018CollectManager.getInstance():isActivitySupport() then 
--			if starIncreaseNum and type(starIncreaseNum) == "number" then 
--				starIncreaseNum = math.floor(starIncreaseNum)
--				if starIncreaseNum >= 1 and starIncreaseNum <= 4 then
--					Thanksgiving2018CollectManager.getInstance():handleStarIncrease(passedLevelId, starIncreaseNum, pos)
--				end 
--			end
--		end

		if #itemTable > 0 then 
			HomeSceneFlyToAnimation:sharedInstance():levelNodeJumpToBagAnimation(itemTable, pos, callback)
		else 
			if callback and type(callback) == "function" then callback() end
		end
	end

	-- Get New Star
	local levelScoreRef = UserManager:getInstance():getUserScore(passedLevelId)
	local isJumpLevel = JumpLevelManager:getLevelPawnNum(passedLevelId) > 0
	local isHelpedNode = UserManager:getInstance():hasAskForHelpInfo(passedLevelId)

	if levelScoreRef or isJumpLevel or isHelpedNode then
		local newStar
		if not (isJumpLevel or isHelpedNode) then
			newStar = levelScoreRef.star
		else
			newStar = 0
		end

		-- Update Node's Star Level
		local function updateNodeViewStar(callback)
			if jumpLevelPawn and jumpLevelPawn > 0 then
				node:setStar(newStar, jumpLevelPawn, true, true, callback)
			elseif isHelpedNode then
				node:setStar(newStar, 0, true, true, callback)
			elseif newStar > oldStar then
				node:setStar(newStar, 0, true, true, function ()
--					if LevelType:isMainLevel(passedLevelId) and userLevelState and userLevelState == Qixi2018CollectManager.UserState.kTopLevel then 
                    if LevelType:isMainLevel(passedLevelId) and userLevelState and userLevelState == Thanksgiving2018CollectManager.UserState.kTopLevel then 
						starIncreaseNum = newStar - oldStar
					end
					if callback then callback() end
				end)
			else
				node:playParticle()
				callback()
			end
		end

		-- Check If User's Top Level Is Changed
		-- printx( 1 , "WorldScene:playLevelPassed  111  passedLevelId =" , passedLevelId )
		local function checkTopLevelChange()
			-- open start panel as anim finished while no window nor ladybug anim on screen
			local function onUserIconMoveAnimFinished()

				local function popNextLevel()
					
					if not isPlayNextLevel then
						return
					end

					if not self.isUnlockingHiddenBranch then 
						if not PopoutManager:haveWindowOnScreen_WithoutHttpLoading() then
							if not require('zoo.panel.newLadybug.LadybugAnimation'):isPlayingAnim() then
								self:startLevel(UserManager:getInstance().user:getTopLevelId())
							end
						end
					end
				end

				-- printx( 1 , "WorldScene:playLevelPassed  111.2")
				popNextLevel()
				-- PreBuffLogic:playBuffUpgradeAnimation( popNextLevel , passedLevelId)
			end
			
			self.homeScene:checkDataChange()
			-- printx( 1 , "WorldScene:playLevelPassed  111.1 isPlayNextLevel = " , isPlayNextLevel)
			if isPlayNextLevel then 
				self:updateUserIconPos(onUserIconMoveAnimFinished)
			else 
				self:updateUserIconPos(onUserIconMoveAnimFinished) 
			end
			self:refreshTopAreaCloudState()
		end

		local chain = CallbackChain:create()
		chain:appendFunc(updateNodeViewStar)
		chain:appendFunc(playRewardAnimation)
		chain:appendFunc(checkTopLevelChange)
		chain:call()
	else
		-- printx( 1 , "WorldScene:playLevelPassed  222  passedLevelId =" , passedLevelId )
		-- Note: Passed Level Has No Score, This Condition May Occur When Sync The Data With Server.
		-- Specific Reason To Cause This Problem, Is Not Clear.

		-- Check If User's Top Level Is Changed
		self.homeScene:checkDataChange()
		self:updateUserIconPos( function () PreBuffLogic:playBuffUpgradeAnimation() end )
		playRewardAnimation()
	end
end

function WorldScene:startLevel(levelId, startLevelType, source)
	if _G.isLocalDevelopMode then printx(0, "[INFO] WorldScene:startLevel:", levelId) end
	if not PopoutManager:sharedInstance():haveWindowOnScreen_WithoutHttpLoading()
			and not HomeScene:sharedInstance().ladyBugOnScreen then
		if _G.__autoPlay then
			-- stopObjectRefDebug()
			-- startObjectRefDebug()
		    local step = {randomSeed = 0, replaySteps = {}, level = levelId, selectedItemsData = {}}
			local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , {} , false , {} )
			newStartLevelLogic:startWithReplay( ReplayMode.kAuto , step )
			return
		end
		local levelType = LevelType:getLevelTypeByLevelId(levelId)

		local startGamePanel = StartGamePanel:create(levelId, levelType, startLevelType, source)
		
		-- 
		startGamePanel:setOnClosePanelCallback(function( ... )
			if self.unlockHiddenBranchCloudBranchId then
				self:unlockHiddenBranchCloud(self.unlockHiddenBranchCloudBranchId)
				self.unlockHiddenBranchCloudBranchId = nil
			end
			AskForHelpManager:getInstance():leaveMode()
		end)

		startGamePanel:popout(false)
	end
end

function WorldScene:onNodeViewTapped(event, ...)

	assert(event)
	assert(event.name == DisplayEvents.kTouchTap)
	assert(event.context)
	assert(#{...} == 0)

	local nodeView = event.context
	local levelId = nodeView:getLevelId()

	if self.topLevelId ~= levelId then
		Notify:dispatch("QuitNextLevelModeEvent")
	end

	-- ------------------------
	-- Create Start Game Panel
	-- ------------------------
	local function onUnlockSuccess()
		self:startLevel(levelId)
		self:fixLevelStar(levelId)
	end

	local function onUnlockFail()
		self:startLevel(levelId)
	end

	local function onUnlockHideLevelFail()
		--do nothing?
	end

	local isOnlineCheckFourStarLevel, groupId = NewAreaOpenMgr.getInstance():isOnlineCheckFourStar(levelId)
	if isOnlineCheckFourStarLevel then 
		NewAreaOpenMgr.getInstance():fourStarUnlockCheck(groupId, onUnlockSuccess, onUnlockFail)
	else
		local isOnlineCheckHideLevel, areaId = NewAreaOpenMgr.getInstance():isOnlineCheckHideAreaLevel(levelId) 
		if isOnlineCheckHideLevel then 
			NewAreaOpenMgr.getInstance():hideAreaUnlockCheck(areaId, onUnlockSuccess, onUnlockHideLevelFail)
		else
			onUnlockSuccess()
		end
	end
end

function WorldScene:fixLevelStar(levelId)
	-- 保证当前星数跟分数一致
	local score = UserManager:getInstance():getUserScore(levelId)
	local levelMapMeta = LevelMapManager.getInstance():getMeta(levelId)
	local levelRewardMeta = MetaManager.getInstance():getLevelRewardByLevelId(levelId)
	if score and score.star >= 0 then
		-- score.star = 0
		local newStar = levelMapMeta:getStar(score.score)
		------ 4星不能直接给玩家，必须要玩家再打出来才给他
		-- if newStar > 3 then
		-- 	newStar = 3
		-- end
		if newStar > score.star then
			local function onSuccess( evt )
				DcUtil:UserTrack({ category="stage", sub_category="repair_stage_star" })

				local newStar = evt.data.star
				local score = UserManager:getInstance():getUserScore(levelId)
				local deltaStar = newStar - score.star 

				if newStar <= score.star then
					return
				end
				-- 
				score.star = newStar
				UserManager:getInstance():removeUserScore(levelId)
				UserManager:getInstance():addUserScore(score)
				UserService:getInstance():removeUserScore(levelId)
				UserService:getInstance():addUserScore(score)

				if LevelType:isMainLevel(levelId) then
					local curNormalStar = UserManager:getInstance().user:getStar()
					local newNormalStar = curNormalStar + deltaStar
					UserManager:getInstance().user:setStar(newNormalStar)
					UserService.getInstance().user:setStar(newNormalStar)
				elseif LevelType:isHideLevel(levelId) then
					local curHideStar = UserManager:getInstance().user:getHideStar()
					local newHideStar = curHideStar + deltaStar
					UserManager:getInstance().user:setHideStar(newHideStar)
					UserService.getInstance().user:setHideStar(newHideStar)
				end

				HomeScene:sharedInstance().starButton:updateView()

				local nodeView = self.levelToNode[levelId]
				if nodeView then
					nodeView:setStar(newStar, 0, false, false, false)
					nodeView:updateView(false, false)
				end

				local curStarReward = false
				if newStar == 1 then
					curStarReward = levelRewardMeta.oneStarReward 
				elseif newStar == 2 then
					curStarReward = levelRewardMeta.twoStarReward
				elseif newStar == 3 then
					curStarReward = levelRewardMeta.threeStarReward
				elseif newStar == 4 then
					curStarReward = levelRewardMeta.fourStarReward
				end

				if curStarReward then
					for k,v in pairs(curStarReward) do
						if v.itemId == ItemType.INGREDIENT then
							UserManager:getInstance():addReward(v)
							UserService:getInstance():addReward(v)
							GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kStageEnd, v.itemId, v.num, DcSourceType.kLevelReward, levelId)
						end
					end
				end

				Localhost:flushCurrentUserData()

				if LevelType:isMainLevel(levelId) then
					local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(levelId)
					if branchId and MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then
						if self.hiddenBranchArray[branchId] and self.hiddenBranchArray[branchId]:isClosed() then
							self.unlockHiddenBranchCloudBranchId = branchId
						end
					end
				end
			end

			local http = SetLevelStarHttp.new()
			http:ad(Events.kComplete, onSuccess)
			http:load(levelId,newStar)
		end
	end
end

function WorldScene:moveTopLevelNodeToCenter( animFinishCallback )

	if not animFinishCallback then animFinishCallback = false end
	-- body
	if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT or
			self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT then
			self:addEventListener(WorldSceneScrollerEvents.SCROLLED_FOR_TUTOR, function ()
				self:removeEventListenerByName(WorldSceneScrollerEvents.SCROLLED_FOR_TUTOR)
				self:moveNodeToCenter(self.topLevelId, animFinishCallback)
			end)
		self:scrollToOrigin()
	else
		self:moveNodeToCenter(self.topLevelId, animFinishCallback)
	end
end

function WorldScene:moveCloudLockToCenter(cloudId, animFinishCallback)

	self:resumeFromAnimation()
	if self.regionCloud then
		self.regionCloud:setVisible(false)
	end

	local actionArray = CCArray:create()
	local cloud
	for k,v in pairs(self.lockedCloudCacheDatas) do
		if v.areaId == cloudId then
			cloud = v
			break
		end
	end
	if not cloud then 
		if animFinishCallback then animFinishCallback() end
		return 
	end

	local newCloudLockNode = self.lockedCloudLayer:getNewCloudLockNode()

	local targetNodePosInWorld = newCloudLockNode:convertToWorldSpace( ccp(cloud.cloudX , cloud.cloudY) )

	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()

	
	local function onMoveToFinishedFunc()
		-- debug.debug()
		self:setScrollable(true)
		if animFinishCallback then animFinishCallback() end
		WorldMapOptimizer:getInstance():update()
	end

	if _G.isLocalDevelopMode then printx(0, visibleOrigin.y, visibleSize.height, targetNodePosInWorld.y) end
	local deltaMoveDistance = (visibleOrigin.y + visibleSize.height / 2) - (targetNodePosInWorld.y - visibleOrigin.y) + cloud.cloudHeight / 2
	local function initMoveMaskLayerFunc()
		self:setScrollable(false)
	end
	local initMoveMaskLayerAction = CCCallFunc:create(initMoveMaskLayerFunc)
	actionArray:addObject(initMoveMaskLayerAction)
	-- delay for 0.1 sec to avoid parallax node error
	actionArray:addObject(CCDelayTime:create(0.1))
	actionArray:addObject(CCMoveBy:create(1.5, ccp(0, deltaMoveDistance)))

	self.ignoreHitCloudCheck = (deltaMoveDistance > 0)

	---------------
	-- Move To Finished
	-- --------------

	local onMoveToFinishedAction = CCCallFunc:create(onMoveToFinishedFunc)
	actionArray:addObject(onMoveToFinishedAction)
	local seq = CCSequence:create(actionArray)
	self.maskedLayer:stopAllActions()
	self.maskedLayer:runAction(seq)

end

function WorldScene:showLadybugFourStarGuid( levelId )
	-- body
	local node = self.levelToNode[levelId]
	local size = node:getGroupBounds().size
	local pos_to = node:getPosition()
	local function flyAwayCallback( ... )
		-- body
		if self.ladybugFourStar then 
			self.ladybugFourStar:removeFromParentAndCleanup(true)
			self.ladybugFourStar = nil
		end
	end
	flyAwayCallback()
	local txt = Localization:getInstance():getText("fourstar_this_stage_tips_2")
	local xDelta = 2*size.width /3
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
		xDelta = 1*size.width /2
	end
	local sprite = LadybugFourStarAnimationInLevelNode:create( ccp(pos_to.x + xDelta, pos_to.y - size.height/2), 200,
		LadyBugFourStarAnimationType.kScaleWithoutBtn, txt, flyAwayCallback)

	self.scaleTreeLayer1:addChild(sprite)
	self.ladybugFourStar = sprite
end

function WorldScene:moveNodeToCenter(levelId, animFinishCallback, isGuaranteeCallback, ...)
	if PublishActUtil:isGroundPublish() then 
		return
	end
	if _G.isLocalDevelopMode then printx(0, "WorldScene:moveNodeToCenter") end
	-- debug.debug()
	assert(type(levelId) == "number")
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	if self.trunkScrollInteractionController then
		self.trunkScrollInteractionController:getScrollView():setCurrent(levelId)
	end

	local function verticalScroll( ... )

		if self.regionCloud then
			self.regionCloud:setVisible(false)
		end

		local node = self.levelToNode[levelId]
		assert(node)

		if not node then 
			if animFinishCallback then animFinishCallback() end
			self.lastNodeMoveCallback = nil
			return
		end

		local nodePosition = node:getPosition()
		local actionArray = CCArray:create()

		local nodeParent = node:getParent()
		local targetNodePosInWorld = nodeParent:convertToWorldSpace(ccp(nodePosition.x, nodePosition.y))

		local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()

		he_log_warning("need adapt the screen resolution ?? ")
		local distanceToVisibleTopTriggerTrunkMove = visibleSize.height * 0.3
		-- local distanceToVisibleTopTrunkMoveTo = visibleSize.height * 0.5
		
		local function onMoveToFinishedFunc()
			-- debug.debug()
			self:setScrollable(true)
			if animFinishCallback then animFinishCallback() end
			self.lastNodeMoveCallback = nil
			WorldMapOptimizer:getInstance():update()
			self:onVerticalScrollStop()
		end

		if targetNodePosInWorld.y > visibleOrigin.y + visibleSize.height - distanceToVisibleTopTriggerTrunkMove or targetNodePosInWorld.y < visibleOrigin.y + distanceToVisibleTopTriggerTrunkMove then

			local deltaMoveDistance = (visibleOrigin.y + visibleSize.height - distanceToVisibleTopTriggerTrunkMove) - targetNodePosInWorld.y
			if targetNodePosInWorld.y < visibleOrigin.y + distanceToVisibleTopTriggerTrunkMove then
				deltaMoveDistance = visibleOrigin.y + distanceToVisibleTopTriggerTrunkMove - targetNodePosInWorld.y
			end

			-- ------------
			-- Init Action
			-- -----------
			local function initMoveMaskLayerFunc()
				self:setScrollable(false)
			end
			local initMoveMaskLayerAction = CCCallFunc:create(initMoveMaskLayerFunc)
			actionArray:addObject(initMoveMaskLayerAction)
			-- delay for 0.1 sec to avoid parallax node error
			actionArray:addObject(CCDelayTime:create(0.1))

			-- ----------
			-- Move To
			-- -----------

			if not self.isUnlockingHiddenBranch then
				actionArray:addObject(CCMoveBy:create(0.8, ccp(0, deltaMoveDistance)))
			end

			self.ignoreHitCloudCheck = (deltaMoveDistance > 0)
			-- if _G.isLocalDevelopMode then printx(0, 'deltaMoveDistance', deltaMoveDistance) end
			---------------
			-- Move To Finished
			-- --------------

			local onMoveToFinishedAction = CCCallFunc:create(onMoveToFinishedFunc)
			actionArray:addObject(onMoveToFinishedAction)
			local seq = CCSequence:create(actionArray)

			self.maskedLayer:runAction(seq)

			local endMaskedLayerY = self.maskedLayer:getPositionY() + deltaMoveDistance
			self:updateAllRegionCloudState(endMaskedLayerY)
			self:onMaskedLayerAutoScrollTo(endMaskedLayerY)
			self.regionCloudY, self.regionCloudIndex = self:getNearestRegionCloudPosAndId(math.abs(endMaskedLayerY))
			-- if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxx', self.regionCloudY, self.regionCloudIndex,self.maskedLayer:getPositionY(), deltaMoveDistance) end
			self:setRegionCloudPosition()
		else
			-- if animFinishCallback then animFinishCallback() end
			self.maskedLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(onMoveToFinishedFunc)))
		end

	end

	self:resumeFromAnimation()


	self.maskedLayer:stopAllActions()

	if self.lastNodeMoveCallback then
		self.lastNodeMoveCallback()
		self.lastNodeMoveCallback = nil
	end


	if isGuaranteeCallback then
		self.lastNodeMoveCallback = animFinishCallback
	end

			
	if LevelType:isMainLevel(levelId) and self.scrollHorizontalState ~= WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
		self:scrollToOrigin()
		local seq = CCSequence:createWithTwoActions(CCDelayTime:create(1),CCCallFunc:create(verticalScroll))
		self.maskedLayer:runAction(seq)
	else
		verticalScroll()
	end
end

function WorldScene:buildMissionBubble(level)
	
	if not level then level = self.topLevelId end

	local node = self.levelToNode[level]
	assert(node)

	local nodePosition = node:getPosition()
	local targetPos = ccp(nodePosition.x, nodePosition.y + 0)

	if not self.missionBubbles[level] then
		self.missionBubbles[level] = MissionTrunkLevelNodeBubble:create()
		self.friendPictureLayer:addChild(self.missionBubbles[level])
	end
	local bubble = self.missionBubbles[level]
	bubble:setPosition( ccp( targetPos.x + 1 , targetPos.y - 72 ) )
	bubble:setScale(0.8)
end

function WorldScene:clearMissionBubble(level)
	if self.missionBubbles[level] and self.missionBubbles[level]:getParent() then
		self.missionBubbles[level]:removeFromParentAndCleanup(true)
		self.missionBubbles[level] = nil
	end
end

function WorldScene:clearAllMissionBubble()
	if self.missionBubbles then
		for k,v in pairs(self.missionBubbles) do
			if v:getParent() then
				v:removeFromParentAndCleanup(true)
			end
		end

		self.missionBubbles = {}
	end
end

function WorldScene:checkMissionBubbleShow(level)
	if self.missionBubbles[level] then
		return true
	else
		return false
	end
end

function WorldScene:moveUserIconToNode(levelId, animFinishCallback, ...)
	assert(type(levelId) == "number")
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "WorldScene:moveUserIconToNode Called !") end
	if _G.isLocalDevelopMode then printx(0, "levelId: " .. levelId) end

	local node = self.levelToNode[levelId]
	assert(node)

	local nodePosition = node:getPosition()
	local targetPos = ccp(nodePosition.x, nodePosition.y + self.userIconDeltaPosY)
	local curPos = self.userIcon:getPosition()
	local distance = ccpDistance(targetPos, curPos)
	local time = distance / self.userIconMovingSpeed

	if time > 2 then
		time = 2
	end

	------------------------------
	-- Block User Scroll THe Trunk 
	-- ------------------------------

	local actionArray = CCArray:create()

	-------------------------------
	-- Move THe Trunk If The Target Pos Is High
	-- ---------------------------------------
	-- Convert Target Node Pos To World Scene
	local nodeParent = node:getParent()
	local targetNodePosInWorld = nodeParent:convertToWorldSpace(ccp(nodePosition.x, nodePosition.y))

	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	he_log_warning("need adapt the screen resolution ?? ")
	local distanceToVisibleTopTriggerTrunkMove = 200
	local distanceToVisibleTopTrunkMoveTo = 500

	if targetNodePosInWorld.y > visibleOrigin.y + visibleSize.height - distanceToVisibleTopTriggerTrunkMove then

		local deltaMoveDistance = (visibleOrigin.y + visibleSize.height - distanceToVisibleTopTrunkMoveTo) - targetNodePosInWorld.y

		-- ------------
		-- Init Action
		-- -----------
		local function initMoveMaskLayerFunc()
			self:setScrollable(false)
		end
		local initMoveMaskLayerAction = CCCallFunc:create(initMoveMaskLayerFunc)
		actionArray:addObject(initMoveMaskLayerAction)

		-- ----------
		-- Move To
		-- -----------

		if not self.isUnlockingHiddenBranch then
			self.maskedLayer.moving = true
			local moveBy = CCMoveBy:create(time, ccp(0, deltaMoveDistance))
			local targetMoveBy = CCTargetedAction:create(self.maskedLayer.refCocosObj, moveBy)
			actionArray:addObject(targetMoveBy)
		end

		---------------
		-- Move To Finished
		-- --------------
		local function onMoveToFinishedFunc()
			self:setScrollable(true)
			self.maskedLayer.moving = nil
			WorldMapOptimizer:getInstance():update()
		end
		local onMoveToFinishedAction = CCCallFunc:create(onMoveToFinishedFunc)
		actionArray:addObject(onMoveToFinishedAction)
	end

	-------------------
	-- Move User Icon
	-- ----------------

	-- Set User Icon To Top
	local userIconParent = self.userIcon:getParent()
	self.userIcon:removeFromParentAndCleanup(false)
	userIconParent:addChild(self.userIcon)
	
	-- Move To
	local moveToAction = CCMoveTo:create(time, targetPos)
	local targetMoveToAction = CCTargetedAction:create(self.userIcon.refCocosObj, moveToAction)
	actionArray:addObject(targetMoveToAction)

	-- Callback
	local function animFinish()
		if animFinishCallback then
			animFinishCallback()
		end
		PrepackageUtil:LevelUpShowTipToNetWork()
		WorldMapOptimizer:getInstance():update()

		if UserCallbackManager.getInstance():isActivitySupport() then 
			UserCallbackManager.getInstance():updateBuffCountdownIcon()
		end

		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kUserIconMoved))

	end
	local animFinishAction = CCCallFunc:create(animFinish)
	actionArray:addObject(animFinishAction)

	-- Seq
	local seq = CCSequence:create(actionArray)
	---- Seq 
	--local seq = CCSequence:createWithTwoActions(moveToAction, animFinishAction)

	self.userIcon:runAction(seq)

end

--如果是一个branchId的话 那么直接 callback()
function WorldScene:scrollToBranch_JS( branchId,callback )
	if _G.isLocalDevelopMode  then printx(100 , " WorldScene:scrollToBranch_JS -------------------------------------" ) end
	if _G.isLocalDevelopMode  then printx(100 , " branchId = " , branchId ) end
	if _G.isLocalDevelopMode  then printx(100 , " self.currentStayBranchIndex = " , self.currentStayBranchIndex ) end
	if branchId and self.currentStayBranchIndex == branchId then
		self:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.1),
			CCCallFunc:create(function( ... )
				if callback then
					callback()
				end
			end)
		))
	else
		self:scrollToBranch( branchId,callback )
	end
end

function WorldScene:scrollToBranch( branchId,callback )

	local curBranchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)

	local function onVerticalScrollComplete()
		self.currentStayBranchIndex = branchId
		if tonumber(curBranchData.type) == 1 then
			self:scrollToRight()
		elseif tonumber(curBranchData.type) == 2 then
			self:scrollToLeft()
		end

		self:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.5),
			CCCallFunc:create(function( ... )
				if callback then
					callback()
				end
			end)
		))
	end

	local branchPos = self.hiddenBranchLayer:convertToWorldSpace(ccp(0, curBranchData.y))
	local branchPos = self.maskedLayer:convertToNodeSpace(branchPos)
	local targetY = branchPos.y - Director:sharedDirector():getVisibleOrigin().y
	local function verticalScroll()
		self:verticalScrollTo(targetY, onVerticalScrollComplete)
	end

	if self.scrollHorizontalState ~= WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
		self:scrollToOrigin()
		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(verticalScroll)))
	else
		verticalScroll()
	end
end

function WorldScene:dcUnlockHiddenBranch(branchId)
	-- 9号点增加玩家隐藏关状态点,删除这个点
	-- local userTopLevel = UserManager.getInstance().user:getTopLevelId()
	-- local areaId = 0
	-- local areaDataCache = {}
	-- local openedBranchList = {}

	-- for levelId = 1, userTopLevel do
	-- 	if levelId % 15 == 1 then -- 新区域
	-- 		areaId = areaId + 1
	-- 		areaDataCache[areaId] = {id = areaId, num = 0, star = 0}

	-- 		if levelId > 15 then -- 隐藏关从第二区域开始
	-- 			local hiddenBranchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(levelId)
	-- 			if hiddenBranchId and MetaModel:sharedInstance():isHiddenBranchCanOpen(hiddenBranchId) then
	-- 				table.insert(openedBranchList, hiddenBranchId)
	-- 			end
	-- 		end
	-- 	end
	-- 	local score =  UserManager.getInstance():getUserScore(levelId)
	-- 	local star = score and score.star or 0
	-- 	if star >= 3 then
	-- 		areaDataCache[areaId].num = areaDataCache[areaId].num + 1
	-- 	end
	-- 	areaDataCache[areaId].star = areaDataCache[areaId].star + star
	-- end
	-- local under3StarLvNum = {}
	-- local areaTotalStarNum = {}
	-- for id = 1, areaId do
	-- 	table.insert(under3StarLvNum, areaDataCache[id].num)
	-- 	table.insert(areaTotalStarNum, areaDataCache[id].star)
	-- end
	-- DcUtil:UserTrack({
	-- 	category = 'level',
	-- 	sub_category = 'hide_level_start',
	-- 	t1 = branchId,
	-- 	t2 = table.concat(areaTotalStarNum, "_"),
	-- 	t3 = table.concat(under3StarLvNum, "_"),
	-- 	t4 = table.concat(openedBranchList, "_"),
	-- 	})
end

function WorldScene:unlockHiddenBranchCloud(branchId, noScroll)
	if not self.hiddenBranchArray[branchId] then
		return
	end

	if not self.hiddenBranchArray[branchId]:isClosed() then
		return
	end

	-- DC
	self:dcUnlockHiddenBranch(branchId)

	local function unlock()
		local hiddenBranchData = MetaModel:sharedInstance():getHiddenBranchDataByBranchId(branchId)
		local nodeView = self.levelToNode[hiddenBranchData.startHiddenLevel]
		if nodeView then
			nodeView:setStar(0, 0, false, false, false)
			nodeView:updateView(true, false)
			local function onNodeViewTapped_inner(event)
				self:onNodeViewTapped(event)
			end
			nodeView:addEventListener(DisplayEvents.kTouchTap, onNodeViewTapped_inner, nodeView)					
		end

		self.hiddenBranchArray[branchId]:updateState()
		HomeScene:sharedInstance().starButton:updateView()
	end

	if noScroll then 
		unlock()
	else
		self:scrollToBranch(branchId, unlock)
	end
end

function WorldScene:onGetNewStarLevel(event, ...)
	-- assert(event)
	-- assert(event.name == WorldMapNodeViewEvents.OPENED_WITH_NEW_STAR)
	-- assert(event.data)
	-- assert(#{...} == 0)

	local changedLevelId = event.data
	-- local branchDataList = MetaModel:sharedInstance():getHiddenBranchDataList()

	local function unlockHiddenBranch(branchId)
		-- If Exist A Hidden Branch Based On This Normal Level
		if branchId then
			if not self.hiddenBranchArray[branchId] or WorldSceneShowManager:getInstance():getHideBranchOpenFlag() then
				WorldSceneShowManager:getInstance():setHideBranchOpenFlag(false)
				-- Check If This Hidden Branch Can Open
				-- if MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then
				if MetaModel:sharedInstance():isHiddenBranchCanShow(branchId) then 
					local function onHiddenBranchTapped(event)
						self:onHiddenBranchTapped(event)
					end

					local function createNewBranch()

						-- if GameGuide then GameGuide:sharedInstance():forceStopGuide() end
						
						local newBranch = HiddenBranch:create(branchId, false, self.hiddenBranchLayer.refCocosObj:getTexture())
						self.hiddenBranchArray[branchId] = newBranch
						self.hiddenBranchLayer:addChild(newBranch)
						MetaModel:sharedInstance():markHiddenBranchOpen(branchId)

                        local branchBox = HiddenBranchBox:create(branchId, newBranch, self.hiddenBranchBubbleAnimLayer, self.hiddenBranchTipLayer, self.hiddenBranchBoxAnimLayer.refCocosObj:getTexture())
	                    self.hiddenBranchBoxAnimLayer:addChild(branchBox)
                        newBranch.branchBox = branchBox

						newBranch:addEventListener(HiddenBranchEvent.OPEN_ANIM_FINISHED, self.onHiddenBranchOpenAnimFinished, self)
						newBranch:addEventListener(DisplayEvents.kTouchTap, onHiddenBranchTapped, branchId)
						
						if not MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then
							newBranch:showCloud(
								self.lockedCloudLayer:getBatchNode(),
								self.lockedCloudLayer:getHiddenBranchTextBatchNode(),
								self.lockedCloudLayer:getHiddenBranchNumberBatchNode(),
								self.lockedCloudLayer:getHiddenBranchExtraTextNode()
							)
						end

						newBranch:playOpenAnim(self.hiddenBranchAnimLayer)
					end

					self:setTouchEnabled(false)
					self.isUnlockingHiddenBranch = true
					-- self:scrollToBranch(branchId,createNewBranch)
					createNewBranch()

					-- Cookie.getInstance():write(CookieKey.kUnlockHiddenArea, "true")
				end
			end
		end
	end

	if LevelType:isMainLevel(changedLevelId) then
		local branchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(changedLevelId)
		if not self.hiddenBranchArray[branchId] then
			unlockHiddenBranch(branchId)
		else
			if MetaModel:sharedInstance():isHiddenBranchCanOpen(branchId) then
				self:unlockHiddenBranchCloud(branchId)
			else
				self.hiddenBranchArray[branchId]:updateState()
			end
		end
	elseif LevelType:isHideLevel(changedLevelId) then
		local hiddenBranchData = MetaModel:sharedInstance():getHiddenBranchDataByHiddenLevelId(changedLevelId)
		local endHiddenLevel = hiddenBranchData.endHiddenLevel
		local nextHiddenLevelOnSameBranch = changedLevelId + 1

		local branchId = MetaModel:sharedInstance():getHiddenBranchIdByHiddenLevelId(changedLevelId)
		self.hiddenBranchArray[branchId]:updateState()

		if changedLevelId < endHiddenLevel then
			local nodeView = self.levelToNode[nextHiddenLevelOnSameBranch]
			if nodeView and nodeView:getStar() < 0 then
				nodeView:setStar(0, 0, false, false, false)
				nodeView:updateView(true, false)
				local function onNodeViewTapped_inner(event)
					self:onNodeViewTapped(event)
				end
				nodeView:addEventListener(DisplayEvents.kTouchTap, onNodeViewTapped_inner, nodeView)
			end
		else
			local dependedBranch = MetaModel:sharedInstance():getHiddenBranchIdByDependingBranch(branchId)
			unlockHiddenBranch(dependedBranch)
		end
	end

	-- 通关最高关卡
	if LevelType:isMainLevel(changedLevelId) and changedLevelId == kMaxLevels then
		if not UserManager.getInstance():hasPassedByTrick(changedLevelId) then
			NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kPassAllLevel, kMaxLevels)
		end
	end
end

function WorldScene:showHiddenAreaIntroduction()
	if UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kHiddenBranchIntroduction) then
		return
	end
	local localRecord = Cookie.getInstance():read(CookieKey.kHiddenAreaIntroduction)
	if not localRecord then
		local panel = HiddenBranchIntroductionPanel:create()
		PopoutQueue:sharedInstance():push(panel)
	end
end

function WorldScene.onHiddenBranchOpenAnimFinished(event, ...)
	assert(event)
	assert(event.name == HiddenBranchEvent.OPEN_ANIM_FINISHED)
	assert(event.data)
	assert(event.context)
	assert(#{...} == 0)


	local self = event.context
	local branchId = event.data

	local branchDataList = self.metaModel:getHiddenBranchDataList()
	local curBranchData = branchDataList[branchId]
	
	local headHiddenLevel = curBranchData.startHiddenLevel

	for headHiddenLevel=curBranchData.startHiddenLevel,curBranchData.endHiddenLevel do
		local nodeView = self:buildHiddenNode(headHiddenLevel)
	end

	WorldMapOptimizer:getInstance():update(true)

	self:setTouchEnabled(true)
	self.isUnlockingHiddenBranch = false
	-- self:showHiddenAreaIntroduction()

	local hiddenStar = 0
	for i = curBranchData.startHiddenLevel, curBranchData.endHiddenLevel do
		hiddenStar = hiddenStar + 3
	end

    --当前是最高隐藏关解锁 解锁完成移动到隐藏关位置
    local function MoveToTopHiddenBranch()
        HomeScene:sharedInstance():jumpToTopHiddenLevel()
    end

    local metaModel = MetaModel:sharedInstance()
    local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
    local TopHideLevelBranchID = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId( configTopLevel )

    --是最高区域 并且 最高区域未满星
    local TopAreaIsFullStar = MetaModel:sharedInstance():isAllLevelsTreeStarForHideArea(branchId)
    local isActivitySupport = CollectStarsManager.getInstance():isActivitySupportForIsMyArea()
    if TopHideLevelBranchID == branchId and not TopAreaIsFullStar and isActivitySupport then
        MoveToTopHiddenBranch()
    end
end

function WorldScene:onHiddenBranchTapped(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchTap)
	assert(event.context)
	assert(#{...} == 0)

	-- Check Which ExploreCloud Clicked 
	local branchIndex = event.context
	self.currentStayBranchIndex = branchIndex
	local branch = self.hiddenBranchArray[branchIndex]

	-- If Not Scrolled Horizontal Yet
	-- Based On Selected Branch Direction 
	-- Scroll Horizontally Left Or Right
	if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then

		-- Check Branch Direction
		local direction = branch:getDirection()

		if direction == HiddenBranchDirection.LEFT then
			self:scrollToLeft()
		elseif direction == HiddenBranchDirection.RIGHT then
			self:scrollToRight()
		else
			assert(false)
		end

	elseif self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT 
		or self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT then

		-- When Tapped In Already Scrolled To Left Or Right
		-- Scroll Back To The Origin Position
		self:scrollToOrigin()
	end
end

function WorldScene:playOnEnterCenterUserPosAnim( moveToLevelId, ... )
	assert(#{...} == 0)

	-- 这里一定是向上滚，所以需要检查hitRegionCloud
	self.ignoreHitCloudCheck = false

	---------------
	-- Get Config
	-- ------------
	local config = UIConfigManager:sharedInstance():getConfig()
	local linearVelocity = config.worldScene_velocity
	assert(linearVelocity)

	local topLevelBelowScreenCenter = config.worldScene_topLevelBelowScreenCenter
	assert(topLevelBelowScreenCenter)

	-- Get Usr Top Level Pos
	local topLevelId = moveToLevelId or UserManager.getInstance().user:getTopLevelId()
	local topLevelNode = self.levelToNode[topLevelId]
	assert(topLevelNode)
	if not topLevelNode then return end

	if self.trunkScrollInteractionController then
		self.trunkScrollInteractionController:getScrollView():setCurrent(topLevelId)
	end

	local curTopLevelNodePosY = topLevelNode:getPositionY()
	-- Convert Top Level Node's Pos TO World/Scene Space
	local topLevelNodeParent = topLevelNode:getParent()
	local curTopLevelNodePosYInWorldSpace = topLevelNodeParent:convertToWorldSpace(ccp(0, curTopLevelNodePosY))

	-- Get Screen Visible Rect
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	-- Get Center Y In Screen
	local centerYInScreen = visibleOrigin.y * 2 + visibleSize.height / 2

	-- Ensure When User Has Top Level Id == 1, Not Scroll The Tree
	if curTopLevelNodePosYInWorldSpace.y < centerYInScreen + 200 then
		if __WP8 and self.checkFriendVisible then self:checkFriendVisible() end
		return
	end

	-- --------------------------------------
	-- Get The maskedLayer Pos Should Have
	-- -------------------------------------
	--local newMaskedLayerPosY = centerYInScreen - topLevelBelowScreenCenter - curTopLevelNodePosY
	local newMaskedLayerPosY = centerYInScreen - topLevelBelowScreenCenter - curTopLevelNodePosYInWorldSpace.y
	local newMaskedLayerPosX = self.maskedLayer:getPositionX()

	-- Check Whether newMaskedLayerPosY Out Of Range
	self:updateAllRegionCloudState()
	self.regionCloudY, self.regionCloudIndex = self:getNearestRegionCloudPosAndId(math.abs(newMaskedLayerPosY))
	self:setRegionCloudPosition()
	local whetherInRange = self:checkSceneOutRange(newMaskedLayerPosY)
	-- if _G.isLocalDevelopMode then printx(0, 'whetherInRange', whetherInRange) end debug.debug()
	if whetherInRange == CheckSceneOutRangeConstant.HIT_REGION_CLOUD then
		newMaskedLayerPosY = visibleOrigin.y - self:getRegionCloudCheckPosition(self.regionCloudY)
	elseif whetherInRange == CheckSceneOutRangeConstant.IN_RANGE then
		-- Do Nothing
	elseif whetherInRange == CheckSceneOutRangeConstant.BOTTOM_OUT_OF_RANGE then
		newMaskedLayerPosY = self:getMinMaskedLayerY()
	elseif whetherInRange == CheckSceneOutRangeConstant.TOP_OUT_OF_RANGE then
		newMaskedLayerPosY = self:getMaxMaskedLayerY()
	else
		assert(false, "not possible !")
	end


	-- Move To Initial 
	local bottomPos = self:getMaxMaskedLayerY()
	self.maskedLayer:setPositionY(bottomPos)
	self:onVerticalScrollStop()

	if initialMaskedLayerPosY ~= newMaskedLayerPosY then

		-- Disable Scrollable
		self:setScrollable(false)
		
		-- Move TO
		local startPosY = self.maskedLayer:getPositionY()
		local destPosY = newMaskedLayerPosY

		local max = self:getMinMaskedLayerY()
		local deltaLength = -(destPosY - startPosY)
		local percent = math.abs(deltaLength/max)
		local time = 12 * percent  --deltaLength / linearVelocity

		local minTime = 0.3
		if time > 1.8 then time = 1.8 end
		if time < minTime then time = minTime end

		local moveTo = CCMoveTo:create(time, ccp(newMaskedLayerPosX, newMaskedLayerPosY))
		local ease = moveTo
		if time <= minTime then
			ease = CCEaseSineOut:create(moveTo)
		elseif time > minTime and time < 0.65 then
			ease = CCEaseOut:create(moveTo, 2)
		else
			ease = CCEaseExponentialOut:create(moveTo)
		end

		-- Finish Callback
		local function animFinish()
			self:setScrollable(true)
			if __WP8 and self.checkFriendVisible then self:checkFriendVisible() end
			WorldMapOptimizer:getInstance():firstUpdate()
			self:dispatchEvent(Event.new(WorldSceneScrollerEvents.GAME_INIT_ANIME_FIN))
			self:onVerticalScrollStop()
		end
		local moveToFinishCallback = CCCallFunc:create(animFinish)

		local array = CCArray:create()
		array:addObject(CCDelayTime:create(0.04))
		array:addObject(ease)
		array:addObject(moveToFinishCallback)
		self.maskedLayer:runAction(CCSequence:create(array))
	end
end

function WorldScene:create(homeScene, ...)
	assert(homeScene)
	assert(#{...} == 0)

	local newWorldScene = WorldScene.new()
	newWorldScene:init(homeScene)
	return newWorldScene
end

--add by zhigang.niu 不更新好友ID 直接获取好友信息
function WorldScene:sendGetFriendInfoHttp(onSuccessCallback, onFailedCallback, onCancelCallBack, ...)

    local function GetFriengInfo()
        local function onSuccess()
            self.friendsInitiated = true

		    GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kFriendsSynced))
		    GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kInitPushEnergyRequestTask))

            if onSuccessCallback then
                onSuccessCallback()
            end
	    end

	    local function onFailed(event)

            if onFailedCallback then
                onFailedCallback()
            end

		    assert(event)
		    assert(event.name == Events.kError)

		    local err = event.data

		    local errorMessage = "WorldScene:sendFriendHttp Failed !!\n"
		    errorMessage = "errorMessage:" .. err
		    -- assert(false, errorMessage)
	    end

        local function onCancel(event)
            if onCancelCallBack then onCancelCallBack() end
        end

        ---------------------------
	    -- Second Refresh Friend Infos
	    -- ---------------------------
	    local http = FriendHttp.new( true )
	    http:addEventListener(Events.kComplete, onSuccess)
	    http:addEventListener(Events.kError, onFailed)
        http:addEventListener(Events.kCancel, onCancel)

	    local friendIds = UserManager:getInstance().friendIds
		
	    http:load(true, friendIds)
    end

    local function FailedLoginCallback()
        if onCancelCallBack then onCancelCallBack() end
    end

    RequireNetworkAlert:callFuncWithLogged(GetFriengInfo, FailedLoginCallback, kRequireNetworkAlertAnimation.kNoAnimation)
end

--add by zhigang.niu 去掉30分钟CD时间直接获取 
function WorldScene:sendFriendHttpEx(onSuccessCallback, onFailedCallback, onCancelCallback, ...)
	assert(false == onSuccessCallback or type(onSuccessCallback) == "function")
    assert(false == onFailedCallback or type(onFailedCallback) == "function")
    assert(false == onCancleCallback or type(onCancleCallback) == "function")
	assert(#{...} == 0)

    if AccountBindingLogic.preconnectting then
        if onCancelCallback then onCancelCallback() end
		return
	end

	local function onGetFriendsIdEnd()
        self:sendGetFriendInfoHttp( onSuccessCallback, onFailedCallback, onCancelCallback )
	end

	-----------------------
	-- First Refresh Friend Ids
	-- -------------------------
	local function onUserLogin()
		local http = GetFriendsHttp.new(true)
		http:addEventListener(Events.kComplete, onGetFriendsIdEnd)
		http:addEventListener(Events.kError, onGetFriendsIdEnd)
        http:addEventListener(Events.kCancel, onGetFriendsIdEnd)
		http:load()
	end
	RequireNetworkAlert:callFuncWithLogged(onUserLogin, nil, kRequireNetworkAlertAnimation.kNoAnimation)
end

function WorldScene:sendFriendHttp(onSuccessCallback, ...)
	assert(false == onSuccessCallback or type(onSuccessCallback) == "function")
	assert(#{...} == 0)

	if AccountBindingLogic.preconnectting then
		return
	end

	local function onGetFriendsIdEnd()
	
		local function onSuccess()
			self.lastGetFriendTime = Localhost:time()
			self.friendsInitiated = true
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kFriendsSynced))
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kInitPushEnergyRequestTask))

			if onSuccessCallback then
				onSuccessCallback()
			end
		end

		local function onFailed(event)
			assert(event)
			assert(event.name == Events.kError)

			local err = event.data

			local errorMessage = "WorldScene:sendFriendHttp Failed !!\n"
			errorMessage = "errorMessage:" .. err
			-- assert(false, errorMessage)
		end

		---------------------------
		-- Second Refresh Friend Infos
		-- ---------------------------
		local http = FriendHttp.new()
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFailed)

		local friendIds = UserManager:getInstance().friendIds
		
		http:load(true, friendIds)
	end

	-----------------------
	-- First Refresh Friend Ids
	-- -------------------------
	local function onUserLogin()
		if not __IOS_FB then -- facebook不走getFriends
			if (self.lastGetFriendTime or 0) + 30 * 60 * 1000 < Localhost:time() then
				local http = GetFriendsHttp.new()
				http:addEventListener(Events.kComplete, onGetFriendsIdEnd)
				http:addEventListener(Events.kError, onGetFriendsIdEnd)
				http:load()
			end
		end
	end
	RequireNetworkAlert:callFuncWithLogged(onUserLogin, nil, kRequireNetworkAlertAnimation.kNoAnimation)
end

-- 得到当前屏幕正在显示的区域ID（跨区域时以显示的节点数多的区域为主）
function WorldScene:getCurrentAreaId( ... )
	-- body
	local min_y = 0 
	local max_y = self.winSize.height 
	local levelList = {}
	local maxCount = 0
	local maxArea = 0
	for k, v in pairs(self.levelToNode) do 
		local node_pos = v:getPosition()
		local node_y = self.treeNodeLayer:convertToWorldSpace(ccp(node_pos.x, node_pos.y)).y
		if node_y > min_y and node_y < max_y and k < 10000 then
			-- if _G.isLocalDevelopMode then printx(0, node_y, min_y, max_y, k) end 
			local areaId = math.ceil(k / 15)
			if not levelList[areaId] then
				levelList[areaId] = 0
			end

			levelList[areaId] = levelList[areaId] + 1
			if maxArea == 0 then
				maxArea = areaId
				maxCount = levelList[areaId]
			elseif levelList[areaId] > maxCount then 
				maxArea = areaId
				maxCount = levelList[areaId]
			end

		end
	end

	return maxArea
end



function WorldScene:onTopPictureClicked( ... )
	local friendIds = UserManager:getInstance().friendIds
	local friends = FriendManager.getInstance().friends

	local friendIdList = {}
	for k,v in pairs(friendIds) do
		if friends[v] and friends[v].topLevelId == kMaxLevels then
			table.insert(friendIdList,v)
		end
	end
	if UserManager.getInstance().user:getTopLevelId() == kMaxLevels then
		table.insert(friendIdList,UserManager:getInstance().user.uid)
	end

	DcUtil:UserTrack({
		category = "UI",
		sub_category = "click_top_picture",	
	},true)

	TopRankPanel.popoutIfNecessary(friendIdList)
end

local CUR_PLAY_FLOAT_CLOUD = nil
function WorldScene:onVerticalScrollStop()
	--[[
	local newMaskPosY = -self.maskedLayer:getPositionY()
	local hitIdx = 1
	if self.lockedClouds == nil or #self.lockedClouds < 1 then return end

	for i = 1, #self.lockedClouds do
		if self.lockedClouds[i] ~= nil then
			local curCloud = self.lockedClouds[i]
			local nodePos = curCloud:convertToNodeSpace(ccp(0, 0))
			if CUR_PLAY_FLOAT_CLOUD ~= curCloud and nodePos.y < 1580 and nodePos.y > -1280 then
				curCloud:startFloatAnim()
				if CUR_PLAY_FLOAT_CLOUD ~= nil then 
					CUR_PLAY_FLOAT_CLOUD:stopFloatAnim() 
				end
				CUR_PLAY_FLOAT_CLOUD = curCloud
			end
		end
	end
	--]]
end

--------------------------------------------------------------------------------------------------------------

--[[
function WorldScene:addFloatIcon(floatIcon)
	local function onFloatIconTapped(event)
		if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN then
			if floatIcon:getFloatType() == FloatIconType.kRight then
				self:scrollToRight()
			elseif floatIcon:getFloatType() == FloatIconType.kLeft then
				self:scrollToLeft()
			end
			local dcData = {game_type="stage", game_name="two_year_anniversary", category="other", sub_category="two_year_anniversary_change"}
			DcUtil:log(109, dcData)
		elseif self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT 
			or self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT then
			-- self:scrollToOrigin()
		end
	end
	floatIcon:addEventListener(DisplayEvents.kTouchTap, onFloatIconTapped)

	self.floatIconsLayer:addChild(floatIcon)
	table.insert(self.floatIcons, floatIcon)

	self:updateFloatIconPos(floatIcon)
end
]]

--[[
function WorldScene:updateAllFloatIconPos()
	for _, v in pairs(self.floatIcons) do
		self:updateFloatIconPos(v)
	end
end
]]

--[[
function WorldScene:updateFloatIconPos(floatIcon)
	if floatIcon and not floatIcon.isDisposed then
		local checks = {topLevelId = UserManager:getInstance().user:getTopLevelId()}
		if not floatIcon:checkVisible(checks) then
			floatIcon:setVisible(false)
			return
		else
			floatIcon:setVisible(true)
		end

		if floatIcon:getPosType() == FloatIconPositionType.kTopLevel then
			local topLevelId = topLevelId or self.topLevelId
			local locationNode = self.levelToNode[topLevelId]

			if locationNode then
				local posY = locationNode:getPositionY()

				local levelIdInArea = topLevelId % 15
				if levelIdInArea == 0 then levelIdInArea = 15 end
				-- 计算最高位置限制
				local maxPosY = self.levelToNode[topLevelId - levelIdInArea + 15]:getPositionY() - 590
				posY = math.min(posY, maxPosY)
				-- 计算最低位置限制
				local hiddenBranchId = MetaModel:sharedInstance():getHiddenBranchIdByNormalLevelId(topLevelId - levelIdInArea)
				if hiddenBranchId then
					local minPosY = posY

					-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>", floatIcon:getFloatType(), hiddenBranchId) end
					if floatIcon:getFloatType() == FloatIconType.kRight and hiddenBranchId % 2 == 1 then -- 右边的隐藏关
						minPosY = self.levelToNode[topLevelId - levelIdInArea]:getPositionY() + 400
					elseif floatIcon:getFloatType() == FloatIconType.kLeft and hiddenBranchId % 2 == 0 then -- 左边的隐藏关
						minPosY = self.levelToNode[topLevelId - levelIdInArea]:getPositionY() + 400
					end
					posY = math.max(posY, minPosY)
				end
				floatIcon:setPosition(ccp(floatIcon:getPositionX(), posY))
			else
				floatIcon:setVisible(false)
			end			
		end
	end
end
]]

--[[
function WorldScene:updateAnniversaryFloatButton()
	if not self.anniversaryFloatButton and UserManager:getInstance().user:getTopLevelId() >= 20 then
		if AnniversaryFloatButton and AnniversaryFloatButton:isSupport() and AnniversaryFloatButton:isInAcitivtyTime() then
			local floatIcon = AnniversaryFloatButton:create(FloatIconType.kRight, FloatIconPositionType.kTopLevel)
			self.anniversaryFloatButton = floatIcon

			self.anniversaryFloatButton:setAnchorPoint(ccp(0.5, 0.5))
			self.anniversaryFloatButton:ignoreAnchorPointForPosition(false)

			floatIcon:setPositionXY(820, 0)

			self:addFloatIcon(floatIcon)
		end
	end
end
]]
