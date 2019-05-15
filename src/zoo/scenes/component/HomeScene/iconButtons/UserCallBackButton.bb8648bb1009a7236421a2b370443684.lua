require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
local model = require("zoo/localActivity/UserCallBackTest/src/model/Model.lua"):getInstance()
UserCallBackButton = class(IconButtonBase)

function UserCallBackButton:ctor()
    self.idPre = "UserCallBackButton"
    self.playTipPriority = 1010
end

function UserCallBackButton:playHasNotificationAnim()
    IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function UserCallBackButton:stopHasNotificationAnim()
    IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end

function UserCallBackButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_continue_login')

    IconButtonBase.init(self, self.ui)
    self.rewardDot = self:addRedDotReward()
    self:updateReward()
end

function UserCallBackButton:dispose()
    IconButtonBase.dispose(self)
end

function UserCallBackButton:updateReward(forceTrue)
    self.rewardDot:setVisible(false)
    self:stopRedDotJumpAni(self.rewardDot)
    if model.received == false or forceTrue then
        self.rewardDot:setVisible(true)
        self:playRedDotJumpAni(self.rewardDot)
        self:playHasRewardAni()
    end
end

function UserCallBackButton:create()
    local btn = UserCallBackButton.new()
    btn:init()
    btn:initShowHideConfig(ManagedIconBtns.USER_CALLBACK)
    return btn
end

function UserCallBackButton:showTip(tipState)
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