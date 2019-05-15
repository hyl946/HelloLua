require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
local UIHelper = require 'zoo.panel.UIHelper'
local XFLogic = require 'zoo.panel.xfRank.XFLogic'
local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'

XFPreheatButton = class(IconButtonBase)

function XFPreheatButton:ctor()
    self.idPre = "XFPreheatButton"
    self.playTipPriority = 500
end

function XFPreheatButton:playHasNotificationAnim(...)
    IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function XFPreheatButton:stopHasNotificationAnim(...)
    IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end


function XFPreheatButton:init()
    self.ui = UIHelper:createUI('ui/xf_homescene_icon.json', 'xf_homescene_icon/xfBtn')
    IconButtonBase.init(self, self.ui)

    self["tip"..IconTipState.kNormal] = '即将开启！'
    self["tip"..IconTipState.kExtend] = Localization:getInstance():getText("xfBtn.race.button.tip.extend")
    self["tip"..IconTipState.kReward] = '满星巅峰榜开启！'

    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)

    self.dot = self.ui:getChildByPath('wrapper/redDot')
    self.dot:setVisible(false)

    self.tipState = nil

    self.tickTaskMgr = TickTaskMgr.new()
    local REFRESH_UI_ID = 1
    self.tickTaskMgr:setTickTask(REFRESH_UI_ID, function ( ... )
        self:update()
    end)


end

function XFPreheatButton:onAddToStage( ... )
    if self.isDisposed then return end
    self.tickTaskMgr:step()
    self.tickTaskMgr:start()
end

function XFPreheatButton:dispose()
    self.tickTaskMgr:stop()
    IconButtonBase.dispose(self)
end


function XFPreheatButton:update()
    if self.isDisposed then return end

    if XFLogic:isPreheadEnabled() then
        self:showTip(IconTipState.kNormal)
        self.dot:setVisible(false)
    else
        self:showTip(IconTipState.kReward)
        self.dot:setVisible(true)
    end
end

function XFPreheatButton:create()
    local btn = XFPreheatButton.new()
    btn:init()
    btn:initShowHideConfig(ManagedIconBtns.XF_PREHEAT)
    return btn
end

function XFPreheatButton:showTip(tipState)
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
