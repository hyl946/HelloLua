local InciteDescPanel = class(BasePanel)

function InciteDescPanel:create()
    local panel = InciteDescPanel.new()
    panel:loadRequiredResource(PanelConfigFiles.incite_panel)
    panel:init()
    return panel
end

function InciteDescPanel:init()
	self.m = InciteManager
	self.ui = self:buildInterfaceGroup("Incite/DescPanel")
    BasePanel.init(self, self.ui)

    self.closeBtn = self.ui:getChildByName('close')
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onCloseBtnTapped(event) 
	                               end)

	self.ui:getChildByName('text1'):setString("当幸运转盘出现时，即获得当日3次免费转盘机会")
	self.ui:getChildByName('text2'):setString("完整观看视频后，可以参与转盘开奖")
	self.ui:getChildByName('text3'):setString("转盘开奖完毕后，需要等待60分钟才能再次观看视频开奖呦")
	self.ui:getChildByName('title'):setString("活动说明")
	-- self.ui:getChildByName('title'):setColor(ccc3(25,134,201))
end

function InciteDescPanel:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)

    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()
        
    self:setPosition(ccp(centerPosX, centerPosY))
end

function InciteDescPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

return InciteDescPanel