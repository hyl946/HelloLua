TileSand = class(CocosObject)

-- 因为使用了BatchNode,只能使用Sprite
function TileSand:createIdleSand()
	local sprite = Sprite:createWithSpriteFrameName("sand_idle_0000.png")
	local frames = SpriteUtil:buildFrames("sand_idle_%04d.png", 0, 34)
	local animate = SpriteUtil:buildAnimate(frames, 1/8)
	sprite:play(animate)
	return sprite
end

-- function TileSand:buildCleanAnim2(callback, texture)
-- 	local sandSprite = Sprite:createWithSpriteFrameName("sand_clean_0000.png")
-- 	local frames = SpriteUtil:buildFrames("sand_clean_%04d.png", 0, 34)
-- 	local animate = SpriteUtil:buildAnimate(frames, 1/20)
-- 	sandSprite:play(animate, 0, 1, callback, true)
-- 	local posOffset = {x=-3, y=8}
-- 	return sandSprite, posOffset
-- end

function TileSand:buildCleanAnim(callback, texture)
	local container = nil
	if texture then
		container = Sprite:createEmpty()
		container:setTexture(texture)
	else
		container = Sprite:createWithSpriteFrameName("sand_clean_0014.png")
	end
	container:setAnchorPoint(ccp(0, 0))

	local animCount = 0

	local function onAnimCompleted()
		if animCount > 0 then
			animCount = animCount - 1
			if animCount == 0 then
				container:removeFromParentAndCleanup(true)
				if callback then callback() end
			end
		end
	end

	local sandSprite = Sprite:createWithSpriteFrameName("sand_clean_0000.png")
	local frames = SpriteUtil:buildFrames("sand_clean_%04d.png", 0, 14)
	local animate = SpriteUtil:buildAnimate(frames, 1/40)
	sandSprite:play(animate, 0.1, 1, onAnimCompleted, true)
	animCount = animCount + 1
	container:addChild(sandSprite)

	local sprite_name = "sand_clean_dust.png"
	for k = 1, 9 do 
		animCount = animCount + 1
		local sprite = Sprite:createWithSpriteFrameName(sprite_name)
		local angle = (k-1) * 360/9 + 20   ----------角度
		local radian = angle * math.pi / 180
		-- if _G.isLocalDevelopMode then printx(0, "angle = ", angle, "radian = ",radian) end
		-- sprite:setRotation(angle)
		-- sprite:setScale(0.5)
		sprite:setOpacity(255 * 0.3)
		sprite:setAnchorPoint(ccp(0.5,0.5))
		local tarScale = 0.7 + 0.2 * math.random()
		local time_spaw = 0.14
		local action_move_1 = CCMoveBy:create(time_spaw*1, ccp(math.sin(radian) * 2 *GamePlayConfig_Tile_Width/3 , math.cos(radian) * 2 *GamePlayConfig_Tile_Width/3  ))
		local action_fadein = CCFadeTo:create(time_spaw * 1, 255*0.7)
		local action_scale = CCScaleTo:create(time_spaw*1,tarScale)
		local actionArray_spawn_1 = CCArray:create()
		actionArray_spawn_1:addObject(action_move_1)
		actionArray_spawn_1:addObject(action_fadein)
		actionArray_spawn_1:addObject(action_scale)
		local action_spaw_1 = CCSpawn:create(actionArray_spawn_1)

		local action_fadeout = CCFadeTo:create(time_spaw * 4, 255 * 0.1)
		local action_move_2 = CCMoveBy:create(time_spaw * 4, ccp(math.sin(radian) * GamePlayConfig_Tile_Width/10 , math.cos(radian) * GamePlayConfig_Tile_Width/10  ))
		-- local action_scale_2 = CCScaleTo:create(time_spaw * 4, tarScale * 1.1)
		local actionArray_spawn_2 = CCArray:create()
		actionArray_spawn_2:addObject(action_fadeout)
		actionArray_spawn_2:addObject(action_move_2)
		-- actionArray_spawn_2:addObject(action_scale_2)
		local action_spaw_2 = CCSpawn:create(actionArray_spawn_2)

		local actionArray = CCArray:create()
		actionArray:addObject(action_spaw_1)
		actionArray:addObject(action_spaw_2)
		actionArray:addObject(CCCallFunc:create(onAnimCompleted))

		sprite:runAction(CCSequence:create(actionArray))
		container:addChild(sprite)
	end

	local posOffset = {x=-3, y=3}
	return container, posOffset
end

function TileSand:buildMoveAnim(direction, callback)
	assert(direction)
	local framePattern = nil
	local posOffset = {x=0, y=0}
	local isReversed = false

	if direction.dr == -1 and direction.dc == 0 then -- up
		isReversed = true
		framePattern = "sand_move_down"
		posOffset = {x=-1, y=35}
	elseif direction.dr == 1 and direction.dc == 0 then -- down
		framePattern = "sand_move_down"
		posOffset = {x=-1, y=-35}
	elseif direction.dr == 0 and direction.dc == 1 then -- right
		framePattern = "sand_move_right"
		posOffset = {x=34, y=-1}
	elseif direction.dr == 0 and direction.dc == -1 then -- left
		isReversed = true
		framePattern = "sand_move_right"
		-- framePattern = "sand_move_left"
		posOffset = {x=-36.5, y=0}
	else
		if _G.isLocalDevelopMode then printx(0, "invalid direction for sand to move:", table.tostring(direction)) end
		return
	end

	-- if direction.dr == -1 and direction.dc == 0 then
	-- 	framePattern = "sand_move_up"
	-- 	posOffset = {x=-1, y=33}
	-- elseif direction.dr == 1 and direction.dc == 0 then
	-- 	framePattern = "sand_move_down"
	-- 	posOffset = {x=-1, y=-35}
	-- elseif direction.dr == 0 and direction.dc == 1 then
	-- 	framePattern = "sand_move_right"
	-- 	posOffset = {x=34, y=-1}
	-- elseif direction.dr == 0 and direction.dc == -1 then
	-- 	framePattern = "sand_move_left"
	-- 	posOffset = {x=-33, y=0.5}
	-- else
	-- 	if _G.isLocalDevelopMode then printx(0, "invalid direction for sand to move:", table.tostring(direction)) end
	-- 	return
	-- end
	local lastFrameIdx = 39
	local initFrame = isReversed and lastFrameIdx or 0
	local sprite = Sprite:createWithSpriteFrameName(string.format(framePattern.."_%04d.png", initFrame))
	local frames = SpriteUtil:buildFrames(framePattern.."_%04d.png", 0, lastFrameIdx, isReversed)
	local animate = SpriteUtil:buildAnimate(frames, 1/60)
	sprite:play(animate, 0, 1, callback)
	return sprite, posOffset
end
