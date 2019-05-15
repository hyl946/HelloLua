MissionTrunkLevelNodeBubble = class(BasePanel)

function MissionTrunkLevelNodeBubble:create()
	local instance = MissionTrunkLevelNodeBubble.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_bugtips)
	instance:init()

	return instance
end

function MissionTrunkLevelNodeBubble:init()
	local ui = self:buildInterfaceGroup("missionBubbleOnTrunkLevelNode")
	--local ui = self:buildInterfaceGroup("MarketPanel")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)

	local uiSize = self.ui:getGroupBounds().size
	self.ui:setPosition( ccp( uiSize.width/-2 , uiSize.height/2 ) )

	local actArr = CCArray:create()
	actArr:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.5 , 0.9 , 0.8 ) ) )
	actArr:addObject( CCEaseSineIn:create( CCScaleTo:create( 0.5 , 0.8 , 0.8 ) ) )
	actArr:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.5 , 0.8 , 0.9 ) ) )
	actArr:addObject( CCEaseSineIn:create( CCScaleTo:create( 0.5 , 0.8 , 0.8 ) ) )
	self:runAction( CCRepeatForever:create( CCSequence:create(actArr) ) )
end