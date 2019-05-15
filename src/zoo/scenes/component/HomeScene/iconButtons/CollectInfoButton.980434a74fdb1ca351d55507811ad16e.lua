require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"


CollectInfoButton = class(IconButtonBase)

function CollectInfoButton:create(removeFunc)
    local instance = CollectInfoButton.new()
    instance:init(removeFunc)
    return instance
end

function CollectInfoButton:init(removeFunc)
    self.removeFunc = removeFunc

    self.ui = ResourceManager:sharedInstance():buildGroup('collectInfoIcon')
    local wrapperUI = self.ui:getChildByName("wrapper")
    local icon = wrapperUI:getChildByName("icon")

    IconButtonBase.init(self, self.ui)

    self.physicalReward = CDKeyManager:getInstance():getPhysicalReward()
    if not self.physicalReward then
        return
    end

    self.timeTxt = self.wrapper:getChildByName('time')

    --self.timeTxt:setScale(1.15)
    self.timeTxt:setText('00:00:00')
    self.timeTxt:setAnchorPoint(ccp(0.5,1))
    self.timeTxt:setPositionX(self.wrapperSize.width/2 - self.wrapper:getPositionX())

    wrapperUI:addEventListener(DisplayEvents.kTouchTap, function()
        RewardCollectInfoPanel:create(self.physicalReward):popout()
    end)

    self:setCdTime()
end


function CollectInfoButton:setCdTime()
    
    local function onTick()
        local leftTime = self.physicalReward.endTime/1000 - Localhost:time()/1000 
        -- if _G.isLocalDevelopMode then printx(0, leftTime) end
        if leftTime <= 0 then
            self.removeFunc()
            return
        end
        self.timeTxt:setText(convertSecondToHHMMSSFormat(leftTime))
    end

    self.timeTxt:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
        CCCallFunc:create(onTick),
        CCDelayTime:create(1)
    )))
    onTick()

end