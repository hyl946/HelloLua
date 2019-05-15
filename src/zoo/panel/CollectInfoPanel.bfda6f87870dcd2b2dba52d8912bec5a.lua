
CollectInfoPanel = class(BasePanel)

local UserInfoMation = table.const{
	kName = 1,
	kCall = 2,
	kAddress = 3,
}

function CollectInfoPanel:isInfoFull( ... )
	return CDKeyManager:getInstance():isInfoFull()
end

function CollectInfoPanel:updateExchangeCodeInfo(contact)
	CDKeyManager:getInstance():updateExchangeCodeInfo(contact)
end


function CollectInfoPanel:getExchangeInfoByIndex(index)
	return CDKeyManager:getInstance():getExchangeInfoByIndex(index)
end

function CollectInfoPanel:getRequestExtra( ... )
	return nil
end

function CollectInfoPanel:create(rewardData, closeCallback)
	local s = CollectInfoPanel.new()
	s:loadRequiredResource(PanelConfigFiles.cd_key_exchange_panel)
	s:init(rewardData, closeCallback)
	return s
end

function CollectInfoPanel:init(rewardData, closeCallback)

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

	self.closeCallback = closeCallback
	self.ui:setTouchEnabled(true, 0, true)
	self:initButton()
	self:initText()
	self:initInputText()
	
end

function CollectInfoPanel:initButton( ... )
	-- body
	-- close button
	local function closebtnTapped( ... )
		-- body
		if self.rewardData and not self:isInfoFull() then
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

function CollectInfoPanel:initText( ... )
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

function CollectInfoPanel:initInputText( ... )
	-- body
	self.inputList = {}
	for k = 1, 3 do
		local inputDisplay = self.ui:getChildByName("input_"..k)
		local errorDisplay = self.ui:getChildByName("input_red_"..k)
		local item = InputItem:create(inputDisplay, errorDisplay, k, self,self:getExchangeInfoByIndex(k))
		table.insert(self.inputList, item)
	end

end

function CollectInfoPanel:onOkBtnTapped( ... )
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
		self:updateExchangeCodeInfo(contact)
		CommonTip:showTip(Localization:getInstance():getText("exchangecode.tip.save"))
		self:onCloseBtnTapped()
	end

	local function onFail( evt )
		-- body
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)))
	end

	if self.isChanged then
		local http = ContextHttp.new(true)
		http:ad(Events.kComplete, onSuccess)
		http:ad(Events.kError, onFail)
		http:load(0, contact, self:getRequestExtra())
	else
		self:onCloseBtnTapped()
	end

end

function CollectInfoPanel:onCloseBtnTapped(event, ...)
	if not self.isOnCloseBtnTappedCalled then
		self.isOnCloseBtnTappedCalled = true
		self:remove()
	end
end

function CollectInfoPanel:popout()
	local function onAnimOver()
		self.allowBackKeyTap = true
	end
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
end

function CollectInfoPanel:remove(...)
	if self.closeCallback and type(self.closeCallback) == "function" then
		self.closeCallback()
	end
	PopoutManager:sharedInstance():remove(self, true)

end

function CollectInfoPanel:getHCenterInParentX(...)
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


InputItem = class()

function InputItem:create( inputDisplay, errorDisplay, index, contact, inputText )
	-- body
	local s = InputItem.new()
	s:init(inputDisplay, errorDisplay, index, contact, inputText)
	return s
end

function InputItem:init( inputDisplay, errorDisplay, index, contact, inputText )
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

	self:initInput(inputText)

end

function InputItem:initInput( inputText )
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

	-- input:setText(CDKeyManager:getInstance():getExchangeInfoByIndex(self.index))
	input:setText(inputText)
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


-- 三方平台，实物中奖信息
RewardCollectInfoPanel = class(CollectInfoPanel)

function RewardCollectInfoPanel:create( physicalReward,closeCallback )
	local panel = RewardCollectInfoPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.cd_key_exchange_panel)
	panel:init(physicalReward,closeCallback)
	return panel
end

function RewardCollectInfoPanel:init( physicalReward,closeCallback )
	self.physicalReward = physicalReward
 	function self.physicalReward:getEndTimeString( ... )
		local t = os.date("*t", tonumber(self.endTime/1000))
		
		-- 特殊处理，不管后面23时统一显示成24时
		local hour = t.hour
		if hour == 23 then
			hour = 24
		end
		return string.format("%d年%d月%d日%d时",t.year,t.month,t.day,hour)
	end

 	local context = self

	local rewardData = {}
	rewardData.endTime = self.physicalReward.endTime/1000
	function rewardData:getEndTimeString( ... )
		return context.physicalReward:getEndTimeString()
	end
	function rewardData:getMaterialDesc( ... )
		return ""
	end 

	CollectInfoPanel.init(self,rewardData,closeCallback)
end

function RewardCollectInfoPanel:initText( ... )

	local tip_reward = self.ui:getChildByName("tip_reward")
	tip_reward:setPositionX(60)
	tip_reward:setDimensions(CCSizeMake(500,0))
	tip_reward:setString(self.physicalReward.desc)

	local timeLimitLabel = self.ui:getChildByName("time_tip")
	timeLimitLabel:setString(Localization:getInstance():getText("exchangecode.time",{num = self.physicalReward:getEndTimeString()}))

	local tip_context = self.ui:getChildByName("tip")
	tip_context:setString(Localization:getInstance():getText("exchangecode.description"))

	local diffHeight = tip_reward:getContentSize().height - 40
	for k,v in pairs({"bg2","bg"}) do
		local bg = self.ui:getChildByName(v)
		local size = bg:getPreferredSize() 
		bg:setPreferredSize(CCSizeMake(size.width,size.height + diffHeight))
	end
	for k,v in pairs({
		"bg3","tip","input_1","input_red_1","input_2","input_red_2","input_3","input_red_3","time_tip","okBtn"
	}) do
		local u = self.ui:getChildByName(v)
		u:setPositionY(u:getPositionY() - diffHeight)
	end

end

function RewardCollectInfoPanel:isInfoFull( ... )
	return CDKeyManager:getInstance():isInfoFull()
end

function RewardCollectInfoPanel:updateExchangeCodeInfo(contact)
	CDKeyManager:getInstance():updateExchangeCodeInfo(contact)
end


function RewardCollectInfoPanel:getExchangeInfoByIndex(index)
	return CDKeyManager:getInstance():getExchangeInfoByIndex(index)
end

function RewardCollectInfoPanel:getRequestExtra( ... )
	return self.physicalReward.id
end