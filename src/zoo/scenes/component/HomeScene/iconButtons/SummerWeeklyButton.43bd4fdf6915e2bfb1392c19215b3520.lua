require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

SummerWeeklyButton = class(IconButtonBase)

function SummerWeeklyButton:ctor()
    self.idPre = "SummerWeeklyButton"
    self.playTipPriority = 1010
end

function SummerWeeklyButton:playHasNotificationAnim(...)
    IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function SummerWeeklyButton:stopHasNotificationAnim(...)
    IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end

function SummerWeeklyButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup("WeeklyRaceBtn")
    IconButtonBase.init(self, self.ui)

    self["tip"..IconTipState.kNormal] = Localization:getInstance():getText("weeklyrace.winter.panel.tip8")
    self["tip"..IconTipState.kExtend] = Localization:getInstance():getText("weekly.race.panel.rabbit.notice")
    self["tip"..IconTipState.kReward] = Localization:getInstance():getText("weeklyrace.winter.panel.tip5")

    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)

    self.numTip = getRedNumTip()
    self.wrapper:addChild(self.numTip)
    self.rewardDot = self.wrapper:getChildByName('reward_dot')
    self.rewardDot:setVisible(false)
    local pos = self.rewardDot:getPosition()
    self.numTip:setPositionXY(pos.x + 16, pos.y - 16)

    self:update()

    local function onTimeout()
        local now = Localhost:time() / 1000
        if compareDate(os.date("*t", now), os.date("*t", now - 1)) ~= 0 then
            self:update()
        end
    end
    self.scheduler = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 1, false)

    GamePlayEvents.addPassLevelEvent(function ( ... )
        self:update()
    end)
end

function SummerWeeklyButton:dispose()
    if self.scheduler then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduler)
    end
    IconButtonBase.dispose(self)
end

local SummerWeeklyTips = {
    kFirstTip = 1,
    kCanPlay = 2,
    kCanReward = 3,
}
function SummerWeeklyButton:update()
    if self.isDisposed then return end
    
    self.numTip:setVisible(false)
    self.rewardDot:setVisible(false)

    local matchData = SeasonWeeklyRaceManager:getInstance():getAndUpdateMatchData()
    local showPlayTip = SeasonWeeklyRaceManager:getInstance():isShowDailyFirstTip()
    local leftPlay = SeasonWeeklyRaceManager:getInstance():getLeftPlay()
    local tipShowed = SeasonWeeklyRaceManager:getInstance():getTipShowTimes(SummerWeeklyTips.kCanPlay)
    if SeasonWeeklyRaceManager:getInstance():hasReward() then 
        self.rewardDot:setVisible(true)
        -- self:stopHasNotificationAnim()
        self:showTip(IconTipState.kReward)
    else
        if leftPlay > 0 then
            self.numTip:setNum(leftPlay)
            self.numTip:setVisible(true)
        end

        if leftPlay > 0 then
            if tipShowed < 1 then
                -- self:stopHasNotificationAnim()
                self:showTip(IconTipState.kExtend)
            end
        else
            self:stopHasNotificationAnim()
            -- self:showTip(IconTipState.kNormal)
        end
    end
    if showPlayTip then SeasonWeeklyRaceManager:getInstance():onShowDailyFirstTip() end

    if leftPlay > 0 and tipShowed < 1 then
        self:playOnlyIconAnim()
    end
end

function SummerWeeklyButton:create(...)
    local btn = SummerWeeklyButton.new()
    btn:init()
    btn:initShowHideConfig(ManagedIconBtns.WEEKLY)
    return btn
end

function SummerWeeklyButton:showTip(tipState)
    if not tipState then return end 

    if self.tipState == tipState then
        return
    end

    self:stopHasNotificationAnim()

    self.tipState = tipState
    self.id = self.idPre .. self.tipState
    local tips = self["tip"..self.tipState]
    if tips then 
        self:setTipPosition(IconButtonBasePos.RIGHT)
        self:setTipString(tips)
        self:playHasNotificationAnim()
    end
end
