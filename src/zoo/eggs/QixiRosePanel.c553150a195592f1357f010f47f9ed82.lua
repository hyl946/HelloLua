
local QixiRosePanel = class(BasePanel)

function QixiRosePanel:create()
    local panel = QixiRosePanel.new()
    panel:init()
    return panel
end

function QixiRosePanel:init()
    local ui = ResourceManager:sharedInstance():buildGroup("qixi_2017/panel")
    BasePanel.init(self, ui)
    

    local bglight = CommonEffect:buildGetPropLightAnim(localize('qixi.2017.weekly.title') , true)
    bglight:setPosition(ccp(480, -640))
    bglight:setScale(1.2)
    self.ui:addChild(bglight)

    local bounds = bglight:getGroupBounds()
    local waterSprite = Sprite:createWithSpriteFrameName('qixi_2017/big_rose0000')

    waterSprite:setPosition(ccp(480, -640))
    self.ui:addChild(waterSprite)

    local inputLayer = Layer:create()
    inputLayer:changeWidthAndHeight(960, 1280)
    self.ui:addChild(inputLayer)

    inputLayer:setTouchEnabled(true)
    inputLayer:ad(DisplayEvents.kTouchTap, function ()
        self:onCloseBtnTapped()
    end)

    inputLayer:setPositionY(-1280)
end

function QixiRosePanel:_close()
    PopoutManager:sharedInstance():remove(self)
end

function QixiRosePanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
    PopoutManager:sharedInstance():add(self, false)
    self.allowBackKeyTap = true

    self:popoutShowTransition()
end

function QixiRosePanel:onCloseBtnTapped( ... )
    if self.isDisposed then
        return
    end

    self:_close()

    local QixiManager = require 'zoo.eggs.QixiManager'
    local visibleSize   = CCDirector:sharedDirector():getVisibleSize()
    local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

    QixiManager:getInstance():tryPlayFlyRoseAnimation(ccp(
        visibleOrigin.x + visibleSize.width/2,
        visibleOrigin.y + visibleSize.height/2
    ))
end

function QixiRosePanel:popoutShowTransition( ... )
    setTimeOut(function ( ... )
        if self.isDisposed then
            return
        end
        self:onCloseBtnTapped()
    end, 2)
end

return QixiRosePanel
