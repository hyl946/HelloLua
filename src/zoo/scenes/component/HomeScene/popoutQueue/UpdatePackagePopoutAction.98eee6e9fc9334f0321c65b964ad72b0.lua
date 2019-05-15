UpdatePackagePopoutAction = class(HomeScenePopoutAction)

function UpdatePackagePopoutAction:ctor()
	self.name = "UpdatePackagePopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

local function isWifi()
	if __ANDROID then
		-- local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		-- local netType = metaInfo:getNetworkInfo()
		-- return netType ~= -1 and netType ~= 0
		return NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi
	else
		return true -- IOS不需要在更新时弹流量提醒，所以假装ios总是wifi
	end
end

local function popoutCallback( curTips )
	CCUserDefault:sharedUserDefault():setStringForKey("game.updateInfo.tips",curTips)
	if not isWifi() then
		CCUserDefault:sharedUserDefault():setStringForKey("game.updateInfo.waitWifi", 'true')
	else
		CCUserDefault:sharedUserDefault():setStringForKey("game.updateInfo.waitWifi", 'false')
	end
	NewVersionUtil:cacheUpdateInfo()
	CCUserDefault:sharedUserDefault():flush()
end

function UpdatePackagePopoutAction:checkCanPop()
	if UpdatePackageManager:enabled() then
		return self:onCheckPopResult(false)
	end

	if not NewVersionUtil:hasPackageUpdate() then
		return self:onCheckPopResult(false)
	end

	if not NewVersionUtil:hasNewVersion() then
		return self:onCheckPopResult(false)
	end

	local updateVersionButton = AutoPopout.homeScene.updateVersionButton
	if not updateVersionButton or updateVersionButton.isDisposed then
		return self:onCheckPopResult(false)
	end

	local updateInfo = UserManager.getInstance().updateInfo or {}
	local curTips = updateInfo.tips or ""

	local function getString( key )
		return CCUserDefault:sharedUserDefault():getStringForKey(key)
	end

	--版本信息没有变化
	local isSameVersion = getString("game.updateInfo.tips") == curTips
	--等待第一次4g切换到wifi
	local isJustChangedWifi = getString("game.updateInfo.waitWifi") == 'true' and isWifi()

	self.today = math.floor((Localhost:timeInSec()/3600+8)/24)
	local lastPopDay = CCUserDefault:sharedUserDefault():getIntegerForKey("UpdatePackagePopoutAction.day", 0)
	local isPopToday = lastPopDay == self.today

	-- print("------------UpdatePackagePopoutAction self.today",self.today,lastPopDay)

	if isSameVersion and not isJustChangedWifi and isPopToday then
		return self:onCheckPopResult(false)
	end

   	if (not _G.isPrePackage) then
   		local WifiAutoDownloadManager = require 'zoo.data.WifiAutoDownloadManager'
   		
		if WifiAutoDownloadManager:getInstance():isTurnOn() and 
			NetworkUtil:getNetworkStatus() == NetworkUtil.NetworkStatus.kWifi then
			popoutCallback(curTips)
			return self:onCheckPopResult(false)
		else
			return self:onCheckPopResult(true)
		end
	else
		return self:onCheckPopResult(true)
	end
end

function UpdatePackagePopoutAction:popout( next_action )
	CCUserDefault:sharedUserDefault():setIntegerForKey("UpdatePackagePopoutAction.day", self.today)
	CCUserDefault:sharedUserDefault():flush()

	local updateVersionButton = AutoPopout.homeScene.updateVersionButton

	local position = updateVersionButton:getPositionInWorldSpace()

	local updateInfo = UserManager.getInstance().updateInfo or {}
	local curTips = updateInfo.tips or ""

	local panel
	local function doPopout( forcePopout )
		if panel then
			local function onClose()
				next_action()
				if not updateVersionButton or updateVersionButton.isDisposed then return end
				updateVersionButton.wrapper:setTouchEnabled(true)
			end
			panel:addEventListener(kPanelEvents.kClose, onClose)
			updateVersionButton.wrapper:setTouchEnabled(false)
			panel:popout(forcePopout)

			popoutCallback(curTips)
		else
			next_action()
		end
	end

	if (_G.isPrePackage ) then
		panel = PrePackageUpdatePanel:create(position)
		doPopout()
	else
		local AsyncSkinLoader = require 'zoo.panel.AsyncSkinLoader'
        AsyncSkinLoader:create(UpdatePageagePanel, {
            position
        }, UpdatePageagePanel.getSkin, function ( __panel )
            panel = __panel
            doPopout(true)
        end, next_action)

	end
end

function UpdatePackagePopoutAction:popupCondition()
	return true
end