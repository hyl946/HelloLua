require 'zoo.panel.basePanel.BasePanel'
require "zoo.util.NewVersionUtil"
require "zoo.panel.UpdateSJSuccessPanel"

local kRewardQzoneItemID = 10001
local kRewardQzoneItemNum = 2

local staticUrlRoot = "http://downloadapk.manimal.happyelements.cn/"
local isTfApk = DcUtil:getSubPlatform() and string.len(DcUtil:getSubPlatform()) == 2
if isTfApk then
	staticUrlRoot = "http://apk.manimal.happyelements.cn/"
end


--不支持更新的平台
local noSupportPlatforms = {
	PlatformNameEnum.kCMCCMM,
	PlatformNameEnum.kCMCCMM_JS,
	PlatformNameEnum.kCMCCMM_ZJ,
	PlatformNameEnum.kCUCCWO,
	PlatformNameEnum.k189Store,
	PlatformNameEnum.kCMGame,
	PlatformNameEnum.kHEMM,
	PlatformNameEnum.kMobileMM,
}
local downloadProcess = nil


-- 14:50,10014:1,2:80000
---------------------------------------------------
---------------------------------------------------
-------------- PrePackageRewardRender
---------------------------------------------------
---------------------------------------------------
-- assert(not PrePackageRewardRender)
assert(BaseUI)
PrePackageRewardRender = class(BasePanel)

function PrePackageRewardRender:create(reward)

	local panel = PrePackageRewardRender.new()
	panel:loadRequiredResource(PanelConfigFiles.prepackage_update_panel)
	panel.reward = reward
	panel:init()
	return panel
end

function PrePackageRewardRender:unloadRequiredResource()
end

function PrePackageRewardRender:init()
	self.ui = self:buildInterfaceGroup("confirmrenderer")
	------------------
	-- Init Base Class
	-- ---------------
	BaseUI.init(self,self.ui)

	self:initData()

	self:initUI()
end

function PrePackageRewardRender:initData()
end



function PrePackageRewardRender:initUI()
	self.txtCount = TextField:createWithUIAdjustment(self.ui:getChildByName("txtCountFontSize"), self.ui:getChildByName("txtCount"))
	self.txtCount:removeFromParentAndCleanup(false)
	self.ui:addChild(self.txtCount)

	local num = self.reward.num
	if tonumber(num) > 9999 then
		coinString = math.floor(num / 10000) .. "万"
	else
		coinString = tostring(num)
	end

	self.txtCount:setString("x"..coinString)

	local prop = ResourceManager:sharedInstance():buildItemSprite(self.reward.itemId)
	prop:setVisible(true)
	prop:setScale(1.2)
	local w = prop:getContentSize().width * 1.2
	local h = prop:getContentSize().height * 1.2
	local holder = self.ui:getChildByName("mcHolder")
	holder:removeChildren(false)
	-- if _G.isLocalDevelopMode then printx(0, prop:getContentSize().width,prop:getContentSize().height,"content size") end

	prop:setPosition( ccp(-w/2,h/2))
	holder:addChild(prop)

end


---------------------------------------------------
---------------------------------------------------
-------------- PrePackageUpdatePanel
---------------------------------------------------
---------------------------------------------------
PrePackageUpdatePanel = class(BasePanel)

function PrePackageUpdatePanel:create(position,tip)
	local panel = PrePackageUpdatePanel.new()
	panel:loadRequiredResource(PanelConfigFiles.prepackage_update_panel)
	panel.btnPosInWorldSpace = position
	panel.tip = tip
	panel:init()
	return panel
end

function PrePackageUpdatePanel:unloadRequiredResource()
end

function PrePackageUpdatePanel:init()
	self:initData()

	self:initUI()
end

function PrePackageUpdatePanel:initData()

	if (_G.isPrePackage) then

		if (not UserManager:getInstance().updateInfo) then
			UserManager:getInstance().updateInfo = {} 
		end
		UserManager:getInstance().updateInfo.blocks = {}
		UserManager:getInstance().updateInfo.preRewards = {{num=50,itemId=14},{num=1,itemId=10014},{num=80000,itemId=2}}
		UserManager:getInstance().updateInfo.tips = Localization:getInstance():getText('update.panel.preinstall.desc')
	end

end

function PrePackageUpdatePanel:initUI()
	self.ui = self:buildInterfaceGroup("prepackage_update_panel_group")

	BasePanel.init(self, self.ui)

	local function onCloseTap( ... )
		self:onCloseBtnTapped()
	end
	
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local wSize = CCDirector:sharedDirector():getWinSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local size = self:getGroupBounds().size
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	self.btnGetReward = GroupButtonBase:create(self.ui:getChildByName("btnGetReward"))
	self.btnGetReward:setColorMode(kGroupButtonColorMode.green)
	self.btnGetReward:setString(Localization:getInstance():getText('update.panel.preinstall.btn'))
	self.btnGetReward:addEventListener(DisplayEvents.kTouchTap, handler(self,self.onbtnGetRewardTap))

	self.btnClose = self:createTouchButtonBySprite(self.ui:getChildByName("btnClose"), onCloseTap)

	self.txtDesc = self.ui:getChildByName("txtDesc")
	self.txtDesc:setString(Localization:getInstance():getText('update.panel.preinstall.desc'))

	self.txtChkDesc = self.ui:getChildByName("txtChkDesc")
	self.txtChkDesc:setString(Localization:getInstance():getText('update.panel.preinstall.info2'))

	self.txtBottomDesc = self.ui:getChildByName("txtBottomDesc")
	

	local function onCheckboxTapped(evt)
		self.checkBoxSelected = not self.checkBoxSelected
		self.chbNetwork.select:setVisible(self.checkBoxSelected)

		self.btnGetReward:setEnabled(self.checkBoxSelected)

		if (not self.checkBoxSelected) then
			CommonTip:showTip(Localization:getInstance():getText("update.panel.preinstall.tip"),1,nil,5)
		end
	end

	self.chbNetwork = self.ui:getChildByName('chbNetwork')
	self.chbNetwork.select = self.chbNetwork:getChildByName("select")
	self.chbNetwork:setTouchEnabled(true)
	self.chbNetwork:ad(DisplayEvents.kTouchTap, onCheckboxTapped)
	self.checkBoxSelected = true
	if self.checkBoxSelected then
		self.chbNetwork.select:setVisible(true)
	else
		self.chbNetwork.select:setVisible(false)
	end

	self:initRewardsAndTip()

	-- 玩家当前不允许游戏联网
	if (PrepackageUtil:isPreNoNetWork()) then
		self.txtChkDesc:setVisible(true)
		self.chbNetwork:setVisible(true)
		self.txtBottomDesc:setString(Localization:getInstance():getText('update.panel.preinstall.info3'))
	else
		self.txtChkDesc:setVisible(false)
		self.chbNetwork:setVisible(false)
		self.txtBottomDesc:setString(Localization:getInstance():getText('update.panel.preinstall.info1'))
	end
end

function PrePackageUpdatePanel:initRewardsAndTip()
	local wSize = CCDirector:sharedDirector():getVisibleSize()
	-- if _G.isLocalDevelopMode then printx(0, "wSize====>",wSize.width,wSize.height) end

	self.rewardContainer = self.ui:getChildByName("mcRewardsContainer")

	-- 预装包初始包的tip和奖励写死在代码中
	local rewards
	if (_G.isPrePackage) then
		rewards = UserManager:getInstance().updateInfo.preRewards
	else
		rewards = UserManager:getInstance().updateInfo.rewards
	end

	local blocks = UserManager:getInstance().updateInfo.blocks
	local targets = {}
	if type(rewards) == "table" and #rewards > 0 then
		for k, v in ipairs(rewards) do table.insert(targets, v) end
	elseif type(blocks) == "table" and #blocks > 0 then
		for k, v in ipairs(blocks) do table.insert(targets, v) end
	end

	if ( #targets == 0 or #targets >3) then
		assert(false, "preReards wrong count " .. tostring(#targets) )
		return 
	end

	-- self.rewardContainer:removeChildren(false)
	-- self.rewardContainer:removeChildAt(1)
	for i,v in ipairs(targets) do
		self.rewardContainer:addChild(PrePackageRewardRender:create(v))
		if _G.isLocalDevelopMode then printx(0, i,tostring(v)) end
	end
	-- debug.debug()

	if ( #targets == 1) then
		-- do nothing
	elseif ( #targets == 2) then
		local c1 = self.rewardContainer:getChildAt(1)
		c1:setPositionX(c1:getPositionX() - 80 * wSize.width / 720)
		local c2 = self.rewardContainer:getChildAt(2)
		c2:setPositionX(c2:getPositionX() + 80 * wSize.width / 720)
	elseif ( #targets == 3) then
		local c1 = self.rewardContainer:getChildAt(1)
		c1:setPositionX(c1:getPositionX() - 160 * wSize.width / 720)
		local c3 = self.rewardContainer:getChildAt(3)
		c3:setPositionX(c3:getPositionX() + 160 * wSize.width / 720)
	end

	self.txtDesc:setString( UserManager:getInstance().updateInfo.tips)


	self.tip = self.tip or tostring(UserManager:getInstance().updateInfo.tips) 
	local version = tostring(UserManager:getInstance().updateInfo.version)
	local t = tostring(UserManager:getInstance().updateInfo.md5)

	self:setTitle(1)

	if type(downloadProcess) == "table" and (downloadProcess.status == "ing" or downloadProcess.status == "ready") then
		-- animal:setVisible(false) 
	end

	local progress = self.ui:getChildByName("progress")
	self.pgtxt = self.ui:getChildByName("pgtxt")
	self.pgtxt:setPositionY(progress:getPositionY() - 8)
	self.progress = HomeSceneItemProgressBar:create(progress, 0, 100)


	if type(downloadProcess) ~= "table" then downloadProcess = {} end
	downloadProcess.refreshCallback = function() self:refresh() end

	-- self.showHideAnim = IconPanelShowHideAnim:create(self, self.btnPosInWorldSpace)
	if self:isApkExist(version) then
		downloadProcess.status = "ready"
		downloadProcess.percentage = 0
		downloadProcess.apkPath = self:getApkPath(version)
	end
	self:refresh()

end

-- 1 普通 2 下载中 3 下载完成
function PrePackageUpdatePanel:setTitle(type)
	for i=1,3 do
		self.ui:getChildByName("mcTitle"..tostring(i)):setVisible(false)
	end
	self.ui:getChildByName("mcTitle"..tostring(type)):setVisible(true)
end

function PrePackageUpdatePanel:onbtnGetRewardTap()
	-- 预装报需要先联网获得updateinfo
	if (_G.isPrePackage) then
		local prepackageUtil
		if __ANDROID then 
			prepackageUtil = luajava.bindClass("com.happyelements.android.utils.PrepackageUtils")
		end
		CCUserDefault:sharedUserDefault():setBoolForKey("isPrePackageNetworkOpen", true)
		CCUserDefault:sharedUserDefault():setIntegerForKey("PrepackageNetWorkDialogState", PrepackageNetWorkDialogState.NEVER_SHOW)
		if prepackageUtil then
			prepackageUtil:getInstance():setPrePackageNoNetworkMode(false)
		end
		-- PrepackageUtil:restart()
		_G.isPrePackageNoNetworkMode = false
		
		local function onLoginSuccess()
			if _G.isLocalDevelopMode then printx(0, UserManager:getInstance().updateInfo.rewards) end
			if _G.isLocalDevelopMode then printx(0, UserManager:getInstance().updateInfo.tips ) end

			self:download()
		end

		local function onLoginFailed()
			if _G.isLocalDevelopMode then printx(0, "login failed") end
		end
        RequireNetworkAlert:callFuncWithLogged(onLoginSuccess,onLoginFailed)
    else
    	self:download()
	end
end

function PrePackageUpdatePanel:download()
	local version = nil
	if (UserManager:getInstance().updateInfo) then
		version = tostring(UserManager:getInstance().updateInfo.version)
	end

	if type(downloadProcess) ~= "table" or downloadProcess.status ~= "ing" and downloadProcess.status ~= "ready" then
		if self:isDownloadSupport() then
			if _G.isLocalDevelopMode then printx(0, "download support 111111111111") end
			DcUtil:UserTrack({ category='update', sub_category='update_panel_button'})
			
			if __ANDROID or __WIN32 then
				downloadProcess = {["status"] = "ing", ["percentage"] = 0}
				-- animal:setVisible(false)
				self:downloadApk(version,tostring(UserManager:getInstance().updateInfo.md5))


			else
				NewVersionUtil:gotoMarket()
			end
		else
			if _G.isLocalDevelopMode then printx(0, "download support 22222222222222") end
			self:onCloseBtnTapped()
		end
		self:refresh()
	elseif downloadProcess.status == "ing" then
		if _G.isLocalDevelopMode then printx(0, "download support 3333333333") end
		self:onCloseBtnTapped()
	elseif downloadProcess.apkPath then
		if _G.isLocalDevelopMode then printx(0, "download support 44444444444444") end
		local PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")  -- ok
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder') -- ok
		PackageUtils:installApk(MainActivityHolder.ACTIVITY:getContext(),downloadProcess.apkPath)
	else
		if _G.isLocalDevelopMode then printx(0, "download support 5555555555555") end
		self:onCloseBtnTapped()
	end
end


function PrePackageUpdatePanel:refresh()
	if self.isDisposed then return end

	local actualHeight = 0
	-- local animal = self.ui:getChildByName("ani")
	local label = self.ui:getChildByName("txtDesc")
	-- local label1 = self.ui:getChildByName("label1")
	local tip = self.ui:getChildByName("txtBottomDesc")
	local bg = self.ui:getChildByName("mcBg")
	-- local bg1 = self.ui:getChildByName("bg1")

	-- local dimension = label1:getDimensions()
	-- label1:setDimensions(CCSizeMake(dimension.width, 0))
	-- dimension = label:getDimensions()
	-- label:setDimensions(CCSizeMake(dimension.width, 0))


	if not downloadProcess then
		label:setString(string.gsub(tostring(UserManager.getInstance().updateInfo.tips),"\\n","\n"))
		--发现新版本！
		self:setTitle(1)
	elseif downloadProcess.status == "ing" then
		local rewards = UserManager:getInstance().updateInfo.rewards
		if type(rewards) == "table" and #rewards > 0 then
			label:setString(Localization:getInstance():getText("new.version.dynamic.downloading.label"))
		else
			label:setString(Localization:getInstance():getText("new.version.dynamic.downloading.label.zero"))
		end
		--新版本下载中！
		self:setTitle(2)
	elseif downloadProcess.status == "ready" then
		local rewards = UserManager:getInstance().updateInfo.rewards
		if type(rewards) == "table" and #rewards > 0 then
			label:setString(Localization:getInstance():getText("new.version.package.complete.label"))
		else
			label:setString(Localization:getInstance():getText("new.version.package.complete.label.zero"))
		end
		--下载成功！
		self:setTitle(3)
	else
		label:setString(string.gsub(tostring(UserManager.getInstance().updateInfo.tips),"\\n","\n"))
		--发现新版本！
		self:setTitle(1)
	end

	-- local cSize = label:getContentSize()
	-- cSize = {width = cSize.width, height = cSize.height}
	-- if __IOS then
	-- 	local dimension = label:getDimensions()
	-- 	label:setDimensions(CCSizeMake(dimension.width, cSize.height + 15))
	-- 	cSize.height = cSize.height + 15
	-- end
	-- if #self.items > 0 then
	-- 	actualHeight = label:getPositionY() - cSize.height - 20
	-- 	local iSize = self.items[1].contentSize
	-- 	for k, v in ipairs(self.items) do v:setPositionY(actualHeight) end
	-- 	actualHeight = actualHeight - iSize.height - 20
	-- else
	-- 	actualHeight = label:getPositionY() - cSize.height - 50
	-- end

	local selfScale = self:getScale()
	local bSize = self.btnGetReward:getGroupBounds().size
	bSize = {width = bSize.width / selfScale, height = bSize.height / selfScale}
	-- self.btnGetReward:setPositionY(actualHeight - bSize.height / 2)
	if type(downloadProcess) == "table" and downloadProcess.percentage then
		self.progress:setCurNumber(downloadProcess.percentage)
		self.pgtxt:setText(tostring(downloadProcess.percentage)..'%')
	end
	-- self.progress:setPositionY(actualHeight - 5)
	-- actualHeight = actualHeight - bSize.height - 20
	self.pgtxt:setPositionX((bg:getGroupBounds().size.width / selfScale - self.pgtxt:getContentSize().width) / 2) -- center?
	self.pgtxt:setPositionY(self.progress:getPositionY() - 8)

	if not downloadProcess or downloadProcess.status ~= "ing" and downloadProcess.status ~= "ready" then
		if self:isDownloadSupport() then 
			-- self.btnGetReward:setString(Localization:getInstance():getText("update.mew.vision.panel.yes"))
			local rewards
			if UserManager:getInstance().updateInfo then
				rewards = UserManager:getInstance().updateInfo.rewards
			end
			if type(rewards) == "table" and #rewards > 0 then
				--更新领奖励
				self.btnGetReward:setString(Localization:getInstance():getText("new.version.button.download"))
			else
				--立即更新
				self.btnGetReward:setString(Localization:getInstance():getText("new.version.button.download.zero"))
			end

		else 
			self.btnGetReward:setString(Localization:getInstance():getText("new.version.done.cancel")) 
		end
		self.btnGetReward:setVisible(true)
		self.progress:setVisible(false)
		self.pgtxt:setVisible(false)
		
		if (PrepackageUtil:isPreNoNetWork()) then
			tip:setString(Localization:getInstance():getText("update.panel.preinstall.info3"))	
		else
			tip:setString(Localization:getInstance():getText("new.version.package.tip.text"))	
		end		
	elseif downloadProcess.status == "ing" then
		self.btnGetReward:setString(Localization:getInstance():getText("update.done.doing"))
		self.btnGetReward:setVisible(false)
		self.progress:setVisible(true)
		self.pgtxt:setVisible(true)
		local rewards
		if UserManager:getInstance().updateInfo then
			rewards = UserManager:getInstance().updateInfo.rewards
		end
		if type(rewards) == "table" and #rewards > 0 then
			tip:setString(Localization:getInstance():getText("new.version.dynamic.downloading.tip"))
		else
			tip:setString(Localization:getInstance():getText("new.version.dynamic.downloading.tip.zero"))
		end
	elseif downloadProcess.status == "ready" then
		self.btnGetReward:setString(Localization:getInstance():getText("new.version.package.complete.confirm"))
		self.btnGetReward:setVisible(true)
		self.progress:setVisible(false)
		self.pgtxt:setVisible(false)
		local rewards = UserManager:getInstance().updateInfo.rewards
		if type(rewards) == "table" and #rewards > 0 then
			tip:setString(Localization:getInstance():getText("new.version.package.complete.tip"))
		else
			tip:setString(Localization:getInstance():getText("new.version.package.complete.tip.zero"))
		end
	end
	-- local tSize = tip:getContentSize()
	-- tip:setPositionY(actualHeight)
	-- actualHeight = actualHeight - tSize.height - 20
	-- local bg1Size = bg1:getPreferredSize()
	-- bg1:setPreferredSize(CCSizeMake(bg1Size.width, bg1:getPositionY() - actualHeight))
	-- animal:setPositionY(bg1:getPositionY() - bg1:getPreferredSize().height + animal:getGroupBounds().size.height / selfScale)
	-- local bgSize = bg:getPreferredSize()
	-- bg:setPreferredSize(CCSizeMake(bgSize.width, bg1:getPositionX() - bg1:getPositionY() + bg1:getPreferredSize().height))
	-- local hitArea = self.ui:getChildByName("hit_area")
	-- bgSize = bg:getGroupBounds().size
	-- hitArea:setScaleY(bgSize.height / selfScale / hitArea:getContentSize().height)
end





































function PrePackageUpdatePanel:autoPopout()
	if self:hasLoading() then 
		self:dispose()
	else	
		self:popout()
	end
end

function PrePackageUpdatePanel:popout()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)

	self:refresh()
	downloadProcess.refreshCallback = function() self:refresh() end
end

function PrePackageUpdatePanel:onCloseBtnTapped( ... )
	self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))

	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

function PrePackageUpdatePanel:dispose()
	if type(downloadProcess) == "table" then
		downloadProcess.refreshCallback = nil
	end
	BasePanel.dispose(self)
end

















function PrePackageUpdatePanel:getLpsChannel( ... )
	-- body
	local result = ""
	if StartupConfig:getInstance():getPlatformName() == PlatformNameEnum.kSj then
		local channelId = AndroidPayment.getInstance():getChinaMobileChannelId()
		if channelId and channelId ~= "2200144172" then
			result = "."..channelId
		end
	end
	return result
end


function PrePackageUpdatePanel:getApkPath( version )
	local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils")  -- ok
	local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder') -- ok

	local androidPlatformName = StartupConfig:getInstance():getPlatformName()
	local isMini = StartupConfig:getInstance():getSmallRes() and "mini." or ""
	local lpsChannel = self:getLpsChannel()
	local apkName = _G.packageName .. "." ..isMini.. tostring(version) .. "." .. androidPlatformName ..lpsChannel.. ".apk"

	local apkPath = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext()) .. 	"/" .. apkName

	return apkPath
end

function PrePackageUpdatePanel:isApkExist( version )

	if not __ANDROID then
		return false
	end

	local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils") -- ok
	-- local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')

	return FileUtils:isExist(self:getApkPath(version))
end

function PrePackageUpdatePanel:downloadApk(version,t,tryCount)
	if ((not version) or (not UserManager:getInstance().updateInfo)) then
		CommonTip:showTip(Localization:getInstance():getText("new.version.download.error") , "negative")
		return 
	end

	tryCount = tryCount or 3

	local androidPlatformName = StartupConfig:getInstance():getPlatformName()
	local isMini = StartupConfig:getInstance():getSmallRes() and "mini." or ""
	local lpsChannel = self:getLpsChannel()
	local apkName = _G.packageName .. "." ..isMini.. tostring(version) .. "." .. androidPlatformName ..lpsChannel.. ".apk"
	if _G.isLocalDevelopMode then printx(0, "-G.packageName",_G.packageName) end
	if _G.isLocalDevelopMode then printx(0, "isMini ",isMini) end
	if _G.isLocalDevelopMode then printx(0, "version ",version) end
	if _G.isLocalDevelopMode then printx(0, "androidPlatformName ",androidPlatformName) end
	if _G.isLocalDevelopMode then printx(0, "lpsChannel ",lpsChannel) end

	local apkUrl = staticUrlRoot .. "apk/" .. apkName .. "?t=" .. t --tostring(os.date("%y%m%d%H%M", os.time() or 0))
	if _G.isLocalDevelopMode then printx(0, "apkUrl",apkUrl) end
	if isTfApk then
		apkUrl = apkUrl .. "&source=" .. DcUtil:getSubPlatform()
	end
	local updateUrl = UserManager:getInstance().updateInfo.updateUrl
	if updateUrl then
		apkUrl = updateUrl
	end
	local md5Url = apkUrl:gsub("%.apk","%.md5")

	local apkPath = ""
	if (not __WIN32) then  -- it doesn't mater for platform
		local FileUtils =  luajava.bindClass("com.happyelements.android.utils.FileUtils") -- ok
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder') -- ok
		apkPath = FileUtils:getApkDownloadPath(MainActivityHolder.ACTIVITY:getContext()) .. 	"/" .. apkName
	end

	local homeScene = HomeScene:sharedInstance()

	if _G.isLocalDevelopMode then printx(0, apkName) end

	-- local loading = self:getOrbuildLoading()
	if homeScene.updateVersionButton then 
		homeScene.updateVersionButton:setText("ing", 0)
		homeScene.updateVersionButton:setVisible(true)
	end
	local md5 = ""

	local function onSuccess( ... )
		-- if loading then 
		-- 	self:removeLoading()
		-- 	loading = nil
		-- end
		if _G.isLocalDevelopMode then printx(0, ">>> download success") end

		if isTfApk or updateUrl or md5 == HeMathUtils:md5File(apkPath) then 
			-- local PackageUtils = luajava.bindClass("com.happyelements.android.utils.PackageUtils")
			-- PackageUtils:installApk(MainActivityHolder.ACTIVITY:getContext(),apkPath)
			if type(downloadProcess) == "table" then
				downloadProcess.status = "ready"
				downloadProcess.percentage = 0
				downloadProcess.apkPath = apkPath
				if downloadProcess.refreshCallback then
					downloadProcess.refreshCallback()
				else
					homeScene:runAction(CCCallFunc:create(function()
						if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
						local position = homeScene.updateVersionButton:getPosition()
						local panel = PrePackageUpdatePanel:create(position)
						if panel then
							local function onClose()
								if not homeScene.updateVersionButton or homeScene.updateVersionButton.isDisposed then return end
								homeScene.updateVersionButton.wrapper:setTouchEnabled(true)
							end
							panel:addEventListener(kPanelEvents.kClose, onClose)
							homeScene.updateVersionButton.wrapper:setTouchEnabled(false)
							panel:popout()
						end
					end))
				end
			end
			if homeScene.updateVersionButton then 
				homeScene.updateVersionButton:setText("ready")
				homeScene.updateVersionButton:setVisible(true)
			end
		else
			HeFileUtils:removeFile(apkPath)
			CommonTip:showTip(Localization:getInstance():getText("new.version.download.error") , "negative")
			if type(downloadProcess) == "table" then
				downloadProcess.status = "error"
				downloadProcess.percentage = 0
				if downloadProcess.refreshCallback then
					downloadProcess.refreshCallback()
				end
			end
			if homeScene.updateVersionButton then 
				homeScene.updateVersionButton:setText()
				homeScene.updateVersionButton:setVisible(true)
			end
		end
	end
	local function onError( code )
		if _G.isLocalDevelopMode then printx(0, ">>> download onError ",code) end 
		tryCount = tryCount - 1
		if code ~= 1000 then
			if tryCount > 0 then
				self:downloadApk(version,t,tryCount)
			else
				-- if loading then 
				-- 	self:removeLoading()
				-- 	loading = nil
				-- end
				CommonTip:showTip(Localization:getInstance():getText("new.version.download.error") , "negative")
			end
		else
			CommonTip:showTip("当前更新链接出错，请通过应用商店下载最新版本游戏哦~", "negative")
			he_log_error("download apk error:"..StartupConfig:getInstance():getPlatformName())
		end

		if homeScene.updateVersionButton then 
			homeScene.updateVersionButton:setText()
			homeScene.updateVersionButton:setVisible(true)
		end

		if type(downloadProcess) == "table" then
			downloadProcess.status = "error"
			downloadProcess.percentage = 0
			if downloadProcess.refreshCallback then
				downloadProcess.refreshCallback()
			end
		end
	end
	local function onProcess(progress,total)
		if _G.isLocalDevelopMode then printx(0, ">>> download onProcess ",progress,"   ",total) end 
		if homeScene.updateVersionButton then 
			homeScene.updateVersionButton:setText("ing", math.floor(progress * 100 / total))
			homeScene.updateVersionButton:setVisible(true)
		end
		
		if type(downloadProcess) == "table" then
			downloadProcess.status = "ing"
			downloadProcess.percentage = math.floor(progress * 100 / total)
			if downloadProcess.refreshCallback then
				downloadProcess.refreshCallback()
			else
				-- TODO: autopop
			end
		end
	end

	if homeScene.updateVersionButton then 
		homeScene.updateVersionButton:setVisible(true)
	end

	local function startDownload()
		if _G.isLocalDevelopMode then printx(0, "enter start download ....") end
		local downLoadCallfunc = luajava.createProxy("com.happyelements.android.utils.DownloadApkCallback", {
				onSuccess = onSuccess,
				onError = onError,
				onProcess = onProcess	
			})

		local HttpUtil = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
		HttpUtil:downloadApk(apkUrl,apkPath,downLoadCallfunc)
	end

	-- @TBD test will be uncomment
	-- function mockDownload()
	-- 	local scheduleScriptFuncID
	-- 	local total = 100
	-- 	local curr = 0
	-- 	local function onScheduleScriptFunc()
	-- 		curr = curr + 1
	-- 		onProcess(curr,total)
	--     	if ( curr > total) then
	--     		onSuccess()
	--     		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(scheduleScriptFuncID)
	--     	end
	--   	end
	--   	scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onScheduleScriptFunc,0.1,false)
	-- end
	-- mockDownload()
	if _G.isLocalDevelopMode then printx(0, ">>>>> isTfApk ",isTfApk) end
	if _G.isLocalDevelopMode then printx(0, ">>>>> updateUrl ",updateUrl) end

	if isTfApk or updateUrl then 
		if _G.isLocalDevelopMode then printx(0, ">>>>> start download ") end
		startDownload()
	else
		if _G.isLocalDevelopMode then printx(0, ">>>>> md5Url ",md5Url) end
		self:requestApkMd5(md5Url,function( m )
			md5 = m
			if _G.isLocalDevelopMode then printx(0, "!!! md5 is ",md5) end
			if md5 == "" then 
				onError(0)
				return
			end
			startDownload()
		end)
	end
	
	self:onCloseBtnTapped()
end



local cacheMd5 = {}
function PrePackageUpdatePanel:requestApkMd5( md5Url,callback )

	local key = md5Url:gsub("%?t=.+$","")
	if _G.isLocalDevelopMode then printx(0, "requestApkMd5 key ",key) end

	if cacheMd5[key] then
		if _G.isLocalDevelopMode then printx(0, " requestApkMd5 cacheMd5 ") end
		callback(cacheMd5[key])
		if _G.isLocalDevelopMode then printx(0, ">>>>>> 88888888888888888") end
		return
	end

    local function onCallback(response)
    	if _G.isLocalDevelopMode then printx(0, ">>> callback ",response.httpCode ) end
		if response.httpCode ~= 200 then 
			if _G.isLocalDevelopMode then printx(0, "get requestApkMd5 error code:" .. response.body) end

			callback("")
		else
			if _G.isLocalDevelopMode then printx(0, ">>> callback 1111",response,"  ",response.body ) end
			callback(response.body)
			cacheMd5[key] = response.body
		end
    end

	local request = HttpRequest:createGet(md5Url)
  	local connection_timeout = 2
  	if __WP8 then 
    	connection_timeout = 5
  	end
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
    HttpClient:getInstance():sendRequest(onCallback, request)
    if _G.isLocalDevelopMode then printx(0, " 77777777777777 ") end
end

function PrePackageUpdatePanel:getOrbuildLoading( ... )
	local homeScene = HomeScene:sharedInstance()

	local loading = homeScene.packageLoading
	if loading then 
		return loading
	end
	if self.isDisposed then 
		return nil
	end

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	loading = self:buildInterfaceGroup("updage_package_loading")
	loading:setPositionX(visibleSize.x)
	loading:setPositionY(visibleSize.height + visibleOrigin.y)
	homeScene:addChild(loading, SceneLayerShowKey.POP_OUT_LAYER)

	homeScene.packageLoading = loading

	function loading:setPercent( current,total )
		self:getChildByName("text"):setString(Localization:getInstance():getText(
			"new.version.download.progress",
			{
				rate = string.format("%.2fM/%.2fM",current/(1024*1024),total/(1024*1024))
			}
		))	
		local bar = self:getChildByName("bar")
		if total > 0 then 
			bar:setPreferredSize(CCSizeMake(visibleSize.width * current / total,bar:getPreferredSize().height))
		else
			bar:setPreferredSize(CCSizeMake(1,bar:getPreferredSize().height))
		end
		if _G.isLocalDevelopMode then printx(0, "current:" .. current .. " total:" .. total) end
		if _G.isLocalDevelopMode then printx(0, "percent:" .. bar:getContentSize().width) end
	end
	loading:setPercent(0,0)

	return loading
end

function PrePackageUpdatePanel:hasLoading( ... )
	local homeScene = HomeScene:sharedInstance()
	local loading = homeScene.packageLoading

	return loading 
end
function PrePackageUpdatePanel:removeLoading( ... )
	local homeScene = HomeScene:sharedInstance()
		
	local loading =	homeScene.packageLoading
	if loading then 
		loading:removeFromParentAndCleanup(true)
		homeScene.packageLoading = nil
	end
end

function PrePackageUpdatePanel:isDownloadSupport( ... )
	-- -- for test
	-- if __WIN32 then 
	-- 	return true
	-- end

	if not __ANDROID then 
		return true
	end

  	local androidPlatformName = StartupConfig:getInstance():getPlatformName()

	for i, platform in ipairs(noSupportPlatforms) do
		if platform == androidPlatformName then
	    	return false
		end
	end
	return true
end


