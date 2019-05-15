
LightMoveAnimation = class(Layer)

local lightScaleSizeWidth = 648
local lightScaleSizeHeight = 155
function LightMoveAnimation:ctor()

end

function LightMoveAnimation:init()
	Layer.initLayer(self)

	self.plistPath = "materials/moveLight.plist"
	if __use_small_res then  
		self.plistPath = table.concat(self.plistPath:split("."),"@2x.")
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(self.plistPath)

	self.light = Sprite:createWithSpriteFrameName("moveLight.png")
	local scaleX = self.sizeWidth/lightScaleSizeWidth
	local scaleY = self.sizeHeight/lightScaleSizeHeight
	self.light:setScale(scaleY)
	local lightSize = self.light:getGroupBounds().size
	self.light:setAnchorPoint(ccp(0.5, 0))
	self.light:setRotation(self.rotation)
    self.lightOriPosX = 0
    self.lightOriPosY = -lightSize.height

	local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(self.sizeWidth, self.sizeHeight))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0.5, 0.5))
    clipping:ignoreAnchorPointForPosition(false)

    -- local clipping = LayerColor:create()
    -- clipping:setColor(ccc3(255,0,0))
    -- clipping:setOpacity(150)
    -- clipping:setContentSize(CCSizeMake(self.sizeWidth, self.sizeHeight))
    -- clipping:setAnchorPoint(ccp(0.5, 0.5))
    -- clipping:ignoreAnchorPointForPosition(false)

    clipping:addChild(self.light)
    self:addChild(clipping)
end

function LightMoveAnimation:play(callback)
	if self.light then 
		self.light:setPosition(ccp(self.lightOriPosX, self.lightOriPosY))
		local arr = CCArray:create()
		arr:addObject(CCMoveTo:create(self.lightMoveTime, ccp(self.sizeWidth, self.sizeHeight)))
		arr:addObject(CCCallFunc:create(function ()
			if callback then callback() end
		end)) 
		self.light:stopAllActions()
		self.light:runAction(CCSequence:create(arr))
	end
end

function LightMoveAnimation:dispose()
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(self.plistPath)
	Layer.dispose(self)
end

function LightMoveAnimation:create(sizeWidth, sizeHeight, moveTime, rotation)
	local layer = LightMoveAnimation.new()
	layer.sizeWidth = sizeWidth
	layer.sizeHeight = sizeHeight
	layer.lightMoveTime = moveTime or 0.5
	layer.rotation = rotation or 19
	layer:init()
	return layer
end