TileBuffBoom = class(CocosObject)

hasLoadBuffBoomAnimation = false

TileBuffBoomState = {
	kNormal = 1,
	kOnHit = 2,
	kExplode = 3,
}

function TileBuffBoom:create( buffBoomLevel , buffBoomState )

	local node = TileBuffBoom.new(CCNode:create())
    node:init( buffBoomLevel , buffBoomState)
	
	return node
end

function TileBuffBoom:init( buffBoomLevel , buffBoomState )
    	
    if not buffBoomLevel then buffBoomLevel = 3 end
    if not buffBoomState then buffBoomState = TileBuffBoomState.kNormal end

    if not hasLoadBuffBoomAnimation then
    	--FrameLoader:loadArmature("skeleton/BuffBoomAnimation")
    	hasLoadBuffBoomAnimation = true
    end

    self.level = buffBoomLevel
    --printx( 1 , "   TileBuffBoom:init  ----------------------------------------------------")
    self:changeBuffBoomState( buffBoomState )
end

function TileBuffBoom:buildAnimation()
	local container = Layer:create()
	local body = ArmatureNode:create("BuffBoom_Animation/BuffBoom_Animation")

	body:playByIndex(0)
	body:update(0.001) -- 此处的参数含义为时间

	--[[
	if animeStr == "normal" then
		body:setPositionY( -8 )
	else
		body:setPositionY( -5 )
	end
	]]

	container.body = body
	container.body:setScale(0.9)
	container.body:setPositionXY(-2 , -3)
	container:addChild(body)

	return container
end

function TileBuffBoom:changeBuffBoomState(newState , callback)
	-- printx( 1 , "TileBuffBoom:changeBuffBoomState  111  newState = " , newState)

	local playTimes = 1
	local animeName = nil
	local needPlay = true


	if not self.anime then
		self.anime = self:buildAnimation()
		self:addChild( self.anime )
	end

	self.anime.body:stop()
	self.anime.body:removeAllEventListeners()

	if newState == TileBuffBoomState.kNormal then

		if self.level == 3 then
			animeName = "levelto2"
			needPlay = false
			playTimes = 0
		elseif self.level == 2 then
			animeName = "wait2"
			needPlay = true
			playTimes = 0
		elseif self.level == 1 then
			animeName = "wait1"
			needPlay = true
			playTimes = 0
		elseif self.level == 0 then
			animeName = "wait0"
			needPlay = true
			playTimes = 0
		end

	elseif newState == TileBuffBoomState.kOnHit then

		if self.level == 1 then
			animeName = "levelto0"
			needPlay = true
			playTimes = 1
		elseif self.level == 2 then
			animeName = "levelto1"
			needPlay = true
			playTimes = 1
		elseif self.level == 3 then
			animeName = "levelto2"
			needPlay = true
			playTimes = 1
		elseif self.level == 0 then
			return
		end

	elseif newState == TileBuffBoomState.kExplode then

		animeName = "boom"
		needPlay = true
		playTimes = 1
		
	end

	local function onHitAnimationComplete()
		--self.anime.body(curLevel - 1 , "wait")
		self.anime.body:removeAllEventListeners()
		self:changeBuffBoomState( TileBuffBoomState.kNormal )
		--if onAnimFinished then onAnimFinished() end
	end

	local function onExplodeAnimationComplete()
		--self.anime.body(curLevel - 1 , "wait")
		self.anime.body:removeAllEventListeners()
		self.anime.body:setVisible(false)
		--if onAnimFinished then onAnimFinished() end
	end

	-- printx( 1 , "TileBuffBoom:changeBuffBoomState  222  animeName =" , animeName , "playTimes =" , playTimes)
	self.anime.body:play(animeName , playTimes)
	self.anime.body:update(0.001)
	self.anime.body:stop()

	if playTimes > 0 and newState == TileBuffBoomState.kOnHit then
		self.level = self.level - 1
		self.anime.body:ad(ArmatureEvents.COMPLETE, onHitAnimationComplete)
	end

	--[[
	if newState == TileBuffBoomState.kExplode then
		self.anime.body:ad(ArmatureEvents.COMPLETE, onExplodeAnimationComplete)
	end
	--]]

	if needPlay then
		self.anime.body:play(animeName , playTimes)
	else
		self.anime.body:stop()
	end

	self.state = newState
end

function TileBuffBoom:hideBody()
	self.anime.body:removeAllEventListeners()
	self.anime.body:setVisible(false)
end