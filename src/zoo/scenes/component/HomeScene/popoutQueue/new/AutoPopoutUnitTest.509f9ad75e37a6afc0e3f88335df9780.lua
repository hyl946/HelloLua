--[[
 * AutoPopoutUnitTest
 * @date    2018-08-03 10:20:08
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

AutoPopoutUnitTest = {}

local debugActions = {
	-- "UserCallBackPopoutAction",
	-- "UserCallBack4To6PopoutAction",
	-- "FcmPopoutAction",
	-- "ChooseGraphicQualityPopoutAction",
	-- "RealNamePopoutAction",
	-- "LoginSuccessPopoutAction",
	-- "SVIPGetRewardAction",
	-- "GivebackPopoutAction",
	-- "SVIPGetPhonePopoutAction",
	-- "UpdatePackagePopoutNewAction",
	-- "UpdateSuccessPopoutAction",
	-- "UpdateDynamicPopoutAction",
	-- "XFShareAction",
	-- "AlertNewLevelPopoutAction",
	-- "UnlockCloudPanelPopoutAction",
	-- "RankRacePanelPopoutAction",
	-- "FriendRecommendPopoutAction",
	-- "StarBankPanelPopoutAction",
	-- "AreaTaskTriggerPopoutAction",
	-- "ActivityPopoutAction",
	-- "FLGOutboxPopoutAction",
	-- "NotificationGuidePopoutAction",
	-- "UnlockBlockerAndPlayPopoutAction",
	-- "RequireDiskSpaceAction",
	-- "PersonalInfoGuideAction",
	-- "UpdateProfileAlertAction",
}

function AutoPopoutUnitTest:init()
	for id,action in pairs(AutoPopout.actions or {}) do
		if table.indexOf(debugActions, action.name) then
			action.debug = true
			-- action.checkRuntime = true
		end

		if action.recallUserNotPop then
			AutoPopout:print("recallUserNotPop:", action.name)
		end
	end

	self.testUrl = false
	self.testNotify = false
	
	self.testRecall = false
	self.isRecall = false

	self.testConfig = false

	if self.testConfig then
		AutoPopoutConfig = {
			timeout = 5,--单个面板检测是否弹出timeout：s
			popActionTag = 20001,
			limit = {
				[AutoPopoutActionType.kTop] = 0,
				[AutoPopoutActionType.kOpenUrl] = 1,
				[AutoPopoutActionType.kNextLevelMode] = -1,
				[AutoPopoutActionType.kSubFeatureNotify] = 1,
				[AutoPopoutActionType.kSubFeatureSystem] = 1,
				[AutoPopoutActionType.kSubFeatureNormal] = 1,
				[AutoPopoutActionType.kActivity] = 1,
				[AutoPopoutActionType.kGuide] = 20,
			},
		}
	end
end

function AutoPopoutUnitTest:cacheUrl(url)
	local no = ""
	local openEnergyGift = "happyanimal3://activity_wxshare/redirect?pid=he&uid=11335&actId=160"
	local askforhelp = "happyanimal3://askforhelp/redirect?wx=1&aaf=7&uid=43084&pid=apple&invitecode=472801039&ts=1533871028000&game_name=FriendLevel_help_link&levelId=1665&ask=1&from=singlemessage&isappinstalled=0&autodown=0&viral_id=1533610311557_17049"
	local full = "happyanimal3://fullstar_wxshare/redirect?uid=12345&pid=he&shareKey=testsharekey&inviteCode=123456789&actId=10086"
	local activity = "happyanimal3://activity_wxshare/redirect?aaf=5&actId=4020&share_key=2089689030_0_1_17757&pid=he&uid=2089689030&invitecode=6123126321&game_name=qixi_2018_1&shareKey=2089689030_0_1_17757&userName=消消乐玩家"
	local weekly = "happyanimal3://week_match_v2/redirect?uid=12345&pid=he&shareKey=testsharekey&inviteCode=123456789"
	
	local unlocak = "happyanimal3://activity_wxshare/redirect?sender=43569&pf=apple&cloudId=40112&plan=3&actId=10009&game_name=ios_unlock_help_3&from=groupmessage&viral_id=1534819208074_44654"
	
	local bind = "happyanimal3://open_binding/redirect?url=https%3A%2F%2Fff.happyelements.com%2Findex.php%2Fbind%2Fwx%2F1001%2FosxUQuAYN4_xvhKRyjv7ArRXZ_gA%3Ffrom%3D2%26redirect%3D"
	local testu = bind


	if self.testUrl then
		return testu
	else
		return url
	end
end

function AutoPopoutUnitTest:isRecallUser(ret)
	if self.testRecall then
		return self.isRecall
	else
		return ret
	end
end

function AutoPopoutUnitTest:cacheNotify(para)
	local t = "{\"type\":\"server\",\"typeId\":\"43062-1533724593812-20000\",\"textId\":\"0\",\"timeStamp\":1533724593812,\"rewards\":\"14:1\"}"
	if self.testNotify then
		return t
	else
		return para
	end
end