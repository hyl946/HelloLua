TileSnail = class(CocosObject)

local kCharacterAnimationTime = 1/30

local SnailAnimation = table.const{
	kIdle = 1,
	kAppear = 2, 
	kDisappear = 3,
	kMove = 4, 
	kShocked =5,
	kToShell = 6, 
	kOutShell = 7
}
function TileSnail:create( )
	-- body
	local node = TileSnail.new(CCNode:create())
	node:init()
	return node
end

function TileSnail:init( ... )
	-- body
	local snail = Sprite:createWithSpriteFrameName("scene_snail_idle_0000")
	self.snail = snail
	self:addChild(snail)

	local arrow = Sprite:createWithSpriteFrameName("scene_snail_arrow_0000")
	self.arrow = arrow
	self:addChild(arrow)
	local frames = SpriteUtil:buildFrames("scene_snail_arrow_%04d", 0, 20)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	arrow:play(animate)
	self.arrow:setVisible(false)
	self:playIdleAnimation()
end

function TileSnail:updateArrow( direction )
	-- body
	self.arrow:setVisible(true)
	if direction ==  RouteConst.kUp then 
		self.arrow:setRotation(-90)
		self.arrow:setPosition(ccp(0, GamePlayConfig_Tile_Height/2))
	elseif direction == RouteConst.kDown then
		self.arrow:setRotation(90)
		self.arrow:setPosition(ccp(0, -GamePlayConfig_Tile_Height/2))
	elseif direction == RouteConst.kLeft or direction == RouteConst.kRight then
		self.arrow:setRotation(0)
		self.arrow:setPosition(ccp(GamePlayConfig_Tile_Width/2,0))
	else
		self.arrow:setVisible(false)
	end
end

function TileSnail:playToShellAnimation( callback )
	-- body
	local frames = SpriteUtil:buildFrames("scene_snail_toShell_%04d", 0, 20)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.snail:stopAllActions()
	self.snail:play(animate, 0, 1, callback)
	self.animation = SnailAnimation.kToShell
end

function TileSnail:changeVisibleMoveSnail( value )
	-- body
	if self.snail then 
		self.snail:setVisible(not value)
	end
	if self.moveSnail then 
		self.moveSnail:setVisible(value)
	end
end
function TileSnail:playOutShellAnimation( callback )
	-- body
	self:changeVisibleMoveSnail(false)
	local frames = SpriteUtil:buildFrames("scene_snail_toShell_%04d", 0, 20, true)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.snail:stopAllActions()
	local function animationCallback( ... )
		-- body
		if callback then callback() end
	end 
	self.snail:play(animate, 0, 1, animationCallback)
	self.animation = SnailAnimation.kOutShell
end

function TileSnail:playIdleAnimation( ... )
	-- body
	if self.animation ~= SnailAnimation.kIdle then 
		local frames = SpriteUtil:buildFrames("scene_snail_idle_%04d", 0, 29)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.snail:stopAllActions()
		self.snail:play(animate)
		self.animation = SnailAnimation.kIdle
	end
end

function TileSnail:playDestroyAnimation(callback)
	-- body
	self:changeVisibleMoveSnail(false)
	local function animationCallback( ... )
		-- body
		if callback then callback() end
	end
	self.animation = SnailAnimation.kDisappear
	local frames = SpriteUtil:buildFrames("scene_snail_destory_%04d", 0, 25)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.snail:stopAllActions()
	self.snail:play(animate, 0, 1, animationCallback)
end

function TileSnail:setMainSpriteRotation( rotation )
	-- body
	-- if self.moveHedgehog then
	-- 	self.moveHedgehog.main_sprite:setRotation(-rotation)
	-- end
end

function TileSnail:createMoveSnail( callback )
	-- body
	local function animationCallback( ... )
		-- body
		if callback then callback() end
	end
	local time = 0.5
	local moveSnail = Sprite:createEmpty()

	--shadow
	local shadow = Sprite:createWithSpriteFrameName("scene_snail_shadow")
	local action_move_1 = CCMoveBy:create(time/2, ccp(-GamePlayConfig_Tile_Width/3, 0))
	local action_move_2 = CCMoveBy:create(time/2, ccp(GamePlayConfig_Tile_Width/3, 0))
	shadow:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action_move_1, action_move_2)) )
	moveSnail:addChild(shadow)
	moveSnail.shadow = shadow

	--snail
	local snail = Sprite:createWithSpriteFrameName("scene_snail_rotation")
	local action_rotation = CCRepeatForever:create(CCRotateBy:create(time, 360))
	snail:runAction(action_rotation)
	moveSnail:addChild(snail)
	moveSnail.snail = snail


	local function createLight( minScale, maxScale, position )
		-- body
		minScale = minScale or 1
		maxScale = maxScale or 1
		position = position or ccp(0, 0)
		local light =  Sprite:createWithSpriteFrameName("scene_snail_light")
		light:setAnchorPoint(ccp(0.9, 0.5))
		light:setScale(minScale)
		light:setPosition(position)
		local function reset( ... )
			-- body
			light:setOpacity(255)
			light:setScale(minScale)
		end

		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(time/2, maxScale))
		arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(time/2, 1.1 * maxScale), CCFadeOut:create(time/2)))
		arr:addObject(CCCallFunc:create(reset))

		light:runAction(CCRepeatForever:create(CCSequence:create(arr)))
		return light
	end

	local light_1 = createLight(0.2, 1, ccp(-GamePlayConfig_Tile_Width/4, GamePlayConfig_Tile_Height/5))
	moveSnail:addChild(light_1)
	moveSnail.light_1 = light_1

	local light_2 = createLight(0.15, 0.75, ccp(GamePlayConfig_Tile_Width/4, -GamePlayConfig_Tile_Height/3))
	moveSnail:addChild(light_2)
	moveSnail.light_2 = light_2
	self.moveSnail = moveSnail
	self:addChild(moveSnail)
end

function TileSnail:playMoveAnimation( callback )
	-- body
	if not self.moveSnail then 
		self:createMoveSnail(callback)
	end
	self:changeVisibleMoveSnail(true)
	
end



