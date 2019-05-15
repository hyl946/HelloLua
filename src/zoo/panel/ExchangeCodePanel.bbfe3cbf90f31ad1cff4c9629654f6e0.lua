require "zoo.panel.basePanel.BasePanel"
require "hecore.ui.PopoutManager"
require "zoo.baseUI.ButtonWithShadow"
require "zoo.config.ActivityConfig"

ExchangeCodePanel = class(BasePanel)

function ExchangeCodePanel:create(scaleOriginPosInWorldSpace, ...)
	assert(scaleOriginPosInWorldSpace)
	assert(#{...} == 0)

	local panel = ExchangeCodePanel.new()
	if panel:init(scaleOriginPosInWorldSpace) then
		if _G.isLocalDevelopMode then printx(0, "return true, panel should been shown") end
		return panel
	else
		if _G.isLocalDevelopMode then printx(0, "return false, panel's been destroyed") end
		panel = nil
		return nil
	end
end

function ExchangeCodePanel:init(scaleOriginPosInWorldSpace, ...)
	assert(scaleOriginPosInWorldSpace)
	assert(#{...} == 0)

	if Localhost:time() >= ActivityDeadline.kExchangeCode then
		CommonTip:showTip(Localization:getInstance():getText("exchange.code.panel.activity.over"), "negative")
		return false
	end

	-- 建立窗口UI和初始化
	self.ui = ResourceManager:sharedInstance():buildGroup("ExchangeCodePanel")
	BasePanel.init(self, self.ui)
	self:setPositionForPopoutManager()

	self.scaleOriginPosInWorldSpace = scaleOriginPosInWorldSpace

	---------------------
	-- Create Show Hide Anim
	-- ----------------------
	self.showHideAnim = IconPanelShowHideAnim:create(self, self.scaleOriginPosInWorldSpace)

	-- 获取控件
	self.btnClose = self.ui:getChildByName("btnClose")
	self.captain = self.ui:getChildByName("captain")
	self.btnGet = self.ui:getChildByName("btnGet")
	self.exchText = self.ui:getChildByName("exchText")
	self.exchBg = self.ui:getChildByName("exchBg")
	self.exchCode = self.ui:getChildByName("exchCode")
	self.exchMask = self.ui:getChildByName("exchMask")
	self.cmtText = self.ui:getChildByName("cmtText")
	self.app1Name = self.ui:getChildByName("app1Name")
	self.app2Name = self.ui:getChildByName("app2Name")
	self.app3Name = self.ui:getChildByName("app3Name")
	self.app1Cmt = self.ui:getChildByName("app1Cmt")
	self.app2Cmt = self.ui:getChildByName("app2Cmt")
	self.app3Cmt = self.ui:getChildByName("app3Cmt")
	self.deadline = self.ui:getChildByName("deadline")

	if not self.btnClose or not self.captain or not self.btnGet or not self.exchText or not self.exchBg or not self.exchCode or not self.exchMask or
		not self.cmtText or not self.app1Name or not self.app2Name or not self.app3Name or not self.app1Cmt or not self.app2Cmt or not self.app3Cmt or
		not self.deadline then
		return false
	end
	self.btnGet = ButtonWithShadow:create(self.btnGet)

	-- 设置文字（需要本地化文件）
	self.captain:setString(Localization:getInstance():getText("exchange.code.panel.title"))
	self.btnGet:setString(Localization:getInstance():getText("exchange.code.panel.btn.get.text"))
	self.exchText:setString(Localization:getInstance():getText("exchange.code.panel.exch.text"))
	self.exchCode:setString("")
	self.cmtText:setString(Localization:getInstance():getText("exchange.code.panel.cmt.text"))
	self.app1Name:setString(Localization:getInstance():getText("exchange.code.panel.app1.name"))
	self.app2Name:setString(Localization:getInstance():getText("exchange.code.panel.app2.text"))
	self.app3Name:setString(Localization:getInstance():getText("exchange.code.panel.app3.name"))
	self.app1Cmt:setString(Localization:getInstance():getText("exchange.code.panel.app1.cmt"))
	self.app2Cmt:setString(Localization:getInstance():getText("exchange.code.panel.app2.cmt"))
	self.app3Cmt:setString(Localization:getInstance():getText("exchange.code.panel.app3.cmt"))
	self.deadline:setString(Localization:getInstance():getText("exchange.code.panel.deadline"))

	-- 设置状态
	local pos = self.exchMask:getPosition()
	local size = self.exchMask:getGroupBounds().size
	self.exchMask:setAnchorPoint(ccp(1, 0.5))
	self.exchMask:setPosition(ccp(pos.x + size.width, pos.y - size.height / 2))
	self.btnGet:changeToColor("green")

	-- 添加事件监听
	local function onCloseClick()
		self:onCloseBtnTapped()
	end
	self.btnClose:setTouchEnabled(true)
	self.btnClose:setButtonMode(true)
	self.btnClose:ad(DisplayEvents.kTouchTap, onCloseClick)
	local function onGetCode()
		self:getExchangeCode()
	end
	self.btnGet.ui:ad(DisplayEvents.kTouchTap, onGetCode)

	return true
end

function ExchangeCodePanel:onCloseBtnTapped()
	local function onHideAnimFinished()
		--PopoutManager:sharedInstance():remove(self, true)
		PopoutManager:sharedInstance():removeWithBgFadeOut(self, false, true)
	end
	self.allowBackKeyTap = false
	self.showHideAnim:playHideAnim(onHideAnimFinished)
end

function ExchangeCodePanel:popout()
	local function onAnimOver() self.allowBackKeyTap = true end
	PopoutManager:sharedInstance():add(self, true, false)
	self.showHideAnim:playShowAnim(onAnimOver)
end

function ExchangeCodePanel:getExchangeCode()
	local exchangeCode = UserManager:getInstance().exchangeCode or ""
	if string.len(exchangeCode) == 0 then
		CommonTip:showTip(Localization:getInstance():getText("exchange.code.panel.get.code.fail"), "negative")
		return
	end
	self.btnGet:changeToColor("grey")
	self.btnGet.ui:setTouchEnabled(false)
	self.exchCode:setString(exchangeCode)
	self.exchMask:runAction(CCScaleTo:create(0.5, 0, 1))
end
