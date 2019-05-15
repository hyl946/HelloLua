
FruitTreeEnergyPanel = class(BaseUI)

function FruitTreeEnergyPanel:create( ... )
	local panel = FruitTreeEnergyPanel.new()
	panel:init()
	panel.panelPluginType = "Pendant"
	return panel
end

function FruitTreeEnergyPanel:init( ... )
	self.ui = ResourceManager:sharedInstance():buildGroup("energy_fruit_tree_panel")
	BaseUI.init(self,self.ui)

	local button = GroupButtonBase:create(self.ui:getChildByName("btn"))
	button:setString("去摘取")
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )
		DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_fruit"}, true)
		self:dispatchEvent(Event.new(kPanelEvents.kButton))
	end)
end
