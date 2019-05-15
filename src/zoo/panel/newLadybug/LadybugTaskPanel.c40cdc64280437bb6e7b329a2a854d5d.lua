require "zoo.common.OneSecondTimer"

local TipCtrl = require 'zoo.panel.newLadybug.ctrls.TipCtrl'
local BtnCtrl = require 'zoo.panel.newLadybug.ctrls.BtnCtrl'
local TaskTargetCtrl = require 'zoo.panel.newLadybug.ctrls.TaskTargetCtrl'
local RewardCtrl = require 'zoo.panel.newLadybug.ctrls.RewardCtrl'

local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
local TimerCtrl = require 'zoo.panel.newLadybug.ctrls.TimerCtrl'
local OldRewardPanel = require 'zoo.panel.newLadybug.OldRewardPanel'

local LadybugGuidePanel = require 'zoo.panel.newLadybug.LadybugGuidePanel'
local DescPanel = require 'zoo.panel.newLadybug.DescPanel'
local SuccessFinishPanel = require 'zoo.panel.newLadybug.SuccessFinishPanel'



local LadybugTaskPanel = class(BasePanel)

function LadybugTaskPanel:create()
    local panel = LadybugTaskPanel.new()
    panel:loadRequiredResource("ui/newLadybug.json")
    panel:init()
    return panel
end

function LadybugTaskPanel:init()

    self.clock = OneSecondTimer:create()
    self.panelLuaName = "LadybugTaskPanel"
    
    local ui = self:buildInterfaceGroup("ladybug.new/panel")
	BasePanel.init(self, ui, "LadybugTaskPanel")
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)


    self:getChild('tip')
    self:getChild('timer')
    self:getChild('rewardContainer')
    self:getChild('taskTarget')
    self:getChild('playBtn')
    self:getChild('getRewardBtn')
    self:getChild('ladybug')
    self:getChild('title')
    self:getChild('desc')

    self.desc:setTouchEnabled(true)
    self.desc:ad(DisplayEvents.kTouchTap, function ( ... )
        DescPanel:create():popout()
    end)

    self.timerCtrl = TimerCtrl.new(self.timer)


    self.tipCtrl = TipCtrl.new(self.tip)

    self.playBtn = GroupButtonBase:create(self.playBtn)
    self.getRewardBtn = GroupButtonBase:create(self.getRewardBtn)

    self.btnCtrl = BtnCtrl.new(self.playBtn, self.getRewardBtn)

    self.btnCtrl:setPlayBtnCallback(function ( ... )
        -- if PopoutQueue:sharedInstance():isPopAll() == false then
        --     _G.nextLevelModel = true
        -- end

        if ModuleNoticeButton then
            ModuleNoticeButton:setPlayNext(false)
        end
        self:_close()
    end)
    self.btnCtrl:setGetRewardCallback(function ( ... )
        self:getReward()
    end)

    self.taskTargetCtrl = TaskTargetCtrl.new(self.taskTarget)

    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = Director:sharedDirector():getVisibleOrigin()

    self.showHideAnim = IconPanelShowHideAnim:create(self, ccp(
        origin.x + visibleSize.width/2,
        origin.y + visibleSize.height/2
    ))


    if not self:needPlayTargetAnim() then
        self.taskTargetCtrl:show()
    end

    self:refresh()

end

function LadybugTaskPanel:createGuideMask( ... )
    local wSize = Director:sharedDirector():getWinSize()
    local index = self.ui:getChildIndex(self.rewardContainer)
    local mask = LayerColor:createWithColor(ccc3(0, 0, 0), wSize.width, wSize.height)
    mask:ignoreAnchorPointForPosition(false)
    mask:setAnchorPoint(ccp(0, 0))
    local pos = self.ui:convertToNodeSpace(ccp(0, 0))
    self.ui:addChildAt(mask, index)
    mask:setPosition(ccp(pos.x, pos.y))
    mask:setOpacity(200)
    self.guideMask = mask
    self.guideMask:setVisible(false)
end


function LadybugTaskPanel:startClock( onTick )
    if self.clock.started then
        self.clock:stop()
    end
    self.clock:setOneSecondCallback(onTick)
    self.clock:start()
end

function LadybugTaskPanel:getReward( ... )
    if self.isDisposed then return end
    

    LadybugDataManager:getInstance():getReward(function ( rewardItems )

        LadybugDataManager:getInstance():refreshGoldCoinButton()

        if self.isDisposed then return end
        self:refresh()
        self:tryPlayTargetAnim()

        for index, item in ipairs(rewardItems) do
            local itemUI = nil


            if self.itemUIsByItemId and self.itemUIsByItemId[tonumber(item.itemId)] then
                itemUI = self.itemUIsByItemId[tonumber(item.itemId)]
                local bounds = itemUI:getGroupBounds()
                local startPos = ccp(bounds:getMidX(), bounds:getMidY())
                local anim = FlyItemsAnimation:create({item})
                anim:setWorldPosition(startPos)
                anim:play()
            elseif self.itemUIs and self.itemUIs[index] then
                itemUI = self.itemUIs[index].node
                local bounds = itemUI:getGroupBounds()
                local startPos = ccp(bounds:getMidX(), bounds:getMidY())
                local anim = FlyItemsAnimation:create({item})
                anim:setWorldPosition(startPos)
                anim:play()
            end
        end

        if LadybugDataManager:getInstance():hadAllFinish() then
            self:onCloseBtnTapped()

            SuccessFinishPanel:create():popout()
        end

    end)
end

function LadybugTaskPanel:buildRewards( rewards )

    if self.isDisposed then return end


    self:loadRequiredResource("ui/newLadybug.json")

    if self.itemUIs then
        for index, itemUI in ipairs(self.itemUIs) do
            itemUI.node:removeFromParentAndCleanup(true)
        end
        self.rewardCtrls = nil
        self.itemUIs = nil
    end

    self.rewardCtrls = {}
    self.itemUIs = {}

    self.itemUIsByItemId = {}

    for i = 1, #rewards do

        local itemUI = self:buildInterfaceGroup('ladybug.new/rewardItem')

        table.insert(self.rewardCtrls, RewardCtrl.new(itemUI))
        table.insert(self.itemUIs, {node = itemUI})
        self.rewardContainer:addChild(itemUI)

        self.rewardCtrls[i]:setReward(rewards[i])

        self.itemUIsByItemId[tonumber(rewards[i].itemId)] = itemUI


    end

    local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.horizontalLayoutItems(self.itemUIs)
end

function LadybugTaskPanel:setRewardState(state)
    if self.isDisposed then return end


    for index, ctrl in ipairs(self.rewardCtrls) do
        ctrl:setState(state)
    end
end

function LadybugTaskPanel:setRewardExtraState( extraState )
    if self.isDisposed then return end

    self.rewardCtrls[#self.rewardCtrls]:setExtraState(extraState)
end


function LadybugTaskPanel:getChild(childName)
    self[childName] = self.ui:getChildByName(childName)
end

function LadybugTaskPanel:_close()
    if self.isDisposed then return end

    if self.closeCallback then
        self.closeCallback()
    end

	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function LadybugTaskPanel:popout(closeCallback)
    self.closeCallback = closeCallback

    -- local visibleSize = Director:sharedDirector():getVisibleSize()
    -- local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
    -- local panelSize = CCSizeMake(878, 907)
    -- if _G.isLocalDevelopMode then printx(0, panelSize.width, panelSize.height) end

    -- self:setPositionY( - (visibleSize.height - panelSize.height) /2 )
    -- self:setPositionX((visibleSize.width - panelSize.width)/2)

	PopoutQueue.sharedInstance():push(self, true)
end

function LadybugTaskPanel:popoutShowTransition()
    local function onTransFinish() 
        self:createGuideMask()

        self.allowBackKeyTap = true 

        setTimeOut(function ( ... )
            if self.ui.isDisposed then
                return
            end

            self.__panelPopouted = true
            self:tryPlayTargetAnim()

        end, 3/24.0)


        local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
        local ladybugMgr = LadybugDataManager:getInstance()
        local taskInfo = ladybugMgr:getTaskInfo()

        if not self:popoutGuide() then
            self.tipCtrl:tryPlayAnim(taskInfo, true)
        else
            self.tipCtrl:tryPlayAnim(taskInfo, false)
        end

        self:checkOldReward()

    end
    self.showHideAnim:playShowAnim(onTransFinish)
end

function LadybugTaskPanel:getPlayTargetAnimKey( ... )
    local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
    local ladybugMgr = LadybugDataManager:getInstance()
    local taskInfo = ladybugMgr:getTaskInfo()
    local uid = UserManager:getInstance().user.uid or '12345'
    local key = 'new.ladybug.target.anim.show.' .. tostring(taskInfo.id) .. '.' .. uid
    return key
end

function LadybugTaskPanel:needPlayTargetAnim( ... )
    return CCUserDefault:sharedUserDefault():getBoolForKey(self:getPlayTargetAnimKey(), false) == false
end

function LadybugTaskPanel:hadPlayTargetAnim( ... )
    CCUserDefault:sharedUserDefault():setBoolForKey(self:getPlayTargetAnimKey(), true)
end

function LadybugTaskPanel:tryPlayTargetAnim( ... )
    if self.isDisposed then return end
    if not self.__panelPopouted then return end

    if self:needPlayTargetAnim() then
        self:hadPlayTargetAnim()
        self.taskTargetCtrl:playAnim()
    else
        self.taskTargetCtrl:show()
    end
end

function LadybugTaskPanel:checkOldReward( ... )
    LadybugDataManager:getInstance():getAllOldReward(function (rewardItems)
        if #rewardItems > 0 then
            OldRewardPanel:create(rewardItems):popout()
        end
    end)

    -- OldRewardPanel:create({
    --     {itemId=10058, num = 1},
    --     {itemId=10013, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},
    --     {itemId=14, num = 1},

    -- }):popout()
end


function LadybugTaskPanel:onCloseBtnTapped( ... )
    self:_close()
end

function LadybugTaskPanel:dispose( ... )
    if self.clock.started then
        self.clock:stop()
    end
    self.taskTargetCtrl:dispose()
    BasePanel.dispose(self, ...)
    
    ModuleNoticeButton:tryPopoutStartGamePanel()
end

function LadybugTaskPanel:refresh( ... )
    if self.isDisposed then return end


    local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
    local ladybugMgr = LadybugDataManager:getInstance()
    local taskInfo = ladybugMgr:getTaskInfo()
    local todayTask, finished = ladybugMgr:getTaskState(taskInfo)


    local rewardConfig = ladybugMgr:getRewardConfig(taskInfo.id)
    local taskTarget = ladybugMgr:getTaskTarget(taskInfo.id)

    self:buildRewards(rewardConfig)

    if taskTarget.taskType == LadybugDataManager.TaskTargetType.kMainLevel then

        local topLevelId = UserManager:getInstance().user:getTopLevelId()

        local star = 0

        local score = UserManager.getInstance():getUserScore(taskTarget.level)
        if score then
            star = score.star
        end

        self.taskTargetCtrl:setText(taskInfo.id, taskTarget.taskType, taskTarget.level, topLevelId, taskTarget.star, star, todayTask, finished)
    else
        self.taskTargetCtrl:setText(taskInfo.id, taskTarget.taskType, taskTarget.num, tonumber(taskInfo.extra) or 0, nil, nil, todayTask, finished)
    end

    if ladybugMgr:hadFinishWithoutGetReward(taskInfo) then


        if ladybugMgr:canGetReward(taskInfo) then
            self:setRewardState(RewardCtrl.State.kAvailable)

            self.btnCtrl:setState(BtnCtrl.State.kFinishAllowReward)
            self.timerCtrl:hide()
        else
            self:setRewardState(RewardCtrl.State.kNormal)
            self.btnCtrl:setState(BtnCtrl.State.kFinishNotAllowReward)

            self:startClock(function ( ... )
                if self.isDisposed then return end

                local taskInfo = ladybugMgr:getTaskInfo()
                local restTime = ladybugMgr:getRewardAvailableTime(taskInfo)
                self.timerCtrl:hide()

                if restTime <= 0 then
                    if self.clock.started then
                        self.clock:stop()
                    end
                    self:refresh()
                end

            end)
        end

        if ladybugMgr:isValidExtraReward(taskInfo) then
            self:setRewardExtraState(RewardCtrl.ExtraState.kNormal)
        else
            self:setRewardExtraState(RewardCtrl.ExtraState.kTimeOut)
        end

    else

        self.btnCtrl:setState(BtnCtrl.State.kGoing)

        self:setRewardState(RewardCtrl.State.kNormal)

        if ladybugMgr:isValidExtraReward(taskInfo) then
            self:setRewardExtraState(RewardCtrl.ExtraState.kNormal)

            self:startClock(function ( ... )
                
                if self.isDisposed then return end
                
                local taskInfo = ladybugMgr:getTaskInfo()
                local restTime = ladybugMgr:getExtraRewardRestTime(taskInfo)

                self.timerCtrl:setTime( restTime)


                if restTime <= 0 then
                    if self.clock.started then
                        self.clock:stop()
                    end
                    self:refresh()
                end

            end)

            local taskInfo = ladybugMgr:getTaskInfo()
            local restTime = ladybugMgr:getExtraRewardRestTime(taskInfo)
            self.timerCtrl:setTime( restTime)


        else
            self:setRewardExtraState(RewardCtrl.ExtraState.kTimeOut)
            self.timerCtrl:hide()
        end
    end
end

function LadybugTaskPanel:popoutGuide( ... )
    if self.isDisposed then return end
    if (not self.taskTarget) or self.taskTarget.isDisposed then return end

    local uid = UserManager:getInstance().user.uid or '12345'
    local key1 = 'new.ladybug.hongchao5.guide__1.showed.'..uid

    if CCUserDefault:sharedUserDefault():getBoolForKey(key1, false) == false then
        CCUserDefault:sharedUserDefault():setBoolForKey(key1, true)
        local bounds = self.timer:getGroupBounds()
        local origin = ccp(bounds.origin.x, bounds.origin.y)
        local size = CCSizeMake(bounds.size.width, bounds.size.height)

        self.guideMask:setVisible(true)
        LadybugGuidePanel:createGuideOne(origin, size, function ( ... )
            if self.isDisposed then return end
            self.guideMask:setVisible(false)
        end):popout()
        return true
    end
    return false
end

return LadybugTaskPanel
