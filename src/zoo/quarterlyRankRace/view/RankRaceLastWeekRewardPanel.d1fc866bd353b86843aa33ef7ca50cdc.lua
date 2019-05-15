local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

local rrMgr


local RankRaceLastWeekRewardPanel = class(BasePanel)

function RankRaceLastWeekRewardPanel:create()

    if not RankRaceMgr then
        require 'zoo.quarterlyRankRace.RankRaceMgr'
    end
    rrMgr = RankRaceMgr:getInstance()
    local panel = RankRaceLastWeekRewardPanel.new()
    panel:init()
    return panel
end

function RankRaceLastWeekRewardPanel:init()

    local lastWeekLotteryRewards = rrMgr:getData():getLastWeekLotteryRewards()
    local lastWeekBoxRewards = rrMgr:getData():getLastWeekBoxRewards()
    local lastWeekBoxes = rrMgr:getData():getLastWeekBoxes()

    self.lastWeekBoxesForDC = table.clone(lastWeekBoxes, true)

    local resIndex = 1

    if #lastWeekLotteryRewards <= 0 then
        resIndex = 2
    elseif #lastWeekBoxes <= 0 then
        resIndex = 3
    end

    local ui = UIHelper:createUI('ui/RankRace/small_panel.json', 'rank.smallpan/last_reward_' .. resIndex)
	BasePanel.init(self, ui)
    
    self.fBox = self.ui:getChildByPath('up/fBox')
    self.bottom = self.ui:getChildByPath('bottom')

    if self.ui:getChildByPath('up') then
        local num = #lastWeekBoxes
        local scale = 1
        if num == 7 then
            scale = 0.9
        elseif num <= 3 then
            scale = 1.2
        end

        --获取上周的赛季
        local lastSeasonIndex = RankRaceMgr.getInstance():getSaijiIndex(RankRaceMgr.getInstance():getCurWeekIndex() - 1) 
        for i, v in ipairs(lastWeekBoxes) do
            local index = v
            if v == 7 then
                local Dan = RankRaceMgr.getInstance():getData():getLastWeekDan()
                local bigDan = math.ceil(Dan/3)
                if bigDan == 1 then
                    index = 8
                elseif bigDan == 2 then
                    index = 9
                elseif bigDan == 3 then
                    index = 10
                end
            end
            local itemRes = 'n.race.rank/s'..lastSeasonIndex .. '/box'..index

            local boxUI = UIHelper:createUI('ui/RankRace/reward.json', itemRes)
            boxUI:getChildByPath('3'):removeFromParentAndCleanup(true)
            boxUI:getChildByPath('2'):removeFromParentAndCleanup(true)
            boxUI:getChildByPath('target'):removeFromParentAndCleanup(true)
            boxUI.userData = {i}
            boxUI:setScale(scale)
            local bounds = boxUI:getGroupBounds()
            boxUI:setPositionX(bounds.size.width/2)
            boxUI:setPositionY(-bounds.size.height/2)
            self.fBox:addItem(boxUI)

            local index = i
            UIUtils:setTouchHandler(boxUI, function ( ... )
                if self.isDisposed then return end
                if not lastWeekBoxRewards[index] then 
                    return
                end
                local tipPanel = BoxRewardTipPanel:create({ rewards=table.clone(lastWeekBoxRewards[index].rewards or {}, true)})
                tipPanel:setTipString(Localization:getInstance():getText("rank.race.last.week.reward.tip.title"))
                self.ui:addChild(tipPanel)
                local bounds = boxUI:getGroupBounds()
                tipPanel:setArrowPointPositionInWorldSpace(0,bounds:getMidX(),bounds:getMidY())
            end)
        end

        if num == 1 then
            self.fBox:setBorder(20, 190)
        elseif num == 2 then
            self.fBox:setBorder(20, 90)
        elseif num <= 3 then
            self.fBox:setBorder(20, 0)
        elseif num == 7 then
            self.fBox:setBorder(0, 0)
            self.fBox:setMargin(-40, 0)
        else
            self.fBox:setMargin(-65, 10)
            self.fBox:setBorder(-30, 36)
        end
    end

    if self.ui:getChildByPath('bottom') then
        local lastTC1 = rrMgr:getData():getLastWeekTC1()

        local numUI = self.ui:getChildByPath('bottom/num')
        numUI:changeFntFile('fnt/addfriend4.fnt')
        numUI:setColor(hex2ccc3('663300'))
        numUI:setScale(1.3)
        numUI:setText(tostring(lastTC1))
        UIHelper:move(numUI, 0, -3)
        UIHelper:move(self.ui:getChildByPath('bottom/label/2'), math.max(numUI:getContentSize().width * 1.3 - 64, 0), 0)

        self.ui:getChildByPath('bottom/icon'):setRewardItem(lastWeekLotteryRewards[1])

        if resIndex == 1 or resIndex == 3 then
            local icon1 = self.ui:getChildByPath('bottom/label/1')
            local icon2 = self.ui:getChildByPath('bottom/label/4')

            if RankRaceMgr.getInstance():isOldUISeason() then
                icon2:setVisible(false)
            else
                icon1:setVisible(false)
            end
        end
    end

    self.button = GroupButtonBase:create(self.ui:getChildByPath('button'))
    self.button:setString('领取')
    self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
        self:getRewards()
    end))
end

function RankRaceLastWeekRewardPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function RankRaceLastWeekRewardPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function RankRaceLastWeekRewardPanel:getRewards( ... )
    rrMgr:receiveLastWeekRewards(function ( rewards )
        if self.isDisposed then return end

        if #rewards <= 0 then
            CommonTip:showTip(localize('rank.race.empty.last.week.rewards'))
            self:_close()
            return
        end
        
        local anim = FlyItemsAnimation:create( table.filter(Misc:clampRewardsNum(rewards), function ( v )
            return v.itemId ~= ItemType.RACE_TARGET_1
        end))
        local bounds = self.ui:getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()

        self:_close()

        DcUtil:UserTrack({
            category='weeklyrace2018', 
            sub_category='weeklyrace2018_get_last_week_reward',
            t1 = table.concat(self.lastWeekBoxesForDC, ' '),
        })
    end, function ( evt )
        -- body
        if self.isDisposed then return end
        self:_close()

        local errorCode = evt.data
        if errorCode then
            CommonTip:showTip(localize('error.tip.' .. errorCode))
        else
            CommonTip:showNetworkAlert()
        end
    end)
end

function RankRaceLastWeekRewardPanel:onCloseBtnTapped( ... )
    if self.isDisposed then return end
    self:_close()
end

function RankRaceLastWeekRewardPanel:turnTo( pageIndex )
    if self.isDisposed then return end
    self.page:turnTo(pageIndex)
end

return RankRaceLastWeekRewardPanel
