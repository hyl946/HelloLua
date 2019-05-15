TileBlocker199 = class(CocosObject)

local shell1Config = {
	[1] = {x = 5,   y = 4, rotation_positive = 90,  rotation_negative = -270},
	[2] = {x = 5, 	y = 4, rotation_positive = 180, rotation_negative = -180},
	[3] = {x = 5, 	y = 4, rotation_positive = 270, rotation_negative = -90},
	[4] = {x = 5, 	y = 4, rotation_positive = 360, rotation_negative = -0},
}

function TileBlocker199:create(type, level, color, isActive)
	local node = TileBlocker199.new(CCNode:create())
	node.name = 'blocker199'
	node.type = type
	node.level = level
	node.color = color
	if node.color then node.colorIndex = AnimalTypeConfig.convertColorTypeToIndex(node.color) end
	node.isActive = isActive
	node:_init()
	return node
end

--破碎动画
function TileBlocker199:playGrowupAnimation(level)
	self.level = level
	self:_clearSpriteAndShell()
	if self.level == 0 then
		local function finishCallback()
			self.effect:removeFromParentAndCleanup(true)
		end
		self.effect = self:_initSkeletonAnimation('export/blocker199_growup'..self.level, 1, finishCallback)
		self.effect:setPosition(ccp(-2, 5))
		self.effectLayer:addChild(self.effect)

		self:_initGreyAnimation()
	else
		local function finishCallback( ... )
			self:_clearSpriteAndShell()
			self:_init()
		end
		self.sprite = self:_initSkeletonAnimation('export/blocker199_growup'..self.level, 1, finishCallback)
		self.sprite:setPosition(ccp(-2, 5))
		self.spriteLayer:addChild(self.sprite)
	end
end

--变色动画
function TileBlocker199:playReinitAnimation(type, color, isRotation)
	local lastType = self.type or 1
	self.type = type or 1
	self.color = color
	self.colorIndex = AnimalTypeConfig.convertColorTypeToIndex(self.color) or 1
	self:_clearSpriteAndShell()

	local function finishCallback()
		self:_clearSpriteAndShell()
		self:_initIdleAnimation()
	end

	if isRotation then
		self.sprite = self:_initAnimation('blocker199_discolor_'..self.colorIndex, 17, 1, 36)
		self.shell = self:rotateShell(lastType, self.type, finishCallback)
		local x = shell1Config[self.type].x or 0
		local y = shell1Config[self.type].y or 0

		self.shell:setPosition(ccp(x, y))
	else
		self.sprite = self:_initAnimation('blocker199_discolor_'..self.colorIndex, 17, 1, 36, finishCallback)
		self.shell = self:_initShell()
	end

	self.spriteLayer:addChild(self.sprite)
	self.shellLayer:addChild(self.shell)
end

function TileBlocker199:playExplodeAnimation()
	self:_clearSpriteAndShell()
	self.sprite = self:_initAnimation('blocker199_explode_'..self.colorIndex, 29 , 1, 36)
	self.spriteLayer:addChild(self.sprite)

	local function spriteCallback(index)
		local part = nil
		if index == 1 then
			local x = -shell1Config[self.type].x or 0
			local y = shell1Config[self.type].y or 0

			part = Sprite:createWithSpriteFrameName("blocker199_shell1")
			part:setPosition(ccp(x, y))
			part:setRotation(self.type * 90)
			part:setScale(0.9)
		else
			part = Sprite:createWithSpriteFrameName("blocker199_shell2")
			part:setPosition(ccp(-3.4, 4.95))
		end
		return part
	end

	local data = {
		[1]={{startFrame=0,duration=4,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=4,duration=4,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.79,scaleY=0.79,rotation=0.00,opacity=255.00},
		{startFrame=8,duration=12,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=1.01,scaleY=1.01,rotation=0.00,opacity=255.00},
		{startFrame=20,duration=4,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=1.01,scaleY=1.01,rotation=0.00,opacity=255.00},
		{startFrame=24,duration=4,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.83,scaleY=0.83,rotation=0.00,opacity=255.00},
		{startFrame=28,duration=3,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=31,duration=1,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00}},
		[2]={{startFrame=0,duration=4,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00},
		{startFrame=4,duration=4,x=3.25,y=4.70,scaleX=0.88,scaleY=0.88,rotation=0.00,opacity=255.00},
		{startFrame=8,duration=12,x=3.55,y=5.20,scaleX=1.12,scaleY=1.12,rotation=0.00,opacity=255.00},
		{startFrame=20,duration=4,x=3.55,y=5.20,scaleX=1.12,scaleY=1.12,rotation=0.00,opacity=255.00},
		{startFrame=24,duration=4,x=3.25,y=4.80,scaleX=0.92,scaleY=0.92,rotation=0.00,opacity=255.00},
		{startFrame=28,duration=3,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=-5.22,opacity=255.00},
		{startFrame=31,duration=1,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00}},
	}

	self.shell = Sprite:createEmpty()
	self.shellLayer:addChild(self.shell)
	local actions = self:_initScriptActions(self.shell, data, 36, spriteCallback)
	self.shellLayer:runAction(CCSequence:createWithTwoActions(CCSpawn:create(actions), CCCallFunc:create(function()
		self:_clearSpriteAndShell()
		self:_initGreyAnimation()
	end)))
end

function TileBlocker199:playEffectAnimation(len)
	--if _G.isLocalDevelopMode then printx(0, 'TileBlocker199:playEffectAnimation', len) end
	local sprite = self['_initEffect'..len](self)
	return sprite
end

function TileBlocker199:_init()
	if self.spriteLayer == nil then
		self.spriteLayer = Sprite:createEmpty()
		self:addChild(self.spriteLayer)
	end
	if self.shellLayer == nil then
		self.shellLayer = Sprite:createEmpty()
		self:addChild(self.shellLayer)
	end
	if self.effectLayer == nil then 
		self.effectLayer = Sprite:createEmpty()
		self:addChild(self.effectLayer)
	end

	self:_clearSpriteAndShell()
	if self.level == 0 then
		if self.colorIndex > 0 then
			self:_initIdleAnimation()
		else
			self:_initGreyAnimation()
		end
	else
		self.sprite = self:_initSkeletonAnimation('export/blocker199_stable'..self.level)
		self.spriteLayer:addChild(self.sprite)
		self.sprite:setPosition(ccp(-2, 5))
	end
end

function TileBlocker199:_initGreyAnimation()
	self.sprite = self:_initAnimation('blocker199_grey', 30, 0, 24)
	self.sprite:setPosition(ccp(0, -2))
	self.spriteLayer:addChild(self.sprite)
	self.shell = self:_initShell()
	self.shellLayer:addChild(self.shell)
end

function TileBlocker199:_initIdleAnimation()
	self.sprite = Sprite:createWithSpriteFrameName('blocker199_idle1_' .. self.colorIndex .. '_0000')
	local frames, animate

	frames = SpriteUtil:buildFrames('blocker199_idle1_' .. self.colorIndex .. '_%04d', 0, 35)
	table.union(frames, SpriteUtil:buildFrames('blocker199_idle2_' .. self.colorIndex .. '_%04d', 0, 35))
	animate = SpriteUtil:buildAnimate(frames, 1/24)
	self.sprite:play(animate, 0, playCount)
	self.sprite:setPosition(ccp(0, -1))
	self.spriteLayer:addChild(self.sprite)

	self.shell = self['_initShellStable'..self.type](self)

	local x = -shell1Config[self.type].x
	local y = shell1Config[self.type].y

	self.shell:setPosition(ccp(x, y))
	self.shellLayer:addChild(self.shell)
end

function TileBlocker199:_initAnimation(prefix, frame, playCount, framerate, callback)
	local resName = prefix .. '_0000'
	local sp = Sprite:createWithSpriteFrameName(resName)
	local frames, animate
	local aniName = prefix .. '_%04d'
	if framerate == nil then framerate = 24 end
	if not playCount then playCount = 0 end

	frames = SpriteUtil:buildFrames(aniName, 0, frame)
	animate = SpriteUtil:buildAnimate(frames, 1 / framerate)
	sp:play(animate, 0, playCount, function () if callback then callback() end end)

	return sp
end

function TileBlocker199:_initSkeletonAnimation(name, count, callback)
	if count == nil then count = 0 end
	local function finishCallback()
		if callback then
			callback()
		end
	end
	FrameLoader:loadArmature("skeleton/blocker199")
	local sprite = ArmatureNode:create(name)
	sprite:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
	sprite:playByIndex(0, count)
	sprite:update(0.001)
	return sprite
end

function TileBlocker199:_initShell()
	local shell = Sprite:createEmpty()
	local shell1 = Sprite:createWithSpriteFrameName('blocker199_shell1')
	local x, y

	local x = shell1Config[self.type].x or 0
	local y = shell1Config[self.type].y or 0

	shell1:setPosition(ccp(0, 0))
	shell1:setRotation(self.type * 90)
	shell1:setScale(0.9)
	shell:addChild(shell1)
	local shell2 = Sprite:createWithSpriteFrameName('blocker199_shell2')
	shell:addChild(shell2)
	return shell
end

function TileBlocker199:_clearSpriteAndShell()
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	if self.shell then self.shell:removeFromParentAndCleanup(true) end
end

function TileBlocker199:removeWholeView()
	self:_clearSpriteAndShell()
end

--------------------------------------------------
-- shell stable
--------------------------------------------------
function TileBlocker199:_initShellStable1()
	local data = {
		[1]={
		{startFrame=0,duration=7,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=255.00},
		{startFrame=7,duration=9,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=16,duration=8,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=24,duration=1,x=shell1Config[1].x,y=shell1Config[1].y,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=255.00}},

		[2]={
		{startFrame=0,duration=11,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00},
		{startFrame=11,duration=13,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=6.43,opacity=255.00},
		{startFrame=24,duration=1,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00}},

		[3]={
		{startFrame=0,duration=4,x=31.50,y=5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=10.20},
		{startFrame=4,duration=11,x=33.95,y=5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=255.00},
		{startFrame=15,duration=5,x=40.75,y=5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=255.00},
		{startFrame=20,duration=1,x=43.20,y=5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=10.20}},

		[4]={
		{startFrame=0,duration=4,x=6.5,y=-21.70,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=10.20},
		{startFrame=4,duration=11,x=6.5,y=-24.15,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=15,duration=5,x=6.5,y=-30.95,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=20,duration=1,x=6.5,y=-33.40,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=10.20}},
	}
	return self:_initShellStable(data)
end

function TileBlocker199:_initShellStable2()
	local data = {
		[1]={{startFrame=0,duration=7,x=shell1Config[2].x,y=shell1Config[2].y,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=255.00},
		{startFrame=7,duration=9,x=shell1Config[2].x,y=shell1Config[2].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=16,duration=8,x=shell1Config[2].x,y=shell1Config[2].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=24,duration=1,x=shell1Config[2].x,y=shell1Config[2].y,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=255.00}},

		[2]={
		{startFrame=0,duration=11,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00},
		{startFrame=11,duration=13,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=6.43,opacity=255.00},
		{startFrame=24,duration=1,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00}},

		[3]={
		{startFrame=0,duration=4,x=3.5,y=31.95,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=10.20},
		{startFrame=4,duration=11,x=3.5,y=34.40,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=255.00},
		{startFrame=15,duration=5,x=3.5,y=41.20,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=255.00},
		{startFrame=20,duration=1,x=3.5,y=43.65,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=10.20}},

		[4]={
		{startFrame=0,duration=4,x=30.95,y=5.5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=10.20},
		{startFrame=4,duration=11,x=33.40,y=5.5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=255.00},
		{startFrame=15,duration=5,x=40.20,y=5.5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=255.00},
		{startFrame=20,duration=1,x=42.65,y=5.5,scaleX=0.90,scaleY=0.90,rotation=90.00,opacity=10.20}},
	}
	return self:_initShellStable(data)
end

function TileBlocker199:_initShellStable3()
	local data = {
		[1]={
		{startFrame=0,duration=7,x=shell1Config[3].x,y=shell1Config[3].y,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=255.00},
		{startFrame=7,duration=9,x=shell1Config[3].x,y=shell1Config[3].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=16,duration=8,x=shell1Config[3].x,y=shell1Config[3].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=24,duration=1,x=shell1Config[3].x,y=shell1Config[3].y,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=255.00}},

		[2]={
		{startFrame=0,duration=11,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00},
		{startFrame=11,duration=13,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=6.43,opacity=255.00},
		{startFrame=24,duration=1,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00}},

		[3]={
		{startFrame=0,duration=4,x=-22.35,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=10.20},
		{startFrame=4,duration=11,x=-24.80,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=255.00},
		{startFrame=15,duration=5,x=-31.60,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=255.00},
		{startFrame=20,duration=1,x=-34.05,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=10.20}},

		[4]={
		{startFrame=0,duration=4,x=3,y=32.35,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=10.20},
		{startFrame=4,duration=11,x=3,y=34.80,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=255.00},
		{startFrame=15,duration=5,x=3,y=41.60,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=255.00},
		{startFrame=20,duration=1,x=3,y=44.05,scaleX=0.90,scaleY=0.90,rotation=180.00,opacity=10.20}},
	}
	return self:_initShellStable(data)
end

function TileBlocker199:_initShellStable4()
	local data = {
		[1]={
		{startFrame=0,duration=7,x=shell1Config[4].x,y=shell1Config[4].y,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=7,duration=9,x=shell1Config[4].x,y=shell1Config[4].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=16,duration=8,x=shell1Config[4].x,y=shell1Config[4].y,scaleX=0.90,scaleY=0.90,rotation=NaN,opacity=255.00},
		{startFrame=24,duration=1,x=shell1Config[4].x,y=shell1Config[4].y,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00}},

		[2]={
		{startFrame=0,duration=11,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00},
		{startFrame=11,duration=13,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=6.43,opacity=255.00},
		{startFrame=24,duration=1,x=3.40,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00,opacity=255.00}},

		[3]={
		{startFrame=0,duration=4,x=7.05,y=-21.25,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=10.20},
		{startFrame=4,duration=11,x=7.05,y=-23.70,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=15,duration=5,x=7.05,y=-30.50,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=255.00},
		{startFrame=20,duration=1,x=7.05,y=-32.95,scaleX=0.90,scaleY=0.90,rotation=0.00,opacity=10.20}},

		[4]={
		{startFrame=0,duration=4,x=-22.35,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=10.20},
		{startFrame=4,duration=11,x=-24.80,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=255.00},
		{startFrame=15,duration=5,x=-31.60,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=255.00},
		{startFrame=20,duration=1,x=-34.05,y=2.5,scaleX=0.90,scaleY=0.90,rotation=-90.00,opacity=10.20}},
	}
	return self:_initShellStable(data)
end

function TileBlocker199:_initShellStable(data, sprite)
	local function spriteCallback(index)
		local part = nil
		if index == 1 then
			part = Sprite:createWithSpriteFrameName("blocker199_shell1")
		elseif index == 2 then
			part = Sprite:createWithSpriteFrameName("blocker199_shell2")
		else
			part = Sprite:createWithSpriteFrameName("blocker199_shell3")
		end
		return part
	end

	if sprite == nil then 
		sprite = Sprite:createEmpty()
	end
	local actions = self:_initScriptActions(sprite, data, 24, spriteCallback)
	sprite:runAction(CCSequence:createWithTwoActions(CCSpawn:create(actions), CCCallFunc:create(function()
		self:_initShellStable(data, sprite)
	end)))
	return sprite
end

--------------------------------------------------
-- shell rotation
--------------------------------------------------
function TileBlocker199:rotateShell(from, to, callback)
	local rotation_start
	if to > from then
		rotation_start = shell1Config[from].rotation_positive
	else
		rotation_start = shell1Config[from].rotation_negative
	end
	local rotation_end = shell1Config[to].rotation_positive
	local data = {
		[1]={
		{rotateBy = true, startFrame=0,duration=8,x=-shell1Config[to].x,y=shell1Config[to].y,scaleX=0.90,scaleY=0.90,rotation=rotation_start},
		{rotateBy = true, startFrame=8,duration=4,x=-shell1Config[to].x,y=shell1Config[to].y,scaleX=0.90,scaleY=0.90,rotation=rotation_end - rotation_start + 10},
		{rotateBy = true, startFrame=12,duration=3,x=-shell1Config[to].x,y=shell1Config[to].y,scaleX=0.90,scaleY=0.90,rotation=-10},
		{rotateBy = true, startFrame=15,duration=4,x=-shell1Config[to].x,y=shell1Config[to].y,scaleX=0.90,scaleY=0.90,rotation=0},
		{rotateBy = true, startFrame=19,duration=1,x=-shell1Config[to].x,y=shell1Config[to].y,scaleX=0.90,scaleY=0.90,rotation=0}},
		
		[2]={
		{startFrame=0,duration=8,x=-3.40*2,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00},
		{startFrame=8,duration=4,x=-3.40*2,y=4.95,scaleX=1.00,scaleY=1.00,rotation=10.99},
		{startFrame=12,duration=3,x=-3.40*2,y=4.95,scaleX=1.00,scaleY=1.00,rotation=-4.49},
		{startFrame=15,duration=3,x=-3.40*2,y=4.95,scaleX=1.00,scaleY=1.00,rotation=6.19},
		{startFrame=18,duration=1,x=-3.40*2,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00},
		{startFrame=19,duration=1,x=-3.40*2,y=4.95,scaleX=1.00,scaleY=1.00,rotation=0.00}},
	}

	return self:_initShellRotation(data, callback)
end

function TileBlocker199:_initShellRotation(data, callback)
	local function spriteCallback(index)
		local part = nil
		if index == 1 then
			part = Sprite:createWithSpriteFrameName("blocker199_shell1")
		else
			part = Sprite:createWithSpriteFrameName("blocker199_shell2")
		end
		return part
	end
 
	local sprite = Sprite:createEmpty()
	local actions = self:_initScriptActions(sprite, data, 36, spriteCallback)
	sprite:runAction(CCSequence:createWithTwoActions(CCSpawn:create(actions), CCCallFunc:create(function()
		if callback then callback() end
	end)))
	return sprite
end

--------------------------------------------------
-- explode effect
--------------------------------------------------
function TileBlocker199:_initEffect1()
	local data = {
		[1]={{startFrame=0,duration=4,x=1.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=8,x=1.75,y=-57.30,scaleX=0.92,scaleY=1.10},
		{startFrame=12,duration=1,x=2.25,y=-83.50,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=8,x=-8.25,y=-38.80,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-7.05,y=-113.40,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=8,x=-20.25,y=-31.20,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-19.45,y=-107.00,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=7,x=4.95,y=-28.20,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=4.75,y=-53.85,scaleX=0.58,scaleY=0.58}},
		[5]={{startFrame=6,duration=7,x=0.05,y=-29.65,scaleX=0.51,scaleY=0.51},
		{startFrame=13,duration=1,x=1.25,y=-40.95,scaleX=0.37,scaleY=0.37}},
		[6]={{startFrame=2,duration=8,x=-16.60,y=-34.45,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-16.65,y=-88.20,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=4.95,y=-31.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-3.55,y=-66.65,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-14.95,y=-31.80,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-32.70,y=-92.20,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-4.70,y=-29.00,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=19.10,y=-94.45,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-13.60,y=-38.00,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-13.20,y=-114.50,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-14.90,y=-35.15,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-0.70,y=-115.85,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-21.05,y=-38.10,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-26.95,y=-96.20,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-1.50,y=-41.20,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-18.15,y=-91.80,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-14.95,y=-30.40,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-13.15,y=-55.70,scaleX=0.53,scaleY=0.53}},
		[15]={{startFrame=9,duration=1,x=-9.80,y=-94.30,scaleX=0.40,scaleY=0.40}},
		[16]={{startFrame=9,duration=1,x=4.20,y=-105.50,scaleX=0.48,scaleY=0.48}},
		[17]={{startFrame=9,duration=1,x=-3.55,y=-50.30,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=12,duration=1,x=22.45,y=-103.20,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=15.00,y=-65.35,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=-23.15,y=-56.50,scaleX=0.36,scaleY=0.36}},
		[21]={{startFrame=12,duration=1,x=3.45,y=-89.45,scaleX=0.71,scaleY=0.71}},
		[22]={{startFrame=11,duration=1,x=-18.05,y=-99.05,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=13,duration=1,x=-5.60,y=-53.40,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=13,duration=1,x=3.20,y=-82.45,scaleX=1.00,scaleY=1.00}},
		[25]={{startFrame=14,duration=1,x=-17.45,y=-66.15,scaleX=0.61,scaleY=0.61}},
		[26]={{startFrame=14,duration=1,x=19.50,y=-54.75,scaleX=0.36,scaleY=0.36}},
		[27]={{startFrame=14,duration=1,x=8.75,y=-103.85,scaleX=0.36,scaleY=0.36}},
	}
	return self:_initEffect(data, 15)
end

function TileBlocker199:_initEffect2()
	local data = {
		[1]={{startFrame=0,duration=4,x=1.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=1.75,y=-57.25,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=2.10,y=-140.05,scaleX=0.91,scaleY=1.00},
		{startFrame=12,duration=1,x=2.25,y=-164.05,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=8,x=-8.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-7.05,y=-193.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=8,x=-20.25,y=-31.15,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-19.45,y=-183.65,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=7,x=4.95,y=-28.15,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=7.15,y=-123.00,scaleX=0.70,scaleY=0.70}},
		[5]={{startFrame=6,duration=7,x=0.05,y=-29.60,scaleX=0.51,scaleY=0.51},
		{startFrame=13,duration=1,x=-2.45,y=-83.20,scaleX=0.69,scaleY=0.69}},
		[6]={{startFrame=2,duration=8,x=-16.60,y=-34.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-16.65,y=-168.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=4.95,y=-31.40,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-3.55,y=-123.80,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-14.95,y=-31.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-32.70,y=-172.75,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-4.70,y=-28.95,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-9.25,y=-81.05,scaleX=0.64,scaleY=0.64}},
		[10]={{startFrame=5,duration=7,x=-13.60,y=-37.95,scaleX=1.10,scaleY=1.10},
		{startFrame=12,duration=1,x=-17.45,y=-89.05,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-14.90,y=-35.10,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-7.15,y=-103.05,scaleX=0.96,scaleY=0.96}},
		[12]={{startFrame=5,duration=8,x=-21.05,y=-38.05,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-26.95,y=-176.75,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-1.50,y=-41.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-18.15,y=-172.35,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-14.95,y=-30.35,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-13.15,y=-136.25,scaleX=0.53,scaleY=0.53}},
		[15]={{startFrame=10,duration=1,x=-9.80,y=-174.85,scaleX=0.40,scaleY=0.40}},
		[16]={{startFrame=10,duration=1,x=4.20,y=-186.05,scaleX=0.48,scaleY=0.48}},
		[17]={{startFrame=10,duration=1,x=-3.55,y=-130.85,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=12,duration=1,x=11.50,y=-51.05,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=15.00,y=-145.90,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=-4.25,y=-104.35,scaleX=0.36,scaleY=0.36}},
		[21]={{startFrame=12,duration=1,x=3.45,y=-170.00,scaleX=0.71,scaleY=0.71}},
		[22]={{startFrame=11,duration=1,x=-18.05,y=-179.60,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=13,duration=1,x=-4.30,y=-97.40,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=13,duration=1,x=3.20,y=-163.00,scaleX=1.00,scaleY=1.00}},
		[25]={{startFrame=13,duration=1,x=16.20,y=-128.90,scaleX=0.54,scaleY=0.54}},
		[26]={{startFrame=13,duration=1,x=-8.15,y=-64.90,scaleX=0.37,scaleY=0.37}},
		[27]={{startFrame=13,duration=1,x=14.75,y=-46.90,scaleX=0.37,scaleY=0.37}},
		[28]={{startFrame=14,duration=1,x=-17.45,y=-146.70,scaleX=0.61,scaleY=0.61}},
		[29]={{startFrame=14,duration=1,x=19.50,y=-135.30,scaleX=0.36,scaleY=0.36}},
		[30]={{startFrame=14,duration=1,x=8.75,y=-184.40,scaleX=0.36,scaleY=0.36}},
		[31]={{startFrame=14,duration=1,x=1.55,y=-94.30,scaleX=0.36,scaleY=0.36}},
	}
	return self:_initEffect(data, 15)
end

function TileBlocker199:_initEffect3()
	local data = {
		[1]={{startFrame=0,duration=4,x=0.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=0.75,y=-172.00,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=1.25,y=-213.95,scaleX=0.90,scaleY=1.21},
		{startFrame=12,duration=1,x=1.25,y=-237.55,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=3,x=-9.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-8.55,y=-185.70,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-8.05,y=-222.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=3,x=-21.25,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-20.80,y=-171.45,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-20.45,y=-213.55,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=8,x=3.95,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=-1.55,y=-163.15,scaleX=0.80,scaleY=0.80}},
		[5]={{startFrame=3,duration=8,x=-9.30,y=-52.95,scaleX=1.24,scaleY=1.24},
		{startFrame=11,duration=1,x=-9.35,y=-277.65,scaleX=1.24,scaleY=1.24}},
		[6]={{startFrame=2,duration=8,x=-17.60,y=-37.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-27.65,y=-194.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=3.95,y=-74.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-4.55,y=-215.70,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-15.95,y=-58.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-17.25,y=-158.70,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-5.70,y=-71.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-0.40,y=-255.00,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-14.60,y=-53.95,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-14.95,y=-139.00,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-1.90,y=-42.60,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-1.70,y=-119.55,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-5.15,y=-164.50,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-18.90,y=-204.50,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-2.50,y=-46.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-2.50,y=-89.95,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-15.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-15.90,y=-64.20,scaleX=0.80,scaleY=0.80}},
		[15]={{startFrame=9,duration=1,x=-10.80,y=-150.15,scaleX=0.40,scaleY=0.40}},
		[16]={{startFrame=9,duration=1,x=3.20,y=-161.35,scaleX=0.48,scaleY=0.48}},
		[17]={{startFrame=9,duration=1,x=-4.55,y=-106.15,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=12,duration=1,x=7.10,y=-83.40,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=8.55,y=-168.60,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=-2.65,y=-139.80,scaleX=0.36,scaleY=0.36}},
		[21]={{startFrame=12,duration=1,x=9.10,y=-218.30,scaleX=0.71,scaleY=0.71}},
		[22]={{startFrame=11,duration=1,x=-2.65,y=-157.90,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=13,duration=1,x=-4.55,y=-67.60,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=13,duration=1,x=2.20,y=-241.00,scaleX=1.00,scaleY=1.00}},
		[25]={{startFrame=14,duration=1,x=1.80,y=-153.90,scaleX=0.61,scaleY=0.61}},
		[26]={{startFrame=14,duration=1,x=2.90,y=-224.40,scaleX=0.36,scaleY=0.36}},
		[27]={{startFrame=14,duration=1,x=0.20,y=-71.25,scaleX=0.36,scaleY=0.36}},	
	}
	return self:_initEffect(data, 15)
end

function TileBlocker199:_initEffect4()
	local data = {
		[1]={{startFrame=0,duration=4,x=0.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=0.75,y=-172.00,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=1.25,y=-290.95,scaleX=0.90,scaleY=1.21},
		{startFrame=12,duration=1,x=1.25,y=-313.55,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=3,x=-9.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-8.55,y=-185.70,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-8.05,y=-299.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=3,x=-21.25,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-20.80,y=-171.45,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-20.45,y=-290.55,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=3,x=3.95,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=8,duration=5,x=4.50,y=-167.80,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=4.95,y=-278.40,scaleX=0.80,scaleY=0.80}},
		[5]={{startFrame=3,duration=4,x=-9.30,y=-52.95,scaleX=1.24,scaleY=1.24},
		{startFrame=7,duration=4,x=-9.30,y=-165.25,scaleX=1.24,scaleY=1.24},
		{startFrame=11,duration=1,x=-9.35,y=-277.65,scaleX=1.24,scaleY=1.24}},
		[6]={{startFrame=2,duration=8,x=-17.60,y=-37.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-17.65,y=-248.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=3.95,y=-74.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-4.55,y=-215.70,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-15.95,y=-58.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-14.20,y=-268.75,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-5.70,y=-71.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-0.40,y=-255.00,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-14.60,y=-53.95,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-14.95,y=-169.00,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-1.90,y=-42.60,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-1.70,y=-126.55,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-5.15,y=-164.50,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-4.90,y=-235.50,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-2.50,y=-46.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-2.50,y=-89.95,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-15.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-15.90,y=-71.20,scaleX=0.80,scaleY=0.80}},
		[15]={{startFrame=9,duration=1,x=-10.80,y=-281.15,scaleX=0.40,scaleY=0.40}},
		[16]={{startFrame=9,duration=1,x=3.20,y=-292.35,scaleX=0.48,scaleY=0.48}},
		[17]={{startFrame=9,duration=1,x=-4.55,y=-237.15,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=12,duration=1,x=7.10,y=-90.40,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=8.55,y=-226.60,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=-2.65,y=-197.80,scaleX=0.36,scaleY=0.36}},
		[21]={{startFrame=12,duration=1,x=9.10,y=-276.30,scaleX=0.71,scaleY=0.71}},
		[22]={{startFrame=11,duration=1,x=-2.65,y=-157.90,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=13,duration=1,x=-4.55,y=-56.35,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=13,duration=1,x=2.20,y=-321.00,scaleX=1.00,scaleY=1.00}},
		[25]={{startFrame=14,duration=1,x=12.80,y=-205.90,scaleX=0.61,scaleY=0.61}},
		[26]={{startFrame=14,duration=1,x=13.90,y=-276.40,scaleX=0.36,scaleY=0.36}},
		[27]={{startFrame=14,duration=1,x=11.20,y=-123.25,scaleX=0.36,scaleY=0.36}},
	}
	return self:_initEffect(data, 15)
end

function TileBlocker199:_initEffect5()
	local data = {
		[1]={{startFrame=0,duration=4,x=0.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=0.75,y=-172.00,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=1.25,y=-362.95,scaleX=0.90,scaleY=1.21},
		{startFrame=12,duration=1,x=1.25,y=-385.55,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=3,x=-9.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-8.55,y=-185.70,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-8.05,y=-371.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=3,x=-21.25,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-20.80,y=-171.45,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-20.45,y=-362.55,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=3,x=3.95,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=8,duration=5,x=4.50,y=-239.80,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=4.95,y=-350.40,scaleX=0.80,scaleY=0.80}},
		[5]={{startFrame=3,duration=4,x=-9.30,y=-52.95,scaleX=1.24,scaleY=1.24},
		{startFrame=7,duration=4,x=-9.30,y=-165.25,scaleX=1.24,scaleY=1.24},
		{startFrame=11,duration=1,x=-9.35,y=-349.65,scaleX=1.24,scaleY=1.24}},
		[6]={{startFrame=2,duration=8,x=-17.60,y=-37.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-17.65,y=-320.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=3.95,y=-74.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-4.55,y=-287.70,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-15.95,y=-58.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-14.20,y=-340.75,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-5.70,y=-71.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-0.40,y=-327.00,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-14.60,y=-53.95,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-14.95,y=-241.00,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-1.90,y=-42.60,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-1.70,y=-198.55,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-5.15,y=-164.50,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-4.90,y=-307.50,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-2.50,y=-46.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-2.50,y=-161.95,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-15.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-15.90,y=-143.20,scaleX=0.80,scaleY=0.80}},
		[15]={{startFrame=9,duration=1,x=-10.80,y=-353.15,scaleX=0.40,scaleY=0.40}},
		[16]={{startFrame=9,duration=1,x=3.20,y=-364.35,scaleX=0.48,scaleY=0.48}},
		[17]={{startFrame=9,duration=1,x=-4.55,y=-309.15,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=12,duration=1,x=7.10,y=-162.40,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=8.55,y=-298.60,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=-2.65,y=-269.80,scaleX=0.36,scaleY=0.36}},
		[21]={{startFrame=12,duration=1,x=9.10,y=-348.30,scaleX=0.71,scaleY=0.71}},
		[22]={{startFrame=11,duration=1,x=-2.65,y=-229.90,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=13,duration=1,x=-4.55,y=-128.35,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=13,duration=1,x=2.20,y=-393.00,scaleX=1.00,scaleY=1.00}},
		[25]={{startFrame=14,duration=1,x=12.80,y=-277.90,scaleX=0.61,scaleY=0.61}},
		[26]={{startFrame=14,duration=1,x=13.90,y=-348.40,scaleX=0.36,scaleY=0.36}},
		[27]={{startFrame=14,duration=1,x=11.20,y=-195.25,scaleX=0.36,scaleY=0.36}},
	}
	return self:_initEffect(data, 15)
end

function TileBlocker199:_initEffect6()
	local data = {
		[1]={{startFrame=0,duration=4,x=1.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=1.75,y=-172.00,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=2.25,y=-446.95,scaleX=0.90,scaleY=1.21},
		{startFrame=12,duration=1,x=2.25,y=-469.55,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=3,x=-8.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-7.55,y=-185.70,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-7.05,y=-455.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=3,x=-20.25,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-19.80,y=-171.45,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-19.45,y=-446.55,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=3,x=4.95,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=8,duration=5,x=5.50,y=-239.80,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=5.95,y=-434.40,scaleX=0.80,scaleY=0.80}},
		[5]={{startFrame=3,duration=4,x=-8.30,y=-52.95,scaleX=1.24,scaleY=1.24},
		{startFrame=7,duration=4,x=-8.30,y=-165.25,scaleX=1.24,scaleY=1.24},
		{startFrame=11,duration=1,x=-8.35,y=-433.65,scaleX=1.24,scaleY=1.24}},
		[6]={{startFrame=2,duration=8,x=-16.60,y=-37.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-16.65,y=-404.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=4.95,y=-74.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-3.55,y=-371.70,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-14.95,y=-58.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-13.20,y=-424.75,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-4.70,y=-71.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=0.60,y=-411.00,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-13.60,y=-53.95,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-13.95,y=-325.00,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-0.90,y=-42.60,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-0.70,y=-282.55,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-4.15,y=-164.50,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-3.90,y=-391.50,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-1.50,y=-46.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-1.50,y=-245.95,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-14.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-14.90,y=-196.20,scaleX=0.80,scaleY=0.80}},
		[15]={{startFrame=9,duration=1,x=-9.80,y=-437.15,scaleX=0.40,scaleY=0.40}},
		[16]={{startFrame=9,duration=1,x=4.20,y=-448.35,scaleX=0.48,scaleY=0.48}},
		[17]={{startFrame=9,duration=1,x=-3.55,y=-393.15,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=12,duration=1,x=8.10,y=-246.40,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=9.55,y=-382.60,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=-1.65,y=-353.80,scaleX=0.36,scaleY=0.36}},
		[21]={{startFrame=12,duration=1,x=10.10,y=-432.30,scaleX=0.71,scaleY=0.71}},
		[22]={{startFrame=11,duration=1,x=-1.65,y=-313.90,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=13,duration=1,x=-3.55,y=-212.35,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=13,duration=1,x=3.20,y=-477.00,scaleX=1.00,scaleY=1.00}},
		[25]={{startFrame=14,duration=1,x=13.80,y=-361.90,scaleX=0.61,scaleY=0.61}},
		[26]={{startFrame=14,duration=1,x=14.90,y=-432.40,scaleX=0.36,scaleY=0.36}},
		[27]={{startFrame=14,duration=1,x=12.20,y=-279.25,scaleX=0.36,scaleY=0.36}},
	}
	return self:_initEffect(data, 15)
end

function TileBlocker199:_initEffect7()
	local data = {
		[1]={{startFrame=0,duration=4,x=0.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=0.75,y=-172.00,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=1.25,y=-525.95,scaleX=0.90,scaleY=1.21},
		{startFrame=12,duration=1,x=1.25,y=-548.55,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=3,x=-9.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-8.55,y=-185.70,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-8.05,y=-534.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=3,x=-21.25,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-20.80,y=-171.45,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-20.45,y=-525.55,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=3,x=3.95,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=8,duration=5,x=4.50,y=-239.80,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=4.95,y=-513.40,scaleX=0.80,scaleY=0.80}},
		[5]={{startFrame=3,duration=4,x=-9.30,y=-52.95,scaleX=1.24,scaleY=1.24},
		{startFrame=7,duration=4,x=-9.30,y=-165.25,scaleX=1.24,scaleY=1.24},
		{startFrame=11,duration=1,x=-9.35,y=-512.65,scaleX=1.24,scaleY=1.24}},
		[6]={{startFrame=2,duration=8,x=-17.60,y=-37.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-17.65,y=-483.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=3.95,y=-74.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-4.55,y=-450.70,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-15.95,y=-58.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-14.20,y=-503.75,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-5.70,y=-71.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-0.40,y=-490.00,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-14.60,y=-53.95,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-14.95,y=-404.00,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-1.90,y=-42.60,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-1.70,y=-361.55,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-5.15,y=-164.50,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-4.90,y=-470.50,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-2.50,y=-46.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-2.50,y=-324.95,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-15.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-15.90,y=-275.20,scaleX=0.80,scaleY=0.80}},
		[15]={{startFrame=6,duration=5,x=-15.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=4.10,y=-153.20,scaleX=0.80,scaleY=0.80}},
		[16]={{startFrame=9,duration=1,x=-10.80,y=-516.15,scaleX=0.40,scaleY=0.40}},
		[17]={{startFrame=9,duration=1,x=3.20,y=-527.35,scaleX=0.48,scaleY=0.48}},
		[18]={{startFrame=9,duration=1,x=-4.55,y=-472.15,scaleX=0.48,scaleY=0.48}},
		[19]={{startFrame=12,duration=1,x=7.10,y=-325.40,scaleX=0.48,scaleY=0.48}},
		[20]={{startFrame=12,duration=1,x=8.55,y=-461.60,scaleX=0.48,scaleY=0.48}},
		[21]={{startFrame=12,duration=1,x=-2.65,y=-432.80,scaleX=0.36,scaleY=0.36}},
		[22]={{startFrame=12,duration=1,x=9.10,y=-511.30,scaleX=0.71,scaleY=0.71}},
		[23]={{startFrame=12,duration=1,x=19.30,y=-192.05,scaleX=0.65,scaleY=0.65}},
		[24]={{startFrame=11,duration=1,x=-2.65,y=-392.90,scaleX=0.48,scaleY=0.48}},
		[25]={{startFrame=13,duration=1,x=-4.55,y=-291.35,scaleX=0.48,scaleY=0.48}},
		[26]={{startFrame=13,duration=1,x=2.20,y=-556.00,scaleX=1.00,scaleY=1.00}},
		[27]={{startFrame=14,duration=1,x=12.80,y=-440.90,scaleX=0.61,scaleY=0.61}},
		[28]={{startFrame=14,duration=1,x=13.90,y=-511.40,scaleX=0.36,scaleY=0.36}},
		[29]={{startFrame=14,duration=1,x=11.20,y=-358.25,scaleX=0.36,scaleY=0.36}},
	}
	return self:_initEffect(data, 16)
end

function TileBlocker199:_initEffect8()
	local data = {
		[1]={{startFrame=0,duration=4,x=1.00,y=1.00,scaleX=0.94,scaleY=0.94},
		{startFrame=4,duration=5,x=1.75,y=-172.00,scaleX=0.92,scaleY=1.10},
		{startFrame=9,duration=3,x=2.25,y=-605.95,scaleX=0.90,scaleY=1.21},
		{startFrame=12,duration=1,x=2.25,y=-628.55,scaleX=0.90,scaleY=0.93}},
		[2]={{startFrame=1,duration=3,x=-8.25,y=-38.75,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-7.55,y=-185.70,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-7.05,y=-614.95,scaleX=0.80,scaleY=0.80}},
		[3]={{startFrame=1,duration=3,x=-20.25,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=4,duration=5,x=-19.80,y=-171.45,scaleX=0.80,scaleY=0.80},
		{startFrame=9,duration=1,x=-19.45,y=-605.55,scaleX=0.80,scaleY=0.80}},
		[4]={{startFrame=5,duration=3,x=4.95,y=-32.15,scaleX=0.80,scaleY=0.80},
		{startFrame=8,duration=5,x=5.50,y=-319.80,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=5.95,y=-593.40,scaleX=0.80,scaleY=0.80}},
		[5]={{startFrame=3,duration=4,x=-8.30,y=-52.95,scaleX=1.24,scaleY=1.24},
		{startFrame=7,duration=4,x=-8.30,y=-165.25,scaleX=1.24,scaleY=1.24},
		{startFrame=11,duration=1,x=-8.35,y=-592.65,scaleX=1.24,scaleY=1.24}},
		[6]={{startFrame=2,duration=8,x=-16.60,y=-37.40,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-16.65,y=-563.75,scaleX=1.10,scaleY=1.10}},
		[7]={{startFrame=3,duration=8,x=4.95,y=-74.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-3.55,y=-530.70,scaleX=0.80,scaleY=0.80}},
		[8]={{startFrame=2,duration=8,x=-14.95,y=-58.75,scaleX=0.65,scaleY=0.65},
		{startFrame=10,duration=1,x=-13.20,y=-583.75,scaleX=0.65,scaleY=0.65}},
		[9]={{startFrame=4,duration=7,x=-4.70,y=-71.45,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=0.60,y=-570.00,scaleX=0.80,scaleY=0.80}},
		[10]={{startFrame=5,duration=5,x=-13.60,y=-53.95,scaleX=1.10,scaleY=1.10},
		{startFrame=10,duration=1,x=-13.95,y=-484.00,scaleX=1.10,scaleY=1.10}},
		[11]={{startFrame=4,duration=8,x=-0.90,y=-42.60,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-0.70,y=-441.55,scaleX=0.80,scaleY=0.80}},
		[12]={{startFrame=5,duration=8,x=-4.15,y=-164.50,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-3.90,y=-550.50,scaleX=1.24,scaleY=1.24}},
		[13]={{startFrame=6,duration=5,x=-1.50,y=-46.15,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=-1.50,y=-404.95,scaleX=0.80,scaleY=0.80}},
		[14]={{startFrame=7,duration=5,x=-14.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=12,duration=1,x=-14.90,y=-355.20,scaleX=0.80,scaleY=0.80}},
		[15]={{startFrame=7,duration=6,x=-14.95,y=-42.90,scaleX=0.80,scaleY=0.80},
		{startFrame=13,duration=1,x=1.10,y=-187.25,scaleX=0.80,scaleY=0.80}},
		[16]={{startFrame=6,duration=5,x=-14.95,y=-32.90,scaleX=0.80,scaleY=0.80},
		{startFrame=11,duration=1,x=5.10,y=-233.20,scaleX=0.80,scaleY=0.80}},
		[17]={{startFrame=4,duration=9,x=-15.05,y=-45.05,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=-23.15,y=-309.75,scaleX=1.24,scaleY=1.24}},
		[18]={{startFrame=7,duration=6,x=-4.05,y=-45.05,scaleX=1.24,scaleY=1.24},
		{startFrame=13,duration=1,x=1.15,y=-149.55,scaleX=0.78,scaleY=0.78}},
		[19]={{startFrame=9,duration=1,x=-9.80,y=-596.15,scaleX=0.40,scaleY=0.40}},
		[20]={{startFrame=9,duration=1,x=4.20,y=-607.35,scaleX=0.48,scaleY=0.48}},
		[21]={{startFrame=9,duration=1,x=-3.55,y=-552.15,scaleX=0.48,scaleY=0.48}},
		[22]={{startFrame=12,duration=1,x=8.10,y=-405.40,scaleX=0.48,scaleY=0.48}},
		[23]={{startFrame=12,duration=1,x=9.55,y=-541.60,scaleX=0.48,scaleY=0.48}},
		[24]={{startFrame=12,duration=1,x=-1.65,y=-512.80,scaleX=0.36,scaleY=0.36}},
		[25]={{startFrame=12,duration=1,x=10.10,y=-591.30,scaleX=0.71,scaleY=0.71}},
		[26]={{startFrame=12,duration=1,x=20.30,y=-272.05,scaleX=0.65,scaleY=0.65}},
		[27]={{startFrame=11,duration=1,x=-1.65,y=-472.90,scaleX=0.48,scaleY=0.48}},
		[28]={{startFrame=13,duration=1,x=-3.55,y=-371.35,scaleX=0.48,scaleY=0.48}},
		[29]={{startFrame=13,duration=1,x=3.20,y=-636.00,scaleX=1.00,scaleY=1.00}},
		[30]={{startFrame=13,duration=1,x=7.30,y=-446.60,scaleX=0.69,scaleY=0.69}},
		[31]={{startFrame=14,duration=1,x=13.80,y=-520.90,scaleX=0.61,scaleY=0.61}},
		[32]={{startFrame=14,duration=1,x=14.90,y=-591.40,scaleX=0.36,scaleY=0.36}},
		[33]={{startFrame=14,duration=1,x=12.20,y=-438.25,scaleX=0.36,scaleY=0.36}},
		[34]={{startFrame=14,duration=1,x=10.75,y=-189.00,scaleX=0.61,scaleY=0.61}},
		[35]={{startFrame=14,duration=1,x=-2.30,y=-307.35,scaleX=0.78,scaleY=0.79}},
		[36]={{startFrame=14,duration=1,x=4.70,y=-104.75,scaleX=0.78,scaleY=0.78}},
	}
	return self:_initEffect(data, 19)
end

function TileBlocker199:_initEffect(data, num)
	local function spriteCallback(index)
		local part = nil
		if index == 1 then
			part = Sprite:createWithSpriteFrameName("blocker199_effect1")
		elseif index >= num then
			part = Sprite:createWithSpriteFrameName("blocker199_effect3")
		else
			part = Sprite:createWithSpriteFrameName("blocker199_effect2")
		end
		return part
	end

	local sprite = Sprite:createEmpty()
	local tempSprite = Sprite:createWithSpriteFrameName("blocker199_effect1")
	local texture = tempSprite:getTexture()
  	sprite:setTexture(texture)
  	tempSprite:dispose()
  
	local actions = self:_initScriptActions(sprite, data, 36, spriteCallback)
	sprite:runAction(CCSpawn:create(actions))
	return sprite
end

function TileBlocker199:_initScriptActions(sprite, data, framerate, spriteCallback)
	local actions = CCArray:create()
	for k, v in ipairs(data) do
		local part = spriteCallback(k)
		sprite:addChild(part)

		if part and part.refCocosObj then 
			local partActions = CCArray:create()
			partActions:addObject(ResUtils:getAnimationActions(part, v, framerate))
			partActions:addObject(CCCallFunc:create(function()
				part:removeFromParentAndCleanup(true)
			end))
		
			actions:addObject(CCTargetedAction:create(
				part.refCocosObj,
				CCSequence:create(partActions)
			))
		end
	end
	
	return actions
end