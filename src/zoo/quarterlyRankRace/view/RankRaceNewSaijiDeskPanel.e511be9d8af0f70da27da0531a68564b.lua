
local UIHelper = require 'zoo.panel.UIHelper'

local RankRaceNewSaijiDeskPanel = class(BasePanel)

function RankRaceNewSaijiDeskPanel:create( done )
    local panel = RankRaceNewSaijiDeskPanel.new()
    panel:init( done )
    return panel
end

function RankRaceNewSaijiDeskPanel:init( done )
    local ui = UIHelper:createUI("ui/RankRace/newChange.json", "newChange/panel")
	BasePanel.init(self, ui)

    self.done = done

    --close
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function ( ... )
        self:onCloseBtnTapped()
    end)

--	self.ui:getChildByPath('label'):setString(localize('rank.race.skill.desc.label'))
end

function RankRaceNewSaijiDeskPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceNewSaijiDeskPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

	RankRaceMgr:getInstance():getData():setNewSkillGuideFlag()
end

function RankRaceNewSaijiDeskPanel:onCloseBtnTapped( ... )
    self:_close()

    if self.done then self.done() end
end

return RankRaceNewSaijiDeskPanel
