PayCheckProgressCircle = class(BaseUI)

function PayCheckProgressCircle:ctor()
	
end

function PayCheckProgressCircle:init()
	BaseUI.init(self, self.ui)

	local bg = self.ui:getChildByName("bg")
	local progressBounds = bg:getGroupBounds()
	local nodePos = self:convertToNodeSpace(ccp(progressBounds:getMidX(),progressBounds:getMidY()))

	self.progressText = self.ui:getChildByName("countdownLabel")
	self.progressText:setAnchorPoint(ccp(0.5,0.5))
	self.progressText:setPosition(ccp(nodePos.x, nodePos.y - 3))
	self.progressText:setText(self.defaultLabel or "")

	local progress = self.ui:getChildByName("progress")
	progress:removeFromParentAndCleanup(false)
	self.ccprogress = CCProgressTimer:create(progress.refCocosObj)
	progress:dispose()

	self.ccprogress:setType(kCCProgressTimerTypeRadial)
	self.ccprogress:setPercentage(0)
	self.ccprogress:setPosition(ccp(nodePos.x, nodePos.y))
	local childIndex = self.ui:getChildIndex(self.progressText)
	self.ui:addChildAt(CocosObject.new(self.ccprogress), childIndex)
end

function PayCheckProgressCircle:setPercentage(percent)
	if self.isDisposed then return end
	percent = math.floor(percent or 0)
	self.ccprogress:stopAllActions()
	self.ccprogress:runAction(CCProgressFromTo:create(
		0.01,
		self.ccprogress:getPercentage(),
		percent
	))
end

function PayCheckProgressCircle:setLabel(label)
	if self.isDisposed then return end
	self.progressText:setText(label)
end

function PayCheckProgressCircle:reset()
	if self.isDisposed then return end
	self.progressText:setText(self.defaultLabel or "")
	self.ccprogress:setPercentage(0)
end

function PayCheckProgressCircle:create(ui, defaultLabel)
	local progress = PayCheckProgressCircle.new()
	progress.ui = ui
	progress.defaultLabel = defaultLabel
	progress:init()
	return progress
end


ManualOnlinePayCheck = class(BasePanel)

local hasCheckSuccess = false
function ManualOnlinePayCheck:ctor()
	self.checkTime = 0
	self.faqBtnTap = false
	--倒计时秒数
	self.maxCountdownTime = 5
	--为显示而用的系数
	self.countdownCoefficient = 10

	--一个面板 只有一次查询成功
	hasCheckSuccess = false
end

function ManualOnlinePayCheck:init()
	self.ui	= self:buildInterfaceGroup("ManualOnlinePayCheck") 
	BasePanel.init(self, self.ui)

	local panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(panelTitle)
	panelTitle:setString(Localization:getInstance():getText("polling.panel.title"))

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:removeSelf()
	end)

	self.desc1 = self.ui:getChildByName("desc1")
	self.desc1:setString(Localization:getInstance():getText("polling.panel.desc1"))
	self.desc2 = self.ui:getChildByName("desc2")
	self.desc2:setString(Localization:getInstance():getText("polling.panel.desc2"))
	self.desc3 = self.ui:getChildByName("desc3")
	self.desc3:setString(Localization:getInstance():getText("polling.panel.desc3"))

	self.faqBtn = GroupButtonBase:create(self.ui:getChildByName("faqBtn"))
	self.faqBtn:setColorMode(kGroupButtonColorMode.blue)
	self.faqBtn:setString(Localization:getInstance():getText("polling.panel.button2"))
	self.faqBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onFaqBtnTap()
		end)

	self.checkBtnSmall = GroupButtonBase:create(self.ui:getChildByName("checkBtnSmall"))
	self.checkBtnSmall:setString(Localization:getInstance():getText("polling.panel.button1"))
	self.checkBtnSmall:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onCheckBtnTap(evt)
		end)

	self.checkBtn = GroupButtonBase:create(self.ui:getChildByName("checkBtn"))
	self.checkBtn:setString(Localization:getInstance():getText("polling.panel.button1"))
	self.checkBtn:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onCheckBtnTap(evt)
		end)

	self.progressCircle = PayCheckProgressCircle:create(self.ui:getChildByName("progressBar"), self.maxCountdownTime)

	self:updatePanel()
end

function ManualOnlinePayCheck:updatePanel()
	self.checkBtn:setString(Localization:getInstance():getText("polling.panel.button1"))
	self.checkBtn:setEnabled(true)
	self.checkBtnSmall:setString(Localization:getInstance():getText("polling.panel.button1"))
	self.checkBtnSmall:setEnabled(true)

	self.progressCircle:setVisible(false)
	if self.checkTime > 2 then 
		self.desc1:setVisible(false)
		self.desc2:setVisible(false)
		self.desc3:setVisible(true)

		self.faqBtn:setVisible(true)
		self.checkBtnSmall:setVisible(true)
		self.checkBtn:setVisible(false)
	else
		self.desc1:setVisible(true)
		self.desc2:setVisible(true)
		self.desc3:setVisible(false)

		self.faqBtn:setVisible(false)
		self.checkBtnSmall:setVisible(false)
		self.checkBtn:setVisible(true)
	end
end

function ManualOnlinePayCheck:onFaqBtnTap()
	self.faqBtnTap = true
	self.faqBtn:setEnabled(false)
    
    PaymentNetworkCheck.getInstance():check(function ()
    	if self.isDisposed then return end
    	self:removePopout()
    	FAQ:openFAQClient()
    end, function ()
    	if self.isDisposed then return end
    	self.faqBtn:setEnabled(true)
    	CommonTip:showTip(Localization:getInstance():getText("forcepop.tip3"), "negative")
    end)
end

function ManualOnlinePayCheck:onCheckBtnTap(evt)
	local btn = evt.target
	local currentCountdown = nil
	local maxTime = self.maxCountdownTime * self.countdownCoefficient
	if btn then 
		btn:setEnabled(false)
		btn:setString(Localization:getInstance():getText("polling.panel.button3"))
	end

	local function stopScheduler()
		if self.isDisposed then return end
		if self.schedulerId then 
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		end
		self.schedulerId = nil

		if self.progressCircle then 
			self.progressCircle:reset()
		end
		self:updatePanel()
	end

	local function callback()
		if currentCountdown then 
			currentCountdown = currentCountdown - 1
			if currentCountdown < 0 then 
				CommonTip:showTip(Localization:getInstance():getText("polling.panel.tip2"), "negative")
				stopScheduler()
			else
				self.progressCircle:setLabel(math.ceil(currentCountdown / self.countdownCoefficient))
				local percent  = (maxTime - currentCountdown) / maxTime * 100
				self.progressCircle:setPercentage(percent)
			end
		else
			stopScheduler()
		end
	end

	local function checkSuccess()
		-- CommonTip:showTip(Localization:getInstance():getText("polling.panel.tip1"), "negative")
		if not hasCheckSuccess then 
			hasCheckSuccess = true
			self:removePopout()
		end
	end

	if not self.schedulerId then 
		self.checkTime = self.checkTime + 1
		currentCountdown = maxTime
		self.schedulerId = Director:sharedDirector():getScheduler():scheduleScriptFunc(callback, 1 / self.countdownCoefficient, false)
		self.progressCircle:setVisible(true)
		if self.checkTime > 2 then 
			self.faqBtn:setVisible(false)
		end
		if self.checkFunc then 
			self.checkFunc(checkSuccess)
		end
	else
		stopScheduler()
	end
end

function ManualOnlinePayCheck:removeSelf()
	CommonTip:showTip(Localization:getInstance():getText("polling.panel.tip3"), "negative")
	if self.cancelFunc then self.cancelFunc() end
	self:removePopout()
end

function ManualOnlinePayCheck:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:popoutShowTransition()
end

function ManualOnlinePayCheck:popoutShowTransition()
	self.allowBackKeyTap = true
	self:_calcPosition()
end

function ManualOnlinePayCheck:_calcPosition()
	local selfSizeWidth = 670
	local selfSizeHeight = 482
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local deltaWidth = vSize.width - selfSizeWidth
	local deltaHeight = vSize.height - selfSizeHeight
	local selfParent = self:getParent()

	if selfParent then
		local pos = selfParent:convertToNodeSpace(ccp(vOrigin.x + deltaWidth / 2, vOrigin.y + selfSizeHeight + deltaHeight / 2))
		self:setPosition(ccp(pos.x, pos.y))
	end
end

function ManualOnlinePayCheck:removePopout()
	if self.isDisposed then return end
	DcUtil:payManualOnlinePayCheckPanel(self.checkTime, self.faqBtnTap)
	if self.schedulerId then 
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
		self.schedulerId = nil 
	end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function ManualOnlinePayCheck:onCloseBtnTapped()
	self:removeSelf()
end

function ManualOnlinePayCheck:create(checkFunc, cancelFunc)
	local panel = ManualOnlinePayCheck.new()
	panel.checkFunc = checkFunc
	panel.cancelFunc = cancelFunc
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end