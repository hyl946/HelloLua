
UpdateDynamicPopoutAction = class(HomeScenePopoutAction)

function UpdateDynamicPopoutAction:ctor()
	self.name = "UpdateDynamicPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

local function isWifi()
	if __ANDROID then
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		local netType = metaInfo:getNetworkInfo()
		return netType ~= -1 and netType ~= 0
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

function UpdateDynamicPopoutAction:checkCanPop()
	if self.debug then
		CCUserDefault:sharedUserDefault():setStringForKey("game.updateInfo.tips","1")
	end
	local updateVersionButton = AutoPopout.homeScene.updateVersionButton
	local hasNewVersion = NewVersionUtil:hasNewVersion()

	if not updateVersionButton or not hasNewVersion then
		return self:onCheckPopResult(false)
	end

    local updateInfo = UserManager.getInstance().updateInfo or {}
	local curTips = updateInfo.tips or ""

	local function getString( key )
		return CCUserDefault:sharedUserDefault():getStringForKey(key)
	end

    local check = getString("game.updateInfo.tips") ~= curTips 
    			or (getString("game.updateInfo.waitWifi") == 'true' and isWifi())

   	if not check then
   		return self:onCheckPopResult(false)
   	end
   	if (not _G.isPrePackage) and NewVersionUtil:hasPackageUpdate() then
		return self:onCheckPopResult(false)
	elseif NewVersionUtil:hasDynamicUpdate() then
		return self:onCheckPopResult(true)
	else
		return self:onCheckPopResult(false)
	end
end

function UpdateDynamicPopoutAction:popout( next_action )
	local updateVersionButton = AutoPopout.homeScene.updateVersionButton
	local isAutoPopout = true

	if NewVersionUtil:hasDynamicUpdate() and not updateVersionButton.isDisposed then
		updateVersionButton.wrapper:setTouchEnabled(false)

		DynamicUpdatePanel:onCheckDynamicUpdate(isAutoPopout,next_action,next_action)
		
		local updateInfo = UserManager.getInstance().updateInfo or {}
		local curTips = updateInfo.tips or ""
		popoutCallback(curTips)
	else 
		next_action()
	end
end