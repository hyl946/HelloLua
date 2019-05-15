require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

ThanksgivingButton = class(IconButtonBase)

function ThanksgivingButton:init()
    if _G.isLocalDevelopMode then printx(0, "ThanksgivingButton init") end
    self.ui = self.builder:buildGroup('Thanksgiving/thanksgivingButton')
    IconButtonBase.init(self, self.ui)
    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)

    self.redDot = self.wrapper:getChildByName('redDot')
    self.num 	= self.wrapper:getChildByName('num')
    self.rewardFlag = self.wrapper:getChildByName('rewardFlag')
    self.rewardFlag:setAnchorPointCenterWhileStayOrigianlPosition(ccp(0.5, 0.5))

    self:update()
end

local maData = nil
local config = nil
function ThanksgivingButton:update()
    if not self or self.isDisposed then return end

    if not _G.thanksgivingLoadComplete then 
        self:updateNumFlag(false)
        self:updateRewardFlag(false)
        return 
    end

    if not maData then
        maData = require("activity.Thanksgiving.Data")
    end
    if not config then
        config = require("activity/Thanksgiving/Config.lua")
    end

    if maData and config then
        if config.isEndActivity() then -- 活动已结束，需要移除icon
            if self.remove then self.remove() end
            return      
        end

        local hasReward = maData.getInstance():hasReward()
        local number = maData.getInstance().freePlay or 0
        local toAcceptsNumber = maData.getInstance().toAccepts and #maData.getInstance().toAccepts or 0
        number = number + toAcceptsNumber

        if hasReward then
            self:updateNumFlag(false)
            self:updateRewardFlag(true)
        elseif not config.isEndPlayGame() and number > 0 then
            self:updateRewardFlag(false)
            self:updateNumFlag(number > 0, number)
        else
            self:updateNumFlag(false)
            self:updateRewardFlag(false)
        end
    else
        self:updateNumFlag(false)
        self:updateRewardFlag(false)
    end
end

function ThanksgivingButton:updateRewardFlag(visible)
	if visible then
		self.rewardFlag:setVisible(true)
        if not self.rewardFlag.isRunningAction then
	    	self.rewardFlag:runAction(self:buildAnimation())
	    	self.rewardFlag.isRunningAction = true
	    end
	else
		self.rewardFlag:stopAllActions()
    	self.rewardFlag.isRunningAction = false
    	self.rewardFlag:setVisible(false)
	end
end

function ThanksgivingButton:updateNumFlag(visible, number)
	if visible and number > 0 then
		self.num:setString(tostring(number))
        self.num:setVisible(true)
        self.redDot:setVisible(true)
	else
		self.num:setVisible(false)
        self.redDot:setVisible(false)
	end
end

function ThanksgivingButton:create(...)
    local instance = ThanksgivingButton.new()
    if instance then 
    	instance.builder = InterfaceBuilder:createWithContentsOfFile("flash/scenes/homeScene/thanksgiving_icon.json")
    	instance:init()
    end
    return instance
end

function ThanksgivingButton:showTip(tip)
    self:setTipPosition(IconButtonBasePos.RIGHT)
    self:setTipString(tip)
    IconButtonBase.playHasNotificationAnim(self)
end

function ThanksgivingButton:dispose()
	IconButtonBase.dispose(self)
	InterfaceBuilder:unloadAsset("flash/scenes/homeScene/thanksgiving_icon.json")
end

function ThanksgivingButton:buildAnimation()
    local expand1 = CCScaleTo:create(7/24, 1.2)
    local shrink1 = CCScaleTo:create(7/24, 1)
    local expand2 = CCScaleTo:create(7/24, 1.2)
    local shrink2 = CCScaleTo:create(7/24, 1)
    local delay = CCDelayTime:create(90/24)
    local actions = CCArray:create()
    actions:addObject(expand1)
    actions:addObject(shrink1)
    actions:addObject(expand2)
    actions:addObject(shrink2)
    actions:addObject(delay)
    local repeatAction = CCRepeatForever:create(CCSequence:create(actions))
    return repeatAction
end

return ThanksgivingButton