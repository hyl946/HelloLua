
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月18日 12:07:36
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.ui.LayoutBuilder"

---------------------------------------------------
-------------- Trunks
---------------------------------------------------

assert(not Trunks)
assert(BaseUI)
Trunks = class(BaseUI)

function Trunks:init(numberOfFlower, ...)
	assert(type(numberOfFlower) == "number")
	assert(#{...} == 0)

	local layer = Layer:create()

	--------------------
	-- Init Base Class
	-- ------------------
	BaseUI.init(self, layer)

	------------------
	-- Get Data
	-- ----------
	self.numberOfFlower = numberOfFlower

	-- Get Flower Pos Info From .json File
	self.flowerPosInOneTrunk = false
	self.numberOfFlowerPerTrunk = false
	self:getPosInfoForOneTrunk()

	-- Get Needed Trunk Number
	self.trunkNumber = math.ceil(numberOfFlower / self.numberOfFlowerPerTrunk) + 1
	self.trunksPos = {}

	-- Build Trunk
	self:buildTrunk()
end

function Trunks:getTrunkNumber(...)
	assert(#{...} == 0)

	return self.trunkNumber
end

function Trunks:getFlowerPos(flowerIndex, ...)
	assert(type(flowerIndex) == "number")
	assert(#{...} == 0)

	assert(flowerIndex <= self.numberOfFlower)

	-- Calculate In Which Trunk
	local trunkIndex = math.ceil(flowerIndex / self.numberOfFlowerPerTrunk)
	local flowerIndex = flowerIndex - (trunkIndex - 1) * self.numberOfFlowerPerTrunk
	
	local flowerPos = self.flowerPosInOneTrunk[flowerIndex]
	local trunkPos = self.trunksPos[trunkIndex]

	local pos = ccp(trunkPos.x + flowerPos.x, trunkPos.y + flowerPos.y)
	return pos
end

function Trunks:buildTrunk(...)
	assert(#{...} == 0)

	local branchRootPosX = -118
	local branchRootPosY = 0

	local backGroundCloudLayer = Layer:create()
	self:addChild(backGroundCloudLayer)
	
	--------------------
	--- Trunk Root
	------------------
	local branchRoot = Sprite:createWithSpriteFrameName("trunkRoot.png")
	assert(branchRoot)
	branchRoot:setAnchorPoint(ccp(0,0))

	local rect = branchRoot:getGroupBounds()
	local branchRootHeight = rect.size.height 
	branchRoot:setPositionX(branchRootPosX)
	branchRoot:setPositionY(branchRootPosY)
	
	self.branchRoot = branchRoot
	self:addChild(branchRoot)
	
	--------------2016春节烟花----------------
	-- if WorldSceneShowManager:getInstance():isInAcitivtyTime() then 
	-- 	local clickedFirework = ClickedFireworkAnimation:create()
	-- 	self.branchRoot.clickedFirework = clickedFirework
	-- 	self.branchRoot:addChild(clickedFirework)
	-- end

	---------------------------------------
	-- Intermediate Bwtween Root And Trunk
	-- ----------------------------------
	local manualAdjustPosY = -209
 	local bottomAvailabelY = branchRootPosY + branchRootHeight + manualAdjustPosY

	-----------------------
	-- Back Ground Cloud
	-- --------------------
	-- local trunkRootCloudSprite = Sprite:createWithSpriteFrameName("trunkRootBackCloud.png")
	-- assert(trunkRootCloudSprite)
	-- trunkRootCloudSprite:setAnchorPoint(ccp(0,0))

	-- local manualAdjustPosY = -50 
	-- trunkRootCloudSprite:setPosition(ccp(branchRootPosX, bottomAvailabelY + manualAdjustPosY))
	-- --self:addChild(trunkRootCloudSprite)
	-- self.trunkRootCloudSprite = trunkRootCloudSprite
	-- backGroundCloudLayer:addChild(trunkRootCloudSprite)

	---------------
	-- Each Trunk
	-- --------------
	
	-- Delay Create Batch Node
	local batchNode = false

	local winSize = CCDirector:sharedDirector():getWinSize()
	bottomAvailabelY = bottomAvailabelY + 10
	self.bottomAvailabelY = bottomAvailabelY

	for index = 1,self.trunkNumber do

		local tree = Sprite:createWithSpriteFrameName("trunk.png")
		assert(tree)
		tree:setAnchorPoint(ccp(0,1))
    
	    if __WP8 then 
	      bottomAvailabelY = bottomAvailabelY - 1
	      if index == 1 then
	        tree:getTexture():setAliasTexParameters()
	      end
	    end
		
	    local rect = tree:getGroupBounds()
		local treeHeight = rect.size.height
		bottomAvailabelY = bottomAvailabelY + treeHeight + 0
		local y = bottomAvailabelY
		
		local posX = 105
		tree:setPosition(ccp(posX, y))

		self.trunksPos[index] = {x=posX, y=y}

		-- Delay Create Batch Node
		if not batchNode then
			local texture = tree:getTexture()
			batchNode = SpriteBatchNode:createWithTexture(texture)
			batchNode.name = "batchNode"
		end
		if not self.trees then
			self.trees = {}
		end
		
		batchNode:addChild(tree)
		table.insert(self.trees,tree)
	end

	if batchNode then
		self:addChild(batchNode)
	end

	---- Re Order To Top
	branchRoot:removeFromParentAndCleanup(false)
	self:addChild(branchRoot)
end

function Trunks:getPosInfoForOneTrunk(...)
	assert(#{...} == 0)

	self.flowerPosInOneTrunk = {}

	local filePath = "flash/scenes/homeScene/trunkFlowerPos.json"
	local path = CCFileUtils:sharedFileUtils():fullPathForFilename(filePath)    
	local t, fsize = lua_read_file(path)
	local simplejson = require("cjson")
	local config = simplejson.decode(t)
	assert(config.groups)
	local flowerPosGroup = config.groups["flowerPos"]
	assert(flowerPosGroup)

	local maxIndex = 0
	for k,symbol in ipairs(flowerPosGroup) do

		local flowerIndex = tonumber(symbol.id)
		local posX = tonumber(symbol.x)
		local posY = -tonumber(symbol.y)

		if flowerIndex ~= nil then
			assert(flowerIndex > 0)

			if flowerIndex > maxIndex then
				maxIndex = flowerIndex
			end

			self.flowerPosInOneTrunk[flowerIndex] = {x=posX, y=posY}
		end
	end

	-- Check Flower Index Is Continuous
	for index = 1, maxIndex do
		assert(self.flowerPosInOneTrunk[index])
	end

	self.numberOfFlowerPerTrunk = #self.flowerPosInOneTrunk
end

function Trunks:create(numberOfFlower, ...)
	assert(type(numberOfFlower) == "number")
	assert(#{...} == 0)

	local newTrunk = Trunks.new()
	newTrunk:init(numberOfFlower)
	return newTrunk
end
