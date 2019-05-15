TileWeeklyBoss = class(CocosObject)

local kCharacterAnimationTime = 1/30
local animationList = table.const
{
	kNormal = 0,
	kHit = 1,
	kDestroy = 2,
}

--使用的boss类型，方便换皮
WeeklyBossType = table.const
{
	kBoss5 = {
		name = 'boss_2018_s1',
		filePath = "skeleton/weekly_2018s1_boss5",
		armatureName = 'weekly_2018s1_boss5',
		normal = {name = 'normal', time = 10/24*30 *kCharacterAnimationTime},
		hit = {name = 'hit', time = 15/24*30 *kCharacterAnimationTime},
		destroy = {name = 'die', time = 18/24*30 *kCharacterAnimationTime},
	}
}

function TileWeeklyBoss:create(bossType)
	local node = TileWeeklyBoss.new(CCNode:create())
	node.bossType = bossType or WeeklyBossType.kBoss5
	node:init()
	return node
end

function TileWeeklyBoss:init()
	self.level = 1
	self.currentAnimation = nil

	FrameLoader:loadArmature(self.bossType.filePath, self.bossType.armatureName, self.bossType.armatureName)
	
	self.bossPart3 = ArmatureNode:create('boss5_cherry_3')
	-- self.bossPart3:setScale(0.9)
	self.bossPart3:setPosition(ccp(-80, 79))
	self.bossPart3:update(0.001)
	self:addChild(self.bossPart3)

	self.bossPart2 = ArmatureNode:create('boss5_cherry_2')
	-- self.bossPart2:setScale(0.9)
	self.bossPart2:setPosition(ccp(-79, 78))
	self.bossPart2:update(0.001)
	self:addChild(self.bossPart2)
	self.bossPart2:play(self.bossType.normal.name, 0)

	self.bossPart1 = ArmatureNode:create('boss5_cherry_1')
	-- self.bossPart1:setScale(0.9)
	self.bossPart1:setPosition(ccp(-80, 79))
	self.bossPart1:update(0.001)
	self:addChild(self.bossPart1)

	self:normal()
end

function TileWeeklyBoss:normal()
	if self.currentAnimation == animationList.kNormal then return end
	self.currentAnimation = animationList.kNormal
	if self.bossPart2 then
		self.bossPart2:play(self.bossType.normal.name, 0)
	end
end

function TileWeeklyBoss:hit(currentBlood, callback)
	local function animationComplete()
		if callback then callback() end
		self:normal()
	end

	if self.level >= 4 then
		if callback then callback() end
	else
		-- GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyBossHit)
		self.level = 4 - currentBlood
		if self.level > 4 then 
			self.level = 4
		end
		self.currentAnimation = animationList.kHit
		self:createHitAnimation(animationComplete)
	end
end

function TileWeeklyBoss:createHitAnimation(animationComplete)
	self.bossPart1:removeAllEventListeners()
	self.bossPart1:addEventListener(ArmatureEvents.COMPLETE, function()
			if animationComplete then animationComplete() end
		end)
	self.bossPart1:play(self.bossType.hit.name .. self.level, 1)
	self.bossPart2:play(self.bossType.hit.name, 1)
	self.bossPart3:play(self.bossType.hit.name .. self.level, 1)
end

function TileWeeklyBoss:destroy(callback)
	local function animationComplete()
		if callback then callback() end
	end
	self.currentAnimation = animationList.kDestroy
	self:createDestroyAnimation(animationComplete)
end

function TileWeeklyBoss:createDestroyAnimation(animationComplete)
	local timeoutId
	local function onTimeOut()
		if not timeoutId then return end
		cancelTimeOut(timeoutId)
		timeoutId = nil
		animationComplete()
	end
	timeoutId = setTimeOut(onTimeOut, self.bossType.destroy.time)
	self.bossPart1:removeAllEventListeners()
	self.bossPart3:removeAllEventListeners()
	self.bossPart3:addEventListener(ArmatureEvents.COMPLETE, onTimeOut)
	self.bossPart1:play(self.bossType.destroy.name, 1)
	self.bossPart3:play(self.bossType.destroy.name, 1)
	self.bossPart2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function ()
		self.bossPart2:setVisible(false)
	end)))
end
