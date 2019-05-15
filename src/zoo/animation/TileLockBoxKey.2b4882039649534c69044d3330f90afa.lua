TileLockBoxKey = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileLockBoxKey:create()
	local node = TileLockBoxKey.new(CCNode:create())
	node.name = "coin"

	local effectSprite = Sprite:createWithSpriteFrameName("lockBox_key_normal")
	-- local frames = SpriteUtil:buildFrames("nationday_star_%04d", 0, 30)
	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- effectSprite:play(animate, 0, 0)
	
	--effectSprite:setScale(0.95)
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	return node
end

function TileLockBoxKey:playBreak()
	
	local function onRepeatFinishCallback_DestroyEffect()
		if self.destroySprite and self.destroySprite:getParent() then
			self:removeChild( self.destroySprite )
		end
	end 

	local destroySprite = ItemViewUtils:buildAnimalDestroyEffect(6, onRepeatFinishCallback_DestroyEffect)

	self.destroySprite = destroySprite
	self:addChildAt( destroySprite , 1 )

	self.effectSprite:runAction(CCFadeOut:create(0.5))
	self.effectSprite:runAction(CCScaleTo:create(0.5 , 0.01))

	-- local frames = SpriteUtil:buildFrames("coin_destroy%02d", 0, 12)
	-- local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- self.effectSprite:play(animate, 0, 1)
end