local UIHelper = require 'zoo.panel.UIHelper'
local Misc = require('zoo.quarterlyRankRace.utils.Misc')

Mark2019BuQianPanel = class(BasePanel)
function Mark2019BuQianPanel:create( BuQianCall, day, PackOpenAnim )
    local panel = Mark2019BuQianPanel.new()
    panel:init(BuQianCall,day, PackOpenAnim)
    return panel
end

function Mark2019BuQianPanel:init( BuQianCall,day, PackOpenAnim )

    self.BuQianCall = BuQianCall
    self.BuQianDay = day
    self.PackOpenAnim = PackOpenAnim

    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/buqianPanel")
    BasePanel.init(self, ui)

    local BuQianCost = Mark2019Manager.getInstance():getReMarkCost()
    self.BuQianCost = BuQianCost

    local goldNum = self.ui:getChildByName('goldNum')
    goldNum:setString(""..self.BuQianCost)
    local srcPos = goldNum:getPosition()
    goldNum:setPosition( ccp(srcPos.x+3,srcPos.y-6))

    local okbtn = self.ui:getChildByName('btn')
    self.ok_btn = GroupButtonBase:create(okbtn)
    self.ok_btn:setString("确定")
    self.ok_btn:setColorMode(kGroupButtonColorMode.green)
    self.ok_btn:ad(DisplayEvents.kTouchTap, function( )
        self:reMarkSure()
        if self.PackOpenAnim then self.PackOpenAnim() end
    end) 
end

function Mark2019BuQianPanel:_close()
    Mark2019Manager.getInstance():removeObserver(self)
    PopoutManager:sharedInstance():remove(self)
end

function Mark2019BuQianPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 150)

    self:popoutShowTransition()
end

function Mark2019BuQianPanel:popoutShowTransition()
    Mark2019Manager.getInstance():addObserver(self)
end

function Mark2019BuQianPanel:reMarkSure()

    local UsrCoin = UserManager.getInstance().user:getCash()
    
    local bGoldEnouth = false

    if UsrCoin >= self.BuQianCost then
        bGoldEnouth = true
    end

    if bGoldEnouth then
        -- body
        self:onCloseBtnTapped()

        local BuqianCall = self.BuQianCall
        local Mark2019SelectPanel = require "zoo.panel.Mark2019.Mark2019SelectPanel"
        Mark2019SelectPanel:create(BuqianCall, true, self.BuQianDay ):popout()
    else
        Mark2019Manager.getInstance():goldNotEnough()
    end
end

function Mark2019BuQianPanel:setPositionForPopoutManager()
    local vSize = CCDirector:sharedDirector():getVisibleSize()
    local posAdd =  CCDirector:sharedDirector():getVisibleOrigin().y
    self:setPosition(ccp(self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)))
end

function Mark2019BuQianPanel:onCloseBtnTapped( ... )
    self:_close()

    if self.BuQianCall then self.BuQianCall() end
end

function Mark2019BuQianPanel:onPassDay()
    self:_close()
end


return Mark2019BuQianPanel