MissionRulesPanel = class(BasePanel)

function MissionRulesPanel:create(onClose , onShowMange)
	local instance = MissionRulesPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.mission_rules)
	instance:init(onClose , onShowMange)
	return instance
end

function MissionRulesPanel:init(onClose , onShowMange)

	local ui = self:buildInterfaceGroup("missionPanel.Rules/missionRulesPanel")
	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui)

	self.closeBtnRes = self.ui:getChildByName("btn_close")
	self.closeBtn = GroupButtonBase:create(self.closeBtnRes)
	--self.closeBtn:setString(Localization:getInstance():getText("mission.missionPanel.getReward.failed1"))
	self.closeBtn:setString("知道了")
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
									function (event) 
	                              		if onClose then onClose() end
									end)


	self.btn_story = ui:getChildByName("btn_story")
	self.btn_story:setAnchorPoint(ccp(0.5,0.5))
	self.btn_story:setTouchEnabled(true, 0, false)
	self.btn_story:setButtonMode(true)
	self.btn_story:addEventListener(DisplayEvents.kTouchTap, 
									function (event) 
	                              		if onShowMange then onShowMange() end
									end)

	self.text_des_1 = ui:getChildByName("text_des_1")
	self.text_des_1:setString(Localization:getInstance():getText("mission.missionPanel.rules.des_1"))
	self.text_des_2 = ui:getChildByName("text_des_2")
	self.text_des_2:setString(Localization:getInstance():getText("mission.missionPanel.rules.des_2"))
	self.text_des_3 = ui:getChildByName("text_des_3")
	self.text_des_3:setString(Localization:getInstance():getText("mission.missionPanel.rules.des_3"))
end