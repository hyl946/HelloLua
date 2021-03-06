--验证身份证信息
--只支持18位身份证的验证

--[[
#身份证18位编码规则：dddddd yyyymmdd xxx y   
#dddddd：地区码   
#yyyymmdd: 出生年月日   
#xxx:顺序类编码，无法确定，奇数为男，偶数为女   
#y: 校验码，该位数值可通过前17位计算获得  
#<p />  
#18位号码加权因子为(从右到左) Wi = [ 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2,1 ]  
#验证位 Y = [ 1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2 ]   
#校验位计算公式：Y_P = mod( ∑(Ai×Wi),11 )   
#i为身份证号码从右往左数的 2...18 位; Y_P为脚丫校验码所在校验码数组位置  
参考代码:
      https://github.com/yujinqiu/idlint
]]
local string_len = string.len
local tonumber = tonumber

-- // wi =2(n-1)(mod 11) 
local wi = { 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1 }; 
-- // verify digit 
local vi= { '1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2' }; 

local function isBirthDate(date)
    local year = tonumber(date:sub(1,4))
    local month = tonumber(date:sub(5,6))
    local day = tonumber(date:sub(7,8))
    if year < 1900 or year > 2016 or month >12 or month < 1 then
        return false
    end
    -- //月份天数表
    local month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    local bLeapYear = (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
    if bLeapYear  then
        month_days[2] = 29;
    end

    if day > month_days[month] or day < 1 then
        return false
    end

    return true
end

local function isAllNumberOrWithXInEnd( str )
    local ret = str:match("%d+X?") 
    return ret == str 
end


local function checkSum(idcard)
    -- copy from http://stackoverflow.com/questions/829063/how-to-iterate-individual-characters-in-lua-string
    local nums = {}
    local _idcard = idcard:sub(1,17)
    for ch in _idcard:gmatch"." do
        table.insert(nums,tonumber(ch))
    end
    local sum = 0
    for i,k in ipairs(nums) do
        sum = sum + k * wi[i]
    end

    return vi [sum % 11+1] == idcard:sub(18, 18)
end


local msg_success = 1
local err_length = -1
local err_province = -2
local err_birth_date = -3
local err_code_sum = -4
local err_unknow_charactor = -5

local function verifyIdCard(idcard)
    if string_len(idcard) ~= 18 then
        return err_length
    end

    if not isAllNumberOrWithXInEnd(idcard) then
        return err_unknow_charactor
    end
    -- //第1-2位为省级行政区划代码，[11, 65] (第一位华北区1，东北区2，华东区3，中南区4，西南区5，西北区6)
    local nProvince = tonumber(idcard:sub(1, 2))
    if( nProvince < 11 or nProvince > 65 ) then
        return err_province
    end

    -- //第3-4为为地级行政区划代码，第5-6位为县级行政区划代码因为经常有调整，这块就不做校验

    -- //第7-10位为出生年份；//第11-12位为出生月份 //第13-14为出生日期
    if not isBirthDate(idcard:sub(7,14)) then
        return err_birth_date
    end

    if not checkSum(idcard) then
        return err_code_sum
    end

    return msg_success
end


--[[local function UnitTest_CheckBirthDay()
    assert(isBirthDate('19881128') == true)
    assert(isBirthDate('19881328') == false)
    assert(isBirthDate('19881232') == false)
    assert(isBirthDate('19880229') == true)
    assert(isBirthDate('19880228') == true)
    assert(isBirthDate('18000228') == false)
    assert(isBirthDate('20000229') == true)
    assert(isBirthDate('21220228') == false)

end

local function UnitTest()
    print('begin UnitTest')
    UnitTest_CheckBirthDay()
    assert(verifyIdCard('411302198011276412') == err_code_sum)
    assert(verifyIdCard('4113021988112864x7') == err_unknow_charactor)
    assert(verifyIdCard('41130219881128641') == err_length)
end

UnitTest()]]--

local kHasFocusEvent = false
if __ANDROID then
	kHasFocusEvent = true
end

local DeviceType = {
	iPad = false,
	iPad3 = false,
	iPhone = false,
}
if __IOS then
	local deviceType = MetaInfo:getInstance():getMachineType() or ""
	for k,v in pairs(DeviceType) do
		DeviceType[k] = string.find(deviceType, k) ~= nil
	end
end


local IdCardInput = class(CocosObject)

function IdCardInput:verify()
	if string.isEmpty(self:getText()) then
		return false
	end

	if verifyIdCard(self:getText()) == msg_success then
		return true
	end

	return false
end

function IdCardInput:create(labelPlaceholder, panel, hideClearButton)
	local input = IdCardInput.new(CCNode:create())
	input:init(labelPlaceholder, panel, hideClearButton)
	return input
end

function IdCardInput:setClearButtonBG(style)
	if __ANDROID then
		self.input:setClearButtonBG(style)
	else
		--not supported yet!
	end
end

function IdCardInput:hideClearButton()
	if __ANDROID then
		self.input:hideClearButton()
	else
		--not supported yet!
	end
end

function IdCardInput:setEnabled(enabled)
	if __ANDROID then
		self.input:setEnabled(enabled)
	else
		--not supported yet!
	end
end

function IdCardInput:dispose( ... )
	CocosObject.dispose(self)

	if self.panel then
		self.panel:removeEventListener(PopoutEvents.kBecomeSecondPanel,self.becomeSecondPanel)
		self.panel:removeEventListener(PopoutEvents.kReBecomeTopPanel,self.reBecomeTopPanel)
	end
end

function IdCardInput:init(labelPlaceholder, panel, hideClearButton)

	local labelSize = labelPlaceholder:getDimensions()
	local labelPosX = labelPlaceholder:getPositionX()
	local labelPosY = labelPlaceholder:getPositionY()

	self:setAnchorPoint(ccp(0,1))
	self:setPositionX(labelPosX)
	self:setPositionY(labelPosY)
	self:setContentSize(labelSize)

	
	local inputSize = labelSize
	local inputBg = Scale9Sprite.new(CCScale9Sprite:create())
	if __ANDROID then
		self.input = require("hecore.ui.AndroidEditText"):create(inputSize,inputBg)
		if not hideClearButton then self.input:showClearButton() end
	else
		self.input = TextInput:create(inputSize,inputBg)
		self.input.refCocosObj:setZoomOnTouchDown(false)
		if not hideClearButton then self.input.refCocosObj:showClearButton() end
	end

	self:setFontColor(labelPlaceholder:getColor())
	
	local inputPosition = ccp(labelSize.width/2,labelSize.height/2)
	
	if __IOS then

		if DeviceType.iPhone then
			inputPosition.x = inputPosition.x - 12
		else
			inputPosition.x = inputPosition.x - 5
		end

		if DeviceType.iPad3 then
			inputPosition.y = inputPosition.y + 12
		elseif DeviceType.iPad then
			inputPosition.y = inputPosition.y + 6 + 7
		else
			inputPosition.y = inputPosition.y + 6
		end

		if DeviceType.iPad3 then
			self.input.refCocosObj:setClearButtonOffset(ccp(0,-10))
		end
	end

	self.input:setPosition(inputPosition)

	self.input.originalPosX = inputPosition.x
	self.input.originalPosY = inputPosition.y

	self.input:runAction(CCCallFunc:create(function( ... )
		self.input:setPosition(ccp(self.input.originalPosX,self.input.originalPosY))	
	end))
	self:addChild(self.input)

	for _,v in pairs({
		"setVisible",
		"openKeyBoard",
		"closeKeyBoard",
		-- "setText",
		-- "getText",
		-- "setFontColor",
		-- "setPlaceHolder",
		-- "setPlaceholderFontColor",
		"setMaxLength",
		-- "setIdCardInputMode",
		-- "setIdCardInputFlag",

		"hasEventListener",
		"hasEventListenerByName",
		"addEventListener",
		"removeEventListener",
		"removeEventListenerByName",
		"removeAllEventListeners",
		"dispatchEvent",
		"dp", 
		"he", 
		"hn", 
		"ad", 
		"rm", 
		"rma",
	}) do
		self[v] = function ( ... )
			local params = { ... } 
			params[1] = self.input
			return self.input[v](unpack(params))
		end
	end

	if panel then
		self.panel = panel
		self.becomeSecondPanel = function( ... )
			self:onBecomeSecondPanel()
		end
		self.reBecomeTopPanel = function( ... )
			self:onReBecomeTopPanel()
		end
		panel:addEventListener(PopoutEvents.kBecomeSecondPanel,self.becomeSecondPanel)
		panel:addEventListener(PopoutEvents.kReBecomeTopPanel,self.reBecomeTopPanel)
	end

	if __ANDROID and kHasFocusEvent and panel then
		if not panel.__inputs then
			panel.__inputs = {}
		end
		table.insert(panel.__inputs,self)
		self.input:addEventListener(kTextInputEvents.kGotFocus,function( ... )
			if self.input:getKeyboardHeight() > 0 and #panel.__inputs == 1 then
				self:onGotFocus(panel,self.input:getKeyboardHeight())
			else
				self:runAction(CCSequence:createWithTwoActions(
					CCDelayTime:create(0.15),
					CCCallFunc:create(function( ... )
						self:onGotFocus(panel,self.input:getKeyboardHeight())
					end)
				))
			end
		end)
		self.input:addEventListener(kTextInputEvents.kLostFocus,function( ... )
			self:runAction(CCSequence:createWithTwoActions(
				CCDelayTime:create(0.15),
				CCCallFunc:create(function( ... )
					self:onLostFocus(panel)
				end)
			))
		end)
	end

	if __IOS and panel then
		if not panel.__inputs then
			panel.__inputs = {}
		end
		table.insert(panel.__inputs,self)
		self.input.refCocosObj:registerScriptImeHandler(function( eventName )
			if eventName == "keyboardWillShow" then
				self:dispatchEvent(Event.new(kTextInputEvents.kGotFocus,nil,self))
				self:onGotFocus(panel,self.input.refCocosObj:getKeyboardHeight())
			elseif eventName == "keyboardWillHide" then
				self:dispatchEvent(Event.new(kTextInputEvents.kLostFocus,nil,self))
				self:onLostFocus(panel)
			end
		end)
	end

	self.input:addEventListener(kTextInputEvents.kBegan,function( ... )
			self.inputBegan = true
	end)

	self.input:addEventListener(kTextInputEvents.kEnded,function( ... )
			self.inputBegan = false
	end)

	--default font colors
	self:setFontColor(ccc3(180,94,16))
	self:setPlaceholderFontColor(ccc3(203, 203, 203))
end

function IdCardInput:hide( ... )
	self.isHide = true

	self.input:setPositionX(-100000)

	if self.label then
		self.label:setVisible(false)
	end
end
function IdCardInput:show( ... )
	self.isHide = false
	-- self.input:setPositionX(self.input.originalPosX)

	self:runAction(CCCallFunc:create(function( ... )
		self.input:setPositionX(self.input.originalPosX)
	end))
	
	if self.label then
		self.label:setVisible(false)
	end
end

function IdCardInput:getText( ... )
	return self.input:getText() or ""
end

function IdCardInput:setText( text )
	self.input:setText(text)

	if self.placeHolderLabel then
		self.placeHolderLabel:setVisible(string.isEmpty(self:getText()))
	end
end
function IdCardInput:setFontColor( color )
	self.fontColor = color
	self.input:setFontColor(color)
end
function IdCardInput:getFontColor( ... )
	return self.fontColor or ccc3(0,0,0)
end
function IdCardInput:setPlaceHolder( text )
	self.placeHolderText = text

	if not self.placeHolderLabel then 
		local height = self:getContentSize().height
		local size = height - 12
		if __ANDROID then 
			size = height - 20 + 0.5			
		end

		if __IOS then
			size = (height + 10)/2 + 0.5
		end

		self.placeHolderLabel = TextField.new(CCLabelTTF:create("","",size))
		if __ANDROID then 
			self.placeHolderLabel:setAnchorPoint(ccp(0,0.5))
			self.placeHolderLabel:setPosition(ccp(0,self:getContentSize().height/2 + 3))
		elseif __IOS then
			self.placeHolderLabel:setAnchorPoint(ccp(0,0.5))
			self.placeHolderLabel:setPosition(ccp(0,self:getContentSize().height/2))

			if DeviceType.iPad3 then
				self.placeHolderLabel:setPosition(ccp(7,self:getContentSize().height/2))
			elseif DeviceType.iPad then
				self.placeHolderLabel:setPosition(ccp(7,self:getContentSize().height/2))
			end
			
		else
			self.placeHolderLabel:setAnchorPoint(ccp(0,0.5))
			self.placeHolderLabel:setPosition(ccp(0,self:getContentSize().height/2))
		end
		self:addChild(self.placeHolderLabel)

		self.input:addEventListener(kTextInputEvents.kChanged,function( ... )
			self.placeHolderLabel:setVisible(string.isEmpty(self:getText()))
		end)
	end
	self.placeHolderLabel:setColor(self:getPlaceholderFontColor())
	self.placeHolderLabel:setString(text)
	self.placeHolderLabel:setVisible(string.isEmpty(self:getText()))
end
function IdCardInput:getPlaceHolder( ... )
	return self.placeHolderText or ""
end
function IdCardInput:setPlaceholderFontColor( color )
	self.placeholderFontColor = color
	self.input:setPlaceholderFontColor(color)

	if self.placeHolderLabel then
		self.placeHolderLabel:setColor(color)
	end
end
function IdCardInput:setInputMode( inputMode )
	self.inputMode = inputMode
	self.input:setInputMode(inputMode)
end

function IdCardInput:getInputMode( ... )
	return self.inputMode or -1
end

function IdCardInput:setInputFlag( inputFlag )
	self.inputFlag = inputFlag
	self.input:setInputFlag(inputFlag)
end

function IdCardInput:getInputFlag( ... )
	return self.inputFlag or -1
end

function IdCardInput:getPlaceholderFontColor( ... )
	return self.placeholderFontColor or ccc3(166,166,166)
end

function IdCardInput:onBecomeSecondPanel( ... )

	if self.isHide then
		return
	end

	if _G.isLocalDevelopMode then printx(0, "onBecomeSecondPanel") end
	self:runAction(CCCallFunc:create(function ( ... )
		self.input:setPositionX(-100000)
	end))

	if not self.label then
		local height = self:getContentSize().height

		local size = height - 12
		if __ANDROID then 
			size = height - 20 + 0.5			
		end

		if __IOS then
			size = (height + 10)/2 + 0.5

			if DeviceType.iPad3 then
				size = size + 7
			elseif DeviceType.iPad then
				size = size + 7
			end
		end

		self.label = TextField.new(CCLabelTTF:create("","",size))
		self.label:setDimensions(self:getContentSize())
		if __ANDROID then 
			self.label:setAnchorPoint(ccp(0,0.5))
			self.label:setPosition(ccp(0,self:getContentSize().height/2 + 3))
		elseif __IOS then
			self.label:setAnchorPoint(ccp(0,0.5))
			self.label:setPosition(ccp(0,self:getContentSize().height/2))

			if DeviceType.iPad3 then
				self.label:setPosition(ccp(7,self:getContentSize().height/2))
			elseif DeviceType.iPad then
				self.label:setPosition(ccp(7,self:getContentSize().height/2))
			end
		else
			self.label:setAnchorPoint(ccp(0,0.5))
			self.label:setPosition(ccp(0,self:getContentSize().height/2))
		end
		self.label:setHorizontalAlignment(kCCTextAlignmentLeft)
		self.label:setVerticalAlignment(kCCVerticalTextAlignmentCenter)

		self.label:setVisible(false)
		self:addChild(self.label)
	end

	if not string.isEmpty(self:getText()) then
		if self:getInputFlag() == kEditBoxInputFlagPassword then
			self.label:setString(string.rep("●",#self:getText()))
		else
			self.label:setString(self:getText())
		end

		--[[setTimeOut( function(...) 
			if  not self.isDisposed then
				self.label:setColor(self:getFontColor())
				self.label:setVisible(true)
			end
		end, 1/30 )]]--

		self:runAction(CCCallFunc:create(function( ... )
			self.label:setColor(self:getFontColor())
			self.label:setVisible(true)
		end))
	end
end

function IdCardInput:onReBecomeTopPanel( ... )

	if self.isHide then
		return
	end
	if _G.isLocalDevelopMode then printx(0, "onReBecomeTopPanel") end
	self:runAction(CCCallFunc:create(function( ... )
		self.input:setPositionX(self.input.originalPosX)
	end))

	if self.label then
		self.label:setVisible(false)
	end

end

function IdCardInput:onGotFocus( panel,keyboardHeight )

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local bounds = panel.ui:getChildByName("bg"):getGroupBounds()

	if not keyboardHeight or keyboardHeight <= 0 then
		keyboardHeight = visibleSize.height * 0.4
	end

	visibleSize.height = math.max(visibleSize.height - keyboardHeight,bounds.size.height)

	panel.__panelMovePos = ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	)

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.05),
		CCCallFunc:create(function( ... )
			panel:setPosition(panel.__panelMovePos)

			for _,v in pairs(panel.__inputs) do
				v.input:setPosition(ccp(v.input:getPositionX(),v.input:getPositionY()))
			end
		end)
	))

end

function IdCardInput:onLostFocus( panel )

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local bounds = panel.ui:getChildByName("bg"):getGroupBounds()

	panel.__panelMovePos = ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	)

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.05),
		CCCallFunc:create(function( ... )
			panel:setPosition(panel.__panelMovePos)
			
			for _,v in pairs(panel.__inputs) do
				v.input:setPosition(ccp(v.input:getPositionX(),v.input:getPositionY()))
			end
		end)
	))

end

return IdCardInput