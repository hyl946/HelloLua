require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

RankRaceButton = class(IconButtonBase)

function RankRaceButton:ctor()
    self.idPre = "RankRaceButton"
    self.playTipPriority = 1010
end

function RankRaceButton:playHasNotificationAnim(...)
    IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function RankRaceButton:stopHasNotificationAnim(...)
    if not RankRaceMgr:getInstance():hasAvailableRewards() then
        IconButtonManager:getInstance():removePlayTipActivityIcon(self)
    end
end


function RankRaceButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_rank_race')

    IconButtonBase.init(self, self.ui)

    self["tip"..IconTipState.kNormal] = Localization:getInstance():getText("rank.race.button.tip.normal")
    self["tip"..IconTipState.kExtend] = Localization:getInstance():getText("rank.race.button.tip.extend")
    self["tip"..IconTipState.kReward] = Localization:getInstance():getText("rank.race.button.tip.reward")

    self.rewardDot = self:addRedDotReward()
    self.numTip = self:addRedDotNum()

    self.rewardDot:setVisible(false)

    self:update()

    GamePlayEvents.addPassLevelEvent(function ()
        self:update()
    end)

    RankRaceMgr:getInstance():addObserver(self)
end

function RankRaceButton:dispose()
    RankRaceMgr:getInstance():removeObserver(self)
    if self.scheduler then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
    IconButtonBase.dispose(self)
end

function RankRaceButton:onNotify( obKey )
    -- body
    if obKey == RankRaceOBKey.kPassDay or obKey == RankRaceOBKey.kRewardInfoChange or obKey == RankRaceOBKey.kOpenMainPanel then
        self:update()
    end
end

function RankRaceButton:scheduleUpdate()
    local function update()
        self:showTime()
    end

    local isWeekly = self:isWeekly()
    if not self.schedule and isWeekly then
        self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
    elseif not isWeekly then
        self:unscheduleUpdate()
    end
    update()
end

function RankRaceButton:unscheduleUpdate()
    if self.schedule then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
        self.schedule = nil
    end
end

function RankRaceButton:isWeekly()
    local startTime = RankRaceMgr:getInstance():getCurWeekStartTS()
    local weeklyStartTs = 5*24*3600 + startTime
    local now = Localhost:timeInSec()
    return weeklyStartTs <= now, 2*24*3600 - (now - weeklyStartTs)
end

function RankRaceButton:showTime()
    local isWeekly,remind = self:isWeekly()

    self.ui:getChildByName("week_race_lable"):setVisible(not isWeekly)

    if self.timeLabel then 
        self.timeLabel:setVisible(isWeekly)

        if isWeekly then
            self.timeLabel:setText(convertSecondToHHMMSSFormat(remind))
        end
    end
end

function RankRaceButton:hasRewards()
    return RankRaceMgr:getInstance():hasAvailableRewards()
end

function RankRaceButton:update()
    if self.isDisposed then return end
    self.numTip:setVisible(false)
    self.rewardDot:setVisible(false)

    self:stopHasNumberAni()
    self:stopHasRewardAni()
    self:stopRedDotJumpAni(self.rewardDot)


    if not RankRaceMgr:getInstance():isEnabled() then 
        return 
    end
    
    local hasRewards = RankRaceMgr:getInstance():hasAvailableRewards()
    local leftFreePlay = RankRaceMgr:getInstance():getLeftFreePlay()

    if leftFreePlay > 0 then
        self.numTip:setNum(leftFreePlay)
        self.numTip:setVisible(true)
        self:playHasNumberAni()
    elseif hasRewards then 
        self.rewardDot:setVisible(true)
        self:playRedDotJumpAni(self.rewardDot)
        self:playHasRewardAni()
    end

    if hasRewards then
        self:showTip(IconTipState.kReward)
    elseif leftFreePlay > 0 then
        self:showTip(IconTipState.kExtend)
    else
        self:showTip(IconTipState.kNormal)
        self:stopHasNotificationAnim()
    end

    local isWeekly, remind = self:isWeekly()
    if isWeekly then 
        self:startCountdown(remind + Localhost:timeInSec())
    end
end

function RankRaceButton:create()
    local btn = RankRaceButton.new()
    btn:init()
    btn:initShowHideConfig(ManagedIconBtns.RANK_RACE)
    return btn
end

function RankRaceButton:showTip(tipState)
    if not tipState then return end 

    if self.tipState == tipState then
        return
    end

    self:stopHasNotificationAnim()

    self.tipState = tipState
    self.id = self.idPre .. self.tipState
    local tips = self["tip"..self.tipState]
    if tips then 
        self:setTipPosition(IconButtonBasePos.LEFT)
        self:setTipString(tips)
        self:playHasNotificationAnim()
    end
end
