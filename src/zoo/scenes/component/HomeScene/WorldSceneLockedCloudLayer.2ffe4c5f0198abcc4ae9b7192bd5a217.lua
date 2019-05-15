WorldSceneLockedCloudLayer = class(Layer)

function WorldSceneLockedCloudLayer:create( ... )
	local layer = WorldSceneLockedCloudLayer.new()

	Layer.initLayer(layer)
	layer:getBatchNode()
	layer:getNewCloudLockNode()
	layer:getNewBlockerShowNode()
	layer:getBlockerShowBatchNode()
	layer:getHiddenBranchTextBatchNode()
	layer:getHiddenBranchExtraTextNode()
	layer:getHiddenBranchNumberBatchNode()
	
	return layer
end

function WorldSceneLockedCloudLayer:getNewCloudLockNode( ... )
	if not self.newCloudLockNode then
		self.newCloudLockNode = Layer:create()
		self:addChild(self.newCloudLockNode)
	end

	return self.newCloudLockNode
end

function WorldSceneLockedCloudLayer:getNewBlockerShowNode( ... )
	if not self.newBlockerShowNode then
		self.newBlockerShowNode = Layer:create()
		self:addChild(self.newBlockerShowNode)
	end

	return self.newBlockerShowNode
end

function WorldSceneLockedCloudLayer:getBlockerShowBatchNode( ... )
	if not self.blockerShowBatchNode then
		local blockerFrame = Sprite:createWithSpriteFrameName("area_blocker_fg0000")
		local texture = blockerFrame:getTexture()
		self.blockerShowBatchNode = SpriteBatchNode:createWithTexture(texture)
		blockerFrame:dispose()

		self:addChild(self.blockerShowBatchNode)
	end

	return self.blockerShowBatchNode
end

function WorldSceneLockedCloudLayer:getBatchNode( ... )
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
function WorldSceneLockedCloudLayer:getHiddenBranchTextBatchNode( ... )
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

function WorldSceneLockedCloudLayer:getHiddenBranchExtraTextNode()
	if not self.hiddenExtraTextNode then
		self.hiddenExtraTextNode = Layer:create()
		self:addChild(self.hiddenExtraTextNode)
	end

	return self.hiddenExtraTextNode
end

function WorldSceneLockedCloudLayer:getHiddenBranchNumberBatchNode( ... )
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