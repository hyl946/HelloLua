require "zoo.panel.RealName.RealNamePanel"

PushRealNameEvent = {
	kClose = 'PushRealName.Event.kClose',
	kFail = 'PushRealName.Event.kFail',
	kSuccess = 'PushRealName.Event.kSuccess'
}

RealNamePanelType = table.const{
	idcard1 = 1,
	idcard2 = 2,
	idcard3 = 3,
	idcard4 = 4,
	phone1 = 5,
	phone2 = 6,
	phone360 = 7,
	help = 8,
	offlineSuccess = 9,
	offlineFail = 10,
	onlineSuccess = 11,
	onlineFail = 12,
}

RealNameEntryType = table.const{
	forcePopout = 0,
	homeScene = 1, 
	pay = 2
}

RealNameRewardType = table.const{
	phone = 1, 
	idcard = 2
}

local RealNameCondition = table.const{
	A1 = "A1",
	A2 = "A2",
	A3 = "A3",
	B1 = "B1",
	B2 = "B2",
	B3 = "B3",
	C1 = "C1",
	C2 = "C2",
	C3 = "C3",
}

local function hasAccountBinded()
    return UserManager.getInstance().profile:isPhoneBound() or UserManager.getInstance().profile:isSNSBound()
end

local function isGuest( ... )
    if hasAccountBinded() then
        return false
    else
        return true
    end
end

local function isPhoneAuthed()
	local enabled = UserManager:getInstance().realNameAuthed
	if enabled == nil then
		return true
	end

	return enabled
end

local function isIdCardAuthed()
	local enabled = UserManager:getInstance().realNameIdCardAuthed
	if enabled == nil then
		return true
	end

	return enabled
end

local function getAuthMode(data)--根据实名方式和触发条件判断是否需要验证
	if data == RealNameCondition.A1 then 
		data = "1-1"
	elseif data == RealNameCondition.A2 then
		data = "1-2"
	elseif data == RealNameCondition.A3 then
		data = "1-3"
	elseif data == RealNameCondition.B1 then
		data = "2-1"
	elseif data == RealNameCondition.B2 then
		data = "2-2"
	elseif data == RealNameCondition.B3 then
		data = "2-3"
	elseif data == RealNameCondition.C1 then
		data = "3-1"
	elseif data == RealNameCondition.C2 then
		data = "3-2"  
	elseif data == RealNameCondition.C3 then 
		data = "3-3"
	else
		data = nil
	end
	
	if data then
		local dataArr = string.split(data, '-')
		local mode, condition = tonumber(dataArr[1]), tonumber(dataArr[2])
		
		if condition == 1 then
			if UserManager.getInstance().profile:isPhoneBound() then
				return false, mode
			elseif UserManager.getInstance().profile:is360Bound() then
				return false, mode
			elseif isIdCardAuthed() or isPhoneAuthed() then
				return false, mode
			else
				return true, mode
			end
		elseif condition == 2 then
			if not isGuest() then
				return false, mode
			elseif isIdCardAuthed() or isPhoneAuthed() then
				return false, mode
			else
				return true, mode
			end
		else--if condition == 3 then
			return not isIdCardAuthed(), mode
		end	
	else
		return false, nil
	end
end

local function isNeedAuth(switch)
	if switch and switch.enable then 
		if switch.extra then 
			local config = {}
			for config_provice, config_authMode in string.gmatch(switch.extra, '([^,:]+):([^,:]+)') do
				config[config_provice] = config_authMode
			end
			local _, curProcice = RealNameManager:getLocationInfoCached()
			curProcice = curProcice or ''
			if config[curProcice] ~= nil then
				return getAuthMode(config[curProcice])
			end
			if config['全国'] ~= nil then
				return getAuthMode(config['全国'])
			end
		end

		if MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.A1 , uid) then
			return getAuthMode(RealNameCondition.A1)--模式1条件1
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.A2, uid) then
			return getAuthMode(RealNameCondition.A2)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.A3, uid) then
			return getAuthMode(RealNameCondition.A3)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.B1, uid) then
			return getAuthMode(RealNameCondition.B1)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.B2, uid) then
			return getAuthMode(RealNameCondition.B2)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.B3, uid) then
			return getAuthMode(RealNameCondition.B3)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.C1, uid) then
			return getAuthMode(RealNameCondition.C1)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.C2, uid) then
			return getAuthMode(RealNameCondition.C2)
		elseif MaintenanceManager:getInstance():isEnabledInGroup(switch.name, RealNameCondition.C3, uid) then
			return getAuthMode(RealNameCondition.C3)
		end
	end
		
	return false, nil
end

local function isWait()--是不是异步认证等待中
	return (UserManager:getInstance().realNameStatus == 3 and true or false)
end

RealNameManager = {}

function RealNameManager:init()
	--支付时, 未完成实名认证使用如下错误码
	self.errCode = -1000061
	self.errMsg = '未完成认证，本次支付失败~'
	self.errWaitCode = -999999

	self.autoed = false
	self.handledEvent = false
	self.triggered = false
	self.dcData = nil
	self.homeSceneAuthMode = nil
	self.payAuthMode = nil
	self.isCallSDK = nil
	self.isAuthing = nil --认证进行中

	local authConfigs = PlatformConfig:getAuthConfigs() or {}
	if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		self.skipOneKeyBind = true
	elseif not table.includes(authConfigs, PlatformAuthEnum.kPhone) then
		self.skipOneKeyBind = true
	else
		self.skipOneKeyBind = false
	end
end

local enableKey = 'real.name.enable'
function RealNameManager:isOpen()--前后端是否同时开启实名验证
	if _G.isLocalDevelopMode and not _G.testRealNameSwitch then 
		return false
	end
	local bClient = MaintenanceManager:getInstance():isEnabled("AuthenticationFeature", false)--Maintenance开关
	local bServer = UserManager:getInstance().realNameAuthSwitchStatus--服务器开关

	if bClient and bServer then 
		return true
	end
end

function RealNameManager:isHomeSceneOpen()--HomeScene的两个入口是否打开
	if not self:isOpen() then return false end
	if isWait() then return false end 

	local switch = MaintenanceManager:getInstance():getMaintenanceByKey("AuthenticationUniteHomeScene")
	local bOpen, mode = isNeedAuth(switch)
	if mode ~= self.homeSceneAuthMode then self.homeSceneAuthMode = mode end

	return bOpen
end

function RealNameManager:isPayOpen()--支付的时候是否打开
	if not self:isOpen() then return false end

	local switch = MaintenanceManager:getInstance():getMaintenanceByKey("AuthenticationUnitePayment")
	local bOpen, mode = isNeedAuth(switch)
	if mode ~= self.payAuthMode then self.payAuthMode = mode end

	return bOpen
end

function RealNameManager:isAuthMode1(authMode)--实名方式1
	if authMode == 1 then return true end
	return false
end

function RealNameManager:isAuthMode2(authMode)--实名方式2
	if authMode == 2 then return true end
	return false
end

function RealNameManager:isAuthMode3(authMode)--实名方式3
	if authMode == 3 then return true end
	return false
end

function RealNameManager:setDcData(key, value)
	if not self.dcData then 
		self.dcData = {
            category = "ui",
            sub_category = "authentication_unite_feature"
        } 
	end
	self.dcData[key] = value
end

function RealNameManager:clearDcData()
	self.dcData = nil
end

function RealNameManager:dc()
	DcUtil:UserTrack(self.dcData)
end

function RealNameManager:isAlipayInstall()
	if __IOS then return false end
	return OpenUrlUtil:canOpenUrl("alipays://") 
end

function RealNameManager:writeAuthSuccess(rewardType, bRealtime)
	if bRealtime then 
		if rewardType == RealNameRewardType.idcard  then
			UserManager:getInstance().realNameIdCardAuthed = true
			UserService:getInstance().realNameIdCardAuthed = true
		else
			UserManager:getInstance().realNameAuthed = true
			UserService:getInstance().realNameAuthed = true
		end
	else
		UserManager:getInstance().realNameStatus = 3
	end
end

function RealNameManager:__createRationalConsumptionLabel(fontSize, color)

	local realFntSize = fontSize
	-- if _G.__use_small_res then
	-- 	realFntSize = realFntSize / 0.625
	-- end

	local text = TextField:create("", nil, realFntSize, CCSizeMake(0, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
	text:setColor(color)
	text:setAnchorPoint(ccp(0.5, 0))
	text:setString(localize('authentication.feature.ui'))


	-- if _G.__use_small_res then
	-- 	text:setScale(0.625)
	-- end

	return text
end

function RealNameManager:createRationalConsumptionLabel( hadMask )
	if hadMask then
		return self:__createRationalConsumptionLabel(24, hex2ccc3('476C7B'))
	else
		return self:__createRationalConsumptionLabel(24, hex2ccc3('B8DFFF'))
	end
end

function RealNameManager:__addConsumptionLabelToPanel( panel, label, offset, handleAction)

	if offset == nil then
		offset = ccp(0, 0)
	end

	if panel and panel.isDisposed == false then
		panel.ui:addChild(label)

		local groupBounds = label:getGroupBounds()

		local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()

		local deltaY = groupBounds.origin.y - visibleOrigin.y

		local originWidth = label:getContentSize().width
		local realWidth = groupBounds.size.width

		local realScale = realWidth / originWidth

		deltaY = deltaY / realScale

		label:setPositionY(label:getPositionY() - deltaY + offset.y)



		local deltaX = groupBounds:getMidX() - visibleOrigin.x - visibleSize.width/2

		deltaX = deltaX / realScale

		label:setPositionX(label:getPositionX() - deltaX + offset.x)

		-- if _G.__use_small_res then
			-- label:setScale(1/realScale * 0.625)
		-- else
			label:setScale(1/realScale)
		-- end

		if handleAction then
			panel.__oldRunAction = panel.runAction
			panel.runAction = function ( context, action )
				panel.__oldRunAction(context, CCSequence:createWithTwoActions(action, CCCallFunc:create(function ( ... )
					if panel.isDisposed then
						return
					end
					if label.isDisposed then
						return
					end

					label:stopActionByTag(1000)

					local groupBounds = label:getGroupBounds()

					local visibleOrigin = Director.sharedDirector():getVisibleOrigin()
					local visibleSize = CCDirector:sharedDirector():getVisibleSize()

					local deltaY = groupBounds.origin.y - visibleOrigin.y

					local originWidth = label:getContentSize().width
					local realWidth = groupBounds.size.width

					local realScale = realWidth / originWidth

					deltaY = deltaY / realScale

					label:setPositionY(label:getPositionY() - deltaY + 0)



					local deltaX = groupBounds:getMidX() - visibleOrigin.x - visibleSize.width/2

					deltaX = deltaX / realScale

					label:setPositionX(label:getPositionX() - deltaX + 0)

					label:setScale(1/realScale)

					-- if _G.__use_small_res then
						-- label:setScale(1/realScale * 0.625)
					-- else
						label:setScale(1/realScale)
					-- end

				end)))

				if panel.isDisposed then
					return
				end

				local posY = panel:getPositionY()
				local labelPosY = label:getPositionY()
				local panelScale = panel:getScaleX() * panel.ui:getScaleX()

				local checkAction = CCRepeatForever:create(CCCallFunc:create(
					function ( ... )
						if panel.isDisposed then
							return
						end
						
						if label and (not label.isDisposed) then
							local pos = panel:getPosition()
							local deltaY = (pos.y - posY)/panelScale
							label:setPositionY(labelPosY - deltaY)
						end
					end
				))
				checkAction:setTag(1000)
				label:runAction(checkAction)
			end
		end


		if panel.remove then
			panel.__oldRemove = panel.remove
			panel.remove = function (context, ...)
				label:setVisible(false)
				panel.__oldRemove(context, ...)
			end
		end

	end
end

function RealNameManager:addConsumptionLabelToPanel( panel, hadMask, offset, handleAction)
	if self:isOpen() then
		self:__addConsumptionLabelToPanel(panel, self:createRationalConsumptionLabel(hadMask), offset, handleAction)
	end
end

function RealNameManager:createLabelInMarketPanel( ... )
	local hadMask = GiftPack:isEnabledNewerPackOne()
	local color = hadMask and hex2ccc3('476C7B') or hex2ccc3('FCC38B')
	return self:__createRationalConsumptionLabel(24, color)
end

function RealNameManager:__addConsumptionLabelToVerticalPage( page, label, offset)
	local width = page.width 
	local height = page.height

	local content = page:getContent()

	if not offset then
		offset = ccp(0, 0)
	end

	if content then
		content:addChild(label)
		local height = math.max(content:getHeight(), height)
		label:setPosition(ccp(width/2+offset.x, -height - 30+offset.y))

		if content.__layout then
			local oldFunc = content.__layout
			content.__layout = function ( context, ... )
				oldFunc(context, ...)
				self:rePosition(page, label)
			end

		end
	else
		label:dispose()
	end
end

function RealNameManager:addConsumptionLabelToVerticalPage(page, offset)
	if self:isOpen() then
		local label = self:createLabelInMarketPanel()
		self:__addConsumptionLabelToVerticalPage(page, label, offset)
	end
end

function RealNameManager:rePosition( page, label )

	local width = page.width 
	local height = page.height
	
	local content = page:getContent()
	if content then
		local height = math.max(content:getHeight(), height)
		label:setPosition(ccp(width/2, -height - 30))
	end
end


function RealNameManager:checkOnPay(onSuccess, onFail)
	self.triggered = false
	
	if self:isPayOpen() then
		if isWait() then 
			CommonTip:showTip(localize('authentication.feature.id.fail3'), "negative", function ()
                if onFail then onFail(self.errWaitCode) end 
            end, 1)
			return
		end
		if self:canPayPopout() then 
			local function clearPay()
				self.triggered = false
				self.isCallSDK = nil
				self.paySuccessCallback = nil
				self.payFailCallback = nil
			end
			self.paySuccessCallback = function(...) 
				if onSuccess then onSuccess(...) end
				clearPay()
			end
			self.payFailCallback = function(...)
				if onFail then 
					if #{...} == 0 then 
						onFail(self.errCode) 
					else
						onFail(...)
					end
				end
				clearPay()
			end

			self.triggered = true
			self:popoutEntryPanel(RealNameEntryType.pay)
		else
			if onSuccess then onSuccess() end
		end
	else
		if onSuccess then onSuccess() end
	end
end

function RealNameManager:setCallSDK(bCall)
	self.isCallSDK = bCall
end

function RealNameManager:setAuthing(bAuth)
	self.isAuthing = bAuth
end

function RealNameManager:getAuthing()
	return self.isAuthing
end

function RealNameManager:isTriggered( ... )
	return self.triggered
end

local localtionKey = 'real.name.ip.location'
local locationMap = {"安徽","北京","重庆","福建","甘肃","广东","广西","贵州","海南","河北","河南","黑龙江","湖北","湖南","吉林","江苏","江西","辽宁","内蒙古","宁夏","青海","山东","山西","陕西","上海","四川","天津","西藏","新疆","云南","浙江", "测试"}

function RealNameManager:getLocationInfoAsync(callback)

	if __IOS then
		return
	end

	if __ANDROID then
		require "zoo.util.WXJPPackageUtil"
		if not WXJPPackageUtil.getInstance():isWXJPPackage() then
			local decisionProcessor = require("zoo.loader.CMPaymentDecisionProcessor").new()
			if not decisionProcessor:getProvinceWithIccid() then
				self.__no_iccid = true
				return
			end
		end

		if PrepackageUtil:isPreNoNetWork() then
			return
		end
	end

    local callbackHanler = function(locationDetail)
        if type(locationDetail) == "table" then
            local province = locationDetail.province
            if type(province) == "string" and string.len(province) > 0 then
               	local provinceId = table.indexOf(locationMap, province) or 0
               	CCUserDefault:sharedUserDefault():setIntegerForKey(localtionKey, provinceId)
            	if callback then
            		callback(provinceId)
            	end
            	return
            end
        end
    	if callback then
    		callback(self:getLocationInfoCached())
    	end
    end
    LocationManager_All.getInstance():getIPLocation(callbackHanler)
end

function RealNameManager:getLocationInfoCached( ... )
	if __IOS or (__ANDROID and self.__no_iccid ) then
		local province = Cookie.getInstance():read(CookieKey.kLocationProvince) or ''
		local provinceId = table.indexOf(locationMap, province) or 0
		return provinceId, province
	else
		local provinceId = CCUserDefault:sharedUserDefault():getIntegerForKey(localtionKey, 0) or 0
		return provinceId, locationMap[provinceId] or ""
	end
end

function RealNameManager:__popoutOneKeyBindPanel( ... )
	local panel = nil
	if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		panel = require 'zoo.panel.RealName.bind.OneKeyBinding360Panel'
	else
		panel = require 'zoo.panel.RealName.bind.OneKeyBindingPanel'
	end
	panel:create(function ( ... )
		require 'zoo.panelBusLogic.PushBindingLogic'
		PushBindingLogic:checkRemovePanelAndIcon(PlatformAuthEnum.kPhone)
	end):popout()
end

--在界面切回大藤蔓 自动弹出 领奖 和 一键绑定
--虽然函数名看起来只是 弹一键绑定

function RealNameManager:autoPopoutFollowPanel( canBind )

	if self.autoed then return end
	self.autoed = true

	local curScene = Director:sharedDirector():getRunningScene()
	if curScene == HomeScene:sharedInstance() and not PopoutManager:sharedInstance():haveWindowOnScreenWithoutCommonTip() then
		if self.skipOneKeyBind then return end
		if canBind then
			self:__popoutOneKeyBindPanel()
		end
	else
		local __popout
		__popout = function( ... )
			if self.handledEvent then return end --事件是否处理过
			local curScene = Director:sharedDirector():getRunningScene()
			if curScene == HomeScene:sharedInstance() then
				if not PopoutManager:sharedInstance():haveWindowOnScreenWithoutCommonTip() then
					if self.skipOneKeyBind then return end
					if canBind then
						self:__popoutOneKeyBindPanel()
					end
					self.handledEvent = true
					GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kSceneNoPanel, __popout)
					GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterHomeScene, __popout)
				end
			end
		end
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kSceneNoPanel, __popout)
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterHomeScene, __popout)
	end
end

function RealNameManager:isAdviceBindEnabled( ... )


	if self.skipOneKeyBind then
		return false
	elseif UserManager.getInstance().profile:isPhoneBound() then
		return false
	end
	return true
end

function RealNameManager:havePhoneAuthedCanUseToBind( onSuccess, onFail )
	local Http = require 'zoo.panel.RealName.Http'
	Http:havePhoneAuthedCanUseToBind(onSuccess, onFail)
end

function RealNameManager:popoutAdviceBindPanel( phoneNum, onConfirm, onCancel)
	local AdviceBindPanel = require 'zoo.panel.RealName.bind.AdviceBindPanel'
	local panel = AdviceBindPanel:create()
	panel:setPhoneNumber(phoneNum)
	panel:ad(panel.kResult.kConfirm, onConfirm)
	panel:ad(panel.kResult.kCancel, onCancel)
	panel:popout()
end

--

function RealNameManager:bindAuthedPhoneNum( phoneNum, source, onSuccess, onFail )

	local Http = require 'zoo.panel.RealName.Http'
	Http:bindAuthedPhoneNum(phoneNum, function ( ... )

		if source ~= AccountBindingSource.PUSH_BIND_PANEL then				
			PushBindingLogic:checkRemovePanelAndIcon(PlatformAuthEnum.kPhone)
			if ((source == AccountBindingSource.FROM_LOGIN and BindPhoneBonus.hasPreloadLoginReward) or
			   source == AccountBindingSource.ACCOUNT_SETTING) and 
			   BindPhoneBonus:loginRewardEnabled() then
        		BindPhoneBonus:setShouldGetReward(true)
			end
		end

		if onSuccess then
			onSuccess(...)
		end
	end, function ( errCode, errMsg, data )
		local curScene = Director:sharedDirector():getRunningScene()

		if type(data) == 'table' and tostring(data.ret) == '221' then
			if curScene then
				curScene:runAction(CCCallFunc:create(function ( ... )
					CommonTip:showTip(localize('authentication.feature.bonding.tip'))
				end))
			end
		else
			if curScene then
				curScene:runAction(CCCallFunc:create(function ( ... )
					CommonTip:showTip(localize('authentication.feature.bonding.tip'))
				end))
			end
		end

		if onFail then onFail() end
	end)
end

function RealNameManager:decorateAlertGuest(onTouchOAuthLogin, onTouchGuestLogin)

	return function ( ... )
		local AlertPanel = require 'zoo.panel.RealName.bind.AlertPanel'
		local panel = AlertPanel:create()
		panel:ad(panel.kResult.kConfirm, onTouchOAuthLogin)
		panel:ad(panel.kResult.kCancel, onTouchGuestLogin)
		panel:popout()
	end
end

--游客登录提示  
function RealNameManager:isGuestLoginAlertEnable( ... )
	if not self:isOpen() then
		return false
	end

	local keyName = 'CustomerAccountWarning'
	return MaintenanceManager:getInstance():isEnabled(keyName)
end

function RealNameManager:popoutEntryPanel(entryType, closeCallback)
	local panel, panelType
	local authMode = (entryType == RealNameEntryType.pay and self.payAuthMode or self.homeSceneAuthMode)
	self:setDcData("scene", entryType)
	self:setDcData("method", authMode)
	if self:isAuthMode1(authMode) then
		DcUtil:UserTrack({category = "ui", sub_category = "alipay_install", install = (self:isAlipayInstall() and 0 or -1)})
		panelType = self:isAlipayInstall() and RealNamePanelType.idcard1 or RealNamePanelType.idcard2
	elseif self:isAuthMode2(authMode) then
		DcUtil:UserTrack({category = "ui", sub_category = "alipay_install", install = (self:isAlipayInstall() and 0 or -1)})
		panelType = self:isAlipayInstall() and RealNamePanelType.idcard3 or RealNamePanelType.idcard4
	elseif self:isAuthMode3(authMode) then
		panelType = PlatformConfig:isPlatform(PlatformNameEnum.k360) and RealNamePanelType.phone360 or RealNamePanelType.phone1
	end

	if panelType then
		panel = RealNamePanel:create(panelType, closeCallback)
		panel:popout()
	end
end

function RealNameManager:onEnterHomeScene( ... )
	if self:isHomeSceneOpen() then
		local function callback()
	        local homeScene = HomeScene:sharedInstance()
	        if not homeScene.realNameIcon then

                local bHaveSVIPActivity = SVIPGetPhoneManager:getInstance():CurIsHaveIcon()
                -- 不弹实名认证手机部分
                if not bHaveSVIPActivity then
	        	    local RealNameButton = require 'zoo.panel.RealName.RealNameButton'
				    local icon = RealNameButton:create(true)
	        	    homeScene:addIcon(icon)
		            homeScene.realNameIcon = icon
                end
	        end
	    end
	    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
	end
end

function RealNameManager:onAuthSuccess( ... )
	local homeScene = HomeScene:sharedInstance()
    if homeScene.realNameIcon and not homeScene.realNameIcon.isDisposed then
    	homeScene:removeIcon(homeScene.realNameIcon, true)
    end
    homeScene.realNameIcon = nil
end

--获得异步奖励状态
function RealNameManager:getRealNameStatus()
	local realNameStatus = UserManager:getInstance().realNameStatus or 0
	local realNameFlag = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kRealNameAuthPopout)
	return realNameStatus, realNameFlag
end

--获得实名认证奖励
function RealNameManager:getRealNameReward(realNameStatus, bRealtime, rewardType, callback)
	local function dc(verify)
		RealNameManager:setDcData("verify", verify)
	    RealNameManager:dc()
	end
	if realNameStatus == 1 then
		local function successCallback()
			dc(0)
			RealNameManager:clearDcData()
			UserLocalLogic:setBAFlag(kBAFlagsIdx.kRealNameAuthPopout)
			if self.paySuccessCallback then self.paySuccessCallback() end
		end

		local panelType = (bRealtime and RealNamePanelType.onlineSuccess or RealNamePanelType.offlineSuccess)
		local panel = RealNamePanel:create(panelType, successCallback)
		local rewardId, rewardConfig = self:parseRawRewardConfig(rewardType)
		panel:setRewards(rewardId, rewardConfig)
		panel:popout()

		self:writeAuthSuccess(rewardType, bRealtime)
        self:onAuthSuccess()
	elseif realNameStatus == 2 then 
		local function failCallback()
			dc(-1)
			if callback then callback() end
			UserLocalLogic:setBAFlag(kBAFlagsIdx.kRealNameAuthPopout)
			if self.payFailCallback then self.payFailCallback() end
		end

		local panelType = (bRealtime and RealNamePanelType.onlineFail or RealNamePanelType.offlineFail)
		local panel = RealNamePanel:create(panelType, failCallback)
		panel:popout()
	end
end

function RealNameManager:parseRawRewardConfig(rewardType)
	local realNameRewards = UserManager:getInstance().global.realNameIdCardRewards
	if RealNameRewardType.phone == rewardType then 
		realNameRewards = UserManager:getInstance().global.realNameRewards
	end

	if realNameRewards == "" or realNameRewards == nil then
		return nil, {}
	end

	local rewardId = realNameRewards:match('(%d+)|')
	rewardId = tonumber(rewardId)

	local rewardsConfig = realNameRewards:match('|(.+)')
	local rewards = {}
	for itemId, num in rewardsConfig:gmatch('(%d+):(%d+)') do
		table.insert(rewards, {itemId = tonumber(itemId), num = tonumber(num)})
	end

	if #rewards > 0 and type(rewardId) == 'number' then
		return rewardId, rewards
	end

	return nil, {}
end

local function getDayStartTimeByTS(ts)
	if ts ~= nil then
		local utc8TimeOffset = 57600
		local dayInSec = 86400
		ts = ts - ((ts - utc8TimeOffset) % dayInSec)
		ts = ts * 1000
		return ts
	end

	return 0
end

local function getHomeScenePopoutCounterKey()--homescene弹出计数
	return 'real.name.home.popout.counter.' .. UserManager:getInstance():getUID()
end

local function getHomeScenePopoutDateKey()--最后弹出时间
	return 'real.name.home.popout.day.' .. UserManager:getInstance():getUID()
end

local function getPayPopoutCounterKey()--pay弹出计数
	return 'real.name.pay.popout.counter.' .. UserManager:getInstance():getUID()
end

local function getPayPopoutDateKey()--最后弹出时间
	return 'real.name.pay.popout.day.' .. UserManager:getInstance():getUID()
end

local function getLocalSwitchKey()--账号绑定与实名制强弹交替出现，每天更换一次出现的内容
	return 'real.name.local.switch.'..UserManager:getInstance():getUID()
end

local function getLocalSwitchDateKey()
	return 'real.name.local.switch.date.'..UserManager:getInstance():getUID()
end

function RealNameManager:incHomeScenePopoutCounter( ... )
	local key = getHomeScenePopoutCounterKey()
	local counter = self:getHomeScenePopoutCounter()
	CCUserDefault:sharedUserDefault():setIntegerForKey(key, counter + 1)
end

function RealNameManager:getHomeScenePopoutCounter( ... )
	local key = getHomeScenePopoutCounterKey()
	local counter = CCUserDefault:sharedUserDefault():getIntegerForKey(key, 0) or 0
	return counter
end

--刷新强弹日期
function RealNameManager:refreshHomeScenePopoutDate( ... )
	local now = Localhost:timeInSec()
	local today = getDayStartTimeByTS(now)
	
	CCUserDefault:sharedUserDefault():setStringForKey(getHomeScenePopoutDateKey(), tostring(today))
end

--今天强弹过吗
function RealNameManager:canHomeSceneForcePopout( ... )
	local now = Localhost:timeInSec()
	local today = getDayStartTimeByTS(now)
	
	local isTodayPop = (tonumber(CCUserDefault:sharedUserDefault():getStringForKey(getHomeScenePopoutDateKey(), '0')) or 0) < tonumber(tostring(today))
	return isTodayPop and self:isCounterEnough()
end

function RealNameManager:isCounterEnough()
	local switch = MaintenanceManager:getInstance():getMaintenanceByKey("AuthenticationUniteHomeScene")
	local counter = (switch and tonumber(switch.value) or 0)
	return self:getHomeScenePopoutCounter() < counter and true or false
end

function RealNameManager:canPayPopout( ... )
	local now = Localhost:timeInSec()
	local today = getDayStartTimeByTS(now)

	local isNewDay = (tonumber(CCUserDefault:sharedUserDefault():getStringForKey(getPayPopoutDateKey(), '0')) or 0) < tonumber(tostring(today))
	if isNewDay then
		CCUserDefault:sharedUserDefault():setStringForKey(getPayPopoutDateKey(), tostring(today))
		CCUserDefault:sharedUserDefault():setIntegerForKey(getPayPopoutCounterKey(), 0)
	end

	local switch = MaintenanceManager:getInstance():getMaintenanceByKey("AuthenticationUnitePayment")
	local settingCounter = (switch and tonumber(switch.value) or 0)
	local cacheCounter = CCUserDefault:sharedUserDefault():getIntegerForKey(getPayPopoutCounterKey(), 0) or 0
	local isCounterPop = (cacheCounter < settingCounter)
	if isCounterPop then CCUserDefault:sharedUserDefault():setIntegerForKey(getPayPopoutCounterKey(), cacheCounter + 1) end
	return isCounterPop
end

function RealNameManager:getLocalSwitchDate()
	return CCUserDefault:sharedUserDefault():getStringForKey(getLocalSwitchDateKey(), '0')
end

function RealNameManager:setLocalSwitchDate()
	local now = Localhost:timeInSec()
	local today = getDayStartTimeByTS(now)
	
	CCUserDefault:sharedUserDefault():setStringForKey(getLocalSwitchDateKey(), tostring(today))
end

function RealNameManager:getLocalSwitch()--true可以强弹实名制
	return CCUserDefault:sharedUserDefault():getBoolForKey(getLocalSwitchKey(), true)
end

function RealNameManager:setLocalSwitch(value)--账号绑定和实名制强弹控制
	if not value then 
		local now = Localhost:timeInSec()
		local today = getDayStartTimeByTS(now)
		local switchDate = (tonumber(self:getLocalSwitchDate()) or 0)
		local bSwitch = self:getLocalSwitch()
		if switchDate < tonumber(tostring(today)) then 
			bSwitch = (not bSwitch)
			CCUserDefault:sharedUserDefault():setBoolForKey(getLocalSwitchKey(), bSwitch)
			self:setLocalSwitchDate()
		end
		return bSwitch
	else
		CCUserDefault:sharedUserDefault():setBoolForKey(getLocalSwitchKey(), true)
		self:setLocalSwitchDate()
		return true
	end
end

