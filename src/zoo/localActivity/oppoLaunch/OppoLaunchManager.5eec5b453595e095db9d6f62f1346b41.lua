require "zoo.localActivity.oppoLaunch.OppoTurntablePanel"
require "zoo.localActivity.oppoLaunch.OppoTurntableDesc"

OppoLaunchManager = class()
local instance = nil
local kRedDotShowOver = "oppo_red_dot_show_over"
local kBtnLastShowTime = "oppo_btn_last_show_time"

function OppoLaunchManager.getInstance()
	if not instance then
		instance = OppoLaunchManager.new()
		instance:init()
	end
	return instance
end

function OppoLaunchManager:init()
	self.isOppoLaunch = false or __WIN32
	self.autoQueryServer = false
	self.rewardPool = {}
	self.continueDay = 0
	self.rewards = {}

	self.userDefault = CCUserDefault:sharedUserDefault()
	self.btnLastShowTime = self.userDefault:getIntegerForKey(kBtnLastShowTime, 0)

	if PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then 
		pcall(function ()
			local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy"):getInstance()
			self.isOppoLaunch = oppoProxy:isStartFromOgc()
			self.autoQueryServer = self.isOppoLaunch
		end)
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kBBK) then 
		pcall(function ()
			local vivoProxy = luajava.bindClass("com.happyelements.android.platform.vivo.VivoProxy"):get()
			self.isOppoLaunch = vivoProxy:isStartFromOgc()
			self.autoQueryServer = self.isOppoLaunch
		end)
	elseif self:isMi() then 
		pcall(function ()
			local miProxy = luajava.bindClass("com.happyelements.android.platform.xiaomi.MiLaunchProxy"):get()
			self.isOppoLaunch = miProxy:isStartFromOgc()
			RemoteDebug:uploadLog('isMiLaunch:', self.isOppoLaunch)
			self.autoQueryServer = self.isOppoLaunch
		end)
	end

	self.userDefault = CCUserDefault:sharedUserDefault()
	self.isRedDotShowOver = self.userDefault:getBoolForKey(kRedDotShowOver, false)
end

function OppoLaunchManager:getIsOppoLaunch()
	return self.isOppoLaunch
end

function OppoLaunchManager:shouldShowRedDot()
	if not self:shouldShowOGCButton() then return false end
	return not self.isRedDotShowOver
end

function OppoLaunchManager:setRedDotShowOver()
	if not self.isRedDotShowOver then 
		self.isRedDotShowOver = true
		self.userDefault:setBoolForKey(kRedDotShowOver, true)
	end
end

function OppoLaunchManager:tryOppoLaunchReward(endCallback)
	local function successFunc(showPanel)
		if showPanel then 
			local panel = OppoTurntablePanel:create(endCallback)
			panel:popout()
		else
			if endCallback then endCallback() end
		end
	end

	local function failFunc(errCode)
		local tipKey 
		--重复领取   731650
		--活动已过期 731651
		if errCode == 0 or errCode == 731650 or errCode == 731651 then 
			if _G.isLocalDevelopMode then 
				tipKey = "游戏中心启动测试==错误码=="..errCode, "negative"
			end
		elseif errCode == ZooErrorCode.kNetworkError then
			tipKey = "联网登录才可以获取游戏中心奖励哦~"
		else
			tipKey= "error.tip."..tostring(errCode)
		end
		if tipKey then 
			local tipValue = Localization:getInstance():getText(tipKey)
			CommonTip:showTip(tipValue, "negative")
		end

		if endCallback then endCallback() end
	end
	
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	if __ANDROID and self.autoQueryServer and topLevelId >= 20 then 
		if PlatformConfig:isPlatform(PlatformNameEnum.kOppo) or PlatformConfig:isPlatform(PlatformNameEnum.kBBK) or self:isMi() then
			self:getServerData(successFunc, failFunc)
			self.autoQueryServer = false
		end
	else
		if endCallback then endCallback() end
	end
end

function OppoLaunchManager:canPop()
	local topLevelId = UserManager:getInstance().user:getTopLevelId()
	return __ANDROID and self.autoQueryServer and topLevelId >= 20
			and (PlatformConfig:isPlatform(PlatformNameEnum.kOppo) or PlatformConfig:isPlatform(PlatformNameEnum.kBBK) or self:isMi())
end

function OppoLaunchManager:isVivo()
	return PlatformConfig:isPlatform(PlatformNameEnum.kBBK)
end

function OppoLaunchManager:isMi()
	if __WIN32 then
		return true
	end
	return PlatformConfig:isPlatform(PlatformNameEnum.kMI)
end

--only called when panel(OppoTurntablePanel/OppoTurntableDesc) close
function OppoLaunchManager:updateBtnLastShowTime()
	if self:getLeftRewardsNum() <= 0 then 
		self.userDefault:setIntegerForKey(kBtnLastShowTime, Localhost:timeInSec())
		if HomeScene:sharedInstance().oppoLaunchButton then 
			HomeScene:sharedInstance():onIconBtnFinishJob(HomeScene:sharedInstance().oppoLaunchButton)
			HomeScene:sharedInstance().oppoLaunchButton = nil
		end
	else
		if not HomeScene:sharedInstance().oppoLaunchButton then 
			HomeScene:sharedInstance():buildOppoLaunchButton()
		end
	end
end

function OppoLaunchManager:isTodayLaunchBtnShow()
	return Localhost:getDayStartTimeByTS(self.btnLastShowTime) == Localhost:getDayStartTimeByTS(Localhost:timeInSec()) 
end

function OppoLaunchManager:shouldShowOGCButton()
	if __WIN32 and _G.isLocalDevelopMode then 
		return true
	end
	if not __ANDROID then return end 
	if not PlatformConfig:isPlatform(PlatformNameEnum.kOppo) and not PlatformConfig:isPlatform(PlatformNameEnum.kBBK) and not self:isMi() then return end
	if self:isTodayLaunchBtnShow() then return end

	return true
end

local showRewardPool = {
	{itemId = 2, num = 2000},
	{itemId = 10058, num = 1},
	{itemId = 2, num = 5000}, 
	{itemId = 14, num = 2},
	{itemId = 2, num = 8000},
	{itemId = 10059, num = 1},
	{itemId = 14, num = 1},
	{itemId = 10013, num = 1},
}

local realRewardPool = {
	{itemId = 2, num = 2000},
	{itemId = 2, num = 5000}, 
	{itemId = 2, num = 8000},
	{itemId = 14, num = 1},
	{itemId = 14, num = 2},
	{itemId = 10058, num = 1},
	{itemId = 10059, num = 1},
	{itemId = 10013, num = 1},
}


function OppoLaunchManager:getServerData(successFunc, failFunc)
	self.showRewardPool = showRewardPool
	self.realRewardPool = realRewardPool

	local function onSuccess(evt)
		local info = evt.data or {}
		self.continueDay = info.continueDay or 1
		-- {
		-- 	{first = 1, second = 5},
		-- 	{first = 2, second = 3},
		-- }
		self.rewards = info.rewards or {}

		if self.continueDay < 1 or #self.rewards <= 0 then 
			if successFunc then successFunc(false) end
		else
			if successFunc then successFunc(true) end
		end
	end

	local function onFail(evt)
		local errCode = evt and evt.data or 0
		if failFunc then failFunc(errCode) end
	end

	local http = OppoLaunchRewardHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
    http:addEventListener(Events.kError, onFail)
	http:syncLoad()
end

function OppoLaunchManager:getRewardById(rewardId)
	return self.realRewardPool[rewardId]
end

function OppoLaunchManager:getRewardPool()
	return self.showRewardPool
end

function OppoLaunchManager:getContinueDayNum()
	return self.continueDay
end

function OppoLaunchManager:getCurrentReward()
	local reward = self.rewards[1]
	local rewardWrapper = nil
	if reward then 
		table.remove(self.rewards, 1)
		rewardWrapper = {}
		rewardWrapper.id = reward.first
		local rewardConfig = self:getRewardById(reward.second)
		rewardWrapper.itemId = rewardConfig.itemId
		rewardWrapper.num = rewardConfig.num
	end

	return rewardWrapper
end

function OppoLaunchManager:getLeftRewardsNum()
	return #self.rewards
end

function OppoLaunchManager:addReward(reward)
	--离线请求同步后端
	local http = OpNotifyOffline.new()
	local function opSuccess()
		UserManager:getInstance():addReward(reward, true)
		UserService:getInstance():addReward(reward)
		local dcSource = DcSourceType.kOppoLaunch
		if PlatformConfig:isPlatform(PlatformNameEnum.kBBK) then
			dcSource = DcSourceType.kVivoLaunch
		elseif self:isMi() then
			dcSource = DcSourceType.kMiLaunch
		end
		GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, reward.itemId, reward.num, dcSource)

		Localhost:getInstance():flushCurrentUserData()
	end
	local function opFail()
	end
	http:ad(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
	http:load(OpNotifyOfflineType.kOppoLaunchReward, reward.id)
end

function OppoLaunchManager:launchGameCenter()
	if self:isVivo() then 

	elseif self:isMi() then
		OppoLaunchManager:dc("oppoact_center_click")
		--migamecenter://openurl/https://static.g.mi.com/game/newAct/qdtq/index.html?hideTitleBar=1&refresh=true&tag=0&backToMain=true
		local url = 'migamecenter://details?pkgname=com.happyelements.AndroidAnimal'
		OpenUrlUtil:openUrl(url)
	else
		OppoLaunchManager:dc("oppoact_center_click")
		pcall(function ()
			local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy"):getInstance()
			oppoProxy:launchGameCenter()
		end)
	end
end

function OppoLaunchManager:launchForum()
	if self:isVivo() then 

	elseif self:isMi() then

	else
		OppoLaunchManager:dc("oppoact_community")
		pcall(function ()
			local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy"):getInstance()
			local callback = {
	            onSuccess=function(result)
	            end,
	            onError=function(errorCode, msg)
	            end,
	            onCancel=function()
	            end
	        }
	        oppoProxy:launchForum(convertToInvokeCallback(callback))
		end)
	end
end

function OppoLaunchManager:dc(subCategory, goodsId, num, clickType)
	local params = {}
	if self:isVivo() then
		params.category = "vivoact"
	elseif self:isMi() then
		params.category = "miact"
	else
		params.category = "oppoact"
	end

	params.sub_category = subCategory

	if self:isVivo() then
		params.sub_category = string.gsub(subCategory, "oppo(%w+)", "vivo%1")
	elseif self:isMi() then
		params.sub_category = string.gsub(subCategory, "oppo(%w+)", "mi%1")
	end

	if goodsId then 
		params.goodsId = goodsId
	end
	if num then
		params.num = num
	end
	if clickType then 
		params.clickType = clickType
	end
	DcUtil:dcForOppoLaunch(params)
end