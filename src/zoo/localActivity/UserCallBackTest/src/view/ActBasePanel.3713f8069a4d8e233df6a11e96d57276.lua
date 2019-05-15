local ActBasePanel = class(BasePanel)

local DESC_BTN_LOGIC = { NONE = 0,
						 SHOW_DESC = 1 }

local OK_BTN_LOGIC = { NONE = 0, 
					   OK = 1 }

function ActBasePanel:init( config, model )
	self.config = config
	self.model = model
	self.passDayTimeOutID = nil

----UI 相关
	self.ui = nil
	self.uiScale = 1
	self.descBtn = nil
	self.closeBtn = nil
	self.__isActPanel__ = true

----数据相关
	self:initUI()
end

function ActBasePanel:startPassDayCountDown()
	local nowInSec = Localhost:timeInSec()
	local dayEnd = self.config.getDayStartTimeByTS(nowInSec + 86400)
	self.passDayTimeOutID = setTimeOut(function()
		if self.ui.isDisposed then return end
		self:onPassDay()
	end, dayEnd - nowInSec + 1)
end

function ActBasePanel:onPassDay()
	self:startPassDayCountDown()
	self:refresh()
end

function getFullScreenUIPosXYScale( ... )
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local scale = math.min(visibleSize.height / 1280, visibleSize.width / 720)
	local contentPosX = visibleOrigin.x + (visibleSize.width - 720 * scale) / 2
	local contentPosY = visibleOrigin.y + 1280 * scale
	return contentPosX, contentPosY, scale
end

function ActBasePanel:initUI()
	BasePanel.init(self, self.ui)

	self:startPassDayCountDown()

	local contentX, contentY, scale = getFullScreenUIPosXYScale()
	self:setScale(scale)
	self:setPositionXY(contentX, 0)

	if self.closeBtn ~= nil then
		self.closeBtn:setTouchEnabled(true, 0, true)
		self.closeBtn:setButtonMode(true)
		self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() 
			if not self.closeBtn.inClk then
				self.closeBtn.inClk = true
				if self.onClkCloseBtn ~= nil then
					self:onClkCloseBtn() 
				end
			end
		end)
		local closeRawPos = self.closeBtn:getPosition()
		-- self.closeBtn:setPositionXY(closeRawPos.x + contentX, closeRawPos.y)
	end

	if self.okBtn ~= nil then
		self.okBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onClkOKBtn() end)
		self.okBtnLogic = OK_BTN_LOGIC.OK
		if self.okBtn.groupNode ~= nil then
			self.okBtnLight = self.okBtn.groupNode:getChildByName("light") --可能为nil
		elseif self.okBtn.getChildByName ~= nil then
			self.okBtnLight = self.okBtn:getChildByName("light") --可能为nil
		end
	end

	if self.descBtn ~= nil then
		self.descBtn:setTouchEnabled(true, 0, true)
		self.descBtn:setButtonMode(true)
		self.descBtnLogic = DESC_BTN_LOGIC.SHOW_DESC
		self.descBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onClkDescBtn() end)
	end

	self:refresh()
end

function ActBasePanel:okBtnHideAction()
	if self.ui.isDisposed then return end

	if self.okBtn ~= nil then
		if self.okBtnLight ~= nil then
			self.okBtnLight:setVisible(false)
			self.okBtnLight:stopAllActions()
		end

		if self.okBtn.stopAction ~= nil then self.okBtn.stopAction.cancelBubbleAnimation() end
	end
end

function ActBasePanel:okBtnShowAction()
	if self.ui.isDisposed then return end

	if self.okBtn.stopAction ~= nil then self.okBtn.stopAction.cancelBubbleAnimation() end
	self.okBtn.stopAction = self.okBtn:useBubbleAnimation()

	if self.okBtnLight ~= nil then
			self.okBtnLight:setVisible(true)
			self.okBtnLight:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeOut:create(0.9), CCFadeIn:create(0.9))))
	end
end

function ActBasePanel:refresh()
	if self.ui.isDisposed then return end
end

-----------------按钮状态扩展逻辑-------------主要针对出现新的活动阶段时使用------------------
function ActBasePanel:refreshBtnsExtend()
	
end

function ActBasePanel:setActEndView()
	self.okBtnLogic = OK_BTN_LOGIC.NONE
end

function ActBasePanel:onClkOKBtn()
	if self.okBtnLogic == OK_BTN_LOGIC.NONE then
		return
	elseif self.okBtnLogic == OK_BTN_LOGIC.OK then
		self.okBtnLogic = OK_BTN_LOGIC.NONE
		self:clkToOK()
	end
end

--↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓点击OK按钮↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
function ActBasePanel:clkToOK()
	
end
--↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑点击OK按钮↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

function ActBasePanel:onClkDescBtn()
	if self.descBtnLogic == DESC_BTN_LOGIC.SHOW_DESC then
		self.descBtnLogic = DESC_BTN_LOGIC.NONE
		setTimeOut(function( ... )
			self.descBtnLogic = DESC_BTN_LOGIC.SHOW_DESC
		end, 0.5)
		return true
	end

	return false
end

function ActBasePanel:onClkCloseBtn()
	-- print("================================================remove main panel")
	self.model:setMainPanel(nil)
	PopoutManager:sharedInstance():remove(self)
end

function ActBasePanel:popout()
	PopoutQueue:sharedInstance():push(self)
	return self
end

function ActBasePanel:popoutShowTransition()
	self.allowBackKeyTap = true
	local panelPopNum, todayPopNum = self.model:getPanelPopNum(), self.model:getTodayPanelPouNum()
	if panelPopNum == 1 then
		self:playFirstTimePopAnim()
	elseif todayPopNum == 1 then
		self:playTodayFirstTimePopAnim()
	else
		self:playNormalPopAnim()
	end
end

function ActBasePanel:playFirstTimePopAnim( ... )
	-- body
end

function ActBasePanel:playTodayFirstTimePopAnim( ... )
	-- body
end

function ActBasePanel:playNormalPopAnim( ... )
	-- body
end

function ActBasePanel:onKeyBackClicked(...)
	if self.allowBackKeyTap then
		self:onClkCloseBtn()
	end
end

function ActBasePanel:dispose( ... )
	self.model:setMainPanel(nil)
	if self.passDayTimeOutID ~= nil then
		cancelTimeOut(self.passDayTimeOutID)
	end
	BasePanel.dispose(self)
end

return ActBasePanel