-- 六一儿童节 

require "zoo.panel.BeginnerPanel"

BaseBeginnerPanel = BeginnerPanel
EggsBeginnerPanel = class(BaseBeginnerPanel)
function EggsBeginnerPanel:create( ... )
	local panel = EggsBeginnerPanel.new()
	panel:loadRequiredResource("ui/eggs/panel.json")
	panel:init()
	return panel
end
function EggsBeginnerPanel:init( ... )
	BaseBeginnerPanel.init(self)

	self.captain:setVisible(false)

	if PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) and DcUtil.getSubPlatform and DcUtil.getSubPlatform() == "he201507211442349840" then --江西移动活动
		self.ui:getChildByName("title2"):setVisible(false)
		self.ui:getChildByName("title3"):setVisible(false)
	elseif self:isBaiduPlatform() then
		self.ui:getChildByName("title1"):setVisible(false)
		self.ui:getChildByName("title3"):setVisible(false)
	elseif PlatformConfig:isQQPlatform() then
		self.ui:getChildByName("title1"):setVisible(false)
		self.ui:getChildByName("title2"):setVisible(false)
	else
		self.ui:getChildByName("title2"):setVisible(false)
		self.ui:getChildByName("title3"):setVisible(false)
	end
end
function EggsBeginnerPanel:popout( ... )
	BaseBeginnerPanel.popout(self)

	self.ui:setPositionY(self.ui:getPositionY()-150)
end

BaseUpdateSuccessPanel = UpdateSuccessPanel
EggsUpdateSuccessPanel = class(BaseUpdateSuccessPanel)
function EggsUpdateSuccessPanel:create(rewards)
	local panel = EggsUpdateSuccessPanel.new()
	panel:loadRequiredResource("ui/eggs/panel.json")
	panel:init(rewards)
	return panel
end
function EggsUpdateSuccessPanel:init( rewards )
	BaseUpdateSuccessPanel.init(self,rewards)

	self.ui:getChildByName("title"):setVisible(false)
	
	local diffY = self.ui:getChildByName("bg"):getPreferredSize().height - 520
	for i=1,3 do
		local bubble = self.ui:getChildByName("bubble" .. i)
		bubble:setPositionY(bubble:getPositionY() - diffY)
	end
end
function EggsUpdateSuccessPanel:popoutShowTransition( ... )
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	self:setScale(0.9)
	local size = self.ui:getChildByName("bg"):getGroupBounds().size

	self:setPositionX(visibleSize.width/2 - size.width/2)
	self:setPositionY(-(visibleSize.height/2 - size.height/2))
end

function EggsUpdateSuccessPanel:popout( ... )
	BaseUpdateSuccessPanel.popout(self)
end

BaseMarkPanel = MarkPanel
EggsMarkPanel = class(BaseMarkPanel)
function EggsMarkPanel:create( scaleOriginPosInWorld )
	local markPanel = EggsMarkPanel.new()
	markPanel:loadRequiredResource("ui/eggs/panel.json")
	markPanel:init(scaleOriginPosInWorld)
	return markPanel
end
function EggsMarkPanel:init( scaleOriginPosInWorld )
	BaseMarkPanel.init(self,scaleOriginPosInWorld)

	self.newCaptain:setVisible(false)
end

-- BeginnerPanel = EggsBeginnerPanel
-- UpdateSuccessPanel = EggsUpdateSuccessPanel
-- MarkPanel = EggsMarkPanel