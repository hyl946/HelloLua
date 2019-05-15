require "zoo.panel.basePanel.BasePanel"

WeChatPanel = class(BasePanel)

function WeChatPanel:create(btnCallback, closeCallback)
	local panel = WeChatPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
	if panel:init(btnCallback, closeCallback) then
		return panel
	else
		panel = nil
		return nil
	end
end

function WeChatPanel:init(btnCallback, closeCallback)
	self.closeCallback = closeCallback

	-- 初始化面板
	self.ui = self:buildInterfaceGroup("WeChatPanel") --ResourceManager:sharedInstance():buildGroup("WeChatPanel")
	BasePanel.init(self, self.ui)

	-- 获取控件
	self.bg = self.ui:getChildByName("_bg")
	self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(self.panelTitle)

	self.btn = self.ui:getChildByName("btn")
	self.close = self.ui:getChildByName("close")
	self.num1 = self.ui:getChildByName("num1")
	self.num1_fontSize = self.ui:getChildByName("num1_fontSize")
	self.num2 = self.ui:getChildByName("num2")
	self.num2_fontSize = self.ui:getChildByName("num2_fontSize")
	self.text1 = self.ui:getChildByName("text1")
	self.text2 = self.ui:getChildByName("text2")
	self.picPos1 = self.ui:getChildByName("picPos1")
	self.picPos2 = self.ui:getChildByName("picPos2")
	if not self.panelTitle or not self.btn or not self.close or not self.num1 or not self.num1_fontSize or not self.num2 or
	not self.num2_fontSize or not self.text1 or not self.text2 or not self.picPos1 or not self.picPos2 then
		return false
	end
	self.btn = GroupButtonBase:create(self.btn)
	self.btn:useStaticLabel(34)
	--self.btn:changeToColor("green")
	self.num1 = TextField:createWithUIAdjustment(self.num1_fontSize, self.num1)
	self:addChild(self.num1)
	self.num2 = TextField:createWithUIAdjustment(self.num2_fontSize, self.num2) 
	self:addChild(self.num2)

	-- 屏幕适配
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	-- 设置文字（需要更新本地化文件）
	self.panelTitle:setString(Localization:getInstance():getText("wechat.panel.captain"))
	self.btn:setString(Localization:getInstance():getText("wechat.panel.btn"))
	self.num1:setString("1")
	self.num2:setString("2")
	self.text1:setString(Localization:getInstance():getText("wechat.panel.text1"))
	self.text2:setString(Localization:getInstance():getText("wechat.panel.text2"))

	-- 设置图片
	self.pic1 = Sprite:createWithSpriteFrameName("howto_wechatpic1 instance 10000")
	self.pic2 = Sprite:createWithSpriteFrameName("howto_wechatpic2 instance 10000")
	local pos = self.picPos1:getPosition()
	self.pic1:setAnchorPoint(ccp(0, 1))
	self.pic1:setPosition(ccp(pos.x - 30, pos.y + 30))
	self:addChild(self.pic1)
	self.picPos1:removeFromParentAndCleanup(true)
	local pos = self.picPos2:getPosition()
	self.pic2:setAnchorPoint(ccp(0, 1))
	self.pic2:setPosition(ccp(pos.x - 30, pos.y + 30))
	self:addChild(self.pic2)
	self.picPos2:removeFromParentAndCleanup(true)

	-- 设置互动事件监听
	local function onCloseTapped()
		self:onCloseBtnTapped()
	end
	self.close:setTouchEnabled(true)
	self.close:addEventListener(DisplayEvents.kTouchTap, onCloseTapped)

	local function onBtnTapped()
		if btnCallback then btnCallback() end
		PopoutManager:sharedInstance():remove(self)
	end
	self.btn:addEventListener(DisplayEvents.kTouchTap, onBtnTapped)
	self.btn:useBubbleAnimation()
	-- 屏蔽下方点击
	--self.bg:setTouchEnabled(true, 0, true)

	return true
end

function WeChatPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)

	FrameLoader:loadImageWithPlist( "ui/weixinpanel_pic.plist" )
end

function WeChatPanel:unloadRequiredResource()
	BasePanel.unloadRequiredResource(self)
	FrameLoader:unloadImageWithPlists({"ui/weixinpanel_pic.plist"})
end

function WeChatPanel:popout()
	PopoutManager:sharedInstance():add(self, false, false)
	self.allowBackKeyTap = true
end

function WeChatPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	if self.closeCallback then self.closeCallback() end
	PopoutManager:sharedInstance():remove(self)
end