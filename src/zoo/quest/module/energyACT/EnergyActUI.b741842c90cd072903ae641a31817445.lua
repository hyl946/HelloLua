local UIHelper = require 'zoo.panel.UIHelper'
local TickTaskMgr = require 'zoo.areaTask.TickTaskMgr'
local IconHighlighter = require 'zoo.localActivity.PigYear.IconHighlighter'

local EnergyRewardsPanel = class(BasePanel)

local function getDayStartTimeByTS(ts)
    local utc8TimeOffset = 57600 -- (24 - 8) * 3600
    local oneDaySeconds = 86400 -- 24 * 3600
    return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local layoutUtils = require 'zoo.panel.happyCoinShop.utils'

local winSize = Director:sharedDirector():getWinSize()
local visibleSize = CCDirector:sharedDirector():getVisibleSize()

function EnergyRewardsPanel:create(energyMinutes)
   local EnergyRewardsPanel = EnergyRewardsPanel.new()
    EnergyRewardsPanel:init(energyMinutes)
    return EnergyRewardsPanel
end

function EnergyRewardsPanel:init(energyMinutes)

    self.__passDayListener = function ( ... )
        if self.isDisposed then return end
        self:onPassDay()
    end
    self:initUI(energyMinutes)
end


function EnergyRewardsPanel:registerEventListeners( ... )
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, self.__passDayListener)
end

function EnergyRewardsPanel:unregisterEventListeners( ... )
    GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kPassDay, self.__passDayListener)
end


function EnergyRewardsPanel:onPassDay( ... )
    if self.isDisposed then return end

	setTimeOut(function ( ... )
        if self.isDisposed then return end
        self:onCloseBtnTapped()
    end, 1)

end


function EnergyRewardsPanel:dispose()
    self:unregisterEventListeners()
    if self.tickTaskMgr then
        self.tickTaskMgr:stop()
        self.tickTaskMgr = nil
    end
    BasePanel.dispose(self)

    if self.floatIcon then
        if not self.floatIcon.isDisposed then
            self.floatIcon:remove()
        end
    end
    self.isDisposed = nil
end

function EnergyRewardsPanel:initUI(energyMinutes)
	   
    local EnergyActQuestManager = require 'zoo.quest.module.energyACT.EnergyActQuestManager'

    local ui 
	ui = UIHelper:createUI('tempFunctionRes/EnergyACT/panels.json', 'energy.act.2018.local/k1')
    self.ui = ui
    BasePanel.init(self, ui)
    self.tickTaskMgr = TickTaskMgr.new()
    self.tickTaskMgr:setTickTask(10000, function()
        if self.isDisposed then return end
    end)


    local bubble = self.ui:getChildByName('bubble')
    local label2 = self.ui:getChildByName('label2')
    local btn1 = self.ui:getChildByName('btn1')
    local btn2 = self.ui:getChildByName('btn2')
    local label1 = self.ui:getChildByName('label1')
    if label2 then
    	label2:setString(localize('恭喜您完成幸运任务，获得无限精力'))
    	label1:setString(localize('今日24点前可领取，领取后即可使用，不会进入背包哦！'))
        local gbtn1
    	local gbtn2

        gbtn2 = GroupButtonBase:create(btn2)
    	gbtn2:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(function ( ... )
    		if self.isDisposed then return end

            gbtn1:setEnabled(false, true)
            gbtn2:setEnabled(false, true)

            local actIcon = EnergyActQuestManager:getInstance():getActivityIcon()
            if actIcon then
                -- local flyIcon = ResourceManager:sharedInstance():buildItemSprite(ItemType.INFINITE_ENERGY_BOTTLE)

                self.floatIcon = IconHighlighter:create(actIcon, self)
                self.floatIcon:show()

                local pos = self.icon:convertToWorldSpace(ccp(0, 0))
                pos = self:convertToNodeSpace(pos)
                self.icon:removeFromParentAndCleanup(false)
                self:addChild(self.icon)
                self.icon:setPosition(pos)

                local targetBounds = actIcon:getGroupBounds()
                local targetPos = ccp(targetBounds:getMidX(), targetBounds:getMidY())
                targetPos = self:convertToNodeSpace(targetPos)
                self.icon:setAnchorPointCenterWhileStayOrigianlPosition()
                self.icon:runAction(UIHelper:sequence{
                    CCJumpTo:create(0.5, targetPos, 200, 1),
                    CCCallFunc:create(function ( ... )
                        if self.isDisposed then return end
                        self.floatIcon:remove()
                        self:onCloseBtnTapped()

                        if self.finishCallback then
                            self.finishCallback()
                        end
            
                    end)
                })

            end
            self.ui:setVisible(false)

    	end))

    	gbtn2:setColorMode(kGroupButtonColorMode.orange)

    	gbtn1 = GroupButtonBase:create(btn1)
    	gbtn1:ad(DisplayEvents.kTouchTap, 	preventContinuousClick(function ( ... )
			if self.isDisposed then return end
		  
            -- gbtn1:setEnabled(false, true)
            -- gbtn2:setEnabled(false, true)

            EnergyActQuestManager:getInstance():receiveTaskRewards(function ( ... )
                if self.isDisposed then return end

                local reward = {itemId = ItemType.INFINITE_ENERGY_BOTTLE, 1}
                local anim = FlyItemsAnimation:create({reward})
                local bounds = bubble:getGroupBounds()
                anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
                anim:play()
                self:onCloseBtnTapped()
                if self.finishCallback then
                    self.finishCallback()
                end

                DcUtil:UserTrack({
                    category = 'weekend_energy',
                    sub_category = 'stage_end_get_reward',
                })

            end)


    	end))

        self.gbtn2 = gbtn2
    end

    local title1 = self.ui:getChildByName('title1')
    local title2 = self.ui:getChildByName('title2')

    local icon = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE, energyMinutes)
    bubble:addChild(icon)
    icon:setAnchorPoint(ccp(0.5, 0.5))
    icon:setScale(1.5)
    icon:setPosition(ccp(100, 125))
    self.icon = icon


    DcUtil:UserTrack({
        category = 'weekend_energy',
        sub_category = 'stage_end_reward',
    })

end

function EnergyRewardsPanel:setFinishCallback( callback )
    self.finishCallback = callback
end

function EnergyRewardsPanel:popout( ... )
    PopoutManager:sharedInstance():add(self, true)
    self:popoutShowTransition()
    return self
end

function EnergyRewardsPanel:onKeyBackClicked(...)
    if self.allowBackKeyTap then
        if self.gbtn2 then
            if self.isDisposed then return end
            if self.gbtn2.isEnabled then
                self.gbtn2:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, self, ccp(0, 0)))
            end
        else
            self:onCloseBtnTapped()
        end
    end
end

function EnergyRewardsPanel:onCloseBtnTapped( ... )
    if self.isDisposed then return end

    PopoutManager:sharedInstance():remove(self)
end


function EnergyRewardsPanel:popoutShowTransition()
    self.allowBackKeyTap = true
    self:registerEventListeners()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self.tickTaskMgr:start()
end

-- EnergyRewardsPanel:create():popout()

return {
    EnergyRewardsPanel = EnergyRewardsPanel,
}