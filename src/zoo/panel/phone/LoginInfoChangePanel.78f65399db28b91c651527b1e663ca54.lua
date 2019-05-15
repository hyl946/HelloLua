
local ColorButton = class()

function ColorButton:ctor(btn, bg, txt)
	self.btn = btn
	self.bg = bg
	self.txt = txt
	self.txtOriginColor = txt:getColor()
end

function ColorButton:setDisable()
	self.btn:setTouchEnabled(false)
	self.bg:adjustColor(0, -1, 0, 0)
	self.bg:applyAdjustColorShader()
	self.txt:setColor(ccc3(120, 120, 120))
end

function ColorButton:setEnable(onClick)
	self.btn:setTouchEnabled(true)
	self.btn:addEventListener(DisplayEvents.kTouchTap, function()
		if onClick and type(onClick) == 'function' then onClick() end
	end)
	self.bg:adjustColor(0, 0, 0, 0)
	self.bg:applyAdjustColorShader()
	self.txt:setColor(self.txtOriginColor)
end

function ColorButton:create(btn, bg, txt)
	local v = ColorButton.new(btn, bg, txt)	
	return v
end

LoginInfoChangePanel = class(BasePanel)        

LoginInfoChangePanel.CancelBtnDecisionType = {
	kExitGame = 1,
	kSwitchLogin = 2,
}

local AlertReasonType = {
	kQQPlatformIncorrect = 1,	-- 应用宝/非应用宝安装包错误
	kSNSChangeToGuest = 2,		-- 登录方式由SNS账号登录变为游客登录
	kAccountIncorrect = 3,		-- 相同的loginType(非游客)不同的账号
	kLoginTypeNotExist = 4,		-- 原账号使用的loginType在当前Platform不支持
	kSNSChangeToSNS = 5,		-- 登录方式变化(非游客)
}

local AlertReasonDCType = {
	[AlertReasonType.kQQPlatformIncorrect] = "xibaoyyb",
	[AlertReasonType.kSNSChangeToGuest] = "xibaoyk",
	[AlertReasonType.kAccountIncorrect] = "xibaosns",
	[AlertReasonType.kLoginTypeNotExist] = "xibaobsns",
	[AlertReasonType.kSNSChangeToSNS] = "xibaobsns",
}

function LoginInfoChangePanel:ctor()
	
end

function LoginInfoChangePanel:init(alertInfo)
	self.ui	= self:buildInterfaceGroup("LoginChangeDetectPanel")
	BasePanel.init(self, self.ui)

	self.alertInfo = alertInfo

	local content = self.ui:getChildByName("content")

	local desc = self:buildDescContent(
		self:getDescContent(alertInfo),
		"802D16",
		content:getFontName(),
		content:getFontSize()
	)
	desc:setPositionX(content:getPositionX())
	desc:setPositionY(content:getPositionY())
	self.ui:addChild(desc)

	-- content:setString(self:getDescContent(alertInfo))

	local title = self.ui:getChildByName("title")
	title:setString(Localization:getInstance():getText("xibao_tips5"))

	local confirmText = self.ui:getChildByName("confirmTxt")
	local confirmBtn = self.ui:getChildByName("confirmBtn")
	local confirmBtnBg = confirmBtn:getChildByName("icon")
	self.confirmBtn = self:buildButton(confirmBtn, confirmBtnBg, confirmText)

	local cancelText = self.ui:getChildByName("cancelTxt")
	local cancelBtn = self.ui:getChildByName("cancelBtn")
	local cancelBtnBg = cancelBtn:getChildByName("icon")
	self.cancelBtn = self:buildButton(cancelBtn, cancelBtnBg, cancelText)

	confirmText:setString(Localization:getInstance():getText("xibao_tips7"))
	if alertInfo.reason == AlertReasonType.kQQPlatformIncorrect 
		or alertInfo.reason == AlertReasonType.kLoginTypeNotExist
		then
		cancelText:setString(Localization:getInstance():getText("xibao_tips6"))
	else
		cancelText:setString(Localization:getInstance():getText("login.panel.title.2"))
	end

	self.confirmBtn:setEnable(function() self:onConfirmClick() end)
	self.cancelBtn:setEnable(function() self:onCancelClick() end)

	self.alertInfo = alertInfo
	self:dcLogOnAppear(0)
end

function LoginInfoChangePanel:dcLogOnAppear(param)
	-- param : 0.面板出现 1.点左边按钮 2.点右边按钮
	local params = self.alertInfo.params
	local currentLoginType = params.currentLoginType
	local targetLoginType = params.targetLoginType
	local targetPlatform = params.targetPlatform
	local currentPlatform = PlatformConfig.name
	DcUtil:UserTrack({category = 'UI', sub_category = AlertReasonDCType[self.alertInfo.reason], 
		t1 = targetLoginType, t2 = currentLoginType, t3 = targetPlatform, t4 = currentPlatform, t5 = param})
end

function LoginInfoChangePanel:getDescContent(alertInfo)
	local reason = alertInfo.reason
	local params = alertInfo.params
	local currentLoginType = params.currentLoginType
	local targetLoginType = params.targetLoginType
	local targetTopLevelId = params.targetTopLevelId
	local targetPlatform = params.targetPlatform
	local currentTopLevelId = UserManager:getInstance().user:getTopLevelId()
	local result = nil	

	local function getText(key, value)
		return Localization:getInstance():getText(key, value)
	end

	local function getAuthName(auth)
		if auth == PlatformAuthEnum.kPhone then
			return getText("xibao_tips8")
		elseif auth == PlatformAuthEnum.kMI then
			return getText("platform.mi")
		else
			return PlatformConfig:getPlatformNameLocalization(auth)
		end
	end

	if reason == AlertReasonType.kQQPlatformIncorrect then
		local targetPf
		local targetAddr
		if PlatformConfig:isQQPlatform() then
			targetPf = getText("platform.he")
			if targetLoginType == PlatformAuthEnum.kWDJ 
				or targetLoginType == PlatformAuthEnum.kMI 
				or targetLoginType == PlatformAuthEnum.k360 
				then
				targetAddr = getAuthName(targetLoginType)
			else
				targetAddr = getText("platform.he")
			end
		else
			targetPf = getText("platform.yingyongbao")
			targetAddr = targetPf
		end
		result = getText("xibao_tips1", {
			n = '\n',
			replace1 = currentTopLevelId, 
			replace2 = targetTopLevelId, 
			replace3 = targetAddr, 
		})
	elseif reason == AlertReasonType.kSNSChangeToGuest then
		result = getText("xibao_tips2", {
			n = '\n',
			replace1 = getAuthName(targetLoginType),
			replace2 = targetTopLevelId,
			replace3 = getText("xibao_tips9"),
			replace4 = currentTopLevelId,
			replace5 = getAuthName(targetLoginType)
		})
	elseif reason == AlertReasonType.kAccountIncorrect then
		result = getText("xibao_tips3", {
			n = '\n',
			replace1 = currentTopLevelId,
			replace2 = targetTopLevelId,
			replace3 = getAuthName(currentLoginType),
		})
	elseif reason == AlertReasonType.kLoginTypeNotExist then
		if targetLoginType == PlatformAuthEnum.kWDJ 
			or targetLoginType == PlatformAuthEnum.kMI 
			or targetLoginType == PlatformAuthEnum.k360 
			then
			targetAddr = getAuthName(targetLoginType)
		else
			targetAddr = getText("platform.he")
		end
		result = getText("xibao_tips4", {
			n = '\n',
			replace1 = getAuthName(targetLoginType),
			replace2 = targetTopLevelId,
			replace3 = targetAddr
		})
	elseif reason == AlertReasonType.kSNSChangeToSNS then
		result = getText("xibao_tips2", {
			n = '\n',
			replace1 = getAuthName(targetLoginType),
			replace2 = targetTopLevelId,
			replace3 = getAuthName(currentLoginType),
			replace4 = currentTopLevelId,
			replace5 = getAuthName(targetLoginType)
		})
	end
	return result
end

function LoginInfoChangePanel:buildDescContent( text,defaultColor,fntName,fntSize )

	local container = CocosObject:create()
	if not text then
		return container
	end

	local textLines = {}
	for k,v in pairs(text:split("\n")) do
		
		local list = {}
		local stack = {
			{ text=v,color=defaultColor }
		}
		while #stack > 0 do 

			local s2,e2 = string.find(stack[#stack].text,"%[/#%]")
			if not s2 then 
				s2 = #stack[#stack].text + 1
				e2 = #stack[#stack].text - 1
			end

			local temp = string.sub(stack[#stack].text,1,s2-1)
			local s1,e1,color,align = string.find(temp,"%[#([0-9A-Fa-f]-)%,?(|?)]")

			if s1 then 
				local text1 = string.sub(stack[#stack].text,1,s1-1)
				local text2 = string.sub(stack[#stack].text,e1+1,#stack[#stack].text)

				table.insert(list,{ text=text1,color=stack[#stack].color })
				table.insert(stack,{ text=text2,color=color,align=align })
			else
				local text1 = string.sub(stack[#stack].text,1,s2-1)
				local text2 = string.sub(stack[#stack].text,e2+1,#stack[#stack].text)

				table.insert(list,{ text=text1,color=stack[#stack].color,align=stack[#stack].align})
				table.remove(stack,#stack)
				if #stack > 0 then 
					stack[#stack].text = text2
				end
			end
		end

		table.insert(textLines,list)
	end

	local labelLines = {}
	local alignWidth = 0
	local height
	for _,line in pairs(textLines) do
		table.insert(labelLines,{})
		for k,v in pairs(line) do
			-- local fnt = BitmapText:create(v.text,"fnt/tutorial_white.fnt")
			local label = CCLabelTTF:create(v.text,fntName,fntSize)
			label:setAnchorPoint(ccp(0,1))
			label:setColor(HeDisplayUtil:ccc3FromUInt(tonumber(v.color,16)))

			label = CocosObject.new(label)
			table.insert(labelLines[#labelLines],label)

			if v.align == "|" then
				label.align = v.align
				alignWidth = math.max(alignWidth,label:getContentSize().width)
			end

			if not height then
				height = label:getContentSize().height			
			end
		end
	end

	
	local posY = 0
	for _,line in pairs(labelLines) do
		local posX = 0
		for k,v in pairs(line) do
			local offsetX = 0
			if v.align then
				offsetX = (alignWidth - v:getContentSize().width) / 2
			end

			v:setPositionX(posX + offsetX)
			v:setPositionY(posY)
			container:addChild(v)

			posX = posX + v:getContentSize().width + offsetX * 2
		end

		posY = posY - height 
	end

	return container 
end

function LoginInfoChangePanel:buildButton(btn, bg, txt)
	local result = ColorButton:create(btn, bg, txt)
	return result
end

function LoginInfoChangePanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self.allowBackKeyTap = true
	self:setToScreenCenter()
end

function LoginInfoChangePanel:create(alertInfo)
	local panel = LoginInfoChangePanel.new()
	panel:loadRequiredResource("ui/login.json")
	panel:init(alertInfo)

	return panel
end

function LoginInfoChangePanel:onConfirmClick()
	self:dcLogOnAppear(1)
	if self.confirmCallback and type(self.confirmCallback) == 'function' then
		self.confirmCallback()
	end
end

function LoginInfoChangePanel:onCancelClick()
	self:dcLogOnAppear(2)
	if self.cancelCallback and type(self.cancelCallback) == 'function' then
		local decision = nil
		if self.alertInfo.reason == AlertReasonType.kQQPlatformIncorrect 
			or self.alertInfo.reason == AlertReasonType.kLoginTypeNotExist
			then
			decision = LoginInfoChangePanel.CancelBtnDecisionType.kExitGame
		else
			decision = LoginInfoChangePanel.CancelBtnDecisionType.kSwitchLogin
		end
		self.cancelCallback(decision)
		self.allowBackKeyTap = false
		PopoutManager:sharedInstance():remove(self, true)
	end
end

function LoginInfoChangePanel:setConfirmCallback(callback)
	self.confirmCallback = callback
end

function LoginInfoChangePanel:setCancelCallback(callback)
	self.cancelCallback = callback
end

