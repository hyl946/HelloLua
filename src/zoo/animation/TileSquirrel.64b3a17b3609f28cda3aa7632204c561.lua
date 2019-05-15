TileSquirrel = class(CocosObject)
local animationList = table.const{
	kNormal = 0,
	kMove   = 1,
	kGet    = 2,
	kExciting = 3,
	kDoze = 4,
	kHappy  = 5,
}
function TileSquirrel:create( ... )
	-- body
	local container = TileSquirrel.new(CCNode:create())
	container.name = "Squirrel"

	FrameLoader:loadArmature( "skeleton/squirrel_animation" )
	local node = ArmatureNode:create("squirrel/before_get_key")
	container.mainAnimation = node
	container:addChild(node)
	-- CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/squirrel_animation/texture.png"))
	container.animationType = -1
	container:playNormalAnimation()
	container:setScale(0.5)
	return container
end

function TileSquirrel:playNormalAnimation( ... )
	-- body

	if self.animationType == animationList.kNormal then return end
	self.animationType = animationList.kNormal
	self.mainAnimation:setAnimationScale(0.75)
	self.mainAnimation:removeAllEventListeners()
	self.mainAnimation:playByIndex(animationList.kNormal, 0)
end

function TileSquirrel:playMoveAnimation( callback )
	-- body
	if self.animationType == animationList.kMove 
		or self.animationType == animationList.kExciting then return end
		
	self.animationType = animationList.kMove
	self.mainAnimation:setAnimationScale(1.75)
	self.mainAnimation:removeAllEventListeners()
	self.mainAnimation:playByIndex(animationList.kMove, 0)
	
end

function TileSquirrel:playGetAnimation( callback )
	-- body
	if self.animationType == animationList.kHappy then 
		return
	end

	self.animationType = animationList.kHappy
	self.mainAnimation:setAnimationScale(1.25)
	self.mainAnimation:removeAllEventListeners()
	self.mainAnimation:playByIndex(animationList.kHappy)
	local function animationCallback( ... )
		-- body
		self:playNormalAnimation()
		if callback then callback() end
	end
	self.mainAnimation:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
	
end

function TileSquirrel:playExcitingAnimation( isLoop )
	-- body
	self.animationType = animationList.kExciting
	self.mainAnimation:removeAllEventListeners()
	if isLoop then 
		self.mainAnimation:setAnimationScale(1.0)
		self.mainAnimation:playByIndex(animationList.kHappy, 0)
	else
		self.mainAnimation:setAnimationScale(1.25)
		self.mainAnimation:playByIndex(animationList.kExciting)
		local function animationCallback( ... )
			-- body
			self:playNormalAnimation()
		end
		self.mainAnimation:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
	end
end

function TileSquirrel:playDozeAnimation( ... )
	-- body
	self.animationType = animationList.kDoze
	self.mainAnimation:removeAllEventListeners()
	self.mainAnimation:setAnimationScale(1.25)
	self.mainAnimation:playByIndex(animationList.kDoze)
	local function animationCallback( ... )
		-- body
		self:playNormalAnimation()
	end
	self.mainAnimation:addEventListener(ArmatureEvents.COMPLETE, animationCallback)
end



TileSquirrelAndKey = class(CocosObject)
function TileSquirrelAndKey:create( ... )
	-- body
	local container = TileSquirrelAndKey.new(CCNode:create())
	container.name = "Squirrel"

	local node = ArmatureNode:create("squirrel/get_key")
	container.mainAnimation = node
	container:addChild(node)
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/squirrel_animation/texture.png"))
	container:setScale(0.5)
	return container
end

function TileSquirrelAndKey:play( callback )
	-- body
	local function completeCallback( ... )
		-- body
		if callback then callback() end
	end

	self.mainAnimation:setAnimationScale(1.0)
	self.mainAnimation:playByIndex(0)
	self.mainAnimation:addEventListener(ArmatureEvents.COMPLETE, completeCallback)
end