require "zoo.panel.basePanel.BasePanel"

MarkEnergyRemindPanel = class(BasePanel)

function MarkEnergyRemindPanel:create(confirmCallback)
	local panel = MarkEnergyRemindPanel.new()
	panel:init(confirmCallback)
	return panel
end

function MarkEnergyRemindPanel:init(confirmCallback)
	self:loadRequiredJson(PanelConfigFiles.mark_energy_remind_panel)
	local ui = self:buildInterfaceGroup("MarkEnergyRemindPanel")
	BasePanel.init(self, ui)

	local text = ui:getChildByName("text")
	text:setString(Localization:getInstance():getText("mark.panel.remind.infi.energy.text"))

	local btn1 = GroupButtonBase:create(ui:getChildByName("btn1"))
	btn1:setString(Localization:getInstance():getText("mark.panel.remind.infi.energy.btn1"))
	btn1:setColorMode(kGroupButtonColorMode.orange)
	btn1:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)

	local btn2 = GroupButtonBase:create(ui:getChildByName("btn2"))
	btn2:setString(Localization:getInstance():getText("mark.panel.remind.infi.energy.btn2"))
	btn2:addEventListener(DisplayEvents.kTouchTap, function()
			if confirmCallback then confirmCallback() end
			self:onCloseBtnTapped()
		end)

	local ph = ui:getChildByName("ph")
	ph:setVisible(false)
	local sprite = ResourceManager:sharedInstance():buildItemGroup(10039)
	local size = sprite:getGroupBounds().size
	local pSize = ph:getGroupBounds().size
	sprite:setScale(math.min(pSize.width / size.width, pSize.height / size.height))
	sprite:setPositionX(ph:getPositionX() + (pSize.width - size.width * sprite:getScale()) / 2)
	sprite:setPositionY(ph:getPositionY() - (pSize.height - size.height * sprite:getScale()) / 2)
	ui:addChildAt(sprite, ui:getChildIndex(ph))

	local bg = ui:getChildByName("bg")
	bg:setVisible(false)
	local bSize = bg:getGroupBounds().size
	bSize = {width = bSize.width, height = bSize.height}
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	local color = LayerColor:create()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	color:setContentSize(CCSizeMake(vSize.width / self:getScale(), bSize.height))
	color:setOpacity(170)
	color:setPositionXY(-self:getPositionX(), -bSize.height)
	ui:addChildAt(color, 0)
end

function MarkEnergyRemindPanel:popout()
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = true
end

function MarkEnergyRemindPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end