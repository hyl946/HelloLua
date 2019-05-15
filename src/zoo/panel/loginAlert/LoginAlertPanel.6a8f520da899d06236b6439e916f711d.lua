local LoginAlertPanel = class(BasePanel)
local model = LoginAlertModel:getInstance()

local LOGIN_BTN_LOGIC = {NONE = 0, LOGIN_IN = 1}
local ADVICE_LOGIN_BTN_LOGIC = {NONE = 0, ASK_HELP = 1, LOGIN_IN = 2, DOWN_LOAD = 3, INSTALL = 4}

function LoginAlertPanel:create()
	local panel = LoginAlertPanel.new()
	panel:loadRequiredResource("ui/LoginAlertPanel.json")
	panel:init()
	return panel
end

function LoginAlertPanel:init()
	self.ui = self:buildInterfaceGroup("LoginAlertPanel/LoginAlertPanel")
	BasePanel.init(self, self.ui)

	local contentX, contentY, scale = LogicUtil.getFullScreenUIPosXYScale()
	self:setScale(scale)
	self:setPositionXY(contentX, 0)

	self.ui:getChildByName("closeBtn"):removeFromParentAndCleanup(true)
    self.loginBtn = self.ui:getChildByName('loginBtn')
    self.loginBtn:setTouchEnabled(true, 0, true)
	self.loginBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkLoginBtn()
	end)
	self.loginBtnLogic = LOGIN_BTN_LOGIC.LOGIN_IN

	self.toAdviceLoginBtn = GroupButtonBase:create(self.ui:getChildByName('toAdviceLoginBtn'))
	self.toAdviceLoginBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkToAdviceLoginBtn()
	end)

	local curDescStr = localize("xibao_cur_login_desc", {name=localize("xibao_login" .. model.currentLoginInfo.loginType)})
	self.ui:getChildByName("curLoginDesc"):setString(curDescStr)


	local function setNum( nodeName, num )
		local numUI = self.ui:getChildByName(nodeName)
		numUI:changeFntFile('fnt/level_seq_n_energy_cd.fnt')
		numUI:setText(num)
		numUI:setAnchorPoint(ccp(1, 0.5))
		numUI:setPositionX(410)
		numUI:setPositionY(numUI:getPositionY() - 46.25/2)
		numUI:setScale(1.8)

		if #tostring(num) > 5 then
			numUI:setScale(numUI:getScaleX() * 5 / (#tostring(num)) )
		end 
	end

	setNum('gold', tostring(model.adviceLoginInfo.cash) )
	setNum('level', tostring(model.adviceLoginInfo.topLevelId))

	local username_txt = '消消乐玩家'

	if model.adviceLoginInfo.profile and model.adviceLoginInfo.profile.name then
		username_txt = nameDecode(model.adviceLoginInfo.profile.name) or username_txt
	end

	local username = self.ui:getChildByName('username')

	username_txt = TextUtil:ensureTextWidth( username_txt, username:getFontSize(), username:getDimensions() )
	
	username:setString(tostring(username_txt))


	self.ui:getChildByName('top_label'):setString('系统检测到您有以下常用账号')

	local uid = model.adviceLoginInfo.uid
	local headC = self.ui:getChildByName("rightHeadImg"):getChildByName("bg")
	self.ui:getChildByPath('rightHeadImg/top'):setVisible(false)
	
	local headUrl = model.adviceLoginInfo.headUrl 
	LogicUtil.loadUserHeadIcon(uid, headC, headUrl)
	self:refresh()
end

function LoginAlertPanel:refresh()
	self:refreshToAdviceLoginBtn()
end

function LoginAlertPanel:refreshToAdviceLoginBtn()
	self.alertType = model:getAlertType()
	self.ui:getChildByName("rightDesc"):setString("")
	self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.NONE
	--不同PKG并且通过URL链接下载不到的情况
	if self.alertType == LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_UNAVAILABLE or 
	   self.alertType == LoginAlertModel.ALERT_TYPE.SAME_SERVER_DIFFERENT_PKG_UNAVAILABLE or 
	   self.alertType == LoginAlertModel.ALERT_TYPE.AUTH_REMOVED_WITHOUT_OTHER_SNS then
	   if model.adviceLoginInfo.packageName ~= _G.packageName and model:adviceAppInstalled() then --已经安装不能下载的推荐包
	   		self.toAdviceLoginBtn:setString(localize("xibao_button_3"))--"去登录吧")--
	   		self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.LOGIN_IN
			self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss4"))
	   else
	   		self.toAdviceLoginBtn:setString(localize("xibao_button_5"))--"联系客服")--
	   		self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.ASK_HELP
	   		self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss5"))
	   end

	--不同PKG，通过URL链接可下载
	elseif self.alertType == LoginAlertModel.ALERT_TYPE.DIFFERENT_SERVER_PKG_AVAILABLE or
		   self.alertType == LoginAlertModel.ALERT_TYPE.SAME_SERVER_DIFFERENT_PKG_AVAILABLE then
		   if model:adviceAppInstalled() then
	   			self.toAdviceLoginBtn:setString(localize("xibao_button_3"))--"去登录吧")--
	   			self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.LOGIN_IN
				self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss4"))
		   elseif not model:adviceApkExist() then--看看apk是否下载完成
	   			self.toAdviceLoginBtn:setString(localize("xibao_button_2"))--"去下载吧")--
	   			self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.DOWN_LOAD
				self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss2"))
		   else
	   			self.toAdviceLoginBtn:setString(localize("xibao_button_9"))--"去安装吧")--
	   			self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.INSTALL
				self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss9"))
		   end

	--当前PKG可切换登录
	elseif self.alertType == LoginAlertModel.ALERT_TYPE.NEED_OVERLOAD_INSTALL then
			if not model:adviceApkExist() then
				self.toAdviceLoginBtn:setString(localize("xibao_button_2"))--"去下载吧")--
	   			self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.DOWN_LOAD
				self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss2"))
			else
				self.toAdviceLoginBtn:setString(localize("xibao_button_9"))--"去安装吧")--
	   			self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.INSTALL
				self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss9"))
			end
			
	else
	   	self.toAdviceLoginBtn:setString(localize("xibao_button_4"))--"切切换号")--
	   	self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.LOGIN_IN
		self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss3"))
	end


    self.toAdviceLoginBtn.groupNode:getChildByName("label"):setAnchorPoint(ccp(0.5, 0.5))
    self.toAdviceLoginBtn.groupNode:getChildByName("label"):setPositionXY(2, -8)
end

function LoginAlertPanel:onClkLoginBtn()
	model:log(1)
	if self.loginBtnLogic == LOGIN_BTN_LOGIC.LOGIN_IN then

		require('zoo.panel.loginAlert.ConfirmPanel'):create(function ( ... )
			-- body
			if self.isDisposed then
				return
			end

    		self:onCloseBtnTapped()

		end, function ( ... )
			-- body
			self.loginBtnLogic = LOGIN_BTN_LOGIC.LOGIN_IN
			
		end):popout()

    end
    
    self.loginBtnLogic = LOGIN_BTN_LOGIC.NONE
end

function LoginAlertPanel:onClkToAdviceLoginBtn()
	if self.toAdviceLoginBtnLogic == ADVICE_LOGIN_BTN_LOGIC.NONE then 
		return 
	elseif self.toAdviceLoginBtnLogic == ADVICE_LOGIN_BTN_LOGIC.LOGIN_IN then
		model:log(2)
		self:clkToLoginAdvice()
    elseif self.toAdviceLoginBtnLogic == ADVICE_LOGIN_BTN_LOGIC.DOWN_LOAD then
    	self:checkDownload()
    elseif self.toAdviceLoginBtnLogic == ADVICE_LOGIN_BTN_LOGIC.INSTALL then
    	self:checkInstall()
    elseif self.toAdviceLoginBtnLogic == ADVICE_LOGIN_BTN_LOGIC.ASK_HELP then
		model:log(6)
    	self:clkToFC()
	end

	self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.NONE
end

function LoginAlertPanel:checkInstall()
	if not model:adviceApkExist() then
		self:checkDownload()
    else
    	model:log(8)
    	if self.alertType ~= LoginAlertModel.ALERT_TYPE.NEED_OVERLOAD_INSTALL then
			model:writeLoginInfo(2)
    		self:onCloseBtnTapped()
    	end
    	setTimeOut(function( ... )
    		if self.alertType == LoginAlertModel.ALERT_TYPE.NEED_OVERLOAD_INSTALL then
    			self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.INSTALL
    		end
    		self:installAdviceApp()
    	end, 0.05)
    end
end

function LoginAlertPanel:checkDownload()
	if model:canDownloadAPK() then
		model:log(3)
    	self:downLoadAdviceAPK()
    else
    	self.inOpenUrl = true
    	setTimeOut(function()
    		self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.DOWN_LOAD
    	end, 0.01)
    	OpenUrlUtil:openUrl(model.adviceLoginInfo.platformShopUrl)
    end
end

function LoginAlertPanel:onEnterForeGround()
	if self.ui == nil or self.ui.isDisposed then return end
	if self.inOpenUrl then
		local function onSucess(installFlag)
			if self.ui == nil or self.ui.isDisposed then return end

		 	model.isAdviceAppInstalled = installFlag
		 	if model:adviceAppInstalled() and model:isSupportAdviceLoginTypes() then
		 		setTimeOut(function( ... )
					if self.ui == nil or self.ui.isDisposed then return end
					
		 			self.toAdviceLoginBtn:setString(localize("xibao_button_3"))--"去登录吧")--
	   				self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.LOGIN_IN
					self.ui:getChildByName("rightDesc"):setString(localize("xibao_tipss4"))
		 		end, 0.1)
		   	end
		end
		local function onError(errCode)
		end
		PackageUtil.isPackageInstalled(model.adviceLoginInfo.packageName, onSucess, onError)
	end
end

--[[
	SAME_SERVER_SAME_PKG_SAME_BIND_TYPE = 3,--相同服务器，相同PKG，相同账户绑定
	SAME_SERVER_SAME_PKG_DIFFERENT_BIND_TYPE = 4,--相同服务器，相同PKG，不同账户绑定
]]
function LoginAlertPanel:clkToLoginAdvice()
	if self.alertType == LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_SAME_BIND_TYPE then
		--到账号登录页面
		model:writeLoginInfo(2)
		self:removePanel()
		model:toAccountBindLogin()
	elseif self.alertType == LoginAlertModel.ALERT_TYPE.SAME_SERVER_SAME_PKG_DIFFERENT_BIND_TYPE then
		--重新到登录页面
		model:writeLoginInfo(2)
		self:removePanel()
		model:backToLogin()
	else
		self:onCloseBtnTapped()
		model:writeLoginInfo(2)
		setTimeOut(function( ... )
    		PackageUtil.openAppByPackage(model.adviceLoginInfo.packageName)
		end, 0.05)
	end
end

function LoginAlertPanel:clkToFC()
    if PrepackageUtil:isPreNoNetWork() then
        PrepackageUtil:showSettingNetWorkDialog()
        self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.ASK_HELP
    else
    	require "zoo.common.FAQ"
	    FAQ:openFAQClientIfLogin(nil, FAQTabTags.kSheQu)
		setTimeOut(function() self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.ASK_HELP end, 2)
		return
    end
end

function LoginAlertPanel:installAdviceApp()
	if not __ANDROID then return end

	model:writeLoginInfo(2)
	local PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
    local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
    PackageUtils:installApk(MainActivityHolder.ACTIVITY:getContext(), model:getAdviceApkPath())
end

function LoginAlertPanel:downLoadAdviceAPK()
	local WifiAlertCls = require 'zoo.panel.WifiAlert'
	if WifiAlertCls:isNetworkOff() then
		CommonTip:showTip(localize("dis.connect.warning.tips"))
		setTimeOut(function() self.toAdviceLoginBtnLogic = ADVICE_LOGIN_BTN_LOGIC.DOWN_LOAD end, 0.1)

    -- elseif UpdatePackageManager:enabled() then
    --     UpdatePackageManager:getInstance():startDownload()
        
	else
		local apkUrl = model.adviceLoginInfo.apkDownloadUrl
		local sizeUrl = apkUrl:gsub("%.apk","%.size")
		UpdatePageagePanel.requestApkSize(self, sizeUrl, function(dataSize)
			self:removePanel()
			local DownLoadPanelCls = require "zoo.panel.loginAlert.DownloadTargetApkPanel"
			DownLoadPanelCls:create(dataSize):popout()
		end)
	end
end

local function CmgameExit()
    if __ANDROID and
        PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
        not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame)
        and _G.needCallCmgameExit
    then
        local function exit()
            local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
            cmgamePayment:exitGame()
        end
        pcall(exit)
    end
end

function LoginAlertPanel:exitCurGame()
	CmgameExit()
	CCDirector:sharedDirector():endToLua()
end

function LoginAlertPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenter()
	model:log(0)
	-- CommonTipWithBtn:showTip({tip = self.alertType .. " " .. model.adviceLoginInfo.packageName .. " " .. tostring(model.isAdviceAppInstalled), yes = "好"}, "negative", nil, nil, nil, true)
end

function LoginAlertPanel:onCloseBtnTapped()
	self:removePanel()
	model:closeAlertPanel()
end

function LoginAlertPanel:removePanel()
	PopoutManager:sharedInstance():remove(self, true)
end

return LoginAlertPanel