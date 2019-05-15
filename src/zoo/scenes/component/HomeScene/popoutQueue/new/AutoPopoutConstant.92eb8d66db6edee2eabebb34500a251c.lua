--[[
 * AutoPopoutConstant
 * @date    2018-08-01 11:00:48
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AutoPopoutActionType = {
	kTop = 1,
	kOpenUrl = 2,
	kNextLevelMode = 3,
	kFeature = 4,
	kActivity = 5,
	kGuide = 6,
	kSubFeatureNotify = 41,
	kSubFeatureSystem = 42,
	kSubFeatureNormal = 43,
	kBottom = 1000,
}

AutoPopoutSource = {
	kOpenUrl = 1, --废弃，请用kEnterForeground
	kSceneEnter = 2, --普通进入homescene
	kEnterForeground = 3,
	kInitEnter = 4, --第一次进入homescene
	kTriggerPop = 5,--触发式强弹
	kGamePlayQuit = 6, --sub source,游戏场景切换回来
	kReturnFromFAQ = 7,
}

AutoPopoutState = {
	kIdle = 0,
	kChecking = 1,
	kPopout = 2,
	kWaiting = 3,
	kFinished = 4,
	kWaitClosePanel = 5,
	kPopCache = 6,
	kNextLevelMode = 7,
}

AutoPopoutConfig = {
	timeout = 5,--单个面板检测是否弹出timeout：s
	popActionTag = 20001,
	limit = {
		[AutoPopoutActionType.kTop] = 2,
		[AutoPopoutActionType.kOpenUrl] = 1,
		[AutoPopoutActionType.kNextLevelMode] = -1,
		[AutoPopoutActionType.kSubFeatureNotify] = 1,
		[AutoPopoutActionType.kSubFeatureSystem] = 2,
		[AutoPopoutActionType.kSubFeatureNormal] = 3,
		[AutoPopoutActionType.kActivity] = 1,
		[AutoPopoutActionType.kGuide] = 1,
	},

}

AutoPopoutSource.name = function (_, value)
	if _G.isLocalDevelopMode then
		for k,v in pairs(AutoPopoutSource) do
			if v == value then
				return k
			end
		end
		return "unkown"
	else
		return value
	end
end

AutoPopoutState.name = function (_, value)
	if _G.isLocalDevelopMode then
		for k,v in pairs(AutoPopoutState) do
			if v == value then
				return k
			end
		end
		return "unkown"
	else
		return value
	end
end