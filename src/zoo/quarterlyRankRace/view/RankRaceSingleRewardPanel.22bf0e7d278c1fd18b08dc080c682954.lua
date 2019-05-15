local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceSingleRewardPanel = class(BasePanel)

function RankRaceSingleRewardPanel:create(rewards, close_cb)

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end

    rrMgr = RankRaceMgr:getInstance()

    local panel = RankRaceSingleRewardPanel.new()
    panel:init(rewards, close_cb)
    return panel
end

function RankRaceSingleRewardPanel:init(rewards, close_cb)
    local ui = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/linkReward')
	BasePanel.init(self, ui)

    self.rewards = rewards
    self.close_cb = close_cb

    self.ui:getChildByPath('reward'):setRewardItem(rewards[1])


    local button = GroupButtonBase:create(self.ui:getChildByPath('button'))
    button:setString('领取')
    button:ad(DisplayEvents.kTouchTap, function ( ... )
        if self.isDisposed then return end
        self:onCloseBtnTapped()
    end)
end

function RankRaceSingleRewardPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
    if self.close_cb then self.close_cb() end
end

function RankRaceSingleRewardPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
    PopoutQueue:sharedInstance():push(self, true, false)
	self.allowBackKeyTap = true
end

function RankRaceSingleRewardPanel:onCloseBtnTapped( ... )
    if self.isDisposed then return end
    self:_close()
end


return RankRaceSingleRewardPanel
