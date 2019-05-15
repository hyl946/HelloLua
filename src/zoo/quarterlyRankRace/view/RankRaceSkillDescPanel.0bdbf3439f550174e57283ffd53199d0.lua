
local UIHelper = require 'zoo.panel.UIHelper'

local RankRaceSkillDescPanel = class(BasePanel)

function RankRaceSkillDescPanel:create()
    local panel = RankRaceSkillDescPanel.new()
    panel:init()
    return panel
end

function RankRaceSkillDescPanel:init()
    local ui = UIHelper:createUI("ui/RankRace/skill_desc.json", "skill.desc.panel.du/panel")
	BasePanel.init(self, ui)

	self.ui:getChildByPath('label'):setString(localize('rank.race.skill.desc.label'))
end

function RankRaceSkillDescPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceSkillDescPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

	RankRaceMgr:getInstance():getData():setSkillGuideFlag()
end

function RankRaceSkillDescPanel:onCloseBtnTapped( ... )
    self:_close()
end

return RankRaceSkillDescPanel
