TileMimosa = class(CocosObject)
local kCharacterAnimationTime = 1/30

function TileMimosa:create(direction)
	-- body
	local node = TileMimosa.new(CCNode:create())
	node.name = "TileMimosa"
	--ligth
	node.light = Sprite:createWithSpriteFrameName("mimosa.back_light_0000")
	node.light:setVisible(false)
	node:addChild(node.light)
	--direction
	local directionAnimation = Sprite:createWithSpriteFrameName("scene.mimosa.direction_0000")
	directionAnimation:setAnchorPoint(ccp(0,0.5))
	node:addChild(directionAnimation)
	local frames2 = SpriteUtil:buildFrames("scene.mimosa.direction_%04d", 0,19)
	local animatie2 =  SpriteUtil:buildAnimate(frames2, kCharacterAnimationTime)
	directionAnimation:play(animatie2)

	local pos , rotationValue
	if direction == 1 then                               --left
		pos = ccp(-GamePlayConfig_Tile_Width/3, 0)
		rotationValue = -180
	elseif direction == 2 then                           --right
		pos = ccp(GamePlayConfig_Tile_Width/3, 0)
		rotationValue = 0
	elseif direction == 3 then                           --up
		pos = ccp(0, GamePlayConfig_Tile_Height/3)
		rotationValue = -90
	else 
		pos = ccp(0, -GamePlayConfig_Tile_Height/3)     --down
		rotationValue = 90
	end
	directionAnimation:setRotation(rotationValue)
	directionAnimation:setPosition(pos)
	node.directionAnimation = directionAnimation

	--mimosa
	node.mainSprite = Sprite:createWithSpriteFrameName("mimosa.idle_0000")
	node:addChild(node.mainSprite) 
	return node
end

function TileMimosa:playIdleAnimation( ... )
	-- body
	local frames = SpriteUtil:buildFrames("mimosa.idle_%04d", 0, 20)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.mainSprite:play(animate)
end

function TileMimosa:playActivieAnimation( times, callback )
	-- body
	self.mainSprite:stopAllActions()
	local function animationCallback( ... )
		-- body
		if callback then callback() end
		self:playIdleAnimation()
	end

	local frames = SpriteUtil:buildFrames("mimosa.active_%04d", 0, 20)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	if times and times > 0 then
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.mainSprite:play(animate, 0 , times, animationCallback)
	else
		local animate = SpriteUtil:buildAnimate(frames, 1/48)
		self.mainSprite:play(animate)
	end
	
end

local function createLeafAnimation( callback, isGrow)
	-- body
	local container = Sprite:createEmpty()
	--star
	local star_max = 8
	local time = 1
	if isGrow then
		for k = 1, star_max do 
			local angle = (k-1) * 360/star_max   ----------角度
			local radian = angle * math.pi / 180
			local xStand = GamePlayConfig_Tile_Width * math.sin(radian)
			local yStand = GamePlayConfig_Tile_Height * math.cos(radian)
			local star = Sprite:createWithSpriteFrameName("mimosa.star")
			local function removeStar( ... )
				-- body
				if star then
					star:removeFromParentAndCleanup(true)
				end
			end

			star:setPosition(ccp(0.3 * xStand, 0.3 * yStand))
			local arr = CCArray:create()
			arr:addObject(CCMoveTo:create(time * 0.3, ccp(0,0)))
			arr:addObject(CCMoveTo:create(time * 0.4, ccp(1 * xStand,1 * yStand)))
			arr:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(time * 0.3, ccp(1.1 * xStand, 1.1 * yStand)), CCFadeOut:create(0.3)))
			arr:addObject(CCCallFunc:create())
			star:runAction(CCSequence:create(arr))
			container:addChild(star)
		end
	end

	

	--leaf
	local pos_list = {	
						ccp(-GamePlayConfig_Tile_Width / 3, GamePlayConfig_Tile_Height/3), 
						ccp(GamePlayConfig_Tile_Width / 3, GamePlayConfig_Tile_Height/3), 
						ccp(-GamePlayConfig_Tile_Width / 3, -GamePlayConfig_Tile_Height/3), 
						ccp(GamePlayConfig_Tile_Width / 3, -GamePlayConfig_Tile_Height/3), 
					}
	local rotation_list = {-135, -17.5, 73.9, 150}
	for k =1, 4 do 
		local leaf = Sprite:createWithSpriteFrameName("scene.mimosa.direction_0000")
		local frames = SpriteUtil:buildFrames("scene.mimosa.direction_%04d", 0,19, not isGrow)
		local animatie =  SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		local function removeLeaf( ... )
			-- body
			if leaf then leaf:removeFromParentAndCleanup(true) end
		end
		leaf:setScale(1.33)
		leaf:setPosition(pos_list[k])
		leaf:setRotation(rotation_list[k])
		leaf:play(animatie, 0, 1, removeLeaf)
		container:addChild(leaf)
	end
	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(callback)))
	return container

end

function TileMimosa:playGrowAnimation( callback )
	-- body
	local leaf
	local function leafCallback( ... )
		-- body
		if leaf then
			leaf:removeFromParentAndCleanup(true)
		end
	end
	leaf = createLeafAnimation(leafCallback, true)
	self:addChild(leaf)
	self:playActivieAnimation(1, callback)
end

function TileMimosa:playBackAnimation(callback )
	-- body
	local function lightCallback()
		if self.light then 
			self.light:setVisible(false)
		end
	end
	self.light:setVisible(true)
	self.light:setScale(1)
	self.light:setAlpha(1)
	local arr = CCArray:create()
	arr:addObject(CCScaleTo:create(0.2, 1.3))
	arr:addObject(CCScaleTo:create(0.8, 0.1))
	arr:addObject(CCCallFunc:create(lightCallback))
	self.light:runAction(CCSequence:create(arr))
	
	local leaf 
	local function leafCallback( ... )
		-- body
		if leaf then
			leaf:removeFromParentAndCleanup(true)
		end
	end
	leaf = createLeafAnimation(leafCallback)
	self:addChild(leaf)

	self:playActivieAnimation(1, callback)
end
