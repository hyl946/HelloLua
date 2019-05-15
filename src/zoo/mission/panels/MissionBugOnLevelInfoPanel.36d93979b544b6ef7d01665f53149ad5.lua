require "zoo.mission.panels.MissionBugTip"

MissionBugOnLevelInfoPanel = class(BasePanel)

function MissionBugOnLevelInfoPanel:create(levelId)
	local instance = MissionBugOnLevelInfoPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_bugtips)
	instance:init(levelId)
	return instance
end

function MissionBugOnLevelInfoPanel:init(levelId)
	local ui = self:buildInterfaceGroup("MissionBugOnLevelInfoPanel")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)

	self.bg	= self.ui:getChildByName("bg")

	self.bugTip = MissionBugTip:create()
	self.bugTip:setPosition(ccp( 120 , -30 ))
	--self.bugTip:setScale(0.7)
	self:addChild(self.bugTip)

	self.bg:setOpacity(0)

	local actArr = CCArray:create()
	actArr:addObject( CCDelayTime:create( 1 ) )
	actArr:addObject( CCCallFunc:create( 
		function () 
			self:setPositionY(-1020)
		end ) )
	actArr:addObject( CCFadeTo:create( 0.5 , 255 ) )
	actArr:addObject( CCCallFunc:create( 
		function () 
			self.bugTip:showTips(4 , 0 , nil , levelId) 
		end ) )
	self.bg:runAction( CCSequence:create(actArr) )

	
end