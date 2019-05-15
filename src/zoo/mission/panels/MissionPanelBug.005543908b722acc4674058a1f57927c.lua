MissionPanelBug = class(Layer)

function MissionPanelBug:create()
	local instance = MissionPanelBug.new()
	instance:initLayer()
	instance:initBug()
	return instance
end

function MissionPanelBug:initBug()

	self.view = Sprite:createEmpty()
	self:addChild(self.view)

	FrameLoader:loadArmature("skeleton/user_mission_animation")

	self:playIdle()

end

function MissionPanelBug:playIdle()
	if self.bug then
		self.bug:stop()
		self.bug:removeFromParentAndCleanup(true)
	end
	self.bug = ArmatureNode:create("user_mission_piaochong/idle")
	self.bug:playByIndex(0 , 0)
	self.view:addChild( self.bug )
end

function MissionPanelBug:playTalk(callback)
	if self.bug then
		self.bug:stop()
		self.bug:removeFromParentAndCleanup(true)
	end
	self.bug = ArmatureNode:create("user_mission_piaochong/talk")
	self.bug:playByIndex(0 , 1)
	self.view:addChild( self.bug )

	local function onTimeOut()
		self:playIdle()
		if callback and type(callback) == "function" then
			callback()
		end
	end

	local actArr = CCArray:create()
	actArr:addObject( CCDelayTime:create( self.bug:getTotalTime() ) )
	actArr:addObject( CCCallFunc:create( onTimeOut ) )
	self.view:runAction( CCSequence:create(actArr) )
	
end

function MissionPanelBug:playEat(callback)
	if self.bug then
		self.bug:stop()
		self.bug:removeFromParentAndCleanup(true)
	end
	self.bug = ArmatureNode:create("user_mission_piaochong/eat")
	self.bug:playByIndex(0 , 1)
	self.view:addChild( self.bug )

	local function onTimeOut()
		self:playIdle()
		if callback and type(callback) == "function" then
			callback()
		end
	end

	local actArr = CCArray:create()
	actArr:addObject( CCDelayTime:create( self.bug:getTotalTime() ) )
	actArr:addObject( CCCallFunc:create( onTimeOut ) )
	self.view:runAction( CCSequence:create(actArr) )
	
end