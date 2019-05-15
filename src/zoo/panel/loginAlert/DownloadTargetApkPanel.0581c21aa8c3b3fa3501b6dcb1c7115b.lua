local DownloadTargetApkPanel = class(BasePanel)
local model = LoginAlertModel:getInstance()
local WifiAlertCls = require 'zoo.panel.WifiAlert'
local YES_BTN_LOGIC = {NONE = 0, YES = 1, INSTALL_OVERLOAD = 2}
local NO_BTN_LOGIC = {NONE = 0, NO = 1}
local SimpleBarCls = require 'zoo.ui.SimpleBar'

function DownloadTargetApkPanel:create(dataSize)
	local panel = DownloadTargetApkPanel.new()
	panel:loadRequiredResource("ui/LoginAlertPanel.json")
	dataSize = dataSize or 0
	panel:init(dataSize)
	return panel
end

function DownloadTargetApkPanel:init(dataSize)
	self.dataSize = dataSize
	self.ui = self:buildInterfaceGroup("LoginAlertPanel/DownloadTargetApkPanel")
	BasePanel.init(self, self.ui)

	local contentX, contentY, scale = LogicUtil.getFullScreenUIPosXYScale()
	self:setScale(scale)
	self:setPositionXY(contentX, 0)

    self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function()
        	if not self.closeBtn.clked then
        		self.closeBtn.clked = true
            	self:onCloseBtnTapped()
        	end
        end) 
    self:disableCloseBtn()


	self.inDownloadSucess = false
	self.inDownloadError = false
	self.inDownloadProcess = false
	self.tryCount = 3
	self.barRes = self.ui:getChildByName("bar")
	local bar = self.barRes:getChildByName("bar")
	local barUI = bar:getChildByName("barUI")
	local barMask = bar:getChildByName("barMask")
	local barAnchor = bar:getChildByName("barAnchor")
	barAnchor:setPositionY(barAnchor:getPositionY() - 5)
	self.barAnchor = barAnchor
	self.stepBar = SimpleBarCls:create(barUI, barMask, barAnchor, 1)
	self.stepBar.barClippingNode:setPositionXY(2, -2)


	local fntFile = "fnt/login_alert_bar_num.fnt"
	self.loadStepTf = BitmapText:create('', fntFile)
	self.loadStepTf:setAnchorPoint(ccp(0.5, 0.5))
	self.loadStepTf:setPreferredSize(170, 30)
	self.loadStepTf:setPositionXY(319, -640)
	self.ui:addChild(self.loadStepTf)

    local uid = model.adviceLoginInfo.uid
	local headC = self.ui:getChildByName("rightHeadImg"):getChildByName("bg")
	self.ui:getChildByPath('rightHeadImg/top'):setVisible(false)
	
	local headUrl = model.adviceLoginInfo.headUrl 
	LogicUtil.loadUserHeadIcon(uid, headC, headUrl)
	self.tipRawPosX, self.tipRawPosY = self.ui:getChildByName("wifiTip"):getPositionX(), self.ui:getChildByName("wifiTip"):getPositionY() - 10
	self.downDoladPosY = self.tipRawPosY - 20

	self.yesBtn = GroupButtonBase:create(self.ui:getChildByName('yesBtn'))
    self.yesBtn:setString(localize("xibao_button_7"))--"去")--
    -- self.yesBtn.groupNode:getChildByName("label"):setAnchorPoint(ccp(0.5, 0.5))
    -- self.yesBtn.groupNode:getChildByName("label"):setPositionXY(2, -3)
	self.yesBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkYesBtn()
	end)
	self.noBtn = GroupButtonBase:create(self.ui:getChildByName('noBtn'))
    self.noBtn:setString(localize("xibao_button_6"))--"去")--
 --    self.noBtn.groupNode:getChildByName("label"):setAnchorPoint(ccp(0.5, 0.5))
	-- self.noBtn.groupNode:getChildByName("label"):setPositionXY(2, -3)
	self.noBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkNoBtn()
	end)
    self.noBtn:setColorMode(kGroupButtonColorMode.blue)

	if WifiAlertCls:isWifi() then
		 model:log(4)
		 self.noBtnLogic = NO_BTN_LOGIC.NONE
		 self.yesBtnLogic = YES_BTN_LOGIC.NONE
		 self.noBtn:setVisible(false)
		 self.yesBtn:setVisible(false)
		 self:showDownloadBarAnchor()
    	 self:startDownLoadAdviceAPK()
    else
    	 local fSize = math.floor(self.dataSize / 1024 / 1024)
    	 if fSize < 1 then fSize = 80 end
		 self.ui:getChildByName("wifiTip"):setString(localize("xibao_tipss6", {size = fSize}))
		 self.ui:getChildByName("wifiTip"):setPositionXY(self.tipRawPosX, self.tipRawPosY - 5)
		 self.yesBtnLogic = YES_BTN_LOGIC.YES
    	 self.noBtnLogic = NO_BTN_LOGIC.NO
		 self.barRes:setVisible(false)
		 self:hideDownloadBarAnchor()
    end

	-- self.ui:getChildByName("wifiTip"):setString(localize("xibao_tipss7"))
	-- self.ui:getChildByName("wifiTip"):setPositionXY(self.tipRawPosX, self.downDoladPosY)
 --    self:onDownloadProcess(100, 300)
	-- local teRate = 0
	-- self.barRes:runAction(AnimationUtil.getForeverCall(0.05, function( ... )
	-- 	teRate = teRate + 0.01
	-- 	if teRate <= 1 then 
	-- 		local curRate = math.floor(teRate * 100)
	-- 		self.loadStepTf:setString(curRate .. "%")
	-- 		self.stepBar:setRate(teRate)
	--     end
	-- end))



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
	username:setString(tostring(username_txt))


	self.ui:getChildByName('top_label'):setString('系统检测到您有以下常用账号')

end

function DownloadTargetApkPanel:hideDownloadBarAnchor()
	self.barRes:stopAllActions()
	self.barAnchor:setVisible(false)
	self.loadStepTf:setVisible(false)
end

function DownloadTargetApkPanel:showDownloadBarAnchor( ... )
	self.barAnchor:setVisible(true)
	self.barRes:setVisible(true)
	local actionNum = self.barRes:numberOfRunningActions()
	if actionNum ~= nil and actionNum < 1 then
		for i = 1, 7 do
			local star = self.barAnchor:getChildByName("star" .. i)
			local fRotate = AnimationUtil.getForeverRatate()
			star:runAction(fRotate)
		end
		
		self.starPool = {}
		for i = 1, 10 do
			self.starPool[i] = Sprite:createWithSpriteFrameName("LoginAlertPanel/bar_star__0000")
		end
		local function createAFlyStar()
			self:createAFlyStar()
		end
		self.barRes:runAction(AnimationUtil.getForeverCall(0.2, createAFlyStar))
	end
end

function DownloadTargetApkPanel:createAFlyStar()
	if self.ui == nil or self.ui.isDisposed then return end
	if self.barAnchor == nil or self.barAnchor.isDisposed then return end
	local starIcon = self:getAStar()
	if starIcon == nil then return end

	local flyX = math.random(-200, -100)
	local flyTime = -flyX / 175
	starIcon:setAnchorPoint(ccp(0.5, 0.5))
	local function disposeIcon()
		if self.ui == nil or self.ui.isDisposed then return end
		if self.barAnchor == nil or self.barAnchor.isDisposed then return end

		if self.starPool == nil then
			starIcon:removeFromParentAndCleanup(true)
		else
			starIcon:removeFromParentAndCleanup(false)
			self.starPool[#self.starPool + 1] = starIcon
		end
	end
	local starPosX, starPosY, theAction = AnimationUtil.getRectFlyBackParam(0, -5, 25, 40, flyX, 0, flyTime, true, disposeIcon)
	starIcon:setPositionXY(starPosX, starPosY)
	self.barAnchor:addChild(starIcon)
	starIcon:runAction(theAction)
end

function DownloadTargetApkPanel:getAStar()
	local rStar
	if #self.starPool > 0 then 
		rStar = self.starPool[#self.starPool]
		self.starPool[#self.starPool] = nil
	end

	return rStar
end

function DownloadTargetApkPanel:onClkYesBtn()
	if self.yesBtnLogic == YES_BTN_LOGIC.NONE then return 

	elseif self.yesBtnLogic == YES_BTN_LOGIC.YES then
		--先检查有没有网
    	local WifiAlertCls = require 'zoo.panel.WifiAlert'
		if WifiAlertCls:isNetworkOff() then
			CommonTip:showTip(localize("dis.connect.warning.tips"))
			self.yesBtnLogic = YES_BTN_LOGIC.YES
			return
		else
			model:log(5)
			self.yesBtnLogic = YES_BTN_LOGIC.NONE
			self.noBtnLogic = NO_BTN_LOGIC.NONE
		 	self:startDownLoadAdviceAPK()
		 	self.yesBtn:setVisible(false)
		 	self.noBtn:setVisible(false)
		end
	elseif self.yesBtnLogic == YES_BTN_LOGIC.INSTALL_OVERLOAD then
		self:installNewAPK()
		setTimeOut(function()
			self.yesBtnLogic = YES_BTN_LOGIC.INSTALL_OVERLOAD
		end, 1)
		self.yesBtnLogic = YES_BTN_LOGIC.NONE
	end

end

function DownloadTargetApkPanel:onClkNoBtn()
	if self.noBtnLogic == NO_BTN_LOGIC.NONE then return end
	self:onCloseBtnTapped()
	self.noBtnLogic = NO_BTN_LOGIC.NONE
	self.yesBtnLogic = YES_BTN_LOGIC.NONE
end

function DownloadTargetApkPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenter()
end

function DownloadTargetApkPanel:onCloseBtnTapped()
	if self.isClosed then return end

	self.isClosed = true
	PopoutManager:sharedInstance():remove(self, true)
	model:popoutAlertPanel()
end

function DownloadTargetApkPanel:removePanelAndLogin()
	model:closeAlertPanel()
	if self.isClosed then return end

	self.isClosed = true
	PopoutManager:sharedInstance():remove(self, true)
end

function DownloadTargetApkPanel:disableCloseBtn()
	self.allowBackKeyTap = false
	if self.closeBtn == nil or self.closeBtn.isDisposed then return end

	if self.closeBtn:getParent() ~= nil then
		self.closeBtn:removeFromParentAndCleanup(false)
		self.allowBackKeyTap = false
	end
end

function DownloadTargetApkPanel:enableCloseBtn()
	self.allowBackKeyTap = true
	if self.closeBtn == nil or self.closeBtn.isDisposed then return end

	if self.closeBtn:getParent() == nil then
		self.ui:addChild(self.closeBtn)
		self.allowBackKeyTap = true
	end
end

function DownloadTargetApkPanel:startDownLoadAdviceAPK()--开始下载APK
	if not __ANDROID then return end

	require "hecore.luaJavaConvert"
	local function sucessCallBack()
		self.loadStepTf:setString("100%")
		self:onDownloadSucess()
	end
	local function errorCallBack()
		self:onDownloadError()
	end
	local function processCallBack(progress,total)
		self:onDownloadProcess(progress,total)
	end
	local downLoadCallfunc = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback", {
			onSuccess = sucessCallBack,
			onError = errorCallBack,
			onProcess = processCallBack	
		})
	self.inDownloadProcess = true
	self:showDownloadBarAnchor()
	self.stepBar:setRate(0)
	self.ui:getChildByName("wifiTip"):setString(localize("xibao_tipss7"))
	self.ui:getChildByName("wifiTip"):setPositionXY(self.tipRawPosX, self.downDoladPosY)
	local HttpUtil = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
	HttpUtil:downloadApk(model.adviceLoginInfo.apkDownloadUrl, model:getAdviceApkPath(), downLoadCallfunc)


end

function DownloadTargetApkPanel:onDownloadProcess(progress,total)
	if self.ui == nil or self.ui.isDisposed then return end

	if progress < total then
		self.loadStepTf:setString(math.floor(progress / total * 100) .. "%")
	else
		self.loadStepTf:setString("100%")
	end
	self.stepBar:setRate(progress / total)
	self.loadStepTf:setVisible(true)
end

function DownloadTargetApkPanel:onDownloadSucess()
	if self.ui == nil or self.ui.isDisposed then return end

	model:log(7)
	self.ui:getChildByName("wifiTip"):setString(localize("xibao_tipss8"))
	self.ui:getChildByName("wifiTip"):setPositionXY(self.tipRawPosX, self.downDoladPosY)
	self.barRes:setVisible(true)
	self.barAnchor:removeFromParentAndCleanup(true)

	if model:getAlertType() == LoginAlertModel.ALERT_TYPE.NEED_OVERLOAD_INSTALL then
		if self.ui == nil or self.ui.isDisposed then 
			self:installNewAPK()
			return 
		end
		self.barRes:setVisible(false)
		self.loadStepTf:setVisible(false)
	 	self.yesBtn:setVisible(true)
	 	self.yesBtnLogic = YES_BTN_LOGIC.INSTALL_OVERLOAD
    	self.yesBtn:setString(localize("xibao_button_9"))--"安装")--
		self.yesBtn.groupNode:setPositionX(self.yesBtn.groupNode:getPositionX() - 110)
		self.ui:getChildByName("wifiTip"):setString(localize("xibao_tipss11"))
		self.ui:getChildByName("wifiTip"):setPositionXY(self.tipRawPosX, self.downDoladPosY)
		self:installNewAPK()
	else
		self:removePanelAndLogin()
		setTimeOut(function()
			self:installNewAPK()
		end, 0.5)
	end
end

function DownloadTargetApkPanel:installNewAPK()
	model:writeLoginInfo(2)
	local PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
    local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
    PackageUtils:installApk(MainActivityHolder.ACTIVITY:getContext(), model:getAdviceApkPath())
end

function DownloadTargetApkPanel:onDownloadError()
	if self.ui == nil or self.ui.isDisposed then return end
	
	self.tryCount = self.tryCount - 1
	if code ~= 1000 then
		if self.tryCount > 0 then
			self:startDownLoadAdviceAPK()
		else
			self:enableCloseBtn()
			CommonTip:showTip(localize("xibao_tipss10"), "negative")
			self.ui:getChildByName("wifiTip"):setString(localize("xibao_tipss10"))
			self.ui:getChildByName("wifiTip"):setPositionXY(self.tipRawPosX, self.downDoladPosY)
			self.barAnchor:setVisible(false)
		end
	else
		self:enableCloseBtn()
		self.barAnchor:setVisible(false)
		CommonTip:showTip("当前更新链接出错，请通过应用商店下载最新版本游戏哦~", "negative")
		he_log_error("download xibao apk error advicePKG:" .. model.adviceLoginInfo.packageName .. "    curPKG:" .. _G.packageName)
		self.inDownloadError = true
	end
end

function DownloadTargetApkPanel:dispose()
	if self.starPool ~= nil and #self.starPool > 0 then
		for i = 1, #self.starPool do
			local star = self.starPool[i]
			if star ~= nil and not star.isDisposed then
				star:dispose()
			end
		end
	end
	self.starPool = nil

	if self.closeBtn:getParent() == nil then
		self.closeBtn:cleanup(true)
		self.closeBtn = nil
	end
	BasePanel.dispose(self)
end

return DownloadTargetApkPanel