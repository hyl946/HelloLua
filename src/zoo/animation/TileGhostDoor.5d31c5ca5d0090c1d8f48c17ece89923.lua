TileGhostDoor = class(CocosObject)

GhostDoorType = {
	k_appear = "in",
	k_vanish = "out"
}

local kCharacterAnimationTime = 1/30

local assetPrefix = "blocker_ghost_"
local appearAssetShiftY = -22
local vanishAssetShiftY = 15

-------------------------------------------------------------------------------------
function TileGhostDoor:create(type)
	local node = TileGhostDoor.new(CCNode:create())
	node.name = "ghostDoor"
	node:_startIdleAnimation(type)
	
	return node
end

function TileGhostDoor:_cleanSprite()
	if self.sprite then 
		self.sprite:removeFromParentAndCleanup(true)
	end
end

function TileGhostDoor:_startIdleAnimation(type)
	self.doorType = type

	self:_cleanSprite()

	local typeAsset
	local assetShiftY
	if self.doorType == GhostDoorType.k_appear then
		typeAsset = "entrance_"
		assetShiftY = appearAssetShiftY
	elseif self.doorType == GhostDoorType.k_vanish then
		typeAsset = "exit_"
		assetShiftY = vanishAssetShiftY
	end

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix..typeAsset.."0000")
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames(assetPrefix..typeAsset.."%04d", 0, 30)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.sprite:runAction(CCRepeatForever:create(animate))

	self.sprite:setPosition(ccp(0, assetShiftY))
end