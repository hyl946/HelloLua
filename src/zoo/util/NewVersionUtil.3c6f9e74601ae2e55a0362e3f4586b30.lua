
require "zoo.panel.RequireNetworkAlert"
require "zoo.config.NetworkConfig"

NewVersionUtil = {}

local AndroidMarketDetails = {
	[PlatformNameEnum.kBBK]		= {url='market://details?id='.._G.packageName..'&caller='.._G.packageName, pkg='com.bbk.appstore'},
	[PlatformNameEnum.kOppo]	= {url='market://details?id='.._G.packageName..'&caller='.._G.packageName, pkg='com.oppo.market'},
	[PlatformNameEnum.kMI]		= {url='market://details?id='.._G.packageName..'&caller='.._G.packageName, pkg='com.xiaomi.market'},
	[PlatformNameEnum.kHuaWei]	= {url='market://details?id='.._G.packageName..'&caller='.._G.packageName, pkg='com.huawei.appmarket'},
}
	-- 360和wandoujia走CDN更新
	-- [PlatformNameEnum.k360]		= {url='market://details?id='.._G.packageName..'&caller='.._G.packageName, pkg='com.qihoo.appstore'},
	-- [PlatformNameEnum.kWDJ]		= {url='market://details?id='.._G.packageName..'&caller='.._G.packageName, pkg='com.wandoujia.phoenix2'},

function NewVersionUtil:gotoMarket()
	if RequireNetworkAlert:popout() then
		NewVersionUtil:openMarket()
	end
end

function NewVersionUtil:openMarket()
	if __WP8 then 
		Wp8Utils:GotoMarket() 
		return 
	end
	if __ANDROID then
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local Intent = luajava.bindClass('android.content.Intent')
		local Uri =  luajava.bindClass('android.net.Uri') 
		
		local intent = luajava.newInstance('android.content.Intent')
		intent:setAction(Intent.ACTION_VIEW)

		local marketDetail = AndroidMarketDetails[PlatformConfig.name]
		if marketDetail then
			intent:setData(Uri:parse(marketDetail.url))
			if marketDetail.pkg then
				intent:setPackage(marketDetail.pkg)
			end
		else
			local url = nil
			local updateInfo = UserManager:getInstance().updateInfo
			if updateInfo and updateInfo.updateUrl and updateInfo.updateUrl ~= "" then 
				url = updateInfo.updateUrl
			end
			if url then 
				intent:setData(Uri:parse(url))
			else
				intent:setData(Uri:parse('market://details?id=' .. _G.packageName))
			end
		end
		local context = MainActivityHolder.ACTIVITY:getContext()
		context:startActivity(intent)
	end
	if __IOS then
		self:gotoAppleStore()
	end
end

function NewVersionUtil:canOpenMarket()
	if __IOS then 
		return true
	end
	if __ANDROID then
		if not MaintenanceManager:getInstance():isEnabled("UpdateByMarket", true) then
			return false
		end
		local marketDetail = AndroidMarketDetails[PlatformConfig.name]
		if marketDetail then
			if marketDetail.pkg then
				return luajava.bindClass("com.happyelements.android.utils.PackageUtils"):isPackageInstalled(marketDetail.pkg)
			else
				return true
			end
		end
	end
	return false
end

function NewVersionUtil:gotoAppleStore()
	local deviceType = MetaInfo:getInstance():getMachineType() or ""
    local systemVersion = AppController:getSystemVersion() or 7
	local nsURL = nil
    if string.find(deviceType, "iPad") and (systemVersion >= 6 and systemVersion < 7) then
		nsURL = NSURL:URLWithString("itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=791532221")
    else
		nsURL = NSURL:URLWithString("itms-apps://itunes.apple.com/app/id791532221")
    end
	UIApplication:sharedApplication():openURL(nsURL)
end


-- 有更新版本，包含大包跟动态更新
function NewVersionUtil:hasNewVersion()
	-- 0：不需要更新；1：大版本更新；2：动态更新
	return NewVersionUtil.hasDynamicUpdate(self) or NewVersionUtil.hasPackageUpdate(self)
end

function NewVersionUtil:hasDynamicUpdate()
	if PrepackageUtil:isPreNoNetWork() or _G.isPrePackageCannotShowUpdatePanel then return false end
	
	if not UserManager.getInstance().updateInfo  then
		return false
	end

	if not UserManager.getInstance().updateInfo.tips then
		return false
	end

	if UserManager.getInstance().user:getTopLevelId() < 20 and not __WP8 then
		return false
	end

	return UserManager.getInstance().updateInfo.type == 2
end

function NewVersionUtil:hasPackageUpdate()
	-- if _G.isPrePackageCannotShowUpdatePanel or (PrepackageUtil:isPreNoNetWork() ) then return false end
	if _G.isPrePackageCannotShowUpdatePanel then return false end

	if (_G.isPrePackage and UserManager.getInstance():hasPassed(30)) then 
		return true
	end 

	if not UserManager.getInstance().updateInfo then
		return false
	end

	if not UserManager.getInstance().updateInfo.tips then
		return false
	end
	
	if UserManager.getInstance().user:getTopLevelId() < 20 and not __WP8 then
		return false
	end

	return UserManager.getInstance().updateInfo.type == 1
end

function NewVersionUtil:hasUpdateReward()
	
	-- if UserManager.getInstance().user:getTopLevelId() < 20 and not __WP8 then
	-- 	return false
	-- end

	local result = true

	if (UserManager.getInstance().preRewardsFlag) then
		result = false
	end

	local rewards = UserManager.getInstance().updateRewards or UserManager.getInstance().preRewards or {}
	if #rewards <= 0 then result = false end
	for k, reward in ipairs(rewards) do
		if not reward or not reward.num or not reward.itemId then
			result = false
			break
		end
	end

	if (_G.isPrePackage) then
		result = false
	end

	if NewVersionUtil:hasSJReward() then
		result = true
	end

	-- if _G.isLocalDevelopMode then printx(0, "update result >>>>>",result,NewVersionUtil:hasSJReward()) end

	return result
end

function NewVersionUtil:hasSJReward( )
	-- body
	local result = false
	local sjRewards = UserManager.getInstance().sjRewards
	if sjRewards and #sjRewards > 0 then
		result = true
	end
	return result
end

-- function NewVersionUtil:cacheUpdateInfo()


-- 	if NewVersionUtil.hasNewVersion(self) then 
-- 		local updateInfo = UserManager.getInstance().updateInfo	
-- 		local key = "game.updateInfo" .. "." .. ResourceLoader.getCurVersion() .. "." .. _G.bundleVersion		
-- 		local content = nil
-- 		if updateInfo.Reward then 
-- 			content = tostring(updateInfo.type) .. ";" .. tostring(updateInfo.Reward.itemId) .. ";" .. tostring(updateInfo.Reward.num)
-- 		else
-- 			content = tostring(updateInfo.type)
-- 		end
-- 		if _G.isLocalDevelopMode then printx(0, key .. '  ' .. content) end
-- 		CCUserDefault:sharedUserDefault():setStringForKey(key,content)
-- 	end
-- end

function NewVersionUtil:cacheUpdateInfo( ... )
	
	if NewVersionUtil.hasNewVersion(self) then 

		local updateInfo = UserManager.getInstance().updateInfo	
		local updateInfo_json = table.serialize(updateInfo)
		local key = "game.updateInfo.newformat" .. "." .. ResourceLoader.getCurVersion() .. "." .. _G.bundleVersion		
		CCUserDefault:sharedUserDefault():setStringForKey(key,updateInfo_json)
	end

end

function NewVersionUtil:readCacheUpdateInfo()

	local key = "game.updateInfo.newformat" .. "." .. ResourceLoader.getCurVersion() .. "." .. _G.bundleVersion
	local updateInfo_json = CCUserDefault:sharedUserDefault():getStringForKey(key)

	if updateInfo_json and updateInfo_json ~= "" then 
		local updateInfo = { }
		updateInfo = table.deserialize(updateInfo_json)
		updateInfo.tips = CCUserDefault:sharedUserDefault():getStringForKey("game.updateInfo.tips")
		UserManager.getInstance().updateInfo = updateInfo
	end
end


-- function NewVersionUtil:readCacheUpdateInfo()
-- 	local key = "game.updateInfo" .. "." .. ResourceLoader.getCurVersion() .. "." .. _G.bundleVersion
-- 	if _G.isLocalDevelopMode then printx(0, key) end
-- 	local cacheUpdateInfo = CCUserDefault:sharedUserDefault():getStringForKey(key)
-- 	if cacheUpdateInfo and cacheUpdateInfo ~= "" then 
-- 		local t = cacheUpdateInfo:split(';')
-- 		if #t ~= 3 and #t ~= 1 then
-- 			return 
-- 		end
-- 		local updateInfo = { }
-- 		updateInfo.type = tonumber(t[1])
-- 		if #t == 3 then 
-- 			updateInfo.Reward = {}
-- 			updateInfo.Reward.itemId = tonumber(t[2])
-- 			updateInfo.Reward.num = tonumber(t[3])
-- 		end
-- 		updateInfo.tips = CCUserDefault:sharedUserDefault():getStringForKey("game.updateInfo.tips")
-- 		UserManager.getInstance().updateInfo = updateInfo
-- 	end
-- end


function NewVersionUtil:showUnlockCloudTip( level  )
	-- body
	if level > 0 then
		local tip = Localization:getInstance():getText("sj.update.finish.unlock")
		local function yesCallback( ... )
			-- body
			local function onSendUnlockMsgSuccess( ... )
				-- body
				local user =  UserService:getInstance().user
				local minLevelId = user:getTopLevelId() + 1
				user:setTopLevelId(minLevelId)
				local lockedClouds = HomeScene:sharedInstance().worldScene.lockedClouds
				for k, v in pairs(lockedClouds) do 
					if v.id == level and not v.isCachedInPool then
						v:unlockCloud()
					end
				end
			end
			local logic = UnlockLevelAreaLogic:create(level)
			logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
			logic:start(UnlockLevelAreaLogicUnlockType.USE_DOWN_NEW_APK, {})
		end
		local text = {
			tip = Localization:getInstance():getText("sj.update.finish.unlock"),
			yes = Localization:getInstance():getText("button.ok"),
		}
		CommonTipWithBtn:showTip(text, "positive", yesCallback, nil, nil, true)
	end
end

