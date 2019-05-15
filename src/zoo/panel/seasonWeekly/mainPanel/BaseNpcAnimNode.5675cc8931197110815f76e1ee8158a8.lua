local armatures = {}

local function loadArmature(resourceSrc, skeletonName, textureName)
    if not armatures[resourceSrc] then
        armatures[resourceSrc] = 0
    end
    armatures[resourceSrc] = armatures[resourceSrc] + 1
    FrameLoader:loadArmature( resourceSrc, skeletonName, textureName )
end

local function unloadArmature(resourceSrc, cleanup)
    if armatures[resourceSrc] then
        armatures[resourceSrc] = armatures[resourceSrc] - 1
        if armatures[resourceSrc] <= 0 then
            FrameLoader:unloadArmature( resourceSrc, cleanup )
        end
    end
end

local jsonCache = {}

local function loadJson( jsonPathname )
	-- body
	if not jsonCache[jsonPathname] then
		InterfaceBuilder:createWithContentsOfFile(jsonPathname)
		jsonCache[jsonPathname] = 0
	end

	jsonCache[jsonPathname] = jsonCache[jsonPathname] + 1
end

local function unloadJson( jsonPathname )
	if not jsonCache[jsonPathname] then 
		return 
	end

	jsonCache[jsonPathname] = jsonCache[jsonPathname] - 1

	if jsonCache[jsonPathname] <= 0 then
		InterfaceBuilder:unloadAsset(jsonPathname)
		jsonCache[jsonPathname] = nil
	end

end

local BaseNpcAnimNode = class(Layer)

function BaseNpcAnimNode:create( skeletonResourceSrc, skeletonName, animNodeName, skinJson)
	local node = BaseNpcAnimNode.new()
 	node:initAnimNode(skeletonResourceSrc, skeletonName, animNodeName, skinJson)
 	return node
end

function BaseNpcAnimNode:initAnimNode( skeletonResourceSrc, skeletonName, animNodeName, skinJson )
 	self:initLayer()
 	self:ignoreAnchorPointForPosition(false)

 	self:initSkinConfig()


 	self.skeletonResourceSrc = skeletonResourceSrc
 	self.skeletonName = skeletonName
 	self.animNodeName = animNodeName
 	self.skinJson = skinJson

 	loadJson(self.skinJson)
 	loadArmature(self.skeletonResourceSrc, self.skeletonName)

 	self.animNode = ArmatureNode:create(self.animNodeName)
 	self:addChild(self.animNode)

 	self.skinResData = {}

end

function BaseNpcAnimNode:getSkinResData( ... )
	return self.skinResData or {}
end

function BaseNpcAnimNode:dispose( ... )
	-- body
	Layer.dispose(self, ...)

	unloadJson(self.skinJson)
	unloadArmature(self.skeletonResourceSrc, true)

end


function BaseNpcAnimNode:setSkin( slotName, spriteFrameName, resIndex)
	local slot = self.animNode:getCon(slotName)
	if not slot then
		return
	end

	slot:removeAllChildrenWithCleanup(true)

	self.skinResData[slotName] = nil	

	if spriteFrameName and CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameName) then
		local skin = CCSprite:createWithSpriteFrameName(spriteFrameName)
		skin:setAnchorPoint(ccp(0, 0))
		slot:addChild(skin)
		self.skinResData[slotName] = resIndex
	end

end

function BaseNpcAnimNode:setSkin2( skinType, resIndex )
	local skinTypeMapSlots = self.skinConfig.skinTypeMapSlots or {}
	for _, slot in ipairs(skinTypeMapSlots[skinType] or {}) do
		local slotMapSpriteFrameNamePrefix = self.skinConfig.slotMapSpriteFrameNamePrefix or {}
		if slotMapSpriteFrameNamePrefix[slot] then
			local spriteFrameName = slotMapSpriteFrameNamePrefix[slot] .. '_' .. (resIndex or 'bu_cun_zai') .. '0000'
			self:setSkin(slot, spriteFrameName, resIndex)
		end
	end
end

function BaseNpcAnimNode:getSkinConfig( ... )
	return self.skinConfig or {}
end

function BaseNpcAnimNode:setSkinConfig( skinConfig )
	self.skinConfig  = skinConfig
end

function BaseNpcAnimNode:initSkinConfig( ... )
	self.skinConfig = {}
end


return BaseNpcAnimNode