ActivityCenterItemPanel = class(Layer)

function ActivityCenterItemPanel:ctor( ... )
	
end

function ActivityCenterItemPanel:create( itemData )
	local panel = ActivityCenterItemPanel.new()
	panel:initLayer()
	panel:init(itemData)
	return panel
end

function ActivityCenterItemPanel:init( itemData )
	self:initLayer()
	self.data = itemData

	self.scene = itemData.curScene

	local ActivityCenterItemLoadingPanel = (require "zoo.ActivityCenter.ActivityCenterItemLoadingPanel")
	if self:is(ActivityCenterItemLoadingPanel) then
		local ui = self.scene.builder:buildGroup("ActivityCenter/loadingPanel")
	    self:addChild(ui)
	    self.ui = ui
	elseif itemData.type == ActivityCenterType.kAct then
		local cPanelPath = "activity/" .. itemData.id .. "/" .. itemData.cPanelPath
		StarBank:print(string.find(itemData.cPanelPath, "activity/"), itemData.cPanelPath)
		if string.find(itemData.cPanelPath, "activity/") == 1 then
			cPanelPath = itemData.cPanelPath
		end
		self.builder = ActivityCenter:loadResources(cPanelPath)
	    self.ui = self.builder:buildGroup(itemData.cPanelName)
	    self:addChild(self.ui)
	end
end

function ActivityCenterItemPanel:buildInterfaceGroup( name )
	if self.builder then
		return self.builder:buildGroup(name)
	end
end

function ActivityCenterItemPanel:getChildByName( name )
	return self.ui:getChildByName(name)
end