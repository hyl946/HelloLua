local Input = require "zoo.panel.phone.Input"
local Title = require "zoo.panel.phone.Title"
local Button = require "zoo.panel.phone.Button"


UMPayPanel = class(BasePanel)
function UMPayPanel:create(cb, goodsInfo)
	local panel = UMPayPanel.new()
	panel:loadRequiredResource("ui/UMPayPanel.json")
	panel:init(cb, goodsInfo)
	return panel
end

function UMPayPanel:init(cb, goodsInfo)
	self.cb = cb
	self.goodsInfo = goodsInfo

	self.ui = self:buildInterfaceGroup("UMPayPanel")
	BasePanel.init(self, self.ui)

	self.ui:getChildByName("title"):setText("话费支付")
	self.ui:getChildByName("uptext"):setString("开心消消乐")
	self.ui:getChildByName("downtext"):setString("话费支付")
	self.ui:getChildByName("goodsinfo"):setString(Localization:getInstance():getText(self.goodsInfo.goodsName))
	self.ui:getChildByName("price"):setString(string.format("￥%.2f",self.goodsInfo.totalFee))

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:onCancel()
	end)

	self.codeInput = Input:create(self.ui:getChildByName("code"),self)
	self.codeInput:setMaxLength(6)
	self.codeInput:setInputMode(kEditBoxInputModeNumeric)
	self.codeInput:setPlaceHolder(Localization:getInstance():getText("login.panel.intro.5"))
	self.ui:addChild(self.codeInput)

	self.btnGetCode = GroupButtonBase:create(self.ui:getChildByName("btnGetCode"))
	self.btnGetCode:setString(Localization:getInstance():getText("login.panel.button.16"))
	self.btnGetCode:addEventListener(DisplayEvents.kTouchTap,function( ... )
		--获取验证码,提交订单
		self:requestSmsCode()
	end)

	self.btnSendCode = ButtonIconsetBase:create(self.ui:getChildByName("btnSendCode"))
	self.btnSendCode:setString("确认支付")
	self.btnSendCode:addEventListener(DisplayEvents.kTouchTap,function( ... )
		--提交验证码
		self:sendSmsCode()
	end)
	self.btnSendCode:setEnabled(false)
	self.btnSendCode:setIconByFrameName("common_icon/pay/icon_mobile_small0000")

	self.codeInput:addEventListener(kTextInputEvents.kChanged,function( ... )
		self:checkSmsCode(self.codeInput:getText())
	end)

	self.mobileidInput = Input:create(self.ui:getChildByName("mobileid"),self)
	self.mobileidInput:setMaxLength(11)
	self.mobileidInput:setInputMode(kEditBoxInputModePhoneNumber)

	local phoneNumber = nil
	local phoneNumbers = self:getDefaultPhoneNumbers()

	if phoneNumbers and #phoneNumbers > 0 then
		phoneNumber = phoneNumbers[#phoneNumbers]
		self.mobileidInput:setText(phoneNumber)
		self:checkMobileid(phoneNumber)
	else
		self.btnGetCode:setEnabled(false)
	end

	self.mobileidInput:setPlaceHolder("请输入中国移动手机号")
	
	self.ui:addChild(self.mobileidInput)

	self.mobileidInput:addEventListener(kTextInputEvents.kChanged,function( ... )
		self:checkMobileid(self.mobileidInput:getText())
		self:updateItem()
	end)

	self.mobileidInput:addEventListener(kTextInputEvents.kGotFocus,function( ... )
		self:showPhoneList()
	end)

	self.mobileidInput:addEventListener(kTextInputEvents.kLostFocus,function( ... )
		setTimeOut(function (  )
			self:setPhoneListVisible(false)
		end, 0.1)
	end)

	self:buildPhoneList(phoneNumbers)
end

function UMPayPanel:showPhoneList()
	self:setPhoneListVisible(true)
	self:updateItem()
end

function UMPayPanel:match(findT, num )
	for index = #self.phoneNumbers, 1, -1  do
		local n = self.phoneNumbers[index]
		local p = string.find(n, "^"..num)
		if p then
			if not table.indexOf(findT, n) then
				table.insert( findT, n )
			end
		end
	end

	if #num == 1 then
		return
	end
	return self:match(findT, string.sub(num, 1, #num - 1))
end

function UMPayPanel:updateItem()
	local mobileid = self.mobileidInput:getText()
	if mobileid == nil or mobileid == "" then mobileid = "1" end

	if mobileid and string.len(mobileid) > 0 then
		local findT = {}
		self:match(findT, mobileid)
		if table.indexOf(findT, mobileid) then
			table.remove(findT, mobileid)
		end
		for index,content in ipairs(self.items) do
			local phoneNumber = findT[index]
			if phoneNumber then
				content.phoneNumber = phoneNumber
				content.text:setString(phoneNumber)
			end
		end

		local count = #findT <= 5 and #findT or 5
		self.clipping.stencilNode:changeHeight(count * self.ITEM_HEIGHT)

		if count == 0 then
			self:setPhoneListVisible(false)
		end

		 for index,content in ipairs(self.items) do
	    	content:setVisible(count >= index)
	    end
	end
end

function UMPayPanel:setPhoneListVisible( visible )
	self.clipping:setVisible(visible)
    self.layout:setVisible(visible)

    if #self.phoneNumbers > 0 then
    	self.codeInput:setVisible(not visible)
    	self.codeInput:setEnabled(not visible)
    end
end

function UMPayPanel:buildPhoneItem(index)
	local content = LayerColor:createWithColor(ccc3(255,255,255), self.ITEM_WIDTH, self.ITEM_HEIGHT - 2)
    content:ignoreAnchorPointForPosition(false)
    content:setAnchorPoint(ccp(0,1))

    local normalTextColor = ccc3(180, 94, 16)

    local text = TextField:create(tostring(index), nil, self.ITEM_HEIGHT * 2 / 5, nil, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    text:setAnchorPoint(ccp(0,0.5))
    text:setColor(normalTextColor)
    text:setPosition(ccp(8, self.ITEM_HEIGHT / 2))
    content.text = text
    content:addChild(text)
    content.index = index
    content:setTouchEnabled(true)
    content:ad(DisplayEvents.kTouchTap,
                                   function (event)
                                   		if self.clipping:isVisible() and 
                                   			content:isVisible() and 
                                   			content.phoneNumber and
                                   			#content.phoneNumber == 11 
                                   		then
                                        	self:setPhoneListVisible(false)
                                        	self:checkMobileid(content.phoneNumber)
                                        	self.mobileidInput:setText(content.phoneNumber)
                                        	self:setPhoneListVisible(false)
                                        end
                                   end)
    self.layout:addChild(content)
    content:setPositionY((6 - index)*self.ITEM_HEIGHT)
    self.items[index] = content
end

function UMPayPanel:buildPhoneList( phoneNumbers )
	local mobileid_bg = self.ui:getChildByName("mobileid_bg")
	local pos = mobileid_bg:getPosition()
	local size = mobileid_bg:getGroupBounds().size
	local x = pos.x
	local y = pos.y - size.height

	self.ITEM_WIDTH = size.width
	self.ITEM_HEIGHT = size.height
	local w = self.ITEM_WIDTH - 10
	local h = self.ITEM_HEIGHT * 5

	local stencilNode = CCLayerColor:create(ccc4(255,255,255,255), w, h)
	stencilNode:ignoreAnchorPointForPosition(false)
	stencilNode:setAnchorPoint(ccp(0,1))
	local clipping = ClippingNode.new(CCClippingNode:create(stencilNode))

	local layout = LayerColor:createWithColor(ccc3(229, 195, 134), w, h)
	self.layout = layout
	layout:ignoreAnchorPointForPosition(false)
	layout:setAnchorPoint(ccp(0,1))
	layout.itemCount = 0
	layout:setTouchEnabled(true, 0, true)
	clipping:addChild(layout)
	clipping:setPosition(ccp(x + 5, y))

	self.items = {}

	for index = 1, 5 do
		self:buildPhoneItem(index)
	end

	self.clipping = clipping
	clipping.stencilNode = stencilNode

	if self.phoneListPos == nil then
		local pos = layout:getPosition()
		self.phoneListPos = {x = pos.x, y = pos.y}
	end

	self:setPhoneListVisible(false)
    self.ui:addChild(clipping)

    self.clipping.stencilNode:changeHeight(0)
end

function UMPayPanel:getDefaultPhoneNumbers()
	local userDefault = CCUserDefault:sharedUserDefault()
	local numbers = userDefault:getStringForKey("umpay.default.phone.number")

	local phone = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone)

	if numbers ~= "" then
		self.phoneNumbers = numbers:split(",")
	end

	self.phoneNumbers = self.phoneNumbers or {}

	if phone and #phone == 11 and not table.indexOf(self.phoneNumbers, phone) and self:isChinaMobilePhone(phone) then
		table.insert(self.phoneNumbers, phone)
	end

	return self.phoneNumbers
end

function UMPayPanel:pushDefaultPhoneNum(num)
	self.phoneNumbers = self.phoneNumbers or {}
	if self.phoneNumbers and num and string.len(num) == 11 then
		local sortT = {}
		for index,n in ipairs(self.phoneNumbers) do
			if n ~= num then
				table.insert(sortT, n)
			end
		end
		table.insert(sortT, num)

		self.phoneNumbers = sortT
	end
end

function UMPayPanel:setSmsCode( smsCode )
	self.smsCode = smsCode
	self.codeInput:setText(smsCode)
	self.btnSendCode:setEnabled(true)
end

function UMPayPanel:sendSmsCode()
	self.cb.sendSmsCode(self.smsCode)
	self.btnSendCode:setEnabled(false)
end

function UMPayPanel:isChinaMobilePhone( phone )
	local mobile = "134,135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188"
	-- local union = "130,131,132,155,156,185,186,145,176"
	-- local egame = "133,153,177,180,181,189"
	
	local prefix = string.sub(phone or "", 1, 3)
	local isMobile = string.find(mobile, prefix)
	return isMobile and #prefix == 3
end

function UMPayPanel:validatePhone()
	if not self.mobileidInput:validatePhone() then return false end

	local isMobile = self:isChinaMobilePhone(self.mobileid)

	if not isMobile then
		CommonTip:showTip("请输入中国移动手机号")
	end

	return isMobile
end

function UMPayPanel:requestSmsCode()
	if self:validatePhone() then
		self.cb.requestSmsCode(self.mobileid)
		self:requestSmsCodeCountDown()

		self.rqSmsCodeCount = (self.rqSmsCodeCount or 0) + 1
	end
end

function UMPayPanel:requestSmsCodeCountDown()
	self.btnGetCode:setEnabled(false)

	local count = Localhost.getInstance():time() / 1000
	local function update()
		if self.isDisposed then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
			self.schedule = nil
			return
		end

		local countDown = 60 - Localhost.getInstance():time() / 1000 + count
		if countDown <= 0 then
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
			self.isCountDown = false
			self.schedule = nil
			self.btnGetCode:setString("获取验证码")
			self:checkMobileid(self.mobileid)
			self.btnGetCode.label:setScale(1)
			self.btnGetCode.label:setPosition(ccp(self.oriPos.x + 30, self.oriPos.y))
		else
			self.isCountDown = true
			self.btnGetCode:setEnabled(false)
			self.btnGetCode:setString(tostring(countDown).."后重新获取")
			local pos = self.btnGetCode.label:getPosition()
			if self.oriPos == nil then
				self.oriPos = {x = pos.x, y = pos.y}
			end
			self.btnGetCode.label:setScale(0.75)
			self.btnGetCode.label:setPosition(ccp(pos.x + 40, pos.y - 6))
		end
	end

	if self.schedule then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
	end

	self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 1, false)
end

function UMPayPanel:checkMobileid( mobileid )
	self.mobileid = mobileid
	if mobileid and #mobileid == 11 then
		self.btnGetCode:setEnabled(not self.isCountDown)
	else
		self.btnGetCode:setEnabled(false)
		self.codeInput:setText("")
		self:checkSmsCode("")
	end
end

function UMPayPanel:checkSmsCode( smsCode )
	self.smsCode = smsCode
	self:checkPayEnabled()
end

function UMPayPanel:checkPayEnabled()
	local isMobile = self:isChinaMobilePhone(self.mobileid)

	local enable = isMobile 
					and self.smsCode and self.smsCode ~= ""
					and self.rqSmsCodeCount and self.rqSmsCodeCount >= 1

	self.btnSendCode:setEnabled(enable)
end

function UMPayPanel:setPayState( state )
	self.payState = state
end

function UMPayPanel:popout( replace )
	PopoutStack:push(self,true,false)
	local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
    self:setPosition(ccp(centerPosX, centerPosY))
end

function UMPayPanel:remove()
	if self.phoneNumbers then
		local str = ""
		local max = #self.phoneNumbers
		for index,n in ipairs(self.phoneNumbers) do
			if index ~= max then
				str = str .. n .. ","
			else
				str = str .. n
			end
		end

		CCUserDefault:sharedUserDefault():setStringForKey("umpay.default.phone.number", str)
	end
	PopoutStack:pop()
end

function UMPayPanel:onCancel( )
	self:remove()
	self.cb.cancel()
	-- CommonTip:showTip("本次交易已取消！", "negative")
end

function UMPayPanel:onKeyBackClicked()
	if not self.payState then
		self:onCancel()
	end
end


function UMPayPanel:setPhoneLoginCompleteCallback( phoneLoginCompleteCallback )
	self.phoneLoginCompleteCallback = phoneLoginCompleteCallback
end

function UMPayPanel:setBackCallback( backCallback )
	self.backCallback = backCallback
end