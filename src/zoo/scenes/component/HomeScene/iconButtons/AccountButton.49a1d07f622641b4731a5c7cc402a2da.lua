local PersonalInfoReward = require 'zoo.PersonalCenter.PersonalInfoReward'

AccountButton = class(IconButtonBase)

function AccountButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_card')
    self.redDot = self:addRedDot()

    -- Init Base
    IconButtonBase.init(self, self.ui)

    local function refreshDot()
        if self.isDisposed then return end

        -- self.rewardTip:setVisible(false)
        self.redDot:setVisible(false)
        self.newFlag:setVisible(false)

        -- local rewardTipVisible = PersonalInfoReward:isInRewardTime()
        -- if rewardTipVisible then
        --     self.rewardTip:setVisible(true)
        --     return
        -- end

        local showNewFlag = HeadFrameType:setProfileContext():hasNewHeadFrame()
        if showNewFlag then
            self.newFlag:setVisible(true)
            return
        end

        local dotTipVisible = false
        if PersonalCenterManager:getData(PersonalCenterManager.SHOW_ACCBTN_OUTSIDE_REDDOT) then
            dotTipVisible = true
        end

        if dotTipVisible then
            self.redDot:setVisible(true)
            return
        end
    end

    -- local RewardTip = require 'zoo.scenes.component.HomeScene.RewardTip'
    -- local rewardTip = nil
    -- rewardTip = RewardTip:create(ResourceManager:sharedInstance():buildGroup("timer.peron.reward/timer"))
    -- rewardTip:setPosition(ccp(30, 20))
    -- self.rewardTip = rewardTip
    -- self.ui:addChild(rewardTip)

    local newFlag = ResourceManager:sharedInstance():buildGroup('home_scene_icon/common_res/icon_flag_new')
    newFlag:setPosition(ccp(30, 15))

    self.ui:addChild(newFlag)
    newFlag:setVisible(false)
    self.newFlag = newFlag

    -- rewardTip.onStatusChange = function ()
    --     if self.isDisposed then return end
    --     if PersonalInfoReward:isInRewardTime() then
    --         rewardTip:setData(PersonalInfoReward:getReward(), PersonalInfoReward:getEndTimeInSec())
    --     end
    --     rewardTip:setVisible(PersonalInfoReward:isInRewardTime())
    --     refreshDot()
    -- end
    -- rewardTip:setVisible(false)
    -- PersonalInfoReward:getInfoAsync(rewardTip.onStatusChange)
        
    HeadFrameType:getEventMgr():ad(HeadFrameType.Events.kUpdateShowTime, function ()
        refreshDot()
    end)

    refreshDot()
end

function AccountButton:create()
    local instance = AccountButton.new()
    instance:init()
    return instance
end