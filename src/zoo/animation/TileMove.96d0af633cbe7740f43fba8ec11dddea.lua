TileMove = class(Sprite)

function TileMove:createTile(texture, withCollector)
	local node = TileMove.new(CCSprite:create())
	if texture  then
		node:setTexture(texture)
	end
	node:init(withCollector)
	return node
end

function TileMove:init(withCollector)
	local tile = Sprite:createWithSpriteFrameName("move_tile")
	tile:setAnchorPoint(ccp(0.5, 0.5))
	tile:setScale(1.008)
	self:addChild(tile)
	if withCollector then
		local collector = Sprite:createWithSpriteFrameName("map_move_tile_ingr_collect")
		collector:setAnchorPoint(ccp(0.5, 1))
		collector:setPosition(ccp(0, -28))
		self:addChild(collector)
	end
end

function TileMove:createArrowAnimation(dir, onAnimationFinish)
	local fps = 24
	local container = Sprite:createEmpty()
	container:setAnchorPoint(ccp(0.5, 0.5))
	local arrow = Sprite:createWithSpriteFrameName("move_tile_arrow")
	arrow:setOpacity(255 * 0.07)
	arrow:setPosition(ccp(-58, -3))

	local actionSeq = CCArray:create()
	local action1 = CCSpawn:createWithTwoActions(CCMoveBy:create(10/fps, ccp(38, 0)), CCFadeTo:create(10/fps, 255))
	local action2 = CCMoveBy:create(5/fps, ccp(21, 0))
	local action3 = CCSpawn:createWithTwoActions(CCMoveBy:create(10/fps, ccp(32, 0)), CCFadeTo:create(10/fps, 255 * 0.5))
	actionSeq:addObject(action1)
	actionSeq:addObject(action2)
	actionSeq:addObject(action3)
	local action4 = CCCallFunc:create(function()
		if container and not container.isDisposed then container:removeFromParentAndCleanup(true) end 
		if onAnimationFinish then onAnimationFinish() end
		end)
	actionSeq:addObject(action4)

	arrow:runAction(CCSequence:create(actionSeq))
	container:addChild(arrow)
	if dir == 1 then
		container:setRotation(-90)
	elseif dir == 2 then
	elseif dir == 3 then
		container:setRotation(90)
	elseif dir == 4 then
		container:setRotation(-180)
	end
	return container
end