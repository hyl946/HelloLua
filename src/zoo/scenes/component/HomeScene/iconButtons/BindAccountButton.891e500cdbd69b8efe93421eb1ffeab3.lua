require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
BindAccountButton = class(IconButtonBase)

function BindAccountButton:create(is360, time, pushType)
    local instance = BindAccountButton.new()
    if instance:init(is360, time, pushType) then 
        instance:initShowHideConfig(ManagedIconBtns.BIND_ACCOUNT)
        return instance
    else
        return nil
    end
end

function BindAccountButton:init(is360, time, pushType)
    if is360 then 
        self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_bind_360')
    else
        self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_bind')
    end

    IconButtonBase.init(self, self.ui)
    
    self.rewardIcon = self:addRedDotReward()
    if time > 0 then 
        self:playRedDotJumpAni(self.rewardIcon)
        self:playHasRewardAni()
    end

    self:setCdTime(time or 0)
    self:playOnlyIconAnim()
    return true
end

function BindAccountButton:stopTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function BindAccountButton:setCdTime(seconds)
    self:stopTimer()
    self.cdTime = seconds
    local function onTick()
    	if self.isDisposed then return end
        if self.cdTime < 0 then 
        	self:stopTimer()
            self.rewardIcon:setVisible(false)
            self:stopRedDotJumpAni(self.rewardIcon)
            self:stopHasRewardAni()
            self:setCustomizedLabel('账号绑定')

        	return
        end
        self.cdTime = PushBindingLogic:getAwardTimeLeft()
        if self.cdTime >= 0 then
            local timeStr = convertSecondToHHMMSSFormat(self.cdTime)
            self:setCustomizedLabel(timeStr)
            PushBindingLogic:updatePanelCountDown(timeStr)
        else
            self:setCustomizedLabel('账号绑定')
        end
    end

    if self.cdTime > 0 then
        self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    end
    onTick()
end

function BindAccountButton:dispose()
    self:stopTimer()
    IconButtonBase.dispose(self)
end