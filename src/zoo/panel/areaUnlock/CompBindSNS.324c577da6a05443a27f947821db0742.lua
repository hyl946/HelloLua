local CompBindSNS = class()

function CompBindSNS:create(parentPanel, ui)
	local comp = CompBindSNS.new()
	comp:init(parentPanel, ui)
	return comp
end

function CompBindSNS:init(parentPanel, ui)
	self.parentPanel = parentPanel
	self.ui = ui

	self:checkBindSNS()
	self.snsLabel = self.ui:getChildByName("label_sns")
	self.qqIcon = self.ui:getChildByName("icon_qq")
	self.wechatIcon = self.ui:getChildByName("icon_wechat")
	self.phoneIcon = self.ui:getChildByName("icon_phone")
	self.t360Icon = self.ui:getChildByName("icon_360")
	self.phoneIcon:setVisible(false)
	self.qqIcon:setVisible(false)
	self.wechatIcon:setVisible(false)
	self.t360Icon:setVisible(false)
	if self.singleAuth == PlatformAuthEnum.k360 then
		self.t360Icon:setVisible(true)
		self.snsIcon = self.t360Icon
		self.snsLabel:setString(Localization:getInstance():getText("unlock.cloud.desc7", {num="360"}))
	elseif self.singleAuth == PlatformAuthEnum.kWechat then
		self.wechatIcon:setVisible(true)
		self.snsIcon = self.wechatIcon
		self.snsLabel:setString(Localization:getInstance():getText("unlock.cloud.desc7", {num="微信"}))
	else
		self.phoneIcon:setVisible(true)
		self.snsIcon = self.phoneIcon
		self.snsLabel:setString(Localization:getInstance():getText("unlock.cloud.desc7", {num="手机"}))
	end
	self.snsBtn = GroupButtonBase:create(self.ui:getChildByName('btn_sns'))
	self.snsBtn:setString(Localization:getInstance():getText('unlock.cloud.desc9'))
	self.snsBtn:ad(DisplayEvents.kTouchTap, function () self:bindSNS() end )
end

function CompBindSNS:checkBindSNS()
	self.singleAuth = self:getSNSAuth()
	local localData = Localhost:readUnlockLocalInfo()
	if not localData then
		localData = {}
		localData.lastBindSnsType = nil
		localData.lastBindAreaId = nil
	end
	localData.lastBindSnsType = self.singleAuth
	localData.lastBindAreaId = self.parentPanel.lockedCloudId
	Localhost:saveUnlockLocalInfo( localData )
end

function CompBindSNS:getSNSAuth()
	if PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) then return end
	local profile = UserManager:getInstance().profile
	local usedSnsSource = UserManager:getInstance().usedSnsSource

	if not usedSnsSource then usedSnsSource = {} end

	local authConfig = PlatformConfig.authConfig
	local singleAuth = nil

	local function getAuthDetailName(auth)
		local authDetail = PlatformAuthDetail[auth]
		if authDetail and authDetail.name then
			return authDetail.name
		end
		return "nil"
	end
	
	if type(authConfig) == "table" then
		local canWechat = false
		local canPhone = false
		local can360 = false
		for k,v in pairs(authConfig) do
			local authName = getAuthDetailName(v)
			if v == PlatformAuthEnum.kWechat and not profile:isWechatBound() and not usedSnsSource[authName] then
				canWechat = true
			end
			if v == PlatformAuthEnum.kPhone and not profile:isPhoneBound() and not usedSnsSource[authName] then
				canPhone = true
			end
			if v == PlatformAuthEnum.k360 and not profile:is360Bound() and not usedSnsSource[authName] then
				can360 = true
			end
		end

		if canWechat and canPhone then
			local cfgPriorityMaintenance = MaintenanceManager:getInstance():getMaintenanceByKey("AreaUnlockPushPriority")
			local cfgPriority
			if cfgPriorityMaintenance ~= nil then cfgPriority = cfgPriorityMaintenance.extra end
			if cfgPriority == nil then  cfgPriority = "360,phone,wechat,mi,wdj,weibo" end

			if cfgPriority ~= nil then
				local idxWechat = string.find(cfgPriority, "wechat")
				local idxPhone = string.find(cfgPriority, "phone")
				if idxWechat and idxPhone and idxWechat < idxPhone then 
					canPhone = false
				else 
					canWechat = false
				 end
			end
		end

		if can360 then
			singleAuth = PlatformAuthEnum.k360
		elseif canWechat then
			singleAuth = PlatformAuthEnum.kWechat
		elseif canPhone then
			singleAuth = PlatformAuthEnum.kPhone
		end

	else
		local authName = getAuthDetailName(authConfig)
		if authConfig == PlatformAuthEnum.k360 and not profile:is360Bound() and not usedSnsSource[authName] then
			singleAuth = PlatformAuthEnum.k360
		elseif authConfig == PlatformAuthEnum.kWechat and not profile:isWechatBound() and not usedSnsSource[authName] then
			singleAuth = PlatformAuthEnum.kWechat
		elseif authConfig == PlatformAuthEnum.kPhone and not profile:isPhoneBound() and not usedSnsSource[authName] then
			singleAuth = PlatformAuthEnum.kPhone
		end
	end

	return singleAuth
end

function CompBindSNS:bindSNS()
	local function sendUnlockMsgBySNS(lastBindSnsType)
		local function onSendUnlockMsgSuccess(event)
			if _G.isLocalDevelopMode then printx(0, "onSendUnlockMsgSuccess Called !") end
			local localData = Localhost:readUnlockLocalInfo()
			localData.lastBindSnsType = 0
			localData.lastBindAreaId = 0
			Localhost:saveUnlockLocalInfo( localData )
			local function onRemoveSelfFinish()
				self.parentPanel.unlockCloudSucessCallBack()
				if _G.isLocalDevelopMode then printx(0, "onRemoveSelfFinish Called !") end
			end
			self.isUnlockSuccess = true
			self.parentPanel:remove(onRemoveSelfFinish)
		end

		local function onSendUnlockMsgFailed(errorCode)
			self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_NONE
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
		end

		local function onSendUnlockMsgCanceled(event)
			self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_NONE
		end

		local logic = UnlockLevelAreaLogic:create(self.parentPanel.lockedCloudId)
		logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
		logic:setOnFailCallback(onSendUnlockMsgFailed)
		logic:setOnCancelCallback(onSendUnlockMsgCanceled)
		local datas = {}
		local authDetail = PlatformAuthDetail[lastBindSnsType]
		if authDetail and authDetail.name then
			datas.auth = authDetail.name
			logic:start(UnlockLevelAreaLogicUnlockType.USE_SNS, nil , nil , datas)
		end
	end
	
	---------------------------------------------------------------
	local function onConnectFinish()
		sendUnlockMsgBySNS( self.singleAuth )
	end
	local function onConnectError()
	end
	local function onConnectCancel()
	end
	local function onReturnCallback()
	end
	local function onSuccess()
		sendUnlockMsgBySNS( self.singleAuth )
	end

	if self.singleAuth == PlatformAuthEnum.kWechat or self.singleAuth == PlatformAuthEnum.k360 then
		AccountBindingLogic:bindNewSns( self.singleAuth, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.AREA_UNLOCK)
	elseif self.singleAuth == PlatformAuthEnum.kPhone then
		AccountBindingLogic:bindNewPhone(onReturnCallback, onSuccess, AccountBindingSource.AREA_UNLOCK)
	end
end

return CompBindSNS