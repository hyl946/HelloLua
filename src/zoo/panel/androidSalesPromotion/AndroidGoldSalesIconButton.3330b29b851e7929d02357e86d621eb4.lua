require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

AndroidGoldSalesIconButton = class(IconButtonBase)

function AndroidGoldSalesIconButton:create(time)
    local instance = AndroidGoldSalesIconButton.new()
    instance:init(time)
    return instance
end

function AndroidGoldSalesIconButton:init(time)
    self.ui = ResourceManager:sharedInstance():buildGroup('android_discount_icon')
    IconButtonBase.init(self, self.ui)
    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)
    self.timeTxt = self.wrapper:getChildByName('time')

    --self.timeTxt:setScale(1.15)
    self.timeTxt:setText('00:00:00')
    self.timeTxt:setAnchorPoint(ccp(0.5,1))
    self.timeTxt:setPositionX(self.wrapperSize.width/2 - self.wrapper:getPositionX())

    self:setCdTime(time or 0)

    local secondPerFrame	= 1 / 60
    local scale1	= CCScaleTo:create(secondPerFrame * (13 - 1), 1.076,	0.875)
	local scale2	= CCScaleTo:create(secondPerFrame * (25 - 13),  0.911, 1.12)
	local scale3	= CCScaleTo:create(secondPerFrame * (36 - 25),  0.981, 1.024)
	local scale4	= CCScaleTo:create(secondPerFrame * (50 - 36),  1, 1)

	local actionArray = CCArray:create()
	actionArray:addObject(scale1)
	actionArray:addObject(scale2)
	actionArray:addObject(scale3)
	actionArray:addObject(scale4)

	local seq 	= CCSequence:create(actionArray)
	local icon = self.wrapper:getChildByName('icon')
	icon:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.0))
	icon:runAction(CCRepeatForever:create(seq))
end

function AndroidGoldSalesIconButton:stopTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function AndroidGoldSalesIconButton:setCdTime(seconds)
    self:stopTimer()
    self.cdTime = seconds
    local function onTick()
    	if self.isDisposed then return end
        if self.cdTime < 0 then 
        	self:stopTimer()
        	return 
        end
        self.cdTime = AndroidSalesManager.getInstance():getGoldSalesLeftSeconds() 
        if self.cdTime >= 0 then
            self.timeTxt:setText(convertSecondToHHMMSSFormat(self.cdTime))
        end
    end
    if self.cdTime > 0 then
        self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    end
    onTick()
end

function AndroidGoldSalesIconButton:stopIconAni()
    local icon = self.wrapper:getChildByName('icon')
    icon:stopAllActions()
    icon:setScale(1)
end

function AndroidGoldSalesIconButton:dispose()
    self:stopTimer()
    IconButtonBase.dispose(self)
end