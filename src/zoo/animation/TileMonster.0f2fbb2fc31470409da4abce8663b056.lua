--------------------------------------
--class TileMonster
--class BigMonsterFoot
--class MonsterFoot
--------------------------------------

TileMonster = class(CocosObject)

local kCharacterAnimationTime = 1/30
local animationList = table.const
{
	kNormal = 1,
	kEncourage = 2,
	kJump = 3
}

function TileMonster:create()
	-- body
	local node = TileMonster.new(CCNode:create())
	node.name = "tile_monster"
	node:initMonster()
	return node
end

function TileMonster:initMonster( ... )
	-- body
	local mainSprite = Sprite:createWithSpriteFrameName("BigMonster_stand_0000")
	self.mainSprite = mainSprite
	self.currentAnimation = nil
	self:addChild(mainSprite)
	self:playNormalAnimation()
	-- self:testAnimation()
end

function TileMonster:playNormalAnimation(  )
	-- body
	if self.currentAnimation == animationList.kNormal then
		return 
	end

	if self.mainSprite then 
		self.mainSprite:stopAllActions()
		self.currentAnimation = animationList.kNormal
		local frames = SpriteUtil:buildFrames("BigMonster_stand_%04d", 0, 55)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.mainSprite:play(animate)
	end
end

function TileMonster:playEncourageAnimation( callback )
	-- body
	if self.currentAnimation == animationList.kEncourage then
		if callback and type(callback) == "function" then callback() end
		return 
	end

	local function animationCallback( ... )
		-- body
		self.currentAnimation = nil
		if callback and type(callback) == "function" then callback() end
		self:playNormalAnimation()

	end

	if self.mainSprite then 
		self.mainSprite:stopAllActions()
		self.currentAnimation = animationList.kEncourage
		local frames = SpriteUtil:buildFrames("BigMonster_ext_%04d", 0, 29)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.mainSprite:play(animate, 0, 1, animationCallback)
	end


end

function TileMonster:playJumpAnimation( jumpCallback, finishCallback )
	-- body
	if not self.mainSprite then finishCallback() return end
	self.mainSprite:stopAllActions()

	local function animationCallback( ... )
		-- body
		GamePlayMusicPlayer:playEffect(GameMusicType.kMonsterJumpOut)
		local action = CCSequence:createWithTwoActions(CCFadeOut:create(0.5), CCCallFunc:create(finishCallback))
		if jumpCallback then jumpCallback() end
		self.mainSprite:runAction(action)

	end
	self.currentAnimation = animationList.kJump
	local frames = SpriteUtil:buildFrames("BigMonster_jump_%04d", 0, 46)
	local animate = SpriteUtil:buildAnimate(frames, (kCharacterAnimationTime * 30 / 44))
	self.mainSprite:play(animate, 0, 1, animationCallback)
end

---------------------------
--测试各种动画
---------------------------
function TileMonster:testAnimation( ... )
	-- body
	local function jumpAniamtioncallback( ... )
		-- body
		if _G.isLocalDevelopMode then printx(0, "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< jumpAniamtioncallback") end

	end
	
	local function animationcallback( ... )
		-- body
		self:playJumpAnimation(jumpAniamtioncallback)

	end

	local function delaycallback( ... )
		-- body
		self:playEncourageAnimation(animationcallback)
	end

	local action_delay = CCDelayTime:create(2)
	local action_callback = CCCallFunc:create(delaycallback)
	self:runAction(CCSequence:createWithTwoActions(action_delay, action_callback))
end

---------------------------------
--雪怪脚踏动画 3*2
---------------------------------
MonsterFoot = class(CocosObject)
function MonsterFoot:create( finishCallback,animationCallback, delayIndex  )
	-- body
	local s = MonsterFoot.new(CCNode:create())
	s.name = "MonsterFoot"
	s:init(finishCallback,animationCallback, delayIndex )
	return s
end

function MonsterFoot:init( finishCallback,animationCallback , delayIndex  )
	-- body
	
	local function callback_middle( ... )
		-- body
		if animationCallback then
			animationCallback()
		end
	end 

	local function callback_over( ... )
		-- body
		if finishCallback then 
			finishCallback()
		end
	end

	local function callback_out()
		FrameLoader:loadArmature( "skeleton/big_monster_foot_animation")
		local mainSprite = ArmatureNode:create("littleAttack")
		self:addChild(mainSprite)
		mainSprite:playByIndex(0, 1)
		local delay_time = 0.1--25/30
		local action_delay = CCDelayTime:create(delay_time)
		local action_callback = CCCallFunc:create(callback_middle)
		mainSprite:setScale(0.9)
		self:runAction(CCSequence:createWithTwoActions(action_delay,action_callback))

		local delay_time_2 = CCDelayTime:create(3)
		local action_callback_2 = CCCallFunc:create(callback_over)
		self:runAction(CCSequence:createWithTwoActions(delay_time_2, action_callback_2))
	end

	local delay_time_0 = CCDelayTime:create(0.27 + delayIndex * 0.2)	--0.5 -> 0.27
	local action_out_callback = CCCallFunc:create(callback_out)
	self:runAction(CCSequence:createWithTwoActions(delay_time_0, action_out_callback))
end


---------------------------------
--雪怪脚踏动画 9*9
---------------------------------
BigMonsterFoot = class(CocosObject)
function BigMonsterFoot:create( finishCallback , animationCallback)
	-- body
	local s = BigMonsterFoot.new(CCNode:create())
	s.name = "BigMonsterFoot"
	s:init(finishCallback, animationCallback)
	return s
end

function BigMonsterFoot:init( finishCallback,animationCallback )
	-- body
	local function callback_middle( ... )
		-- body
		if animationCallback then
			animationCallback()
		end
	end 

	local function callback_over( ... )
		-- body
		if finishCallback then 
			finishCallback()
		end
	end
	
	FrameLoader:loadArmature( "skeleton/big_monster_foot_animation")
	local function callback_playAnimation( ... )
		-- body
		local mainSprite = ArmatureNode:create("strom")
		self:addChild(mainSprite)
		mainSprite:playByIndex(0, 1)
	end

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.01))
	arr:addObject(CCCallFunc:create(callback_playAnimation))
	arr:addObject(CCDelayTime:create(1.3))
	arr:addObject(CCCallFunc:create(callback_middle))
	arr:addObject(CCDelayTime:create(2))
	arr:addObject(CCCallFunc:create(callback_over))
	self:runAction(CCSequence:create(arr))
end
