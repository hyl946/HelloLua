EnterContactInfoPanel = class(BasePanel)

local ContactInfoType = table.const{
	kName = 1,
	kPhone = 2,
	kAddress = 3,
}

------------------------------ EnterContactInfoPanelController ------------------------------

EnterContactInfoPanelController = class()

function EnterContactInfoPanelController:getInfoByType(infoType)
	local contactInfo = self:getContactInfo()
	if type(contactInfo) == "table" then
		if infoType == ContactInfoType.kName then
			return contactInfo.name
		elseif infoType == ContactInfoType.kPhone then
			return contactInfo.phone
		elseif infoType == ContactInfoType.kAddress then
			return contactInfo.address
		end 
	end
	return nil
end

function EnterContactInfoPanelController:getActId()
	return 0
end

function EnterContactInfoPanelController:isContactInfoFull()
	return false
end

function EnterContactInfoPanelController:updateContactInfo(contactInfo)

end

function EnterContactInfoPanelController:getContactInfo()
	return nil
end

function EnterContactInfoPanelController:onEnterContactCloseCallback()

end

function EnterContactInfoPanelController:onEnterContactConfirmCallback()

end

------------------------------ InputItem ------------------------------

local InputItem = class()

function InputItem:create( inputDisplay, errorDisplay, index, contact )
	-- body
	local s = InputItem.new()
	s:init(inputDisplay, errorDisplay, index, contact)
	return s
end

function InputItem:init( inputDisplay, errorDisplay, index, contact )
	-- body
	self.inputDisplay = inputDisplay
	self.errorDisplay = errorDisplay
	self.index = index
	self.contact = contact

	local box = errorDisplay:getChildByName("box")
	errorDisplay:getChildByName("txt"):setString(
		Localization:getInstance():getText("exchangecode.information"..index))
	box:getChildByName("txt"):setString(
		Localization:getInstance():getText("exchangecode.information.tip"..index))

	errorDisplay:setVisible(false)

	local function onErrorDisplayBegin( ... )
		-- body
		self:hideError()
	end
	errorDisplay:setTouchEnabled(true, 0, false)
	errorDisplay:addEventListener(DisplayEvents.kTouchBegin, onErrorDisplayBegin)
	self.txt = inputDisplay:getChildByName("txt"):setString(
		Localization:getInstance():getText("exchangecode.information"..index))

	self:initInput()

end

function InputItem:initInput( ... )
	-- body
	local inputBg = self.inputDisplay:getChildByName("input_c")
	local inputSize = inputBg:getGroupBounds().size--inputBg:getContentSize()
	local inputPos = inputBg:getPosition()
	local parent = inputBg:getParent()
	inputBg:removeFromParentAndCleanup(false)

	-- local function onTextBegin()
	-- 	self:hideError()
	-- end

	local function onTextChange()
		local text = self.input:getText() or ""
		if string.len(text) < 1 then return end
		local charTab = {}
		for uchar in string.gfind(text, "[%z\1-\127\194-\244][\128-\191]*") do
			table.insert(charTab, uchar)
		end
		self.input:setText(table.concat(charTab))
	end

	local function onTextEnd( evt )
		-- body
		if self.input then 
			onTextChange()
			local text = self.input:getText() or ""
			if text ~= "" then
				self.input:setText(text)
				self.contact.isChanged = true
			end
		end

	end

	local position = ccp(inputPos.x + inputSize.width/2, inputPos.y - inputSize.height/2)
	-- local input = TextInputIm:create(inputSize, 
	-- 	Scale9Sprite:createWithSpriteFrameName("inputBg_collect_info0000"), inputBg.refCocosObj)
	local input = TextInputIm.new()
    input:init(inputSize, Scale9Sprite:createWithSpriteFrameName("inputBg_collect_info0000"))

    local _y = input.label:getPositionY()
    input.label:setPositionY(_y + 10)
	input.originalX_ = position.x
	input.originalY_ = position.y
	input:setPosition(position)
	input:setFontColor(ccc3(66,33,00))
	if self.index == 2 then  ---电话
		input:setInputMode(kEditBoxInputModePhoneNumber)
		input:setMaxLength(11)
	end
	input:addEventListener(kTextInputEvents.kEnded, onTextEnd)
	-- input:addEventListener(kTextInputEvents.kBegan, onTextBegin)
	parent:addChild(input)

	input:setText(self.contact.contoller:getInfoByType(self.index))
	self.input = input

	inputBg:dispose()
end

function InputItem:getText( ... )
	-- body
	if self.input and self.input:getText() then 
		return self.input:getText()
	else
		return ""
	end
end

function InputItem:check( ... )
	-- body
	if self.input:getText() == "" then
		self:showError()
		return false
	end
	return true
end

function InputItem:showError( ... )
	-- body
	self.errorDisplay:setVisible(true)
	self.txt:setVisible(false)
end

function InputItem:hideError( ... )
	-- body
	self.errorDisplay:setVisible(false)
	self.txt:setVisible(true)
end


------------------------------ EnterContactInfoPanel ------------------------------

function EnterContactInfoPanel:create(rewardData, contoller)
	local s = EnterContactInfoPanel.new()
	s:loadRequiredResource(PanelConfigFiles.cd_key_exchange_panel)
	s:init(rewardData, contoller)
	return s
end

function EnterContactInfoPanel:init(rewardData, contoller)
	self.contoller = contoller
	----------------------
	-- Get UI Componenet
	-- -----------------
	self.ui	= self:buildInterfaceGroup("collect_info_panel")--ResourceManager:sharedInstance():buildGroup("cdkey")
	self.rewardData = rewardData
	self.isChanged = false
	--------------------
	-- Init Base Class
	-- --------------
	BasePanel.init(self, self.ui)

	self.ui:setTouchEnabled(true, 0, true)
	self:initButton()
	self:initText()
	self:initInputText()
end

function EnterContactInfoPanel:initButton( ... )
	-- body
	-- close button
	local function closebtnTapped( ... )
		-- body
		if self.rewardData and not self.contoller:isContactInfoFull() then
			local now = os.time() + (__g_utcDiffSeconds or 0)
			local time_limit = tonumber(self.rewardData.endTime)
			if now >= time_limit then
				local txt = {tip = Localization:getInstance():getText("exchangecode.tip.giveup"), 
							yes = Localization:getInstance():getText("exchangecode.button.back"),
							no = Localization:getInstance():getText("exchangecode.button.quit")}
				local function yesCallback( ... )
					-- body
				end

				local function noCallback( ... )
					-- body
					self:onCloseBtnTapped()
				end
				CommonTipWithBtn:showTip(txt, 2, yesCallback, noCallback)
			else
				CommonTip:showTip(Localization:getInstance():
					getText("exchangecode.tip.quit", {num = self.rewardData:getEndTimeString()}))
				self:onCloseBtnTapped()
			end
		else
			self:onCloseBtnTapped()
		end
	end
	self.closeBtn = self.ui:getChildByName("close_btn")
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, closebtnTapped)

	local function onOkBtnTapped( evt)
		-- body
		self:onOkBtnTapped()
	end
	--okBtn
	self.okBtn = GroupButtonBase:create(self.ui:getChildByName("okBtn"))

	local txt = Localization:getInstance():getText("login.panel.button.11")

	self.okBtn:setString(txt)
	self.okBtn:addEventListener(DisplayEvents.kTouchTap, onOkBtnTapped)
	self.okBtn:useBubbleAnimation()

end

function EnterContactInfoPanel:initText( ... )
	-- body
	if self.rewardData then
		local tip_congratulation = self.ui:getChildByName("tip2")
		tip_congratulation:setString(Localization:getInstance():getText("exchangecode.goods"))

		local tip_reward = self.ui:getChildByName("tip_reward")
		tip_reward:setString(self.rewardData:getMaterialDesc())

		local timeLimitLabel = self.ui:getChildByName("time_tip")
		timeLimitLabel:setString(Localization:getInstance():
			getText("exchangecode.time",{num = self.rewardData:getEndTimeString()}))
	end

	local tip_context = self.ui:getChildByName("tip")
	tip_context:setString(Localization:getInstance():getText("exchangecode.description"))

end

function EnterContactInfoPanel:initInputText( ... )
	-- body
	self.inputList = {}
	for k = 1, 3 do
		local inputDisplay = self.ui:getChildByName("input_"..k)
		local errorDisplay = self.ui:getChildByName("input_red_"..k)
		local item = InputItem:create(inputDisplay, errorDisplay, k, self)
		table.insert(self.inputList, item)
	end

end

function EnterContactInfoPanel:onOkBtnTapped( ... )
	-- body
	local isShowTip = false

	local contact = {}
	for k, v in pairs(self.inputList) do 
		if not v:check() then
			isShowTip = true
		else
			if v.index == 1 then 
				contact.name = v:getText()
			elseif v.index == 2 then
				contact.phone  = v:getText()
			elseif v.index == 3 then 
				contact.address = v:getText()
			end
		end
	end

	if isShowTip then
		CommonTip:showTip(Localization:getInstance():getText("exchangecode.tip.miss"))
		return 
	end

	local function onSuccess( ... )
		-- body
		CommonTip:showTip(Localization:getInstance():getText("exchangecode.tip.save"), "positive")
		if self.contoller.onEnterContactConfirmCallback then
			self.contoller:onEnterContactConfirmCallback(contact)
		end
		self:dismissPanel()
	end

	local function onFail( evt )
		-- body
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)))
	end

	if self.isChanged then
		local http = ContextHttp.new(true)
		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
		http:load(self.contoller:getActId(), contact)
	else
		if self.contoller.onEnterContactConfirmCallback then
			self.contoller:onEnterContactConfirmCallback(nil)
		end
		self:dismissPanel()
	end
end

function EnterContactInfoPanel:onCloseBtnTapped(event, ...)
	if not self.isDisposed then
		if self.contoller.onEnterContactCloseCallback then
			self.contoller:onEnterContactCloseCallback(nil)
		end
		self:dismissPanel()
	end
end

function EnterContactInfoPanel:popout()
	local function onAnimOver()
		self.allowBackKeyTap = true
	end
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
end

function EnterContactInfoPanel:dismissPanel()
	if not self.isDisposed then
		PopoutManager:sharedInstance():remove(self, true)
	end
end

function EnterContactInfoPanel:getHCenterInParentX(...)
	assert(#{...} == 0)

	-- Vertical Center In Screen Y
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	-- local selfHeight	= self:getGroupBounds().size.height
	local selfWidth = self.ui:getChildByName("bg"):getGroupBounds().size.width

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	local vCenterInScreenX	= visibleOrigin.x + halfDeltaWidth

	-- Vertical Center In Parent Y
	local parent 		= self:getParent()
	local posInParent	= parent:convertToNodeSpace(ccp(vCenterInScreenX, 0))

	return posInParent.x
end
