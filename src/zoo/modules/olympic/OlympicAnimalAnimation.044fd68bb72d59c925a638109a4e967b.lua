OlympicAnimalAnimation = {}

OlympicAnimalAnimationState = table.const{
	
	kRun = "run",
	kWait = "wait",
	kDizziness = "dizziness",
	kRecover = "recover",
	kLose = "wait2",
}

local RealState = table.const{
	kRun = "run",
	kWait1 = "wait1",
	kWait2 = "wait2",
	kAddStep = "add_step",
	kDizziness = "dizziness",
	kRecover = "recover",
}

local ChangeStateConfig = {

	wait1 = {
		[0] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--小玩熊
		[1] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--河马
		[2] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--青蛙
		[3] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--熊
		[4] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--猫头鹰
		[5] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--狐狸
		[6] = { threshold1 = 0 , threshold1Random = 100 , threshold2 = 2 },--鸡
	},
	wait2 = {
		[0] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--小玩熊
		[1] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--河马
		[2] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--青蛙
		[3] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--熊
		[4] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--猫头鹰
		[5] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--狐狸
		[6] = { threshold1 = 5 , threshold1Random = 50 , threshold2 = 10 },--鸡
	},
}

function OlympicAnimalAnimation:init()

	if self.initialized then return end

	FrameLoader:loadArmature( 'skeleton/olympic_animal_animation', "olympic_animal_animation", "olympic_animal_animation" )
	--FrameLoader:loadImageWithPlist("flash/missionAnime.plist")
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/missionAnime.plist"))
	--CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/common/properties.plist"))
	self.initialized = true
end

function OlympicAnimalAnimation:unloadRes()
	-- ArmatureFactory:remove("olympic_animal_animation", "olympic_animal_animation")
	FrameLoader:unloadArmature('skeleton/olympic_animal_animation', true)
	self.initialized = false
end

function OlympicAnimalAnimation:createAnimal(colorIndex , state)
	
	local container = OlympicAnimalAnimationContainer:create()
	container:change(colorIndex , state , true)

	return container
end

function OlympicAnimalAnimation:createAnimalByAddStepPanel(colorIndex)

	local container = Layer:create()
	local resname = "olympic_animal_animation/animal_" .. tostring(colorIndex) .. "_add_step"
		--printx( 1 , "  OlympicAnimalAnimationContainer:change   resname = " , resname)

	local anime = ArmatureNode:create( resname  )
	--printx( 1 , "   self.body = " , self.body)
	container:addChild(anime)

	if colorIndex == 1 then

	elseif colorIndex == 2 then
		anime:setScale(2)
	elseif colorIndex == 3 then

	elseif colorIndex == 4 then
		anime:setScale(2.8)
	elseif colorIndex == 5 then
		anime:setPositionX(50)
	elseif colorIndex == 6 then
		anime:setScale(1.8)
		anime:setPositionX(-20)
		container:setScaleX(-1)
	end

	anime:playByIndex(0, 0)
	anime:update( 0.001 )

	return container
end

function OlympicAnimalAnimation:createHoleStateAnimal()

	local container = Layer:create()
	local resname = "olympic_gold/goldState"
		--printx( 1 , "  OlympicAnimalAnimationContainer:change   resname = " , resname)

	local anime = ArmatureNode:create( resname  )
	--printx( 1 , "   self.body = " , self.body)
	container:addChild(anime)

	anime:playByIndex(0, 1)
	anime:update( 0.001 )

	container.body = anime

	return container
end

function OlympicAnimalAnimation:createGlodBoomAnimal()

	local container = Layer:create()
	local resname = "olympic_gold/goldBoom"
		--printx( 1 , "  OlympicAnimalAnimationContainer:change   resname = " , resname)

	local anime = ArmatureNode:create( resname  )
	--printx( 1 , "   self.body = " , self.body)
	container:addChild(anime)

	anime:playByIndex(0, 1)
	anime:update( 0.001 )

	container.body = anime

	return container
end



OlympicAnimalAnimationContainer = class(Layer)

function OlympicAnimalAnimationContainer:create()
  local layer = OlympicAnimalAnimationContainer.new()
  layer:initLayer()
  return layer
end

function OlympicAnimalAnimationContainer:change(colorIndex , state , autoChange)

	if autoChange == nil then autoChange = true end

	if state == OlympicAnimalAnimationState.kWait then

		if self.state == RealState.kWait1 then
			if self.colorIndex ~= 0 then
				state = RealState.kWait1
			else
				state = RealState.kWait1
			end
		elseif self.state == RealState.kWait2 then
			state = RealState.kWait1
		elseif self.state == RealState.kRun then
			state = RealState.kWait1
		elseif self.state == nil then
			if math.random( 1,100 ) < 50 then
				state = RealState.kWait1
			else
				state = RealState.kWait1
			end
		end
	end

	--printx( 1 , "   colorIndex = " , colorIndex , " state = " , state , " self.colorIndex = " , self.colorIndex , " self.state = " , self.state)
	if self.colorIndex == colorIndex and self.state == state then
		return
	end

	if self.colorIndex ~= colorIndex then
		self:disposeAnimation()

		local resname = "olympic_animal_animation/animal_" .. tostring(colorIndex)
		--printx( 1 , "  OlympicAnimalAnimationContainer:change   resname = " , resname)

		self.body = ArmatureNode:create( resname  )
		--printx( 1 , "   self.body = " , self.body)
		self:addChild(self.body)

		self.body:play( RealState.kWait1 , 1 )
		self.body:update( 0.001 )
		self.state = RealState.kWait1

		self.body:addEventListener(ArmatureEvents.COMPLETE, function () 
				self:onBodyAnimationComplete() 
			end )

	end

	self.colorIndex = colorIndex
	

	if self.state ~= state then

		local playTimes = 0
		if state == RealState.kWait1 then
			playTimes = 1
		elseif state == RealState.kWait2 then
			playTimes = 1
		elseif state == RealState.kRecover then
			playTimes = 1
		end

		self.body:removeEventListenerByName(ArmatureEvents.COMPLETE)

		self.body:play( state , playTimes)
		self.body:update(0.001)
		self.state = state

		self.body:addEventListener(ArmatureEvents.COMPLETE, function () 
				self:onBodyAnimationComplete() 
			end )
	end

	self.jsq = 0
end

function OlympicAnimalAnimationContainer:onBodyAnimationComplete()
	--printx( 1 , "   OlympicAnimalAnimationContainer:change   ArmatureEvents.COMPLETE ```````````````")
	--printx( 1 , "   self.state = " , self.state)
	if self.state == RealState.kWait1 then
		if self.colorIndex ~= 0 then

			local dochange = false

			if self.jsq < 7 then
				if math.random( 1 , 100 ) < 15 then
					--dochange = true
				end
			elseif self.jsq < 25 then
				if math.random( 1 , 100 ) < 10 then
					dochange = true
				end
			else
				if math.random( 1 , 100 ) < 35 then
					dochange = true
				end
			end
			if dochange then
				self:change(self.colorIndex , RealState.kWait2)
			else
				self.body:play( self.state , 1)
			end

			self.jsq = self.jsq + 1
		else
			self.body:play( self.state , 1)
		end
	elseif self.state == RealState.kWait2 then
		self:change(self.colorIndex , RealState.kWait1)
	elseif self.state == RealState.kRecover then
		self:change(self.colorIndex , RealState.kWait1)
	end


	--[[
	if not self.changeThreshold then
		self.changeThreshold = 1
	end

	if self.state ~= RealState.kWait1 and self.state ~= RealState.kWait2 then
		--self.body:playByIndex(0, 1)
		return
	end

	local function changeState()
		if self.state == RealState.kWait1 then
			self:change( self.colorIndex , RealState.kWait2 , true )
		elseif self.state == RealState.kWait2 then
			self:change( self.colorIndex , RealState.kWait1 , true )
		end
	end
	
	local config = ChangeStateConfig.wait1[1]
	if ChangeStateConfig[self.state] and ChangeStateConfig[self.state][self.colorIndex] then
		config = ChangeStateConfig[self.state][self.colorIndex]
	end

	if self.changeThreshold > config.threshold1 then

		if self.changeThreshold > config.threshold2 then
			changeState()
			self.changeThreshold = 0
		else
			if math.random( 1,100 ) < config.threshold1Random then
				changeState()
				self.changeThreshold = 0
			else
				self.body:play(self.state, 1)
			end
		end
	else
		self.body:play(self.state, 1)
	end

	self.changeThreshold = self.changeThreshold + 1
	]]
end

function OlympicAnimalAnimationContainer:disposeAnimation()
	if self.body then
		self.body:stop()
		self.body:removeEventListenerByName(ArmatureEvents.COMPLETE)
		self.body:removeFromParentAndCleanup(true)
		self.body = nil
		self.changeThreshold = nil
	end
end

function OlympicAnimalAnimationContainer:dispose()
	self:disposeAnimation()
	Layer.dispose(self)
end