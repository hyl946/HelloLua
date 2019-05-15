local MarketPanelIosAliGuidePanel = class(BasePanel)


function MarketPanelIosAliGuidePanel:create(tipType) -- typeNum = 1 或者 2
	local instance = MarketPanelIosAliGuidePanel.new()
	instance:loadRequiredResource('ui/market_IOS_Ali_guide.json')
	instance:init(tipType)
	return instance
end

function MarketPanelIosAliGuidePanel:init(tipType)
	if type(tipType) ~= 'number' then
		tipType = 1
	end
	if tipType ~= 1 and tipType ~= 2 then
		tipType = 1
	end

	local ui = self:buildInterfaceGroup('market_ios_ali_guide/tipPanel'..tipType)
	BasePanel.init(self, ui)

	FrameLoader:loadArmature('skeleton/market_panel_ios_ali_guide', 'market_panel_ios_ali_guide', 'market_panel_ios_ali_guide')

    self.anim = ArmatureNode:create('market_panel_ios_ali_guide__/market_panel_ios_ali_guide')
    self.anim:setRotation(-27.2)

    local placeHolder = self.ui:getChildByName('animDot')
    local pos = placeHolder:getPosition()
    self.anim:setPosition(ccp(pos.x, pos.y))
    self.ui:addChild(self.anim)
end

function MarketPanelIosAliGuidePanel:dispose()
    BasePanel.dispose(self)
	-- ArmatureFactory:remove('market_panel_ios_ali_guide', 'market_panel_ios_ali_guide')
    FrameLoader:unloadArmature('skeleton/market_panel_ios_ali_guide', true)
end



function MarketPanelIosAliGuidePanel:popout()
	PopoutManager:sharedInstance():add(self)
	self.anim:play('animal', 0)
end

function MarketPanelIosAliGuidePanel:close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

return MarketPanelIosAliGuidePanel