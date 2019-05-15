local AliQuickPayDebugPanel = class(BasePanel)

function AliQuickPayDebugPanel:create(popTimes, lastPopTime)
	local panel = AliQuickPayDebugPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(popTimes, lastPopTime)

	return panel
end

function AliQuickPayDebugPanel:init(popTimes, lastPopTime)

	self.ui = self:buildInterfaceGroup("AliQuickPayDebugPanel")
    BasePanel.init(self, self.ui)

    self.popTimes = popTimes
    self.lastPopTime = lastPopTime

    self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName("btnSave"))
    self.btnConfirm:setString(Localization:getInstance():getText("清除信息"))
    self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function ()
        self:onCloseBtnTapped()
        local Guide = require("zoo.panel.alipay.AliQuickPayGuide")
        Guide.clearGuides()
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("支付宝快付防打扰信息"))

	self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)

	self:initText()
end

function AliQuickPayDebugPanel:initText()
    self.ui:getChildByName("tip1"):setString("已打扰次数：") 
    self.ui:getChildByName("tip2"):setString("上次打扰时间：")
    self.ui:getChildByName("tip3"):setString("当前时间：")
    self.ui:getChildByName("tip4"):setString("是否首次登录：")
    self.ui:getChildByName("tip5"):setString("签约状态：")

    local lastPopTimeStr = "0"
    if self.lastPopTime > 0 then
    	lastPopTimeStr = os.date("%c", self.lastPopTime)
    end

    local currentTime = Localhost:time() / 1000
    self.ui:getChildByName("txtCurrentTime"):setString(os.date("%c", currentTime))
    self.ui:getChildByName("txtPopTimes"):setString(self.popTimes.."次")
    self.ui:getChildByName("txtLastPopTime"):setString(lastPopTimeStr)
    self.ui:getChildByName("txtSignState"):setString(self.popTimes.."次")
    self.ui:getChildByName("txtFirstLogin"):setString( tostring(__IS_TOTAY_FIRST_LOGIN) )
    self.ui:getChildByName("txtSignState"):setString( tostring(UserManager.getInstance().userExtend.aliIngameState))
end

function AliQuickPayDebugPanel:popout()
	self:setPositionForPopoutManager()

	PopoutManager:sharedInstance():add(self, true, false)
end

function AliQuickPayDebugPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function AliQuickPayDebugPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end


return AliQuickPayDebugPanel