
require "zoo.scenes.component.HomeScene.popoutQueue.HomeScenePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.LoginSuccessPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdateSuccessPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdatePackagePopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UpdateDynamicPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.GivebackPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.RecallPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ActivityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OGCPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MarkPanelPopoutAction"
-- require "zoo.scenes.component.HomeScene.popoutQueue.LadyBugPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenActivityPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenBindingPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenLevelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.OpenCDKeyPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.MissionPanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.CollectInfoPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AlertNewLevelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.ClipBoardCheckPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.AnnouncementPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.UserCallBackPopoutAction"
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
require "zoo.scenes.component.HomeScene.popoutQueue.RankRacePanelPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.NewHeadFrameUnlockPopoutAction"
require "zoo.scenes.component.HomeScene.popoutQueue.CollectStarsPopoutAction"

local MAX = 2
local POP_ACT_MAX_NUM = 1
local POP_FEATRUE_MAX_NUM = 2

local TopActions = {
    --关卡闪退恢复
	ResumeGamePlayPopoutAction,
	-- 用户位置信息上传提示
	LocationPrivacyPopoutAction,
	--更新率优化 新版更新逻辑
	UpdatePackagePopoutNewAction,
	--Oppo游戏中心进入
	OGCPopoutAction,
	-- 更改画质
	ChooseGraphicQualityPopoutAction,
	-- 推荐好友
	FriendRecommendPopoutAction,

	AreaTaskTriggerPopoutAction,
}


local OpenUrlActions = {
	-- 通过链接打开活动面板
	OpenActivityPopoutAction,
	-- 通过链接打开社区绑定url
	OpenBindingPopoutAction,
	-- 通过链接打开对应关卡
	OpenLevelPopoutAction,
	-- 通过链接打开兑换码界面
	OpenCDKeyPanelPopoutAction	
}

local ActionPrioritys = {
	UpdateProfileAlertAction,
	-- 点击notification进入游戏
	NotificationEnterPopoutAction,
	-- 前置道具转换
	ExchangePrePropPopoutAction,
	-- 防沉迷
	FcmPopoutAction,
	-- 游戏公告Announcement 暂时放这里
	AnnouncementPopoutAction,
	-- SNS登录提示弹板
	LoginSuccessPopoutAction,
	--流失用户连登
	UserCallBackPopoutAction,

	-- -- 卡关、卡区流失用户召回
	RecallPopoutAction,
	-- 补偿面板
	GivebackPopoutAction,
	-- 豌豆荚SDK下线提示
	WDJRemovePopoutAction,
	-- mitalk SDK下线提示
	MiTalkRemovePopoutAction,
	-- 邀请好友有礼下线下线提示
	InviteFriendRewardRemovePopoutAction,
	-- 大版本更新面板
	UpdatePackagePopoutAction,
	-- 更新奖励面板
	UpdateSuccessPopoutAction,
	-- 动态更新面板
	UpdateDynamicPopoutAction,
	--有新的头像框解锁
	NewHeadFrameUnlockPopoutAction ,
    --SVIP
    SVIPGetPhonePopoutAction,
	--自动加好友
	ClipBoardCheckPopoutAction,
	-- 签到面板
	MarkPanelPopoutAction,
	--周赛每周开始强弹
	RankRacePanelPopoutAction,
	--星星储蓄罐
	StarBankPanelPopoutAction,
	-- 任务系统强弹
	MissionPanelPopoutAction,
	-- 瓢虫面板
	LadyBugPanelPopoutAction,
	-- 鼓励绑定账号
	BindAccountPopoutAction,
	-- 鼓励实名
	RealNamePopoutAction,
	-- 收集用户信息面板
	CollectInfoPopoutAction,
	-- 提醒玩家有新关卡
	AlertNewLevelPopoutAction,
	-- 活动强弹
	ActivityPopoutAction,
	--玩隐藏关引导
	-- PlayHiddenLevelGuide,
	-- 区域解锁面板强弹
	UnlockCloudPanelPopoutAction,
	-- 激励视频
	IncitePanelPopoutAction,
	--刷星活动是否要自动弹出来
	CollectStarsPopoutAction,
}
local ActionNames = {
	[UpdateProfileAlertAction] = "UpdateProfileAlertAction",
	[FcmPopoutAction] = "FcmPopoutAction",
	[AnnouncementPopoutAction] = "AnnouncementPopoutAction",
	[ResumeGamePlayPopoutAction]  = "ResumeGamePlayPopoutAction",
	[OpenActivityPopoutAction]  = "OpenActivityPopoutAction",
	[OpenBindingPopoutAction]	= "OpenBindingPopoutAction",
	[NewHeadFrameUnlockPopoutAction]	= "NewHeadFrameUnlockPopoutAction",
	[OpenLevelPopoutAction]		= "OpenLevelPopoutAction",
	[OpenCDKeyPanelPopoutAction]= "OpenCDKeyPanelPopoutAction",
	[LoginSuccessPopoutAction] 	= "LoginSuccessPopoutAction",
	[UserCallBackPopoutAction]  = "UserCallBackPopoutAction",
	[RecallPopoutAction]		= 'RecallPopoutAction',
	[GivebackPopoutAction] 		= 'GivebackPopoutAction',
	[WDJRemovePopoutAction] 	= 'WDJRemovePopoutAction',
	[MiTalkRemovePopoutAction] 	= 'MiTalkRemovePopoutAction',
	[InviteFriendRewardRemovePopoutAction] 	= 'InviteFriendRewardRemovePopoutAction',
	[UpdatePackagePopoutAction] = "UpdatePackagePopoutAction",
	[UpdateSuccessPopoutAction] = "UpdateSuccessPopoutAction",
	[UpdateDynamicPopoutAction] = "UpdateDynamicPopoutAction",
    [SVIPGetPhonePopoutAction] = "SVIPGetPhonePopoutAction",
	[ActivityPopoutAction] 		= "ActivityPopoutAction",
	[OGCPopoutAction] 			= "OGCPopoutAction",
	[MarkPanelPopoutAction]		= 'MarkPanelPopoutAction',
	[RankRacePanelPopoutAction] = 'RankRacePanelPopoutAction',
	-- [LadyBugPanelPopoutAction]  = 'LadyBugPanelPopoutAction',
	[MissionPanelPopoutAction]  = 'MissionPanelPopoutAction',
	[CollectInfoPopoutAction]	= 'CollectInfoPopoutAction',
	[AlertNewLevelPopoutAction] = 'AlertNewLevelPopoutAction',
	[ClipBoardCheckPopoutAction] = 'ClipBoardCheckPopoutAction',
	[BindAccountPopoutAction] = "BindAccountPopoutAction",
	[RealNamePopoutAction] = "RealNamePopoutAction",
	[IncitePanelPopoutAction] 	= "IncitePanelPopoutAction",
	-- [PlayHiddenLevelGuide] = "PlayHiddenLevelGuide",
	[ChooseGraphicQualityPopoutAction] = 'ChooseGraphicQualityPopoutAction',
	[UnlockCloudPanelPopoutAction] = 'UnlockCloudPanelPopoutAction',
	[NotificationEnterPopoutAction] = 'NotificationEnterPopoutAction',
	[ExchangePrePropPopoutAction] = 'ExchangePrePropPopoutAction',
	[FriendRecommendPopoutAction] = 'FriendRecommendPopoutAction',
	[UpdatePackagePopoutNewAction] = 'UpdatePackagePopoutNewAction',
	[AreaTaskTriggerPopoutAction] = 'AreaTaskTriggerPopoutAction',
	[LocationPrivacyPopoutAction] = 'LocationPrivacyPopoutAction',
	[CollectStarsPopoutAction]	= "CollectStarsPopoutAction",
}

-- kHomeScenePopoutNode = CocosObject:create()
HomeScenePopoutQueue = {}
function HomeScenePopoutQueue:reset( condition )
	self.actions = table.filter(self.actions or {},function(v) return v.isFixed end)
	-- 已经弹过的这次不算弹出次数
	table.each(self.actions,function( v ) 
		if v.hasPopout then v.isPlaceholder = true end 
	end)

	self.condition = condition
	self.preCondition = nil
end
HomeScenePopoutQueue:reset("enter")

-- action: 
--	Action.new():placeholder() 
--	Action.new(...)
function HomeScenePopoutQueue:insert(action, noPopRightNow)
	if not self:has(action.class) then
		table.insert(self.actions,action)
		if not noPopRightNow then 
			-- self:popoutIfNecessary(self.condition)
		end
	end
end

function HomeScenePopoutQueue:has( actionClass )
	return self:get(actionClass) ~= nil
end

function HomeScenePopoutQueue:remove( actionClass )
	self.actions = table.filter(self.actions,function(v) return v.class ~= actionClass end)
end

function HomeScenePopoutQueue:get( actionClass )
	return table.find(self.actions,function(v) return v.class == actionClass end)
end

function HomeScenePopoutQueue:checklimit(hasPopoutActions, action)
	local featureNum = 0
	local actNum = 0

	for _,a in ipairs(hasPopoutActions) do
		local isOpen = table.indexOf(OpenUrlActions, a.class) 	--open url活动不算强弹次数   
		if not isOpen and not a.isNoCountLimit then 
			if a:is(ActivityPopoutAction) then
				actNum = actNum + 1
			else
				featureNum = featureNum + 1
			end
		end
	end

	if action:is(ActivityPopoutAction) then
		return actNum >= POP_ACT_MAX_NUM
	else
		return featureNum >= POP_FEATRUE_MAX_NUM
	end
end

-- private
function HomeScenePopoutQueue:popoutIfNecessary( popoutCondition )
	if self.hasPopout then
		return
	end
	if PopoutQueue:sharedInstance():shouldStopHomeScenePopoutQueue() then
		PopoutQueue:sharedInstance():pushPopoutCondition( popoutCondition )
		return
	end

	local hasPopoutActions = table.filter(self.actions,function(v) return not v.isPlaceholder and v.hasPopout end)
	for i,actions in ipairs({TopActions, OpenUrlActions, ActionPrioritys}) do

		for ii,actionClass in ipairs(actions) do
			local action = self:get(actionClass)
			
			-- 优先级高的还没加进队列
			if not action then
				self:checkPopoutEnd()
				return
			end
			
			local isLimit = (i ~= 2) and self:checklimit(hasPopoutActions, action)
			local isRepeatForever = action.isRepeatForever

			if (not isLimit) or isRepeatForever then
				local isPlaceholder = action.isPlaceholder
				local hasPopout = table.find(hasPopoutActions,function(v) return v.class == actionClass end)
				local hasCondition = table.includes(action:getConditions(),popoutCondition)

				if not isPlaceholder and not hasPopout and hasCondition then
					kHomeScenePopoutNode:runAction(CCCallFunc:create(function( ... )
						if _G.isLocalDevelopMode then printx(0, "kHomeScenePopoutNode -> popout " .. popoutCondition .. " " .. tostring(ActionNames[action.class])) end
						action:popout()
					end, 
					'CCCallFunc_CreateLog: ' .. debug.traceback()
					))
					self.hasPopout = true
					action.hasPopout = true

					BroadcastManager:getInstance():unActive()

					return
				end
			end
		end
	end
	self:checkPopoutEnd()
end

-- private
function HomeScenePopoutQueue:next( preAction )
	self.hasPopout = false
	if _G.isLocalDevelopMode then printx(0, tostring(ActionNames[preAction.class]) .. " next") end

	if table.last(ActionPrioritys) == preAction.class then
		self:checkPopoutEnd(true)
		return
	end

	if preAction.isPlaceholder then
		self:popoutIfNecessary(self.preCondition or self.condition)
	else
		self.preCondition = "preActionNext"
		self:popoutIfNecessary("preActionNext")
	end
end

function HomeScenePopoutQueue:checkPopoutEnd(forceEnd)
	local hasPopoutActions = table.filter(self.actions,function(v)  return not v.isPlaceholder and v.hasPopout end)
	local isEnd = forceEnd or (#hasPopoutActions > 0)

	BroadcastManager:getInstance():active(isEnd)
	
	print("function HomeScenePopoutQueue:checkPopoutEnd isEnd = " , isEnd )

	if isEnd then
	--	PopoutQueue:sharedInstance():popAgain()
	else
		if not PushBindingLogic.isDataInit then
			PushBindingLogic:initData()
		end
	end
end


function HomeScenePopoutQueue:isComplete( ... )
	if self.hasPopout then
		return false
	end

	local hasPopoutActions = table.filter(self.actions,function(v) return not v.isPlaceholder and v.hasPopout end)
	
	if #hasPopoutActions >= POP_FEATRUE_MAX_NUM + POP_ACT_MAX_NUM then
		return true
	end

	for _,actionClass in ipairs(ActionPrioritys) do
		local action = self:get(actionClass)
		
		-- 优先级高的还没加进队列
		if not action then
			return false
		end
	end

	return true
end

function HomeScenePopoutQueue:printQueueLog( ... )
	local s = ""
	for _,v in pairs(self.actions) do
		local log = "no name"
		if ActionNames[v.class] then
			log = ActionNames[v.class]
		end

		if v.isPlaceholder then
			log = log .. " placeholder"
		end

		s = s..log.."\n"

		if _G.isLocalDevelopMode then printx(0, log) end
	end
	-- RemoteDebug:uploadLogWithTag('t---HomeScenePopoutQueue:printQueueLog()' ,s .. " -- "..debug.traceback())
end