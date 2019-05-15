TilePuffer = class(CocosObject)

PufferState = {
	
	kNormal = 1,
	kGrow = 2,
	kActivated = 3,
	kExplode = 4,
}

hasLoadPufferAnimation = false

function TilePuffer:create(itemView , pufferState)

	local node = TilePuffer.new(CCNode:create())
    node:init(itemView , pufferState)
	
	return node
end

function TilePuffer:init(itemView , pufferState)

	self.itemView = itemView
	self.itemData = self.itemView.oldData
    
    if not hasLoadPufferAnimation then
    	FrameLoader:loadArmature("skeleton/puffer_animation")
    end
    --printx( 1 , "   TilePuffer:init  ----------------------------------------------------")
    --printx( 1 , "   pufferState = " , pufferState)
    if pufferState == PufferState.kActivated then
    	self:changePufferState( PufferState.kActivated )
    else
    	self:changePufferState( PufferState.kNormal )
    end
    
end

function TilePuffer:buildAnimation( animeStr )
	local container = Layer:create()
	local body = ArmatureNode:create("pufferAnimation/" .. animeStr)

	body:playByIndex(0)
	body:update(0.001) -- 此处的参数含义为时间

	if animeStr == "normal" then
		body:setPositionY( -8 )
	else
		body:setPositionY( -5 )
	end

	container.body = body
	container:addChild(body)

	return container
end

function TilePuffer:changePufferState(newState , callback)
	--printx( 1 , "   TilePuffer:changeDripState  111  newState = " , newState)

	local function clearBody()
		if self.anime then
			self.anime.body:stop()
			self.anime:removeFromParentAndCleanup(true)
			self.anime = nil
		end
	end

	local function finishCallback()
		if callback then callback() end
	end

	--self.itemView

	if self.state ~= newState then

		clearBody()

		if newState == PufferState.kNormal then

			self.anime = self:buildAnimation("normal")
			self:addChild( self.anime )
			self.anime.body:playByIndex(0)

		elseif newState == PufferState.kGrow and self.state == PufferState.kNormal then

			self.anime = self:buildAnimation("change")
			self:addChild( self.anime )
			self.anime.body:playByIndex(0)
			self.anime.body:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPufferActive )

		elseif newState == PufferState.kActivated then

			self.anime = self:buildAnimation("big_normal")
			self:addChild( self.anime )
			self.anime.body:playByIndex(0)

		elseif newState == PufferState.kExplode and self.state == PufferState.kActivated then

			self.anime = self:buildAnimation("bomb")
			self:addChild( self.anime )
			self.anime.body:playByIndex(0)
			self.anime.body:setAnimationScale(1.2)
			self.anime.body:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayPufferCasting )
			
		end

		self.state = newState
	end
end