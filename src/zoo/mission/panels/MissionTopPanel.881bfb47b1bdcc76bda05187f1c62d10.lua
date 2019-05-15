MissionTopPanel = class(BasePanel)

function MissionTopPanel:create(rewards , onReward , onCancel)
	local instance = MissionTopPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_1)
	instance:loadRequiredResource(PanelConfigFiles.mission_2)
	instance:init(rewards , onReward , onCancel)

	return instance
end

function MissionTopPanel:init(rewards , onReward , onCancel)

	local ui = self:buildInterfaceGroup("missionPanel_topPanel")
	--local ui = self:buildInterfaceGroup("MarketPanel")

	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)
	self.closeBtnRes	= self.ui:getChildByName("btn_close")
	self.closeBtn		= GroupButtonBase:create(self.closeBtnRes)

	self.rewardBtnRes	= self.ui:getChildByName("btn_reward")
	self.rewardBtn		= GroupButtonBase:create(self.rewardBtnRes)


	local function onCancelTap()
		if onCancel and type(onCancel) == "function" then
			onCancel()
		end
	end

	local function onRewardTap()
		if onReward and type(onReward) == "function" then
			onReward()
		end
	end

	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCancelTap)
	self.rewardBtn:addEventListener(DisplayEvents.kTouchTap, onRewardTap)

	self:buildReward(rewards)
end

function MissionTopPanel:buildReward(rewards)
	
end