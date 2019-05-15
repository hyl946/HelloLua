MissionPanelFlower = class(BasePanel)

function MissionPanelFlower:create()
	local instance = MissionPanelFlower.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_1)
	--instance:loadRequiredResource(PanelConfigFiles.mission_2)
	instance:init()
	return instance
end

function MissionPanelFlower:init()
	local ui = self:buildInterfaceGroup("missionPanel_Flower")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)
	--ui:setPosition( ccp(-150 , 0) )

	local container = ui:getChildByName("missionPanel_Flower_container")

	self.label_time = ui:getChildByName("label_time")
	self.label_time:setScale(1.5)
	local labelpos = self.label_time:getPosition()
	self.label_time:setPosition( ccp( labelpos.x - 10 , labelpos.y - 30 ) )

	self.containerPos = container:getPosition()
	container:removeFromParentAndCleanup(true)
	self.ui:setPosition( ccp( 
		-1 * self.ui:getGroupBounds().size.width , 
		self.ui:getGroupBounds().size.height) )

	self.expireTime = 0
end

function MissionPanelFlower:addItem(item)
	item:setPosition( ccp( self.containerPos.x , self.containerPos.y ) )

	self.ui:addChild(item)
	item:runAction( CCRotateTo:create( 1, -3 ) )
end

function MissionPanelFlower:playShakeAnimation()
	local actArr = CCArray:create()
	
	actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( 1, 3 ) ) )
	actArr:addObject( CCDelayTime:create( 20 ) )
	actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( 1, 0 ) ) )
	actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( 1, -3 ) ) )
	actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( 1, 0 ) ) )

	actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( 1, 3 ) ) )
	actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( 1, 0 ) ) )
	actArr:addObject( CCEaseSineOut:create( CCRotateTo:create( 1, -3 ) ) )
	actArr:addObject( CCEaseSineIn:create( CCRotateTo:create( 1, 0 ) ) )

	--actArr:addObject( CCCallFunc:create( function ()  end ) )
	self:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
end

function MissionPanelFlower:stopShakeAnimation()
	self:stopAllActions()
end

function MissionPanelFlower:onTimer()

	local time = self.expireTime - Localhost:timeInSec()
	if time > 0 then
		self.label_time:setText( convertSecondToHHMMSSFormat( time ) )
		--self.label_time:setString( convertSecondToHHMMSSFormat( time ) )
	else
		self.label_time:setText("")
		--self.label_time:setString("")
		self.expireTime = 0

		if self.timerId then
			TimerUtil.removeAlarm(self.timerId)
			self.timerId = nil
		end
	end
end

function MissionPanelFlower:showTimeTic(expireTime)

	if expireTime > 9999999999 then
		expireTime = math.floor( expireTime / 1000 )
	end
	if self.timerId then
		TimerUtil.removeAlarm(self.timerId)
		self.timerId = nil
	end

	self.expireTime = expireTime

	self.timerId = TimerUtil.addAlarm(function () self:onTimer() end , 1 , 0 )
	self:onTimer()
end

function MissionPanelFlower:hideTimeTic()
	if self.timerId then
		TimerUtil.removeAlarm(self.timerId)
		self.timerId = nil
	end

	self.label_time:setText("")
	self.expireTime = 0
end