MissionMangaPanel = class(BasePanel)

function MissionMangaPanel:create()
	local instance = MissionMangaPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_manga)
	instance:init()
	return instance
end

function MissionMangaPanel:init()
	local ui = self:buildInterfaceGroup("missionPanel_Manga")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)

	self.ui:setTouchEnabled(true, 0, false)
	--self.ui:setButtonMode(true)
	self.ui:addEventListener(DisplayEvents.kTouchTap, 
		function (event) 
      		self:onCloseBtnTapped(event) 
		end)


	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()
    
    local uiWidth = self.ui:getGroupBounds().size.width
    local uiHeight = self.ui:getGroupBounds().size.height - 10

    local fixScale = visibleSize.height / uiHeight
	self:setScale(  fixScale  )

	local fixX = (visibleSize.width - (uiWidth * fixScale)) / 2
	self:setPositionX(fixX)

end

function MissionMangaPanel:onCloseBtnTapped()
	if self:getParent() then
		PopoutManager:sharedInstance():remove(self)
	end

	--MissionPanelLogic:openPanel()
	MissionPanelLogic:tryCreateMission( nil , function () 
		CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips")) 
		end , true )
end

function MissionMangaPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end