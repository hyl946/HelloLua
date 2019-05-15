
local LaborWaterPanel = class(BasePanel)

function LaborWaterPanel:create()
    local panel = LaborWaterPanel.new()
    panel:loadRequiredResource("ui/LaborDay.json")
    panel:init()
    return panel
end

function LaborWaterPanel:init()
    local ui = self:buildInterfaceGroup("labor.day.package/panel")
	BasePanel.init(self, ui)
    

    local bglight = CommonEffect:buildGetPropLightAnim('获得欢乐五一活动水壶！' , true)
	bglight:setPosition(ccp(480, -640))
	bglight:setScale(1.2)
	self.ui:addChild(bglight)

	local bounds = bglight:getGroupBounds()
	local waterSprite = Sprite:createWithSpriteFrameName('labor.day.package/tips/big_water0000')

	waterSprite:setPosition(ccp(480, -640))
	self.ui:addChild(waterSprite)

	local inputLayer = Layer:create()
	inputLayer:changeWidthAndHeight(960, 1280)
	self.ui:addChild(inputLayer)

	inputLayer:setTouchEnabled(true)
	inputLayer:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onCloseBtnTapped()
	end)

	inputLayer:setPositionY(-1280)
end

function LaborWaterPanel:_close()
	PopoutManager:sharedInstance():remove(self)
end

function LaborWaterPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, false)
	self.allowBackKeyTap = true

	self:popoutShowTransition()
end

function LaborWaterPanel:onCloseBtnTapped( ... )
	if self.isDisposed then
		return
	end

    self:_close()

    local LaborDayManager = require 'zoo.eggs.LaborDayManager'
    local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	LaborDayManager:getInstance():tryPlayFlyWaterDropAnimation(ccp(
		visibleOrigin.x + visibleSize.width/2,
		visibleOrigin.y + visibleSize.height/2
	))
end

function LaborWaterPanel:popoutShowTransition( ... )
	setTimeOut(function ( ... )
		if self.isDisposed then
			return
		end
		self:onCloseBtnTapped()
	end, 2)
end

return LaborWaterPanel
