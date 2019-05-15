require 'zoo.panel.basePanel.BasePanel'

IOSScoreGuidePanel = class(BasePanel)

function IOSScoreGuidePanel:create(showTime)
	local panel = IOSScoreGuidePanel.new()
	panel:loadRequiredResource(PanelConfigFiles.ios_score_guide)
	panel:init(showTime)
	return panel
end

function IOSScoreGuidePanel:unloadRequiredResource()
end

function IOSScoreGuidePanel:init(showTime)
	self:initData(showTime)

	self:initUI()
end

function IOSScoreGuidePanel:initData(showTime)
	-- 该面板是第N次出现
	self.showTime = showTime or 1
	self.maxInputLen = 300

	self.state = "review"
end

function IOSScoreGuidePanel:initUI()
	self.ui = self:buildInterfaceGroup("pingjia_panel")

	BasePanel.init(self, self.ui)

	local function onCloseTap( ... )
		-- self.btnClose:setEnabled(false)
		if (self.state == "review") then 
			local topLevel = UserManager:getInstance().user.topLevelId
			DcUtil:UserTrack({category = 'ios_review', sub_category = 'end', stage = topLevel, type = 2, times = self.showTime, result = 0})
		else
			DcUtil:UserTrack({category = 'ios_review', sub_category = 'end_advice', result = 0})
		end
		-- 一周再触发
		-- IOSScoreGuideFacade:getInstance():setReopenTimestamp(7 * 24 * 60 * 60)

		self:onCloseBtnTapped()
	end
	
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local wSize = CCDirector:sharedDirector():getWinSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local size = self:getGroupBounds().size
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	self.btnClose = self:createTouchButtonBySprite(self.ui:getChildByName("btnClose"), onCloseTap)
	
	self.btnToWrite = GroupButtonBase:create(self.ui:getChildByName("btnToWrite"))	
	self.btnToWrite:setColorMode(kGroupButtonColorMode.orange)
	self.btnToWrite:setString(Localization:getInstance():getText('apple_mark_button2'))
	self.btnToWrite:addEventListener(DisplayEvents.kTouchTap, handler(self,self.onBtnToWriteTap))

	self.btnToAppleStore = GroupButtonBase:create(self.ui:getChildByName("btnToAppleStore"))	
	self.btnToAppleStore:setColorMode(kGroupButtonColorMode.blue)
	self.btnToAppleStore:setString(Localization:getInstance():getText('apple_mark_button1'))
	self.btnToAppleStore:addEventListener(DisplayEvents.kTouchTap, handler(self,self.onBtnToAppleStoreTap))


	if ((not self.showTime) or self.showTime <= 1) then
		self.ui:getChildByName("mcBg1"):setVisible(true)
		self.ui:getChildByName("mcBg2"):setVisible(false)
		self.ui:getChildByName("mcBg3"):setVisible(false)
	elseif (self.showTime <= 2) then
		self.ui:getChildByName("mcBg1"):setVisible(false)
		self.ui:getChildByName("mcBg2"):setVisible(true)
		self.ui:getChildByName("mcBg3"):setVisible(false)
	else
		self.ui:getChildByName("mcBg1"):setVisible(false)
		self.ui:getChildByName("mcBg2"):setVisible(false)
		self.ui:getChildByName("mcBg3"):setVisible(true)
	end

	self.writePage = self.ui:getChildByName("mcWritePage")
	self.writePage:setVisible(false)

	self.txtInputHolder = self.writePage:getChildByName("txtInputHolder")
	self.txtTip = self.writePage:getChildByName("txtTip")
	self.txtTipNumber = self.writePage:getChildByName("txtTipNumber")

	self.txtTip:setVisible(false)
	self.txtTipNumber:setVisible(false)
end

function IOSScoreGuidePanel:onBtnToWriteTap()
	self.state = "advice"

	local topLevel = UserManager:getInstance().user.topLevelId
	DcUtil:UserTrack({category = 'ios_review', sub_category = 'end', stage = topLevel, type = 2, times = self.showTime, result = 2})

	if _G.isLocalDevelopMode then printx(0, ">>>>>> write >>>>>>>>>") end
	self.btnToWrite:setEnabled(false)
	-- setTimeOut(function() 
	-- 	self.btnToWrite:setEnabled(true)
	-- end,1)

	self.ui:getChildByName("mcBg1"):setVisible(false)
	self.ui:getChildByName("mcBg2"):setVisible(false)
	self.ui:getChildByName("mcBg3"):setVisible(false)
	self.btnToWrite:setVisible(false)
	self.btnToAppleStore:setVisible(false)

	self.writePage:setVisible(true)
	-- self.writePage:getChildByName("txtDesc"):setString(Localization:getInstance():getText("apple_opinion_text"))
	self.txtInputHolder:setString(Localization:getInstance():getText("apple_opinion_hint"))
	-- self.txtTip:setString(Localization:getInstance():getText("apple_opinion_num"))
	self.txtTip:setString(Localization:getInstance():getText("apple_opinion_num",{num="  "}))

	self.btnSend = GroupButtonBase:create(self.writePage:getChildByName("btnSend"))	
	self.btnSend:setColorMode(kGroupButtonColorMode.green)
	self.btnSend:setString(Localization:getInstance():getText('apple_opinion_button'))
	self.btnSend:addEventListener(DisplayEvents.kTouchTap, handler(self,self.onBtnSendTap))
	self.btnSend:setEnabled(false)

	local inputSelect = self.writePage:getChildByName("mcInputHolder")
	local inputSize = inputSelect:getContentSize()

	if _G.isLocalDevelopMode then printx(0, ">>>>",inputSize.width,inputSize.height) end
	inputSize.width = inputSize.width * self:getScaleX()
	inputSize.height = inputSize.height * self:getScaleY()
	-- inputSize = ccp(inputSize.width * self:getScaleX() , inputSize.height * self:getScaleY())

	local inputPos = inputSelect:getPosition()
	inputSelect:setVisible(true)
	inputSelect:removeFromParentAndCleanup(false)

	local position = ccp(inputPos.x + inputSize.width/2, inputPos.y - inputSize.height/2)

	local input = TextInput:create(inputSize, Scale9Sprite:createWithSpriteFrameName("IOSScoreGuide_ui_empty0000"))
	input.originalX_ = position.x
	input.originalY_ = position.y
	input:setText("")
	input:setPosition(position)
	input:setFontColor(ccc3(0, 0, 0))
	input:setMaxLength(self.maxInputLen)
	input:setInputMode(kEditBoxInputModeAny)


	self.input = input
	if _G.isLocalDevelopMode then printx(0, ">>>>> init text input position >>>>>",self.input:getPositionX(),self.input:getPositionY()) end
	-- customize panel position when openkeyboard
	-- fuuuu : the 'keyboardwillshow maybe call two more times....'
	self.input.refCocosObj:registerScriptImeHandler(function(eventName)
		if (eventName == "keyboardWillShow") then
			if (not self.hasFocus) then 
				self.hasFocus = true
					if _G.isLocalDevelopMode then printx(0, ">>>>> init text input keyboardWillShow >>>>>",self.input:getPositionX(),self.input:getPositionY()) end
					if _G.isLocalDevelopMode then printx(0, "will show .......") end
					self:textViewGetFocus()
			end 
		elseif eventName == "keyboardWillHide" then
			if (self.hasFocus) then 
				self.hasFocus = false
				if _G.isLocalDevelopMode then printx(0, "will hide .......") end
				if _G.isLocalDevelopMode then printx(0, ">>>>> init text input keyboardWillHide >>>>>",self.input:getPositionX(),self.input:getPositionY()) end
				self:textViewLostFocus()
			end
		end

	end)

	local function checkLimit()
		local len = utfstrlen(input:getText())
		if _G.isLocalDevelopMode then printx(0, "checkLimit >>>>> ",input:getText(),len) end

		-- 字数限制
		local limit = self.maxInputLen - len
		if (limit < 10) then 
			self.txtTip:setVisible(true)
			self.txtTipNumber:setVisible(true)

			local limitStr = tostring(limit)
			if (limit < 0) then
				limitStr = "0"
			end

			self.txtTipNumber:setString(limitStr)

			-- 截取发送建议
			if (limit < 0) then
				self.btnSend:setEnabled(false)
			else
				self.btnSend:setEnabled(true)
			end
		else
			self.txtTip:setVisible(false)
			self.txtTipNumber:setVisible(false)
		end
	end

	local function onTextBegin() 
		if _G.isLocalDevelopMode then printx(0, "input begin ") end
		self.txtInputHolder:setString("")
	end
	input:addEventListener(kTextInputEvents.kBegan, onTextBegin)
	local function onTextEnd() 
		if _G.isLocalDevelopMode then printx(0, ">>>>>> text end >>>>") end
		checkLimit()
		

		if (utfstrlen(input:getText()) > 0) then
			self.txtInputHolder:setString("")
			self.btnSend:setEnabled(true)
		else
			self.btnSend:setEnabled(false)
			self.txtInputHolder:setString(Localization:getInstance():getText("apple_opinion_hint"))
		end
	end

	local function onTextChanged() 
		if _G.isLocalDevelopMode then printx(0, " >>> text changed >>>") end
		checkLimit()
	end

	if __WIN32 then
		input:ad(kTextInputEvents.kEnded, onTextEnd)
	else
		input:ad(kTextInputEvents.kEnded, onTextEnd)
		input:ad(kTextInputEvents.kLostFocus, onTextEnd)
	end
	input:ad(kTextInputEvents.kChanged,onTextChanged)

	self.writePage:addChild(input)
	inputSelect:dispose()
end

function IOSScoreGuidePanel:textViewGetFocus()
	self.originalPosition = ccp(self:getPositionX(),self:getPositionY())
	self.originalInputPosition = ccp(self.input:getPositionX(),self.input:getPositionY());

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.05),
		CCCallFunc:create(function( ... )
			self:setPosition(ccp(self.originalPosition.x,250))
			self.input:setPosition(ccp(self.originalInputPosition.x,self.originalInputPosition.y))
		end)
	))


end

function IOSScoreGuidePanel:textViewLostFocus()
	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.05),
		CCCallFunc:create(function( ... )
			self:setPosition(self.originalPosition)
			self.input:setPosition(ccp(self.originalInputPosition.x,self.originalInputPosition.y))
		end)
	))
end

function IOSScoreGuidePanel:onBtnToAppleStoreTap()
	if _G.isLocalDevelopMode then printx(0, ">>>>>> to apple stroe  >>>>>>>>>") end
	local topLevel = UserManager:getInstance().user.topLevelId
	DcUtil:UserTrack({category = 'ios_review', sub_category = 'end', stage = topLevel, type = 2, times = self.showTime, result = 1})

	self.btnToAppleStore:setEnabled(false)
	-- setTimeOut(function() 
	-- 	self.btnToAppleStore:setEnabled(true)
	-- end,1)

	-- 终身？逗呢。。再活69年
	-- IOSScoreGuideFacade:getInstance():setReopenTimestamp(365 * 69 * 24 * 60 * 60)
	-- IOSScoreGuideFacade:getInstance():setCloseTime()

	self:onCloseBtnTapped()
	
	local nsURL = NSURL:URLWithString(NetworkConfig.appstoreURL)
	UIApplication:sharedApplication():openURL(nsURL)
end

function IOSScoreGuidePanel:onBtnSendTap( ... )
	if _G.isLocalDevelopMode then printx(0, ">>>>>>> send >>>>>>>>>>> ",tostring(self.input:getText())) end	

	DcUtil:UserTrack({category = 'ios_review', sub_category = 'end_advice', result = 1})

	self.btnSend:setEnabled(false)

	-- 两周再触发
	-- IOSScoreGuideFacade:getInstance():setReopenTimestamp(14 * 24 * 60 * 60)


	local http = OpNotifyOffline.new()
    local function opSuccess( evt )
    	if _G.isLocalDevelopMode then printx(0, "cache success============") end
    end
    local function opFail( evt )
    	if _G.isLocalDevelopMode then printx(0, "cache failed=========") end
    end
    http:addEventListener(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
	http:load(OpNotifyOfflineType.kIOSScoreGuide,tostring(self.input:getText()))
	SyncManager.getInstance():sync(nil, nil, kRequireNetworkAlertAnimation.kNone)

	self:onCloseBtnTapped()



    -- local http = OpNotifyOffineHttp.new()
    -- http:ad(Events.kComplete, opSuccess)
    -- http:ad(Events.kError, opFail)
    -- http:load(OpNotifyType.kPassMaxNormalLevel, tostring(MetaManager:getInstance():getMaxNormalLevelByLevelArea()))
    -- SyncManager.getInstance():sync(nil, nil, kRequireNetworkAlertAnimation.kNone)

end


function IOSScoreGuidePanel:updateView()
end

function IOSScoreGuidePanel:popout()
	self.allowBackKeyTap = true
	-- PopoutManager:sharedInstance():add(self, true, false)
	PopoutQueue:sharedInstance():push(self, true, false)

	-- he_dumpGLObjectRefs()
end

function IOSScoreGuidePanel:onCloseBtnTapped( ... )
	-- 记录关闭次数
	local config = CCUserDefault:sharedUserDefault()
	local closeTime = config:getIntegerForKey(kIOSScoreGuideData.kCloseTime,0)
	config:setIntegerForKey(kIOSScoreGuideData.kCloseTime,closeTime+1)
	config:setIntegerForKey(kIOSScoreGuideData.kTodayPassLevelCount, 0)
	config:flush()

	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end


