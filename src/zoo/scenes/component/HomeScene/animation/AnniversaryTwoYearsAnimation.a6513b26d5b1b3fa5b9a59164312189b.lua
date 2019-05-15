AnniversaryTwoYearsAnimation = {}

function AnniversaryTwoYearsAnimation:init(context)
	if not self.worldScene then self.worldScene = context end
	self.lastMaskedLayerY = self.worldScene.maskedLayer:getPositionY()
	self.currMaskedLayerY = self.lastMaskedLayerY

	TimerUtil.addAlarm( function () self:onMoveCheck() end , 2 , 0 , nil)
end

function AnniversaryTwoYearsAnimation:onMoveCheck()
	self.currMaskedLayerY = self.worldScene.maskedLayer:getPositionY()
	if self.currMaskedLayerY == self.lastMaskedLayerY then

		local now = Localhost:timeInSec()

		if not self.isPlaneFlying then

			local function setNextPlanefly()
				
				local rt = tostring( math.random(50) )
				self.planeDelayTime = rt + 55
				self.planeLastFlyTime = Localhost:timeInSec()

			end

			if self.planeLastFlyTime and self.planeDelayTime then
				if self.planeLastFlyTime + self.planeDelayTime < now then
					self:flyPlane()
					setNextPlanefly()
				end
			else
				self:flyPlane()
				setNextPlanefly()
			end
		end

		if not self.isBalloonFlying then
			
			local function setNextBalloonfly()
				
				local rt = tostring( math.random(50) )
				self.balloonDelayTime = rt + 70
				self.balloonLastFlyTime = Localhost:timeInSec()

			end

			if self.balloonLastFlyTime and self.balloonDelayTime then
				if self.balloonLastFlyTime + self.balloonDelayTime < now then
					self:flyBalloon()
					setNextBalloonfly()
				end
			else
				self:flyBalloon()
				setNextBalloonfly()
			end
		end

	else

		self.planeDelayTime = nil
		self.planeLastFlyTime = nil
		self.balloonDelayTime = nil
		self.balloonLastFlyTime = nil

	end

	self.lastMaskedLayerY = self.currMaskedLayerY
end

function AnniversaryTwoYearsAnimation:delayFlyPlane(delayTime , callback)

	self.planeTimerKey = TimerUtil.addAlarm( function () 

				if self.worldScene.maskedLayer:getPositionY() == self.planeMaskedLayerY then
					self:flyPlane() 
					self.planeTimerKey = nil
					if callback then callback() end
				end
				
			end , delayTime , 1 , nil)
end

function AnniversaryTwoYearsAnimation:buildPlane()
	if WorldSceneShowManager:getInstance():isInAcitivtyTime() or true then

		local container = Layer:create()
		local containerPlane = Layer:create()
		container:addChild(containerPlane)
		local plane = Sprite:createWithSpriteFrameName("plane_0001")
		--star:setPositionX(-30)
		local plane_frames = SpriteUtil:buildFrames("plane_%04d", 1, 9)
		local plane_animate = SpriteUtil:buildAnimate(plane_frames, 1/24)
		plane:play(plane_animate, 0, 0, nil, false)
		--local locationNode = self.worldScene.levelToNode[UserManager:getInstance().user:getTopLevelId()]
		--local posY = locationNode:getPositionY()
		containerPlane:addChild( plane )
		container.plane = containerPlane
		--plane:setPosition(ccp(200 , 200))
		--star1Layer:removeFromParentAndCleanup(false)
		container:setPosition(ccp( -500 , 0 ) )
		self.planeAnimate = container
		return container
	else
		--star1Layer:removeFromParentAndCleanup(true)
		return nil
	end
end


function AnniversaryTwoYearsAnimation:flyPlane()

	local planeContainer = self.planeAnimate

	if planeContainer then
		self.isPlaneFlying = true

		planeContainer.plane:stopAllActions()
		planeContainer:stopAllActions()

		--local posY = locationNode:getPositionY()
		local posY = (self.worldScene.maskedLayer:getPositionY() * -1) + 800
		planeContainer:setPosition(ccp( 1300 , posY ) )

		local actArr = CCArray:create()
		
		actArr:addObject( CCEaseSineOut:create( CCMoveTo:create( 0.5 , ccp( 0 , 10 ) ) ) )
		actArr:addObject( CCEaseSineIn:create( CCMoveTo:create( 0.5 , ccp( 0 , 0 ) ) ) )
		actArr:addObject( CCEaseSineOut:create( CCMoveTo:create( 0.5 , ccp( 0 , -10 ) ) ) )
		actArr:addObject( CCEaseSineIn:create( CCMoveTo:create( 0.5 , ccp( 0 , 0 ) ) ) )

		--actArr:addObject( CCCallFunc:create( function ()  end ) )
		planeContainer.plane:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )

		local actArr2 = CCArray:create()
		actArr2:addObject( CCMoveTo:create( 22 , ccp( -600 , posY ) ) )
		actArr2:addObject( CCCallFunc:create( function ()  self.isPlaneFlying = false end ) )
		planeContainer:runAction( CCSequence:create(actArr2)  )

		--[[
		local rt = tostring( math.random(50) )

		setTimeOut(function () 
			AnniversaryTwoYearsAnimation:flyPlane( AnniversaryTwoYearsAnimation.homeScene )
		end, rt + 30 )
		]]
	end
end




function AnniversaryTwoYearsAnimation:buildBalloon()

	if WorldSceneShowManager:getInstance():isInAcitivtyTime() or true then
		FrameLoader:loadArmature("skeleton/AnniversaryTwoYearsBalloon")
		local balloonAnim = ArmatureNode:create("AnniversaryTwoYears/AnniversaryTwoYearsBalloon")
		local balloon = Sprite:createEmpty()
		balloon:addChild(balloonAnim)
		balloonAnim:playByIndex(0)
		self.balloon = balloon
		balloon:setPositionX(-500)

		return balloon
	else
		--star1Layer:removeFromParentAndCleanup(true)
		return nil
	end
end


function AnniversaryTwoYearsAnimation:flyBalloon()

	local balloon = self.balloon
	
	local test = 0

	if balloon then
		self.isBalloonFlying = true
		balloon:stopAllActions()
		--local locationNode = self.worldScene.levelToNode[UserManager:getInstance().user:getTopLevelId()]
		local posY = (self.worldScene.maskedLayer:getPositionY() * -1) + 800
		balloon:setPosition(ccp( 90 , posY - 900 ) )

		local actArr2 = CCArray:create()
		actArr2:addObject( CCEaseSineIn:create( CCMoveTo:create( 15 , ccp( 90, posY + 600 ) ) ) )
		actArr2:addObject( CCCallFunc:create( function ()  
				self.isBalloonFlying = false 
				self.balloon:setPositionX(-500)
			end ) )
		balloon:runAction( CCSequence:create(actArr2)  )
	end

	--[[
	local rt = tostring( math.random(50) )

	setTimeOut(function () 
			AnniversaryTwoYearsAnimation:flyBalloon( AnniversaryTwoYearsAnimation.homeScene )
		end, rt + 30 )

	setTimeOut(function () 
		print( "RRR  ==============================AnniversaryTwoYearsAnimation======================================    " , 
			self.worldScene.maskedLayer:getPositionY() , test )  
		end, 5)
	]]
end