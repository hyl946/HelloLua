TileGravitySkin_Water = class(CocosObject)

function TileGravitySkin_Water:create( layerType , isHorLine )
    local instance = TileGravitySkin_Water.new(CCNode:create())
    instance:init( layerType , isHorLine )
    instance.name = "TileGravitySkin_Water"
    return instance
end

function TileGravitySkin_Water:init( layerType , isHorLine)

	local layerTypeStr = nil
	local horStr = nil
	local xScale = 1
	local yScale = 1

	if layerType == "top" then
		layerTypeStr = "Top"
		xScale = 1.008
	else
		layerTypeStr = "Bottom"
		xScale = 1.01
	end

	if isHorLine then
		horStr = "HorLine"

		local animeName = "GravitySkin_Water_" .. horStr .. "_" .. layerTypeStr .. "%04d"
		local animeLength = 37

		local spr , spr_animate = SpriteUtil:buildAnimatedSprite( 1/15 , animeName , 1,  animeLength , false )
		spr:play(spr_animate)

		self.sprite = spr
	else
		horStr = "Normal"
		local resName = "GravitySkin_Water_" .. horStr .. "_" .. layerTypeStr
		self.sprite = Sprite:createWithSpriteFrameName(resName)
	end
	
	self.sprite:setScale( xScale , yScale )

    self:addChild(self.sprite)

    if layerType == "top" then

    	self:checkShowBubbles()
    end
end

function TileGravitySkin_Water:showBubbles( bubbleType )

	-- printx( 1 , "TileGravitySkin_Water:showBubbles   " , bubbleType )
	if self.isDisposed then
		return
	end

	local animeLength = 38
	local pos = ccp( 20 , -10 )

	if bubbleType == 1 then
		animeLength = 38
		pos = ccp( 20 , -10 )
	elseif bubbleType == 2 then
		animeLength = 57
		pos = ccp( -20 , -5 )
	end

	local bubble , bubble_animate = SpriteUtil:buildAnimatedSprite(
				1/15 , 
				"GravitySkin_Water_Bubble_" .. tostring(bubbleType) .. "_" .. "%04d" , 
				1,  
				animeLength , 
				false 
			)
	bubble:setPosition( pos )
	self:addChild( bubble )

	bubble:play( bubble_animate , 0 , 1 , function () 
			bubble:setVisible( false )
			bubble:removeFromParentAndCleanup( true )
			self:checkShowBubbles() 
		end )
end

function TileGravitySkin_Water:checkShowBubbles()
	if self.isDisposed then
		return
	end

	local function docheck()
		if self.isDisposed then
			return
		end
		local bubbleType = math.random( 1 , 2 )
		-- local bubbleType = 2
		local delayTime = math.random() * 2

		setTimeOut( 
			function () 
				self:showBubbles( bubbleType ) 
			end 
			, delayTime )
	end

	if math.random(1 , 500) <= 200 then
		setTimeOut( docheck , 0.1 )
	else
		setTimeOut( function () self:checkShowBubbles() end , math.random( 4 , 8 ) )
	end
	
end
