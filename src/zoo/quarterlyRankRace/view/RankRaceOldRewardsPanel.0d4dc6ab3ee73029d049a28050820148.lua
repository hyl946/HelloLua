local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceOldRewardsPanel = class(BasePanel)

function RankRaceOldRewardsPanel:create(rewards)

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end
    rrMgr = RankRaceMgr:getInstance()
    local panel = RankRaceOldRewardsPanel.new()
    panel:init(rewards)
    return panel
end

function RankRaceOldRewardsPanel:init(_rewards)

    local ui = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/old_rewards')
	BasePanel.init(self, ui)
    
    local rewardsMap = {}

    for _, v in ipairs(_rewards) do
        if not rewardsMap[v.itemId] then
            rewardsMap[v.itemId] = 0
        end
        rewardsMap[v.itemId] = rewardsMap[v.itemId] + v.num
    end

    self.rewards = {}

    for itemId, num in pairs(rewardsMap) do
        table.insert(self.rewards, {
            itemId = itemId,
            num = num,
        })
    end

    table.sort(self.rewards, function ( a, b )
        if a.itemId == 2 then
            return false
        elseif b.itemId == 2 then
            return true
        else
            return false
        end
    end)

    local scrollView = self.ui:getChildByPath('up/content')
    local fBox = scrollView:findChildByName('item1')
    fBox:setBorder(0, 8)

    for _, v in ipairs(self.rewards or {}) do
        local itemUI = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/2@RewardItem')
        itemUI:setRewardItem(v)

        if itemUI.num then
            itemUI.num:setTag(HeDisplayUtil.kIgnoreGroupBounds)
        end

        fBox:addItem(itemUI)
    end

    scrollView:updateItemsHeight()
    scrollView:pluginRefresh()

    self.button = GroupButtonBase:create(self.ui:getChildByPath('button'))
    self.button:setString('领取')
    self.button:ad(DisplayEvents.kTouchTap, function ( ... )
        self:onCloseBtnTapped()
    end)


end


function RankRaceOldRewardsPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceOldRewardsPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function RankRaceOldRewardsPanel:onCloseBtnTapped( ... )
    local rewards = self.rewards
    local anim = FlyItemsAnimation:create(Misc:clampRewardsNum(rewards))
    local bounds = self.ui:getGroupBounds()
    anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
    anim:play()
    self:_close()
end


return RankRaceOldRewardsPanel
