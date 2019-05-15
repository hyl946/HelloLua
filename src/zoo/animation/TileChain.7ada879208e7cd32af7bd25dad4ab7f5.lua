TileChain = class(Sprite)

-- 横向冰柱的偏移位置（up）
local HPosOffset = table.const {
	{x = -7, y = 31},
	{x = 0.5, y = 35},
	{x = 0.5, y = 34.5},
	{x = 0, y = 35},
	{x = 0, y = 35},
}

-- 纵向冰柱的偏移位置（left）
local VPosOffset = table.const {
	{x = -44.5, y = -15.5},
	{x = -35, y = 0},
	{x = -34, y = -0.5},
	{x = -34.5, y = 0},
	{x = -35, y = 0},
}

function TileChain:createWithChains(chainsData, texture)
	assert(texture, "texture cannot be nil for batchnode")
	local container = TileChain.new(CCSprite:create())
	container:setTexture(texture)
	container.texture = texture
	container:initWithChainsData(chainsData)
	return container
end

function TileChain:initWithChainsData(chainsData)
	self.chainsData = {}
	self.chainsView = {}
	if chainsData then
		for _, data in pairs(chainsData) do
			self.chainsData[data.direction] = data.level
			if data.level > 0 then
				local chainView = TileChain:createChainSprite(data.level, data.direction)
				self.chainsView[data.direction] = chainView
				self:addChild(chainView)
			end
		end
	end
end

function TileChain:createChainSprite(level, dir)
	local sprite = nil
	if level == 1 then
		if dir == ChainDirConfig.kUp or dir == ChainDirConfig.kDown then -- 上下
			sprite = Sprite:createWithSpriteFrameName(string.format("chain_h_lv%d_0000.png",level))
		else -- 左右
			sprite = Sprite:createWithSpriteFrameName(string.format("chain_v_lv%d_0000.png",level))
		end
	else
		sprite = Sprite:createWithSpriteFrameName(string.format("chain_lv%d_0000.png",level))
		if dir == ChainDirConfig.kUp or dir == ChainDirConfig.kDown then -- 上下
			if level == 5 then -- level5的冰柱需要加上叶子
				local s2 = Sprite:createWithSpriteFrameName("chain_h_leaf_0000.png")
				s2:setPosition(ccp(47, 12))
				sprite.leaves = s2
				sprite:addChild(s2)
			end
		else -- 左右
			if level == 5 then
				local s2 = Sprite:createWithSpriteFrameName("chain_v_leaf_0000.png")
				s2:setPosition(ccp(61, 30))
				s2:setFlipX(true)
				s2:setFlipY(true)
				s2:setRotation(90)
				sprite.leaves = s2
				sprite:addChild(s2)
			end
			sprite:setFlipY(true)
			sprite:setRotation(90)
		end
	end
	-- set position
	local posX, posY = 0, 0
	-- level 1 横竖素材不同，需要单独处理
	if dir == ChainDirConfig.kUp or dir == ChainDirConfig.kDown then
		local posOffset = HPosOffset[level]
		posX = posOffset.x
		posY = posOffset.y
		if dir == ChainDirConfig.kDown then posY = posY - 70 end
	elseif dir == ChainDirConfig.kRight or dir == ChainDirConfig.kLeft then
		local posOffset = VPosOffset[level]
		posX = posOffset.x
		posY = posOffset.y
		if dir == ChainDirConfig.kRight then posX = posX + 70 end
	end
	sprite:setPosition(ccp(posX, posY))
	sprite.level = level
	sprite.direction = dir

	return sprite
end

local framesCount = {29, 15, 20, 15, 15} -- 各等级冰柱消除动画帧数（lv4,5另有藤蔓和落叶动画）
local breakAnimFPS = 30
local animRepeatTimes = 1

function TileChain:playBreakAnimation(breakLevels, onAnimComplete, isRemove)
	if not breakLevels and table.size(breakLevels) < 1 then
		return
	end

	local breakAnimCount = 0
	for dir, level in pairs(breakLevels) do
		if level > 0 then
			if isRemove then
				level = 1
				self.chainsData[dir] = 0
			else
				self.chainsData[dir] = level - 1
			end

			local chainView = self.chainsView[dir]
			if chainView and not chainView.isDisposed then
				chainView:removeFromParentAndCleanup(true)
				self.chainsView[dir] = nil
			end

			local function onAnimCompleteCallback()
				local oldView = self.chainsView[dir]
				if oldView and not oldView.isDisposed then
					oldView:removeFromParentAndCleanup(true)
					self.chainsView[dir] = nil
				end

				local newLevel = self.chainsData[dir] or 0
				if newLevel > 0 then
					local newView = self:createChainSprite(newLevel, dir)
					self.chainsView[dir] = newView
					self:addChild(newView)
				end
				breakAnimCount = breakAnimCount - 1
				if breakAnimCount < 1 then
					if onAnimComplete then onAnimComplete() end
				end
			end
			chainView = self:buildBreakAnimation(level, dir, onAnimCompleteCallback)
			self.chainsView[dir] = chainView
			self:addChild(chainView)
			breakAnimCount = breakAnimCount + 1
		end
	end
end

function TileChain:buildBreakAnimation(level, direction, onAnimComplete)
	local chainSprite = TileChain:createChainSprite(level, direction)
	chainSprite.animCount = 0
	local delay = 0

	local function onAnimationComplete()
		if chainSprite and not chainSprite.isDisposed then
			chainSprite.animCount = chainSprite.animCount - 1
			if chainSprite.animCount < 1 then
				chainSprite:removeFromParentAndCleanup(true)
				if onAnimComplete then onAnimComplete() end
			end
		end
	end

	if level == 1 then -- level1横竖素材不同
		local fmtStr = nil
		if direction == ChainDirConfig.kUp or direction == ChainDirConfig.kDown then -- 上下
			fmtStr = "chain_h_lv"..tostring(level).."_%04d.png"
		else -- 左右
			fmtStr = "chain_v_lv"..tostring(level).."_%04d.png"
		end
		local frames = SpriteUtil:buildFrames(fmtStr, 0, framesCount[level])
		local animate = SpriteUtil:buildAnimate(frames, 1/breakAnimFPS)
		chainSprite.animCount = chainSprite.animCount + 1
		chainSprite:play(animate, delay, animRepeatTimes, onAnimationComplete, false)
	else
		local fmtStr = "chain_lv"..tostring(level).."_%04d.png"
		local frames = SpriteUtil:buildFrames(fmtStr, 0, framesCount[level])
		local animate = SpriteUtil:buildAnimate(frames, 1/breakAnimFPS)
		chainSprite.animCount = chainSprite.animCount + 1
		chainSprite:play(animate, delay, animRepeatTimes, onAnimationComplete, false)

		if level == 4 then -- level4添加藤蔓破碎动画
			local vineSprite = nil
			local vineFrameName = nil
			if direction == ChainDirConfig.kUp or direction == ChainDirConfig.kDown then -- 上下
				vineSprite = Sprite:createWithSpriteFrameName("chain_h_vine_0000.png")
				local posX, posY = 34, 6
				vineSprite:setPosition(ccp(posX, posY))
				vineFrameName = "chain_h_vine_%04d.png"
			else -- 左右
				vineSprite = Sprite:createWithSpriteFrameName("chain_v_vine_0000.png")
				vineSprite:setRotation(-90)
				local posX, posY = 53, 15
				vineSprite:setPosition(ccp(posX, posY))
				vineFrameName = "chain_v_vine_%04d.png"
			end
			local vineFrames = SpriteUtil:buildFrames(vineFrameName, 0, 25)
			local vineAnimate = SpriteUtil:buildAnimate(vineFrames, 1/breakAnimFPS)
			chainSprite.animCount = chainSprite.animCount + 1
			vineSprite:play(vineAnimate, delay, animRepeatTimes, onAnimationComplete, true)
			chainSprite:addChild(vineSprite)
		elseif level == 5 then -- level5同时播放叶子掉落动画
			if chainSprite.leaves and not chainSprite.leaves.isDisposed then
				local leafFrameName = nil
				if direction == ChainDirConfig.kUp or direction == ChainDirConfig.kDown then -- 上下
					leafFrameName = "chain_h_leaf_%04d.png"
				else -- 左右
					leafFrameName = "chain_v_leaf_%04d.png"
				end
				local leafFrames = SpriteUtil:buildFrames(leafFrameName, 0, 30)
				local leafAnimate = SpriteUtil:buildAnimate(leafFrames, 1/breakAnimFPS)
				chainSprite.animCount = chainSprite.animCount + 1
				chainSprite.leaves:play(leafAnimate, delay, animRepeatTimes, onAnimationComplete, true)
			end
		end
	end
	return chainSprite
end
