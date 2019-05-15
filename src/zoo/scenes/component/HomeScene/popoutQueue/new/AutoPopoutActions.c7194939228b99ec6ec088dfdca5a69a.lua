--[[
 * AutoPopoutActions
 * @date    2018-08-01 11:09:32
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopoutConstant"

require "zoo.scenes.component.HomeScene.popoutQueue.HomeScenePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.LoginSuccessPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdateSuccessPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdatePackagePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdateDynamicPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.GivebackPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.RecallPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ActivityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OGCPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenActivityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenBindingWeChatPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenBindingPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenLevelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenCDKeyPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MissionPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.CollectInfoPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AlertNewLevelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ClipBoardCheckPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AnnouncementPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UserCallBackPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UserCallBack4To6PopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.BindAccountPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.RealNamePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.IncitePanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.PlayHiddenLevelGuide"
require "zoo.scenes.component.HomeScene.popoutQueue.ResumeGamePlayPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.WDJRemovePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MiTalkRemovePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ChooseGraphicQualityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.FcmPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.InviteFriendRewardRemovePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UnlockCloudPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.NotificationEnterPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ExchangePrePropPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.StarBankPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdateProfileAlertAction"
require "zoo.scenes.component.HomeScene.popoutQueue.FriendRecommendPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdatePackagePopoutNewAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AreaTaskTriggerPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.SVIPGetPhonePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.LocationPrivacyPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ModuleNoticeAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AchieveGuideAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenAskForHelpAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenUnlockAreaAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenWeekMatchAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenEnergyGiftAction"
require "zoo.scenes.component.HomeScene.popoutQueue.SVIPGetRewardAction"
require "zoo.scenes.component.HomeScene.popoutQueue.XFShareAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AreaTaskRewardPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.InfiniteEnergyGuideAction"
require "zoo.scenes.component.HomeScene.popoutQueue.PersonalInfoGuideAction"
require "zoo.scenes.component.HomeScene.popoutQueue.SheQuGuidePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MarkPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.IconCollectGuidePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.FLGOutboxPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.FLGInboxPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenFullStarRankAction"
require "zoo.scenes.component.HomeScene.popoutQueue.NDJActivityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.NotificationGuidePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UnlockBlockerAndPlayPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.RequireDiskSpaceAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AreaUnlockGuidePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ActivityCenterGuidePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.NewHeadFrameGuideAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AreaUnlockPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MinshengActivityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.QuestACTPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.GiftPackPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ClipBoardPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MiniProgramPromoteAction"

local TopActions = {
	--关卡闪退恢复
	ResumeGamePlayPopoutAction,
	--这不应该在强弹里面，弹的是广播,这是邪路，请不要模仿
	AreaTaskRewardPopoutAction,
	--用户位置信息上传提示
	LocationPrivacyPopoutAction,
	--not enough free disk space warning
	RequireDiskSpaceAction,
	--Oppo游戏中心进入
	OGCPopoutAction,
	--更改画质
	ChooseGraphicQualityPopoutAction,
}

local OpenUrlActions = {
	--微信小程序绑定
	OpenBindingWeChatPopoutAction,
	--社区绑定
	OpenBindingPopoutAction,
	--帮好友闯关
	OpenAskForHelpAction,
	--帮解锁
	OpenUnlockAreaAction,
	--送精力
	OpenEnergyGiftAction,
	--周赛领宝石
	OpenWeekMatchAction,
	--满星排行
	OpenFullStarRankAction,
	-- 通过链接打开活动面板
	OpenActivityPopoutAction,
}

local NextLevelModeActions = {
	--瓢虫任务
	LadyBugTaskPanelPopoutAction,
	--星星奖励
	StarRewardPanelPopoutAction,
	--新手礼包
	NewerGiftPanelPopoutAction,
	--触发签到
	MarkNoticePanelPopoutAction,
	--果树
	FruitTreeNoticePanelPopoutAction,
	--周赛
	WeeklyRaceTriggerPopoutAction,
	--限时闯关
	AreaTaskTriggerPopoutAction,
}

--功能面板分为通知，系统，普通功能3种，因为优先级是相互穿插的，所以需要指定actionType
local FeatureActions = {
	-- 点击notification进入游戏
	{AutoPopoutActionType.kSubFeatureNotify, NotificationEnterPopoutAction},
	--自动加好友
	{AutoPopoutActionType.kSubFeatureNormal, ClipBoardCheckPopoutAction},
	--7天回流用户连登
	{AutoPopoutActionType.kSubFeatureNormal, UserCallBackPopoutAction},
	--4~6天回流用户连登
	{AutoPopoutActionType.kSubFeatureNormal, UserCallBack4To6PopoutAction},
	-- 防沉迷
	{AutoPopoutActionType.kSubFeatureSystem, FcmPopoutAction},
	-- 鼓励实名
--	{AutoPopoutActionType.kSubFeatureSystem, RealNamePopoutAction},
	-- 游戏公告Announcement
	{AutoPopoutActionType.kSubFeatureSystem, AnnouncementPopoutAction},
	--微信登录使用昵称头像确认面板
	{AutoPopoutActionType.kSubFeatureSystem, UpdateProfileAlertAction},
	-- SNS登录提示弹板
	{AutoPopoutActionType.kSubFeatureSystem, LoginSuccessPopoutAction},
	-- 鼓励账号领奖面板
	{AutoPopoutActionType.kSubFeatureSystem, SVIPGetRewardAction},
	-- 补偿面板
	{AutoPopoutActionType.kSubFeatureSystem, GivebackPopoutAction},
	-- 大版本更新面板,老逻辑
	{AutoPopoutActionType.kSubFeatureSystem, UpdatePackagePopoutAction},
	-- 大版本更新面板,新逻辑
	{AutoPopoutActionType.kSubFeatureSystem, UpdatePackagePopoutNewAction},
	-- 鼓励账号绑定vip，半小时
--	{AutoPopoutActionType.kSubFeatureNormal, SVIPGetPhonePopoutAction},
	-- 更新奖励面板
	{AutoPopoutActionType.kSubFeatureSystem, UpdateSuccessPopoutAction},
	-- 动态更新面板
	{AutoPopoutActionType.kSubFeatureSystem, UpdateDynamicPopoutAction},
	--解锁新的头像框
	-- {AutoPopoutActionType.kSubFeatureSystem, NewHeadFrameUnlockPopoutAction},
	--满级红包 发送
	{AutoPopoutActionType.kSubFeatureNormal, FLGOutboxPopoutAction},
	--满星炫耀
	{AutoPopoutActionType.kSubFeatureNormal, XFShareAction},
	-- 鼓励绑定账号
--	{AutoPopoutActionType.kSubFeatureNormal, BindAccountPopoutAction},
	-- 签到面板
	{AutoPopoutActionType.kSubFeatureNormal, MarkPanelPopoutAction},
    -- 回流账号绑定面板
	{AutoPopoutActionType.kSubFeatureNormal, ClipBoardPopoutAction},

    --小程序推广领奖面板
    {AutoPopoutActionType.kSubFeatureNormal, MiniProgramPromoteAction},
    
	--满级红包 接收
	{AutoPopoutActionType.kSubFeatureNormal, FLGInboxPopoutAction},

	{AutoPopoutActionType.kSubFeatureNormal, QuestACTPopoutAction},
	--扭蛋机活动,走的是活动强弹
	-- {AutoPopoutActionType.kSubFeatureNormal, NDJActivityPopoutAction},
	-- 新关卡开启奔走相告面板
--	{AutoPopoutActionType.kSubFeatureNormal, AlertNewLevelPopoutAction},
	-- 区域解锁面板强弹
	{AutoPopoutActionType.kSubFeatureNormal, UnlockCloudPanelPopoutAction},
	--新障碍介绍面板，区域解锁后
	{AutoPopoutActionType.kSubFeatureNormal, UnlockBlockerAndPlayPopoutAction},
	--区域解锁
	{AutoPopoutActionType.kSubFeatureNormal, AreaUnlockPanelPopoutAction},
	--周赛每周开始强弹
	{AutoPopoutActionType.kSubFeatureNormal, RankRacePanelPopoutAction},
	--幸运精力瓶，推荐好友
	{AutoPopoutActionType.kSubFeatureNormal, FriendRecommendPopoutAction},
	--星星储蓄罐
	-- {AutoPopoutActionType.kSubFeatureNormal, StarBankPanelPopoutAction},
	--新手礼包
	{AutoPopoutActionType.kSubFeatureNormal, GiftPackPopoutAction},
	--限时闯关
	{AutoPopoutActionType.kSubFeatureNormal, AreaTaskNotFinishedFristPopoutAction},
	--各种通知
	{AutoPopoutActionType.kSubFeatureNormal, NotificationGuidePopoutAction},
	-- 激励视频
	{AutoPopoutActionType.kSubFeatureNormal, IncitePanelPopoutAction},

	--刷星活动的强弹检测 
	{AutoPopoutActionType.kActivity, CollectStarsPopoutAction},
	
}

local ActivityActions = {
	-- 活动强弹
	ActivityPopoutAction,
	-- minsheng
	MinshengActivityPopoutAction,
}

local GuideActions = {
	--活动收入活动中心引导
	ActivityCenterGuidePopoutAction,
	--社区引导
--	SheQuGuidePopoutAction,
	--成就引导
--	AchieveGuideAction,
	--新头像框引导
	NewHeadFrameGuideAction,
	--签到，果树，好友信件收进+号
	IconCollectGuidePopoutAction,
	--无限精力
	InfiniteEnergyGuideAction,
	--个人名片
	PersonalInfoGuideAction,
	--15,30解新区域引导
	AreaUnlockGuidePopoutAction,
}

return {
	{actionType = AutoPopoutActionType.kTop, 			actions = TopActions},
	{actionType = AutoPopoutActionType.kOpenUrl, 		actions = OpenUrlActions},
	{actionType = AutoPopoutActionType.kNextLevelMode, 	actions = NextLevelModeActions},

	{actionType = AutoPopoutActionType.kFeature, 		actions = FeatureActions},

	{actionType = AutoPopoutActionType.kActivity, 		actions = ActivityActions},
	{actionType = AutoPopoutActionType.kGuide, 			actions = GuideActions},
	{actionType = AutoPopoutActionType.kBottom, 		actions = {}},
}