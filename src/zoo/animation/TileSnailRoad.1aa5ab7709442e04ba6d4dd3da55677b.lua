TileSnailRoad = class(CocosObject)

local kCharacterAnimationTime = 1/30


function TileSnailRoad:create( roadType, rotation )
	-- body
	local str
	local animation
	if roadType == TileRoadType.kLine then
		str = "line"
	elseif roadType == TileRoadType.kCorner then
		str = "corner"
	else
		str = "point"

		animation = Sprite:createWithSpriteFrameName("road_point_mask_0000")
		local frames = SpriteUtil:buildFrames("road_point_mask_%04d", 0, 30, roadType == TileRoadType.kStartPoint)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		animation:play(animate)
		animation:setAnchorPoint(ccp(0,0))
	end
	
	local node = TileSnailRoad.new(CCSprite:createWithSpriteFrameName("road_"..str.."_dark"))

	local mask = Sprite:createWithSpriteFrameName("road_"..str.."_bright")
	mask:setAnchorPoint(ccp(0,0))
	node.mask = mask
	node:addChild(mask)
	mask:setVisible(false)

	if animation then
		node:addChild(animation)
	end
	node:setRotation(rotation)
	node.isBright = false
	return node

end

function TileSnailRoad:changeState(changeToBright)
	-- body
	if changeToBright then
		self:changeBright()
	else
		self:changeDark()
	end
end

function TileSnailRoad:changeBright( ... )
	-- body
	if self.isBright then return end
	self.mask:setVisible(true)
	self.mask:runAction(CCFadeIn:create(0.3))
	self.isBright = true
end

function TileSnailRoad:changeDark( ... )
	-- body
	if self.isBright then
		self.mask:runAction(CCFadeOut:create(0.3))
		self.isBright = false
	end
end
