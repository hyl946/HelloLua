require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

local MauNumberOneButton = class(IconButtonBase)

function MauNumberOneButton:ctor()
    self.idPre = "MauNumberOneButton"
    self.playTipPriority = 1011
end

function MauNumberOneButton:playHasNotificationAnim()
    IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function MauNumberOneButton:stopHasNotificationAnim()
    IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end

function MauNumberOneButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/local_activity/mau/btn_i_activity_mau')
    IconButtonBase.init(self, self.ui)

    self["tip"..IconTipState.kReward] = localize("领取24小时无限精力~")
    self.rewardDot = self:addRedDotReward()

    self:update()
end

function MauNumberOneButton:update()
    if self.isDisposed then return end

    self:playRedDotJumpAni(self.rewardDot)
    self:playHasRewardAni()

    self:showTip(IconTipState.kReward)
end

function MauNumberOneButton:showTip(tipState)
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

function MauNumberOneButton:create()
    local btn = MauNumberOneButton.new()
    btn:init()
    btn:initShowHideConfig(ManagedIconBtns.MAU_NUMBER_ONE)
    return btn
end

return MauNumberOneButton