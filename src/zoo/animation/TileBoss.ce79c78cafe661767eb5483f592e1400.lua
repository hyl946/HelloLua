TileBoss = class(CocosObject)

local kCharacterAnimationTime = 1/30
local animationList = table.const
{
	kNone = 0,
	kNormal = 1,
	kDestroy = 2,
	kDisappear = 3,
	kComeout = 4,
	kHit = 5,
	kCast = 6,
}

--使用的boss类型，方便换皮
BossType = table.const
{
	kLion = {
		name = 'boss_starfish',
		filePath = 'skeleton/season_weekly_boss_animation',
		armatureName = 'LionH',
		normal = {name = 'normal', time = 34 * kCharacterAnimationTime },
		hit = {name = 'hit', time = 30 *kCharacterAnimationTime},
		cast = {name = 'super', time = 33 * kCharacterAnimationTime},
		destroy = {name = 'die', time = 137 *kCharacterAnimationTime},
	},
	kHuli = {
		name = 'boss_huli',
		filePath = 'skeleton/winter2016_weekly_boss_animation',
		armatureName = 'boss_huli',
		normal = {name = 'normal', time = 34 * kCharacterAnimationTime },
		hit = {name = 'hit', time = 30 *kCharacterAnimationTime},
		cast = {name = 'super', time = 33 * kCharacterAnimationTime},
		destroy = {name = 'die', time = 137 *kCharacterAnimationTime},
	},
	kTuzi = {
		name = 'boss_tuzi',
		filePath = 'skeleton/weekly_2017s1_boss1',
		armatureName = 'boss_tuzi',
		normal = {name = 'normal', time = 34 * kCharacterAnimationTime },
		hit = {name = 'hit', time = 30 *kCharacterAnimationTime},
		cast = {name = 'super', time = 33 * kCharacterAnimationTime},
		destroy = {name = 'die', time = 137 *kCharacterAnimationTime},

		scale = 0.8,
		offsetX = 0, 
		offsetY = 10,
		specialBg = true,
	},
	kJingyu = {
		name = 'boss_jingyu',
		filePath = 'skeleton/weekly_2017s2_boss1',
		armatureName = 'boss_jingyu',
		normal = {name = 'normal', time = 36 * kCharacterAnimationTime },
		hit = {name = 'hit', time = 35 *kCharacterAnimationTime},
		cast = {name = 'super', time = 56 * kCharacterAnimationTime},
		destroy = {name = 'die', time = 50 *kCharacterAnimationTime},

		-- scale = 0.8,
		offsetX = -15, 
		offsetY = 8,
		specialBg = true,
	}
}

local OFFSET_X = 2
local OFFSET_Y = 25
local BaseScale = 1 

function TileBoss:create(bossType)
	local node = TileBoss.new(CCNode:create())
	node.bossType = bossType or BossType.kJingyu
	node.name = "tile_boss_"..node.bossType.name
	node.currentAnimation = animationList.kNone
	node:initBoss()
	return node
end

function TileBoss:initBoss()
	if self.bossType.specialBg then 
		FrameLoader:loadArmature(self.bossType.filePath, 'jingyu_water', 'jingyu_water')
		self.bossBg = ArmatureNode:create('jingyu_water')
		self.bossBg:update(0.001)
		self:addChild(self.bossBg)
		-- self.bossBg:setScale(0.9)
		self.bossBg:setPosition(ccp(-70, 68))
		self.bossBg:play("normal", 0)

		self.bgDisappear = function ()
			if self.blood then self.blood:setVisible(false) end
			setTimeOut(function ()
				if self.bossBg and not self.bossBg.isDisposed and not self.isDisposed then 
					self.bossBg:play("disappear", 1)
				end
			end, self.bossType.destroy.time/2)
		end
	end

	if self.bossType.normal then
		FrameLoader:loadArmature(self.bossType.filePath, self.bossType.armatureName, self.bossType.armatureName)
		local boss = ArmatureNode:create(self.bossType.armatureName)
		boss:update(0.001)
		self:addChild(boss)
		self.boss = boss
	end

	if self.bossType.water then
		local sprite = Sprite:createWithSpriteFrameName('boss_water_0000')
		self.water = sprite
		self:addChild(self.water)
		self.water:setPosition(ccp(0, -40))
		self.water:play(SpriteUtil:buildAnimate(SpriteUtil:buildFrames(self.bossType.water.name..'_%04d', 0, self.bossType.water.frame), kCharacterAnimationTime))
	end

	local scale = self.bossType.scale or 0.91
	self.boss:setScale(scale)
	local posX = self.bossType.offsetX or 0
	local posY = self.bossType.offsetY or 0
	self.boss:setPosition(ccp(OFFSET_X - 47 + posX, OFFSET_Y + 28 + posY))
	self:createBloodBar()
	self:normal()

	if isLocalDevelopMode then
		self.testContainer = LayerColor:create()
		self.testContainer:setContentSize(CCSizeMake(70, 30))
		self.testContainer:setColor(ccc3(255, 255, 255))
		self.testContainer:setOpacity(180)
		self.testContainer:setPositionX(-35)
		self.testContainer:setPositionY(35)
		self.debug_label = TextField:create()
		self.debug_label:setColor(ccc3(255,0,0))
		self.testContainer:addChild(self.debug_label)
		self.debug_label:setPosition(ccp(35, 15))
		self.debug_label:setAnchorPoint(ccp(0.5,0.5))
		self:addChild(self.testContainer)
	end
end

function TileBoss:createBloodBar()
	local blood = Sprite:createEmpty()

	local dangerBg = Sprite:createWithSpriteFrameName("boss_blood_danger_0000")
	dangerBg:setAnchorPoint(ccp(0.5, 0.5))
	dangerBg:setScaleY(0.9)
	dangerBg:setScaleX(1)
	dangerBg:setPosition(dangerBg:getGroupBounds().size.width / 2 - 6 , -1 - 4)
    blood:addChild(dangerBg)
    dangerBg:setOpacity(0)
    self.dangerBg = dangerBg

	local bloodbg = Sprite:createWithSpriteFrameName("boss_blood_bar_0000")
	bloodbg:setAnchorPoint(ccp(0, 0.5))
	bloodbg:setScaleY(0.9)
	blood:addChild(bloodbg)

	local bloodfg_mask = Sprite:createWithSpriteFrameName("boss_blood_bar_0001")
	local bloodfg = Sprite:createWithSpriteFrameName("boss_blood_bar_0001")

	clipingnode = ClippingNode.new(CCClippingNode:create(bloodfg_mask.refCocosObj))
	clipingnode:setPositionX(0)
	clipingnode:setAlphaThreshold(0.98)
	bloodfg_mask:setAnchorPoint(ccp(0, 0.5))
	bloodfg_mask:dispose()
	bloodfg:setAnchorPoint(ccp(0, 0.5))
	clipingnode:addChild(bloodfg)

	blood:addChild(clipingnode)
	self:addChild(blood)
	self.bloodBar = bloodfg
	bloodfg:setPosition(OFFSET_X - 10 + 5, 0 - 3)
	self.bloodBarWidth = bloodfg:getGroupBounds().size.width

	local pos_x = -self.bloodBarWidth /2
	local pos_y = -GamePlayConfig_Tile_Height * 3 /4
	blood:setPosition(ccp(pos_x - 4 + 5, pos_y - 4))
	self.blood = blood
end

--------------------
--percent = [0,1]
--------------------
function TileBoss:setBloodPercent(percent, isPlayAnimation, debug_string)
	if _G.isLocalDevelopMode then printx(0, 'percent', percent) end
	local percent = 1 - percent
	if self.bloodBar and percent then
		self.bloodBar:stopAllActions()
		if isPlayAnimation then
			self.bloodBar:runAction(CCMoveTo:create(0.5, ccp(( percent - 1) * self.bloodBarWidth + OFFSET_X, 0)))
		else
			self.bloodBar:setPosition(ccp((percent - 1) * self.bloodBarWidth + OFFSET_X, 0))
		end
		if percent >= 0.7 then
			self:playDangerEffect()
		end

		if isLocalDevelopMode and self.testContainer and debug_string then
			self.debug_label:setString(debug_string)
		end
		
	end
end

function TileBoss:normal()

	if self.currentAnimation == animationList.kNormal then return end
	self:reset()
	self.currentAnimation = animationList.kNormal
	if self.boss then
		self.boss:play(self.bossType.normal.name, 0)
	end
end

function TileBoss:destroy(callback)

	local function animationComplete()
		if callback then callback() end
	end
	self:reset()
	self.currentAnimation = animationList.kDestroy
	self:createDestroyAnimation(animationComplete)
	
end

function TileBoss:cast(callback)
	local function animationComplete()
		if callback then callback() end
		self:normal()
	end
	self:reset()
	self.currentAnimation = animationList.kDestroy
	self:createCastingAnimation(animationComplete)
end

function TileBoss:createCastingAnimation(animationComplete)
	local timeoutId
	local function onTimeOut()
		if not timeoutId then return end
		cancelTimeOut(timeoutId)
		timeoutId = nil
		if not self.isDisposed then
			animationComplete()
		end
	end
	timeoutId = setTimeOut(onTimeOut, self.bossType.cast.time)
	self.boss:removeAllEventListeners()
	self.boss:addEventListener(ArmatureEvents.COMPLETE, onTimeOut)
	self.boss:play(self.bossType.cast.name, 1)	
end

function TileBoss:addClippingNode()
	local clippingnode = ClippingNode:create(CCRectMake(0, 0, GamePlayConfig_Tile_Width * 2,GamePlayConfig_Tile_Height * 2))
	clippingnode:setPosition(ccp(-GamePlayConfig_Tile_Width, -GamePlayConfig_Tile_Height) )
	self.clippingnode = clippingnode
	self:addChild(clippingnode)

	local container = Sprite:createEmpty()
	clippingnode:addChild(container)
	self.container = container
	container:setPosition(ccp(GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height))

	if self.boss then 
		self.boss:removeFromParentAndCleanup(false)
		self.container:addChild(self.boss)
	end

	if self.water then
		self.water:removeFromParentAndCleanup(false)
		self.container:addChild(self.water)
	end

	if self.blood then 
		self.blood:removeFromParentAndCleanup(false)
	end
end

function TileBoss:removeClippingnode()
	if self.boss then 
		self.boss:removeFromParentAndCleanup(false)
		self:addChild(self.boss)
	end

	if self.water then
		self.water:removeFromParentAndCleanup(false)
		self:addChild(self.water)
	end

	if self.blood then 
		self:addChild(self.blood)
	end

	self.clippingnode:removeFromParentAndCleanup(true)
	self.container = nil
	self.clippingnode = nil
end


function TileBoss:disappear(callback)
	local function animationComplete()
		self:removeClippingnode()
		if callback then callback() end
	end 
	self:addClippingNode()
	self.currentAnimation = animationList.kDisappear
	self:createDisAppearAnimation(animationComplete)

end

function TileBoss:comeout(callback)
	local function animationComplete()
		self:removeClippingnode()
		self:normal()
		if callback then callback() end
	end
	self:addClippingNode()
	self.currentAnimation = animationList.kComeout
	self:createComeoutAnimation(animationComplete)
end


function TileBoss:hit( callback )
	local function animationComplete()
		if callback then callback() end
		self:normal()
	end

	if self.currentAnimation == animationList.kHit then
		if callback then callback() end
	else
		GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyBossHit)

		self:reset()
		self.currentAnimation = animationList.kHit
		self:createHitAnimation(animationComplete)
	end
end

function TileBoss:createComeoutAnimation(animationComplete)
	local function callback()
		if animationComplete then animationComplete() end
	end
	self.container:setPosition(ccp(GamePlayConfig_Tile_Width, 3*GamePlayConfig_Tile_Height))
	self.container:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.6, ccp(GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height)), CCCallFunc:create(callback)))
end

function TileBoss:createDisAppearAnimation(animationComplete)
	local function callback()
		self.container:setPosition(ccp(GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height))
		if animationComplete then animationComplete() end
	end
	self.container:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.6, ccp(0, -2*GamePlayConfig_Tile_Height)), CCCallFunc:create(callback)))
end


function TileBoss:createHitAnimation(animationComplete)
	self.boss:removeAllEventListeners()
	self.boss:addEventListener(ArmatureEvents.COMPLETE, function()
			if animationComplete then animationComplete() end
		end)
	self.boss:play(self.bossType.hit.name, 1)
end

function TileBoss:createDestroyAnimation(animationComplete)
	--rabbit
	local function completeCallback()
		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(0.3, 0.2))
		arr:addObject(CCMoveBy:create(0.3, ccp(-GamePlayConfig_Tile_Width, GamePlayConfig_Tile_Height * 3)))
		arr:addObject(CCRotateTo:create(0.3, -30))
		local action_callback = CCCallFunc:create(animationComplete)
		local action = CCSequence:createWithTwoActions(CCSpawn:create(arr), action_callback)
		self.boss:runAction(action)
	end

	local timeoutId
	local function onTimeOut()
		if not timeoutId then return end
		cancelTimeOut(timeoutId)
		timeoutId = nil
		animationComplete()
	end
	timeoutId = setTimeOut(onTimeOut, self.bossType.destroy.time)
	self.boss:removeAllEventListeners()
	self.boss:addEventListener(ArmatureEvents.COMPLETE, onTimeOut)
	self.boss:play(self.bossType.destroy.name, 1)

	if self.bgDisappear then self.bgDisappear() end

	--bg_star
	local bg_star = Sprite:createWithSpriteFrameName("boss_bg_star")
	bg_star:setScale(0.6)
	bg_star:setOpacity(0)
	self:addChild(bg_star)
	self.bg_star = bg_star

	local bg_star_arr = CCArray:create()
	bg_star_arr:addObject(CCDelayTime:create(0.2))
	bg_star_arr:addObject(CCFadeIn:create(0.1))
	bg_star_arr:addObject(CCScaleTo:create(0.1))

	local bg_scale = CCSequence:createWithTwoActions(CCScaleTo:create(0.2, 1.46), CCScaleTo:create(0.4, 2.07))
	bg_star_arr:addObject(CCSpawn:createWithTwoActions(bg_scale, CCFadeOut:create(0.6)))
	self.bg_star:runAction(CCSequence:create(bg_star_arr))


	if self.water then
		self.water:runAction(CCFadeOut:create(0.5))
	end
end

function TileBoss:reset()


	if self.boss then 
		self.boss:stopAllActions()
		self.boss:setRotation(0)
	end
	if self.bg_star then 
		self.bg_star:removeFromParentAndCleanup(true)
		self.bg_star = nil
	end

end

function TileBoss:playDangerEffect()
	if not self.isInDanger then
		local action = CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(1), CCFadeOut:create(1)))
		self.dangerBg:runAction(action)
		self.isInDanger = true
	end
end